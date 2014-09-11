#-------------------------------------------------------------------------------
# flipsyrup.py
#
# Cycle-Accurate Hardware Simulation Framework on Abstract FPGA Platforms
# 
# Copyright (C) 2013, Shinya Takamaeda-Yamazaki
# License: Apache 2.0
#-------------------------------------------------------------------------------

# Processing step
# (1) RTL conversion and gathering the memory interface information
# (2) Cache system synthesis
# (3) Channel system synthesis
# (4) Drive signal insertion
# (5) Top module synthesis with user-defined RTL

import os
import sys
import math
import re
import copy
import shutil
import glob
from jinja2 import Environment, FileSystemLoader
if sys.version_info[0] < 3:
    import ConfigParser as configparser
else:
    import configparser

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)) )

import utils.version
import configuration_reader.configuration_reader
import configuration_reader.domain_generator
from configuration_reader.resource_definition import MemorySpaceDefinition
from configuration_reader.resource_definition import InterfaceDefinition
from configuration_reader.resource_definition import OnchipMemoryDefinition
from configuration_reader.resource_definition import OffchipMemoryDefinition
from configuration_reader.resource_definition import OutChannelDefinition
from configuration_reader.resource_definition import InChannelDefinition

from rtl_converter.rtl_converter import RtlConverter
from drive_inserter.drive_inserter import DriveInserter
from abstract_memory.abstract_memory import AbstractMemoryGenerator
from abstract_channel.abstract_channel import AbstractChannelGenerator

import pyverilog.vparser.ast as vast
from pyverilog.ast_code_generator.codegen import ASTCodeGenerator

TEMPLATE_DIR = os.path.dirname(os.path.abspath(__file__)) + '/template/'

