add wave -noupdate /top_wrapper_tb/sys_clk
add wave -noupdate /top_wrapper_tb/sys_rst
add wave -noupdate /top_wrapper_tb/regbank_clk
add wave -noupdate /top_wrapper_tb/regbank_resetn

add wave -noupdate -group AXI-L sim:/top_wrapper_tb/host_axil_awvalid
add wave -noupdate -group AXI-L sim:/top_wrapper_tb/host_axil_awready
add wave -noupdate -group AXI-L sim:/top_wrapper_tb/host_axil_awaddr
add wave -noupdate -group AXI-L sim:/top_wrapper_tb/host_axil_awprot
add wave -noupdate -group AXI-L sim:/top_wrapper_tb/host_axil_wvalid
add wave -noupdate -group AXI-L sim:/top_wrapper_tb/host_axil_wready
add wave -noupdate -group AXI-L sim:/top_wrapper_tb/host_axil_wdata
add wave -noupdate -group AXI-L sim:/top_wrapper_tb/host_axil_wstrb
add wave -noupdate -group AXI-L sim:/top_wrapper_tb/host_axil_bvalid
add wave -noupdate -group AXI-L sim:/top_wrapper_tb/host_axil_bready
add wave -noupdate -group AXI-L sim:/top_wrapper_tb/host_axil_bresp
add wave -noupdate -group AXI-L sim:/top_wrapper_tb/host_axil_arvalid
add wave -noupdate -group AXI-L sim:/top_wrapper_tb/host_axil_arready
add wave -noupdate -group AXI-L sim:/top_wrapper_tb/host_axil_araddr
add wave -noupdate -group AXI-L sim:/top_wrapper_tb/host_axil_arprot
add wave -noupdate -group AXI-L sim:/top_wrapper_tb/host_axil_rvalid
add wave -noupdate -group AXI-L sim:/top_wrapper_tb/host_axil_rready
add wave -noupdate -group AXI-L sim:/top_wrapper_tb/host_axil_rdata
add wave -noupdate -group AXI-L sim:/top_wrapper_tb/host_axil_rresp

add wave -noupdate -group NSB -label node_state_0 sim:/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[0]
add wave -noupdate -group NSB -label node_id_0 sim:/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_id_id[0]

add wave -noupdate -group NSB -label node_state_1 sim:/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[1]
add wave -noupdate -group NSB -label node_id_1 sim:/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_id_id[1]

add wave -noupdate -group NSB -label node_state_2 sim:/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[2]
add wave -noupdate -group NSB -label node_id_2 sim:/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_id_id[2]

add wave -noupdate -group NSB -label node_state_3 sim:/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[3]
add wave -noupdate -group NSB -label node_id_3 sim:/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_id_id[3]

add wave -noupdate -group NSB -label node_state_4 sim:/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[4]
add wave -noupdate -group NSB -label node_id_4 sim:/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_id_id[4]

add wave -noupdate -group NSB -label node_state_5 sim:/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[5]
add wave -noupdate -group NSB -label node_id_5 sim:/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_id_id[5]

add wave -noupdate -group NSB -label node_state_6 sim:/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[6]
add wave -noupdate -group NSB -label node_id_6 sim:/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_id_id[6]

add wave -noupdate -group NSB -label node_state_7 sim:/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[7]
add wave -noupdate -group NSB -label node_id_7 sim:/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_id_id[7]

add wave -noupdate -group NSB -label node_state_8 sim:/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[8]
add wave -noupdate -group NSB -label node_id_8 sim:/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_id_id[8]
add wave -noupdate -group NSB -label node_state_9 sim:/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[9]
add wave -noupdate -group NSB -label node_id_9 sim:/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_id_id[9]
add wave -noupdate -group NSB -label node_state_10 sim:/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[10]
add wave -noupdate -group NSB -label node_id_10 sim:/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_id_id[10]
add wave -noupdate -group NSB -label node_state_11 sim:/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[11]
add wave -noupdate -group NSB -label node_id_11 sim:/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_id_id[11]
add wave -noupdate -group NSB -label node_state_12 sim:/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[12]
add wave -noupdate -group NSB -label node_id_12 sim:/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_id_id[12]
add wave -noupdate -group NSB -label node_state_13 sim:/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[13]
add wave -noupdate -group NSB -label node_id_13 sim:/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_id_id[13]
add wave -noupdate -group NSB -label node_state_14 sim:/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[14]
add wave -noupdate -group NSB -label node_id_14 sim:/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_id_id[14]
add wave -noupdate -group NSB -label node_state_15 sim:/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[15]
add wave -noupdate -group NSB -label node_id_15 sim:/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_id_id[15]

