// Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2019.2 (lin64) Build 2708876 Wed Nov  6 21:39:14 MST 2019
// Date        : Fri May 19 14:47:01 2023
// Host        : ee-beholder0.ee.ic.ac.uk running 64-bit CentOS Linux release 7.9.2009 (Core)
// Command     : write_verilog -force -mode funcsim
//               /scratch/pg519/fc_wa1/hw/hw.runs/fixed4_upsampler_synth_1/fixed4_upsampler_sim_netlist.v
// Design      : fixed4_upsampler
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xcu250-figd2104-2L-e
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "fixed4_upsampler,floating_point_v7_1_9,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "floating_point_v7_1_9,Vivado 2019.2" *) 
(* NotValidForBitStream *)
module fixed4_upsampler
   (aclk,
    aresetn,
    s_axis_a_tvalid,
    s_axis_a_tdata,
    m_axis_result_tvalid,
    m_axis_result_tdata);
  (* x_interface_info = "xilinx.com:signal:clock:1.0 aclk_intf CLK" *) (* x_interface_parameter = "XIL_INTERFACENAME aclk_intf, ASSOCIATED_BUSIF S_AXIS_OPERATION:M_AXIS_RESULT:S_AXIS_C:S_AXIS_B:S_AXIS_A, ASSOCIATED_RESET aresetn, ASSOCIATED_CLKEN aclken, FREQ_HZ 10000000, PHASE 0.000, INSERT_VIP 0" *) input aclk;
  (* x_interface_info = "xilinx.com:signal:reset:1.0 aresetn_intf RST" *) (* x_interface_parameter = "XIL_INTERFACENAME aresetn_intf, POLARITY ACTIVE_LOW, INSERT_VIP 0" *) input aresetn;
  (* x_interface_info = "xilinx.com:interface:axis:1.0 S_AXIS_A TVALID" *) (* x_interface_parameter = "XIL_INTERFACENAME S_AXIS_A, TDATA_NUM_BYTES 1, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0, HAS_TREADY 0, HAS_TSTRB 0, HAS_TKEEP 0, HAS_TLAST 0, FREQ_HZ 100000000, PHASE 0.000, LAYERED_METADATA undef, INSERT_VIP 0" *) input s_axis_a_tvalid;
  (* x_interface_info = "xilinx.com:interface:axis:1.0 S_AXIS_A TDATA" *) input [7:0]s_axis_a_tdata;
  (* x_interface_info = "xilinx.com:interface:axis:1.0 M_AXIS_RESULT TVALID" *) (* x_interface_parameter = "XIL_INTERFACENAME M_AXIS_RESULT, TDATA_NUM_BYTES 4, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0, HAS_TREADY 0, HAS_TSTRB 0, HAS_TKEEP 0, HAS_TLAST 0, FREQ_HZ 100000000, PHASE 0.000, LAYERED_METADATA undef, INSERT_VIP 0" *) output m_axis_result_tvalid;
  (* x_interface_info = "xilinx.com:interface:axis:1.0 M_AXIS_RESULT TDATA" *) output [31:0]m_axis_result_tdata;

  wire aclk;
  wire aresetn;
  wire [31:0]m_axis_result_tdata;
  wire m_axis_result_tvalid;
  wire [7:0]s_axis_a_tdata;
  wire s_axis_a_tvalid;
  wire NLW_U0_m_axis_result_tlast_UNCONNECTED;
  wire NLW_U0_s_axis_a_tready_UNCONNECTED;
  wire NLW_U0_s_axis_b_tready_UNCONNECTED;
  wire NLW_U0_s_axis_c_tready_UNCONNECTED;
  wire NLW_U0_s_axis_operation_tready_UNCONNECTED;
  wire [0:0]NLW_U0_m_axis_result_tuser_UNCONNECTED;

  (* C_ACCUM_INPUT_MSB = "7" *) 
  (* C_ACCUM_LSB = "-5" *) 
  (* C_ACCUM_MSB = "32" *) 
  (* C_A_FRACTION_WIDTH = "0" *) 
  (* C_A_TDATA_WIDTH = "8" *) 
  (* C_A_TUSER_WIDTH = "1" *) 
  (* C_A_WIDTH = "4" *) 
  (* C_BRAM_USAGE = "0" *) 
  (* C_B_FRACTION_WIDTH = "0" *) 
  (* C_B_TDATA_WIDTH = "8" *) 
  (* C_B_TUSER_WIDTH = "1" *) 
  (* C_B_WIDTH = "4" *) 
  (* C_COMPARE_OPERATION = "8" *) 
  (* C_C_FRACTION_WIDTH = "0" *) 
  (* C_C_TDATA_WIDTH = "8" *) 
  (* C_C_TUSER_WIDTH = "1" *) 
  (* C_C_WIDTH = "4" *) 
  (* C_FIXED_DATA_UNSIGNED = "0" *) 
  (* C_HAS_ABSOLUTE = "0" *) 
  (* C_HAS_ACCUMULATOR_A = "0" *) 
  (* C_HAS_ACCUMULATOR_PRIMITIVE_A = "0" *) 
  (* C_HAS_ACCUMULATOR_PRIMITIVE_S = "0" *) 
  (* C_HAS_ACCUMULATOR_S = "0" *) 
  (* C_HAS_ACCUM_INPUT_OVERFLOW = "0" *) 
  (* C_HAS_ACCUM_OVERFLOW = "0" *) 
  (* C_HAS_ACLKEN = "0" *) 
  (* C_HAS_ADD = "0" *) 
  (* C_HAS_ARESETN = "1" *) 
  (* C_HAS_A_TLAST = "0" *) 
  (* C_HAS_A_TUSER = "0" *) 
  (* C_HAS_B = "0" *) 
  (* C_HAS_B_TLAST = "0" *) 
  (* C_HAS_B_TUSER = "0" *) 
  (* C_HAS_C = "0" *) 
  (* C_HAS_COMPARE = "0" *) 
  (* C_HAS_C_TLAST = "0" *) 
  (* C_HAS_C_TUSER = "0" *) 
  (* C_HAS_DIVIDE = "0" *) 
  (* C_HAS_DIVIDE_BY_ZERO = "0" *) 
  (* C_HAS_EXPONENTIAL = "0" *) 
  (* C_HAS_FIX_TO_FLT = "1" *) 
  (* C_HAS_FLT_TO_FIX = "0" *) 
  (* C_HAS_FLT_TO_FLT = "0" *) 
  (* C_HAS_FMA = "0" *) 
  (* C_HAS_FMS = "0" *) 
  (* C_HAS_INVALID_OP = "0" *) 
  (* C_HAS_LOGARITHM = "0" *) 
  (* C_HAS_MULTIPLY = "0" *) 
  (* C_HAS_OPERATION = "0" *) 
  (* C_HAS_OPERATION_TLAST = "0" *) 
  (* C_HAS_OPERATION_TUSER = "0" *) 
  (* C_HAS_OVERFLOW = "0" *) 
  (* C_HAS_RECIP = "0" *) 
  (* C_HAS_RECIP_SQRT = "0" *) 
  (* C_HAS_RESULT_TLAST = "0" *) 
  (* C_HAS_RESULT_TUSER = "0" *) 
  (* C_HAS_SQRT = "0" *) 
  (* C_HAS_SUBTRACT = "0" *) 
  (* C_HAS_UNDERFLOW = "0" *) 
  (* C_HAS_UNFUSED_MULTIPLY_ACCUMULATOR_A = "0" *) 
  (* C_HAS_UNFUSED_MULTIPLY_ACCUMULATOR_S = "0" *) 
  (* C_HAS_UNFUSED_MULTIPLY_ADD = "0" *) 
  (* C_HAS_UNFUSED_MULTIPLY_SUB = "0" *) 
  (* C_LATENCY = "5" *) 
  (* C_MULT_USAGE = "0" *) 
  (* C_OPERATION_TDATA_WIDTH = "8" *) 
  (* C_OPERATION_TUSER_WIDTH = "1" *) 
  (* C_OPTIMIZATION = "1" *) 
  (* C_RATE = "1" *) 
  (* C_RESULT_FRACTION_WIDTH = "24" *) 
  (* C_RESULT_TDATA_WIDTH = "32" *) 
  (* C_RESULT_TUSER_WIDTH = "1" *) 
  (* C_RESULT_WIDTH = "32" *) 
  (* C_THROTTLE_SCHEME = "3" *) 
  (* C_TLAST_RESOLUTION = "0" *) 
  (* C_XDEVICEFAMILY = "virtexuplus" *) 
  (* downgradeipidentifiedwarnings = "yes" *) 
  fixed4_upsampler_floating_point_v7_1_9 U0
       (.aclk(aclk),
        .aclken(1'b1),
        .aresetn(aresetn),
        .m_axis_result_tdata(m_axis_result_tdata),
        .m_axis_result_tlast(NLW_U0_m_axis_result_tlast_UNCONNECTED),
        .m_axis_result_tready(1'b0),
        .m_axis_result_tuser(NLW_U0_m_axis_result_tuser_UNCONNECTED[0]),
        .m_axis_result_tvalid(m_axis_result_tvalid),
        .s_axis_a_tdata(s_axis_a_tdata),
        .s_axis_a_tlast(1'b0),
        .s_axis_a_tready(NLW_U0_s_axis_a_tready_UNCONNECTED),
        .s_axis_a_tuser(1'b0),
        .s_axis_a_tvalid(s_axis_a_tvalid),
        .s_axis_b_tdata({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axis_b_tlast(1'b0),
        .s_axis_b_tready(NLW_U0_s_axis_b_tready_UNCONNECTED),
        .s_axis_b_tuser(1'b0),
        .s_axis_b_tvalid(1'b0),
        .s_axis_c_tdata({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axis_c_tlast(1'b0),
        .s_axis_c_tready(NLW_U0_s_axis_c_tready_UNCONNECTED),
        .s_axis_c_tuser(1'b0),
        .s_axis_c_tvalid(1'b0),
        .s_axis_operation_tdata({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axis_operation_tlast(1'b0),
        .s_axis_operation_tready(NLW_U0_s_axis_operation_tready_UNCONNECTED),
        .s_axis_operation_tuser(1'b0),
        .s_axis_operation_tvalid(1'b0));
endmodule

(* C_ACCUM_INPUT_MSB = "7" *) (* C_ACCUM_LSB = "-5" *) (* C_ACCUM_MSB = "32" *) 
(* C_A_FRACTION_WIDTH = "0" *) (* C_A_TDATA_WIDTH = "8" *) (* C_A_TUSER_WIDTH = "1" *) 
(* C_A_WIDTH = "4" *) (* C_BRAM_USAGE = "0" *) (* C_B_FRACTION_WIDTH = "0" *) 
(* C_B_TDATA_WIDTH = "8" *) (* C_B_TUSER_WIDTH = "1" *) (* C_B_WIDTH = "4" *) 
(* C_COMPARE_OPERATION = "8" *) (* C_C_FRACTION_WIDTH = "0" *) (* C_C_TDATA_WIDTH = "8" *) 
(* C_C_TUSER_WIDTH = "1" *) (* C_C_WIDTH = "4" *) (* C_FIXED_DATA_UNSIGNED = "0" *) 
(* C_HAS_ABSOLUTE = "0" *) (* C_HAS_ACCUMULATOR_A = "0" *) (* C_HAS_ACCUMULATOR_PRIMITIVE_A = "0" *) 
(* C_HAS_ACCUMULATOR_PRIMITIVE_S = "0" *) (* C_HAS_ACCUMULATOR_S = "0" *) (* C_HAS_ACCUM_INPUT_OVERFLOW = "0" *) 
(* C_HAS_ACCUM_OVERFLOW = "0" *) (* C_HAS_ACLKEN = "0" *) (* C_HAS_ADD = "0" *) 
(* C_HAS_ARESETN = "1" *) (* C_HAS_A_TLAST = "0" *) (* C_HAS_A_TUSER = "0" *) 
(* C_HAS_B = "0" *) (* C_HAS_B_TLAST = "0" *) (* C_HAS_B_TUSER = "0" *) 
(* C_HAS_C = "0" *) (* C_HAS_COMPARE = "0" *) (* C_HAS_C_TLAST = "0" *) 
(* C_HAS_C_TUSER = "0" *) (* C_HAS_DIVIDE = "0" *) (* C_HAS_DIVIDE_BY_ZERO = "0" *) 
(* C_HAS_EXPONENTIAL = "0" *) (* C_HAS_FIX_TO_FLT = "1" *) (* C_HAS_FLT_TO_FIX = "0" *) 
(* C_HAS_FLT_TO_FLT = "0" *) (* C_HAS_FMA = "0" *) (* C_HAS_FMS = "0" *) 
(* C_HAS_INVALID_OP = "0" *) (* C_HAS_LOGARITHM = "0" *) (* C_HAS_MULTIPLY = "0" *) 
(* C_HAS_OPERATION = "0" *) (* C_HAS_OPERATION_TLAST = "0" *) (* C_HAS_OPERATION_TUSER = "0" *) 
(* C_HAS_OVERFLOW = "0" *) (* C_HAS_RECIP = "0" *) (* C_HAS_RECIP_SQRT = "0" *) 
(* C_HAS_RESULT_TLAST = "0" *) (* C_HAS_RESULT_TUSER = "0" *) (* C_HAS_SQRT = "0" *) 
(* C_HAS_SUBTRACT = "0" *) (* C_HAS_UNDERFLOW = "0" *) (* C_HAS_UNFUSED_MULTIPLY_ACCUMULATOR_A = "0" *) 
(* C_HAS_UNFUSED_MULTIPLY_ACCUMULATOR_S = "0" *) (* C_HAS_UNFUSED_MULTIPLY_ADD = "0" *) (* C_HAS_UNFUSED_MULTIPLY_SUB = "0" *) 
(* C_LATENCY = "5" *) (* C_MULT_USAGE = "0" *) (* C_OPERATION_TDATA_WIDTH = "8" *) 
(* C_OPERATION_TUSER_WIDTH = "1" *) (* C_OPTIMIZATION = "1" *) (* C_RATE = "1" *) 
(* C_RESULT_FRACTION_WIDTH = "24" *) (* C_RESULT_TDATA_WIDTH = "32" *) (* C_RESULT_TUSER_WIDTH = "1" *) 
(* C_RESULT_WIDTH = "32" *) (* C_THROTTLE_SCHEME = "3" *) (* C_TLAST_RESOLUTION = "0" *) 
(* C_XDEVICEFAMILY = "virtexuplus" *) (* ORIG_REF_NAME = "floating_point_v7_1_9" *) (* downgradeipidentifiedwarnings = "yes" *) 
module fixed4_upsampler_floating_point_v7_1_9
   (aclk,
    aclken,
    aresetn,
    s_axis_a_tvalid,
    s_axis_a_tready,
    s_axis_a_tdata,
    s_axis_a_tuser,
    s_axis_a_tlast,
    s_axis_b_tvalid,
    s_axis_b_tready,
    s_axis_b_tdata,
    s_axis_b_tuser,
    s_axis_b_tlast,
    s_axis_c_tvalid,
    s_axis_c_tready,
    s_axis_c_tdata,
    s_axis_c_tuser,
    s_axis_c_tlast,
    s_axis_operation_tvalid,
    s_axis_operation_tready,
    s_axis_operation_tdata,
    s_axis_operation_tuser,
    s_axis_operation_tlast,
    m_axis_result_tvalid,
    m_axis_result_tready,
    m_axis_result_tdata,
    m_axis_result_tuser,
    m_axis_result_tlast);
  input aclk;
  input aclken;
  input aresetn;
  input s_axis_a_tvalid;
  output s_axis_a_tready;
  input [7:0]s_axis_a_tdata;
  input [0:0]s_axis_a_tuser;
  input s_axis_a_tlast;
  input s_axis_b_tvalid;
  output s_axis_b_tready;
  input [7:0]s_axis_b_tdata;
  input [0:0]s_axis_b_tuser;
  input s_axis_b_tlast;
  input s_axis_c_tvalid;
  output s_axis_c_tready;
  input [7:0]s_axis_c_tdata;
  input [0:0]s_axis_c_tuser;
  input s_axis_c_tlast;
  input s_axis_operation_tvalid;
  output s_axis_operation_tready;
  input [7:0]s_axis_operation_tdata;
  input [0:0]s_axis_operation_tuser;
  input s_axis_operation_tlast;
  output m_axis_result_tvalid;
  input m_axis_result_tready;
  output [31:0]m_axis_result_tdata;
  output [0:0]m_axis_result_tuser;
  output m_axis_result_tlast;

  wire \<const0> ;
  wire \<const1> ;
  wire aclk;
  wire aresetn;
  wire [31:0]\^m_axis_result_tdata ;
  wire m_axis_result_tvalid;
  wire [7:0]s_axis_a_tdata;
  wire s_axis_a_tvalid;
  wire NLW_i_synth_m_axis_result_tlast_UNCONNECTED;
  wire NLW_i_synth_s_axis_a_tready_UNCONNECTED;
  wire NLW_i_synth_s_axis_b_tready_UNCONNECTED;
  wire NLW_i_synth_s_axis_c_tready_UNCONNECTED;
  wire NLW_i_synth_s_axis_operation_tready_UNCONNECTED;
  wire [27:26]NLW_i_synth_m_axis_result_tdata_UNCONNECTED;
  wire [0:0]NLW_i_synth_m_axis_result_tuser_UNCONNECTED;

  assign m_axis_result_tdata[31:30] = \^m_axis_result_tdata [31:30];
  assign m_axis_result_tdata[29:28] = \^m_axis_result_tdata [27:26];
  assign m_axis_result_tdata[27:0] = \^m_axis_result_tdata [27:0];
  assign m_axis_result_tlast = \<const0> ;
  assign m_axis_result_tuser[0] = \<const0> ;
  assign s_axis_a_tready = \<const1> ;
  assign s_axis_b_tready = \<const1> ;
  assign s_axis_c_tready = \<const1> ;
  assign s_axis_operation_tready = \<const1> ;
  GND GND
       (.G(\<const0> ));
  VCC VCC
       (.P(\<const1> ));
  (* C_ACCUM_INPUT_MSB = "7" *) 
  (* C_ACCUM_LSB = "-5" *) 
  (* C_ACCUM_MSB = "32" *) 
  (* C_A_FRACTION_WIDTH = "0" *) 
  (* C_A_TDATA_WIDTH = "8" *) 
  (* C_A_TUSER_WIDTH = "1" *) 
  (* C_A_WIDTH = "4" *) 
  (* C_BRAM_USAGE = "0" *) 
  (* C_B_FRACTION_WIDTH = "0" *) 
  (* C_B_TDATA_WIDTH = "8" *) 
  (* C_B_TUSER_WIDTH = "1" *) 
  (* C_B_WIDTH = "4" *) 
  (* C_COMPARE_OPERATION = "8" *) 
  (* C_C_FRACTION_WIDTH = "0" *) 
  (* C_C_TDATA_WIDTH = "8" *) 
  (* C_C_TUSER_WIDTH = "1" *) 
  (* C_C_WIDTH = "4" *) 
  (* C_FIXED_DATA_UNSIGNED = "0" *) 
  (* C_HAS_ABSOLUTE = "0" *) 
  (* C_HAS_ACCUMULATOR_A = "0" *) 
  (* C_HAS_ACCUMULATOR_PRIMITIVE_A = "0" *) 
  (* C_HAS_ACCUMULATOR_PRIMITIVE_S = "0" *) 
  (* C_HAS_ACCUMULATOR_S = "0" *) 
  (* C_HAS_ACCUM_INPUT_OVERFLOW = "0" *) 
  (* C_HAS_ACCUM_OVERFLOW = "0" *) 
  (* C_HAS_ACLKEN = "0" *) 
  (* C_HAS_ADD = "0" *) 
  (* C_HAS_ARESETN = "1" *) 
  (* C_HAS_A_TLAST = "0" *) 
  (* C_HAS_A_TUSER = "0" *) 
  (* C_HAS_B = "0" *) 
  (* C_HAS_B_TLAST = "0" *) 
  (* C_HAS_B_TUSER = "0" *) 
  (* C_HAS_C = "0" *) 
  (* C_HAS_COMPARE = "0" *) 
  (* C_HAS_C_TLAST = "0" *) 
  (* C_HAS_C_TUSER = "0" *) 
  (* C_HAS_DIVIDE = "0" *) 
  (* C_HAS_DIVIDE_BY_ZERO = "0" *) 
  (* C_HAS_EXPONENTIAL = "0" *) 
  (* C_HAS_FIX_TO_FLT = "1" *) 
  (* C_HAS_FLT_TO_FIX = "0" *) 
  (* C_HAS_FLT_TO_FLT = "0" *) 
  (* C_HAS_FMA = "0" *) 
  (* C_HAS_FMS = "0" *) 
  (* C_HAS_INVALID_OP = "0" *) 
  (* C_HAS_LOGARITHM = "0" *) 
  (* C_HAS_MULTIPLY = "0" *) 
  (* C_HAS_OPERATION = "0" *) 
  (* C_HAS_OPERATION_TLAST = "0" *) 
  (* C_HAS_OPERATION_TUSER = "0" *) 
  (* C_HAS_OVERFLOW = "0" *) 
  (* C_HAS_RECIP = "0" *) 
  (* C_HAS_RECIP_SQRT = "0" *) 
  (* C_HAS_RESULT_TLAST = "0" *) 
  (* C_HAS_RESULT_TUSER = "0" *) 
  (* C_HAS_SQRT = "0" *) 
  (* C_HAS_SUBTRACT = "0" *) 
  (* C_HAS_UNDERFLOW = "0" *) 
  (* C_HAS_UNFUSED_MULTIPLY_ACCUMULATOR_A = "0" *) 
  (* C_HAS_UNFUSED_MULTIPLY_ACCUMULATOR_S = "0" *) 
  (* C_HAS_UNFUSED_MULTIPLY_ADD = "0" *) 
  (* C_HAS_UNFUSED_MULTIPLY_SUB = "0" *) 
  (* C_LATENCY = "5" *) 
  (* C_MULT_USAGE = "0" *) 
  (* C_OPERATION_TDATA_WIDTH = "8" *) 
  (* C_OPERATION_TUSER_WIDTH = "1" *) 
  (* C_OPTIMIZATION = "1" *) 
  (* C_RATE = "1" *) 
  (* C_RESULT_FRACTION_WIDTH = "24" *) 
  (* C_RESULT_TDATA_WIDTH = "32" *) 
  (* C_RESULT_TUSER_WIDTH = "1" *) 
  (* C_RESULT_WIDTH = "32" *) 
  (* C_THROTTLE_SCHEME = "3" *) 
  (* C_TLAST_RESOLUTION = "0" *) 
  (* C_XDEVICEFAMILY = "virtexuplus" *) 
  (* downgradeipidentifiedwarnings = "yes" *) 
  fixed4_upsampler_floating_point_v7_1_9_viv i_synth
       (.aclk(aclk),
        .aclken(1'b0),
        .aresetn(aresetn),
        .m_axis_result_tdata({\^m_axis_result_tdata [31:30],\^m_axis_result_tdata [27:26],NLW_i_synth_m_axis_result_tdata_UNCONNECTED[27:26],\^m_axis_result_tdata [25:0]}),
        .m_axis_result_tlast(NLW_i_synth_m_axis_result_tlast_UNCONNECTED),
        .m_axis_result_tready(1'b0),
        .m_axis_result_tuser(NLW_i_synth_m_axis_result_tuser_UNCONNECTED[0]),
        .m_axis_result_tvalid(m_axis_result_tvalid),
        .s_axis_a_tdata({1'b0,1'b0,1'b0,1'b0,s_axis_a_tdata[3:0]}),
        .s_axis_a_tlast(1'b0),
        .s_axis_a_tready(NLW_i_synth_s_axis_a_tready_UNCONNECTED),
        .s_axis_a_tuser(1'b0),
        .s_axis_a_tvalid(s_axis_a_tvalid),
        .s_axis_b_tdata({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axis_b_tlast(1'b0),
        .s_axis_b_tready(NLW_i_synth_s_axis_b_tready_UNCONNECTED),
        .s_axis_b_tuser(1'b0),
        .s_axis_b_tvalid(1'b0),
        .s_axis_c_tdata({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axis_c_tlast(1'b0),
        .s_axis_c_tready(NLW_i_synth_s_axis_c_tready_UNCONNECTED),
        .s_axis_c_tuser(1'b0),
        .s_axis_c_tvalid(1'b0),
        .s_axis_operation_tdata({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axis_operation_tlast(1'b0),
        .s_axis_operation_tready(NLW_i_synth_s_axis_operation_tready_UNCONNECTED),
        .s_axis_operation_tuser(1'b0),
        .s_axis_operation_tvalid(1'b0));
endmodule
`pragma protect begin_protected
`pragma protect version = 1
`pragma protect encrypt_agent = "XILINX"
`pragma protect encrypt_agent_info = "Xilinx Encryption Tool 2019.1"
`pragma protect key_keyowner="Cadence Design Systems.", key_keyname="cds_rsa_key", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=64)
`pragma protect key_block
AjZB+YVLd1bTTa3WQVDZlW8SmeBH1XsEnW+cd9vBo88QDxI5OnPvKDRv7dLl9m6fF2bToriQttjX
EVbwPEdtWA==

`pragma protect key_keyowner="Synopsys", key_keyname="SNPS-VCS-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
pZ6Sc104qCnNiKGoLJZ9crkD/EMrEX083KVoG1qkYhUTWB6FL12Zoz4AlAEtTS7wMZX3hnhQizz2
w/8JTalvLaVb3+84yFptB16n/caxZqC387B8OJ+rUqlU9i0FvXdj0oLV+zC1aUGz4NnNJGGECNJY
JOMJyoyszss2JGTfCUc=

`pragma protect key_keyowner="Aldec", key_keyname="ALDEC15_001", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
ZSlnSztvgpRUQP6Gk9jZgQM3X58QrkBrUva/G1n2j9vQqI7pY//DdMmu54WB7d7cmGU/yeFSPyy6
+ko9o6RaPvAOr4ofgFZ+++Q54YWrUY+IlR9TVY2OEra7l9B/oEgGxRqXrmoUTy86F9kBbiEtJFf2
B6Cw7YEWokaAi4ExPfZCvW/E4iKePPuYeanwibn06ZLgMHQ7PUXi9ENXFAmIPdPuT7BigBm60214
2eXMakfo3bhj5eF5EFs0skrKhq4fPqdda2PdiR95ZynbZtbuzHeEczc3EW6RtXaMxxMZin5IPARz
7p8ncWfmJjHWjVnUQ2U9ih9XRaaEhv41NvIj2w==

`pragma protect key_keyowner="ATRENTA", key_keyname="ATR-SG-2015-RSA-3", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
uU/BOVQ04gMjsTE2xf7l6wF035bngTUwhIFMcb7kOaZSIHqrd99S0J5ndJBUPvVbLPZEy1unGPtC
tBwkIrNCmonX4x/VE313gi1MbstvovReF4auAaCDnSKe8PONAzldyzXzaUnjv+07ETeqbrUCiHzK
3SA3sucV677rW14m/x4Jgvfm0F88nlBu9j3F+p6C7shd4emv/5pTa5+JUBIEkiCWQog+zLQNCnsr
jlPlOi0AiTYQkQUDNmo0vxcvMZ0CGnF/T1Gad8Orirs3MUr68jFUvS/U1z013SUUrnI9WruDQVBb
yie+gRf7eF+UTtjtqnvbK6r4zU+ed+0S2ocXtQ==

`pragma protect key_keyowner="Xilinx", key_keyname="xilinxt_2019_02", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
UxeuCiEbyQMyXkSYONtECmLrU4LpHM+flSFspv2dZPSz/LD2JGLLBufpYzLZhWjYqeEi+DvyNAC7
Ae5kyiNsR2+BTuYde55y/JsH1fOwHMLIInw3HVnW60KY40/RaH4xZ+v2T4sHNaSRgMAGvUVMslnX
63U8XzRJCvIkFIHTAfSh2mizW2xQDSWE7O9aWnb+wfHzNQsBxvBw+wlTUkVrUdz24dgrg+vYsNjt
IBHNCHWOcx1m5jgJmhCZRxBMSHSs+bJmL2ZaxN5I7aO0qhHCSzs0SGT6z94h4j7khKJSY7hNJuLo
BlZ/jDu+H25WUiUajpW+gqT5vYJT4C/vl6wRNg==

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VELOCE-RSA", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
VddFTyDGw+IoWQ+5Axqhm9zHBmBDlLzN/0wDa2XfUUGWSDcC6df3L1o/0jCIkMzXg9Zcnz7dAPid
E20SEOTmm1gZZ2LdOfWySQxBjuNuqlMBxQlFfwksr8s+YrmVkqacvmjPOzKipO6OxdJybRkGTV8D
JdWUyR12kGSnn1gd4Rc=

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VERIF-SIM-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
aln1xJ/D3cPv6b1D4QZIDmheM6mGLg5cjAj+/HaeWzVAOTyVwnyjHAYj6/hRnLk6vJ46tCy+opLu
U19OzlJMFQbichN++UIWLo+x+Is6UgYNBIYcRMp1RlCsvs6eGVaGgyM9YJFx6lLHHgF9qCQmVMxI
NZDhUcbb79cloWuhddwTLoZ+KpbXi0Rog9T/yqACDibfi/TAY/cVnGp2utcxHcksaoY3K6ZLqM5Y
PRlu5oKePXfePWZtKbrb+A71EXvpqyd6fyRf+RgdlcuVhzuRjF8C6caK+ZgWUpFYEapBIUcGmE7P
UjmuQ27qRmIxzwEZjVZ9DoM6JV8iulBuVRPlfw==

`pragma protect key_keyowner="Real Intent", key_keyname="RI-RSA-KEY-1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
G0blZXyfhFOdWvGQRAEvUBoxqUsL0Y6pvnmlrnRKHvq11cUaM7iPu6qQSKMOTbaDhj7txHqVG5hY
Y+L+ttkoxHIeV4Jvwad3DdSFeno1UwFdE2948ZGJFwx4+bZ+jOWE+e/xlaBfDdp0+rLBmSZ6iEbK
Du7mZ05rKyEE3/+sp06gy9rmGizmr75uZIx6s4det2dvZ5OEPAfkoY/zulTYCn0J7qrVhkjVc3FI
Jzax7p0D4AeSWElIH9I6C/pCJeugy6wVPB50r/Pm5HSPNCtqp4eXsTSU1a1C+9MX3pp1UH4Jlc2e
tP6Oc+j1sRDOv3WkhlnRqfFk5VL038voavcc9g==

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-PREC-RSA", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
f+u38fxiuqYQ46OPBzkEjtsTsElnh8YNUTpmV0/3Fqz8l4q0DQkm5aezWnvYF/Kd2d/6D/CsINJj
1dMOfkmGbidIHpNNghIp338x0vukljxLpcIhp1E3D15hZihrBPzDJ6wUahvvNJNmuOujpxisNerY
TgFIKpG9KF2hAmM8yzcfe1CFzkZvdEfa8PdnSjJ+LRZO62Te9VsdPNrJKz7EIQQwVjq9fTgOjRD0
LMTRY3BAx96jDgI5TCTCNbrlSeP6iqr/u6rV4NIZjPYKbwIV2VQRMAdtoYe3AbWe5AaY22llC3Vy
sFBJpq907isGmRc5jIzDuAPbjfxZHRJw3jSnOw==

`pragma protect key_keyowner="Synplicity", key_keyname="SYNP15_1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
je3pJObYDMIH6G2lg9/zv+4aAApTqtlBxGJ4Cme+JH8wlVYl+8xxv8WNTF9IrTTVWff/u0lvp9MR
94pisAqRIEPh/snUNFQXgosE9yxaniTxKv1m0lJdp+VoZqqbP59+pbnGQ/KQcPzoXdgYajPQFhiR
yZZbY7YrIKGYBpcZiaZ8mkuGSusLD7mBKCwk+OrB4AxawFjmqedIkD8cEqMY+FlrPP8vQ8YtkPES
lJrXHyIjBhdAK6EUUBD/o66tiad6KfimCjYq884ku0KGwAlpyOMmXu7oWSfyGi9sc4UXMWLvVB8+
i4MAXJw3Q4fR9Yg2LR/6UJhoRfBQhpCyqqccHw==

`pragma protect data_method = "AES128-CBC"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 51904)
`pragma protect data_block
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
`pragma protect end_protected
`ifndef GLBL
`define GLBL
`timescale  1 ps / 1 ps

module glbl ();

    parameter ROC_WIDTH = 100000;
    parameter TOC_WIDTH = 0;

//--------   STARTUP Globals --------------
    wire GSR;
    wire GTS;
    wire GWE;
    wire PRLD;
    tri1 p_up_tmp;
    tri (weak1, strong0) PLL_LOCKG = p_up_tmp;

    wire PROGB_GLBL;
    wire CCLKO_GLBL;
    wire FCSBO_GLBL;
    wire [3:0] DO_GLBL;
    wire [3:0] DI_GLBL;
   
    reg GSR_int;
    reg GTS_int;
    reg PRLD_int;

//--------   JTAG Globals --------------
    wire JTAG_TDO_GLBL;
    wire JTAG_TCK_GLBL;
    wire JTAG_TDI_GLBL;
    wire JTAG_TMS_GLBL;
    wire JTAG_TRST_GLBL;

    reg JTAG_CAPTURE_GLBL;
    reg JTAG_RESET_GLBL;
    reg JTAG_SHIFT_GLBL;
    reg JTAG_UPDATE_GLBL;
    reg JTAG_RUNTEST_GLBL;

    reg JTAG_SEL1_GLBL = 0;
    reg JTAG_SEL2_GLBL = 0 ;
    reg JTAG_SEL3_GLBL = 0;
    reg JTAG_SEL4_GLBL = 0;

    reg JTAG_USER_TDO1_GLBL = 1'bz;
    reg JTAG_USER_TDO2_GLBL = 1'bz;
    reg JTAG_USER_TDO3_GLBL = 1'bz;
    reg JTAG_USER_TDO4_GLBL = 1'bz;

    assign (strong1, weak0) GSR = GSR_int;
    assign (strong1, weak0) GTS = GTS_int;
    assign (weak1, weak0) PRLD = PRLD_int;

    initial begin
	GSR_int = 1'b1;
	PRLD_int = 1'b1;
	#(ROC_WIDTH)
	GSR_int = 1'b0;
	PRLD_int = 1'b0;
    end

    initial begin
	GTS_int = 1'b1;
	#(TOC_WIDTH)
	GTS_int = 1'b0;
    end

endmodule
`endif
