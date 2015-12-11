#-------------------------------------------------------------------------------
# domain_generator.py
#
# Copyright (C) 2013, Shinya Takamaeda-Yamazaki
# License: Apache 2.0
#-------------------------------------------------------------------------------
from __future__ import absolute_import
from __future__ import print_function
import sys
import os

from flipsyrup.configuration_reader.resource_definition import DomainDefinition
from flipsyrup.configuration_reader.resource_definition import InterfaceDefinition
from flipsyrup.configuration_reader.resource_definition import OutChannelDefinition
from flipsyrup.configuration_reader.resource_definition import InChannelDefinition

def get_domains(interfacelist, outchannellist, inchannellist):
    domaindict = {}

    for interface in sorted(interfacelist, key=lambda x:x.priority, reverse=True):
        if not interface.domain in domaindict:
            domaindict[interface.domain] = DomainDefinition(interface.domain)
        domaindict[interface.domain].append_interface(interface)

    for outchannel in sorted(outchannellist, key=lambda x:x.name):
        if not outchannel.domain in domaindict:
            domaindict[outchannel.domain] = DomainDefinition(outchannel.domain)
        domaindict[outchannel.domain].append_outchannel(outchannel)

    for inchannel in sorted(inchannellist, key=lambda x:x.name):
        if not inchannel.domain in domaindict:
            domaindict[inchannel.domain] = DomainDefinition(inchannel.domain)
        domaindict[inchannel.domain].append_inchannel(inchannel)

    domainlist = list( domaindict.values() )
    return domainlist
