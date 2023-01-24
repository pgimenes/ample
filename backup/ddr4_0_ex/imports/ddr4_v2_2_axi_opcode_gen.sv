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
//  /   /         Filename           : ddr4_v2_2_8_axi_opcode_gen.sv
// /___/   /\     Date Last Modified : $Date: 2014/09/03 $
// \   \  /  \    Date Created       : Wed Jan 13 2016
//  \___\/\___\
//
//Device: UltraScale
//Design Name: AXI TG
//Purpose:
//   This block converts the higher level instructions from the boot/prbs/custom modules to axi level opcodes(which are later handled by axi_wrapper)
//   higher level instructions are converted to write and read opcodes
//Reference:
//Revision History:
//*****************************************************************************
`timescale 1ps/1ps 
module ddr4_v2_2_8_axi_opcode_gen #(
  parameter C_AXI_ID_WIDTH           = 10,
  parameter C_AXI_ADDR_WIDTH         = 32, 
  parameter C_AXI_DATA_WIDTH         = 32,
  parameter C_DATA_PATTERN_PRBS      = 3'd1,
  parameter C_DATA_PATTERN_WALKING0  = 3'd2,
  parameter C_DATA_PATTERN_WALKING1  = 3'd3,
  parameter C_DATA_PATTERN_ALL_F     = 3'd4,
  parameter C_DATA_PATTERN_ALL_0     = 3'd5,
  parameter C_DATA_PATTERN_A5A5      = 3'd6,
  parameter C_STRB_PATTERN_DEFAULT   = 3'd1,
  parameter C_STRB_PATTERN_WALKING1  = 3'd2,
  parameter C_STRB_PATTERN_WALKING0  = 3'd3, 
  parameter APP_DATA_WIDTH	     = 32, 
  parameter C_AXI_NBURST_SUPPORT     = 0,	
  parameter SEND_NBURST              = 0,
  parameter TCQ                      = 100,
  parameter C_AXI_BURST_WRAP         = 2'b10,
  parameter DBG_READ_REPEAT_CNT = 100, // HW Data Error Debug
  parameter ECC			     = "OFF"	 
)(
  input                                  clk,
  input                                  tg_rst,
  input                                  opcode_gen_start,
  output                                 opcode_gen_done,
  input [C_AXI_ADDR_WIDTH -1:0]          instr_axi_addr,
  input [7:0]                            instr_axi_length,
  input [2:0]                            instr_axi_size,
  input [1:0]                            instr_axi_burst,
  input [2:0]                            instr_axi_strb_pattern,
  input                                  reset_id,
// AXI write address channel signals
  input                                  axi_awready, // Indicates slave is ready to accept a 
  output reg [C_AXI_ID_WIDTH-1:0]        axi_awid,    // Write ID
  output reg [C_AXI_ADDR_WIDTH-1:0]      axi_awaddr,  // Write address
  output reg [7:0]                       axi_awlen,   // Write Burst Length
  output reg [2:0]                       axi_awsize,  // Write Burst size
  output reg [1:0]                       axi_awburst, // Write Burst type
  output reg                             axi_awlock,  // Write lock type
  output reg [3:0]                       axi_awcache, // Write Cache type
  output reg [2:0]                       axi_awprot,  // Write Protection type
  output reg                             axi_awvalid, // Write address valid
// AXI write data channel signals
  input                                  axi_wready,  // Write data ready
  output [C_AXI_DATA_WIDTH-1:0]          axi_wdata,    // Write data
  output [C_AXI_DATA_WIDTH/8-1:0]        axi_wstrb,    // Write strobes
  output                                 axi_wlast,    // Last write transaction   
  output                                 axi_wvalid,   // Write valid  
// AXI write response channel signals
  input  [C_AXI_ID_WIDTH-1:0]            axi_bid,     // Response ID
  input  [1:0]                           axi_bresp,   // Write response
  input                                  axi_bvalid,  // Write reponse valid
  output reg                             axi_bready,  // Response ready
// AXI read address channel signals
  input                                  axi_arready,     // Read address ready
  output reg [C_AXI_ID_WIDTH-1:0]        axi_arid,        // Read ID
  output reg [C_AXI_ADDR_WIDTH-1:0]      axi_araddr,      // Read address
  output reg [7:0]                       axi_arlen,       // Read Burst Length
  output reg [2:0]                       axi_arsize,      // Read Burst size
  output reg [1:0]                       axi_arburst,     // Read Burst type
  output reg                             axi_arlock,      // Read lock type
  output reg [3:0]                       axi_arcache,     // Read Cache type
  output reg [2:0]                       axi_arprot,      // Read Protection type
  output reg                             axi_arvalid,     // Read address valid 
// AXI read data channel signals   
  input  [C_AXI_ID_WIDTH-1:0]            axi_rid,     // Response ID
  input  [1:0]                           axi_rresp,   // Read response
  input                                  axi_rvalid,  // Read reponse valid
  input  [C_AXI_DATA_WIDTH-1:0]          axi_rdata,    // Read data
  input                                  axi_rlast,    // Read last
  output reg                             axi_rready,  // Read Response ready
  //error signals
  output                                 vio_axi_tg_mismatch_error,
  output [C_AXI_DATA_WIDTH-1:0]          vio_axi_tg_expected_bits,
  output [C_AXI_DATA_WIDTH-1:0]          vio_axi_tg_actual_bits,
  output [C_AXI_DATA_WIDTH-1:0]          vio_axi_tg_error_bits,
  output [8:0]                           vio_axi_tg_data_beat_count,
  output [C_AXI_ID_WIDTH-1:0]            vio_axi_tg_error_status_id,
  output [C_AXI_ADDR_WIDTH-1:0]          vio_axi_tg_error_status_addr,
  output [7:0]                           vio_axi_tg_error_status_len,
  output [2:0]                           vio_axi_tg_error_status_size,
  output [1:0]                           vio_axi_tg_error_status_burst,
  output                                 vio_axi_tg_write_resp_error,
  output                                 vio_axi_tg_read_resp_error,
  output                                 vio_axi_tg_data_err_status_rdy,
  output [1:0]                           vio_axi_tg_data_err_status // HW Data Error Debug
);


//axi wrapper signals
reg                         cmd_en_wr;
reg [C_AXI_ADDR_WIDTH -1:0] awaddr;
reg [7:0]                   awlen;
reg [2:0]                   awsize;
reg [1:0]                   awburst;
reg [2:0]                   wdata_pattern;
reg [2:0]                   wstrb_pattern;
wire                        write_done;
reg                         cmd_en_rd;
reg [C_AXI_ADDR_WIDTH -1:0] araddr;
reg [7:0]                   arlen;
reg [2:0]                   arsize;
reg [1:0]                   arburst;
reg [2:0]                   rdata_pattern;
reg [2:0]                   rstrb_pattern;
reg                         compare_wr_rd;
reg                         compare_bg;
wire                        read_done;
reg                         data_chk_done;
reg                         data_chk_done_r;

always @(posedge clk)begin
  if(tg_rst) begin
    data_chk_done_r   <= #TCQ 0;
  end
  else begin
    data_chk_done_r   <= #TCQ data_chk_done;
  end
end

reg tg_opcode_gen_idle_s;
reg tg_opcode_gen_load_s ;
reg tg_opcode_gen_write_simple_s ;
reg tg_opcode_gen_write_a5a5_aligned_addr_s ;
reg tg_opcode_gen_read_simple_s ;
reg tg_opcode_gen_read_bg_s ;
reg tg_opcode_gen_done_s ;

//registering the input addr/cmds when in LOAD state for timing
reg [C_AXI_ADDR_WIDTH -1:0]          instr_axi_addr_r;
reg [7:0]                            instr_axi_length_r;
reg [2:0]                            instr_axi_size_r;
reg [1:0]                            instr_axi_burst_r;
reg [2:0]                            instr_axi_strb_pattern_r;
always @(posedge clk) begin
  if(tg_opcode_gen_idle_s && opcode_gen_start)begin
    instr_axi_addr_r <= #TCQ instr_axi_addr;
    instr_axi_length_r <= #TCQ instr_axi_length;
    instr_axi_size_r <= #TCQ instr_axi_size;
    instr_axi_burst_r <= #TCQ instr_axi_burst;
    instr_axi_strb_pattern_r <= #TCQ (instr_axi_burst == C_AXI_BURST_WRAP)? C_STRB_PATTERN_DEFAULT : instr_axi_strb_pattern; // for WRAP Burst back ground data is not proper due to instr_axi_strb_pattern and fixed to C_STRB_PATTERN_DEFAULT which is working fine
  end 
end

//generation of aligned addr
reg [C_AXI_ADDR_WIDTH -1 :0] aligned_addr;
always @ (*)begin
  case(instr_axi_size_r)
    3'b000: aligned_addr  = instr_axi_addr_r;
    3'b001: aligned_addr  = {instr_axi_addr_r[C_AXI_ADDR_WIDTH -1 : 1],1'd0};
    3'b010: aligned_addr  = {instr_axi_addr_r[C_AXI_ADDR_WIDTH -1 : 2],2'd0};
    3'b011: aligned_addr  = {instr_axi_addr_r[C_AXI_ADDR_WIDTH -1 : 3],3'd0};
    3'b100: aligned_addr  = {instr_axi_addr_r[C_AXI_ADDR_WIDTH -1 : 4],4'd0};
    3'b101: aligned_addr  = {instr_axi_addr_r[C_AXI_ADDR_WIDTH -1 : 5],5'd0};
    3'b110: aligned_addr  = {instr_axi_addr_r[C_AXI_ADDR_WIDTH -1 : 6],6'd0};
    3'b111: aligned_addr  = {instr_axi_addr_r[C_AXI_ADDR_WIDTH -1 : 7],7'd0};
   default: aligned_addr  = 'd0;
   endcase
end 

reg [C_AXI_ADDR_WIDTH -1 :0] ecc_aligned_addr; //64B aligned addr; ecc designs are always 64B. 
always @ (*)begin
	ecc_aligned_addr = {instr_axi_addr_r[C_AXI_ADDR_WIDTH -1 : 6],6'd0} ; 
end	
  	

reg [6:0] start_addr_lower_bits;
always @ (*)begin
  case(instr_axi_size_r)
    3'b000: start_addr_lower_bits  = 7'd0;
    3'b001: start_addr_lower_bits  = {6'd0,instr_axi_addr_r[0]};
    3'b010: start_addr_lower_bits  = {5'd0,instr_axi_addr_r[1:0]};
    3'b011: start_addr_lower_bits  = {4'd0,instr_axi_addr_r[2:0]};
    3'b100: start_addr_lower_bits  = {3'd0,instr_axi_addr_r[3:0]};
    3'b101: start_addr_lower_bits  = {2'd0,instr_axi_addr_r[4:0]};
    3'b110: start_addr_lower_bits  = {1'd0,instr_axi_addr_r[5:0]};
    3'b111: start_addr_lower_bits  =  instr_axi_addr_r[6:0];
   default: start_addr_lower_bits  =  7'd0;
  endcase
end 

reg [6:0] ecc_start_addr_lower_bits;
always @ (*)begin
	ecc_start_addr_lower_bits  = {1'd0,instr_axi_addr_r[5:0]};
end

reg partial_len; 
always @(*) begin
   case(instr_axi_size_r)
      3'b000: partial_len  = (instr_axi_length_r[5:0] == 6'b111111)? 1'b0: 1'b1;
      3'b001: partial_len  = (instr_axi_length_r[4:0] == 5'b11111 )? 1'b0: 1'b1; 
      3'b010: partial_len  = (instr_axi_length_r[3:0] == 4'b1111  )? 1'b0: 1'b1;
      3'b011: partial_len  = (instr_axi_length_r[2:0] == 3'b111   )? 1'b0: 1'b1;
      3'b100: partial_len  = (instr_axi_length_r[1:0] == 2'b11    )? 1'b0: 1'b1;
      3'b101: partial_len  = (instr_axi_length_r[0]   == 1'b1     )? 1'b0: 1'b1;
      3'b110: partial_len  =  1'b0;
      3'b111: partial_len  =  1'b0;
      default: partial_len = 1'b0;
   endcase
end

reg [7:0] full_axi_length; //the ecc_aligned_addr is aligned to 64B. Select len such that the axi txn
// will write to locations n*64B . Adding the additional 64B to length to ensure that the 
// ecc_aligned_addr, full_axi_length will definitely both lower 64B aligned addr (of the origival axi_addr)
// as well as the last aligned 64B
always @(*) begin
   case(instr_axi_size_r)
      3'b000: full_axi_length  = {instr_axi_length[7:6],6'b111111} + 8'b0100_0000;
      3'b001: full_axi_length  = {instr_axi_length[7:5],5'b11111}  + 8'b0010_0000; 
      3'b010: full_axi_length  = {instr_axi_length[7:4],4'b1111}   + 8'b0001_0000;
      3'b011: full_axi_length  = {instr_axi_length[7:3],3'b111}    + 8'b0000_1000;
      3'b100: full_axi_length  = {instr_axi_length[7:2],2'b11}     + 8'b0000_0100;
      3'b101: full_axi_length  = {instr_axi_length[7:1],1'b1}      + 8'b0000_0010;
      3'b110: full_axi_length  = instr_axi_length                  + 8'b0000_0001;
      3'b111: full_axi_length  = instr_axi_length;
      default: full_axi_length = instr_axi_length;
   endcase
end

function bit[2:0] clogb2 (input integer in);
  begin
    in = in - 1;
    for (clogb2=1; in>1; clogb2=clogb2+1)
      in = in >> 1;
  end
endfunction
localparam [2:0] C_AXI_BURST_SIZE_MAX = clogb2(C_AXI_DATA_WIDTH/8);
wire [2:0]  ecc_axi_size;
//assign ecc_axi_size = C_AXI_BURST_SIZE_MAX;
assign ecc_axi_size = instr_axi_size_r;

//reg [7:0] ecc_axi_length_1;
//always @(*) begin
//   case(ecc_axi_size)
//      3'b000: ecc_axi_length_1  = instr_axi_length[7:6] + 1;
//      3'b001: ecc_axi_length_1  = instr_axi_length[7:5] + 1; 
//      3'b010: ecc_axi_length_1  = instr_axi_length[7:4] + 1;
//      3'b011: ecc_axi_length_1  = instr_axi_length[7:3] + 1;
//      3'b100: ecc_axi_length_1  = instr_axi_length[7:2] + 1;
//      3'b101: ecc_axi_length_1  = instr_axi_length[7:1] + 1;
//      3'b110: ecc_axi_length_1  = instr_axi_length + 1;
//      3'b111: ecc_axi_length_1  = instr_axi_length;
//      default: ecc_axi_length_1 = instr_axi_length;
//   endcase
//end
//
//reg [7:0] ecc_axi_length;
//always @(*) begin
//   case(ecc_axi_size)
//      3'b000: ecc_axi_length  = {ecc_axi_length_1, 6'b111111};
//      3'b001: ecc_axi_length  = {ecc_axi_length_1, 5'b11111}; 
//      3'b010: ecc_axi_length  = {ecc_axi_length_1, 4'b1111};
//      3'b011: ecc_axi_length  = {ecc_axi_length_1, 3'b111};
//      3'b100: ecc_axi_length  = {ecc_axi_length_1, 2'b11};
//      3'b101: ecc_axi_length  = {ecc_axi_length_1, 1'b1};
//      3'b110: ecc_axi_length  = ecc_axi_length_1;
//      3'b111: ecc_axi_length  = ecc_axi_length_1;
//      default: ecc_axi_length = ecc_axi_length_1;
//   endcase
//end


reg [7:0] ecc_axi_length;
always @(*) begin
   case(ecc_axi_size)
      3'b000: ecc_axi_length  = {instr_axi_length[7:6], 6'b0} + 7'b1111111;
      3'b001: ecc_axi_length  = {instr_axi_length[7:5], 5'b0} + 6'b111111; 
      3'b010: ecc_axi_length  = {instr_axi_length[7:4], 4'b0} + 5'b11111;
      3'b011: ecc_axi_length  = {instr_axi_length[7:3], 3'b0} + 4'b1111;
      3'b100: ecc_axi_length  = {instr_axi_length[7:2], 2'b0} + 3'b111;
      3'b101: ecc_axi_length  = {instr_axi_length[7:1], 1'b0} + 2'b11;
      3'b110: ecc_axi_length  = instr_axi_length + 1'b1;
      3'b111: ecc_axi_length  = instr_axi_length;
      default: ecc_axi_length = instr_axi_length;
   endcase
end

wire [1:0] ecc_axi_burst;
assign ecc_axi_burst = 2'b01; //INCR type

wire instr_axi_addr_is_aligned = (ecc_start_addr_lower_bits == 7'd0)? 1'b1: 1'b0; 
wire ecc_prevent_bg_write  = ((SEND_NBURST== 1) ? 1'b1: ((((APP_DATA_WIDTH > C_AXI_DATA_WIDTH) && partial_len) == 1)? 1'b1 : 1'b0)) && (ECC == "ON");

//state machine states
reg [3:0] tg_opcode_gen_sm_ps;
localparam TG_OPCODE_GEN_IDLE = 4'd0;
localparam TG_OPCODE_GEN_LOAD = 4'd1;
localparam TG_OPCODE_GEN_WRITE_SIMPLE = 4'd2;
localparam TG_OPCODE_GEN_WRITE_A5A5 = 4'd3;
localparam TG_OPCODE_GEN_WRITE_A5A5_ALIGNED_ADDR = 4'd4;
localparam TG_OPCODE_GEN_READ_SIMPLE = 4'd5;
localparam TG_OPCODE_GEN_READ_BG = 4'd6;
localparam TG_OPCODE_GEN_DONE = 4'd7;

wire arc_tg_opcode_gen_idle_to_load;
wire arc_tg_opcode_gen_load_to_write_simple;
wire arc_tg_opcode_gen_load_to_write_a5a5_aligned_addr;
wire arc_tg_opcode_gen_write_simple_to_read_simple;
wire arc_tg_opcode_gen_write_simple_to_read_bg;
wire arc_tg_opcode_gen_write_a5a5_aligned_addr_to_write_simple;
wire arc_tg_opcode_gen_read_simple_to_done;
wire arc_tg_opcode_gen_read_bg_to_done;
wire arc_tg_opcode_gen_done_to_idle;
//the following states are to be traversed if
//1. we want to do simple write followed by read; this is done for aligned addr and default wsrtb
// IDLE ->LOAD ->WRITE_SIMPLE ->READ_SIMPLE ->DONE 
//2. we will write background pattern A5A5 to aligned addr, then prbs write to unaligned addr followed by read_bg. This is used for unaligned addr and/or walking strb
// IDLE ->LOAD ->WRITE_A5A5_ALIGNED_ADDR ->WRITE_SIMPLE ->READ_BG ->DONE 

assign arc_tg_opcode_gen_idle_to_load = (tg_opcode_gen_idle_s && opcode_gen_start)? 1'b1 :1'b0;
assign arc_tg_opcode_gen_load_to_write_simple = (tg_opcode_gen_load_s && (instr_axi_strb_pattern == C_STRB_PATTERN_DEFAULT) && instr_axi_addr_is_aligned && !ecc_prevent_bg_write)?1'b1 : 1'b0;
assign arc_tg_opcode_gen_load_to_write_a5a5_aligned_addr =  (tg_opcode_gen_load_s && ((instr_axi_strb_pattern != C_STRB_PATTERN_DEFAULT) || (!instr_axi_addr_is_aligned)||(ecc_prevent_bg_write)))? 1'b1 : 1'b0;
assign arc_tg_opcode_gen_write_simple_to_read_simple = (tg_opcode_gen_write_simple_s && write_done && (instr_axi_strb_pattern == C_STRB_PATTERN_DEFAULT) && instr_axi_addr_is_aligned)? 1'b1 :1'b0;
assign arc_tg_opcode_gen_write_simple_to_read_bg = (tg_opcode_gen_write_simple_s && write_done && ((instr_axi_strb_pattern != C_STRB_PATTERN_DEFAULT) || !instr_axi_addr_is_aligned))? 1'b1 :1'b0;
assign arc_tg_opcode_gen_write_a5a5_aligned_addr_to_write_simple = (tg_opcode_gen_write_a5a5_aligned_addr_s && write_done)? 1'b1:1'b0 ;
assign arc_tg_opcode_gen_read_simple_to_done = (tg_opcode_gen_read_simple_s && /*read_done*/data_chk_done_r)? 1'b1:1'b0;
assign arc_tg_opcode_gen_read_bg_to_done = (tg_opcode_gen_read_bg_s && /*read_done*/data_chk_done_r)? 1'b1:1'b0;
assign arc_tg_opcode_gen_done_to_idle = 1'b1;

(*mark_debug = "TRUE"*) reg read_continuous; // HW Data Error Debug

(*mark_debug = "TRUE"*) reg [C_AXI_DATA_WIDTH-1:0]          vio_axi_tg_actual_bits_mask;

//opcode generation state machine
always@(posedge clk) begin
  if (tg_rst) begin
    tg_opcode_gen_sm_ps <= #TCQ TG_OPCODE_GEN_IDLE;
    tg_opcode_gen_idle_s <= #TCQ 1'b1;
    tg_opcode_gen_load_s <= #TCQ 1'b0;
    tg_opcode_gen_write_simple_s <= #TCQ 1'b0;
    tg_opcode_gen_write_a5a5_aligned_addr_s <= #TCQ 1'b0;
    tg_opcode_gen_read_simple_s <= #TCQ 1'b0;
    tg_opcode_gen_read_bg_s <= #TCQ 1'b0;
    tg_opcode_gen_done_s <= #TCQ 1'b0;
  end
  else begin
	  casez (tg_opcode_gen_sm_ps)
      TG_OPCODE_GEN_IDLE: 
		    if (arc_tg_opcode_gen_idle_to_load) begin
		      tg_opcode_gen_sm_ps <= #TCQ TG_OPCODE_GEN_LOAD;
		      tg_opcode_gen_idle_s <= #TCQ 1'b0;
		      tg_opcode_gen_load_s  <= #TCQ 1'b1;
		    end        
      TG_OPCODE_GEN_LOAD: 
		    if (arc_tg_opcode_gen_load_to_write_simple) begin
		      tg_opcode_gen_sm_ps <= #TCQ TG_OPCODE_GEN_WRITE_SIMPLE;
		      tg_opcode_gen_load_s <= #TCQ 1'b0;
		      tg_opcode_gen_write_simple_s  <= #TCQ 1'b1;
		    end           
		    else if (arc_tg_opcode_gen_load_to_write_a5a5_aligned_addr) begin
		      tg_opcode_gen_sm_ps <= #TCQ TG_OPCODE_GEN_WRITE_A5A5_ALIGNED_ADDR;
		      tg_opcode_gen_load_s <= #TCQ 1'b0;
		      tg_opcode_gen_write_a5a5_aligned_addr_s  <= #TCQ 1'b1;
		    end
    TG_OPCODE_GEN_WRITE_SIMPLE: 
		    if (arc_tg_opcode_gen_write_simple_to_read_simple) begin
		      tg_opcode_gen_sm_ps <= #TCQ TG_OPCODE_GEN_READ_SIMPLE;
		      tg_opcode_gen_write_simple_s <= #TCQ 1'b0;
		      tg_opcode_gen_read_simple_s  <= #TCQ 1'b1;
		    end       
		    else if (arc_tg_opcode_gen_write_simple_to_read_bg) begin
		      tg_opcode_gen_sm_ps <= #TCQ TG_OPCODE_GEN_READ_BG;
		      tg_opcode_gen_write_simple_s <= #TCQ 1'b0;
		      tg_opcode_gen_read_bg_s  <= #TCQ 1'b1;
		    end       
     TG_OPCODE_GEN_WRITE_A5A5_ALIGNED_ADDR: 
		    if (arc_tg_opcode_gen_write_a5a5_aligned_addr_to_write_simple) begin
		      tg_opcode_gen_sm_ps <= #TCQ TG_OPCODE_GEN_WRITE_SIMPLE;
		      tg_opcode_gen_write_a5a5_aligned_addr_s <= #TCQ 1'b0;
		      tg_opcode_gen_write_simple_s  <= #TCQ 1'b1;
		    end
    TG_OPCODE_GEN_READ_SIMPLE: 
          if (arc_tg_opcode_gen_read_simple_to_done && !read_continuous) begin // HW Data Error Debug
		      tg_opcode_gen_sm_ps <= #TCQ TG_OPCODE_GEN_DONE;
		      tg_opcode_gen_read_simple_s <= #TCQ 1'b0;
		      tg_opcode_gen_done_s <= #TCQ 1'b1;
		    end
    TG_OPCODE_GEN_READ_BG: 
          if (arc_tg_opcode_gen_read_bg_to_done && !read_continuous) begin // HW Data Error Debug
		      tg_opcode_gen_sm_ps <= #TCQ TG_OPCODE_GEN_DONE;
		      tg_opcode_gen_read_bg_s <= #TCQ 1'b0;
		      tg_opcode_gen_done_s <= #TCQ 1'b1;
		    end
     TG_OPCODE_GEN_DONE: 
		    if (arc_tg_opcode_gen_done_to_idle) begin
		      tg_opcode_gen_sm_ps <= #TCQ TG_OPCODE_GEN_IDLE;
		      tg_opcode_gen_done_s <= #TCQ 1'b0;
		      tg_opcode_gen_idle_s  <= #TCQ 1'b1;
		    end       
    endcase
  end
end  

assign opcode_gen_done = tg_opcode_gen_done_s;

always @ (*)begin
  if (tg_rst) begin
    cmd_en_wr = 1'b0;
    awaddr = 'd0;
    awlen = 'd0;
    awsize = 'd0;
    awburst = 'd0;
    wdata_pattern = 'd0;
    wstrb_pattern = 'd0;    
  end
  else if (tg_opcode_gen_write_simple_s) begin
    cmd_en_wr = 1'b1;
    awaddr = instr_axi_addr_r;
    awlen = instr_axi_length_r;
    awsize = instr_axi_size_r;
    awburst = instr_axi_burst_r;
    wdata_pattern = C_DATA_PATTERN_PRBS;
    wstrb_pattern = instr_axi_strb_pattern_r;    
  end  
  else if (tg_opcode_gen_write_a5a5_aligned_addr_s) begin
    cmd_en_wr = 1'b1;
    awaddr = (ecc_prevent_bg_write == 1) ? ecc_aligned_addr: aligned_addr; 
    awlen =  (ecc_prevent_bg_write == 1) ? ecc_axi_length : instr_axi_length_r; 
    awsize = (ecc_prevent_bg_write == 1) ? ecc_axi_size : instr_axi_size_r;
    awburst = (ecc_prevent_bg_write == 1) ? ecc_axi_burst : instr_axi_burst_r;
    wdata_pattern = C_DATA_PATTERN_A5A5;
    wstrb_pattern = C_STRB_PATTERN_DEFAULT;    
  end  
  else begin
    cmd_en_wr = 1'b0;  
    awaddr = 'd0;
    awlen = 'd0;
    awsize = 'd0;
    awburst = 'd0;
    wdata_pattern = 'd0;
    wstrb_pattern = 'd0;    
  end  
end

always @ (*)begin
  if (tg_rst) begin
    cmd_en_rd = 1'b0;
    araddr = 'd0;
    arlen = 'd0;
    arsize = 'd0;
    arburst = 'd0;
    rdata_pattern = 'd0;
    rstrb_pattern = 'd0;   
    compare_wr_rd = 1'b0;
    compare_bg = 1'b0;
  end
  else if (tg_opcode_gen_read_simple_s) begin
    cmd_en_rd = 1'b1;
    araddr = instr_axi_addr_r;
    arlen = instr_axi_length_r;
    arsize = instr_axi_size_r;
    arburst = instr_axi_burst_r;
    rdata_pattern = C_DATA_PATTERN_PRBS;
    rstrb_pattern = instr_axi_strb_pattern_r;    
    compare_wr_rd = 1'b1;
    compare_bg = 1'b0;
  end  
  else if (tg_opcode_gen_read_bg_s) begin
    cmd_en_rd = 1'b1;
    araddr = instr_axi_addr_r;
    arlen = instr_axi_length_r;
    arsize = instr_axi_size_r;
    arburst = instr_axi_burst_r;
    rdata_pattern = C_DATA_PATTERN_PRBS;
    rstrb_pattern = instr_axi_strb_pattern_r;    
    compare_wr_rd = 1'b1;
    compare_bg = 1'b1;
  end  
  else begin
    cmd_en_rd = 1'b0;
    araddr = 'd0;
    arlen = 'd0;
    arsize = 'd0;
    arburst = 'd0;
    rdata_pattern = 'd0;
    rstrb_pattern = 'd0;   
    compare_wr_rd = 1'b0;
    compare_bg = 1'b0;
  end  
end

(*mark_debug = "TRUE"*) reg [C_AXI_ADDR_WIDTH-1:0] rpt_rd_araddr; // HW Data Error Debug

ddr4_v2_2_8_axi_wrapper #(
  .C_AXI_ID_WIDTH(C_AXI_ID_WIDTH),
  .C_AXI_ADDR_WIDTH(C_AXI_ADDR_WIDTH),
  .C_AXI_DATA_WIDTH(C_AXI_DATA_WIDTH),
  .C_DATA_PATTERN_PRBS(C_DATA_PATTERN_PRBS),
  .C_DATA_PATTERN_WALKING0(C_DATA_PATTERN_WALKING0),
  .C_DATA_PATTERN_WALKING1(C_DATA_PATTERN_WALKING1),
  .C_DATA_PATTERN_ALL_F(C_DATA_PATTERN_ALL_F),
  .C_DATA_PATTERN_ALL_0(C_DATA_PATTERN_ALL_0),
  .C_DATA_PATTERN_A5A5(C_DATA_PATTERN_A5A5),
  .C_STRB_PATTERN_DEFAULT(C_STRB_PATTERN_DEFAULT),
  .C_STRB_PATTERN_WALKING1(C_STRB_PATTERN_WALKING1),
  .C_STRB_PATTERN_WALKING0(C_STRB_PATTERN_WALKING0),
  .TCQ(TCQ)
) u_axi_wrapper (
  .clk             ( clk),
  .tg_rst          ( tg_rst),
  .cmd_en_wr       ( cmd_en_wr),
  .awaddr          ( awaddr),
  .awlen           ( awlen),
  .awsize          ( awsize),
  .awburst         ( awburst),
  .wdata_pattern   ( wdata_pattern),
  .wstrb_pattern   ( wstrb_pattern),
  .write_done      ( write_done),
  .cmd_en_rd       ( cmd_en_rd),
  .araddr          ( araddr),
  .arlen           ( arlen),
  .arsize          ( arsize),
  .arburst         ( arburst),
  .rdata_pattern   ( rdata_pattern),
  .rstrb_pattern   ( rstrb_pattern),
  .compare_wr_rd   ( compare_wr_rd),
  .compare_bg      ( compare_bg),
  .read_done       ( read_done),
  .reset_id        ( reset_id),
  .data_chk_done    (data_chk_done),
  .rpt_rd_araddr     (rpt_rd_araddr),
  .axi_awready     ( axi_awready),
  .axi_awid        ( axi_awid),
  .axi_awaddr      ( axi_awaddr),
  .axi_awlen       ( axi_awlen),
  .axi_awsize      ( axi_awsize),
  .axi_awburst     ( axi_awburst),
  .axi_awlock      ( axi_awlock),
  .axi_awcache     ( axi_awcache),
  .axi_awprot      ( axi_awprot),
  .axi_awvalid     ( axi_awvalid),
  .axi_wready      ( axi_wready),
  .axi_wdata       ( axi_wdata),
  .axi_wstrb       ( axi_wstrb),
  .axi_wlast       ( axi_wlast),
  .axi_wvalid      ( axi_wvalid),
  .axi_bid         ( axi_bid),
  .axi_bresp       ( axi_bresp),
  .axi_bvalid      ( axi_bvalid),
  .axi_bready      ( axi_bready),
  .axi_arready     ( axi_arready),
  .axi_arid        ( axi_arid),
  .axi_araddr      ( axi_araddr),
  .axi_arlen       ( axi_arlen),
  .axi_arsize      ( axi_arsize),
  .axi_arburst     ( axi_arburst),
  .axi_arlock      ( axi_arlock),
  .axi_arcache     ( axi_arcache),
  .axi_arprot      ( axi_arprot),
  .axi_arvalid     ( axi_arvalid),
  .axi_rid         ( axi_rid),
  .axi_rresp       ( axi_rresp),
  .axi_rvalid      ( axi_rvalid),
  .axi_rdata       ( axi_rdata),
  .axi_rlast       ( axi_rlast),
  .axi_rready      ( axi_rready),
  .read_continuous (read_continuous), // HW Data Error Debug
  .vio_axi_tg_mismatch_error(vio_axi_tg_mismatch_error),
  .vio_axi_tg_expected_bits(vio_axi_tg_expected_bits),
  .vio_axi_tg_actual_bits(vio_axi_tg_actual_bits),
  .vio_axi_tg_actual_bits_mask(vio_axi_tg_actual_bits_mask),
  .vio_axi_tg_error_bits(vio_axi_tg_error_bits),
  .vio_axi_tg_data_beat_count(vio_axi_tg_data_beat_count),
  .vio_axi_tg_error_status_id(vio_axi_tg_error_status_id),
  .vio_axi_tg_error_status_addr(vio_axi_tg_error_status_addr),
  .vio_axi_tg_error_status_len(vio_axi_tg_error_status_len),
  .vio_axi_tg_error_status_size(vio_axi_tg_error_status_size),
  .vio_axi_tg_error_status_burst(vio_axi_tg_error_status_burst),
  .vio_axi_tg_write_resp_error(vio_axi_tg_write_resp_error),
  .vio_axi_tg_read_resp_error(vio_axi_tg_read_resp_error)
);


// HW Data Error Debug block
// {{
/////////////////////////////////////////////////////////////////////////////////////////
// we have added data error type finder debug logic on AXI TG. It does below task,
// 
// When the data error seen on the slave read data, the debug logic will store the
// mismatched read beat data value and initiate the interrupt via read_contiuous
// siganl(asserted to 1) to TG to stop sending further original writes/reads. 
// 
// Now the debug logic will do continuous read requests to the data mismatched
// location to find out the data error type. 
// 
// i.e. lets say if the 3rd beat of read data is got matched on original read request, 
// then the debug logic will send out read request to the 3rd read data beat start_addr location 
// with same axi_size of original txn and axi_len=0 and axi_burst=INCR(irrespective of original req burst) 
// "DBG_READ_REPEAT_CNT" no of times. Each time the read data comes from the slave, the dbg logic compares it with
// the 'stored original corrupted read data'. 
// 
// If there is no mismatch between the dbg logic received rd data vs stored rd data, means, all the time we are
// reading out the same original mismatched read data consistently and hence concluded this
// data error scenorio as WRITE_PATH_ERROR. 
// 
// Else if there is a mismatch between the dbg logic received rd data vs stored
// rd data, means, read data from same location is not consistent and hence concluded this
// data error scenorio as READ_PATH_ERROR. 
// 
// The debug logic will assert the vio_axi_tg_data_err_status_rdy to 1.
// when it has determined the type of data error and will update in 
// vio_axi_tg_data_err_status signal, // 2'b00 - No_Error, 2'b01 - Write_Path_Error, 2'b10 - Read_Path_Error
// 
// Once the debug logic is determined the data error type, it will initiate the interrupt via read_contiuous
// siganl(asserted to 0) to TG to resume sending further original writes/reads, if any.
(*mark_debug = "TRUE"*) reg stop_read_continuous;
(*mark_debug = "TRUE"*) reg [31 : 0] read_continuous_cnt;
always @(posedge clk)begin
  if(tg_rst)begin
    read_continuous <= #TCQ 0;
  end
  else if(vio_axi_tg_mismatch_error && !stop_read_continuous) begin
    read_continuous <= #TCQ 1;
  end
  else if(stop_read_continuous) begin
    read_continuous <= #TCQ 0;
  end
end

always @(posedge clk)begin
  if(tg_rst)begin
    stop_read_continuous  <= #TCQ 0;
  end
  else if(read_continuous_cnt == DBG_READ_REPEAT_CNT) begin
    stop_read_continuous  <= #TCQ 1;
  end
end

(*mark_debug = "TRUE"*) reg read_continuous_start;
always @(posedge clk)begin
  if(tg_rst)begin
    read_continuous_cnt   <= #TCQ 0;
    read_continuous_start <= #TCQ 'b0;
  end
  else if(read_continuous && axi_arvalid && axi_arready) begin // first continuous read
    read_continuous_cnt   <= #TCQ read_continuous_cnt + 1'b1;
    read_continuous_start <= #TCQ 'b1;
  end
end

(*mark_debug = "TRUE"*) reg read_continuous_win;
(*mark_debug = "TRUE"*) reg read_continuous_big_win;
(*mark_debug = "TRUE"*) reg dbg_status_rdy;
(*mark_debug = "TRUE"*) reg [31:0]  read_cont_data_chk_cnt;
(*mark_debug = "TRUE"*) reg [31 : 0] read_data_err_cnt;
(*mark_debug = "TRUE"*) reg  read_data_err_seen;
always @ (posedge clk) begin
  if(tg_rst)begin
    read_continuous_win     <= #TCQ 'b0;
    read_continuous_big_win <= #TCQ 'b0;
    dbg_status_rdy          <= #TCQ 'b0;
  end
  else if (read_continuous && axi_arvalid && axi_arready)begin // first continuous read
    read_continuous_win     <= #TCQ 'b1;
    read_continuous_big_win <= #TCQ 'b1;
  end
  else if(stop_read_continuous && axi_rvalid && axi_rready && axi_rlast) begin
    read_continuous_win     <= #TCQ 'b0;
  end
  else if(read_continuous_start && !read_continuous_win && read_cont_data_chk_cnt == DBG_READ_REPEAT_CNT/*axi_arvalid && axi_arready*/) begin
    read_continuous_big_win <= #TCQ 'b0;
    dbg_status_rdy          <= #TCQ 'b1;
  end
end

(*mark_debug = "TRUE"*) reg read_continuous_win_r;
(*mark_debug = "TRUE"*) reg read_continuous_big_win_r;
always @(posedge clk)begin
  if(tg_rst)begin
    read_continuous_win_r   <= #TCQ 0;
    read_continuous_big_win_r   <= #TCQ 0;
  end
  else begin
    read_continuous_win_r   <= #TCQ read_continuous_win;
    read_continuous_big_win_r   <= #TCQ read_continuous_big_win;
  end
end

`ifdef EN_RDATA_COMPRESS
(*mark_debug = "TRUE"*) reg reset_exp_str_rdata;
(*mark_debug = "TRUE"*) reg [C_AXI_DATA_WIDTH-1:0] exp_str_rdata;
(*mark_debug = "TRUE"*) reg [C_AXI_DATA_WIDTH-1:0] exp_rdata_reduction;
(*mark_debug = "TRUE"*) reg [C_AXI_DATA_WIDTH-1:0] exp_rdata_reduction_temp;
(*mark_debug = "TRUE"*) reg [C_AXI_DATA_WIDTH-1:0] exp_adder;
always @ (posedge clk) begin
  if(tg_rst)begin
    reset_exp_str_rdata         <= #TCQ 1'b0;
    exp_adder                   <= #TCQ 'b0;
    exp_rdata_reduction         <= #TCQ 'b0;
    exp_rdata_reduction_temp    <= #TCQ 'b0;
  end
  else if (!read_continuous_start && axi_rvalid && axi_rready)begin
    exp_adder                   <= #TCQ exp_adder + 1'b1;
    exp_rdata_reduction_temp    <= #TCQ exp_rdata_reduction_temp  ^ (axi_rdata + exp_adder);
    reset_exp_str_rdata         <= #TCQ axi_rlast ? 1 : 0;
  end
  else if(reset_exp_str_rdata) begin
    reset_exp_str_rdata         <= #TCQ 1'b0;
    exp_adder                   <= #TCQ 'b0;
    exp_rdata_reduction         <= #TCQ exp_rdata_reduction_temp;
    exp_rdata_reduction_temp    <= #TCQ 'b0;
  end
