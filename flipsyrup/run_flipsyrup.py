#-------------------------------------------------------------------------------
# run_flipsyrup.py
#
# Cycle-Accurate Hardware Simulation Framework on Abstract FPGA Platforms
# 
# Copyright (C) 2013, Shinya Takamaeda-Yamazaki
# License: Apache 2.0
#-------------------------------------------------------------------------------
from __future__ import absolute_import
from __future__ import print_function
import os
import sys
import glob
from optparse import OptionParser
if sys.version_info[0] < 3:
    import ConfigParser as configparser
else:
    import configparser

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from flipsyrup.flipsyrup import SyrupBuilder
from flipsyrup.utils import version

def main():
    INFO = "flipSyrup: Cycle-Accurate Hardware Simulation Framework on Abstract FPGA Platforms"
    VERSION = version.VERSION
    USAGE = "Usage: python flipsyrup.py [config] [-t topmodule] [-I includepath]+ [--memimg=filename] [--usertest=filename] [file]+"

    def showVersion():
        print(INFO)
        print(VERSION)
        print(USAGE)
        sys.exit()
    
    optparser = OptionParser()
    optparser.add_option("-v","--version",action="store_true",dest="showversion",
                         default=False,help="Show the version")
    optparser.add_option("-t","--top",dest="topmodule",
                         default="TOP",help="Top module of user logic, Default=userlogic")
    optparser.add_option("-I","--include",dest="include",action="append",
                         default=[],help="Include path")
    optparser.add_option("-D",dest="define",action="append",
                         default=[],help="Macro Definition")
    optparser.add_option("--memimg",dest="memimg",
                         default=None,help="Memory image file, Default=None")
    optparser.add_option("--usertest",dest="usertest",
                         default=None,help="User-defined test code file, Default=None")
    (options, args) = optparser.parse_args()

    filelist = []
    for arg in args:
        filelist.extend( glob.glob(os.path.expanduser(arg)) )

    if options.showversion:
        showVersion()

    for f in filelist:
        if not os.path.exists(f): raise IOError("file not found: " + f)

    if len(filelist) == 0:
        showVersion()

    configfile = None
    userlogic_filelist = []
    for f in filelist:
        if f.endswith('.v'):
            userlogic_filelist.append(f)
        if f.endswith('.config'):
            if configfile is not None: raise IOError("Multiple configuration files")
            configfile = f

    print("Input files")
    print("  Configuration: %s" % configfile)
    print("  User-logic: %s" % ', '.join(userlogic_filelist) )

    # default values
    configs = {
        'single_clock' : True,
        'drive' : 'DRIVE',
        'if_type' : 'axi',
        'output' : 'out.v',
        'sim_addrwidth' : 27,
        'hperiod_ulogic' : 5,
        'hperiod_cthread' : 5,
        'hperiod_axi' : 5,
    }

    confp = configparser.SafeConfigParser()
    if configfile is not None:
        confp.read(configfile)

    if not confp.has_section('BRAM'):
        raise ValueError("BRAM parameters are not defined.")
    if not confp.has_section('DRAM'):
        raise ValueError("DRAM parameters are not defined.")
        
    memory_configs = {}
    memory_configs['BRAM'] = {}
    memory_configs['DRAM'] = {}
    for k, v in confp.items('BRAM'):
        memory_configs['BRAM'][k] = v
    for k, v in confp.items('DRAM'):
        memory_configs['DRAM'][k] = v

    if confp.has_section('synthesis'):
        for k, v in confp.items('synthesis'):
            if k == 'single_clock':
                configs[k] = False if 'n' in v or 'N' in v else True
            elif k not in configs:
                raise ValueError("No such configuration item: %s" % k)
            else:
                configs[k] = v

    if confp.has_section('simulation'):
        for k, v in confp.items('simulation'):
            if k == 'sim_addrwidth' or k == 'hperiod_ulogic' or k == 'hperiod_cthread' or k == 'hperiod_axi':
                configs[k] = int(v)
            elif k not in configs:
                raise ValueError("No such configuration item: %s" % k)
            else:
                configs[k] = v

    if configs['hperiod_ulogic'] != configs['hperiod_axi']:
        raise ValueError(("Half period values of User-logic and AXI"
                          " should be same in current implementation"))

    builder = SyrupBuilder()
    builder.build(configs, memory_configs,
                  userlogic_filelist, 
                  options.topmodule, 
                  include=options.include,
                  define=options.define,
                  usertest=options.usertest,
                  memimg=options.memimg)

if __name__ == '__main__':
    main()
