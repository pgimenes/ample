import numpy as np
import struct
import math
import json
import os

class InitManager:

    def __init__(self, graph, base_path="config_files", nodeslot_dump_file="nodeslot_programming.json", layer_config_file="layer_config.json", memory_dump_file="memory.mem", graph_dump_file="graph_dump.txt"):
        # Adjacency list, incoming messages and weights are pulled from the TrainedGraph object
        self.trained_graph = graph
        self.trained_graph.init_nx_graph()

        # List of hex bytes
        self.memory_hex = []

        self.offsets = {'adj_list': 0, 'scale_factors': 0, 'in_messages':0, 'weights':0, 'out_messages':0}

        # Adjacency list
        self.node_ids, self.node_offsets = np.unique(self.trained_graph.dataset.edge_index[0], return_index=True)

        # Create directory for output files
        os.makedirs(base_path, exist_ok=True)

        # Memory dump
        self.memory_dump_file = os.path.join(base_path, memory_dump_file)
        self.graph_dump_file = os.path.join(base_path, graph_dump_file)

        # Layer configuration
        self.layer_config_file = os.path.join(base_path, layer_config_file)
        self.layer_config = {'global_config': {}, 'layers': []}

        # Nodeslot programming
        self.nodeslot_dump_file = os.path.join(base_path, nodeslot_dump_file)
        self.nodeslot_programming = {'nodeslots':[]}

    # Memory initialization
    # ===============================================

    def map_memory(self):
        self.memory_hex = []
        self.map_adj_list()
        self.map_scale_factors()
        self.map_in_messages()
        self.map_weights()

    def map_adj_list(self):
        for node in self.trained_graph.nx_graph.nodes:
            self.trained_graph.nx_graph.nodes[node]['adjacency_list_address'] = len(self.memory_hex)
            self.memory_hex += self.int_list_to_byte_list(self.trained_graph.nx_graph.nodes[node]['neighbours'], align=True, alignment=64)

        # Set offset for next memory range
        self.offsets['scale_factors'] = len(self.memory_hex)

    def map_scale_factors(self):
        for node in self.trained_graph.nx_graph.nodes:
            self.trained_graph.nx_graph.nodes[node]['scale_factors_address'] = len(self.memory_hex)
            self.memory_hex += self.float_list_to_byte_list(self.trained_graph.nx_graph.nodes[node]['scale_factors'], align=True, alignment=64, pad_side='left')
        
        # Set offset for next memory range
        self.offsets['in_messages'] = len(self.memory_hex)

    def map_in_messages(self):
        for node in self.trained_graph.nx_graph.nodes:
            self.memory_hex += self.float_list_to_byte_list(self.trained_graph.embeddings[node], align=True, alignment=64)
        
        # Set offset for next memory range
        self.offsets['weights'] = len(self.memory_hex)

    def map_weights(self):
        for outf in range(self.trained_graph.feature_count):
            self.memory_hex += self.float_list_to_byte_list(self.trained_graph.weights[outf], align=True, alignment=64)

        # Set offset for next memory range
        self.offsets['out_messages'] = len(self.memory_hex)

    def dump_memory(self):
        with open(self.memory_dump_file, 'w') as file:
            for i in range(len(self.memory_hex)//64):
                file.write(''.join(self.memory_hex[i*64:(i+1)*64]))
                file.write('\n')
            file.write(''.join(self.memory_hex[64*(len(self.memory_hex)//64):]))
            file.write('\n')

    # Nodeslot programming and layer configuration
    # ===============================================

    def set_layer_config(self):
        self.layer_config['global_config']['layer_count'] = 1
        layer = {
            'in_feature_count': self.trained_graph.feature_count,
            'out_feature_count': self.trained_graph.feature_count,

            'transformation_activation': self.trained_graph.transformation_activation,
            'leaky_relu_alpha': self.trained_graph.leaky_relu_alpha,
            'transformation_bias': self.trained_graph.transformation_bias,

            'dequantization_parameter': self.trained_graph.dequantization_parameter,
            
            'adjacency_list_address': self.offsets['adj_list'],
            'in_messages_address': self.offsets['in_messages'],
            'weights_address': self.offsets['weights'],
            'out_messages_address': self.offsets['out_messages']
        }
        self.layer_config['layers'].append(layer)

    def program_nodeslots(self, ignore_isolated_nodes=False):
        for node in self.trained_graph.nx_graph.nodes:
            nb_cnt = self.trained_graph.nx_graph.nodes[node]['neighbour_count']
            # if (nb_cnt > 64):
            #     print(f"node {node} has neighbour count {nb_cnt}")
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
                        
                        'out_messages_address_lsb': self.offsets['out_messages'] + node * self.trained_graph.feature_count * 4,
                        'out_messages_address_msb': 0
                        }
            self.nodeslot_programming['nodeslots'].append(nodeslot)

    def dump_json(self):
        # Re-initializize layer config and nodeslot programming
        self.layer_config = {'global_config': {}, 'layers': []}
        self.nodeslot_programming = {'nodeslots':[]}
        self.set_layer_config()
        self.program_nodeslots()

        with open(self.nodeslot_dump_file, 'w') as file:
            json.dump(self.nodeslot_programming, file, indent=4)
        with open(self.layer_config_file, 'w') as file:
            json.dump(self.layer_config, file, indent=4)

    # Memory initialization utilities
    # ===============================================

    def int_list_to_byte_list(self, in_list, align=False, alignment=None):
        '''
        Convert to list of bytes in hex
        '''
        in_list = [0] if (in_list == []) else in_list
        memory_hex = np.array([f"{dest_node:08x}" for dest_node in in_list])
        memory_hex = [s[i:i+2] for s in memory_hex for i in range(0, 8, 2)]
        if (align and alignment is not None):
            zeros = (alignment - len(memory_hex) % alignment)
            zeros = 0 if (zeros == 64) else zeros
            memory_hex += ['00'] * zeros
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
    
    # Graph info for debugging
    # ===============================================

    def dump_txt(self):
        with open(self.graph_dump_file, 'w') as file:
            file.write(f"out_messages_offset = {self.offsets['out_messages']};")
            file.write("\n")
            
            file.write("adj_list = '{")
            file.write(str(self.trained_graph.dataset.edge_index[1])[1:-1])
            file.write("};")
            file.write("\n")

            file.write("node_offsets = '{")
            file.write(str(self.trained_graph.node_offsets)[1:-1])
            file.write("};")
            file.write("\n")

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
