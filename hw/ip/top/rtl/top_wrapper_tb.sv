`timescale 1ns/100ps

import top_pkg::*;

module top_wrapper_tb
(
    input logic                           sys_clk,
    input logic                           sys_rst, //Common port for all controllers

    input  logic                          regbank_clk,
    input  logic                          regbank_resetn,
    
    // AXI-L interface to Host
    input  logic [0 : 0]                  host_axil_awvalid,
    output logic [0 : 0]                  host_axil_awready,
    input  logic [31 : 0]                 host_axil_awaddr,
    input  logic [2 : 0]                  host_axil_awprot,

    input  logic [0 : 0]                  host_axil_wvalid,
    output logic [0 : 0]                  host_axil_wready,
    input  logic [31 : 0]                 host_axil_wdata,
    input  logic [3 : 0]                  host_axil_wstrb,

    output logic [0 : 0]                  host_axil_bvalid,
    input  logic [0 : 0]                  host_axil_bready,
    output logic [1 : 0]                  host_axil_bresp,

    input  logic [0 : 0]                  host_axil_arvalid,
    output logic [0 : 0]                  host_axil_arready,
    input  logic [31 : 0]                 host_axil_araddr,
    input  logic [2 : 0]                  host_axil_arprot,

    output logic [0 : 0]                  host_axil_rvalid,
    input  logic [0 : 0]                  host_axil_rready,
    output logic [31 : 0]                 host_axil_rdata,
    output logic [1 : 0]                  host_axil_rresp
);

// ====================================================================================
// Declarations
// ====================================================================================

// AXI Memory Interconnect -> Memory (Routed to DRAM Controller if `DRAM_CONTROLLER defined)
logic  [7:0]                   c0_ddr4_s_axi_awid;
logic  [33:0]                  c0_ddr4_s_axi_awaddr;
logic  [7:0]                   c0_ddr4_s_axi_awlen;
logic  [2:0]                   c0_ddr4_s_axi_awsize;
logic  [1:0]                   c0_ddr4_s_axi_awburst;
logic  [0:0]                   c0_ddr4_s_axi_awlock;
logic  [3:0]                   c0_ddr4_s_axi_awcache;
logic  [2:0]                   c0_ddr4_s_axi_awprot;
logic  [3:0]                   c0_ddr4_s_axi_awqos;
logic                          c0_ddr4_s_axi_awvalid;
logic                          c0_ddr4_s_axi_awready;
logic  [511:0]                 c0_ddr4_s_axi_wdata;
logic  [63:0]                  c0_ddr4_s_axi_wstrb;
logic                          c0_ddr4_s_axi_wlast;
logic                          c0_ddr4_s_axi_wvalid;
logic                          c0_ddr4_s_axi_wready;
logic [7:0]                    c0_ddr4_s_axi_bid;
logic [1:0]                    c0_ddr4_s_axi_bresp;
logic                          c0_ddr4_s_axi_bvalid;
logic                          c0_ddr4_s_axi_bready;
logic  [7:0]                   c0_ddr4_s_axi_arid;
logic  [33:0]                  c0_ddr4_s_axi_araddr;
logic  [7:0]                   c0_ddr4_s_axi_arlen;
logic  [2:0]                   c0_ddr4_s_axi_arsize;
logic  [1:0]                   c0_ddr4_s_axi_arburst;
logic  [0:0]                   c0_ddr4_s_axi_arlock;
logic  [3:0]                   c0_ddr4_s_axi_arcache;
logic  [2:0]                   c0_ddr4_s_axi_arprot;
logic  [3:0]                   c0_ddr4_s_axi_arqos;
logic                          c0_ddr4_s_axi_arvalid;
logic                          c0_ddr4_s_axi_arready;
logic [7:0]                    c0_ddr4_s_axi_rid;
logic [511:0]                  c0_ddr4_s_axi_rdata;
logic [1:0]                    c0_ddr4_s_axi_rresp;
logic                          c0_ddr4_s_axi_rlast;
logic                          c0_ddr4_s_axi_rvalid;
logic                          c0_ddr4_s_axi_rready;

