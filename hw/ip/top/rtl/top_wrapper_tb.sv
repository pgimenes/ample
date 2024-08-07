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

// Prefetcher Read Masters -> HBM
logic [HBM_BANKS-1:0]  [7:0]                   read_master_axi_awid;
logic [HBM_BANKS-1:0]  [33:0]                  read_master_axi_awaddr;
logic [HBM_BANKS-1:0]  [7:0]                   read_master_axi_awlen;
logic [HBM_BANKS-1:0]  [2:0]                   read_master_axi_awsize;
logic [HBM_BANKS-1:0]  [1:0]                   read_master_axi_awburst;
logic [HBM_BANKS-1:0]  [0:0]                   read_master_axi_awlock;
logic [HBM_BANKS-1:0]  [3:0]                   read_master_axi_awcache;
logic [HBM_BANKS-1:0]  [2:0]                   read_master_axi_awprot;
logic [HBM_BANKS-1:0]  [3:0]                   read_master_axi_awqos;
logic [HBM_BANKS-1:0]                          read_master_axi_awvalid;
logic [HBM_BANKS-1:0]                          read_master_axi_awready;
logic [HBM_BANKS-1:0]  [511:0]                 read_master_axi_wdata;
logic [HBM_BANKS-1:0]  [63:0]                  read_master_axi_wstrb;
logic [HBM_BANKS-1:0]                          read_master_axi_wlast;
logic [HBM_BANKS-1:0]                          read_master_axi_wvalid;
logic [HBM_BANKS-1:0]                          read_master_axi_wready;
logic [HBM_BANKS-1:0] [7:0]                    read_master_axi_bid;
logic [HBM_BANKS-1:0] [1:0]                    read_master_axi_bresp;
logic [HBM_BANKS-1:0]                          read_master_axi_bvalid;
logic [HBM_BANKS-1:0]                          read_master_axi_bready;
logic [HBM_BANKS-1:0]  [7:0]                   read_master_axi_arid;
logic [HBM_BANKS-1:0]  [33:0]                  read_master_axi_araddr;
logic [HBM_BANKS-1:0]  [7:0]                   read_master_axi_arlen;
logic [HBM_BANKS-1:0]  [2:0]                   read_master_axi_arsize;
logic [HBM_BANKS-1:0]  [1:0]                   read_master_axi_arburst;
logic [HBM_BANKS-1:0]  [0:0]                   read_master_axi_arlock;
logic [HBM_BANKS-1:0]  [3:0]                   read_master_axi_arcache;
logic [HBM_BANKS-1:0]  [2:0]                   read_master_axi_arprot;
logic [HBM_BANKS-1:0]  [3:0]                   read_master_axi_arqos;
logic [HBM_BANKS-1:0]                          read_master_axi_arvalid;
logic [HBM_BANKS-1:0]                          read_master_axi_arready;
logic [HBM_BANKS-1:0] [7:0]                    read_master_axi_rid;
logic [HBM_BANKS-1:0] [511:0]                  read_master_axi_rdata;
logic [HBM_BANKS-1:0] [1:0]                    read_master_axi_rresp;
logic [HBM_BANKS-1:0]                          read_master_axi_rlast;
logic [HBM_BANKS-1:0]                          read_master_axi_rvalid;
logic [HBM_BANKS-1:0]                          read_master_axi_rready;

