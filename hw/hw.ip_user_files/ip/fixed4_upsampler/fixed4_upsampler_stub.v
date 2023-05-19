// Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2019.2 (lin64) Build 2708876 Wed Nov  6 21:39:14 MST 2019
// Date        : Fri May 19 14:47:01 2023
// Host        : ee-beholder0.ee.ic.ac.uk running 64-bit CentOS Linux release 7.9.2009 (Core)
// Command     : write_verilog -force -mode synth_stub
//               /scratch/pg519/fc_wa1/hw/hw.runs/fixed4_upsampler_synth_1/fixed4_upsampler_stub.v
// Design      : fixed4_upsampler
// Purpose     : Stub declaration of top-level module interface
// Device      : xcu250-figd2104-2L-e
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "floating_point_v7_1_9,Vivado 2019.2" *)
module fixed4_upsampler(aclk, aresetn, s_axis_a_tvalid, s_axis_a_tdata, 
  m_axis_result_tvalid, m_axis_result_tdata)
/* synthesis syn_black_box black_box_pad_pin="aclk,aresetn,s_axis_a_tvalid,s_axis_a_tdata[7:0],m_axis_result_tvalid,m_axis_result_tdata[31:0]" */;
  input aclk;
  input aresetn;
  input s_axis_a_tvalid;
  input [7:0]s_axis_a_tdata;
  output m_axis_result_tvalid;
  output [31:0]m_axis_result_tdata;
endmodule
