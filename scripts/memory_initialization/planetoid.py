import argparse
from sdk.init_manager import InitManager
from sdk.graphs.planetoid_graph import PlanetoidGraph

'''
    Build the Planetoid graphs with requested embedding size and generate memory file.
'''

def main(args):

    if args.pubmed:
        graph_name = "Pubmed"
    elif args.cora:
        graph_name = "Cora"
    elif args.citeseer:
        graph_name = "Citeseer"
    else:
        raise ValueError("No graph name specified")


    # Load graph and generate feature embeddings
    planet = PlanetoidGraph(name=graph_name)
    planet.random_weights()

    # Initialize Memory

    init_manager = InitManager(planet)
    init_manager.initialize()

    # Dump
    init_manager.dump_memory("memory.mem")
    init_manager.dump_txt("graph_dump.txt")
    init_manager.dump_json()

def parse_arguments():
    parser = argparse.ArgumentParser()
    parser.add_argument('--pubmed', action='store_true', help='Use Pubmed graph')
    parser.add_argument('--cora', action='store_true', help='Use Cora graph')
    parser.add_argument('--citeseer', action='store_true', help='Use Citeseer graph')
    return parser.parse_args()

if (__name__ == "__main__"):
    args = parse_arguments()
    main(args)
