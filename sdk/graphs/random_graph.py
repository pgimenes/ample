
from sdk.trained_graph import TrainedGraph
from torch_geometric.datasets import FakeDataset

class RandomGraph(TrainedGraph):
    def __init__(
            self,
            num_nodes = 10000,
            avg_degree = 2,
            num_channels=64,
            graph_precision="FLOAT_32"
            ):
        
        self.num_nodes = num_nodes
        self.avg_degree = avg_degree

        dataset = FakeDataset(
                                num_graphs=1, 
                                avg_num_nodes = num_nodes,
                                avg_degree=avg_degree,
                                num_channels=num_channels
                            )[0]
        super().__init__(dataset=dataset, feature_count=num_channels, graph_precision=graph_precision)