// Nodeslot programmer -> DRAM C0
logic  [7:0]                   nodeslot_fetch_axi_awid;
logic  [33:0]                  nodeslot_fetch_axi_awaddr;
logic  [7:0]                   nodeslot_fetch_axi_awlen;
logic  [2:0]                   nodeslot_fetch_axi_awsize;
logic  [1:0]                   nodeslot_fetch_axi_awburst;
logic  [0:0]                   nodeslot_fetch_axi_awlock;
logic  [3:0]                   nodeslot_fetch_axi_awcache;
logic  [2:0]                   nodeslot_fetch_axi_awprot;
logic  [3:0]                   nodeslot_fetch_axi_awqos;
logic                          nodeslot_fetch_axi_awvalid;
logic                          nodeslot_fetch_axi_awready;
logic  [511:0]                 nodeslot_fetch_axi_wdata;
logic  [63:0]                  nodeslot_fetch_axi_wstrb;
logic                          nodeslot_fetch_axi_wlast;
logic                          nodeslot_fetch_axi_wvalid;
logic                          nodeslot_fetch_axi_wready;
logic [7:0]                    nodeslot_fetch_axi_bid;
logic [1:0]                    nodeslot_fetch_axi_bresp;
logic                          nodeslot_fetch_axi_bvalid;
logic                          nodeslot_fetch_axi_bready;
logic  [7:0]                   nodeslot_fetch_axi_arid;
logic  [33:0]                  nodeslot_fetch_axi_araddr;
logic  [7:0]                   nodeslot_fetch_axi_arlen;
logic  [2:0]                   nodeslot_fetch_axi_arsize;
logic  [1:0]                   nodeslot_fetch_axi_arburst;
logic  [0:0]                   nodeslot_fetch_axi_arlock;
logic  [3:0]                   nodeslot_fetch_axi_arcache;
logic  [2:0]                   nodeslot_fetch_axi_arprot;
logic  [3:0]                   nodeslot_fetch_axi_arqos;
logic                          nodeslot_fetch_axi_arvalid;
logic                          nodeslot_fetch_axi_arready;
logic [7:0]                    nodeslot_fetch_axi_rid;
logic [511:0]                  nodeslot_fetch_axi_rdata;
logic [1:0]                    nodeslot_fetch_axi_rresp;
logic                          nodeslot_fetch_axi_rlast;
logic                          nodeslot_fetch_axi_rvalid;
logic                          nodeslot_fetch_axi_rready;

