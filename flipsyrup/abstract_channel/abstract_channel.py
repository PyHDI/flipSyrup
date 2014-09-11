#-------------------------------------------------------------------------------
# abstract_channel.py
# 
# Abstract Channel System Synthesis Framework
# 
# Copyright (C) 2013, Shinya Takamaeda-Yamazaki
# License: Apache 2.0
#-------------------------------------------------------------------------------

import os
import sys
import math
from jinja2 import Environment, FileSystemLoader

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))) )

import utils.version

import configuration_reader.configuration_reader

from configuration_reader.resource_definition import DomainDefinition
from configuration_reader.resource_definition import OutChannelDefinition
from configuration_reader.resource_definition import InChannelDefinition
import configuration_reader.domain_generator

TEMPLATE_DIR = os.path.dirname(os.path.abspath(__file__)) + '/template/'

class AbstractChannelGenerator(object):
    def __init__(self):
        self.env = Environment(loader=FileSystemLoader(TEMPLATE_DIR))
        self.env.globals['int'] = int
        self.env.globals['log'] = math.log

    def render(self, domainlist):
        filename = 'channel.txt'
        template = self.env.get_template(filename)
        numdomains = len(domainlist)
        template_dict = {
            'domains' : domainlist,
            'numdomains' : numdomains,
        }
        rslt = template.render(template_dict)
        return rslt

    def create(self, domainlist):
        code = self.render(domainlist)
        return code

#-------------------------------------------------------------------------------
def main():
    from optparse import OptionParser
    optparser = OptionParser()
    optparser.add_option("-o","--output",dest="outputfile",
                         default="out.v",help="Output File name, Default=out.v")
    (options, args) = optparser.parse_args()

    outchannellist = []
    inchannellist = []

    outchannellist.append( OutChannelDefinition('NorthOut', 'MCore', 0, 32) )
    inchannellist.append( InChannelDefinition('NorthIn', 'MCore', 0, 32) )

    domainlist = configuration_reader.domain_generator.get_domains((), outchannellist, inchannellist)
    gen = AbstractChannelGenerator()
    code = gen.create(domainlist)

    f = open(options.outputfile, 'w')
    f.write(code)
    f.close()

#-------------------------------------------------------------------------------
if __name__ == '__main__':
    main()