#-------------------------------------------------------------------------------
class SyrupBuilder(object):
    def __init__(self):
        self.env = Environment(loader=FileSystemLoader(TEMPLATE_DIR))
        self.env.globals['int'] = int
        self.env.globals['log'] = math.log
        self.env.globals['len'] = len

    #---------------------------------------------------------------------------
    def render(self, template_file, 
               userlogic_name, domains,
               def_top_parameters, def_top_localparams, def_top_ioports,
               name_top_ioports,
               ext_addrwidth=64, ext_datawidth=128, ext_burstlength=256,
               drive_name=None, single_clock=False, 
               hdlname=None, testname=None, ipcore_version=None,
               memimg=None, binfile=False, usertestcode=None, simaddrwidth=None,
               mpd_parameters=None, mpd_ports=None,
               clock_hperiod_userlogic=None,
               clock_hperiod_axi=None):

        ext_burstlen_width = int(math.ceil(math.log(ext_burstlength,2) + 1))
        template_dict = {
            'userlogic_name' : userlogic_name,
            'domains' : domains,

            'def_top_parameters' : def_top_parameters,
            'def_top_localparams' : def_top_localparams,
            'def_top_ioports' : def_top_ioports,
            'name_top_ioports' : name_top_ioports,

            'ext_addrwidth' : ext_addrwidth,
            'ext_datawidth' : ext_datawidth,
            'ext_burstlength' : ext_burstlength,
            'ext_burstlen_width' : ext_burstlen_width,
            'drive' : drive_name,
            'single_clock' : single_clock,

            'hdlname' : hdlname,
            'testname' : testname,
            'ipcore_version' : ipcore_version,
            'memimg' : memimg if memimg is not None else 'None',
            'binfile' : binfile,
            'usertestcode' : '' if usertestcode is None else usertestcode,
            'simaddrwidth' : simaddrwidth,
            
            'mpd_parameters' : () if mpd_parameters is None else mpd_parameters,
            'mpd_ports' : () if mpd_ports is None else mpd_ports,

            'clock_hperiod_userlogic' : clock_hperiod_userlogic,
            'clock_hperiod_axi' : clock_hperiod_axi,
            }
        
        template = self.env.get_template(template_file)
        rslt = template.render(template_dict)
        return rslt

    #---------------------------------------------------------------------------
    def build(self, configs, memory_configs, filelist, topmodule,
              include=None, define=None, memimg=None, usertest=None):

        if configs['single_clock'] and (configs['hperiod_ulogic'] != configs['hperiod_axi']):
            raise ValueError("All clock periods should be same in single clock mode.")

        # default values
        ext_burstlength = 256 if configs['if_type'] == 'axi' else 256

        converter = RtlConverter(filelist,
                                 topmodule=topmodule, include=include, define=define)
        ast = converter.generate()

        top_parameters = converter.getTopParameters()
        top_ioports = converter.getTopIOPorts()

        memoryspacelist, interfacelist, outchannellist, inchannellist = converter.getResourceDefinitions()
        domains = configuration_reader.domain_generator.get_domains(interfacelist, outchannellist, inchannellist)

        if len(domains) > 1:
            raise ValueError("Using multiple domains is not supported currently.")

        # Drive Signal Insertion
        inserter = DriveInserter(configs['drive'])
        drive_ast = inserter.generate(ast)

        asttocode = ASTCodeGenerator()
        userlogic_code = asttocode.visit(drive_ast)

        # Syrup memory
        resourcelist = configuration_reader.configuration_reader.readResourceDefinitions(memory_configs)

        onchipmemorylist = []
        offchipmemorylist = []

        for resource in resourcelist:
            if isinstance(resource, OnchipMemoryDefinition):
                onchipmemorylist.append(resource)
            elif isinstance(resource, OffchipMemoryDefinition):
                offchipmemorylist.append(resource)
            elif isinstance(resource, MemorySpaceDefinition):
                raise TypeError("Can not accept External Memory Space Definitions.")
            elif isinstance(resource, InterfaceDefinition):
                raise TypeError("Can not accept External Interface Definitions.")
            else:
                raise NameError('Wrong Definition Format')

        if not offchipmemorylist:
            raise ValueError("Off-chip Memory Definition not found")

        if not onchipmemorylist:
            raise ValueError("On-chip Memory Definition not found")

        ext_addrwidth = offchipmemorylist[0].addrlen
        ext_datawidth = offchipmemorylist[0].datawidth

        memorygen = AbstractMemoryGenerator(onchipmemorylist, offchipmemorylist, 
                                            memoryspacelist, interfacelist, domains)
        memory_code = memorygen.create()

        channelgen = AbstractChannelGenerator()
        channel_code = channelgen.create(domains)

        # top module
        asttocode = ASTCodeGenerator()
        def_top_parameters = []
        def_top_localparams = []
        def_top_ioports = []
        name_top_ioports = []
        for p in top_parameters.values():
            r = asttocode.visit(p)
            if r.count('localparam'):
                def_top_localparams.append( r )
            else:
                def_top_parameters.append( r.replace(';', ',') )
        for pk, pv in top_ioports.items():
            new_pv = vast.Ioport(pv, vast.Wire(pv.name, pv.width, pv.signed))
            def_top_ioports.append( asttocode.visit(new_pv) )
            name_top_ioports.append( pk )

        node_template_file = ('node_axi.txt' if configs['if_type'] == 'axi' else
                              #'node_avalon.txt' if configs['if_type'] == 'avalon' else 
                              #'node_wishborn.txt' if configs['if_type'] == 'wishborn' else 
                              'node_general.txt')
        node_code = self.render(node_template_file,
                                topmodule, domains,
                                def_top_parameters, def_top_localparams, def_top_ioports, name_top_ioports, 
                                ext_addrwidth=ext_addrwidth,
                                ext_datawidth=ext_datawidth,
                                ext_burstlength=ext_burstlength,
                                drive_name=configs['drive'],
                                single_clock=configs['single_clock'])

        # finalize
        entire_code = []
        entire_code.append(node_code)
        entire_code.append(userlogic_code)
        entire_code.append(memory_code)
        entire_code.append(channel_code)
        if configs['if_type'] == 'axi':
            entire_code.append(open(TEMPLATE_DIR+'axi_master_interface.v', 'r').read())

        code = ''.join(entire_code)
        
        # write to file, without AXI interfaces
        if configs['if_type'] == 'general':
            f = open(configs['output'], 'w')
            f.write(code)
            f.close()
            return
            
        if configs['if_type'] != 'axi':
            raise ValueError("Interface type '%s' is not supported." % configs['if_type'])

        # write to files, with AXI interface
        def_top_parameters = []
        def_top_ioports = []
        mpd_parameters = []
        mpd_ports = []

        for pk, pv in top_parameters.items():
            r = asttocode.visit(pv)
            def_top_parameters.append( r )
            if r.count('localparam'):
                continue
            _name = pv.name
            _value = asttocode.visit( pv.value )
            _dt = 'string' if r.count('"') else 'integer'
            mpd_parameters.append( (_name, _value, _dt) )

        for pk, pv in top_ioports.items():
            new_pv = vast.Wire(pv.name, pv.width, pv.signed)
            def_top_ioports.append( asttocode.visit(new_pv) )
            _name = pv.name
            _dir = ('I' if isinstance(pv, vast.Input) else
                    'O' if isinstance(pv, vast.Output) else
                    'IO')
            _vec = '' if pv.width is None else asttocode.visit(pv.width) 
            mpd_ports.append( (_name, _dir, _vec) )

        # write to files 
        # with AXI interface, create IPcore dir
        ipcore_version = '_v1_00_a'
        mpd_version = '_v2_1_0'
        dirname = 'syrup_' + topmodule + ipcore_version + '/'
        mpdname = 'syrup_' + topmodule + mpd_version + '.mpd'
        #muiname = 'syrup_' + topmodule + mpd_version + '.mui'
        paoname = 'syrup_' + topmodule + mpd_version + '.pao'
        tclname = 'syrup_' + topmodule + mpd_version + '.tcl'
        hdlname = 'syrup_' + topmodule + '.v'
        testname = 'testbench_' + topmodule + '.v'
        memname = 'mem.img'
        makefilename = 'Makefile'
        copied_memimg = memname if memimg is not None else None
        binfile = (True if memimg is not None and memimg.endswith('.bin') else False)
        hdlpath = dirname + 'hdl/'
        verilogpath = dirname + 'hdl/verilog/'
        mpdpath = dirname + 'data/'
        #muipath = dirname + 'data/'
        paopath = dirname + 'data/'
        tclpath = dirname + 'data/'
        testpath = dirname + 'test/'
        makefilepath = dirname + 'test/'

        if not os.path.exists(dirname):
            os.mkdir(dirname)
        if not os.path.exists(dirname + '/' + 'data'):
            os.mkdir(dirname + '/' + 'data')
        if not os.path.exists(dirname + '/' + 'doc'):
            os.mkdir(dirname + '/' + 'doc')
        if not os.path.exists(dirname + '/' + 'hdl'):
            os.mkdir(dirname + '/' + 'hdl')
        if not os.path.exists(dirname + '/' + 'hdl/verilog'):
            os.mkdir(dirname + '/' + 'hdl/verilog')
        if not os.path.exists(dirname + '/' + 'test'):
            os.mkdir(dirname + '/' + 'test')

        # hdl file
        f = open(verilogpath+hdlname, 'w')
        f.write(code)
        f.close()

        # mpd file
        mpd_template_file = 'mpd.txt'
        mpd_code = self.render(mpd_template_file,
                               topmodule, domains, 
                               def_top_parameters, def_top_localparams, def_top_ioports, name_top_ioports,
                               ext_addrwidth=ext_addrwidth, 
                               ext_datawidth=ext_datawidth, 
                               ext_burstlength=ext_burstlength,
                               single_clock=configs['single_clock'],
                               ipcore_version=ipcore_version, 
                               mpd_ports=mpd_ports, mpd_parameters=mpd_parameters)
        f = open(mpdpath+mpdname, 'w')
        f.write(mpd_code)
        f.close()

        # mui file
        #mui_template_file = 'mui.txt'
        #mui_code = self.render(mui_template_file,
        #                       topmodule, domains,
        #                       def_top_parameters, def_top_localparams,
        #                       def_top_ioports, name_top_ioports,
        #                       ext_addrwidth=ext_addrwidth,
        #                       ext_datawidth=ext_datawidth,
        #                       ext_burstlength=ext_burstlength, 
        #                       single_clock=configs['single_clock'],
        #                       mpd_parameters=mpd_parameters)
        #f = open(muipath+muiname, 'w')
        #f.write(mui_code)
        #f.close()

        # pao file
        pao_template_file = 'pao.txt'
        pao_code = self.render(pao_template_file,
                               topmodule, domains,
                               def_top_parameters, def_top_localparams, def_top_ioports, name_top_ioports,
                               ext_addrwidth=ext_addrwidth,
                               ext_datawidth=ext_datawidth,
                               ext_burstlength=ext_burstlength,
                               single_clock=configs['single_clock'],
                               hdlname=hdlname, ipcore_version=ipcore_version)
        f = open(paopath+paoname, 'w')
        f.write(pao_code)
        f.close()

        # tcl file
        tcl_code = ''
        if not configs['single_clock'] and inchannellist:
            tcl_code = open(TEMPLATE_DIR+'tcl.tcl', 'r').read()
        f = open(tclpath+tclname, 'w')
        f.write(tcl_code)
        f.close()

        # user test code
        usertestcode = None 
        if usertest is not None:
            usertestcode = open(usertest, 'r').read()

        # test file
        test_template_file = 'testbench.txt'
        test_code = self.render(test_template_file,
                                topmodule, domains,
                                def_top_parameters, def_top_localparams, def_top_ioports, name_top_ioports,
                                ext_addrwidth=ext_addrwidth,
                                ext_datawidth=ext_datawidth,
                                ext_burstlength=ext_burstlength,
                                single_clock=configs['single_clock'],
                                hdlname=hdlname,
                                memimg=copied_memimg, binfile=binfile,
                                usertestcode=usertestcode,
                                simaddrwidth=configs['sim_addrwidth'],
                                clock_hperiod_userlogic=configs['hperiod_ulogic'],
                                clock_hperiod_axi=configs['hperiod_axi'])
        f = open(testpath+testname, 'w')
        f.write(test_code)
        f.close()

        # memory image for test
        if memimg is not None:
            f = open(testpath+memname, 'w')
            f.write(open(memimg, 'r').read())
            f.close()

        # makefile file
        makefile_template_file = 'Makefile.txt'
        makefile_code = self.render(makefile_template_file,
                                    topmodule, domains,
                                    def_top_parameters, def_top_localparams, def_top_ioports, name_top_ioports,
                                    ext_addrwidth=ext_addrwidth,
                                    ext_datawidth=ext_datawidth,
                                    ext_burstlength=ext_burstlength,
                                    single_clock=configs['single_clock'],
                                    testname=testname)
        f = open(makefilepath+makefilename, 'w')
        f.write(makefile_code)
        f.close()

