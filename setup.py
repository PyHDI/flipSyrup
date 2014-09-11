from setuptools import setup, find_packages

import flipsyrup.utils.version
import re

m = re.search(r'(\d+\.\d+\.\d+)', flipsyrup.utils.version.VERSION)
version = m.group(1) if m is not None else '0.0.0'

import sys
script_name = 'flipsyrup-' + version + '-py' + '.'.join([str(s) for s in sys.version_info[:3]])

setup(name='flipsyrup',
      version=version,
      description='Cycle-Accurate Hardware Simulation Framework on Abstract FPGA Platforms',
      author='Shinya Takamaeda-Yamazaki',
      #url='',
      packages=find_packages(),
      package_data={ 'flipsyrup.template' : ['*.*'],
                     'flipsyrup.rtl_converter.template' : ['*.*'],
                     'flipsyrup.abstract_memory.template' : ['*.*'],
                     'flipsyrup.abstract_channel.template' : ['*.*'],
                     'flipsyrup.pyverilog.ast_code_generator' : ['template/*'], 
                     'flipsyrup.pyverilog' : ['testcode/*'],
                 },
      entry_points="""
      [console_scripts]
      %s = flipsyrup.flipsyrup:main
      """ % script_name,
)

