onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /top_wrapper_tb/top_i/nodeslot_prefetcher_i/core_clk
add wave -noupdate /top_wrapper_tb/top_i/nodeslot_prefetcher_i/resetn
add wave -noupdate -group AXI-READ /top_wrapper_tb/top_i/nodeslot_prefetcher_i/read_master_axi_awid
add wave -noupdate -group AXI-READ /top_wrapper_tb/top_i/nodeslot_prefetcher_i/read_master_axi_awaddr
add wave -noupdate -group AXI-READ /top_wrapper_tb/top_i/nodeslot_prefetcher_i/read_master_axi_awlen
add wave -noupdate -group AXI-READ /top_wrapper_tb/top_i/nodeslot_prefetcher_i/read_master_axi_awsize
add wave -noupdate -group AXI-READ /top_wrapper_tb/top_i/nodeslot_prefetcher_i/read_master_axi_awburst
add wave -noupdate -group AXI-READ /top_wrapper_tb/top_i/nodeslot_prefetcher_i/read_master_axi_awlock
add wave -noupdate -group AXI-READ /top_wrapper_tb/top_i/nodeslot_prefetcher_i/read_master_axi_awcache
add wave -noupdate -group AXI-READ /top_wrapper_tb/top_i/nodeslot_prefetcher_i/read_master_axi_awprot
add wave -noupdate -group AXI-READ /top_wrapper_tb/top_i/nodeslot_prefetcher_i/read_master_axi_awqos
add wave -noupdate -group AXI-READ /top_wrapper_tb/top_i/nodeslot_prefetcher_i/read_master_axi_awvalid
add wave -noupdate -group AXI-READ /top_wrapper_tb/top_i/nodeslot_prefetcher_i/read_master_axi_awready
add wave -noupdate -group AXI-READ /top_wrapper_tb/top_i/nodeslot_prefetcher_i/read_master_axi_wdata
add wave -noupdate -group AXI-READ /top_wrapper_tb/top_i/nodeslot_prefetcher_i/read_master_axi_wstrb
add wave -noupdate -group AXI-READ /top_wrapper_tb/top_i/nodeslot_prefetcher_i/read_master_axi_wlast
add wave -noupdate -group AXI-READ /top_wrapper_tb/top_i/nodeslot_prefetcher_i/read_master_axi_wvalid
add wave -noupdate -group AXI-READ /top_wrapper_tb/top_i/nodeslot_prefetcher_i/read_master_axi_wready
add wave -noupdate -group AXI-READ /top_wrapper_tb/top_i/nodeslot_prefetcher_i/read_master_axi_bid
add wave -noupdate -group AXI-READ /top_wrapper_tb/top_i/nodeslot_prefetcher_i/read_master_axi_bresp
add wave -noupdate -group AXI-READ /top_wrapper_tb/top_i/nodeslot_prefetcher_i/read_master_axi_bvalid
add wave -noupdate -group AXI-READ /top_wrapper_tb/top_i/nodeslot_prefetcher_i/read_master_axi_bready
add wave -noupdate -group AXI-READ /top_wrapper_tb/top_i/nodeslot_prefetcher_i/read_master_axi_arid
add wave -noupdate -group AXI-READ /top_wrapper_tb/top_i/nodeslot_prefetcher_i/read_master_axi_araddr
add wave -noupdate -group AXI-READ /top_wrapper_tb/top_i/nodeslot_prefetcher_i/read_master_axi_arlen
add wave -noupdate -group AXI-READ /top_wrapper_tb/top_i/nodeslot_prefetcher_i/read_master_axi_arsize
add wave -noupdate -group AXI-READ /top_wrapper_tb/top_i/nodeslot_prefetcher_i/read_master_axi_arburst
add wave -noupdate -group AXI-READ /top_wrapper_tb/top_i/nodeslot_prefetcher_i/read_master_axi_arlock
add wave -noupdate -group AXI-READ /top_wrapper_tb/top_i/nodeslot_prefetcher_i/read_master_axi_arcache
add wave -noupdate -group AXI-READ /top_wrapper_tb/top_i/nodeslot_prefetcher_i/read_master_axi_arprot
add wave -noupdate -group AXI-READ /top_wrapper_tb/top_i/nodeslot_prefetcher_i/read_master_axi_arqos
add wave -noupdate -group AXI-READ /top_wrapper_tb/top_i/nodeslot_prefetcher_i/read_master_axi_arvalid
add wave -noupdate -group AXI-READ /top_wrapper_tb/top_i/nodeslot_prefetcher_i/read_master_axi_arready
add wave -noupdate -group AXI-READ /top_wrapper_tb/top_i/nodeslot_prefetcher_i/read_master_axi_rid
add wave -noupdate -group AXI-READ /top_wrapper_tb/top_i/nodeslot_prefetcher_i/read_master_axi_rdata
add wave -noupdate -group AXI-READ /top_wrapper_tb/top_i/nodeslot_prefetcher_i/read_master_axi_rresp
add wave -noupdate -group AXI-READ /top_wrapper_tb/top_i/nodeslot_prefetcher_i/read_master_axi_rlast
add wave -noupdate -group AXI-READ /top_wrapper_tb/top_i/nodeslot_prefetcher_i/read_master_axi_rvalid
add wave -noupdate -group AXI-READ /top_wrapper_tb/top_i/nodeslot_prefetcher_i/read_master_axi_rready
add wave -noupdate -group NSB /top_wrapper_tb/top_i/nodeslot_prefetcher_i/nsb_nodeslot_neighbour_count_count_hw
add wave -noupdate -group NSB /top_wrapper_tb/top_i/nodeslot_prefetcher_i/nsb_nodeslot_node_id_id_hw
add wave -noupdate -group NSB /top_wrapper_tb/top_i/nodeslot_prefetcher_i/nsb_nodeslot_precision_precision_hw
add wave -noupdate -group NSB /top_wrapper_tb/top_i/nodeslot_prefetcher_i/nsb_nodeslot_config_make_valid_value_hw
add wave -noupdate -group NSB /top_wrapper_tb/top_i/nodeslot_prefetcher_i/nsb_nodeslot_neighbour_count_strobe_hw
add wave -noupdate -group NSB /top_wrapper_tb/top_i/nodeslot_prefetcher_i/nsb_nodeslot_node_id_strobe_hw
add wave -noupdate -group NSB /top_wrapper_tb/top_i/nodeslot_prefetcher_i/nsb_nodeslot_precision_strobe_hw
add wave -noupdate -group NSB /top_wrapper_tb/top_i/nodeslot_prefetcher_i/nsb_nodeslot_config_make_valid_strobe_hw
add wave -noupdate -group NSB /top_wrapper_tb/top_i/nodeslot_prefetcher_i/nsb_nodeslot_neighbour_count_count_hw_n
add wave -noupdate -group NSB /top_wrapper_tb/top_i/nodeslot_prefetcher_i/nsb_nodeslot_node_id_id_hw_n
add wave -noupdate -group NSB /top_wrapper_tb/top_i/nodeslot_prefetcher_i/nsb_nodeslot_precision_precision_hw_n
add wave -noupdate -group NSB /top_wrapper_tb/top_i/nodeslot_prefetcher_i/nsb_nodeslot_config_make_valid_value_hw_n
add wave -noupdate -group Status /top_wrapper_tb/top_i/nodeslot_prefetcher_i/status_nodeslots_empty_mask_0_value
add wave -noupdate -group Status /top_wrapper_tb/top_i/nodeslot_prefetcher_i/status_nodeslots_empty_mask_1_value
add wave -noupdate -group Status /top_wrapper_tb/top_i/nodeslot_prefetcher_i/status_nodeslots_empty_mask_2_value
add wave -noupdate -group Status /top_wrapper_tb/top_i/nodeslot_prefetcher_i/status_nodeslots_empty_mask_3_value
add wave -noupdate -group Status /top_wrapper_tb/top_i/nodeslot_prefetcher_i/status_nodeslots_empty_mask_4_value
add wave -noupdate -group Status /top_wrapper_tb/top_i/nodeslot_prefetcher_i/status_nodeslots_empty_mask_5_value
add wave -noupdate -group Status /top_wrapper_tb/top_i/nodeslot_prefetcher_i/status_nodeslots_empty_mask_6_value
add wave -noupdate -group Status /top_wrapper_tb/top_i/nodeslot_prefetcher_i/status_nodeslots_empty_mask_7_value
add wave -noupdate -group Regbank /top_wrapper_tb/top_i/nodeslot_prefetcher_i/graph_config_node_count_value
add wave -noupdate -group Regbank /top_wrapper_tb/top_i/nodeslot_prefetcher_i/ctrl_start_nodeslot_fetch_value
add wave -noupdate -group Regbank /top_wrapper_tb/top_i/nodeslot_prefetcher_i/ctrl_start_nodeslot_fetch_done_value
add wave -noupdate -group Regbank /top_wrapper_tb/top_i/nodeslot_prefetcher_i/ctrl_start_nodeslot_fetch_done_ack_value
add wave -noupdate -group Fetch /top_wrapper_tb/top_i/nodeslot_prefetcher_i/fetch_req_valid
add wave -noupdate -group Fetch /top_wrapper_tb/top_i/nodeslot_prefetcher_i/fetch_req_ready
add wave -noupdate -group Fetch /top_wrapper_tb/top_i/nodeslot_prefetcher_i/fetch_start_address
add wave -noupdate -group Fetch /top_wrapper_tb/top_i/nodeslot_prefetcher_i/required_bytes
add wave -noupdate -group Fetch /top_wrapper_tb/top_i/nodeslot_prefetcher_i/fetch_resp_valid
add wave -noupdate -group Fetch /top_wrapper_tb/top_i/nodeslot_prefetcher_i/fetch_resp_last
add wave -noupdate -group Fetch /top_wrapper_tb/top_i/nodeslot_prefetcher_i/fetch_resp_data
add wave -noupdate -group Fetch /top_wrapper_tb/top_i/nodeslot_prefetcher_i/fetch_resp_data_q
add wave -noupdate -group Fetch /top_wrapper_tb/top_i/nodeslot_prefetcher_i/fetch_resp_axi_id
add wave -noupdate -group Logic /top_wrapper_tb/top_i/nodeslot_prefetcher_i/nodeslots_empty_status_mask
add wave -noupdate -group Logic /top_wrapper_tb/top_i/nodeslot_prefetcher_i/nodeslots_programmed_mask
add wave -noupdate -group Logic /top_wrapper_tb/top_i/nodeslot_prefetcher_i/nodeslot_free_mask
add wave -noupdate -group Logic /top_wrapper_tb/top_i/nodeslot_prefetcher_i/granted_nodeslot_oh
add wave -noupdate -group Logic /top_wrapper_tb/top_i/nodeslot_prefetcher_i/granted_nodeslot_bin
add wave -noupdate -group Logic /top_wrapper_tb/top_i/nodeslot_prefetcher_i/fetched_beat_valid
add wave -noupdate -group Logic /top_wrapper_tb/top_i/nodeslot_prefetcher_i/fetched_beat
add wave -noupdate -group Logic /top_wrapper_tb/top_i/nodeslot_prefetcher_i/slot_counter
add wave -noupdate -group Logic /top_wrapper_tb/top_i/nodeslot_prefetcher_i/required_transactions
add wave -noupdate -group Logic /top_wrapper_tb/top_i/nodeslot_prefetcher_i/fetched_nodeslots
add wave -noupdate -group Logic /top_wrapper_tb/top_i/nodeslot_prefetcher_i/next_node_id
add wave -noupdate -group Logic /top_wrapper_tb/top_i/nodeslot_prefetcher_i/nodeslot_finished
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {622 ps} 0}
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
WaveRestoreZoom {0 ps} {2473 ps}
