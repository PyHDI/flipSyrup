from __future__ import absolute_import
from __future__ import print_function
import math

class ResourceDefinition(object):
    def __init__(self, name):
        self.name = name
    
class OnchipMemoryDefinition(ResourceDefinition):
    def __init__(self, name, size):
        ResourceDefinition.__init__(self, name)
        self.size = size
    def __repr__(self):
        ret = []
        ret.append('(')
        ret.append(self.name)
        ret.append(': ')
        ret.append('size:')
        ret.append(str(self.size))
        ret.append(')')
        return ''.join(ret)

class OffchipMemoryDefinition(ResourceDefinition):
    def __init__(self, name, size, datawidth=512, addrlen=32, numports=0, accessors=None):
        ResourceDefinition.__init__(self, name)
        self.size = size
        self.datawidth = datawidth
        self.addrlen = addrlen
        self.numports = numports
        self.offset = int(math.log(int(self.datawidth / 8), 2))
        self.accessors = [] if accessors is None else accessors
    def __repr__(self):
        ret = []
        ret.append('(')
        ret.append(self.name)
        ret.append(': ')
        ret.append('size:')
        ret.append(str(self.size))
        ret.append(', ')
        ret.append('datawidth:')
        ret.append(str(self.datawidth))
        ret.append(', ')
        ret.append('addrlen:')
        ret.append(str(self.addrlen))
        if self.numports > 0:
            ret.append(', ')
            ret.append('numports:')
            ret.append(str(self.numports))
        if self.accessors:
            ret.append(', ')
            ret.append('accessors:')
            for accessor in self.accessors:
                ret.append(accessor)
                ret.append(', ')
            ret.pop()
        ret.append(')')
        return ''.join(ret)
    def append_accessor(self, t):
        self.numports += 1
        self.accessors.append(t)

class MemorySpaceDefinition(ResourceDefinition):
    def __init__(self, name, size, datawidth=32, memtype='cache',
                 numports=0, mask=False, offset=0, 
                 cache_capacity=0, cache_way=1, cache_linewidth=128,
                 accessors=None):
        ResourceDefinition.__init__(self, name)
        self.size = size
        self.datawidth = datawidth
        self.addrlen = int(math.ceil(math.log(size, 2)))
        self.maskwidth = int(math.ceil(datawidth / 8))
        self.word_addrlen = self.addrlen - int(math.ceil(math.log(self.maskwidth, 2)))
        self.memtype = memtype
        self.numports = numports
        self.mask = mask
        self.offset = offset
        self.cache_capacity = cache_capacity
        self.cache_way = cache_way
        self.cache_linewidth = cache_linewidth
        self.accessors = [] if accessors is None else accessors
    def __repr__(self):
        ret = []
        ret.append('(')
        ret.append(self.name)
        ret.append(': ')
        ret.append('size:')
        ret.append(str(self.size))
        ret.append(', ')
        ret.append('datawidth:')
        ret.append(str(self.datawidth))
        ret.append(', ')
        ret.append('addrlen:')
        ret.append(str(self.addrlen))
        ret.append(', ')
        ret.append('word_addrlen:')
        ret.append(str(self.word_addrlen))
        ret.append(', ')
        ret.append('memtype:')
        ret.append(self.memtype)
        ret.append(', ')
        ret.append('cache_way:')
        ret.append(str(self.cache_way))
        ret.append(', ')
        ret.append('cache_linewidth:')
        ret.append(str(self.cache_linewidth))
        if self.numports > 0:
            ret.append(', ')
            ret.append('numports:')
            ret.append(str(self.numports))
        ret.append(', ')
        ret.append('mask:')
        if self.mask: ret.append('on')
        else: ret.append('off')
        if self.mask:
            ret.append(', ')
            ret.append('maskwidth:')
            ret.append(str(self.maskwidth))
        ret.append(', ')
        ret.append('offset:')
        ret.append(str(self.offset))
        if self.accessors:
            ret.append(', ')
            ret.append('accessors:')
            for accessor in self.accessors:
                ret.append(accessor)
                ret.append(', ')
            ret.pop()
        ret.append(')')
        return ''.join(ret)
    def append_accessor(self, t):
        self.accessors.append(t)
    def set_offset(self, offset):
        self.offset = offset
    def set_cache_capacity(self, cache_capacity):
        self.cache_capacity = cache_capacity

