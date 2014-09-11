#-------------------------------------------------------------------------------
# jinja_test.py
#
# Jinja Template Engine Test
#
# Copyright (C) 2013, Shinya Takamaeda-Yamazaki
# License: Apache 2.0
#-------------------------------------------------------------------------------

import os
import sys
import math
from jinja2 import Template

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))) )

from resource_definition import InterfaceDefinition
from resource_definition import DomainDefinition

#-------------------------------------------------------------------------------
if __name__ == '__main__':
    from optparse import OptionParser
    INFO = "Jinja Template Engine Test"
    VERSION = "ver.1.0.0"
    USAGE = "Usage: python jinja_test.py filename"

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
    (options, args) = optparser.parse_args()

    filelist = args
    if options.showversion:
        showVersion()

    template_text = open('domaincontroller.v', 'r').read()

    template = Template(template_text)

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

    numdomains = len(domains)

    template_dict = {
        'domains' : domains,
        'numdomains': numdomains,
        }

    rslt = template.render(template_dict)

    print(rslt)