end


(*mark_debug = "TRUE"*) reg reset_act_str_rdata;
(*mark_debug = "TRUE"*) reg [C_AXI_DATA_WIDTH-1:0] act_str_rdata;
(*mark_debug = "TRUE"*) reg [C_AXI_DATA_WIDTH-1:0] act_rdata_reduction;
(*mark_debug = "TRUE"*) reg [C_AXI_DATA_WIDTH-1:0] act_adder; // unique number to add with the rdata beat
(*mark_debug = "TRUE"*) reg rdata_reduction_mismatched;
always @ (posedge clk) begin
  if(tg_rst)begin
    reset_act_str_rdata         <= #TCQ 1'b0;
    act_rdata_reduction         <= #TCQ 'b0;
    act_adder                   <= #TCQ 'b0;
    rdata_reduction_mismatched  <= #TCQ 'b0;
    read_cont_data_chk_cnt      <= #TCQ 'b0;
    read_data_err_cnt           <= #TCQ 0;
  end
  else if (read_continuous_win_r && axi_rvalid && axi_rready)begin
    act_adder                   <= #TCQ act_adder + 1'b1;
    act_rdata_reduction         <= #TCQ act_rdata_reduction ^ (axi_rdata + act_adder);
    reset_act_str_rdata         <= #TCQ axi_rlast ? 1 : 0;
  end
  else if(read_continuous_win_r && reset_act_str_rdata && (act_rdata_reduction != exp_rdata_reduction))begin
    rdata_reduction_mismatched  <= #TCQ 1'b1;
    act_adder                   <= #TCQ 'b0;
    act_rdata_reduction         <= #TCQ 'b0;
    reset_act_str_rdata         <= #TCQ 'b0;
    read_data_err_cnt           <= #TCQ read_data_err_cnt + 1'b1;
    read_cont_data_chk_cnt      <= #TCQ read_cont_data_chk_cnt + 1'b1;
  end
  else if(reset_act_str_rdata)begin
    read_cont_data_chk_cnt      <= #TCQ read_cont_data_chk_cnt + 1'b1;
    act_adder                   <= #TCQ 'b0;
    act_rdata_reduction         <= #TCQ 'b0;
    reset_act_str_rdata         <= #TCQ 'b0;
  end
