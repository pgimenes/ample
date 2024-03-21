
from sdk.trained_graph import TrainedGraph

import torch
from torch_geometric.datasets import Planetoid

class PlanetoidGraph(TrainedGraph):
    def __init__(self, name="Pubmed", embeddings=[], graph_precision="FLOAT_32", self_connection=False, feature_count=64):
        self.device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
        dataset=Planetoid(root=".", name=name)[0]
        embeds = dataset.x if (embeddings == []) else embeddings
        super().__init__(dataset=dataset, embeddings=embeds, graph_precision=graph_precision, self_connection=self_connection, feature_count=feature_count)

    def __str__(self) -> str:
        return "PlanetoidGraph"