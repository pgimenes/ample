-makelib ies_lib/xpm -sv \
  "/usr/local/Xilinx/Vivado/2019.2/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \
-endlib
-makelib ies_lib/xpm \
  "/usr/local/Xilinx/Vivado/2019.2/data/ip/xpm/xpm_VCOMP.vhd" \
-endlib
-makelib ies_lib/microblaze_v11_0_2 \
  "../../../ipstatic/hdl/microblaze_v11_0_vh_rfs.vhd" \
-endlib
-makelib ies_lib/xil_defaultlib \
  "../../../../fuzzy_carnival_base.srcs/sources_1/ip/ddr4_0/bd_0/ip/ip_0/sim/bd_9054_microblaze_I_0.vhd" \
-endlib
-makelib ies_lib/lib_cdc_v1_0_2 \
  "../../../ipstatic/hdl/lib_cdc_v1_0_rfs.vhd" \
-endlib
-makelib ies_lib/proc_sys_reset_v5_0_13 \
  "../../../ipstatic/hdl/proc_sys_reset_v5_0_vh_rfs.vhd" \
-endlib
-makelib ies_lib/xil_defaultlib \
  "../../../../fuzzy_carnival_base.srcs/sources_1/ip/ddr4_0/bd_0/ip/ip_1/sim/bd_9054_rst_0_0.vhd" \
-endlib
-makelib ies_lib/lmb_v10_v3_0_10 \
  "../../../ipstatic/hdl/lmb_v10_v3_0_vh_rfs.vhd" \
-endlib
-makelib ies_lib/xil_defaultlib \
  "../../../../fuzzy_carnival_base.srcs/sources_1/ip/ddr4_0/bd_0/ip/ip_2/sim/bd_9054_ilmb_0.vhd" \
  "../../../../fuzzy_carnival_base.srcs/sources_1/ip/ddr4_0/bd_0/ip/ip_3/sim/bd_9054_dlmb_0.vhd" \
-endlib
-makelib ies_lib/lmb_bram_if_cntlr_v4_0_17 \
  "../../../ipstatic/hdl/lmb_bram_if_cntlr_v4_0_vh_rfs.vhd" \
-endlib
-makelib ies_lib/xil_defaultlib \
  "../../../../fuzzy_carnival_base.srcs/sources_1/ip/ddr4_0/bd_0/ip/ip_4/sim/bd_9054_dlmb_cntlr_0.vhd" \
  "../../../../fuzzy_carnival_base.srcs/sources_1/ip/ddr4_0/bd_0/ip/ip_5/sim/bd_9054_ilmb_cntlr_0.vhd" \
-endlib
-makelib ies_lib/blk_mem_gen_v8_4_4 \
  "../../../ipstatic/simulation/blk_mem_gen_v8_4.v" \
-endlib
-makelib ies_lib/xil_defaultlib \
  "../../../../fuzzy_carnival_base.srcs/sources_1/ip/ddr4_0/bd_0/ip/ip_6/sim/bd_9054_lmb_bram_I_0.v" \
-endlib
-makelib ies_lib/xil_defaultlib \
  "../../../../fuzzy_carnival_base.srcs/sources_1/ip/ddr4_0/bd_0/ip/ip_7/sim/bd_9054_second_dlmb_cntlr_0.vhd" \
  "../../../../fuzzy_carnival_base.srcs/sources_1/ip/ddr4_0/bd_0/ip/ip_8/sim/bd_9054_second_ilmb_cntlr_0.vhd" \
-endlib
-makelib ies_lib/xil_defaultlib \
  "../../../../fuzzy_carnival_base.srcs/sources_1/ip/ddr4_0/bd_0/ip/ip_9/sim/bd_9054_second_lmb_bram_I_0.v" \
-endlib
-makelib ies_lib/iomodule_v3_1_5 \
  "../../../ipstatic/hdl/iomodule_v3_1_vh_rfs.vhd" \
-endlib
-makelib ies_lib/xil_defaultlib \
  "../../../../fuzzy_carnival_base.srcs/sources_1/ip/ddr4_0/bd_0/ip/ip_10/sim/bd_9054_iomodule_0_0.vhd" \
