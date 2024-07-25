import networkx as nx
import numpy as np
import matplotlib.pyplot as plt
import torch
from torch_geometric.utils import to_networkx
from torch_geometric.loader import GraphSAINTRandomWalkSampler

from torch_geometric.utils import add_self_loops,add_remaining_self_loops


import random

import logging

from tqdm import tqdm

import math

data_width = 64


class TrainedGraph:
    def __init__(self, dataset, feature_count=None, embeddings=[], graph_precision="FLOAT_32", self_connection=False):
        self.dataset = dataset
        # self.dataset.edge_index, _ = add_self_loops(self.dataset.edge_index)
        # self.dataset.edge_index = self.reorder_edge_index(self.dataset.edge_index)
        # self.sort_edge_index()
        self.nx_graph = to_networkx(self.dataset)
        self.graph_precision = graph_precision

        # Node offsets in adjacency list
        node_ids, node_offsets = np.unique(dataset.edge_index[0], return_index=True)
        self.node_offsets = [0] * len(self.nx_graph.nodes)
        for idx, i in enumerate(node_ids):
            self.node_offsets[i] = node_offsets[idx]

        # Feature count initialization may change when embeddings are trained
        self.feature_count = dataset.x.shape[1] if feature_count is None else feature_count

        self.init_nx_graph(self_connection=self_connection)

        # Local copy of embeddings stored in node objects
        self.embeddings = embeddings

        # TO DO: read dequantization parameter from QAT
        self.dequantization_parameter = 1

    def sort_edge_index(self):
            # Sort edge index by source node and then by destination node
            edge_index = self.dataset.edge_index.numpy()
            sorted_indices = np.lexsort((edge_index[1], edge_index[0]))
            self.dataset.edge_index = torch.tensor(edge_index[:, sorted_indices], dtype=torch.long)

    def init_nx_graph(self, self_connection=False):
        for node in self.nx_graph.nodes:
            neighbours = list(self.nx_graph.neighbors(node))
            if self_connection:
                neighbours += [node]

            #Features stored in blocks of 512
            #Find number of 512bit/64 bytes blocks required to store features
            # 4*self.feature_count - num bytes
            # 64 - bytes per block

            # axi_addr = math.ceil(4*self.feature_count / 64)

            self.nx_graph.nodes[node]["meta"] = {
                'neighbours' : neighbours,
                'neighbour_count': len(neighbours),
                'aggregation_function': "SUM",
                
                'adj_list_offset': int(self.node_offsets[node]),
                #'neighbour_message_ptrs':[nb_ptr for nb_ptr in neighbours], # to be defined by init manager

                'neighbour_message_ptrs': [self.calc_axi_addr(self.feature_count)*nb_ptr for nb_ptr in neighbours],
                'adjacency_list_address_lsb': 0, # to be defined by init manager
                
                # Add a single scale factor to isolated nodes to occupy memory range
                'scale_factors': [1] * len(neighbours) if len(neighbours) > 0 else [1],

                'precision': random.choice(["FLOAT_32", "FIXED_8"]) if self.graph_precision == 'mixed' else self.graph_precision
            }


    def reorder_edge_index(self, edge_index):
        # Separate source and target nodes
        src, dst = edge_index

        # Determine the number of nodes
        num_nodes = src.max().item() + 1

        # Create a mask for self-loops
        self_loops = src == dst

        # Split self-loops and other edges
        self_loops_src = src[self_loops]
        self_loops_dst = dst[self_loops]
        other_src = src[~self_loops]
        other_dst = dst[~self_loops]

        # Initialize lists to hold reordered edges
        reordered_src = []
        reordered_dst = []

        # Iterate over each node and add self-loop first, followed by other edges
        for node in range(num_nodes):
            node_self_loops = self_loops_src[self_loops_src == node]
            node_other_edges_src = other_src[other_src == node]
            node_other_edges_dst = other_dst[other_src == node]

            reordered_src.append(node_self_loops)
            reordered_dst.append(node_self_loops)  # self_loops_dst is the same as self_loops_src
            reordered_src.append(node_other_edges_src)
            reordered_dst.append(node_other_edges_dst)

        # Concatenate all reordered edges
        reordered_src = torch.cat(reordered_src)
        reordered_dst = torch.cat(reordered_dst)

        return torch.stack([reordered_src, reordered_dst], dim=0)

    def remove_self_connection(self):
        for node in self.nx_graph.nodes:
            if node in self.nx_graph.nodes[node]["meta"]["neighbours"]:
                self.nx_graph.nodes[node]["meta"]["neighbours"].remove(node)
                neighbours_count = len(self.nx_graph.nodes[node]["meta"]["neighbours"])
                self.nx_graph.nodes[node]["meta"]["neighbour_count"] = neighbours_count
                self.nx_graph.nodes[node]["meta"]["neighbour_message_ptrs"] = [self.calc_axi_addr(self.feature_count)*nb_ptr for nb_ptr in self.nx_graph.nodes[node]["meta"]["neighbours"]]
                self.nx_graph.nodes[node]["meta"]['scale_factors'] = [1] * neighbours_count if neighbours_count > 0 else [1]


    def apply_self_connection(self):
        for node in self.nx_graph.nodes:
            neighbours = [node] + self.nx_graph.nodes[node]["meta"]["neighbours"] 
            self.nx_graph.nodes[node]["meta"]["neighbours"] = neighbours
            self.nx_graph.nodes[node]["meta"]["neighbour_count"] = len(neighbours)
            self.nx_graph.nodes[node]["meta"]["neighbour_message_ptrs"] = [self.calc_axi_addr(self.feature_count)*nb_ptr for nb_ptr in self.nx_graph.nodes[node]["meta"]["neighbours"]]
            self.nx_graph.nodes[node]["meta"]['scale_factors'] = [1] * len(neighbours) if len(neighbours) > 0 else [1]

    def remove_connections(self):
        for node in self.nx_graph.nodes:
            neighbours = [node]
            self.nx_graph.nodes[node]["meta"]["neighbours"] = neighbours
            self.nx_graph.nodes[node]["meta"]["neighbour_count"] = len(neighbours)
            self.nx_graph.nodes[node]["meta"]["neighbour_message_ptrs"] = [self.calc_axi_addr(self.feature_count)*nb_ptr for nb_ptr in self.nx_graph.nodes[node]["meta"]["neighbours"]]
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
        plt.savefig("Graph.png")
        plt.close()
        
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

    def calc_axi_addr(self,feature_count):
        return math.ceil(4*feature_count / data_width) *data_width


    def __str__(self) -> str:
        return "TrainedGraph"
