import numpy as np

import json
import os
import torch
from .utilities import dump_byte_list, binary_to_hex

from sdk.memory_mapper import Memory_Mapper

import logging

from tqdm import tqdm

class InitManager:

    def __init__(self, 
                    graph, 
                    model, 
                    base_path="config_files", 
                    nodeslot_json_dump_file="nodeslot_programming.json", 
                    layer_config_file="layer_config.json", 
                    nodeslot_mem_dump_file="nodeslots.mem", 
                    memory_dump_file="memory.mem", 
                    debug_dump_file="graph_dump.txt"
                ):
        # Adjacency list, incoming messages and weights are pulled from the TrainedGraph object
        self.trained_graph = graph
        self.model = model
        
        self.memory_mapper = Memory_Mapper(graph.nx_graph, model, base_path=base_path, dump_file=memory_dump_file)

        # Create directory for output files
        os.makedirs(base_path, exist_ok=True)

        # Paths
        self.memory_dump_file = os.path.join(base_path, memory_dump_file)
        self.layer_config_file = os.path.join(base_path, layer_config_file)
        self.nodeslot_json_dump_file = os.path.join(base_path, nodeslot_json_dump_file)
        self.nodeslot_mem_dump_file = os.path.join(base_path, nodeslot_mem_dump_file)
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
        self.layer_config['global_config'] = {
            "layer_count": len(self.model.layers),
            "node_count": self.trained_graph.dataset.x.shape[0]
        }
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
        
        # Cull nodes to make mod 4 = 0
        mod = len(self.nodeslot_programming['nodeslots']) % 4
        if mod > 0:
            self.nodeslot_programming['nodeslots'] = self.nodeslot_programming['nodeslots'][:-mod]

    def generate_nodeslots_mem(self):
        node_groups = np.array(self.nodeslot_programming["nodeslots"])
        
        node_groups = np.pad(
                                node_groups, 
                                (0, 8 - node_groups.shape[0] % 8), 
                                "constant", 
                                constant_values=None
                            ).reshape(-1, 8)
        
        nodeslot_mem_hex = []

        for group in tqdm(node_groups):
            # print(f"group {group_idx}/{len(node_groups)}")
            assert(len(group) == 8)
            str_lst = []
            for nodeslot in group:
                if (nodeslot is None) or (nodeslot['neighbour_count'] == 0):
                    str_lst.append("0"*64)
                    continue
                str = ""
                str = f"{nodeslot['neighbour_count']:20b}{nodeslot['node_id']:20b}" + str
                str = "00" + str
                str = "1" + "0"*21 + str
                str = str.replace(" ", "0")
                str_lst.append(str)
            
            str = "".join(str_lst[::-1])
            hex = binary_to_hex(str).zfill(128)
            nodeslot_mem_hex += "".join(hex)
        
        assert (len(nodeslot_mem_hex) % 2 == 0)
        nmh = [nodeslot_mem_hex[i] + nodeslot_mem_hex[i+1] for i in range(0, len(nodeslot_mem_hex), 2)]
        return nmh

    def dump_nodeslot_programming(self):
        self.nodeslot_programming = {'nodeslots':[]}
        self.program_nodeslots()

        with open(self.nodeslot_json_dump_file, 'w') as file:
            json.dump(self.nodeslot_programming, file, indent=4)

        # Dump nodeslots.mem file
        nodeslot_byte_list = self.generate_nodeslots_mem()
        dump_byte_list(nodeslot_byte_list, self.nodeslot_mem_dump_file)


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
