flipSyrup
==============================

Cycle-Accurate Hardware Simulation Framework on Abstract FPGA Platforms

Copyright (C) 2013, Shinya Takamaeda-Yamazaki

E-mail: shinya\_at\_is.naist.jp


License
==============================

Apache License 2.0
(http://www.apache.org/licenses/LICENSE-2.0)


Publication
==============================

If you use flipSyrup in your research, please cite our paper.

- Shinya Takamaeda-Yamazaki and Kenji Kise: A Framework for Efficient Rapid Prototyping by Virtually Enlarging FPGA Resources, 2014 International Conference on ReConFigurable Computing and FPGAs (ReConFig 2014), December 2014.
[Paper](http://ieeexplore.ieee.org/xpl/articleDetails.jsp?tp=&arnumber=7032488)
[Slide](http://www.slideshare.net/shtaxxx/20141208reconfigflipsyrup)

```
@INPROCEEDINGS{Takamaeda:2014:ReConFig:flipSyrup,
author={Takamaeda-Yamazaki, Shinya and Kise, Kenji}, 
booktitle={ReConFigurable Computing and FPGAs (ReConFig), 2014 International Conference on}, 
title={A framework for efficient rapid prototyping by virtually enlarging FPGA resources}, 
year={2014}, 
month={Dec}, 
pages={1-8}, 
doi={10.1109/ReConFig.2014.7032488},
}
```

- Shinya Takamaeda-Yamazaki and Kenji Kise: flipSyrup: Cycle-Accurate Hardware Simulation Framework on Abstract FPGA Platforms, 24th International Conference on Field Programmable Logic and Applications (FPL 2014) (Poster), September 2014.
[Paper](http://ieeexplore.ieee.org/xpl/articleDetails.jsp?tp=&arnumber=6927436)

```
@INPROCEEDINGS{Takamaeda:2014:FPL:flipSyrup,
author={Takamaeda-Yamazaki, Shinya and Kise, Kenji}, 
booktitle={Field Programmable Logic and Applications (FPL), 2014 24th International Conference on}, 
title={flipSyrup: Cycle-accurate hardware simulation framework on abstract FPGA platforms}, 
year={2014}, 
month={Sept}, 
pages={1-4},
doi={10.1109/FPL.2014.6927436},}
```


What's flipSyrup?
==============================

flipSyrup is an FPGA-based prototyping framework on modern FPGA platforms.

flipSyrup genrates an AXI4 IP-core package from your prototyping target RTL design implemented under the resource abstraction of FPGA platform given by flipSyrup.
The generated IP-core can be used as a standard IP-core with other common IP-cores together.

flipSyrup supports both single FPGA platform and multi-FPGA platform.
You can implement a cycle-accurate prototyping system on both situations.

flipSyrup employs two resources abstractions that an FPGA platform has.

- Syrup Memory
    - Memory system abstraction.
    - Prototyping target logic can use this abstract memory as an ideal single-cycle memory.
    - flipSyrup compiler automatically synthesizes a cache-based memory system to simulate cycle-accurately the taget behavior.
- Syrup Channel
    - Inter-FPGA interconnection abstraction for multi-FPGA platform based prototyping.
    - Prototyping target logic can use this abstrct channel as a register to be connected to its neighbor FPGA.
    - flipSyrup compiler automatically synthesizes a FIFO-based synchronizatoin system to communicate with neighbor FPGAs.


Installation
==============================

Requirements
--------------------

- Python: 2.7, 3.4 or later

Python3 is recommended.

- Icarus Verilog: 0.9.7 or later

Install on your platform. For exmple, on Ubuntu:

    sudo apt-get install iverilog

- Jinja2: 2.8 or later

Install on your python environment by using pip:

    pip install jinja2

- Pyverilog: 1.0.4 or later

Install from pip (or download and install from GitHub):

    pip install pyverilog


Install
--------------------

Install Veriloggen:

    python setup.py install


Getting Started
==============================

You can use the flipSyrup command from your console.

    flipsyrup

You can find some examples in 'flipSyrup/tests'.

Let's begin flipSyrup by an example in 'tests/singleport'. You will find two source files.

- userlogic.v  : User-defined Verilog code using Syrup memory blocks

Then type 'make' and 'make run' to simulate sample system.

    make build
    make sim

Or type commands as below directly.

    python flipsyrup config/sample.config -t userlogic -I include/ --usertest=tests/singleport/testbench.v tests/singleport/userlogic.v 
    iverilog -I syrup_userlogic_v1_00_a/hdl/verilog/ syrup_userlogic_v1_00_a/test/testbench_userlogic.v 
    ./a.out

flipSyrup compiler generates a directory for IP-core (syrup\_userlogic\_v1\_00\_a, in this example).

'syrup\_userlogic\_v1\_00\_a.v' includes 
- IP-core RTL design (hdl/verilog/syrup\_userlogic.v)
- Test bench (test/testbench\_userlogic.v) 
- XPS setting files (syrup\_userlogic\_v2\_1\_0.{mpd,pao,tcl})

A bit-stream can be synthesized by using Xilinx Platform Studio.
Please copy the generated IP-core into 'pcores' directory of XPS project.


flipSyrup Command Options
==============================

Command
------------------------------

    flipsyrup [config] [-t topmodule] [-I includepath]+ [--memimg=filename] [--usertest=filename] [file]+

Description
------------------------------

* file
    - User-logic Verilog file (.v) and FPGA system memory specification (.config).
      Automatically, .v file is recognized as a user-logic Verilog file, and 
      .config file recongnized as a memory specification of used FPGA system, respectively.
* config
    - Configuration file which includes memory and device specification 
* -t
    - Name of user-defined top module, default is "userlogic".
* -I
    - Include path for input Verilog HDL files.
* --memimg
    - DRAM image file in HEX DRAM (option, if you need).
      The file is copied into test directory.
      If no file is assigned, the array is initialized with incremental values.
* --usertest
    - User-defined test code file (option, if you need).
      The code is copied into testbench script.


Related Project
==============================

[Pyverilog](https://github.com/PyHDI/Pyverilog)
- Python-based Hardware Design Processing Toolkit for Verilog HDL
