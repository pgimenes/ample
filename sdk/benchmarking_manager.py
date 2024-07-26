import torch
import subprocess, multiprocessing, time
import numpy as np
import os
import subprocess
import shutil

def read_power_file(filename):
    powers = []
    with open(filename, "r") as file:
        for line in file:
            power = float(line.strip())
            powers.append(power)
    return powers

def read_timing_file(filename):
    lst = []
    with open(filename, "r") as file:
        for line in file:
            lst = [float(a) for a in line.split(",")]
    return lst

class BenchmarkWrapper():
    def __init__(self, model):
        self.model = model
        self.starter, self.ender = torch.cuda.Event(enable_timing=True), torch.cuda.Event(enable_timing=True)
        self.loss_criterion = torch.nn.CrossEntropyLoss(reduction="sum")

    def forward(self, x, edge_index):
        out = self.model(x, edge_index)
        return out

    def predict(self, batch):
        x, edge_index = batch[0], batch[1]
        torch.cuda.empty_cache()
        torch.cuda._sleep(1_000_000)
        self.starter.record()
        _ = self.forward(x, edge_index)
        torch.cuda.synchronize()
        self.ender.record()
        torch.cuda.synchronize()
        inference_time = self.starter.elapsed_time(self.ender)
        return inference_time

    def warm_up(self, batch, steps=10):
        x, edge_index = batch[0], batch[1]
        for _ in range(steps):
            out = self.forward(x, edge_index)
        return out
    


class CPUBenchmarkWrapper():
    def __init__(self, model):
        self.model = model
        # self.starter, self.ender = torch.cuda.Event(enable_timing=True), torch.cuda.Event(enable_timing=True)
        self.loss_criterion = torch.nn.CrossEntropyLoss(reduction="sum")

    def forward(self, x, edge_index):
        out = self.model(x, edge_index)
        return out

    def predict(self, batch):
        x, edge_index = batch[0], batch[1]
        start_time = time.time()
        with torch.no_grad():  # Disable gradient calculation
            _ = self.forward(x, edge_index)
        end_time = time.time()
        inference_time = end_time - start_time
        return inference_time
    



class BenchmarkingManager:
    def __init__(self, model, graph, args):
        if (torch.cuda.is_available()):
            self.bman = BenchmarkWrapper(model)
        else:
            self.bman = CPUBenchmarkWrapper(model)
        self.graph = graph
        self.cpu = args.cpu
        self.gpu = args.gpu
        self.sim = args.sim
        self.fpga_clk_freq = args.fpga_clk_freq
        self.args = args
        self.device = args.device

    def gpu_run_inference(self):
        print(f"device {self.device}")
        self.bman.model.to(torch.device(f"cuda:{self.device}"))
        data = self.graph.dataset
        data.x = data.x.to(torch.device(f"cuda:{self.device}"))
        data.edge_index = data.edge_index.to(torch.device(f"cuda:{self.device}"))
        
        times = []
        for i in range(100): #Do Loop in predict function?
            time_taken = self.bman.predict(batch=(data.x, data.edge_index))
            times.append(time_taken)

        avg_time = np.mean(times)
        std_dev = np.std(times)
        with open("timing_tmp.txt", "w") as f:
            f.write(f"{avg_time}, {std_dev}")
        return avg_time


    def gpu_measure_power(self):
        with open("powers.txt", "w") as file:
            pass

        while True:
            try:
                power_output = subprocess.check_output(["nvidia-smi", "--id=0", "--query-gpu=power.draw", "--format=csv,noheader,nounits"])
                power = float(power_output.decode().strip())
                with open("powers.txt", "a") as file:
                    file.write(f"{power}\n")
                time.sleep(0.1)
            except KeyboardInterrupt:
                print(f"finishing")
    
    def cpu_benchmark(self):
        self.bman.model.to(torch.device("cpu"))
        data = self.graph.dataset
        data.x = data.x.to(torch.device("cpu"))
        data.edge_index = data.edge_index.to(torch.device("cpu"))
        
        times = []
        for i in range(100):
            time_taken = self.bman.predict(batch=(data.x, data.edge_index))
            times.append(time_taken)

        avg_time = np.mean(times)
        std_dev = np.std(times)
        return {
            "cpu_latency_mean": avg_time,
            "cpu_latency_std_dev": std_dev
        }

    def gpu_benchmark(self):
        inference_job = multiprocessing.Process(target=self.gpu_run_inference)
        power_job = multiprocessing.Process(target=self.gpu_measure_power)

        inference_job.start()
        power_job.start()

        try:
            inference_job.join()  # Wait for inference_job process to finish
            lst = read_timing_file("timing_tmp.txt")
            print(f"Inference job completed in {lst}ms. Terminating power job...")
            power_job.terminate()  # Terminate power_job process

        except KeyboardInterrupt:
            print("Keyboard interrupt detected. Terminating processes...")
            inference_job.terminate()
            power_job.terminate()

        power = np.mean(read_power_file("powers.txt"))
        print(f"mean power {power}")
        
        throughput = self.graph.dataset.y.shape[0] / lst[0]
        return {
                "gpu_latency_mean": lst[0],
                "gpu_latency_std_dev": lst[1],
                "gpu_mean_power": power,
                "gpu_nodes_per_ms": throughput,
                "gpu_throughput_per_watt": throughput/power
                }

    def fpga_benchmark(self):

        # * Load layer config
        if (self.args.preload):
            dest_dir = os.environ.get(f"WORKAREA") + "/hw/sim/layer_config"
            config_path = f"{self.args.preload_path}/layer_configs/layer_config_degree_{self.graph.avg_degree}_nodes_{self.graph.num_nodes}"
            
            assert os.path.isdir(config_path), f"{config_path} was not found"

            # Delete current layer config
            try:
                shutil.rmtree(dest_dir)
            except OSError:
                pass

            # Copy new layer config
            cm = f"cp -r {config_path} {dest_dir}"
            print(f"==== Running {cm}")
            subprocess.run(cm, shell=True, capture_output=False, text=True)

        os.environ['AMPLE_GRAPH_TB_TOLERANCE'] = str(self.args.tb_tolerance)
        os.environ['AMPLE_GRAPH_TB_LOG_LEVEL'] = str(self.args.tb_log_level)
        os.environ['AMPLE_GRAPH_TB_NODESLOT_COUNT'] = '64'

        # * Run simulation (assume )
        path = os.environ.get("WORKAREA") + "/hw/sim"
        print(f"cd {path}")
        command = f"cd {path}; make run_sim GUI=0"

        print(f"==== Running command: {command}")
        process = subprocess.run(command, shell=True, capture_output=False, text=True)

        with open(f"{path}/sim_time.txt", "r") as f:
            stime = f.readline()


        cycles_dict = self.read_cycles_file(f"{path}/sim_cycles.txt")
        sim_cycle_time = sum(cycles_dict.values()) * (1/self.fpga_clk_freq)
        throughput = self.graph.dataset.y.shape[0] / float(stime)
        return {
            # "fpga_latency": stime,
            "fpga_sim_cycle_time": sim_cycle_time,
            "fpga_mean_power": 30,
            "fpga_nodes_per_ms": throughput,
            "fpga_throughput_per_watt": throughput/30
        }


    def read_cycles_file(self,file_path):
        cycles_dict = {}

        with open(file_path, "r") as f:
            lines = f.readlines()

        for line in lines:
            if line.startswith("Layer"):
                parts = line.split()
                layer = int(parts[1])  # Extract layer number
                cycles = int(parts[3])  # Extract cycle count
                cycles_dict[layer] = cycles

        return cycles_dict

    def benchmark(self):
        metrics = {}
        if (self.cpu):
            metrics["cpu"] = self.cpu_benchmark()
        if (self.gpu):
           metrics["gpu"] = self.gpu_benchmark()
        if (self.sim):
            metrics["fpga"] = self.fpga_benchmark()
        return metrics