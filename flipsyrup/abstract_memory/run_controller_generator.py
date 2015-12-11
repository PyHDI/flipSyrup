#-------------------------------------------------------------------------------
# run_controller_generator.py
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

from flipsyrup.configuration_reader.resource_definition import OnchipMemoryDefinition
from flipsyrup.configuration_reader.resource_definition import OffchipMemoryDefinition
from flipsyrup.configuration_reader.resource_definition import MemorySpaceDefinition
from flipsyrup.configuration_reader.resource_definition import DomainDefinition
from flipsyrup.configuration_reader.resource_definition import InterfaceDefinition
from flipsyrup.abstract_memory.controller_generator import generate

TEMPLATE_DIR = os.path.dirname(os.path.abspath(__file__)) + '/template/'

def main():
    INFO = "test for controller_generator.py"
    VERSION = "ver.1.0.0"
    USAGE = "Usage: python controller_generator.py name"

    def showVersion():
        print(INFO)
        print(VERSION)
        print(USAGE)
        sys.exit()

    optparser = OptionParser()
    optparser.add_option("-v","--version",action="store_true",dest="showversion",
                         default=False,help="Show the version")
    (options, args) = optparser.parse_args()

    if options.showversion:
        showVersion()

    #if len(args) < 1:
    #    showVersion()

    domains = []

    interface0 = InterfaceDefinition('Core0', 'MCore', 'Node0', mode='readwrite', mask=True, addrlen=20, datawidth=32, maskwidth=4)
    interface1 = InterfaceDefinition('Core1', 'MCore', 'Node0', mode='readwrite', mask=True, addrlen=20, datawidth=32, maskwidth=4)

    interface2 = InterfaceDefinition('Core2', 'NCore', 'Node1', mode='readwrite', mask=True, addrlen=20, datawidth=32, maskwidth=4)
    interface3 = InterfaceDefinition('Core3', 'NCore', 'Node1', mode='readwrite', mask=True, addrlen=20, datawidth=32, maskwidth=4)
    
    domain0 = DomainDefinition('MCore')
    domain0.append_interface( interface0 )
    domain0.append_interface( interface1 )
    domains.append( domain0 )

    domain1 = DomainDefinition('NCore')
    domain1.append_interface( interface2 )
    domain1.append_interface( interface3 )
    domains.append( domain1 )

    env = Environment(loader=FileSystemLoader(TEMPLATE_DIR))
    controllerdef = generate(env, domains)
    
    print(controllerdef)

if __name__ == '__main__':
    main()
