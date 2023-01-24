`timescale 1ps/1ps

module top
(
    input logic             sys_clk,
    input                   sys_rst, //Common port for all controllers
    
    // AXI-L interface to Host
    input  logic [31 : 0]    host_axil_awaddr,
    input  logic [2 : 0]     host_axil_awprot,
    input  logic [0 : 0]     host_axil_awvalid,
    output logic [0 : 0]     host_axil_awready,
    input  logic [31 : 0]    host_axil_wdata,
    input  logic [3 : 0]     host_axil_wstrb,
    input  logic [0 : 0]     host_axil_wvalid,
    input  logic [0 : 0]     host_axil_bready,
    input  logic [31 : 0]    host_axil_araddr,
    input  logic [2 : 0]     host_axil_arprot,
    input  logic [0 : 0]     host_axil_arvalid,
    input  logic [0 : 0]     host_axil_rready,
    output logic [0 : 0]     host_axil_wready,
    output logic [1 : 0]     host_axil_bresp,
    output logic [0 : 0]     host_axil_bvalid,
    output logic [0 : 0]     host_axil_arready,
    output logic [31 : 0]    host_axil_rdata,
    output logic [1 : 0]     host_axil_rresp,
    output logic [0 : 0]     host_axil_rvalid,
    
    // DDR4
    input                   c0_sys_clk_p,
    input                   c0_sys_clk_n,
    output                  c0_ddr4_act_n,
    output [16:0]           c0_ddr4_adr,
    output [1:0]            c0_ddr4_ba,
    output [1:0]            c0_ddr4_bg,
    output [0:0]            c0_ddr4_cke,
    output [0:0]            c0_ddr4_odt,
    output [0:0]            c0_ddr4_cs_n,
    output [0:0]            c0_ddr4_ck_t,
    output [0:0]            c0_ddr4_ck_c,
    output                  c0_ddr4_reset_n,
    output                  c0_ddr4_parity,
    inout  [71:0]           c0_ddr4_dq,
    inout  [17:0]           c0_ddr4_dqs_t,
    inout  [17:0]           c0_ddr4_dqs_c,
    
    output                  c0_init_calib_complete,
    output                  c0_data_compare_error
);

// ====================================================================================
// Declarations
// ====================================================================================

logic                             c0_ddr4_clk;
logic                             c0_ddr4_rst;
logic                             dbg_clk;
logic                             c0_ddr4_aresetn;

// AXI-L interface
logic [127 : 0]                   axil_interconnect_m_axi_awaddr;
logic [11 : 0]                    axil_interconnect_m_axi_awprot;
logic [3 : 0]                     axil_interconnect_m_axi_awvalid;
logic [3 : 0]                     axil_interconnect_m_axi_awready;
logic [127 : 0]                   axil_interconnect_m_axi_wdata;
logic [15 : 0]                    axil_interconnect_m_axi_wstrb;
logic [3 : 0]                     axil_interconnect_m_axi_wvalid;
logic [3 : 0]                     axil_interconnect_m_axi_wready;
logic [7 : 0]                     axil_interconnect_m_axi_bresp;
logic [3 : 0]                     axil_interconnect_m_axi_bvalid;
logic [3 : 0]                     axil_interconnect_m_axi_bready;
logic [127 : 0]                   axil_interconnect_m_axi_araddr;
logic [11 : 0]                    axil_interconnect_m_axi_arprot;
logic [3 : 0]                     axil_interconnect_m_axi_arvalid;
logic [3 : 0]                     axil_interconnect_m_axi_arready;
logic [127 : 0]                   axil_interconnect_m_axi_rdata;
logic [7 : 0]                     axil_interconnect_m_axi_rresp;
logic [3 : 0]                     axil_interconnect_m_axi_rvalid;
logic [3 : 0]                     axil_interconnect_m_axi_rready;

// AXI-L -> Aggregation Engine
logic [31 : 0]                    axil_interconnect_aggregation_engine_axi_awaddr;
logic [2 : 0]                     axil_interconnect_aggregation_engine_axi_awprot;
logic [0 : 0]                     axil_interconnect_aggregation_engine_axi_awvalid;
logic [0 : 0]                     axil_interconnect_aggregation_engine_axi_awready;
logic [31 : 0]                    axil_interconnect_aggregation_engine_axi_wdata;
logic [3 : 0]                     axil_interconnect_aggregation_engine_axi_wstrb;
logic [0 : 0]                     axil_interconnect_aggregation_engine_axi_wvalid;
logic [0 : 0]                     axil_interconnect_aggregation_engine_axi_wready;
logic [1 : 0]                     axil_interconnect_aggregation_engine_axi_bresp;
logic [0 : 0]                     axil_interconnect_aggregation_engine_axi_bvalid;
logic [0 : 0]                     axil_interconnect_aggregation_engine_axi_bready;
logic [31 : 0]                    axil_interconnect_aggregation_engine_axi_araddr;
logic [2 : 0]                     axil_interconnect_aggregation_engine_axi_arprot;
logic [0 : 0]                     axil_interconnect_aggregation_engine_axi_arvalid;
logic [0 : 0]                     axil_interconnect_aggregation_engine_axi_arready;
logic [31 : 0]                    axil_interconnect_aggregation_engine_axi_rdata;
logic [1 : 0]                     axil_interconnect_aggregation_engine_axi_rresp;
logic [0 : 0]                     axil_interconnect_aggregation_engine_axi_rvalid;
logic [0 : 0]                     axil_interconnect_aggregation_engine_axi_rready;

// AXI-L -> Transformation Engine
logic [31 : 0]                    axil_interconnect_transformation_engine_axi_awaddr;
logic [2 : 0]                     axil_interconnect_transformation_engine_axi_awprot;
logic [0 : 0]                     axil_interconnect_transformation_engine_axi_awvalid;
logic [0 : 0]                     axil_interconnect_transformation_engine_axi_awready;
logic [31 : 0]                    axil_interconnect_transformation_engine_axi_wdata;
logic [3 : 0]                     axil_interconnect_transformation_engine_axi_wstrb;
logic [0 : 0]                     axil_interconnect_transformation_engine_axi_wvalid;
logic [0 : 0]                     axil_interconnect_transformation_engine_axi_wready;
logic [1 : 0]                     axil_interconnect_transformation_engine_axi_bresp;
logic [0 : 0]                     axil_interconnect_transformation_engine_axi_bvalid;
logic [0 : 0]                     axil_interconnect_transformation_engine_axi_bready;
logic [31 : 0]                    axil_interconnect_transformation_engine_axi_araddr;
logic [2 : 0]                     axil_interconnect_transformation_engine_axi_arprot;
logic [0 : 0]                     axil_interconnect_transformation_engine_axi_arvalid;
logic [0 : 0]                     axil_interconnect_transformation_engine_axi_arready;
logic [31 : 0]                    axil_interconnect_transformation_engine_axi_rdata;
logic [1 : 0]                     axil_interconnect_transformation_engine_axi_rresp;
logic [0 : 0]                     axil_interconnect_transformation_engine_axi_rvalid;
logic [0 : 0]                     axil_interconnect_transformation_engine_axi_rready;

// AXI-L -> Message Passing Engine
logic [31 : 0]                    axil_interconnect_message_passing_engine_axi_awaddr;
logic [2 : 0]                     axil_interconnect_message_passing_engine_axi_awprot;
logic [0 : 0]                     axil_interconnect_message_passing_engine_axi_awvalid;
logic [0 : 0]                     axil_interconnect_message_passing_engine_axi_awready;
logic [31 : 0]                    axil_interconnect_message_passing_engine_axi_wdata;
logic [3 : 0]                     axil_interconnect_message_passing_engine_axi_wstrb;
logic [0 : 0]                     axil_interconnect_message_passing_engine_axi_wvalid;
logic [0 : 0]                     axil_interconnect_message_passing_engine_axi_wready;
logic [1 : 0]                     axil_interconnect_message_passing_engine_axi_bresp;
logic [0 : 0]                     axil_interconnect_message_passing_engine_axi_bvalid;
logic [0 : 0]                     axil_interconnect_message_passing_engine_axi_bready;
logic [31 : 0]                    axil_interconnect_message_passing_engine_axi_araddr;
logic [2 : 0]                     axil_interconnect_message_passing_engine_axi_arprot;
logic [0 : 0]                     axil_interconnect_message_passing_engine_axi_arvalid;
logic [0 : 0]                     axil_interconnect_message_passing_engine_axi_arready;
logic [31 : 0]                    axil_interconnect_message_passing_engine_axi_rdata;
logic [1 : 0]                     axil_interconnect_message_passing_engine_axi_rresp;
logic [0 : 0]                     axil_interconnect_message_passing_engine_axi_rvalid;
logic [0 : 0]                     axil_interconnect_message_passing_engine_axi_rready;

// AXI-L -> M3
logic [31 : 0]                    axil_interconnect_m3_axi_awaddr;
logic [2 : 0]                     axil_interconnect_m3_axi_awprot;
logic [0 : 0]                     axil_interconnect_m3_axi_awvalid;
logic [0 : 0]                     axil_interconnect_m3_axi_awready;
logic [31 : 0]                    axil_interconnect_m3_axi_wdata;
logic [3 : 0]                     axil_interconnect_m3_axi_wstrb;
logic [0 : 0]                     axil_interconnect_m3_axi_wvalid;
logic [0 : 0]                     axil_interconnect_m3_axi_wready;
logic [1 : 0]                     axil_interconnect_m3_axi_bresp;
logic [0 : 0]                     axil_interconnect_m3_axi_bvalid;
logic [0 : 0]                     axil_interconnect_m3_axi_bready;
logic [31 : 0]                    axil_interconnect_m3_axi_araddr;
logic [2 : 0]                     axil_interconnect_m3_axi_arprot;
logic [0 : 0]                     axil_interconnect_m3_axi_arvalid;
logic [0 : 0]                     axil_interconnect_m3_axi_arready;
logic [31 : 0]                    axil_interconnect_m3_axi_rdata;
logic [1 : 0]                     axil_interconnect_m3_axi_rresp;
logic [0 : 0]                     axil_interconnect_m3_axi_rvalid;
logic [0 : 0]                     axil_interconnect_m3_axi_rready;

// AXI Memory Interconnect -> DDR4
logic  [3:0]                       c0_ddr4_s_axi_awid;
logic  [33:0]                      c0_ddr4_s_axi_awaddr;
logic  [7:0]                       c0_ddr4_s_axi_awlen;
logic  [2:0]                       c0_ddr4_s_axi_awsize;
logic  [1:0]                       c0_ddr4_s_axi_awburst;
logic  [0:0]                       c0_ddr4_s_axi_awlock;
logic  [3:0]                       c0_ddr4_s_axi_awcache;
logic  [2:0]                       c0_ddr4_s_axi_awprot;
logic  [3:0]                       c0_ddr4_s_axi_awqos;
logic                              c0_ddr4_s_axi_awvalid;
logic                              c0_ddr4_s_axi_awready;
logic  [511:0]                     c0_ddr4_s_axi_wdata;
logic  [63:0]                      c0_ddr4_s_axi_wstrb;
logic                              c0_ddr4_s_axi_wlast;
logic                              c0_ddr4_s_axi_wvalid;
logic                              c0_ddr4_s_axi_wready;
logic                              c0_ddr4_s_axi_bready;
logic [3:0]                        c0_ddr4_s_axi_bid;
logic [1:0]                        c0_ddr4_s_axi_bresp;
logic                              c0_ddr4_s_axi_bvalid;
logic  [3:0]                       c0_ddr4_s_axi_arid;
logic  [33:0]                      c0_ddr4_s_axi_araddr;
logic  [7:0]                       c0_ddr4_s_axi_arlen;
logic  [2:0]                       c0_ddr4_s_axi_arsize;
logic  [1:0]                       c0_ddr4_s_axi_arburst;
logic  [0:0]                       c0_ddr4_s_axi_arlock;
logic  [3:0]                       c0_ddr4_s_axi_arcache;
logic  [2:0]                       c0_ddr4_s_axi_arprot;
logic  [3:0]                       c0_ddr4_s_axi_arqos;
logic                              c0_ddr4_s_axi_arvalid;
logic                              c0_ddr4_s_axi_arready;
logic                              c0_ddr4_s_axi_rready;
logic [3:0]                        c0_ddr4_s_axi_rid;
logic [511:0]                      c0_ddr4_s_axi_rdata;
logic [1:0]                        c0_ddr4_s_axi_rresp;
logic                              c0_ddr4_s_axi_rlast;
logic                              c0_ddr4_s_axi_rvalid;

// Debug Bus
logic [511:0]                         dbg_bus;

logic c0_ddr4_reset_n_int;

assign c0_ddr4_reset_n = c0_ddr4_reset_n_int;

// Aggregation Engine -> AXI Memory Interconnect
logic [33:0]                       aggregation_engine_axi_interconnect_axi_araddr;
logic [1:0]                        aggregation_engine_axi_interconnect_axi_arburst;
logic [3:0]                        aggregation_engine_axi_interconnect_axi_arcache;
logic [3:0]                        aggregation_engine_axi_interconnect_axi_arid;
logic [7:0]                        aggregation_engine_axi_interconnect_axi_arlen;
logic [0:0]                        aggregation_engine_axi_interconnect_axi_arlock;
logic [2:0]                        aggregation_engine_axi_interconnect_axi_arprot;
logic [3:0]                        aggregation_engine_axi_interconnect_axi_arqos;
logic [2:0]                        aggregation_engine_axi_interconnect_axi_arsize;
logic                              aggregation_engine_axi_interconnect_axi_arvalid;
logic                              aggregation_engine_axi_interconnect_axi_arready;
logic [33:0]                       aggregation_engine_axi_interconnect_axi_awaddr;
logic [1:0]                        aggregation_engine_axi_interconnect_axi_awburst;
logic [3:0]                        aggregation_engine_axi_interconnect_axi_awcache;
logic [3:0]                        aggregation_engine_axi_interconnect_axi_awid;
logic [7:0]                        aggregation_engine_axi_interconnect_axi_awlen;
logic [0:0]                        aggregation_engine_axi_interconnect_axi_awlock;
logic [2:0]                        aggregation_engine_axi_interconnect_axi_awprot;
logic [3:0]                        aggregation_engine_axi_interconnect_axi_awqos;
logic                              aggregation_engine_axi_interconnect_axi_awready;
logic [2:0]                        aggregation_engine_axi_interconnect_axi_awsize;
logic                              aggregation_engine_axi_interconnect_axi_awvalid;
logic [3:0]                        aggregation_engine_axi_interconnect_axi_bid;
logic                              aggregation_engine_axi_interconnect_axi_bready;
logic [1:0]                        aggregation_engine_axi_interconnect_axi_bresp;
logic                              aggregation_engine_axi_interconnect_axi_bvalid;
logic [511:0]                      aggregation_engine_axi_interconnect_axi_rdata;
logic [3:0]                        aggregation_engine_axi_interconnect_axi_rid;
logic                              aggregation_engine_axi_interconnect_axi_rlast;
logic                              aggregation_engine_axi_interconnect_axi_rready;
logic [1:0]                        aggregation_engine_axi_interconnect_axi_rresp;
logic                              aggregation_engine_axi_interconnect_axi_rvalid;
logic [511:0]                      aggregation_engine_axi_interconnect_axi_wdata;
logic                              aggregation_engine_axi_interconnect_axi_wlast;
logic                              aggregation_engine_axi_interconnect_axi_wready;
logic [63:0]                       aggregation_engine_axi_interconnect_axi_wstrb;
logic                              aggregation_engine_axi_interconnect_axi_wvalid;

// Transformation Engine -> AXI Memory Interconnect
logic [33:0]                       transformation_engine_axi_interconnect_axi_araddr;
logic [1:0]                        transformation_engine_axi_interconnect_axi_arburst;
logic [3:0]                        transformation_engine_axi_interconnect_axi_arcache;
logic [3:0]                        transformation_engine_axi_interconnect_axi_arid;
logic [7:0]                        transformation_engine_axi_interconnect_axi_arlen;
logic [0:0]                        transformation_engine_axi_interconnect_axi_arlock;
logic [2:0]                        transformation_engine_axi_interconnect_axi_arprot;
logic [3:0]                        transformation_engine_axi_interconnect_axi_arqos;
logic [2:0]                        transformation_engine_axi_interconnect_axi_arsize;
logic                              transformation_engine_axi_interconnect_axi_arvalid;
logic                              transformation_engine_axi_interconnect_axi_arready;
logic [33:0]                       transformation_engine_axi_interconnect_axi_awaddr;
logic [1:0]                        transformation_engine_axi_interconnect_axi_awburst;
logic [3:0]                        transformation_engine_axi_interconnect_axi_awcache;
logic [3:0]                        transformation_engine_axi_interconnect_axi_awid;
logic [7:0]                        transformation_engine_axi_interconnect_axi_awlen;
logic [0:0]                        transformation_engine_axi_interconnect_axi_awlock;
logic [2:0]                        transformation_engine_axi_interconnect_axi_awprot;
logic [3:0]                        transformation_engine_axi_interconnect_axi_awqos;
logic                              transformation_engine_axi_interconnect_axi_awready;
logic [2:0]                        transformation_engine_axi_interconnect_axi_awsize;
logic                              transformation_engine_axi_interconnect_axi_awvalid;
logic [3:0]                        transformation_engine_axi_interconnect_axi_bid;
logic                              transformation_engine_axi_interconnect_axi_bready;
logic [1:0]                        transformation_engine_axi_interconnect_axi_bresp;
logic                              transformation_engine_axi_interconnect_axi_bvalid;
logic [511:0]                      transformation_engine_axi_interconnect_axi_rdata;
logic [3:0]                        transformation_engine_axi_interconnect_axi_rid;
logic                              transformation_engine_axi_interconnect_axi_rlast;
logic                              transformation_engine_axi_interconnect_axi_rready;
logic [1:0]                        transformation_engine_axi_interconnect_axi_rresp;
logic                              transformation_engine_axi_interconnect_axi_rvalid;
logic [511:0]                      transformation_engine_axi_interconnect_axi_wdata;
logic                              transformation_engine_axi_interconnect_axi_wlast;
logic                              transformation_engine_axi_interconnect_axi_wready;
logic [63:0]                       transformation_engine_axi_interconnect_axi_wstrb;
logic                              transformation_engine_axi_interconnect_axi_wvalid;

// ====================================================================================
// Aggregation Engine
// ====================================================================================

fc_base_aggregation_engine fc_base_aggregation_engine_i (
    .core_clk                           (sys_clk),
    .resetn                             (!sys_rst),
    
    // Regbank Slave AXI interface
    .s_axi_awaddr                       (axil_interconnect_m_axi_awaddr     [31:0]),
    .s_axi_awprot                       (axil_interconnect_m_axi_awprot     [2:0]),
    .s_axi_awvalid                      (axil_interconnect_m_axi_awvalid    [0]),
    .s_axi_awready                      (axil_interconnect_m_axi_awready    [0]),
    .s_axi_wdata                        (axil_interconnect_m_axi_wdata      [31:0]),
    .s_axi_wstrb                        (axil_interconnect_m_axi_wstrb      [3:0]),
    .s_axi_wvalid                       (axil_interconnect_m_axi_wvalid     [0]),
    .s_axi_wready                       (axil_interconnect_m_axi_wready     [0]),
    .s_axi_bresp                        (axil_interconnect_m_axi_bresp      [1:0]),
    .s_axi_bvalid                       (axil_interconnect_m_axi_bvalid     [0]),
    .s_axi_bready                       (axil_interconnect_m_axi_bready     [0]),
    .s_axi_araddr                       (axil_interconnect_m_axi_araddr     [31:0]),
    .s_axi_arprot                       (axil_interconnect_m_axi_arprot     [2:0]),
    .s_axi_arvalid                      (axil_interconnect_m_axi_arvalid    [0]),
    .s_axi_arready                      (axil_interconnect_m_axi_arready    [0]),
    .s_axi_rdata                        (axil_interconnect_m_axi_rdata      [31:0]),
    .s_axi_rresp                        (axil_interconnect_m_axi_rresp      [1:0]),
    .s_axi_rvalid                       (axil_interconnect_m_axi_rvalid     [0]),
    .s_axi_rready                       (axil_interconnect_m_axi_rready     [0]),

    // Master AXI interface (to DRAM controller)
    .m_axi_araddr                           (aggregation_engine_axi_interconnect_axi_araddr),
    .m_axi_arburst                          (aggregation_engine_axi_interconnect_axi_arburst),
    .m_axi_arcache                          (aggregation_engine_axi_interconnect_axi_arcache),
    .m_axi_arid                             (aggregation_engine_axi_interconnect_axi_arid),
    .m_axi_arlen                            (aggregation_engine_axi_interconnect_axi_arlen),
    .m_axi_arlock                           (aggregation_engine_axi_interconnect_axi_arlock),
    .m_axi_arprot                           (aggregation_engine_axi_interconnect_axi_arprot),
    .m_axi_arqos                            (aggregation_engine_axi_interconnect_axi_arqos),
    .m_axi_arsize                           (aggregation_engine_axi_interconnect_axi_arsize),
    .m_axi_arvalid                          (aggregation_engine_axi_interconnect_axi_arvalid),
    .m_axi_arready                          (aggregation_engine_axi_interconnect_axi_arready),
    .m_axi_awaddr                           (aggregation_engine_axi_interconnect_axi_awaddr),
    .m_axi_awburst                          (aggregation_engine_axi_interconnect_axi_awburst),
    .m_axi_awcache                          (aggregation_engine_axi_interconnect_axi_awcache),
    .m_axi_awid                             (aggregation_engine_axi_interconnect_axi_awid),
    .m_axi_awlen                            (aggregation_engine_axi_interconnect_axi_awlen),
    .m_axi_awlock                           (aggregation_engine_axi_interconnect_axi_awlock),
    .m_axi_awprot                           (aggregation_engine_axi_interconnect_axi_awprot),
    .m_axi_awqos                            (aggregation_engine_axi_interconnect_axi_awqos),
    .m_axi_awready                          (aggregation_engine_axi_interconnect_axi_awready),
    .m_axi_awsize                           (aggregation_engine_axi_interconnect_axi_awsize),
    .m_axi_awvalid                          (aggregation_engine_axi_interconnect_axi_awvalid),
    .m_axi_bid                              (aggregation_engine_axi_interconnect_axi_bid),
    .m_axi_bready                           (aggregation_engine_axi_interconnect_axi_bready),
    .m_axi_bresp                            (aggregation_engine_axi_interconnect_axi_bresp),
    .m_axi_bvalid                           (aggregation_engine_axi_interconnect_axi_bvalid),
    .m_axi_rdata                            (aggregation_engine_axi_interconnect_axi_rdata),
    .m_axi_rid                              (aggregation_engine_axi_interconnect_axi_rid),
    .m_axi_rlast                            (aggregation_engine_axi_interconnect_axi_rlast),
    .m_axi_rready                           (aggregation_engine_axi_interconnect_axi_rready),
    .m_axi_rresp                            (aggregation_engine_axi_interconnect_axi_rresp),
    .m_axi_rvalid                           (aggregation_engine_axi_interconnect_axi_rvalid),
    .m_axi_wdata                            (aggregation_engine_axi_interconnect_axi_wdata),
    .m_axi_wlast                            (aggregation_engine_axi_interconnect_axi_wlast),
    .m_axi_wready                           (aggregation_engine_axi_interconnect_axi_wready),
    .m_axi_wstrb                            (aggregation_engine_axi_interconnect_axi_wstrb),
    .m_axi_wvalid                           (aggregation_engine_axi_interconnect_axi_wvalid),

    .c0_init_calib_complete                 (c0_init_calib_complete)

);


// ====================================================================================
// Transformation Engine
// ====================================================================================

fc_base_transformation_engine fc_base_transformation_engine_i (
    .core_clk                                           (sys_clk),
    .resetn                                             (!sys_rst),

    // AXI-L interface
    .s_axi_awaddr                                       (axil_interconnect_m_axi_awaddr     [63:32]), // input
    .s_axi_awprot                                       (axil_interconnect_m_axi_awprot     [5:3]), // input
    .s_axi_awvalid                                      (axil_interconnect_m_axi_awvalid    [1]), // input
    .s_axi_awready                                      (axil_interconnect_m_axi_awready    [1]), // output
    .s_axi_wdata                                        (axil_interconnect_m_axi_wdata      [63:32]), // input
    .s_axi_wstrb                                        (axil_interconnect_m_axi_wstrb      [7:4]), // input
    .s_axi_wvalid                                       (axil_interconnect_m_axi_wvalid     [1]), // input
    .s_axi_wready                                       (axil_interconnect_m_axi_wready     [1]), // output
    .s_axi_araddr                                       (axil_interconnect_m_axi_bresp      [3:2]), // input
    .s_axi_arprot                                       (axil_interconnect_m_axi_bvalid     [1]), // input
    .s_axi_arvalid                                      (axil_interconnect_m_axi_bready     [1]), // input
    .s_axi_arready                                      (axil_interconnect_m_axi_araddr     [63:32]), // output
    .s_axi_rdata                                        (axil_interconnect_m_axi_arprot     [5:3]), // output
    .s_axi_rresp                                        (axil_interconnect_m_axi_arvalid    [1]), // output
    .s_axi_rvalid                                       (axil_interconnect_m_axi_arready    [1]), // output
    .s_axi_rready                                       (axil_interconnect_m_axi_rdata      [63:32]), // input
    .s_axi_bresp                                        (axil_interconnect_m_axi_rresp      [3:2]), // output
    .s_axi_bvalid                                       (axil_interconnect_m_axi_rvalid     [1]), // output
    .s_axi_bready                                       (axil_interconnect_m_axi_rready     [1]), // input

    .m_axi_araddr                                       (transformation_engine_axi_interconnect_axi_araddr),
    .m_axi_arburst                                      (transformation_engine_axi_interconnect_axi_arburst),
    .m_axi_arcache                                      (transformation_engine_axi_interconnect_axi_arcache),
    .m_axi_arid                                         (transformation_engine_axi_interconnect_axi_arid),
    .m_axi_arlen                                        (transformation_engine_axi_interconnect_axi_arlen),
    .m_axi_arlock                                       (transformation_engine_axi_interconnect_axi_arlock),
    .m_axi_arprot                                       (transformation_engine_axi_interconnect_axi_arprot),
    .m_axi_arqos                                        (transformation_engine_axi_interconnect_axi_arqos),
    .m_axi_arsize                                       (transformation_engine_axi_interconnect_axi_arsize),
    .m_axi_arvalid                                      (transformation_engine_axi_interconnect_axi_arvalid),
    .m_axi_arready                                      (transformation_engine_axi_interconnect_axi_arready),
    .m_axi_awaddr                                       (transformation_engine_axi_interconnect_axi_awaddr),
    .m_axi_awburst                                      (transformation_engine_axi_interconnect_axi_awburst),
    .m_axi_awcache                                      (transformation_engine_axi_interconnect_axi_awcache),
    .m_axi_awid                                         (transformation_engine_axi_interconnect_axi_awid),
    .m_axi_awlen                                        (transformation_engine_axi_interconnect_axi_awlen),
    .m_axi_awlock                                       (transformation_engine_axi_interconnect_axi_awlock),
    .m_axi_awprot                                       (transformation_engine_axi_interconnect_axi_awprot),
    .m_axi_awqos                                        (transformation_engine_axi_interconnect_axi_awqos),
    .m_axi_awready                                      (transformation_engine_axi_interconnect_axi_awready),
    .m_axi_awsize                                       (transformation_engine_axi_interconnect_axi_awsize),
    .m_axi_awvalid                                      (transformation_engine_axi_interconnect_axi_awvalid),
    .m_axi_bid                                          (transformation_engine_axi_interconnect_axi_bid),
    .m_axi_bready                                       (transformation_engine_axi_interconnect_axi_bready),
    .m_axi_bresp                                        (transformation_engine_axi_interconnect_axi_bresp),
    .m_axi_bvalid                                       (transformation_engine_axi_interconnect_axi_bvalid),
    .m_axi_rdata                                        (transformation_engine_axi_interconnect_axi_rdata),
    .m_axi_rid                                          (transformation_engine_axi_interconnect_axi_rid),
    .m_axi_rlast                                        (transformation_engine_axi_interconnect_axi_rlast),
    .m_axi_rready                                       (transformation_engine_axi_interconnect_axi_rready),
    .m_axi_rresp                                        (transformation_engine_axi_interconnect_axi_rresp),
    .m_axi_rvalid                                       (transformation_engine_axi_interconnect_axi_rvalid),
    .m_axi_wdata                                        (transformation_engine_axi_interconnect_axi_wdata),
    .m_axi_wlast                                        (transformation_engine_axi_interconnect_axi_wlast),
    .m_axi_wready                                       (transformation_engine_axi_interconnect_axi_wready),
    .m_axi_wstrb                                        (transformation_engine_axi_interconnect_axi_wstrb),
    .m_axi_wvalid                                       (transformation_engine_axi_interconnect_axi_wvalid)
);

// ====================================================================================
// AXI-L Register Control Crossbar
// ====================================================================================

axi_L_register_control_crossbar axi_L_register_control_crossbar_i (
  .aclk                                 (sys_clk),                    // input wire aclk
  .aresetn                              (!sys_rst),              // input wire aresetn

  .s_axi_awaddr                         (host_axil_awaddr),    // input wire [31 : 0] s_axi_awaddr
  .s_axi_awprot                         (host_axil_awprot),    // input wire [2 : 0] s_axi_awprot
  .s_axi_awvalid                        (host_axil_awvalid),  // input wire [0 : 0] s_axi_awvalid
  .s_axi_awready                        (host_axil_awready),  // output wire [0 : 0] s_axi_awready
  .s_axi_wdata                          (host_axil_wdata),      // input wire [31 : 0] s_axi_wdata
  .s_axi_wstrb                          (host_axil_wstrb),      // input wire [3 : 0] s_axi_wstrb
  .s_axi_wvalid                         (host_axil_wvalid),    // input wire [0 : 0] s_axi_wvalid
  .s_axi_wready                         (host_axil_wready),    // output wire [0 : 0] s_axi_wready
  .s_axi_bresp                          (host_axil_bresp),      // output wire [1 : 0] s_axi_bresp
  .s_axi_bvalid                         (host_axil_bvalid),    // output wire [0 : 0] s_axi_bvalid
  .s_axi_bready                         (host_axil_bready),    // input wire [0 : 0] s_axi_bready
  .s_axi_araddr                         (host_axil_araddr),    // input wire [31 : 0] s_axi_araddr
  .s_axi_arprot                         (host_axil_arprot),    // input wire [2 : 0] s_axi_arprot
  .s_axi_arvalid                        (host_axil_arvalid),  // input wire [0 : 0] s_axi_arvalid
  .s_axi_arready                        (host_axil_arready),  // output wire [0 : 0] s_axi_arready
  .s_axi_rdata                          (host_axil_rdata),      // output wire [31 : 0] s_axi_rdata
  .s_axi_rresp                          (host_axil_rresp),      // output wire [1 : 0] s_axi_rresp
  .s_axi_rvalid                         (host_axil_rvalid),    // output wire [0 : 0] s_axi_rvalid
  .s_axi_rready                         (host_axil_rready),    // input wire [0 : 0] s_axi_rready

  .m_axi_awaddr                         (axil_interconnect_m_axi_awaddr),    // output wire [127 : 0] m_axi_awaddr
  .m_axi_awprot                         (axil_interconnect_m_axi_awprot),    // output wire [11 : 0] m_axi_awprot
  .m_axi_awvalid                        (axil_interconnect_m_axi_awvalid),  // output wire [3 : 0] m_axi_awvalid
  .m_axi_awready                        (axil_interconnect_m_axi_awready),  // input wire [3 : 0] m_axi_awready
  .m_axi_wdata                          (axil_interconnect_m_axi_wdata),      // output wire [127 : 0] m_axi_wdata
  .m_axi_wstrb                          (axil_interconnect_m_axi_wstrb),      // output wire [15 : 0] m_axi_wstrb
  .m_axi_wvalid                         (axil_interconnect_m_axi_wvalid),    // output wire [3 : 0] m_axi_wvalid
  .m_axi_wready                         (axil_interconnect_m_axi_wready),    // input wire [3 : 0] m_axi_wready
  .m_axi_bresp                          (axil_interconnect_m_axi_bresp),      // input wire [7 : 0] m_axi_bresp
  .m_axi_bvalid                         (axil_interconnect_m_axi_bvalid),    // input wire [3 : 0] m_axi_bvalid
  .m_axi_bready                         (axil_interconnect_m_axi_bready),    // output wire [3 : 0] m_axi_bready
  .m_axi_araddr                         (axil_interconnect_m_axi_araddr),    // output wire [127 : 0] m_axi_araddr
  .m_axi_arprot                         (axil_interconnect_m_axi_arprot),    // output wire [11 : 0] m_axi_arprot
  .m_axi_arvalid                        (axil_interconnect_m_axi_arvalid),  // output wire [3 : 0] m_axi_arvalid
  .m_axi_arready                        (axil_interconnect_m_axi_arready),  // input wire [3 : 0] m_axi_arready
  .m_axi_rdata                          (axil_interconnect_m_axi_rdata),      // input wire [127 : 0] m_axi_rdata
  .m_axi_rresp                          (axil_interconnect_m_axi_rresp),      // input wire [7 : 0] m_axi_rresp
  .m_axi_rvalid                         (axil_interconnect_m_axi_rvalid),    // input wire [3 : 0] m_axi_rvalid
  .m_axi_rready                         (axil_interconnect_m_axi_rready)    // output wire [3 : 0] m_axi_rready
);

// ====================================================================================
// AXI Memory Interconnect
// ====================================================================================

axi_memory_interconnect axi_memory_interconnect_i (
  .INTERCONNECT_ACLK            (sys_clk),        // input wire INTERCONNECT_ACLK
  .INTERCONNECT_ARESETN         (!sys_rst),  // input wire INTERCONNECT_ARESETN

  .S00_AXI_ACLK                 (sys_clk),                  // input wire S00_AXI_ACLK
  .S00_AXI_ARESET_OUT_N         (),  // output wire S00_AXI_ARESET_OUT_N
  
  .S00_AXI_ARADDR               (aggregation_engine_axi_interconnect_axi_araddr     ),              // input wire [33 : 0] S00_AXI_ARADDR
  .S00_AXI_ARBURST              (aggregation_engine_axi_interconnect_axi_arburst        ),            // input wire [1 : 0] S00_AXI_ARBURST
  .S00_AXI_ARCACHE              (aggregation_engine_axi_interconnect_axi_arcache        ),            // input wire [3 : 0] S00_AXI_ARCACHE
  .S00_AXI_ARID                 (aggregation_engine_axi_interconnect_axi_arid       ),                  // input wire [0 : 0] S00_AXI_ARID
  .S00_AXI_ARLEN                (aggregation_engine_axi_interconnect_axi_arlen      ),                // input wire [7 : 0] S00_AXI_ARLEN
  .S00_AXI_ARLOCK               (aggregation_engine_axi_interconnect_axi_arlock     ),                               // input wire S00_AXI_ARLOCK
  .S00_AXI_ARPROT               (aggregation_engine_axi_interconnect_axi_arprot     ),                               // input wire [2 : 0] S00_AXI_ARPROT
  .S00_AXI_ARQOS                (aggregation_engine_axi_interconnect_axi_arqos      ),                               // input wire [3 : 0] S00_AXI_ARQOS
  .S00_AXI_ARSIZE               (aggregation_engine_axi_interconnect_axi_arsize     ),              // input wire [2 : 0] S00_AXI_ARSIZE
  .S00_AXI_ARVALID              (aggregation_engine_axi_interconnect_axi_arvalid        ),            // input wire S00_AXI_ARVALID
  .S00_AXI_ARREADY              (aggregation_engine_axi_interconnect_axi_arready        ),            // output wire S00_AXI_ARREADY
  .S00_AXI_AWADDR               (aggregation_engine_axi_interconnect_axi_awaddr     ),              // input wire [33 : 0] S00_AXI_AWADDR
  .S00_AXI_AWBURST              (aggregation_engine_axi_interconnect_axi_awburst        ),            // input wire [1 : 0] S00_AXI_AWBURST
  .S00_AXI_AWCACHE              (aggregation_engine_axi_interconnect_axi_awcache        ),            // input wire [3 : 0] S00_AXI_AWCACHE
  .S00_AXI_AWID                 (aggregation_engine_axi_interconnect_axi_awid       ),                  // input wire [0 : 0] S00_AXI_AWID
  .S00_AXI_AWLEN                (aggregation_engine_axi_interconnect_axi_awlen      ),                // input wire [7 : 0] S00_AXI_AWLEN
  .S00_AXI_AWLOCK               (aggregation_engine_axi_interconnect_axi_awlock     ),                               // input wire S00_AXI_AWLOCK
  .S00_AXI_AWPROT               (aggregation_engine_axi_interconnect_axi_awprot     ),              // input wire [2 : 0] S00_AXI_AWPROT
  .S00_AXI_AWQOS                (aggregation_engine_axi_interconnect_axi_awqos      ),                               // input wire [3 : 0] S00_AXI_AWQOS
  .S00_AXI_AWREADY              (aggregation_engine_axi_interconnect_axi_awready        ),            // output wire S00_AXI_AWREADY
  .S00_AXI_AWSIZE               (aggregation_engine_axi_interconnect_axi_awsize     ),              // input wire [2 : 0] S00_AXI_AWSIZE
  .S00_AXI_AWVALID              (aggregation_engine_axi_interconnect_axi_awvalid        ),            // input wire S00_AXI_AWVALID
  .S00_AXI_BID                  (aggregation_engine_axi_interconnect_axi_bid        ),                    // output wire [0 : 0] S00_AXI_BID
  .S00_AXI_BREADY               (aggregation_engine_axi_interconnect_axi_bready     ),              // input wire S00_AXI_BREADY
  .S00_AXI_BRESP                (aggregation_engine_axi_interconnect_axi_bresp      ),                // output wire [1 : 0] S00_AXI_BRESP
  .S00_AXI_BVALID               (aggregation_engine_axi_interconnect_axi_bvalid     ),              // output wire S00_AXI_BVALID
  .S00_AXI_RDATA                (aggregation_engine_axi_interconnect_axi_rdata      ),                // output wire [511 : 0] S00_AXI_RDATA
  .S00_AXI_RID                  (aggregation_engine_axi_interconnect_axi_rid        ),                    // output wire [0 : 0] S00_AXI_RID
  .S00_AXI_RLAST                (aggregation_engine_axi_interconnect_axi_rlast      ),                // output wire S00_AXI_RLAST
  .S00_AXI_RREADY               (aggregation_engine_axi_interconnect_axi_rready     ),              // input wire S00_AXI_RREADY
  .S00_AXI_RRESP                (aggregation_engine_axi_interconnect_axi_rresp      ),                // output wire [1 : 0] S00_AXI_RRESP
  .S00_AXI_RVALID               (aggregation_engine_axi_interconnect_axi_rvalid     ),              // output wire S00_AXI_RVALID
  .S00_AXI_WDATA                (aggregation_engine_axi_interconnect_axi_wdata      ),                // input wire [511 : 0] S00_AXI_WDATA
  .S00_AXI_WLAST                (aggregation_engine_axi_interconnect_axi_wlast      ),                // input wire S00_AXI_WLAST
  .S00_AXI_WREADY               (aggregation_engine_axi_interconnect_axi_wready     ),              // output wire S00_AXI_WREADY
  .S00_AXI_WSTRB                (aggregation_engine_axi_interconnect_axi_wstrb      ),                // input wire [63 : 0] S00_AXI_WSTRB
  .S00_AXI_WVALID               (aggregation_engine_axi_interconnect_axi_wvalid     ),              // input wire S00_AXI_WVALID

  .S01_AXI_ACLK                 (sys_clk),                  // input wire S01_AXI_ACLK
  .S01_AXI_ARESET_OUT_N         (),  // output wire S01_AXI_ARESET_OUT_N
  
  .S01_AXI_AWID                 (transformation_engine_axi_interconnect_axi_awid),                  // input wire [0 : 0] S01_AXI_AWID
  .S01_AXI_AWADDR               (transformation_engine_axi_interconnect_axi_awaddr),              // input wire [33 : 0] S01_AXI_AWADDR
  .S01_AXI_AWLEN                (transformation_engine_axi_interconnect_axi_awlen),                // input wire [7 : 0] S01_AXI_AWLEN
  .S01_AXI_AWSIZE               (transformation_engine_axi_interconnect_axi_awsize),              // input wire [2 : 0] S01_AXI_AWSIZE
  .S01_AXI_AWBURST              (transformation_engine_axi_interconnect_axi_awburst),            // input wire [1 : 0] S01_AXI_AWBURST
  .S01_AXI_AWLOCK               (transformation_engine_axi_interconnect_axi_awlock),              // input wire S01_AXI_AWLOCK
  .S01_AXI_AWCACHE              (transformation_engine_axi_interconnect_axi_awcache),            // input wire [3 : 0] S01_AXI_AWCACHE
  .S01_AXI_AWPROT               (transformation_engine_axi_interconnect_axi_awprot),              // input wire [2 : 0] S01_AXI_AWPROT
  .S01_AXI_AWQOS                (transformation_engine_axi_interconnect_axi_awqos),                // input wire [3 : 0] S01_AXI_AWQOS
  .S01_AXI_AWVALID              (transformation_engine_axi_interconnect_axi_awvalid),            // input wire S01_AXI_AWVALID
  .S01_AXI_AWREADY              (transformation_engine_axi_interconnect_axi_awready),            // output wire S01_AXI_AWREADY
  .S01_AXI_WDATA                (transformation_engine_axi_interconnect_axi_wdata),                // input wire [511 : 0] S01_AXI_WDATA
  .S01_AXI_WSTRB                (transformation_engine_axi_interconnect_axi_wstrb),                // input wire [63 : 0] S01_AXI_WSTRB
  .S01_AXI_WLAST                (transformation_engine_axi_interconnect_axi_wlast),                // input wire S01_AXI_WLAST
  .S01_AXI_WVALID               (transformation_engine_axi_interconnect_axi_wvalid),              // input wire S01_AXI_WVALID
  .S01_AXI_WREADY               (transformation_engine_axi_interconnect_axi_wready),              // output wire S01_AXI_WREADY
  .S01_AXI_BID                  (transformation_engine_axi_interconnect_axi_bid),                    // output wire [0 : 0] S01_AXI_BID
  .S01_AXI_BRESP                (transformation_engine_axi_interconnect_axi_bresp),                // output wire [1 : 0] S01_AXI_BRESP
  .S01_AXI_BVALID               (transformation_engine_axi_interconnect_axi_bvalid),              // output wire S01_AXI_BVALID
  .S01_AXI_BREADY               (transformation_engine_axi_interconnect_axi_bready),              // input wire S01_AXI_BREADY
  .S01_AXI_ARID                 (transformation_engine_axi_interconnect_axi_arid),                  // input wire [0 : 0] S01_AXI_ARID
  .S01_AXI_ARADDR               (transformation_engine_axi_interconnect_axi_araddr),              // input wire [33 : 0] S01_AXI_ARADDR
  .S01_AXI_ARLEN                (transformation_engine_axi_interconnect_axi_arlen),                // input wire [7 : 0] S01_AXI_ARLEN
  .S01_AXI_ARSIZE               (transformation_engine_axi_interconnect_axi_arsize),              // input wire [2 : 0] S01_AXI_ARSIZE
  .S01_AXI_ARBURST              (transformation_engine_axi_interconnect_axi_arburst),            // input wire [1 : 0] S01_AXI_ARBURST
  .S01_AXI_ARLOCK               (transformation_engine_axi_interconnect_axi_arlock),              // input wire S01_AXI_ARLOCK
  .S01_AXI_ARCACHE              (transformation_engine_axi_interconnect_axi_arcache),            // input wire [3 : 0] S01_AXI_ARCACHE
  .S01_AXI_ARPROT               (transformation_engine_axi_interconnect_axi_arprot),              // input wire [2 : 0] S01_AXI_ARPROT
  .S01_AXI_ARQOS                (transformation_engine_axi_interconnect_axi_arqos),                // input wire [3 : 0] S01_AXI_ARQOS
  .S01_AXI_ARVALID              (transformation_engine_axi_interconnect_axi_arvalid),            // input wire S01_AXI_ARVALID
  .S01_AXI_ARREADY              (transformation_engine_axi_interconnect_axi_arready),            // output wire S01_AXI_ARREADY
  .S01_AXI_RID                  (transformation_engine_axi_interconnect_axi_rid),                    // output wire [0 : 0] S01_AXI_RID
  .S01_AXI_RDATA                (transformation_engine_axi_interconnect_axi_rdata),                // output wire [511 : 0] S01_AXI_RDATA
  .S01_AXI_RRESP                (transformation_engine_axi_interconnect_axi_rresp),                // output wire [1 : 0] S01_AXI_RRESP
  .S01_AXI_RLAST                (transformation_engine_axi_interconnect_axi_rlast),                // output wire S01_AXI_RLAST
  .S01_AXI_RVALID               (transformation_engine_axi_interconnect_axi_rvalid),              // output wire S01_AXI_RVALID
  .S01_AXI_RREADY               (transformation_engine_axi_interconnect_axi_rready),              // input wire S01_AXI_RREADY
  
  .S02_AXI_ACLK                 ('0),                  // input wire S02_AXI_ACLK
  .S02_AXI_ARESET_OUT_N         (),  // output wire S02_AXI_ARESET_OUT_N
  .S02_AXI_AWID                 ('0),                  // input wire [0 : 0] S02_AXI_AWID
  .S02_AXI_AWADDR               ('0),              // input wire [33 : 0] S02_AXI_AWADDR
  .S02_AXI_AWLEN                ('0),                // input wire [7 : 0] S02_AXI_AWLEN
  .S02_AXI_AWSIZE               ('0),              // input wire [2 : 0] S02_AXI_AWSIZE
  .S02_AXI_AWBURST              ('0),            // input wire [1 : 0] S02_AXI_AWBURST
  .S02_AXI_AWLOCK               ('0),              // input wire S02_AXI_AWLOCK
  .S02_AXI_AWCACHE              ('0),            // input wire [3 : 0] S02_AXI_AWCACHE
  .S02_AXI_AWPROT               ('0),              // input wire [2 : 0] S02_AXI_AWPROT
  .S02_AXI_AWQOS                ('0),                // input wire [3 : 0] S02_AXI_AWQOS
  .S02_AXI_AWVALID              ('0),            // input wire S02_AXI_AWVALID
  .S02_AXI_AWREADY              (),            // output wire S02_AXI_AWREADY
  .S02_AXI_WDATA                ('0),                // input wire [511 : 0] S02_AXI_WDATA
  .S02_AXI_WSTRB                ('0),                // input wire [63 : 0] S02_AXI_WSTRB
  .S02_AXI_WLAST                ('0),                // input wire S02_AXI_WLAST
  .S02_AXI_WVALID               ('0),              // input wire S02_AXI_WVALID
  .S02_AXI_WREADY               (),              // output wire S02_AXI_WREADY
  .S02_AXI_BID                  (),                    // output wire [0 : 0] S02_AXI_BID
  .S02_AXI_BRESP                (),                // output wire [1 : 0] S02_AXI_BRESP
  .S02_AXI_BVALID               (),              // output wire S02_AXI_BVALID
  .S02_AXI_BREADY               ('0),              // input wire S02_AXI_BREADY
  .S02_AXI_ARID                 ('0),                  // input wire [0 : 0] S02_AXI_ARID
  .S02_AXI_ARADDR               ('0),              // input wire [33 : 0] S02_AXI_ARADDR
  .S02_AXI_ARLEN                ('0),                // input wire [7 : 0] S02_AXI_ARLEN
  .S02_AXI_ARSIZE               ('0),              // input wire [2 : 0] S02_AXI_ARSIZE
  .S02_AXI_ARBURST              ('0),            // input wire [1 : 0] S02_AXI_ARBURST
  .S02_AXI_ARLOCK               ('0),              // input wire S02_AXI_ARLOCK
  .S02_AXI_ARCACHE              ('0),            // input wire [3 : 0] S02_AXI_ARCACHE
  .S02_AXI_ARPROT               ('0),              // input wire [2 : 0] S02_AXI_ARPROT
  .S02_AXI_ARQOS                ('0),                // input wire [3 : 0] S02_AXI_ARQOS
  .S02_AXI_ARVALID              ('0),            // input wire S02_AXI_ARVALID
  .S02_AXI_ARREADY              (),            // output wire S02_AXI_ARREADY
  .S02_AXI_RID                  (),                    // output wire [0 : 0] S02_AXI_RID
  .S02_AXI_RDATA                (),                // output wire [511 : 0] S02_AXI_RDATA
  .S02_AXI_RRESP                (),                // output wire [1 : 0] S02_AXI_RRESP
  .S02_AXI_RLAST                (),                // output wire S02_AXI_RLAST
  .S02_AXI_RVALID               (),              // output wire S02_AXI_RVALID
  .S02_AXI_RREADY               ('0),              // input wire S02_AXI_RREADY
  
  .S03_AXI_ACLK                 ('0),                  // input wire S03_AXI_ACLK
  .S03_AXI_ARESET_OUT_N         (),  // output wire S03_AXI_ARESET_OUT_N
  .S03_AXI_AWID                 ('0),                  // input wire [0 : 0] S03_AXI_AWID
  .S03_AXI_AWADDR               ('0),              // input wire [33 : 0] S03_AXI_AWADDR
  .S03_AXI_AWLEN                ('0),                // input wire [7 : 0] S03_AXI_AWLEN
  .S03_AXI_AWSIZE               ('0),              // input wire [2 : 0] S03_AXI_AWSIZE
  .S03_AXI_AWBURST              ('0),            // input wire [1 : 0] S03_AXI_AWBURST
  .S03_AXI_AWLOCK               ('0),              // input wire S03_AXI_AWLOCK
  .S03_AXI_AWCACHE              ('0),            // input wire [3 : 0] S03_AXI_AWCACHE
  .S03_AXI_AWPROT               ('0),              // input wire [2 : 0] S03_AXI_AWPROT
  .S03_AXI_AWQOS                ('0),                // input wire [3 : 0] S03_AXI_AWQOS
  .S03_AXI_AWVALID              ('0),            // input wire S03_AXI_AWVALID
  .S03_AXI_AWREADY              (),            // output wire S03_AXI_AWREADY
  .S03_AXI_WDATA                ('0),                // input wire [511 : 0] S03_AXI_WDATA
  .S03_AXI_WSTRB                ('0),                // input wire [63 : 0] S03_AXI_WSTRB
  .S03_AXI_WLAST                ('0),                // input wire S03_AXI_WLAST
  .S03_AXI_WVALID               ('0),              // input wire S03_AXI_WVALID
  .S03_AXI_WREADY               (),              // output wire S03_AXI_WREADY
  .S03_AXI_BID                  (),                    // output wire [0 : 0] S03_AXI_BID
  .S03_AXI_BRESP                (),                // output wire [1 : 0] S03_AXI_BRESP
  .S03_AXI_BVALID               (),              // output wire S03_AXI_BVALID
  .S03_AXI_BREADY               ('0),              // input wire S03_AXI_BREADY
  .S03_AXI_ARID                 ('0),                  // input wire [0 : 0] S03_AXI_ARID
  .S03_AXI_ARADDR               ('0),              // input wire [33 : 0] S03_AXI_ARADDR
  .S03_AXI_ARLEN                ('0),                // input wire [7 : 0] S03_AXI_ARLEN
  .S03_AXI_ARSIZE               ('0),              // input wire [2 : 0] S03_AXI_ARSIZE
  .S03_AXI_ARBURST              ('0),            // input wire [1 : 0] S03_AXI_ARBURST
  .S03_AXI_ARLOCK               ('0),              // input wire S03_AXI_ARLOCK
  .S03_AXI_ARCACHE              ('0),            // input wire [3 : 0] S03_AXI_ARCACHE
  .S03_AXI_ARPROT               ('0),              // input wire [2 : 0] S03_AXI_ARPROT
  .S03_AXI_ARQOS                ('0),                // input wire [3 : 0] S03_AXI_ARQOS
  .S03_AXI_ARVALID              ('0),            // input wire S03_AXI_ARVALID
  .S03_AXI_ARREADY              (),            // output wire S03_AXI_ARREADY
  .S03_AXI_RID                  (),                    // output wire [0 : 0] S03_AXI_RID
  .S03_AXI_RDATA                (),                // output wire [511 : 0] S03_AXI_RDATA
  .S03_AXI_RRESP                (),                // output wire [1 : 0] S03_AXI_RRESP
  .S03_AXI_RLAST                (),                // output wire S03_AXI_RLAST
  .S03_AXI_RVALID               (),              // output wire S03_AXI_RVALID
  .S03_AXI_RREADY               ('0),              // input wire S03_AXI_RREADY
  
  .M00_AXI_ACLK                 (sys_clk),                  // input wire M00_AXI_ACLK
  .M00_AXI_ARESET_OUT_N         (),  // output wire M00_AXI_ARESET_OUT_N

  .M00_AXI_AWID                 (c0_ddr4_s_axi_awid),                  // output wire [3 : 0] M00_AXI_AWID
  .M00_AXI_AWADDR               (c0_ddr4_s_axi_awaddr),              // output wire [33 : 0] M00_AXI_AWADDR
  .M00_AXI_AWLEN                (c0_ddr4_s_axi_awlen),                // output wire [7 : 0] M00_AXI_AWLEN
  .M00_AXI_AWSIZE               (c0_ddr4_s_axi_awsize),              // output wire [2 : 0] M00_AXI_AWSIZE
  .M00_AXI_AWBURST              (c0_ddr4_s_axi_awburst),            // output wire [1 : 0] M00_AXI_AWBURST
  .M00_AXI_AWLOCK               (c0_ddr4_s_axi_awlock),              // output wire M00_AXI_AWLOCK
  .M00_AXI_AWCACHE              (c0_ddr4_s_axi_awcache),            // output wire [3 : 0] M00_AXI_AWCACHE
  .M00_AXI_AWPROT               (c0_ddr4_s_axi_awprot),              // output wire [2 : 0] M00_AXI_AWPROT
  .M00_AXI_AWQOS                (c0_ddr4_s_axi_awqos),                // output wire [3 : 0] M00_AXI_AWQOS
  .M00_AXI_AWVALID              (c0_ddr4_s_axi_awvalid),            // output wire M00_AXI_AWVALID
  .M00_AXI_AWREADY              (c0_ddr4_s_axi_awready),            // input wire M00_AXI_AWREADY
  .M00_AXI_WDATA                (c0_ddr4_s_axi_wdata),                // output wire [511 : 0] M00_AXI_WDATA
  .M00_AXI_WSTRB                (c0_ddr4_s_axi_wstrb),                // output wire [63 : 0] M00_AXI_WSTRB
  .M00_AXI_WLAST                (c0_ddr4_s_axi_wlast),                // output wire M00_AXI_WLAST
  .M00_AXI_WVALID               (c0_ddr4_s_axi_wvalid),              // output wire M00_AXI_WVALID
  .M00_AXI_WREADY               (c0_ddr4_s_axi_wready),              // input wire M00_AXI_WREADY
  .M00_AXI_BREADY               (c0_ddr4_s_axi_bready),              // output wire M00_AXI_BREADY
  .M00_AXI_BID                  (c0_ddr4_s_axi_bid),                    // input wire [3 : 0] M00_AXI_BID
  .M00_AXI_BRESP                (c0_ddr4_s_axi_bresp),                // input wire [1 : 0] M00_AXI_BRESP
  .M00_AXI_BVALID               (c0_ddr4_s_axi_bvalid),              // input wire M00_AXI_BVALID
  .M00_AXI_ARID                 (c0_ddr4_s_axi_arid),                  // output wire [3 : 0] M00_AXI_ARID
  .M00_AXI_ARADDR               (c0_ddr4_s_axi_araddr),              // output wire [33 : 0] M00_AXI_ARADDR
  .M00_AXI_ARLEN                (c0_ddr4_s_axi_arlen),                // output wire [7 : 0] M00_AXI_ARLEN
  .M00_AXI_ARSIZE               (c0_ddr4_s_axi_arsize),              // output wire [2 : 0] M00_AXI_ARSIZE
  .M00_AXI_ARBURST              (c0_ddr4_s_axi_arburst),            // output wire [1 : 0] M00_AXI_ARBURST
  .M00_AXI_ARLOCK               (c0_ddr4_s_axi_arlock),              // output wire M00_AXI_ARLOCK
  .M00_AXI_ARCACHE              (c0_ddr4_s_axi_arcache),            // output wire [3 : 0] M00_AXI_ARCACHE
  .M00_AXI_ARPROT               (c0_ddr4_s_axi_arprot),              // output wire [2 : 0] M00_AXI_ARPROT
  .M00_AXI_ARQOS                (c0_ddr4_s_axi_arqos),                // output wire [3 : 0] M00_AXI_ARQOS
  .M00_AXI_ARVALID              (c0_ddr4_s_axi_arvalid),            // output wire M00_AXI_ARVALID
  .M00_AXI_ARREADY              (c0_ddr4_s_axi_arready),            // input wire M00_AXI_ARREADY
  .M00_AXI_RREADY               (c0_ddr4_s_axi_rready),              // output wire M00_AXI_RREADY
  .M00_AXI_RID                  (c0_ddr4_s_axi_rid),                    // input wire [3 : 0] M00_AXI_RID
  .M00_AXI_RDATA                (c0_ddr4_s_axi_rdata),                // input wire [511 : 0] M00_AXI_RDATA
  .M00_AXI_RRESP                (c0_ddr4_s_axi_rresp),                // input wire [1 : 0] M00_AXI_RRESP
  .M00_AXI_RLAST                (c0_ddr4_s_axi_rlast),                // input wire M00_AXI_RLAST
  .M00_AXI_RVALID               (c0_ddr4_s_axi_rvalid)              // input wire M00_AXI_RVALID
);

// ====================================================================================
// DDR4 Controller
// ====================================================================================

ddr4_0 u_ddr4_0
(
    .sys_rst                          (sys_rst),

    .c0_sys_clk_p                     (c0_sys_clk_p),
    .c0_sys_clk_n                     (c0_sys_clk_n),
    .c0_init_calib_complete           (c0_init_calib_complete),
    .c0_ddr4_act_n                    (c0_ddr4_act_n),
    .c0_ddr4_adr                      (c0_ddr4_adr),
    .c0_ddr4_ba                       (c0_ddr4_ba),
    .c0_ddr4_bg                       (c0_ddr4_bg),
    .c0_ddr4_cke                      (c0_ddr4_cke),
    .c0_ddr4_odt                      (c0_ddr4_odt),
    .c0_ddr4_cs_n                     (c0_ddr4_cs_n),
    .c0_ddr4_ck_t                     (c0_ddr4_ck_t),
    .c0_ddr4_ck_c                     (c0_ddr4_ck_c),
    .c0_ddr4_reset_n                  (c0_ddr4_reset_n_int),

    .c0_ddr4_parity                   (c0_ddr4_parity),
    .c0_ddr4_dq                       (c0_ddr4_dq),
    .c0_ddr4_dqs_c                    (c0_ddr4_dqs_c),
    .c0_ddr4_dqs_t                    (c0_ddr4_dqs_t),

    .c0_ddr4_ui_clk                   (c0_ddr4_clk),
    .c0_ddr4_ui_clk_sync_rst          (c0_ddr4_rst),
    .addn_ui_clkout1                  (),
    .dbg_clk                          (dbg_clk),

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


    // Slave Interface AXI ports
    .c0_ddr4_aresetn                     (c0_ddr4_aresetn),
    .c0_ddr4_s_axi_awid                  (c0_ddr4_s_axi_awid),
    .c0_ddr4_s_axi_awaddr                (c0_ddr4_s_axi_awaddr),
    .c0_ddr4_s_axi_awlen                 (c0_ddr4_s_axi_awlen),
    .c0_ddr4_s_axi_awsize                (c0_ddr4_s_axi_awsize),
    .c0_ddr4_s_axi_awburst               (c0_ddr4_s_axi_awburst),
    .c0_ddr4_s_axi_awlock                (c0_ddr4_s_axi_awlock),
    .c0_ddr4_s_axi_awcache               (c0_ddr4_s_axi_awcache),
    .c0_ddr4_s_axi_awprot                (c0_ddr4_s_axi_awprot),
    .c0_ddr4_s_axi_awqos                 (c0_ddr4_s_axi_awqos),
    .c0_ddr4_s_axi_awvalid               (c0_ddr4_s_axi_awvalid),
    .c0_ddr4_s_axi_awready               (c0_ddr4_s_axi_awready),
    .c0_ddr4_s_axi_wdata                 (c0_ddr4_s_axi_wdata),
    .c0_ddr4_s_axi_wstrb                 (c0_ddr4_s_axi_wstrb),
    .c0_ddr4_s_axi_wlast                 (c0_ddr4_s_axi_wlast),
    .c0_ddr4_s_axi_wvalid                (c0_ddr4_s_axi_wvalid),
    .c0_ddr4_s_axi_wready                (c0_ddr4_s_axi_wready),
    .c0_ddr4_s_axi_bid                   (c0_ddr4_s_axi_bid),
    .c0_ddr4_s_axi_bresp                 (c0_ddr4_s_axi_bresp),
    .c0_ddr4_s_axi_bvalid                (c0_ddr4_s_axi_bvalid),
    .c0_ddr4_s_axi_bready                (c0_ddr4_s_axi_bready),
    .c0_ddr4_s_axi_arid                  (c0_ddr4_s_axi_arid),
    .c0_ddr4_s_axi_araddr                (c0_ddr4_s_axi_araddr),
    .c0_ddr4_s_axi_arlen                 (c0_ddr4_s_axi_arlen),
    .c0_ddr4_s_axi_arsize                (c0_ddr4_s_axi_arsize),
    .c0_ddr4_s_axi_arburst               (c0_ddr4_s_axi_arburst),
    .c0_ddr4_s_axi_arlock                (c0_ddr4_s_axi_arlock),
    .c0_ddr4_s_axi_arcache               (c0_ddr4_s_axi_arcache),
    .c0_ddr4_s_axi_arprot                (c0_ddr4_s_axi_arprot),
    .c0_ddr4_s_axi_arqos                 (c0_ddr4_s_axi_arqos),
    .c0_ddr4_s_axi_arvalid               (c0_ddr4_s_axi_arvalid),
    .c0_ddr4_s_axi_arready               (c0_ddr4_s_axi_arready),
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

endmodule