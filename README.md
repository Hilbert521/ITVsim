# ITVsim
A simple *MATLAB* simulator for prototyping control strategies on multi-agent aeromagnetic surveys

<p align="center">
   <img src="https://github.com/vgracianos/ITVsim/blob/master/docs/img/screenshot.png?raw=true" alt="ITVsim Screenshot" title="ITVsim Screenshot" />
</p>

# Usage

* Open MATLAB at the root directory of this project and call the method **ITVsim** in the command line.
* New control algorithms should extend the class **Strategy**. Some examples are included with this code.

This software has been tested under *MATLAB R2013a*.

# Source Files

Name            | Description
----------------|-----------------------------------------------
algorithms/     |  Example control algorithms
docs/           |  Documentation (available only in PT-BR)
simulation.m    |  Main MATLAB file
strategy.m      |  Base class for implementing control strategies
terrain.m       |  Terrain generator based on Perlin Noise

