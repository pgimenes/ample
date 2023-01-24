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
//  /   /         Filename           : ddr4_v2_2_8_boot_mode_gen.sv
// /___/   /\     Date Last Modified : $Date: 2014/09/03 $
// \   \  /  \    Date Created       : Wed Jan 13 2016
//  \___\/\___\
//
//Device: UltraScale
//Design Name: AXI TG
//Purpose:
//   This module contains the high level instructions recommended to at when the axi slave is started. It will send aligned addr+incr burst type with every length and size possible combination, aligned addr+wrap type with every possible length and size and also unaligned addresses. In simulation it is recommended to run only few lengths/sizes, but for h/w all possible combinations should be run to weed out any issues.
//Reference:
//Revision History:
//*****************************************************************************
`timescale 1ps/1ps 
module ddr4_v2_2_8_boot_mode_gen #(
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
  input                                  boot_mode_start,
  input                                  boot_mode_stop,
  input                                  opcode_gen_done,
  output                                 opcode_gen_start,
  output [C_AXI_ADDR_WIDTH -1:0]         boot_mode_instr_axi_addr,
  output [7:0]                           boot_mode_instr_axi_length,
  output [2:0]                           boot_mode_instr_axi_size,
  output [1:0]                           boot_mode_instr_axi_burst,
  output [2:0]                           boot_mode_instr_axi_strb_pattern,
  output reg                             boot_mode_done,
  output [31:0]                          dbg_instr_pointer
);
function bit[2:0] clogb2 (input integer in);
  begin
    in = in - 1;
    for (clogb2=1; in>1; clogb2=clogb2+1)
      in = in >> 1;
  end
endfunction

//////////////////////////////////////////////////////////////////////// BOOT INSTRUCTION SPACE /////////////////////////////////////////////////////////////////////////////////
localparam [2:0] C_AXI_BURST_SIZE_MAX = clogb2(C_AXI_DATA_WIDTH/8);
//If narrow_burst_enable option is not selected for MIG design, TG cannot send narrow transfers. Refer pg150 for more details 
localparam [2:0] C_AXI_BURST_SIZE_MIN = (SEND_NBURST == 1)? 3'd0: C_AXI_BURST_SIZE_MAX; 

//boot ram instruction memory
localparam C_INSTRUCTION_MEM_WIDTH = 'd1 + 'd40 + 'd3 + 'd2 + 'd2 + 'd8 + 'd8 + 'd3 + 'd3;
localparam C_INSTRUCTION_MEM_DEPTH = 'd6; // 2 ^ C_INSTRUCTION_MEM_DEPTH -1) //max value of C_INSTRUCTION_MEM_DEPTH ='d31

localparam C_LEN_INCR_BY_ONE = 2'b00;
localparam C_LEN_INCR_MUL_2  = 2'b01;

reg [C_INSTRUCTION_MEM_WIDTH -1 :0] instr_mem [(C_INSTRUCTION_MEM_DEPTH-1):0];
reg [C_INSTRUCTION_MEM_DEPTH -1 :0] instr_pointer;
                     //valid instr,start_addr, strb_pattern,             burst type,       len_incr_mode,     len start,len end,     size start          size end
assign instr_mem[0] = {1'b1, 40'h0           , C_STRB_PATTERN_DEFAULT ,  C_AXI_BURST_INCR, C_LEN_INCR_MUL_2 , 8'd0  , 8'd255, C_AXI_BURST_SIZE_MIN, C_AXI_BURST_SIZE_MAX };
assign instr_mem[1] = {1'b1, 40'h0           , C_STRB_PATTERN_DEFAULT ,  C_AXI_BURST_WRAP, C_LEN_INCR_MUL_2 , 8'd1  , 8'd15 , C_AXI_BURST_SIZE_MIN, C_AXI_BURST_SIZE_MAX };
assign instr_mem[2] = {1'b1, 40'h00_0000_00FF, C_STRB_PATTERN_DEFAULT ,  C_AXI_BURST_INCR, C_LEN_INCR_MUL_2 , 8'd1  , 8'd1  , C_AXI_BURST_SIZE_MIN, C_AXI_BURST_SIZE_MAX };
//assign instr_mem[4] = {1'b1, 40'h0           , C_STRB_PATTERN_WALKING1,  C_AXI_BURST_INCR, C_LEN_INCR_MUL_2 , 8'd0  , 8'd15 , C_AXI_BURST_SIZE_MIN, C_AXI_BURST_SIZE_MAX };
//assign instr_mem[5] = {1'b1, 40'h0           , C_STRB_PATTERN_WALKING1,  C_AXI_BURST_WRAP, C_LEN_INCR_MUL_2 , 8'd1  , 8'd15 , C_AXI_BURST_SIZE_MIN, C_AXI_BURST_SIZE_MAX };
assign instr_mem[3] = {C_INSTRUCTION_MEM_WIDTH{1'b0}};
assign instr_mem[4] = {C_INSTRUCTION_MEM_WIDTH{1'b0}};
assign instr_mem[5] = {C_INSTRUCTION_MEM_WIDTH{1'b0}};
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
reg boot_mode_stop_asserted;
always @(posedge clk) begin
  if(tg_rst)begin
    boot_mode_stop_asserted <= #TCQ 1'b0;
  end  
  else if(boot_mode_stop && ~boot_mode_stop_asserted && ~boot_mode_done) begin
    boot_mode_stop_asserted <= #TCQ 1'b1;
  end
  else if(boot_mode_stop_asserted && boot_mode_done)begin
    boot_mode_stop_asserted <= #TCQ 1'b0;
  end  
end
//boot ram state machine states
localparam TG_INSTR_START     = 4'b0000;
localparam TG_INSTR_LOAD      = 4'b0001;
localparam TG_INSTR_EXE       = 4'b0010;
localparam TG_INSTR_WAIT      = 4'b0011;
localparam TG_INSTR_DONE      = 4'b0100;

wire [C_INSTRUCTION_MEM_WIDTH -1 :0] tg_curr_instr;
wire tg_curr_instr_valid;
wire [C_AXI_ADDR_WIDTH -1:0] tg_curr_instr_start_addr;
wire [2:0] tg_curr_instr_strb_pattern;
wire [1:0] tg_curr_instr_axi_burst;
wire [1:0] tg_curr_instr_axi_len_incr_by;
wire [7:0] tg_curr_instr_axi_len_start;
wire [7:0] tg_curr_instr_axi_len_end;
wire [2:0] tg_curr_instr_axi_size_start;
wire [2:0] tg_curr_instr_axi_size_end;

reg [3:0]tg_instr_sm_ps;
wire arc_tg_instr_start_load;
wire arc_tg_instr_load_start;
wire arc_tg_instr_load_exe;
wire arc_tg_instr_exe_wait;
wire arc_tg_instr_wait_exe;
wire arc_tg_instr_wait_done;
wire arc_tg_instr_done_load;

reg tg_instr_start_s;
reg tg_instr_load_s;
reg tg_instr_exe_s;
reg tg_instr_wait_s;
reg tg_instr_done_s;

assign arc_tg_instr_start_load = boot_mode_start; 
//instruction pointer
always @ (posedge clk) begin
  if(tg_rst || tg_instr_start_s)begin
    instr_pointer <= #TCQ 'd0;
  end
  else if (tg_instr_done_s)begin
    instr_pointer <= #TCQ instr_pointer + 1'b1;
  end  
  else begin
    instr_pointer <= #TCQ instr_pointer;
  end
end

assign dbg_instr_pointer[31: C_INSTRUCTION_MEM_DEPTH] = 'd0;
assign dbg_instr_pointer[C_INSTRUCTION_MEM_DEPTH -1 :0] = instr_pointer;

assign tg_curr_instr = instr_mem[instr_pointer];
assign tg_curr_instr_valid = tg_curr_instr[69];
assign tg_curr_instr_start_addr = tg_curr_instr[C_AXI_ADDR_WIDTH -1 + 29 : 29];
assign tg_curr_instr_strb_pattern = tg_curr_instr[28:26];
assign tg_curr_instr_axi_burst = tg_curr_instr[25:24];
assign tg_curr_instr_axi_len_incr_by = tg_curr_instr[23:22];
assign tg_curr_instr_axi_len_start = tg_curr_instr[21:14];
assign tg_curr_instr_axi_len_end = tg_curr_instr[13:6];
assign tg_curr_instr_axi_size_start = tg_curr_instr[5:3];
assign tg_curr_instr_axi_size_end = tg_curr_instr[2:0];

assign arc_tg_instr_load_start = (tg_instr_load_s)? ((~tg_curr_instr_valid) || (boot_mode_stop_asserted)) : 1'b0;
assign arc_tg_instr_load_exe = (tg_instr_load_s)? tg_curr_instr_valid : 1'b0;

assign arc_tg_instr_exe_wait = 1'b1;

reg [7:0] axi_length_count;
reg [2:0] axi_size_count;
wire axi_size_count_done;
wire axi_length_count_done;
//length and size counters
//max size, all lengths; max_size-1, all lengths
always @ (posedge clk) begin
  if (tg_rst) begin
    axi_length_count <= #TCQ 8'd0;
  end
  else if (tg_instr_load_s || (tg_instr_wait_s && opcode_gen_done && axi_length_count_done))begin
    //sumitp axi_length_count <= #TCQ tg_curr_instr_axi_len_end;
    axi_length_count <= #TCQ (2**tg_curr_instr_axi_size_end * tg_curr_instr_axi_len_end > 2**12) ? (tg_curr_instr_axi_len_end >> (8-(12-tg_curr_instr_axi_size_end))) : tg_curr_instr_axi_len_end ; // 4KB address boundary check
  end  
  else if (tg_instr_wait_s && opcode_gen_done && !axi_length_count_done && ((tg_curr_instr_axi_burst == C_AXI_BURST_INCR) && (tg_curr_instr_axi_len_incr_by == C_LEN_INCR_BY_ONE))) begin
    axi_length_count <= #TCQ axi_length_count - 1'b1;
  end  
  else if (tg_instr_wait_s && opcode_gen_done && !axi_length_count_done && ((tg_curr_instr_axi_burst == C_AXI_BURST_WRAP) || (tg_curr_instr_axi_len_incr_by == C_LEN_INCR_MUL_2))) begin
    axi_length_count <= #TCQ {1'b0, axi_length_count[7:1]} ;
  end
  else begin
    axi_length_count <= #TCQ axi_length_count;
  end  
end
assign axi_length_count_done = (axi_length_count <= tg_curr_instr_axi_len_start)? 1'b1: 1'b0;
always @ (posedge clk) begin
  if (tg_rst) begin
    axi_size_count <= #TCQ 8'd0;
  end
//  else if (tg_instr_load_s || (tg_instr_wait_s && opcode_gen_done && axi_size_count_done))begin
  else if (tg_instr_load_s)begin
    axi_size_count <= #TCQ tg_curr_instr_axi_size_end;
  end  
//  else if (tg_instr_wait_s && opcode_gen_done && !axi_size_count_done) begin
  else if (tg_instr_wait_s && opcode_gen_done && axi_length_count_done && !axi_size_count_done) begin
    axi_size_count <= #TCQ axi_size_count - 1'b1;
  end  
end
assign axi_size_count_done = (axi_size_count == tg_curr_instr_axi_size_start)? 1'b1: 1'b0;

//axi size decoder
reg [7:0] size;
always @ (posedge clk)begin
 case(axi_size_count)
  3'b000: size <= #TCQ 8'd1; //1 byte
  3'b001: size <= #TCQ 8'd2;
  3'b010: size <= #TCQ 8'd4;
  3'b011: size <= #TCQ 8'd8;
  3'b100: size <= #TCQ 8'd16;
  3'b101: size <= #TCQ 8'd32;
  3'b110: size <= #TCQ 8'd64;
  3'b111: size <= #TCQ 8'd128;
 default: size <= #TCQ 8'd0;
 endcase
end
//ceil length decoder
//axi size decoder
reg [8:0] length;
always @ (posedge clk)begin
 casex(axi_length_count)
  8'b0000_000x: length <= #TCQ 9'd1; 
  8'b0000_001x: length <= #TCQ 9'd2; 
  8'b0000_01xx: length <= #TCQ 9'd3; 
  8'b0000_1xxx: length <= #TCQ 9'd4; 
  8'b0001_xxxx: length <= #TCQ 9'd5; 
  8'b001x_xxxx: length <= #TCQ 9'd6; 
  8'b01xx_xxxx: length <= #TCQ 9'd7; 
  8'b1xxx_xxxx: length <= #TCQ 9'd8; 
 default: length <= #TCQ 9'd0;
 endcase
end

//incrementing address
reg [C_AXI_ADDR_WIDTH -1:0] axi_addr;
always @ (posedge clk) begin
  if (tg_instr_load_s)begin
    axi_addr <= #TCQ tg_curr_instr_start_addr;
  end  
  else if (tg_instr_wait_s && opcode_gen_done) begin
    axi_addr <= #TCQ axi_addr + ( 1 << (length + axi_size_count));
  end  
end

assign arc_tg_instr_wait_exe = (tg_instr_wait_s)? (opcode_gen_done && !(axi_size_count_done && axi_length_count_done)) : 1'b0;

assign arc_tg_instr_wait_done = (tg_instr_wait_s)? ((opcode_gen_done && axi_size_count_done && axi_length_count_done) || (opcode_gen_done && boot_mode_stop_asserted)) : 1'b0;

assign arc_tg_instr_done_load = 1'b1;

always @ (posedge clk) begin
end
//boot ram state machine
always@(posedge clk) begin
  if (tg_rst) begin
    tg_instr_sm_ps <= #TCQ TG_INSTR_START;
    tg_instr_start_s <= #TCQ 1'b1;
    tg_instr_load_s <= #TCQ 1'b0;
    tg_instr_exe_s <= #TCQ 1'b0;
    tg_instr_wait_s <= #TCQ 1'b0;
    tg_instr_done_s <= #TCQ 1'b0;
    boot_mode_done <= #TCQ 1'b0;
  end
  else begin
	  casez (tg_instr_sm_ps)
      TG_INSTR_START: 
		    if (arc_tg_instr_start_load) begin
		      tg_instr_sm_ps <= #TCQ TG_INSTR_LOAD;
		      tg_instr_start_s <= #TCQ 1'b0;
		      tg_instr_load_s  <= #TCQ 1'b1;
          boot_mode_done <= #TCQ 1'b0;
		    end       
        else begin
          boot_mode_done <= #TCQ 1'b0;
        end  
      TG_INSTR_LOAD: 
		    if (arc_tg_instr_load_start) begin //last instr
		      tg_instr_sm_ps <= #TCQ TG_INSTR_START;
		      tg_instr_start_s  <= #TCQ 1'b1;
		      tg_instr_load_s <= #TCQ 1'b0;
          boot_mode_done <= #TCQ 1'b1;
		    end  
        else if(arc_tg_instr_load_exe) begin
		      tg_instr_sm_ps <= #TCQ TG_INSTR_EXE;
		      tg_instr_load_s <= #TCQ 1'b0;
		      tg_instr_exe_s  <= #TCQ 1'b1;
        end
      TG_INSTR_EXE: 
		    if (arc_tg_instr_exe_wait) begin
		      tg_instr_sm_ps <= #TCQ TG_INSTR_WAIT;
		      tg_instr_exe_s <= #TCQ 1'b0;
		      tg_instr_wait_s  <= #TCQ 1'b1;
		    end        
      TG_INSTR_WAIT: 
		    if (arc_tg_instr_wait_exe) begin
		      tg_instr_sm_ps <= #TCQ TG_INSTR_EXE;
		      tg_instr_wait_s <= #TCQ 1'b0;
		      tg_instr_exe_s  <= #TCQ 1'b1;
		    end   
        else if (arc_tg_instr_wait_done) begin
		      tg_instr_sm_ps <= #TCQ TG_INSTR_DONE;
		      tg_instr_wait_s <= #TCQ 1'b0;
		      tg_instr_done_s  <= #TCQ 1'b1;
        end  
      TG_INSTR_DONE: 
		    if (arc_tg_instr_done_load) begin
		      tg_instr_sm_ps <= #TCQ TG_INSTR_LOAD;
		      tg_instr_done_s <= #TCQ 1'b0;
		      tg_instr_load_s  <= #TCQ 1'b1;
		    end  
    endcase
  end
end  

//generation of aligned addr
reg [C_AXI_ADDR_WIDTH -1 :0] aligned_addr;
always @ (*)begin
  case(axi_size_count)
    3'b000: aligned_addr  = axi_addr;
    3'b001: aligned_addr  = {axi_addr[C_AXI_ADDR_WIDTH -1 : 1],1'd0};
    3'b010: aligned_addr  = {axi_addr[C_AXI_ADDR_WIDTH -1 : 2],2'd0};
    3'b011: aligned_addr  = {axi_addr[C_AXI_ADDR_WIDTH -1 : 3],3'd0};
    3'b100: aligned_addr  = {axi_addr[C_AXI_ADDR_WIDTH -1 : 4],4'd0};
    3'b101: aligned_addr  = {axi_addr[C_AXI_ADDR_WIDTH -1 : 5],5'd0};
    3'b110: aligned_addr  = {axi_addr[C_AXI_ADDR_WIDTH -1 : 6],6'd0};
    3'b111: aligned_addr  = {axi_addr[C_AXI_ADDR_WIDTH -1 : 7],7'd0};
  endcase
end
wire [C_AXI_ADDR_WIDTH -1 :0] axi_start_addr;
assign axi_start_addr = (tg_curr_instr_axi_burst == C_AXI_BURST_WRAP)? aligned_addr :axi_addr ;
assign opcode_gen_start = tg_instr_exe_s;
assign boot_mode_instr_axi_addr = axi_start_addr ;
assign boot_mode_instr_axi_length = axi_length_count ;
assign boot_mode_instr_axi_size = axi_size_count ;
assign boot_mode_instr_axi_burst = tg_curr_instr_axi_burst ;
assign boot_mode_instr_axi_strb_pattern = tg_curr_instr_strb_pattern;

//synthesis translate off
always @(instr_pointer) begin
  $display("DEBUG:::BOOT_MODE:::at time =%t executing instruction %0d",$time,instr_pointer);
end
always @ (posedge opcode_gen_start)begin
  $display("DEBUG:::BOOT_MODE::::at time =%t instruction =%h axi_size_count =%0d axi_length_count=%0d",$time,instr_pointer,axi_size_count,axi_length_count);
end
//synthesis translate on

endmodule

