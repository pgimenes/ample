
from sdk.trained_graph import TrainedGraph
from networkx.generators.random_graphs import erdos_renyi_graph

class RandomGraph(TrainedGraph):
    def __init__(self, node_count=64, 
                p=0.5,
                feature_count=64, 
                graph_precision="FLOAT_32"):

        
        super().__init__(dataset=dataset, feature_count=feature_count, graph_precision=graph_precision)