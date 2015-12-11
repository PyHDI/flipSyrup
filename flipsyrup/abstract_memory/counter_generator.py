#-------------------------------------------------------------------------------
# counter_generator.py
#
# Automatic Generator for Verilog HDL Design of Scratchpad Memory and Cache
#
# Copyright (C) 2013, Shinya Takamaeda-Yamazaki
# License: Apache 2.0
#-------------------------------------------------------------------------------
from __future__ import absolute_import
from __future__ import print_function

def generate(env, domains):
    filename = 'counter.v'
    template = env.get_template(filename)
    numdomains = len(domains)
    template_dict = {
        'domains' : domains,
        'numdomains': numdomains,
        }
    rslt = template.render(template_dict)
    return rslt
