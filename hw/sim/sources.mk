VERILOG_INCLUDE_DIRS = \
	$(WORKAREA)/hw/build/build_project.ip_user_files/ipstatic/hdl \
	$(WORKAREA)/imports/json_sv/sv \
	$(WORKAREA)/hw/build/regbanks/aggregation_engine_regbank \
	$(WORKAREA)/hw/build/regbanks/feature_transformation_engine_regbank \
	$(WORKAREA)/hw/build/regbanks/node_scoreboard_regbank \
	$(WORKAREA)/hw/build/regbanks/prefetcher_regbank \
	/mnt/applications/Xilinx/19.2/Vivado/2019.2/data/xilinx_vip/include \
	$(WORKAREA)/hw/build/ip/aggregation_engine/tb \
	$(WORKAREA)/hw/build/ip/prefetcher/tb \
	$(WORKAREA)/hw/build/ip/node_scoreboard/tb \

# Xilinx IP
VERILOG_SOURCES = \
	$(WORKAREA)/hw/sim/glbl.v \
	$(WORKAREA)/hw/build/build_project.ip_user_files/ipstatic/simulation/blk_mem_gen_v8_4.v \
	$(WORKAREA)/hw/build/build_project.srcs/sources_1/ip/axi_memory_interconnect/sim/axi_memory_interconnect.v \
	$(WORKAREA)/hw/build/build_project.srcs/sources_1/ip/axi_L_register_control_crossbar/sim/axi_L_register_control_crossbar.v \
	$(WORKAREA)/hw/build/build_project.srcs/sources_1/ip/transformation_buffer_sdp_bram/sim/transformation_buffer_sdp_bram.v \
	$(WORKAREA)/hw/build/build_project.srcs/sources_1/ip/aggregation_buffer_sdp_bram/sim/aggregation_buffer_sdp_bram.v \
	$(WORKAREA)/hw/build/build_project.srcs/sources_1/ip/scale_factor_queue/sim/scale_factor_queue.v \
	$(WORKAREA)/hw/build/ip/lib/buffers/ultraram.v \
	$(WORKAREA)/hw/build/ip/include/arch_defines.v \
	$(WORKAREA)/imports/verilog-axi/rtl/axi_ram.v \
	$(WORKAREA)/imports/verilog-axi/rtl/priority_encoder.v \
	$(WORKAREA)/imports/verilog-axi/rtl/arbiter.v \
	$(WORKAREA)/imports/verilog-axi/rtl/axil_crossbar.v \
	$(WORKAREA)/imports/verilog-axi/rtl/axil_interconnect.v \
	$(WORKAREA)/imports/verilog-axi/rtl/axil_interconnect_wrap_1x4.v \

# Imports
VERILOG_SOURCES += \
	$(WORKAREA)/hw/build/ip/include/arch_package.sv \
	$(WORKAREA)/imports/nocrouter/src/rtl/noc/noc_pkg.sv \
	$(WORKAREA)/imports/nocrouter/src/rtl/input_port/circular_buffer.sv \
	$(WORKAREA)/imports/nocrouter/src/rtl/crossbar/crossbar.sv \
	$(WORKAREA)/imports/nocrouter/src/rtl/input_port/input_block.sv \
	$(WORKAREA)/imports/nocrouter/src/if/input_block2crossbar.sv \
	$(WORKAREA)/imports/nocrouter/src/if/input_block2switch_allocator.sv \
	$(WORKAREA)/imports/nocrouter/src/if/input_block2vc_allocator.sv \
	$(WORKAREA)/imports/nocrouter/src/rtl/input_port/input_buffer.sv \
	$(WORKAREA)/imports/nocrouter/src/rtl/input_port/input_port.sv \
	$(WORKAREA)/imports/nocrouter/src/rtl/noc/mesh.sv \
	$(WORKAREA)/imports/nocrouter/src/rtl/noc/node_link.sv \
	$(WORKAREA)/imports/nocrouter/src/rtl/input_port/rc_unit.sv \
	$(WORKAREA)/imports/nocrouter/src/rtl/allocators/round_robin_arbiter.sv \
	$(WORKAREA)/imports/nocrouter/src/rtl/router/router.sv \
	$(WORKAREA)/imports/nocrouter/src/if/router2router.sv \
	$(WORKAREA)/imports/nocrouter/src/rtl/noc/router_link.sv \
	$(WORKAREA)/imports/nocrouter/src/rtl/allocators/separable_input_first_allocator.sv \
	$(WORKAREA)/imports/nocrouter/src/rtl/allocators/switch_allocator.sv \
	$(WORKAREA)/imports/nocrouter/src/if/switch_allocator2crossbar.sv \
	$(WORKAREA)/imports/nocrouter/src/rtl/allocators/vc_allocator.sv \

