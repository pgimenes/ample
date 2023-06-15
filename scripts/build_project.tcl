# Create the build directory, ignoring any exception
catch {exec mkdir $env(FYP_DIR)/hw/build}
cd $env(FYP_DIR)/hw/build

set project_name "build_project"

# Check if the project exists
if {[file exists $project_name.xpr]} {
    puts "Build project already exists, opening it."
    open_project $project_name.xpr
} else {
    # Project doesn't exist, create a new project
    puts "Creating build project."
    create_project $project_name -part xcu250-figd2104-2L-e -force
    set_property board_part xilinx.com:au250:part0:1.3 [current_project]
}

# Update IP files
add_files $env(FYP_DIR)/hw/ip/aggregation_engine/include
add_files $env(FYP_DIR)/hw/ip/aggregation_engine/rtl
add_files $env(FYP_DIR)/hw/ip/include
add_files $env(FYP_DIR)/hw/ip/lib
add_files $env(FYP_DIR)/hw/ip/node_scoreboard/include
add_files $env(FYP_DIR)/hw/ip/node_scoreboard/rtl
add_files $env(FYP_DIR)/hw/ip/prefetcher/include
add_files $env(FYP_DIR)/hw/ip/prefetcher/rtl
add_files $env(FYP_DIR)/hw/ip/top/rtl
add_files $env(FYP_DIR)/hw/ip/transformation_engine/rtl
add_files $env(FYP_DIR)/imports/nocrouter/src/if
add_files $env(FYP_DIR)/imports/nocrouter/src/rtl

set_property top top_wrapper [current_fileset]

# Add testbench files
add_files $env(FYP_DIR)/imports/json_sv/sv
add_files $env(FYP_DIR)/hw/ip/aggregation_engine/tb
add_files $env(FYP_DIR)/hw/ip/node_scoreboard/tb
add_files $env(FYP_DIR)/hw/ip/prefetcher/tb
add_files $env(FYP_DIR)/hw/ip/top/tb
add_files $env(FYP_DIR)/hw/ip/tb_lib

set_property top top_tb [get_filesets sim_1]

# Add register banks
add_files -fileset sources_1 $env(FYP_DIR)/hw/build/regbanks/aggregation_engine_regbank
add_files -fileset sources_1 $env(FYP_DIR)/hw/build/regbanks/feature_transformation_engine_regbank
add_files -fileset sources_1 $env(FYP_DIR)/hw/build/regbanks/node_scoreboard_regbank
add_files -fileset sources_1 $env(FYP_DIR)/hw/build/regbanks/prefetcher_regbank

# Import Xilinx IP
import_ip -files $env(FYP_DIR)/hw/xilinx/axi_L_register_control_crossbar.xci
import_ip -files $env(FYP_DIR)/hw/xilinx/axi_memory_interconnect.xci
import_ip -files $env(FYP_DIR)/hw/xilinx/axi_memory_master_vip.xci
import_ip -files $env(FYP_DIR)/hw/xilinx/axil_master_vip.xci
import_ip -files $env(FYP_DIR)/hw/xilinx/fp_add.xci
import_ip -files $env(FYP_DIR)/hw/xilinx/fp_mult.xci
import_ip -files $env(FYP_DIR)/hw/xilinx/aggregation_buffer_sdp_bram.xci
import_ip -files $env(FYP_DIR)/hw/xilinx/transformation_buffer_sdp_bram.xci
import_ip -files $env(FYP_DIR)/hw/xilinx/fixed4_upsampler.xci
import_ip -files $env(FYP_DIR)/hw/xilinx/fixed8_upsampler.xci
import_ip -files $env(FYP_DIR)/hw/xilinx/fixed16_upsampler.xci
import_ip -files $env(FYP_DIR)/hw/xilinx/scale_factor_queue.xci
import_ip -files $env(FYP_DIR)/hw/xilinx/ddr4_0.xcix

generate_target all [get_ips]

