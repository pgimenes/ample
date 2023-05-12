// Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2019.2 (lin64) Build 2708876 Wed Nov  6 21:39:14 MST 2019
// Date        : Thu Apr 20 16:31:25 2023
// Host        : ee-beholder0.ee.ic.ac.uk running 64-bit CentOS Linux release 7.9.2009 (Core)
// Command     : write_verilog -force -mode synth_stub
//               /scratch/pg519/fuzzy_carnival/hw/hw.runs/aggregation_buffer_sdp_bram_synth_1/aggregation_buffer_sdp_bram_stub.v
// Design      : aggregation_buffer_sdp_bram
// Purpose     : Stub declaration of top-level module interface
// Device      : xcu250-figd2104-2L-e
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "blk_mem_gen_v8_4_4,Vivado 2019.2" *)
module aggregation_buffer_sdp_bram(clka, ena, wea, addra, dina, clkb, enb, addrb, doutb, 
  sleep)
/* synthesis syn_black_box black_box_pad_pin="clka,ena,wea[0:0],addra[8:0],dina[63:0],clkb,enb,addrb[9:0],doutb[31:0],sleep" */;
  input clka;
  input ena;
  input [0:0]wea;
  input [8:0]addra;
  input [63:0]dina;
  input clkb;
  input enb;
  input [9:0]addrb;
  output [31:0]doutb;
  input sleep;
endmodule
