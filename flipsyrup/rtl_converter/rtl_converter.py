#-------------------------------------------------------------------------------
# rtl_converter.py
# 
# RTL Converter with Pyverilog
#
# Copyright (C) 2013, Shinya Takamaeda-Yamazaki
# License: Apache 2.0
#-------------------------------------------------------------------------------
import sys
import os
import subprocess
import copy
import re
import collections

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))) )

import utils.version

from configuration_reader.resource_definition import MemorySpaceDefinition
from configuration_reader.resource_definition import InterfaceDefinition
from configuration_reader.resource_definition import OutChannelDefinition
from configuration_reader.resource_definition import InChannelDefinition

if sys.version_info[0] >= 3:
    from rtl_converter.convertvisitor import InstanceConvertVisitor
    from rtl_converter.convertvisitor import InstanceReplaceVisitor
else:
    from convertvisitor import InstanceConvertVisitor
    from convertvisitor import InstanceReplaceVisitor

import pyverilog.utils.signaltype as signaltype
from pyverilog.utils.scope import ScopeLabel, ScopeChain
import pyverilog.vparser.ast as vast
from pyverilog.vparser.parser import VerilogCodeParser
from pyverilog.dataflow.modulevisitor import ModuleVisitor
from pyverilog.ast_code_generator.codegen import ASTCodeGenerator

TEMPLATE_DIR = os.path.dirname(os.path.abspath(__file__)) + '/template/'
TEMPLATE_FILE = TEMPLATE_DIR + 'syrup.v'

