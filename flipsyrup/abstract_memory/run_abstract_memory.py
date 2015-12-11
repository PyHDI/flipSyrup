#-------------------------------------------------------------------------------
# run_abstract_memory.py
#
# Virtualized memory interface 
# with on-chip scratchpads or caches for FPGA-based prototyping
#
# Copyright (C) 2013, Shinya Takamaeda-Yamazaki
# License: Apache 2.0
#-------------------------------------------------------------------------------
from __future__ import absolute_import
from __future__ import print_function
import os
import sys
from optparse import OptionParser

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))

from flipsyrup.configuration_reader.resource_definition import OnchipMemoryDefinition
from flipsyrup.configuration_reader.resource_definition import OffchipMemoryDefinition
from flipsyrup.configuration_reader.resource_definition import MemorySpaceDefinition
from flipsyrup.configuration_reader.resource_definition import InterfaceDefinition
from flipsyrup.configuration_reader.domain_generator import get_domains
from flipsyrup.abstract_memory.abstract_memory import AbstractMemoryGenerator

def main():    
    optparser = OptionParser()
    optparser.add_option("-o","--output",dest="outputfile",
                         default="out.v",help="Output File name, Default=out.v")
    (options, args) = optparser.parse_args()

    onchipmemorylist = []
    offchipmemorylist = []
    memoryspacelist = []
    interfacelist = []

    onchipmemorylist.append( OnchipMemoryDefinition('BRAM', 16*1024) )
    offchipmemorylist.append( OffchipMemoryDefinition('DRAM', 128*1024*1024, 256, 32) )
    interfacelist.append( InterfaceDefinition('CoreInst0', 'MCore', 'NodeMemory0',
                                              mode='read', priority=0, mask=False) )
    interfacelist.append( InterfaceDefinition('CoreData0', 'MCore', 'NodeMemory0',
                                              mode='readwrite', priority=1, mask=True) )
    interfacelist.append( InterfaceDefinition('DMARead0', 'MCore', 'NodeMemory0',
                                              mode='read', priority=2, mask=False) )
    interfacelist.append( InterfaceDefinition('DMAWrite0', 'MCore', 'NodeMemory0',
                                              mode='write', priority=3, mask=False) )
    memoryspacelist.append( MemorySpaceDefinition('NodeMemory0', size=32*1024, datawidth=32, memtype='cache',
                                                  cache_way=1, cache_linewidth=256) )

    domainlist = get_domains(interfacelist, (), ())
    module = AbstractMemoryGenerator(onchipmemorylist, offchipmemorylist, 
                                     memoryspacelist, interfacelist, domainlist)
    moduledef = module.create()

    f = open(options.outputfile, 'w')
    f.write(moduledef)
    f.close()

if __name__ == '__main__':
    main()