// Transformation Engine -> DRAM C1
logic  [7:0]                   transformation_engine_axi_awid;
logic  [33:0]                  transformation_engine_axi_awaddr;
logic  [7:0]                   transformation_engine_axi_awlen;
logic  [2:0]                   transformation_engine_axi_awsize;
logic  [1:0]                   transformation_engine_axi_awburst;
logic  [0:0]                   transformation_engine_axi_awlock;
logic  [3:0]                   transformation_engine_axi_awcache;
logic  [2:0]                   transformation_engine_axi_awprot;
logic  [3:0]                   transformation_engine_axi_awqos;
logic                          transformation_engine_axi_awvalid;
logic                          transformation_engine_axi_awready;
logic  [511:0]                 transformation_engine_axi_wdata;
logic  [63:0]                  transformation_engine_axi_wstrb;
logic                          transformation_engine_axi_wlast;
logic                          transformation_engine_axi_wvalid;
logic                          transformation_engine_axi_wready;
logic [7:0]                    transformation_engine_axi_bid;
logic [1:0]                    transformation_engine_axi_bresp;
logic                          transformation_engine_axi_bvalid;
logic                          transformation_engine_axi_bready;
logic  [7:0]                   transformation_engine_axi_arid;
logic  [33:0]                  transformation_engine_axi_araddr;
logic  [7:0]                   transformation_engine_axi_arlen;
logic  [2:0]                   transformation_engine_axi_arsize;
logic  [1:0]                   transformation_engine_axi_arburst;
logic  [0:0]                   transformation_engine_axi_arlock;
logic  [3:0]                   transformation_engine_axi_arcache;
logic  [2:0]                   transformation_engine_axi_arprot;
logic  [3:0]                   transformation_engine_axi_arqos;
logic                          transformation_engine_axi_arvalid;
logic                          transformation_engine_axi_arready;
logic [7:0]                    transformation_engine_axi_rid;
logic [511:0]                  transformation_engine_axi_rdata;
logic [1:0]                    transformation_engine_axi_rresp;
logic                          transformation_engine_axi_rlast;
logic                          transformation_engine_axi_rvalid;
logic                          transformation_engine_axi_rready;

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
    .read_master_axi_arid                        (read_master_axi_arid),
    .read_master_axi_araddr                      (read_master_axi_araddr),
    .read_master_axi_arlen                       (read_master_axi_arlen),
    .read_master_axi_arsize                      (read_master_axi_arsize),
    .read_master_axi_arburst                     (read_master_axi_arburst),
    .read_master_axi_arlock                      (read_master_axi_arlock),
    .read_master_axi_arcache                     (read_master_axi_arcache),
    .read_master_axi_arprot                      (read_master_axi_arprot),
    .read_master_axi_arqos                       (read_master_axi_arqos),
    .read_master_axi_arvalid                     (read_master_axi_arvalid),
    .read_master_axi_arready                     (read_master_axi_arready),
    .read_master_axi_rid                         (read_master_axi_rid),
    .read_master_axi_rdata                       (read_master_axi_rdata),
    .read_master_axi_rresp                       (read_master_axi_rresp),
    .read_master_axi_rlast                       (read_master_axi_rlast),
    .read_master_axi_rvalid                      (read_master_axi_rvalid),
    .read_master_axi_rready                      (read_master_axi_rready),

    .transformation_engine_axi_awid,
    .transformation_engine_axi_awaddr,
    .transformation_engine_axi_awlen,
    .transformation_engine_axi_awsize,
    .transformation_engine_axi_awburst,
    .transformation_engine_axi_awlock,
    .transformation_engine_axi_awcache,
    .transformation_engine_axi_awprot,
    .transformation_engine_axi_awqos,
    .transformation_engine_axi_awvalid,
    .transformation_engine_axi_awready,
    .transformation_engine_axi_wdata,
    .transformation_engine_axi_wstrb,
    .transformation_engine_axi_wlast,
    .transformation_engine_axi_wvalid,
    .transformation_engine_axi_wready,
    .transformation_engine_axi_bid,
    .transformation_engine_axi_bresp,
    .transformation_engine_axi_bvalid,
    .transformation_engine_axi_bready,
    .transformation_engine_axi_arid,
    .transformation_engine_axi_araddr,
    .transformation_engine_axi_arlen,
    .transformation_engine_axi_arsize,
    .transformation_engine_axi_arburst,
    .transformation_engine_axi_arlock,
    .transformation_engine_axi_arcache,
    .transformation_engine_axi_arprot,
    .transformation_engine_axi_arqos,
    .transformation_engine_axi_arvalid,
    .transformation_engine_axi_arready,
    .transformation_engine_axi_rid,
    .transformation_engine_axi_rdata,
    .transformation_engine_axi_rresp,
    .transformation_engine_axi_rlast,
    .transformation_engine_axi_rvalid,
    .transformation_engine_axi_rready,

    .nodeslot_fetch_axi_awid                (nodeslot_fetch_axi_awid),
    .nodeslot_fetch_axi_awaddr              (nodeslot_fetch_axi_awaddr),
    .nodeslot_fetch_axi_awlen               (nodeslot_fetch_axi_awlen),
    .nodeslot_fetch_axi_awsize              (nodeslot_fetch_axi_awsize),
    .nodeslot_fetch_axi_awburst             (nodeslot_fetch_axi_awburst),
    .nodeslot_fetch_axi_awlock              (nodeslot_fetch_axi_awlock),
    .nodeslot_fetch_axi_awcache             (nodeslot_fetch_axi_awcache),
    .nodeslot_fetch_axi_awprot              (nodeslot_fetch_axi_awprot),
    .nodeslot_fetch_axi_awqos               (nodeslot_fetch_axi_awqos),
    .nodeslot_fetch_axi_awvalid             (nodeslot_fetch_axi_awvalid),
    .nodeslot_fetch_axi_awready             (nodeslot_fetch_axi_awready),
    .nodeslot_fetch_axi_wdata               (nodeslot_fetch_axi_wdata),
    .nodeslot_fetch_axi_wstrb               (nodeslot_fetch_axi_wstrb),
    .nodeslot_fetch_axi_wlast               (nodeslot_fetch_axi_wlast),
    .nodeslot_fetch_axi_wvalid              (nodeslot_fetch_axi_wvalid),
    .nodeslot_fetch_axi_wready              (nodeslot_fetch_axi_wready),
    .nodeslot_fetch_axi_bid                 (nodeslot_fetch_axi_bid),
    .nodeslot_fetch_axi_bresp               (nodeslot_fetch_axi_bresp),
    .nodeslot_fetch_axi_bvalid              (nodeslot_fetch_axi_bvalid),
    .nodeslot_fetch_axi_bready              (nodeslot_fetch_axi_bready),
    .nodeslot_fetch_axi_arid                (nodeslot_fetch_axi_arid),
    .nodeslot_fetch_axi_araddr              (nodeslot_fetch_axi_araddr),
    .nodeslot_fetch_axi_arlen               (nodeslot_fetch_axi_arlen),
    .nodeslot_fetch_axi_arsize              (nodeslot_fetch_axi_arsize),
    .nodeslot_fetch_axi_arburst             (nodeslot_fetch_axi_arburst),
    .nodeslot_fetch_axi_arlock              (nodeslot_fetch_axi_arlock),
    .nodeslot_fetch_axi_arcache             (nodeslot_fetch_axi_arcache),
    .nodeslot_fetch_axi_arprot              (nodeslot_fetch_axi_arprot),
    .nodeslot_fetch_axi_arqos               (nodeslot_fetch_axi_arqos),
    .nodeslot_fetch_axi_arvalid             (nodeslot_fetch_axi_arvalid),
    .nodeslot_fetch_axi_arready             (nodeslot_fetch_axi_arready),
    .nodeslot_fetch_axi_rid                 (nodeslot_fetch_axi_rid),
    .nodeslot_fetch_axi_rdata               (nodeslot_fetch_axi_rdata),
    .nodeslot_fetch_axi_rresp               (nodeslot_fetch_axi_rresp),
    .nodeslot_fetch_axi_rlast               (nodeslot_fetch_axi_rlast),
    .nodeslot_fetch_axi_rvalid              (nodeslot_fetch_axi_rvalid),
    .nodeslot_fetch_axi_rready              (nodeslot_fetch_axi_rready)
);


  
assign transformation_engine_axi_wready = &read_master_axi_wready;
assign transformation_engine_axi_awready = &read_master_axi_awready;

