onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /top_wrapper_tb/top_i/aggregation_engine_i/core_clk
add wave -noupdate /top_wrapper_tb/top_i/aggregation_engine_i/resetn
add wave -noupdate /top_wrapper_tb/top_i/aggregation_engine_i/regbank_clk
add wave -noupdate /top_wrapper_tb/top_i/aggregation_engine_i/regbank_resetn
add wave -noupdate -group AXI /top_wrapper_tb/top_i/aggregation_engine_i/s_axi_awaddr
add wave -noupdate -group AXI /top_wrapper_tb/top_i/aggregation_engine_i/s_axi_awprot
add wave -noupdate -group AXI /top_wrapper_tb/top_i/aggregation_engine_i/s_axi_awvalid
add wave -noupdate -group AXI /top_wrapper_tb/top_i/aggregation_engine_i/s_axi_awready
add wave -noupdate -group AXI /top_wrapper_tb/top_i/aggregation_engine_i/s_axi_wdata
add wave -noupdate -group AXI /top_wrapper_tb/top_i/aggregation_engine_i/s_axi_wstrb
add wave -noupdate -group AXI /top_wrapper_tb/top_i/aggregation_engine_i/s_axi_wvalid
add wave -noupdate -group AXI /top_wrapper_tb/top_i/aggregation_engine_i/s_axi_wready
add wave -noupdate -group AXI /top_wrapper_tb/top_i/aggregation_engine_i/s_axi_araddr
add wave -noupdate -group AXI /top_wrapper_tb/top_i/aggregation_engine_i/s_axi_arprot
add wave -noupdate -group AXI /top_wrapper_tb/top_i/aggregation_engine_i/s_axi_arvalid
add wave -noupdate -group AXI /top_wrapper_tb/top_i/aggregation_engine_i/s_axi_arready
add wave -noupdate -group AXI /top_wrapper_tb/top_i/aggregation_engine_i/s_axi_rdata
add wave -noupdate -group AXI /top_wrapper_tb/top_i/aggregation_engine_i/s_axi_rresp
add wave -noupdate -group AXI /top_wrapper_tb/top_i/aggregation_engine_i/s_axi_rvalid
add wave -noupdate -group AXI /top_wrapper_tb/top_i/aggregation_engine_i/s_axi_rready
add wave -noupdate -group AXI /top_wrapper_tb/top_i/aggregation_engine_i/s_axi_bresp
add wave -noupdate -group AXI /top_wrapper_tb/top_i/aggregation_engine_i/s_axi_bvalid
add wave -noupdate -group AXI /top_wrapper_tb/top_i/aggregation_engine_i/s_axi_bready
add wave -noupdate -expand -group NSB-AGE /top_wrapper_tb/top_i/aggregation_engine_i/nsb_age_req_valid
add wave -noupdate -expand -group NSB-AGE /top_wrapper_tb/top_i/aggregation_engine_i/nsb_age_req_ready
add wave -noupdate -expand -group NSB-AGE -expand /top_wrapper_tb/top_i/aggregation_engine_i/nsb_age_req
add wave -noupdate -expand -group NSB-AGE /top_wrapper_tb/top_i/aggregation_engine_i/nsb_age_resp_valid
add wave -noupdate -expand -group NSB-AGE -expand /top_wrapper_tb/top_i/aggregation_engine_i/nsb_age_resp
add wave -noupdate -expand -group Msg-Chan /top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req_valid
add wave -noupdate -expand -group Msg-Chan /top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req_ready
add wave -noupdate -expand -group Msg-Chan -group 0-31 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[31]}
add wave -noupdate -expand -group Msg-Chan -group 0-31 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[30]}
add wave -noupdate -expand -group Msg-Chan -group 0-31 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[29]}
add wave -noupdate -expand -group Msg-Chan -group 0-31 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[28]}
add wave -noupdate -expand -group Msg-Chan -group 0-31 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[27]}
add wave -noupdate -expand -group Msg-Chan -group 0-31 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[26]}
add wave -noupdate -expand -group Msg-Chan -group 0-31 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[25]}
add wave -noupdate -expand -group Msg-Chan -group 0-31 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[24]}
add wave -noupdate -expand -group Msg-Chan -group 0-31 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[23]}
add wave -noupdate -expand -group Msg-Chan -group 0-31 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[22]}
add wave -noupdate -expand -group Msg-Chan -group 0-31 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[21]}
add wave -noupdate -expand -group Msg-Chan -group 0-31 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[20]}
add wave -noupdate -expand -group Msg-Chan -group 0-31 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[19]}
add wave -noupdate -expand -group Msg-Chan -group 0-31 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[18]}
add wave -noupdate -expand -group Msg-Chan -group 0-31 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[17]}
add wave -noupdate -expand -group Msg-Chan -group 0-31 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[16]}
add wave -noupdate -expand -group Msg-Chan -group 0-31 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[15]}
add wave -noupdate -expand -group Msg-Chan -group 0-31 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[14]}
add wave -noupdate -expand -group Msg-Chan -group 0-31 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[13]}
add wave -noupdate -expand -group Msg-Chan -group 0-31 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[12]}
add wave -noupdate -expand -group Msg-Chan -group 0-31 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[11]}
add wave -noupdate -expand -group Msg-Chan -group 0-31 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[10]}
add wave -noupdate -expand -group Msg-Chan -group 0-31 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[9]}
add wave -noupdate -expand -group Msg-Chan -group 0-31 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[8]}
add wave -noupdate -expand -group Msg-Chan -group 0-31 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[7]}
add wave -noupdate -expand -group Msg-Chan -group 0-31 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[6]}
add wave -noupdate -expand -group Msg-Chan -group 0-31 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[5]}
add wave -noupdate -expand -group Msg-Chan -group 0-31 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[4]}
add wave -noupdate -expand -group Msg-Chan -group 0-31 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[3]}
add wave -noupdate -expand -group Msg-Chan -group 0-31 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[2]}
add wave -noupdate -expand -group Msg-Chan -group 0-31 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[1]}
add wave -noupdate -expand -group Msg-Chan -group 0-31 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[0]}
add wave -noupdate -expand -group Msg-Chan -group 32-63 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[63]}
add wave -noupdate -expand -group Msg-Chan -group 32-63 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[62]}
add wave -noupdate -expand -group Msg-Chan -group 32-63 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[61]}
add wave -noupdate -expand -group Msg-Chan -group 32-63 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[60]}
add wave -noupdate -expand -group Msg-Chan -group 32-63 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[59]}
add wave -noupdate -expand -group Msg-Chan -group 32-63 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[58]}
add wave -noupdate -expand -group Msg-Chan -group 32-63 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[57]}
add wave -noupdate -expand -group Msg-Chan -group 32-63 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[56]}
add wave -noupdate -expand -group Msg-Chan -group 32-63 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[55]}
add wave -noupdate -expand -group Msg-Chan -group 32-63 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[54]}
add wave -noupdate -expand -group Msg-Chan -group 32-63 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[53]}
add wave -noupdate -expand -group Msg-Chan -group 32-63 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[52]}
add wave -noupdate -expand -group Msg-Chan -group 32-63 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[51]}
add wave -noupdate -expand -group Msg-Chan -group 32-63 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[50]}
add wave -noupdate -expand -group Msg-Chan -group 32-63 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[49]}
add wave -noupdate -expand -group Msg-Chan -group 32-63 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[48]}
add wave -noupdate -expand -group Msg-Chan -group 32-63 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[47]}
add wave -noupdate -expand -group Msg-Chan -group 32-63 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[46]}
add wave -noupdate -expand -group Msg-Chan -group 32-63 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[45]}
add wave -noupdate -expand -group Msg-Chan -group 32-63 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[44]}
add wave -noupdate -expand -group Msg-Chan -group 32-63 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[43]}
add wave -noupdate -expand -group Msg-Chan -group 32-63 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[42]}
add wave -noupdate -expand -group Msg-Chan -group 32-63 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[41]}
add wave -noupdate -expand -group Msg-Chan -group 32-63 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[40]}
add wave -noupdate -expand -group Msg-Chan -group 32-63 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[39]}
add wave -noupdate -expand -group Msg-Chan -group 32-63 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[38]}
add wave -noupdate -expand -group Msg-Chan -group 32-63 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[37]}
add wave -noupdate -expand -group Msg-Chan -group 32-63 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[36]}
add wave -noupdate -expand -group Msg-Chan -group 32-63 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[35]}
add wave -noupdate -expand -group Msg-Chan -group 32-63 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[34]}
add wave -noupdate -expand -group Msg-Chan -group 32-63 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[33]}
add wave -noupdate -expand -group Msg-Chan -group 32-63 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[32]}
add wave -noupdate -expand -group Msg-Chan -group 64-95 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[95]}
add wave -noupdate -expand -group Msg-Chan -group 64-95 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[94]}
add wave -noupdate -expand -group Msg-Chan -group 64-95 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[93]}
add wave -noupdate -expand -group Msg-Chan -group 64-95 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[92]}
add wave -noupdate -expand -group Msg-Chan -group 64-95 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[91]}
add wave -noupdate -expand -group Msg-Chan -group 64-95 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[90]}
add wave -noupdate -expand -group Msg-Chan -group 64-95 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[89]}
add wave -noupdate -expand -group Msg-Chan -group 64-95 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[88]}
add wave -noupdate -expand -group Msg-Chan -group 64-95 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[87]}
add wave -noupdate -expand -group Msg-Chan -group 64-95 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[86]}
add wave -noupdate -expand -group Msg-Chan -group 64-95 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[85]}
add wave -noupdate -expand -group Msg-Chan -group 64-95 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[84]}
add wave -noupdate -expand -group Msg-Chan -group 64-95 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[83]}
add wave -noupdate -expand -group Msg-Chan -group 64-95 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[82]}
add wave -noupdate -expand -group Msg-Chan -group 64-95 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[81]}
add wave -noupdate -expand -group Msg-Chan -group 64-95 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[80]}
add wave -noupdate -expand -group Msg-Chan -group 64-95 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[79]}
add wave -noupdate -expand -group Msg-Chan -group 64-95 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[78]}
add wave -noupdate -expand -group Msg-Chan -group 64-95 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[77]}
add wave -noupdate -expand -group Msg-Chan -group 64-95 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[76]}
add wave -noupdate -expand -group Msg-Chan -group 64-95 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[75]}
add wave -noupdate -expand -group Msg-Chan -group 64-95 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[74]}
add wave -noupdate -expand -group Msg-Chan -group 64-95 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[73]}
add wave -noupdate -expand -group Msg-Chan -group 64-95 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[72]}
add wave -noupdate -expand -group Msg-Chan -group 64-95 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[71]}
add wave -noupdate -expand -group Msg-Chan -group 64-95 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[70]}
add wave -noupdate -expand -group Msg-Chan -group 64-95 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[69]}
add wave -noupdate -expand -group Msg-Chan -group 64-95 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[68]}
add wave -noupdate -expand -group Msg-Chan -group 64-95 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[67]}
add wave -noupdate -expand -group Msg-Chan -group 64-95 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[66]}
add wave -noupdate -expand -group Msg-Chan -group 64-95 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[65]}
add wave -noupdate -expand -group Msg-Chan -group 64-95 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[64]}
add wave -noupdate -expand -group Msg-Chan -group 96-127 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[127]}
add wave -noupdate -expand -group Msg-Chan -group 96-127 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[126]}
add wave -noupdate -expand -group Msg-Chan -group 96-127 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[125]}
add wave -noupdate -expand -group Msg-Chan -group 96-127 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[124]}
add wave -noupdate -expand -group Msg-Chan -group 96-127 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[123]}
add wave -noupdate -expand -group Msg-Chan -group 96-127 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[122]}
add wave -noupdate -expand -group Msg-Chan -group 96-127 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[121]}
add wave -noupdate -expand -group Msg-Chan -group 96-127 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[120]}
add wave -noupdate -expand -group Msg-Chan -group 96-127 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[119]}
add wave -noupdate -expand -group Msg-Chan -group 96-127 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[118]}
add wave -noupdate -expand -group Msg-Chan -group 96-127 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[117]}
add wave -noupdate -expand -group Msg-Chan -group 96-127 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[116]}
add wave -noupdate -expand -group Msg-Chan -group 96-127 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[115]}
add wave -noupdate -expand -group Msg-Chan -group 96-127 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[114]}
add wave -noupdate -expand -group Msg-Chan -group 96-127 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[113]}
add wave -noupdate -expand -group Msg-Chan -group 96-127 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[112]}
add wave -noupdate -expand -group Msg-Chan -group 96-127 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[111]}
add wave -noupdate -expand -group Msg-Chan -group 96-127 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[110]}
add wave -noupdate -expand -group Msg-Chan -group 96-127 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[109]}
add wave -noupdate -expand -group Msg-Chan -group 96-127 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[108]}
add wave -noupdate -expand -group Msg-Chan -group 96-127 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[107]}
add wave -noupdate -expand -group Msg-Chan -group 96-127 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[106]}
add wave -noupdate -expand -group Msg-Chan -group 96-127 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[105]}
add wave -noupdate -expand -group Msg-Chan -group 96-127 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[104]}
add wave -noupdate -expand -group Msg-Chan -group 96-127 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[103]}
add wave -noupdate -expand -group Msg-Chan -group 96-127 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[102]}
add wave -noupdate -expand -group Msg-Chan -group 96-127 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[101]}
add wave -noupdate -expand -group Msg-Chan -group 96-127 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[100]}
add wave -noupdate -expand -group Msg-Chan -group 96-127 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[99]}
add wave -noupdate -expand -group Msg-Chan -group 96-127 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[98]}
add wave -noupdate -expand -group Msg-Chan -group 96-127 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[97]}
add wave -noupdate -expand -group Msg-Chan -group 96-127 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[96]}
add wave -noupdate -expand -group Msg-Chan -group 128-159 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[159]}
add wave -noupdate -expand -group Msg-Chan -group 128-159 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[158]}
add wave -noupdate -expand -group Msg-Chan -group 128-159 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[157]}
add wave -noupdate -expand -group Msg-Chan -group 128-159 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[156]}
add wave -noupdate -expand -group Msg-Chan -group 128-159 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[155]}
add wave -noupdate -expand -group Msg-Chan -group 128-159 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[154]}
add wave -noupdate -expand -group Msg-Chan -group 128-159 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[153]}
add wave -noupdate -expand -group Msg-Chan -group 128-159 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[152]}
add wave -noupdate -expand -group Msg-Chan -group 128-159 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[151]}
add wave -noupdate -expand -group Msg-Chan -group 128-159 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[150]}
add wave -noupdate -expand -group Msg-Chan -group 128-159 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[149]}
add wave -noupdate -expand -group Msg-Chan -group 128-159 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[148]}
add wave -noupdate -expand -group Msg-Chan -group 128-159 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[147]}
add wave -noupdate -expand -group Msg-Chan -group 128-159 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[146]}
add wave -noupdate -expand -group Msg-Chan -group 128-159 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[145]}
add wave -noupdate -expand -group Msg-Chan -group 128-159 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[144]}
add wave -noupdate -expand -group Msg-Chan -group 128-159 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[143]}
add wave -noupdate -expand -group Msg-Chan -group 128-159 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[142]}
add wave -noupdate -expand -group Msg-Chan -group 128-159 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[141]}
add wave -noupdate -expand -group Msg-Chan -group 128-159 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[140]}
add wave -noupdate -expand -group Msg-Chan -group 128-159 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[139]}
add wave -noupdate -expand -group Msg-Chan -group 128-159 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[138]}
add wave -noupdate -expand -group Msg-Chan -group 128-159 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[137]}
add wave -noupdate -expand -group Msg-Chan -group 128-159 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[136]}
add wave -noupdate -expand -group Msg-Chan -group 128-159 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[135]}
add wave -noupdate -expand -group Msg-Chan -group 128-159 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[134]}
add wave -noupdate -expand -group Msg-Chan -group 128-159 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[133]}
add wave -noupdate -expand -group Msg-Chan -group 128-159 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[132]}
add wave -noupdate -expand -group Msg-Chan -group 128-159 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[131]}
add wave -noupdate -expand -group Msg-Chan -group 128-159 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[130]}
add wave -noupdate -expand -group Msg-Chan -group 128-159 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[129]}
add wave -noupdate -expand -group Msg-Chan -group 128-159 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[128]}
add wave -noupdate -expand -group Msg-Chan -group 160-191 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[191]}
add wave -noupdate -expand -group Msg-Chan -group 160-191 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[190]}
add wave -noupdate -expand -group Msg-Chan -group 160-191 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[189]}
add wave -noupdate -expand -group Msg-Chan -group 160-191 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[188]}
add wave -noupdate -expand -group Msg-Chan -group 160-191 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[187]}
add wave -noupdate -expand -group Msg-Chan -group 160-191 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[186]}
add wave -noupdate -expand -group Msg-Chan -group 160-191 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[185]}
add wave -noupdate -expand -group Msg-Chan -group 160-191 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[184]}
add wave -noupdate -expand -group Msg-Chan -group 160-191 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[183]}
add wave -noupdate -expand -group Msg-Chan -group 160-191 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[182]}
add wave -noupdate -expand -group Msg-Chan -group 160-191 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[181]}
add wave -noupdate -expand -group Msg-Chan -group 160-191 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[180]}
add wave -noupdate -expand -group Msg-Chan -group 160-191 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[179]}
add wave -noupdate -expand -group Msg-Chan -group 160-191 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[178]}
add wave -noupdate -expand -group Msg-Chan -group 160-191 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[177]}
add wave -noupdate -expand -group Msg-Chan -group 160-191 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[176]}
add wave -noupdate -expand -group Msg-Chan -group 160-191 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[175]}
add wave -noupdate -expand -group Msg-Chan -group 160-191 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[174]}
add wave -noupdate -expand -group Msg-Chan -group 160-191 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[173]}
add wave -noupdate -expand -group Msg-Chan -group 160-191 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[172]}
add wave -noupdate -expand -group Msg-Chan -group 160-191 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[171]}
add wave -noupdate -expand -group Msg-Chan -group 160-191 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[170]}
add wave -noupdate -expand -group Msg-Chan -group 160-191 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[169]}
add wave -noupdate -expand -group Msg-Chan -group 160-191 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[168]}
add wave -noupdate -expand -group Msg-Chan -group 160-191 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[167]}
add wave -noupdate -expand -group Msg-Chan -group 160-191 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[166]}
add wave -noupdate -expand -group Msg-Chan -group 160-191 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[165]}
add wave -noupdate -expand -group Msg-Chan -group 160-191 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[164]}
add wave -noupdate -expand -group Msg-Chan -group 160-191 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[163]}
add wave -noupdate -expand -group Msg-Chan -group 160-191 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[162]}
add wave -noupdate -expand -group Msg-Chan -group 160-191 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[161]}
add wave -noupdate -expand -group Msg-Chan -group 160-191 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[160]}
add wave -noupdate -expand -group Msg-Chan -group 192-223 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[223]}
add wave -noupdate -expand -group Msg-Chan -group 192-223 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[222]}
add wave -noupdate -expand -group Msg-Chan -group 192-223 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[221]}
add wave -noupdate -expand -group Msg-Chan -group 192-223 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[220]}
add wave -noupdate -expand -group Msg-Chan -group 192-223 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[219]}
add wave -noupdate -expand -group Msg-Chan -group 192-223 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[218]}
add wave -noupdate -expand -group Msg-Chan -group 192-223 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[217]}
add wave -noupdate -expand -group Msg-Chan -group 192-223 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[216]}
add wave -noupdate -expand -group Msg-Chan -group 192-223 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[215]}
add wave -noupdate -expand -group Msg-Chan -group 192-223 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[214]}
add wave -noupdate -expand -group Msg-Chan -group 192-223 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[213]}
add wave -noupdate -expand -group Msg-Chan -group 192-223 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[212]}
add wave -noupdate -expand -group Msg-Chan -group 192-223 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[211]}
add wave -noupdate -expand -group Msg-Chan -group 192-223 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[210]}
add wave -noupdate -expand -group Msg-Chan -group 192-223 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[209]}
add wave -noupdate -expand -group Msg-Chan -group 192-223 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[208]}
add wave -noupdate -expand -group Msg-Chan -group 192-223 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[207]}
add wave -noupdate -expand -group Msg-Chan -group 192-223 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[206]}
add wave -noupdate -expand -group Msg-Chan -group 192-223 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[205]}
add wave -noupdate -expand -group Msg-Chan -group 192-223 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[204]}
add wave -noupdate -expand -group Msg-Chan -group 192-223 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[203]}
add wave -noupdate -expand -group Msg-Chan -group 192-223 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[202]}
add wave -noupdate -expand -group Msg-Chan -group 192-223 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[201]}
add wave -noupdate -expand -group Msg-Chan -group 192-223 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[200]}
add wave -noupdate -expand -group Msg-Chan -group 192-223 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[199]}
add wave -noupdate -expand -group Msg-Chan -group 192-223 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[198]}
add wave -noupdate -expand -group Msg-Chan -group 192-223 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[197]}
add wave -noupdate -expand -group Msg-Chan -group 192-223 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[196]}
add wave -noupdate -expand -group Msg-Chan -group 192-223 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[195]}
add wave -noupdate -expand -group Msg-Chan -group 192-223 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[194]}
add wave -noupdate -expand -group Msg-Chan -group 192-223 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[193]}
add wave -noupdate -expand -group Msg-Chan -group 192-223 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[192]}
add wave -noupdate -expand -group Msg-Chan -group 224-255 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[255]}
add wave -noupdate -expand -group Msg-Chan -group 224-255 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[254]}
add wave -noupdate -expand -group Msg-Chan -group 224-255 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[253]}
add wave -noupdate -expand -group Msg-Chan -group 224-255 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[252]}
add wave -noupdate -expand -group Msg-Chan -group 224-255 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[251]}
add wave -noupdate -expand -group Msg-Chan -group 224-255 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[250]}
add wave -noupdate -expand -group Msg-Chan -group 224-255 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[249]}
add wave -noupdate -expand -group Msg-Chan -group 224-255 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[248]}
add wave -noupdate -expand -group Msg-Chan -group 224-255 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[247]}
add wave -noupdate -expand -group Msg-Chan -group 224-255 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[246]}
add wave -noupdate -expand -group Msg-Chan -group 224-255 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[245]}
add wave -noupdate -expand -group Msg-Chan -group 224-255 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[244]}
add wave -noupdate -expand -group Msg-Chan -group 224-255 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[243]}
add wave -noupdate -expand -group Msg-Chan -group 224-255 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[242]}
add wave -noupdate -expand -group Msg-Chan -group 224-255 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[241]}
add wave -noupdate -expand -group Msg-Chan -group 224-255 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[240]}
add wave -noupdate -expand -group Msg-Chan -group 224-255 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[239]}
add wave -noupdate -expand -group Msg-Chan -group 224-255 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[238]}
add wave -noupdate -expand -group Msg-Chan -group 224-255 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[237]}
add wave -noupdate -expand -group Msg-Chan -group 224-255 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[236]}
add wave -noupdate -expand -group Msg-Chan -group 224-255 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[235]}
add wave -noupdate -expand -group Msg-Chan -group 224-255 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[234]}
add wave -noupdate -expand -group Msg-Chan -group 224-255 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[233]}
add wave -noupdate -expand -group Msg-Chan -group 224-255 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[232]}
add wave -noupdate -expand -group Msg-Chan -group 224-255 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[231]}
add wave -noupdate -expand -group Msg-Chan -group 224-255 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[230]}
add wave -noupdate -expand -group Msg-Chan -group 224-255 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[229]}
add wave -noupdate -expand -group Msg-Chan -group 224-255 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[228]}
add wave -noupdate -expand -group Msg-Chan -group 224-255 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[227]}
add wave -noupdate -expand -group Msg-Chan -group 224-255 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[226]}
add wave -noupdate -expand -group Msg-Chan -group 224-255 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[225]}
add wave -noupdate -expand -group Msg-Chan -group 224-255 {/top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req[224]}
add wave -noupdate -expand -group Msg-Chan /top_wrapper_tb/top_i/aggregation_engine_i/message_channel_resp
add wave -noupdate -expand -group Msg-Chan /top_wrapper_tb/top_i/aggregation_engine_i/message_channel_resp_valid
add wave -noupdate -expand -group Msg-Chan /top_wrapper_tb/top_i/aggregation_engine_i/message_channel_resp_ready
add wave -noupdate -expand -group Agg-BuffSlot /top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_write_enable
add wave -noupdate -expand -group Agg-BuffSlot /top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_write_address
add wave -noupdate -expand -group Agg-BuffSlot -expand /top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_feature_count
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-Free -label 0-7 -group Agg-BuffSlot-NodeID {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_slot_free[0][7]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-Free -label 0-7 -group Agg-BuffSlot-NodeID {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_slot_free[0][6]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-Free -label 0-7 -group Agg-BuffSlot-NodeID {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_slot_free[0][5]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-Free -label 0-7 -group Agg-BuffSlot-NodeID {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_slot_free[0][4]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-Free -label 0-7 -group Agg-BuffSlot-NodeID {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_slot_free[0][3]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-Free -label 0-7 -group Agg-BuffSlot-NodeID {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_slot_free[0][2]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-Free -label 0-7 -group Agg-BuffSlot-NodeID {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_slot_free[0][1]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-Free -label 0-7 -group Agg-BuffSlot-NodeID {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_slot_free[0][0]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-Free -label 0-7 -group Agg-BuffSlot-NodeID {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_slot_free[0][15]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-Free -label 0-7 -group Agg-BuffSlot-NodeID {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_slot_free[0][14]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-Free -label 0-7 -group Agg-BuffSlot-NodeID {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_slot_free[0][13]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-Free -label 0-7 -group Agg-BuffSlot-NodeID {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_slot_free[0][12]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-Free -label 0-7 -group Agg-BuffSlot-NodeID {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_slot_free[0][11]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-Free -label 0-7 -group Agg-BuffSlot-NodeID {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_slot_free[0][10]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-Free -label 0-7 -group Agg-BuffSlot-NodeID {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_slot_free[0][9]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-Free -label 0-7 -group Agg-BuffSlot-NodeID {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_slot_free[0][8]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-Free -label 0-7 -group Agg-BuffSlot-NodeID {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_slot_free[0][23]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-Free -label 0-7 -group Agg-BuffSlot-NodeID {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_slot_free[0][22]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-Free -label 0-7 -group Agg-BuffSlot-NodeID {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_slot_free[0][21]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-Free -label 0-7 -group Agg-BuffSlot-NodeID {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_slot_free[0][20]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-Free -label 0-7 -group Agg-BuffSlot-NodeID {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_slot_free[0][19]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-Free -label 0-7 -group Agg-BuffSlot-NodeID {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_slot_free[0][18]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-Free -label 0-7 -group Agg-BuffSlot-NodeID {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_slot_free[0][17]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-Free -label 0-7 -group Agg-BuffSlot-NodeID {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_slot_free[0][16]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-Free -label 0-7 -group Agg-BuffSlot-NodeID {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_slot_free[0][31]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-Free -label 0-7 -group Agg-BuffSlot-NodeID {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_slot_free[0][30]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-Free -label 0-7 -group Agg-BuffSlot-NodeID {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_slot_free[0][29]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-Free -label 0-7 -group Agg-BuffSlot-NodeID {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_slot_free[0][28]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-Free -label 0-7 -group Agg-BuffSlot-NodeID {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_slot_free[0][27]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-Free -label 0-7 -group Agg-BuffSlot-NodeID {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_slot_free[0][26]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-Free -label 0-7 -group Agg-BuffSlot-NodeID {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_slot_free[0][25]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-Free -label 0-7 -group Agg-BuffSlot-NodeID {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_slot_free[0][24]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-Free -label 0-7 -group Agg-BuffSlot-NodeID {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_slot_free[0][47]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-Free -label 0-7 -group Agg-BuffSlot-NodeID {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_slot_free[0][46]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-Free -label 0-7 -group Agg-BuffSlot-NodeID {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_slot_free[0][45]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-Free -label 0-7 -group Agg-BuffSlot-NodeID {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_slot_free[0][44]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-Free -label 0-7 -group Agg-BuffSlot-NodeID {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_slot_free[0][43]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-Free -label 0-7 -group Agg-BuffSlot-NodeID {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_slot_free[0][42]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-Free -label 0-7 -group Agg-BuffSlot-NodeID {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_slot_free[0][41]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-Free -label 0-7 -group Agg-BuffSlot-NodeID {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_slot_free[0][40]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-Free -label 0-7 -group Agg-BuffSlot-NodeID {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_slot_free[0][55]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-Free -label 0-7 -group Agg-BuffSlot-NodeID {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_slot_free[0][54]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-Free -label 0-7 -group Agg-BuffSlot-NodeID {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_slot_free[0][53]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-Free -label 0-7 -group Agg-BuffSlot-NodeID {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_slot_free[0][52]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-Free -label 0-7 -group Agg-BuffSlot-NodeID {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_slot_free[0][51]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-Free -label 0-7 -group Agg-BuffSlot-NodeID {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_slot_free[0][50]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-Free -label 0-7 -group Agg-BuffSlot-NodeID {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_slot_free[0][49]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-Free -label 0-7 -group Agg-BuffSlot-NodeID {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_slot_free[0][48]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-Free -label 0-7 -group Agg-BuffSlot-NodeID {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_slot_free[0][63]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-Free -label 0-7 -group Agg-BuffSlot-NodeID {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_slot_free[0][62]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-Free -label 0-7 -group Agg-BuffSlot-NodeID {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_slot_free[0][61]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-Free -label 0-7 -group Agg-BuffSlot-NodeID {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_slot_free[0][60]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-Free -label 0-7 -group Agg-BuffSlot-NodeID {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_slot_free[0][59]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-Free -label 0-7 -group Agg-BuffSlot-NodeID {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_slot_free[0][58]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-Free -label 0-7 -group Agg-BuffSlot-NodeID {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_slot_free[0][57]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-Free -label 0-7 -group Agg-BuffSlot-NodeID {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_slot_free[0][56]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-Free -group 32-39 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_slot_free[0][39]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-Free -group 32-39 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_slot_free[0][38]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-Free -group 32-39 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_slot_free[0][37]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-Free -group 32-39 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_slot_free[0][36]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-Free -group 32-39 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_slot_free[0][35]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-Free -group 32-39 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_slot_free[0][34]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-Free -group 32-39 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_slot_free[0][33]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-Free -group 32-39 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_slot_free[0][32]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-NodeID -group 0-7 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_set_node_id[0][7]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-NodeID -group 0-7 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_set_node_id[0][6]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-NodeID -group 0-7 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_set_node_id[0][5]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-NodeID -group 0-7 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_set_node_id[0][4]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-NodeID -group 0-7 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_set_node_id[0][3]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-NodeID -group 0-7 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_set_node_id[0][2]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-NodeID -group 0-7 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_set_node_id[0][1]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-NodeID -group 0-7 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_set_node_id[0][0]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-NodeID -group 8-15 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_set_node_id[0][15]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-NodeID -group 8-15 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_set_node_id[0][14]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-NodeID -group 8-15 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_set_node_id[0][13]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-NodeID -group 8-15 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_set_node_id[0][12]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-NodeID -group 8-15 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_set_node_id[0][11]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-NodeID -group 8-15 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_set_node_id[0][10]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-NodeID -group 8-15 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_set_node_id[0][9]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-NodeID -group 8-15 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_set_node_id[0][8]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-NodeID -group 16-23 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_set_node_id[0][23]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-NodeID -group 16-23 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_set_node_id[0][22]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-NodeID -group 16-23 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_set_node_id[0][21]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-NodeID -group 16-23 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_set_node_id[0][20]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-NodeID -group 16-23 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_set_node_id[0][19]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-NodeID -group 16-23 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_set_node_id[0][18]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-NodeID -group 16-23 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_set_node_id[0][17]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-NodeID -group 16-23 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_set_node_id[0][16]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-NodeID -group 24-31 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_set_node_id[0][31]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-NodeID -group 24-31 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_set_node_id[0][30]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-NodeID -group 24-31 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_set_node_id[0][29]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-NodeID -group 24-31 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_set_node_id[0][28]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-NodeID -group 24-31 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_set_node_id[0][27]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-NodeID -group 24-31 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_set_node_id[0][26]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-NodeID -group 24-31 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_set_node_id[0][25]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-NodeID -group 24-31 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_set_node_id[0][24]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-NodeID -group 32-29 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_set_node_id[0][39]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-NodeID -group 32-29 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_set_node_id[0][38]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-NodeID -group 32-29 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_set_node_id[0][37]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-NodeID -group 32-29 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_set_node_id[0][36]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-NodeID -group 32-29 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_set_node_id[0][35]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-NodeID -group 32-29 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_set_node_id[0][34]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-NodeID -group 32-29 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_set_node_id[0][33]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-NodeID -group 32-29 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_set_node_id[0][32]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-NodeID -group 40-47 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_set_node_id[0][47]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-NodeID -group 40-47 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_set_node_id[0][46]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-NodeID -group 40-47 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_set_node_id[0][45]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-NodeID -group 40-47 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_set_node_id[0][44]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-NodeID -group 40-47 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_set_node_id[0][43]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-NodeID -group 40-47 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_set_node_id[0][42]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-NodeID -group 40-47 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_set_node_id[0][41]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-NodeID -group 40-47 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_set_node_id[0][40]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-NodeID -group 48-55 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_set_node_id[0][55]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-NodeID -group 48-55 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_set_node_id[0][54]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-NodeID -group 48-55 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_set_node_id[0][53]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-NodeID -group 48-55 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_set_node_id[0][52]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-NodeID -group 48-55 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_set_node_id[0][51]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-NodeID -group 48-55 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_set_node_id[0][50]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-NodeID -group 48-55 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_set_node_id[0][49]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-NodeID -group 48-55 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_set_node_id[0][48]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-NodeID -group 56-63 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_set_node_id_valid[0][63]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-NodeID -group 56-63 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_set_node_id_valid[0][62]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-NodeID -group 56-63 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_set_node_id_valid[0][61]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-NodeID -group 56-63 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_set_node_id_valid[0][60]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-NodeID -group 56-63 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_set_node_id_valid[0][59]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-NodeID -group 56-63 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_set_node_id_valid[0][58]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-NodeID -group 56-63 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_set_node_id_valid[0][56]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-NodeID -group 56-63 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_set_node_id_valid[0][57]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-NodeID -group 56-63 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_set_node_id[0][63]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-NodeID -group 56-63 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_set_node_id[0][62]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-NodeID -group 56-63 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_set_node_id[0][61]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-NodeID -group 56-63 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_set_node_id[0][60]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-NodeID -group 56-63 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_set_node_id[0][59]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-NodeID -group 56-63 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_set_node_id[0][58]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-NodeID -group 56-63 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_set_node_id[0][57]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-NodeID -group 56-63 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_set_node_id[0][56]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-NodeID-Valid -group 0-7 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_set_node_id_valid[0][7]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-NodeID-Valid -group 0-7 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_set_node_id_valid[0][6]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-NodeID-Valid -group 0-7 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_set_node_id_valid[0][5]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-NodeID-Valid -group 0-7 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_set_node_id_valid[0][4]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-NodeID-Valid -group 0-7 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_set_node_id_valid[0][3]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-NodeID-Valid -group 0-7 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_set_node_id_valid[0][2]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-NodeID-Valid -group 0-7 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_set_node_id_valid[0][1]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-NodeID-Valid -group 0-7 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_set_node_id_valid[0][0]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-NodeID-Valid -group 48-55 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_set_node_id_valid[0][55]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-NodeID-Valid -group 48-55 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_set_node_id_valid[0][54]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-NodeID-Valid -group 48-55 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_set_node_id_valid[0][53]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-NodeID-Valid -group 48-55 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_set_node_id_valid[0][52]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-NodeID-Valid -group 48-55 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_set_node_id_valid[0][51]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-NodeID-Valid -group 48-55 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_set_node_id_valid[0][50]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-NodeID-Valid -group 48-55 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_set_node_id_valid[0][49]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-NodeID-Valid -group 48-55 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_set_node_id_valid[0][48]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-NodeID-Valid -group 40-47 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_set_node_id_valid[0][47]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-NodeID-Valid -group 40-47 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_set_node_id_valid[0][46]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-NodeID-Valid -group 40-47 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_set_node_id_valid[0][45]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-NodeID-Valid -group 40-47 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_set_node_id_valid[0][44]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-NodeID-Valid -group 40-47 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_set_node_id_valid[0][43]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-NodeID-Valid -group 40-47 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_set_node_id_valid[0][42]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-NodeID-Valid -group 40-47 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_set_node_id_valid[0][41]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-NodeID-Valid -group 40-47 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_set_node_id_valid[0][40]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-NodeID-Valid -group 32-39 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_set_node_id_valid[0][39]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-NodeID-Valid -group 32-39 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_set_node_id_valid[0][38]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-NodeID-Valid -group 32-39 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_set_node_id_valid[0][37]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-NodeID-Valid -group 32-39 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_set_node_id_valid[0][36]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-NodeID-Valid -group 32-39 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_set_node_id_valid[0][35]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-NodeID-Valid -group 32-39 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_set_node_id_valid[0][34]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-NodeID-Valid -group 32-39 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_set_node_id_valid[0][33]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-NodeID-Valid -group 32-39 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_set_node_id_valid[0][32]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-NodeID-Valid -group 24-31 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_set_node_id_valid[0][31]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-NodeID-Valid -group 24-31 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_set_node_id_valid[0][30]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-NodeID-Valid -group 24-31 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_set_node_id_valid[0][29]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-NodeID-Valid -group 24-31 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_set_node_id_valid[0][28]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-NodeID-Valid -group 24-31 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_set_node_id_valid[0][27]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-NodeID-Valid -group 24-31 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_set_node_id_valid[0][26]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-NodeID-Valid -group 24-31 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_set_node_id_valid[0][25]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-NodeID-Valid -group 24-31 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_set_node_id_valid[0][24]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-NodeID-Valid -group 16-23 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_set_node_id_valid[0][23]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-NodeID-Valid -group 16-23 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_set_node_id_valid[0][22]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-NodeID-Valid -group 16-23 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_set_node_id_valid[0][21]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-NodeID-Valid -group 16-23 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_set_node_id_valid[0][20]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-NodeID-Valid -group 16-23 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_set_node_id_valid[0][19]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-NodeID-Valid -group 16-23 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_set_node_id_valid[0][18]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-NodeID-Valid -group 16-23 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_set_node_id_valid[0][17]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-NodeID-Valid -group 16-23 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_set_node_id_valid[0][16]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-NodeID-Valid -group 8-15 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_set_node_id_valid[0][15]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-NodeID-Valid -group 8-15 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_set_node_id_valid[0][14]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-NodeID-Valid -group 8-15 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_set_node_id_valid[0][13]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-NodeID-Valid -group 8-15 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_set_node_id_valid[0][12]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-NodeID-Valid -group 8-15 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_set_node_id_valid[0][11]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-NodeID-Valid -group 8-15 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_set_node_id_valid[0][10]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-NodeID-Valid -group 8-15 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_set_node_id_valid[0][9]}
add wave -noupdate -expand -group Agg-BuffSlot -group Agg-BuffSlot-NodeID-Valid -group 8-15 {/top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_set_node_id_valid[0][8]}
add wave -noupdate -group Scale /top_wrapper_tb/top_i/aggregation_engine_i/scale_factor_queue_pop
add wave -noupdate -group Scale /top_wrapper_tb/top_i/aggregation_engine_i/scale_factor_queue_out_valid
add wave -noupdate -group Layer-config /top_wrapper_tb/top_i/aggregation_engine_i/layer_config_in_features_strobe
add wave -noupdate -group Layer-config /top_wrapper_tb/top_i/aggregation_engine_i/layer_config_in_features_count
add wave -noupdate -group Layer-config /top_wrapper_tb/top_i/aggregation_engine_i/layer_config_out_features_strobe
add wave -noupdate -group Layer-config /top_wrapper_tb/top_i/aggregation_engine_i/layer_config_out_features_count
add wave -noupdate -group Layer-config /top_wrapper_tb/top_i/aggregation_engine_i/layer_config_upsampling_parameter_strobe
add wave -noupdate -group Layer-config /top_wrapper_tb/top_i/aggregation_engine_i/layer_config_upsampling_parameter_value
add wave -noupdate /top_wrapper_tb/top_i/aggregation_engine_i/aggregation_req_valid
add wave -noupdate /top_wrapper_tb/top_i/aggregation_engine_i/aggregation_req_ready
add wave -noupdate /top_wrapper_tb/top_i/aggregation_engine_i/aggregation_req
add wave -noupdate -group AGM /top_wrapper_tb/top_i/aggregation_engine_i/aggregation_manager_done_valid
add wave -noupdate -group AGM /top_wrapper_tb/top_i/aggregation_engine_i/aggregation_manager_done_nodeslot
add wave -noupdate -group AGM /top_wrapper_tb/top_i/aggregation_engine_i/aggregation_manager_done_ready
add wave -noupdate -group AGM /top_wrapper_tb/top_i/aggregation_engine_i/agm_nodeslot
add wave -noupdate -group AGM /top_wrapper_tb/top_i/aggregation_engine_i/aggregation_manager_resp_arbitration_oh
add wave -noupdate -group AGM /top_wrapper_tb/top_i/aggregation_engine_i/aggregation_manager_resp_arbitration_bin
add wave -noupdate -expand -group BM /top_wrapper_tb/top_i/aggregation_engine_i/bm_set_node_id_valid
add wave -noupdate -expand -group BM /top_wrapper_tb/top_i/aggregation_engine_i/bm_set_node_id_ready
add wave -noupdate -expand -group BM /top_wrapper_tb/top_i/aggregation_engine_i/bm_set_node_id
add wave -noupdate -expand -group BM /top_wrapper_tb/top_i/aggregation_engine_i/bm_write_enable
add wave -noupdate -expand -group BM /top_wrapper_tb/top_i/aggregation_engine_i/bm_write_ready
add wave -noupdate -expand -group BM /top_wrapper_tb/top_i/aggregation_engine_i/bm_write_address
add wave -noupdate -expand -group BM /top_wrapper_tb/top_i/aggregation_engine_i/buffer_manager_done
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {18625242 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 305
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
WaveRestoreZoom {0 ps} {51702001 ps}
bookmark add wave bookmark4 {{17959609 ps} {22111537 ps}} 0
bookmark add wave bookmark5 {{18551117 ps} {18990769 ps}} 0
