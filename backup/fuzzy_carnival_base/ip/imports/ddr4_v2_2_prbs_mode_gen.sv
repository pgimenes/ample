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
//  /   /         Filename           : ddr4_v2_2_8_prbs_mode_gen.sv
// /___/   /\     Date Last Modified : $Date: 2014/09/03 $
// \   \  /  \    Date Created       : Wed Jan 13 2016
//  \___\/\___\
//
//Device: UltraScale
//Design Name: AXI TG
//Purpose:
//   This module send out random high level instructions . It will randomly choose start_addr, length,size,burst type and send the instruction. In simulation few instructions are sent but in h/w more instructions can be run. It is started by asserting prbs_mode_start and is stopper by asserting prbs_mode_stop.
//Reference:
//Revision History:
//*****************************************************************************
`timescale 1ps/1ps 
module ddr4_v2_2_8_prbs_mode_gen #(
  parameter SIMULATION               = "TRUE",
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
  parameter TCQ                      = 100
)(
  input                                  clk,
  input                                  tg_rst,
  input                                  prbs_mode_start,
  input                                  prbs_mode_stop,
  input                                  opcode_gen_done,
  input [31:0]                           prbs_mode_seed,
  output reg                             opcode_gen_start,
  output [C_AXI_ADDR_WIDTH -1:0]         prbs_mode_instr_axi_addr,
  output [7:0]                           prbs_mode_instr_axi_length,
  output [2:0]                           prbs_mode_instr_axi_size,
  output [1:0]                           prbs_mode_instr_axi_burst,
  output [2:0]                           prbs_mode_instr_axi_strb_pattern,
  output reg                             prbs_mode_done,  
  output [31:0]                          dbg_instr_pointer
);
function integer clogb2 (input integer in);
  begin
    in = in - 1;
    for (clogb2=1; in>1; clogb2=clogb2+1)
      in = in >> 1;
  end
endfunction
localparam C_WSTRB_WIDTH_LOG2 = clogb2(C_AXI_DATA_WIDTH/8);

reg prbs_mode_running;

wire prbs_instr_counter_done;
generate 
  if(SIMULATION == "TRUE")begin : simulation_prbs_command_counter
    localparam [32:0] C_NUMBER_OF_PRBS_INSTR_TO_SEND = 33'd30;//reduced count from 50 to 30 to reduce simulation time 
    reg [32:0] prbs_instr_counter;
    assign prbs_instr_counter_done = prbs_instr_counter[32];
    always @(posedge clk) begin
      if(tg_rst)begin
        prbs_instr_counter <= #TCQ 33'd0;
       end
      else if(prbs_mode_start && !prbs_mode_running) begin
        prbs_instr_counter <= #TCQ C_NUMBER_OF_PRBS_INSTR_TO_SEND - 2;
      end  
      else if(prbs_mode_running && opcode_gen_done && !prbs_instr_counter_done) begin
        prbs_instr_counter <= #TCQ prbs_instr_counter -1;
      end  
      else begin
        prbs_instr_counter <= #TCQ prbs_instr_counter;
      end 
    end
  end
  else begin :hw_mode
    assign prbs_instr_counter_done = 1'b0;
  end  
endgenerate

reg [31:0] prbs_instr_count; //counts number of commands sent
always @(posedge clk) begin
  if(prbs_mode_start && !prbs_mode_running)begin
    prbs_instr_count <= #TCQ 0;
  end
  else if(opcode_gen_start)begin
    prbs_instr_count <= #TCQ prbs_instr_count + 1'b1;
  end  
end
assign dbg_instr_pointer = prbs_instr_count;

reg prbs_mode_stop_asserted;
always @(posedge clk) begin
  if(tg_rst)begin
    prbs_mode_stop_asserted <= #TCQ 1'b0;
  end  
  else if(prbs_mode_stop && ~prbs_mode_stop_asserted && ~prbs_mode_done) begin
    prbs_mode_stop_asserted <= #TCQ 1'b1;
  end
  else if(prbs_mode_stop_asserted && prbs_mode_done)begin
    prbs_mode_stop_asserted <= #TCQ 1'b0;
  end  
end

always @(posedge clk) begin
  if(tg_rst)begin
    prbs_mode_running <= #TCQ 0;
    opcode_gen_start <= #TCQ 0;
    prbs_mode_done <= #TCQ 0;
  end
  else if(prbs_mode_start && !prbs_mode_running) begin
    prbs_mode_running <= #TCQ 1;
    opcode_gen_start <= #TCQ 1;
    prbs_mode_done <= #TCQ 0;
  end
  else if(prbs_mode_running && opcode_gen_done && !prbs_mode_stop_asserted && !prbs_instr_counter_done) begin
    prbs_mode_running <= #TCQ 1;
    opcode_gen_start <= #TCQ 1;
    prbs_mode_done <= #TCQ 0;
  end
  else if(prbs_mode_running && opcode_gen_done && (prbs_mode_stop_asserted || prbs_instr_counter_done)) begin
    prbs_mode_running <= #TCQ 0;
    opcode_gen_start <= #TCQ 0;
    prbs_mode_done <= #TCQ 1;
  end
  else begin
    prbs_mode_running <= #TCQ prbs_mode_running;
    opcode_gen_start <= #TCQ 0;
    prbs_mode_done <= #TCQ 0;
  end  
end
//####################################################################################################################
//                                                                                                                   #
//                                                                                                                   #
// 64 taps: [64,63,61,60]: {{8'b01011000}, {56'b0}}                                                                  #
//  upper 32 bits are loadable                                                                                       #
//                                                                                                                   #
//
//
//     ........................................................................................
//         ^                  ^                      ^             ^                          |
//         |   ____           |  ___     ___         | ___         |  ___     ___     ___     |
//         |   |   |   |---|<-  |   |   |   | |---|<- |   |  |---|<- |   |...|   |   |   |    |  The first 32 bits are parallel loadable.
//         ----|64 |<--|xor|<-- |63 |-->|62 |-|xor|<--|61 |<-|xor|<--|60 |...|33 |<--|1|<<--
//             |___|    ---     |___|   |___|  ---    |___|   ---    |___|...|___|   |___|
//
//
//                                           <<-- shifting  --
//#####################################################################################################################

// use SRLC32E for lower 32 stages and 32 registers for upper 32 stages.
// we need to provide 30 bits addres. SRLC32 has only one bit output.
// address seed will be loaded to upper 32 bits.
//
//  parallel load and serial shift out to  LFSR  during INIT time
reg [64 :1]            lfsr_q;
reg [63 :0]            prbs;

always @ (posedge clk) begin
  if(prbs_mode_start && !prbs_mode_running) begin//reset it to a known good state to prevent it locks up
    lfsr_q <= #TCQ {32'b0,prbs_mode_seed};
  end else if(prbs_mode_running && opcode_gen_done && !prbs_mode_stop_asserted && !prbs_instr_counter_done) begin
    lfsr_q[64] <= #TCQ lfsr_q[64] ^ lfsr_q[63];
    lfsr_q[63] <= #TCQ lfsr_q[62];
    lfsr_q[62] <= #TCQ lfsr_q[64] ^ lfsr_q[61];
    lfsr_q[61] <= #TCQ lfsr_q[64] ^ lfsr_q[60];
    lfsr_q[60:2] <= #TCQ lfsr_q[59:1];
    lfsr_q[1] <= #TCQ lfsr_q[64];
  end
end

always @(lfsr_q[64:1]) begin
  prbs = lfsr_q[64:1];
end
//we will use the generated prbs data and determine addr/burst type/size etc from that. Since the prbs data is random, even the addr/size etc will be random for each cycle
//generation of aligned addr
reg [C_AXI_ADDR_WIDTH -1 :0] aligned_addr;
always @ (*)begin
  case(prbs_mode_instr_axi_size)
    3'b000: aligned_addr  = prbs;
    3'b001: aligned_addr  = {prbs[C_AXI_ADDR_WIDTH -1 : 1],1'd0};
    3'b010: aligned_addr  = {prbs[C_AXI_ADDR_WIDTH -1 : 2],2'd0};
    3'b011: aligned_addr  = {prbs[C_AXI_ADDR_WIDTH -1 : 3],3'd0};
    3'b100: aligned_addr  = {prbs[C_AXI_ADDR_WIDTH -1 : 4],4'd0};
    3'b101: aligned_addr  = {prbs[C_AXI_ADDR_WIDTH -1 : 5],5'd0};
    3'b110: aligned_addr  = {prbs[C_AXI_ADDR_WIDTH -1 : 6],6'd0};
    3'b111: aligned_addr  = {prbs[C_AXI_ADDR_WIDTH -1 : 7],7'd0};
   default: aligned_addr  = 'd0;
  endcase
end

assign prbs_mode_instr_axi_addr = (prbs_mode_instr_axi_burst == C_AXI_BURST_WRAP)? aligned_addr : prbs[C_AXI_ADDR_WIDTH -1:0];

reg [7:0] wrap_length;
always @(*)begin
  case (prbs[36:35])
    2'b00: wrap_length = 8'd1;
    2'b01: wrap_length = 8'd3;
    2'b10: wrap_length = 8'd7;
    2'b11: wrap_length = 8'd15;
  default: wrap_length = 8'd0;
  endcase
end
assign prbs_mode_instr_axi_length = (prbs_mode_instr_axi_burst == C_AXI_BURST_WRAP)? wrap_length :(SIMULATION == "TRUE")?{1'b0,prbs[41:35]}: prbs[42:35];  // reduced length to 128 for simulations

//this is an indirect way of generating a random size that is less than the log2(AXI_DATA_WIDTH/8). If the generated random value exceed log2(AXI_DATA_WIDTH/8), it is ceil to log2(AXI_DATA_WIDTH/8). min AXI_DATA_WIDTH is 32bits => min log2(AXI_DATA_WIDTH/8)=2 which requires 2bits to represent
generate 
if(SEND_NBURST == 1) begin : narrow_burst_support_enabled
  if(C_WSTRB_WIDTH_LOG2 < 'd4)begin //2bits can be selected from prbs pattern
    assign prbs_mode_instr_axi_size = (prbs[44:43] < C_WSTRB_WIDTH_LOG2)? {1'b0,prbs[44:43]} : C_WSTRB_WIDTH_LOG2;
  end
  else begin //3bits need to be selected from prbs pattern
    assign prbs_mode_instr_axi_size = (prbs[45:43] < C_WSTRB_WIDTH_LOG2)? prbs[45:43] : C_WSTRB_WIDTH_LOG2;
  end
end
else begin: narrow_burst_support_disabled
//If narrow_burst_enable option is not selected for MIG design, TG cannot send narrow transfers. Refer pg150 for more details 
  assign prbs_mode_instr_axi_size = C_WSTRB_WIDTH_LOG2;
end  
endgenerate

assign prbs_mode_instr_axi_burst = (prbs[47:46] == 2'b00)? C_AXI_BURST_WRAP : C_AXI_BURST_INCR;

assign prbs_mode_instr_axi_strb_pattern = (prbs[49:48] == 2'b00)? C_STRB_PATTERN_WALKING1 : C_STRB_PATTERN_DEFAULT ;

//synthesis translate off
always @ (posedge opcode_gen_start)begin
  $display("DEBUG:::PRBS_MODE::::at time =%t instruction =%0d axi_addr = %h length =%0d size =%0d burst =%0d strb_pattern =%0d)",$time,prbs_instr_count,prbs_mode_instr_axi_addr,prbs_mode_instr_axi_length,prbs_mode_instr_axi_size,prbs_mode_instr_axi_burst,prbs_mode_instr_axi_strb_pattern);
end
//synthesis translate on
endmodule

