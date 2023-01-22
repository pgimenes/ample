#----------------------------------------
# JasperGold Version Info
# tool      : JasperGold 2018.06
# platform  : Linux 3.10.0-957.21.3.el7.x86_64
# version   : 2018.06p002 64 bits
# build date: 2018.08.27 18:04:53 PDT
#----------------------------------------
# started Thu Dec 29 12:08:00 GMT 2022
# hostname  : ee-mill3.ee.ic.ac.uk
# pid       : 29872
# arguments : '-label' 'session_0' '-console' 'ee-mill3.ee.ic.ac.uk:37784' '-style' 'windows' '-data' 'AQAAADx/////AAAAAAAAA3oBAAAAEABMAE0AUgBFAE0ATwBWAEU=' '-proj' '/home/pg519/nfshome/fuzzy_carnival/fuzzy_carnival_base/ip/transformation_engine/fv/jgproject/sessionLogs/session_0' '-init' '-hidden' '/home/pg519/nfshome/fuzzy_carnival/fuzzy_carnival_base/ip/transformation_engine/fv/jgproject/.tmp/.initCmds.tcl' 'transformation_engine_fv.tcl'
clear -all

analyze -clear

analyze -sv \
    ../include/sys_array_pkg.sv \
    ../rtl/transformation_engine.sv \
    ../rtl/fixed_point_mac.sv \
    ../rtl/mac.sv \
    ../rtl/sys_array_pe.sv \
    ../rtl/sys_array.sv
include {transformation_engine_fv.tcl}
include {transformation_engine_fv.tcl}
include {transformation_engine_fv.tcl}
include {transformation_engine_fv.tcl}
include {transformation_engine_fv.tcl}
prove -bg -property {{<embedded>::transformation_engine.sys_array_i.rows_gen[0].cols_gen[0].sys_array_pe_i.mac_i.P_acc_grows}}
include {transformation_engine_fv.tcl}
prove -bg -property {{<embedded>::transformation_engine.sys_array_i.rows_gen[0].cols_gen[0].sys_array_pe_i.mac_i.P_acc_constant}}
include {transformation_engine_fv.tcl}
prove -bg -property {{<embedded>::transformation_engine.sys_array_i.rows_gen[0].cols_gen[0].sys_array_pe_i.mac_i.P_acc_constant}}
include {transformation_engine_fv.tcl}
prove -bg -property {{<embedded>::transformation_engine.sys_array_i.rows_gen[0].cols_gen[0].sys_array_pe_i.mac_i.P_acc_constant}}
include {transformation_engine_fv.tcl}
include {transformation_engine_fv.tcl}
prove -bg -property {{<embedded>::transformation_engine.sys_array_i.rows_gen[0].cols_gen[0].sys_array_pe_i.mac_i.P_acc_constant}}
include {transformation_engine_fv.tcl}
prove -bg -property {{<embedded>::transformation_engine.sys_array_i.rows_gen[0].cols_gen[0].sys_array_pe_i.mac_i.P_acc_constant}}
include {transformation_engine_fv.tcl}
prove -bg -property {{<embedded>::transformation_engine.sys_array_i.rows_gen[0].cols_gen[0].sys_array_pe_i.mac_i.P_acc_constant}}
include {transformation_engine_fv.tcl}
prove -bg -property {{<embedded>::transformation_engine.sys_array_i.rows_gen[0].cols_gen[0].sys_array_pe_i.mac_i.P_acc_constant}}
visualize -property {<embedded>::transformation_engine.sys_array_i.rows_gen[0].cols_gen[0].sys_array_pe_i.mac_i.P_acc_constant} -new_window
include {transformation_engine_fv.tcl}
prove -bg -property {{<embedded>::transformation_engine.sys_array_i.rows_gen[0].cols_gen[0].sys_array_pe_i.mac_i.P_acc_constant}}
include {transformation_engine_fv.tcl}
include {transformation_engine_fv.tcl}
include {transformation_engine_fv.tcl}
prove -bg -property {{<embedded>::transformation_engine.sys_array_i.rows_gen[2].cols_gen[1].sys_array_pe_i.P_update_acc_both_valid}}
prove -bg -all
include {transformation_engine_fv.tcl}
include {transformation_engine_fv.tcl}
include {transformation_engine_fv.tcl}
prove -bg -property {{<embedded>::transformation_engine.sys_array_i.genblk4[0].P_row_valid_propagates}}
include {transformation_engine_fv.tcl}
prove -bg -property {{<embedded>::transformation_engine.sys_array_i.genblk5[0].P_down_valid_propagates} {<embedded>::transformation_engine.sys_array_i.genblk5[0].P_down_valid_propagates:precondition1} {<embedded>::transformation_engine.sys_array_i.genblk5[1].P_down_valid_propagates} {<embedded>::transformation_engine.sys_array_i.genblk5[1].P_down_valid_propagates:precondition1} {<embedded>::transformation_engine.sys_array_i.genblk5[2].P_down_valid_propagates} {<embedded>::transformation_engine.sys_array_i.genblk5[2].P_down_valid_propagates:precondition1} {<embedded>::transformation_engine.sys_array_i.genblk5[3].P_down_valid_propagates} {<embedded>::transformation_engine.sys_array_i.genblk5[3].P_down_valid_propagates:precondition1}}
include {transformation_engine_fv.tcl}
prove -bg -property {{<embedded>::transformation_engine.sys_array_i.genblk5[0].P_down_valid_propagates}}
prove -bg -property {{<embedded>::transformation_engine.sys_array_i.genblk5[0].P_down_valid_propagates} {<embedded>::transformation_engine.sys_array_i.genblk5[1].P_down_valid_propagates} {<embedded>::transformation_engine.sys_array_i.genblk5[2].P_down_valid_propagates} {<embedded>::transformation_engine.sys_array_i.genblk5[3].P_down_valid_propagates}}
prove -bg -property {{<embedded>::transformation_engine.sys_array_i.genblk5[0].P_down_valid_propagates:precondition1}}
prove -bg -property {{<embedded>::transformation_engine.sys_array_i.genblk4[0].P_forward_valid_propagates} {<embedded>::transformation_engine.sys_array_i.genblk4[1].P_forward_valid_propagates} {<embedded>::transformation_engine.sys_array_i.genblk4[2].P_forward_valid_propagates} {<embedded>::transformation_engine.sys_array_i.genblk4[3].P_forward_valid_propagates}}
include {transformation_engine_fv.tcl}
prove -bg -property {{<embedded>::transformation_engine.sys_array_i.genblk4[0].P_forward_valid_propagates}}
include {transformation_engine_fv.tcl}
prove -bg -property {{<embedded>::transformation_engine.sys_array_i.genblk4[0].P_forward_valid_propagates}}
include {transformation_engine_fv.tcl}
prove -bg -property {{<embedded>::transformation_engine.sys_array_i.genblk4[0].P_forward_valid_propagates}}
include {transformation_engine_fv.tcl}
prove -bg -property {{<embedded>::transformation_engine.sys_array_i.genblk4[0].P_forward_valid_propagates}}
include {transformation_engine_fv.tcl}
prove -bg -property {{<embedded>::transformation_engine.sys_array_i.genblk4[0].P_forward_valid_propagates}}
