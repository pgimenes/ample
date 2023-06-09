vlib modelsim_lib/work
vlib modelsim_lib/msim

vlib modelsim_lib/msim/xil_defaultlib

vmap xil_defaultlib modelsim_lib/msim/xil_defaultlib

vlog -64 -incr -sv -L axi_vip_v1_1_6 -L xilinx_vip -work xil_defaultlib  "+incdir+../../../../build_project.ip_user_files/ip/ddr4_0/ip_1/rtl/map" "+incdir+../../../../build_project.ip_user_files/ip/ddr4_0/rtl/ip_top" "+incdir+../../../../build_project.ip_user_files/ip/ddr4_0/rtl/cal" "+incdir+../../../../build_project.ip_user_files/ipstatic/hdl" "+incdir+../../../../../../imports/json_sv/sv" "+incdir+../../../../regbanks/aggregation_engine_regbank" "+incdir+../../../../regbanks/feature_transformation_engine_regbank" "+incdir+../../../../regbanks/node_scoreboard_regbank" "+incdir+../../../../regbanks/prefetcher_regbank" "+incdir+/mnt/applications/Xilinx/19.2/Vivado/2019.2/data/xilinx_vip/include" \
"../../../../build_project.srcs/sources_1/ip/axil_master_vip/sim/axil_master_vip_pkg.sv" \
"../../../../build_project.srcs/sources_1/ip/axil_master_vip/sim/axil_master_vip.sv" \

vlog -64 -incr -work xil_defaultlib  "+incdir+../../../../build_project.ip_user_files/ip/ddr4_0/ip_1/rtl/map" "+incdir+../../../../build_project.ip_user_files/ip/ddr4_0/rtl/ip_top" "+incdir+../../../../build_project.ip_user_files/ip/ddr4_0/rtl/cal" "+incdir+../../../../build_project.ip_user_files/ipstatic/hdl" "+incdir+../../../../../../imports/json_sv/sv" "+incdir+../../../../regbanks/aggregation_engine_regbank" "+incdir+../../../../regbanks/feature_transformation_engine_regbank" "+incdir+../../../../regbanks/node_scoreboard_regbank" "+incdir+../../../../regbanks/prefetcher_regbank" "+incdir+/mnt/applications/Xilinx/19.2/Vivado/2019.2/data/xilinx_vip/include" \
"../../../../build_project.srcs/sources_1/ip/axi_memory_interconnect/sim/axi_memory_interconnect.v" \
"../../../../build_project.srcs/sources_1/ip/axi_L_register_control_crossbar/sim/axi_L_register_control_crossbar.v" \

vcom -64 -93 -work xil_defaultlib  \
"../../../../build_project.srcs/sources_1/ip/fp_mult/sim/fp_mult.vhd" \
"../../../../build_project.srcs/sources_1/ip/fp_add/sim/fp_add.vhd" \

vlog -64 -incr -work xil_defaultlib  "+incdir+../../../../build_project.ip_user_files/ip/ddr4_0/ip_1/rtl/map" "+incdir+../../../../build_project.ip_user_files/ip/ddr4_0/rtl/ip_top" "+incdir+../../../../build_project.ip_user_files/ip/ddr4_0/rtl/cal" "+incdir+../../../../build_project.ip_user_files/ipstatic/hdl" "+incdir+../../../../../../imports/json_sv/sv" "+incdir+../../../../regbanks/aggregation_engine_regbank" "+incdir+../../../../regbanks/feature_transformation_engine_regbank" "+incdir+../../../../regbanks/node_scoreboard_regbank" "+incdir+../../../../regbanks/prefetcher_regbank" "+incdir+/mnt/applications/Xilinx/19.2/Vivado/2019.2/data/xilinx_vip/include" \
"../../../../build_project.srcs/sources_1/ip/transformation_buffer_sdp_bram/sim/transformation_buffer_sdp_bram.v" \
"../../../../build_project.srcs/sources_1/ip/aggregation_buffer_sdp_bram/sim/aggregation_buffer_sdp_bram.v" \
"../../../../build_project.srcs/sources_1/ip/scale_factor_queue/sim/scale_factor_queue.v" \
"../../../../ip/lib/buffers/ultraram.v" \

