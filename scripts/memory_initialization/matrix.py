from sdk.init_manager import InitManager
from sdk.graphs.matrix_graph import MatrixGraph

def main():
    # Load graph and generate feature embeddings
    matrix = MatrixGraph()
    matrix.feature_count = 4
    matrix.random_embeddings()
    matrix.random_weights()

    # matrix.visualize()

    # Initialize Memory
    init_manager = InitManager(matrix)
    init_manager.initialize()

    # Dump
    # init_manager.dump_memory("memory.mem")
    init_manager.dump_txt("graph_dump.txt")
    init_manager.dump_nodeslots()

if (__name__ == "__main__"):
    main()