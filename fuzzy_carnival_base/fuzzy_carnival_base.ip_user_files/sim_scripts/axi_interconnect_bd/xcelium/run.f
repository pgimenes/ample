-makelib xcelium_lib/xpm -sv \
  "/usr/local/Xilinx/Vivado/2019.2/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
  "/usr/local/Xilinx/Vivado/2019.2/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \
-endlib
-makelib xcelium_lib/xpm \
  "/usr/local/Xilinx/Vivado/2019.2/data/ip/xpm/xpm_VCOMP.vhd" \
-endlib
-makelib xcelium_lib/generic_baseblocks_v2_1_0 \
  "../../../../fuzzy_carnival_base.srcs/sources_1/bd/axi_interconnect_bd/ipshared/b752/hdl/generic_baseblocks_v2_1_vl_rfs.v" \
-endlib
-makelib xcelium_lib/axi_infrastructure_v1_1_0 \
  "../../../../fuzzy_carnival_base.srcs/sources_1/bd/axi_interconnect_bd/ipshared/ec67/hdl/axi_infrastructure_v1_1_vl_rfs.v" \
-endlib
-makelib xcelium_lib/axi_register_slice_v2_1_20 \
  "../../../../fuzzy_carnival_base.srcs/sources_1/bd/axi_interconnect_bd/ipshared/72d4/hdl/axi_register_slice_v2_1_vl_rfs.v" \
-endlib
-makelib xcelium_lib/fifo_generator_v13_2_5 \
  "../../../../fuzzy_carnival_base.srcs/sources_1/bd/axi_interconnect_bd/ipshared/276e/simulation/fifo_generator_vlog_beh.v" \
-endlib
-makelib xcelium_lib/fifo_generator_v13_2_5 \
  "../../../../fuzzy_carnival_base.srcs/sources_1/bd/axi_interconnect_bd/ipshared/276e/hdl/fifo_generator_v13_2_rfs.vhd" \
-endlib
-makelib xcelium_lib/fifo_generator_v13_2_5 \
  "../../../../fuzzy_carnival_base.srcs/sources_1/bd/axi_interconnect_bd/ipshared/276e/hdl/fifo_generator_v13_2_rfs.v" \
-endlib
-makelib xcelium_lib/axi_data_fifo_v2_1_19 \
  "../../../../fuzzy_carnival_base.srcs/sources_1/bd/axi_interconnect_bd/ipshared/60de/hdl/axi_data_fifo_v2_1_vl_rfs.v" \
-endlib
-makelib xcelium_lib/axi_crossbar_v2_1_21 \
  "../../../../fuzzy_carnival_base.srcs/sources_1/bd/axi_interconnect_bd/ipshared/6b0d/hdl/axi_crossbar_v2_1_vl_rfs.v" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  "../../../bd/axi_interconnect_bd/ip/axi_interconnect_bd_xbar_1/sim/axi_interconnect_bd_xbar_1.v" \
-endlib
-makelib xcelium_lib/microblaze_v11_0_2 \
  "../../../../fuzzy_carnival_base.srcs/sources_1/bd/axi_interconnect_bd/ipshared/f871/hdl/microblaze_v11_0_vh_rfs.vhd" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  "../../../bd/axi_interconnect_bd/ip/axi_interconnect_bd_ddr4_0_0/bd_0/ip/ip_0/sim/bd_f308_microblaze_I_0.vhd" \
-endlib
-makelib xcelium_lib/lib_cdc_v1_0_2 \
  "../../../../fuzzy_carnival_base.srcs/sources_1/bd/axi_interconnect_bd/ipshared/ef1e/hdl/lib_cdc_v1_0_rfs.vhd" \
-endlib
-makelib xcelium_lib/proc_sys_reset_v5_0_13 \
  "../../../../fuzzy_carnival_base.srcs/sources_1/bd/axi_interconnect_bd/ipshared/8842/hdl/proc_sys_reset_v5_0_vh_rfs.vhd" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  "../../../bd/axi_interconnect_bd/ip/axi_interconnect_bd_ddr4_0_0/bd_0/ip/ip_1/sim/bd_f308_rst_0_0.vhd" \
