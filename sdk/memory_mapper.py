
import numpy as np
import struct
import logging
import os
from .utilities import int_list_to_byte_list, float_list_to_byte_list

from torch_geometric.nn import GCNConv, GINConv, SAGEConv
from torch.nn import Linear

class Memory_Mapper:

    def __init__(self, graph, model, base_path="config_files", dump_file="memory.mem"):
        self.graph = graph
        self.model = model
        self.memory_hex = []
        self.offsets = {'adj_list': 0, 'scale_factors': 0, 'in_messages':0, 'weights':0, 'out_messages':0}
        self.dump_file = os.path.join(base_path, dump_file)

    def map (self):
        logging.debug(f"Mapping memory contents.")
        self.memory_hex = []
        self.map_adj_list()
        self.map_scale_factors()
        self.map_in_messages()
        self.map_weights()

    def map_adj_list(self):
        for node in self.graph.nodes:
            self.graph.nodes[node]["meta"]['adjacency_list_address'] = len(self.memory_hex)
            self.memory_hex += int_list_to_byte_list(self.graph.nodes[node]["meta"]['neighbour_message_ptrs'], align=True, alignment=64, pad_side="right")

        # Set offset for next memory range
        self.offsets['scale_factors'] = len(self.memory_hex)

    def map_scale_factors(self):
        for node in self.graph.nodes:
            self.graph.nodes[node]["meta"]['scale_factors_address'] = len(self.memory_hex)
            if (self.graph.nodes[node]["meta"]['precision'] == 'FLOAT_32'):
                self.memory_hex += float_list_to_byte_list(self.graph.nodes[node]["meta"]['scale_factors'], align=True, alignment=64, pad_side='left')
            else:
                self.memory_hex += int_list_to_byte_list(self.graph.nodes[node]["meta"]['scale_factors'], align=True, alignment=64, pad_side='left')
        
        # Set offset for next memory range
        self.offsets['in_messages'] = len(self.memory_hex)

    def map_in_messages(self):
        for node in self.graph.nodes:
            self.memory_hex += float_list_to_byte_list(self.graph.nodes[node]["meta"]['embedding'], align=True, alignment=64)
        
        # Set offset for next memory range
        self.offsets['weights'] = len(self.memory_hex)

    def map_weights(self):
        for layer in self.model.layers:
            if isinstance(layer, GCNConv):
                linear = layer.lin
            elif isinstance(layer, GINConv):
                linear = layer.nn
            elif isinstance(layer, SAGEConv):
                linear = layer.lin_l
            elif isinstance(layer, Linear):
                linear = layer
            else:
                raise RuntimeError(f"Unrecognized layer {layer}")
            
            out_feature_count = linear.weight.shape[0]

            for outf in range(out_feature_count):
                self.memory_hex += float_list_to_byte_list(linear.weight[outf], align=True, alignment=64)

        # Set offset for next memory range
        self.offsets['out_messages'] = len(self.memory_hex)

    # Dump
    # ===============================================

    def dump_memory(self):
        with open(self.dump_file, 'w') as file:
            for i in range(len(self.memory_hex)//64):
                file.write(''.join(self.memory_hex[i*64:(i+1)*64]))
                file.write('\n')
            file.write(''.join(self.memory_hex[64*(len(self.memory_hex)//64):]))
            file.write('\n')