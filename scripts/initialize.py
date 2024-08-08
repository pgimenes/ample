import argparse
import sys
import os
workarea = os.environ.get('WORKAREA')

if workarea is None:
    raise EnvironmentError("WORKAREA environment variable is not set")

os.chdir(workarea)

sys.path.append(workarea)

from sdk.initialization_manager import InitManager

from sdk.graphs.matrix_graph import MatrixGraph
from sdk.graphs.karate_club import KarateClubGraph
from sdk.graphs.random_graph import RandomGraph
from sdk.graphs.planetoid_graph import PlanetoidGraph
from sdk.graphs.large_graphs import RedditGraph, FlickrGraph, YelpGraph, AmazonProductsGraph

from sdk.models.models import GCN_Model, GAT_Model, GraphSAGE_Model, GIN_Model

from sdk.benchmarking_manager import BenchmarkingManager

import itertools
import logging

import os
import subprocess
import pandas as pd
from tabulate import tabulate

import numpy as np

import torch

logging.basicConfig(level=logging.INFO, format='[%(asctime)s]:%(levelname)s:: %(message)s')

# Create a logger with a specified level (e.g., INFO)
logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)

# Create a console handler and set its level to INFO
console_handler = logging.StreamHandler()
console_handler.setLevel(logging.INFO)

# Create a file handler and set its level to INFO
file_handler = logging.FileHandler('out.log')
file_handler.setLevel(logging.INFO)

# Add both handlers to the logger
logger.addHandler(console_handler)
logger.addHandler(file_handler)

from functools import partial

'''
    Build graphs with requested embedding size and generate memory file.
'''

graph_map = {
    'matrix': MatrixGraph,
    'karate': KarateClubGraph,
    'erdos': RandomGraph,
    'cora': partial(PlanetoidGraph, name="Cora"),
    'citeseer': partial(PlanetoidGraph, name="Citeseer"),
    'pubmed': partial(PlanetoidGraph, name="Pubmed"),
    'flickr': FlickrGraph,
    'reddit': RedditGraph,
    'yelp': YelpGraph,
    'amazon': AmazonProductsGraph,
}

model_map = {
  'gcn': GCN_Model,
  'gat': GAT_Model,
  'gin': GIN_Model,
  'sage': GraphSAGE_Model
}

def main(args):
    # Load Graphs
    graphs = []
    for arg, graph_cls in graph_map.items():
        if getattr(args, arg):
            # To do: temporary
            if arg == "erdos":
                graph = RandomGraph(num_nodes=args.num_nodes, avg_degree=args.avg_degree, num_channels=args.in_features, graph_precision=args.precision)
            else:
                graph = graph_cls(graph_precision=args.precision)
            
            graphs.append(graph)

    # Load Models
    models = []
    for arg, _ in model_map.items():
        if getattr(args, arg):
            models.append(arg)

    if (args.sweep):
        run_sweep(args, models)
        return
    
    for (graph, model) in itertools.product(graphs, models):
        run_pass(graph, model, args, payloads=args.payloads, base_path=args.base_path)

def run_graph_commands(graph, commands):
    for command in commands:
        method = getattr(graph, command, None)
        if callable(method):
            method()

def apply_graph_options(graph, options):
    for key, value in options.items():
        setattr(graph, key, value)

def get_dtype(args):
    if args.precision == 'FLOAT_32':
        dtype = torch.float32
    elif args.precision == 'FIXED_16':
        dtype = torch.float16
    elif args.precision == 'FIXED_8':
        dtype = torch.uint8
    elif args.precision == 'FIXED_4':
        dtype = torch.uint8  # PyTorch does not support uint4, using uint8 as a placeholder
    else:
        dtype = torch.float32

    return dtype

def run_pass(
                graph, 
                model, 
                args,
                payloads=False, 
                base_path = os.environ.get("WORKAREA") + "/hw/sim/layer_config"
            ):
    
    logger.info(f"Running with model {model} and graph {graph}")

    dtype = get_dtype(args)

    model = model_map[model](
        graph.dataset.x.shape[1] if args.in_features is None else args.in_features,
        graph.dataset.x.shape[1] if args.out_features is None else args.out_features,
        layer_count = args.layers,
        hidden_dimension = args.hidden_dimension,
        precision = dtype
        )
    init_manager = InitManager(graph, model, base_path=base_path)
    bman = BenchmarkingManager(graph=graph, model=model, args=args)
    
    if isinstance(model, GIN_Model):
        graph.apply_self_connection()

    if isinstance(model, GraphSAGE_Model):
        scale_factors = []
        for node in graph.nx_graph.nodes:
            nb_cnt = graph.nx_graph.nodes[node]["meta"]["neighbour_count"]
            nb_cnt = 1 if nb_cnt == 0 else nb_cnt
            scale_factors.append([1 / nb_cnt] * nb_cnt)
        graph.set_scale_factors(scale_factors)

    if (args.reduce):
        init_manager.reduce_graph()
    if (args.random):
        init_manager.trained_graph.random_embeddings()
    else:
        init_manager.trained_graph.train_embeddings()

    # Not working
    # if isinstance(model, GCN_Model):
    #     graph.apply_self_connection()
    
    if (payloads):
        init_manager.map()
        init_manager.dump_memory()
        init_manager.dump_layer_config()
        init_manager.dump_nodeslot_programming()
        init_manager.embedding_expectation()
        init_manager.save_model()
        init_manager.save_graph()
    
    metrics = {}
    if (args.cpu or args.gpu or args.sweep or args.sim):
        metrics = bman.benchmark()

    if (args.dq):
        graph.quantize_dq()

    logger.info(f"==== Pass metrics=======:\n {metrics}")

    return metrics

