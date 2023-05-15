import numpy as np
import struct
import math
import json
import os

class InitManager:

    def __init__(self, graph, nodeslot_dump_file="nodeslot_programming.json", layer_config_file="layer_config.json", memory_dump_file="memory.mem", graph_dump_file="graph_dump.txt"):
        # Adjacency list, incoming messages and weights are pulled from the TrainedGraph object
        self.trained_graph = graph

        # List of hex bytes
        self.memory_hex = []

        self.offsets = [0]
        # Adjacency list has range: 0 -> edge_count * 4
        self.offsets.append(self.required_bytes_with_padding(bytes_required=len(4 * self.trained_graph.dataset.edge_index[0]) ))
        # Incoming messages have range: offsets[1] -> node_count * features_per_node * bytes_per_feature (float = 4)
        self.offsets.append(self.offsets[1] + self.required_bytes_with_padding(len(self.trained_graph.nx_graph.nodes) * self.trained_graph.feature_count * 4))
        # Weights have range: offsets[2] -> feature_count * feature_count * bytes_per_weight (float = 4)
        self.offsets.append(self.offsets[2] + self.trained_graph.feature_count**2 * 4)
        # Outgoing messages start at offsets [3]
        
        # Adjacency list
        self.node_ids, self.node_offsets = np.unique(self.trained_graph.dataset.edge_index[0], return_index=True)
        self.adj_list = self.trained_graph.dataset.edge_index[1]

        # Incoming messages
        self.in_messages = self.trained_graph.embeddings

        # Weights
        self.weights = self.trained_graph.weights

        # Create directory for output files
        os.makedirs("config_files", exist_ok=True)

        # Memory dump
        self.memory_dump_file = os.path.join("config_files", memory_dump_file)
        self.graph_dump_file = os.path.join("config_files", graph_dump_file)

        # Layer configuration
        self.layer_config_file = os.path.join("config_files", layer_config_file)
        self.layer_config = {'global_config': {}, 'layers': []}
        self.set_layer_config()

        # Nodeslot programming
        self.nodeslot_dump_file = os.path.join("config_files", nodeslot_dump_file)
        self.nodeslot_programming = {'nodeslots':[]}
        self.program_nodeslots()

    def dump_json(self):
        with open(self.nodeslot_dump_file, 'w') as file:
            json.dump(self.nodeslot_programming, file, indent=4)
        with open(self.layer_config_file, 'w') as file:
            json.dump(self.layer_config, file, indent=4)

    def set_layer_config(self):
        self.layer_config['global_config']['layer_count'] = 1
        layer = {
            'in_feature_count': self.trained_graph.feature_count,
            'out_feature_count': self.trained_graph.feature_count,
            'adjacency_list_address': self.offsets[0],
            'in_messages_address': self.offsets[1],
            'weights_address': self.offsets[2],
            'out_messages_address': self.offsets[3],
        }
        self.layer_config['layers'].append(layer)

    def program_nodeslots(self):
        for node in self.trained_graph.nx_graph.nodes:
            nb_cnt = self.trained_graph.nx_graph.nodes[node]['neighbour_count']
            if (nb_cnt == 0):
                continue
            nodeslot = {'node_id' : node,
                        'neighbour_count': nb_cnt,
                        'precision': 'FLOAT_32',
                        'adjacency_list_address_lsb': 4*self.trained_graph.nx_graph.nodes[node]['adj_list_offset'],
                        'adjacency_list_address_msb': 0,
                        'out_messages_address_lsb': self.offsets[3] + node * self.trained_graph.feature_count * 4,
                        'out_messages_address_msb': 0
                        }
            self.nodeslot_programming['nodeslots'].append(nodeslot)

    def required_bytes_with_padding(self, bytes_required):
        '''
            Pad with 0s to fill each block of 64 bytes
        '''
        return (math.ceil(bytes_required/64) * 64)

    def initialize(self):
        self.set_adj_list()
        self.set_in_messages()
        self.set_weights()

    def set_adj_list(self):
        # Define list of node offsets (to be programmed into nodeslots)
        self.memory_hex = self.int_list_to_byte_list(self.adj_list, pad=True, end_offset=self.offsets[1])

    def set_in_messages(self):
        for node in range(len(self.trained_graph.nx_graph.nodes)):
            self.memory_hex += self.float_list_to_byte_list(self.in_messages[node])
        # TO DO: padding

    def set_weights(self):
        for outf in range(self.trained_graph.feature_count):
            self.memory_hex += self.float_list_to_byte_list(self.trained_graph.weights[outf])
        # TO DO: padding

    def int_list_to_byte_list(self, in_list, pad=False, end_offset=None):
        '''
        Convert to list of bytes in hex
        '''
        memory_hex = np.array([f"{dest_node:08x}" for dest_node in in_list])
        memory_hex = [s[i:i+2] for s in memory_hex for i in range(0, 8, 2)]
        if (pad and end_offset is not None):
            memory_hex += ['00'] * (end_offset - len(memory_hex))
        return memory_hex

    def float_list_to_byte_list(self, in_list, pad=False, end_offset=None):
        hex_list = [struct.pack('!f', i).hex() for i in in_list]
        hex_list = [s[i:i+2] for s in hex_list for i in range(0, 8, 2)]
        if (pad and end_offset is not None):
            hex_list += ['00'] * (end_offset - len(hex_list))
        return hex_list

    def print_memory(self, memory):
        for i in range(len(memory)//64):
            print(''.join(memory[i*64:(i+1)*64]))
        print(''.join(memory[64*(len(memory)//64):]))

    def dump_memory(self):
        with open(self.memory_dump_file, 'w') as file:
            for i in range(len(self.memory_hex)//64):
                file.write(''.join(self.memory_hex[i*64:(i+1)*64]))
                file.write('\n')
            file.write(''.join(self.memory_hex[64*(len(self.memory_hex)//64):]))
            file.write('\n')

    def dump_txt(self):
        with open(self.graph_dump_file, 'w') as file:
            file.write(f"out_messages_offset = {self.offsets[3]};")
            file.write("\n")
            
            file.write("adj_list = '{")
            file.write(str(self.adj_list.tolist())[1:-1])
            file.write("};")
            file.write("\n")

            file.write("node_offsets = '{")
            file.write(str(self.node_offsets.tolist())[1:-1])
            file.write("};")
            file.write("\n")

            for idx, node in enumerate(self.in_messages):
                file.write(f"embeddings[{idx}] = ")
                file.write("'{")
                file.write(str(node.tolist())[1:-1])
                file.write("};")
                file.write("\n")

            for idx, feature in enumerate(self.weights):
                file.write(f"weights[{idx}] = ")
                file.write("'{")
                file.write(str(feature.tolist())[1:-1])
                file.write("};")
                file.write("\n")