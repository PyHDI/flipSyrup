#-------------------------------------------------------------------------------
# abstract_channel.py
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
import math
from jinja2 import Environment, FileSystemLoader

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
