#!/bin/bash -f
#*********************************************************************************************************
# usage: top_tb.sh [-help]
# usage: top_tb.sh [-lib_map_path]
# usage: top_tb.sh [-noclean_files]
# usage: top_tb.sh [-reset_run]
#
#*********************************************************************************************************

set -e

exec > top_tb_log.log

# Command line options
xv_boost_lib_path=/mnt/applications/Xilinx/19.2/Vivado/2019.2/tps/boost_1_64_0
xvlog_opts="--relax -L axi_vip_v1_1_6 -L xilinx_vip --define GRAPH_TEST --define RAM_MODEL -i ../../ip/node_scoreboard/tb"
xvhdl_opts="--relax"

if [ "${SIM_GUI:-0}" -eq 1 ]; then
  SIM_ARGS="--gui"
fi

if [ "${FAST_BUILD:-0}" -eq 1 ]; then
  xvlog_opts+=" --define TOP_FAST_BUILD"
fi

# Main steps
run()
{
  check_args $# $1
  setup $1 $2

  if [[ $# -eq 0 || "$*" == *"--all"* ]]; then
    
    echo "[$(date +%Y-%m-%d\ %H:%M:%S)]: Starting build stage."
    build_start_time=$(date +%s)

    compile
    elaborate
    
    build_end_time=$(date +%s)
    build_execution_time=$((build_end_time - build_start_time))
    echo "[$(date +%Y-%m-%d\ %H:%M:%S)]: Build executed in $((build_execution_time / 60))m $((build_execution_time % 60))s."
    
    simulate
  
  else

    # If --all not set, run each step if the flag is set
    if [[ "$*" == *"--compile"* ]]; then
      compile
    fi

    if [[ "$*" == *"--elaborate"* ]]; then
      elaborate
    fi

    if [[ "$*" == *"--simulate"* ]]; then
      simulate
    fi

  fi  

}

# RUN_STEP: <compile>
compile()
{

  echo "[$(date +%Y-%m-%d\ %H:%M:%S)]: Starting compilation stage."
  compilation_start_time=$(date +%s)
  
  # Compile verilog (flag raised by default in bashrc)
  if [[ "$COMPILE_VLOG" -eq 1 ]]; then
    echo "[$(date +%Y-%m-%d\ %H:%M:%S)]: Building Verilog design files."
    xvlog $xvlog_opts -prj vlog.prj 2>&1 | tee compile.log
  fi

  # compile VHDL if flag raised
  if [[ "$COMPILE_VHDL" -eq 1 ]]; then
    echo "[$(date +%Y-%m-%d\ %H:%M:%S)]: Compiling VHDL design files."
    xvhdl $xvhdl_opts -prj vhdl.prj 2>&1 | tee compile.log
  fi
  
  # Compile testbench files
  if [[ "$BUILD_TB" -eq 1 ]]; then
    echo "[$(date +%Y-%m-%d\ %H:%M:%S)]: Building testbench."
    xvlog $xvlog_opts -prj vlog_tb.prj 2>&1 | tee compile.log
  fi

  compilation_end_time=$(date +%s)
  compilation_execution_time=$((compilation_end_time - compilation_start_time))
  echo "[$(date +%Y-%m-%d\ %H:%M:%S)]: Compilation stage executed in $((compilation_execution_time / 60))m $((compilation_execution_time % 60))s."
}

# RUN_STEP: <elaborate>
elaborate()
{
  elaboration_start_time=$(date +%s)
  
  echo "[$(date +%Y-%m-%d\ %H:%M:%S)]: Starting elaboration stage."
  xelab --relax --verbose --stats --O3 --debug typical --timescale 1ps/1ps --mt auto -d "FLOAT_MAC=1" -L axi_infrastructure_v1_1_0 -L xil_defaultlib -L axi_vip_v1_1_6 -L microblaze_v11_0_2 -L lib_cdc_v1_0_2 -L proc_sys_reset_v5_0_13 -L lmb_v10_v3_0_10 -L lmb_bram_if_cntlr_v4_0_17 -L blk_mem_gen_v8_4_4 -L iomodule_v3_1_5 -L fifo_generator_v13_2_5 -L axi_interconnect_v1_7_17 -L generic_baseblocks_v2_1_0 -L axi_register_slice_v2_1_20 -L axi_data_fifo_v2_1_19 -L axi_crossbar_v2_1_21 -L xbip_utils_v3_0_10 -L axi_utils_v2_0_6 -L xbip_pipe_v3_0_6 -L xbip_dsp48_wrapper_v3_0_4 -L xbip_dsp48_addsub_v3_0_6 -L xbip_dsp48_multadd_v3_0_6 -L xbip_bram18k_v3_0_6 -L mult_gen_v12_0_16 -L floating_point_v7_1_9 -L xilinx_vip -L unisims_ver -L unimacro_ver -L secureip -L xpm --snapshot $TB_TOP xil_defaultlib.$TB_TOP -log elaborate.log
  
  elaboration_end_time=$(date +%s)
  elaboration_execution_time=$((elaboration_end_time - elaboration_start_time))
  echo "[$(date +%Y-%m-%d\ %H:%M:%S)]: Elaboration stage executed in $((elaboration_execution_time / 60))m $((elaboration_execution_time % 60))s."
}

# RUN_STEP: <simulate>
simulate()
{
  echo "[$(date +%Y-%m-%d\ %H:%M:%S)]: Starting simulation."
  xsim $TB_TOP $SIM_ARGS -key {Behavioral:sim_1:Functional:top_tb} -tclbatch cmd.tcl -protoinst "protoinst_files/bd_9054.protoinst" -log simulate.log
}

# STEP: setup
setup()
{
  case $1 in
    "-lib_map_path" )
      if [[ ($2 == "") ]]; then
        echo -e "ERROR: Simulation library directory path not specified (type \"./top_tb.sh -help\" for more information)\n"
        exit 1
      fi
     copy_setup_file $2
    ;;
    "-reset_run" )
      reset_run
      echo -e "INFO: Simulation run files deleted.\n"
      exit 0
    ;;
    "-noclean_files" )
      # do not remove previous data
    ;;
    * )
     copy_setup_file $2
  esac

  # Add any setup/initialization commands here:-

  # <user specific commands>

}

