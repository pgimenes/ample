#!/usr/bin/env python3

from sdk.init_manager import InitManager
from sdk.graphs.matrix_graph import MatrixGraph
import os

def main():
    # Load graph and generate feature embeddings
    matrix = MatrixGraph()
    matrix.feature_count = 4
    matrix.random_embeddings(feature_size=4)
    matrix.random_weights()

    # matrix.visualize()

    # Initialize Memory
    base_path = os.environ.get("FYP_DIR") + "/hw/sim_files/xsim"
    init_manager = InitManager(matrix, base_path=base_path)
    init_manager.map_memory()

    # Dump
    init_manager.dump_memory()
    init_manager.dump_txt()
    init_manager.dump_json()

if (__name__ == "__main__"):
    main()