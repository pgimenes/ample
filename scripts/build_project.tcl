# Create the build directory, ignoring any exception
catch {exec mkdir $env(WORKAREA)/hw/build}
cd $env(WORKAREA)/hw/build

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
add_files $env(WORKAREA)/hw/ip/aggregation_engine/include
add_files $env(WORKAREA)/hw/ip/aggregation_engine/rtl
add_files $env(WORKAREA)/hw/ip/include
add_files $env(WORKAREA)/hw/ip/lib
add_files $env(WORKAREA)/hw/ip/node_scoreboard/include
add_files $env(WORKAREA)/hw/ip/node_scoreboard/rtl
add_files $env(WORKAREA)/hw/ip/prefetcher/include
add_files $env(WORKAREA)/hw/ip/prefetcher/rtl
add_files $env(WORKAREA)/hw/ip/top/rtl
add_files $env(WORKAREA)/hw/ip/transformation_engine/rtl

set_property top top_wrapper [current_fileset]

# Add imported IP
add_files $env(WORKAREA)/imports/nocrouter/src/if
add_files $env(WORKAREA)/imports/nocrouter/src/rtl
add_files $env(WORKAREA)/imports/verilog-axi/rtl/

set_property top top_tb [get_filesets sim_1]

# Add register banks
add_files -fileset sources_1 $env(WORKAREA)/hw/build/regbanks/aggregation_engine_regbank
add_files -fileset sources_1 $env(WORKAREA)/hw/build/regbanks/feature_transformation_engine_regbank
add_files -fileset sources_1 $env(WORKAREA)/hw/build/regbanks/node_scoreboard_regbank
add_files -fileset sources_1 $env(WORKAREA)/hw/build/regbanks/prefetcher_regbank

# Import Xilinx IP
import_ip -files $env(WORKAREA)/hw/xilinx_ip/axi_memory_interconnect.xci
import_ip -files $env(WORKAREA)/hw/xilinx_ip/fp_add.xci
import_ip -files $env(WORKAREA)/hw/xilinx_ip/fp_mult.xci
import_ip -files $env(WORKAREA)/hw/xilinx_ip/aggregation_buffer_sdp_bram.xci
import_ip -files $env(WORKAREA)/hw/xilinx_ip/scale_factor_queue.xci
import_ip -files $env(WORKAREA)/hw/xilinx_ip/ddr4_0.xcix

generate_target all [get_ips]

# Add constraint files
add_files $env(WORKAREA)/hw/constraints/constraints.xdc

