#----------------------------------------
# JasperGold Version Info
# tool      : JasperGold 2018.06
# platform  : Linux 3.10.0-957.21.3.el7.x86_64
# version   : 2018.06p002 64 bits
# build date: 2018.08.27 18:04:53 PDT
#----------------------------------------
# started Thu Dec 29 11:47:59 GMT 2022
# hostname  : ee-mill3.ee.ic.ac.uk
# pid       : 127191
# arguments : '-label' 'session_0' '-console' 'ee-mill3.ee.ic.ac.uk:44410' '-style' 'windows' '-data' 'AQAAADx/////AAAAAAAAA3oBAAAAEABMAE0AUgBFAE0ATwBWAEU=' '-proj' '/home/pg519/nfshome/fuzzy_carnival/fuzzy_carnival_base/ip/transformation_engine/fv/jgproject/sessionLogs/session_0' '-init' '-hidden' '/home/pg519/nfshome/fuzzy_carnival/fuzzy_carnival_base/ip/transformation_engine/fv/jgproject/.tmp/.initCmds.tcl' 'transformation_engine_fv.tcl'
clear -all

analyze -clear

analyze -sv \
    ../rtl/fixed_point_mac.sv \
    ../rtl/mac.sv \
    ../rtl/sys_array_pe.sv \
    ../rtl/sys_array.sv \
    ../rtl/transformation_engine.sv
include {transformation_engine_fv.tcl}
include {transformation_engine_fv.tcl}
