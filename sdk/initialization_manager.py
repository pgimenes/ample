import numpy as np

import json
import os
import torch
from .utilities import dump_byte_list, binary_to_hex

from sdk.memory_mapper import Memory_Mapper
from sdk.graph_tracer import GraphTracer

import logging

from tqdm import tqdm
from copy import deepcopy

from torch.nn import Linear
from torch_geometric.nn import GCNConv, GINConv, SAGEConv

from .models.models import GraphSAGE_Model, Edge_Embedding_Model,Interaction_Net_Model, EdgeGCNLayer, AGG_MLP_Model, AggregateEdges#AGG_MLP_Model - temp

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
        # self.model_layer_max_features = max([self.get_feature_counts(self.model)])
        # Nodeslot programming
        self.nodeslot_programming = []
        self.nodeslot_programming_group_start_address = []

        # self.traced_model = GraphTracer(model)

        # # Print the input and output layers
        # self.traced_model.print_input_output_layers()

    

    # def get_model_hierarchy(self):
    #     model_hierarchy = []
    #     if hasattr(self.model, 'named_children') and len(list(self.model.children()))>1:
    #         for name, module in self.model.named_children():
    #             print(f'{name}: {module.__class__.__name__}')
    #             model_hierarchy.append(self.get_feature_counts(module))
    #     else:
    #         model_hierarchy.append(self.get_feature_counts(self.model))
    #         print('Simple hierarchy')
    #     return model_hierarchy




    # Nodeslot programming and layer configuration
    # ===============================================
    #TODO change this
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
        elif isinstance(layer, EdgeGCNLayer):
            inc = layer.in_channels
            outc = layer.out_channels
        elif isinstance(layer, AGG_MLP_Model):
            inc = layer.in_features
            outc = layer.out_features
        elif isinstance(layer, AggregateEdges):
            inc = layer.in_channels
            outc = layer.in_channels
        else:
            raise RuntimeError(f"Unrecognized layer type {type(layer)}")        
        return inc, outc

    #TODO use other layer_config
    def get_default_layer_config(self, layer,idx):
        
        inc, outc = self.get_layer_feature_count(layer)
        if isinstance(layer, torch.nn.Linear):
            aggregate_enable = 0
            adj_list_addr= self.memory_mapper.offsets['adj_list']['self_ptr']

        else:
            adj_list_addr= self.memory_mapper.offsets['adj_list']['nbrs']
            aggregate_enable = 1
        edge_node = 0
        #Multi-layer support - out messages become in messages for next layer
        if 'input' in layer.name:
            in_messages_address = self.memory_mapper.offsets['in_messages']
        else:
            in_messages_address = self.memory_mapper.out_messages_ptr


        if 'hidden' or 'input' in layer.name:
            out_messages_address = self.memory_mapper.out_messages_ptr#Can change this to have intermediate out messages (['out_messages'][idx-1])
        else:
            out_messages_address= self.memory_mapper.out_messages_ptr
            self.memory_mapper.offsets['out_messages'][idx] = out_messages_address
            #Will need to modify if writing back edge embeddings as there is likely to be more edges than nodes
            #New out messages pointer = [data_needed_to_store(number of features in [this layer])] * number of nodes in graph
            self.memory_mapper.out_messages_ptr += self.calc_axi_addr((self.get_feature_counts(self.model))[idx]) * len(self.trained_graph.nx_graph.nodes[node_id])
        return {
            'nodeslot_count': len(self.trained_graph.nx_graph.nodes),
            'in_feature_count': inc,
            'out_feature_count': outc,
            'transformation_activation': 0,
            'leaky_relu_alpha': 0,
            'transformation_bias': 0,
            'dequantization_parameter': self.trained_graph.dequantization_parameter,
            'adjacency_list_address': adj_list_addr,
            'in_messages_address': in_messages_address, 
            'weights_address': self.memory_mapper.offsets['weights'][idx],
            'out_messages_address': out_messages_address,
            'aggregation_wait_count': 16,
            'transformation_wait_count': 16,
            'aggregate_enable' : aggregate_enable,
            'edge_node': edge_node,
            'nodeslot_start_address': 0,
            'concat_width': 1
        }
        

    def get_layer_config(self, layer,in_messages_address,idx,edge=0,linear=0,concat=0,concat_width =1):
        inc, outc = self.get_layer_feature_count(layer)
        if edge:
            nodeslot_count = len(self.trained_graph.nx_graph.edges())
        else:
            nodeslot_count = len(self.trained_graph.nx_graph.nodes)

        if linear:
            aggregate_enable = 0
            if concat:
                adjacency_list_address = self.memory_mapper.offsets['adj_list']['concat_ptr'] #Workaround to aggregate from different layers
            else:
                adjacency_list_address = self.memory_mapper.offsets['adj_list']['self_ptr']
        else:
            # if edge: 
            #     adjacency_list_address = self.memory_mapper.offsets['adj_list']['edge_nbrs'] #Only use if node is using edges
            # else:
            adjacency_list_address = self.memory_mapper.offsets['adj_list']['nbrs']
            aggregate_enable = 1

        return {
            'nodeslot_count': nodeslot_count,
            'in_feature_count': inc,
            'out_feature_count': outc,
            'transformation_activation': 0,
            'leaky_relu_alpha': 0,
            'transformation_bias': 0,
            'dequantization_parameter': self.trained_graph.dequantization_parameter,
            'adjacency_list_address': adjacency_list_address,
            'in_messages_address': in_messages_address, 
            'weights_address': self.memory_mapper.offsets['weights'][idx],
            'out_messages_address': self.memory_mapper.out_messages_ptr,
            'aggregation_wait_count': 16,
            'transformation_wait_count': 16,
            'aggregate_enable' : aggregate_enable,
            'edge_node': edge, #Change to nodeslot grouping - where is this used?
            'nodeslot_start_address': self.nodeslot_programming_group_start_address[edge], #Temp TODO change to index that can be specified not jsut edge - or use dict and call it Vg,Eg, Vm,Em etc
            'concat_width': concat_width #Temp TODO change to index that can be specified not jsut edge - or use dict and call it Vg,Eg, Vm,Em etc

        }





    

    def set_layer_config_edge_embedder(self):
        self.layer_config["global_config"]["layer_count"] =  4
        

        #|IIIIIEEEEEEEEEE |SSSSS      | EEEEEEEEEEEEE | RRRRR
        #|in_msg          |out_msg[0] |+#nodes        | +#nodes +#edges

        #TODO take offsets from trained graph so that only need declare once

        ######Source Embedder######
        in_messages_address = self.memory_mapper.offsets['in_messages']
        self.memory_mapper.out_messages_ptr = self.memory_mapper.offsets['out_messages'][0] 

        #Read from in messages, write to out_msg[0] 
        l1 = self.get_layer_config(self.model.src_embedder,in_messages_address = in_messages_address,idx=0,edge=0,linear=1)
        self.layer_config['layers'].append(l1)

        # print('node num:')
        # print(len(self.trained_graph.nx_graph.nodes))
        
        #Edge already indexed to start after nodes
        # self.memory_mapper.out_messages_ptr += self.calc_axi_addr((self.model.src_embedder.out_features) * len(self.trained_graph.nx_graph.nodes))

        ######Edge Embedder###### - do second so that index starts at end of last nodeslot
        #Read from in messages (indexed), write to out_msg[0] + #nodes (included in index)

        l2 = self.get_layer_config(self.model.edge_embedder,in_messages_address = in_messages_address,idx=1,edge=1,linear=1)
        self.layer_config['layers'].append(l2)

        # print('edge num:')
        # print(len(self.trained_graph.nx_graph.edges))
        self.memory_mapper.out_messages_ptr += self.calc_axi_addr((self.trained_graph.feature_count) * (len(self.trained_graph.nx_graph.edges)+len(self.trained_graph.nx_graph.nodes)))

        #Receive Embedder
        #Read from in messages, write to out_msg[0] +#nodes +#edges (not included in index)

        l3 = self.get_layer_config(self.model.rx_embedder,in_messages_address = in_messages_address,idx=2,edge=0,linear=1)
        self.layer_config['layers'].append(l3)
        out_message_end = self.memory_mapper.out_messages_ptr

        self.memory_mapper.out_messages_ptr += self.calc_axi_addr((self.trained_graph.feature_count) * len(self.trained_graph.nx_graph.nodes))

        #Edge update
        #Read from out_msg[0], write to out_msg[0] +#nodes(included in index) - wrinting to edges
        embeddings_start_address = self.memory_mapper.offsets['out_messages'][0]
        self.memory_mapper.out_messages_ptr = self.memory_mapper.offsets['out_messages'][0] 
        l4 = self.get_layer_config(self.model.edge_update,in_messages_address = embeddings_start_address,idx=3,edge=1,linear=0)
        self.layer_config['layers'].append(l4)

        self.memory_mapper.out_messages_ptr = out_message_end 

    def set_layer_config_interaction_net(self):
        self.layer_config["global_config"]["layer_count"] =  2
        
        #0                1           2               3                 4                       5          6
        #|IIIIIEEEEEEEEEE |SSSSS      | EEEEEEEEEEE(1)| RRRRR(1)        | XXXXXXXEEEEEEEEEE(2)  | RRRR (2) | RRRR (3)
        #|in_msg          |out_msg[0] |+#nodes        | +#nodes +#edges | +2*#nodes +#edges     |          |

        #TODO take offsets from trained graph so that only need declare once - use outmessages idx

        ######Source Embedder######
        in_messages_address = self.memory_mapper.offsets['in_messages'] #0
        self.memory_mapper.out_messages_ptr = self.memory_mapper.offsets['out_messages'][0] 


        #Out messages start set to 1
        #Read from in messages, write to out_msg[0] 
        l0 = self.get_layer_config(self.model.src_embedder,in_messages_address = in_messages_address,idx=0,edge=0,linear=1)
        self.layer_config['layers'].append(l0)

        ######Edge Embedder###### - do second so that index starts at end of last nodeslot
        #Read from in messages (indexed), write to out_msg[0] + #nodes (included in index)

        l1 = self.get_layer_config(self.model.edge_embedder,in_messages_address = in_messages_address,idx=1,edge=1,linear=1)
        self.layer_config['layers'].append(l1)

        # print('edge num:')
        # print(len(self.trained_graph.nx_graph.edges))

        self.memory_mapper.out_messages_ptr += self.calc_axi_addr((self.trained_graph.feature_count) * (len(self.trained_graph.nx_graph.edges)+len(self.trained_graph.nx_graph.nodes)))
        #out messages - 3

        #Receive Embedder
        #Read from in messages, write to out_msg[0] +#nodes +#edges (not included in index)

        l2 = self.get_layer_config(self.model.rx_embedder,in_messages_address = in_messages_address,idx=2,edge=0,linear=1)
        self.layer_config['layers'].append(l2)
        out_message_end = self.memory_mapper.out_messages_ptr

        self.memory_mapper.out_messages_ptr += self.calc_axi_addr((self.trained_graph.feature_count) * len(self.trained_graph.nx_graph.nodes))
        #Out messages 4
        addr_4 = self.memory_mapper.out_messages_ptr

        #Edge update
        #Read from out_msg[0], write to out_msg[0] +#nodes(included in index) - wrinting to edges
        embeddings_start_address = self.memory_mapper.offsets['out_messages'][0]
        # self.memory_mapper.out_messages_ptr = self.memory_mapper.offsets['out_messages'][0] 
        l3 = self.get_layer_config(self.model.edge_update,in_messages_address = embeddings_start_address,idx=3,edge=1,linear=0)
        self.layer_config['layers'].append(l3)

        self.memory_mapper.out_messages_ptr += self.calc_axi_addr((self.trained_graph.feature_count) * (len(self.trained_graph.nx_graph.edges)+len(self.trained_graph.nx_graph.nodes)))
        #5
        rx_node_embed_address = self.memory_mapper.out_messages_ptr


        #######RX Node Embed ########
        in_messages_address = self.memory_mapper.offsets['in_messages']
        l4 = self.get_layer_config(self.model.rx_node_embedder, in_messages_address = in_messages_address,idx=4,edge=0,linear=1)
        self.layer_config['layers'].append(l4)


        self.memory_mapper.out_messages_ptr += self.calc_axi_addr((self.trained_graph.feature_count) * (len(self.trained_graph.nx_graph.nodes)))
        #6

        #######RX Edge Aggregate ######## 
        # Aggregate edge neighbours
        in_messages_address = addr_4 #Take message from previous layer (4), write to the same layer
        #out message for this is same location as l4 - how to resolve?
        l5 = self.get_layer_config(self.model.rx_edge_aggr,in_messages_address = in_messages_address,idx=5,edge=0,linear=0)
        self.layer_config['layers'].append(l5)

        #######Rx Node Update ######## 
        in_messages_address = rx_node_embed_address
        l6 = self.get_layer_config(self.model.rx_node_update,in_messages_address = in_messages_address,idx=6,edge=0,linear=1,concat=1,concat_width=2)
        self.layer_config['layers'].append(l6)

        self.memory_mapper.out_messages_ptr = out_message_end 




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


        #Can add precision here?
        self.layer_config['global_config'] = {
            "layer_count": len(self.model.layers),
            "node_count": self.trained_graph.dataset.x.shape[0],
            "edge_count": self.trained_graph.dataset.edge_index.shape[1],
        }

        if (isinstance(self.model, GraphSAGE_Model)):
            self.set_layer_config_graphsage()
        elif (isinstance(self.model, Edge_Embedding_Model)):
            self.set_layer_config_edge_embedder()
        elif (isinstance(self.model, Interaction_Net_Model)):
            self.set_layer_config_interaction_net()

        else :
            # print(self.model.named_children() and isinstance(self.model.named_children(),list))
            # if hasattr(self.model, 'named_children') and isinstance(self.model.named_children(),list):
            #     print('complex model')
            #     for name, module in self.model.named_children():
            #         print(f'{name}: {module.__class__.__name__}')
            #         for idx,layer in enumerate(module):
            #             layer_config_i = self.get_default_layer_config(layer,idx)
            #             self.layer_config['layers'].append(layer_config_i)
            # else:
            # Default layer configuration
            for idx,layer in enumerate(self.model.layers):
                layer_config_i = self.get_default_layer_config(layer,idx)
                self.layer_config['layers'].append(layer_config_i)

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
                # 'adjacency_list_address_lsb': self.trained_graph.nx_graph.nodes[node_id]["meta"]['adjacency_list_address'],
                'adjacency_list_address_msb': 0,
                'scale_factors_address_lsb': self.trained_graph.nx_graph.nodes[node_id]["meta"]['scale_factors_address'],
                'scale_factors_address_msb': 0,
                'out_messages_address_lsb': node_id * self.calc_axi_addr(self.trained_graph.feature_count), # /*self.memory_mapper.offsets['out_messages'] + */#
                'out_messages_address_msb': 0
            }



    def get_default_edge(self, edge):
        edge_meta = edge[2]['meta']
        # print('edge_meta',edge_meta)
        return {
            'node_id' : edge_meta['edge_id'],  #Refactor name
            'neighbour_count':3, #Self, rx, src
            'precision':edge_meta['precision'],
            'aggregation_function': edge_meta['aggregation_function'], #SUM or CONCAT
            # 'adjacency_list_address_lsb': edge_meta['adjacency_list_address'],
            'adjacency_list_address_msb': 0,
            'scale_factors_address_lsb': edge_meta['scale_factors_address'],
            'scale_factors_address_msb': 0,
            'out_messages_address_lsb': edge_meta['edge_id'] * self.calc_axi_addr(self.trained_graph.feature_count), #Change to edge feature count # /*self.memory_mapper.offsets['out_messages'] + */#
            'out_messages_address_msb': 0
        }

    def program_nodeslots_graphsage(self):
        # Layer 1: W1 projection
        nodeslot_group = []
        for node in self.trained_graph.nx_graph.nodes:
            nodeslot = self.get_default_nodeslot(node)
            nodeslot["neighbour_count"] = 1
            nodeslot_group.append(nodeslot)

        # Layer 2: W3 projection
        for node in self.trained_graph.nx_graph.nodes:
            nodeslot = self.get_default_nodeslot(node)
            nodeslot["neighbour_count"] = 1
            nodeslot_group.append(nodeslot)

        # Layer 3: mean aggregation + W2 transformation
        for node in self.trained_graph.nx_graph.nodes:
            nodeslot = self.get_default_nodeslot(node)
            nodeslot_group.append(nodeslot)

        # Layer 4: sum aggregation result with residual
        for node in self.trained_graph.nx_graph.nodes:
            nodeslot = self.get_default_nodeslot(node)
            nodeslot["neighbour_count"] = 2
            nodeslot["aggregation_function"] = "SUM"
            nodeslot_group.append(nodeslot)

        self.nodeslot_programming.append(nodeslot_group)


    #TODO change soloads all indicies in graph
    def load_nodeslot_programming_from_graph(self):
        dense_nodes = []
        nodeslot_group = []
        for node in self.trained_graph.nx_graph.nodes:
            nb_cnt = self.trained_graph.nx_graph.nodes[node]["meta"]['neighbour_count']
            if (self.ignore_isolated_nodes and nb_cnt == 0):
                continue
            if (nb_cnt > 256):
                dense_nodes.append(node)
                continue
            nodeslot = self.get_default_nodeslot(node)
            nodeslot_group.append(nodeslot)
        self.nodeslot_programming.append(nodeslot_group)
        logging.debug(f"Dense node count: {len(dense_nodes)}")


    def load_edges_programming_from_graph(self):
        nodeslot_group = []
        for edge in self.trained_graph.nx_graph.edges(data=True):
            edge = self.get_default_edge(edge)     
            nodeslot_group.append(edge)
            # Print all the features (attributes) of the edge
        self.nodeslot_programming.append(nodeslot_group)

            

    def program_nodeslots(self, ignore_isolated_nodes=True):
        self.ignore_isolated_nodes = ignore_isolated_nodes
        logging.info(f"Generating nodeslot programming.")
        
        if (isinstance(self.model, GraphSAGE_Model)):
            self.program_nodeslots_graphsage()
        elif(isinstance(self.model, Edge_Embedding_Model)):
            self.load_nodeslot_programming_from_graph()
            self.load_edges_programming_from_graph()
        elif(isinstance(self.model, Interaction_Net_Model)):
            self.load_nodeslot_programming_from_graph()
            self.load_edges_programming_from_graph()
        else:
            self.load_nodeslot_programming_from_graph()
            



    def generate_nodeslots_mem(self,nodeslot_group):
        # print('nodeslot_group',nodeslot_group)
        node_groups = np.array(nodeslot_group)
        
        node_groups = np.pad(
                                node_groups, 
                                (0, 8 - node_groups.shape[0] % 8), 
                                "constant", 
                                constant_values=None
                            ).reshape(-1, 8)
        
        nodeslot_mem_hex = []

        for group_idx,group in tqdm(enumerate(node_groups)):
            # logging.info(f"Generating nodeslot group {group_idx} memory.")

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

        nodeslot_mem_len = len(nodeslot_mem_hex)//2 #byte indexed
        return nmh,nodeslot_mem_len


    def dump_nodeslot_programming(self):
        # self.nodeslot_programming = {'nodeslots':[]}
        self.program_nodeslots()
        with open(self.nodeslot_json_dump_file, 'w') as file:
            json.dump(self.nodeslot_programming, file, indent=4)

        nodeslot_memory_pointer = 0
        nodeslot_byte_list = []
        for group,nodeslot_group in enumerate(self.nodeslot_programming):
            # print('node group',group)
            # print(nodeslot_group)
            self.nodeslot_programming_group_start_address.append(nodeslot_memory_pointer)
            # Dump nodeslots.mem file
            group_byte_list,nmh_length = self.generate_nodeslots_mem(nodeslot_group)
            # print('nhm',nmh_length)
            nodeslot_byte_list +=group_byte_list
            nodeslot_memory_pointer += nmh_length


        dump_byte_list(nodeslot_byte_list, self.nodeslot_mem_dump_file)

    def dump_memory(self):
        self.memory_mapper.dump_memory()

    # Generate feature embedding expectation
    # ===============================================

    def embedding_expectation(self):
        self.model.eval()
        with torch.no_grad():
            embeddings = self.trained_graph.dataset.x
            #TODO Change to have edge flag
            if (isinstance(self.model, Edge_Embedding_Model)) or (isinstance(self.model, Interaction_Net_Model)): #Temp
                output = self.model(self.trained_graph.dataset.x,self.trained_graph.dataset.edge_attr, self.trained_graph.dataset.edge_index)
            else:
                output = self.model(self.trained_graph.dataset.x, self.trained_graph.dataset.edge_index)
        np.savetxt(self.updated_embeddings_file, (output[-1]).numpy(), delimiter=',')

    #Save JIT model for testbench
    def save_model(self):
        self.model.eval()

        x = self.trained_graph.dataset.x  # Node features tensor
        edge_index = self.trained_graph.dataset.edge_index  # Edge indices tensor
        # edge_attr = self.trained_graph.dataset.edge_attr  # Edge attributes tensor



        # edge_attr = self.trained_graph.dataset.edge_attr if 'edge_attr' in self.dataset else None  # Edge attributes tensor (optional)
        # data = (x, edge_index, edge_attr) if edge_attr is not None else (x, edge_index)


        # data = (x, edge_attr,edge_index)
        #Traced Model - allow TB to be compatible with GCNConv
        #TODO Change to have edge flag
        # if (isinstance(self.model, Edge_Embedding_Model) or (isinstance(self.model, Interaction_Net_Model))):
        #     edge_attr = self.trained_graph.dataset.edge_attr  # Edge attributes tensor
        #     data = (x,edge_index,edge_attr) 
        #     # edge_attr = self.trained_graph.dataset
        #     jit_model = torch.jit.trace(self.model, data)
        # else:
        edge_attr = self.trained_graph.dataset.edge_attr  # Edge attributes tensor
        # data = (x,edge_index,edge_attr) 

        # Start with the required elements
        data = [x, edge_index]

        # Append edge_attr if it's not None
        if edge_attr is not None:
            data.append(edge_attr)
            # print('edge_attr',edge_attr)

        jit_model = torch.jit.trace(self.model, data)
        #Non-traced model
        # jit_model = torch.jit.script(self.model).to('cpu')
        torch.jit.save(jit_model, 'model.pt')

        return jit_model

    
    #Save graph for testbench
    def save_graph(self):
        input_data = {
            'x': self.trained_graph.dataset.x,  
            'edge_index': self.trained_graph.dataset.edge_index,
            'edge_attr': self.trained_graph.dataset.edge_attr
        }

        torch.save({
            'input_data': input_data
        }, 'graph.pth')

    def calc_axi_addr(self,feature_count):
        #ceil(num_bytes/num_bytes_in_data_slot)*num_bytes_in_data_slot
        return math.ceil(4*feature_count / data_width) * data_width
    
    # Function to get feature count of each layer
    def get_feature_counts(self,model):
        ##Add function to include in features size
        #Change to self.model
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
    
    def map_memory(self):
        self.memory_mapper.map_memory()