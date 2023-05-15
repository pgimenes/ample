import argparse
from sdk.init_manager import InitManager
from sdk.graphs.large_graphs import RedditGraph, FlickrGraph, YelpGraph

'''
    Build the Planetoid graphs with requested embedding size and generate memory file.
'''

def main(args):

    if (args.reddit):
        # Load graph and generate feature embeddings
        graph = RedditGraph()
        run_graph(graph)

    if (args.flickr):
        # Load graph and generate feature embeddings
        graph = FlickrGraph()
        run_graph(graph)

    if (args.yelp):
        # Load graph and generate feature embeddings
        graph = YelpGraph()
        run_graph(graph)

def run_graph(graph):
    graph.random_weights()

    # Initialize Memory

    init_manager = InitManager(graph)
    init_manager.initialize()

    # Dump
    init_manager.dump_memory()
    init_manager.dump_txt()
    init_manager.dump_json()

def parse_arguments():
    parser = argparse.ArgumentParser()
    parser.add_argument('--reddit', action='store_true', help='Use Reddit graph')
    parser.add_argument('--flickr', action='store_true', help='Use Flickr graph')
    parser.add_argument('--yelp', action='store_true', help='Use Yelp graph')
    return parser.parse_args()

if (__name__ == "__main__"):
    args = parse_arguments()
    main(args)