def run_sweep(args, models):
    # avg_degree_range = [2]
    # node_count_range = [100000]
    avg_degree_range = [1, 2, 3, 4, 5]
    node_count_range = range(100000, 1000100, 100000)

    metrics = []

    # * Run build stage a single time for FPGA simulation, if requested
    if (args.sim):
        path = os.environ.get("WORKAREA") + "/hw/sim"
        command = f"cd {path}; make clean; make build"
        logger.info(f"==== Running command: {command}")
        process = subprocess.run(command, shell=True, capture_output=False, text=True)

    for degree in avg_degree_range:
        for node_count in node_count_range:
            logger.info(f"Running graph with degree {degree} and node_count {node_count}")
            graph = RandomGraph(num_nodes=node_count, avg_degree=degree, num_channels=args.in_features, graph_precision=args.precision)
        

            # * For FPGA benchmarking, run_pass will first dump payloads then run simulations
            results = run_pass(
                graph, 
                models[0], 
                args,
                payloads = args.payloads, 
                base_path = os.environ.get("WORKAREA") + "/hw/sim/layer_config"
            )

            # if (args.preload):
            #     df = pd.read_csv(args.preload_path + "/sweep.csv")

            #     # * Add new results when node_count and average_neighbour_count match

            #     metrics = df.to_dict(orient="records")
            # else:
            metrics.append({
                "node_count": graph.dataset.y.shape[0],
                "average_neighbour_count": graph.dataset.edge_index.shape[1] / graph.dataset.y.shape[0],
                **{k: v for d in results.values() for k, v in d.items()},
            })

    df = pd.DataFrame(metrics)
    print(tabulate(df, headers="keys", tablefmt="psql"))
    df.to_csv("sweep.csv")


def parse_arguments():
    parser = argparse.ArgumentParser()

    # Actions
    parser.add_argument('--sweep', action='store_true', help='Run benchmarking for random graphs over a range of average node counts and average degrees')
    parser.add_argument('--payloads', action='store_true', help='Generate simulation initialization payloads')
    parser.add_argument('--dq', action='store_true', help='Perform DegreeQuant quantization')

    # Graphs
    parser.add_argument('--matrix', action='store_true', help='Use Matrix graph')
    parser.add_argument('--karate', action='store_true', help='Use Karate graph')
    parser.add_argument('--erdos', action='store_true', help='Use random graph generated by Erdos-Renyi model')
    parser.add_argument('--pubmed', action='store_true', help='Use Pubmed graph')
    parser.add_argument('--cora', action='store_true', help='Use Cora graph')
    parser.add_argument('--citeseer', action='store_true', help='Use Citeseer graph')
    parser.add_argument('--reddit', action='store_true', help='Use Reddit graph')
    parser.add_argument('--flickr', action='store_true', help='Use Flickr graph')
    parser.add_argument('--yelp', action='store_true', help='Use Yelp graph')
    parser.add_argument('--amazon', action='store_true', help='Use Amazon graph')

    # Models
    parser.add_argument('--gcn', action='store_true', help='Use GCN Model')
    parser.add_argument('--gin', action='store_true', help='Use GIN Model')
    parser.add_argument('--gat', action='store_true', help='Use GAT Model')
    parser.add_argument('--sage', action='store_true', help='Use GraphSAGE Model')

    parser.add_argument('--layers', type=int, default=2, help='Number of layers')
    parser.add_argument('--hidden-dimension', type=int, default=34, help='Hidden dimension size')

    default_base_path = os.environ.get("WORKAREA") + "/hw/sim/layer_config"
    parser.add_argument('--base_path', default=default_base_path, help='Base path (default: $WORKAREA/hw/sim/layer_config)')
    
    parser.add_argument('--in_features', type=int, default=None, help='Input feature count')
    parser.add_argument('--out_features', type=int, default=None, help='Output feature count')

    # For random (erdos) graphs
    
    parser.add_argument('--avg_degree', type=float, default=1, help='Average number of neighbours per node')
    parser.add_argument('--num_nodes', type=int, default=10000, help='Approximate number of nodes in the graph')
    
    parser.add_argument('--random', action='store_true', help='Initialize graph with random embedding.')
    
    parser.add_argument('--precision', choices=['FLOAT_32', 'FIXED_16', 'FIXED_8', 'FIXED_4', 'mixed'], default='FLOAT_32',
                            help='Precision for calculations (default: FLOAT_32)')

    parser.add_argument('--reduce', action='store_true', help='Run sampling step before generating payloads.')

    # Tools
    parser.add_argument('--cpu', action='store_true', help='Run benchmarking steps on CPU')
    parser.add_argument('--gpu', action='store_true', help='Run benchmarking steps on GPU')
    parser.add_argument('--device', type=int, default=0, help='Which GPU to use for benchmarking')
    parser.add_argument('--fpga_clk_freq', type=int, default=200e6, help='Clock Period of FPGA to measure sim time for benchmarking')

    parser.add_argument('--sim', action='store_true', help='Run benchmarking steps in Cocotb simulation')
    parser.add_argument('--preload', action='store_true', help='Pre-load GPU results and layer configs')
    
    parser.add_argument('--tb_tolerance',  type=float, default=0.1, help='Set tolerance for tb-model mismatch for Cocotb testbench')
    parser.add_argument('--tb_log_level', choices=['DEBUG', 'INFO', 'WARNING', 'ERROR', 'CRITICAL'], default='INFO',
                            help='Set log level for Cocotb testbench')


    default_preload_path = "/home/pg519/shared/agile_results"
    parser.add_argument('--preload_path', default=default_preload_path, help='Base path (default: /home/pg519/shared/agile_results)')

    return parser.parse_args()

if (__name__ == "__main__"):
    args = parse_arguments()
    main(args)