// ====================================================================================
// Instances
// ====================================================================================

top top_i
(
    .sys_clk                                   (sys_clk),
    .sys_rst                                   (sys_rst),

    .regbank_clk                               (regbank_clk),
    .regbank_resetn                            (regbank_resetn),

    .host_axil_awvalid                         (host_axil_awvalid),
    .host_axil_awready                         (host_axil_awready),
    .host_axil_awaddr                          (host_axil_awaddr),
    .host_axil_awprot                          (host_axil_awprot),
    .host_axil_wvalid                          (host_axil_wvalid),
    .host_axil_wready                          (host_axil_wready),
    .host_axil_wdata                           (host_axil_wdata),
    .host_axil_wstrb                           (host_axil_wstrb),
    .host_axil_bvalid                          (host_axil_bvalid),
    .host_axil_bready                          (host_axil_bready),
    .host_axil_bresp                           (host_axil_bresp),
    .host_axil_arvalid                         (host_axil_arvalid),
    .host_axil_arready                         (host_axil_arready),
    .host_axil_araddr                          (host_axil_araddr),
    .host_axil_arprot                          (host_axil_arprot),
    .host_axil_rvalid                          (host_axil_rvalid),
    .host_axil_rready                          (host_axil_rready),
    .host_axil_rdata                           (host_axil_rdata),
    .host_axil_rresp                           (host_axil_rresp),

    .c0_ddr4_s_axi_awid                        (c0_ddr4_s_axi_awid),
    .c0_ddr4_s_axi_awaddr                      (c0_ddr4_s_axi_awaddr),
    .c0_ddr4_s_axi_awlen                       (c0_ddr4_s_axi_awlen),
    .c0_ddr4_s_axi_awsize                      (c0_ddr4_s_axi_awsize),
    .c0_ddr4_s_axi_awburst                     (c0_ddr4_s_axi_awburst),
    .c0_ddr4_s_axi_awlock                      (c0_ddr4_s_axi_awlock),
    .c0_ddr4_s_axi_awcache                     (c0_ddr4_s_axi_awcache),
    .c0_ddr4_s_axi_awprot                      (c0_ddr4_s_axi_awprot),
    .c0_ddr4_s_axi_awqos                       (c0_ddr4_s_axi_awqos),
    .c0_ddr4_s_axi_awvalid                     (c0_ddr4_s_axi_awvalid),
    .c0_ddr4_s_axi_awready                     (c0_ddr4_s_axi_awready),
    .c0_ddr4_s_axi_wdata                       (c0_ddr4_s_axi_wdata),
    .c0_ddr4_s_axi_wstrb                       (c0_ddr4_s_axi_wstrb),
    .c0_ddr4_s_axi_wlast                       (c0_ddr4_s_axi_wlast),
    .c0_ddr4_s_axi_wvalid                      (c0_ddr4_s_axi_wvalid),
    .c0_ddr4_s_axi_wready                      (c0_ddr4_s_axi_wready),
    .c0_ddr4_s_axi_bid                         (c0_ddr4_s_axi_bid),
    .c0_ddr4_s_axi_bresp                       (c0_ddr4_s_axi_bresp),
    .c0_ddr4_s_axi_bvalid                      (c0_ddr4_s_axi_bvalid),
    .c0_ddr4_s_axi_bready                      (c0_ddr4_s_axi_bready),
    .c0_ddr4_s_axi_arid                        (c0_ddr4_s_axi_arid),
    .c0_ddr4_s_axi_araddr                      (c0_ddr4_s_axi_araddr),
    .c0_ddr4_s_axi_arlen                       (c0_ddr4_s_axi_arlen),
    .c0_ddr4_s_axi_arsize                      (c0_ddr4_s_axi_arsize),
    .c0_ddr4_s_axi_arburst                     (c0_ddr4_s_axi_arburst),
    .c0_ddr4_s_axi_arlock                      (c0_ddr4_s_axi_arlock),
    .c0_ddr4_s_axi_arcache                     (c0_ddr4_s_axi_arcache),
    .c0_ddr4_s_axi_arprot                      (c0_ddr4_s_axi_arprot),
    .c0_ddr4_s_axi_arqos                       (c0_ddr4_s_axi_arqos),
    .c0_ddr4_s_axi_arvalid                     (c0_ddr4_s_axi_arvalid),
    .c0_ddr4_s_axi_arready                     (c0_ddr4_s_axi_arready),
    .c0_ddr4_s_axi_rid                         (c0_ddr4_s_axi_rid),
    .c0_ddr4_s_axi_rdata                       (c0_ddr4_s_axi_rdata),
    .c0_ddr4_s_axi_rresp                       (c0_ddr4_s_axi_rresp),
    .c0_ddr4_s_axi_rlast                       (c0_ddr4_s_axi_rlast),
    .c0_ddr4_s_axi_rvalid                      (c0_ddr4_s_axi_rvalid),
    .c0_ddr4_s_axi_rready                      (c0_ddr4_s_axi_rready)
);