# Copy xsim.ini file
copy_setup_file()
{
  file="xsim.ini"
  lib_map_path="/mnt/applications/Xilinx/19.2/Vivado/2019.2/data/xsim"
  if [[ ($1 != "") ]]; then
    lib_map_path="$1"
  fi
  if [[ ($lib_map_path != "") ]]; then
    src_file="$lib_map_path/$file"
    if [[ -e $src_file ]]; then
      cp $src_file .
    fi

    # Map local design libraries to xsim.ini
    map_local_libs

  fi
}

# Map local design libraries
map_local_libs()
{
  updated_mappings=()
  local_mappings=()

  # Local design libraries
  local_libs=(microblaze_v11_0_2 lib_cdc_v1_0_2 proc_sys_reset_v5_0_13 lmb_v10_v3_0_10 lmb_bram_if_cntlr_v4_0_17 blk_mem_gen_v8_4_4 iomodule_v3_1_5 xbip_utils_v3_0_10 axi_utils_v2_0_6 xbip_pipe_v3_0_6 xbip_dsp48_wrapper_v3_0_4 xbip_dsp48_addsub_v3_0_6 xbip_dsp48_multadd_v3_0_6 xbip_bram18k_v3_0_6 mult_gen_v12_0_16 floating_point_v7_1_9)

  if [[ 0 == ${#local_libs[@]} ]]; then
    return
  fi

  file="xsim.ini"
  file_backup="xsim.ini.bak"

  if [[ -e $file ]]; then
    rm -f $file_backup
    # Create a backup copy of the xsim.ini file
    cp $file $file_backup
    # Read libraries from backup file and search in local library collection
    while read -r line
    do
      IN=$line
      # Split mapping entry with '=' delimiter to fetch library name and mapping
      read lib_name mapping <<<$(IFS="="; echo $IN)
      # If local library found, then construct the local mapping and add to local mapping collection
      if `echo ${local_libs[@]} | grep -wq $lib_name` ; then
        line="$lib_name=xsim.dir/$lib_name"
        local_mappings+=("$lib_name")
      fi
      # Add to updated library mapping collection
      updated_mappings+=("$line")
    done < "$file_backup"
    # Append local libraries not found originally from xsim.ini
    for (( i=0; i<${#local_libs[*]}; i++ )); do
      lib_name="${local_libs[i]}"
      if `echo ${local_mappings[@]} | grep -wvq $lib_name` ; then
        line="$lib_name=xsim.dir/$lib_name"
        updated_mappings+=("$line")
      fi
    done
    # Write updated mappings in xsim.ini
    rm -f $file
    for (( i=0; i<${#updated_mappings[*]}; i++ )); do
      lib_name="${updated_mappings[i]}"
      echo $lib_name >> $file
    done
  else
    for (( i=0; i<${#local_libs[*]}; i++ )); do
      lib_name="${local_libs[i]}"
      mapping="$lib_name=xsim.dir/$lib_name"
      echo $mapping >> $file
    done
  fi
}

# Delete generated data from the previous run
reset_run()
{
  files_to_remove=(xelab.pb xsim.jou xvhdl.log xvlog.log compile.log elaborate.log simulate.log xelab.log xsim.log run.log xvhdl.pb xvlog.pb $TB_TOP.wdb xsim.dir)
  for (( i=0; i<${#files_to_remove[*]}; i++ )); do
    file="${files_to_remove[i]}"
    if [[ -e $file ]]; then
      rm -rf $file
    fi
  done
}

# Check command line arguments
check_args()
{
  # if [[ ($1 == 1 ) && ($2 != "-lib_map_path" && $2 != "-noclean_files" && $2 != "-reset_run" && $2 != "-help" && $2 != "-h") ]]; then
  #   echo -e "ERROR: Unknown option specified '$2' (type \"./top_tb.sh -help\" for more information)\n"
  #   exit 1
  # fi

  if [[ ($2 == "-help" || $2 == "-h") ]]; then
    usage
  fi
}

# Script usage
usage()
{
  msg="Usage: top_tb.sh [-help]\n\
Usage: top_tb.sh [-lib_map_path]\n\
Usage: top_tb.sh [-reset_run]\n\
Usage: top_tb.sh [-noclean_files]\n\n\
[-help] -- Print help information for this script\n\n\
[-lib_map_path <path>] -- Compiled simulation library directory path. The simulation library is compiled\n\
using the compile_simlib tcl command. Please see 'compile_simlib -help' for more information.\n\n\
[-reset_run] -- Recreate simulator setup files and library mappings for a clean run. The generated files\n\
from the previous run will be removed. If you don't want to remove the simulator generated files, use the\n\
-noclean_files switch.\n\n\
[-noclean_files] -- Reset previous run, but do not remove simulator generated files from the previous run.\n\n"
  echo -e $msg
  exit 1
}

# Launch script
run $1 $2