-endlib
-makelib xcelium_lib/lmb_v10_v3_0_10 \
  "../../../../fuzzy_carnival_base.srcs/sources_1/bd/axi_interconnect_bd/ipshared/2e88/hdl/lmb_v10_v3_0_vh_rfs.vhd" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  "../../../bd/axi_interconnect_bd/ip/axi_interconnect_bd_ddr4_0_0/bd_0/ip/ip_2/sim/bd_f308_ilmb_0.vhd" \
  "../../../bd/axi_interconnect_bd/ip/axi_interconnect_bd_ddr4_0_0/bd_0/ip/ip_3/sim/bd_f308_dlmb_0.vhd" \
-endlib
-makelib xcelium_lib/lmb_bram_if_cntlr_v4_0_17 \
  "../../../../fuzzy_carnival_base.srcs/sources_1/bd/axi_interconnect_bd/ipshared/db6f/hdl/lmb_bram_if_cntlr_v4_0_vh_rfs.vhd" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  "../../../bd/axi_interconnect_bd/ip/axi_interconnect_bd_ddr4_0_0/bd_0/ip/ip_4/sim/bd_f308_dlmb_cntlr_0.vhd" \
  "../../../bd/axi_interconnect_bd/ip/axi_interconnect_bd_ddr4_0_0/bd_0/ip/ip_5/sim/bd_f308_ilmb_cntlr_0.vhd" \
-endlib
-makelib xcelium_lib/blk_mem_gen_v8_4_4 \
  "../../../../fuzzy_carnival_base.srcs/sources_1/bd/axi_interconnect_bd/ipshared/2985/simulation/blk_mem_gen_v8_4.v" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  "../../../bd/axi_interconnect_bd/ip/axi_interconnect_bd_ddr4_0_0/bd_0/ip/ip_6/sim/bd_f308_lmb_bram_I_0.v" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  "../../../bd/axi_interconnect_bd/ip/axi_interconnect_bd_ddr4_0_0/bd_0/ip/ip_7/sim/bd_f308_second_dlmb_cntlr_0.vhd" \
  "../../../bd/axi_interconnect_bd/ip/axi_interconnect_bd_ddr4_0_0/bd_0/ip/ip_8/sim/bd_f308_second_ilmb_cntlr_0.vhd" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  "../../../bd/axi_interconnect_bd/ip/axi_interconnect_bd_ddr4_0_0/bd_0/ip/ip_9/sim/bd_f308_second_lmb_bram_I_0.v" \
-endlib
-makelib xcelium_lib/iomodule_v3_1_5 \
  "../../../../fuzzy_carnival_base.srcs/sources_1/bd/axi_interconnect_bd/ipshared/f748/hdl/iomodule_v3_1_vh_rfs.vhd" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  "../../../bd/axi_interconnect_bd/ip/axi_interconnect_bd_ddr4_0_0/bd_0/ip/ip_10/sim/bd_f308_iomodule_0_0.vhd" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  "../../../bd/axi_interconnect_bd/ip/axi_interconnect_bd_ddr4_0_0/bd_0/sim/bd_f308.v" \
  "../../../bd/axi_interconnect_bd/ip/axi_interconnect_bd_ddr4_0_0/ip_0/sim/axi_interconnect_bd_ddr4_0_0_microblaze_mcs.v" \
