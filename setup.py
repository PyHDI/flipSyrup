from setuptools import setup, find_packages

import flipsyrup.utils.version
import re
import os

m = re.search(r'(\d+\.\d+\.\d+(-.+)?)', pycoram.utils.version.VERSION)
version = m.group(1) if m is not None else '0.0.0'

def read(filename):
    return open(os.path.join(os.path.dirname(__file__), filename)).read()

import sys
script_name = 'flipsyrup'

setup(name='flipsyrup',
      version=version,
      description='Cycle-Accurate Hardware Simulation Framework on Abstract FPGA Platforms',
      long_description=read('README.rst'),
      keywords = 'FPGA, Verilog HDL, Cycle-Accurate Simulation',
      author='Shinya Takamaeda-Yamazaki',
      author_email='shinya.takamaeda_at_gmail_com',
      license="Apache License 2.0",
      url='https://github.com/PyHDI/flipSyrup',
      packages=find_packages(),
      package_data={ 'flipsyrup.template' : ['*.*'],
                     'flipsyrup.rtl_converter.template' : ['*.*'],
                     'flipsyrup.abstract_memory.template' : ['*.*'],
                     'flipsyrup.abstract_channel.template' : ['*.*'],
                 },
      install_requires=[ 'pyverilog>=1.0.4', 'Jinja2>=2.8' ],
      extras_require={
          'test' : [ 'pytest>=2.8.2', 'pytest-pythonpath>=0.7' ],
      },
      entry_points="""
      [console_scripts]
      %s = flipsyrup.run_flipsyrup:main
      """ % script_name,
)
