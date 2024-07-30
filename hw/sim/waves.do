onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /top_wrapper_tb/sys_clk
add wave -noupdate /top_wrapper_tb/sys_rst
add wave -noupdate /top_wrapper_tb/regbank_clk
add wave -noupdate /top_wrapper_tb/regbank_resetn
add wave -noupdate /top_wrapper_tb/top_i/transformation_engine_i/core_clk
add wave -noupdate /top_wrapper_tb/top_i/transformation_engine_i/resetn
add wave -noupdate /top_wrapper_tb/top_i/transformation_engine_i/regbank_clk
add wave -noupdate /top_wrapper_tb/top_i/transformation_engine_i/regbank_resetn
add wave -noupdate -group NSB -group 0-31 -label node_state_0 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[0]}
add wave -noupdate -group NSB -group 0-31 -label node_state_1 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[1]}
add wave -noupdate -group NSB -group 0-31 -label node_state_2 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[2]}
add wave -noupdate -group NSB -group 0-31 -label node_state_3 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[3]}
add wave -noupdate -group NSB -group 0-31 -label node_state_4 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[4]}
add wave -noupdate -group NSB -group 0-31 -label node_state_5 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[5]}
add wave -noupdate -group NSB -group 0-31 -label node_state_6 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[6]}
add wave -noupdate -group NSB -group 0-31 -label node_state_7 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[7]}
add wave -noupdate -group NSB -group 0-31 -label node_state_8 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[8]}
add wave -noupdate -group NSB -group 0-31 -label node_state_9 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[9]}
add wave -noupdate -group NSB -group 0-31 -label node_state_10 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[10]}
add wave -noupdate -group NSB -group 0-31 -label node_state_11 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[11]}
add wave -noupdate -group NSB -group 0-31 -label node_state_12 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[12]}
add wave -noupdate -group NSB -group 0-31 -label node_state_13 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[13]}
add wave -noupdate -group NSB -group 0-31 -label node_state_14 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[14]}
add wave -noupdate -group NSB -group 0-31 -label node_state_15 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[15]}
add wave -noupdate -group NSB -group 0-31 -label node_state_16 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[16]}
add wave -noupdate -group NSB -group 0-31 -label node_state_17 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[17]}
add wave -noupdate -group NSB -group 0-31 -label node_state_18 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[18]}
add wave -noupdate -group NSB -group 0-31 -label node_state_19 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[19]}
add wave -noupdate -group NSB -group 0-31 -label node_state_20 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[20]}
add wave -noupdate -group NSB -group 0-31 -label node_state_21 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[21]}
add wave -noupdate -group NSB -group 0-31 -label node_state_22 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[22]}
add wave -noupdate -group NSB -group 0-31 -label node_state_23 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[23]}
add wave -noupdate -group NSB -group 0-31 -label node_state_24 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[24]}
add wave -noupdate -group NSB -group 0-31 -label node_state_25 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[25]}
add wave -noupdate -group NSB -group 0-31 -label node_state_26 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[26]}
add wave -noupdate -group NSB -group 0-31 -label node_state_27 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[27]}
add wave -noupdate -group NSB -group 0-31 -label node_state_28 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[28]}
add wave -noupdate -group NSB -group 0-31 -label node_state_29 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[29]}
add wave -noupdate -group NSB -group 0-31 -label node_state_30 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[30]}
add wave -noupdate -group NSB -group 0-31 -label node_state_31 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[31]}
add wave -noupdate -group NSB -group 32-63 -label node_state_32 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[32]}
add wave -noupdate -group NSB -group 32-63 -label node_state_33 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[33]}
add wave -noupdate -group NSB -group 32-63 -label node_state_34 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[34]}
add wave -noupdate -group NSB -group 32-63 -label node_state_35 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[35]}
add wave -noupdate -group NSB -group 32-63 -label node_state_36 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[36]}
add wave -noupdate -group NSB -group 32-63 -label node_state_37 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[37]}
add wave -noupdate -group NSB -group 32-63 -label node_state_38 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[38]}
add wave -noupdate -group NSB -group 32-63 -label node_state_39 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[39]}
add wave -noupdate -group NSB -group 32-63 -label node_state_40 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[40]}
add wave -noupdate -group NSB -group 32-63 -label node_state_41 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[41]}
add wave -noupdate -group NSB -group 32-63 -label node_state_42 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[42]}
add wave -noupdate -group NSB -group 32-63 -label node_state_43 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[43]}
add wave -noupdate -group NSB -group 32-63 -label node_state_44 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[44]}
add wave -noupdate -group NSB -group 32-63 -label node_state_45 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[45]}
add wave -noupdate -group NSB -group 32-63 -label node_state_46 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[46]}
add wave -noupdate -group NSB -group 32-63 -label node_state_47 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[47]}
add wave -noupdate -group NSB -group 32-63 -label node_state_48 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[48]}
add wave -noupdate -group NSB -group 32-63 -label node_state_49 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[49]}
add wave -noupdate -group NSB -group 32-63 -label node_state_50 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[50]}
add wave -noupdate -group NSB -group 32-63 -label node_state_51 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[51]}
add wave -noupdate -group NSB -group 32-63 -label node_state_52 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[52]}
add wave -noupdate -group NSB -group 32-63 -label node_state_53 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[53]}
add wave -noupdate -group NSB -group 32-63 -label node_state_54 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[54]}
add wave -noupdate -group NSB -group 32-63 -label node_state_55 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[55]}
add wave -noupdate -group NSB -group 32-63 -label node_state_56 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[56]}
add wave -noupdate -group NSB -group 32-63 -label node_state_57 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[57]}
add wave -noupdate -group NSB -group 32-63 -label node_state_58 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[58]}
add wave -noupdate -group NSB -group 32-63 -label node_state_59 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[59]}
add wave -noupdate -group NSB -group 32-63 -label node_state_60 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[60]}
add wave -noupdate -group NSB -group 32-63 -label node_state_61 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[61]}
add wave -noupdate -group NSB -group 32-63 -label node_state_62 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[62]}
add wave -noupdate -group NSB -group 32-63 -label node_state_63 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[63]}
add wave -noupdate -group NSB -group 64-95 -label node_state_64 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[64]}
add wave -noupdate -group NSB -group 64-95 -label node_state_65 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[65]}
add wave -noupdate -group NSB -group 64-95 -label node_state_66 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[66]}
add wave -noupdate -group NSB -group 64-95 -label node_state_67 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[67]}
add wave -noupdate -group NSB -group 64-95 -label node_state_68 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[68]}
add wave -noupdate -group NSB -group 64-95 -label node_state_69 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[69]}
add wave -noupdate -group NSB -group 64-95 -label node_state_70 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[70]}
add wave -noupdate -group NSB -group 64-95 -label node_state_71 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[71]}
add wave -noupdate -group NSB -group 64-95 -label node_state_72 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[72]}
add wave -noupdate -group NSB -group 64-95 -label node_state_73 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[73]}
add wave -noupdate -group NSB -group 64-95 -label node_state_74 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[74]}
add wave -noupdate -group NSB -group 64-95 -label node_state_75 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[75]}
add wave -noupdate -group NSB -group 64-95 -label node_state_76 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[76]}
add wave -noupdate -group NSB -group 64-95 -label node_state_77 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[77]}
add wave -noupdate -group NSB -group 64-95 -label node_state_78 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[78]}
add wave -noupdate -group NSB -group 64-95 -label node_state_79 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[79]}
add wave -noupdate -group NSB -group 64-95 -label node_state_80 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[80]}
add wave -noupdate -group NSB -group 64-95 -label node_state_81 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[81]}
add wave -noupdate -group NSB -group 64-95 -label node_state_82 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[82]}
add wave -noupdate -group NSB -group 64-95 -label node_state_83 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[83]}
add wave -noupdate -group NSB -group 64-95 -label node_state_84 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[84]}
add wave -noupdate -group NSB -group 64-95 -label node_state_85 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[85]}
add wave -noupdate -group NSB -group 64-95 -label node_state_86 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[86]}
add wave -noupdate -group NSB -group 64-95 -label node_state_87 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[87]}
add wave -noupdate -group NSB -group 64-95 -label node_state_88 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[88]}
add wave -noupdate -group NSB -group 64-95 -label node_state_89 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[89]}
add wave -noupdate -group NSB -group 64-95 -label node_state_90 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[90]}
add wave -noupdate -group NSB -group 64-95 -label node_state_91 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[91]}
add wave -noupdate -group NSB -group 64-95 -label node_state_92 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[92]}
add wave -noupdate -group NSB -group 64-95 -label node_state_93 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[93]}
add wave -noupdate -group NSB -group 64-95 -label node_state_94 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[94]}
add wave -noupdate -group NSB -group 64-95 -label node_state_95 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[95]}
add wave -noupdate -group NSB -group 96-127 -label node_state_96 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[96]}
add wave -noupdate -group NSB -group 96-127 -label node_state_97 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[97]}
add wave -noupdate -group NSB -group 96-127 -label node_state_98 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[98]}
add wave -noupdate -group NSB -group 96-127 -label node_state_99 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[99]}
add wave -noupdate -group NSB -group 96-127 -label node_state_100 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[100]}
add wave -noupdate -group NSB -group 96-127 -label node_state_101 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[101]}
add wave -noupdate -group NSB -group 96-127 -label node_state_102 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[102]}
add wave -noupdate -group NSB -group 96-127 -label node_state_103 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[103]}
add wave -noupdate -group NSB -group 96-127 -label node_state_104 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[104]}
add wave -noupdate -group NSB -group 96-127 -label node_state_105 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[105]}
add wave -noupdate -group NSB -group 96-127 -label node_state_106 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[106]}
add wave -noupdate -group NSB -group 96-127 -label node_state_107 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[107]}
add wave -noupdate -group NSB -group 96-127 -label node_state_108 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[108]}
add wave -noupdate -group NSB -group 96-127 -label node_state_109 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[109]}
add wave -noupdate -group NSB -group 96-127 -label node_state_110 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[110]}
add wave -noupdate -group NSB -group 96-127 -label node_state_111 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[111]}
add wave -noupdate -group NSB -group 96-127 -label node_state_112 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[112]}
add wave -noupdate -group NSB -group 96-127 -label node_state_113 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[113]}
add wave -noupdate -group NSB -group 96-127 -label node_state_114 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[114]}
add wave -noupdate -group NSB -group 96-127 -label node_state_115 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[115]}
add wave -noupdate -group NSB -group 96-127 -label node_state_116 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[116]}
add wave -noupdate -group NSB -group 96-127 -label node_state_117 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[117]}
add wave -noupdate -group NSB -group 96-127 -label node_state_118 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[118]}
add wave -noupdate -group NSB -group 96-127 -label node_state_119 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[119]}
add wave -noupdate -group NSB -group 96-127 -label node_state_120 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[120]}
add wave -noupdate -group NSB -group 96-127 -label node_state_121 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[121]}
add wave -noupdate -group NSB -group 96-127 -label node_state_122 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[122]}
add wave -noupdate -group NSB -group 96-127 -label node_state_123 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[123]}
add wave -noupdate -group NSB -group 96-127 -label node_state_124 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[124]}
add wave -noupdate -group NSB -group 96-127 -label node_state_125 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[125]}
add wave -noupdate -group NSB -group 96-127 -label node_state_126 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[126]}
add wave -noupdate -group NSB -group 96-127 -label node_state_127 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[127]}
add wave -noupdate -group NSB -group 128-159 -label node_state_128 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[128]}
add wave -noupdate -group NSB -group 128-159 -label node_state_129 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[129]}
add wave -noupdate -group NSB -group 128-159 -label node_state_130 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[130]}
add wave -noupdate -group NSB -group 128-159 -label node_state_131 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[131]}
add wave -noupdate -group NSB -group 128-159 -label node_state_132 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[132]}
add wave -noupdate -group NSB -group 128-159 -label node_state_133 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[133]}
add wave -noupdate -group NSB -group 128-159 -label node_state_134 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[134]}
add wave -noupdate -group NSB -group 128-159 -label node_state_135 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[135]}
add wave -noupdate -group NSB -group 128-159 -label node_state_136 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[136]}
add wave -noupdate -group NSB -group 128-159 -label node_state_137 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[137]}
add wave -noupdate -group NSB -group 128-159 -label node_state_138 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[138]}
add wave -noupdate -group NSB -group 128-159 -label node_state_139 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[139]}
add wave -noupdate -group NSB -group 128-159 -label node_state_140 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[140]}
add wave -noupdate -group NSB -group 128-159 -label node_state_141 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[141]}
add wave -noupdate -group NSB -group 128-159 -label node_state_142 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[142]}
add wave -noupdate -group NSB -group 128-159 -label node_state_143 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[143]}
add wave -noupdate -group NSB -group 128-159 -label node_state_144 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[144]}
add wave -noupdate -group NSB -group 128-159 -label node_state_145 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[145]}
add wave -noupdate -group NSB -group 128-159 -label node_state_146 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[146]}
add wave -noupdate -group NSB -group 128-159 -label node_state_147 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[147]}
add wave -noupdate -group NSB -group 128-159 -label node_state_148 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[148]}
add wave -noupdate -group NSB -group 128-159 -label node_state_149 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[149]}
add wave -noupdate -group NSB -group 128-159 -label node_state_150 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[150]}
add wave -noupdate -group NSB -group 128-159 -label node_state_151 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[151]}
add wave -noupdate -group NSB -group 128-159 -label node_state_152 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[152]}
add wave -noupdate -group NSB -group 128-159 -label node_state_153 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[153]}
add wave -noupdate -group NSB -group 128-159 -label node_state_154 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[154]}
add wave -noupdate -group NSB -group 128-159 -label node_state_155 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[155]}
add wave -noupdate -group NSB -group 128-159 -label node_state_156 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[156]}
add wave -noupdate -group NSB -group 128-159 -label node_state_157 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[157]}
add wave -noupdate -group NSB -group 128-159 -label node_state_158 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[158]}
add wave -noupdate -group NSB -group 128-159 -label node_state_159 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[159]}
add wave -noupdate -group NSB -group 160-191 -label node_state_160 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[160]}
add wave -noupdate -group NSB -group 160-191 -label node_state_161 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[161]}
add wave -noupdate -group NSB -group 160-191 -label node_state_162 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[162]}
add wave -noupdate -group NSB -group 160-191 -label node_state_163 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[163]}
add wave -noupdate -group NSB -group 160-191 -label node_state_164 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[164]}
add wave -noupdate -group NSB -group 160-191 -label node_state_165 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[165]}
add wave -noupdate -group NSB -group 160-191 -label node_state_166 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[166]}
add wave -noupdate -group NSB -group 160-191 -label node_state_167 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[167]}
add wave -noupdate -group NSB -group 160-191 -label node_state_168 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[168]}
add wave -noupdate -group NSB -group 160-191 -label node_state_169 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[169]}
add wave -noupdate -group NSB -group 160-191 -label node_state_170 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[170]}
add wave -noupdate -group NSB -group 160-191 -label node_state_171 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[171]}
add wave -noupdate -group NSB -group 160-191 -label node_state_172 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[172]}
add wave -noupdate -group NSB -group 160-191 -label node_state_173 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[173]}
add wave -noupdate -group NSB -group 160-191 -label node_state_174 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[174]}
add wave -noupdate -group NSB -group 160-191 -label node_state_175 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[175]}
add wave -noupdate -group NSB -group 160-191 -label node_state_176 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[176]}
add wave -noupdate -group NSB -group 160-191 -label node_state_177 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[177]}
add wave -noupdate -group NSB -group 160-191 -label node_state_178 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[178]}
add wave -noupdate -group NSB -group 160-191 -label node_state_179 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[179]}
add wave -noupdate -group NSB -group 160-191 -label node_state_180 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[180]}
add wave -noupdate -group NSB -group 160-191 -label node_state_181 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[181]}
add wave -noupdate -group NSB -group 160-191 -label node_state_182 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[182]}
add wave -noupdate -group NSB -group 160-191 -label node_state_183 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[183]}
add wave -noupdate -group NSB -group 160-191 -label node_state_184 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[184]}
add wave -noupdate -group NSB -group 160-191 -label node_state_185 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[185]}
add wave -noupdate -group NSB -group 160-191 -label node_state_186 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[186]}
add wave -noupdate -group NSB -group 160-191 -label node_state_187 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[187]}
add wave -noupdate -group NSB -group 160-191 -label node_state_188 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[188]}
add wave -noupdate -group NSB -group 160-191 -label node_state_189 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[189]}
add wave -noupdate -group NSB -group 160-191 -label node_state_190 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[190]}
add wave -noupdate -group NSB -group 160-191 -label node_state_191 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[191]}
add wave -noupdate -group NSB -group 192-223 -label node_state_192 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[192]}
add wave -noupdate -group NSB -group 192-223 -label node_state_193 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[193]}
add wave -noupdate -group NSB -group 192-223 -label node_state_194 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[194]}
add wave -noupdate -group NSB -group 192-223 -label node_state_195 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[195]}
add wave -noupdate -group NSB -group 192-223 -label node_state_196 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[196]}
add wave -noupdate -group NSB -group 192-223 -label node_state_197 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[197]}
add wave -noupdate -group NSB -group 192-223 -label node_state_198 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[198]}
add wave -noupdate -group NSB -group 192-223 -label node_state_199 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[199]}
add wave -noupdate -group NSB -group 192-223 -label node_state_200 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[200]}
add wave -noupdate -group NSB -group 192-223 -label node_state_201 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[201]}
add wave -noupdate -group NSB -group 192-223 -label node_state_202 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[202]}
add wave -noupdate -group NSB -group 192-223 -label node_state_203 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[203]}
add wave -noupdate -group NSB -group 192-223 -label node_state_204 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[204]}
add wave -noupdate -group NSB -group 192-223 -label node_state_205 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[205]}
add wave -noupdate -group NSB -group 192-223 -label node_state_206 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[206]}
add wave -noupdate -group NSB -group 192-223 -label node_state_207 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[207]}
add wave -noupdate -group NSB -group 192-223 -label node_state_208 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[208]}
add wave -noupdate -group NSB -group 192-223 -label node_state_209 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[209]}
add wave -noupdate -group NSB -group 192-223 -label node_state_210 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[210]}
add wave -noupdate -group NSB -group 192-223 -label node_state_211 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[211]}
add wave -noupdate -group NSB -group 192-223 -label node_state_212 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[212]}
add wave -noupdate -group NSB -group 192-223 -label node_state_213 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[213]}
add wave -noupdate -group NSB -group 192-223 -label node_state_214 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[214]}
add wave -noupdate -group NSB -group 192-223 -label node_state_215 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[215]}
add wave -noupdate -group NSB -group 192-223 -label node_state_216 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[216]}
add wave -noupdate -group NSB -group 192-223 -label node_state_217 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[217]}
add wave -noupdate -group NSB -group 192-223 -label node_state_218 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[218]}
add wave -noupdate -group NSB -group 192-223 -label node_state_219 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[219]}
add wave -noupdate -group NSB -group 192-223 -label node_state_220 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[220]}
add wave -noupdate -group NSB -group 192-223 -label node_state_221 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[221]}
add wave -noupdate -group NSB -group 192-223 -label node_state_222 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[222]}
add wave -noupdate -group NSB -group 192-223 -label node_state_223 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[223]}
add wave -noupdate -group NSB -group 224-255 -label node_state_224 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[224]}
add wave -noupdate -group NSB -group 224-255 -label node_state_225 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[225]}
add wave -noupdate -group NSB -group 224-255 -label node_state_226 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[226]}
add wave -noupdate -group NSB -group 224-255 -label node_state_227 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[227]}
add wave -noupdate -group NSB -group 224-255 -label node_state_228 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[228]}
add wave -noupdate -group NSB -group 224-255 -label node_state_229 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[229]}
add wave -noupdate -group NSB -group 224-255 -label node_state_230 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[230]}
add wave -noupdate -group NSB -group 224-255 -label node_state_231 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[231]}
add wave -noupdate -group NSB -group 224-255 -label node_state_232 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[232]}
add wave -noupdate -group NSB -group 224-255 -label node_state_233 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[233]}
add wave -noupdate -group NSB -group 224-255 -label node_state_234 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[234]}
add wave -noupdate -group NSB -group 224-255 -label node_state_235 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[235]}
add wave -noupdate -group NSB -group 224-255 -label node_state_236 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[236]}
add wave -noupdate -group NSB -group 224-255 -label node_state_237 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[237]}
add wave -noupdate -group NSB -group 224-255 -label node_state_238 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[238]}
add wave -noupdate -group NSB -group 224-255 -label node_state_239 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[239]}
add wave -noupdate -group NSB -group 224-255 -label node_state_240 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[240]}
add wave -noupdate -group NSB -group 224-255 -label node_state_241 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[241]}
add wave -noupdate -group NSB -group 224-255 -label node_state_242 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[242]}
add wave -noupdate -group NSB -group 224-255 -label node_state_243 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[243]}
add wave -noupdate -group NSB -group 224-255 -label node_state_244 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[244]}
add wave -noupdate -group NSB -group 224-255 -label node_state_245 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[245]}
add wave -noupdate -group NSB -group 224-255 -label node_state_246 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[246]}
add wave -noupdate -group NSB -group 224-255 -label node_state_247 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[247]}
add wave -noupdate -group NSB -group 224-255 -label node_state_248 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[248]}
add wave -noupdate -group NSB -group 224-255 -label node_state_249 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[249]}
add wave -noupdate -group NSB -group 224-255 -label node_state_250 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[250]}
add wave -noupdate -group NSB -group 224-255 -label node_state_251 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[251]}
add wave -noupdate -group NSB -group 224-255 -label node_state_252 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[252]}
add wave -noupdate -group NSB -group 224-255 -label node_state_253 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[253]}
add wave -noupdate -group NSB -group 224-255 -label node_state_254 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[254]}
add wave -noupdate -group NSB -group 224-255 -label node_state_255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[255]}
add wave -noupdate -group WEIGHT_BANK -label weight_bank_state {/top_wrapper_tb/top_i/prefetcher_i/genblk1[0]/weight_bank_i/weight_bank_state}
add wave -noupdate -group WEIGHT_BANK -label weight_channel_resp {/top_wrapper_tb/top_i/prefetcher_i/genblk1[0]/weight_bank_i/weight_channel_resp}
add wave -noupdate -group FETCH_TAG_0 -label message_fetch_state {/top_wrapper_tb/top_i/prefetcher_i/feature_bank_i/genblk1[0]/fetch_tag_i/message_fetch_state}
add wave -noupdate -group FETCH_TAG_0 -label fetch_state {/top_wrapper_tb/top_i/prefetcher_i/feature_bank_i/genblk1[0]/fetch_tag_i/adj_queue_manager_i/fetch_state}
add wave -noupdate -group FETCH_TAG_1 -label message_fetch_state {/top_wrapper_tb/top_i/prefetcher_i/feature_bank_i/genblk1[1]/fetch_tag_i/message_fetch_state}
add wave -noupdate -group FETCH_TAG_1 -label fetch_state {/top_wrapper_tb/top_i/prefetcher_i/feature_bank_i/genblk1[1]/fetch_tag_i/adj_queue_manager_i/fetch_state}
add wave -noupdate -group FETCH_TAG_2 -label message_fetch_state {/top_wrapper_tb/top_i/prefetcher_i/feature_bank_i/genblk1[2]/fetch_tag_i/message_fetch_state}
add wave -noupdate -group FETCH_TAG_2 -label fetch_state {/top_wrapper_tb/top_i/prefetcher_i/feature_bank_i/genblk1[2]/fetch_tag_i/adj_queue_manager_i/fetch_state}
add wave -noupdate -group FETCH_TAG_3 -label message_fetch_state {/top_wrapper_tb/top_i/prefetcher_i/feature_bank_i/genblk1[3]/fetch_tag_i/message_fetch_state}
add wave -noupdate -group FETCH_TAG_3 -label fetch_state {/top_wrapper_tb/top_i/prefetcher_i/feature_bank_i/genblk1[3]/fetch_tag_i/adj_queue_manager_i/fetch_state}
add wave -noupdate -group AGE -label nsb_age_req_valid /top_wrapper_tb/top_i/aggregation_engine_i/nsb_age_req_valid
add wave -noupdate -group AGE -label nsb_age_req_ready /top_wrapper_tb/top_i/aggregation_engine_i/nsb_age_req_ready
add wave -noupdate -group AGE -label nsb_age_req /top_wrapper_tb/top_i/aggregation_engine_i/nsb_age_req
add wave -noupdate -group AGE -label nsb_age_resp_valid /top_wrapper_tb/top_i/aggregation_engine_i/nsb_age_resp_valid
add wave -noupdate -group AGE -label nsb_age_resp /top_wrapper_tb/top_i/aggregation_engine_i/nsb_age_resp
add wave -noupdate -group FLOAT_AGC_ALLOCATOR -label allocation_req_valid {/top_wrapper_tb/top_i/aggregation_engine_i/precision_block[0]/mesh_block[1]/aggregation_mesh_i/agc_allocator/allocation_req_valid}
add wave -noupdate -group FLOAT_AGC_ALLOCATOR -label allocation_req_ready {/top_wrapper_tb/top_i/aggregation_engine_i/precision_block[0]/mesh_block[1]/aggregation_mesh_i/agc_allocator/allocation_req_ready}
add wave -noupdate -group FLOAT_AGC_ALLOCATOR -label allocation_req {/top_wrapper_tb/top_i/aggregation_engine_i/precision_block[0]/mesh_block[1]/aggregation_mesh_i/agc_allocator/allocation_req}
add wave -noupdate -group FLOAT_AGC_ALLOCATOR -label agm_req_valid {/top_wrapper_tb/top_i/aggregation_engine_i/precision_block[0]/mesh_block[1]/aggregation_mesh_i/agc_allocator/agm_req_valid}
add wave -noupdate -group FLOAT_AGC_ALLOCATOR -label agm_req_ready {/top_wrapper_tb/top_i/aggregation_engine_i/precision_block[0]/mesh_block[1]/aggregation_mesh_i/agc_allocator/agm_req_ready}
add wave -noupdate -group FLOAT_AGC_ALLOCATOR -label agm_req {/top_wrapper_tb/top_i/aggregation_engine_i/precision_block[0]/mesh_block[1]/aggregation_mesh_i/agc_allocator/agm_req}
add wave -noupdate -group FLOAT_AGM -label agm_state {/top_wrapper_tb/top_i/aggregation_engine_i/precision_block[0]/mesh_block[1]/aggregation_mesh_i/agm_block[0]/agm_i/agm_state}
add wave -noupdate -group FLOAT_AGM -label agm_state {/top_wrapper_tb/top_i/aggregation_engine_i/precision_block[0]/mesh_block[1]/aggregation_mesh_i/agm_block[1]/agm_i/agm_state}
add wave -noupdate -group FLOAT_AGM -label agm_state {/top_wrapper_tb/top_i/aggregation_engine_i/precision_block[0]/mesh_block[1]/aggregation_mesh_i/agm_block[2]/agm_i/agm_state}
add wave -noupdate -group FLOAT_AGM -label agm_state {/top_wrapper_tb/top_i/aggregation_engine_i/precision_block[0]/mesh_block[1]/aggregation_mesh_i/agm_block[3]/agm_i/agm_state}
add wave -noupdate -group FLOAT_AGC -label row0_col0 {/top_wrapper_tb/top_i/aggregation_engine_i/precision_block[0]/mesh_block[1]/aggregation_mesh_i/row_gen[0]/col_gen[0]/agc_i/agc_state}
add wave -noupdate -group FLOAT_AGC -label row0_col1 {/top_wrapper_tb/top_i/aggregation_engine_i/precision_block[0]/mesh_block[1]/aggregation_mesh_i/row_gen[0]/col_gen[1]/agc_i/agc_state}
add wave -noupdate -group FLOAT_AGC -label row0_col2 {/top_wrapper_tb/top_i/aggregation_engine_i/precision_block[0]/mesh_block[1]/aggregation_mesh_i/row_gen[0]/col_gen[2]/agc_i/agc_state}
add wave -noupdate -group FLOAT_AGC -label row0_col3 {/top_wrapper_tb/top_i/aggregation_engine_i/precision_block[0]/mesh_block[1]/aggregation_mesh_i/row_gen[0]/col_gen[3]/agc_i/agc_state}
add wave -noupdate -group FLOAT_AGC -label row1_col0 {/top_wrapper_tb/top_i/aggregation_engine_i/precision_block[0]/mesh_block[1]/aggregation_mesh_i/row_gen[1]/col_gen[0]/agc_i/agc_state}
add wave -noupdate -group FLOAT_AGC -label row1_col1 {/top_wrapper_tb/top_i/aggregation_engine_i/precision_block[0]/mesh_block[1]/aggregation_mesh_i/row_gen[1]/col_gen[1]/agc_i/agc_state}
add wave -noupdate -group FLOAT_AGC -label row1_col2 {/top_wrapper_tb/top_i/aggregation_engine_i/precision_block[0]/mesh_block[1]/aggregation_mesh_i/row_gen[1]/col_gen[2]/agc_i/agc_state}
add wave -noupdate -group FLOAT_AGC -label row1_col3 {/top_wrapper_tb/top_i/aggregation_engine_i/precision_block[0]/mesh_block[1]/aggregation_mesh_i/row_gen[1]/col_gen[3]/agc_i/agc_state}
add wave -noupdate -group FLOAT_AGC -label row2_col0 {/top_wrapper_tb/top_i/aggregation_engine_i/precision_block[0]/mesh_block[1]/aggregation_mesh_i/row_gen[2]/col_gen[0]/agc_i/agc_state}
add wave -noupdate -group FLOAT_AGC -label row2_col1 {/top_wrapper_tb/top_i/aggregation_engine_i/precision_block[0]/mesh_block[1]/aggregation_mesh_i/row_gen[2]/col_gen[1]/agc_i/agc_state}
add wave -noupdate -group FLOAT_AGC -label row2_col2 {/top_wrapper_tb/top_i/aggregation_engine_i/precision_block[0]/mesh_block[1]/aggregation_mesh_i/row_gen[2]/col_gen[2]/agc_i/agc_state}
add wave -noupdate -group FLOAT_AGC -label row2_col3 {/top_wrapper_tb/top_i/aggregation_engine_i/precision_block[0]/mesh_block[1]/aggregation_mesh_i/row_gen[2]/col_gen[3]/agc_i/agc_state}
add wave -noupdate -group FLOAT_AGC -label row3_col0 {/top_wrapper_tb/top_i/aggregation_engine_i/precision_block[0]/mesh_block[1]/aggregation_mesh_i/row_gen[3]/col_gen[0]/agc_i/agc_state}
add wave -noupdate -group FLOAT_AGC -label row3_col1 {/top_wrapper_tb/top_i/aggregation_engine_i/precision_block[0]/mesh_block[1]/aggregation_mesh_i/row_gen[3]/col_gen[1]/agc_i/agc_state}
add wave -noupdate -group FLOAT_AGC -label row3_col2 {/top_wrapper_tb/top_i/aggregation_engine_i/precision_block[0]/mesh_block[1]/aggregation_mesh_i/row_gen[3]/col_gen[2]/agc_i/agc_state}
add wave -noupdate -group FLOAT_AGC -label row3_col3 {/top_wrapper_tb/top_i/aggregation_engine_i/precision_block[0]/mesh_block[1]/aggregation_mesh_i/row_gen[3]/col_gen[3]/agc_i/agc_state}
add wave -noupdate -group FLOAT_BM -label bm_state {/top_wrapper_tb/top_i/aggregation_engine_i/precision_block[0]/mesh_block[1]/aggregation_mesh_i/bm_block[0]/buffer_manager_i/bm_state}
add wave -noupdate -group FLOAT_BM -label bm_state {/top_wrapper_tb/top_i/aggregation_engine_i/precision_block[0]/mesh_block[1]/aggregation_mesh_i/bm_block[1]/buffer_manager_i/bm_state}
add wave -noupdate -group FLOAT_BM -label bm_state {/top_wrapper_tb/top_i/aggregation_engine_i/precision_block[0]/mesh_block[1]/aggregation_mesh_i/bm_block[2]/buffer_manager_i/bm_state}
add wave -noupdate -group FLOAT_BM -label bm_state {/top_wrapper_tb/top_i/aggregation_engine_i/precision_block[0]/mesh_block[1]/aggregation_mesh_i/bm_block[3]/buffer_manager_i/bm_state}
add wave -noupdate -group FTE -label float_core_state {/top_wrapper_tb/top_i/transformation_engine_i/genblk1[0]/feature_transformation_core_i/fte_state}
add wave -noupdate -group FTE -label pulse_systolic_module {/top_wrapper_tb/top_i/transformation_engine_i/genblk1[0]/feature_transformation_core_i/pulse_systolic_module}
add wave -noupdate -group AXI-L-Interconnect /top_wrapper_tb/top_i/axil_interconnect_i/clk
add wave -noupdate -group AXI-L-Interconnect /top_wrapper_tb/top_i/axil_interconnect_i/rst
add wave -noupdate -group AXI-L-Interconnect /top_wrapper_tb/top_i/axil_interconnect_i/s00_axil_awaddr
add wave -noupdate -group AXI-L-Interconnect /top_wrapper_tb/top_i/axil_interconnect_i/s00_axil_awprot
add wave -noupdate -group AXI-L-Interconnect /top_wrapper_tb/top_i/axil_interconnect_i/s00_axil_awvalid
add wave -noupdate -group AXI-L-Interconnect /top_wrapper_tb/top_i/axil_interconnect_i/s00_axil_awready
add wave -noupdate -group AXI-L-Interconnect /top_wrapper_tb/top_i/axil_interconnect_i/s00_axil_wdata
add wave -noupdate -group AXI-L-Interconnect /top_wrapper_tb/top_i/axil_interconnect_i/s00_axil_wstrb
add wave -noupdate -group AXI-L-Interconnect /top_wrapper_tb/top_i/axil_interconnect_i/s00_axil_wvalid
add wave -noupdate -group AXI-L-Interconnect /top_wrapper_tb/top_i/axil_interconnect_i/s00_axil_wready
add wave -noupdate -group AXI-L-Interconnect /top_wrapper_tb/top_i/axil_interconnect_i/s00_axil_bresp
add wave -noupdate -group AXI-L-Interconnect /top_wrapper_tb/top_i/axil_interconnect_i/s00_axil_bvalid
add wave -noupdate -group AXI-L-Interconnect /top_wrapper_tb/top_i/axil_interconnect_i/s00_axil_bready
add wave -noupdate -group AXI-L-Interconnect /top_wrapper_tb/top_i/axil_interconnect_i/s00_axil_araddr
add wave -noupdate -group AXI-L-Interconnect /top_wrapper_tb/top_i/axil_interconnect_i/s00_axil_arprot
add wave -noupdate -group AXI-L-Interconnect /top_wrapper_tb/top_i/axil_interconnect_i/s00_axil_arvalid
add wave -noupdate -group AXI-L-Interconnect /top_wrapper_tb/top_i/axil_interconnect_i/s00_axil_arready
add wave -noupdate -group AXI-L-Interconnect /top_wrapper_tb/top_i/axil_interconnect_i/s00_axil_rdata
add wave -noupdate -group AXI-L-Interconnect /top_wrapper_tb/top_i/axil_interconnect_i/s00_axil_rresp
add wave -noupdate -group AXI-L-Interconnect /top_wrapper_tb/top_i/axil_interconnect_i/s00_axil_rvalid
add wave -noupdate -group AXI-L-Interconnect /top_wrapper_tb/top_i/axil_interconnect_i/s00_axil_rready
add wave -noupdate -group AXI-L-Interconnect /top_wrapper_tb/top_i/axil_interconnect_i/m00_axil_awaddr
add wave -noupdate -group AXI-L-Interconnect /top_wrapper_tb/top_i/axil_interconnect_i/m00_axil_awprot
add wave -noupdate -group AXI-L-Interconnect /top_wrapper_tb/top_i/axil_interconnect_i/m00_axil_awvalid
add wave -noupdate -group AXI-L-Interconnect /top_wrapper_tb/top_i/axil_interconnect_i/m00_axil_awready
add wave -noupdate -group AXI-L-Interconnect /top_wrapper_tb/top_i/axil_interconnect_i/m00_axil_wdata
add wave -noupdate -group AXI-L-Interconnect /top_wrapper_tb/top_i/axil_interconnect_i/m00_axil_wstrb
add wave -noupdate -group AXI-L-Interconnect /top_wrapper_tb/top_i/axil_interconnect_i/m00_axil_wvalid
add wave -noupdate -group AXI-L-Interconnect /top_wrapper_tb/top_i/axil_interconnect_i/m00_axil_wready
add wave -noupdate -group AXI-L-Interconnect /top_wrapper_tb/top_i/axil_interconnect_i/m00_axil_bresp
add wave -noupdate -group AXI-L-Interconnect /top_wrapper_tb/top_i/axil_interconnect_i/m00_axil_bvalid
add wave -noupdate -group AXI-L-Interconnect /top_wrapper_tb/top_i/axil_interconnect_i/m00_axil_bready
add wave -noupdate -group AXI-L-Interconnect /top_wrapper_tb/top_i/axil_interconnect_i/m00_axil_araddr
add wave -noupdate -group AXI-L-Interconnect /top_wrapper_tb/top_i/axil_interconnect_i/m00_axil_arprot
add wave -noupdate -group AXI-L-Interconnect /top_wrapper_tb/top_i/axil_interconnect_i/m00_axil_arvalid
add wave -noupdate -group AXI-L-Interconnect /top_wrapper_tb/top_i/axil_interconnect_i/m00_axil_arready
add wave -noupdate -group AXI-L-Interconnect /top_wrapper_tb/top_i/axil_interconnect_i/m00_axil_rdata
add wave -noupdate -group AXI-L-Interconnect /top_wrapper_tb/top_i/axil_interconnect_i/m00_axil_rresp
add wave -noupdate -group AXI-L-Interconnect /top_wrapper_tb/top_i/axil_interconnect_i/m00_axil_rvalid
add wave -noupdate -group AXI-L-Interconnect /top_wrapper_tb/top_i/axil_interconnect_i/m00_axil_rready
add wave -noupdate -group AXI-L-Interconnect /top_wrapper_tb/top_i/axil_interconnect_i/m01_axil_awaddr
add wave -noupdate -group AXI-L-Interconnect /top_wrapper_tb/top_i/axil_interconnect_i/m01_axil_awprot
add wave -noupdate -group AXI-L-Interconnect /top_wrapper_tb/top_i/axil_interconnect_i/m01_axil_awvalid
add wave -noupdate -group AXI-L-Interconnect /top_wrapper_tb/top_i/axil_interconnect_i/m01_axil_awready
add wave -noupdate -group AXI-L-Interconnect /top_wrapper_tb/top_i/axil_interconnect_i/m01_axil_wdata
add wave -noupdate -group AXI-L-Interconnect /top_wrapper_tb/top_i/axil_interconnect_i/m01_axil_wstrb
add wave -noupdate -group AXI-L-Interconnect /top_wrapper_tb/top_i/axil_interconnect_i/m01_axil_wvalid
add wave -noupdate -group AXI-L-Interconnect /top_wrapper_tb/top_i/axil_interconnect_i/m01_axil_wready
add wave -noupdate -group AXI-L-Interconnect /top_wrapper_tb/top_i/axil_interconnect_i/m01_axil_bresp
add wave -noupdate -group AXI-L-Interconnect /top_wrapper_tb/top_i/axil_interconnect_i/m01_axil_bvalid
add wave -noupdate -group AXI-L-Interconnect /top_wrapper_tb/top_i/axil_interconnect_i/m01_axil_bready
add wave -noupdate -group AXI-L-Interconnect /top_wrapper_tb/top_i/axil_interconnect_i/m01_axil_araddr
add wave -noupdate -group AXI-L-Interconnect /top_wrapper_tb/top_i/axil_interconnect_i/m01_axil_arprot
add wave -noupdate -group AXI-L-Interconnect /top_wrapper_tb/top_i/axil_interconnect_i/m01_axil_arvalid
add wave -noupdate -group AXI-L-Interconnect /top_wrapper_tb/top_i/axil_interconnect_i/m01_axil_arready
add wave -noupdate -group AXI-L-Interconnect /top_wrapper_tb/top_i/axil_interconnect_i/m01_axil_rdata
add wave -noupdate -group AXI-L-Interconnect /top_wrapper_tb/top_i/axil_interconnect_i/m01_axil_rresp
add wave -noupdate -group AXI-L-Interconnect /top_wrapper_tb/top_i/axil_interconnect_i/m01_axil_rvalid
add wave -noupdate -group AXI-L-Interconnect /top_wrapper_tb/top_i/axil_interconnect_i/m01_axil_rready
add wave -noupdate -group AXI-L-Interconnect /top_wrapper_tb/top_i/axil_interconnect_i/m02_axil_awaddr
add wave -noupdate -group AXI-L-Interconnect /top_wrapper_tb/top_i/axil_interconnect_i/m02_axil_awprot
add wave -noupdate -group AXI-L-Interconnect /top_wrapper_tb/top_i/axil_interconnect_i/m02_axil_awvalid
add wave -noupdate -group AXI-L-Interconnect /top_wrapper_tb/top_i/axil_interconnect_i/m02_axil_awready
add wave -noupdate -group AXI-L-Interconnect /top_wrapper_tb/top_i/axil_interconnect_i/m02_axil_wdata
add wave -noupdate -group AXI-L-Interconnect /top_wrapper_tb/top_i/axil_interconnect_i/m02_axil_wstrb
add wave -noupdate -group AXI-L-Interconnect /top_wrapper_tb/top_i/axil_interconnect_i/m02_axil_wvalid
add wave -noupdate -group AXI-L-Interconnect /top_wrapper_tb/top_i/axil_interconnect_i/m02_axil_wready
add wave -noupdate -group AXI-L-Interconnect /top_wrapper_tb/top_i/axil_interconnect_i/m02_axil_bresp
add wave -noupdate -group AXI-L-Interconnect /top_wrapper_tb/top_i/axil_interconnect_i/m02_axil_bvalid
add wave -noupdate -group AXI-L-Interconnect /top_wrapper_tb/top_i/axil_interconnect_i/m02_axil_bready
add wave -noupdate -group AXI-L-Interconnect /top_wrapper_tb/top_i/axil_interconnect_i/m02_axil_araddr
add wave -noupdate -group AXI-L-Interconnect /top_wrapper_tb/top_i/axil_interconnect_i/m02_axil_arprot
add wave -noupdate -group AXI-L-Interconnect /top_wrapper_tb/top_i/axil_interconnect_i/m02_axil_arvalid
add wave -noupdate -group AXI-L-Interconnect /top_wrapper_tb/top_i/axil_interconnect_i/m02_axil_arready
add wave -noupdate -group AXI-L-Interconnect /top_wrapper_tb/top_i/axil_interconnect_i/m02_axil_rdata
add wave -noupdate -group AXI-L-Interconnect /top_wrapper_tb/top_i/axil_interconnect_i/m02_axil_rresp
add wave -noupdate -group AXI-L-Interconnect /top_wrapper_tb/top_i/axil_interconnect_i/m02_axil_rvalid
add wave -noupdate -group AXI-L-Interconnect /top_wrapper_tb/top_i/axil_interconnect_i/m02_axil_rready
add wave -noupdate -group AXI-L-Interconnect /top_wrapper_tb/top_i/axil_interconnect_i/m03_axil_awaddr
add wave -noupdate -group AXI-L-Interconnect /top_wrapper_tb/top_i/axil_interconnect_i/m03_axil_awprot
add wave -noupdate -group AXI-L-Interconnect /top_wrapper_tb/top_i/axil_interconnect_i/m03_axil_awvalid
add wave -noupdate -group AXI-L-Interconnect /top_wrapper_tb/top_i/axil_interconnect_i/m03_axil_awready
add wave -noupdate -group AXI-L-Interconnect /top_wrapper_tb/top_i/axil_interconnect_i/m03_axil_wdata
add wave -noupdate -group AXI-L-Interconnect /top_wrapper_tb/top_i/axil_interconnect_i/m03_axil_wstrb
add wave -noupdate -group AXI-L-Interconnect /top_wrapper_tb/top_i/axil_interconnect_i/m03_axil_wvalid
add wave -noupdate -group AXI-L-Interconnect /top_wrapper_tb/top_i/axil_interconnect_i/m03_axil_wready
add wave -noupdate -group AXI-L-Interconnect /top_wrapper_tb/top_i/axil_interconnect_i/m03_axil_bresp
add wave -noupdate -group AXI-L-Interconnect /top_wrapper_tb/top_i/axil_interconnect_i/m03_axil_bvalid
add wave -noupdate -group AXI-L-Interconnect /top_wrapper_tb/top_i/axil_interconnect_i/m03_axil_bready
add wave -noupdate -group AXI-L-Interconnect /top_wrapper_tb/top_i/axil_interconnect_i/m03_axil_araddr
add wave -noupdate -group AXI-L-Interconnect /top_wrapper_tb/top_i/axil_interconnect_i/m03_axil_arprot
add wave -noupdate -group AXI-L-Interconnect /top_wrapper_tb/top_i/axil_interconnect_i/m03_axil_arvalid
add wave -noupdate -group AXI-L-Interconnect /top_wrapper_tb/top_i/axil_interconnect_i/m03_axil_arready
add wave -noupdate -group AXI-L-Interconnect /top_wrapper_tb/top_i/axil_interconnect_i/m03_axil_rdata
add wave -noupdate -group AXI-L-Interconnect /top_wrapper_tb/top_i/axil_interconnect_i/m03_axil_rresp
add wave -noupdate -group AXI-L-Interconnect /top_wrapper_tb/top_i/axil_interconnect_i/m03_axil_rvalid
add wave -noupdate -group AXI-L-Interconnect /top_wrapper_tb/top_i/axil_interconnect_i/m03_axil_rready
add wave -noupdate -group AXI-REGBANK /top_wrapper_tb/top_i/transformation_engine_i/s_axi_awaddr
add wave -noupdate -group AXI-REGBANK /top_wrapper_tb/top_i/transformation_engine_i/s_axi_awprot
add wave -noupdate -group AXI-REGBANK /top_wrapper_tb/top_i/transformation_engine_i/s_axi_awvalid
add wave -noupdate -group AXI-REGBANK /top_wrapper_tb/top_i/transformation_engine_i/s_axi_awready
add wave -noupdate -group AXI-REGBANK /top_wrapper_tb/top_i/transformation_engine_i/s_axi_wdata
add wave -noupdate -group AXI-REGBANK /top_wrapper_tb/top_i/transformation_engine_i/s_axi_wstrb
add wave -noupdate -group AXI-REGBANK /top_wrapper_tb/top_i/transformation_engine_i/s_axi_wvalid
add wave -noupdate -group AXI-REGBANK /top_wrapper_tb/top_i/transformation_engine_i/s_axi_wready
add wave -noupdate -group AXI-REGBANK /top_wrapper_tb/top_i/transformation_engine_i/s_axi_araddr
add wave -noupdate -group AXI-REGBANK /top_wrapper_tb/top_i/transformation_engine_i/s_axi_arprot
add wave -noupdate -group AXI-REGBANK /top_wrapper_tb/top_i/transformation_engine_i/s_axi_arvalid
add wave -noupdate -group AXI-REGBANK /top_wrapper_tb/top_i/transformation_engine_i/s_axi_arready
add wave -noupdate -group AXI-REGBANK /top_wrapper_tb/top_i/transformation_engine_i/s_axi_rdata
add wave -noupdate -group AXI-REGBANK /top_wrapper_tb/top_i/transformation_engine_i/s_axi_rresp
add wave -noupdate -group AXI-REGBANK /top_wrapper_tb/top_i/transformation_engine_i/s_axi_rvalid
add wave -noupdate -group AXI-REGBANK /top_wrapper_tb/top_i/transformation_engine_i/s_axi_rready
add wave -noupdate -group AXI-REGBANK /top_wrapper_tb/top_i/transformation_engine_i/s_axi_bresp
add wave -noupdate -group AXI-REGBANK /top_wrapper_tb/top_i/transformation_engine_i/s_axi_bvalid
add wave -noupdate -group AXI-REGBANK /top_wrapper_tb/top_i/transformation_engine_i/s_axi_bready
add wave -noupdate -group NSB-FTE /top_wrapper_tb/top_i/transformation_engine_i/nsb_fte_req_valid
add wave -noupdate -group NSB-FTE /top_wrapper_tb/top_i/transformation_engine_i/nsb_fte_req_ready
add wave -noupdate -group NSB-FTE /top_wrapper_tb/top_i/transformation_engine_i/nsb_fte_req
add wave -noupdate -group NSB-FTE /top_wrapper_tb/top_i/transformation_engine_i/nsb_fte_resp_valid
add wave -noupdate -group NSB-FTE /top_wrapper_tb/top_i/transformation_engine_i/nsb_fte_resp
add wave -noupdate -group NSB-FTE -group CONFIG /top_wrapper_tb/top_i/transformation_engine_i/layer_config_in_features_strobe
add wave -noupdate -group NSB-FTE -group CONFIG /top_wrapper_tb/top_i/transformation_engine_i/layer_config_in_features_count
add wave -noupdate -group NSB-FTE -group CONFIG /top_wrapper_tb/top_i/transformation_engine_i/layer_config_out_features_strobe
add wave -noupdate -group NSB-FTE -group CONFIG /top_wrapper_tb/top_i/transformation_engine_i/layer_config_out_features_count
add wave -noupdate -group NSB-FTE -group CONFIG /top_wrapper_tb/top_i/transformation_engine_i/layer_config_activation_function_strobe
add wave -noupdate -group NSB-FTE -group CONFIG /top_wrapper_tb/top_i/transformation_engine_i/layer_config_activation_function_value
add wave -noupdate -group NSB-FTE -group CONFIG /top_wrapper_tb/top_i/transformation_engine_i/layer_config_bias_strobe
add wave -noupdate -group NSB-FTE -group CONFIG /top_wrapper_tb/top_i/transformation_engine_i/layer_config_bias_value
add wave -noupdate -group NSB-FTE -group CONFIG /top_wrapper_tb/top_i/transformation_engine_i/layer_config_leaky_relu_alpha_strobe
add wave -noupdate -group NSB-FTE -group CONFIG /top_wrapper_tb/top_i/transformation_engine_i/layer_config_leaky_relu_alpha_value
add wave -noupdate -group NSB-FTE -group CONFIG /top_wrapper_tb/top_i/transformation_engine_i/layer_config_out_features_address_msb_strobe
add wave -noupdate -group NSB-FTE -group CONFIG /top_wrapper_tb/top_i/transformation_engine_i/layer_config_out_features_address_lsb_strobe
add wave -noupdate -group NSB-FTE -group CONFIG /top_wrapper_tb/top_i/transformation_engine_i/layer_config_out_features_address_msb_value
add wave -noupdate -group NSB-FTE -group CONFIG /top_wrapper_tb/top_i/transformation_engine_i/layer_config_out_features_address_lsb_value
add wave -noupdate -group NSB-FTE -group CONFIG /top_wrapper_tb/top_i/transformation_engine_i/ctrl_buffering_enable_strobe
add wave -noupdate -group NSB-FTE -group CONFIG /top_wrapper_tb/top_i/transformation_engine_i/ctrl_buffering_enable_value
add wave -noupdate -group NSB-FTE -group CONFIG /top_wrapper_tb/top_i/transformation_engine_i/ctrl_writeback_enable_strobe
add wave -noupdate -group NSB-FTE -group CONFIG /top_wrapper_tb/top_i/transformation_engine_i/ctrl_writeback_enable_value
add wave -noupdate -group AGG-BUFFER /top_wrapper_tb/top_i/transformation_engine_i/aggregation_buffer_node_id
add wave -noupdate -group AGG-BUFFER /top_wrapper_tb/top_i/transformation_engine_i/aggregation_buffer_pop
add wave -noupdate -group AGG-BUFFER /top_wrapper_tb/top_i/transformation_engine_i/aggregation_buffer_out_feature_valid
add wave -noupdate -group AGG-BUFFER /top_wrapper_tb/top_i/transformation_engine_i/aggregation_buffer_out_feature
add wave -noupdate -group AGG-BUFFER /top_wrapper_tb/top_i/transformation_engine_i/aggregation_buffer_slot_free
add wave -noupdate -group WEIGHT-CHANNEL /top_wrapper_tb/top_i/transformation_engine_i/weight_channel_req_valid
add wave -noupdate -group WEIGHT-CHANNEL /top_wrapper_tb/top_i/transformation_engine_i/weight_channel_req_ready
add wave -noupdate -group WEIGHT-CHANNEL /top_wrapper_tb/top_i/transformation_engine_i/weight_channel_req
add wave -noupdate -group WEIGHT-CHANNEL /top_wrapper_tb/top_i/transformation_engine_i/weight_channel_resp_valid
add wave -noupdate -group WEIGHT-CHANNEL /top_wrapper_tb/top_i/transformation_engine_i/weight_channel_resp_ready
add wave -noupdate -group TFE-AXI-INTERCONNECT /top_wrapper_tb/top_i/transformation_engine_i/transformation_engine_axi_interconnect_axi_araddr
add wave -noupdate -group TFE-AXI-INTERCONNECT /top_wrapper_tb/top_i/transformation_engine_i/transformation_engine_axi_interconnect_axi_arburst
add wave -noupdate -group TFE-AXI-INTERCONNECT /top_wrapper_tb/top_i/transformation_engine_i/transformation_engine_axi_interconnect_axi_arcache
add wave -noupdate -group TFE-AXI-INTERCONNECT /top_wrapper_tb/top_i/transformation_engine_i/transformation_engine_axi_interconnect_axi_arid
add wave -noupdate -group TFE-AXI-INTERCONNECT /top_wrapper_tb/top_i/transformation_engine_i/transformation_engine_axi_interconnect_axi_arlen
add wave -noupdate -group TFE-AXI-INTERCONNECT /top_wrapper_tb/top_i/transformation_engine_i/transformation_engine_axi_interconnect_axi_arlock
add wave -noupdate -group TFE-AXI-INTERCONNECT /top_wrapper_tb/top_i/transformation_engine_i/transformation_engine_axi_interconnect_axi_arprot
add wave -noupdate -group TFE-AXI-INTERCONNECT /top_wrapper_tb/top_i/transformation_engine_i/transformation_engine_axi_interconnect_axi_arqos
add wave -noupdate -group TFE-AXI-INTERCONNECT /top_wrapper_tb/top_i/transformation_engine_i/transformation_engine_axi_interconnect_axi_arsize
add wave -noupdate -group TFE-AXI-INTERCONNECT /top_wrapper_tb/top_i/transformation_engine_i/transformation_engine_axi_interconnect_axi_arvalid
add wave -noupdate -group TFE-AXI-INTERCONNECT /top_wrapper_tb/top_i/transformation_engine_i/transformation_engine_axi_interconnect_axi_arready
add wave -noupdate -group TFE-AXI-INTERCONNECT /top_wrapper_tb/top_i/transformation_engine_i/transformation_engine_axi_interconnect_axi_rdata
add wave -noupdate -group TFE-AXI-INTERCONNECT /top_wrapper_tb/top_i/transformation_engine_i/transformation_engine_axi_interconnect_axi_rid
add wave -noupdate -group TFE-AXI-INTERCONNECT /top_wrapper_tb/top_i/transformation_engine_i/transformation_engine_axi_interconnect_axi_rlast
add wave -noupdate -group TFE-AXI-INTERCONNECT /top_wrapper_tb/top_i/transformation_engine_i/transformation_engine_axi_interconnect_axi_rready
add wave -noupdate -group TFE-AXI-INTERCONNECT /top_wrapper_tb/top_i/transformation_engine_i/transformation_engine_axi_interconnect_axi_rresp
add wave -noupdate -group TFE-AXI-INTERCONNECT /top_wrapper_tb/top_i/transformation_engine_i/transformation_engine_axi_interconnect_axi_rvalid
add wave -noupdate -group TFE-AXI-INTERCONNECT /top_wrapper_tb/top_i/transformation_engine_i/transformation_engine_axi_interconnect_axi_awaddr
add wave -noupdate -group TFE-AXI-INTERCONNECT /top_wrapper_tb/top_i/transformation_engine_i/transformation_engine_axi_interconnect_axi_awburst
add wave -noupdate -group TFE-AXI-INTERCONNECT /top_wrapper_tb/top_i/transformation_engine_i/transformation_engine_axi_interconnect_axi_awcache
add wave -noupdate -group TFE-AXI-INTERCONNECT /top_wrapper_tb/top_i/transformation_engine_i/transformation_engine_axi_interconnect_axi_awid
add wave -noupdate -group TFE-AXI-INTERCONNECT /top_wrapper_tb/top_i/transformation_engine_i/transformation_engine_axi_interconnect_axi_awlen
add wave -noupdate -group TFE-AXI-INTERCONNECT /top_wrapper_tb/top_i/transformation_engine_i/transformation_engine_axi_interconnect_axi_awlock
add wave -noupdate -group TFE-AXI-INTERCONNECT /top_wrapper_tb/top_i/transformation_engine_i/transformation_engine_axi_interconnect_axi_awprot
add wave -noupdate -group TFE-AXI-INTERCONNECT /top_wrapper_tb/top_i/transformation_engine_i/transformation_engine_axi_interconnect_axi_awqos
add wave -noupdate -group TFE-AXI-INTERCONNECT /top_wrapper_tb/top_i/transformation_engine_i/transformation_engine_axi_interconnect_axi_awready
add wave -noupdate -group TFE-AXI-INTERCONNECT /top_wrapper_tb/top_i/transformation_engine_i/transformation_engine_axi_interconnect_axi_awsize
add wave -noupdate -group TFE-AXI-INTERCONNECT /top_wrapper_tb/top_i/transformation_engine_i/transformation_engine_axi_interconnect_axi_awvalid
add wave -noupdate -group TFE-AXI-INTERCONNECT /top_wrapper_tb/top_i/transformation_engine_i/transformation_engine_axi_interconnect_axi_wdata
add wave -noupdate -group TFE-AXI-INTERCONNECT /top_wrapper_tb/top_i/transformation_engine_i/transformation_engine_axi_interconnect_axi_wlast
add wave -noupdate -group TFE-AXI-INTERCONNECT /top_wrapper_tb/top_i/transformation_engine_i/transformation_engine_axi_interconnect_axi_wready
add wave -noupdate -group TFE-AXI-INTERCONNECT /top_wrapper_tb/top_i/transformation_engine_i/transformation_engine_axi_interconnect_axi_wstrb
add wave -noupdate -group TFE-AXI-INTERCONNECT /top_wrapper_tb/top_i/transformation_engine_i/transformation_engine_axi_interconnect_axi_wvalid
add wave -noupdate -group TFE-AXI-INTERCONNECT /top_wrapper_tb/top_i/transformation_engine_i/transformation_engine_axi_interconnect_axi_bid
add wave -noupdate -group TFE-AXI-INTERCONNECT /top_wrapper_tb/top_i/transformation_engine_i/transformation_engine_axi_interconnect_axi_bready
add wave -noupdate -group TFE-AXI-INTERCONNECT /top_wrapper_tb/top_i/transformation_engine_i/transformation_engine_axi_interconnect_axi_bresp
add wave -noupdate -group TFE-AXI-INTERCONNECT /top_wrapper_tb/top_i/transformation_engine_i/transformation_engine_axi_interconnect_axi_bvalid
add wave -noupdate -group TC-AXI-WRITE-MASTER /top_wrapper_tb/top_i/transformation_engine_i/transformation_core_axi_write_master_req_valid
add wave -noupdate -group TC-AXI-WRITE-MASTER /top_wrapper_tb/top_i/transformation_engine_i/transformation_core_axi_write_master_req_ready
add wave -noupdate -group TC-AXI-WRITE-MASTER /top_wrapper_tb/top_i/transformation_engine_i/transformation_core_axi_write_master_req_start_address
add wave -noupdate -group TC-AXI-WRITE-MASTER /top_wrapper_tb/top_i/transformation_engine_i/transformation_core_axi_write_master_req_len
add wave -noupdate -group TC-AXI-WRITE-MASTER /top_wrapper_tb/top_i/transformation_engine_i/transformation_core_axi_write_master_pop
add wave -noupdate -group TC-AXI-WRITE-MASTER /top_wrapper_tb/top_i/transformation_engine_i/transformation_core_axi_write_master_data_valid
add wave -noupdate -group TC-AXI-WRITE-MASTER /top_wrapper_tb/top_i/transformation_engine_i/transformation_core_axi_write_master_data
add wave -noupdate -group TC-AXI-WRITE-MASTER /top_wrapper_tb/top_i/transformation_engine_i/transformation_core_axi_write_master_resp_valid
add wave -noupdate -group TC-AXI-WRITE-MASTER /top_wrapper_tb/top_i/transformation_engine_i/transformation_core_axi_write_master_resp_ready
add wave -noupdate -group TC-AXI-WRITE-MASTER -group AXI-WRITE-MASTER /top_wrapper_tb/top_i/transformation_engine_i/axi_write_master_req_valid
add wave -noupdate -group TC-AXI-WRITE-MASTER -group AXI-WRITE-MASTER /top_wrapper_tb/top_i/transformation_engine_i/axi_write_master_req_ready
add wave -noupdate -group TC-AXI-WRITE-MASTER -group AXI-WRITE-MASTER /top_wrapper_tb/top_i/transformation_engine_i/axi_write_master_req_start_address
add wave -noupdate -group TC-AXI-WRITE-MASTER -group AXI-WRITE-MASTER /top_wrapper_tb/top_i/transformation_engine_i/axi_write_master_req_len
add wave -noupdate -group TC-AXI-WRITE-MASTER -group AXI-WRITE-MASTER /top_wrapper_tb/top_i/transformation_engine_i/axi_write_master_pop
add wave -noupdate -group TC-AXI-WRITE-MASTER -group AXI-WRITE-MASTER /top_wrapper_tb/top_i/transformation_engine_i/axi_write_master_data_valid
add wave -noupdate -group TC-AXI-WRITE-MASTER -group AXI-WRITE-MASTER /top_wrapper_tb/top_i/transformation_engine_i/axi_write_master_data
add wave -noupdate -group TC-AXI-WRITE-MASTER -group AXI-WRITE-MASTER /top_wrapper_tb/top_i/transformation_engine_i/axi_write_master_resp_valid
add wave -noupdate -group TC-AXI-WRITE-MASTER -group AXI-WRITE-MASTER /top_wrapper_tb/top_i/transformation_engine_i/axi_write_master_resp_ready
add wave -noupdate -group TRANS-CORE /top_wrapper_tb/top_i/transformation_engine_i/transformation_core_req_ready
add wave -noupdate -group TRANS-CORE /top_wrapper_tb/top_i/transformation_engine_i/transformation_core_resp_valid
add wave -noupdate -group TRANS-CORE /top_wrapper_tb/top_i/transformation_engine_i/transformation_core_resp_ready
add wave -noupdate -group TRANS-CORE /top_wrapper_tb/top_i/transformation_engine_i/transformation_core_resp
add wave -noupdate -group TRANS-CORE /top_wrapper_tb/top_i/transformation_engine_i/transformation_core_resp_valid_bin
add wave -noupdate -group TRANS-CORE /top_wrapper_tb/top_i/transformation_engine_i/transformation_core_write_master_alloc_bin
add wave -noupdate -group TRANS-CORE /top_wrapper_tb/top_i/transformation_engine_i/transformation_core_write_master_alloc_bin_q
add wave -noupdate -group TRANS-BUFFER /top_wrapper_tb/top_i/transformation_engine_i/transformation_buffer_write_enable
add wave -noupdate -group TRANS-BUFFER /top_wrapper_tb/top_i/transformation_engine_i/transformation_buffer_write_address
add wave -noupdate -group TRANS-BUFFER /top_wrapper_tb/top_i/transformation_engine_i/transformation_buffer_slot_free
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {223 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 344
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {831 ps}
bookmark add wave bookmark1 {{17959609 ps} {22111537 ps}} 0