add wave -group WEIGHT_BANK -label weight_bank_state sim:/top_wrapper_tb/top_i/prefetcher_i/weight_bank_float_i/weight_bank_state
add wave -group WEIGHT_BANK -label weight_channel_resp sim:/top_wrapper_tb/top_i/prefetcher_i/weight_bank_float_i/weight_channel_resp

add wave -noupdate -group FETCH_TAG_0 -label message_fetch_state sim:/top_wrapper_tb/top_i/prefetcher_i/feature_bank_i/genblk1[0]/fetch_tag_i/message_fetch_state
add wave -noupdate -group FETCH_TAG_0 -label fetch_state         sim:/top_wrapper_tb/top_i/prefetcher_i/feature_bank_i/genblk1[0]/fetch_tag_i/adj_queue_manager_i/fetch_state

add wave -noupdate -group FETCH_TAG_1 -label message_fetch_state sim:/top_wrapper_tb/top_i/prefetcher_i/feature_bank_i/genblk1[1]/fetch_tag_i/message_fetch_state
add wave -noupdate -group FETCH_TAG_1 -label fetch_state         sim:/top_wrapper_tb/top_i/prefetcher_i/feature_bank_i/genblk1[1]/fetch_tag_i/adj_queue_manager_i/fetch_state

add wave -noupdate -group FETCH_TAG_2 -label message_fetch_state sim:/top_wrapper_tb/top_i/prefetcher_i/feature_bank_i/genblk1[2]/fetch_tag_i/message_fetch_state
add wave -noupdate -group FETCH_TAG_2 -label fetch_state         sim:/top_wrapper_tb/top_i/prefetcher_i/feature_bank_i/genblk1[2]/fetch_tag_i/adj_queue_manager_i/fetch_state

add wave -noupdate -group FETCH_TAG_3 -label message_fetch_state sim:/top_wrapper_tb/top_i/prefetcher_i/feature_bank_i/genblk1[3]/fetch_tag_i/message_fetch_state
add wave -noupdate -group FETCH_TAG_3 -label fetch_state         sim:/top_wrapper_tb/top_i/prefetcher_i/feature_bank_i/genblk1[3]/fetch_tag_i/adj_queue_manager_i/fetch_state

add wave -noupdate -group AGE -label nsb_age_req_valid sim:/top_wrapper_tb/top_i/aggregation_engine_i/nsb_age_req_valid
add wave -noupdate -group AGE -label nsb_age_req_ready sim:/top_wrapper_tb/top_i/aggregation_engine_i/nsb_age_req_ready
add wave -noupdate -group AGE -label nsb_age_req sim:/top_wrapper_tb/top_i/aggregation_engine_i/nsb_age_req

add wave -noupdate -group AGE -label nsb_age_resp_valid sim:/top_wrapper_tb/top_i/aggregation_engine_i/nsb_age_resp_valid
add wave -noupdate -group AGE -label nsb_age_resp sim:/top_wrapper_tb/top_i/aggregation_engine_i/nsb_age_resp

add wave -noupdate -group FLOAT_AGC_ALLOCATOR -label allocation_req_valid sim:/top_wrapper_tb/top_i/aggregation_engine_i/precision_block[0]/aggregation_mesh_i/agc_allocator/allocation_req_valid
add wave -noupdate -group FLOAT_AGC_ALLOCATOR -label allocation_req_ready sim:/top_wrapper_tb/top_i/aggregation_engine_i/precision_block[0]/aggregation_mesh_i/agc_allocator/allocation_req_ready
add wave -noupdate -group FLOAT_AGC_ALLOCATOR -label allocation_req sim:/top_wrapper_tb/top_i/aggregation_engine_i/precision_block[0]/aggregation_mesh_i/agc_allocator/allocation_req
add wave -noupdate -group FLOAT_AGC_ALLOCATOR -label agm_req_valid sim:/top_wrapper_tb/top_i/aggregation_engine_i/precision_block[0]/aggregation_mesh_i/agc_allocator/agm_req_valid
add wave -noupdate -group FLOAT_AGC_ALLOCATOR -label agm_req_ready sim:/top_wrapper_tb/top_i/aggregation_engine_i/precision_block[0]/aggregation_mesh_i/agc_allocator/agm_req_ready
add wave -noupdate -group FLOAT_AGC_ALLOCATOR -label agm_req sim:/top_wrapper_tb/top_i/aggregation_engine_i/precision_block[0]/aggregation_mesh_i/agc_allocator/agm_req

