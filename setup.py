from setuptools import setup, find_packages

import flipsyrup.utils.version
import re
import os

m = re.search(r'(\d+\.\d+\.\d+)', flipsyrup.utils.version.VERSION)
version = m.group(1) if m is not None else '0.0.0'

def read(filename):
    return open(os.path.join(os.path.dirname(__file__), filename)).read()

import sys
script_name = 'flipsyrup-' + version + '-py' + '.'.join([str(s) for s in sys.version_info[:3]])

setup(name='flipsyrup',
      version=version,
      description='Cycle-Accurate Hardware Simulation Framework on Abstract FPGA Platforms',
      long_description=read('README.rst'),
      keywords = 'FPGA,Verilog HDL,Memory System Abstraction,IP-core,AMBA AXI4, FPGA-based Rapid Prototyping, Cycle-Accurate Simulation',
      author='Shinya Takamaeda-Yamazaki',
      author_email='shinya.takamaeda_at_gmail_com',
      license="Apache License 2.0",
      url='http://shtaxxx.github.io/flipSyrup/',
      packages=find_packages(),
      package_data={ 'flipsyrup.template' : ['*.*'],
                     'flipsyrup.rtl_converter.template' : ['*.*'],
                     'flipsyrup.abstract_memory.template' : ['*.*'],
                     'flipsyrup.abstract_channel.template' : ['*.*'],
#                     'flipsyrup.pyverilog.ast_code_generator' : ['template/*'], 
#                     'flipsyrup.pyverilog' : ['testcode/*'],
                 },
      entry_points="""
      [console_scripts]
      %s = flipsyrup.flipsyrup:main
      """ % script_name,
)

