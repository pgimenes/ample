<!-- Improved compatibility of back to top link: See: https://github.com/othneildrew/Best-README-Template/pull/73 -->
<a name="readme-top"></a>

[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]

<!-- PROJECT LOGO -->
<br />
<div align="center">
  <!-- <a href="https://github.com/othneildrew/Best-README-Template">
    <img src="images/logo.png" alt="Logo" width="80" height="80">
  </a> -->

  <h3 align="center">AMPLE: Accelerated Message Passing Learning Engine</h3>

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



<p align="right">(<a href="#readme-top">back to top</a>)</p>


<!-- GETTING STARTED -->
## Getting Started

### Prerequisites

* To run the Software Development Kit (SDK), create a new conda environment with the provided package list.
  ```sh
  conda env create -f env.yml
  conda activate sdk
  ```

### Building and Running a Simulation

1. Set the WORK_AREA environment variable
   ```sh
   export WORK_AREA="<path/to/repo>"
   ```
1. Clone the repo with SSH
   ```sh
   git clone git@github.com:pgimenes/fuzzy_carnival.git $WORK_AREA
   ```
3. Run the build script to generate Xilinx IP files and register banks and pull latest version of required submodules.
   ```sh
   source $WORK_AREA/scripts/build.sh
   ```
4. Run the SDK to generate required simulation files for desired application. The --matrix argument generates payloads for a 4x4 matrix multiplication.
   ```sh
   $WORK_AREA/sdk/initialize.py --matrix
   ```
4. Launch a simulation, and monitor the generated log at $WORK_AREA/hw/sim/top_tb_log.log.
   ```sh
   cd $WORK_AREA/hw/sim; ./top_tb.sh
   ```



<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- USAGE EXAMPLES -->
## Usage

TO DO

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
