from sdk.init_manager import InitManager
from sdk.graphs.planetoid_graph import PlanetoidGraph

'''
    Build the Planetoid graphs with requested embedding size and generate memory file.
'''

def main():
    # Load graph and generate feature embeddings
    planet = PlanetoidGraph(name="Pubmed")
    planet.random_weights()

    # Initialize Memory

    init_manager = InitManager(planet)
    init_manager.initialize()

    # Dump
    init_manager.dump_memory("memory.mem")
    init_manager.dump_txt("graph_dump.txt")
    init_manager.dump_nodeslot_programming()

if (__name__ == "__main__"):
    main()