end

`else

(*mark_debug = "TRUE"*) reg [C_AXI_DATA_WIDTH-1:0] exp_str_rdata;
(*mark_debug = "TRUE"*) reg [C_AXI_DATA_WIDTH-1:0] exp_str_rdata_mask;
(*mark_debug = "TRUE"*) reg [8:0] str_rd_beat_cnt;
(*mark_debug = "TRUE"*) reg [8:0] str_rd_beat_cnt_temp;
(*mark_debug = "TRUE"*) reg [1:0] str_rd_burst;
(*mark_debug = "TRUE"*) reg [2:0] str_rd_size;
(*mark_debug = "TRUE"*) reg [7:0] str_rd_len;
(*mark_debug = "TRUE"*) reg [8:0] str_rd_len_temp;
(*mark_debug = "TRUE"*) reg [15:0] str_rd_txn_size;
(*mark_debug = "TRUE"*) reg [15:0] str_rd_txn_size_temp;
(*mark_debug = "TRUE"*) reg [15:0] str_rd_txn_size_temp2;
(*mark_debug = "TRUE"*) reg [15:0] str_rd_full_txn_size;
(*mark_debug = "TRUE"*) reg [3:0] str_rd_full_txn_size_w;
(*mark_debug = "TRUE"*) reg [C_AXI_ADDR_WIDTH-1:0] str_rd_addr;
(*mark_debug = "TRUE"*) reg [C_AXI_ADDR_WIDTH-1:0] str_rd_addr_wrap_low;
(*mark_debug = "TRUE"*) reg [C_AXI_ADDR_WIDTH-1:0] str_rd_addr_wrap_high;
(*mark_debug = "TRUE"*) reg [C_AXI_ADDR_WIDTH-1:0] str_rd_addr_wrap_err;
(*mark_debug = "TRUE"*) reg stored;
(*mark_debug = "TRUE"*) reg stored_r;
(*mark_debug = "TRUE"*) reg stored_2r;
always @ (posedge clk) begin
  if(tg_rst)begin
    exp_str_rdata           <= #TCQ 'b0;
    exp_str_rdata_mask      <= #TCQ 'b0;
    stored                  <= #TCQ 1'b0;
    str_rd_beat_cnt         <= #TCQ 9'b0;
    str_rd_beat_cnt_temp         <= #TCQ 9'b0;
    str_rd_addr             <= #TCQ 'b0;
    str_rd_burst            <= #TCQ 2'b0;
    str_rd_size             <= #TCQ 3'b0;
    str_rd_len              <= #TCQ 8'b0;
    str_rd_len_temp         <= #TCQ 8'b0;
    str_rd_txn_size         <= #TCQ 16'b0;
    str_rd_full_txn_size    <= #TCQ 16'b0;
    str_rd_full_txn_size_w  <= #TCQ 4'b0;
  end
  else if(vio_axi_tg_mismatch_error && !stored)begin
    exp_str_rdata           <= #TCQ vio_axi_tg_actual_bits;
    exp_str_rdata_mask      <= #TCQ vio_axi_tg_actual_bits_mask;
    str_rd_beat_cnt         <= #TCQ vio_axi_tg_data_beat_count;
    str_rd_addr             <= #TCQ vio_axi_tg_error_status_addr;
    str_rd_burst            <= #TCQ vio_axi_tg_error_status_burst;
    str_rd_size             <= #TCQ vio_axi_tg_error_status_size;
    str_rd_len              <= #TCQ vio_axi_tg_error_status_len;
    //str_rd_txn_size         <= #TCQ ((vio_axi_tg_data_beat_count - 1) * (2**vio_axi_tg_error_status_size));
    //str_rd_full_txn_size    <= #TCQ ((vio_axi_tg_error_status_len+1) * (2**vio_axi_tg_error_status_size));
    //str_rd_full_txn_size_w  <= #TCQ fn_clogb2_ext(((vio_axi_tg_error_status_len+1) * (2**vio_axi_tg_error_status_size)));
    stored                  <= #TCQ 1'b1;
  end
  else if(stored && !stored_r)begin // pipeline for timing fix
    str_rd_beat_cnt_temp     <= #TCQ str_rd_beat_cnt - 1;
    str_rd_len_temp          <= #TCQ str_rd_len + 1;
  end
  else if(stored_r && !stored_2r)begin // pipeline for timing fix
    str_rd_txn_size         <= #TCQ str_rd_beat_cnt_temp << str_rd_size;
    str_rd_full_txn_size    <= #TCQ str_rd_len_temp << str_rd_size;
    str_rd_full_txn_size_w  <= #TCQ fn_clogb2_ext(str_rd_len_temp << str_rd_size);
  end
end

always@(posedge clk)begin
  if(tg_rst) begin
    stored_r    <= #TCQ 0;
    stored_2r   <= #TCQ 0;
  end
  else begin
    stored_r    <= #TCQ stored;
    stored_2r   <= #TCQ stored_r;
  end
end

(*mark_debug = "TRUE"*) reg addr_calc_done;
(*mark_debug = "TRUE"*) reg addr_calc_done_r;
always @ (posedge clk) begin
  if(tg_rst)begin
    addr_calc_done_r  <= #TCQ 0;
  end
  else begin
    addr_calc_done_r  <= #TCQ addr_calc_done;
  end
end

always @ (posedge clk) begin
  if(tg_rst)begin
    rpt_rd_araddr           <= #TCQ 'b0;
    addr_calc_done          <= #TCQ 'b0;
    str_rd_addr_wrap_low    <= #TCQ 'b0;
    str_rd_addr_wrap_high   <= #TCQ 'b0;
    str_rd_addr_wrap_err    <= #TCQ 'b0;
  end
  else if (stored_2r && str_rd_burst == 1  && !addr_calc_done)begin
    rpt_rd_araddr   <=  #TCQ str_rd_beat_cnt != 1 ? (fn_aligned_addr(str_rd_addr, {1'b0,str_rd_size}) + str_rd_txn_size) : str_rd_addr;
    addr_calc_done  <= #TCQ 1;
  end
  else if (stored_2r && str_rd_burst == 2 && !addr_calc_done)begin
    str_rd_addr_wrap_low    <= #TCQ fn_aligned_addr(str_rd_addr, str_rd_full_txn_size_w);
    str_rd_addr_wrap_high   <= #TCQ fn_aligned_addr(str_rd_addr, str_rd_full_txn_size_w) + str_rd_full_txn_size;
    str_rd_addr_wrap_err    <= #TCQ str_rd_addr + str_rd_txn_size; // assumed wrap addr is aligned
    addr_calc_done          <= #TCQ 1;
  end
  else if (stored_2r && str_rd_burst == 2 && !addr_calc_done_r)begin
    rpt_rd_araddr   <= #TCQ (str_rd_addr_wrap_err >= str_rd_addr_wrap_high) ? (str_rd_addr_wrap_low + (str_rd_addr_wrap_err - str_rd_addr_wrap_high)) : str_rd_addr_wrap_err;
  end
end

function bit[3:0] fn_clogb2_ext (input bit[11:0] value);
  case(value)
    12'd2     :   fn_clogb2_ext   = 4'd1;
    12'd4     :   fn_clogb2_ext   = 4'd2;
    12'd8     :   fn_clogb2_ext   = 4'd3;
    12'd16    :   fn_clogb2_ext   = 4'd4;
    12'd32    :   fn_clogb2_ext   = 4'd5;
    12'd64    :   fn_clogb2_ext   = 4'd6;
    12'd128   :   fn_clogb2_ext   = 4'd7;
    12'd256   :   fn_clogb2_ext   = 4'd8;
    12'd512   :   fn_clogb2_ext   = 4'd9;
    12'd1024  :   fn_clogb2_ext   = 4'd10;
    default   :   fn_clogb2_ext   = 4'd0; 
  endcase
endfunction

function bit[C_AXI_ADDR_WIDTH-1:0] fn_aligned_addr (input bit [C_AXI_ADDR_WIDTH-1:0] addr, bit [3:0] size);
  case(size)
    4'b0000 : fn_aligned_addr = addr;
    4'b0001 : fn_aligned_addr = {addr[C_AXI_ADDR_WIDTH -1 : 1],1'd0};
    4'b0010 : fn_aligned_addr = {addr[C_AXI_ADDR_WIDTH -1 : 2],2'd0};
    4'b0011 : fn_aligned_addr = {addr[C_AXI_ADDR_WIDTH -1 : 3],3'd0};
    4'b0100 : fn_aligned_addr = {addr[C_AXI_ADDR_WIDTH -1 : 4],4'd0};
    4'b0101 : fn_aligned_addr = {addr[C_AXI_ADDR_WIDTH -1 : 5],5'd0};
    4'b0110 : fn_aligned_addr = {addr[C_AXI_ADDR_WIDTH -1 : 6],6'd0};
    4'b0111 : fn_aligned_addr = {addr[C_AXI_ADDR_WIDTH -1 : 7],7'd0};
    4'b1000 : fn_aligned_addr = {addr[C_AXI_ADDR_WIDTH -1 : 8],8'd0};
    4'b1001 : fn_aligned_addr = {addr[C_AXI_ADDR_WIDTH -1 : 9],9'd0};
    4'b1010 : fn_aligned_addr = {addr[C_AXI_ADDR_WIDTH -1 : 10],10'd0};
    4'b1011 : fn_aligned_addr = {addr[C_AXI_ADDR_WIDTH -1 : 11],11'd0};
    4'b1100 : fn_aligned_addr = {addr[C_AXI_ADDR_WIDTH -1 : 12],12'd0};
    4'b1101 : fn_aligned_addr = {addr[C_AXI_ADDR_WIDTH -1 : 13],13'd0};
    4'b1110 : fn_aligned_addr = {addr[C_AXI_ADDR_WIDTH -1 : 14],14'd0};
    4'b1111 : fn_aligned_addr = {addr[C_AXI_ADDR_WIDTH -1 : 15],15'd0};
  endcase
endfunction

(*mark_debug = "TRUE"*) wire rd_rpt_data_mismatch;
assign rd_rpt_data_mismatch = |((axi_rdata & exp_str_rdata_mask)^exp_str_rdata);

always @ (posedge clk) begin
  if(tg_rst)begin
    read_cont_data_chk_cnt      <= #TCQ 'b0;
    //read_data_err_cnt           <= #TCQ 0;
    read_data_err_seen          <= #TCQ 0; // use read_data_err_seen instead of read_data_err_cnt for timing fix
  end
  //else if (read_continuous_win_r && axi_rvalid && axi_rready && (axi_rdata != exp_str_rdata))begin
  else if (read_continuous_win_r && axi_rvalid && axi_rready && rd_rpt_data_mismatch)begin // timing fix
    //read_data_err_cnt           <= #TCQ read_data_err_cnt + 1'b1;
    read_data_err_seen          <= #TCQ 1;
    read_cont_data_chk_cnt      <= #TCQ read_cont_data_chk_cnt + 1'b1;
  end
  else if (read_continuous_win_r && axi_rvalid && axi_rready )begin
    read_cont_data_chk_cnt      <= #TCQ read_cont_data_chk_cnt + 1'b1;
  end
  else begin
    read_cont_data_chk_cnt      <= #TCQ read_cont_data_chk_cnt;
    //read_data_err_cnt           <= #TCQ read_data_err_cnt;
  end
end

`endif

