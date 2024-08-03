import torch
import torch.nn as nn
import torch.nn.functional as F

from torch.nn import Linear
from torch.nn import ReLU
from torch_geometric.nn import MessagePassing, GCNConv, GATConv, SAGEConv, GINConv
import pytorch_lightning as pl
from torch import Tensor
from torch_geometric.typing import SparseTensor
import numpy as np
import torch_scatter

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

# class Edge_Embedding_Model(torch.nn.Module): #NodeRx_Src_Embedding_Model
#     def __init__(self):
#         super().__init__()


class AGG_MLP_Model(nn.Module):
    def __init__(self, in_features=32, out_features=32):
        super().__init__()
        # self.add = add_tensors()
        self.in_features = in_features
        self.out_features = out_features
        self.lin = nn.Linear(in_features, out_features,bias = False)

    def forward(self, edge_embed, src_embed, rx_embed):
        # agg = torch.add(edge_embed, src_embed, rx_embed)
        agg = edge_embed + src_embed + rx_embed
        out = self.lin(agg)
        return out

class Edge_Embedding_Model(torch.nn.Module): #NodeRx_Src_Embedding_Model
    def __init__(self, in_channels=32, out_channels=32, layer_count=1, hidden_dimension=32, precision = torch.float32):
        super().__init__()
        self.precision = precision
        self.layers = nn.ModuleList()

        #########Source Node Edge Embed MLP#########
        self.src_embedder = nn.Linear(in_channels, out_channels, bias=False) 
        self.src_embedder.name  = 'src_embedder'
        self.layers.append(self.src_embedder) #Used to map weights in SDK


        #########Edge Node MLP#########
        #Change to GCN to aggregate itself and last layer edge if not first model
        self.edge_embedder = nn.Linear(in_channels, hidden_dimension, bias=False)
        self.edge_embedder.name = 'edge_embedder'
        self.layers.append(self.edge_embedder)


        #########Receive Node Edge Embed MLP#########
        self.rx_embedder = nn.Linear(in_channels, out_channels, bias=False)
        self.rx_embedder.name = 'rx_embedder'
        self.layers.append(self.rx_embedder)


        #########Edge Node Update#########
        self.edge_update = AGG_MLP_Model(in_channels, hidden_dimension)
        self.edge_update.name = 'edge_update'
        self.layers.append(self.edge_update)


        for layer in self.layers:
            layer.to(self.precision)

    def forward(self, x, edge_index,edge_attr):
        x = x.to(self.precision)  
        outputs = []

        #TODO change to U and V to match with SDK
        u = edge_index[0]
        v = edge_index[1]
        # print('edege_index')
        # print(u)
        # print(v)
        src_embed = self.src_embedder(x)
        outputs.append(src_embed)

        #Check edge attributes are mapped correctly

        edge_embed = self.edge_embedder(edge_attr)
        outputs.append(edge_embed)
        # print('edge_embed')
        # print(edge_embed)

        rx_embed = self.rx_embedder(x)
        outputs.append(rx_embed)

        src_embed = src_embed[u]
        rx_embed = rx_embed[v]
        
        updated_edge = self.edge_update(src_embed,edge_embed,rx_embed)

        outputs.append(updated_edge)

        return outputs



class AggregateEdges(torch.nn.Module):
    def __init__(self,in_channels=32,out_channels=32):
        super().__init__()
        self.in_channels = in_channels
        self.out_channels = out_channels
        self.lin = torch.nn.Linear(in_channels, out_channels,bias=False)

    def forward(self, edge_index, edge_attr):
        # x: Node feature matrix with shape [num_nodes, num_node_features]
        # edge_index: Graph connectivity (edge indices) with shape [2, num_edges]
        # edge_attr: Edge feature matrix with shape [num_edges, num_edge_features]
        # print('edge_index')
        # print(edge_index)
        # print('rx')
        rx  = edge_index[1]
        # print(rx)
        output = torch_scatter.scatter_add(edge_attr, rx.unsqueeze(1).expand(-1, edge_attr.size(1)), dim=0)
        # x = torch_scatter.scatter_add(edge_attr, rx)
        output = self.lin(output)
        return output
        # return self.propagate(edge_index, x=x, edge_attr=edge_attr)


# class AggregateEdges(MessagePassing):
#     def __init__(self,in_channels=32,out_channels=32):
#         super().__init__()

