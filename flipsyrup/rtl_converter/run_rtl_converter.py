#-------------------------------------------------------------------------------
# rtl_converter.py
# 
# RTL Converter with Pyverilog
#
# Copyright (C) 2013, Shinya Takamaeda-Yamazaki
# License: Apache 2.0
#-------------------------------------------------------------------------------
from __future__ import absolute_import
from __future__ import print_function
import sys
import os
from optparse import OptionParser

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))

from pyverilog.ast_code_generator.codegen import ASTCodeGenerator
from flipsyrup.utils import version
from flipsyrup.rtl_converter.rtl_converter import RtlConverter

def main():
    INFO = "RTL Converter with Pyverilog"
    VERSION = version.VERSION
    USAGE = "Usage: python rtlconverter.py -t TOPMODULE file ..."

    def showVersion():
        print(INFO)
        print(VERSION)
        print(USAGE)
        sys.exit()
    
    optparser = OptionParser()
    optparser.add_option("-v","--version",action="store_true",dest="showversion",
                         default=False,help="Show the version")
    optparser.add_option("-t","--top",dest="topmodule",
                         default="userlogic",help="Top module, Default=userlogic")
    optparser.add_option("-o","--output",dest="outputfile",
                         default="out.v",help="Output file name, Default=out.v")
    optparser.add_option("-I","--include",dest="include",action="append",
                         default=[],help="Include path")
    optparser.add_option("-D",dest="define",action="append",
                         default=[],help="Macro Definition")
    (options, args) = optparser.parse_args()

    filelist = args
    if options.showversion:
        showVersion()

    for f in filelist:
        if not os.path.exists(f): raise IOError("file not found: " + f)

    if len(filelist) == 0:
        showVersion()

    converter = RtlConverter(filelist, options.topmodule,
                             include=options.include,
                             define=options.define)
    ast = converter.generate()
    converter.dumpTargetObject()
    
    asttocode = ASTCodeGenerator()
    code = asttocode.visit(ast)

    f = open(options.outputfile, 'w')
    f.write(code)
    f.close()

if __name__ == '__main__':
    main()
