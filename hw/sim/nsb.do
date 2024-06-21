onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /top_wrapper_tb/top_i/node_scoreboard_i/AXIL_ADDR_WIDTH
add wave -noupdate /top_wrapper_tb/top_i/node_scoreboard_i/NODESLOT_COUNT
add wave -noupdate /top_wrapper_tb/top_i/node_scoreboard_i/AXI_ADDRESS_MSB_BITS
add wave -noupdate /top_wrapper_tb/top_i/node_scoreboard_i/core_clk
add wave -noupdate /top_wrapper_tb/top_i/node_scoreboard_i/resetn
add wave -noupdate /top_wrapper_tb/top_i/node_scoreboard_i/regbank_clk
add wave -noupdate /top_wrapper_tb/top_i/node_scoreboard_i/regbank_resetn
add wave -noupdate -group AXI-L /top_wrapper_tb/top_i/node_scoreboard_i/s_axi_awaddr
add wave -noupdate -group AXI-L /top_wrapper_tb/top_i/node_scoreboard_i/s_axi_awprot
add wave -noupdate -group AXI-L /top_wrapper_tb/top_i/node_scoreboard_i/s_axi_awvalid
add wave -noupdate -group AXI-L /top_wrapper_tb/top_i/node_scoreboard_i/s_axi_awready
add wave -noupdate -group AXI-L /top_wrapper_tb/top_i/node_scoreboard_i/s_axi_wdata
add wave -noupdate -group AXI-L /top_wrapper_tb/top_i/node_scoreboard_i/s_axi_wstrb
add wave -noupdate -group AXI-L /top_wrapper_tb/top_i/node_scoreboard_i/s_axi_wvalid
add wave -noupdate -group AXI-L /top_wrapper_tb/top_i/node_scoreboard_i/s_axi_wready
add wave -noupdate -group AXI-L /top_wrapper_tb/top_i/node_scoreboard_i/s_axi_araddr
add wave -noupdate -group AXI-L /top_wrapper_tb/top_i/node_scoreboard_i/s_axi_arprot
add wave -noupdate -group AXI-L /top_wrapper_tb/top_i/node_scoreboard_i/s_axi_arvalid
add wave -noupdate -group AXI-L /top_wrapper_tb/top_i/node_scoreboard_i/s_axi_arready
add wave -noupdate -group AXI-L /top_wrapper_tb/top_i/node_scoreboard_i/s_axi_rdata
add wave -noupdate -group AXI-L /top_wrapper_tb/top_i/node_scoreboard_i/s_axi_rresp
add wave -noupdate -group AXI-L /top_wrapper_tb/top_i/node_scoreboard_i/s_axi_rvalid
add wave -noupdate -group AXI-L /top_wrapper_tb/top_i/node_scoreboard_i/s_axi_rready
add wave -noupdate -group AXI-L /top_wrapper_tb/top_i/node_scoreboard_i/s_axi_bresp
add wave -noupdate -group AXI-L /top_wrapper_tb/top_i/node_scoreboard_i/s_axi_bvalid
add wave -noupdate -group AXI-L /top_wrapper_tb/top_i/node_scoreboard_i/s_axi_bready
add wave -noupdate -group NSB_AGE /top_wrapper_tb/top_i/node_scoreboard_i/nsb_age_req_valid
add wave -noupdate -group NSB_AGE /top_wrapper_tb/top_i/node_scoreboard_i/nsb_age_req_ready
add wave -noupdate -group NSB_AGE /top_wrapper_tb/top_i/node_scoreboard_i/nsb_age_req
add wave -noupdate -group NSB_AGE /top_wrapper_tb/top_i/node_scoreboard_i/nsb_age_resp_valid
add wave -noupdate -group NSB_AGE /top_wrapper_tb/top_i/node_scoreboard_i/nsb_age_resp
add wave -noupdate -group NSB_FTE /top_wrapper_tb/top_i/node_scoreboard_i/nsb_fte_req_valid
add wave -noupdate -group NSB_FTE /top_wrapper_tb/top_i/node_scoreboard_i/nsb_fte_req_ready
add wave -noupdate -group NSB_FTE /top_wrapper_tb/top_i/node_scoreboard_i/nsb_fte_req
add wave -noupdate -group NSB_FTE /top_wrapper_tb/top_i/node_scoreboard_i/nsb_fte_resp_valid
add wave -noupdate -group NSB_FTE /top_wrapper_tb/top_i/node_scoreboard_i/nsb_fte_resp
add wave -noupdate -group NSB_PREF /top_wrapper_tb/top_i/node_scoreboard_i/nsb_prefetcher_req_valid
add wave -noupdate -group NSB_PREF /top_wrapper_tb/top_i/node_scoreboard_i/nsb_prefetcher_req_ready
add wave -noupdate -group NSB_PREF /top_wrapper_tb/top_i/node_scoreboard_i/nsb_prefetcher_req
add wave -noupdate -group NSB_PREF /top_wrapper_tb/top_i/node_scoreboard_i/nsb_prefetcher_resp_valid
add wave -noupdate -group NSB_PREF /top_wrapper_tb/top_i/node_scoreboard_i/nsb_prefetcher_resp
add wave -noupdate -group CTRL /top_wrapper_tb/top_i/node_scoreboard_i/ctrl_start_nodeslot_fetch_value
add wave -noupdate -group CTRL /top_wrapper_tb/top_i/node_scoreboard_i/ctrl_fetch_layer_weights_strobe
add wave -noupdate -group CTRL /top_wrapper_tb/top_i/node_scoreboard_i/ctrl_fetch_layer_weights_fetch
add wave -noupdate -group CTRL /top_wrapper_tb/top_i/node_scoreboard_i/ctrl_fetch_layer_weights_precision_strobe
add wave -noupdate -group CTRL /top_wrapper_tb/top_i/node_scoreboard_i/ctrl_fetch_layer_weights_precision_value
add wave -noupdate -group CTRL /top_wrapper_tb/top_i/node_scoreboard_i/ctrl_fetch_layer_weights_done_strobe
add wave -noupdate -group CTRL /top_wrapper_tb/top_i/node_scoreboard_i/ctrl_fetch_layer_weights_done_done
add wave -noupdate -group CTRL /top_wrapper_tb/top_i/node_scoreboard_i/ctrl_fetch_layer_weights_done_ack_strobe
add wave -noupdate -group CTRL /top_wrapper_tb/top_i/node_scoreboard_i/ctrl_fetch_layer_weights_done_ack_ack
add wave -noupdate -group CTRL /top_wrapper_tb/top_i/node_scoreboard_i/ctrl_start_nodeslot_fetch_strobe
add wave -noupdate -group CTRL /top_wrapper_tb/top_i/node_scoreboard_i/ctrl_start_nodeslot_fetch_done_strobe
add wave -noupdate -group CTRL /top_wrapper_tb/top_i/node_scoreboard_i/ctrl_start_nodeslot_fetch_done_ack_strobe
add wave -noupdate -group CTRL /top_wrapper_tb/top_i/node_scoreboard_i/ctrl_start_nodeslot_fetch_done_value
add wave -noupdate -group CTRL /top_wrapper_tb/top_i/node_scoreboard_i/ctrl_start_nodeslot_fetch_done_ack_value
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 0 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[63]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 0 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[62]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 0 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[61]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 0 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[60]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 0 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[59]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 0 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[58]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 0 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[57]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 0 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[56]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 0 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[55]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 0 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[54]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 0 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[53]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 0 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[52]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 0 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[51]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 0 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[50]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 0 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[49]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 0 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[48]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 0 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[47]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 0 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[46]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 0 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[45]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 0 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[44]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 0 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[43]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 0 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[42]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 0 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[41]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 0 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[40]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 0 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[39]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 0 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[38]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 0 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[37]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 0 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[36]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 0 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[35]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 0 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[34]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 0 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[33]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 0 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[32]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 0 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[31]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 0 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[30]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 0 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[29]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 0 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[28]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 0 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[27]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 0 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[26]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 0 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[25]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 0 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[24]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 0 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[23]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 0 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[22]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 0 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[21]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 0 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[20]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 0 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[19]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 0 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[18]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 0 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[17]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 0 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[16]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 0 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[15]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 0 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[14]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 0 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[13]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 0 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[12]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 0 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[11]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 0 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[10]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 0 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[9]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 0 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[8]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 0 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[7]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 0 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[6]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 0 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[5]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 0 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[4]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 0 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[3]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 0 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[2]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 0 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[1]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 0 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[0]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[128]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[255]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[254]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[253]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[252]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[251]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[250]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[249]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[248]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[247]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[246]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[245]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[244]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[243]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[242]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[241]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[240]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[239]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[238]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[237]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[236]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[235]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[234]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[233]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[232]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[231]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[230]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[229]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[228]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[227]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[226]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[225]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[224]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[223]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[222]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[221]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[220]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[219]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[218]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[217]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[216]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[215]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[214]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[213]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[212]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[211]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[210]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[209]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[208]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[207]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[206]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[205]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[204]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[203]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[202]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[201]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[200]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[199]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[198]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[197]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[196]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[195]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[194]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[193]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[192]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[191]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[190]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[189]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[188]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[187]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[186]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[185]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[184]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[183]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[182]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[181]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[180]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[179]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[178]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[177]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[176]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[175]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[174]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[173]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[172]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[171]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[170]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[169]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[168]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[167]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[166]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[165]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[164]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[163]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[162]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[161]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[160]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[159]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[158]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[157]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[156]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[155]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[154]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[153]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[152]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[151]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[150]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[149]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[148]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[147]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[146]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[145]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[144]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[143]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[142]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[141]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[140]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[139]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[138]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[137]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[136]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[135]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[134]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[133]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[132]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[131]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[130]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[129]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 64 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[127]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 64 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[126]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 64 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[125]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 64 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[124]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 64 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[123]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 64 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[122]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 64 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[121]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 64 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[120]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 64 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[119]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 64 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[118]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 64 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[117]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 64 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[116]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 64 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[115]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 64 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[114]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 64 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[113]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 64 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[112]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 64 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[111]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 64 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[110]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 64 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[109]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 64 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[108]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 64 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[107]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 64 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[106]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 64 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[105]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 64 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[104]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 64 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[103]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 64 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[102]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 64 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[101]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 64 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[100]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 64 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[99]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 64 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[98]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 64 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[97]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 64 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[96]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 64 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[95]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 64 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[94]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 64 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[93]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 64 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[92]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 64 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[91]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 64 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[90]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 64 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[89]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 64 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[88]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 64 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[87]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 64 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[86]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 64 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[85]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 64 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[84]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 64 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[83]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 64 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[82]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 64 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[81]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 64 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[80]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 64 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[79]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 64 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[78]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 64 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[77]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 64 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[76]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 64 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[75]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 64 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[74]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 64 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[73]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 64 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[72]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 64 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[71]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 64 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[70]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 64 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[69]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 64 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[68]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 64 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[67]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 64 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[66]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 64 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[65]}
add wave -noupdate -group NSB_NODESLOT -group Nodeslot_Neighbour_Count -group 64 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count[64]}
add wave -noupdate -group NSB_NODESLOT /top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_id_id
add wave -noupdate -group NSB_NODESLOT /top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_precision_precision
add wave -noupdate -group NSB_NODESLOT /top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_config_make_valid_value
add wave -noupdate -group NSB_NODESLOT /top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count_sw
add wave -noupdate -group NSB_NODESLOT /top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_id_id_sw
add wave -noupdate -group NSB_NODESLOT /top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_precision_precision_sw
add wave -noupdate -group NSB_NODESLOT /top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_config_make_valid_value_sw
add wave -noupdate -group NSB_NODESLOT /top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_strobe_sw
add wave -noupdate -group NSB_NODESLOT /top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_id_strobe_sw
add wave -noupdate -group NSB_NODESLOT /top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_precision_strobe_sw
add wave -noupdate -group NSB_NODESLOT /top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_config_make_valid_strobe_sw
add wave -noupdate -group NSB_NODESLOT /top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state
add wave -noupdate -group NSB_NODESLOT /top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_strobe
add wave -noupdate -group NSB_NODESLOT /top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_aggregation_function_strobe
add wave -noupdate -group NSB_NODESLOT /top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_aggregation_function_value
add wave -noupdate -group NSB_NODESLOT /top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_count_hw
add wave -noupdate -group NSB_NODESLOT /top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_id_id_hw
add wave -noupdate -group NSB_NODESLOT /top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_precision_precision_hw
add wave -noupdate -group NSB_NODESLOT /top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_config_make_valid_value_hw
add wave -noupdate -group NSB_NODESLOT /top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_neighbour_count_strobe_hw
add wave -noupdate -group NSB_NODESLOT /top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_id_strobe_hw
add wave -noupdate -group NSB_NODESLOT /top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_precision_strobe_hw
add wave -noupdate -group NSB_NODESLOT /top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_config_make_valid_strobe_hw
add wave -noupdate -group Status -group PREF /top_wrapper_tb/top_i/node_scoreboard_i/fetch_nb_list_resp_received
add wave -noupdate -group Status -group PREF /top_wrapper_tb/top_i/node_scoreboard_i/fetch_scale_factors_resp_received
add wave -noupdate -group Status -group PREF /top_wrapper_tb/top_i/node_scoreboard_i/fetch_nbs_resp_received
add wave -noupdate -group Status -group PREF /top_wrapper_tb/top_i/node_scoreboard_i/accepting_prefetch_request
add wave -noupdate -group Status -group PREF /top_wrapper_tb/top_i/node_scoreboard_i/prefetcher_arbiter_grant_oh
add wave -noupdate -group Status -group PREF /top_wrapper_tb/top_i/node_scoreboard_i/prefetcher_arbiter_grant_bin
add wave -noupdate -group Status -group PREF /top_wrapper_tb/top_i/node_scoreboard_i/weights_fetched
add wave -noupdate -group Status -group PREF /top_wrapper_tb/top_i/node_scoreboard_i/waiting_weights_fetch_req
add wave -noupdate -group Status -group PREF /top_wrapper_tb/top_i/node_scoreboard_i/active_weights_fetch_precision
add wave -noupdate -group Status -group AGE /top_wrapper_tb/top_i/node_scoreboard_i/aggregation_done
add wave -noupdate -group Status -group AGE /top_wrapper_tb/top_i/node_scoreboard_i/aggregation_buffer_population_count
add wave -noupdate -group Status -group AGE /top_wrapper_tb/top_i/node_scoreboard_i/aggregation_buffer_waiting_transformation
add wave -noupdate -group Status -group AGE /top_wrapper_tb/top_i/node_scoreboard_i/aggregation_buffer_slots_waiting_transformation
add wave -noupdate -group Status -group AGE /top_wrapper_tb/top_i/node_scoreboard_i/aggregation_buffer_precision_arb_bin
add wave -noupdate -group Status -group AGE /top_wrapper_tb/top_i/node_scoreboard_i/age_arbiter_grant_bin
add wave -noupdate -group Status -group AGE /top_wrapper_tb/top_i/node_scoreboard_i/accepting_aggregation_request
add wave -noupdate -group Status -group AGE /top_wrapper_tb/top_i/node_scoreboard_i/nsb_config_aggregation_wait_count_strobe
add wave -noupdate -group Status -group AGE /top_wrapper_tb/top_i/node_scoreboard_i/nsb_config_aggregation_wait_count_count
add wave -noupdate -group Status -group FTE /top_wrapper_tb/top_i/node_scoreboard_i/transformation_done
add wave -noupdate -group Status -group FTE /top_wrapper_tb/top_i/node_scoreboard_i/accepting_transformation_request
add wave -noupdate -group Status -group FTE /top_wrapper_tb/top_i/node_scoreboard_i/fte_request_timeout
add wave -noupdate -group Status -group {Nodes Waiting} /top_wrapper_tb/top_i/node_scoreboard_i/nodeslots_waiting_nb_list_fetch
add wave -noupdate -group Status -group {Nodes Waiting} /top_wrapper_tb/top_i/node_scoreboard_i/nodeslots_waiting_neighbour_fetch
add wave -noupdate -group Status -group {Nodes Waiting} /top_wrapper_tb/top_i/node_scoreboard_i/nodeslots_waiting_scale_factor_fetch
add wave -noupdate -group Status -group {Nodes Waiting} /top_wrapper_tb/top_i/node_scoreboard_i/nodeslots_waiting_prefetcher
add wave -noupdate -group Status -group {Nodes Waiting} /top_wrapper_tb/top_i/node_scoreboard_i/nodeslots_waiting_aggregation
add wave -noupdate -group Status -group {Nodes Waiting} /top_wrapper_tb/top_i/node_scoreboard_i/nodeslots_waiting_transformation
add wave -noupdate -group Status -group Empty /top_wrapper_tb/top_i/node_scoreboard_i/status_nodeslots_empty_mask_lsb_value
add wave -noupdate -group Status -group Empty /top_wrapper_tb/top_i/node_scoreboard_i/status_nodeslots_empty_mask_lsb_strobe
add wave -noupdate -group Status -group Empty /top_wrapper_tb/top_i/node_scoreboard_i/status_nodeslots_empty_mask_0_strobe
add wave -noupdate -group Status -group Empty /top_wrapper_tb/top_i/node_scoreboard_i/status_nodeslots_empty_mask_1_strobe
add wave -noupdate -group Status -group Empty /top_wrapper_tb/top_i/node_scoreboard_i/status_nodeslots_empty_mask_2_strobe
add wave -noupdate -group Status -group Empty /top_wrapper_tb/top_i/node_scoreboard_i/status_nodeslots_empty_mask_3_strobe
add wave -noupdate -group Status -group Empty /top_wrapper_tb/top_i/node_scoreboard_i/status_nodeslots_empty_mask_4_strobe
add wave -noupdate -group Status -group Empty /top_wrapper_tb/top_i/node_scoreboard_i/status_nodeslots_empty_mask_5_strobe
add wave -noupdate -group Status -group Empty /top_wrapper_tb/top_i/node_scoreboard_i/status_nodeslots_empty_mask_6_strobe
add wave -noupdate -group Status -group Empty /top_wrapper_tb/top_i/node_scoreboard_i/status_nodeslots_empty_mask_7_strobe
add wave -noupdate -group Status -group Empty /top_wrapper_tb/top_i/node_scoreboard_i/status_nodeslots_empty_mask_msb_value
add wave -noupdate -group Status -group Empty /top_wrapper_tb/top_i/node_scoreboard_i/status_nodeslots_empty_mask_0_value
add wave -noupdate -group Status -group Empty /top_wrapper_tb/top_i/node_scoreboard_i/status_nodeslots_empty_mask_1_value
add wave -noupdate -group Status -group Empty /top_wrapper_tb/top_i/node_scoreboard_i/status_nodeslots_empty_mask_2_value
add wave -noupdate -group Status -group Empty /top_wrapper_tb/top_i/node_scoreboard_i/status_nodeslots_empty_mask_3_value
add wave -noupdate -group Status -group Empty /top_wrapper_tb/top_i/node_scoreboard_i/status_nodeslots_empty_mask_4_value
add wave -noupdate -group Status -group Empty /top_wrapper_tb/top_i/node_scoreboard_i/status_nodeslots_empty_mask_5_value
add wave -noupdate -group Status -group Empty /top_wrapper_tb/top_i/node_scoreboard_i/status_nodeslots_empty_mask_6_value
add wave -noupdate -group Status -group Empty /top_wrapper_tb/top_i/node_scoreboard_i/status_nodeslots_empty_mask_7_value
add wave -noupdate -group Status -group Empty /top_wrapper_tb/top_i/node_scoreboard_i/status_nodeslots_empty_mask_msb_strobe
add wave -noupdate -group Status -label node_state_0 -group 0-31 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[0]}
add wave -noupdate -group Status -label node_state_0 -group 0-31 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[1]}
add wave -noupdate -group Status -label node_state_0 -group 0-31 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[2]}
add wave -noupdate -group Status -label node_state_0 -group 0-31 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[3]}
add wave -noupdate -group Status -label node_state_0 -group 0-31 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[4]}
add wave -noupdate -group Status -label node_state_0 -group 0-31 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[5]}
add wave -noupdate -group Status -label node_state_0 -group 0-31 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[6]}
add wave -noupdate -group Status -label node_state_0 -group 0-31 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[7]}
add wave -noupdate -group Status -label node_state_0 -group 0-31 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[8]}
add wave -noupdate -group Status -label node_state_0 -group 0-31 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[9]}
add wave -noupdate -group Status -label node_state_0 -group 0-31 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[10]}
add wave -noupdate -group Status -label node_state_0 -group 0-31 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[11]}
add wave -noupdate -group Status -label node_state_0 -group 0-31 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[12]}
add wave -noupdate -group Status -label node_state_0 -group 0-31 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[13]}
add wave -noupdate -group Status -label node_state_0 -group 0-31 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[14]}
add wave -noupdate -group Status -label node_state_0 -group 0-31 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[15]}
add wave -noupdate -group Status -label node_state_0 -group 0-31 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[16]}
add wave -noupdate -group Status -label node_state_0 -group 0-31 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[17]}
add wave -noupdate -group Status -label node_state_0 -group 0-31 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[18]}
add wave -noupdate -group Status -label node_state_0 -group 0-31 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[19]}
add wave -noupdate -group Status -label node_state_0 -group 0-31 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[20]}
add wave -noupdate -group Status -label node_state_0 -group 0-31 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[21]}
add wave -noupdate -group Status -label node_state_0 -group 0-31 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[22]}
add wave -noupdate -group Status -label node_state_0 -group 0-31 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[23]}
add wave -noupdate -group Status -label node_state_0 -group 0-31 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[24]}
add wave -noupdate -group Status -label node_state_0 -group 0-31 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[25]}
add wave -noupdate -group Status -label node_state_0 -group 0-31 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[26]}
add wave -noupdate -group Status -label node_state_0 -group 0-31 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[27]}
add wave -noupdate -group Status -label node_state_0 -group 0-31 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[28]}
add wave -noupdate -group Status -label node_state_0 -group 0-31 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[29]}
add wave -noupdate -group Status -label node_state_0 -group 0-31 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[30]}
add wave -noupdate -group Status -label node_state_0 -group 0-31 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[31]}
add wave -noupdate -group Status -label node_state_32 -group 32-63 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[32]}
add wave -noupdate -group Status -label node_state_32 -group 32-63 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[33]}
add wave -noupdate -group Status -label node_state_32 -group 32-63 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[34]}
add wave -noupdate -group Status -label node_state_32 -group 32-63 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[35]}
add wave -noupdate -group Status -label node_state_32 -group 32-63 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[36]}
add wave -noupdate -group Status -label node_state_32 -group 32-63 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[37]}
add wave -noupdate -group Status -label node_state_32 -group 32-63 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[38]}
add wave -noupdate -group Status -label node_state_32 -group 32-63 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[39]}
add wave -noupdate -group Status -label node_state_32 -group 32-63 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[40]}
add wave -noupdate -group Status -label node_state_32 -group 32-63 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[41]}
add wave -noupdate -group Status -label node_state_32 -group 32-63 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[42]}
add wave -noupdate -group Status -label node_state_32 -group 32-63 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[43]}
add wave -noupdate -group Status -label node_state_32 -group 32-63 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[44]}
add wave -noupdate -group Status -label node_state_32 -group 32-63 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[45]}
add wave -noupdate -group Status -label node_state_32 -group 32-63 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[46]}
add wave -noupdate -group Status -label node_state_32 -group 32-63 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[47]}
add wave -noupdate -group Status -label node_state_32 -group 32-63 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[48]}
add wave -noupdate -group Status -label node_state_32 -group 32-63 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[49]}
add wave -noupdate -group Status -label node_state_32 -group 32-63 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[50]}
add wave -noupdate -group Status -label node_state_32 -group 32-63 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[51]}
add wave -noupdate -group Status -label node_state_32 -group 32-63 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[52]}
add wave -noupdate -group Status -label node_state_32 -group 32-63 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[53]}
add wave -noupdate -group Status -label node_state_32 -group 32-63 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[54]}
add wave -noupdate -group Status -label node_state_32 -group 32-63 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[55]}
add wave -noupdate -group Status -label node_state_32 -group 32-63 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[56]}
add wave -noupdate -group Status -label node_state_32 -group 32-63 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[57]}
add wave -noupdate -group Status -label node_state_32 -group 32-63 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[58]}
add wave -noupdate -group Status -label node_state_32 -group 32-63 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[59]}
add wave -noupdate -group Status -label node_state_32 -group 32-63 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[60]}
add wave -noupdate -group Status -label node_state_32 -group 32-63 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[61]}
add wave -noupdate -group Status -label node_state_32 -group 32-63 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[62]}
add wave -noupdate -group Status -label node_state_32 -group 32-63 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[63]}
add wave -noupdate -group Status -label node_state_64 -group 64-95 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[64]}
add wave -noupdate -group Status -label node_state_64 -group 64-95 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[65]}
add wave -noupdate -group Status -label node_state_64 -group 64-95 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[66]}
add wave -noupdate -group Status -label node_state_64 -group 64-95 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[67]}
add wave -noupdate -group Status -label node_state_64 -group 64-95 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[68]}
add wave -noupdate -group Status -label node_state_64 -group 64-95 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[69]}
add wave -noupdate -group Status -label node_state_64 -group 64-95 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[70]}
add wave -noupdate -group Status -label node_state_64 -group 64-95 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[71]}
add wave -noupdate -group Status -label node_state_64 -group 64-95 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[72]}
add wave -noupdate -group Status -label node_state_64 -group 64-95 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[73]}
add wave -noupdate -group Status -label node_state_64 -group 64-95 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[74]}
add wave -noupdate -group Status -label node_state_64 -group 64-95 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[75]}
add wave -noupdate -group Status -label node_state_64 -group 64-95 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[76]}
add wave -noupdate -group Status -label node_state_64 -group 64-95 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[77]}
add wave -noupdate -group Status -label node_state_64 -group 64-95 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[78]}
add wave -noupdate -group Status -label node_state_64 -group 64-95 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[79]}
add wave -noupdate -group Status -label node_state_64 -group 64-95 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[80]}
add wave -noupdate -group Status -label node_state_64 -group 64-95 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[81]}
add wave -noupdate -group Status -label node_state_64 -group 64-95 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[82]}
add wave -noupdate -group Status -label node_state_64 -group 64-95 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[83]}
add wave -noupdate -group Status -label node_state_64 -group 64-95 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[84]}
add wave -noupdate -group Status -label node_state_64 -group 64-95 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[85]}
add wave -noupdate -group Status -label node_state_64 -group 64-95 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[86]}
add wave -noupdate -group Status -label node_state_64 -group 64-95 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[87]}
add wave -noupdate -group Status -label node_state_64 -group 64-95 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[88]}
add wave -noupdate -group Status -label node_state_64 -group 64-95 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[89]}
add wave -noupdate -group Status -label node_state_64 -group 64-95 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[90]}
add wave -noupdate -group Status -label node_state_64 -group 64-95 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[91]}
add wave -noupdate -group Status -label node_state_64 -group 64-95 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[92]}
add wave -noupdate -group Status -label node_state_64 -group 64-95 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[93]}
add wave -noupdate -group Status -label node_state_64 -group 64-95 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[94]}
add wave -noupdate -group Status -label node_state_64 -group 64-95 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[95]}
add wave -noupdate -group Status -label node_state_96 -group 96-127 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[96]}
add wave -noupdate -group Status -label node_state_96 -group 96-127 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[97]}
add wave -noupdate -group Status -label node_state_96 -group 96-127 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[98]}
add wave -noupdate -group Status -label node_state_96 -group 96-127 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[99]}
add wave -noupdate -group Status -label node_state_96 -group 96-127 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[100]}
add wave -noupdate -group Status -label node_state_96 -group 96-127 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[101]}
add wave -noupdate -group Status -label node_state_96 -group 96-127 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[102]}
add wave -noupdate -group Status -label node_state_96 -group 96-127 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[103]}
add wave -noupdate -group Status -label node_state_96 -group 96-127 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[104]}
add wave -noupdate -group Status -label node_state_96 -group 96-127 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[105]}
add wave -noupdate -group Status -label node_state_96 -group 96-127 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[106]}
add wave -noupdate -group Status -label node_state_96 -group 96-127 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[107]}
add wave -noupdate -group Status -label node_state_96 -group 96-127 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[108]}
add wave -noupdate -group Status -label node_state_96 -group 96-127 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[109]}
add wave -noupdate -group Status -label node_state_96 -group 96-127 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[110]}
add wave -noupdate -group Status -label node_state_96 -group 96-127 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[111]}
add wave -noupdate -group Status -label node_state_96 -group 96-127 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[112]}
add wave -noupdate -group Status -label node_state_96 -group 96-127 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[113]}
add wave -noupdate -group Status -label node_state_96 -group 96-127 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[114]}
add wave -noupdate -group Status -label node_state_96 -group 96-127 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[115]}
add wave -noupdate -group Status -label node_state_96 -group 96-127 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[116]}
add wave -noupdate -group Status -label node_state_96 -group 96-127 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[117]}
add wave -noupdate -group Status -label node_state_96 -group 96-127 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[118]}
add wave -noupdate -group Status -label node_state_96 -group 96-127 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[119]}
add wave -noupdate -group Status -label node_state_96 -group 96-127 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[120]}
add wave -noupdate -group Status -label node_state_96 -group 96-127 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[121]}
add wave -noupdate -group Status -label node_state_96 -group 96-127 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[122]}
add wave -noupdate -group Status -label node_state_96 -group 96-127 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[123]}
add wave -noupdate -group Status -label node_state_96 -group 96-127 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[124]}
add wave -noupdate -group Status -label node_state_96 -group 96-127 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[125]}
add wave -noupdate -group Status -label node_state_96 -group 96-127 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[126]}
add wave -noupdate -group Status -label node_state_96 -group 96-127 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[127]}
add wave -noupdate -group Status -label node_state_128 -group 128-159 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[128]}
add wave -noupdate -group Status -label node_state_128 -group 128-159 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[129]}
add wave -noupdate -group Status -label node_state_128 -group 128-159 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[130]}
add wave -noupdate -group Status -label node_state_128 -group 128-159 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[131]}
add wave -noupdate -group Status -label node_state_128 -group 128-159 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[132]}
add wave -noupdate -group Status -label node_state_128 -group 128-159 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[133]}
add wave -noupdate -group Status -label node_state_128 -group 128-159 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[134]}
add wave -noupdate -group Status -label node_state_128 -group 128-159 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[135]}
add wave -noupdate -group Status -label node_state_128 -group 128-159 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[136]}
add wave -noupdate -group Status -label node_state_128 -group 128-159 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[137]}
add wave -noupdate -group Status -label node_state_128 -group 128-159 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[138]}
add wave -noupdate -group Status -label node_state_128 -group 128-159 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[139]}
add wave -noupdate -group Status -label node_state_128 -group 128-159 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[140]}
add wave -noupdate -group Status -label node_state_128 -group 128-159 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[141]}
add wave -noupdate -group Status -label node_state_128 -group 128-159 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[142]}
add wave -noupdate -group Status -label node_state_128 -group 128-159 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[143]}
add wave -noupdate -group Status -label node_state_128 -group 128-159 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[144]}
add wave -noupdate -group Status -label node_state_128 -group 128-159 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[145]}
add wave -noupdate -group Status -label node_state_128 -group 128-159 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[146]}
add wave -noupdate -group Status -label node_state_128 -group 128-159 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[147]}
add wave -noupdate -group Status -label node_state_128 -group 128-159 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[148]}
add wave -noupdate -group Status -label node_state_128 -group 128-159 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[149]}
add wave -noupdate -group Status -label node_state_128 -group 128-159 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[150]}
add wave -noupdate -group Status -label node_state_128 -group 128-159 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[151]}
add wave -noupdate -group Status -label node_state_128 -group 128-159 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[152]}
add wave -noupdate -group Status -label node_state_128 -group 128-159 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[153]}
add wave -noupdate -group Status -label node_state_128 -group 128-159 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[154]}
add wave -noupdate -group Status -label node_state_128 -group 128-159 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[155]}
add wave -noupdate -group Status -label node_state_128 -group 128-159 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[156]}
add wave -noupdate -group Status -label node_state_128 -group 128-159 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[157]}
add wave -noupdate -group Status -label node_state_128 -group 128-159 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[158]}
add wave -noupdate -group Status -label node_state_128 -group 128-159 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[159]}
add wave -noupdate -group Status -label node_state_160 -group 160-191 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[160]}
add wave -noupdate -group Status -label node_state_160 -group 160-191 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[161]}
add wave -noupdate -group Status -label node_state_160 -group 160-191 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[162]}
add wave -noupdate -group Status -label node_state_160 -group 160-191 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[163]}
add wave -noupdate -group Status -label node_state_160 -group 160-191 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[164]}
add wave -noupdate -group Status -label node_state_160 -group 160-191 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[165]}
add wave -noupdate -group Status -label node_state_160 -group 160-191 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[166]}
add wave -noupdate -group Status -label node_state_160 -group 160-191 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[167]}
add wave -noupdate -group Status -label node_state_160 -group 160-191 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[168]}
add wave -noupdate -group Status -label node_state_160 -group 160-191 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[169]}
add wave -noupdate -group Status -label node_state_160 -group 160-191 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[170]}
add wave -noupdate -group Status -label node_state_160 -group 160-191 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[171]}
add wave -noupdate -group Status -label node_state_160 -group 160-191 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[172]}
add wave -noupdate -group Status -label node_state_160 -group 160-191 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[173]}
add wave -noupdate -group Status -label node_state_160 -group 160-191 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[174]}
add wave -noupdate -group Status -label node_state_160 -group 160-191 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[175]}
add wave -noupdate -group Status -label node_state_160 -group 160-191 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[176]}
add wave -noupdate -group Status -label node_state_160 -group 160-191 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[177]}
add wave -noupdate -group Status -label node_state_160 -group 160-191 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[178]}
add wave -noupdate -group Status -label node_state_160 -group 160-191 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[179]}
add wave -noupdate -group Status -label node_state_160 -group 160-191 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[180]}
add wave -noupdate -group Status -label node_state_160 -group 160-191 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[181]}
add wave -noupdate -group Status -label node_state_160 -group 160-191 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[182]}
add wave -noupdate -group Status -label node_state_160 -group 160-191 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[183]}
add wave -noupdate -group Status -label node_state_160 -group 160-191 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[184]}
add wave -noupdate -group Status -label node_state_160 -group 160-191 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[185]}
add wave -noupdate -group Status -label node_state_160 -group 160-191 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[186]}
add wave -noupdate -group Status -label node_state_160 -group 160-191 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[187]}
add wave -noupdate -group Status -label node_state_160 -group 160-191 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[188]}
add wave -noupdate -group Status -label node_state_160 -group 160-191 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[189]}
add wave -noupdate -group Status -label node_state_160 -group 160-191 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[190]}
add wave -noupdate -group Status -label node_state_160 -group 160-191 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[191]}
add wave -noupdate -group Status -label node_state_192 -group 192-223 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[192]}
add wave -noupdate -group Status -label node_state_192 -group 192-223 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[193]}
add wave -noupdate -group Status -label node_state_192 -group 192-223 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[194]}
add wave -noupdate -group Status -label node_state_192 -group 192-223 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[195]}
add wave -noupdate -group Status -label node_state_192 -group 192-223 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[196]}
add wave -noupdate -group Status -label node_state_192 -group 192-223 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[197]}
add wave -noupdate -group Status -label node_state_192 -group 192-223 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[198]}
add wave -noupdate -group Status -label node_state_192 -group 192-223 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[199]}
add wave -noupdate -group Status -label node_state_192 -group 192-223 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[200]}
add wave -noupdate -group Status -label node_state_192 -group 192-223 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[201]}
add wave -noupdate -group Status -label node_state_192 -group 192-223 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[202]}
add wave -noupdate -group Status -label node_state_192 -group 192-223 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[203]}
add wave -noupdate -group Status -label node_state_192 -group 192-223 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[204]}
add wave -noupdate -group Status -label node_state_192 -group 192-223 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[205]}
add wave -noupdate -group Status -label node_state_192 -group 192-223 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[206]}
add wave -noupdate -group Status -label node_state_192 -group 192-223 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[207]}
add wave -noupdate -group Status -label node_state_192 -group 192-223 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[208]}
add wave -noupdate -group Status -label node_state_192 -group 192-223 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[209]}
add wave -noupdate -group Status -label node_state_192 -group 192-223 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[210]}
add wave -noupdate -group Status -label node_state_192 -group 192-223 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[211]}
add wave -noupdate -group Status -label node_state_192 -group 192-223 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[212]}
add wave -noupdate -group Status -label node_state_192 -group 192-223 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[213]}
add wave -noupdate -group Status -label node_state_192 -group 192-223 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[214]}
add wave -noupdate -group Status -label node_state_192 -group 192-223 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[215]}
add wave -noupdate -group Status -label node_state_192 -group 192-223 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[216]}
add wave -noupdate -group Status -label node_state_192 -group 192-223 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[217]}
add wave -noupdate -group Status -label node_state_192 -group 192-223 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[218]}
add wave -noupdate -group Status -label node_state_192 -group 192-223 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[219]}
add wave -noupdate -group Status -label node_state_192 -group 192-223 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[220]}
add wave -noupdate -group Status -label node_state_192 -group 192-223 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[221]}
add wave -noupdate -group Status -label node_state_192 -group 192-223 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[222]}
add wave -noupdate -group Status -label node_state_192 -group 192-223 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[223]}
add wave -noupdate -group Status -label node_state_224 -group 224-255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[224]}
add wave -noupdate -group Status -label node_state_224 -group 224-255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[225]}
add wave -noupdate -group Status -label node_state_224 -group 224-255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[226]}
add wave -noupdate -group Status -label node_state_224 -group 224-255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[227]}
add wave -noupdate -group Status -label node_state_224 -group 224-255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[228]}
add wave -noupdate -group Status -label node_state_224 -group 224-255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[229]}
add wave -noupdate -group Status -label node_state_224 -group 224-255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[230]}
add wave -noupdate -group Status -label node_state_224 -group 224-255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[231]}
add wave -noupdate -group Status -label node_state_224 -group 224-255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[232]}
add wave -noupdate -group Status -label node_state_224 -group 224-255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[233]}
add wave -noupdate -group Status -label node_state_224 -group 224-255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[234]}
add wave -noupdate -group Status -label node_state_224 -group 224-255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[235]}
add wave -noupdate -group Status -label node_state_224 -group 224-255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[236]}
add wave -noupdate -group Status -label node_state_224 -group 224-255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[237]}
add wave -noupdate -group Status -label node_state_224 -group 224-255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[238]}
add wave -noupdate -group Status -label node_state_224 -group 224-255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[239]}
add wave -noupdate -group Status -label node_state_224 -group 224-255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[240]}
add wave -noupdate -group Status -label node_state_224 -group 224-255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[241]}
add wave -noupdate -group Status -label node_state_224 -group 224-255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[242]}
add wave -noupdate -group Status -label node_state_224 -group 224-255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[243]}
add wave -noupdate -group Status -label node_state_224 -group 224-255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[244]}
add wave -noupdate -group Status -label node_state_224 -group 224-255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[245]}
add wave -noupdate -group Status -label node_state_224 -group 224-255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[246]}
add wave -noupdate -group Status -label node_state_224 -group 224-255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[247]}
add wave -noupdate -group Status -label node_state_224 -group 224-255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[248]}
add wave -noupdate -group Status -label node_state_224 -group 224-255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[249]}
add wave -noupdate -group Status -label node_state_224 -group 224-255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[250]}
add wave -noupdate -group Status -label node_state_224 -group 224-255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[251]}
add wave -noupdate -group Status -label node_state_224 -group 224-255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[252]}
add wave -noupdate -group Status -label node_state_224 -group 224-255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[253]}
add wave -noupdate -group Status -label node_state_224 -group 224-255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[254]}
add wave -noupdate -group Status -label node_state_224 -group 224-255 {/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[255]}
add wave -noupdate -group Status /top_wrapper_tb/top_i/node_scoreboard_i/nodeslot_finished
add wave -noupdate -group Status /top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_allocated_fetch_tag_strobe
add wave -noupdate -group Status /top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_allocated_fetch_tag_fetch_tag
add wave -noupdate -group Status /top_wrapper_tb/top_i/node_scoreboard_i/nodeslot_state
add wave -noupdate -group Status /top_wrapper_tb/top_i/node_scoreboard_i/nodeslot_state_n
add wave -noupdate -group {Layer Config} /top_wrapper_tb/top_i/node_scoreboard_i/graph_config_node_count_strobe
add wave -noupdate -group {Layer Config} /top_wrapper_tb/top_i/node_scoreboard_i/graph_config_node_count_value
add wave -noupdate -group {Layer Config} /top_wrapper_tb/top_i/node_scoreboard_i/layer_config_scale_factors_address_lsb_value
add wave -noupdate -group {Layer Config} /top_wrapper_tb/top_i/node_scoreboard_i/layer_config_scale_factors_address_lsb_strobe
add wave -noupdate -group {Layer Config} /top_wrapper_tb/top_i/node_scoreboard_i/layer_config_scale_factors_address_msb_strobe
add wave -noupdate -group {Layer Config} /top_wrapper_tb/top_i/node_scoreboard_i/layer_config_scale_factors_address_msb_value
add wave -noupdate -group {Layer Config} /top_wrapper_tb/top_i/node_scoreboard_i/layer_config_valid_strobe
add wave -noupdate -group {Layer Config} /top_wrapper_tb/top_i/node_scoreboard_i/layer_config_valid_value
add wave -noupdate -group {Layer Config} /top_wrapper_tb/top_i/node_scoreboard_i/layer_config_in_features_strobe
add wave -noupdate -group {Layer Config} /top_wrapper_tb/top_i/node_scoreboard_i/layer_config_in_features_count
add wave -noupdate -group {Layer Config} /top_wrapper_tb/top_i/node_scoreboard_i/layer_config_out_features_strobe
add wave -noupdate -group {Layer Config} /top_wrapper_tb/top_i/node_scoreboard_i/layer_config_out_features_count
add wave -noupdate -group {Layer Config} /top_wrapper_tb/top_i/node_scoreboard_i/layer_config_adjacency_list_address_lsb_strobe
add wave -noupdate -group {Layer Config} /top_wrapper_tb/top_i/node_scoreboard_i/layer_config_adjacency_list_address_lsb_lsb
add wave -noupdate -group {Layer Config} /top_wrapper_tb/top_i/node_scoreboard_i/layer_config_adjacency_list_address_msb_strobe
add wave -noupdate -group {Layer Config} /top_wrapper_tb/top_i/node_scoreboard_i/layer_config_adjacency_list_address_msb_msb
add wave -noupdate -group {Layer Config} /top_wrapper_tb/top_i/node_scoreboard_i/layer_config_weights_address_lsb_strobe
add wave -noupdate -group {Layer Config} /top_wrapper_tb/top_i/node_scoreboard_i/layer_config_weights_address_lsb_lsb
add wave -noupdate -group {Layer Config} /top_wrapper_tb/top_i/node_scoreboard_i/layer_config_weights_address_msb_strobe
add wave -noupdate -group {Layer Config} /top_wrapper_tb/top_i/node_scoreboard_i/layer_config_weights_address_msb_msb
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {18272400 ps} 0} {{Cursor 2} {40560698 ps} 0}
quietly wave cursor active 2
configure wave -namecolwidth 430
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
WaveRestoreZoom {0 ps} {170877001 ps}
bookmark add wave bookmark2 {{18551117 ps} {18990769 ps}} 0
