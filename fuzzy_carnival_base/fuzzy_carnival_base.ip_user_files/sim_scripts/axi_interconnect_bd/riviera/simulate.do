onbreak {quit -force}
onerror {quit -force}

asim -t 1ps +access +r +m+axi_interconnect_bd -L xpm -L generic_baseblocks_v2_1_0 -L axi_infrastructure_v1_1_0 -L axi_register_slice_v2_1_20 -L fifo_generator_v13_2_5 -L axi_data_fifo_v2_1_19 -L axi_crossbar_v2_1_21 -L xil_defaultlib -L microblaze_v11_0_2 -L lib_cdc_v1_0_2 -L proc_sys_reset_v5_0_13 -L lmb_v10_v3_0_10 -L lmb_bram_if_cntlr_v4_0_17 -L blk_mem_gen_v8_4_4 -L iomodule_v3_1_5 -L util_vector_logic_v2_0_1 -L axi_protocol_converter_v2_1_20 -L axi_clock_converter_v2_1_19 -L axi_dwidth_converter_v2_1_20 -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.axi_interconnect_bd xil_defaultlib.glbl

do {wave.do}

view wave
view structure

do {axi_interconnect_bd.udo}

run -all

endsim

quit -force
