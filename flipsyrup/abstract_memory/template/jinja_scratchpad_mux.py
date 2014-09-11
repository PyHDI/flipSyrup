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

    template_text = open('scratchpad_mux.v', 'r').read()

    template = Template(template_text)

    datawidth = 64
    addrlen = 20
    maskwidth = 4
    numports = 2
    addroffset = int(math.log(int(datawidth/8), 2))
    word_addrlen = addrlen - int(math.ceil(math.log(int(datawidth / 8), 2)))

    cache_capacity = 4 * 1024 # bytes 
    numways = 2
    linesize = 64
    linewidth = linesize * 8
    numlines = int(cache_capacity / (numways * linesize))
    wordperline = int(linesize / int(datawidth / 8))
    wordperlinewidth = int(math.log(wordperline, 2))
    indexwidth = int(math.log(numlines, 2))
    
    template_dict = {
        'name' : 'sample',
        'datawidth' : datawidth,
        'addrlen' : addrlen,
        'word_addrlen' : word_addrlen,
        'maskwidth' : maskwidth,
        'addroffset': addroffset,
        'numports' : numports,
        'numways': numways,
        'linesize': linesize,
        'linewidth': linewidth,
        'numlines': numlines,
        'wordperline': wordperline,
        'wordperlinewidth': wordperlinewidth,
        'indexwidth': indexwidth,
        }

    rslt = template.render(template_dict)

    print(rslt)
