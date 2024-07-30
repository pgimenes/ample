import torch
import torch.nn as nn
import torch.nn.functional as F

from torch.nn import Linear
from torch.nn import ReLU
from torch_geometric.nn import GCNConv, GATConv, SAGEConv, GINConv
import pytorch_lightning as pl
from torch import Tensor
from torch_geometric.typing import SparseTensor

import numpy as np
'''
Graph Convolutional Network
'''

class GCN_Model(torch.nn.Module):
    def __init__(self, in_channels: int, out_channels: int, layer_count=1, hidden_dimension=64, precision = torch.float32):
        super().__init__()
        self.precision = precision
        self.layers = nn.ModuleList()
        if layer_count == 1:
            layer.name = 'gcn_layer_input_output0'
            layer  = GCNConv(in_channels, out_channels,normalize =False)
            self.layers.append(layer)
        else:
            layer = GCNConv(in_channels, hidden_dimension,normalize =False)
            layer.name = 'gcn_layer_input0'
            self.layers.append(layer)
            for i in range(layer_count-2):
                layer = GCNConv(hidden_dimension, hidden_dimension,normalize =False)
                layer.name = f'gcn_layer_hidden{i}'
                self.layers.append(layer)
            layer = GCNConv(hidden_dimension, out_channels,normalize =False)
            layer.name = f'gcn_layer_output{layer_count-1}'
            self.layers.append(layer)


        for layer in self.layers:
            layer.to(self.precision)
            
    def forward(self, x, edge_index):
        x = x.to(self.precision)  
        outputs = []
        for layer in self.layers:
            x = layer(x, edge_index)
            outputs.append(x)

        return outputs






'''
Graph Isomorphism Network
'''

class GINLinear(pl.LightningModule):
    def __init__(self, in_channels, out_channels):
        super().__init__()
        self.layer = torch.nn.Linear(in_channels, out_channels, bias=False)
    
    def forward(self, x):
        return self.layer(x)

class GIN_Model(pl.LightningModule):
    def __init__(self, in_channels, out_channels, layer_count=1, hidden_dimension=64):
        super().__init__()
        self.layers = nn.ModuleList()
        if layer_count == 1:
            self.layers.append(GINConv(
                torch.nn.Linear(in_channels, out_channels, bias=False)
                ))
        else:
            self.layers.append(GINConv(
                torch.nn.Linear(in_channels, hidden_dimension, bias=False)
                ))
            for _ in range(layer_count-2):
                self.layers.append(GINConv(
                    torch.nn.Linear(hidden_dimension, hidden_dimension, bias=False)
                    ))
            self.layers.append(GINConv(
                torch.nn.Linear(hidden_dimension, out_channels, bias=False)
                ))

    def forward(self, x, edge_index):
        for layer in self.layers:
            out = layer(x, edge_index)
        return out

'''
Graph Attention Network
'''

class GAT_Model(pl.LightningModule):
    def __init__(self, num_features, num_classes):
        super().__init__()

        self.hid = 8
        self.in_head = 8
        self.out_head = 1

        self.conv1 = GATConv(num_features, self.hid, self.in_head, dropout=0.6)

        self.conv2 = GATConv(self.hid*self.in_head, num_classes, concat=False,
                                heads=self.out_head, dropout=0.6)

    def forward(self, x, edge_index):
        x = F.dropout(x, p=0.6, training=self.training)
        x = self.conv1(x, edge_index)
        x = F.elu(x)
        x = F.dropout(x, p=0.5, training=self.training)
        x = self.conv2(x, edge_index)
        return F.log_softmax(x, dim=1)
  
'''
GraphSAGE
'''
class GraphSAGE_Model(pl.LightningModule):
    def __init__(self, in_channels, out_channels, layer_count=1, hidden_dimension=64):
        super().__init__()
        self.layers = nn.ModuleList()
        if layer_count == 1:
            self.layers.append(SAGEConv(in_channels, out_channels))
        else:
            self.layers.append(SAGEConv(in_channels, hidden_dimension))
            for _ in range(layer_count-2):
                self.layers.append(SAGEConv(hidden_dimension, hidden_dimension))
            self.layers.append(SAGEConv(hidden_dimension, out_channels))

    def forward(self, x, edge_index):
        for layer in self.layers:
            out = layer(x, edge_index)
        return out
    

'''
Graph Convolutional Network with attatched linear layers
'''