class RtlConverter(object):
    def __init__(self, filelist, topmodule='userlogic', include=None, define=None):
        self.filelist = filelist
        self.topmodule = topmodule
        self.include = include
        self.define = define
        self.template_file = TEMPLATE_FILE

        self.top_parameters = collections.OrderedDict()
        self.top_ioports = collections.OrderedDict()
        self.target_object = collections.OrderedDict()

    def getTopParameters(self):
        return self.top_parameters
    
    def getTopIOPorts(self):
        return self.top_ioports

    def getTargetObject(self):
        return self.target_object

    def getResourceDefinitions(self):
        target_objects = self.getTargetObject()
        spaces = []
        interfaces = []
        outchannels = []
        inchannels = []

        for mode, target_items in target_objects.items():

            if mode == 'SyrupOutChannel':
                routchannels = self.getOutChannelDefinitions(mode, target_items)
                outchannels.extend(routchannels)

            if mode == 'SyrupInChannel':
                rinchannels = self.getInChannelDefinitions(mode, target_items)
                inchannels.extend(rinchannels)

            if re.match('SyrupMemory.*', mode):
                rspaces, rinterfaces = self.getMemoryDefinitions(mode, target_items)
                spaces.extend(rspaces)
                interfaces.extend(rinterfaces)

        return spaces, interfaces, outchannels, inchannels

    def getOutChannelDefinitions(self, mode, target_items):
        channels = []

        for name, values in target_items:
            idx = values['ID']
            datawidth = values['DATA_WIDTH']
            domain = values['DOMAIN']
            channel = OutChannelDefinition(name, domain, idx, datawidth)
            channels.append(channel)
            
        return channels

    def getInChannelDefinitions(self, mode, target_items):
        channels = []

        for name, values in target_items:
            idx = values['ID']
            datawidth = values['DATA_WIDTH']
            domain = values['DOMAIN']
            channel = InChannelDefinition(name, domain, idx, datawidth)
            channels.append(channel)
            
        return channels

    def getMemoryDefinitions(self, mode, target_items):
        spaces = []
        interfaces = []

        m = re.match('.*(.)P$', mode)
        if m:
            numports = int(m.group(1))
        else:
            raise ValueError("Undefined Syrup Object Type: %s" % mode)

        for name, values in target_items:
            idx = values['ID']
            addrwidth = values['ADDR_WIDTH']
            datawidth = values['DATA_WIDTH']
            byte_enable = False if values['BYTE_ENABLE'] == 0 else True
            linewidth = values['LINEWIDTH']
            numways = values['WAY']
            domain = values['DOMAIN']
            size = 2 ** addrwidth

            # numports and offset are calculated later in abstract_memory.py
            space = MemorySpaceDefinition(name, size, datawidth,
                                          memtype='cache',
                                          mask=byte_enable,
                                          cache_way=numways,
                                          cache_linewidth=linewidth)
            spaces.append(space)

            for i in range(numports):
                interface_name = ''.join([name, '_p', str(i)])
                interface = InterfaceDefinition(interface_name, domain, name, mode='readwrite',
                                                mask=byte_enable, addrlen=addrwidth,
                                                datawidth=datawidth, maskwidth=(datawidth/8))
                interfaces.append(interface)

        return spaces, interfaces

    def dumpTargetObject(self):
        target_object = self.getTargetObject()
        for mode, target_items in target_object.items():
            print("Target %s" % mode)
            for name, values in target_items:
                printstr = []
                printstr.append(" ")
                printstr.append(name)
                printstr.append(': ')
                for valname, value in sorted(values.items(), key=lambda x:x[0]):
                    printstr.append('%s:%s ' % (valname, str(value)))
                print(''.join(printstr))
        
    def generate(self):
        code_parser = VerilogCodeParser(self.filelist,
                                        preprocess_include=self.include,
                                        preprocess_define=self.define)
        ast = code_parser.parse()

        module_visitor = ModuleVisitor()
        module_visitor.visit(ast)
        modulenames = module_visitor.get_modulenames()
        moduleinfotable = module_visitor.get_moduleinfotable()

        template_parser = VerilogCodeParser( (self.template_file,) )
        template_ast = template_parser.parse()
        template_visitor = ModuleVisitor()
        template_visitor.visit(template_ast)
        templateinfotable = template_visitor.get_moduleinfotable()

        instanceconvert_visitor = InstanceConvertVisitor(moduleinfotable, self.topmodule, templateinfotable)
        instanceconvert_visitor.start_visit()

        replaced_instance = instanceconvert_visitor.getMergedReplacedInstance()
        replaced_instports = instanceconvert_visitor.getReplacedInstPorts()
        replaced_items = instanceconvert_visitor.getReplacedItems()        

        new_moduleinfotable = instanceconvert_visitor.get_new_moduleinfotable()
        instancereplace_visitor = InstanceReplaceVisitor(replaced_instance, 
                                                         replaced_instports,
                                                         replaced_items,
                                                         new_moduleinfotable)
        ret = instancereplace_visitor.getAST()

        # gather user-defined io-ports on top-module and parameters to connect external
        frametable = instanceconvert_visitor.getFrameTable()
        top_ioports = []
        for i in moduleinfotable.getIOPorts(self.topmodule):
            if signaltype.isClock(i) or signaltype.isReset(i): continue
            top_ioports.append(i)

        top_sigs = frametable.getSignals( ScopeChain( [ScopeLabel(self.topmodule, 'module')] ) )
        top_params = frametable.getConsts( ScopeChain( [ScopeLabel(self.topmodule, 'module')] ) )
        for sk, sv in top_sigs.items():
            if len(sk) > 2: continue
            signame = sk[1].scopename
            for svv in sv:
                if (signame in top_ioports and 
                    not (signaltype.isClock(signame) or signaltype.isReset(signame)) and
                    isinstance(svv, vast.Input) or isinstance(svv, vast.Output) or isinstance(svv, vast.Inout)):
                    port = svv
                    self.top_ioports[signame] = port
                    break

        for ck, cv in top_params.items():
            if len(ck) > 2: continue
            signame = ck[1].scopename
            param = cv[0]
            if isinstance(param, vast.Genvar): continue
            self.top_parameters[signame] = param

        self.target_object = instanceconvert_visitor.getTargetObject()

        return ret

def main():
    from optparse import OptionParser
    INFO = "RTL Converter with Pyverilog"
    VERSION = utils.version.VERSION
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
