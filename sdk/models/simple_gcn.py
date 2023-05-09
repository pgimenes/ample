import torch
import torch.nn as nn
import torch.nn.functional as F
from torch_geometric.nn import GCNConv

class SimpleGCN(nn.Module):
    def __init__(self, in_channels, out_channels):
        super(SimpleGCN, self).__init__()
        self.conv1 = GCNConv(in_channels, 16)
        self.conv2 = GCNConv(16, out_channels)

    def forward(self, x, edge_index):
        x = self.conv1(x, edge_index)
        x = F.relu(x)
        x = F.dropout(x, training=self.training)
        x = self.conv2(x, edge_index)
        return F.log_softmax(x, dim=1)

    def evaluate(self, model, x, edge_index, y, mask):
      model.eval()
      with torch.no_grad():
          logits = model(x, edge_index)
          pred = logits.argmax(dim=1)
          correct = pred[mask].eq(y[mask]).sum().item()
          acc = correct / mask.sum().item()
          return acc