vlog -64 -incr -sv -L axi_vip_v1_1_6 -L xilinx_vip -work xil_defaultlib  "+incdir+../../../../build_project.ip_user_files/ip/ddr4_0/ip_1/rtl/map" "+incdir+../../../../build_project.ip_user_files/ip/ddr4_0/rtl/ip_top" "+incdir+../../../../build_project.ip_user_files/ip/ddr4_0/rtl/cal" "+incdir+../../../../build_project.ip_user_files/ipstatic/hdl" "+incdir+../../../../../../imports/json_sv/sv" "+incdir+../../../../regbanks/aggregation_engine_regbank" "+incdir+../../../../regbanks/feature_transformation_engine_regbank" "+incdir+../../../../regbanks/node_scoreboard_regbank" "+incdir+../../../../regbanks/prefetcher_regbank" "+incdir+/mnt/applications/Xilinx/19.2/Vivado/2019.2/data/xilinx_vip/include" \
"../../../../../../imports/nocrouter/src/rtl/noc/noc_pkg.sv" \
"../../../../ip/include/top_pkg.sv" \
"../../../../ip/lib/systolic_modules/activation_core.sv" \
"../../../../ip/aggregation_engine/include/age_pkg.sv" \
"../../../../../../imports/json_sv/sv/util.sv" \
"../../../../../../imports/json_sv/sv/json.sv" \

vlog -64 -incr -sv -L axi_vip_v1_1_6 -L xilinx_vip -L xil_defaultlib -work xil_defaultlib  "+incdir+../../../../build_project.ip_user_files/ip/ddr4_0/ip_1/rtl/map" "+incdir+../../../../build_project.ip_user_files/ip/ddr4_0/rtl/ip_top" "+incdir+../../../../build_project.ip_user_files/ip/ddr4_0/rtl/cal" "+incdir+../../../../build_project.ip_user_files/ipstatic/hdl" "+incdir+../../../../../../imports/json_sv/sv" "+incdir+../../../../regbanks/aggregation_engine_regbank" "+incdir+../../../../regbanks/feature_transformation_engine_regbank" "+incdir+../../../../regbanks/node_scoreboard_regbank" "+incdir+../../../../regbanks/prefetcher_regbank" "+incdir+/mnt/applications/Xilinx/19.2/Vivado/2019.2/data/xilinx_vip/include" \
"../../../../regbanks/aggregation_engine_regbank/aggregation_engine_regbank_regs_pkg.sv" \
"../../../../regbanks/aggregation_engine_regbank/aggregation_engine_regbank_regs.sv" \
"../../../../regbanks/aggregation_engine_regbank/aggregation_engine_regbank_wrapper.sv" \
"../../../../ip/aggregation_engine/rtl/aggregation_core.sv" \
"../../../../ip/aggregation_engine/rtl/aggregation_core_allocator.sv" \
"../../../../ip/aggregation_engine/rtl/aggregation_engine.sv" \
"../../../../ip/aggregation_engine/rtl/aggregation_manager.sv" \
"../../../../ip/aggregation_engine/rtl/aggregation_mesh.sv" \
"../../../../ip/aggregation_engine/rtl/buffer_manager.sv" \
"../../../../ip/aggregation_engine/rtl/feature_aggregator.sv" \
"../../../../ip/include/arch_package.sv" \
"../../../../ip/lib/axi/axi_read_master.sv" \
"../../../../ip/lib/axi/axi_write_master.sv" \
"../../../../ip/lib/base_components/binary_to_onehot.sv" \
"../../../../ip/lib/buffers/bram_fifo.sv" \
"../../../../../../imports/nocrouter/src/rtl/input_port/circular_buffer.sv" \
"../../../../ip/lib/base_components/count_ones.sv" \
"../../../../../../imports/nocrouter/src/rtl/crossbar/crossbar.sv" \
"../../../../ip/transformation_engine/rtl/feature_transformation_core.sv" \
"../../../../ip/transformation_engine/rtl/feature_transformation_engine.sv" \
"../../../../regbanks/feature_transformation_engine_regbank/feature_transformation_engine_regbank_regs_pkg.sv" \