assign transformation_engine_axi_bvalid = &read_master_axi_bvalid;
assign transformation_engine_axi_bid = read_master_axi_bid[0];
assign transformation_engine_axi_bresp = read_master_axi_bresp[0];

generate begin:HBM_BANK
    for (genvar bank=0; bank < HBM_BANKS; bank++) begin: HBM_i
        axi_ram #(
            .DATA_WIDTH(512),
            .ADDR_WIDTH(34),
            .ID_WIDTH(8)
        ) hbm_bank_i (
            .clk                    (sys_clk),
            .rst                    (sys_rst),

            .s_axi_awid             (transformation_engine_axi_awid    ),
            .s_axi_awaddr           (transformation_engine_axi_awaddr  ),
            .s_axi_awlen            (transformation_engine_axi_awlen   ),
            .s_axi_awsize           (transformation_engine_axi_awsize  ),
            .s_axi_awburst          (transformation_engine_axi_awburst ),
            .s_axi_awlock           (transformation_engine_axi_awlock  ),
            .s_axi_awcache          (transformation_engine_axi_awcache ),
            .s_axi_awprot           (transformation_engine_axi_awprot  ),
            .s_axi_awvalid          (transformation_engine_axi_awvalid ),
            .s_axi_awready          (read_master_axi_awready [bank]    ),
            .s_axi_wdata            (transformation_engine_axi_wdata   ),
            .s_axi_wstrb            (transformation_engine_axi_wstrb   ),
            .s_axi_wlast            (transformation_engine_axi_wlast   ),
            .s_axi_wvalid           (transformation_engine_axi_wvalid  ),
            .s_axi_wready           (read_master_axi_wready  [bank]    ),
            .s_axi_bid              (read_master_axi_bid     [bank]    ),
            .s_axi_bresp            (read_master_axi_bresp   [bank]    ),
            .s_axi_bvalid           (read_master_axi_bvalid  [bank]    ),
            .s_axi_bready           (transformation_engine_axi_bready  ),


            .s_axi_arid             (read_master_axi_arid    [bank]),
            .s_axi_araddr           (read_master_axi_araddr  [bank]),
            .s_axi_arlen            (read_master_axi_arlen   [bank]),
            .s_axi_arsize           (read_master_axi_arsize  [bank]),
            .s_axi_arburst          (read_master_axi_arburst [bank]),
            .s_axi_arlock           (read_master_axi_arlock  [bank]),
            .s_axi_arcache          (read_master_axi_arcache [bank]),
            .s_axi_arprot           (read_master_axi_arprot  [bank]),
            .s_axi_arvalid          (read_master_axi_arvalid [bank]),
            .s_axi_arready          (read_master_axi_arready [bank]),
            .s_axi_rid              (read_master_axi_rid     [bank]),
            .s_axi_rdata            (read_master_axi_rdata   [bank]),
            .s_axi_rresp            (read_master_axi_rresp   [bank]),
            .s_axi_rlast            (read_master_axi_rlast   [bank]),
            .s_axi_rvalid           (read_master_axi_rvalid  [bank]),
            .s_axi_rready           (read_master_axi_rready  [bank])
        );
    end
