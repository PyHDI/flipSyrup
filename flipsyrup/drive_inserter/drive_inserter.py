#-------------------------------------------------------------------------------
# drive_inserter.py
# 
# Moficating AST Node
#
# Copyright (C) 2013, Shinya Takamaeda-Yamazaki
# License: Apache 2.0
#-------------------------------------------------------------------------------

import sys
import os

if sys.version_info[0] >= 3:
    import io as stringio
else:
    import StringIO as stringio

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))) )

import utils.version

from pyverilog.utils.signaltype import isClock
from pyverilog.utils.signaltype import isReset
from pyverilog.vparser.ast import *
from pyverilog.vparser.parser import VerilogCodeParser
from pyverilog.dataflow.visit import *
from pyverilog.ast_code_generator.codegen import ASTCodeGenerator

class ReplaceVisitor(object):
    def visit(self, node):
        method = 'visit_' + node.__class__.__name__
        visitor = getattr(self, method, self.generic_visit)
        return visitor(node)
    def generic_visit(self, node):
        for c in node.children():
            self.visit(c)
        return node

class DriveInserter(ReplaceVisitor):
    def __init__(self, signal, replace_true_statement=False):
        self.signal = signal
        self.replace_true_statement = replace_true_statement
        self.ioport = False
        self.in_clock_always = False
        self.reset_found = False
        self.moduleinfotable = None

    def generate(self, ast):
        rslt = self.visit(ast)
        return rslt

    def isResetCond(self, node):
        sbuf = stringio.StringIO()
        node.show(buf=sbuf)
        s = sbuf.getvalue()
        sbuf.close()
        s = s.replace('\r\n', '')
        s = s.replace('\n', '')
        return isReset(s)

    def visit_ModuleDef(self, node):
        self.ioport = False

        ## check whether the next module already has 'DRIVE' port
        ## if then, the signal insertion steps are skipped.

        for port in node.portlist.ports:
            name = port.first.name if isinstance(port, Ioport) else port.name
            if name == self.signal:
                print(("Module '%s' already has a user-defined drive signal '%s'. "
                       "Drive conditions were not inserted.") %
                      (node.name, self.signal))
                return node

        ret = self.generic_visit(node)
        new_items = list(node.items)
        if not self.ioport:
            #new_items.append(Input(self.signal))
            new_items.insert(0, Input(self.signal))
        ret.items = tuple(new_items)
        return ret

    def visit_Portlist(self, node):
        new_ports = list(node.ports)
        if new_ports and isinstance(new_ports[0], Ioport):
            new_ports.append(
                Ioport(Input(self.signal, width=Width(IntConst('0'),IntConst('0')))))
            self.ioport = True
        else:
            new_ports.append(
                Port(self.signal,
                     width=Width(IntConst('0'),IntConst('0')), 
                     type=None))
        node.ports = tuple(new_ports)
        return self.generic_visit(node)

    def visit_Instance(self, node):
        new_portlist = list(node.portlist)
        if new_portlist and new_portlist[0].portname is None:
            new_portlist.append(PortArg(None, Identifier(self.signal)))
        else:
            new_portlist.append(PortArg(self.signal, Identifier(self.signal)))
        node.portlist = tuple(new_portlist)
        return self.generic_visit(node)

    def visit_Always(self, node):
        self.reset_found = False
        if (node.sens_list.list and isClock(node.sens_list.list[0].sig.name) and
            (node.sens_list.list[0].type == 'posedge' or 
             node.sens_list.list[0].type == 'negedge')):
            self.in_clock_always = True

        ret = self.generic_visit(node)

        if self.in_clock_always and not self.reset_found and node.sens_list:
            new_statement = (node.statement 
                             if isinstance(node.statement, Block) 
                             else Block( (node.statement,)) )
            node.statement = IfStatement(Identifier(self.signal), new_statement, None)

        self.reset_found = False
        self.in_clock_always = False
        return ret

    def visit_IfStatement(self, node):
        if self.in_clock_always and self.isResetCond(node.cond):
            self.reset_found = True
            if self.replace_true_statement:
                new_statement = (node.true_statement 
                                 if isinstance(node.true_statement, Block) 
                                 else Block( (node.true_statement,)) )
                node.true_statement = IfStatement(
                    Identifier(self.signal), new_statement, None)
            else:
                new_statement = (node.false_statement 
                                 if isinstance(node.false_statement, Block) 
                                 else Block( (node.false_statement,)) )
                node.false_statement = IfStatement(
                    Identifier(self.signal), new_statement, None)

        return self.generic_visit(node)

if __name__ == '__main__':
    from optparse import OptionParser

    INFO = "Verilog ast modificator parser"
    VERSION = utils.version.VERSION
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