#         self.in_channels = in_channels
#         self.out_channels = out_channels
#         self.lin = torch.nn.Linear(in_channels, out_channels,bias=False)

#     def forward(self, x, edge_index, edge_attr):
#         # Add self loops to the adjacency matrix if needed
#         # edge_index, _ = add_self_loops(edge_index, num_nodes=x.size(0))

#         # Start propagating messages
#         return self.propagate(edge_index, x=x, edge_attr=edge_attr)

#     def message(self, edge_attr):
#         # Return edge attributes as the message to be passed
#         return edge_attr

#     def aggregate(self, inputs, index):
#     #     # Summing up all incoming edge attributes for each node
#         return torch_scatter.scatter(inputs, index, dim=0, reduce='sum')

#     def update(self, aggr_out):
#         # Return the aggregated result as the updated node features
#         transformed = self.lin(aggr_out)
#         return transformed

class Interaction_Net_Model(torch.nn.Module): #NodeRx_Src_Embedding_Model
    def __init__(self, in_channels=32, out_channels=32, layer_count=1, hidden_dimension=32, precision = torch.float32):
        super().__init__()
        self.precision = precision
        self.layers = nn.ModuleList()

        #########Source Node Edge Embed MLP#########
        self.src_embedder = nn.Linear(in_channels, out_channels, bias=False)
        self.src_embedder.name  = 'src_embedder'
        self.layers.append(self.src_embedder) #Used to map weights in SDK


        #########Edge Node MLP#########
        #Change to GCN to aggregate itself and last layer edge if not first model
        self.edge_embedder = nn.Linear(in_channels, hidden_dimension, bias=False)
        self.edge_embedder.name = 'edge_embedder'
        self.layers.append(self.edge_embedder)


        #########Receive Node Edge Embed MLP#########
        self.rx_embedder = nn.Linear(in_channels, out_channels, bias=False)
        self.rx_embedder.name = 'rx_embedder'
        self.layers.append(self.rx_embedder)


        #########Edge Node GCN#########
        self.edge_update = AGG_MLP_Model(in_channels, hidden_dimension)
        self.edge_update.name = 'edge_update'
        self.layers.append(self.edge_update)


        #---------- Node Update --------------

        #########Receive Node Embed #########
        self.rx_node_embedder = nn.Linear(in_channels, out_channels, bias=False)
        self.rx_node_embedder.name = 'rx_node_embedder'
        self.layers.append(self.rx_node_embedder)

        #########Receive Node Aggregate Edges #########
        self.rx_edge_aggr = AggregateEdges(in_channels, out_channels)
        self.rx_edge_aggr.name = 'rx_edge_aggr'
        self.layers.append(self.rx_edge_aggr)


        #########Receive Node Update #########
        self.rx_node_update = AGG_MLP_Model(in_channels, hidden_dimension)
        self.rx_node_update.name = 'rx_node_update'
        self.layers.append(self.rx_node_update)



        for layer in self.layers:
            layer.to(self.precision)

    def forward(self, x, edge_index,edge_attr):
        x = x.to(self.precision)  
        outputs = []

        #TODO change to U and V to match with SDK
        u = edge_index[0] #Source nodes
        v = edge_index[1] #Receive nodes
        # print('edege_index')
        # print(u)
        # print(v)
        src_embed = self.src_embedder(x)
        outputs.append(src_embed)

        #Check edge attributes are mapped correctly

        edge_embed = self.edge_embedder(edge_attr)
        outputs.append(edge_embed)
        # print('edge_embed')
        # print(edge_embed)

        rx_embed = self.rx_embedder(x)
        outputs.append(rx_embed)

        src_embed = src_embed[u]
        rx_embed = rx_embed[v]
        
        updated_edge = self.edge_update(src_embed,edge_embed,rx_embed)
        outputs.append(updated_edge)

        rx_node_embed = self.rx_node_embedder(x) #TODO change to x[v] - more efficient
        outputs.append(rx_node_embed)

        rx_aggregated_edges = self.rx_edge_aggr(edge_index,updated_edge) #TODO change to x[v] - more efficient
        outputs.append(rx_aggregated_edges)

        print('rx_node_embed',rx_node_embed)
        print('rx_aggregated_edges',rx_aggregated_edges)

        # rx_node_embed = rx_node_embed
        updated_node = self.rx_node_update(rx_node_embed,rx_aggregated_edges,0)

        outputs.append(updated_node)



        return outputs

