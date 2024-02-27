import networkx as nx
import numpy as np
import matplotlib.pyplot as plt

import torch
from torch_geometric.utils import to_networkx
from torch_geometric.loader import GraphSAINTRandomWalkSampler

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

        # Feature count initialization may change when embeddings are trained
        self.feature_count = feature_count

        self.init_nx_graph()

        # Local copy of embeddings stored in node objects
        self.embeddings = embeddings

        # TO DO: read dequantization parameter from QAT
        self.dequantization_parameter = 1

    def visualize(self):
        pos = nx.spring_layout(self.nx_graph)
        nx.draw(self.nx_graph, pos, with_labels=True)
        plt.show()

    def reduce(self):
        logging.info("Reducing graph.")

        print(f"dataset has type {type(self.dataset)}")

        logging.info("STATS BEORE REDUCE")
        logging.info(f"node_count: {self.dataset.num_nodes}, edge_count: {self.dataset.num_edges}")

        loader = GraphSAINTRandomWalkSampler(self.dataset, batch_size=100, walk_length=2, num_steps=5, sample_coverage=100, save_dir="processed", num_workers=4)
        logging.info(f"Loader has size {len(loader)}")

        for data in loader:
            logging.info(f"Data shape: {data.x.shape}")
            logging.info(f"Edge index: {data.edge_index.shape}")


    def init_nx_graph(self):
        counts = {"FLOAT_32": 0, "FIXED_8": 0}
        
        largest_nb_count = 0
        for node in self.nx_graph.nodes:
            neighbours = list(self.nx_graph.neighbors(node))
            if (len(neighbours) > largest_nb_count):
                largest_nb_count = len(neighbours)
                logging.debug(f"Largest neighbour count so far {len(neighbours)}")
            self.nx_graph.nodes[node]['neighbours'] = neighbours
            self.nx_graph.nodes[node]['neighbour_count'] = len(neighbours)
            self.nx_graph.nodes[node]['adj_list_offset'] = int(self.node_offsets[node])
            self.nx_graph.nodes[node]['neighbour_message_ptrs'] = [4*self.feature_count*nb_ptr for nb_ptr in neighbours]
            self.nx_graph.nodes[node]['adjacency_list_address_lsb'] = 0 # to be defined my init manager
            self.nx_graph.nodes[node]['aggregation_function'] = "SUM"

            # Add a single scale factor to isolated nodes to occupy memory range
            self.nx_graph.nodes[node]['scale_factors'] = [1] * len(neighbours) if len(neighbours) > 0 else [1]
            
            if (self.graph_precision == 'mixed'):
                prec = random.choice(["FLOAT_32", "FIXED_8"])
            else:
                prec = self.graph_precision
            
            self.nx_graph.nodes[node]['precision'] = prec
            counts[prec] = counts[prec] + 1

        for prec in ["FLOAT_32", "FIXED_8"]:
            precision_filter = [node for node in self.nx_graph.nodes if self.nx_graph.nodes[node]['precision'] == prec]
            mod = counts[prec] % 4
            logging.debug(f"Precision {prec} has {len(precision_filter)} nodes")
            logging.debug(f"Precision {prec} has modulus {mod}")
            if (mod == 0):
                continue
            for node in precision_filter[-mod:]: # choose last N nodes where N is modulus with wait count
                # Invalidate nodes so they get dropped by testbench
                logging.debug(f"Node {node} being dropped")
                self.nx_graph.nodes[node]['neighbour_count'] = 0
            
    def random_embeddings(self):
        logging.debug(f"Generating random graph embeddings.")

        self.dataset.x = torch.zeros((self.dataset.x.shape[0], self.feature_count))
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
            self.embeddings[node] = embd
            self.dataset.x[node] = torch.tensor(embd, dtype=torch.float)
        
    def __str__(self) -> str:
        return "TrainedGraph"
