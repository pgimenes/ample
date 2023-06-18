import torch
import torch.nn as nn
import torch.nn.functional as F
from torch_geometric.nn import GCNConv, GATConv, SAGEConv
import pytorch_lightning as pl

'''
Graph Convolutional Network
'''

class GCN_Model(pl.LightningModule):
    def __init__(self, in_channels, out_channels):
        super().__init__()
        self.layers = nn.ModuleList()
        self.layers.append(GCNConv(in_channels, out_channels))

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
    def __init__(self, num_features, num_classes):
        super().__init__()

        self.dim_in = num_features
        self.dim_h = 64
        self.dim_out = num_classes

        self.sage1 = SAGEConv(self.dim_in, self.dim_h*2)
        self.sage2 = SAGEConv(self.dim_h*2, self.dim_h)
        self.sage3 = SAGEConv(self.dim_h, self.dim_out)

    def forward(self, x, edge_index):
        x = self.sage1(x, edge_index)
        x = torch.relu(x)
        x = F.dropout(x, p=0.5, training=self.training)
        x = self.sage2(x, edge_index)
        x = torch.relu(x)
        x = F.dropout(x, p=0.2, training=self.training)
        x = self.sage3(x, edge_index)
        return F.log_softmax(x, dim=1)