-endlib
-makelib xcelium_lib/xil_defaultlib -sv \
  "../../../bd/axi_interconnect_bd/ip/axi_interconnect_bd_ddr4_0_0/ip_1/rtl/phy/ddr4_phy_v2_2_xiphy_behav.sv" \
  "../../../bd/axi_interconnect_bd/ip/axi_interconnect_bd_ddr4_0_0/ip_1/rtl/phy/ddr4_phy_v2_2_xiphy.sv" \
  "../../../bd/axi_interconnect_bd/ip/axi_interconnect_bd_ddr4_0_0/ip_1/rtl/iob/ddr4_phy_v2_2_iob_byte.sv" \
  "../../../bd/axi_interconnect_bd/ip/axi_interconnect_bd_ddr4_0_0/ip_1/rtl/iob/ddr4_phy_v2_2_iob.sv" \
  "../../../bd/axi_interconnect_bd/ip/axi_interconnect_bd_ddr4_0_0/ip_1/rtl/clocking/ddr4_phy_v2_2_pll.sv" \
  "../../../bd/axi_interconnect_bd/ip/axi_interconnect_bd_ddr4_0_0/ip_1/rtl/xiphy_files/ddr4_phy_v2_2_xiphy_tristate_wrapper.sv" \
  "../../../bd/axi_interconnect_bd/ip/axi_interconnect_bd_ddr4_0_0/ip_1/rtl/xiphy_files/ddr4_phy_v2_2_xiphy_riuor_wrapper.sv" \
  "../../../bd/axi_interconnect_bd/ip/axi_interconnect_bd_ddr4_0_0/ip_1/rtl/xiphy_files/ddr4_phy_v2_2_xiphy_control_wrapper.sv" \
  "../../../bd/axi_interconnect_bd/ip/axi_interconnect_bd_ddr4_0_0/ip_1/rtl/xiphy_files/ddr4_phy_v2_2_xiphy_byte_wrapper.sv" \
  "../../../bd/axi_interconnect_bd/ip/axi_interconnect_bd_ddr4_0_0/ip_1/rtl/xiphy_files/ddr4_phy_v2_2_xiphy_bitslice_wrapper.sv" \
  "../../../bd/axi_interconnect_bd/ip/axi_interconnect_bd_ddr4_0_0/ip_1/rtl/phy/axi_interconnect_bd_ddr4_0_0_phy_ddr4.sv" \
  "../../../bd/axi_interconnect_bd/ip/axi_interconnect_bd_ddr4_0_0/ip_1/rtl/ip_top/axi_interconnect_bd_ddr4_0_0_phy.sv" \
  "../../../bd/axi_interconnect_bd/ip/axi_interconnect_bd_ddr4_0_0/rtl/controller/ddr4_v2_2_mc_wtr.sv" \
  "../../../bd/axi_interconnect_bd/ip/axi_interconnect_bd_ddr4_0_0/rtl/controller/ddr4_v2_2_mc_ref.sv" \
  "../../../bd/axi_interconnect_bd/ip/axi_interconnect_bd_ddr4_0_0/rtl/controller/ddr4_v2_2_mc_rd_wr.sv" \
  "../../../bd/axi_interconnect_bd/ip/axi_interconnect_bd_ddr4_0_0/rtl/controller/ddr4_v2_2_mc_periodic.sv" \
  "../../../bd/axi_interconnect_bd/ip/axi_interconnect_bd_ddr4_0_0/rtl/controller/ddr4_v2_2_mc_group.sv" \
  "../../../bd/axi_interconnect_bd/ip/axi_interconnect_bd_ddr4_0_0/rtl/controller/ddr4_v2_2_mc_ecc_merge_enc.sv" \
  "../../../bd/axi_interconnect_bd/ip/axi_interconnect_bd_ddr4_0_0/rtl/controller/ddr4_v2_2_mc_ecc_gen.sv" \
  "../../../bd/axi_interconnect_bd/ip/axi_interconnect_bd_ddr4_0_0/rtl/controller/ddr4_v2_2_mc_ecc_fi_xor.sv" \
  "../../../bd/axi_interconnect_bd/ip/axi_interconnect_bd_ddr4_0_0/rtl/controller/ddr4_v2_2_mc_ecc_dec_fix.sv" \
  "../../../bd/axi_interconnect_bd/ip/axi_interconnect_bd_ddr4_0_0/rtl/controller/ddr4_v2_2_mc_ecc_buf.sv" \
  "../../../bd/axi_interconnect_bd/ip/axi_interconnect_bd_ddr4_0_0/rtl/controller/ddr4_v2_2_mc_ecc.sv" \
  "../../../bd/axi_interconnect_bd/ip/axi_interconnect_bd_ddr4_0_0/rtl/controller/ddr4_v2_2_mc_ctl.sv" \
  "../../../bd/axi_interconnect_bd/ip/axi_interconnect_bd_ddr4_0_0/rtl/controller/ddr4_v2_2_mc_cmd_mux_c.sv" \
  "../../../bd/axi_interconnect_bd/ip/axi_interconnect_bd_ddr4_0_0/rtl/controller/ddr4_v2_2_mc_cmd_mux_ap.sv" \
  "../../../bd/axi_interconnect_bd/ip/axi_interconnect_bd_ddr4_0_0/rtl/controller/ddr4_v2_2_mc_arb_p.sv" \
  "../../../bd/axi_interconnect_bd/ip/axi_interconnect_bd_ddr4_0_0/rtl/controller/ddr4_v2_2_mc_arb_mux_p.sv" \
  "../../../bd/axi_interconnect_bd/ip/axi_interconnect_bd_ddr4_0_0/rtl/controller/ddr4_v2_2_mc_arb_c.sv" \
  "../../../bd/axi_interconnect_bd/ip/axi_interconnect_bd_ddr4_0_0/rtl/controller/ddr4_v2_2_mc_arb_a.sv" \
  "../../../bd/axi_interconnect_bd/ip/axi_interconnect_bd_ddr4_0_0/rtl/controller/ddr4_v2_2_mc_act_timer.sv" \
  "../../../bd/axi_interconnect_bd/ip/axi_interconnect_bd_ddr4_0_0/rtl/controller/ddr4_v2_2_mc_act_rank.sv" \
  "../../../bd/axi_interconnect_bd/ip/axi_interconnect_bd_ddr4_0_0/rtl/controller/ddr4_v2_2_mc.sv" \
  "../../../bd/axi_interconnect_bd/ip/axi_interconnect_bd_ddr4_0_0/rtl/ui/ddr4_v2_2_ui_wr_data.sv" \
  "../../../bd/axi_interconnect_bd/ip/axi_interconnect_bd_ddr4_0_0/rtl/ui/ddr4_v2_2_ui_rd_data.sv" \
  "../../../bd/axi_interconnect_bd/ip/axi_interconnect_bd_ddr4_0_0/rtl/ui/ddr4_v2_2_ui_cmd.sv" \
  "../../../bd/axi_interconnect_bd/ip/axi_interconnect_bd_ddr4_0_0/rtl/ui/ddr4_v2_2_ui.sv" \
  "../../../bd/axi_interconnect_bd/ip/axi_interconnect_bd_ddr4_0_0/rtl/axi/ddr4_v2_2_axi_ar_channel.sv" \
  "../../../bd/axi_interconnect_bd/ip/axi_interconnect_bd_ddr4_0_0/rtl/axi/ddr4_v2_2_axi_aw_channel.sv" \
  "../../../bd/axi_interconnect_bd/ip/axi_interconnect_bd_ddr4_0_0/rtl/axi/ddr4_v2_2_axi_b_channel.sv" \
  "../../../bd/axi_interconnect_bd/ip/axi_interconnect_bd_ddr4_0_0/rtl/axi/ddr4_v2_2_axi_cmd_arbiter.sv" \
  "../../../bd/axi_interconnect_bd/ip/axi_interconnect_bd_ddr4_0_0/rtl/axi/ddr4_v2_2_axi_cmd_fsm.sv" \
  "../../../bd/axi_interconnect_bd/ip/axi_interconnect_bd_ddr4_0_0/rtl/axi/ddr4_v2_2_axi_cmd_translator.sv" \
  "../../../bd/axi_interconnect_bd/ip/axi_interconnect_bd_ddr4_0_0/rtl/axi/ddr4_v2_2_axi_fifo.sv" \
  "../../../bd/axi_interconnect_bd/ip/axi_interconnect_bd_ddr4_0_0/rtl/axi/ddr4_v2_2_axi_incr_cmd.sv" \
  "../../../bd/axi_interconnect_bd/ip/axi_interconnect_bd_ddr4_0_0/rtl/axi/ddr4_v2_2_axi_r_channel.sv" \
  "../../../bd/axi_interconnect_bd/ip/axi_interconnect_bd_ddr4_0_0/rtl/axi/ddr4_v2_2_axi_w_channel.sv" \
  "../../../bd/axi_interconnect_bd/ip/axi_interconnect_bd_ddr4_0_0/rtl/axi/ddr4_v2_2_axi_wr_cmd_fsm.sv" \
  "../../../bd/axi_interconnect_bd/ip/axi_interconnect_bd_ddr4_0_0/rtl/axi/ddr4_v2_2_axi_wrap_cmd.sv" \
  "../../../bd/axi_interconnect_bd/ip/axi_interconnect_bd_ddr4_0_0/rtl/axi/ddr4_v2_2_a_upsizer.sv" \
  "../../../bd/axi_interconnect_bd/ip/axi_interconnect_bd_ddr4_0_0/rtl/axi/ddr4_v2_2_axi.sv" \
  "../../../bd/axi_interconnect_bd/ip/axi_interconnect_bd_ddr4_0_0/rtl/axi/ddr4_v2_2_axi_register_slice.sv" \
  "../../../bd/axi_interconnect_bd/ip/axi_interconnect_bd_ddr4_0_0/rtl/axi/ddr4_v2_2_axi_upsizer.sv" \
  "../../../bd/axi_interconnect_bd/ip/axi_interconnect_bd_ddr4_0_0/rtl/axi/ddr4_v2_2_axic_register_slice.sv" \
  "../../../bd/axi_interconnect_bd/ip/axi_interconnect_bd_ddr4_0_0/rtl/axi/ddr4_v2_2_carry_and.sv" \
  "../../../bd/axi_interconnect_bd/ip/axi_interconnect_bd_ddr4_0_0/rtl/axi/ddr4_v2_2_carry_latch_and.sv" \
  "../../../bd/axi_interconnect_bd/ip/axi_interconnect_bd_ddr4_0_0/rtl/axi/ddr4_v2_2_carry_latch_or.sv" \
  "../../../bd/axi_interconnect_bd/ip/axi_interconnect_bd_ddr4_0_0/rtl/axi/ddr4_v2_2_carry_or.sv" \
  "../../../bd/axi_interconnect_bd/ip/axi_interconnect_bd_ddr4_0_0/rtl/axi/ddr4_v2_2_command_fifo.sv" \
  "../../../bd/axi_interconnect_bd/ip/axi_interconnect_bd_ddr4_0_0/rtl/axi/ddr4_v2_2_comparator.sv" \
  "../../../bd/axi_interconnect_bd/ip/axi_interconnect_bd_ddr4_0_0/rtl/axi/ddr4_v2_2_comparator_sel.sv" \
  "../../../bd/axi_interconnect_bd/ip/axi_interconnect_bd_ddr4_0_0/rtl/axi/ddr4_v2_2_comparator_sel_static.sv" \
  "../../../bd/axi_interconnect_bd/ip/axi_interconnect_bd_ddr4_0_0/rtl/axi/ddr4_v2_2_r_upsizer.sv" \
  "../../../bd/axi_interconnect_bd/ip/axi_interconnect_bd_ddr4_0_0/rtl/axi/ddr4_v2_2_w_upsizer.sv" \
  "../../../bd/axi_interconnect_bd/ip/axi_interconnect_bd_ddr4_0_0/rtl/axi_ctrl/ddr4_v2_2_axi_ctrl_addr_decode.sv" \
  "../../../bd/axi_interconnect_bd/ip/axi_interconnect_bd_ddr4_0_0/rtl/axi_ctrl/ddr4_v2_2_axi_ctrl_read.sv" \
  "../../../bd/axi_interconnect_bd/ip/axi_interconnect_bd_ddr4_0_0/rtl/axi_ctrl/ddr4_v2_2_axi_ctrl_reg_bank.sv" \
  "../../../bd/axi_interconnect_bd/ip/axi_interconnect_bd_ddr4_0_0/rtl/axi_ctrl/ddr4_v2_2_axi_ctrl_reg.sv" \
  "../../../bd/axi_interconnect_bd/ip/axi_interconnect_bd_ddr4_0_0/rtl/axi_ctrl/ddr4_v2_2_axi_ctrl_top.sv" \
  "../../../bd/axi_interconnect_bd/ip/axi_interconnect_bd_ddr4_0_0/rtl/axi_ctrl/ddr4_v2_2_axi_ctrl_write.sv" \
  "../../../bd/axi_interconnect_bd/ip/axi_interconnect_bd_ddr4_0_0/rtl/clocking/ddr4_v2_2_infrastructure.sv" \
  "../../../bd/axi_interconnect_bd/ip/axi_interconnect_bd_ddr4_0_0/rtl/cal/ddr4_v2_2_cal_xsdb_bram.sv" \
  "../../../bd/axi_interconnect_bd/ip/axi_interconnect_bd_ddr4_0_0/rtl/cal/ddr4_v2_2_cal_write.sv" \
  "../../../bd/axi_interconnect_bd/ip/axi_interconnect_bd_ddr4_0_0/rtl/cal/ddr4_v2_2_cal_wr_byte.sv" \
  "../../../bd/axi_interconnect_bd/ip/axi_interconnect_bd_ddr4_0_0/rtl/cal/ddr4_v2_2_cal_wr_bit.sv" \
  "../../../bd/axi_interconnect_bd/ip/axi_interconnect_bd_ddr4_0_0/rtl/cal/ddr4_v2_2_cal_sync.sv" \
  "../../../bd/axi_interconnect_bd/ip/axi_interconnect_bd_ddr4_0_0/rtl/cal/ddr4_v2_2_cal_read.sv" \
  "../../../bd/axi_interconnect_bd/ip/axi_interconnect_bd_ddr4_0_0/rtl/cal/ddr4_v2_2_cal_rd_en.sv" \
  "../../../bd/axi_interconnect_bd/ip/axi_interconnect_bd_ddr4_0_0/rtl/cal/ddr4_v2_2_cal_pi.sv" \
  "../../../bd/axi_interconnect_bd/ip/axi_interconnect_bd_ddr4_0_0/rtl/cal/ddr4_v2_2_cal_mc_odt.sv" \
  "../../../bd/axi_interconnect_bd/ip/axi_interconnect_bd_ddr4_0_0/rtl/cal/ddr4_v2_2_cal_debug_microblaze.sv" \
  "../../../bd/axi_interconnect_bd/ip/axi_interconnect_bd_ddr4_0_0/rtl/cal/ddr4_v2_2_cal_cplx_data.sv" \
  "../../../bd/axi_interconnect_bd/ip/axi_interconnect_bd_ddr4_0_0/rtl/cal/ddr4_v2_2_cal_cplx.sv" \
  "../../../bd/axi_interconnect_bd/ip/axi_interconnect_bd_ddr4_0_0/rtl/cal/ddr4_v2_2_cal_config_rom.sv" \
  "../../../bd/axi_interconnect_bd/ip/axi_interconnect_bd_ddr4_0_0/rtl/cal/ddr4_v2_2_cal_addr_decode.sv" \
  "../../../bd/axi_interconnect_bd/ip/axi_interconnect_bd_ddr4_0_0/rtl/cal/ddr4_v2_2_cal_top.sv" \
  "../../../bd/axi_interconnect_bd/ip/axi_interconnect_bd_ddr4_0_0/rtl/cal/ddr4_v2_2_cal_xsdb_arbiter.sv" \
  "../../../bd/axi_interconnect_bd/ip/axi_interconnect_bd_ddr4_0_0/rtl/cal/ddr4_v2_2_cal.sv" \
  "../../../bd/axi_interconnect_bd/ip/axi_interconnect_bd_ddr4_0_0/rtl/cal/ddr4_v2_2_chipscope_xsdb_slave.sv" \
  "../../../bd/axi_interconnect_bd/ip/axi_interconnect_bd_ddr4_0_0/rtl/cal/ddr4_v2_2_dp_AB9.sv" \
  "../../../bd/axi_interconnect_bd/ip/axi_interconnect_bd_ddr4_0_0/rtl/ip_top/axi_interconnect_bd_ddr4_0_0.sv" \
  "../../../bd/axi_interconnect_bd/ip/axi_interconnect_bd_ddr4_0_0/rtl/ip_top/axi_interconnect_bd_ddr4_0_0_ddr4.sv" \
  "../../../bd/axi_interconnect_bd/ip/axi_interconnect_bd_ddr4_0_0/rtl/ip_top/axi_interconnect_bd_ddr4_0_0_ddr4_mem_intfc.sv" \
  "../../../bd/axi_interconnect_bd/ip/axi_interconnect_bd_ddr4_0_0/rtl/cal/axi_interconnect_bd_ddr4_0_0_ddr4_cal_riu.sv" \
  "../../../bd/axi_interconnect_bd/ip/axi_interconnect_bd_ddr4_0_0/tb/microblaze_mcs_0.sv" \