add wave -noupdate -group FLOAT_AGM -label agm_state sim:/top_wrapper_tb/top_i/aggregation_engine_i/precision_block[0]/aggregation_mesh_i/agm_block[0]/agm_i/agm_state
add wave -noupdate -group FLOAT_AGM -label agm_state sim:/top_wrapper_tb/top_i/aggregation_engine_i/precision_block[0]/aggregation_mesh_i/agm_block[1]/agm_i/agm_state
add wave -noupdate -group FLOAT_AGM -label agm_state sim:/top_wrapper_tb/top_i/aggregation_engine_i/precision_block[0]/aggregation_mesh_i/agm_block[2]/agm_i/agm_state
add wave -noupdate -group FLOAT_AGM -label agm_state sim:/top_wrapper_tb/top_i/aggregation_engine_i/precision_block[0]/aggregation_mesh_i/agm_block[3]/agm_i/agm_state

add wave -group FLOAT_AGC -label row0_col0 sim:/top_wrapper_tb/top_i/aggregation_engine_i/precision_block[0]/aggregation_mesh_i/row_gen[0]/col_gen[0]/agc_i/agc_state
add wave -group FLOAT_AGC -label row0_col1 sim:/top_wrapper_tb/top_i/aggregation_engine_i/precision_block[0]/aggregation_mesh_i/row_gen[0]/col_gen[1]/agc_i/agc_state
add wave -group FLOAT_AGC -label row0_col2 sim:/top_wrapper_tb/top_i/aggregation_engine_i/precision_block[0]/aggregation_mesh_i/row_gen[0]/col_gen[2]/agc_i/agc_state
add wave -group FLOAT_AGC -label row0_col3 sim:/top_wrapper_tb/top_i/aggregation_engine_i/precision_block[0]/aggregation_mesh_i/row_gen[0]/col_gen[3]/agc_i/agc_state
add wave -group FLOAT_AGC -label row0_col4 sim:/top_wrapper_tb/top_i/aggregation_engine_i/precision_block[0]/aggregation_mesh_i/row_gen[0]/col_gen[4]/agc_i/agc_state
add wave -group FLOAT_AGC -label row0_col5 sim:/top_wrapper_tb/top_i/aggregation_engine_i/precision_block[0]/aggregation_mesh_i/row_gen[0]/col_gen[5]/agc_i/agc_state
add wave -group FLOAT_AGC -label row0_col6 sim:/top_wrapper_tb/top_i/aggregation_engine_i/precision_block[0]/aggregation_mesh_i/row_gen[0]/col_gen[6]/agc_i/agc_state
add wave -group FLOAT_AGC -label row0_col7 sim:/top_wrapper_tb/top_i/aggregation_engine_i/precision_block[0]/aggregation_mesh_i/row_gen[0]/col_gen[7]/agc_i/agc_state

add wave -group FLOAT_AGC -label row1_col0 sim:/top_wrapper_tb/top_i/aggregation_engine_i/precision_block[0]/aggregation_mesh_i/row_gen[1]/col_gen[0]/agc_i/agc_state
add wave -group FLOAT_AGC -label row1_col1 sim:/top_wrapper_tb/top_i/aggregation_engine_i/precision_block[0]/aggregation_mesh_i/row_gen[1]/col_gen[1]/agc_i/agc_state
add wave -group FLOAT_AGC -label row1_col2 sim:/top_wrapper_tb/top_i/aggregation_engine_i/precision_block[0]/aggregation_mesh_i/row_gen[1]/col_gen[2]/agc_i/agc_state
add wave -group FLOAT_AGC -label row1_col3 sim:/top_wrapper_tb/top_i/aggregation_engine_i/precision_block[0]/aggregation_mesh_i/row_gen[1]/col_gen[3]/agc_i/agc_state
add wave -group FLOAT_AGC -label row1_col4 sim:/top_wrapper_tb/top_i/aggregation_engine_i/precision_block[0]/aggregation_mesh_i/row_gen[1]/col_gen[4]/agc_i/agc_state
add wave -group FLOAT_AGC -label row1_col5 sim:/top_wrapper_tb/top_i/aggregation_engine_i/precision_block[0]/aggregation_mesh_i/row_gen[1]/col_gen[5]/agc_i/agc_state
add wave -group FLOAT_AGC -label row1_col6 sim:/top_wrapper_tb/top_i/aggregation_engine_i/precision_block[0]/aggregation_mesh_i/row_gen[1]/col_gen[6]/agc_i/agc_state
add wave -group FLOAT_AGC -label row1_col7 sim:/top_wrapper_tb/top_i/aggregation_engine_i/precision_block[0]/aggregation_mesh_i/row_gen[1]/col_gen[7]/agc_i/agc_state

