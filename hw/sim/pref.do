onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /top_wrapper_tb/top_i/prefetcher_i/core_clk
add wave -noupdate /top_wrapper_tb/top_i/prefetcher_i/resetn
add wave -noupdate /top_wrapper_tb/top_i/prefetcher_i/regbank_clk
add wave -noupdate /top_wrapper_tb/top_i/prefetcher_i/regbank_resetn
add wave -noupdate -group NSB-PREF /top_wrapper_tb/top_i/prefetcher_i/nsb_prefetcher_req_valid
add wave -noupdate -group NSB-PREF /top_wrapper_tb/top_i/prefetcher_i/nsb_prefetcher_req_ready
add wave -noupdate -group NSB-PREF -expand /top_wrapper_tb/top_i/prefetcher_i/nsb_prefetcher_req
add wave -noupdate -group NSB-PREF /top_wrapper_tb/top_i/prefetcher_i/nsb_prefetcher_resp_valid
add wave -noupdate -group NSB-PREF -expand /top_wrapper_tb/top_i/prefetcher_i/nsb_prefetcher_resp
add wave -noupdate -group NSB-PREF /top_wrapper_tb/top_i/prefetcher_i/nsb_prefetcher_feature_bank_req_valid
add wave -noupdate -group NSB-PREF /top_wrapper_tb/top_i/prefetcher_i/nsb_prefetcher_feature_bank_req_ready
add wave -noupdate -group NSB-PREF /top_wrapper_tb/top_i/prefetcher_i/nsb_prefetcher_feature_bank_resp_valid
add wave -noupdate -group NSB-PREF /top_wrapper_tb/top_i/prefetcher_i/nsb_prefetcher_feature_bank_resp
add wave -noupdate -group NSB-PREF /top_wrapper_tb/top_i/prefetcher_i/nsb_prefetcher_weight_bank_req_valid
add wave -noupdate -group NSB-PREF /top_wrapper_tb/top_i/prefetcher_i/nsb_prefetcher_weight_bank_req_ready
add wave -noupdate -group NSB-PREF /top_wrapper_tb/top_i/prefetcher_i/nsb_prefetcher_weight_bank_resp_valid
add wave -noupdate -group NSB-PREF /top_wrapper_tb/top_i/prefetcher_i/nsb_prefetcher_weight_bank_resp
add wave -noupdate -group AXI-L /top_wrapper_tb/top_i/prefetcher_i/s_axi_awaddr
add wave -noupdate -group AXI-L /top_wrapper_tb/top_i/prefetcher_i/s_axi_awprot
add wave -noupdate -group AXI-L /top_wrapper_tb/top_i/prefetcher_i/s_axi_awvalid
add wave -noupdate -group AXI-L /top_wrapper_tb/top_i/prefetcher_i/s_axi_awready
add wave -noupdate -group AXI-L /top_wrapper_tb/top_i/prefetcher_i/s_axi_wdata
add wave -noupdate -group AXI-L /top_wrapper_tb/top_i/prefetcher_i/s_axi_wstrb
add wave -noupdate -group AXI-L /top_wrapper_tb/top_i/prefetcher_i/s_axi_wvalid
add wave -noupdate -group AXI-L /top_wrapper_tb/top_i/prefetcher_i/s_axi_wready
add wave -noupdate -group AXI-L /top_wrapper_tb/top_i/prefetcher_i/s_axi_araddr
add wave -noupdate -group AXI-L /top_wrapper_tb/top_i/prefetcher_i/s_axi_arprot
add wave -noupdate -group AXI-L /top_wrapper_tb/top_i/prefetcher_i/s_axi_arvalid
add wave -noupdate -group AXI-L /top_wrapper_tb/top_i/prefetcher_i/s_axi_arready
add wave -noupdate -group AXI-L /top_wrapper_tb/top_i/prefetcher_i/s_axi_rdata
add wave -noupdate -group AXI-L /top_wrapper_tb/top_i/prefetcher_i/s_axi_rresp
add wave -noupdate -group AXI-L /top_wrapper_tb/top_i/prefetcher_i/s_axi_rvalid
add wave -noupdate -group AXI-L /top_wrapper_tb/top_i/prefetcher_i/s_axi_rready
add wave -noupdate -group AXI-L /top_wrapper_tb/top_i/prefetcher_i/s_axi_bresp
add wave -noupdate -group AXI-L /top_wrapper_tb/top_i/prefetcher_i/s_axi_bvalid
add wave -noupdate -group AXI-L /top_wrapper_tb/top_i/prefetcher_i/s_axi_bready
add wave -noupdate -group {Read Master} -group RM-AXI /top_wrapper_tb/top_i/prefetcher_i/read_master_axi_araddr
add wave -noupdate -group {Read Master} -group RM-AXI /top_wrapper_tb/top_i/prefetcher_i/read_master_axi_arburst
add wave -noupdate -group {Read Master} -group RM-AXI /top_wrapper_tb/top_i/prefetcher_i/read_master_axi_arcache
add wave -noupdate -group {Read Master} -group RM-AXI /top_wrapper_tb/top_i/prefetcher_i/read_master_axi_arid
add wave -noupdate -group {Read Master} -group RM-AXI /top_wrapper_tb/top_i/prefetcher_i/read_master_axi_arlen
add wave -noupdate -group {Read Master} -group RM-AXI /top_wrapper_tb/top_i/prefetcher_i/read_master_axi_arlock
add wave -noupdate -group {Read Master} -group RM-AXI /top_wrapper_tb/top_i/prefetcher_i/read_master_axi_arprot
add wave -noupdate -group {Read Master} -group RM-AXI /top_wrapper_tb/top_i/prefetcher_i/read_master_axi_arqos
add wave -noupdate -group {Read Master} -group RM-AXI /top_wrapper_tb/top_i/prefetcher_i/read_master_axi_arsize
add wave -noupdate -group {Read Master} -group RM-AXI /top_wrapper_tb/top_i/prefetcher_i/read_master_axi_arvalid
add wave -noupdate -group {Read Master} -group RM-AXI /top_wrapper_tb/top_i/prefetcher_i/read_master_axi_arready
add wave -noupdate -group {Read Master} -group RM-AXI /top_wrapper_tb/top_i/prefetcher_i/read_master_axi_awaddr
add wave -noupdate -group {Read Master} -group RM-AXI /top_wrapper_tb/top_i/prefetcher_i/read_master_axi_awburst
add wave -noupdate -group {Read Master} -group RM-AXI /top_wrapper_tb/top_i/prefetcher_i/read_master_axi_awcache
add wave -noupdate -group {Read Master} -group RM-AXI /top_wrapper_tb/top_i/prefetcher_i/read_master_axi_awid
add wave -noupdate -group {Read Master} -group RM-AXI /top_wrapper_tb/top_i/prefetcher_i/read_master_axi_awlen
add wave -noupdate -group {Read Master} -group RM-AXI /top_wrapper_tb/top_i/prefetcher_i/read_master_axi_awlock
add wave -noupdate -group {Read Master} -group RM-AXI /top_wrapper_tb/top_i/prefetcher_i/read_master_axi_awprot
add wave -noupdate -group {Read Master} -group RM-AXI /top_wrapper_tb/top_i/prefetcher_i/read_master_axi_awqos
add wave -noupdate -group {Read Master} -group RM-AXI /top_wrapper_tb/top_i/prefetcher_i/read_master_axi_awready
add wave -noupdate -group {Read Master} -group RM-AXI /top_wrapper_tb/top_i/prefetcher_i/read_master_axi_awsize
add wave -noupdate -group {Read Master} -group RM-AXI /top_wrapper_tb/top_i/prefetcher_i/read_master_axi_awvalid
add wave -noupdate -group {Read Master} -group RM-AXI /top_wrapper_tb/top_i/prefetcher_i/read_master_axi_bid
add wave -noupdate -group {Read Master} -group RM-AXI /top_wrapper_tb/top_i/prefetcher_i/read_master_axi_bready
add wave -noupdate -group {Read Master} -group RM-AXI /top_wrapper_tb/top_i/prefetcher_i/read_master_axi_bresp
add wave -noupdate -group {Read Master} -group RM-AXI /top_wrapper_tb/top_i/prefetcher_i/read_master_axi_bvalid
add wave -noupdate -group {Read Master} -group RM-AXI /top_wrapper_tb/top_i/prefetcher_i/read_master_axi_rid
add wave -noupdate -group {Read Master} -group RM-AXI /top_wrapper_tb/top_i/prefetcher_i/read_master_axi_rlast
add wave -noupdate -group {Read Master} -group RM-AXI /top_wrapper_tb/top_i/prefetcher_i/read_master_axi_rready
add wave -noupdate -group {Read Master} -group RM-AXI /top_wrapper_tb/top_i/prefetcher_i/read_master_axi_rresp
add wave -noupdate -group {Read Master} -group RM-AXI /top_wrapper_tb/top_i/prefetcher_i/read_master_axi_rvalid
add wave -noupdate -group {Read Master} -group RM-AXI /top_wrapper_tb/top_i/prefetcher_i/read_master_axi_wlast
add wave -noupdate -group {Read Master} -group RM-AXI /top_wrapper_tb/top_i/prefetcher_i/read_master_axi_wready
add wave -noupdate -group {Read Master} -group RM-AXI /top_wrapper_tb/top_i/prefetcher_i/read_master_axi_wstrb
add wave -noupdate -group {Read Master} -group RM-AXI /top_wrapper_tb/top_i/prefetcher_i/read_master_axi_wvalid
add wave -noupdate -group {Read Master} -expand -group RM-INTERFACE /top_wrapper_tb/top_i/prefetcher_i/read_master_req_valid
add wave -noupdate -group {Read Master} -expand -group RM-INTERFACE /top_wrapper_tb/top_i/prefetcher_i/read_master_req_ready
add wave -noupdate -group {Read Master} -expand -group RM-INTERFACE -expand /top_wrapper_tb/top_i/prefetcher_i/read_master_start_address
add wave -noupdate -group {Read Master} -expand -group RM-INTERFACE -childformat {{{/top_wrapper_tb/top_i/prefetcher_i/read_master_byte_count[0]} -radix unsigned}} -subitemconfig {{/top_wrapper_tb/top_i/prefetcher_i/read_master_byte_count[0]} {-height 16 -radix unsigned}} /top_wrapper_tb/top_i/prefetcher_i/read_master_byte_count
add wave -noupdate -group {Read Master} -expand -group RM-INTERFACE /top_wrapper_tb/top_i/prefetcher_i/read_master_resp_valid
add wave -noupdate -group {Read Master} -expand -group RM-INTERFACE -childformat {{{/top_wrapper_tb/top_i/prefetcher_i/read_master_resp_data[31]} -radix unsigned}} -expand -subitemconfig {{/top_wrapper_tb/top_i/prefetcher_i/read_master_resp_data[31]} {-height 16 -radix unsigned}} /top_wrapper_tb/top_i/prefetcher_i/read_master_resp_data
add wave -noupdate -group {Read Master} -expand -group RM-INTERFACE /top_wrapper_tb/top_i/prefetcher_i/read_master_resp_ready
add wave -noupdate -group {Read Master} -expand -group RM-INTERFACE /top_wrapper_tb/top_i/prefetcher_i/read_master_resp_last
add wave -noupdate -group {Read Master} -expand -group RM-INTERFACE /top_wrapper_tb/top_i/prefetcher_i/read_master_resp_axi_id
add wave -noupdate -expand -group {Weight Bank AXI} -group {WB INTERFACE} /top_wrapper_tb/top_i/prefetcher_i/weight_bank_axi_rm_fetch_req_valid
add wave -noupdate -expand -group {Weight Bank AXI} -group {WB INTERFACE} /top_wrapper_tb/top_i/prefetcher_i/weight_read_master_fetch_req_ready
add wave -noupdate -expand -group {Weight Bank AXI} -group {WB INTERFACE} /top_wrapper_tb/top_i/prefetcher_i/weight_bank_axi_rm_fetch_req_ready
add wave -noupdate -expand -group {Weight Bank AXI} -group {WB INTERFACE} /top_wrapper_tb/top_i/prefetcher_i/weight_bank_axi_rm_fetch_start_address
add wave -noupdate -expand -group {Weight Bank AXI} -group {WB INTERFACE} /top_wrapper_tb/top_i/prefetcher_i/weight_bank_axi_rm_fetch_byte_count
add wave -noupdate -expand -group {Weight Bank AXI} -group {WB INTERFACE} /top_wrapper_tb/top_i/prefetcher_i/weight_read_master_fetch_resp_valid
add wave -noupdate -expand -group {Weight Bank AXI} -group {WB INTERFACE} /top_wrapper_tb/top_i/prefetcher_i/weight_bank_axi_rm_fetch_resp_valid
add wave -noupdate -expand -group {Weight Bank AXI} -group {WB INTERFACE} /top_wrapper_tb/top_i/prefetcher_i/weight_bank_axi_rm_fetch_resp_ready
add wave -noupdate -expand -group {Weight Bank AXI} -group {WB INTERFACE} /top_wrapper_tb/top_i/prefetcher_i/weight_read_master_resp_last
add wave -noupdate -expand -group {Weight Bank AXI} -group {WB INTERFACE} /top_wrapper_tb/top_i/prefetcher_i/weight_read_master_resp_data
add wave -noupdate -expand -group {Weight Bank AXI} -group {WB INTERFACE} /top_wrapper_tb/top_i/prefetcher_i/weight_read_master_resp_axi_id
add wave -noupdate -expand -group {Weight Bank AXI} -group {WB INTERFACE} /top_wrapper_tb/top_i/prefetcher_i/active_weight_fetch_precision
add wave -noupdate -expand -group {Weight Bank AXI} -group WB-AXI /top_wrapper_tb/top_i/prefetcher_i/weight_bank_axi_araddr
add wave -noupdate -expand -group {Weight Bank AXI} -group WB-AXI /top_wrapper_tb/top_i/prefetcher_i/weight_bank_axi_arburst
add wave -noupdate -expand -group {Weight Bank AXI} -group WB-AXI /top_wrapper_tb/top_i/prefetcher_i/weight_bank_axi_arcache
add wave -noupdate -expand -group {Weight Bank AXI} -group WB-AXI /top_wrapper_tb/top_i/prefetcher_i/weight_bank_axi_arid
add wave -noupdate -expand -group {Weight Bank AXI} -group WB-AXI /top_wrapper_tb/top_i/prefetcher_i/weight_bank_axi_arlen
add wave -noupdate -expand -group {Weight Bank AXI} -group WB-AXI /top_wrapper_tb/top_i/prefetcher_i/weight_bank_axi_arlock
add wave -noupdate -expand -group {Weight Bank AXI} -group WB-AXI /top_wrapper_tb/top_i/prefetcher_i/weight_bank_axi_arprot
add wave -noupdate -expand -group {Weight Bank AXI} -group WB-AXI /top_wrapper_tb/top_i/prefetcher_i/weight_bank_axi_arqos
add wave -noupdate -expand -group {Weight Bank AXI} -group WB-AXI /top_wrapper_tb/top_i/prefetcher_i/weight_bank_axi_arsize
add wave -noupdate -expand -group {Weight Bank AXI} -group WB-AXI /top_wrapper_tb/top_i/prefetcher_i/weight_bank_axi_arvalid
add wave -noupdate -expand -group {Weight Bank AXI} -group WB-AXI /top_wrapper_tb/top_i/prefetcher_i/weight_bank_axi_arready
add wave -noupdate -expand -group {Weight Bank AXI} -group WB-AXI /top_wrapper_tb/top_i/prefetcher_i/weight_bank_axi_awaddr
add wave -noupdate -expand -group {Weight Bank AXI} -group WB-AXI /top_wrapper_tb/top_i/prefetcher_i/weight_bank_axi_awburst
add wave -noupdate -expand -group {Weight Bank AXI} -group WB-AXI /top_wrapper_tb/top_i/prefetcher_i/weight_bank_axi_awcache
add wave -noupdate -expand -group {Weight Bank AXI} -group WB-AXI /top_wrapper_tb/top_i/prefetcher_i/weight_bank_axi_awid
add wave -noupdate -expand -group {Weight Bank AXI} -group WB-AXI /top_wrapper_tb/top_i/prefetcher_i/weight_bank_axi_awlen
add wave -noupdate -expand -group {Weight Bank AXI} -group WB-AXI /top_wrapper_tb/top_i/prefetcher_i/weight_bank_axi_awlock
add wave -noupdate -expand -group {Weight Bank AXI} -group WB-AXI /top_wrapper_tb/top_i/prefetcher_i/weight_bank_axi_awprot
add wave -noupdate -expand -group {Weight Bank AXI} -group WB-AXI /top_wrapper_tb/top_i/prefetcher_i/weight_bank_axi_awqos
add wave -noupdate -expand -group {Weight Bank AXI} -group WB-AXI /top_wrapper_tb/top_i/prefetcher_i/weight_bank_axi_awready
add wave -noupdate -expand -group {Weight Bank AXI} -group WB-AXI /top_wrapper_tb/top_i/prefetcher_i/weight_bank_axi_awsize
add wave -noupdate -expand -group {Weight Bank AXI} -group WB-AXI /top_wrapper_tb/top_i/prefetcher_i/weight_bank_axi_awvalid
add wave -noupdate -expand -group {Weight Bank AXI} -group WB-AXI /top_wrapper_tb/top_i/prefetcher_i/weight_bank_axi_bid
add wave -noupdate -expand -group {Weight Bank AXI} -group WB-AXI /top_wrapper_tb/top_i/prefetcher_i/weight_bank_axi_bready
add wave -noupdate -expand -group {Weight Bank AXI} -group WB-AXI /top_wrapper_tb/top_i/prefetcher_i/weight_bank_axi_bresp
add wave -noupdate -expand -group {Weight Bank AXI} -group WB-AXI /top_wrapper_tb/top_i/prefetcher_i/weight_bank_axi_bvalid
add wave -noupdate -expand -group {Weight Bank AXI} -group WB-AXI /top_wrapper_tb/top_i/prefetcher_i/weight_bank_axi_rdata
add wave -noupdate -expand -group {Weight Bank AXI} -group WB-AXI /top_wrapper_tb/top_i/prefetcher_i/weight_bank_axi_rid
add wave -noupdate -expand -group {Weight Bank AXI} -group WB-AXI /top_wrapper_tb/top_i/prefetcher_i/weight_bank_axi_rlast
add wave -noupdate -expand -group {Weight Bank AXI} -group WB-AXI /top_wrapper_tb/top_i/prefetcher_i/weight_bank_axi_rready
add wave -noupdate -expand -group {Weight Bank AXI} -group WB-AXI /top_wrapper_tb/top_i/prefetcher_i/weight_bank_axi_rresp
add wave -noupdate -expand -group {Weight Bank AXI} -group WB-AXI /top_wrapper_tb/top_i/prefetcher_i/weight_bank_axi_rvalid
add wave -noupdate -expand -group {Weight Bank AXI} -group WB-AXI /top_wrapper_tb/top_i/prefetcher_i/weight_bank_axi_wdata
add wave -noupdate -expand -group {Weight Bank AXI} -group WB-AXI /top_wrapper_tb/top_i/prefetcher_i/weight_bank_axi_wlast
add wave -noupdate -expand -group {Weight Bank AXI} -group WB-AXI /top_wrapper_tb/top_i/prefetcher_i/weight_bank_axi_wready
add wave -noupdate -expand -group {Weight Bank AXI} -group WB-AXI /top_wrapper_tb/top_i/prefetcher_i/weight_bank_axi_wstrb
add wave -noupdate -expand -group {Weight Bank AXI} -group WB-AXI /top_wrapper_tb/top_i/prefetcher_i/weight_bank_axi_wvalid
add wave -noupdate -expand -group {MESSAGE CHANNEL} /top_wrapper_tb/top_i/prefetcher_i/message_channel_req_valid
add wave -noupdate -expand -group {MESSAGE CHANNEL} /top_wrapper_tb/top_i/prefetcher_i/message_channel_req_ready
add wave -noupdate -expand -group {MESSAGE CHANNEL} /top_wrapper_tb/top_i/prefetcher_i/message_channel_req
add wave -noupdate -expand -group {MESSAGE CHANNEL} -expand /top_wrapper_tb/top_i/prefetcher_i/message_channel_resp
add wave -noupdate -expand -group {MESSAGE CHANNEL} {/top_wrapper_tb/top_i/prefetcher_i/message_channel_resp[14]}
add wave -noupdate -expand -group {MESSAGE CHANNEL} /top_wrapper_tb/top_i/prefetcher_i/message_channel_resp_valid
add wave -noupdate -expand -group {MESSAGE CHANNEL} /top_wrapper_tb/top_i/prefetcher_i/message_channel_resp_ready
add wave -noupdate -group {WEIGHT CHANNEL} /top_wrapper_tb/top_i/prefetcher_i/weight_channel_req_valid
add wave -noupdate -group {WEIGHT CHANNEL} /top_wrapper_tb/top_i/prefetcher_i/weight_channel_req_ready
add wave -noupdate -group {WEIGHT CHANNEL} /top_wrapper_tb/top_i/prefetcher_i/weight_channel_req
add wave -noupdate -group {WEIGHT CHANNEL} /top_wrapper_tb/top_i/prefetcher_i/weight_channel_resp_valid
add wave -noupdate -group {WEIGHT CHANNEL} {/top_wrapper_tb/top_i/prefetcher_i/genblk1[0]/weight_bank_i/weight_channel_resp}
add wave -noupdate -group {WEIGHT CHANNEL} /top_wrapper_tb/top_i/prefetcher_i/weight_channel_resp_ready
add wave -noupdate -group {SCALE FACTOR QUEUE} /top_wrapper_tb/top_i/prefetcher_i/scale_factor_queue_pop
add wave -noupdate -group {SCALE FACTOR QUEUE} /top_wrapper_tb/top_i/prefetcher_i/scale_factor_queue_out_valid
add wave -noupdate -group {SCALE FACTOR QUEUE} /top_wrapper_tb/top_i/prefetcher_i/scale_factor_queue_count
add wave -noupdate -group {SCALE FACTOR QUEUE} /top_wrapper_tb/top_i/prefetcher_i/scale_factor_queue_empty
add wave -noupdate -group {SCALE FACTOR QUEUE} /top_wrapper_tb/top_i/prefetcher_i/scale_factor_queue_full
add wave -noupdate -group {LAYER CONFIG} /top_wrapper_tb/top_i/prefetcher_i/layer_config_in_features_strobe
add wave -noupdate -group {LAYER CONFIG} /top_wrapper_tb/top_i/prefetcher_i/layer_config_in_features_count
add wave -noupdate -group {LAYER CONFIG} /top_wrapper_tb/top_i/prefetcher_i/layer_config_out_features_strobe
add wave -noupdate -group {LAYER CONFIG} /top_wrapper_tb/top_i/prefetcher_i/layer_config_out_features_count
add wave -noupdate -group {LAYER CONFIG} /top_wrapper_tb/top_i/prefetcher_i/layer_config_in_messages_address_lsb_strobe
add wave -noupdate -group {LAYER CONFIG} /top_wrapper_tb/top_i/prefetcher_i/layer_config_in_messages_address_lsb_value
add wave -noupdate -group {LAYER CONFIG} /top_wrapper_tb/top_i/prefetcher_i/layer_config_in_messages_address_msb_strobe
add wave -noupdate -group {LAYER CONFIG} /top_wrapper_tb/top_i/prefetcher_i/layer_config_in_messages_address_msb_value
add wave -noupdate -group {LAYER CONFIG} /top_wrapper_tb/top_i/prefetcher_i/layer_config_adjacency_list_address_lsb_strobe
add wave -noupdate -group {LAYER CONFIG} /top_wrapper_tb/top_i/prefetcher_i/layer_config_adjacency_list_address_lsb_value
add wave -noupdate -group {LAYER CONFIG} /top_wrapper_tb/top_i/prefetcher_i/layer_config_adjacency_list_address_msb_strobe
add wave -noupdate -group {LAYER CONFIG} /top_wrapper_tb/top_i/prefetcher_i/layer_config_adjacency_list_address_msb_value
add wave -noupdate -group {LAYER CONFIG} /top_wrapper_tb/top_i/prefetcher_i/layer_config_weights_address_lsb_strobe
add wave -noupdate -group {LAYER CONFIG} /top_wrapper_tb/top_i/prefetcher_i/layer_config_weights_address_lsb_value
add wave -noupdate -group {LAYER CONFIG} /top_wrapper_tb/top_i/prefetcher_i/layer_config_weights_address_msb_strobe
add wave -noupdate -group {LAYER CONFIG} /top_wrapper_tb/top_i/prefetcher_i/layer_config_weights_address_msb_value
add wave -noupdate -group {LAYER CONFIG} /top_wrapper_tb/top_i/prefetcher_i/layer_config_scale_factors_address_lsb_strobe
add wave -noupdate -group {LAYER CONFIG} /top_wrapper_tb/top_i/prefetcher_i/layer_config_scale_factors_address_lsb_value
add wave -noupdate -group {LAYER CONFIG} /top_wrapper_tb/top_i/prefetcher_i/layer_config_scale_factors_address_msb_strobe
add wave -noupdate -group {LAYER CONFIG} /top_wrapper_tb/top_i/prefetcher_i/layer_config_scale_factors_address_msb_value
add wave -noupdate -group WEIGHT-BANK {/top_wrapper_tb/top_i/prefetcher_i/genblk1[0]/weight_bank_i/core_clk}
add wave -noupdate -group WEIGHT-BANK {/top_wrapper_tb/top_i/prefetcher_i/genblk1[0]/weight_bank_i/resetn}
add wave -noupdate -group WEIGHT-BANK {/top_wrapper_tb/top_i/prefetcher_i/genblk1[0]/weight_bank_i/nsb_prefetcher_weight_bank_req_valid}
add wave -noupdate -group WEIGHT-BANK {/top_wrapper_tb/top_i/prefetcher_i/genblk1[0]/weight_bank_i/nsb_prefetcher_weight_bank_req_ready}
add wave -noupdate -group WEIGHT-BANK {/top_wrapper_tb/top_i/prefetcher_i/genblk1[0]/weight_bank_i/nsb_prefetcher_weight_bank_req}
add wave -noupdate -group WEIGHT-BANK {/top_wrapper_tb/top_i/prefetcher_i/genblk1[0]/weight_bank_i/nsb_prefetcher_weight_bank_resp_valid}
add wave -noupdate -group WEIGHT-BANK {/top_wrapper_tb/top_i/prefetcher_i/genblk1[0]/weight_bank_i/nsb_prefetcher_weight_bank_resp}
add wave -noupdate -group WEIGHT-BANK {/top_wrapper_tb/top_i/prefetcher_i/genblk1[0]/weight_bank_i/weight_bank_axi_rm_fetch_req_valid}
add wave -noupdate -group WEIGHT-BANK {/top_wrapper_tb/top_i/prefetcher_i/genblk1[0]/weight_bank_i/weight_bank_axi_rm_fetch_req_ready}
add wave -noupdate -group WEIGHT-BANK {/top_wrapper_tb/top_i/prefetcher_i/genblk1[0]/weight_bank_i/weight_bank_axi_rm_fetch_start_address}
add wave -noupdate -group WEIGHT-BANK {/top_wrapper_tb/top_i/prefetcher_i/genblk1[0]/weight_bank_i/weight_bank_axi_rm_fetch_byte_count}
add wave -noupdate -group WEIGHT-BANK {/top_wrapper_tb/top_i/prefetcher_i/genblk1[0]/weight_bank_i/weight_bank_axi_rm_fetch_resp_valid}
add wave -noupdate -group WEIGHT-BANK {/top_wrapper_tb/top_i/prefetcher_i/genblk1[0]/weight_bank_i/weight_bank_axi_rm_fetch_resp_ready}
add wave -noupdate -group WEIGHT-BANK {/top_wrapper_tb/top_i/prefetcher_i/genblk1[0]/weight_bank_i/weight_bank_axi_rm_fetch_resp_last}
add wave -noupdate -group WEIGHT-BANK {/top_wrapper_tb/top_i/prefetcher_i/genblk1[0]/weight_bank_i/weight_bank_axi_rm_fetch_resp_data}
add wave -noupdate -group WEIGHT-BANK {/top_wrapper_tb/top_i/prefetcher_i/genblk1[0]/weight_bank_i/weight_bank_axi_rm_fetch_resp_axi_id}
add wave -noupdate -group WEIGHT-BANK {/top_wrapper_tb/top_i/prefetcher_i/genblk1[0]/weight_bank_i/weight_channel_req_valid}
add wave -noupdate -group WEIGHT-BANK {/top_wrapper_tb/top_i/prefetcher_i/genblk1[0]/weight_bank_i/weight_channel_req_ready}
add wave -noupdate -group WEIGHT-BANK {/top_wrapper_tb/top_i/prefetcher_i/genblk1[0]/weight_bank_i/weight_channel_req}
add wave -noupdate -group WEIGHT-BANK {/top_wrapper_tb/top_i/prefetcher_i/genblk1[0]/weight_bank_i/weight_channel_resp_valid}
add wave -noupdate -group WEIGHT-BANK {/top_wrapper_tb/top_i/prefetcher_i/genblk1[0]/weight_bank_i/weight_channel_resp_ready}
add wave -noupdate -group WEIGHT-BANK {/top_wrapper_tb/top_i/prefetcher_i/genblk1[0]/weight_bank_i/layer_config_weights_address_lsb_value}
add wave -noupdate -group WEIGHT-BANK {/top_wrapper_tb/top_i/prefetcher_i/genblk1[0]/weight_bank_i/nsb_prefetcher_weight_bank_req_q}
add wave -noupdate -group WEIGHT-BANK {/top_wrapper_tb/top_i/prefetcher_i/genblk1[0]/weight_bank_i/weight_bank_state}
add wave -noupdate -group WEIGHT-BANK {/top_wrapper_tb/top_i/prefetcher_i/genblk1[0]/weight_bank_i/weight_bank_state_n}
add wave -noupdate -group WEIGHT-BANK {/top_wrapper_tb/top_i/prefetcher_i/genblk1[0]/weight_bank_i/accepting_weight_channel_resp}
add wave -noupdate -group WEIGHT-BANK {/top_wrapper_tb/top_i/prefetcher_i/genblk1[0]/weight_bank_i/row_fifo_push}
add wave -noupdate -group WEIGHT-BANK {/top_wrapper_tb/top_i/prefetcher_i/genblk1[0]/weight_bank_i/row_fifo_in_data}
add wave -noupdate -group WEIGHT-BANK {/top_wrapper_tb/top_i/prefetcher_i/genblk1[0]/weight_bank_i/row_fifo_pop}
add wave -noupdate -group WEIGHT-BANK {/top_wrapper_tb/top_i/prefetcher_i/genblk1[0]/weight_bank_i/row_fifo_out_valid}
add wave -noupdate -group WEIGHT-BANK {/top_wrapper_tb/top_i/prefetcher_i/genblk1[0]/weight_bank_i/row_fifo_out_data}
add wave -noupdate -group WEIGHT-BANK {/top_wrapper_tb/top_i/prefetcher_i/genblk1[0]/weight_bank_i/row_fifo_count}
add wave -noupdate -group WEIGHT-BANK {/top_wrapper_tb/top_i/prefetcher_i/genblk1[0]/weight_bank_i/row_fifo_empty}
add wave -noupdate -group WEIGHT-BANK {/top_wrapper_tb/top_i/prefetcher_i/genblk1[0]/weight_bank_i/row_fifo_full}
add wave -noupdate -group WEIGHT-BANK {/top_wrapper_tb/top_i/prefetcher_i/genblk1[0]/weight_bank_i/features_written}
add wave -noupdate -group WEIGHT-BANK {/top_wrapper_tb/top_i/prefetcher_i/genblk1[0]/weight_bank_i/rows_fetched}
add wave -noupdate -group WEIGHT-BANK {/top_wrapper_tb/top_i/prefetcher_i/genblk1[0]/weight_bank_i/feature_offset}
add wave -noupdate -group WEIGHT-BANK {/top_wrapper_tb/top_i/prefetcher_i/genblk1[0]/weight_bank_i/expected_responses}
add wave -noupdate -group WEIGHT-BANK {/top_wrapper_tb/top_i/prefetcher_i/genblk1[0]/weight_bank_i/weight_bank_axi_rm_fetch_resp_last_q}
add wave -noupdate -group WEIGHT-BANK {/top_wrapper_tb/top_i/prefetcher_i/genblk1[0]/weight_bank_i/weight_bank_axi_rm_fetch_resp_data_q}
add wave -noupdate -group WEIGHT-BANK {/top_wrapper_tb/top_i/prefetcher_i/genblk1[0]/weight_bank_i/weight_bank_axi_rm_fetch_resp_axi_id_q}
add wave -noupdate -group WEIGHT-BANK {/top_wrapper_tb/top_i/prefetcher_i/genblk1[0]/weight_bank_i/bytes_per_row}
add wave -noupdate -group WEIGHT-BANK {/top_wrapper_tb/top_i/prefetcher_i/genblk1[0]/weight_bank_i/bytes_per_row_padded}
add wave -noupdate -group WEIGHT-BANK {/top_wrapper_tb/top_i/prefetcher_i/genblk1[0]/weight_bank_i/required_pulses}
add wave -noupdate -group WEIGHT-BANK {/top_wrapper_tb/top_i/prefetcher_i/genblk1[0]/weight_bank_i/row_pop_shift}
add wave -noupdate -group WEIGHT-BANK {/top_wrapper_tb/top_i/prefetcher_i/genblk1[0]/weight_bank_i/row_counter}
add wave -noupdate -group WEIGHT-BANK {/top_wrapper_tb/top_i/prefetcher_i/genblk1[0]/weight_bank_i/reset_weights}
add wave -noupdate -group WEIGHT-BANK -divider FEATURE-BANK
add wave -noupdate -group FEATURE-BANK /top_wrapper_tb/top_i/prefetcher_i/feature_bank_i/allocation_valid
add wave -noupdate -group FEATURE-BANK /top_wrapper_tb/top_i/prefetcher_i/feature_bank_i/allocation_nodeslot
add wave -noupdate -group FEATURE-BANK /top_wrapper_tb/top_i/prefetcher_i/feature_bank_i/allocation_feature_count
add wave -noupdate -group FEATURE-BANK /top_wrapper_tb/top_i/prefetcher_i/feature_bank_i/deallocation_valid
add wave -noupdate -group FEATURE-BANK /top_wrapper_tb/top_i/prefetcher_i/feature_bank_i/tag_free
add wave -noupdate -group FEATURE-BANK -group FETCH-TAG-ADJ /top_wrapper_tb/top_i/prefetcher_i/feature_bank_i/fetch_tag_adj_rm_req_valid
add wave -noupdate -group FEATURE-BANK -group FETCH-TAG-ADJ /top_wrapper_tb/top_i/prefetcher_i/feature_bank_i/fetch_tag_adj_rm_req_ready
add wave -noupdate -group FEATURE-BANK -group FETCH-TAG-ADJ /top_wrapper_tb/top_i/prefetcher_i/feature_bank_i/fetch_tag_adj_rm_byte_count
add wave -noupdate -group FEATURE-BANK -group FETCH-TAG-ADJ /top_wrapper_tb/top_i/prefetcher_i/feature_bank_i/fetch_tag_adj_rm_resp_valid
add wave -noupdate -group FEATURE-BANK -group FETCH-TAG-ADJ /top_wrapper_tb/top_i/prefetcher_i/feature_bank_i/fetch_tag_adj_rm_resp_ready
add wave -noupdate -group FEATURE-BANK -group FETCH-TAG-ADJ /top_wrapper_tb/top_i/prefetcher_i/feature_bank_i/fetch_tag_adj_rm_resp_last
add wave -noupdate -group FEATURE-BANK -group FETCH-TAG-ADJ /top_wrapper_tb/top_i/prefetcher_i/feature_bank_i/fetch_tag_adj_rm_resp_axi_id
add wave -noupdate -group FEATURE-BANK -group FETCH-TAG-MSG /top_wrapper_tb/top_i/prefetcher_i/feature_bank_i/fetch_tag_msg_rm_req_valid
add wave -noupdate -group FEATURE-BANK -group FETCH-TAG-MSG /top_wrapper_tb/top_i/prefetcher_i/feature_bank_i/fetch_tag_msg_rm_req_ready
add wave -noupdate -group FEATURE-BANK -group FETCH-TAG-MSG /top_wrapper_tb/top_i/prefetcher_i/feature_bank_i/fetch_tag_msg_rm_byte_count
add wave -noupdate -group FEATURE-BANK -group FETCH-TAG-MSG /top_wrapper_tb/top_i/prefetcher_i/feature_bank_i/fetch_tag_msg_rm_resp_valid
add wave -noupdate -group FEATURE-BANK -group FETCH-TAG-MSG /top_wrapper_tb/top_i/prefetcher_i/feature_bank_i/fetch_tag_msg_rm_resp_ready
add wave -noupdate -group FEATURE-BANK -group FETCH-TAG-MSG /top_wrapper_tb/top_i/prefetcher_i/feature_bank_i/fetch_tag_msg_rm_resp_last
add wave -noupdate -group FEATURE-BANK -group FETCH-TAG-MSG /top_wrapper_tb/top_i/prefetcher_i/feature_bank_i/fetch_tag_msg_rm_resp_axi_id
add wave -noupdate -group FEATURE-BANK /top_wrapper_tb/top_i/prefetcher_i/feature_bank_i/fetch_tag_resp_arb
add wave -noupdate -group FEATURE-BANK /top_wrapper_tb/top_i/prefetcher_i/feature_bank_i/fetch_tag_resp_arb_bin
add wave -noupdate -group FEATURE-BANK /top_wrapper_tb/top_i/prefetcher_i/feature_bank_i/chosen_fetch_tag_rm_req_bin
add wave -noupdate -group FEATURE-BANK /top_wrapper_tb/top_i/prefetcher_i/feature_bank_i/chosen_fetch_tag_rm_req_bin_q
add wave -noupdate -group FEATURE-BANK /top_wrapper_tb/top_i/prefetcher_i/feature_bank_i/requesting_fetch_tags
add wave -noupdate -group FEATURE-BANK /top_wrapper_tb/top_i/prefetcher_i/feature_bank_i/fetch_req_was_adj_q
add wave -noupdate -group FEATURE-BANK /top_wrapper_tb/top_i/prefetcher_i/feature_bank_i/fetch_req_was_msg_q
add wave -noupdate -group FEATURE-BANK /top_wrapper_tb/top_i/prefetcher_i/feature_bank_i/read_master_req_fetch_tag
add wave -noupdate -group FEATURE-BANK /top_wrapper_tb/top_i/prefetcher_i/feature_bank_i/read_master_req_fetch_tag_q
add wave -noupdate -group FEATURE-BANK /top_wrapper_tb/top_i/prefetcher_i/feature_bank_i/fetch_tag_bank
add wave -noupdate -group FEATURE-BANK /top_wrapper_tb/top_i/prefetcher_i/feature_bank_i/chosen_ft_group_idx
add wave -noupdate -group FEATURE-BANK /top_wrapper_tb/top_i/prefetcher_i/feature_bank_i/AXI_ADDRESS_WIDTH
add wave -noupdate -group FEATURE-BANK /top_wrapper_tb/top_i/prefetcher_i/feature_bank_i/AXI_DATA_WIDTH
add wave -noupdate -group FEATURE-BANK /top_wrapper_tb/top_i/prefetcher_i/feature_bank_i/FETCH_TAG_COUNT
add wave -noupdate -group FEATURE-BANK /top_wrapper_tb/top_i/prefetcher_i/feature_bank_i/HBM_BANKS
add wave -noupdate -group FEATURE-BANK /top_wrapper_tb/top_i/prefetcher_i/feature_bank_i/FETCH_TAGS_PER_BANK
add wave -noupdate -group FEATURE-BANK /top_wrapper_tb/top_i/prefetcher_i/feature_bank_i/core_clk
add wave -noupdate -group FEATURE-BANK /top_wrapper_tb/top_i/prefetcher_i/feature_bank_i/resetn
add wave -noupdate -group FEATURE-BANK /top_wrapper_tb/top_i/prefetcher_i/feature_bank_i/nsb_prefetcher_feature_bank_req_valid
add wave -noupdate -group FEATURE-BANK /top_wrapper_tb/top_i/prefetcher_i/feature_bank_i/nsb_prefetcher_feature_bank_req_ready
add wave -noupdate -group FEATURE-BANK /top_wrapper_tb/top_i/prefetcher_i/feature_bank_i/nsb_prefetcher_feature_bank_req
add wave -noupdate -group FEATURE-BANK /top_wrapper_tb/top_i/prefetcher_i/feature_bank_i/nsb_prefetcher_feature_bank_resp_valid
add wave -noupdate -group FEATURE-BANK /top_wrapper_tb/top_i/prefetcher_i/feature_bank_i/nsb_prefetcher_feature_bank_resp
add wave -noupdate -group FEATURE-BANK /top_wrapper_tb/top_i/prefetcher_i/feature_bank_i/read_master_fetch_req_valid
add wave -noupdate -group FEATURE-BANK /top_wrapper_tb/top_i/prefetcher_i/feature_bank_i/read_master_fetch_req_ready
add wave -noupdate -group FEATURE-BANK /top_wrapper_tb/top_i/prefetcher_i/feature_bank_i/read_master_fetch_start_address
add wave -noupdate -group FEATURE-BANK /top_wrapper_tb/top_i/prefetcher_i/feature_bank_i/read_master_fetch_byte_count
add wave -noupdate -group FEATURE-BANK /top_wrapper_tb/top_i/prefetcher_i/feature_bank_i/read_master_fetch_resp_valid
add wave -noupdate -group FEATURE-BANK /top_wrapper_tb/top_i/prefetcher_i/feature_bank_i/read_master_fetch_resp_ready
add wave -noupdate -group FEATURE-BANK /top_wrapper_tb/top_i/prefetcher_i/feature_bank_i/read_master_fetch_resp_last
add wave -noupdate -group FEATURE-BANK /top_wrapper_tb/top_i/prefetcher_i/feature_bank_i/read_master_fetch_resp_data
add wave -noupdate -group FEATURE-BANK /top_wrapper_tb/top_i/prefetcher_i/feature_bank_i/read_master_fetch_resp_axi_id
add wave -noupdate -group FEATURE-BANK /top_wrapper_tb/top_i/prefetcher_i/feature_bank_i/message_channel_req_valid
add wave -noupdate -group FEATURE-BANK /top_wrapper_tb/top_i/prefetcher_i/feature_bank_i/message_channel_req_ready
add wave -noupdate -group FEATURE-BANK /top_wrapper_tb/top_i/prefetcher_i/feature_bank_i/message_channel_req
add wave -noupdate -group FEATURE-BANK /top_wrapper_tb/top_i/prefetcher_i/feature_bank_i/message_channel_resp_valid
add wave -noupdate -group FEATURE-BANK /top_wrapper_tb/top_i/prefetcher_i/feature_bank_i/message_channel_resp_ready
add wave -noupdate -group FEATURE-BANK /top_wrapper_tb/top_i/prefetcher_i/feature_bank_i/message_channel_resp
add wave -noupdate -group FEATURE-BANK /top_wrapper_tb/top_i/prefetcher_i/feature_bank_i/scale_factor_queue_pop
add wave -noupdate -group FEATURE-BANK /top_wrapper_tb/top_i/prefetcher_i/feature_bank_i/scale_factor_queue_out_valid
add wave -noupdate -group FEATURE-BANK /top_wrapper_tb/top_i/prefetcher_i/feature_bank_i/scale_factor_queue_out_data
add wave -noupdate -group FEATURE-BANK /top_wrapper_tb/top_i/prefetcher_i/feature_bank_i/scale_factor_queue_count
add wave -noupdate -group FEATURE-BANK /top_wrapper_tb/top_i/prefetcher_i/feature_bank_i/scale_factor_queue_empty
add wave -noupdate -group FEATURE-BANK /top_wrapper_tb/top_i/prefetcher_i/feature_bank_i/scale_factor_queue_full
add wave -noupdate -group FEATURE-BANK /top_wrapper_tb/top_i/prefetcher_i/feature_bank_i/layer_config_in_features_count
add wave -noupdate -group FEATURE-BANK /top_wrapper_tb/top_i/prefetcher_i/feature_bank_i/layer_config_adjacency_list_address_lsb_value
add wave -noupdate -group FEATURE-BANK /top_wrapper_tb/top_i/prefetcher_i/feature_bank_i/layer_config_in_messages_address_lsb_value
add wave -noupdate -group FEATURE-BANK /top_wrapper_tb/top_i/prefetcher_i/feature_bank_i/layer_config_scale_factors_address_lsb_value
add wave -noupdate -group FEATURE-BANK /top_wrapper_tb/top_i/prefetcher_i/feature_bank_i/layer_config_scale_factors_address_msb_value
add wave -noupdate -group FEATURE-BANK /top_wrapper_tb/top_i/prefetcher_i/feature_bank_i/allocation_valid
add wave -noupdate -group FEATURE-BANK /top_wrapper_tb/top_i/prefetcher_i/feature_bank_i/allocation_nodeslot
add wave -noupdate -group FEATURE-BANK /top_wrapper_tb/top_i/prefetcher_i/feature_bank_i/allocation_feature_count
add wave -noupdate -group FEATURE-BANK /top_wrapper_tb/top_i/prefetcher_i/feature_bank_i/deallocation_valid
add wave -noupdate -group FEATURE-BANK /top_wrapper_tb/top_i/prefetcher_i/feature_bank_i/tag_free
add wave -noupdate -group FEATURE-BANK /top_wrapper_tb/top_i/prefetcher_i/feature_bank_i/fetch_tag_adj_rm_req_valid
add wave -noupdate -group FEATURE-BANK /top_wrapper_tb/top_i/prefetcher_i/feature_bank_i/fetch_tag_adj_rm_req_ready
add wave -noupdate -group FEATURE-BANK /top_wrapper_tb/top_i/prefetcher_i/feature_bank_i/fetch_tag_adj_rm_start_address
add wave -noupdate -group FEATURE-BANK /top_wrapper_tb/top_i/prefetcher_i/feature_bank_i/fetch_tag_adj_rm_byte_count
add wave -noupdate -group FEATURE-BANK /top_wrapper_tb/top_i/prefetcher_i/feature_bank_i/fetch_tag_adj_rm_resp_valid
add wave -noupdate -group FEATURE-BANK /top_wrapper_tb/top_i/prefetcher_i/feature_bank_i/fetch_tag_adj_rm_resp_ready
add wave -noupdate -group FEATURE-BANK /top_wrapper_tb/top_i/prefetcher_i/feature_bank_i/fetch_tag_adj_rm_resp_last
add wave -noupdate -group FEATURE-BANK /top_wrapper_tb/top_i/prefetcher_i/feature_bank_i/fetch_tag_adj_rm_resp_data
add wave -noupdate -group FEATURE-BANK /top_wrapper_tb/top_i/prefetcher_i/feature_bank_i/fetch_tag_adj_rm_resp_axi_id
add wave -noupdate -group FEATURE-BANK /top_wrapper_tb/top_i/prefetcher_i/feature_bank_i/fetch_tag_msg_rm_req_valid
add wave -noupdate -group FEATURE-BANK /top_wrapper_tb/top_i/prefetcher_i/feature_bank_i/fetch_tag_msg_rm_req_ready
add wave -noupdate -group FEATURE-BANK /top_wrapper_tb/top_i/prefetcher_i/feature_bank_i/fetch_tag_msg_rm_start_address
add wave -noupdate -group FEATURE-BANK /top_wrapper_tb/top_i/prefetcher_i/feature_bank_i/fetch_tag_msg_rm_byte_count
add wave -noupdate -group FEATURE-BANK /top_wrapper_tb/top_i/prefetcher_i/feature_bank_i/fetch_tag_msg_rm_resp_valid
add wave -noupdate -group FEATURE-BANK /top_wrapper_tb/top_i/prefetcher_i/feature_bank_i/fetch_tag_msg_rm_resp_ready
add wave -noupdate -group FEATURE-BANK /top_wrapper_tb/top_i/prefetcher_i/feature_bank_i/fetch_tag_msg_rm_resp_last
add wave -noupdate -group FEATURE-BANK /top_wrapper_tb/top_i/prefetcher_i/feature_bank_i/fetch_tag_msg_rm_resp_data
add wave -noupdate -group FEATURE-BANK /top_wrapper_tb/top_i/prefetcher_i/feature_bank_i/fetch_tag_msg_rm_resp_axi_id
add wave -noupdate -group FEATURE-BANK /top_wrapper_tb/top_i/prefetcher_i/feature_bank_i/nsb_prefetcher_fetch_tag_req_valid
add wave -noupdate -group FEATURE-BANK /top_wrapper_tb/top_i/prefetcher_i/feature_bank_i/nsb_prefetcher_fetch_tag_req_ready
add wave -noupdate -group FEATURE-BANK /top_wrapper_tb/top_i/prefetcher_i/feature_bank_i/nsb_prefetcher_fetch_tag_req
add wave -noupdate -group FEATURE-BANK /top_wrapper_tb/top_i/prefetcher_i/feature_bank_i/nsb_prefetcher_fetch_tag_resp_valid
add wave -noupdate -group FEATURE-BANK /top_wrapper_tb/top_i/prefetcher_i/feature_bank_i/nsb_prefetcher_fetch_tag_resp
add wave -noupdate -group FEATURE-BANK /top_wrapper_tb/top_i/prefetcher_i/feature_bank_i/fetch_tag_resp_arb
add wave -noupdate -group FEATURE-BANK /top_wrapper_tb/top_i/prefetcher_i/feature_bank_i/fetch_tag_resp_arb_bin
add wave -noupdate -group FEATURE-BANK /top_wrapper_tb/top_i/prefetcher_i/feature_bank_i/chosen_fetch_tag_rm_req
add wave -noupdate -group FEATURE-BANK /top_wrapper_tb/top_i/prefetcher_i/feature_bank_i/chosen_fetch_tag_rm_req_bin
add wave -noupdate -group FEATURE-BANK /top_wrapper_tb/top_i/prefetcher_i/feature_bank_i/chosen_fetch_tag_rm_req_bin_q
add wave -noupdate -group FEATURE-BANK /top_wrapper_tb/top_i/prefetcher_i/feature_bank_i/requesting_fetch_tags
add wave -noupdate -group FEATURE-BANK /top_wrapper_tb/top_i/prefetcher_i/feature_bank_i/fetch_req_was_adj_q
add wave -noupdate -group FEATURE-BANK /top_wrapper_tb/top_i/prefetcher_i/feature_bank_i/fetch_req_was_msg_q
add wave -noupdate -group FEATURE-BANK /top_wrapper_tb/top_i/prefetcher_i/feature_bank_i/read_master_req_fetch_tag
add wave -noupdate -group FEATURE-BANK /top_wrapper_tb/top_i/prefetcher_i/feature_bank_i/read_master_req_fetch_tag_q
add wave -noupdate -group FEATURE-BANK /top_wrapper_tb/top_i/prefetcher_i/feature_bank_i/fetch_tag_bank
add wave -noupdate -group FEATURE-BANK /top_wrapper_tb/top_i/prefetcher_i/feature_bank_i/chosen_ft_group_idx
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {19678878 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 305
configure wave -valuecolwidth 230
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
WaveRestoreZoom {18863311 ps} {20315879 ps}
bookmark add wave bookmark2 {{17959609 ps} {22111537 ps}} 0
bookmark add wave bookmark3 {{18551117 ps} {18990769 ps}} 0