# Add constraint files
add_files $env(FYP_DIR)/hw/constraints/constraints.xdc

# Generate simulation files
export_simulation -of_objects [get_files $env(FYP_DIR)/hw/build/build_project.srcs/sources_1/ip/axi_L_register_control_crossbar/axi_L_register_control_crossbar.xci] -directory $env(FYP_DIR)/hw/build/build_project.ip_user_files/sim_scripts -ip_user_files_dir $env(FYP_DIR)/hw/build/build_project.ip_user_files -ipstatic_source_dir $env(FYP_DIR)/hw/build/build_project.ip_user_files/ipstatic -lib_map_path [list {modelsim=$env(FYP_DIR)/hw/build/build_project.cache/compile_simlib/modelsim} {questa=$env(FYP_DIR)/hw/build/build_project.cache/compile_simlib/questa} {ies=$env(FYP_DIR)/hw/build/build_project.cache/compile_simlib/ies} {xcelium=$env(FYP_DIR)/hw/build/build_project.cache/compile_simlib/xcelium} {vcs=$env(FYP_DIR)/hw/build/build_project.cache/compile_simlib/vcs} {riviera=$env(FYP_DIR)/hw/build/build_project.cache/compile_simlib/riviera}] -use_ip_compiled_libs -force -quiet
export_simulation -of_objects [get_files $env(FYP_DIR)/hw/build/build_project.srcs/sources_1/ip/axi_memory_interconnect/axi_memory_interconnect.xci]                 -directory $env(FYP_DIR)/hw/build/build_project.ip_user_files/sim_scripts -ip_user_files_dir $env(FYP_DIR)/hw/build/build_project.ip_user_files -ipstatic_source_dir $env(FYP_DIR)/hw/build/build_project.ip_user_files/ipstatic -lib_map_path [list {modelsim=$env(FYP_DIR)/hw/build/build_project.cache/compile_simlib/modelsim} {questa=$env(FYP_DIR)/hw/build/build_project.cache/compile_simlib/questa} {ies=$env(FYP_DIR)/hw/build/build_project.cache/compile_simlib/ies} {xcelium=$env(FYP_DIR)/hw/build/build_project.cache/compile_simlib/xcelium} {vcs=$env(FYP_DIR)/hw/build/build_project.cache/compile_simlib/vcs} {riviera=$env(FYP_DIR)/hw/build/build_project.cache/compile_simlib/riviera}] -use_ip_compiled_libs -force -quiet
export_simulation -of_objects [get_files $env(FYP_DIR)/hw/build/build_project.srcs/sources_1/ip/axi_memory_master_vip/axi_memory_master_vip.xci]                     -directory $env(FYP_DIR)/hw/build/build_project.ip_user_files/sim_scripts -ip_user_files_dir $env(FYP_DIR)/hw/build/build_project.ip_user_files -ipstatic_source_dir $env(FYP_DIR)/hw/build/build_project.ip_user_files/ipstatic -lib_map_path [list {modelsim=$env(FYP_DIR)/hw/build/build_project.cache/compile_simlib/modelsim} {questa=$env(FYP_DIR)/hw/build/build_project.cache/compile_simlib/questa} {ies=$env(FYP_DIR)/hw/build/build_project.cache/compile_simlib/ies} {xcelium=$env(FYP_DIR)/hw/build/build_project.cache/compile_simlib/xcelium} {vcs=$env(FYP_DIR)/hw/build/build_project.cache/compile_simlib/vcs} {riviera=$env(FYP_DIR)/hw/build/build_project.cache/compile_simlib/riviera}] -use_ip_compiled_libs -force -quiet
export_simulation -of_objects [get_files $env(FYP_DIR)/hw/build/build_project.srcs/sources_1/ip/axil_master_vip/axil_master_vip.xci]                                 -directory $env(FYP_DIR)/hw/build/build_project.ip_user_files/sim_scripts -ip_user_files_dir $env(FYP_DIR)/hw/build/build_project.ip_user_files -ipstatic_source_dir $env(FYP_DIR)/hw/build/build_project.ip_user_files/ipstatic -lib_map_path [list {modelsim=$env(FYP_DIR)/hw/build/build_project.cache/compile_simlib/modelsim} {questa=$env(FYP_DIR)/hw/build/build_project.cache/compile_simlib/questa} {ies=$env(FYP_DIR)/hw/build/build_project.cache/compile_simlib/ies} {xcelium=$env(FYP_DIR)/hw/build/build_project.cache/compile_simlib/xcelium} {vcs=$env(FYP_DIR)/hw/build/build_project.cache/compile_simlib/vcs} {riviera=$env(FYP_DIR)/hw/build/build_project.cache/compile_simlib/riviera}] -use_ip_compiled_libs -force -quiet
export_simulation -of_objects [get_files $env(FYP_DIR)/hw/build/build_project.srcs/sources_1/ip/aggregation_buffer_sdp_bram/aggregation_buffer_sdp_bram.xci]         -directory $env(FYP_DIR)/hw/build/build_project.ip_user_files/sim_scripts -ip_user_files_dir $env(FYP_DIR)/hw/build/build_project.ip_user_files -ipstatic_source_dir $env(FYP_DIR)/hw/build/build_project.ip_user_files/ipstatic -lib_map_path [list {modelsim=$env(FYP_DIR)/hw/build/build_project.cache/compile_simlib/modelsim} {questa=$env(FYP_DIR)/hw/build/build_project.cache/compile_simlib/questa} {ies=$env(FYP_DIR)/hw/build/build_project.cache/compile_simlib/ies} {xcelium=$env(FYP_DIR)/hw/build/build_project.cache/compile_simlib/xcelium} {vcs=$env(FYP_DIR)/hw/build/build_project.cache/compile_simlib/vcs} {riviera=$env(FYP_DIR)/hw/build/build_project.cache/compile_simlib/riviera}] -use_ip_compiled_libs -force -quiet
export_simulation -of_objects [get_files $env(FYP_DIR)/hw/build/build_project.srcs/sources_1/ip/transformation_buffer_sdp_bram/transformation_buffer_sdp_bram.xci]   -directory $env(FYP_DIR)/hw/build/build_project.ip_user_files/sim_scripts -ip_user_files_dir $env(FYP_DIR)/hw/build/build_project.ip_user_files -ipstatic_source_dir $env(FYP_DIR)/hw/build/build_project.ip_user_files/ipstatic -lib_map_path [list {modelsim=$env(FYP_DIR)/hw/build/build_project.cache/compile_simlib/modelsim} {questa=$env(FYP_DIR)/hw/build/build_project.cache/compile_simlib/questa} {ies=$env(FYP_DIR)/hw/build/build_project.cache/compile_simlib/ies} {xcelium=$env(FYP_DIR)/hw/build/build_project.cache/compile_simlib/xcelium} {vcs=$env(FYP_DIR)/hw/build/build_project.cache/compile_simlib/vcs} {riviera=$env(FYP_DIR)/hw/build/build_project.cache/compile_simlib/riviera}] -use_ip_compiled_libs -force -quiet
export_simulation -of_objects [get_files $env(FYP_DIR)/hw/build/build_project.srcs/sources_1/ip/fixed4_upsampler/fixed4_upsampler.xci]                               -directory $env(FYP_DIR)/hw/build/build_project.ip_user_files/sim_scripts -ip_user_files_dir $env(FYP_DIR)/hw/build/build_project.ip_user_files -ipstatic_source_dir $env(FYP_DIR)/hw/build/build_project.ip_user_files/ipstatic -lib_map_path [list {modelsim=$env(FYP_DIR)/hw/build/build_project.cache/compile_simlib/modelsim} {questa=$env(FYP_DIR)/hw/build/build_project.cache/compile_simlib/questa} {ies=$env(FYP_DIR)/hw/build/build_project.cache/compile_simlib/ies} {xcelium=$env(FYP_DIR)/hw/build/build_project.cache/compile_simlib/xcelium} {vcs=$env(FYP_DIR)/hw/build/build_project.cache/compile_simlib/vcs} {riviera=$env(FYP_DIR)/hw/build/build_project.cache/compile_simlib/riviera}] -use_ip_compiled_libs -force -quiet
export_simulation -of_objects [get_files $env(FYP_DIR)/hw/build/build_project.srcs/sources_1/ip/fixed8_upsampler/fixed8_upsampler.xci]                               -directory $env(FYP_DIR)/hw/build/build_project.ip_user_files/sim_scripts -ip_user_files_dir $env(FYP_DIR)/hw/build/build_project.ip_user_files -ipstatic_source_dir $env(FYP_DIR)/hw/build/build_project.ip_user_files/ipstatic -lib_map_path [list {modelsim=$env(FYP_DIR)/hw/build/build_project.cache/compile_simlib/modelsim} {questa=$env(FYP_DIR)/hw/build/build_project.cache/compile_simlib/questa} {ies=$env(FYP_DIR)/hw/build/build_project.cache/compile_simlib/ies} {xcelium=$env(FYP_DIR)/hw/build/build_project.cache/compile_simlib/xcelium} {vcs=$env(FYP_DIR)/hw/build/build_project.cache/compile_simlib/vcs} {riviera=$env(FYP_DIR)/hw/build/build_project.cache/compile_simlib/riviera}] -use_ip_compiled_libs -force -quiet
export_simulation -of_objects [get_files $env(FYP_DIR)/hw/build/build_project.srcs/sources_1/ip/fixed16_upsampler/fixed16_upsampler.xci]                             -directory $env(FYP_DIR)/hw/build/build_project.ip_user_files/sim_scripts -ip_user_files_dir $env(FYP_DIR)/hw/build/build_project.ip_user_files -ipstatic_source_dir $env(FYP_DIR)/hw/build/build_project.ip_user_files/ipstatic -lib_map_path [list {modelsim=$env(FYP_DIR)/hw/build/build_project.cache/compile_simlib/modelsim} {questa=$env(FYP_DIR)/hw/build/build_project.cache/compile_simlib/questa} {ies=$env(FYP_DIR)/hw/build/build_project.cache/compile_simlib/ies} {xcelium=$env(FYP_DIR)/hw/build/build_project.cache/compile_simlib/xcelium} {vcs=$env(FYP_DIR)/hw/build/build_project.cache/compile_simlib/vcs} {riviera=$env(FYP_DIR)/hw/build/build_project.cache/compile_simlib/riviera}] -use_ip_compiled_libs -force -quiet
export_simulation -of_objects [get_files $env(FYP_DIR)/hw/build/build_project.srcs/sources_1/ip/fp_add/fp_add.xci]                                                   -directory $env(FYP_DIR)/hw/build/build_project.ip_user_files/sim_scripts -ip_user_files_dir $env(FYP_DIR)/hw/build/build_project.ip_user_files -ipstatic_source_dir $env(FYP_DIR)/hw/build/build_project.ip_user_files/ipstatic -lib_map_path [list {modelsim=$env(FYP_DIR)/hw/build/build_project.cache/compile_simlib/modelsim} {questa=$env(FYP_DIR)/hw/build/build_project.cache/compile_simlib/questa} {ies=$env(FYP_DIR)/hw/build/build_project.cache/compile_simlib/ies} {xcelium=$env(FYP_DIR)/hw/build/build_project.cache/compile_simlib/xcelium} {vcs=$env(FYP_DIR)/hw/build/build_project.cache/compile_simlib/vcs} {riviera=$env(FYP_DIR)/hw/build/build_project.cache/compile_simlib/riviera}] -use_ip_compiled_libs -force -quiet
export_simulation -of_objects [get_files $env(FYP_DIR)/hw/build/build_project.srcs/sources_1/ip/fp_mult/fp_mult.xci]                                                 -directory $env(FYP_DIR)/hw/build/build_project.ip_user_files/sim_scripts -ip_user_files_dir $env(FYP_DIR)/hw/build/build_project.ip_user_files -ipstatic_source_dir $env(FYP_DIR)/hw/build/build_project.ip_user_files/ipstatic -lib_map_path [list {modelsim=$env(FYP_DIR)/hw/build/build_project.cache/compile_simlib/modelsim} {questa=$env(FYP_DIR)/hw/build/build_project.cache/compile_simlib/questa} {ies=$env(FYP_DIR)/hw/build/build_project.cache/compile_simlib/ies} {xcelium=$env(FYP_DIR)/hw/build/build_project.cache/compile_simlib/xcelium} {vcs=$env(FYP_DIR)/hw/build/build_project.cache/compile_simlib/vcs} {riviera=$env(FYP_DIR)/hw/build/build_project.cache/compile_simlib/riviera}] -use_ip_compiled_libs -force -quiet
export_simulation -of_objects [get_files $env(FYP_DIR)/hw/build/build_project.srcs/sources_1/ip/scale_factor_queue/scale_factor_queue.xci]                           -directory $env(FYP_DIR)/hw/build/build_project.ip_user_files/sim_scripts -ip_user_files_dir $env(FYP_DIR)/hw/build/build_project.ip_user_files -ipstatic_source_dir $env(FYP_DIR)/hw/build/build_project.ip_user_files/ipstatic -lib_map_path [list {modelsim=$env(FYP_DIR)/hw/build/build_project.cache/compile_simlib/modelsim} {questa=$env(FYP_DIR)/hw/build/build_project.cache/compile_simlib/questa} {ies=$env(FYP_DIR)/hw/build/build_project.cache/compile_simlib/ies} {xcelium=$env(FYP_DIR)/hw/build/build_project.cache/compile_simlib/xcelium} {vcs=$env(FYP_DIR)/hw/build/build_project.cache/compile_simlib/vcs} {riviera=$env(FYP_DIR)/hw/build/build_project.cache/compile_simlib/riviera}] -use_ip_compiled_libs -force -quiet
export_simulation -of_objects [get_files $env(FYP_DIR)/hw/build/build_project.srcs/sources_1/ip/ddr4_0/ddr4_0.xcix]                                                  -directory $env(FYP_DIR)/hw/build/build_project.ip_user_files/sim_scripts -ip_user_files_dir $env(FYP_DIR)/hw/build/build_project.ip_user_files -ipstatic_source_dir $env(FYP_DIR)/hw/build/build_project.ip_user_files/ipstatic -lib_map_path [list {modelsim=$env(FYP_DIR)/hw/build/build_project.cache/compile_simlib/modelsim} {questa=$env(FYP_DIR)/hw/build/build_project.cache/compile_simlib/questa} {ies=$env(FYP_DIR)/hw/build/build_project.cache/compile_simlib/ies} {xcelium=$env(FYP_DIR)/hw/build/build_project.cache/compile_simlib/xcelium} {vcs=$env(FYP_DIR)/hw/build/build_project.cache/compile_simlib/vcs} {riviera=$env(FYP_DIR)/hw/build/build_project.cache/compile_simlib/riviera}] -use_ip_compiled_libs -force -quiet

# SYNTH
set_property STEPS.SYNTH_DESIGN.ARGS.FLATTEN_HIERARCHY none [get_runs synth_1]

# Compile simulation libraries for modelsim
# compile_simlib -simulator modelsim -simulator_exec_path {/mnt/applications/mentor/modelsim-2019.2/modelsim/modeltech/linux_x86_64} -family all -language all -library all -dir {$FYP_DIR/hw/build/build_project.cache/compile_simlib/modelsim} -verbose