end
endgenerate

// DRAM model for nodeslot programming
axi_ram #(
    .DATA_WIDTH (512),
    .ADDR_WIDTH (34),
    .ID_WIDTH   (8),
    .DATA_FILE  ("$WORKAREA/hw/sim/layer_config/nodeslots.mem")
) dram_c0 (
    .clk                    (sys_clk),
    .rst                    (sys_rst),

    .s_axi_awid             (nodeslot_fetch_axi_awid    ),
    .s_axi_awaddr           (nodeslot_fetch_axi_awaddr  ),
    .s_axi_awlen            (nodeslot_fetch_axi_awlen   ),
    .s_axi_awsize           (nodeslot_fetch_axi_awsize  ),
    .s_axi_awburst          (nodeslot_fetch_axi_awburst ),
    .s_axi_awlock           (nodeslot_fetch_axi_awlock  ),
    .s_axi_awcache          (nodeslot_fetch_axi_awcache ),
    .s_axi_awprot           (nodeslot_fetch_axi_awprot  ),
    .s_axi_awvalid          (nodeslot_fetch_axi_awvalid ),
    .s_axi_awready          (nodeslot_fetch_axi_awready ),
    .s_axi_wdata            (nodeslot_fetch_axi_wdata   ),
    .s_axi_wstrb            (nodeslot_fetch_axi_wstrb   ),
    .s_axi_wlast            (nodeslot_fetch_axi_wlast   ),
    .s_axi_wvalid           (nodeslot_fetch_axi_wvalid  ),
    .s_axi_wready           (nodeslot_fetch_axi_wready  ),
    .s_axi_bid              (nodeslot_fetch_axi_bid     ),
    .s_axi_bresp            (nodeslot_fetch_axi_bresp   ),
    .s_axi_bvalid           (nodeslot_fetch_axi_bvalid  ),
    .s_axi_bready           (nodeslot_fetch_axi_bready  ),
    .s_axi_arid             (nodeslot_fetch_axi_arid    ),
    .s_axi_araddr           (nodeslot_fetch_axi_araddr  ),
    .s_axi_arlen            (nodeslot_fetch_axi_arlen   ),
    .s_axi_arsize           (nodeslot_fetch_axi_arsize  ),
    .s_axi_arburst          (nodeslot_fetch_axi_arburst ),
    .s_axi_arlock           (nodeslot_fetch_axi_arlock  ),
    .s_axi_arcache          (nodeslot_fetch_axi_arcache ),
    .s_axi_arprot           (nodeslot_fetch_axi_arprot  ),
    .s_axi_arvalid          (nodeslot_fetch_axi_arvalid ),
    .s_axi_arready          (nodeslot_fetch_axi_arready ),
    .s_axi_rid              (nodeslot_fetch_axi_rid     ),
    .s_axi_rdata            (nodeslot_fetch_axi_rdata   ),
    .s_axi_rresp            (nodeslot_fetch_axi_rresp   ),
    .s_axi_rlast            (nodeslot_fetch_axi_rlast   ),
    .s_axi_rvalid           (nodeslot_fetch_axi_rvalid  ),
    .s_axi_rready           (nodeslot_fetch_axi_rready  )
);

