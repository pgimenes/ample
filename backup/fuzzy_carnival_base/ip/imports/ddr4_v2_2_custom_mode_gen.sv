/******************************************************************************
// (c) Copyright 2016 Xilinx, Inc. All rights reserved.
//
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
//
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
//
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
//
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
******************************************************************************/
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor             : Xilinx
// \   \   \/     Version            : 1.0
//  \   \         Application        : MIG
//  /   /         Filename           : ddr4_v2_2_8_custom_mode_gen.sv
// /___/   /\     Date Last Modified : $Date: 2014/09/03 $
// \   \  /  \    Date Created       : Wed Jan 13 2016
//  \___\/\___\
//
//Device: UltraScale
//Design Name: AXI TG
//Purpose:
//   Customer can edit this module to enter customer-specific axi patterns.
//
//Reference:
//Revision History:
//*****************************************************************************
`timescale 1ps/1ps 
module ddr4_v2_2_8_custom_mode_gen #(
  parameter C_AXI_ID_WIDTH           = 10,
  parameter C_AXI_ADDR_WIDTH         = 32, 
  parameter C_AXI_DATA_WIDTH         = 32,
  parameter C_STRB_PATTERN_DEFAULT   = 3'd1,
  parameter C_STRB_PATTERN_WALKING1  = 3'd2,
  parameter C_STRB_PATTERN_WALKING0  = 3'd3,
  parameter C_AXI_BURST_FIXED        = 2'b00,
  parameter C_AXI_BURST_INCR         = 2'b01,
  parameter C_AXI_BURST_WRAP         = 2'b10,
  parameter SEND_NBURST              = 0,	
  parameter TCQ                      = 100  //the axi shim has TCQ=0
)(
  input                                  clk,
  input                                  tg_rst,
  input                                  custom_mode_start,
  input                                  custom_mode_stop,
  input                                  opcode_gen_done,
  output reg                             opcode_gen_start,
  output [C_AXI_ADDR_WIDTH -1:0]         custom_mode_instr_axi_addr,
  output [7:0]                           custom_mode_instr_axi_length,
  output [2:0]                           custom_mode_instr_axi_size,
  output [1:0]                           custom_mode_instr_axi_burst,
  output [2:0]                           custom_mode_instr_axi_strb_pattern,
  output reg                             custom_mode_done,
  output [31:0]                          dbg_instr_pointer
);
function bit[2:0] clogb2 (input integer in);
  begin
    in = in - 1;
    for (clogb2=1; in>1; clogb2=clogb2+1)
      in = in >> 1;
  end
endfunction
localparam [2:0] C_AXI_BURST_SIZE_MAX = clogb2(C_AXI_DATA_WIDTH/8);
//If narrow_burst_enable option is not selected for MIG design, TG cannot send narrow transfers. Refer pg150 for more details 
localparam [2:0] C_AXI_BURST_SIZE_MIN = (SEND_NBURST == 1)? 3'd0: C_AXI_BURST_SIZE_MAX; 
//////////////////////////////////////////////////////////////////////// CUSTOM INSTRUCTION SPACE /////////////////////////////////////////////////////////////////////////////////
localparam C_INSTRUCTION_MEM_WIDTH = 'd1 + 'd40 + 'd3 + 'd2 + 'd8 + 'd3 ;
localparam C_INSTRUCTION_MEM_DEPTH = 'd8; // 2 ^ C_INSTRUCTION_MEM_DEPTH -1)

reg [C_INSTRUCTION_MEM_WIDTH -1 :0] instr_mem [(C_INSTRUCTION_MEM_DEPTH-1) :0];
reg [C_INSTRUCTION_MEM_DEPTH -1 :0] instr_pointer;
reg [C_INSTRUCTION_MEM_DEPTH -1 :0] instr_pointer_r;
                     //valid instr,start_addr, strb_pattern,             burst type,       len,          size
assign instr_mem[0] = {1'b1, 40'h0           , C_STRB_PATTERN_DEFAULT ,  C_AXI_BURST_INCR, 8'd255, C_AXI_BURST_SIZE_MAX };
assign instr_mem[1] = {1'b1, 40'h54          , C_STRB_PATTERN_DEFAULT ,  C_AXI_BURST_INCR, 8'd255, C_AXI_BURST_SIZE_MAX };
assign instr_mem[2] = {1'b1, 40'h789700      , C_STRB_PATTERN_DEFAULT ,  C_AXI_BURST_WRAP, 8'd15 , C_AXI_BURST_SIZE_MAX };
assign instr_mem[3] = {1'b1, 40'h10892308    , C_STRB_PATTERN_WALKING1,  C_AXI_BURST_INCR, 8'd255, C_AXI_BURST_SIZE_MAX };
assign instr_mem[4] = {1'b1, 40'h871300      , C_STRB_PATTERN_WALKING1,  C_AXI_BURST_WRAP, 8'd15 , C_AXI_BURST_SIZE_MAX };
assign instr_mem[5] = {1'b1, 40'h56_7898_4536, C_STRB_PATTERN_DEFAULT ,  C_AXI_BURST_INCR, 8'd255, C_AXI_BURST_SIZE_MAX };
assign instr_mem[6] = {1'b1, 40'h47_3656_5400, C_STRB_PATTERN_DEFAULT ,  C_AXI_BURST_WRAP, 8'd15 , C_AXI_BURST_SIZE_MAX };
assign instr_mem[7] = {C_INSTRUCTION_MEM_WIDTH{1'b0}};
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
reg custom_mode_stop_asserted;
always @(posedge clk) begin
  if(tg_rst)begin
    custom_mode_stop_asserted <= #TCQ 1'b0;
  end  
  else if(custom_mode_stop && ~custom_mode_stop_asserted && ~custom_mode_done) begin
    custom_mode_stop_asserted <= #TCQ 1'b1;
  end
  else if(custom_mode_stop_asserted && custom_mode_done)begin
    custom_mode_stop_asserted <= #TCQ 1'b0;
  end  
end
reg custom_mode_running;
wire custom_mode_last_instr;
always @(posedge clk) begin
  if(tg_rst) begin
    custom_mode_running <= #TCQ 0;
    instr_pointer <= #TCQ 'd0;
    opcode_gen_start <= #TCQ 0;
    custom_mode_done <= #TCQ 0;
  end
  else if(custom_mode_start && !custom_mode_running) begin
    custom_mode_running <= #TCQ 1;
    instr_pointer <= #TCQ instr_pointer + 1'b1;
    opcode_gen_start <= #TCQ 1;
    custom_mode_done <= #TCQ 0;
  end
  else if(custom_mode_running && opcode_gen_done && !custom_mode_stop_asserted && !custom_mode_last_instr) begin
    custom_mode_running <= #TCQ 1;
    instr_pointer <= #TCQ instr_pointer + 1'b1;
    opcode_gen_start <= #TCQ 1;
    custom_mode_done <= #TCQ 0;
  end
  else if(custom_mode_running && opcode_gen_done && (custom_mode_stop_asserted || custom_mode_last_instr)) begin
    custom_mode_running <= #TCQ 0;
    instr_pointer <= #TCQ 'd0;
    opcode_gen_start <= #TCQ 0;
    custom_mode_done <= #TCQ 1;
  end
  else begin
    custom_mode_running <= #TCQ custom_mode_running;
    instr_pointer <= #TCQ instr_pointer;
    opcode_gen_start <= #TCQ 0;
    custom_mode_done <= #TCQ 0;
  end  
end

assign dbg_instr_pointer[31: C_INSTRUCTION_MEM_DEPTH] = 'd0;
assign dbg_instr_pointer[C_INSTRUCTION_MEM_DEPTH -1 :0] = instr_pointer;

wire [C_INSTRUCTION_MEM_WIDTH -1 :0] tg_curr_instr;

always @(posedge clk) instr_pointer_r <= #TCQ instr_pointer;

assign tg_curr_instr = instr_mem[instr_pointer_r];
assign custom_mode_last_instr = ~ tg_curr_instr[56];
assign custom_mode_instr_axi_addr = tg_curr_instr[C_AXI_ADDR_WIDTH -1 + 16 : 16];
assign custom_mode_instr_axi_strb_pattern = tg_curr_instr[15:13];
assign custom_mode_instr_axi_burst = tg_curr_instr[12:11];
assign custom_mode_instr_axi_length = tg_curr_instr[10:3];
assign custom_mode_instr_axi_size = (tg_curr_instr[2:0] <= C_AXI_BURST_SIZE_MAX)? tg_curr_instr[2:0] : C_AXI_BURST_SIZE_MAX; //taking max value if customer puts more than max size supporetd

//synthesis translate off
always @(instr_pointer) begin
  $display("DEBUG:::CUSTOM_MODE:::at time =%t executing instruction %0d",$time,instr_pointer);
end
//synthesis translate on

endmodule