-endlib
-makelib xcelium_lib/util_vector_logic_v2_0_1 \
  "../../../../fuzzy_carnival_base.srcs/sources_1/bd/axi_interconnect_bd/ipshared/2137/hdl/util_vector_logic_v2_0_vl_rfs.v" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  "../../../bd/axi_interconnect_bd/ip/axi_interconnect_bd_resetn_inv_0_0/sim/axi_interconnect_bd_resetn_inv_0_0.v" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  "../../../bd/axi_interconnect_bd/ip/axi_interconnect_bd_rst_ddr4_0_300M_0/sim/axi_interconnect_bd_rst_ddr4_0_300M_0.vhd" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  "../../../bd/axi_interconnect_bd/sim/axi_interconnect_bd.v" \
-endlib
-makelib xcelium_lib/axi_protocol_converter_v2_1_20 \
  "../../../../fuzzy_carnival_base.srcs/sources_1/bd/axi_interconnect_bd/ipshared/c4a6/hdl/axi_protocol_converter_v2_1_vl_rfs.v" \
-endlib
-makelib xcelium_lib/axi_clock_converter_v2_1_19 \
  "../../../../fuzzy_carnival_base.srcs/sources_1/bd/axi_interconnect_bd/ipshared/9e81/hdl/axi_clock_converter_v2_1_vl_rfs.v" \
-endlib
-makelib xcelium_lib/axi_dwidth_converter_v2_1_20 \
  "../../../../fuzzy_carnival_base.srcs/sources_1/bd/axi_interconnect_bd/ipshared/d394/hdl/axi_dwidth_converter_v2_1_vl_rfs.v" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  "../../../bd/axi_interconnect_bd/ip/axi_interconnect_bd_auto_us_0/sim/axi_interconnect_bd_auto_us_0.v" \
  "../../../bd/axi_interconnect_bd/ip/axi_interconnect_bd_auto_cc_0/sim/axi_interconnect_bd_auto_cc_0.v" \
  "../../../bd/axi_interconnect_bd/ip/axi_interconnect_bd_auto_us_1/sim/axi_interconnect_bd_auto_us_1.v" \
  "../../../bd/axi_interconnect_bd/ip/axi_interconnect_bd_auto_cc_1/sim/axi_interconnect_bd_auto_cc_1.v" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  glbl.v
-endlib

