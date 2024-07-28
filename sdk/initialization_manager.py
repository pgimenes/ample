import numpy as np

import json
import os
import torch
from .utilities import dump_byte_list, binary_to_hex

from sdk.memory_mapper import Memory_Mapper

import logging

from tqdm import tqdm
from copy import deepcopy

from torch.nn import Linear
from torch_geometric.nn import GCNConv, GINConv, SAGEConv

from .models.models import GraphSAGE_Model

import math

data_width = 64

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
        self.model_layer_max_features = max([self.get_feature_counts(self.model)])
        # Nodeslot programming
        self.nodeslot_programming = {'nodeslots':[]}

    # Nodeslot programming and layer configuration
    # ===============================================

    def get_layer_feature_count(self, layer):
        if isinstance(layer, GCNConv):
            inc = layer.in_channels
            outc = layer.out_channels
        elif isinstance(layer, GINConv):
            inc = layer.nn.in_features
            outc = layer.nn.out_features
        elif isinstance(layer, SAGEConv):
            inc = layer.in_channels
            outc = layer.out_channels
        elif isinstance(layer, Linear):
            inc = layer.in_features
            outc = layer.out_features
        else:
            raise RuntimeError(f"Unrecognized layer type {type(layer)}")        
        return inc, outc
    
    def get_default_layer_config(self, layer,idx):
        print('layer setup idx', idx)
        print('adj offsets', self.memory_mapper.offsets['adj_list'])
        inc, outc = self.get_layer_feature_count(layer)
        if isinstance(layer, torch.nn.Linear):
            aggregate_enable = 0
        else:
            aggregate_enable = 1
        #Multi-layer support - out messages become in messages for next layer
        if idx >0: 
            in_messages_address = self.memory_mapper.offsets['out_messages']#Can change this to have intermediate out messages (['out_messages'][idx-1])
        else:
            in_messages_address= self.memory_mapper.offsets['in_messages']
        return {
            'nodeslot_count': len(self.trained_graph.nx_graph.nodes),
            'in_feature_count': inc,
            'out_feature_count': outc,
            'transformation_activation': 0,
            'leaky_relu_alpha': 0,
            'transformation_bias': 0,
            'dequantization_parameter': self.trained_graph.dequantization_parameter,
            'adjacency_list_address': self.memory_mapper.offsets['adj_list'][idx],
            'in_messages_address': in_messages_address, 
            'weights_address': self.memory_mapper.offsets['weights'][idx],
            'out_messages_address': self.memory_mapper.offsets['out_messages'],
            'aggregation_wait_count': 4,
            'transformation_wait_count': 4,
            'aggregate_enable' : aggregate_enable,
        }
        print(idx)

    def set_layer_config_graphsage(self):
        # 4 layers per actual SAGEConv layer
        self.layer_config["global_config"]["layer_count"] = len(self.model.layers) * 4

        for layer in self.model.layers:
            l1 = self.get_default_layer_config(layer)
            l1["transformation_wait_count"] = 16
            self.layer_config['layers'].append(l1)
            
            l2 = self.get_default_layer_config(layer)
            l2["transformation_wait_count"] = 16
            self.layer_config['layers'].append(l2)

            l3 = self.get_default_layer_config(layer)
            self.layer_config['layers'].append(l3)

            l4 = self.get_default_layer_config(layer)
            self.layer_config['layers'].append(l4)

    def set_layer_config(self):
        logging.info(f"Generating layer configuration.")

        self.layer_config['global_config'] = {
            "layer_count": len(self.model.layers),
            "node_count": self.trained_graph.dataset.x.shape[0]
        }

        if (isinstance(self.model, GraphSAGE_Model)):
            self.set_layer_config_graphsage()
        else :
            # Default layer configuration
            for idx,layer in enumerate(self.model.layers):
                layer = self.get_default_layer_config(layer,idx)
                self.layer_config['layers'].append(layer)

    def dump_layer_config (self):
        self.layer_config = {'global_config': {}, 'layers': []}
        self.set_layer_config()
        
        with open(self.layer_config_file, 'w') as file:
            json.dump(self.layer_config, file, indent=4)

    def get_default_nodeslot(self, node_id):
        return {
                'node_id' : node_id,
                'neighbour_count': self.trained_graph.nx_graph.nodes[node_id]["meta"]['neighbour_count'],
                'precision': self.trained_graph.nx_graph.nodes[node_id]["meta"]['precision'],
                'aggregation_function': self.trained_graph.nx_graph.nodes[node_id]["meta"]['aggregation_function'],
                'adjacency_list_address_lsb': self.trained_graph.nx_graph.nodes[node_id]["meta"]['adjacency_list_address'],
                'adjacency_list_address_msb': 0,
                'scale_factors_address_lsb': self.trained_graph.nx_graph.nodes[node_id]["meta"]['scale_factors_address'],
                'scale_factors_address_msb': 0,
                'out_messages_address_lsb': self.memory_mapper.offsets['out_messages'] + node_id * self.calc_axi_addr(self.trained_graph.feature_count),
                'out_messages_address_msb': 0
            }

    def program_nodeslots_graphsage(self):
        # Layer 1: W1 projection
        for node in self.trained_graph.nx_graph.nodes:
            nodeslot = self.get_default_nodeslot(node)
            nodeslot["neighbour_count"] = 1
            self.nodeslot_programming['nodeslots'].append(nodeslot)

        # Layer 2: W3 projection
        for node in self.trained_graph.nx_graph.nodes:
            nodeslot = self.get_default_nodeslot(node)
            nodeslot["neighbour_count"] = 1
            self.nodeslot_programming['nodeslots'].append(nodeslot)

        # Layer 3: mean aggregation + W2 transformation
        for node in self.trained_graph.nx_graph.nodes:
            nodeslot = self.get_default_nodeslot(node)
            self.nodeslot_programming['nodeslots'].append(nodeslot)

        # Layer 4: sum aggregation result with residual
        for node in self.trained_graph.nx_graph.nodes:
            nodeslot = self.get_default_nodeslot(node)
            nodeslot["neighbour_count"] = 2
            nodeslot["aggregation_function"] = "SUM"
            self.nodeslot_programming['nodeslots'].append(nodeslot)

    def program_nodeslots(self, ignore_isolated_nodes=True):
        logging.info(f"Generating nodeslot programming.")
        
        if (isinstance(self.model, GraphSAGE_Model)):
            self.program_nodeslots_graphsage()
        else:
            dense_nodes = []
            for node in self.trained_graph.nx_graph.nodes:
                nb_cnt = self.trained_graph.nx_graph.nodes[node]["meta"]['neighbour_count']
                if (ignore_isolated_nodes and nb_cnt == 0):
                    continue
                if (nb_cnt > 256):
                    dense_nodes.append(node)
                    continue
                nodeslot = self.get_default_nodeslot(node)
                self.nodeslot_programming['nodeslots'].append(nodeslot)
            
            logging.debug(f"Dense node count: {len(dense_nodes)}")

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
        np.savetxt(self.updated_embeddings_file, (output[-1]).numpy(), delimiter=',')

    #Save JIT model for testbench
    def save_model(self):
        self.model.eval()
        x = self.trained_graph.dataset.x  # Node features tensor
        edge_index = self.trained_graph.dataset.edge_index  # Edge indices tensor

        #Traced Model - allow TB to be compatible with GCNConv
        jit_model = torch.jit.trace(self.model, (x, edge_index))
        #Non-traced model
        # jit_model = torch.jit.script(self.model).to('cpu')
        torch.jit.save(jit_model, 'model.pt')

        return jit_model

    
    #Save graph for testbench
    def save_graph(self):
        input_data = {
            'x': self.trained_graph.dataset.x,  
            'edge_index': self.trained_graph.dataset.edge_index  
        }

        torch.save({
            'input_data': input_data
        }, 'graph.pth')

    def calc_axi_addr(self,feature_count):
        return math.ceil(4*feature_count / data_width) * data_width
    
    # Function to get feature count of each layer
    def get_feature_counts(self,model):
        feature_counts = []
        for layer in model.modules():
            if isinstance(layer, torch.nn.Conv2d):
                feature_counts.append(layer.out_channels)
            elif isinstance(layer, torch.nn.Linear):
                feature_counts.append(layer.out_features)
        return feature_counts

    # Sampling
    # ===============================================
    
    def reduce_graph(self):
        self.trained_graph.reduce()
    
    def map(self):
        self.memory_mapper.map()