class GCN_MLP_Model(nn.Module):
    def __init__(self, in_channels, out_channels, layer_count=1, hidden_dimension=34,precision = torch.float32):
        super().__init__()
        self.precision = precision
        self.layers = nn.ModuleList()
        if layer_count == 1:
            layer = GCNConv(in_channels, out_channels, normalize =False)
            layer.name = 'gcn_input_output_layer0'

        elif layer_count>1:
            layer = GCNConv(in_channels, hidden_dimension, normalize =False)
            layer.name = 'gcn_input_layer0'
            self.layers.append(layer)
            for i in range(layer_count-2):
                layer = Linear(hidden_dimension, hidden_dimension, bias=False)
                layer.name = f'linear_hidden_layer{i}'
                self.layers.append(layer)
            layer = Linear(hidden_dimension, out_channels, bias=False)
            layer.name = f'linear_output_layer{layer_count-1}'
            self.layers.append(layer)


        for layer in self.layers:
            layer.to(self.precision)

    def forward(self, x: Tensor, edge_index: Tensor):
        x = x.to(self.precision)  
        if isinstance(edge_index, SparseTensor):
            edge_index = edge_index.to_torch_sparse_coo_tensor()  # Ensure edge_index is a Tensor
        outputs = []
        for layer in self.layers:
            if isinstance(layer, torch.nn.Linear):
                x = layer(x)
            else:
                x = layer(x, edge_index)
            outputs.append(x)
        return outputs

'''
MLP
'''

class MLP_Model(torch.nn.Module):
    def __init__(self, in_channels, out_channels=32, layer_count=1, hidden_dimension=32, precision = torch.float32):
        super().__init__()
        self.precision = precision
        self.layers = nn.ModuleList()
        if layer_count == 1:
            layer = nn.Linear(in_channels, out_channels, bias=True)
            layer.name = 'input_output_layer'  # Assign name directly
            self.layers.append(layer)

        else:
            layer = nn.Linear(in_channels, hidden_dimension, bias=True)
            layer.name = 'input_layer'
            self.layers.append(layer)
            for i in range(layer_count-2):
                layer = nn.Linear(hidden_dimension, hidden_dimension, bias=True)
                layer.name = f'hidden_layer_{i}'
                self.layers.append(layer)
                
            layer = nn.Linear(hidden_dimension, out_channels, bias=True)
            layer.name = 'output_layer'
            self.layers.append(layer)

        for layer in self.layers:
            layer.to(self.precision)

    def forward(self, x, edge_index,):
        x = x.to(self.precision)  
        outputs = []
        for layer in self.layers:
            x = layer(x)
            outputs.append(x)

        return outputs





class Edge_ConcatEmbedding__Model(torch.nn.Module):
    def __init__(self, in_channels, out_channels=32, layer_count=1, hidden_dimension=32, precision = torch.float32):
        super().__init__()
        self.precision = precision
        self.layers = nn.ModuleList()



        ######Source Node MLP#########

        if layer_count == 1:
            layer = nn.Linear(in_channels, out_channels, bias=True)
            layer.name = 'input_output_layer_src'  # Assign name directly
            self.layers.append(layer)

        elif layer_count>1:
            layer = nn.Linear(in_channels, hidden_dimension, bias=True)
            layer.name = 'input_layer_src'
            self.layers.append(layer)

            for i in range(layer_count-2):
                layer = nn.Linear(hidden_dimension, hidden_dimension, bias=True)
                layer.name = f'hidden_layer_src{i}'
                self.layers.append(layer)
                
            layer = nn.Linear(hidden_dimension, out_channels, bias=True)
            layer.name = 'output_layer_src'
            self.layers.append(layer)

        ######Receive Node MLP#########
        if layer_count == 1:
            layer = nn.Linear(in_channels, out_channels, bias=True)
            layer.name = 'input_output_layer_rx'  # Assign name directly
            self.layers.append(layer)

        elif layer_count>1:
            layer = nn.Linear(in_channels, hidden_dimension, bias=True)
            layer.name = 'input_layer_rx'
            self.layers.append(layer)

            for i in range(layer_count-2):
                layer = nn.Linear(hidden_dimension, hidden_dimension, bias=True)
                layer.name = f'hidden_layer_rx{i}'
                self.layers.append(layer)
                
            layer = nn.Linear(hidden_dimension, out_channels, bias=True)
            layer.name = 'output_layer_rx'
            self.layers.append(layer)
  

        for layer in self.layers:
            layer.to(self.precision)

    def forward(self, x, edge_index,):
        x = x.to(self.precision)  
        src_embed = x
        rx_embed = x
        outputs = []
        for layer in self.layers:
            if 'src' in layer.name:
                src_embed = layer(src_embed)
                outputs.append(src_embed)

            if 'rx' in layer.name:
                rx_embed = layer(rx_embed)
                outputs.append(rx_embed)

            # x = layer(x)
            # outputs.append(x)

        return outputs




