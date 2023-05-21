import networkx as nx
import numpy as np
import matplotlib.pyplot as plt

from torch_geometric.utils import to_networkx

import random

class TrainedGraph:
    def __init__(self, dataset, embeddings=[], weights=[], graph_precision="float"):
        self.dataset = dataset
        self.nx_graph = to_networkx(self.dataset)
        self.graph_precision = graph_precision

        # Node offsets in adjacency list
        node_ids, node_offsets = np.unique(dataset.edge_index[0], return_index=True)
        self.node_offsets = [0] * len(self.nx_graph.nodes)
        for idx, i in enumerate(node_ids):
            self.node_offsets[i] = node_offsets[idx]

        self.init_nx_graph()

        # Local copy of embeddings stored in node objects
        self.embeddings = embeddings
        # Feature count initialization may change when embeddings are trained
        self.feature_count = len(dataset.x[0])

        # TO DO: read activation from model object
        self.transformation_activation = 1 # relu
        self.transformation_bias = 0

        # Trained weights
        self.weights = weights

    def visualize(self):
        pos = nx.spring_layout(self.nx_graph)
        nx.draw(self.nx_graph, pos, with_labels=True)
        plt.show()

    def init_nx_graph(self):
        for node in self.nx_graph.nodes:
                    neighbours = list(self.nx_graph.neighbors(node))
                    self.nx_graph.nodes[node]['neighbours'] = neighbours
                    self.nx_graph.nodes[node]['neighbour_count'] = len(neighbours)
                    self.nx_graph.nodes[node]['adj_list_offset'] = int(self.node_offsets[node])
                    self.nx_graph.nodes[node]['adjacency_list_address_lsb'] = 0 # to be defined my init manager
                    self.nx_graph.nodes[node]['aggregation_function'] = "SUM"
                    
                    if (self.graph_precision == 'mixed'):
                        prec = random.choice(["FLOAT_32", "FIXED_16"])
                        self.nx_graph.nodes[node]['precision'] = prec
                        # print(f"Initializing node {node} with precision {prec}")
                    else:
                        self.nx_graph.nodes[node]['precision'] = self.graph_precision
                         
    def random_embeddings(self, feature_size=64):
        self.feature_count = feature_size

        self.embeddings = np.zeros((len(self.nx_graph.nodes), feature_size))
        for node in self.nx_graph.nodes:

            # Define range according to precision
            if (self.nx_graph.nodes[node]['precision'] == "FLOAT_32"):
                embd = [random.uniform(-2, 2) for _ in range(feature_size)]
            elif (self.nx_graph.nodes[node]['precision'] == "FIXED_16"):
                embd = [random.randint(-32768, 32767) for _ in range(feature_size)]
            elif (self.nx_graph.nodes[node]['precision'] == "FIXED_8"):
                embd = [random.randint(-128, 127) for _ in range(feature_size)]
            elif (self.nx_graph.nodes[node]['precision'] == "FIXED_4"):
                embd = [random.randint(-8, 7) for _ in range(feature_size)]
            else:
                print(f"Unrecognized precision, defaulting to float.")
                embd = [random.uniform(-2, 2) for _ in range(feature_size)]

            self.nx_graph.nodes[node]['embedding'] = embd
            self.embeddings[node] = self.nx_graph.nodes[node]['embedding']

    def random_weights(self):
        self.weights = np.zeros((self.feature_count, self.feature_count))
        for outf in range(self.feature_count):
            self.weights[outf] = [random.uniform(-2, 2) for _ in range(self.feature_count)]