class DomainDefinition(ResourceDefinition):
    def __init__(self, name, interfaces=None, outchannels=None, inchannels=None):
        ResourceDefinition.__init__(self, name)
        self.interfaces = [] if interfaces is None else interfaces
        self.numinterfaces = 0 if interfaces is None else len(interfaces)
        self.spaces = set([ interface.space for interface in self.interfaces ])
        self.numspaces = len(self.spaces)
        self.outchannels = [] if outchannels is None else outchannels
        self.inchannels = [] if inchannels is None else inchannels
    def __repr__(self):
        ret = []
        ret.append('(')
        ret.append(self.name)
        if self.interfaces:
            ret.append(', ')
            ret.append('interfaces:')
            for interface in self.interfaces:
                ret.append(interface.name)
                ret.append(', ')
            ret.pop()
        if self.outchannels:
            ret.append(', ')
            ret.append('outchannels:')
            for outchannel in self.outchannels:
                ret.append(outchannel.name)
                ret.append(', ')
            ret.pop()
        if self.inchannels:
            ret.append(', ')
            ret.append('inchannels:')
            for inchannel in self.inchannels:
                ret.append(inchannel.name)
                ret.append(', ')
            ret.pop()
        ret.append(')')
        return ''.join(ret)
    def append_interface(self, t):
        self.interfaces.append(t)
        self.numinterfaces += 1
        self.spaces.add( t.space )
        self.numspaces = len(self.spaces)
    def append_outchannel(self, t):
        self.outchannels.append(t)
    def append_inchannel(self, t):
        self.inchannels.append(t)

class InterfaceDefinition(ResourceDefinition):
    def __init__(self, name, domain, space, mode='readwrite', priority=0, mask=False,
                 addrlen=0, datawidth=0, maskwidth=0):
        ResourceDefinition.__init__(self, name)
        self.domain = domain
        self.space = space
        self.mode = mode
        self.priority = priority
        self.mask = mask
        self.datawidth = datawidth
        self.addrlen = addrlen
        self.maskwidth = maskwidth
    def __repr__(self):
        ret = []
        ret.append('(')
        ret.append(self.name)
        ret.append(': ')
        ret.append('domain:')
        ret.append(self.domain)
        ret.append(', ')
        ret.append('space:')
        ret.append(self.space)
        ret.append(', ')
        ret.append('mode:')
        ret.append(self.mode)
        ret.append(', ')
        ret.append('priority:')
        ret.append(str(self.priority))
        ret.append(', ')
        ret.append('mask:')
        if self.mask: ret.append('on')
        else: ret.append('off')
        if self.mask:
            ret.append(', ')
            ret.append('maskwidth:')
            ret.append(str(self.maskwidth))
        if self.datawidth > 0:
            ret.append(', ')
            ret.append('datawidth:')
            ret.append(str(self.datawidth))
        if self.addrlen > 0:
            ret.append(', ')
            ret.append('addrlen:')
            ret.append(str(self.addrlen))
        if self.mask and self.maskwidth > 0:
            ret.append(', ')
            ret.append('maskwidth:')
            ret.append(str(self.maskwidth))
        ret.append(')')
        return ''.join(ret)
    def set_datawidth(self, datawidth):
        self.datawidth = datawidth
    def set_addrlen(self, addrlen):
        self.addrlen = addrlen
    def set_maskwidth(self, maskwidth):
        self.maskwidth = maskwidth

class ChannelDefinition(ResourceDefinition):
    def __init__(self, name, domain, idx, datawidth):
        ResourceDefinition.__init__(self, name)
        self.domain = domain
        self.idx = idx
        self.datawidth = datawidth
    def __repr__(self):
        ret = []
        ret.append('(')
        ret.append(self.name)
        ret.append(': ')
        ret.append('domain:')
        ret.append(self.domain)
        ret.append(', ')
        ret.append('idx:')
        ret.append(str(self.idx))
        if self.datawidth > 0:
            ret.append(', ')
            ret.append('datawidth:')
            ret.append(str(self.datawidth))
        ret.append(')')
        return ''.join(ret)

class OutChannelDefinition(ChannelDefinition): pass
class InChannelDefinition(ChannelDefinition): pass