class Edge_Embedding_Model(torch.nn.Module):
    def __init__(self, in_features=32, out_features=32, layer_count=2, hidden_dimension=32, precision = torch.float32):
        super().__init__()

        #Change to whatever the node dim is for encoding 
        #Get expeted outputs
        self.rx_node_mlp = MLP_Model(in_features, out_features, layer_count=2, hidden_dimension=32)
        
        self.src_node_mlp = MLP_Model(in_features, out_features, layer_count=2, hidden_dimension=32)

        # self.edge_intermediate_mlp = MLP_Model(in_features, out_features, layer_count=2, hidden_dimension=32)


    

        #Concat version -- not useful for debugging
        # self.edge_mlp = torch.nn.Sequential(
        #     torch.nn.Linear(32 * 2 + edge_dim, hidden_dim),
        #     torch.nn.ReLU(),
        #     torch.nn.Linear(hidden_dim, output_dim)
        # )
        # self.edge_conv = GCNConv(output_dim, hidden_dimension)
        # self.node_update_conv = GCNConv(32 + 32, 32)

    def forward(self, x, edge_index, edge_attr):
        outputs = [] #List of output layer lists per MLP
        # Edge embedding
        row, col = edge_index

        rx_node_embeddings = self.rx_node_mlp(x[row])
        src_node_embeddings = self.src_node_mlp(x[col])
        edge_intermediate_embeddings = self.edge_intermediate_mlp(edge_attr)

        outputs.append(rx_node_embeddings)
        outputs.append(src_node_embeddings)
        outputs.append(edge_intermediate_embeddings)

        #Replace with GCN conv with identity weights and SiLu fucntion
        # edge_embeddings = nn.SilU(rx_node_embeddings + src_node_embeddings + edge_intermediate_embeddings)
        edge_embeddings = rx_node_embeddings + src_node_embeddings + edge_intermediate_embeddings

        outputs.append(edge_embeddings)

        return outputs



        # Node update : Stage 2
        # # Aggregate edge features using a GCN
        # edge_index, _ = add_self_loops(edge_index, num_nodes=x.size(0))
        # edge_aggregated = self.edge_conv(edge_embeddings, edge_index)

        # # Step 4: Concatenate node features with aggregated edge features
        # node_edge_concat = torch.cat([x, edge_aggregated], dim=1)

        # # Step 5: Transform concatenated features to update node features
        # updated_node_features = self.node_update_conv(node_edge_concat, edge_index)
        
        # return updated_node_features, edge_embeddings








# # edge_embeddings = model(data.x, data.edge_index, data.edge_attr)

# class EdgeEmbeddingModel(torch.nn.Module):
#     def __init__(self, in_channels=32, out_channel=32, edge_dim=32,node_dim=32, hidden_dimension=32):
#         super(EdgeEmbeddingModel, self).__init__()
#         # self.node_conv = GCNConv(in_channels, out_channels)
#         self.edge_mlp = torch.nn.Sequential(
#             torch.nn.Linear(node_dim * 2 + edge_dimv, hidden_dimension),
#             torch.nn.SiLU(),
#             torch.nn.Linear(hidden_dimension, out_channels)
#         )

#     def forward(self, x, edge_index, edge_attr):
#         # Node feature transformation
#         # x = self.node_conv(x, edge_index)
        
#         # Edge embedding
#         row, col = edge_index
#         edge_embeddings = torch.cat([x[row], x[col], edge_attr], dim=1)
#         edge_embeddings = self.edge_mlp(edge_embeddings)
        
#         return edge_embeddings




# class NodeUpdateModel(torch.nn.Module):
#     def __init__(self, in_channels=32, out_channel=32, edge_dim=32,node_dim=32, hidden_dimension=32):
#         super().__init__()
#         self.node_conv = GCNConv(in_channels, 32)


#         self.edge_mlp = torch.nn.Sequential(
#             torch.nn.Linear(node_dim * 2 + edge_dim, hidden_dim),
#             torch.nn.ReLU(),
#             torch.nn.Linear(hidden_dim, output_dim)
#         )
#         self.node_update_mlp = torch.nn.Sequential(
#             torch.nn.Linear(node_dim + output_dim, hidden_dim),
#             torch.nn.ReLU(),
#             torch.nn.Linear(hidden_dim, out_channel)
#         )

#     def forward(self, x, edge_index, edge_attr):
#         # Step 1: Node feature transformation
#         # x = self.node_conv(x, edge_index)
    

#         # Edge embedding
#         row, col = edge_index
#         edge_embeddings = torch.cat([x[row], x[col], edge_attr], dim=1)
#         edge_embeddings = self.edge_mlp(edge_embeddings)
        
#         # Step 3: Aggregate edge features for each node
#         edge_index, _ = add_self_loops(edge_index, num_nodes=x.size(0))
#         adj = to_dense_adj(edge_index)[0]


#         aggregated_edge_features = torch.matmul(adj, edge_embeddings)

#         # Step 4: Concatenate node features with aggregated edge features
#         node_edge_concat = torch.cat([x, aggregated_edge_features], dim=1)

#         # Step 5: Transform concatenated features to update node features
#         updated_node_features = self.node_update_mlp(node_edge_concat)
        
#         return updated_node_features, edge_embeddings



