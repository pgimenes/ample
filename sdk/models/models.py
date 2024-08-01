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
            layer  = GCNConv(in_channels, out_channels,normalize =False)
            layer.name = 'gcn_layer_input_output0'
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
    def __init__(self, in_channels, out_channels, layer_count=1, hidden_dimension=32,precision = torch.float32):
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
                if i == 0:
                    layer.name = f'linear_input_layer{i}'
                else:
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
        # x = x.to(self.precision)  
        outputs = []
        for layer in self.layers:
            x = layer(x)
            outputs.append(x)

        return outputs



def convert_edges_to_nodes(edge_index):
    num_edges = edge_index.size(1)
    num_nodes = edge_index.max().item() + 1  # Number of original nodes
    
    # New node indices for each edge
    new_node_indices = torch.arange(num_nodes, num_nodes + num_edges)
    
    # Source nodes for the new edges
    src_nodes = edge_index[0]
    # Destination nodes for the new edges
    dst_nodes = edge_index[1]
    
    # New edges: connect source node to new node and new node to destination node
    new_edges_1 = torch.stack([src_nodes, new_node_indices])
    new_edges_2 = torch.stack([new_node_indices, dst_nodes])
    
    # Concatenate the new edges to form the new edge_index
    new_edge_index = torch.cat([new_edges_1, new_edges_2], dim=1)
    
    return new_edge_index


class EdgeGCNLayer(nn.Module):
    def __init__(self, in_channels=32, out_channels=32):
        super().__init__()
        self.in_channels = in_channels
        self.out_channels = out_channels
        self.update_mlp = nn.Linear(in_channels, out_channels)

    def forward(self, src_embed, rx_embed, edge_embed):
        # Aggregating the embeddings with learnable weights
        combined = src_embed + rx_embed + edge_embed

        # Update with a non-linearity and another MLP layer
        updated_edge_embed = self.update_mlp(combined)
        
        return updated_edge_embed


torch.fx.wrap('agg_mlp')

def agg_mlp(x1, x2, x3):
    model = nn.Sequential(
    nn.Linear(32, 32), 
    )
    output = model(x1 + x2 + x3)

    return output

class Edge_Embedding_Model(torch.nn.Module): #NodeRx_Src_Embedding_Model
    def __init__(self, in_channels, out_channels=32, layer_count=1, hidden_dimension=32, precision = torch.float32):
        super().__init__()
        self.precision = precision
        self.layers = nn.ModuleList()

        #########Source Node MLP#########
        self.src_embedder = nn.Linear(in_channels, out_channels, bias=True)

        #########Receive Node MLP#########
        self.rx_embedder = nn.Linear(in_channels, out_channels, bias=True)
        # layer.name = 'input_output_layer_rx'  # Assign name directly
        # self.layers.append(layer)


        #########Edge Node MLP#########
        #Change to GCN to aggregate itself and last layer edge if not first model
        self.edge_embedder = nn.Linear(in_channels, hidden_dimension, bias=True)
        # layer.name = 'input_layer_edge'  # Assign name directly
        # self.layers.append(layer)


        for layer in self.layers:
            layer.to(self.precision)

    def forward(self, data, edge_index):
        # x = x.to(self.precision)  
        outputs = []
        #Somehow need to choose x[col] and x[row], perhaps give each their own nodeslots?
        x= data.x
        edge_attr = data.edge_attr
        row, col = edge_index

        src_embed = self.src_embedder(x[col])
        outputs.append(src_embed)

        rx_embed = self.rx_embedder(x[row])
        outputs.append(rx_embed)

        edge_embed = self.edge_embedder(edge_attr)
        outputs.append(edge_embed)

        edge_update = agg_mlp(src_embed,rx_embed,edge_embed)

        outputs.append(edge_update)

        return outputs

