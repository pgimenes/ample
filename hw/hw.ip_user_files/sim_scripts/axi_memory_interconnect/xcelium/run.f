-makelib xcelium_lib/xilinx_vip -sv \
  "/mnt/applications/Xilinx/19.2/Vivado/2019.2/data/xilinx_vip/hdl/axi4stream_vip_axi4streampc.sv" \
  "/mnt/applications/Xilinx/19.2/Vivado/2019.2/data/xilinx_vip/hdl/axi_vip_axi4pc.sv" \
  "/mnt/applications/Xilinx/19.2/Vivado/2019.2/data/xilinx_vip/hdl/xil_common_vip_pkg.sv" \
  "/mnt/applications/Xilinx/19.2/Vivado/2019.2/data/xilinx_vip/hdl/axi4stream_vip_pkg.sv" \
  "/mnt/applications/Xilinx/19.2/Vivado/2019.2/data/xilinx_vip/hdl/axi_vip_pkg.sv" \
  "/mnt/applications/Xilinx/19.2/Vivado/2019.2/data/xilinx_vip/hdl/axi4stream_vip_if.sv" \
  "/mnt/applications/Xilinx/19.2/Vivado/2019.2/data/xilinx_vip/hdl/axi_vip_if.sv" \
  "/mnt/applications/Xilinx/19.2/Vivado/2019.2/data/xilinx_vip/hdl/clk_vip_if.sv" \
  "/mnt/applications/Xilinx/19.2/Vivado/2019.2/data/xilinx_vip/hdl/rst_vip_if.sv" \
-endlib
-makelib xcelium_lib/xpm -sv \
  "/mnt/applications/Xilinx/19.2/Vivado/2019.2/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
  "/mnt/applications/Xilinx/19.2/Vivado/2019.2/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \
-endlib
-makelib xcelium_lib/xpm \
  "/mnt/applications/Xilinx/19.2/Vivado/2019.2/data/ip/xpm/xpm_VCOMP.vhd" \
-endlib
-makelib xcelium_lib/fifo_generator_v13_2_5 \
  "../../../ipstatic/simulation/fifo_generator_vlog_beh.v" \
-endlib
-makelib xcelium_lib/fifo_generator_v13_2_5 \
  "../../../ipstatic/hdl/fifo_generator_v13_2_rfs.vhd" \
-endlib
-makelib xcelium_lib/fifo_generator_v13_2_5 \
  "../../../ipstatic/hdl/fifo_generator_v13_2_rfs.v" \
-endlib
-makelib xcelium_lib/axi_interconnect_v1_7_17 \
  "../../../ipstatic/hdl/axi_interconnect_v1_7_vl_rfs.v" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  "../../../../hw.srcs/sources_1/ip/axi_memory_interconnect/sim/axi_memory_interconnect.v" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  glbl.v
-endlib

