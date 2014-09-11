#-------------------------------------------------------------------------------
# memory_generator.py
#
# Automatic Generator for Verilog HDL Design of Scratchpad Memory and Cache
#
# Copyright (C) 2013, Shinya Takamaeda-Yamazaki
# License: Apache 2.0
#-------------------------------------------------------------------------------

import os
import sys
import math
from jinja2 import Environment, FileSystemLoader

TEMPLATE_DIR = os.path.dirname(os.path.abspath(__file__)) + '/template/'

def generate(env, memtype, name, datawidth=32, addrlen=14, numports=1,
             cache_capacity=4096, numways=1, linewidth=128,
             offchip_addrlen=32, offchip_datawidth=128, offchip_numports=1,
             addrmap_start=1024*16):

    filename = memtype + '.v'
    template = env.get_template(filename)

    if datawidth % 8 != 0:
        raise FormatError('data width should be multiple number of 8')
    if datawidth <= 0:
        raise FormatError('illegal parameter datawidth=%d' % datawidth)
    if addrlen <= 0:
        raise FormatError('illegal parameter addrlen=%d' % addrlen)
    if numports <= 0:
        raise FormatError('illegal parameter numports=%d' % numports)

    word_addrlen = addrlen - int(math.ceil(math.log(int(datawidth / 8), 2)))
    if word_addrlen <= 0:
        raise FormatError('illegal parameter word_addrlen=%d' % word_addrlen)

    maskwidth = int(math.ceil(datawidth / 8))
    addroffset = int(math.ceil(math.log(int(datawidth/8), 2)))

    linesize = int(linewidth / 8)

    numlines = int(math.ceil(cache_capacity / (numways * linesize)))
    wordperline = int(math.ceil(linesize / int(datawidth / 8)))
    wordperlinewidth = int(math.ceil(math.log(wordperline, 2)))
    indexwidth = int(math.ceil(math.log(numlines, 2)))

    line_offset = int(math.ceil(math.log(linesize, 2)))
    offchip_offset = int(math.ceil(math.log(offchip_datawidth / 8, 2)))

    template_dict = {
        'name' : name,
        'datawidth' : datawidth,
        'addrlen' : addrlen,
        'word_addrlen' : word_addrlen,
        'maskwidth' : maskwidth,
        'numports' : numports,
        'addroffset': addroffset,
        # cache memory property
        'numways': numways,
        'linesize': linesize,
        'linewidth': linewidth,
        'numlines': numlines,
        'wordperline': wordperline,
        'wordperlinewidth': wordperlinewidth,
        'indexwidth': indexwidth,
        # marshaller
        'line_offset' : line_offset,
        'offchip_offset' : offchip_offset,
        # address map
        'addrmap_start' : addrmap_start,
        # off-chip memory property
        'offchip_addrlen' : offchip_addrlen,
        'offchip_datawidth' : offchip_datawidth,
        'offchip_numports' : offchip_numports,
        }
    
    rslt = template.render(template_dict)
    return rslt

#-------------------------------------------------------------------------------
if __name__ == '__main__':
    from optparse import OptionParser
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