(*mark_debug = "TRUE"*) reg [1:0] dbg_data_err_status; // 2'b00 - No_Error, 2'b01 - Write_Path_Error, 2'b10 - Read_Path_Error
(*mark_debug = "TRUE"*) reg       dbg_data_err_status_ready;
always @(posedge clk)begin
  if(tg_rst)begin
    dbg_data_err_status       <= #TCQ 0; 
    dbg_data_err_status_ready <= #TCQ 0;
  end
  //else if(dbg_status_rdy && !read_continuous_big_win_r && read_data_err_cnt == 0)   begin
  else if(dbg_status_rdy && !read_continuous_big_win_r && read_data_err_seen == 0)   begin
    dbg_data_err_status       <=  #TCQ 2'b01; // write_data_path_error
    dbg_data_err_status_ready <= #TCQ 1;
  end
  //else if(dbg_status_rdy && !read_continuous_big_win_r && read_data_err_cnt > 0) begin
  else if(dbg_status_rdy && !read_continuous_big_win_r && read_data_err_seen == 1) begin
    dbg_data_err_status       <=  #TCQ 2'b10; // read_data_path_error
    dbg_data_err_status_ready <= #TCQ 1;
  end
end

assign vio_axi_tg_data_err_status = dbg_data_err_status; // 2'b00 - No_Error, 2'b01 - Write_Path_Error, 2'b10 - Read_Path_Error
assign vio_axi_tg_data_err_status_rdy = dbg_data_err_status_ready;


