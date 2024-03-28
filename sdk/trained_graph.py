import networkx as nx
import numpy as np
import matplotlib.pyplot as plt

import torch
from torch_geometric.utils import to_networkx
from torch_geometric.loader import GraphSAINTRandomWalkSampler

import random

import logging

from tqdm import tqdm

class TrainedGraph:
    def __init__(self, dataset, embeddings=[], graph_precision="FLOAT_32", self_connection=False):
        self.dataset = dataset
        self.nx_graph = to_networkx(self.dataset)
        self.graph_precision = graph_precision

        # Node offsets in adjacency list
        node_ids, node_offsets = np.unique(dataset.edge_index[0], return_index=True)
        self.node_offsets = [0] * len(self.nx_graph.nodes)
        for idx, i in enumerate(node_ids):
            self.node_offsets[i] = node_offsets[idx]

        # Feature count initialization may change when embeddings are trained
        self.feature_count = dataset.x.shape[1]

        self.init_nx_graph(self_connection=self_connection)

        # Local copy of embeddings stored in node objects
        self.embeddings = embeddings

        # TO DO: read dequantization parameter from QAT
        self.dequantization_parameter = 1

    def init_nx_graph(self, self_connection=False):
        for node in self.nx_graph.nodes:
            neighbours = list(self.nx_graph.neighbors(node))
            if self_connection:
                neighbours += [node]
            self.nx_graph.nodes[node]["meta"] = {
                'neighbours' : neighbours,
                'neighbour_count': len(neighbours),
                'aggregation_function': "SUM",
                
                'adj_list_offset': int(self.node_offsets[node]),
                'neighbour_message_ptrs': [4*self.feature_count*nb_ptr for nb_ptr in neighbours],
                'adjacency_list_address_lsb': 0, # to be defined by init manager
                
                # Add a single scale factor to isolated nodes to occupy memory range
                'scale_factors': [1] * len(neighbours) if len(neighbours) > 0 else [1],

                'precision': random.choice(["FLOAT_32", "FIXED_8"]) if self.graph_precision == 'mixed' else self.graph_precision
            }

    def apply_self_connection(self):
        for node in self.nx_graph.nodes:
            neighbours = self.nx_graph.nodes[node]["meta"]["neighbours"] + [node]
            self.nx_graph.nodes[node]["meta"]["neighbours"] = neighbours
            self.nx_graph.nodes[node]["meta"]["neighbour_count"] = len(neighbours)
            self.nx_graph.nodes[node]["meta"]["neighbour_message_ptrs"] = [4*self.feature_count*nb_ptr for nb_ptr in self.nx_graph.nodes[node]["meta"]["neighbours"]]
            self.nx_graph.nodes[node]["meta"]['scale_factors'] = [1] * len(neighbours) if len(neighbours) > 0 else [1]

    def set_aggregation(self, aggregation):
        for node in self.nx_graph.nodes:
            self.nx_graph.nodes[node]["meta"]["aggregation_function"] = aggregation[node]

    def set_scale_factors(self, scale_factors):
        for node in self.nx_graph.nodes:
            self.nx_graph.nodes[node]["meta"]["scale_factors"] = scale_factors[node]

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
            
    def random_embeddings(self):
        logging.debug(f"Generating random graph embeddings.")

        self.dataset.x = torch.zeros((self.dataset.x.shape[0], self.feature_count))
        self.embeddings = np.zeros((len(self.nx_graph.nodes), self.feature_count))
        for node in self.nx_graph.nodes:

            # Define range according to precision
            if (self.nx_graph.nodes[node]["meta"]['precision'] == "FLOAT_32"):
                embd = [random.uniform(-2, 2) for _ in range(self.feature_count)]
            elif (self.nx_graph.nodes[node]["meta"]['precision'] == "FIXED_16"):
                embd = [random.randint(-8, 7) for _ in range(self.feature_count)]
            elif (self.nx_graph.nodes[node]["meta"]['precision'] == "FIXED_8"):
                embd = [random.randint(-8, 7) for _ in range(self.feature_count)]
            elif (self.nx_graph.nodes[node]["meta"]['precision'] == "FIXED_4"):
                embd = [random.randint(-8, 7) for _ in range(self.feature_count)]
            else:
                print(f"Unrecognized precision, defaulting to float.")
                embd = [random.uniform(-2, 2) for _ in range(self.feature_count)]

            self.nx_graph.nodes[node]["meta"]['embedding'] = embd
            self.embeddings[node] = embd
            self.dataset.x[node] = torch.tensor(embd, dtype=torch.float)

    def visualize(self):
        pos = nx.spring_layout(self.nx_graph)
        nx.draw(self.nx_graph, pos, with_labels=True)
        plt.show()
        
    def quantize_dq(self):
        min_dg, max_dg = 1e10, 0
        print(f"Estimate min/max... ")
        for node in tqdm(self.nx_graph.nodes):
            if self.nx_graph.nodes[node]["meta"]["neighbour_count"] < min_dg:
                min_dg = self.nx_graph.nodes[node]["meta"]["neighbour_count"]
            if self.nx_graph.nodes[node]["meta"]["neighbour_count"] > max_dg:
                max_dg = self.nx_graph.nodes[node]["meta"]["neighbour_count"]

        print(f"max degree {max_dg}, min degree {min_dg}")
        protected_node_cnt = 0
        print(f"Quantizing... ")
        for node in tqdm(self.nx_graph.nodes):
            prob = self.nx_graph.nodes[node]["meta"]["neighbour_count"] / max_dg
            quant = np.random.binomial(n=1, p=prob, size=1)
            if quant:
                self.nx_graph.nodes[node]["meta"]["precision"] = "FIXED_8"
                protected_node_cnt += 1

        print(f"Protected node count: {protected_node_cnt} / {len(self.nx_graph.nodes)} nodes")
        print(f"Ratio: {protected_node_cnt / len(self.nx_graph.nodes)}")

    def train_embeddings(self):
        pass

    def __str__(self) -> str:
        return "TrainedGraph"
