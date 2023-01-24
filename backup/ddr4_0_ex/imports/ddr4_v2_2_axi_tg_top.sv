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
//  /   /         Filename           : ddr4_v2_1_0_axi_tg_top.sv
// /___/   /\     Date Last Modified : $Date: 2014/09/03 $
// \   \  /  \    Date Created       : Wed Jan 13 2016
//  \___\/\___\
//
//Device: UltraScale
//Design Name: AXI TG
//Purpose:
//   This is the top module for the axi tg. It instantiates the boot/prbs/custom mode_gen modules. Based on the user inputs any one of these modes can be active(running). The running mode will drive the inputs to the axi_opcode_gen module which generates axi4 traffic for slave testing.
//   *_mode_start -> when pulsed will start the mode
//   *_mode_stop -> when pulsed will stop the mode
//   *_mode_done -> is high when user stopped the mode or the mode completed all the instructions in its table. cleared by asserting any *_mode_start
//Reference:
//Revision History:
//*****************************************************************************
`timescale 1ps/1ps 
module ddr4_v2_2_8_axi_tg_top #(
  parameter SIMULATION               = "TRUE",
  parameter C_AXI_ID_WIDTH           = 10,
  parameter C_AXI_ADDR_WIDTH         = 32, 
  parameter C_AXI_DATA_WIDTH         = 32,
  parameter TCQ                      = 0,  //the axi shim has TCQ=0 
  parameter C_AXI_NBURST_SUPPORT     = 0,
  parameter APP_DATA_WIDTH	     = 0, 
  parameter ECC			     = "OFF", 	
  parameter DBG_READ_REPEAT_CNT = 1000 // HW Data Error Debug
)(
  input                                  clk,
  input                                  tg_rst,
  input                                  boot_mode_start,
  input                                  boot_mode_stop,
  output                                 boot_mode_done,
  input                                  custom_mode_start,
  input                                  custom_mode_stop,
  output                                 custom_mode_done,
  input                                  prbs_mode_start,
  input                                  prbs_mode_stop,
  output                                 prbs_mode_done,
  input [31:0]                           prbs_mode_seed,
// AXI write address channel signals
  input                                  axi_awready, // Indicates slave is ready to accept a 
  output [C_AXI_ID_WIDTH-1:0]            axi_awid,    // Write ID
  output [C_AXI_ADDR_WIDTH-1:0]          axi_awaddr,  // Write address
  output [7:0]                           axi_awlen,   // Write Burst Length
  output [2:0]                           axi_awsize,  // Write Burst size
  output [1:0]                           axi_awburst, // Write Burst type
  output                                 axi_awlock,  // Write lock type
  output [3:0]                           axi_awcache, // Write Cache type
  output [2:0]                           axi_awprot,  // Write Protection type
  output                                 axi_awvalid, // Write address valid
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
  output                                 axi_bready,  // Response ready
// AXI read address channel signals
  input                                  axi_arready,     // Read address ready
  output [C_AXI_ID_WIDTH-1:0]            axi_arid,        // Read ID
  output [C_AXI_ADDR_WIDTH-1:0]          axi_araddr,      // Read address
  output [7:0]                           axi_arlen,       // Read Burst Length
  output [2:0]                           axi_arsize,      // Read Burst size
  output [1:0]                           axi_arburst,     // Read Burst type
  output                                 axi_arlock,      // Read lock type
  output [3:0]                           axi_arcache,     // Read Cache type
  output [2:0]                           axi_arprot,      // Read Protection type
  output                                 axi_arvalid,     // Read address valid 
// AXI read data channel signals   
  input  [C_AXI_ID_WIDTH-1:0]            axi_rid,     // Response ID
  input  [1:0]                           axi_rresp,   // Read response
  input                                  axi_rvalid,  // Read reponse valid
  input  [C_AXI_DATA_WIDTH-1:0]          axi_rdata,   // Read data
  input                                  axi_rlast,   // Read last
  output                                 axi_rready,  // Read Response ready
  //error signals//all are sticky
  output reg                                 vio_axi_tg_mismatch_error,
  output reg [C_AXI_DATA_WIDTH-1:0]          vio_axi_tg_expected_bits,
  output reg [C_AXI_DATA_WIDTH-1:0]          vio_axi_tg_actual_bits,
  output reg [C_AXI_DATA_WIDTH-1:0]          vio_axi_tg_error_bits,
  output reg [8:0]                           vio_axi_tg_data_beat_count,
  output reg [C_AXI_ID_WIDTH-1:0]            vio_axi_tg_error_status_id,
  output reg [C_AXI_ADDR_WIDTH-1:0]          vio_axi_tg_error_status_addr,
  output reg [7:0]                           vio_axi_tg_error_status_len,
  output reg [2:0]                           vio_axi_tg_error_status_size,
  output reg [1:0]                           vio_axi_tg_error_status_burst,
  output reg                                 vio_axi_tg_write_resp_error,
  output reg                                 vio_axi_tg_read_resp_error,
  output reg                                 vio_axi_tg_data_err_status_rdy,
  output reg [1:0]                           vio_axi_tg_data_err_status, // 2'b00 - No_Error, 2'b01 - Write_Path_Error, 2'b10 - Read_Path_Error

//debug signals
  output reg                             vio_axi_tg_boot_mode_running,
  output reg                             vio_axi_tg_custom_mode_running,
  output reg                             vio_axi_tg_prbs_mode_running,
  output reg [31:0]                      vio_axi_tg_dbg_instr_pointer 
);

localparam C_DATA_PATTERN_PRBS      = 3'd1;
localparam C_DATA_PATTERN_WALKING0  = 3'd2;
localparam C_DATA_PATTERN_WALKING1  = 3'd3;
localparam C_DATA_PATTERN_ALL_F     = 3'd4;
localparam C_DATA_PATTERN_ALL_0     = 3'd5;
localparam C_DATA_PATTERN_A5A5      = 3'd6;
localparam C_STRB_PATTERN_DEFAULT   = 3'd1;
localparam C_STRB_PATTERN_WALKING1  = 3'd2;
localparam C_STRB_PATTERN_WALKING0  = 3'd3;
localparam C_AXI_BURST_FIXED        = 2'b00;
localparam C_AXI_BURST_INCR         = 2'b01;
localparam C_AXI_BURST_WRAP         = 2'b10;

localparam C_WSTRB_WIDTH_LOG2       = $clog2(C_AXI_DATA_WIDTH/8);

localparam SEND_NBURST              = (C_AXI_NBURST_SUPPORT == 1 || APP_DATA_WIDTH > C_AXI_DATA_WIDTH) ? 1 : 0; 
//
reg reset_id; //the axi id gets to 0 if this signal is pulsed. So at start of each mode we start with id=0 and data_gen seed = 'h5555_5555
always @(posedge clk) begin
  if(tg_rst) begin
   vio_axi_tg_boot_mode_running  <= #TCQ 1'b0; 
   vio_axi_tg_custom_mode_running  <= #TCQ 1'b0; 
   vio_axi_tg_prbs_mode_running  <= #TCQ 1'b0; 
   reset_id <= #TCQ 1'b0;
  end  
  else if(boot_mode_start && ~vio_axi_tg_boot_mode_running) begin
   vio_axi_tg_boot_mode_running  <= #TCQ 1'b1;
   vio_axi_tg_custom_mode_running  <= #TCQ 1'b0; 
   vio_axi_tg_prbs_mode_running  <= #TCQ 1'b0; 
   reset_id <= #TCQ 1'b1;
  end 
  else if(custom_mode_start && ~vio_axi_tg_custom_mode_running) begin
   vio_axi_tg_boot_mode_running  <= #TCQ 1'b0; 
   vio_axi_tg_custom_mode_running  <= #TCQ 1'b1; 
   vio_axi_tg_prbs_mode_running  <= #TCQ 1'b0; 
   reset_id <= #TCQ 1'b1;
  end 
  else if(prbs_mode_start && ~vio_axi_tg_prbs_mode_running) begin
   vio_axi_tg_boot_mode_running  <= #TCQ 1'b0; 
   vio_axi_tg_custom_mode_running  <= #TCQ 1'b0; 
   vio_axi_tg_prbs_mode_running  <= #TCQ 1'b1; 
   reset_id <= #TCQ 1'b1;
  end 
  else if(boot_mode_done || custom_mode_done || prbs_mode_done) begin
   vio_axi_tg_boot_mode_running  <= #TCQ 1'b0; 
   vio_axi_tg_custom_mode_running  <= #TCQ 1'b0; 
   vio_axi_tg_prbs_mode_running  <= #TCQ 1'b0; 
   reset_id <= #TCQ 1'b0;
  end
  else begin
   vio_axi_tg_boot_mode_running  <= #TCQ vio_axi_tg_boot_mode_running; 
   vio_axi_tg_custom_mode_running  <= #TCQ vio_axi_tg_custom_mode_running; 
   vio_axi_tg_prbs_mode_running  <= #TCQ vio_axi_tg_prbs_mode_running; 
   reset_id <= #TCQ 1'b0;
  end  
end
//boot mode signals
wire boot_mode_opcode_gen_start;
wire [C_AXI_ADDR_WIDTH -1:0] boot_mode_instr_axi_addr;
wire [7:0]                   boot_mode_instr_axi_length;
wire [2:0]                   boot_mode_instr_axi_size;
wire [1:0]                   boot_mode_instr_axi_burst;
wire [2:0]                   boot_mode_instr_axi_strb_pattern;
wire [31:0]                  boot_mode_dbg_instr_pointer;
//prbs mode signals
wire prbs_mode_opcode_gen_start;
wire [C_AXI_ADDR_WIDTH -1:0] prbs_mode_instr_axi_addr;
wire [7:0]                   prbs_mode_instr_axi_length;
wire [2:0]                   prbs_mode_instr_axi_size;
wire [1:0]                   prbs_mode_instr_axi_burst;
wire [2:0]                   prbs_mode_instr_axi_strb_pattern;
wire [31:0]                  prbs_mode_dbg_instr_pointer;

//custom mode signals
wire custom_mode_opcode_gen_start;
wire [C_AXI_ADDR_WIDTH -1:0] custom_mode_instr_axi_addr;
wire [7:0]                   custom_mode_instr_axi_length;
wire [2:0]                   custom_mode_instr_axi_size;
wire [1:0]                   custom_mode_instr_axi_burst;
wire [2:0]                   custom_mode_instr_axi_strb_pattern;
wire [31:0]                  custom_mode_dbg_instr_pointer;

//axi_opcode_gen signals
reg opcode_gen_start;
reg [C_AXI_ADDR_WIDTH -1:0] instr_axi_addr;
reg [7:0]                   instr_axi_length;
reg [2:0]                   instr_axi_size;
reg [1:0]                   instr_axi_burst;
reg [2:0]                   instr_axi_strb_pattern;
wire opcode_gen_done;

//error signals//all are non_sticky
wire                                 axi_tg_mismatch_error;
wire [C_AXI_DATA_WIDTH-1:0]          axi_tg_expected_bits;
wire [C_AXI_DATA_WIDTH-1:0]          axi_tg_actual_bits;
wire [C_AXI_DATA_WIDTH-1:0]          axi_tg_error_bits;
wire [8:0]                           axi_tg_data_beat_count;
wire [C_AXI_ID_WIDTH-1:0]            axi_tg_error_status_id;
wire [C_AXI_ADDR_WIDTH-1:0]          axi_tg_error_status_addr;
wire [7:0]                           axi_tg_error_status_len;
wire [2:0]                           axi_tg_error_status_size;
wire [1:0]                           axi_tg_error_status_burst;
wire                                 axi_tg_write_resp_error;
wire                                 axi_tg_read_resp_error;
 
//connections to axi_opcode_gen from boot_mode/prbs_mode/custom mode
always @ (*)begin
  if(vio_axi_tg_boot_mode_running)begin
    opcode_gen_start = boot_mode_opcode_gen_start;
    instr_axi_addr = boot_mode_instr_axi_addr;
    instr_axi_length = boot_mode_instr_axi_length;
    instr_axi_size = boot_mode_instr_axi_size;
    instr_axi_burst = boot_mode_instr_axi_burst;
    instr_axi_strb_pattern = boot_mode_instr_axi_strb_pattern;
    vio_axi_tg_dbg_instr_pointer = boot_mode_dbg_instr_pointer;
  end
  else if (vio_axi_tg_custom_mode_running) begin
    opcode_gen_start = custom_mode_opcode_gen_start;
    instr_axi_addr = custom_mode_instr_axi_addr;
    instr_axi_length = custom_mode_instr_axi_length;
    instr_axi_size = custom_mode_instr_axi_size;
    instr_axi_burst = custom_mode_instr_axi_burst;
    instr_axi_strb_pattern = custom_mode_instr_axi_strb_pattern;
    vio_axi_tg_dbg_instr_pointer = custom_mode_dbg_instr_pointer;
  end
  else if (vio_axi_tg_prbs_mode_running) begin
    opcode_gen_start = prbs_mode_opcode_gen_start;
    instr_axi_addr = prbs_mode_instr_axi_addr;
    instr_axi_length = prbs_mode_instr_axi_length;
    instr_axi_size = prbs_mode_instr_axi_size;
    instr_axi_burst = prbs_mode_instr_axi_burst;
    instr_axi_strb_pattern = prbs_mode_instr_axi_strb_pattern;
    vio_axi_tg_dbg_instr_pointer = prbs_mode_dbg_instr_pointer;
  end
  else begin
    opcode_gen_start = 1'b0;
    instr_axi_addr = {C_AXI_ADDR_WIDTH{1'b0}};
    instr_axi_length = 8'd0;
    instr_axi_size = 3'd0;
    instr_axi_burst = 2'd0;
    instr_axi_strb_pattern = 3'd0;
    vio_axi_tg_dbg_instr_pointer = 32'd0;
  end
end

ddr4_v2_2_8_boot_mode_gen #(
  .C_AXI_ID_WIDTH         (C_AXI_ID_WIDTH   ), 
  .C_AXI_ADDR_WIDTH       (C_AXI_ADDR_WIDTH ),
  .C_AXI_DATA_WIDTH       (C_AXI_DATA_WIDTH ),
  .C_STRB_PATTERN_DEFAULT (C_STRB_PATTERN_DEFAULT),
  .C_STRB_PATTERN_WALKING1(C_STRB_PATTERN_WALKING1),
  .C_STRB_PATTERN_WALKING0(C_STRB_PATTERN_WALKING0),
  .C_AXI_BURST_FIXED      (C_AXI_BURST_FIXED),
  .C_AXI_BURST_INCR       (C_AXI_BURST_INCR),
  .C_AXI_BURST_WRAP       (C_AXI_BURST_WRAP),
  .SEND_NBURST            (SEND_NBURST),
  .TCQ                    (TCQ) 
)u_boot_mode_gen (
  .clk                                (clk                            ),            
  .tg_rst                             (tg_rst                         ),
  .boot_mode_start                    (boot_mode_start                 ),
  .boot_mode_stop                     (boot_mode_stop                 ),
  .opcode_gen_done                    (opcode_gen_done                ),
  .opcode_gen_start                   (boot_mode_opcode_gen_start      ),
  .boot_mode_instr_axi_addr           (boot_mode_instr_axi_addr        ),
  .boot_mode_instr_axi_length         (boot_mode_instr_axi_length      ),
  .boot_mode_instr_axi_size           (boot_mode_instr_axi_size        ),
  .boot_mode_instr_axi_burst          (boot_mode_instr_axi_burst       ),
  .boot_mode_instr_axi_strb_pattern   (boot_mode_instr_axi_strb_pattern),
  .boot_mode_done                     (boot_mode_done                  ),
  .dbg_instr_pointer                  (boot_mode_dbg_instr_pointer    )
);

ddr4_v2_2_8_prbs_mode_gen #(
  .SIMULATION             (SIMULATION       ),
  .C_AXI_ID_WIDTH         (C_AXI_ID_WIDTH   ), 
  .C_AXI_ADDR_WIDTH       (C_AXI_ADDR_WIDTH ),
  .C_AXI_DATA_WIDTH       (C_AXI_DATA_WIDTH ),
  .C_STRB_PATTERN_DEFAULT (C_STRB_PATTERN_DEFAULT),
  .C_STRB_PATTERN_WALKING1(C_STRB_PATTERN_WALKING1),
  .C_STRB_PATTERN_WALKING0(C_STRB_PATTERN_WALKING0),
  .C_AXI_BURST_FIXED      (C_AXI_BURST_FIXED),
  .C_AXI_BURST_INCR       (C_AXI_BURST_INCR),
  .C_AXI_BURST_WRAP       (C_AXI_BURST_WRAP),
  .SEND_NBURST            (SEND_NBURST),
  .TCQ                    (TCQ) 
)u_prbs_mode_gen (
  .clk                                (clk                             ),            
  .tg_rst                             (tg_rst                          ),
  .prbs_mode_start                    (prbs_mode_start                 ),
  .prbs_mode_stop                     (prbs_mode_stop                  ),
  .opcode_gen_done                    (opcode_gen_done                 ),
  .opcode_gen_start                   (prbs_mode_opcode_gen_start      ),
  .prbs_mode_seed                     (prbs_mode_seed                  ),
  .prbs_mode_instr_axi_addr           (prbs_mode_instr_axi_addr        ),
  .prbs_mode_instr_axi_length         (prbs_mode_instr_axi_length      ),
  .prbs_mode_instr_axi_size           (prbs_mode_instr_axi_size        ),
  .prbs_mode_instr_axi_burst          (prbs_mode_instr_axi_burst       ),
  .prbs_mode_instr_axi_strb_pattern   (prbs_mode_instr_axi_strb_pattern),
  .prbs_mode_done                     (prbs_mode_done                  ),
  .dbg_instr_pointer                  (prbs_mode_dbg_instr_pointer     )
);

ddr4_v2_2_8_custom_mode_gen #(
  .C_AXI_ID_WIDTH         (C_AXI_ID_WIDTH   ), 
  .C_AXI_ADDR_WIDTH       (C_AXI_ADDR_WIDTH ),
  .C_AXI_DATA_WIDTH       (C_AXI_DATA_WIDTH ),
  .C_STRB_PATTERN_DEFAULT (C_STRB_PATTERN_DEFAULT),
  .C_STRB_PATTERN_WALKING1(C_STRB_PATTERN_WALKING1),
  .C_STRB_PATTERN_WALKING0(C_STRB_PATTERN_WALKING0),
  .C_AXI_BURST_FIXED      (C_AXI_BURST_FIXED),
  .C_AXI_BURST_INCR       (C_AXI_BURST_INCR),
  .C_AXI_BURST_WRAP       (C_AXI_BURST_WRAP),
  .SEND_NBURST            (SEND_NBURST),
  .TCQ                    (TCQ) 
)u_custom_mode_gen (
  .clk                                (clk                               ),            
  .tg_rst                             (tg_rst                            ),
  .custom_mode_start                  (custom_mode_start                 ),
  .custom_mode_stop                   (custom_mode_stop                  ),
  .opcode_gen_done                    (opcode_gen_done                   ),
  .opcode_gen_start                   (custom_mode_opcode_gen_start      ),
  .custom_mode_instr_axi_addr         (custom_mode_instr_axi_addr        ),
  .custom_mode_instr_axi_length       (custom_mode_instr_axi_length      ),
  .custom_mode_instr_axi_size         (custom_mode_instr_axi_size        ),
  .custom_mode_instr_axi_burst        (custom_mode_instr_axi_burst       ),
  .custom_mode_instr_axi_strb_pattern (custom_mode_instr_axi_strb_pattern),
  .custom_mode_done                   (custom_mode_done                  ),
  .dbg_instr_pointer                  (custom_mode_dbg_instr_pointer     )
);

ddr4_v2_2_8_axi_opcode_gen #(
  .C_AXI_ID_WIDTH         (C_AXI_ID_WIDTH   ), 
  .C_AXI_ADDR_WIDTH       (C_AXI_ADDR_WIDTH ),
  .C_AXI_DATA_WIDTH       (C_AXI_DATA_WIDTH ),
  .C_DATA_PATTERN_PRBS    (C_DATA_PATTERN_PRBS),
  .C_DATA_PATTERN_WALKING0(C_DATA_PATTERN_WALKING0),
  .C_DATA_PATTERN_WALKING1(C_DATA_PATTERN_WALKING1),
  .C_DATA_PATTERN_ALL_F   (C_DATA_PATTERN_ALL_F),
  .C_DATA_PATTERN_ALL_0   (C_DATA_PATTERN_ALL_0),
  .C_DATA_PATTERN_A5A5    (C_DATA_PATTERN_A5A5),
  .C_STRB_PATTERN_DEFAULT (C_STRB_PATTERN_DEFAULT),
  .C_STRB_PATTERN_WALKING1(C_STRB_PATTERN_WALKING1),
  .C_STRB_PATTERN_WALKING0(C_STRB_PATTERN_WALKING0), 
  .APP_DATA_WIDTH	        (APP_DATA_WIDTH), 
  .C_AXI_NBURST_SUPPORT	  (C_AXI_NBURST_SUPPORT),
  .SEND_NBURST            (SEND_NBURST),
  .TCQ                    (TCQ), 
  .DBG_READ_REPEAT_CNT (DBG_READ_REPEAT_CNT), // HW Data Error Debug
  .ECC			  (ECC)
)u_axi_opcode_gen(
  .clk                             (clk                   ),
  .tg_rst                          (tg_rst                ),
  .opcode_gen_start                (opcode_gen_start      ),
  .opcode_gen_done                 (opcode_gen_done       ),
  .instr_axi_addr                  (instr_axi_addr        ),
  .instr_axi_length                (instr_axi_length      ),
  .instr_axi_size                  (instr_axi_size        ),
  .instr_axi_burst                 (instr_axi_burst       ),
  .instr_axi_strb_pattern          (instr_axi_strb_pattern),
  .reset_id                        (reset_id              ), 
  .axi_awready                     (axi_awready           ),
  .axi_awid                        (axi_awid              ),
  .axi_awaddr                      (axi_awaddr            ),
  .axi_awlen                       (axi_awlen             ),
  .axi_awsize                      (axi_awsize            ),
  .axi_awburst                     (axi_awburst           ),
  .axi_awlock                      (axi_awlock            ),
  .axi_awcache                     (axi_awcache           ),
  .axi_awprot                      (axi_awprot            ),
  .axi_awvalid                     (axi_awvalid           ),
  .axi_wready                      (axi_wready            ),
  .axi_wdata                       (axi_wdata             ),
  .axi_wstrb                       (axi_wstrb             ),
  .axi_wlast                       (axi_wlast             ),
  .axi_wvalid                      (axi_wvalid            ),
  .axi_bid                         (axi_bid               ),
  .axi_bresp                       (axi_bresp             ),
  .axi_bvalid                      (axi_bvalid            ),
  .axi_bready                      (axi_bready            ),
  .axi_arready                     (axi_arready           ),
  .axi_arid                        (axi_arid              ),
  .axi_araddr                      (axi_araddr            ),
  .axi_arlen                       (axi_arlen             ),
  .axi_arsize                      (axi_arsize            ),
  .axi_arburst                     (axi_arburst           ),
  .axi_arlock                      (axi_arlock            ),
  .axi_arcache                     (axi_arcache           ),
  .axi_arprot                      (axi_arprot            ),
  .axi_arvalid                     (axi_arvalid           ),
  .axi_rid                         (axi_rid               ),
  .axi_rresp                       (axi_rresp             ),
  .axi_rvalid                      (axi_rvalid            ),
  .axi_rdata                       (axi_rdata             ),
  .axi_rlast                       (axi_rlast             ),
  .axi_rready                      (axi_rready            ),
  .vio_axi_tg_mismatch_error       (axi_tg_mismatch_error),
  .vio_axi_tg_expected_bits        (axi_tg_expected_bits),
  .vio_axi_tg_actual_bits          (axi_tg_actual_bits),
  .vio_axi_tg_error_bits           (axi_tg_error_bits),
  .vio_axi_tg_data_beat_count      (axi_tg_data_beat_count),
  .vio_axi_tg_error_status_id      (axi_tg_error_status_id),
  .vio_axi_tg_error_status_addr    (axi_tg_error_status_addr),
  .vio_axi_tg_error_status_len     (axi_tg_error_status_len),
  .vio_axi_tg_error_status_size    (axi_tg_error_status_size),
  .vio_axi_tg_error_status_burst   (axi_tg_error_status_burst),
  .vio_axi_tg_write_resp_error     (axi_tg_write_resp_error),
  .vio_axi_tg_read_resp_error      (axi_tg_read_resp_error),
  .vio_axi_tg_data_err_status_rdy  (vio_axi_tg_data_err_status_rdy),
  .vio_axi_tg_data_err_status      (vio_axi_tg_data_err_status) // HW Data Error Debug
);

// *************************************************************************    
// Watch Dog
// - Check if there is
//   1) Read/Write Command issued
//   2) Read Data return
//   within a fixed number of cycle when TG is activated
// *************************************************************************    
localparam C_TG_WATCH_DOG_MAX_CNT = 16'hFFFF;
reg [15:0] watch_dog_cnt;
wire       watch_dog_enable;
reg        watch_dog_rst;
wire       watch_dog_hang;
assign watch_dog_enable = 1'b1;
always@(posedge clk) begin
  watch_dog_rst <= #TCQ ((axi_awready && axi_awvalid) || (axi_wready && axi_wvalid) || (axi_bready && axi_bvalid) || (axi_arready && axi_arvalid) || (axi_rready && axi_rvalid));
end

always@(posedge clk) begin
   if (tg_rst | watch_dog_rst) begin
     watch_dog_cnt <= #TCQ 'h0;
   end
   else if (watch_dog_enable && ~watch_dog_hang && (vio_axi_tg_boot_mode_running || vio_axi_tg_custom_mode_running || vio_axi_tg_prbs_mode_running) ) begin
     watch_dog_cnt <= #TCQ watch_dog_cnt + 'h1;
   end
   else begin
     watch_dog_cnt <= #TCQ watch_dog_cnt;
   end  
end
assign watch_dog_hang = (watch_dog_cnt == C_TG_WATCH_DOG_MAX_CNT);

//*****************************************************************************
// Generate sticky error status signals for vio connections. 
// The signals will be cleared on tg_rst
//*****************************************************************************
always @(posedge clk) begin
  if (tg_rst) begin
    vio_axi_tg_mismatch_error      <= #TCQ 0;   
    vio_axi_tg_expected_bits       <= #TCQ 0;
    vio_axi_tg_actual_bits         <= #TCQ 0;
    vio_axi_tg_error_bits          <= #TCQ 0;
    vio_axi_tg_data_beat_count     <= #TCQ 0;
    vio_axi_tg_error_status_id     <= #TCQ 0;
    vio_axi_tg_error_status_addr   <= #TCQ 0;
    vio_axi_tg_error_status_len    <= #TCQ 0;
    vio_axi_tg_error_status_size   <= #TCQ 0;
    vio_axi_tg_error_status_burst  <= #TCQ 0;
  end
  else if(axi_tg_mismatch_error && ~vio_axi_tg_mismatch_error)begin
    vio_axi_tg_mismatch_error      <= #TCQ axi_tg_mismatch_error;
    vio_axi_tg_expected_bits       <= #TCQ axi_tg_expected_bits;
    vio_axi_tg_actual_bits         <= #TCQ axi_tg_actual_bits;
    vio_axi_tg_error_bits          <= #TCQ axi_tg_error_bits;
    vio_axi_tg_data_beat_count     <= #TCQ axi_tg_data_beat_count;
    vio_axi_tg_error_status_id     <= #TCQ axi_tg_error_status_id;
    vio_axi_tg_error_status_addr   <= #TCQ axi_tg_error_status_addr;
    vio_axi_tg_error_status_len    <= #TCQ axi_tg_error_status_len;
    vio_axi_tg_error_status_size   <= #TCQ axi_tg_error_status_size;
    vio_axi_tg_error_status_burst  <= #TCQ axi_tg_error_status_burst;
  end  
end
always @(posedge clk) begin
  if (tg_rst) begin
    vio_axi_tg_write_resp_error <= #TCQ 0;
  end
  else if(axi_tg_write_resp_error)begin
    vio_axi_tg_write_resp_error <= #TCQ axi_tg_write_resp_error;
  end  
end
always @(posedge clk) begin
  if (tg_rst) begin
    vio_axi_tg_read_resp_error <= #TCQ 0;
  end
  else if(axi_tg_read_resp_error)begin
    vio_axi_tg_read_resp_error <= #TCQ axi_tg_read_resp_error;
  end  
end

//synthesis translate off
integer mismatch_err_cnt =0;
always @(posedge clk)begin
  if(axi_tg_mismatch_error)begin
    $display("ERROR::mismatch");
    $display("araddr='h%h,arlen='d%0d,arsize='d%0d,arburst='b%2b,rstrb_pattern=%0d",instr_axi_addr,instr_axi_length,instr_axi_size,instr_axi_burst,instr_axi_strb_pattern);
    mismatch_err_cnt <= mismatch_err_cnt+ 1'b1;
  end
  else if(axi_tg_write_resp_error)begin
    $display("ERROR:: at time %t write_resp_error", $time);
    mismatch_err_cnt <= mismatch_err_cnt+ 1'b1;
  end
  else if(axi_tg_read_resp_error)begin
    $display("ERROR:: at time %t read_resp_error", $time);
    mismatch_err_cnt <= mismatch_err_cnt+ 1'b1;
  end
end

always @(posedge clk)begin
  if(watch_dog_hang)begin
    $display("ERROR:: watch_dog_hang");
    $finish;
  end
end

initial begin
  wait(prbs_mode_done ==0);
  wait(prbs_mode_done ==1);
  $display("ALL AXI TRANSACTIONS COMPLETE");
  if(mismatch_err_cnt ==0 ) begin 
    $display ("TEST PASSED");
    $display ("Test Completed Successfully");
  end  
  else begin
    $display("TEST FAILED. No of mismatches = %0d",mismatch_err_cnt);
  end
  $finish;
end
//Assertions
//If narrow_burst_enable option is not selected for MIG design, TG cannot send narrow transfers. Refer pg150 for more details
generate 
if((C_AXI_NBURST_SUPPORT == 0) && (APP_DATA_WIDTH == C_AXI_DATA_WIDTH)) begin: narrow_burst_disabled_check_size
  property narrow_burst_disabled_check_size_for_writes;
    @(posedge clk) disable iff (tg_rst) (axi_awready && axi_awvalid ) |-> (axi_awsize == C_WSTRB_WIDTH_LOG2);
  endproperty
  assert_narrow_burst_disabled_check_size_for_writes : assert property(narrow_burst_disabled_check_size_for_writes)else $error("Sending AXI Write request of size='h%0h when narrow burst support is disabled in Controller. Refer PG150 for more details",axi_awsize);
  
  property narrow_burst_disabled_check_size_for_reads;
    @(posedge clk) disable iff (tg_rst) (axi_arready && axi_arvalid ) |-> (axi_arsize == C_WSTRB_WIDTH_LOG2);
  endproperty
  assert_narrow_burst_disabled_check_size_for_reads : assert property (narrow_burst_disabled_check_size_for_reads) else $error("Sending AXI Read request of size='h%0h when narrow burst support is disabled in Controller. Refer PG150 for more details",axi_arsize);
end
endgenerate
//synthesis translate on
endmodule


