

/******************************************************************************
// (c) Copyright 2013 - 2014 Xilinx, Inc. All rights reserved.
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
//  /   /         Filename           : example_top.sv
// /___/   /\     Date Last Modified : $Date: 2014/09/03 $
// \   \  /  \    Date Created       : Thu Apr 18 2013
//  \___\/\___\
//
// Device           : UltraScale
// Design Name      : DDR4_SDRAM
// Purpose          :
//                    Top-level  module. This module serves both as an example,
//                    and allows the user to synthesize a self-contained
//                    design, which they can be used to test their hardware.
//                    In addition to the memory controller,
//                    the module instantiates:
//                      1. Synthesizable testbench - used to model
//                      user's backend logic and generate different
//                      traffic patterns
//
// Reference        :
// Revision History :
//*****************************************************************************
`ifdef MODEL_TECH
    `define SIMULATION_MODE
`elsif INCA
    `define SIMULATION_MODE
`elsif VCS
    `define SIMULATION_MODE
`elsif XILINX_SIMULATOR
    `define SIMULATION_MODE
`elsif _VCP
    `define SIMULATION_MODE
`endif


`timescale 1ps/1ps
module example_top #
  (
    parameter nCK_PER_CLK           = 4,   // This parameter is controllerwise
    parameter         APP_DATA_WIDTH          = 512, // This parameter is controllerwise
    parameter         APP_MASK_WIDTH          = 64,  // This parameter is controllerwise
    parameter C_AXI_ID_WIDTH                = 4,
                                              // Width of all master and slave ID signals.
                                              // # = >= 1.
    parameter C_AXI_ADDR_WIDTH              = 34,
                                              // Width of S_AXI_AWADDR, S_AXI_ARADDR, M_AXI_AWADDR and
                                              // M_AXI_ARADDR for all SI/MI slots.
                                              // # = 32.
    parameter C_AXI_DATA_WIDTH              = 512,
                                              // Width of WDATA and RDATA on SI slot.
                                              // Must be <= APP_DATA_WIDTH.
                                              // # = 32, 64, 128, 256.
    parameter C_AXI_NBURST_SUPPORT   = 0,

  `ifdef SIMULATION_MODE
    parameter SIMULATION            = "TRUE" 
  `else
    parameter SIMULATION            = "FALSE"
  `endif

  )
   (
    input                 sys_rst, //Common port for all controllers


    output                  c0_init_calib_complete,
    output                  c0_data_compare_error,
    input                   c0_sys_clk_p,
    input                   c0_sys_clk_n,
    output                  c0_ddr4_act_n,
    output [16:0]            c0_ddr4_adr,
    output [1:0]            c0_ddr4_ba,
    output [1:0]            c0_ddr4_bg,
    output [0:0]            c0_ddr4_cke,
    output [0:0]            c0_ddr4_odt,
    output [0:0]            c0_ddr4_cs_n,
    output [0:0]                 c0_ddr4_ck_t,
    output [0:0]                c0_ddr4_ck_c,
    output                  c0_ddr4_reset_n,
    output                c0_ddr4_parity,
    inout  [71:0]            c0_ddr4_dq,
    inout  [17:0]            c0_ddr4_dqs_t,
    inout  [17:0]            c0_ddr4_dqs_c
    );


  localparam  APP_ADDR_WIDTH = 31;
  localparam  MEM_ADDR_ORDER = "ROW_COLUMN_BANK_INTLV";
  localparam DBG_WR_STS_WIDTH      = 32;
  localparam DBG_RD_STS_WIDTH      = 32;
  localparam ECC                   = "ON";





  wire [APP_ADDR_WIDTH-1:0]            c0_ddr4_app_addr;
  wire [2:0]            c0_ddr4_app_cmd;
  wire                  c0_ddr4_app_en;
  wire [APP_DATA_WIDTH-1:0]            c0_ddr4_app_wdf_data;
  wire                  c0_ddr4_app_wdf_end;
  wire [APP_MASK_WIDTH-1:0]            c0_ddr4_app_wdf_mask;
  wire                  c0_ddr4_app_wdf_wren;
  wire [APP_DATA_WIDTH-1:0]            c0_ddr4_app_rd_data;
  wire                  c0_ddr4_app_rd_data_end;
  wire                  c0_ddr4_app_rd_data_valid;
  wire                  c0_ddr4_app_rdy;
  wire                  c0_ddr4_app_wdf_rdy;
  wire                  c0_ddr4_clk;
  wire                  c0_ddr4_rst;
  wire                  dbg_clk;
  wire                  c0_wr_rd_complete;


  reg                              c0_ddr4_aresetn;
  wire                             c0_ddr4_data_msmatch_err;
  wire                             c0_ddr4_write_err;
  wire                             c0_ddr4_read_err;
  wire                             c0_ddr4_test_cmptd;
  wire                             c0_ddr4_write_cmptd;
  wire                             c0_ddr4_read_cmptd;
  wire                             c0_ddr4_cmptd_one_wr_rd;
  wire                             c0_ddr4_tg_data_err_status_rdy;
  wire [1:0]                       c0_ddr4_tg_data_err_status;

  // Slave Interface Write Address Ports
  wire [3:0]      c0_ddr4_s_axi_awid;
  wire [33:0]    c0_ddr4_s_axi_awaddr;
  wire [7:0]                       c0_ddr4_s_axi_awlen;
  wire [2:0]                       c0_ddr4_s_axi_awsize;
  wire [1:0]                       c0_ddr4_s_axi_awburst;
  wire [3:0]                       c0_ddr4_s_axi_awcache;
  wire [2:0]                       c0_ddr4_s_axi_awprot;
  wire                             c0_ddr4_s_axi_awvalid;
  wire                             c0_ddr4_s_axi_awready;
   // Slave Interface Write Data Ports
  wire [511:0]    c0_ddr4_s_axi_wdata;
  wire [63:0]  c0_ddr4_s_axi_wstrb;
  wire                             c0_ddr4_s_axi_wlast;
  wire                             c0_ddr4_s_axi_wvalid;
  wire                             c0_ddr4_s_axi_wready;
   // Slave Interface Write Response Ports
  wire                             c0_ddr4_s_axi_bready;
  wire [3:0]      c0_ddr4_s_axi_bid;
  wire [1:0]                       c0_ddr4_s_axi_bresp;
  wire                             c0_ddr4_s_axi_bvalid;
   // Slave Interface Read Address Ports
  wire [3:0]      c0_ddr4_s_axi_arid;
  wire [33:0]    c0_ddr4_s_axi_araddr;
  wire [7:0]                       c0_ddr4_s_axi_arlen;
  wire [2:0]                       c0_ddr4_s_axi_arsize;
  wire [1:0]                       c0_ddr4_s_axi_arburst;
  wire [3:0]                       c0_ddr4_s_axi_arcache;
  wire                             c0_ddr4_s_axi_arvalid;
  wire                             c0_ddr4_s_axi_arready;
   // Slave Interface Read Data Ports
  wire                             c0_ddr4_s_axi_rready;
  wire [3:0]      c0_ddr4_s_axi_rid;
  wire [511:0]    c0_ddr4_s_axi_rdata;
  wire [1:0]                       c0_ddr4_s_axi_rresp;
  wire                             c0_ddr4_s_axi_rlast;
  wire                             c0_ddr4_s_axi_rvalid;

  wire                             c0_ddr4_cmp_data_valid;
  wire [511:0]    c0_ddr4_cmp_data;     // Compare data
  wire [511:0]    c0_ddr4_rdata_cmp;      // Read data

  wire                             c0_ddr4_dbg_wr_sts_vld;
  wire [DBG_WR_STS_WIDTH-1:0]      c0_ddr4_dbg_wr_sts;
  wire                             c0_ddr4_dbg_rd_sts_vld;
  wire [DBG_RD_STS_WIDTH-1:0]      c0_ddr4_dbg_rd_sts;
  assign c0_data_compare_error = c0_ddr4_data_msmatch_err | c0_ddr4_write_err | c0_ddr4_read_err;

  //HW TG VIO signals
  wire [3:0]                           vio_tg_status_state;
  wire                                 vio_tg_status_err_bit_valid;
  wire [APP_DATA_WIDTH-1:0]            vio_tg_status_err_bit;
  wire [31:0]                          vio_tg_status_err_cnt;
  wire [APP_ADDR_WIDTH-1:0]            vio_tg_status_err_addr;
  wire                                 vio_tg_status_exp_bit_valid;
  wire [APP_DATA_WIDTH-1:0]            vio_tg_status_exp_bit;
  wire                                 vio_tg_status_read_bit_valid;
  wire [APP_DATA_WIDTH-1:0]            vio_tg_status_read_bit;
  wire                                 vio_tg_status_first_err_bit_valid;

  wire [APP_DATA_WIDTH-1:0]            vio_tg_status_first_err_bit;
  wire [APP_ADDR_WIDTH-1:0]            vio_tg_status_first_err_addr;
  wire                                 vio_tg_status_first_exp_bit_valid;
  wire [APP_DATA_WIDTH-1:0]            vio_tg_status_first_exp_bit;
  wire                                 vio_tg_status_first_read_bit_valid;
  wire [APP_DATA_WIDTH-1:0]            vio_tg_status_first_read_bit;
  wire                                 vio_tg_status_err_bit_sticky_valid;
  wire [APP_DATA_WIDTH-1:0]            vio_tg_status_err_bit_sticky;
  wire [31:0]                          vio_tg_status_err_cnt_sticky;
  wire                                 vio_tg_status_err_type_valid;
  wire                                 vio_tg_status_err_type;
  wire                                 vio_tg_status_wr_done;
  wire                                 vio_tg_status_done;
  wire                                 vio_tg_status_watch_dog_hang;
  wire                                 tg_ila_debug;

  // Debug Bus
  wire [511:0]                         dbg_bus;        





wire c0_ddr4_reset_n_int;
  assign c0_ddr4_reset_n = c0_ddr4_reset_n_int;

//***************************************************************************
// The User design is instantiated below. The memory interface ports are
// connected to the top-level and the application interface ports are
// connected to the traffic generator module. This provides a reference
// for connecting the memory controller to system.
//***************************************************************************

  // user design top is one instance for all controllers
ddr4_0 u_ddr4_0
  (
   .sys_rst           (sys_rst),

   .c0_sys_clk_p                   (c0_sys_clk_p),
   .c0_sys_clk_n                   (c0_sys_clk_n),
   .c0_init_calib_complete (c0_init_calib_complete),
   .c0_ddr4_act_n          (c0_ddr4_act_n),
   .c0_ddr4_adr            (c0_ddr4_adr),
   .c0_ddr4_ba             (c0_ddr4_ba),
   .c0_ddr4_bg             (c0_ddr4_bg),
   .c0_ddr4_cke            (c0_ddr4_cke),
   .c0_ddr4_odt            (c0_ddr4_odt),
   .c0_ddr4_cs_n           (c0_ddr4_cs_n),
   .c0_ddr4_ck_t           (c0_ddr4_ck_t),
   .c0_ddr4_ck_c           (c0_ddr4_ck_c),
   .c0_ddr4_reset_n        (c0_ddr4_reset_n_int),

     .c0_ddr4_parity                        (c0_ddr4_parity),
   .c0_ddr4_dq             (c0_ddr4_dq),
   .c0_ddr4_dqs_c          (c0_ddr4_dqs_c),
   .c0_ddr4_dqs_t          (c0_ddr4_dqs_t),

   .c0_ddr4_ui_clk                (c0_ddr4_clk),
   .c0_ddr4_ui_clk_sync_rst       (c0_ddr4_rst),
   .addn_ui_clkout1                            (),
   .dbg_clk                                    (dbg_clk),
     // AXI CTRL port
     .c0_ddr4_s_axi_ctrl_awvalid       (1'b0),
     .c0_ddr4_s_axi_ctrl_awready       (),
     .c0_ddr4_s_axi_ctrl_awaddr        (32'b0),
     // Slave Interface Write Data Ports
     .c0_ddr4_s_axi_ctrl_wvalid        (1'b0),
     .c0_ddr4_s_axi_ctrl_wready        (),
     .c0_ddr4_s_axi_ctrl_wdata         (32'b0),
     // Slave Interface Write Response Ports
     .c0_ddr4_s_axi_ctrl_bvalid        (),
     .c0_ddr4_s_axi_ctrl_bready        (1'b1),
     .c0_ddr4_s_axi_ctrl_bresp         (),
     // Slave Interface Read Address Ports
     .c0_ddr4_s_axi_ctrl_arvalid       (1'b0),
     .c0_ddr4_s_axi_ctrl_arready       (),
     .c0_ddr4_s_axi_ctrl_araddr        (32'b0),
     // Slave Interface Read Data Ports
     .c0_ddr4_s_axi_ctrl_rvalid        (),
     .c0_ddr4_s_axi_ctrl_rready        (1'b1),
     .c0_ddr4_s_axi_ctrl_rdata         (),
     .c0_ddr4_s_axi_ctrl_rresp         (),
     // Interrupt output
     .c0_ddr4_interrupt                (),
  // Slave Interface Write Address Ports
  .c0_ddr4_aresetn                     (c0_ddr4_aresetn),
  .c0_ddr4_s_axi_awid                  (c0_ddr4_s_axi_awid),
  .c0_ddr4_s_axi_awaddr                (c0_ddr4_s_axi_awaddr),
  .c0_ddr4_s_axi_awlen                 (c0_ddr4_s_axi_awlen),
  .c0_ddr4_s_axi_awsize                (c0_ddr4_s_axi_awsize),
  .c0_ddr4_s_axi_awburst               (c0_ddr4_s_axi_awburst),
  .c0_ddr4_s_axi_awlock                (1'b0),
  .c0_ddr4_s_axi_awcache               (c0_ddr4_s_axi_awcache),
  .c0_ddr4_s_axi_awprot                (c0_ddr4_s_axi_awprot),
  .c0_ddr4_s_axi_awqos                 (4'b0),
  .c0_ddr4_s_axi_awvalid               (c0_ddr4_s_axi_awvalid),
  .c0_ddr4_s_axi_awready               (c0_ddr4_s_axi_awready),
  // Slave Interface Write Data Ports
  .c0_ddr4_s_axi_wdata                 (c0_ddr4_s_axi_wdata),
  .c0_ddr4_s_axi_wstrb                 (c0_ddr4_s_axi_wstrb),
  .c0_ddr4_s_axi_wlast                 (c0_ddr4_s_axi_wlast),
  .c0_ddr4_s_axi_wvalid                (c0_ddr4_s_axi_wvalid),
  .c0_ddr4_s_axi_wready                (c0_ddr4_s_axi_wready),
  // Slave Interface Write Response Ports
  .c0_ddr4_s_axi_bid                   (c0_ddr4_s_axi_bid),
  .c0_ddr4_s_axi_bresp                 (c0_ddr4_s_axi_bresp),
  .c0_ddr4_s_axi_bvalid                (c0_ddr4_s_axi_bvalid),
  .c0_ddr4_s_axi_bready                (c0_ddr4_s_axi_bready),
  // Slave Interface Read Address Ports
  .c0_ddr4_s_axi_arid                  (c0_ddr4_s_axi_arid),
  .c0_ddr4_s_axi_araddr                (c0_ddr4_s_axi_araddr),
  .c0_ddr4_s_axi_arlen                 (c0_ddr4_s_axi_arlen),
  .c0_ddr4_s_axi_arsize                (c0_ddr4_s_axi_arsize),
  .c0_ddr4_s_axi_arburst               (c0_ddr4_s_axi_arburst),
  .c0_ddr4_s_axi_arlock                (1'b0),
  .c0_ddr4_s_axi_arcache               (c0_ddr4_s_axi_arcache),
  .c0_ddr4_s_axi_arprot                (3'b0),
  .c0_ddr4_s_axi_arqos                 (4'b0),
  .c0_ddr4_s_axi_arvalid               (c0_ddr4_s_axi_arvalid),
  .c0_ddr4_s_axi_arready               (c0_ddr4_s_axi_arready),
  // Slave Interface Read Data Ports
  .c0_ddr4_s_axi_rid                   (c0_ddr4_s_axi_rid),
  .c0_ddr4_s_axi_rdata                 (c0_ddr4_s_axi_rdata),
  .c0_ddr4_s_axi_rresp                 (c0_ddr4_s_axi_rresp),
  .c0_ddr4_s_axi_rlast                 (c0_ddr4_s_axi_rlast),
  .c0_ddr4_s_axi_rvalid                (c0_ddr4_s_axi_rvalid),
  .c0_ddr4_s_axi_rready                (c0_ddr4_s_axi_rready),
  
  // Debug Port
  .dbg_bus         (dbg_bus)                                             

  );
   always @(posedge c0_ddr4_clk) begin
     c0_ddr4_aresetn <= ~c0_ddr4_rst;
   end



//***************************************************************************
// The AXI testbench module instantiated below drives traffic (patterns)
// on the application interface of the memory controller
//***************************************************************************

//ddr4_v2_2_8_axi4_tg #(
wire [31:0] prbs_mode_seed=32'hABCD_1234;

reg c0_init_calib_complete_r;
reg c0_init_calib_complete_r1;
reg c0_init_calib_complete_r2;
reg c0_init_calib_complete_r3;
always @(posedge c0_ddr4_clk) 
 begin
   if (c0_ddr4_rst) begin
     c0_init_calib_complete_r  <= 1'b0;   
     c0_init_calib_complete_r1 <= 1'b0;
     c0_init_calib_complete_r2 <= 1'b0;
     c0_init_calib_complete_r3 <= 1'b0;
   end
   else begin
   end
     c0_init_calib_complete_r  <= c0_init_calib_complete ;
     c0_init_calib_complete_r1 <= c0_init_calib_complete_r ;
     c0_init_calib_complete_r2 <= c0_init_calib_complete_r1 ;
     c0_init_calib_complete_r3 <= c0_init_calib_complete_r2 ;
 end

wire boot_mode_start;
wire boot_mode_done;
wire prbs_mode_done;
assign boot_mode_start = c0_init_calib_complete_r1 && ~c0_init_calib_complete_r3; //boot_mode_start needs to be a pulse
ddr4_v2_2_8_axi_tg_top #(
     .SIMULATION    (SIMULATION),
     .C_AXI_ID_WIDTH (C_AXI_ID_WIDTH),
     .C_AXI_ADDR_WIDTH (C_AXI_ADDR_WIDTH),
     .C_AXI_DATA_WIDTH (C_AXI_DATA_WIDTH),
     .C_AXI_NBURST_SUPPORT (C_AXI_NBURST_SUPPORT),
     .APP_DATA_WIDTH (APP_DATA_WIDTH),
     .ECC(ECC)
)
//u_ddr4_v2_2_8_axi4_tg (
u_ddr4_v2_2_8_axi_tg_top (
//  .aclk                        (c0_ddr4_clk),
//  .aresetn                     (c0_ddr4_aresetn),
//  // Input control signals
//  .init_cmptd                  (c0_init_calib_complete),
//  .init_test                   (1'b0),
//  .wdog_mask                   (~c0_init_calib_complete),
//  .wrap_en                     (1'b0),
//  // Slave Interface Write Address Ports
//  .axi_wready                  (c0_ddr4_s_axi_awready),
//  .axi_wid                     (c0_ddr4_s_axi_awid),
//  .axi_waddr                   (c0_ddr4_s_axi_awaddr),
//  .axi_wlen                    (c0_ddr4_s_axi_awlen),
//  .axi_wsize                   (c0_ddr4_s_axi_awsize),
//  .axi_wburst                  (c0_ddr4_s_axi_awburst),
//  .axi_wlock                   (),
//  .axi_wcache                  (c0_ddr4_s_axi_awcache),
//  .axi_wprot                   (c0_ddr4_s_axi_awprot),
//  .axi_wvalid                  (c0_ddr4_s_axi_awvalid),
//  // Slave Interface Write Data Ports
//  .axi_wd_wready               (c0_ddr4_s_axi_wready),
//  .axi_wd_wid                  (),
//  .axi_wd_data                 (c0_ddr4_s_axi_wdata),
//  .axi_wd_strb                 (c0_ddr4_s_axi_wstrb),
//  .axi_wd_last                 (c0_ddr4_s_axi_wlast),
//  .axi_wd_valid                (c0_ddr4_s_axi_wvalid),
//  // Slave Interface Write Response Ports
//  .axi_wd_bid                  (c0_ddr4_s_axi_bid),
//  .axi_wd_bresp                (c0_ddr4_s_axi_bresp),
//  .axi_wd_bvalid               (c0_ddr4_s_axi_bvalid),
//  .axi_wd_bready               (c0_ddr4_s_axi_bready),
//  // Slave Interface Read Address Ports
//  .axi_rready                  (c0_ddr4_s_axi_arready),
//  .axi_rid                     (c0_ddr4_s_axi_arid),
//  .axi_raddr                   (c0_ddr4_s_axi_araddr),
//  .axi_rlen                    (c0_ddr4_s_axi_arlen),
//  .axi_rsize                   (c0_ddr4_s_axi_arsize),
//  .axi_rburst                  (c0_ddr4_s_axi_arburst),
//  .axi_rlock                   (),
//  .axi_rcache                  (c0_ddr4_s_axi_arcache),
//  .axi_rprot                   (),
//  .axi_rvalid                  (c0_ddr4_s_axi_arvalid),
//  // Slave Interface Read Data Ports
//  .axi_rd_bid                  (c0_ddr4_s_axi_rid),
//  .axi_rd_rresp                (c0_ddr4_s_axi_rresp),
//  .axi_rd_rvalid               (c0_ddr4_s_axi_rvalid),
//  .axi_rd_data                 (c0_ddr4_s_axi_rdata),
//  .axi_rd_last                 (c0_ddr4_s_axi_rlast),
//  .axi_rd_rready               (c0_ddr4_s_axi_rready),
//
//  // Error status signals
//  .cmd_err                     (c0_ddr4_cmd_err),
//  .data_msmatch_err            (c0_ddr4_data_msmatch_err),
//  .write_err                   (c0_ddr4_write_err),
//  .read_err                    (c0_ddr4_read_err),
//  .test_cmptd                  (c0_ddr4_test_cmptd),
//  .write_cmptd                 (c0_ddr4_write_cmptd),
//  .read_cmptd                  (c0_ddr4_read_cmptd),
//  .cmptd_one_wr_rd             (c0_ddr4_cmptd_one_wr_rd),
//
//  // Debug status signals
//  .cmp_data_en                 (c0_ddr4_cmp_data_valid),
//  .cmp_data_o                  (c0_ddr4_cmp_data),
//  .rdata_cmp                   (c0_ddr4_rdata_cmp),
//  .dbg_wr_sts_vld              (c0_ddr4_dbg_wr_sts_vld),
//  .dbg_wr_sts                  (c0_ddr4_dbg_wr_sts),
//  .dbg_rd_sts_vld              (c0_ddr4_dbg_rd_sts_vld),
//  .dbg_rd_sts                  (c0_ddr4_dbg_rd_sts)
  .clk                             (c0_ddr4_clk),
  .tg_rst                          (c0_ddr4_rst),
  // Axi tg Input control signals
  .boot_mode_start                 ( boot_mode_start),
  .boot_mode_stop                  ( 1'b0),
  .boot_mode_done                  ( boot_mode_done),
  .custom_mode_start               ( 1'b0 ),
  .custom_mode_stop                ( 1'b0),
  .custom_mode_done                ( ),
  .prbs_mode_start                 ( boot_mode_done),
  .prbs_mode_stop                  ( 1'b0),
  .prbs_mode_done                  ( prbs_mode_done),
  .prbs_mode_seed                  ( prbs_mode_seed),
  // Slave Interface Write Address Ports
  .axi_awready                     (c0_ddr4_s_axi_awready),
  .axi_awid                        (c0_ddr4_s_axi_awid),
  .axi_awaddr                      (c0_ddr4_s_axi_awaddr),
  .axi_awlen                       (c0_ddr4_s_axi_awlen),
  .axi_awsize                      (c0_ddr4_s_axi_awsize),
  .axi_awburst                     (c0_ddr4_s_axi_awburst),
  .axi_awlock                      (),
  .axi_awcache                     (c0_ddr4_s_axi_awcache),
  .axi_awprot                      (c0_ddr4_s_axi_awprot),
  .axi_awvalid                     (c0_ddr4_s_axi_awvalid),
  // Slave Interface Write Data Ports
  .axi_wready                      (c0_ddr4_s_axi_wready),
  .axi_wdata                       (c0_ddr4_s_axi_wdata),
  .axi_wstrb                       (c0_ddr4_s_axi_wstrb),
  .axi_wlast                       (c0_ddr4_s_axi_wlast),
  .axi_wvalid                      (c0_ddr4_s_axi_wvalid),
  // Slave Interface Write Response Ports
  .axi_bid                         (c0_ddr4_s_axi_bid),
  .axi_bresp                       (c0_ddr4_s_axi_bresp),
  .axi_bvalid                      (c0_ddr4_s_axi_bvalid),
  .axi_bready                      (c0_ddr4_s_axi_bready),
  // Slave Interface Read Address Ports
  .axi_arready                     (c0_ddr4_s_axi_arready),
  .axi_arid                        (c0_ddr4_s_axi_arid),
  .axi_araddr                      (c0_ddr4_s_axi_araddr),
  .axi_arlen                       (c0_ddr4_s_axi_arlen),
  .axi_arsize                      (c0_ddr4_s_axi_arsize),
  .axi_arburst                     (c0_ddr4_s_axi_arburst),
  .axi_arlock                      (),
  .axi_arcache                     (c0_ddr4_s_axi_arcache),
  .axi_arprot                      (),
  .axi_arvalid                     (c0_ddr4_s_axi_arvalid),
  // Slave Interface Read Data Ports
  .axi_rid                         (c0_ddr4_s_axi_rid),
  .axi_rresp                       (c0_ddr4_s_axi_rresp),
  .axi_rvalid                      (c0_ddr4_s_axi_rvalid),
  .axi_rdata                       (c0_ddr4_s_axi_rdata),
  .axi_rlast                       (c0_ddr4_s_axi_rlast),
  .axi_rready                      (c0_ddr4_s_axi_rready),
  // Axi tg Error status signals
  .vio_axi_tg_mismatch_error       (c0_ddr4_data_msmatch_err),
  .vio_axi_tg_expected_bits        (),
  .vio_axi_tg_actual_bits          (),
  .vio_axi_tg_error_bits           (),
  .vio_axi_tg_data_beat_count      (),
  .vio_axi_tg_error_status_id      (),
  .vio_axi_tg_error_status_addr    (),
  .vio_axi_tg_error_status_len     (),
  .vio_axi_tg_error_status_size    (),
  .vio_axi_tg_error_status_burst   (),
  .vio_axi_tg_write_resp_error     (c0_ddr4_write_err),
  .vio_axi_tg_read_resp_error      (c0_ddr4_read_err),
  .vio_axi_tg_boot_mode_running    (),
  .vio_axi_tg_custom_mode_running  (),
  .vio_axi_tg_prbs_mode_running    (),
  .vio_axi_tg_dbg_instr_pointer    (),
  .vio_axi_tg_data_err_status_rdy  (c0_ddr4_tg_data_err_status_rdy),
  .vio_axi_tg_data_err_status      (c0_ddr4_tg_data_err_status)   
  );




`ifdef VIO_ATG_EN

`endif
endmodule





































