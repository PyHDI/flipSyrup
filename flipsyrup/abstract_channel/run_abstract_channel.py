#-------------------------------------------------------------------------------
# run_abstract_channel.py
# 
# Abstract Channel System Synthesis Framework
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

from flipsyrup.abstract_channel.abstract_channel import AbstractChannelGenerator
from flipsyrup.configuration_reader.resource_definition import OutChannelDefinition
from flipsyrup.configuration_reader.resource_definition import InChannelDefinition
from flipsyrup.configuration_reader.domain_generator import get_domains

def main():
    optparser = OptionParser()
    optparser.add_option("-o","--output",dest="outputfile",
                         default="out.v",help="Output File name, Default=out.v")
    (options, args) = optparser.parse_args()

    outchannellist = []
    inchannellist = []

    outchannellist.append( OutChannelDefinition('NorthOut', 'MCore', 0, 32) )
    inchannellist.append( InChannelDefinition('NorthIn', 'MCore', 0, 32) )

    domainlist = get_domains((), outchannellist, inchannellist)
    gen = AbstractChannelGenerator()
    code = gen.create(domainlist)

    f = open(options.outputfile, 'w')
    f.write(code)
    f.close()

if __name__ == '__main__':
    main()
