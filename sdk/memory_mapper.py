
import numpy as np
import struct
import logging
import os

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
            self.graph.nodes[node]['adjacency_list_address'] = len(self.memory_hex)
            self.memory_hex += self.int_list_to_byte_list(self.graph.nodes[node]['neighbour_message_ptrs'], align=True, alignment=64, pad_side="right")

        # Set offset for next memory range
        self.offsets['scale_factors'] = len(self.memory_hex)

    def map_scale_factors(self):
        for node in self.graph.nodes:
            self.graph.nodes[node]['scale_factors_address'] = len(self.memory_hex)
            if (self.graph.nodes[node]['precision'] == 'FLOAT_32'):
                self.memory_hex += self.float_list_to_byte_list(self.graph.nodes[node]['scale_factors'], align=True, alignment=64, pad_side='left')
            else:
                self.memory_hex += self.int_list_to_byte_list(self.graph.nodes[node]['scale_factors'], align=True, alignment=64, pad_side='left')
        
        # Set offset for next memory range
        self.offsets['in_messages'] = len(self.memory_hex)

    def map_in_messages(self):
        for node in self.graph.nodes:
            self.memory_hex += self.float_list_to_byte_list(self.graph.nodes[node]['embedding'], align=True, alignment=64)
        
        # Set offset for next memory range
        self.offsets['weights'] = len(self.memory_hex)

    def map_weights(self):
        for layer in self.model.layers:
            out_feature_count = layer.lin.weight.shape[0]
            for outf in range(out_feature_count):
                self.memory_hex += self.float_list_to_byte_list(layer.lin.weight[outf], align=True, alignment=64)

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

    # Utilities
    # ===============================================

    def int_list_to_byte_list(self, in_list, align=False, alignment=None, pad_side='right'):
        '''
        Convert to list of bytes in hex
        '''
        memory_hex, new_elements = [], []
        in_list = [0] if (in_list == []) else in_list

        new_elements = np.array([f"{dest_node:08x}" for dest_node in in_list])
        new_elements = [s[i:i+2] for s in new_elements for i in range(0, 8, 2)]

        if (align and alignment is not None):
            zeros = (alignment - len(new_elements) % alignment)
            zeros = 0 if (zeros == 64) else zeros

            if (pad_side == 'right'):
                memory_hex = new_elements + ['00'] * zeros
            elif (pad_side == 'left'):
                memory_hex = ['00'] * zeros + new_elements

        return memory_hex

    def float_list_to_byte_list(self, in_list, align=False, alignment=None, pad_side='right'):
        
        hex_list, new_elements = [], []

        new_elements = [struct.pack('!f', i).hex() for i in in_list]
        new_elements = [s[i:i+2] for s in new_elements for i in range(0, 8, 2)]
        if (align and alignment is not None):
            zeros = (alignment - len(new_elements) % alignment)
            zeros = 0 if (zeros == 64) else zeros
            if (pad_side == 'right'):
                hex_list = new_elements + ['00'] * zeros
            elif (pad_side == 'left'):
                hex_list = ['00'] * zeros + new_elements
        return hex_list