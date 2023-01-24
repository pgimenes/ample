-makelib ies_lib/xpm -sv \
  "/usr/local/Xilinx/Vivado/2019.2/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
  "/usr/local/Xilinx/Vivado/2019.2/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \
-endlib
-makelib ies_lib/xpm \
  "/usr/local/Xilinx/Vivado/2019.2/data/ip/xpm/xpm_VCOMP.vhd" \
-endlib
-makelib ies_lib/fifo_generator_v13_2_5 \
  "../../../ipstatic/simulation/fifo_generator_vlog_beh.v" \
-endlib
-makelib ies_lib/fifo_generator_v13_2_5 \
  "../../../ipstatic/hdl/fifo_generator_v13_2_rfs.vhd" \
-endlib
-makelib ies_lib/fifo_generator_v13_2_5 \
  "../../../ipstatic/hdl/fifo_generator_v13_2_rfs.v" \
-endlib
-makelib ies_lib/axi_interconnect_v1_7_17 \
  "../../../ipstatic/hdl/axi_interconnect_v1_7_vl_rfs.v" \
-endlib
-makelib ies_lib/xil_defaultlib \
  "../../../../ddr4_0_ex.srcs/sources_1/ip/axi_memory_interconnect/sim/axi_memory_interconnect.v" \
-endlib
-makelib ies_lib/xil_defaultlib \
  glbl.v
-endlib

