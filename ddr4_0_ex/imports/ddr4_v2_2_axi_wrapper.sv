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
//  /   /         Filename           : ddr4_v2_2_8_axi_wrapper.sv
// /___/   /\     Date Last Modified : $Date: 2014/09/03 $
// \   \  /  \    Date Created       : Wed Jan 13 2016
//  \___\/\___\
//
//Device: UltraScale
//Design Name: AXI TG
//Purpose:
//   This module is wrapper for converting the reads and writes to transactions
//   that follow the AXI4 protocol.
//   It generates the necessary addr/control signals for both the read and write paths.
//   The data_gen block generates the write data and wstrb
//   The data_chk block compares the received read data with the expected data
//Reference:
//Revision History:
//*****************************************************************************
`timescale 1ps/1ps 
module ddr4_v2_2_8_axi_wrapper #(
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
  parameter TCQ                      = 100
)
( //connected to axi sequence generator
  input                                  clk,
  input                                  tg_rst,
  input                                  cmd_en_wr, //send wr cmd and data
  input [C_AXI_ADDR_WIDTH -1:0]          awaddr,
  input [7:0]                            awlen,
  input [2:0]                            awsize,
  input [1:0]                            awburst,
  input [2:0]                            wdata_pattern,
  input [2:0]                            wstrb_pattern,
  output                                 write_done,
  input                                  cmd_en_rd,//send rd cmd and data
  input [C_AXI_ADDR_WIDTH -1:0]          araddr,
  input [7:0]                            arlen,
  input [2:0]                            arsize,
  input [1:0]                            arburst,
  input [2:0]                            rdata_pattern,
  input [2:0]                            rstrb_pattern,
  input                                  compare_wr_rd, 
  input                                  compare_bg, 
  output                                 read_done,
  input                                  reset_id,
  input                                  read_continuous, // HW Data Error Debug 
  output                                 data_chk_done,
  input  [C_AXI_ADDR_WIDTH-1:0]          rpt_rd_araddr,
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
  output reg                             axi_wvalid,   // Write valid  
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
  output [C_AXI_DATA_WIDTH-1:0]          vio_axi_tg_actual_bits_mask,
  output [C_AXI_DATA_WIDTH-1:0]          vio_axi_tg_error_bits,
  output [8:0]                           vio_axi_tg_data_beat_count,
  output reg [C_AXI_ID_WIDTH-1:0]        vio_axi_tg_error_status_id,
  output reg [C_AXI_ADDR_WIDTH-1:0]      vio_axi_tg_error_status_addr,
  output reg [7:0]                       vio_axi_tg_error_status_len,
  output reg [2:0]                       vio_axi_tg_error_status_size,
  output reg [1:0]                       vio_axi_tg_error_status_burst,
  output                                 vio_axi_tg_write_resp_error,
  output                                 vio_axi_tg_read_resp_error
);
//cmd_en_wr_p, cmd_en_rd_p pulse generation
reg write_channel_active;
reg write_done_r;
always @(posedge clk) write_done_r <= #TCQ write_done;
always @(posedge clk)begin
  if(cmd_en_wr && !write_done_r)
   write_channel_active <= #TCQ 1'b1;
  else 
   write_channel_active <= #TCQ 1'b0;
end
wire generate_wrdata;
assign generate_wrdata = cmd_en_wr && ~write_channel_active ;
reg generate_wrdata_r;
reg generate_wrdata_2r; //wrcmd triggers with this signal
always @(posedge clk)begin
  generate_wrdata_r <= #TCQ generate_wrdata;
  generate_wrdata_2r <= #TCQ generate_wrdata_r;
end

reg read_channel_active;
reg read_done_r;
//always @(posedge clk) read_done_r <= #TCQ read_done;
always @(posedge clk) read_done_r <= #TCQ data_chk_done;
always @(posedge clk)begin
  if(cmd_en_rd && !read_done_r)
   read_channel_active <= #TCQ 1'b1;
  else 
   read_channel_active <= #TCQ 1'b0;
end
wire generate_rddata;
assign generate_rddata = cmd_en_rd && ~read_channel_active ;
reg generate_rddata_r;
reg generate_rddata_2r; //rdcmd triggers with this signal
always @(posedge clk)begin
  generate_rddata_r <= #TCQ generate_rddata;
  generate_rddata_2r <= #TCQ generate_rddata_r;
end

//////////////////////	 
//Write Address Channel
//////////////////////
reg [C_AXI_ID_WIDTH -1:0] awid;
reg [2:0] data_pattern_wr;
reg [2:0] strb_pattern_wr;

always @(posedge clk)
  begin
     if (tg_rst || reset_id)begin
       axi_awvalid <= #TCQ 1'b0;
       axi_awid <= #TCQ  'b0;
       axi_awaddr <= #TCQ  'b0;
       axi_awlen <= #TCQ  8'b0;
       axi_awsize <= #TCQ  3'b0;
       axi_awburst <= #TCQ  2'b0;
       axi_awlock <= #TCQ 1'b0;
       axi_awcache <= #TCQ 4'b0;
       axi_awprot <= #TCQ 3'b0;
       awid <= #TCQ 'b0;
       data_pattern_wr <= #TCQ 3'b000;
       strb_pattern_wr <= #TCQ 3'b000;
      end 
     // If previously not valid and no throttling, start next transaction
     else if (generate_wrdata_2r && axi_awvalid==0)begin
       axi_awvalid <= #TCQ 1'b1;
       axi_awid <= #TCQ awid;
       axi_awaddr <= #TCQ awaddr;
       axi_awlen <= #TCQ awlen;
       axi_awsize <= #TCQ awsize;
       axi_awburst <= #TCQ awburst;
       awid <= #TCQ awid + (wdata_pattern == C_DATA_PATTERN_PRBS);//to ensure that id increments only for primary(prbs)pattern and not for background(A5A5) pattern
       data_pattern_wr <= #TCQ wdata_pattern;
       strb_pattern_wr <= #TCQ wstrb_pattern;
     end  
     /* Once asserted, VALIDs cannot be deasserted, so AWVALID
      must wait until transaction is accepted before throttling */
     else if (axi_awready && axi_awvalid)begin
       axi_awvalid <= #TCQ 1'b0; 
       axi_awid <= #TCQ axi_awid;
       axi_awaddr <= #TCQ axi_awaddr;
       axi_awlen <= #TCQ axi_awlen;
       axi_awsize <= #TCQ axi_awsize;
       axi_awburst <= #TCQ axi_awburst;
       data_pattern_wr <= #TCQ data_pattern_wr;
       strb_pattern_wr <= #TCQ strb_pattern_wr;
     end  
     else begin
       axi_awvalid <= #TCQ axi_awvalid;    
       axi_awid <= #TCQ axi_awid;
       axi_awaddr <= #TCQ axi_awaddr;
       axi_awlen <= #TCQ axi_awlen;
       axi_awsize <= #TCQ axi_awsize;
       axi_awburst <= #TCQ axi_awburst;
       data_pattern_wr <= #TCQ data_pattern_wr;
       strb_pattern_wr <= #TCQ strb_pattern_wr;
     end  
  end
   
//////////////////////	 
//Write Data Channel
//////////////////////
// Forward movement occurs when the channel is valid and ready
wire wnext;

assign wnext = axi_wready & axi_wvalid;
// WVALID logic, similar to the AWVALID always block above
always @(posedge clk)
  begin
     if (tg_rst)begin
       axi_wvalid <= #TCQ 1'b0;  
     end  
     // If previously not valid and not throttling, start next transaction
     else if (generate_wrdata_2r && axi_awvalid==0 && axi_wvalid==0 )
       axi_wvalid <= #TCQ 1'b1;
     /* If WREADY and too many writes, throttle WVALID. Once asserted, VALIDs cannot be deasserted, so WVALID must wait until burst is complete with WLAST */
     else if (wnext && axi_wlast)begin
       axi_wvalid <= #TCQ 1'b0; 
     end  
     else
       axi_wvalid <= #TCQ axi_wvalid;    
  end

//WLAST generation on the MSB of a counter underflow
localparam C_WLEN_COUNT_WIDTH ='d9;
reg [C_WLEN_COUNT_WIDTH -1:0] wlen_count;
assign axi_wlast = wlen_count[C_WLEN_COUNT_WIDTH -1];
/* Burst length counter. Uses extra counter register bit to indicate terminal
 count to reduce decode logic */    
always @(posedge clk)
  begin
     if (tg_rst || (axi_wlast && wnext))
	  wlen_count <= #TCQ 0;
     else if (generate_wrdata_2r && ~wnext)
	  wlen_count <= #TCQ {1'b0,awlen} - 1;
     else if (wnext)
	  wlen_count <= #TCQ wlen_count - 1;
     else
	  wlen_count <= #TCQ wlen_count;
  end

// Write Data Generator
ddr4_v2_2_8_data_gen # (
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
  )u_data_gen 
  (
    .tg_rst(tg_rst),
    .clk(clk),
    .data_en(wnext),
    .data_pattern(data_pattern_wr),
    .pattern_init(generate_wrdata),
    .prbs_seed_i(awid),
    .strb_pattern(wstrb_pattern),
    .len_in(awlen),
    .size_in(awsize),
    .burst_in(awburst),
    .last(axi_wlast),
    .start_addr(awaddr[6:0]),
    .data_out(axi_wdata),
    .wstrb_out(axi_wstrb),
    .wstrb_out_default()
  );

//Always accept write responses
always @(posedge clk)
  begin
     if (tg_rst)
	  axi_bready <= #TCQ 1'b0;
      else
	  axi_bready <= #TCQ 1'b1;
 end

//Flag any write response errors 
assign vio_axi_tg_write_resp_error = axi_bready & axi_bvalid & axi_bresp[1];

assign write_done = axi_bready & axi_bvalid; //write tx complete when write resp is available

//////////////////////	 
//Read Address Channel
//////////////////////
reg [C_AXI_ID_WIDTH -1:0] arid;
reg [2:0] data_pattern_rd;
reg [2:0] strb_pattern_rd;
always @(posedge clk)
  begin
     if (tg_rst || reset_id)begin
       axi_arvalid <= #TCQ 1'b0;
       axi_arid <= #TCQ  'b0;
       axi_araddr <= #TCQ  'b0;
       axi_arlen <= #TCQ  8'b0;
       axi_arsize <= #TCQ  3'b0;
       axi_arburst <= #TCQ  2'b0;
       axi_arlock <= #TCQ 1'b0;
       axi_arcache <= #TCQ 4'b0;
       axi_arprot <= #TCQ 3'b0;
       arid <= #TCQ 'b0;
       data_pattern_rd <= #TCQ 3'b000;
       strb_pattern_rd <= #TCQ 3'b000;
      end 
     // If previously not valid and no throttling, start next transaction
     else if (generate_rddata_2r && axi_arvalid==0)begin
       axi_arvalid <= #TCQ 1'b1;
       axi_arid <= #TCQ read_continuous ? axi_arid : arid; // HW Data Error Debug
       axi_arsize <= #TCQ read_continuous ? axi_arsize : arsize;
       `ifdef EN_RDATA_COMPRESS
       axi_araddr <= #TCQ read_continuous ? axi_araddr : araddr;
       axi_arlen <= #TCQ read_continuous ? axi_arlen : arlen;
       axi_arburst <= #TCQ read_continuous ? axi_arburst : arburst;
       `else
       axi_araddr <= #TCQ read_continuous ? rpt_rd_araddr : araddr;
       axi_arlen <= #TCQ read_continuous ? /*axi_arlen*/8'b0 : arlen;
       axi_arburst <= #TCQ read_continuous ? /*axi_arburst*/2'b1 : arburst;
       `endif
       arid <= #TCQ read_continuous ? arid : (arid + (rdata_pattern == C_DATA_PATTERN_PRBS)); // HW Data Error Debug
       data_pattern_rd <= #TCQ rdata_pattern;
       strb_pattern_rd <= #TCQ rstrb_pattern;
    end  
     /* Once asserted, VALIDs cannot be deasserted, so AWVALID
      must wait until transaction is accepted before throttling */
     else if (axi_arready && axi_arvalid)begin
       axi_arvalid <= #TCQ 1'b0; 
       axi_arid <= #TCQ axi_arid;
       axi_araddr <= #TCQ axi_araddr;
       axi_arlen <= #TCQ axi_arlen;
       axi_arsize <= #TCQ axi_arsize;
       axi_arburst <= #TCQ axi_arburst;
       data_pattern_rd <= #TCQ data_pattern_rd;
       strb_pattern_rd <= #TCQ strb_pattern_rd;
     end  
     else begin
       axi_arvalid <= #TCQ axi_arvalid;    
       axi_arid <= #TCQ axi_arid;
       axi_araddr <= #TCQ axi_araddr;
       axi_arlen <= #TCQ axi_arlen;
       axi_arsize <= #TCQ axi_arsize;
       axi_arburst <= #TCQ axi_arburst;
       data_pattern_rd <= #TCQ data_pattern_rd;
       strb_pattern_rd <= #TCQ strb_pattern_rd;
     end  
  end
