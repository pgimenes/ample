vlib work
vlib riviera

vlib riviera/xilinx_vip
vlib riviera/xpm
vlib riviera/xbip_utils_v3_0_10
vlib riviera/axi_utils_v2_0_6
vlib riviera/xbip_pipe_v3_0_6
vlib riviera/xbip_dsp48_wrapper_v3_0_4
vlib riviera/xbip_dsp48_addsub_v3_0_6
vlib riviera/xbip_dsp48_multadd_v3_0_6
vlib riviera/xbip_bram18k_v3_0_6
vlib riviera/mult_gen_v12_0_16
vlib riviera/floating_point_v7_1_9
vlib riviera/xil_defaultlib

vmap xilinx_vip riviera/xilinx_vip
vmap xpm riviera/xpm
vmap xbip_utils_v3_0_10 riviera/xbip_utils_v3_0_10
vmap axi_utils_v2_0_6 riviera/axi_utils_v2_0_6
vmap xbip_pipe_v3_0_6 riviera/xbip_pipe_v3_0_6
vmap xbip_dsp48_wrapper_v3_0_4 riviera/xbip_dsp48_wrapper_v3_0_4
vmap xbip_dsp48_addsub_v3_0_6 riviera/xbip_dsp48_addsub_v3_0_6
vmap xbip_dsp48_multadd_v3_0_6 riviera/xbip_dsp48_multadd_v3_0_6
vmap xbip_bram18k_v3_0_6 riviera/xbip_bram18k_v3_0_6
vmap mult_gen_v12_0_16 riviera/mult_gen_v12_0_16
vmap floating_point_v7_1_9 riviera/floating_point_v7_1_9
vmap xil_defaultlib riviera/xil_defaultlib

vlog -work xilinx_vip  -sv2k12 "+incdir+/mnt/applications/Xilinx/19.2/Vivado/2019.2/data/xilinx_vip/include" \
"/mnt/applications/Xilinx/19.2/Vivado/2019.2/data/xilinx_vip/hdl/axi4stream_vip_axi4streampc.sv" \
"/mnt/applications/Xilinx/19.2/Vivado/2019.2/data/xilinx_vip/hdl/axi_vip_axi4pc.sv" \
"/mnt/applications/Xilinx/19.2/Vivado/2019.2/data/xilinx_vip/hdl/xil_common_vip_pkg.sv" \
"/mnt/applications/Xilinx/19.2/Vivado/2019.2/data/xilinx_vip/hdl/axi4stream_vip_pkg.sv" \
"/mnt/applications/Xilinx/19.2/Vivado/2019.2/data/xilinx_vip/hdl/axi_vip_pkg.sv" \
"/mnt/applications/Xilinx/19.2/Vivado/2019.2/data/xilinx_vip/hdl/axi4stream_vip_if.sv" \
"/mnt/applications/Xilinx/19.2/Vivado/2019.2/data/xilinx_vip/hdl/axi_vip_if.sv" \
"/mnt/applications/Xilinx/19.2/Vivado/2019.2/data/xilinx_vip/hdl/clk_vip_if.sv" \
"/mnt/applications/Xilinx/19.2/Vivado/2019.2/data/xilinx_vip/hdl/rst_vip_if.sv" \

vlog -work xpm  -sv2k12 "+incdir+/mnt/applications/Xilinx/19.2/Vivado/2019.2/data/xilinx_vip/include" \
"/mnt/applications/Xilinx/19.2/Vivado/2019.2/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
"/mnt/applications/Xilinx/19.2/Vivado/2019.2/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vcom -work xpm -93 \
"/mnt/applications/Xilinx/19.2/Vivado/2019.2/data/ip/xpm/xpm_VCOMP.vhd" \

vcom -work xbip_utils_v3_0_10 -93 \
"../../../ipstatic/hdl/xbip_utils_v3_0_vh_rfs.vhd" \

vcom -work axi_utils_v2_0_6 -93 \
"../../../ipstatic/hdl/axi_utils_v2_0_vh_rfs.vhd" \

vcom -work xbip_pipe_v3_0_6 -93 \
"../../../ipstatic/hdl/xbip_pipe_v3_0_vh_rfs.vhd" \

vcom -work xbip_dsp48_wrapper_v3_0_4 -93 \
"../../../ipstatic/hdl/xbip_dsp48_wrapper_v3_0_vh_rfs.vhd" \

vcom -work xbip_dsp48_addsub_v3_0_6 -93 \
"../../../ipstatic/hdl/xbip_dsp48_addsub_v3_0_vh_rfs.vhd" \

vcom -work xbip_dsp48_multadd_v3_0_6 -93 \
"../../../ipstatic/hdl/xbip_dsp48_multadd_v3_0_vh_rfs.vhd" \

vcom -work xbip_bram18k_v3_0_6 -93 \
"../../../ipstatic/hdl/xbip_bram18k_v3_0_vh_rfs.vhd" \

vcom -work mult_gen_v12_0_16 -93 \
"../../../ipstatic/hdl/mult_gen_v12_0_vh_rfs.vhd" \

vcom -work floating_point_v7_1_9 -93 \
"../../../ipstatic/hdl/floating_point_v7_1_rfs.vhd" \

vcom -work xil_defaultlib -93 \
"../../../../hw.srcs/sources_1/ip/fp_mult/sim/fp_mult.vhd" \

vlog -work xil_defaultlib \
"glbl.v"

