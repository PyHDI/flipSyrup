#-------------------------------------------------------------------------------
# abstract_memory.py
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
import math
from jinja2 import Environment, FileSystemLoader

import flipsyrup.abstract_memory.system_generator as system_generator
import flipsyrup.abstract_memory.controller_generator as controller_generator
import flipsyrup.abstract_memory.counter_generator as counter_generator
import flipsyrup.abstract_memory.memory_generator as memory_generator

TEMPLATE_DIR = os.path.dirname(os.path.abspath(__file__)) + '/template/'

#-------------------------------------------------------------------------------
# top class
#-------------------------------------------------------------------------------
class AbstractMemoryGenerator(object):
    def __init__(self, onchipmemorylist, offchipmemorylist,
                 memoryspacelist, interfacelist, domainlist):

        if not onchipmemorylist:
            raise NameError('on-chip memory definition not found')
        if len(onchipmemorylist) > 1:
            raise NameError('too much on-chip memory definitions')

        self.onchipmemory = onchipmemorylist[0]
        
        if not offchipmemorylist:
            raise NameError('off-chip memory definition not found')
        if len(offchipmemorylist) > 1:
            raise NameError('too much off-chip memory definitions')
        
        self.offchipmemory = offchipmemorylist[0]

        self.memoryspacelist = memoryspacelist
        self.interfacelist = interfacelist
        self.domainlist = domainlist

        self.env = Environment(loader=FileSystemLoader(TEMPLATE_DIR))

    #---------------------------------------------------------------------------
    def calc_memory_area(self, size, numports):
        k = 1
        if numports <= 2: # based on dual-port Block RAM
            k = 1
        else:
            k = numports * numports
        return k * size

    def calc_cache_area(self, addrlen, linesize, numway, capacity, numports):
        numline = ((capacity // numway) // linesize)
        index = int(math.ceil(math.log(numline, 2)))
        doffset = int(math.ceil(math.log(linesize, 2)))
        tag = addrlen - (index + doffset)
        state = 3 # valid, dirty, accessed
        area = (tag + state + linesize) * numway * numline
        return area

    #---------------------------------------------------------------------------
    def initialize(self):
        # Initialization of Memory Spefication
        memorydict = {}

        for memoryspace in sorted(self.memoryspacelist, key=lambda x:x.name):
            memorydict[memoryspace.name] = memoryspace

        for interface in sorted(self.interfacelist, key=lambda x:x.priority, reverse=True):
            memorydict[interface.space].numports += 1
            memorydict[interface.space].append_accessor(interface.name)
            if interface.mask:
                memorydict[interface.space].mask = True

        for interface in sorted(self.interfacelist, key=lambda x:x.priority, reverse=True):
            interface.set_datawidth(memorydict[interface.space].datawidth)
            interface.set_addrlen(memorydict[interface.space].addrlen)
            interface.set_maskwidth(memorydict[interface.space].maskwidth)

        self.memoryspacelist = list(memorydict.values())

        scratchpad_occupied = 0
        raw_cache_requested = 0
        cache_requested = 0
        for memoryspace in sorted(self.memoryspacelist, key=lambda x:x.name):
            area = self.calc_memory_area(memoryspace.size, memoryspace.numports)
            if memoryspace.memtype == 'cache':
                raw_cache_requested += memoryspace.size
                cache_requested += area
            else:
                scratchpad_occupied += area

        rest_onchipmemory = self.onchipmemory.size - scratchpad_occupied
        if rest_onchipmemory < 0:
            raise NameError("too much occupied on-chip memory for scratchpads")

        for memoryspace in sorted(self.memoryspacelist, key=lambda x:x.name):
            if cache_requested <= rest_onchipmemory:
                memoryspace.memtype = 'scratchpad_mask'
            elif raw_cache_requested <= rest_onchipmemory:
                memoryspace.memtype = 'scratchpad_mux'
            else:
                #ratio = memoryspace.size / raw_cache_requested
                ratio = len(self.memoryspacelist)
                memoryspace.cache_capacity = (2 ** int(math.floor(math.log(rest_onchipmemory / ratio, 2))))

        offset = 0
        for memoryspace in sorted(sorted(self.memoryspacelist, key=lambda x:x.name), key=lambda x:x.size, reverse=True):
            if memoryspace.memtype == 'cache':
                memoryspace.set_offset(offset)
                offset += (2 ** memoryspace.addrlen)

        for memoryspace in sorted(self.memoryspacelist, key=lambda x:x.name):
            if memoryspace.memtype == 'cache':
                self.offchipmemory.append_accessor(memoryspace.name)

    #---------------------------------------------------------------------------
    def create(self):
        ret = []
        self.initialize()
        ret.append(self.create_system())
        ret.append(self.create_controller())
        ret.append(self.create_counter())
        ret.append(self.create_memory())
        return ''.join(ret)

    #---------------------------------------------------------------------------
    def create_system(self):
        rslt = system_generator.generate(self.env,
                                         self.domainlist, 
                                         self.memoryspacelist,
                                         self.offchipmemory)
        return rslt

    #---------------------------------------------------------------------------
    def create_controller(self):
        rslt = controller_generator.generate(self.env, self.domainlist)
        return rslt

    #---------------------------------------------------------------------------
    def create_counter(self):
        rslt = counter_generator.generate(self.env, self.domainlist)
        return rslt

    #---------------------------------------------------------------------------
    def create_memory(self):
        ret = []
        for memoryspace in sorted(self.memoryspacelist, key=lambda x:x.name):
            if memoryspace.memtype == 'scratchpad':
                ret.append(self.create_scratchpad(memoryspace))
            if memoryspace.memtype == 'scratchpad_mask':
                ret.append(self.create_scratchpad(memoryspace))
            if memoryspace.memtype == 'scratchpad_mux':
                ret.append(self.create_scratchpad_mux(memoryspace))
            if memoryspace.memtype == 'cache':
                ret.append(self.create_cache(memoryspace))
                ret.append(self.create_marshaller(memoryspace))
                ret.append(self.create_addressmapper(memoryspace))
        if self.offchipmemory.numports > 0:
            ret.append(self.create_offchipmemory())
        return ''.join(ret)
        
    def create_scratchpad(self, definition):
        memtype = 'scratchpad'
        if definition.mask:
            memtype += '_mask'
        name = definition.name
        datawidth = definition.datawidth
        addrlen = definition.addrlen
        numports = definition.numports
        rslt = memory_generator.generate(self.env, memtype, 
                                         name, datawidth=datawidth, addrlen=addrlen,
                                         numports=numports)
        return rslt

    def create_scratchpad_mux(self, definition):
        memtype = 'scratchpad_mux'
        name = definition.name
        datawidth = definition.datawidth
        addrlen = definition.addrlen
        numports = definition.numports
        rslt = memory_generator.generate(self.env, memtype,
                                         name, datawidth=datawidth, addrlen=addrlen, 
                                         numports=numports)
        return rslt

    def create_cache(self, definition):
        memtype = 'banked_cache' # 'cache'
        name = definition.name
        datawidth = definition.datawidth
        addrlen = definition.addrlen
        numports = definition.numports
        cache_capacity = definition.cache_capacity
        numways = definition.cache_way
        linewidth = definition.cache_linewidth
        offchip_datawidth = self.offchipmemory.datawidth
        offchip_addrlen = int(math.ceil(math.log(self.offchipmemory.size, 2)))
        rslt = memory_generator.generate(self.env, memtype,
                                         name, datawidth=datawidth, addrlen=addrlen,
                                         numports=numports,
                                         cache_capacity=cache_capacity,
                                         numways=numways,
                                         linewidth=linewidth,
                                         offchip_datawidth=offchip_datawidth, 
                                         offchip_addrlen=offchip_addrlen)
        return rslt

    def create_marshaller(self, definition):
        memtype = 'marshaller'
        name = definition.name
        addrlen = definition.addrlen
        offchip_datawidth = self.offchipmemory.datawidth
        linewidth = definition.cache_linewidth
        rslt = memory_generator.generate(self.env, memtype,
                                         name, addrlen=addrlen,
                                         linewidth=linewidth,
                                         offchip_datawidth=offchip_datawidth)
        return rslt

    def create_addressmapper(self, definition):
        memtype = 'addressmapper'
        name = definition.name
        addrlen = definition.addrlen
        offchip_datawidth = self.offchipmemory.datawidth
        offchip_addrlen = self.offchipmemory.addrlen
        addrmap_start = definition.offset
        rslt = memory_generator.generate(self.env, memtype,
                                         name, addrlen=addrlen,
                                         offchip_datawidth=offchip_datawidth,
                                         offchip_addrlen=offchip_addrlen, 
                                         addrmap_start=addrmap_start)
        return rslt

    def create_offchipmemory(self):
        memtype = 'offchipmemory'
        name = self.offchipmemory.name
        offchip_datawidth = self.offchipmemory.datawidth
        offchip_addrlen = int(math.ceil(math.log(self.offchipmemory.size, 2)))
        offchip_numports = self.offchipmemory.numports
        rslt = memory_generator.generate(self.env, memtype,
                                         name, offchip_datawidth=offchip_datawidth, 
                                         offchip_addrlen=offchip_addrlen, 
                                         offchip_numports=offchip_numports)
        return rslt