//////////////////////////////////   
//Read Data (and Response) Channel
//////////////////////////////////
always @(posedge clk)
  begin
     if (tg_rst)
	     axi_rready <= #TCQ 1'b0;
     else
	     axi_rready <= #TCQ 1'b1;
     end

assign vio_axi_tg_read_resp_error = axi_rready & axi_rvalid & axi_rresp[1];

assign read_done = axi_rready & axi_rvalid & axi_rlast;

wire rd_valid;
assign rd_valid = axi_rvalid && axi_rready; 
wire rd_last_valid;
assign rd_last_valid = axi_rvalid && axi_rready && axi_rlast;

//this block compares the axi_rdata with the predicted data and issues mismatch_err incase of any mismatches
ddr4_v2_2_8_data_chk # (
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
  )u_data_chk 
  (
    .tg_rst(tg_rst),
    .clk(clk),
    .data_en(rd_valid),
    .data_pattern(data_pattern_rd),
    .pattern_init(generate_rddata),
    .prbs_seed_i(read_continuous ? axi_arid : arid), // HW Data Error Debug
    .strb_pattern(rstrb_pattern),
    .len_in(arlen),
    .size_in(arsize),
    .burst_in(arburst),
    .last(axi_rlast),
    .start_addr(araddr[6:0]),
    .compare_wr_rd(compare_wr_rd),
    .compare_bg(compare_bg),
    .rdata(axi_rdata),
    .rdata_vld(rd_valid),
    .rlast_vld(rd_last_valid),
    .data_chk_done(data_chk_done),
    .mismatch_err(vio_axi_tg_mismatch_error),
    .expected_data(vio_axi_tg_expected_bits),
    .actual_data(vio_axi_tg_actual_bits),
    .actual_data_mask(vio_axi_tg_actual_bits_mask),
    .error_bits(vio_axi_tg_error_bits),
    .data_beat_count(vio_axi_tg_data_beat_count)
  );

//temporarily storing the read addr/cmd for error reporting
always @(posedge clk) begin
  if(axi_arvalid && axi_arready)begin
    vio_axi_tg_error_status_id <= #TCQ axi_arid;
    vio_axi_tg_error_status_addr <= #TCQ axi_araddr;
    vio_axi_tg_error_status_len <= #TCQ axi_arlen;
    vio_axi_tg_error_status_size <= #TCQ axi_arsize;
    vio_axi_tg_error_status_burst <= #TCQ axi_arburst;
  end 
  else if(axi_awvalid && axi_awready) begin
    vio_axi_tg_error_status_id <= #TCQ axi_awid;
    vio_axi_tg_error_status_addr <= #TCQ axi_awaddr;
    vio_axi_tg_error_status_len <= #TCQ axi_awlen;
    vio_axi_tg_error_status_size <= #TCQ axi_awsize;
    vio_axi_tg_error_status_burst <= #TCQ axi_awburst;
  end 
end

//synthesis translate off
 always@(posedge clk) begin
   if(axi_wvalid && axi_wready) begin
     if(axi_wstrb == 0) $fatal(1, "%0t all zero strbs are being sent",$time);
   end  
 end
//synthesis translate on

endmodule