vlog -64 -incr -sv -L axi_vip_v1_1_6 -L xilinx_vip -work xil_defaultlib  "+incdir+../../../../build_project.ip_user_files/ip/ddr4_0/ip_1/rtl/map" "+incdir+../../../../build_project.ip_user_files/ip/ddr4_0/rtl/ip_top" "+incdir+../../../../build_project.ip_user_files/ip/ddr4_0/rtl/cal" "+incdir+../../../../build_project.ip_user_files/ipstatic/hdl" "+incdir+../../../../../../imports/json_sv/sv" "+incdir+../../../../regbanks/aggregation_engine_regbank" "+incdir+../../../../regbanks/feature_transformation_engine_regbank" "+incdir+../../../../regbanks/node_scoreboard_regbank" "+incdir+../../../../regbanks/prefetcher_regbank" "+incdir+/mnt/applications/Xilinx/19.2/Vivado/2019.2/data/xilinx_vip/include" \
"../../../../regbanks/feature_transformation_engine_regbank/feature_transformation_engine_regbank_regs.sv" \
"../../../../regbanks/feature_transformation_engine_regbank/feature_transformation_engine_regbank_wrapper.sv" \
"../../../../ip/lib/arithmetic/fixed_point_mac.sv" \
"../../../../ip/lib/arithmetic/float_mac.sv" \
"../../../../regbanks/node_scoreboard_regbank/node_scoreboard_regbank_regs_pkg.sv" \

vlog -64 -incr -sv -L axi_vip_v1_1_6 -L xilinx_vip -work xil_defaultlib  "+incdir+../../../../build_project.ip_user_files/ip/ddr4_0/ip_1/rtl/map" "+incdir+../../../../build_project.ip_user_files/ip/ddr4_0/rtl/ip_top" "+incdir+../../../../build_project.ip_user_files/ip/ddr4_0/rtl/cal" "+incdir+../../../../build_project.ip_user_files/ipstatic/hdl" "+incdir+../../../../../../imports/json_sv/sv" "+incdir+../../../../regbanks/aggregation_engine_regbank" "+incdir+../../../../regbanks/feature_transformation_engine_regbank" "+incdir+../../../../regbanks/node_scoreboard_regbank" "+incdir+../../../../regbanks/prefetcher_regbank" "+incdir+/mnt/applications/Xilinx/19.2/Vivado/2019.2/data/xilinx_vip/include" \
"../../../../regbanks/prefetcher_regbank/prefetcher_regbank_regs_pkg.sv" \