add wave -group FLOAT_AGC -label row2_col0 sim:/top_wrapper_tb/top_i/aggregation_engine_i/precision_block[0]/aggregation_mesh_i/row_gen[2]/col_gen[0]/agc_i/agc_state
add wave -group FLOAT_AGC -label row2_col1 sim:/top_wrapper_tb/top_i/aggregation_engine_i/precision_block[0]/aggregation_mesh_i/row_gen[2]/col_gen[1]/agc_i/agc_state
add wave -group FLOAT_AGC -label row2_col2 sim:/top_wrapper_tb/top_i/aggregation_engine_i/precision_block[0]/aggregation_mesh_i/row_gen[2]/col_gen[2]/agc_i/agc_state
add wave -group FLOAT_AGC -label row2_col3 sim:/top_wrapper_tb/top_i/aggregation_engine_i/precision_block[0]/aggregation_mesh_i/row_gen[2]/col_gen[3]/agc_i/agc_state
add wave -group FLOAT_AGC -label row2_col4 sim:/top_wrapper_tb/top_i/aggregation_engine_i/precision_block[0]/aggregation_mesh_i/row_gen[2]/col_gen[4]/agc_i/agc_state
add wave -group FLOAT_AGC -label row2_col5 sim:/top_wrapper_tb/top_i/aggregation_engine_i/precision_block[0]/aggregation_mesh_i/row_gen[2]/col_gen[5]/agc_i/agc_state
add wave -group FLOAT_AGC -label row2_col6 sim:/top_wrapper_tb/top_i/aggregation_engine_i/precision_block[0]/aggregation_mesh_i/row_gen[2]/col_gen[6]/agc_i/agc_state
add wave -group FLOAT_AGC -label row2_col7 sim:/top_wrapper_tb/top_i/aggregation_engine_i/precision_block[0]/aggregation_mesh_i/row_gen[2]/col_gen[7]/agc_i/agc_state

add wave -group FLOAT_AGC -label row3_col0 sim:/top_wrapper_tb/top_i/aggregation_engine_i/precision_block[0]/aggregation_mesh_i/row_gen[3]/col_gen[0]/agc_i/agc_state
add wave -group FLOAT_AGC -label row3_col1 sim:/top_wrapper_tb/top_i/aggregation_engine_i/precision_block[0]/aggregation_mesh_i/row_gen[3]/col_gen[1]/agc_i/agc_state
add wave -group FLOAT_AGC -label row3_col2 sim:/top_wrapper_tb/top_i/aggregation_engine_i/precision_block[0]/aggregation_mesh_i/row_gen[3]/col_gen[2]/agc_i/agc_state
add wave -group FLOAT_AGC -label row3_col3 sim:/top_wrapper_tb/top_i/aggregation_engine_i/precision_block[0]/aggregation_mesh_i/row_gen[3]/col_gen[3]/agc_i/agc_state
add wave -group FLOAT_AGC -label row3_col4 sim:/top_wrapper_tb/top_i/aggregation_engine_i/precision_block[0]/aggregation_mesh_i/row_gen[3]/col_gen[4]/agc_i/agc_state
add wave -group FLOAT_AGC -label row3_col5 sim:/top_wrapper_tb/top_i/aggregation_engine_i/precision_block[0]/aggregation_mesh_i/row_gen[3]/col_gen[5]/agc_i/agc_state
add wave -group FLOAT_AGC -label row3_col6 sim:/top_wrapper_tb/top_i/aggregation_engine_i/precision_block[0]/aggregation_mesh_i/row_gen[3]/col_gen[6]/agc_i/agc_state
add wave -group FLOAT_AGC -label row3_col7 sim:/top_wrapper_tb/top_i/aggregation_engine_i/precision_block[0]/aggregation_mesh_i/row_gen[3]/col_gen[7]/agc_i/agc_state

