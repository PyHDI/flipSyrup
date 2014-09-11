flipSyrup
==============================

Cycle-Accurate Hardware Simulation Framework on Abstract FPGA Platforms

Copyright (C) 2013, Shinya Takamaeda-Yamazaki

E-mail: shinya\_at\_is.naist.jp


License
==============================

Apache License 2.0
(http://www.apache.org/licenses/LICENSE-2.0)


What's flipSyrup?
==============================

flipSyrup is an FPGA-based prototyping framework on modern FPGA platforms.

flipSyrup genrates an AXI4 IP-core package from your prototyping target RTL design implemented under the resource abstraction of FPGA platform given by flipSyrup.
The generated IP-core can be used as a standard IP-core with other common IP-cores together.

flipSyrup supports both single FPGA platform and multi-FPGA platform.
You can implement a cycle-accurate prototyping system on both situations.

flipSyrup employs two resources abstractions that an FPGA platform has.

* Syrup Memory
    - Memory system abstraction.
    - Prototyping target logic can use this abstract memory as an ideal single-cycle memory.
    - flipSyrup compiler automatically synthesizes a cache-based memory system to simulate cycle-accurately the taget behavior.
* Syrup Channel
    - Inter-FPGA interconnection abstraction for multi-FPGA platform based prototyping.
    - Prototyping target logic can use this abstrct channel as a register to be connected to its neighbor FPGA.
    - flipSyrup compiler automatically synthesizes a FIFO-based synchronizatoin system to communicate with neighbor FPGAs.


Requirements
==============================

Software
------------------------------

* Python (2.7 or later, 3.3 or later)
* Icarus Verilog (0.9.6 or later)
   - 'iverilog -E' command is used for the preprocessor.
* Jinja2 (2.7 or later)
   - The code generator uses Jinja2 template engine.
   - 'pip install jinja2' (for Python 2.x) or 'pip3 install jinja2' (for Python 3.x)


* Pyverilog (Python-based Verilog HDL Design Processing Toolkit) is already included in this package.

### for RTL simulation

* Icarus Verilog or Synopsys VCS
   - Icarus Verilog is an open-sourced Verilog simulator
   - VCS is a very fast commercial Verilog simulator

### For synthesis of an FPGA circuit design (bit-file)

* Xilinx Platform Studio (14.6 or later)

(Recommended) FPGA Board
------------------------------

### Single FPGA Platform

* Digilent Atlys (Spartan-6)
* Xilinx ML605 (Virtex-6)
* Xilinx VC707 (Virtex-7)

### Multi-FPGA Platform

* ScalableCore System (Spartan-6)


Installation
==============================

If you want to use flipSyrup as a general library, you can install on your environment by using setup.py.

If Python 2.7 is used,

    python setup.py install

If Python 3.x is used,

    python3 setup.py install

Then you can use the flipSyrup command from your console (the version number depends on your environment).

    flipsyrup-0.8.0-py3.4.1


Getting Started
==============================

First, please make sure TARGET in 'base.mk' in 'input' is correctly defined. If you use the installed pycoram command on your environment, please modify 'TARGET' in base.mk as below (the version number depends on your environment)

    TARGET=flipsyrup-0.8.0-py3.4.1

You can find the sample input projects in 'input/tests/singleport'.

* userlogic.v  : User-defined Verilog code using Syrup memory blocks

Then type 'make' and 'make run' to simulate sample system.

    make build
    make sim

Or type commands as below directly.

    python flipsyrup/flipsyrup.py input/sample.config -t userlogic -I include/ --usertest=input/tests/singleport/testbench.v input/tests/singleport/userlogic.v 
    iverilog -I syrup_userlogic_v1_00_a/hdl/verilog/ syrup_userlogic_v1_00_a/test/testbench_userlogic.v 
    ./a.out

flipSyrup compiler generates a directory for IP-core (syrup\_userlogic\_v1\_00\_a, in this example).

'syrup\_userlogic\_v1\_00\_a.v' includes 
* IP-core RTL design (hdl/verilog/syrup\_userlogic.v)
* Test bench (test/testbench\_userlogic.v) 
* XPS setting files (syrup\_userlogic\_v2\_1\_0.{mpd,pao,tcl})

A bit-stream can be synthesized by using Xilinx Platform Studio.
Please copy the generated IP-core into 'pcores' directory of XPS project.


This software has some sample project in 'input'.
To build them, please modify 'Makefile', so that the corresponding files and parameters are selected (especially INPUT, MEMIMG and USERTEST)


flipSyrup Command Options
==============================

Command
------------------------------

    python flipsyrup.py [config] [-t topmodule] [-I includepath]+ [--memimg=filename] [--usertest=filename] [file]+

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

Publication
==============================

- Shinya Takamaeda-Yamazaki and Kenji Kise: flipSyrup: Cycle-Accurate Hardware Simulation Framework on Abstract FPGA Platforms, 24th International Conference on Field Programmable Logic and Applications (FPL 2014) (Poster), September 2014.


Related Project
==============================

[Pyverilog](http://shtaxxx.github.io/Pyverilog/)
- Python-based Hardware Design Processing Toolkit for Verilog HDL
- Used as basic code analyser and generator

