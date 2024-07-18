
import numpy as np
import struct
import logging
import os
from .utilities import int_list_to_byte_list, float_list_to_byte_list


import torch
from torch_geometric.nn import GCNConv, GINConv, SAGEConv
from torch.nn import Linear

class Memory_Mapper:

    def __init__(self, graph, model, base_path="config_files", dump_file="memory.mem"):
        self.graph = graph
        self.model = model
        self.memory_hex = []

        # weights_dict = {}
        # for idx in len(self.model.layers):
        #     weights_dict[str(idx)] = 0
        self.num_layers = self.count_layers(self.model)

        weights_list = [0]*self.num_layers

        self.offsets = {'adj_list': 0, 'scale_factors': 0, 'in_messages':0, 'weights':weights_list, 'out_messages':0}
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
#            self.memory_hex += int_list_to_byte_list([in_message_width* nd_ptr for nd_ptr in self.graph.nodes[node]["meta"]['neighbour_message_ptrs']], align=True, alignment=64, pad_side="right")

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
            #Need to add padding to align to 64 bytes
           # self.memory_hex += float_list_to_byte_list(self.pad_list(self.graph.nodes[node]["meta"]['embedding'],in_message_width), align=True, alignment=64)
            self.memory_hex += float_list_to_byte_list(self.graph.nodes[node]["meta"]['embedding'], align=True, alignment=64)

        # Set offset for next memory range
        self.offsets['weights'][0] = len(self.memory_hex)

    def map_weights(self):
        for idx,layer in enumerate(self.model.layers):
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
            if(idx < self.num_layers-1):
                self.offsets['weights'][idx+1] = len(self.memory_hex)

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

    def pad_list(self,input_list,target_length):
        """
        Pads the input_list with zeros until it reaches the target_length.
        
        :param input_list: List to be padded.
        :param target_length: Desired length of the list after padding.
        :return: Padded list.
        """

        # if type(input_list) is int:
        #     input_list= [input_list]
        # print(input_list)
        current_length = len(input_list)
        if current_length < target_length:
            # Calculate the number of zeros needed
            padding_length = target_length - current_length
            # Extend the list with zeros
            input_list.extend([0] * padding_length)
        return input_list
    

    def count_layers(self,model):
        count = 0
        for module in model.modules():
            if isinstance(module, (torch.nn.Conv2d, torch.nn.Linear,GCNConv,GINConv,SAGEConv)):
                count += 1
        return count