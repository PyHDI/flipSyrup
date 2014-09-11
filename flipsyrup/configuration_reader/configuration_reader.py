#-------------------------------------------------------------------------------
# configuration_reader.py
#
# Copyright (C) 2013, Shinya Takamaeda-Yamazaki
# License: Apache 2.0
#-------------------------------------------------------------------------------

import os
import sys
import re

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))) )

if sys.version_info[0] >= 3:
    from configuration_reader.resource_definition import OnchipMemoryDefinition
    from configuration_reader.resource_definition import OffchipMemoryDefinition
else:
    from resource_definition import OnchipMemoryDefinition
    from resource_definition import OffchipMemoryDefinition

#-------------------------------------------------------------------------------
# Reading Resource Definitions from an input file
#-------------------------------------------------------------------------------

def to_int(v):
    m = re.match('(\d+)(K|k)', v)
    if m: return int(m.group(1)) * 1024
    m = re.match('(\d+)(M)', v)
    if m: return int(m.group(1)) * 1024 * 1024
    m = re.match('(\d+)(G)', v)
    if m: return int(m.group(1)) * 1024 * 1024 * 1024
    return int(v)

def readResourceDefinitions(config):
    if 'BRAM' not in config:
        raise ValueError("BRAM parameters are not defined.")
    if 'DRAM' not in config:
        raise ValueError("DRAM parameters are not defined.")

    config['BRAM']['size']
    bram_size = 32 * 1024 if 'size' not in config['BRAM'] else to_int(config['BRAM']['size'])
    bram = OnchipMemoryDefinition('BRAM', bram_size)

    config['DRAM']['size']
    dram_size = 128 * 1024 * 1024 if 'size' not in config['DRAM'] else to_int(config['DRAM']['size'])
    dram_width = 128 if 'width' not in config['DRAM'] else int(config['DRAM']['width'])
    dram_addrlen = 32 if 'addrlen' not in config['DRAM'] else int(config['DRAM']['addrlen'])
    dram = OffchipMemoryDefinition('DRAM', dram_size, dram_width, dram_addrlen)

    resourcelist = [bram, dram]
    return resourcelist