# Packages
VERILOG_SOURCES += \
	$(WORKAREA)/hw/build/ip/include/top_pkg.sv \
	$(WORKAREA)/hw/build/ip/aggregation_engine/include/age_pkg.sv \
	$(WORKAREA)/hw/build/ip/node_scoreboard/include/node_scoreboard_pkg.sv \
	$(WORKAREA)/hw/build/ip/prefetcher/include/prefetcher_pkg.sv \

# Register banks
VERILOG_SOURCES += \
	$(WORKAREA)/hw/build/regbanks/feature_transformation_engine_regbank/feature_transformation_engine_regbank_regs_pkg.sv \
	$(WORKAREA)/hw/build/regbanks/feature_transformation_engine_regbank/feature_transformation_engine_regbank_regs.sv \
	$(WORKAREA)/hw/build/regbanks/feature_transformation_engine_regbank/feature_transformation_engine_regbank_wrapper.sv \
	$(WORKAREA)/hw/build/regbanks/aggregation_engine_regbank/aggregation_engine_regbank_regs_pkg.sv \
	$(WORKAREA)/hw/build/regbanks/aggregation_engine_regbank/aggregation_engine_regbank_regs.sv \
	$(WORKAREA)/hw/build/regbanks/aggregation_engine_regbank/aggregation_engine_regbank_wrapper.sv \
	$(WORKAREA)/hw/build/regbanks/prefetcher_regbank/prefetcher_regbank_regs_pkg.sv \
	$(WORKAREA)/hw/build/regbanks/prefetcher_regbank/prefetcher_regbank_regs.sv \
	$(WORKAREA)/hw/build/regbanks/prefetcher_regbank/prefetcher_regbank_wrapper.sv \
	$(WORKAREA)/hw/build/regbanks/node_scoreboard_regbank/node_scoreboard_regbank_regs_pkg.sv \
	$(WORKAREA)/hw/build/regbanks/node_scoreboard_regbank/node_scoreboard_regbank_regs.sv \
	$(WORKAREA)/hw/build/regbanks/node_scoreboard_regbank/node_scoreboard_regbank_wrapper.sv \

# IP: Lib
VERILOG_SOURCES += \
	$(WORKAREA)/hw/build/ip/lib/axi/axi_read_master.sv \
	$(WORKAREA)/hw/build/ip/lib/axi/axi_write_master.sv \
	$(WORKAREA)/hw/build/ip/lib/base_components/binary_to_onehot.sv \
	$(WORKAREA)/hw/build/ip/lib/base_components/count_ones.sv \
	$(WORKAREA)/hw/build/ip/lib/base_components/onehot_to_binary_comb.sv \
	$(WORKAREA)/hw/build/ip/lib/base_components/rr_arbiter.sv \
	$(WORKAREA)/hw/build/ip/lib/arithmetic/fixed_point_mac.sv \
	$(WORKAREA)/hw/build/ip/lib/arithmetic/float_mac.sv \
	$(WORKAREA)/hw/build/ip/lib/arithmetic/mac.sv \
	$(WORKAREA)/hw/build/ip/lib/buffers/bram_fifo.sv \
	$(WORKAREA)/hw/build/ip/lib/buffers/hybrid_buffer/hybrid_buffer.sv \
	$(WORKAREA)/hw/build/ip/lib/buffers/hybrid_buffer/hybrid_buffer_driver.sv \
	$(WORKAREA)/hw/build/ip/lib/buffers/hybrid_buffer/hybrid_buffer_slot.sv \
	$(WORKAREA)/hw/build/ip/lib/buffers/ultraram_fifo.sv \
	$(WORKAREA)/hw/build/ip/lib/arithmetic/aggregators/passthrough_aggregator.sv \
	$(WORKAREA)/hw/build/ip/lib/systolic_modules/activation_core.sv \
	$(WORKAREA)/hw/build/ip/lib/systolic_modules/processing_element.sv \
	$(WORKAREA)/hw/build/ip/lib/arithmetic/aggregators/sum_aggregator.sv \
	$(WORKAREA)/hw/build/ip/lib/systolic_modules/systolic_module.sv \

