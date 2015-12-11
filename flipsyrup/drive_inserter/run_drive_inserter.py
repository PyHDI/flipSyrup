#-------------------------------------------------------------------------------
# run_drive_inserter.py
# 
# Moficating AST Node
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
    
from pyverilog.vparser.parser import VerilogCodeParser
from pyverilog.ast_code_generator.codegen import ASTCodeGenerator

from flipsyrup.utils import version
from flipsyrup.drive_inserter.drive_inserter import DriveInserter

def main():
    INFO = "Verilog ast modificator parser"
    VERSION = version.VERSION
    USAGE = "Usage: python parser.py file ..."

    def showVersion():
        print(INFO)
        print(VERSION)
        print(USAGE)
        sys.exit()
    
    optparser = OptionParser()
    optparser.add_option("-v","--version",action="store_true",dest="showversion",
                         default=False,help="Show the version")
    optparser.add_option("-o","--output",dest="outputfile",
                         default="out.v",help="Output File name, Default=out.v")
    optparser.add_option("-I","--include",dest="include",action="append",
                         default=[],help="Include path")
    (options, args) = optparser.parse_args()

    filelist = args
    if options.showversion:
        showVersion()

    for f in filelist:
        if not os.path.exists(f): raise IOError("file not found: " + f)

    if len(filelist) == 0:
        showVersion()

    codeparser = VerilogCodeParser(filelist, preprocess_include=options.include)
    ast = codeparser.parse()
    directives = codeparser.get_directives()

    inserter = DriveInserter('DRIVE')

    rslt = inserter.generate(ast)

    asttocode = ASTCodeGenerator()
    code = asttocode.visit(rslt)

    f = open(options.outputfile, 'w')
    f.write(code)
    f.close()

if __name__ == '__main__':
    main()
