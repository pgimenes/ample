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
add wave -noupdate -group NSB-AGE /top_wrapper_tb/top_i/aggregation_engine_i/nsb_age_req_valid
add wave -noupdate -group NSB-AGE /top_wrapper_tb/top_i/aggregation_engine_i/nsb_age_req_ready
add wave -noupdate -group NSB-AGE /top_wrapper_tb/top_i/aggregation_engine_i/nsb_age_req
add wave -noupdate -group NSB-AGE /top_wrapper_tb/top_i/aggregation_engine_i/nsb_age_resp_valid
add wave -noupdate -group NSB-AGE /top_wrapper_tb/top_i/aggregation_engine_i/nsb_age_resp
add wave -noupdate -group Msg-Chan /top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req_valid
add wave -noupdate -group Msg-Chan /top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req_ready
add wave -noupdate -group Msg-Chan /top_wrapper_tb/top_i/aggregation_engine_i/message_channel_req
add wave -noupdate -group Msg-Chan /top_wrapper_tb/top_i/aggregation_engine_i/message_channel_resp_valid
add wave -noupdate -group Msg-Chan /top_wrapper_tb/top_i/aggregation_engine_i/message_channel_resp_ready
add wave -noupdate -group Agg-BuffSlot /top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_set_node_id_valid
add wave -noupdate -group Agg-BuffSlot /top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_set_node_id
add wave -noupdate -group Agg-BuffSlot /top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_write_enable
add wave -noupdate -group Agg-BuffSlot /top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_write_address
add wave -noupdate -group Agg-BuffSlot /top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_feature_count
add wave -noupdate -group Agg-BuffSlot /top_wrapper_tb/top_i/aggregation_engine_i/aggregation_buffer_slot_slot_free
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
add wave -noupdate -group BM /top_wrapper_tb/top_i/aggregation_engine_i/bm_set_node_id_valid
add wave -noupdate -group BM /top_wrapper_tb/top_i/aggregation_engine_i/bm_set_node_id_ready
add wave -noupdate -group BM /top_wrapper_tb/top_i/aggregation_engine_i/bm_set_node_id
add wave -noupdate -group BM /top_wrapper_tb/top_i/aggregation_engine_i/bm_write_enable
add wave -noupdate -group BM /top_wrapper_tb/top_i/aggregation_engine_i/bm_write_ready
add wave -noupdate -group BM /top_wrapper_tb/top_i/aggregation_engine_i/bm_write_address
add wave -noupdate -group BM /top_wrapper_tb/top_i/aggregation_engine_i/buffer_manager_done
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {59 ps} 0}
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
WaveRestoreZoom {0 ps} {865 ps}