// DRAM model for FTE transactions





// axi_ram #(
//     .DATA_WIDTH(512),
//     .ADDR_WIDTH(34),
//     .ID_WIDTH(8)
// ) dram_c1 (
//     .clk                    (sys_clk),
//     .rst                    (sys_rst),

//     .s_axi_awid             (transformation_engine_axi_awid    ),
//     .s_axi_awaddr           (transformation_engine_axi_awaddr  ),
//     .s_axi_awlen            (transformation_engine_axi_awlen   ),
//     .s_axi_awsize           (transformation_engine_axi_awsize  ),
//     .s_axi_awburst          (transformation_engine_axi_awburst ),
//     .s_axi_awlock           (transformation_engine_axi_awlock  ),
//     .s_axi_awcache          (transformation_engine_axi_awcache ),
//     .s_axi_awprot           (transformation_engine_axi_awprot  ),
//     .s_axi_awvalid          (transformation_engine_axi_awvalid ),
//     .s_axi_awready          (transformation_engine_axi_awready ),
//     .s_axi_wdata            (transformation_engine_axi_wdata   ),
//     .s_axi_wstrb            (transformation_engine_axi_wstrb   ),
//     .s_axi_wlast            (transformation_engine_axi_wlast   ),
//     .s_axi_wvalid           (transformation_engine_axi_wvalid  ),
//     .s_axi_wready           (transformation_engine_axi_wready  ),
//     .s_axi_bid              (transformation_engine_axi_bid     ),
//     .s_axi_bresp            (transformation_engine_axi_bresp   ),
//     .s_axi_bvalid           (transformation_engine_axi_bvalid  ),
//     .s_axi_bready           (transformation_engine_axi_bready  ),
//     .s_axi_arid             (transformation_engine_axi_arid    ),
//     .s_axi_araddr           (transformation_engine_axi_araddr  ),
//     .s_axi_arlen            (transformation_engine_axi_arlen   ),
//     .s_axi_arsize           (transformation_engine_axi_arsize  ),
//     .s_axi_arburst          (transformation_engine_axi_arburst ),
//     .s_axi_arlock           (transformation_engine_axi_arlock  ),
//     .s_axi_arcache          (transformation_engine_axi_arcache ),
//     .s_axi_arprot           (transformation_engine_axi_arprot  ),
//     .s_axi_arvalid          (transformation_engine_axi_arvalid ),
//     .s_axi_arready          (transformation_engine_axi_arready ),
//     .s_axi_rid              (transformation_engine_axi_rid     ),
//     .s_axi_rdata            (transformation_engine_axi_rdata   ),
//     .s_axi_rresp            (transformation_engine_axi_rresp   ),
//     .s_axi_rlast            (transformation_engine_axi_rlast   ),
//     .s_axi_rvalid           (transformation_engine_axi_rvalid  ),
//     .s_axi_rready           (transformation_engine_axi_rready  )
// );



endmodule