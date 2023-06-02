import networkx as nx
import numpy as np
import matplotlib.pyplot as plt

import torch
from torch_geometric.utils import to_networkx

import random

import logging
class TrainedGraph:
    def __init__(self, dataset, feature_count=64, embeddings=[], graph_precision="FLOAT_32"):
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
        self.feature_count = feature_count

        # TO DO: read activation from model object
        self.transformation_activation = 1 # relu
        self.transformation_bias = 0
        self.leaky_relu_alpha = 0.2

        # TO DO: read dequantization parameter from QAT
        self.dequantization_parameter = 1

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

                    # Add a single scale factor to isolated nodes to occupy memory range
                    self.nx_graph.nodes[node]['scale_factors'] = [1] * len(neighbours) if len(neighbours) > 0 else [1]
                    
                    if (self.graph_precision == 'mixed'):
                        prec = random.choice(["FLOAT_32", "FIXED_16"])
                        # print(f"Initializing node {node} with precision {prec}")
                        self.nx_graph.nodes[node]['precision'] = prec
                    else:
                        self.nx_graph.nodes[node]['precision'] = self.graph_precision
                         
    def random_embeddings(self):
        logging.debug(f"Generating random graph embeddings.")

        self.embeddings = np.zeros((len(self.nx_graph.nodes), self.feature_count))
        for node in self.nx_graph.nodes:

            # Define range according to precision
            if (self.nx_graph.nodes[node]['precision'] == "FLOAT_32"):
                embd = [random.uniform(-2, 2) for _ in range(self.feature_count)]
            elif (self.nx_graph.nodes[node]['precision'] == "FIXED_16"):
                embd = [random.randint(-8, 7) for _ in range(self.feature_count)]
            elif (self.nx_graph.nodes[node]['precision'] == "FIXED_8"):
                embd = [random.randint(-8, 7) for _ in range(self.feature_count)]
            elif (self.nx_graph.nodes[node]['precision'] == "FIXED_4"):
                embd = [random.randint(-8, 7) for _ in range(self.feature_count)]
            else:
                print(f"Unrecognized precision, defaulting to float.")
                embd = [random.uniform(-2, 2) for _ in range(self.feature_count)]

            self.nx_graph.nodes[node]['embedding'] = embd
        
        # Update dataset object
        self.dataset.x = torch.tensor(self.embeddings, dtype=torch.float)

    def __str__(self) -> str:
        return "TrainedGraph"
