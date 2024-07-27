<!-- Improved compatibility of back to top link: See: https://github.com/othneildrew/Best-README-Template/pull/73 -->
<a name="readme-top"></a>

<!-- [![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url] -->

<!-- PROJECT LOGO -->
<br />

<div align="center">
  <img src="https://miro.medium.com/v2/resize:fit:640/format:webp/1*2s-my83GACoXqzP5uIH9Aw.png" alt="AGILE Accelerator Image" width="300"/>
</div>

<div align="center">
  <!-- <a href="https://github.com/othneildrew/Best-README-Template">
    <img src="images/logo.png" alt="Logo" width="80" height="80">
  </a> -->

  <h3 align="center">AMPLE: Accelerated Message Passing Logic Engine</h3>

  <p align="center">
    An FPGA accelerator for Graph Neural Networks following the Message Passing Mechanism.
    <br />
    <a href="https://github.com/pgimenes/fuzzy_carnival/wiki"><strong>Explore the docs »</strong></a>
    <br />
    <br />
    <a href="https://github.com/pgimenes/fuzzy_carnival">View Demo</a>
    ·
    <a href="https://github.com/pgimenes/fuzzy_carnival/issues">Report Bug</a>
    ·
    <a href="https://github.com/pgimenes/fuzzy_carnival/issues">Request Feature</a>
  </p>
</div>


<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#overview">Overview</a>
    </li>
    <li>
      <a href="#getting-started">Getting Started</a>
      <ul>
        <li><a href="#prerequisites">Prerequisites</a></li>
        <li><a href="#building-and-running-a-simulation">Building and Running a Simulation</a></li>
      </ul>
    </li>
    <li><a href="#usage">Usage</a></li>
    <li><a href="#contributing">Contributing</a></li>
  </ol>
</details>



<!-- ABOUT THE PROJECT -->
## Overview

<!-- [![Product Name Screen Shot][product-screenshot]](https://example.com) -->

In recent times, Graph Neural Networks (GNNs) have attracted great attention due to their performance on non-Euclidean data. Custom hardware acceleration proves particularly beneficial for GNNs given their irregular memory access patterns, resulting from the sparse structure of the graphs. Despite the relative success of hardware approaches to accelerate GNN inference on FPGA devices, previous works are limited to small graphs with up to 20k nodes, such as Cora, Citeseer and Pubmed. Since the computational overhead of GNN inference grows with increasing graph size, existing accelerators are unable to process medium to large-scale graphs.

AGILE is an FPGA accelerator aimed at enabling GNN inference on large graphs by exploring a range of hardware optimisations:

* Event-driven programming flow, which reduces pipeline gaps by addressing the non-uniform distribution in node degrees. 
* Multi-precision dataflow architecture, enabling quantized GNN inference in hardware at node granularity. 
* Efficient prefetcher unit is implemented to support the large graph use case

Evaluation on the set of Planetoid graphs, containing up to 19717 nodes, shows up to 2.8x speed-up against GPU counterparts, and up to 6.6x against CPU.


<p align="right">(<a href="#readme-top">back to top</a>)</p>


<!-- GETTING STARTED -->
## Getting Started

Follow these instructions to set up your workarea. The following steps assume you have Vivado 2019.2 and Modelsim 2019.2 installed.

1. Start by cloning the repository. 

```bash
git clone https://github.com/pgimenes/agile.git
```

2. Set the `WORKAREA` environment variable.
```bash
cd agile
export WORKAREA=$(pwd)
```

3. If you don't have `conda` installed yet, download the installation file for your platform from the [link](https://www.anaconda.com/download#downloads) and execute with all default settings. For example:
```bash
wget https://repo.anaconda.com/archive/Anaconda3-2023.09-0-Linux-x86_64.sh
chmod +x Anaconda3-2023.09-0-Linux-x86_64.sh
./Anaconda3-2023.09-0-Linux-x86_64.sh -b
``` 

4. Create a conda environment from the defined yaml file and install pip dependencies.
```bash
conda env create -f environment.yml
conda activate agile
pip install -r $WORKAREA/requirements.txt
```

> Note: a common error is that conda does not update the path to use the environment version of python and pip. Check this by running `which pip` and ensuring this points to a path within your anaconda installation.

5. Run the build script to update submodules, build register banks and the Vivado build project. This will ask you for the [Airhdl](https://airhdl.com/) password associated with the project. Contact a project contributor for access to this.

```bash
source $WORKAREA/scripts/build.sh
```

6. Generate the simulation payloads. For example, for the KarateClub dataset:

```bash
python3 $WORKAREA/scripts/initialize.py --karate --gcn --payloads --random
```

7. Build the testbench.
```bash
cd $WORKAREA/hw/sim
make build
```

8. Run the simulation.
```bash
make sim GUI=1
```


8. Benchmark AMPLE against a CPU
```bash
python3 $WORKAREA/scripts/initialize.py --karate --mlp --payloads --random --layers 10 --sim --cpu --tb_log_level INFO
```



Note: Defining ```SIMULATION``` in the Modelsim makefile  will simualte without Xillinx IP and ```SIMULATION_QUICK``` will simulate without FP units, activaiton, bias or aggregation



<p align="right">(<a href="#readme-top">back to top</a>)</p>


<!-- CONTRIBUTING -->
## Contributing

If you have a suggestion that would make this better, please fork the repo and create a pull request. You can also simply open an issue with the tag "enhancement". Don't forget to give the project a star! Thanks again!

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

<p align="right">(<a href="#readme-top">back to top</a>)</p>


<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->

<!-- TO DO: fix links after getting Github Pro -->

[contributors-shield]: https://img.shields.io/github/contributors/othneildrew/Best-README-Template.svg?style=for-the-badge
[contributors-url]: https://github.com/othneildrew/Best-README-Template/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/othneildrew/Best-README-Template.svg?style=for-the-badge
[forks-url]: https://github.com/othneildrew/Best-README-Template/network/members
[stars-shield]: https://img.shields.io/github/stars/othneildrew/Best-README-Template.svg?style=for-the-badge
[stars-url]: https://github.com/othneildrew/Best-README-Template/stargazers
[issues-shield]: https://img.shields.io/github/issues/othneildrew/Best-README-Template.svg?style=for-the-badge
[issues-url]: https://github.com/othneildrew/Best-README-Template/issues