vlog -64 -incr -sv -L axi_vip_v1_1_6 -L xilinx_vip -L xil_defaultlib -work xil_defaultlib  \
"+incdir+../../../../build_project.ip_user_files/ip/ddr4_0/ip_1/rtl/map" \
"+incdir+../../../../build_project.ip_user_files/ip/ddr4_0/rtl/ip_top" \
"+incdir+../../../../build_project.ip_user_files/ip/ddr4_0/rtl/cal" \
"+incdir+../../../../build_project.ip_user_files/ipstatic/hdl"\
"+incdir+../../../../../../imports/json_sv/sv" \
"+incdir+../../../../regbanks/aggregation_engine_regbank" \
"+incdir+../../../../regbanks/feature_transformation_engine_regbank" \
"+incdir+../../../../regbanks/node_scoreboard_regbank" \
"+incdir+../../../../regbanks/prefetcher_regbank" \
"+incdir+/mnt/applications/Xilinx/19.2/Vivado/2019.2/data/xilinx_vip/include" \
"+incdir+../../../../ip/aggregation_engine/tb" \
"+incdir+../../../../ip/prefetcher/tb" \
"+incdir+../../../../ip/node_scoreboard/tb" \
"../../../../ip/lib/buffers/hybrid_buffer/hybrid_buffer.sv" \
"../../../../ip/lib/buffers/hybrid_buffer/hybrid_buffer_driver.sv" \
"../../../../ip/lib/buffers/hybrid_buffer/hybrid_buffer_slot.sv" \
"../../../../../../imports/nocrouter/src/rtl/input_port/input_block.sv" \
"../../../../../../imports/nocrouter/src/if/input_block2crossbar.sv" \
"../../../../../../imports/nocrouter/src/if/input_block2switch_allocator.sv" \
"../../../../../../imports/nocrouter/src/if/input_block2vc_allocator.sv" \
"../../../../../../imports/nocrouter/src/rtl/input_port/input_buffer.sv" \
"../../../../../../imports/nocrouter/src/rtl/input_port/input_port.sv" \
"../../../../ip/lib/arithmetic/mac.sv" \
"../../../../../../imports/nocrouter/src/rtl/noc/mesh.sv" \
"../../../../../../imports/nocrouter/src/rtl/noc/node_link.sv" \
"../../../../ip/node_scoreboard/include/node_scoreboard_pkg.sv" \
"../../../../regbanks/node_scoreboard_regbank/node_scoreboard_regbank_regs.sv" \
"../../../../regbanks/node_scoreboard_regbank/node_scoreboard_regbank_wrapper.sv" \
"../../../../ip/tb_lib/node_scoreboard_tb.sv" \
"../../../../ip/lib/base_components/onehot_to_binary_comb.sv" \
"../../../../ip/lib/arithmetic/aggregators/passthrough_aggregator.sv" \
"../../../../ip/prefetcher/include/prefetcher_pkg.sv" \
"../../../../regbanks/prefetcher_regbank/prefetcher_regbank_regs.sv" \
"../../../../regbanks/prefetcher_regbank/prefetcher_regbank_wrapper.sv" \
"../../../../ip/prefetcher/rtl/prefetcher.sv" \
"../../../../ip/prefetcher/rtl/prefetcher_feature_bank.sv" \
"../../../../ip/prefetcher/rtl/prefetcher_fetch_tag.sv" \
"../../../../ip/prefetcher/rtl/prefetcher_streaming_manager.sv" \
"../../../../ip/prefetcher/rtl/prefetcher_weight_bank.sv" \
"../../../../ip/lib/systolic_modules/processing_element.sv" \
"../../../../../../imports/nocrouter/src/rtl/input_port/rc_unit.sv" \
"../../../../../../imports/nocrouter/src/rtl/allocators/round_robin_arbiter.sv" \
"../../../../../../imports/nocrouter/src/rtl/router/router.sv" \
"../../../../../../imports/nocrouter/src/if/router2router.sv" \
"../../../../../../imports/nocrouter/src/rtl/noc/router_link.sv" \
"../../../../ip/lib/base_components/rr_arbiter.sv" \
"../../../../../../imports/nocrouter/src/rtl/allocators/separable_input_first_allocator.sv" \
"../../../../ip/lib/arithmetic/aggregators/sum_aggregator.sv" \
"../../../../../../imports/nocrouter/src/rtl/allocators/switch_allocator.sv" \
"../../../../../../imports/nocrouter/src/if/switch_allocator2crossbar.sv" \
"../../../../ip/lib/systolic_modules/systolic_module.sv" \
"../../../../ip/node_scoreboard/rtl/node_scoreboard.sv" \
"../../../../ip/top/rtl/top.sv" \
"../../../../ip/lib/buffers/ultraram_fifo.sv" \
"../../../../../../imports/nocrouter/src/rtl/allocators/vc_allocator.sv" \
"../../../../ip/tb_lib/tb_utils.sv" \
"../../../../ip/aggregation_engine/tb/agc_allocator_monitor.sv" \
"../../../../ip/aggregation_engine/tb/agc_monitor.sv" \
"../../../../ip/aggregation_engine/tb/aggregation_engine_tb_monitor.sv" \
"../../../../ip/aggregation_engine/tb/agm_monitor.sv" \
"../../../../ip/aggregation_engine/tb/bm_monitor.sv" \
"../../../../ip/node_scoreboard/tb/node_scoreboard_tb_monitor.sv" \
"../../../../ip/prefetcher/tb/prefetcher_tb_monitor.sv" \
"../../../../ip/top/tb/test.sv" \
"../../../../ip/top/tb/graph_test.sv" \
"../../../../ip/top/tb/top_test.sv" \
"../../../../ip/top/tb/graph_test.sv" \
"../../../../ip/top/tb/top_tb.sv" \

# compile glbl module
vlog -work xil_defaultlib "glbl.v"

