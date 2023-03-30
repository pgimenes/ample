-makelib ies_lib/xilinx_vip -sv \
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
-makelib ies_lib/xpm -sv \
  "/mnt/applications/Xilinx/19.2/Vivado/2019.2/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
  "/mnt/applications/Xilinx/19.2/Vivado/2019.2/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \
-endlib
-makelib ies_lib/xpm \
  "/mnt/applications/Xilinx/19.2/Vivado/2019.2/data/ip/xpm/xpm_VCOMP.vhd" \
-endlib
-makelib ies_lib/microblaze_v11_0_2 \
  "../../../ipstatic/hdl/microblaze_v11_0_vh_rfs.vhd" \
-endlib
-makelib ies_lib/xil_defaultlib \
  "../../../ip/ddr4_0/bd_0/ip/ip_0/sim/bd_9054_microblaze_I_0.vhd" \
-endlib
-makelib ies_lib/lib_cdc_v1_0_2 \
  "../../../ipstatic/hdl/lib_cdc_v1_0_rfs.vhd" \
-endlib
-makelib ies_lib/proc_sys_reset_v5_0_13 \
  "../../../ipstatic/hdl/proc_sys_reset_v5_0_vh_rfs.vhd" \
-endlib
-makelib ies_lib/xil_defaultlib \
  "../../../ip/ddr4_0/bd_0/ip/ip_1/sim/bd_9054_rst_0_0.vhd" \
-endlib
-makelib ies_lib/lmb_v10_v3_0_10 \
  "../../../ipstatic/hdl/lmb_v10_v3_0_vh_rfs.vhd" \
-endlib
-makelib ies_lib/xil_defaultlib \
  "../../../ip/ddr4_0/bd_0/ip/ip_2/sim/bd_9054_ilmb_0.vhd" \
  "../../../ip/ddr4_0/bd_0/ip/ip_3/sim/bd_9054_dlmb_0.vhd" \
-endlib
-makelib ies_lib/lmb_bram_if_cntlr_v4_0_17 \
  "../../../ipstatic/hdl/lmb_bram_if_cntlr_v4_0_vh_rfs.vhd" \
-endlib
-makelib ies_lib/xil_defaultlib \
  "../../../ip/ddr4_0/bd_0/ip/ip_4/sim/bd_9054_dlmb_cntlr_0.vhd" \
  "../../../ip/ddr4_0/bd_0/ip/ip_5/sim/bd_9054_ilmb_cntlr_0.vhd" \
-endlib
-makelib ies_lib/blk_mem_gen_v8_4_4 \
  "../../../ipstatic/simulation/blk_mem_gen_v8_4.v" \
-endlib
-makelib ies_lib/xil_defaultlib \
  "../../../ip/ddr4_0/bd_0/ip/ip_6/sim/bd_9054_lmb_bram_I_0.v" \
-endlib
-makelib ies_lib/xil_defaultlib \
  "../../../ip/ddr4_0/bd_0/ip/ip_7/sim/bd_9054_second_dlmb_cntlr_0.vhd" \
  "../../../ip/ddr4_0/bd_0/ip/ip_8/sim/bd_9054_second_ilmb_cntlr_0.vhd" \
-endlib
-makelib ies_lib/xil_defaultlib \
  "../../../ip/ddr4_0/bd_0/ip/ip_9/sim/bd_9054_second_lmb_bram_I_0.v" \
-endlib
-makelib ies_lib/iomodule_v3_1_5 \
  "../../../ipstatic/hdl/iomodule_v3_1_vh_rfs.vhd" \
-endlib
-makelib ies_lib/xil_defaultlib \
  "../../../ip/ddr4_0/bd_0/ip/ip_10/sim/bd_9054_iomodule_0_0.vhd" \
-endlib
-makelib ies_lib/xil_defaultlib \
  "../../../ip/ddr4_0/bd_0/sim/bd_9054.v" \
  "../../../ip/ddr4_0/ip_0/sim/ddr4_0_microblaze_mcs.v" \
