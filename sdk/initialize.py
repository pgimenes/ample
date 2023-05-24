#!/usr/bin/env python3.10
import argparse
from sdk.init_manager import InitManager
from sdk.graphs.matrix_graph import MatrixGraph
from sdk.graphs.karate_club import KarateClubGraph
from sdk.graphs.planetoid_graph import PlanetoidGraph
from sdk.graphs.large_graphs import RedditGraph, FlickrGraph, YelpGraph
import os

'''
    Build graphs with requested embedding size and generate memory file.
'''

graph_mapping = {
    'matrix': {
        'class': MatrixGraph,
        'options': {'feature_count': 64,
                    'graph_precision': 'mixed'},
    },
    'karate': { 
        'class': KarateClubGraph,
        'options': {'feature_count': 16}
    },
    'pubmed': { 'class': lambda: PlanetoidGraph(name="Pubmed")},
    'cora': { 'class': lambda: PlanetoidGraph(name="Cora")},
    'citeseer': { 'class': lambda: PlanetoidGraph(name="Citeseer")},
    'reddit': { 'class': RedditGraph},
    'flickr': { 'class': FlickrGraph },
    'yelp': { 'class': YelpGraph }
}

def main(args):
    for arg, graph_info in graph_mapping.items():
        if getattr(args, arg):
            graph = graph_info['class']()
            options = graph_info.get('options', {})
            commands = graph_info.get('commands', [])
            apply_options(graph, options)
            run_commands(graph, commands)
            run_graph(graph)

def run_commands(graph, commands):
    for command in commands:
        method = getattr(graph, command, None)
        if callable(method):
            method()

def apply_options(graph, options):
    for key, value in options.items():
        setattr(graph, key, value)

def run_graph(graph, random_weights=True):
    init_manager = InitManager(graph, base_path=args.base_path)
    
    init_manager.trained_graph.random_embeddings(feature_size=graph.feature_count)
    init_manager.trained_graph.random_weights()

    # Initialize Memory
    init_manager.map_memory()

    # Dump
    init_manager.dump_memory()
    init_manager.dump_txt()
    init_manager.dump_json()

def parse_arguments():
    parser = argparse.ArgumentParser()
    parser.add_argument('--matrix', action='store_true', help='Use Matrix graph')
    parser.add_argument('--karate', action='store_true', help='Use Karate graph')
    parser.add_argument('--pubmed', action='store_true', help='Use Pubmed graph')
    parser.add_argument('--cora', action='store_true', help='Use Cora graph')
    parser.add_argument('--citeseer', action='store_true', help='Use Citeseer graph')
    parser.add_argument('--reddit', action='store_true', help='Use Reddit graph')
    parser.add_argument('--flickr', action='store_true', help='Use Flickr graph')
    parser.add_argument('--yelp', action='store_true', help='Use Yelp graph')
    default_base_path = os.environ.get("FYP_DIR") + "/hw/sim"
    parser.add_argument('--base_path', default=default_base_path, help='Base path (default: $FYP_DIR/hw/sim)')
    
    return parser.parse_args()

if (__name__ == "__main__"):
    args = parse_arguments()
    main(args)
