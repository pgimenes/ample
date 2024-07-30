
import numpy as np
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
        self.num_layers = self.count_layers()
        weights_list = [0]*self.num_layers
        #Used to change adj list between layers
        adj_list = [0]*self.num_layers # Change name perhaps to layer offset adj
        self.offsets = {'adj_list': adj_list, 'scale_factors': 0, 'in_messages':0, 'weights':weights_list, 'out_messages':0}
        
        self.dump_file = os.path.join(base_path, dump_file)

    def map (self):
        logging.debug(f"Mapping memory contents.")
        self.memory_hex = []
        self.map_adj_list()
        self.map_scale_factors()
        self.map_in_messages()
        self.map_weights()

    def map_adj_list(self):
        #Dynamically change adj list between layers
        for idx,layer in enumerate(self.model.layers):
            # If there is a linear layer, add another adjacency list to point to the address of the features of a nodes own embedding

            if isinstance(layer, Linear):
                for node in self.graph.nodes:
                    if (idx ==0):
                        #Setting address without layer offset
                        self.graph.nodes[node]["meta"]['adjacency_list_address'] = len(self.memory_hex)
                
                    self.memory_hex += int_list_to_byte_list(self.graph.nodes[node]["meta"]['self_ptr'], align=True, alignment=64, pad_side="right")
            else:
                for node in self.graph.nodes:
                    if (idx ==0):
                        self.graph.nodes[node]["meta"]['adjacency_list_address'] = len(self.memory_hex)
                 
                    self.memory_hex += int_list_to_byte_list(self.graph.nodes[node]["meta"]['neighbour_message_ptrs'], align=True, alignment=64, pad_side="right")
            
            if(idx < self.num_layers-1):
                self.offsets['adj_list'][idx+1] = len(self.memory_hex)

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



    # def map_out_messages(self):
    #     #    Set offset for next memory range
    #     self.offsets['out_messages'][0] = len(self.memory_hex)
    #     #Assuming constant feature width
    #     size_messages = self.offsets['weights'][0]  -self.offsets['in_messages'] 

    #     self.offsets['out_messages'] = len(self.memory_hex)

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
        current_length = len(input_list)
        if current_length < target_length:
            padding_length = target_length - current_length
            input_list.extend([0] * padding_length)
        return input_list
    

    def count_layers(self):
        count = 0
        for module in self.model.modules():
            if isinstance(module, (torch.nn.Conv2d, torch.nn.Linear,GCNConv,GINConv,SAGEConv)):
                count += 1
        return count
    

    def contains_linear_layer(self):
        for layer in self.model.modules():
            if isinstance(layer, torch.nn.Linear):
                return True
        return False

        