axi_ram #(
    .DATA_WIDTH(512),
    .ADDR_WIDTH(34),
    .ID_WIDTH(8)
) ram_model (
    .clk                    (sys_clk),
    .rst                    (sys_rst),

    .s_axi_awid             (c0_ddr4_s_axi_awid),
    .s_axi_awaddr           (c0_ddr4_s_axi_awaddr),
    .s_axi_awlen            (c0_ddr4_s_axi_awlen),
    .s_axi_awsize           (c0_ddr4_s_axi_awsize),
    .s_axi_awburst          (c0_ddr4_s_axi_awburst),
    .s_axi_awlock           (c0_ddr4_s_axi_awlock),
    .s_axi_awcache          (c0_ddr4_s_axi_awcache),
    .s_axi_awprot           (c0_ddr4_s_axi_awprot),
    .s_axi_awvalid          (c0_ddr4_s_axi_awvalid),
    .s_axi_awready          (c0_ddr4_s_axi_awready),
    .s_axi_wdata            (c0_ddr4_s_axi_wdata),
    .s_axi_wstrb            (c0_ddr4_s_axi_wstrb),
    .s_axi_wlast            (c0_ddr4_s_axi_wlast),
    .s_axi_wvalid           (c0_ddr4_s_axi_wvalid),
    .s_axi_wready           (c0_ddr4_s_axi_wready),
    .s_axi_bid              (c0_ddr4_s_axi_bid),
    .s_axi_bresp            (c0_ddr4_s_axi_bresp),
    .s_axi_bvalid           (c0_ddr4_s_axi_bvalid),
    .s_axi_bready           (c0_ddr4_s_axi_bready),
    .s_axi_arid             (c0_ddr4_s_axi_arid),
    .s_axi_araddr           (c0_ddr4_s_axi_araddr),
    .s_axi_arlen            (c0_ddr4_s_axi_arlen),
    .s_axi_arsize           (c0_ddr4_s_axi_arsize),
    .s_axi_arburst          (c0_ddr4_s_axi_arburst),
    .s_axi_arlock           (c0_ddr4_s_axi_arlock),
    .s_axi_arcache          (c0_ddr4_s_axi_arcache),
    .s_axi_arprot           (c0_ddr4_s_axi_arprot),
    .s_axi_arvalid          (c0_ddr4_s_axi_arvalid),
    .s_axi_arready          (c0_ddr4_s_axi_arready),
    .s_axi_rid              (c0_ddr4_s_axi_rid),
    .s_axi_rdata            (c0_ddr4_s_axi_rdata),
    .s_axi_rresp            (c0_ddr4_s_axi_rresp),
    .s_axi_rlast            (c0_ddr4_s_axi_rlast),
    .s_axi_rvalid           (c0_ddr4_s_axi_rvalid),
    .s_axi_rready           (c0_ddr4_s_axi_rready)
);

endmodule