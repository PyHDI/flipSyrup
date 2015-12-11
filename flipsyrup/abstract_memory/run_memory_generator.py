#-------------------------------------------------------------------------------
# run_memory_generator.py
#
# Automatic Generator for Verilog HDL Design of Scratchpad Memory and Cache
#
# Copyright (C) 2013, Shinya Takamaeda-Yamazaki
# License: Apache 2.0
#-------------------------------------------------------------------------------
from __future__ import absolute_import
from __future__ import print_function
import os
import sys
from optparse import OptionParser
from jinja2 import Environment, FileSystemLoader

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))

from flipsyrup.abstract_memory.memory_generator import generate

TEMPLATE_DIR = os.path.dirname(os.path.abspath(__file__)) + '/template/'

def main():
    INFO = "test for memory_generator.py"
    VERSION = "ver.1.0.0"
    USAGE = "Usage: python memory_generator.py memtype name datawidth addrlen numports"

    def showVersion():
        print(INFO)
        print(VERSION)
        print(USAGE)
        sys.exit()

    optparser = OptionParser()
    optparser.add_option("-v","--version",action="store_true",dest="showversion",
                         default=False,help="Show the version")
    optparser.add_option("-n","--name",dest="name",
                         default="MemoryEmulator",help="Module name, Default=MemoryEmulator")
    optparser.add_option("--cache_capacity",dest="cache_capacity",type='int',
                         default=4096,help="Default Cache Capacity, Default=4096 (byte)")
    (options, args) = optparser.parse_args()

    if options.showversion:
        showVersion()

    if len(args) < 5:
        showVersion()

    env = Environment(loader=FileSystemLoader(TEMPLATE_DIR))
    memorydef = generate(env, args[0], args[1], int(args[2]), int(args[3]), int(args[4]), cache_capacity=options.cache_capacity)
    
    print(memorydef)
    
if __name__ == '__main__':
    main()