# IP
VERILOG_SOURCES += \
	$(WORKAREA)/hw/build/ip/aggregation_engine/rtl/aggregation_core.sv \
	$(WORKAREA)/hw/build/ip/aggregation_engine/rtl/aggregation_core_allocator.sv \
	$(WORKAREA)/hw/build/ip/aggregation_engine/rtl/aggregation_engine.sv \
	$(WORKAREA)/hw/build/ip/aggregation_engine/rtl/aggregation_manager.sv \
	$(WORKAREA)/hw/build/ip/aggregation_engine/rtl/aggregation_mesh.sv \
	$(WORKAREA)/hw/build/ip/aggregation_engine/rtl/buffer_manager.sv \
	$(WORKAREA)/hw/build/ip/aggregation_engine/rtl/buffer_manager_arbiter.sv \
	$(WORKAREA)/hw/build/ip/aggregation_engine/rtl/feature_aggregator.sv \
	$(WORKAREA)/hw/build/ip/transformation_engine/rtl/feature_transformation_core.sv \
	$(WORKAREA)/hw/build/ip/transformation_engine/rtl/feature_transformation_engine.sv \
	$(WORKAREA)/hw/build/ip/prefetcher/rtl/prefetcher.sv \
	$(WORKAREA)/hw/build/ip/prefetcher/rtl/prefetcher_feature_bank.sv \
	$(WORKAREA)/hw/build/ip/prefetcher/rtl/prefetcher_fetch_tag.sv \
	$(WORKAREA)/hw/build/ip/prefetcher/rtl/prefetcher_streaming_manager.sv \
	$(WORKAREA)/hw/build/ip/prefetcher/rtl/prefetcher_weight_bank.sv \
	$(WORKAREA)/hw/build/ip/node_scoreboard/rtl/node_scoreboard.sv \
	$(WORKAREA)/hw/build/ip/top/rtl/top.sv \
	$(WORKAREA)/hw/build/ip/top/rtl/top_wrapper_tb.sv \
	$(WORKAREA)/hw/build/ip/aggregation_engine/tb/agc_allocator_interface.sv \
	$(WORKAREA)/hw/build/ip/aggregation_engine/tb/agc_interface.sv \
	$(WORKAREA)/hw/build/ip/aggregation_engine/tb/aggregation_engine_interface.sv \
	$(WORKAREA)/hw/build/ip/aggregation_engine/tb/agm_interface.sv \
	$(WORKAREA)/hw/build/ip/aggregation_engine/tb/bm_interface.sv

VSIM_LIBS = \
	axi_infrastructure_v1_1_0 \
	axi_vip_v1_1_6 \
	fifo_generator_v13_2_5 \
	axi_interconnect_v1_7_17 \
	generic_baseblocks_v2_1_0 \
	axi_register_slice_v2_1_20 \
	axi_data_fifo_v2_1_19 \
	axi_crossbar_v2_1_21 \
	xbip_utils_v3_0_10 \
	axi_utils_v2_0_6 \
	floating_point_v7_1_9 \
	xilinx_vip \
	unisims_ver \
	unimacro_ver \
	secureip \
	xpm
	
LIST_DONE = 1