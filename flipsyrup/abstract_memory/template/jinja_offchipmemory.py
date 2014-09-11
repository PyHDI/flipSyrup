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

sys.path.insert(0, "./")

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

    if options.showversion:
        showVersion()

    template_text = open('offchipmemory.v', 'r').read()

    template = Template(template_text)

    offchip_numports = 4
    offchip_addrlen = 64
    offchip_datawidth = 512

    template_dict = {
        'name' : 'sample',
        'offchip_numports' : offchip_numports,
        'offchip_addrlen' : offchip_addrlen,
        'offchip_datawidth' : offchip_datawidth,
        }

    rslt = template.render(template_dict)

    print(rslt)