add wave -noupdate -group FLOAT_BM -label bm_state sim:/top_wrapper_tb/top_i/aggregation_engine_i/precision_block[0]/aggregation_mesh_i/bm_block[0]/buffer_manager_i/bm_state
add wave -noupdate -group FLOAT_BM -label bm_state sim:/top_wrapper_tb/top_i/aggregation_engine_i/precision_block[0]/aggregation_mesh_i/bm_block[1]/buffer_manager_i/bm_state
add wave -noupdate -group FLOAT_BM -label bm_state sim:/top_wrapper_tb/top_i/aggregation_engine_i/precision_block[0]/aggregation_mesh_i/bm_block[2]/buffer_manager_i/bm_state
add wave -noupdate -group FLOAT_BM -label bm_state sim:/top_wrapper_tb/top_i/aggregation_engine_i/precision_block[0]/aggregation_mesh_i/bm_block[3]/buffer_manager_i/bm_state

add wave -noupdate -group FIXED_AGC_ALLOCATOR -label allocation_req_valid sim:/top_wrapper_tb/top_i/aggregation_engine_i/precision_block[1]/aggregation_mesh_i/agc_allocator/allocation_req_valid
add wave -noupdate -group FIXED_AGC_ALLOCATOR -label allocation_req_ready sim:/top_wrapper_tb/top_i/aggregation_engine_i/precision_block[1]/aggregation_mesh_i/agc_allocator/allocation_req_ready
add wave -noupdate -group FIXED_AGC_ALLOCATOR -label allocation_req sim:/top_wrapper_tb/top_i/aggregation_engine_i/precision_block[1]/aggregation_mesh_i/agc_allocator/allocation_req
add wave -noupdate -group FIXED_AGC_ALLOCATOR -label agm_req_valid sim:/top_wrapper_tb/top_i/aggregation_engine_i/precision_block[1]/aggregation_mesh_i/agc_allocator/agm_req_valid
add wave -noupdate -group FIXED_AGC_ALLOCATOR -label agm_req_ready sim:/top_wrapper_tb/top_i/aggregation_engine_i/precision_block[1]/aggregation_mesh_i/agc_allocator/agm_req_ready
add wave -noupdate -group FIXED_AGC_ALLOCATOR -label agm_req sim:/top_wrapper_tb/top_i/aggregation_engine_i/precision_block[1]/aggregation_mesh_i/agc_allocator/agm_req

add wave -noupdate -group FIXED_AGM -label agm_state sim:/top_wrapper_tb/top_i/aggregation_engine_i/precision_block[1]/aggregation_mesh_i/agm_block[0]/agm_i/agm_state
add wave -noupdate -group FIXED_AGM -label agm_state sim:/top_wrapper_tb/top_i/aggregation_engine_i/precision_block[1]/aggregation_mesh_i/agm_block[1]/agm_i/agm_state
add wave -noupdate -group FIXED_AGM -label agm_state sim:/top_wrapper_tb/top_i/aggregation_engine_i/precision_block[1]/aggregation_mesh_i/agm_block[2]/agm_i/agm_state
add wave -noupdate -group FIXED_AGM -label agm_state sim:/top_wrapper_tb/top_i/aggregation_engine_i/precision_block[1]/aggregation_mesh_i/agm_block[3]/agm_i/agm_state

add wave -group FIXED_AGC -label row0_col0 sim:/top_wrapper_tb/top_i/aggregation_engine_i/precision_block[1]/aggregation_mesh_i/row_gen[0]/col_gen[0]/agc_i/agc_state
add wave -group FIXED_AGC -label row0_col1 sim:/top_wrapper_tb/top_i/aggregation_engine_i/precision_block[1]/aggregation_mesh_i/row_gen[0]/col_gen[1]/agc_i/agc_state
add wave -group FIXED_AGC -label row0_col2 sim:/top_wrapper_tb/top_i/aggregation_engine_i/precision_block[1]/aggregation_mesh_i/row_gen[0]/col_gen[2]/agc_i/agc_state
add wave -group FIXED_AGC -label row0_col3 sim:/top_wrapper_tb/top_i/aggregation_engine_i/precision_block[1]/aggregation_mesh_i/row_gen[0]/col_gen[3]/agc_i/agc_state
add wave -group FIXED_AGC -label row0_col4 sim:/top_wrapper_tb/top_i/aggregation_engine_i/precision_block[1]/aggregation_mesh_i/row_gen[0]/col_gen[4]/agc_i/agc_state
add wave -group FIXED_AGC -label row0_col5 sim:/top_wrapper_tb/top_i/aggregation_engine_i/precision_block[1]/aggregation_mesh_i/row_gen[0]/col_gen[5]/agc_i/agc_state
add wave -group FIXED_AGC -label row0_col6 sim:/top_wrapper_tb/top_i/aggregation_engine_i/precision_block[1]/aggregation_mesh_i/row_gen[0]/col_gen[6]/agc_i/agc_state
add wave -group FIXED_AGC -label row0_col7 sim:/top_wrapper_tb/top_i/aggregation_engine_i/precision_block[1]/aggregation_mesh_i/row_gen[0]/col_gen[7]/agc_i/agc_state

