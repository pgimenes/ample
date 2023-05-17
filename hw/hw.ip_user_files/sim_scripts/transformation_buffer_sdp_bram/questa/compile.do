vlib questa_lib/work
vlib questa_lib/msim

vlib questa_lib/msim/xilinx_vip
vlib questa_lib/msim/xpm
vlib questa_lib/msim/blk_mem_gen_v8_4_4
vlib questa_lib/msim/xil_defaultlib

vmap xilinx_vip questa_lib/msim/xilinx_vip
vmap xpm questa_lib/msim/xpm
vmap blk_mem_gen_v8_4_4 questa_lib/msim/blk_mem_gen_v8_4_4
vmap xil_defaultlib questa_lib/msim/xil_defaultlib

vlog -work xilinx_vip -64 -sv -L axi_vip_v1_1_6 -L xilinx_vip "+incdir+/mnt/applications/Xilinx/19.2/Vivado/2019.2/data/xilinx_vip/include" \
"/mnt/applications/Xilinx/19.2/Vivado/2019.2/data/xilinx_vip/hdl/axi4stream_vip_axi4streampc.sv" \
"/mnt/applications/Xilinx/19.2/Vivado/2019.2/data/xilinx_vip/hdl/axi_vip_axi4pc.sv" \
"/mnt/applications/Xilinx/19.2/Vivado/2019.2/data/xilinx_vip/hdl/xil_common_vip_pkg.sv" \
"/mnt/applications/Xilinx/19.2/Vivado/2019.2/data/xilinx_vip/hdl/axi4stream_vip_pkg.sv" \
"/mnt/applications/Xilinx/19.2/Vivado/2019.2/data/xilinx_vip/hdl/axi_vip_pkg.sv" \
"/mnt/applications/Xilinx/19.2/Vivado/2019.2/data/xilinx_vip/hdl/axi4stream_vip_if.sv" \
"/mnt/applications/Xilinx/19.2/Vivado/2019.2/data/xilinx_vip/hdl/axi_vip_if.sv" \
"/mnt/applications/Xilinx/19.2/Vivado/2019.2/data/xilinx_vip/hdl/clk_vip_if.sv" \
"/mnt/applications/Xilinx/19.2/Vivado/2019.2/data/xilinx_vip/hdl/rst_vip_if.sv" \

vlog -work xpm -64 -sv -L axi_vip_v1_1_6 -L xilinx_vip "+incdir+/mnt/applications/Xilinx/19.2/Vivado/2019.2/data/xilinx_vip/include" \
"/mnt/applications/Xilinx/19.2/Vivado/2019.2/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
"/mnt/applications/Xilinx/19.2/Vivado/2019.2/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vcom -work xpm -64 -93 \
"/mnt/applications/Xilinx/19.2/Vivado/2019.2/data/ip/xpm/xpm_VCOMP.vhd" \

vlog -work blk_mem_gen_v8_4_4 -64 "+incdir+/mnt/applications/Xilinx/19.2/Vivado/2019.2/data/xilinx_vip/include" \
"../../../ipstatic/simulation/blk_mem_gen_v8_4.v" \

vlog -work xil_defaultlib -64 "+incdir+/mnt/applications/Xilinx/19.2/Vivado/2019.2/data/xilinx_vip/include" \
"../../../ip/transformation_buffer_sdp_bram/sim/transformation_buffer_sdp_bram.v" \

vlog -work xil_defaultlib \
"glbl.v"