-endlib
-makelib ies_lib/xil_defaultlib -sv \
  "../../../ip/ddr4_0/ip_1/rtl/phy/ddr4_0_phy_ddr4.sv" \
  "../../../ip/ddr4_0/ip_1/rtl/phy/ddr4_phy_v2_2_xiphy_behav.sv" \
  "../../../ip/ddr4_0/ip_1/rtl/phy/ddr4_phy_v2_2_xiphy.sv" \
  "../../../ip/ddr4_0/ip_1/rtl/iob/ddr4_phy_v2_2_iob_byte.sv" \
  "../../../ip/ddr4_0/ip_1/rtl/iob/ddr4_phy_v2_2_iob.sv" \
  "../../../ip/ddr4_0/ip_1/rtl/clocking/ddr4_phy_v2_2_pll.sv" \
  "../../../ip/ddr4_0/ip_1/rtl/xiphy_files/ddr4_phy_v2_2_xiphy_tristate_wrapper.sv" \
  "../../../ip/ddr4_0/ip_1/rtl/xiphy_files/ddr4_phy_v2_2_xiphy_riuor_wrapper.sv" \
  "../../../ip/ddr4_0/ip_1/rtl/xiphy_files/ddr4_phy_v2_2_xiphy_control_wrapper.sv" \
  "../../../ip/ddr4_0/ip_1/rtl/xiphy_files/ddr4_phy_v2_2_xiphy_byte_wrapper.sv" \
  "../../../ip/ddr4_0/ip_1/rtl/xiphy_files/ddr4_phy_v2_2_xiphy_bitslice_wrapper.sv" \
  "../../../ip/ddr4_0/ip_1/rtl/ip_top/ddr4_0_phy.sv" \
  "../../../ip/ddr4_0/rtl/controller/ddr4_v2_2_mc_wtr.sv" \
  "../../../ip/ddr4_0/rtl/controller/ddr4_v2_2_mc_ref.sv" \
  "../../../ip/ddr4_0/rtl/controller/ddr4_v2_2_mc_rd_wr.sv" \
  "../../../ip/ddr4_0/rtl/controller/ddr4_v2_2_mc_periodic.sv" \
  "../../../ip/ddr4_0/rtl/controller/ddr4_v2_2_mc_group.sv" \
  "../../../ip/ddr4_0/rtl/controller/ddr4_v2_2_mc_ecc_merge_enc.sv" \
  "../../../ip/ddr4_0/rtl/controller/ddr4_v2_2_mc_ecc_gen.sv" \
  "../../../ip/ddr4_0/rtl/controller/ddr4_v2_2_mc_ecc_fi_xor.sv" \
  "../../../ip/ddr4_0/rtl/controller/ddr4_v2_2_mc_ecc_dec_fix.sv" \
  "../../../ip/ddr4_0/rtl/controller/ddr4_v2_2_mc_ecc_buf.sv" \
  "../../../ip/ddr4_0/rtl/controller/ddr4_v2_2_mc_ecc.sv" \
  "../../../ip/ddr4_0/rtl/controller/ddr4_v2_2_mc_ctl.sv" \
  "../../../ip/ddr4_0/rtl/controller/ddr4_v2_2_mc_cmd_mux_c.sv" \
  "../../../ip/ddr4_0/rtl/controller/ddr4_v2_2_mc_cmd_mux_ap.sv" \
  "../../../ip/ddr4_0/rtl/controller/ddr4_v2_2_mc_arb_p.sv" \
  "../../../ip/ddr4_0/rtl/controller/ddr4_v2_2_mc_arb_mux_p.sv" \
  "../../../ip/ddr4_0/rtl/controller/ddr4_v2_2_mc_arb_c.sv" \
  "../../../ip/ddr4_0/rtl/controller/ddr4_v2_2_mc_arb_a.sv" \
  "../../../ip/ddr4_0/rtl/controller/ddr4_v2_2_mc_act_timer.sv" \
  "../../../ip/ddr4_0/rtl/controller/ddr4_v2_2_mc_act_rank.sv" \
  "../../../ip/ddr4_0/rtl/controller/ddr4_v2_2_mc.sv" \
  "../../../ip/ddr4_0/rtl/ui/ddr4_v2_2_ui_wr_data.sv" \
  "../../../ip/ddr4_0/rtl/ui/ddr4_v2_2_ui_rd_data.sv" \
  "../../../ip/ddr4_0/rtl/ui/ddr4_v2_2_ui_cmd.sv" \
  "../../../ip/ddr4_0/rtl/ui/ddr4_v2_2_ui.sv" \
  "../../../ip/ddr4_0/rtl/axi/ddr4_v2_2_axi_ar_channel.sv" \
  "../../../ip/ddr4_0/rtl/axi/ddr4_v2_2_axi_aw_channel.sv" \
  "../../../ip/ddr4_0/rtl/axi/ddr4_v2_2_axi_b_channel.sv" \
  "../../../ip/ddr4_0/rtl/axi/ddr4_v2_2_axi_cmd_arbiter.sv" \
  "../../../ip/ddr4_0/rtl/axi/ddr4_v2_2_axi_cmd_fsm.sv" \
  "../../../ip/ddr4_0/rtl/axi/ddr4_v2_2_axi_cmd_translator.sv" \
  "../../../ip/ddr4_0/rtl/axi/ddr4_v2_2_axi_fifo.sv" \
  "../../../ip/ddr4_0/rtl/axi/ddr4_v2_2_axi_incr_cmd.sv" \
  "../../../ip/ddr4_0/rtl/axi/ddr4_v2_2_axi_r_channel.sv" \
  "../../../ip/ddr4_0/rtl/axi/ddr4_v2_2_axi_w_channel.sv" \
  "../../../ip/ddr4_0/rtl/axi/ddr4_v2_2_axi_wr_cmd_fsm.sv" \
  "../../../ip/ddr4_0/rtl/axi/ddr4_v2_2_axi_wrap_cmd.sv" \
  "../../../ip/ddr4_0/rtl/axi/ddr4_v2_2_a_upsizer.sv" \
  "../../../ip/ddr4_0/rtl/axi/ddr4_v2_2_axi.sv" \
  "../../../ip/ddr4_0/rtl/axi/ddr4_v2_2_axi_register_slice.sv" \
  "../../../ip/ddr4_0/rtl/axi/ddr4_v2_2_axi_upsizer.sv" \
  "../../../ip/ddr4_0/rtl/axi/ddr4_v2_2_axic_register_slice.sv" \
  "../../../ip/ddr4_0/rtl/axi/ddr4_v2_2_carry_and.sv" \
  "../../../ip/ddr4_0/rtl/axi/ddr4_v2_2_carry_latch_and.sv" \
  "../../../ip/ddr4_0/rtl/axi/ddr4_v2_2_carry_latch_or.sv" \
  "../../../ip/ddr4_0/rtl/axi/ddr4_v2_2_carry_or.sv" \
  "../../../ip/ddr4_0/rtl/axi/ddr4_v2_2_command_fifo.sv" \
  "../../../ip/ddr4_0/rtl/axi/ddr4_v2_2_comparator.sv" \
  "../../../ip/ddr4_0/rtl/axi/ddr4_v2_2_comparator_sel.sv" \
  "../../../ip/ddr4_0/rtl/axi/ddr4_v2_2_comparator_sel_static.sv" \
  "../../../ip/ddr4_0/rtl/axi/ddr4_v2_2_r_upsizer.sv" \
  "../../../ip/ddr4_0/rtl/axi/ddr4_v2_2_w_upsizer.sv" \
  "../../../ip/ddr4_0/rtl/axi_ctrl/ddr4_v2_2_axi_ctrl_addr_decode.sv" \
  "../../../ip/ddr4_0/rtl/axi_ctrl/ddr4_v2_2_axi_ctrl_read.sv" \
  "../../../ip/ddr4_0/rtl/axi_ctrl/ddr4_v2_2_axi_ctrl_reg_bank.sv" \
  "../../../ip/ddr4_0/rtl/axi_ctrl/ddr4_v2_2_axi_ctrl_reg.sv" \
  "../../../ip/ddr4_0/rtl/axi_ctrl/ddr4_v2_2_axi_ctrl_top.sv" \
  "../../../ip/ddr4_0/rtl/axi_ctrl/ddr4_v2_2_axi_ctrl_write.sv" \
  "../../../ip/ddr4_0/rtl/clocking/ddr4_v2_2_infrastructure.sv" \
  "../../../ip/ddr4_0/rtl/cal/ddr4_v2_2_cal_xsdb_bram.sv" \
  "../../../ip/ddr4_0/rtl/cal/ddr4_v2_2_cal_write.sv" \
  "../../../ip/ddr4_0/rtl/cal/ddr4_v2_2_cal_wr_byte.sv" \
  "../../../ip/ddr4_0/rtl/cal/ddr4_v2_2_cal_wr_bit.sv" \
  "../../../ip/ddr4_0/rtl/cal/ddr4_v2_2_cal_sync.sv" \
  "../../../ip/ddr4_0/rtl/cal/ddr4_v2_2_cal_read.sv" \
  "../../../ip/ddr4_0/rtl/cal/ddr4_v2_2_cal_rd_en.sv" \
  "../../../ip/ddr4_0/rtl/cal/ddr4_v2_2_cal_pi.sv" \
  "../../../ip/ddr4_0/rtl/cal/ddr4_v2_2_cal_mc_odt.sv" \
  "../../../ip/ddr4_0/rtl/cal/ddr4_v2_2_cal_debug_microblaze.sv" \
  "../../../ip/ddr4_0/rtl/cal/ddr4_v2_2_cal_cplx_data.sv" \
  "../../../ip/ddr4_0/rtl/cal/ddr4_v2_2_cal_cplx.sv" \
  "../../../ip/ddr4_0/rtl/cal/ddr4_v2_2_cal_config_rom.sv" \
  "../../../ip/ddr4_0/rtl/cal/ddr4_v2_2_cal_addr_decode.sv" \
  "../../../ip/ddr4_0/rtl/cal/ddr4_v2_2_cal_top.sv" \
  "../../../ip/ddr4_0/rtl/cal/ddr4_v2_2_cal_xsdb_arbiter.sv" \
  "../../../ip/ddr4_0/rtl/cal/ddr4_v2_2_cal.sv" \
  "../../../ip/ddr4_0/rtl/cal/ddr4_v2_2_chipscope_xsdb_slave.sv" \
  "../../../ip/ddr4_0/rtl/cal/ddr4_v2_2_dp_AB9.sv" \
  "../../../ip/ddr4_0/rtl/ip_top/ddr4_0_ddr4.sv" \
  "../../../ip/ddr4_0/rtl/ip_top/ddr4_0_ddr4_mem_intfc.sv" \
  "../../../ip/ddr4_0/rtl/cal/ddr4_0_ddr4_cal_riu.sv" \
  "../../../ip/ddr4_0/rtl/ip_top/ddr4_0.sv" \
  "../../../ip/ddr4_0/tb/microblaze_mcs_0.sv" \
-endlib
-makelib ies_lib/xil_defaultlib \
  glbl.v
-endlib

