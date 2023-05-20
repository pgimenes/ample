# Create the build directory, ignoring any exception
catch {exec mkdir $env(FYP_DIR)/hw/build}
cd $env(FYP_DIR)/hw/build

create_project build_project -part xcu250-figd2104-2L-e -force

# Import IP
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

generate_target all [get_ips]