-endlib
-makelib ies_lib/xil_defaultlib \
  "../../../../fuzzy_carnival_base.srcs/sources_1/ip/ddr4_0/bd_0/sim/bd_9054.v" \
  "../../../../fuzzy_carnival_base.srcs/sources_1/ip/ddr4_0/ip_0/sim/ddr4_0_microblaze_mcs.v" \
-endlib
-makelib ies_lib/xil_defaultlib -sv \
  "../../../../fuzzy_carnival_base.srcs/sources_1/ip/ddr4_0/ip_1/rtl/phy/ddr4_0_phy_ddr4.sv" \
  "../../../../fuzzy_carnival_base.srcs/sources_1/ip/ddr4_0/ip_1/rtl/phy/ddr4_phy_v2_2_xiphy_behav.sv" \
  "../../../../fuzzy_carnival_base.srcs/sources_1/ip/ddr4_0/ip_1/rtl/phy/ddr4_phy_v2_2_xiphy.sv" \
  "../../../../fuzzy_carnival_base.srcs/sources_1/ip/ddr4_0/ip_1/rtl/iob/ddr4_phy_v2_2_iob_byte.sv" \
  "../../../../fuzzy_carnival_base.srcs/sources_1/ip/ddr4_0/ip_1/rtl/iob/ddr4_phy_v2_2_iob.sv" \
  "../../../../fuzzy_carnival_base.srcs/sources_1/ip/ddr4_0/ip_1/rtl/clocking/ddr4_phy_v2_2_pll.sv" \
  "../../../../fuzzy_carnival_base.srcs/sources_1/ip/ddr4_0/ip_1/rtl/xiphy_files/ddr4_phy_v2_2_xiphy_tristate_wrapper.sv" \
  "../../../../fuzzy_carnival_base.srcs/sources_1/ip/ddr4_0/ip_1/rtl/xiphy_files/ddr4_phy_v2_2_xiphy_riuor_wrapper.sv" \
  "../../../../fuzzy_carnival_base.srcs/sources_1/ip/ddr4_0/ip_1/rtl/xiphy_files/ddr4_phy_v2_2_xiphy_control_wrapper.sv" \
  "../../../../fuzzy_carnival_base.srcs/sources_1/ip/ddr4_0/ip_1/rtl/xiphy_files/ddr4_phy_v2_2_xiphy_byte_wrapper.sv" \
  "../../../../fuzzy_carnival_base.srcs/sources_1/ip/ddr4_0/ip_1/rtl/xiphy_files/ddr4_phy_v2_2_xiphy_bitslice_wrapper.sv" \
  "../../../../fuzzy_carnival_base.srcs/sources_1/ip/ddr4_0/ip_1/rtl/ip_top/ddr4_0_phy.sv" \
  "../../../../fuzzy_carnival_base.srcs/sources_1/ip/ddr4_0/rtl/controller/ddr4_v2_2_mc_wtr.sv" \
  "../../../../fuzzy_carnival_base.srcs/sources_1/ip/ddr4_0/rtl/controller/ddr4_v2_2_mc_ref.sv" \
  "../../../../fuzzy_carnival_base.srcs/sources_1/ip/ddr4_0/rtl/controller/ddr4_v2_2_mc_rd_wr.sv" \
  "../../../../fuzzy_carnival_base.srcs/sources_1/ip/ddr4_0/rtl/controller/ddr4_v2_2_mc_periodic.sv" \
  "../../../../fuzzy_carnival_base.srcs/sources_1/ip/ddr4_0/rtl/controller/ddr4_v2_2_mc_group.sv" \
  "../../../../fuzzy_carnival_base.srcs/sources_1/ip/ddr4_0/rtl/controller/ddr4_v2_2_mc_ecc_merge_enc.sv" \
  "../../../../fuzzy_carnival_base.srcs/sources_1/ip/ddr4_0/rtl/controller/ddr4_v2_2_mc_ecc_gen.sv" \
  "../../../../fuzzy_carnival_base.srcs/sources_1/ip/ddr4_0/rtl/controller/ddr4_v2_2_mc_ecc_fi_xor.sv" \
  "../../../../fuzzy_carnival_base.srcs/sources_1/ip/ddr4_0/rtl/controller/ddr4_v2_2_mc_ecc_dec_fix.sv" \
  "../../../../fuzzy_carnival_base.srcs/sources_1/ip/ddr4_0/rtl/controller/ddr4_v2_2_mc_ecc_buf.sv" \
  "../../../../fuzzy_carnival_base.srcs/sources_1/ip/ddr4_0/rtl/controller/ddr4_v2_2_mc_ecc.sv" \
  "../../../../fuzzy_carnival_base.srcs/sources_1/ip/ddr4_0/rtl/controller/ddr4_v2_2_mc_ctl.sv" \
  "../../../../fuzzy_carnival_base.srcs/sources_1/ip/ddr4_0/rtl/controller/ddr4_v2_2_mc_cmd_mux_c.sv" \
  "../../../../fuzzy_carnival_base.srcs/sources_1/ip/ddr4_0/rtl/controller/ddr4_v2_2_mc_cmd_mux_ap.sv" \
  "../../../../fuzzy_carnival_base.srcs/sources_1/ip/ddr4_0/rtl/controller/ddr4_v2_2_mc_arb_p.sv" \
  "../../../../fuzzy_carnival_base.srcs/sources_1/ip/ddr4_0/rtl/controller/ddr4_v2_2_mc_arb_mux_p.sv" \
  "../../../../fuzzy_carnival_base.srcs/sources_1/ip/ddr4_0/rtl/controller/ddr4_v2_2_mc_arb_c.sv" \
  "../../../../fuzzy_carnival_base.srcs/sources_1/ip/ddr4_0/rtl/controller/ddr4_v2_2_mc_arb_a.sv" \
  "../../../../fuzzy_carnival_base.srcs/sources_1/ip/ddr4_0/rtl/controller/ddr4_v2_2_mc_act_timer.sv" \
  "../../../../fuzzy_carnival_base.srcs/sources_1/ip/ddr4_0/rtl/controller/ddr4_v2_2_mc_act_rank.sv" \
  "../../../../fuzzy_carnival_base.srcs/sources_1/ip/ddr4_0/rtl/controller/ddr4_v2_2_mc.sv" \
  "../../../../fuzzy_carnival_base.srcs/sources_1/ip/ddr4_0/rtl/ui/ddr4_v2_2_ui_wr_data.sv" \
  "../../../../fuzzy_carnival_base.srcs/sources_1/ip/ddr4_0/rtl/ui/ddr4_v2_2_ui_rd_data.sv" \
  "../../../../fuzzy_carnival_base.srcs/sources_1/ip/ddr4_0/rtl/ui/ddr4_v2_2_ui_cmd.sv" \
  "../../../../fuzzy_carnival_base.srcs/sources_1/ip/ddr4_0/rtl/ui/ddr4_v2_2_ui.sv" \
  "../../../../fuzzy_carnival_base.srcs/sources_1/ip/ddr4_0/rtl/axi/ddr4_v2_2_axi_ar_channel.sv" \
  "../../../../fuzzy_carnival_base.srcs/sources_1/ip/ddr4_0/rtl/axi/ddr4_v2_2_axi_aw_channel.sv" \
  "../../../../fuzzy_carnival_base.srcs/sources_1/ip/ddr4_0/rtl/axi/ddr4_v2_2_axi_b_channel.sv" \
  "../../../../fuzzy_carnival_base.srcs/sources_1/ip/ddr4_0/rtl/axi/ddr4_v2_2_axi_cmd_arbiter.sv" \
  "../../../../fuzzy_carnival_base.srcs/sources_1/ip/ddr4_0/rtl/axi/ddr4_v2_2_axi_cmd_fsm.sv" \
  "../../../../fuzzy_carnival_base.srcs/sources_1/ip/ddr4_0/rtl/axi/ddr4_v2_2_axi_cmd_translator.sv" \
  "../../../../fuzzy_carnival_base.srcs/sources_1/ip/ddr4_0/rtl/axi/ddr4_v2_2_axi_fifo.sv" \
  "../../../../fuzzy_carnival_base.srcs/sources_1/ip/ddr4_0/rtl/axi/ddr4_v2_2_axi_incr_cmd.sv" \
  "../../../../fuzzy_carnival_base.srcs/sources_1/ip/ddr4_0/rtl/axi/ddr4_v2_2_axi_r_channel.sv" \
  "../../../../fuzzy_carnival_base.srcs/sources_1/ip/ddr4_0/rtl/axi/ddr4_v2_2_axi_w_channel.sv" \
  "../../../../fuzzy_carnival_base.srcs/sources_1/ip/ddr4_0/rtl/axi/ddr4_v2_2_axi_wr_cmd_fsm.sv" \
  "../../../../fuzzy_carnival_base.srcs/sources_1/ip/ddr4_0/rtl/axi/ddr4_v2_2_axi_wrap_cmd.sv" \
  "../../../../fuzzy_carnival_base.srcs/sources_1/ip/ddr4_0/rtl/axi/ddr4_v2_2_a_upsizer.sv" \
  "../../../../fuzzy_carnival_base.srcs/sources_1/ip/ddr4_0/rtl/axi/ddr4_v2_2_axi.sv" \
  "../../../../fuzzy_carnival_base.srcs/sources_1/ip/ddr4_0/rtl/axi/ddr4_v2_2_axi_register_slice.sv" \
  "../../../../fuzzy_carnival_base.srcs/sources_1/ip/ddr4_0/rtl/axi/ddr4_v2_2_axi_upsizer.sv" \
  "../../../../fuzzy_carnival_base.srcs/sources_1/ip/ddr4_0/rtl/axi/ddr4_v2_2_axic_register_slice.sv" \
  "../../../../fuzzy_carnival_base.srcs/sources_1/ip/ddr4_0/rtl/axi/ddr4_v2_2_carry_and.sv" \
  "../../../../fuzzy_carnival_base.srcs/sources_1/ip/ddr4_0/rtl/axi/ddr4_v2_2_carry_latch_and.sv" \
  "../../../../fuzzy_carnival_base.srcs/sources_1/ip/ddr4_0/rtl/axi/ddr4_v2_2_carry_latch_or.sv" \
  "../../../../fuzzy_carnival_base.srcs/sources_1/ip/ddr4_0/rtl/axi/ddr4_v2_2_carry_or.sv" \
  "../../../../fuzzy_carnival_base.srcs/sources_1/ip/ddr4_0/rtl/axi/ddr4_v2_2_command_fifo.sv" \
  "../../../../fuzzy_carnival_base.srcs/sources_1/ip/ddr4_0/rtl/axi/ddr4_v2_2_comparator.sv" \
  "../../../../fuzzy_carnival_base.srcs/sources_1/ip/ddr4_0/rtl/axi/ddr4_v2_2_comparator_sel.sv" \
  "../../../../fuzzy_carnival_base.srcs/sources_1/ip/ddr4_0/rtl/axi/ddr4_v2_2_comparator_sel_static.sv" \
  "../../../../fuzzy_carnival_base.srcs/sources_1/ip/ddr4_0/rtl/axi/ddr4_v2_2_r_upsizer.sv" \
  "../../../../fuzzy_carnival_base.srcs/sources_1/ip/ddr4_0/rtl/axi/ddr4_v2_2_w_upsizer.sv" \
  "../../../../fuzzy_carnival_base.srcs/sources_1/ip/ddr4_0/rtl/axi_ctrl/ddr4_v2_2_axi_ctrl_addr_decode.sv" \
  "../../../../fuzzy_carnival_base.srcs/sources_1/ip/ddr4_0/rtl/axi_ctrl/ddr4_v2_2_axi_ctrl_read.sv" \
  "../../../../fuzzy_carnival_base.srcs/sources_1/ip/ddr4_0/rtl/axi_ctrl/ddr4_v2_2_axi_ctrl_reg_bank.sv" \
  "../../../../fuzzy_carnival_base.srcs/sources_1/ip/ddr4_0/rtl/axi_ctrl/ddr4_v2_2_axi_ctrl_reg.sv" \
  "../../../../fuzzy_carnival_base.srcs/sources_1/ip/ddr4_0/rtl/axi_ctrl/ddr4_v2_2_axi_ctrl_top.sv" \
  "../../../../fuzzy_carnival_base.srcs/sources_1/ip/ddr4_0/rtl/axi_ctrl/ddr4_v2_2_axi_ctrl_write.sv" \
  "../../../../fuzzy_carnival_base.srcs/sources_1/ip/ddr4_0/rtl/clocking/ddr4_v2_2_infrastructure.sv" \
  "../../../../fuzzy_carnival_base.srcs/sources_1/ip/ddr4_0/rtl/cal/ddr4_v2_2_cal_xsdb_bram.sv" \
  "../../../../fuzzy_carnival_base.srcs/sources_1/ip/ddr4_0/rtl/cal/ddr4_v2_2_cal_write.sv" \
  "../../../../fuzzy_carnival_base.srcs/sources_1/ip/ddr4_0/rtl/cal/ddr4_v2_2_cal_wr_byte.sv" \
  "../../../../fuzzy_carnival_base.srcs/sources_1/ip/ddr4_0/rtl/cal/ddr4_v2_2_cal_wr_bit.sv" \
  "../../../../fuzzy_carnival_base.srcs/sources_1/ip/ddr4_0/rtl/cal/ddr4_v2_2_cal_sync.sv" \
  "../../../../fuzzy_carnival_base.srcs/sources_1/ip/ddr4_0/rtl/cal/ddr4_v2_2_cal_read.sv" \
  "../../../../fuzzy_carnival_base.srcs/sources_1/ip/ddr4_0/rtl/cal/ddr4_v2_2_cal_rd_en.sv" \
  "../../../../fuzzy_carnival_base.srcs/sources_1/ip/ddr4_0/rtl/cal/ddr4_v2_2_cal_pi.sv" \
  "../../../../fuzzy_carnival_base.srcs/sources_1/ip/ddr4_0/rtl/cal/ddr4_v2_2_cal_mc_odt.sv" \
  "../../../../fuzzy_carnival_base.srcs/sources_1/ip/ddr4_0/rtl/cal/ddr4_v2_2_cal_debug_microblaze.sv" \
  "../../../../fuzzy_carnival_base.srcs/sources_1/ip/ddr4_0/rtl/cal/ddr4_v2_2_cal_cplx_data.sv" \
  "../../../../fuzzy_carnival_base.srcs/sources_1/ip/ddr4_0/rtl/cal/ddr4_v2_2_cal_cplx.sv" \
  "../../../../fuzzy_carnival_base.srcs/sources_1/ip/ddr4_0/rtl/cal/ddr4_v2_2_cal_config_rom.sv" \
  "../../../../fuzzy_carnival_base.srcs/sources_1/ip/ddr4_0/rtl/cal/ddr4_v2_2_cal_addr_decode.sv" \
  "../../../../fuzzy_carnival_base.srcs/sources_1/ip/ddr4_0/rtl/cal/ddr4_v2_2_cal_top.sv" \
  "../../../../fuzzy_carnival_base.srcs/sources_1/ip/ddr4_0/rtl/cal/ddr4_v2_2_cal_xsdb_arbiter.sv" \
  "../../../../fuzzy_carnival_base.srcs/sources_1/ip/ddr4_0/rtl/cal/ddr4_v2_2_cal.sv" \
  "../../../../fuzzy_carnival_base.srcs/sources_1/ip/ddr4_0/rtl/cal/ddr4_v2_2_chipscope_xsdb_slave.sv" \
  "../../../../fuzzy_carnival_base.srcs/sources_1/ip/ddr4_0/rtl/cal/ddr4_v2_2_dp_AB9.sv" \
  "../../../../fuzzy_carnival_base.srcs/sources_1/ip/ddr4_0/rtl/ip_top/ddr4_0_ddr4.sv" \
  "../../../../fuzzy_carnival_base.srcs/sources_1/ip/ddr4_0/rtl/ip_top/ddr4_0_ddr4_mem_intfc.sv" \
  "../../../../fuzzy_carnival_base.srcs/sources_1/ip/ddr4_0/rtl/cal/ddr4_0_ddr4_cal_riu.sv" \
  "../../../../fuzzy_carnival_base.srcs/sources_1/ip/ddr4_0/rtl/ip_top/ddr4_0.sv" \
  "../../../../fuzzy_carnival_base.srcs/sources_1/ip/ddr4_0/tb/microblaze_mcs_0.sv" \
-endlib
-makelib ies_lib/xil_defaultlib \
  glbl.v
-endlib