add wave -group FIXED_AGC -label row1_col0 sim:/top_wrapper_tb/top_i/aggregation_engine_i/precision_block[1]/aggregation_mesh_i/row_gen[1]/col_gen[0]/agc_i/agc_state
add wave -group FIXED_AGC -label row1_col1 sim:/top_wrapper_tb/top_i/aggregation_engine_i/precision_block[1]/aggregation_mesh_i/row_gen[1]/col_gen[1]/agc_i/agc_state
add wave -group FIXED_AGC -label row1_col2 sim:/top_wrapper_tb/top_i/aggregation_engine_i/precision_block[1]/aggregation_mesh_i/row_gen[1]/col_gen[2]/agc_i/agc_state
add wave -group FIXED_AGC -label row1_col3 sim:/top_wrapper_tb/top_i/aggregation_engine_i/precision_block[1]/aggregation_mesh_i/row_gen[1]/col_gen[3]/agc_i/agc_state
add wave -group FIXED_AGC -label row1_col4 sim:/top_wrapper_tb/top_i/aggregation_engine_i/precision_block[1]/aggregation_mesh_i/row_gen[1]/col_gen[4]/agc_i/agc_state
add wave -group FIXED_AGC -label row1_col5 sim:/top_wrapper_tb/top_i/aggregation_engine_i/precision_block[1]/aggregation_mesh_i/row_gen[1]/col_gen[5]/agc_i/agc_state
add wave -group FIXED_AGC -label row1_col6 sim:/top_wrapper_tb/top_i/aggregation_engine_i/precision_block[1]/aggregation_mesh_i/row_gen[1]/col_gen[6]/agc_i/agc_state
add wave -group FIXED_AGC -label row1_col7 sim:/top_wrapper_tb/top_i/aggregation_engine_i/precision_block[1]/aggregation_mesh_i/row_gen[1]/col_gen[7]/agc_i/agc_state

add wave -noupdate -group FIXED_BM -label bm_state sim:/top_wrapper_tb/top_i/aggregation_engine_i/precision_block[1]/aggregation_mesh_i/bm_block[0]/buffer_manager_i/bm_state
add wave -noupdate -group FIXED_BM -label bm_state sim:/top_wrapper_tb/top_i/aggregation_engine_i/precision_block[1]/aggregation_mesh_i/bm_block[1]/buffer_manager_i/bm_state
add wave -noupdate -group FIXED_BM -label bm_state sim:/top_wrapper_tb/top_i/aggregation_engine_i/precision_block[1]/aggregation_mesh_i/bm_block[2]/buffer_manager_i/bm_state
add wave -noupdate -group FIXED_BM -label bm_state sim:/top_wrapper_tb/top_i/aggregation_engine_i/precision_block[1]/aggregation_mesh_i/bm_block[3]/buffer_manager_i/bm_state

add wave -group FTE -label float_core_state sim:/top_wrapper_tb/top_i/transformation_engine_i/genblk1[0]/feature_transformation_core_i/fte_state
add wave -group FTE -label pulse_systolic_module sim:/top_wrapper_tb/top_i/transformation_engine_i/genblk1[0]/feature_transformation_core_i/pulse_systolic_module

add wave -group FTE -label float_core_state sim:/top_wrapper_tb/top_i/transformation_engine_i/genblk1[1]/feature_transformation_core_i/fte_state
add wave -group FTE -label pulse_systolic_module sim:/top_wrapper_tb/top_i/transformation_engine_i/genblk1[1]/feature_transformation_core_i/pulse_systolic_module
