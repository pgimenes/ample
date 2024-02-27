import numpy as np

import json
import os
import torch

from sdk.memory_mapper import Memory_Mapper

import logging

class InitManager:

    def __init__(self, graph, model, base_path="config_files", nodeslot_dump_file="nodeslot_programming.json", layer_config_file="layer_config.json", memory_dump_file="memory.mem", debug_dump_file="graph_dump.txt"):
        # Adjacency list, incoming messages and weights are pulled from the TrainedGraph object
        self.trained_graph = graph
        self.model = model
        
        self.memory_mapper = Memory_Mapper(graph.nx_graph, model, base_path=base_path, dump_file=memory_dump_file)

        # Create directory for output files
        os.makedirs(base_path, exist_ok=True)

        # Paths
        self.memory_dump_file = os.path.join(base_path, memory_dump_file)
        self.layer_config_file = os.path.join(base_path, layer_config_file)
        self.nodeslot_dump_file = os.path.join(base_path, nodeslot_dump_file)
        self.debug_dump_file = os.path.join(base_path, debug_dump_file)
        self.updated_embeddings_file = os.path.join(base_path, 'updated_embeddings.csv')

        # Layer configuration
        self.layer_config = {'global_config': {}, 'layers': []}

        # Nodeslot programming
        self.nodeslot_programming = {'nodeslots':[]}

    # Nodeslot programming and layer configuration
    # ===============================================

    def set_layer_config(self):
        logging.debug(f"Generating layer configuration.")

        self.layer_config['global_config']['layer_count'] = len(self.model.layers)
        for layer in self.model.layers:
            layer = {
                'in_feature_count': layer.in_channels,
                'out_feature_count': layer.out_channels,

                'transformation_activation': 0,
                'leaky_relu_alpha': 0,
                'transformation_bias': 0 if torch.all(layer.bias == 0) else layer.bias[0].item(),

                'dequantization_parameter': self.trained_graph.dequantization_parameter,
                
                'adjacency_list_address': self.memory_mapper.offsets['adj_list'],
                'in_messages_address': self.memory_mapper.offsets['in_messages'],
                'weights_address': self.memory_mapper.offsets['weights'],
                'out_messages_address': self.memory_mapper.offsets['out_messages'],

                'aggregation_wait_count': 4,
                'transformation_wait_count': 4
            }
            self.layer_config['layers'].append(layer)

    def dump_layer_config (self):
        self.layer_config = {'global_config': {}, 'layers': []}
        self.set_layer_config()
        
        with open(self.layer_config_file, 'w') as file:
            json.dump(self.layer_config, file, indent=4)

    def program_nodeslots(self, ignore_isolated_nodes=False):
        logging.debug(f"Generating nodeslot programming.")

        dense_nodes = []
        avg_nb_cnt = 0
        for node in self.trained_graph.nx_graph.nodes:
            nb_cnt = self.trained_graph.nx_graph.nodes[node]['neighbour_count']
            avg_nb_cnt += nb_cnt
            if (nb_cnt > 256):
                # print(f"node {node} has neighbour count {nb_cnt}, dropping")
                dense_nodes.append(node)
                continue
            if (ignore_isolated_nodes and nb_cnt == 0):
                continue
            nodeslot = {'node_id' : node,
                        'neighbour_count': nb_cnt,
                        'precision': self.trained_graph.nx_graph.nodes[node]['precision'],
                        'aggregation_function': self.trained_graph.nx_graph.nodes[node]['aggregation_function'],
                        
                        'adjacency_list_address_lsb': self.trained_graph.nx_graph.nodes[node]['adjacency_list_address'],
                        'adjacency_list_address_msb': 0,
                        
                        'scale_factors_address_lsb': self.trained_graph.nx_graph.nodes[node]['scale_factors_address'],
                        'scale_factors_address_msb': 0,
                        
                        'out_messages_address_lsb': self.memory_mapper.offsets['out_messages'] + node * self.trained_graph.feature_count * 4,
                        'out_messages_address_msb': 0
                        }
            self.nodeslot_programming['nodeslots'].append(nodeslot)
        print(f"dense node count {len(dense_nodes)}")
        avg_nb_cnt = avg_nb_cnt / len(self.trained_graph.nx_graph.nodes)
        print(f"Average neighbour count {avg_nb_cnt}")


    def dump_nodeslot_programming(self):
        self.nodeslot_programming = {'nodeslots':[]}
        self.program_nodeslots()

        with open(self.nodeslot_dump_file, 'w') as file:
            json.dump(self.nodeslot_programming, file, indent=4)

    def dump_memory(self):
        self.memory_mapper.dump_memory()

    # Generate feature embedding expectation
    # ===============================================

    def embedding_expectation(self):
        self.model.eval()
        with torch.no_grad():
            embeddings = self.trained_graph.dataset.x
            output = self.model(self.trained_graph.dataset.x, self.trained_graph.dataset.edge_index)
        np.savetxt(self.updated_embeddings_file, output.numpy(), delimiter=',')

    # Sampling
    # ===============================================
    
    def reduce_graph(self):
        self.trained_graph.reduce()

    # Graph info for debugging
    # ===============================================

    def debug_dump(self):
        with open(self.debug_dump_file, 'w') as file:
            for idx, node in enumerate(self.trained_graph.embeddings):
                file.write(f"embeddings[{idx}] = ")
                file.write("'{")
                file.write(str(node.tolist())[1:-1])
                file.write("};")
                file.write("\n")

            for idx, feature in enumerate(self.trained_graph.weights):
                file.write(f"weights[{idx}] = ")
                file.write("'{")
                file.write(str(feature.tolist())[1:-1])
                file.write("};")
                file.write("\n")

    # def dump_weights(self):
    #     for idx, feature in enumerate(self.trained_graph.weights):
