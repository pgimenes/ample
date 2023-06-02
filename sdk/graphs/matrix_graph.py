import torch
from torch_geometric.data import InMemoryDataset, Data
import networkx as nx
from sdk.trained_graph import TrainedGraph
import numpy as np

class MatrixDataset(InMemoryDataset):
    def __init__(self):
        super(MatrixDataset, self).__init__(".", transform=None, pre_transform=None)
        
        self.data, self.slices = self.process()
        
    @property
    def raw_file_names(self):
        return []

    @property
    def processed_file_names(self):
        return ['data.pt']
    
    def download(self):
        # Download to `self.raw_dir`.
        pass

    def process(self):
        # Create Data object
        x = torch.tensor(np.eye(4), dtype=torch.float)
        edge_index = torch.tensor([[0, 0, 3, 3, 6, 6, 9, 9], [1, 2, 4, 5, 7, 8, 10, 11]], dtype=torch.long)
        y = torch.tensor([0]*12, dtype=torch.long)
        data = Data(x=x, edge_index=edge_index, y=y)
        
        # Create data list
        data_list = [data]
        
        # Apply pre-filtering and pre-transform
        if self.pre_filter is not None:
            data_list = [data for data in data_list if self.pre_filter(data)]

        if self.pre_transform is not None:
            data_list = [self.pre_transform(data) for data in data_list]

        data, slices = self.collate(data_list)
        torch.save((data, slices), self.processed_paths[0])
        return data, slices

class MatrixGraph(TrainedGraph):
    def __init__(self, feature_count=4):
        dataset = MatrixDataset()[0]
        super().__init__(dataset=dataset, feature_count=feature_count)

    def train_embeddings(self):
        self.random_embeddings()

    def __str__(self) -> str:
        return "MatrixGraph"