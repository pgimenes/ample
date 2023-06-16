import logging
import time
import functools
import numpy as np

class BenchmarkingManager:
    def __init__(self, model, graph):
        self.model = model
        self.graph = graph

    @functools.lru_cache(maxsize=None)
    def cpu_step(self):
        start_time = time.time()
        out = self.model.forward(self.graph.dataset.x, self.graph.dataset.edge_index)
        end_time = time.time()
        elapsed_time = (end_time - start_time) * 1000
        return elapsed_time
    
    def cpu(self, iterations=1):
        logging.info("Starting CPU benchmarking step")
        times = []
        for i in range(iterations):
            self.cpu_step.cache_clear()
            times.append(self.cpu_step())
        _min, avg, _max = min(times), np.mean(times), max(times)
        logging.info(f"Min time: {_min}ms")
        logging.info(f"Mean time: {avg}ms")
        logging.info(f"Max time: {_max}ms")
        return _min, avg, _max


    def gpu(self):
        pass