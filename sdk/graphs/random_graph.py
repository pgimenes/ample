
from sdk.trained_graph import TrainedGraph
from torch_geometric.datasets import FakeDataset

class RandomGraph(TrainedGraph):
    def __init__(
            self,
            num_nodes = 10000,
            avg_degree = 2,
            num_channels=64,
            graph_precision="FLOAT_32",
            edge_dim=0
            ):
        
        self.num_nodes = num_nodes
        self.avg_degree = avg_degree

        dataset = FakeDataset(
                                num_graphs=1, 
                                avg_num_nodes = num_nodes,
                                avg_degree=avg_degree,
                                num_channels=num_channels,
                                edge_dim=edge_dim
                            )[0]

        
        
        super().__init__(dataset=dataset, graph_precision=graph_precision)