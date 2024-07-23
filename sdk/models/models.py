import torch
import torch.nn as nn
import torch.nn.functional as F

from torch.nn import Linear
from torch.nn import ReLU
from torch_geometric.nn import GCNConv, GATConv, SAGEConv, GINConv
import pytorch_lightning as pl
from torch import Tensor

import numpy as np
'''
Graph Convolutional Network
'''

class GCN_Model(torch.nn.Module):
    def __init__(self, in_channels: int, out_channels: int, layer_count=1, hidden_dimension=64):
        super().__init__()
        self.layers = nn.ModuleList()
        if layer_count == 1:
            self.layers.append(GCNConv(in_channels, out_channels,normalize =False))
        else:
            self.layers.append(GCNConv(in_channels, hidden_dimension,normalize =False))
            for _ in range(layer_count-2):
                self.layers.append(GCNConv(hidden_dimension, hidden_dimension,normalize =False))
            self.layers.append(GCNConv(hidden_dimension, out_channels,normalize =False))

    def forward(self, x: Tensor, edge_index: Tensor):
        outputs = []
        for layer in self.layers:
            x = layer(x, edge_index)
            outputs.append(x)
        # outputs_array = np.stack(outputs)  # Stack all outputs into a single NumPy array

        return outputs


#           outputs = []
#         # output_all_layers=False
#         for layer in self.layers:
#             x = layer(x, edge_index)
#             # if output_all_layers:
#             #     outputs.append(x)
        
#         # if output_all_layers:
#         #     return outputs
#         # else:
#         return x
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
    





class LinearReLU(nn.Module):
    def __init__(self, in_features, out_features):
        super(LinearReLU, self).__init__()
        self.linear = nn.Linear(in_features, out_features)
        self.relu = nn.ReLU()

    def forward(self, x):
        x = self.linear(x)
        x = self.relu(x)
        return x



#Graphcast Test Models


class GCN_MLP_Model(pl.LightningModule):
    def __init__(self, in_channels, out_channels, layer_count=1, hidden_dimension=32):
        super().__init__()
        self.layers = nn.ModuleList()
        self.layers.append(GCNConv(in_channels, hidden_dimension))
        for _ in range(layer_count-2):
            self.layers.append(Linear(hidden_dimension, hidden_dimension, bias=True))
            # self.layers.append(ReLU())

        self.layers.append(Linear(hidden_dimension, out_channels, bias=True))

    def forward(self, x, edge_index):
        for layer in self.layers:
            out = layer(x, edge_index)
        return out
    


layer_outputs = {}

def capture_outputs(module, input, output):
    # Explicitly ensuring the input is a tuple, as expected by TorchScript
    if not isinstance(input, tuple):
        input = (input,)
    layer_name = module.name
    output_detached = output.detach()

    if layer_name in layer_outputs:
        layer_outputs[layer_name].append(output_detached)
    else:
        layer_outputs[layer_name] = [output_detached]


class MLP_Model(torch.nn.Module):
    def __init__(self, in_channels, out_channels, layer_count=1, hidden_dimension=32):
        super().__init__()
        self.layers = nn.ModuleList()
        if layer_count == 1:
            layer = nn.Linear(in_channels, out_channels, bias=True)
            layer.name = 'output_layer'  # Assign name directly
            self.layers.append(layer)

        else:
             # Input layer
            layer = nn.Linear(in_channels, hidden_dimension, bias=True)
            layer.name = 'input_layer'
            self.layers.append(layer)
            for i in range(layer_count-2):
                layer = nn.Linear(hidden_dimension, hidden_dimension, bias=True)
                layer.name = f'hidden_layer_{i}'
                self.layers.append(layer)
                # self.layers.append(Linear(hidden_dimension, hidden_dimension, bias=True))
                # self.layers.append(ReLU())
                # self.layers.append(LinearReLU(hidden_dimension, hidden_dimension))

             # Output layer
            layer = nn.Linear(hidden_dimension, out_channels, bias=True)
            layer.name = 'output_layer'
            self.layers.append(layer)

        #  # Register the hook
        # for layer in self.layers:
        #     layer.register_forward_hook(capture_outputs)

    def forward(self, x, edge_index,):
        outputs = []
        for layer in self.layers:
            x = layer(x)
            outputs.append(x)
        # outputs_array = np.stack(outputs)  # Stack all outputs into a single NumPy array

        return outputs
    
      #     if output_all_layers:
        #         outputs.append(x)
        
        # if output_all_layers:
        #     return outputs
        # else:

