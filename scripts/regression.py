import multiprocessing
import subprocess

datasets = [
    "cora", 
    "citeseer", 
    "pubmed", 
    "flickr", 
    "reddit", 
    "yelp", 
] * 3

models = ["gcn"] * 6 + ["gin"] * 6 + ["sage"] * 6

def run(idx):
    source_configs = f"/home/pg519/shared/layer_configs/{models[idx]}-{datasets[idx]}-fc-64-layer-config"
    
    cmd = f"""
        # git clone https://github.com/pgimenes/agile.git sweep_{models[idx]}_{datasets[idx]} &> ~/sweep_{models[idx]}_{datasets[idx]}.log; \
    
        export WORKAREA=/home/pg519/sweep_{models[idx]}_{datasets[idx]}; \
        export PYTHONPATH=/home/pg519/sweep_{models[idx]}_{datasets[idx]}:/home/pg519/sweep_{models[idx]}_{datasets[idx]}/hw:/home/pg519/sweep_{models[idx]}_{datasets[idx]}/hw/tb;
        source /home/applications/Xilinx/23.1/Vivado/2023.1/settings64.sh; \
    
        cd /home/pg519/sweep_{models[idx]}_{datasets[idx]}; \
        # git checkout feature/mesh-multiplier-benchmarking &>> ~/sweep_{models[idx]}_{datasets[idx]}.log; \
        # source scripts/build.sh &>> ~/sweep_{models[idx]}_{datasets[idx]}.log; \
    
        cd hw/sim; \
        cp -r {source_configs} . &>> ~/sweep_{models[idx]}_{datasets[idx]}.log; \
        mv {models[idx]}-{datasets[idx]}-fc-64-layer-config layer_config &>> ~/sweep_{models[idx]}_{datasets[idx]}.log; \
    
        make clean; \
        make build &>> ~/sweep_{models[idx]}_{datasets[idx]}.log; \
        make run_sim GUI=0 &>> ~/sweep_{models[idx]}_{datasets[idx]}.log; \
    """

    subprocess.run(cmd, shell=True, capture_output=True, text=True)

processes = []
for i in range(0, len(datasets)):
    p = multiprocessing.Process(target=run, args=(i,))
    p.start()
    print(f"Starting process {i} (PID: {p.pid}) running model {models[i]} with dataset {datasets[i]}")
    processes.append(p)

for p in processes:
    p.join()