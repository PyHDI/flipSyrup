#-------------------------------------------------------------------------------
# codegen.py
# 
# Code Generator from AST to Verilog HDL source code
#
# Copyright (C) 2013, Shinya Takamaeda-Yamazaki
# License: Apache 2.0
#-------------------------------------------------------------------------------

import sys
import os
import math
import re
from jinja2 import Environment, FileSystemLoader

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))) )

import pyverilog.utils.version
from pyverilog.vparser.parser import VerilogCodeParser
from pyverilog.vparser.ast import *
from pyverilog.utils.op2mark import op2mark

DEFAULT_TEMPLATE_DIR = os.path.dirname(os.path.abspath(__file__)) + '/template/'

class ConvertVisitor(object):
    def visit(self, node):
        method = 'visit_' + node.__class__.__name__
        visitor = getattr(self, method, self.generic_visit)
        return visitor(node)
    def generic_visit(self, node):
        ret = []
        for c in node.children():
            ret.append(self.visit(c))
        return ''.join(ret)

def getfilename(node):
    return node.__class__.__name__.lower() + '.txt'

class ASTCodeGenerator(ConvertVisitor):
    def __init__(self):
        self.env = Environment(loader=FileSystemLoader(DEFAULT_TEMPLATE_DIR))

    def visit_Source(self, node):
        filename = getfilename(node)
        template = self.env.get_template(filename)
        template_dict = {
            'description' : self.visit(node.description),
            }
        rslt = template.render(template_dict)
        return rslt

    def visit_Description(self, node):
        filename = getfilename(node)
        template = self.env.get_template(filename)
        template_dict = {
            'definitions':[self.visit(definition) for definition in node.definitions],
            }
        rslt = template.render(template_dict)
        return rslt

    def visit_ModuleDef(self, node):
        filename = getfilename(node)
        template = self.env.get_template(filename)
        paramlist = self.visit(node.paramlist)
        template_dict = {
            'modulename' : node.name,
            'paramlist' : '' if len(node.paramlist.params) == 0 else paramlist,
            'portlist' : self.visit(node.portlist),
            'items' : [ self.visit(item) for item in node.items ],
            }
        rslt = template.render(template_dict)
        return rslt
        
    def visit_Paramlist(self, node):
        filename = getfilename(node)
        template = self.env.get_template(filename)
        params = [ self.visit(param).replace(';','') for param in node.params ]
        template_dict = {
            'params' : params,
            'len_params' : len(params),
            }
        rslt = template.render(template_dict)
        return rslt

    def visit_Portlist(self, node):
        filename = getfilename(node)
        template = self.env.get_template(filename)
        ports = [ self.visit(port) for port in node.ports ]
        template_dict = {
            'ports' : ports,
            'len_ports' : len(ports),
            }
        rslt = template.render(template_dict)
        return rslt

    def visit_Port(self, node):
        filename = getfilename(node)
        template = self.env.get_template(filename)
        template_dict = {
            'name' : node.name,
            }
        rslt = template.render(template_dict)
        return rslt

    def visit_Width(self, node):
        filename = getfilename(node)
        template = self.env.get_template(filename)
        template_dict = {
            'msb' : self.visit(node.msb),
            'lsb' : self.visit(node.lsb),
            }
        rslt = template.render(template_dict)
        return rslt
        
    def visit_Length(self, node):
        filename = getfilename(node)
        template = self.env.get_template(filename)
        template_dict = {
            'msb' : self.visit(node.msb),
            'lsb' : self.visit(node.lsb),
            }
        rslt = template.render(template_dict)
        return rslt
        
    def visit_Identifier(self, node):
        filename = getfilename(node)
        template = self.env.get_template(filename)
        template_dict = {
            'name' : node.name,
            'scope' : '' if node.scope is None else self.visit(node.scope),
            }
        rslt = template.render(template_dict)
        return rslt
        
    def visit_Value(self, node):
        filename = getfilename(node)
        template = self.env.get_template(filename)
        template_dict = {
            'value' : node.value,
            }
        rslt = template.render(template_dict)
        return rslt

    def visit_Constant(self, node):
        filename = getfilename(node)
        template = self.env.get_template(filename)
        template_dict = {
            'value' : node.value,
            }
        rslt = template.render(template_dict)
        return rslt

    def visit_IntConst(self, node):
        filename = getfilename(node)
        template = self.env.get_template(filename)
        template_dict = {
            'value' : node.value,
            }
        rslt = template.render(template_dict)
        return rslt

    def visit_FloatConst(self, node):
        filename = getfilename(node)
        template = self.env.get_template(filename)
        template_dict = {
            'value' : node.value,
            }
        rslt = template.render(template_dict)
        return rslt

    def visit_StringConst(self, node):
        filename = getfilename(node)
        template = self.env.get_template(filename)
        template_dict = {
            'value' : node.value,
            }
        rslt = template.render(template_dict)
        return rslt

    def visit_Variable(self, node):
        filename = getfilename(node)
        template = self.env.get_template(filename)
        template_dict = {
            'name' : node.name,
            'width' : '' if node.width is None else self.visit(node.width),
            'signed' : node.signed,
            }
        rslt = template.render(template_dict)
        return rslt
        
    def visit_Input(self, node):
        filename = getfilename(node)
        template = self.env.get_template(filename)
        template_dict = {
            'name' : node.name,
            'width' : '' if node.width is None else self.visit(node.width),
            'signed' : node.signed,
            }
        rslt = template.render(template_dict)
        return rslt

    def visit_Output(self, node):
        filename = getfilename(node)
        template = self.env.get_template(filename)
        template_dict = {
            'name' : node.name,
            'width' : '' if node.width is None else self.visit(node.width),
            'signed' : node.signed,
            }
        rslt = template.render(template_dict)
        return rslt

    def visit_Inout(self, node):
        filename = getfilename(node)
        template = self.env.get_template(filename)
        template_dict = {
            'name' : node.name,
            'width' : '' if node.width is None else self.visit(node.width),
            'signed' : node.signed,
            }
        rslt = template.render(template_dict)
        return rslt

    def visit_Tri(self, node):
        filename = getfilename(node)
        template = self.env.get_template(filename)
        template_dict = {
            'name' : node.name,
            'width' : '' if node.width is None else self.visit(node.width),
            'signed' : node.signed,
            }
        rslt = template.render(template_dict)
        return rslt

    def visit_Wire(self, node):
        filename = getfilename(node)
        template = self.env.get_template(filename)
        template_dict = {
            'name' : node.name,
            'width' : '' if node.width is None else self.visit(node.width),
            'signed' : node.signed,
            }
        rslt = template.render(template_dict)
        return rslt

    def visit_Reg(self, node):
        filename = getfilename(node)
        template = self.env.get_template(filename)
        template_dict = {
            'name' : node.name,
            'width' : '' if node.width is None else self.visit(node.width),
            'signed' : node.signed,
            }
        rslt = template.render(template_dict)
        return rslt

    def visit_WireArray(self, node):
        filename = getfilename(node)
        template = self.env.get_template(filename)
        template_dict = {
            'name' : node.name,
            'width' : '' if node.width is None else self.visit(node.width),
            'length' : self.visit(node.length),
            'signed' : node.signed,
            }
        rslt = template.render(template_dict)
        return rslt

    def visit_RegArray(self, node):
        filename = getfilename(node)
        template = self.env.get_template(filename)
        template_dict = {
            'name' : node.name,
            'width' : '' if node.width is None else self.visit(node.width),
            'length' : self.visit(node.length),
            'signed' : node.signed,
            }
        rslt = template.render(template_dict)
        return rslt

    def visit_Integer(self, node):
        filename = getfilename(node)
        template = self.env.get_template(filename)
        template_dict = {
            'name' : node.name,
            'signed' : node.signed,
            }
        rslt = template.render(template_dict)
        return rslt

    def visit_Real(self, node):
        filename = getfilename(node)
        template = self.env.get_template(filename)
        template_dict = {
            'name' : node.name,
            }
        rslt = template.render(template_dict)
        return rslt

    def visit_Genvar(self, node):
        filename = getfilename(node)
        template = self.env.get_template(filename)
        template_dict = {
            'name' : node.name,
            }
        rslt = template.render(template_dict)
        return rslt

    def visit_Ioport(self, node):
        filename = getfilename(node)
        template = self.env.get_template(filename)
        template_dict = {
            'first' : node.first.__class__.__name__.lower(),
            'second' : '' if node.second is None else node.second.__class__.__name__.lower(),
            'name' : node.first.name,
            'width' : '' if node.first.width is None else self.visit(node.first.width),
            }
        rslt = template.render(template_dict)
        return rslt

    def visit_Parameter(self, node):
        filename = getfilename(node)
        template = self.env.get_template(filename)
        value = self.visit(node.value)
        template_dict = {
            'name' : node.name,
            'width' : '' if node.width is None or (value.startswith('"') and value.endswith('"')) else self.visit(node.width),
            'value' : value,
            'signed' : node.signed,
            }
        rslt = template.render(template_dict)
        return rslt
        
    def visit_Localparam(self, node):
        filename = getfilename(node)
        template = self.env.get_template(filename)
        value = self.visit(node.value)
        template_dict = {
            'name' : node.name,
            'width' : '' if node.width is None or (value.startswith('"') and value.endswith('"')) else self.visit(node.width),
            'value' : value,
            'signed' : node.signed,
            }
        rslt = template.render(template_dict)
        return rslt

    def visit_Decl(self, node):
        filename = getfilename(node)
        template = self.env.get_template(filename)
        template_dict = {
            'items' : [ self.visit(item) for item in node.list ],
            }
        rslt = template.render(template_dict)
        return rslt

    def visit_WireDeclAssign(self, node):
        filename = getfilename(node)
        template = self.env.get_template(filename)
        template_dict = {
            'decl' : self.visit(node.wire),
            'assign' : self.visit(node.assign),
            }
        rslt = template.render(template_dict)
        return rslt

    def visit_RegDeclAssign(self, node):
        filename = getfilename(node)
        template = self.env.get_template(filename)
        template_dict = {
            'decl' : self.visit(node.reg),
            'assign' : self.visit(node.assign),
            }
        rslt = template.render(template_dict)
        return rslt

    def visit_Concat(self, node):
        filename = getfilename(node)
        template = self.env.get_template(filename)
        items = [ self.visit(item) for item in node.list ]
        template_dict = {
            'items' : items,
            'len_items' : len(items),
            }
        rslt = template.render(template_dict)
        return rslt

    def visit_LConcat(self, node):
        filename = getfilename(node)
        template = self.env.get_template(filename)
        items = [ self.visit(item) for item in node.list ]
        template_dict = {
            'items' : items,
            'len_items' : len(items),
            }
        rslt = template.render(template_dict)
        return rslt

    def visit_Repeat(self, node):
        filename = getfilename(node)
        template = self.env.get_template(filename)
        template_dict = {
            'value' : self.visit(node.value),
            'times' : self.visit(node.times),
            }
        rslt = template.render(template_dict)
        return rslt
        
    def visit_Partselect(self, node):
        filename = getfilename(node)
        template = self.env.get_template(filename)
        template_dict = {
            'var' : self.visit(node.var),
            'msb' : self.visit(node.msb),
            'lsb' : self.visit(node.lsb),
            }
        rslt = template.render(template_dict)
        return rslt
        
    def visit_Pointer(self, node):
        filename = getfilename(node)
        template = self.env.get_template(filename)
        template_dict = {
            'var' : self.visit(node.var),
            'ptr' : self.visit(node.ptr),
            }
        rslt = template.render(template_dict)
        return rslt

    def visit_Lvalue(self, node):
        filename = getfilename(node)
        template = self.env.get_template(filename)
        template_dict = {
            'var' : self.visit(node.var),
            }
        rslt = template.render(template_dict)
        return rslt

    def visit_Rvalue(self, node):
        filename = getfilename(node)
        template = self.env.get_template(filename)
        template_dict = {
            'var' : self.visit(node.var),
            }
        rslt = template.render(template_dict)
        return rslt

    def visit_Operator(self, node):
        filename = getfilename(node)
        template = self.env.get_template(filename)
        template_dict = {
            'left' : self.visit(node.left),
            'right' : self.visit(node.right),
            'op' : op2mark(node.__class__.__name__),
            }
        rslt = template.render(template_dict)
        return rslt

    def visit_UnaryOperator(self, node):
        filename = getfilename(node)
        template = self.env.get_template(filename)
        template_dict = {
            'right' : self.visit(node.right),
            'op' : op2mark(node.__class__.__name__),
            }
        rslt = template.render(template_dict)
        return rslt

    def visit_Uplus(self, node):
        return self.visit_UnaryOperator(node)

    def visit_Uminus(self, node):
        return self.visit_UnaryOperator(node)

    def visit_Ulnot(self, node):
        return self.visit_UnaryOperator(node)

    def visit_Unot(self, node):
        return self.visit_UnaryOperator(node)

    def visit_Uand(self, node):
        return self.visit_UnaryOperator(node)
        
    def visit_Unand(self, node):
        return self.visit_UnaryOperator(node)

    def visit_Uor(self, node):
        return self.visit_UnaryOperator(node)
        
    def visit_Unor(self, node):
        return self.visit_UnaryOperator(node)

    def visit_Uxor(self, node):
        return self.visit_UnaryOperator(node)

    def visit_Uxnor(self, node):
        return self.visit_UnaryOperator(node)

    def visit_Power(self, node):
        return self.visit_Operator(node)

    def visit_Times(self, node):
        return self.visit_Operator(node)

    def visit_Divide(self, node):
        return self.visit_Operator(node)

    def visit_Mod(self, node):
        return self.visit_Operator(node)

    def visit_Plus(self, node):
        return self.visit_Operator(node)

    def visit_Minus(self, node):
        return self.visit_Operator(node)

    def visit_Sll(self, node):
        return self.visit_Operator(node)

    def visit_Srl(self, node):
        return self.visit_Operator(node)

    def visit_Sra(self, node):
        return self.visit_Operator(node)

    def visit_LessThan(self, node):
        return self.visit_Operator(node)

    def visit_GreaterThan(self, node):
        return self.visit_Operator(node)

    def visit_LessEq(self, node):
        return self.visit_Operator(node)

    def visit_GreaterEq(self, node):
        return self.visit_Operator(node)

    def visit_Eq(self, node):
        return self.visit_Operator(node)

    def visit_NotEq(self, node):
        return self.visit_Operator(node)

    def visit_Eql(self, node):
        return self.visit_Operator(node)

    def visit_NotEql(self, node):
        return self.visit_Operator(node)

    def visit_And(self, node):
        return self.visit_Operator(node)

    def visit_Xor(self, node):
        return self.visit_Operator(node)

    def visit_Xnor(self, node):
        return self.visit_Operator(node)

    def visit_Or(self, node):
        return self.visit_Operator(node)

    def visit_Land(self, node):
        return self.visit_Operator(node)

    def visit_Lor(self, node):
        return self.visit_Operator(node)

    def visit_Cond(self, node):
        filename = getfilename(node)
        template = self.env.get_template(filename)
        template_dict = {
            'cond' : self.visit(node.cond),
            'true_value' : self.visit(node.true_value),
            'false_value' : self.visit(node.false_value),
            }
        rslt = template.render(template_dict)
        return rslt

    def visit_Assign(self, node):
        filename = getfilename(node)
        template = self.env.get_template(filename)
        template_dict = {
            'left' : self.visit(node.left),
            'right' : self.visit(node.right),
            }
        rslt = template.render(template_dict)
        return rslt

    def visit_Always(self, node):
        filename = getfilename(node)
        template = self.env.get_template(filename)
        template_dict = {
            'sens_list' : self.visit(node.sens_list),
            'statement' : self.visit(node.statement),
            }
        rslt = template.render(template_dict)
        return rslt

    def visit_SensList(self, node):
        filename = getfilename(node)
        template = self.env.get_template(filename)
        items = [ self.visit(item) for item in node.list ]
        template_dict = {
            'items' : items,
            'len_items' : len(items),
            }
        rslt = template.render(template_dict)
        return rslt

    def visit_Sens(self, node):
        filename = getfilename(node)
        template = self.env.get_template(filename)
        template_dict = {
            'sig' : '*' if node.type == 'all' else self.visit(node.sig),
            'type' : node.type if node.type == 'posedge' or node.type == 'negedge' else ''
            }
        rslt = template.render(template_dict)
        return rslt

    def visit_Substitution(self, node):
        filename = getfilename(node)
        template = self.env.get_template(filename)
        template_dict = {
            'left' : self.visit(node.left),
            'right' : self.visit(node.right),
            'ldelay' : '' if node.ldelay is None else self.visit(node.ldelay),
            'rdelay' : '' if node.rdelay is None else self.visit(node.rdelay),
            }
        rslt = template.render(template_dict)
        return rslt

    def visit_BlockingSubstitution(self, node):
        filename = getfilename(node)
        template = self.env.get_template(filename)
        template_dict = {
            'left' : self.visit(node.left),
            'right' : self.visit(node.right),
            'ldelay' : '' if node.ldelay is None else self.visit(node.ldelay),
            'rdelay' : '' if node.rdelay is None else self.visit(node.rdelay),
            }
        rslt = template.render(template_dict)
        return rslt

    def visit_NonblockingSubstitution(self, node):
        filename = getfilename(node)
        template = self.env.get_template(filename)
        template_dict = {
            'left' : self.visit(node.left),
            'right' : self.visit(node.right),
            'ldelay' : '' if node.ldelay is None else self.visit(node.ldelay),
            'rdelay' : '' if node.rdelay is None else self.visit(node.rdelay),
            }
        rslt = template.render(template_dict)
        return rslt

    def visit_IfStatement(self, node):
        filename = getfilename(node)
        template = self.env.get_template(filename)
        template_dict = {
            'cond' : self.visit(node.cond),
            'true_statement' : '' if node.true_statement is None else self.visit(node.true_statement),
            'false_statement' : '' if node.false_statement is None else self.visit(node.false_statement),
            }
        rslt = template.render(template_dict)
        return rslt
        
    def visit_ForStatement(self, node):
        filename = getfilename(node)
        template = self.env.get_template(filename)
        template_dict = {
            'pre' : '' if node.pre is None else self.visit(node.pre),
            'cond' : '' if node.cond is None else self.visit(node.cond),
            'post' : '' if node.post is None else self.visit(node.post).replace(';', ''),
            'statement' : '' if node.statement is None else self.visit(node.statement),
            }
        rslt = template.render(template_dict)
        return rslt
        
    def visit_WhileStatement(self, node):
        filename = getfilename(node)
        template = self.env.get_template(filename)
        template_dict = {
            'cond' : '' if node.cond is None else self.visit(node.cond),
            'statement' : '' if node.statement is None else self.visit(node.statement),
            }
        rslt = template.render(template_dict)
        return rslt

    def visit_CaseStatement(self, node):
        filename = getfilename(node)
        template = self.env.get_template(filename)
        template_dict = {
            'comp' : self.visit(node.comp),
            'caselist' : [ self.visit(case) for case in node.caselist ],
            }
        rslt = template.render(template_dict)
        return rslt

    def visit_Case(self, node):
        filename = getfilename(node)
        template = self.env.get_template(filename)
        condlist = [ 'default' ] if node.cond is None else [ self.visit(c) for c in node.cond ]
        cond = []
        for c in condlist:
            cond.append(c)
            cond.append(', ')
        template_dict = {
            'cond' : ''.join(cond[:-1]),
            'statement' : self.visit(node.statement),
            }
        rslt = template.render(template_dict)
        return rslt

    def visit_Block(self, node):
        filename = getfilename(node)
        template = self.env.get_template(filename)
        template_dict = {
            'scope' : '' if node.scope is None else node.scope,
            'statements' : [ self.visit(statement) for statement in node.statements ],
            }
        rslt = template.render(template_dict)
        return rslt

    def visit_Initial(self, node):
        filename = getfilename(node)
        template = self.env.get_template(filename)
        template_dict = {
            'statement' : self.visit(node.statement),
            }
        rslt = template.render(template_dict)
        return rslt

    def visit_EventStatement(self, node):
        filename = getfilename(node)
        template = self.env.get_template(filename)
        template_dict = {
            'senslist': self.visit(node.senslist),
            }
        rslt = template.render(template_dict)
        return rslt

    def visit_WaitStatement(self, node):
        filename = getfilename(node)
        template = self.env.get_template(filename)
        template_dict = {
            'cond': self.visit(node.cond),
            'statement' : self.visit(node.statement),
            }
        rslt = template.render(template_dict)
        return rslt

    def visit_ForeverStatement(self, node):
        filename = getfilename(node)
        template = self.env.get_template(filename)
        template_dict = {
            'statement' : self.visit(node.statement),
            }
        rslt = template.render(template_dict)
        return rslt

    def visit_DelayStatement(self, node):
        filename = getfilename(node)
        template = self.env.get_template(filename)
        template_dict = {
            'delay' : self.visit(node.delay),
            }
        rslt = template.render(template_dict)
        return rslt
        
    def visit_Instance(self, node):
        filename = getfilename(node)
        template = self.env.get_template(filename)
        portlist = [ self.visit(port) for port in node.portlist ]
        parameterlist = [ self.visit(param) for param in node.parameterlist ]
        template_dict = {
            'module' : node.module,
            'name' : node.name,
            'portlist' : portlist,
            'len_portlist' : len(portlist),
            'parameterlist' : parameterlist,
            'len_parameterlist' : len(parameterlist),
            }
        rslt = template.render(template_dict)
        return rslt

    def visit_ParamArg(self, node):
        filename = getfilename(node)
        template = self.env.get_template(filename)
        template_dict = {
            'paramname' : '' if node.paramname is None else node.paramname,
            'argname' : '' if node.argname is None else self.visit(node.argname),
            }
        rslt = template.render(template_dict)
        return rslt
        
    def visit_PortArg(self, node):
        filename = getfilename(node)
        template = self.env.get_template(filename)
        template_dict = {
            'portname' : '' if node.portname is None else node.portname,
            'argname' : '' if node.argname is None else self.visit(node.argname),
            }
        rslt = template.render(template_dict)
        return rslt
        
    def visit_Function(self, node):
        filename = getfilename(node)
        template = self.env.get_template(filename)
        statement = [ self.visit(s) for s in node.statement ]
        template_dict = {
            'name' : node.name,
            'retwidth' : self.visit(node.retwidth),
            'statement' : statement,
            }
        rslt = template.render(template_dict)
        return rslt

    def visit_FunctionCall(self, node):
        filename = getfilename(node)
        template = self.env.get_template(filename)
        args = [ self.visit(arg) for arg in node.args ]
        template_dict = {
            'name' : self.visit(node.name),
            'args' : args,
            'len_args' : len(args),
            }
        rslt = template.render(template_dict)
        return rslt

    def visit_Task(self, node):
        filename = getfilename(node)
        template = self.env.get_template(filename)
        template_dict = {
            'name' : node.name,
            'statement' : self.visit(node.statement),
            }
        rslt = template.render(template_dict)
        return rslt

    #def visit_TaskCall(self, node):
    #    filename = getfilename(node)
    #    template = self.env.get_template(filename)
    #    args = [ self.visit(arg) for arg in node.args ]
    #    template_dict = {
    #        'name' : self.visit(node.name),
    #        'args' : args,
    #        'len_args' : len(args),
    #        }
    #    rslt = template.render(template_dict)
    #    return rslt

    def visit_GenerateStatement(self, node):
        filename = getfilename(node)
        template = self.env.get_template(filename)
        template_dict = {
            'items' : [ self.visit(item) for item in node.items ]
            }
        rslt = template.render(template_dict)
        return rslt

    def visit_SystemCall(self, node):
        filename = getfilename(node)
        template = self.env.get_template(filename)
        args = [ self.visit(arg) for arg in node.args ]
        template_dict = {
            'syscall' : node.syscall,
            'args' : args,
            'len_args' : len(args),
            }
        rslt = template.render(template_dict)
        return rslt

    def visit_IdentifierScopeLabel(self, node):
        filename = getfilename(node)
        template = self.env.get_template(filename)
        template_dict = {
            'name' : node.name,
            'loop' : '' if node.loop is None else self.visit(node.loop),
            }
        rslt = template.render(template_dict)
        return rslt

    def visit_IdentifierScope(self, node):
        filename = getfilename(node)
        template = self.env.get_template(filename)
        scopes = [ self.visit(scope) for scope in node.labellist ]
        template_dict = {
            'scopes' : scopes,
            }
        rslt = template.render(template_dict)
        return rslt

    def visit_Pragma(self, node):
        filename = getfilename(node)
        template = self.env.get_template(filename)
        template_dict = {
            'entry' : self.visit(node.entry),
            }
        rslt = template.render(template_dict)
        return rslt

    def visit_PragmaEntry(self, node):
        filename = getfilename(node)
        template = self.env.get_template(filename)
        template_dict = {
            'name' : node.name,
            'value' : '' if node.value is None else self.visit(node.value),
            }
        rslt = template.render(template_dict)
        return rslt

    def visit_Disable(self, node):
        filename = getfilename(node)
        template = self.env.get_template(filename)
        template_dict = {
            'name' : node.dest,
            }        
        rslt = template.render(template_dict)
        return rslt

    def visit_ParallelBlock(self, node):
        filename = getfilename(node)
        template = self.env.get_template(filename)
        template_dict = {
            'scope' : '' if node.scope is None else node.scope,
            'statements' : [ self.visit(statement) for statement in node.statements ],
            }
        rslt = template.render(template_dict)
        return rslt

    def visit_SingleStatement(self, node):
        filename = getfilename(node)
        template = self.env.get_template(filename)
        template_dict = {
            'statement' : self.visit(node.statement),
            }
        rslt = template.render(template_dict)
        return rslt

if __name__ == '__main__':
    from optparse import OptionParser

    INFO = "Code converter from AST"
    VERSION = pyverilog.utils.version.VERSION
    USAGE = "Usage: python codegen.py file ..."

    def showVersion():
        print(INFO)
        print(VERSION)
        print(USAGE)
        sys.exit()
    
    optparser = OptionParser()
    optparser.add_option("-v","--version",action="store_true",dest="showversion",
                         default=False,help="Show the version")
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

    codegen = ASTCodeGenerator()
    rslt = codegen.visit(ast)
    print(rslt)

