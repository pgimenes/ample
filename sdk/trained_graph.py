import networkx as nx
import numpy as np
import matplotlib.pyplot as plt

from torch_geometric.utils import to_networkx

import random

class TrainedGraph:
    def __init__(self, dataset, embeddings=[], weights=[]):
        self.dataset = dataset
        self.nx_graph = to_networkx(self.dataset)

        self.node_ids, self.node_offsets = np.unique(dataset.edge_index[0], return_index=True)

        for node in self.nx_graph.nodes:
            neighbours = list(self.nx_graph.neighbors(node))
            self.nx_graph.nodes[node]['neighbours'] = neighbours
            self.nx_graph.nodes[node]['neighbour_count'] = len(neighbours)
            self.nx_graph.nodes[node]['adj_list_offset'] = int(self.node_offsets[node])
        
        self.node_count = len(list(self.nx_graph.nodes))

        # Local copy of embeddings stored in node objects
        self.embeddings = embeddings
        # Feature count initialization may change when embeddings are trained
        self.feature_count = len(dataset.x[0])

        # Trained weights
        self.weights = weights

    def visualize(self):
        pos = nx.spring_layout(self.nx_graph)
        nx.draw(self.nx_graph, pos, with_labels=True)
        plt.show()

    def random_embeddings(self, feature_size=64):
        self.feature_count = feature_size
        self.embeddings = np.zeros((self.node_count, feature_size))
        for node in range(self.node_count):
            embd = [random.uniform(-2, 2) for _ in range(feature_size)]
            self.nx_graph.nodes[node]['embedding'] = embd
            self.embeddings[node] = self.nx_graph.nodes[node]['embedding']

    def random_weights(self):
        self.weights = np.zeros((self.feature_count, self.feature_count))
        for outf in range(self.feature_count):
            self.weights[outf] = [random.uniform(-2, 2) for _ in range(self.feature_count)]