#-------------------------------------------------------------------------------
def main():
    from optparse import OptionParser
    INFO = "flipSyrup: Cycle-Accurate Hardware Simulation Framework on Abstract FPGA Platforms"
    VERSION = utils.version.VERSION
    USAGE = "Usage: python flipsyrup.py [config] [-t topmodule] [-I includepath]+ [--memimg=filename] [--usertest=filename] [file]+"

    def showVersion():
        print(INFO)
        print(VERSION)
        print(USAGE)
        sys.exit()
    
    optparser = OptionParser()
    optparser.add_option("-v","--version",action="store_true",dest="showversion",
                         default=False,help="Show the version")
    optparser.add_option("-t","--top",dest="topmodule",
                         default="TOP",help="Top module of user logic, Default=userlogic")
    optparser.add_option("-I","--include",dest="include",action="append",
                         default=[],help="Include path")
    optparser.add_option("-D",dest="define",action="append",
                         default=[],help="Macro Definition")
    optparser.add_option("--memimg",dest="memimg",
                         default=None,help="Memory image file, Default=None")
    optparser.add_option("--usertest",dest="usertest",
                         default=None,help="User-defined test code file, Default=None")
    (options, args) = optparser.parse_args()

    filelist = []
    for arg in args:
        filelist.extend( glob.glob(os.path.expanduser(arg)) )

    if options.showversion:
        showVersion()

    for f in filelist:
        if not os.path.exists(f): raise IOError("file not found: " + f)

    if len(filelist) == 0:
        showVersion()

    configfile = None
    userlogic_filelist = []
    for f in filelist:
        if f.endswith('.v'):
            userlogic_filelist.append(f)
        if f.endswith('.config'):
            if configfile is not None: raise IOError("Multiple configuration files")
            configfile = f

    print("Input files")
    print("  Configuration: %s" % configfile)
    print("  User-logic: %s" % ', '.join(userlogic_filelist) )

    # default values
    configs = {
        'single_clock' : True,
        'drive' : 'DRIVE',
        'if_type' : 'axi',
        'output' : 'out.v',
        'sim_addrwidth' : 27,
        'hperiod_ulogic' : 5,
        'hperiod_cthread' : 5,
        'hperiod_axi' : 5,
    }

    confp = configparser.SafeConfigParser()
    if configfile is not None:
        confp.read(configfile)

    if not confp.has_section('BRAM'):
        raise ValueError("BRAM parameters are not defined.")
    if not confp.has_section('DRAM'):
        raise ValueError("DRAM parameters are not defined.")
        
    memory_configs = {}
    memory_configs['BRAM'] = {}
    memory_configs['DRAM'] = {}
    for k, v in confp.items('BRAM'):
        memory_configs['BRAM'][k] = v
    for k, v in confp.items('DRAM'):
        memory_configs['DRAM'][k] = v

    if confp.has_section('synthesis'):
        for k, v in confp.items('synthesis'):
            if k == 'single_clock':
                configs[k] = False if 'n' in v or 'N' in v else True
            elif k not in configs:
                raise ValueError("No such configuration item: %s" % k)
            else:
                configs[k] = v

    if confp.has_section('simulation'):
        for k, v in confp.items('simulation'):
            if k == 'sim_addrwidth' or k == 'hperiod_ulogic' or k == 'hperiod_cthread' or k == 'hperiod_axi':
                configs[k] = int(v)
            elif k not in configs:
                raise ValueError("No such configuration item: %s" % k)
            else:
                configs[k] = v

    if configs['hperiod_ulogic'] != configs['hperiod_axi']:
        raise ValueError(("Half period values of User-logic and AXI"
                          " should be same in current implementation"))

    builder = SyrupBuilder()
    builder.build(configs, memory_configs,
                  userlogic_filelist, 
                  options.topmodule, 
                  include=options.include,
                  define=options.define,
                  usertest=options.usertest,
                  memimg=options.memimg)

if __name__ == '__main__':
    main()