//synthesis translate off
//Self Checker
final begin
  if(dbg_status_rdy ==  1)begin
    if(dbg_data_err_status == 2'b01)
      $display("[DATA_ERROR_JUSTIFIED_AS] WRITE PATH ERROR");
    else if(dbg_data_err_status == 2'b10)
      $display("[DATA_ERROR_JUSTIFIED_AS] READ PATH ERROR");
    else begin 
      $error("[DATA_ERROR_JUSTIFIED_AS] Something went wrong.. Pleae check the TG");
      $finish();
    end
  end
end

`ifdef EN_RDATA_COMPRESS
reg [C_AXI_ID_WIDTH-1:0]      sc_arid;
reg [C_AXI_ADDR_WIDTH-1:0]    sc_araddr;
reg [7:0]                     sc_arlen;
reg [2:0]                     sc_arsize;
reg [1:0]                     sc_arburst;
always @(posedge clk)begin
  if(tg_rst)begin
    sc_arid     <=  #TCQ  0;
    sc_araddr   <=  #TCQ  0;
    sc_arlen    <=  #TCQ  0;
    sc_arsize   <=  #TCQ  0;
    sc_arburst  <=  #TCQ  0;
  end
  else if(!read_continuous && axi_arvalid && axi_arready) begin
    sc_arid     <=  #TCQ  axi_arid;
    sc_araddr   <=  #TCQ  axi_araddr;
    sc_arlen    <=  #TCQ  axi_arlen;
    sc_arsize   <=  #TCQ  axi_arsize;
    sc_arburst  <=  #TCQ  axi_arburst;
  end
  else if(read_continuous && axi_arvalid && axi_arready) begin
    if(!(sc_arid    == axi_arid &&
       sc_araddr  ==  axi_araddr &&
       sc_arlen   ==  axi_arlen &&
       sc_arsize  ==  axi_arsize &&
       sc_arburst ==  axi_arburst) ) begin
      $error("ERROR :: TEST_SEQ_ERROR :: expected read request is not generated correctlty. EXP ::: id %0h, addr %0h, len %0h, size %0h, burst %0h. ACT :::  id %0h, addr %0h, len %0h, size %0h, burst %0h.", sc_arid, sc_araddr, sc_arlen, sc_arsize, sc_arburst, axi_arid, axi_araddr, axi_arlen, axi_arsize, axi_arburst);
      $finish();
    end
  end
end
`endif
//synthesis translate on
// }}


endmodule