# Generate simulation files
export_simulation -of_objects [get_files $env(WORKAREA)/hw/build/build_project.srcs/sources_1/ip/axi_memory_interconnect/axi_memory_interconnect.xci]                 -directory $env(WORKAREA)/hw/build/build_project.ip_user_files/sim_scripts -ip_user_files_dir $env(WORKAREA)/hw/build/build_project.ip_user_files -ipstatic_source_dir $env(WORKAREA)/hw/build/build_project.ip_user_files/ipstatic -lib_map_path [list {modelsim=$env(WORKAREA)/hw/build/build_project.cache/compile_simlib/modelsim} {questa=$env(WORKAREA)/hw/build/build_project.cache/compile_simlib/questa} {ies=$env(WORKAREA)/hw/build/build_project.cache/compile_simlib/ies} {xcelium=$env(WORKAREA)/hw/build/build_project.cache/compile_simlib/xcelium} {vcs=$env(WORKAREA)/hw/build/build_project.cache/compile_simlib/vcs} {riviera=$env(WORKAREA)/hw/build/build_project.cache/compile_simlib/riviera}] -use_ip_compiled_libs -force -quiet
export_simulation -of_objects [get_files $env(WORKAREA)/hw/build/build_project.srcs/sources_1/ip/aggregation_buffer_sdp_bram/aggregation_buffer_sdp_bram.xci]         -directory $env(WORKAREA)/hw/build/build_project.ip_user_files/sim_scripts -ip_user_files_dir $env(WORKAREA)/hw/build/build_project.ip_user_files -ipstatic_source_dir $env(WORKAREA)/hw/build/build_project.ip_user_files/ipstatic -lib_map_path [list {modelsim=$env(WORKAREA)/hw/build/build_project.cache/compile_simlib/modelsim} {questa=$env(WORKAREA)/hw/build/build_project.cache/compile_simlib/questa} {ies=$env(WORKAREA)/hw/build/build_project.cache/compile_simlib/ies} {xcelium=$env(WORKAREA)/hw/build/build_project.cache/compile_simlib/xcelium} {vcs=$env(WORKAREA)/hw/build/build_project.cache/compile_simlib/vcs} {riviera=$env(WORKAREA)/hw/build/build_project.cache/compile_simlib/riviera}] -use_ip_compiled_libs -force -quiet
export_simulation -of_objects [get_files $env(WORKAREA)/hw/build/build_project.srcs/sources_1/ip/fp_add/fp_add.xci]                                                   -directory $env(WORKAREA)/hw/build/build_project.ip_user_files/sim_scripts -ip_user_files_dir $env(WORKAREA)/hw/build/build_project.ip_user_files -ipstatic_source_dir $env(WORKAREA)/hw/build/build_project.ip_user_files/ipstatic -lib_map_path [list {modelsim=$env(WORKAREA)/hw/build/build_project.cache/compile_simlib/modelsim} {questa=$env(WORKAREA)/hw/build/build_project.cache/compile_simlib/questa} {ies=$env(WORKAREA)/hw/build/build_project.cache/compile_simlib/ies} {xcelium=$env(WORKAREA)/hw/build/build_project.cache/compile_simlib/xcelium} {vcs=$env(WORKAREA)/hw/build/build_project.cache/compile_simlib/vcs} {riviera=$env(WORKAREA)/hw/build/build_project.cache/compile_simlib/riviera}] -use_ip_compiled_libs -force -quiet
export_simulation -of_objects [get_files $env(WORKAREA)/hw/build/build_project.srcs/sources_1/ip/fp_mult/fp_mult.xci]                                                 -directory $env(WORKAREA)/hw/build/build_project.ip_user_files/sim_scripts -ip_user_files_dir $env(WORKAREA)/hw/build/build_project.ip_user_files -ipstatic_source_dir $env(WORKAREA)/hw/build/build_project.ip_user_files/ipstatic -lib_map_path [list {modelsim=$env(WORKAREA)/hw/build/build_project.cache/compile_simlib/modelsim} {questa=$env(WORKAREA)/hw/build/build_project.cache/compile_simlib/questa} {ies=$env(WORKAREA)/hw/build/build_project.cache/compile_simlib/ies} {xcelium=$env(WORKAREA)/hw/build/build_project.cache/compile_simlib/xcelium} {vcs=$env(WORKAREA)/hw/build/build_project.cache/compile_simlib/vcs} {riviera=$env(WORKAREA)/hw/build/build_project.cache/compile_simlib/riviera}] -use_ip_compiled_libs -force -quiet
export_simulation -of_objects [get_files $env(WORKAREA)/hw/build/build_project.srcs/sources_1/ip/scale_factor_queue/scale_factor_queue.xci]                           -directory $env(WORKAREA)/hw/build/build_project.ip_user_files/sim_scripts -ip_user_files_dir $env(WORKAREA)/hw/build/build_project.ip_user_files -ipstatic_source_dir $env(WORKAREA)/hw/build/build_project.ip_user_files/ipstatic -lib_map_path [list {modelsim=$env(WORKAREA)/hw/build/build_project.cache/compile_simlib/modelsim} {questa=$env(WORKAREA)/hw/build/build_project.cache/compile_simlib/questa} {ies=$env(WORKAREA)/hw/build/build_project.cache/compile_simlib/ies} {xcelium=$env(WORKAREA)/hw/build/build_project.cache/compile_simlib/xcelium} {vcs=$env(WORKAREA)/hw/build/build_project.cache/compile_simlib/vcs} {riviera=$env(WORKAREA)/hw/build/build_project.cache/compile_simlib/riviera}] -use_ip_compiled_libs -force -quiet
export_simulation -of_objects [get_files $env(WORKAREA)/hw/build/build_project.srcs/sources_1/ip/ddr4_0/ddr4_0.xcix]                                                  -directory $env(WORKAREA)/hw/build/build_project.ip_user_files/sim_scripts -ip_user_files_dir $env(WORKAREA)/hw/build/build_project.ip_user_files -ipstatic_source_dir $env(WORKAREA)/hw/build/build_project.ip_user_files/ipstatic -lib_map_path [list {modelsim=$env(WORKAREA)/hw/build/build_project.cache/compile_simlib/modelsim} {questa=$env(WORKAREA)/hw/build/build_project.cache/compile_simlib/questa} {ies=$env(WORKAREA)/hw/build/build_project.cache/compile_simlib/ies} {xcelium=$env(WORKAREA)/hw/build/build_project.cache/compile_simlib/xcelium} {vcs=$env(WORKAREA)/hw/build/build_project.cache/compile_simlib/vcs} {riviera=$env(WORKAREA)/hw/build/build_project.cache/compile_simlib/riviera}] -use_ip_compiled_libs -force -quiet

# SYNTH
set_property STEPS.SYNTH_DESIGN.ARGS.FLATTEN_HIERARCHY none [get_runs synth_1]

# Compile simulation libraries for modelsim
# compile_simlib -simulator modelsim -simulator_exec_path {/mnt/applications/mentor/modelsim-2019.2/modelsim/modeltech/linux_x86_64} -family all -language all -library all -dir {$WORKAREA/hw/build/build_project.cache/compile_simlib/modelsim} -verbose