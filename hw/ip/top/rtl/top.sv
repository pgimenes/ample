`timescale 1ns/100ps

import top_pkg::*;

module top
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
    output logic [1 : 0]                  host_axil_rresp,
       
    // Prefetcher Read Masters -> HBM
    output logic [top_pkg::HBM_BANKS-1:0]  [7:0]                   read_master_axi_awid,
    output logic [top_pkg::HBM_BANKS-1:0]  [33:0]                  read_master_axi_awaddr,
    output logic [top_pkg::HBM_BANKS-1:0]  [7:0]                   read_master_axi_awlen,
    output logic [top_pkg::HBM_BANKS-1:0]  [2:0]                   read_master_axi_awsize,
    output logic [top_pkg::HBM_BANKS-1:0]  [1:0]                   read_master_axi_awburst,
    output logic [top_pkg::HBM_BANKS-1:0]  [0:0]                   read_master_axi_awlock,
    output logic [top_pkg::HBM_BANKS-1:0]  [3:0]                   read_master_axi_awcache,
    output logic [top_pkg::HBM_BANKS-1:0]  [2:0]                   read_master_axi_awprot,
    output logic [top_pkg::HBM_BANKS-1:0]  [3:0]                   read_master_axi_awqos,
    output logic [top_pkg::HBM_BANKS-1:0]                          read_master_axi_awvalid,
    input  logic [top_pkg::HBM_BANKS-1:0]                          read_master_axi_awready,
    output logic [top_pkg::HBM_BANKS-1:0]  [511:0]                 read_master_axi_wdata,
    output logic [top_pkg::HBM_BANKS-1:0]  [63:0]                  read_master_axi_wstrb,
    output logic [top_pkg::HBM_BANKS-1:0]                          read_master_axi_wlast,
    output logic [top_pkg::HBM_BANKS-1:0]                          read_master_axi_wvalid,
    input  logic [top_pkg::HBM_BANKS-1:0]                          read_master_axi_wready,
    input  logic [top_pkg::HBM_BANKS-1:0] [7:0]                    read_master_axi_bid,
    input  logic [top_pkg::HBM_BANKS-1:0] [1:0]                    read_master_axi_bresp,
    input  logic [top_pkg::HBM_BANKS-1:0]                          read_master_axi_bvalid,
    output logic [top_pkg::HBM_BANKS-1:0]                          read_master_axi_bready,
    output logic [top_pkg::HBM_BANKS-1:0]  [7:0]                   read_master_axi_arid,
    output logic [top_pkg::HBM_BANKS-1:0]  [33:0]                  read_master_axi_araddr,
    output logic [top_pkg::HBM_BANKS-1:0]  [7:0]                   read_master_axi_arlen,
    output logic [top_pkg::HBM_BANKS-1:0]  [2:0]                   read_master_axi_arsize,
    output logic [top_pkg::HBM_BANKS-1:0]  [1:0]                   read_master_axi_arburst,
    output logic [top_pkg::HBM_BANKS-1:0]  [0:0]                   read_master_axi_arlock,
    output logic [top_pkg::HBM_BANKS-1:0]  [3:0]                   read_master_axi_arcache,
    output logic [top_pkg::HBM_BANKS-1:0]  [2:0]                   read_master_axi_arprot,
    output logic [top_pkg::HBM_BANKS-1:0]  [3:0]                   read_master_axi_arqos,
    output logic [top_pkg::HBM_BANKS-1:0]                          read_master_axi_arvalid,
    input  logic [top_pkg::HBM_BANKS-1:0]                          read_master_axi_arready,
    input  logic [top_pkg::HBM_BANKS-1:0] [7:0]                    read_master_axi_rid,
    input  logic [top_pkg::HBM_BANKS-1:0] [511:0]                  read_master_axi_rdata,
    input  logic [top_pkg::HBM_BANKS-1:0] [1:0]                    read_master_axi_rresp,
    input  logic [top_pkg::HBM_BANKS-1:0]                          read_master_axi_rlast,
    input  logic [top_pkg::HBM_BANKS-1:0]                          read_master_axi_rvalid,
    output logic [top_pkg::HBM_BANKS-1:0]                          read_master_axi_rready,

    // Feature Transformation Engine -> DRAM (Write Only)
    output logic [33:0]                       transformation_engine_axi_araddr,
    output logic [1:0]                        transformation_engine_axi_arburst,
    output logic [3:0]                        transformation_engine_axi_arcache,
    output logic [3:0]                        transformation_engine_axi_arid,
    output logic [7:0]                        transformation_engine_axi_arlen,
    output logic [0:0]                        transformation_engine_axi_arlock,
    output logic [2:0]                        transformation_engine_axi_arprot,
    output logic [3:0]                        transformation_engine_axi_arqos,
    output logic [2:0]                        transformation_engine_axi_arsize,
    output logic                              transformation_engine_axi_arvalid,
    input  logic                              transformation_engine_axi_arready,
    input  logic [511:0]                      transformation_engine_axi_rdata,
    input  logic [3:0]                        transformation_engine_axi_rid,
    input  logic                              transformation_engine_axi_rlast,
    output logic                              transformation_engine_axi_rready,
    input  logic [1:0]                        transformation_engine_axi_rresp,
    input  logic                              transformation_engine_axi_rvalid,
    output logic [33:0]                       transformation_engine_axi_awaddr,
    output logic [1:0]                        transformation_engine_axi_awburst,
    output logic [3:0]                        transformation_engine_axi_awcache,
    output logic [3:0]                        transformation_engine_axi_awid,
    output logic [7:0]                        transformation_engine_axi_awlen,
    output logic [0:0]                        transformation_engine_axi_awlock,
    output logic [2:0]                        transformation_engine_axi_awprot,
    output logic [3:0]                        transformation_engine_axi_awqos,
    input  logic                              transformation_engine_axi_awready,
    output logic [2:0]                        transformation_engine_axi_awsize,
    output logic                              transformation_engine_axi_awvalid,
    output logic [511:0]                      transformation_engine_axi_wdata,
    output logic                              transformation_engine_axi_wlast,
    input  logic                              transformation_engine_axi_wready,
    output logic [63:0]                       transformation_engine_axi_wstrb,
    output logic                              transformation_engine_axi_wvalid,
    input  logic [3:0]                        transformation_engine_axi_bid,
    output logic                              transformation_engine_axi_bready,
    input  logic [1:0]                        transformation_engine_axi_bresp,
    input  logic                              transformation_engine_axi_bvalid
);

// ====================================================================================
// Declarations
// ====================================================================================

// AXI-L Interconnect (joint for all slaves)
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

// Prefetcher Weight Bank Read Master -> SRAM
logic [33:0]                       weight_bank_axi_araddr;
logic [1:0]                        weight_bank_axi_arburst;
logic [3:0]                        weight_bank_axi_arcache;
logic [3:0]                        weight_bank_axi_arid;
logic [7:0]                        weight_bank_axi_arlen;
logic [0:0]                        weight_bank_axi_arlock;
logic [2:0]                        weight_bank_axi_arprot;
logic [3:0]                        weight_bank_axi_arqos;
logic [2:0]                        weight_bank_axi_arsize;
logic                              weight_bank_axi_arvalid;
logic                              weight_bank_axi_arready;
logic [33:0]                       weight_bank_axi_awaddr;
logic [1:0]                        weight_bank_axi_awburst;
logic [3:0]                        weight_bank_axi_awcache;
logic [3:0]                        weight_bank_axi_awid;
logic [7:0]                        weight_bank_axi_awlen;
logic [0:0]                        weight_bank_axi_awlock;
logic [2:0]                        weight_bank_axi_awprot;
logic [3:0]                        weight_bank_axi_awqos;
logic                              weight_bank_axi_awready;
logic [2:0]                        weight_bank_axi_awsize;
logic                              weight_bank_axi_awvalid;
logic [3:0]                        weight_bank_axi_bid;
logic                              weight_bank_axi_bready;
logic [1:0]                        weight_bank_axi_bresp;
logic                              weight_bank_axi_bvalid;
logic [511:0]                      weight_bank_axi_rdata;
logic [3:0]                        weight_bank_axi_rid;
logic                              weight_bank_axi_rlast;
logic                              weight_bank_axi_rready;
logic [1:0]                        weight_bank_axi_rresp;
logic                              weight_bank_axi_rvalid;
logic [511:0]                      weight_bank_axi_wdata;
logic                              weight_bank_axi_wlast;
logic                              weight_bank_axi_wready;
logic [63:0]                       weight_bank_axi_wstrb;
logic                              weight_bank_axi_wvalid;

// NSB -> Aggregation Engine Interface
logic                                                nsb_age_req_valid;
logic                                                nsb_age_req_ready;
NSB_AGE_REQ_t                                        nsb_age_req;
logic                                                nsb_age_resp_valid; // valid only for now
NSB_AGE_RESP_t                                       nsb_age_resp;

// NSB -> Transformation Engine Interface
logic                                                nsb_fte_req_valid;
logic                                                nsb_fte_req_ready;
NSB_FTE_REQ_t                                        nsb_fte_req;
logic                                                nsb_fte_resp_valid; // valid only for now
NSB_FTE_RESP_t                                       nsb_fte_resp;

// NSB -> Prefetcher Interface
logic                                                nsb_prefetcher_req_valid;
logic                                                nsb_prefetcher_req_ready;
NSB_PREF_REQ_t                                       nsb_prefetcher_req;
logic                                                nsb_prefetcher_resp_valid; // valid only for now
NSB_PREF_RESP_t                                      nsb_prefetcher_resp;

// Message Channels: AGE -> Prefetcher
logic [MESSAGE_CHANNEL_COUNT-1:0]                  message_channel_req_valid;
logic [MESSAGE_CHANNEL_COUNT-1:0]                  message_channel_req_ready;
MESSAGE_CHANNEL_REQ_t [MESSAGE_CHANNEL_COUNT-1:0]  message_channel_req;

logic [MESSAGE_CHANNEL_COUNT-1:0]                  message_channel_resp_valid;
logic [MESSAGE_CHANNEL_COUNT-1:0]                  message_channel_resp_ready;
MESSAGE_CHANNEL_RESP_t [MESSAGE_CHANNEL_COUNT-1:0] message_channel_resp;

// Weight Channel: FTE -> Prefetcher
logic                 [top_pkg::PRECISION_COUNT-1:0] weight_channel_req_valid;
logic                 [top_pkg::PRECISION_COUNT-1:0] weight_channel_req_ready;
WEIGHT_CHANNEL_REQ_t  [top_pkg::PRECISION_COUNT-1:0] weight_channel_req;
logic                 [top_pkg::PRECISION_COUNT-1:0] weight_channel_resp_valid;
logic                 [top_pkg::PRECISION_COUNT-1:0] weight_channel_resp_ready;
WEIGHT_CHANNEL_RESP_t [top_pkg::PRECISION_COUNT-1:0] weight_channel_resp;

// AGE -> Aggregation Buffer Interface
logic [top_pkg::PRECISION_COUNT-1:0] [AGGREGATION_BUFFER_SLOTS-1:0]                                              aggregation_buffer_set_node_id_valid;
logic [top_pkg::PRECISION_COUNT-1:0] [AGGREGATION_BUFFER_SLOTS-1:0] [NODE_ID_WIDTH-1:0]                          aggregation_buffer_set_node_id;
logic [top_pkg::PRECISION_COUNT-1:0] [AGGREGATION_BUFFER_SLOTS-1:0]                                              aggregation_buffer_write_enable;
logic [top_pkg::PRECISION_COUNT-1:0] [AGGREGATION_BUFFER_SLOTS-1:0] [$clog2(AGGREGATION_BUFFER_WRITE_DEPTH)-1:0] aggregation_buffer_write_address;
logic [top_pkg::PRECISION_COUNT-1:0] [AGGREGATION_BUFFER_SLOTS-1:0] [AGGREGATION_BUFFER_WRITE_WIDTH-1:0]         aggregation_buffer_write_data;
logic [top_pkg::PRECISION_COUNT-1:0] [AGGREGATION_BUFFER_SLOTS-1:0] [$clog2(AGGREGATION_BUFFER_READ_DEPTH)-1:0]  aggregation_buffer_feature_count;

// FTE -> Aggregation Buffer Interface
logic [top_pkg::PRECISION_COUNT-1:0] [AGGREGATION_BUFFER_SLOTS-1:0] [NODE_ID_WIDTH-1:0]                          aggregation_buffer_node_id;
logic [top_pkg::PRECISION_COUNT-1:0] [AGGREGATION_BUFFER_SLOTS-1:0]                                              aggregation_buffer_pop;
logic [top_pkg::PRECISION_COUNT-1:0] [AGGREGATION_BUFFER_SLOTS-1:0] [AGGREGATION_BUFFER_READ_WIDTH-1:0]          aggregation_buffer_out_feature;
logic [top_pkg::PRECISION_COUNT-1:0] [AGGREGATION_BUFFER_SLOTS-1:0]                                              aggregation_buffer_out_feature_valid;
logic [top_pkg::PRECISION_COUNT-1:0] [AGGREGATION_BUFFER_SLOTS-1:0]                                              aggregation_buffer_slot_free;

// FTE -> Transformation Buffer Interface
logic [TRANSFORMATION_BUFFER_SLOTS-1:0]                                                 transformation_buffer_write_enable;
logic [TRANSFORMATION_BUFFER_SLOTS-1:0] [$clog2(TRANSFORMATION_BUFFER_WRITE_DEPTH)-1:0] transformation_buffer_write_address;
logic [TRANSFORMATION_BUFFER_SLOTS-1:0] [TRANSFORMATION_BUFFER_WRITE_WIDTH-1:0]         transformation_buffer_write_data;
logic [TRANSFORMATION_BUFFER_SLOTS-1:0] [$clog2(TRANSFORMATION_BUFFER_READ_DEPTH)-1:0]  transformation_buffer_feature_count;

// MPE -> TRANSFORMATION Buffer Interface
logic [TRANSFORMATION_BUFFER_SLOTS-1:0]                                                 transformation_buffer_pop;
logic [TRANSFORMATION_BUFFER_SLOTS-1:0] [TRANSFORMATION_BUFFER_READ_WIDTH-1:0]          transformation_buffer_out_feature;
logic [TRANSFORMATION_BUFFER_SLOTS-1:0]                                                 transformation_buffer_slot_free;

// Prefetcher -> AGE: Scale Factor interface
logic [top_pkg::MESSAGE_CHANNEL_COUNT-1:0]                                           scale_factor_queue_pop;
logic [top_pkg::MESSAGE_CHANNEL_COUNT-1:0] [SCALE_FACTOR_QUEUE_READ_WIDTH-1:0]       scale_factor_queue_out_data;
logic [top_pkg::MESSAGE_CHANNEL_COUNT-1:0]                                           scale_factor_queue_out_valid;
logic [top_pkg::MESSAGE_CHANNEL_COUNT-1:0] [$clog2(SCALE_FACTOR_QUEUE_READ_DEPTH):0] scale_factor_queue_count;
logic [top_pkg::MESSAGE_CHANNEL_COUNT-1:0]                                           scale_factor_queue_empty;
logic [top_pkg::MESSAGE_CHANNEL_COUNT-1:0]                                           scale_factor_queue_full;

// ====================================================================================
// Node Scoreboard
// ====================================================================================

node_scoreboard #(
    .NODESLOT_COUNT (top_pkg::MAX_NODESLOT_COUNT)
) node_scoreboard_i (
    .core_clk                       (sys_clk),
    .resetn                         (!sys_rst),

    .regbank_clk                    (regbank_clk),
    .regbank_resetn                 (regbank_resetn),
    
    // Regbank Slave AXI interface
    .s_axi_awaddr                                       (axil_interconnect_m_axi_awaddr     [95:64]),
    .s_axi_awprot                                       (axil_interconnect_m_axi_awprot     [8:6]),
    .s_axi_awvalid                                      (axil_interconnect_m_axi_awvalid    [2:2]),
    .s_axi_awready                                      (axil_interconnect_m_axi_awready    [2:2]),
    .s_axi_wdata                                        (axil_interconnect_m_axi_wdata      [95:64]),
    .s_axi_wstrb                                        (axil_interconnect_m_axi_wstrb      [11:8]),
    .s_axi_wvalid                                       (axil_interconnect_m_axi_wvalid     [2:2]),
    .s_axi_wready                                       (axil_interconnect_m_axi_wready     [2:2]),
    .s_axi_bresp                                        (axil_interconnect_m_axi_bresp      [5:4]),
    .s_axi_bvalid                                       (axil_interconnect_m_axi_bvalid     [2:2]),
    .s_axi_bready                                       (axil_interconnect_m_axi_bready     [2:2]),
    .s_axi_araddr                                       (axil_interconnect_m_axi_araddr     [95:64]),
    .s_axi_arprot                                       (axil_interconnect_m_axi_arprot     [8:6]),
    .s_axi_arvalid                                      (axil_interconnect_m_axi_arvalid    [2:2]),
    .s_axi_arready                                      (axil_interconnect_m_axi_arready    [2:2]),
    .s_axi_rdata                                        (axil_interconnect_m_axi_rdata      [95:64]),
    .s_axi_rresp                                        (axil_interconnect_m_axi_rresp      [5:4]),
    .s_axi_rvalid                                       (axil_interconnect_m_axi_rvalid     [2:2]),
    .s_axi_rready                                       (axil_interconnect_m_axi_rready     [2:2]),

    // Node Scoreboard -> Aggregation Engine Interface
    .nsb_age_req_valid                                  (nsb_age_req_valid),
    .nsb_age_req_ready                                  (nsb_age_req_ready),
    .nsb_age_req                                        (nsb_age_req),
    .nsb_age_resp_valid                                 (nsb_age_resp_valid),
    .nsb_age_resp                                       (nsb_age_resp),

    // Node Scoreboard -> Transformation Engine Interface
    .nsb_fte_req_valid                                  (nsb_fte_req_valid),
    .nsb_fte_req_ready                                  (nsb_fte_req_ready),
    .nsb_fte_req                                        (nsb_fte_req),
    .nsb_fte_resp_valid                                 (nsb_fte_resp_valid),
    .nsb_fte_resp                                       (nsb_fte_resp),

    // Node Scoreboard -> Prefetcher Interface
    .nsb_prefetcher_req_valid                           (nsb_prefetcher_req_valid),
    .nsb_prefetcher_req_ready                           (nsb_prefetcher_req_ready),
    .nsb_prefetcher_req                                 (nsb_prefetcher_req),
    .nsb_prefetcher_resp_valid                          (nsb_prefetcher_resp_valid),
    .nsb_prefetcher_resp                                (nsb_prefetcher_resp)
);

// ====================================================================================
// Prefetcher
// ====================================================================================

prefetcher #(
    .FETCH_TAG_COUNT (top_pkg::MESSAGE_CHANNEL_COUNT)
) prefetcher_i (
    .core_clk                                                  (sys_clk),
    .resetn                                                    (!sys_rst),

    .regbank_clk                                               (regbank_clk),
    .regbank_resetn                                            (regbank_resetn),

    // Node Scoreboard -> Prefetcher Interface
    .nsb_prefetcher_req_valid                                  (nsb_prefetcher_req_valid),
    .nsb_prefetcher_req_ready                                  (nsb_prefetcher_req_ready),
    .nsb_prefetcher_req                                        (nsb_prefetcher_req),
    .nsb_prefetcher_resp_valid                                 (nsb_prefetcher_resp_valid),
    .nsb_prefetcher_resp                                       (nsb_prefetcher_resp),

    // Regbank Slave AXI interface
    .s_axi_awaddr                                              (axil_interconnect_m_axi_awaddr     [127:96]),
    .s_axi_wdata                                               (axil_interconnect_m_axi_wdata      [127:96]),
    .s_axi_araddr                                              (axil_interconnect_m_axi_araddr     [127:96]),
    .s_axi_rdata                                               (axil_interconnect_m_axi_rdata      [127:96]),
    .s_axi_awprot                                              (axil_interconnect_m_axi_awprot     [11:9]),
    .s_axi_arprot                                              (axil_interconnect_m_axi_arprot     [11:9]),
    .s_axi_awvalid                                             (axil_interconnect_m_axi_awvalid    [3:3]),
    .s_axi_awready                                             (axil_interconnect_m_axi_awready    [3:3]),
    .s_axi_wvalid                                              (axil_interconnect_m_axi_wvalid     [3:3]),
    .s_axi_wready                                              (axil_interconnect_m_axi_wready     [3:3]),
    .s_axi_bvalid                                              (axil_interconnect_m_axi_bvalid     [3:3]),
    .s_axi_bready                                              (axil_interconnect_m_axi_bready     [3:3]),
    .s_axi_arvalid                                             (axil_interconnect_m_axi_arvalid    [3:3]),
    .s_axi_arready                                             (axil_interconnect_m_axi_arready    [3:3]),
    .s_axi_rvalid                                              (axil_interconnect_m_axi_rvalid     [3:3]),
    .s_axi_rready                                              (axil_interconnect_m_axi_rready     [3:3]),
    .s_axi_wstrb                                               (axil_interconnect_m_axi_wstrb      [15:12]),
    .s_axi_bresp                                               (axil_interconnect_m_axi_bresp      [7:6]),
    .s_axi_rresp                                               (axil_interconnect_m_axi_rresp      [7:6]),

    // Prefetcher Read masters -> HBM
    .read_master_axi_araddr             (read_master_axi_araddr),
    .read_master_axi_arburst            (read_master_axi_arburst),
    .read_master_axi_arcache            (read_master_axi_arcache),
    .read_master_axi_arid               (read_master_axi_arid),
    .read_master_axi_arlen              (read_master_axi_arlen),
    .read_master_axi_arlock             (read_master_axi_arlock),
    .read_master_axi_arprot             (read_master_axi_arprot),
    .read_master_axi_arqos              (read_master_axi_arqos),
    .read_master_axi_arsize             (read_master_axi_arsize),
    .read_master_axi_arvalid            (read_master_axi_arvalid),
    .read_master_axi_arready            (read_master_axi_arready),
    .read_master_axi_awaddr             (read_master_axi_awaddr),
    .read_master_axi_awburst            (read_master_axi_awburst),
    .read_master_axi_awcache            (read_master_axi_awcache),
    .read_master_axi_awid               (read_master_axi_awid),
    .read_master_axi_awlen              (read_master_axi_awlen),
    .read_master_axi_awlock             (read_master_axi_awlock),
    .read_master_axi_awprot             (read_master_axi_awprot),
    .read_master_axi_awqos              (read_master_axi_awqos),
    .read_master_axi_awready            (read_master_axi_awready),
    .read_master_axi_awsize             (read_master_axi_awsize),
    .read_master_axi_awvalid            (read_master_axi_awvalid),
    .read_master_axi_bid                (read_master_axi_bid),
    .read_master_axi_bready             (read_master_axi_bready),
    .read_master_axi_bresp              (read_master_axi_bresp),
    .read_master_axi_bvalid             (read_master_axi_bvalid),
    .read_master_axi_rdata              (read_master_axi_rdata),
    .read_master_axi_rid                (read_master_axi_rid),
    .read_master_axi_rlast              (read_master_axi_rlast),
    .read_master_axi_rready             (read_master_axi_rready),
    .read_master_axi_rresp              (read_master_axi_rresp),
    .read_master_axi_rvalid             (read_master_axi_rvalid),
    .read_master_axi_wdata              (read_master_axi_wdata),
    .read_master_axi_wlast              (read_master_axi_wlast),
    .read_master_axi_wready             (read_master_axi_wready),
    .read_master_axi_wstrb              (read_master_axi_wstrb),
    .read_master_axi_wvalid             (read_master_axi_wvalid),

    // Prefetcher Weights RM -> AXI Memory Interconnect
    .weight_bank_axi_araddr     (weight_bank_axi_araddr),
    .weight_bank_axi_arburst    (weight_bank_axi_arburst),
    .weight_bank_axi_arcache    (weight_bank_axi_arcache),
    .weight_bank_axi_arid       (weight_bank_axi_arid),
    .weight_bank_axi_arlen      (weight_bank_axi_arlen),
    .weight_bank_axi_arlock     (weight_bank_axi_arlock),
    .weight_bank_axi_arprot     (weight_bank_axi_arprot),
    .weight_bank_axi_arqos      (weight_bank_axi_arqos),
    .weight_bank_axi_arsize     (weight_bank_axi_arsize),
    .weight_bank_axi_arvalid    (weight_bank_axi_arvalid),
    .weight_bank_axi_arready    (weight_bank_axi_arready),
    .weight_bank_axi_awaddr     (weight_bank_axi_awaddr),
    .weight_bank_axi_awburst    (weight_bank_axi_awburst),
    .weight_bank_axi_awcache    (weight_bank_axi_awcache),
    .weight_bank_axi_awid       (weight_bank_axi_awid),
    .weight_bank_axi_awlen      (weight_bank_axi_awlen),
    .weight_bank_axi_awlock     (weight_bank_axi_awlock),
    .weight_bank_axi_awprot     (weight_bank_axi_awprot),
    .weight_bank_axi_awqos      (weight_bank_axi_awqos),
    .weight_bank_axi_awready    (weight_bank_axi_awready),
    .weight_bank_axi_awsize     (weight_bank_axi_awsize),
    .weight_bank_axi_awvalid    (weight_bank_axi_awvalid),
    .weight_bank_axi_bid        (weight_bank_axi_bid),
    .weight_bank_axi_bready     (weight_bank_axi_bready),
    .weight_bank_axi_bresp      (weight_bank_axi_bresp),
    .weight_bank_axi_bvalid     (weight_bank_axi_bvalid),
    .weight_bank_axi_rdata      (weight_bank_axi_rdata),
    .weight_bank_axi_rid        (weight_bank_axi_rid),
    .weight_bank_axi_rlast      (weight_bank_axi_rlast),
    .weight_bank_axi_rready     (weight_bank_axi_rready),
    .weight_bank_axi_rresp      (weight_bank_axi_rresp),
    .weight_bank_axi_rvalid     (weight_bank_axi_rvalid),
    .weight_bank_axi_wdata      (weight_bank_axi_wdata),
    .weight_bank_axi_wlast      (weight_bank_axi_wlast),
    .weight_bank_axi_wready     (weight_bank_axi_wready),
    .weight_bank_axi_wstrb      (weight_bank_axi_wstrb),
    .weight_bank_axi_wvalid     (weight_bank_axi_wvalid),

    // Message Channels: AGE -> Prefetcher
    .message_channel_req_valid                                 (message_channel_req_valid),
    .message_channel_req_ready                                 (message_channel_req_ready),
    .message_channel_req                                       (message_channel_req),

    .message_channel_resp_valid                                (message_channel_resp_valid),
    .message_channel_resp_ready                                (message_channel_resp_ready),
    .message_channel_resp                                      (message_channel_resp),

    .weight_channel_req_valid                                  (weight_channel_req_valid),
    .weight_channel_req_ready                                  (weight_channel_req_ready),
    .weight_channel_req                                        (weight_channel_req),

    .weight_channel_resp_valid                                 (weight_channel_resp_valid),
    .weight_channel_resp_ready                                 (weight_channel_resp_ready),
    .weight_channel_resp                                       (weight_channel_resp),

    .scale_factor_queue_pop                                    (scale_factor_queue_pop),
    .scale_factor_queue_out_data                               (scale_factor_queue_out_data),
    .scale_factor_queue_out_valid                              (scale_factor_queue_out_valid),
    .scale_factor_queue_count                                  (scale_factor_queue_count),
    .scale_factor_queue_empty                                  (scale_factor_queue_empty),
    .scale_factor_queue_full                                   (scale_factor_queue_full)
);

// ====================================================================================
// Aggregation Engine
// ====================================================================================

aggregation_engine aggregation_engine_i (
    .core_clk                                     (sys_clk),
    .resetn                                       (!sys_rst),

    .regbank_clk                                               (regbank_clk),
    .regbank_resetn                                            (regbank_resetn),
    
    // Node Scoreboard -> Aggregation Engine Interface
    .nsb_age_req_valid                            (nsb_age_req_valid),
    .nsb_age_req_ready                            (nsb_age_req_ready),
    .nsb_age_req                                  (nsb_age_req),

    .nsb_age_resp_valid                           (nsb_age_resp_valid),
    .nsb_age_resp                                 (nsb_age_resp),

    // Regbank Slave AXI interface
    .s_axi_awaddr                                 (axil_interconnect_m_axi_awaddr     [31:0]),
    .s_axi_awprot                                 (axil_interconnect_m_axi_awprot     [2:0]),
    .s_axi_awvalid                                (axil_interconnect_m_axi_awvalid    [0]),
    .s_axi_awready                                (axil_interconnect_m_axi_awready    [0]),
    .s_axi_wdata                                  (axil_interconnect_m_axi_wdata      [31:0]),
    .s_axi_wstrb                                  (axil_interconnect_m_axi_wstrb      [3:0]),
    .s_axi_wvalid                                 (axil_interconnect_m_axi_wvalid     [0]),
    .s_axi_wready                                 (axil_interconnect_m_axi_wready     [0]),
    .s_axi_bresp                                  (axil_interconnect_m_axi_bresp      [1:0]),
    .s_axi_bvalid                                 (axil_interconnect_m_axi_bvalid     [0]),
    .s_axi_bready                                 (axil_interconnect_m_axi_bready     [0]),
    .s_axi_araddr                                 (axil_interconnect_m_axi_araddr     [31:0]),
    .s_axi_arprot                                 (axil_interconnect_m_axi_arprot     [2:0]),
    .s_axi_arvalid                                (axil_interconnect_m_axi_arvalid    [0]),
    .s_axi_arready                                (axil_interconnect_m_axi_arready    [0]),
    .s_axi_rdata                                  (axil_interconnect_m_axi_rdata      [31:0]),
    .s_axi_rresp                                  (axil_interconnect_m_axi_rresp      [1:0]),
    .s_axi_rvalid                                 (axil_interconnect_m_axi_rvalid     [0]),
    .s_axi_rready                                 (axil_interconnect_m_axi_rready     [0]),

    .message_channel_req_valid                    (message_channel_req_valid),
    .message_channel_req_ready                    (message_channel_req_ready),
    .message_channel_req                          (message_channel_req),

    .message_channel_resp_valid                   (message_channel_resp_valid),
    .message_channel_resp_ready                   (message_channel_resp_ready),
    .message_channel_resp                         (message_channel_resp),

    .aggregation_buffer_slot_set_node_id_valid    (aggregation_buffer_set_node_id_valid),
    .aggregation_buffer_slot_set_node_id          (aggregation_buffer_set_node_id),

    .aggregation_buffer_slot_write_enable         (aggregation_buffer_write_enable),
    .aggregation_buffer_slot_write_address        (aggregation_buffer_write_address),
    .aggregation_buffer_slot_write_data           (aggregation_buffer_write_data),

    .aggregation_buffer_slot_feature_count        (aggregation_buffer_feature_count),
    .aggregation_buffer_slot_slot_free            (aggregation_buffer_slot_free),

    .scale_factor_queue_pop                       (scale_factor_queue_pop),
    .scale_factor_queue_out_data                  (scale_factor_queue_out_data),
    .scale_factor_queue_out_valid                 (scale_factor_queue_out_valid)
);

// ====================================================================================
// Aggregation Buffer
// ====================================================================================

for (genvar precision = top_pkg::FLOAT_32; precision < top_pkg::PRECISION_COUNT; precision++) begin

    hybrid_buffer #(
        .NUM_SLOTS   (top_pkg::AGGREGATION_BUFFER_SLOTS),
        .WRITE_WIDTH (top_pkg::AGGREGATION_BUFFER_WRITE_WIDTH),
        .WRITE_DEPTH (top_pkg::AGGREGATION_BUFFER_WRITE_DEPTH),
        .READ_WIDTH  (top_pkg::AGGREGATION_BUFFER_READ_WIDTH),
        .READ_DEPTH  (top_pkg::AGGREGATION_BUFFER_READ_DEPTH)
    ) aggregation_buffer_i (
        .core_clk           (sys_clk),
        .resetn             (!sys_rst),

        .set_node_id_valid  (aggregation_buffer_set_node_id_valid [precision]),
        .set_node_id        (aggregation_buffer_set_node_id       [precision]),
        .slot_node_id       (aggregation_buffer_node_id           [precision]),

        .write_enable       (aggregation_buffer_write_enable    [precision]),
        .write_address      (aggregation_buffer_write_address   [precision]),
        .write_data         (aggregation_buffer_write_data      [precision]),
        .feature_count      (aggregation_buffer_feature_count   [precision]),

        .pop                (aggregation_buffer_pop               [precision]),
        .out_feature        (aggregation_buffer_out_feature       [precision]),
        .out_feature_valid  (aggregation_buffer_out_feature_valid [precision]),
        .slot_free          (aggregation_buffer_slot_free         [precision])

    );
end


// ====================================================================================
// Transformation Engine
// ====================================================================================

feature_transformation_engine transformation_engine_i (
    .core_clk                                           (sys_clk),
    .resetn                                             (!sys_rst),

    .regbank_clk                                               (regbank_clk),
    .regbank_resetn                                            (regbank_resetn),

    // AXI-L interface
    .s_axi_awaddr                                       (axil_interconnect_m_axi_awaddr     [63:32]), // input
    .s_axi_awprot                                       (axil_interconnect_m_axi_awprot     [5:3]), // input
    .s_axi_awvalid                                      (axil_interconnect_m_axi_awvalid    [1:1]), // input
    .s_axi_awready                                      (axil_interconnect_m_axi_awready    [1:1]), // output
    .s_axi_wdata                                        (axil_interconnect_m_axi_wdata      [63:32]), // input
    .s_axi_wstrb                                        (axil_interconnect_m_axi_wstrb      [7:4]), // input
    .s_axi_wvalid                                       (axil_interconnect_m_axi_wvalid     [1:1]), // input
    .s_axi_wready                                       (axil_interconnect_m_axi_wready     [1:1]), // output
    .s_axi_araddr                                       (axil_interconnect_m_axi_araddr     [63:32]), // input
    .s_axi_arprot                                       (axil_interconnect_m_axi_arprot     [5:3]), // input
    .s_axi_arvalid                                      (axil_interconnect_m_axi_arvalid    [1:1]), // input
    .s_axi_arready                                      (axil_interconnect_m_axi_arready    [1:1]), // output
    .s_axi_rdata                                        (axil_interconnect_m_axi_rdata      [63:32]), // output
    .s_axi_rresp                                        (axil_interconnect_m_axi_rresp      [3:2]), // output
    .s_axi_rvalid                                       (axil_interconnect_m_axi_rvalid     [1:1]), // output
    .s_axi_rready                                       (axil_interconnect_m_axi_rready     [1:1]), // input
    .s_axi_bresp                                        (axil_interconnect_m_axi_bresp      [3:2]), // output
    .s_axi_bvalid                                       (axil_interconnect_m_axi_bvalid     [1:1]), // output
    .s_axi_bready                                       (axil_interconnect_m_axi_bready     [1:1]), // input

    // Node Scoreboard -> Transformation Engine Interface
    .nsb_fte_req_valid                                  (nsb_fte_req_valid),
    .nsb_fte_req_ready                                  (nsb_fte_req_ready),
    .nsb_fte_req                                        (nsb_fte_req),
    .nsb_fte_resp_valid                                 (nsb_fte_resp_valid),
    .nsb_fte_resp                                       (nsb_fte_resp),

    .aggregation_buffer_node_id                         (aggregation_buffer_node_id),
    .aggregation_buffer_pop                             (aggregation_buffer_pop),
    .aggregation_buffer_out_feature_valid               (aggregation_buffer_out_feature_valid),
    .aggregation_buffer_out_feature                     (aggregation_buffer_out_feature),
    .aggregation_buffer_slot_free                       (aggregation_buffer_slot_free),

    .weight_channel_req_valid                           (weight_channel_req_valid),
    .weight_channel_req_ready                           (weight_channel_req_ready),
    .weight_channel_req                                 (weight_channel_req),
    .weight_channel_resp_valid                          (weight_channel_resp_valid),
    .weight_channel_resp_ready                          (weight_channel_resp_ready),
    .weight_channel_resp                                (weight_channel_resp),

    .transformation_engine_axi_interconnect_axi_araddr    (transformation_engine_axi_araddr),
    .transformation_engine_axi_interconnect_axi_arburst   (transformation_engine_axi_arburst),
    .transformation_engine_axi_interconnect_axi_arcache   (transformation_engine_axi_arcache),
    .transformation_engine_axi_interconnect_axi_arid      (transformation_engine_axi_arid),
    .transformation_engine_axi_interconnect_axi_arlen     (transformation_engine_axi_arlen),
    .transformation_engine_axi_interconnect_axi_arlock    (transformation_engine_axi_arlock),
    .transformation_engine_axi_interconnect_axi_arprot    (transformation_engine_axi_arprot),
    .transformation_engine_axi_interconnect_axi_arqos     (transformation_engine_axi_arqos),
    .transformation_engine_axi_interconnect_axi_arsize    (transformation_engine_axi_arsize),
    .transformation_engine_axi_interconnect_axi_arvalid   (transformation_engine_axi_arvalid),
    .transformation_engine_axi_interconnect_axi_arready   (transformation_engine_axi_arready),
    .transformation_engine_axi_interconnect_axi_awaddr    (transformation_engine_axi_awaddr),
    .transformation_engine_axi_interconnect_axi_awburst   (transformation_engine_axi_awburst),
    .transformation_engine_axi_interconnect_axi_awcache   (transformation_engine_axi_awcache),
    .transformation_engine_axi_interconnect_axi_awid      (transformation_engine_axi_awid),
    .transformation_engine_axi_interconnect_axi_awlen     (transformation_engine_axi_awlen),
    .transformation_engine_axi_interconnect_axi_awlock    (transformation_engine_axi_awlock),
    .transformation_engine_axi_interconnect_axi_awprot    (transformation_engine_axi_awprot),
    .transformation_engine_axi_interconnect_axi_awqos     (transformation_engine_axi_awqos),
    .transformation_engine_axi_interconnect_axi_awready   (transformation_engine_axi_awready),
    .transformation_engine_axi_interconnect_axi_awsize    (transformation_engine_axi_awsize),
    .transformation_engine_axi_interconnect_axi_awvalid   (transformation_engine_axi_awvalid),
    .transformation_engine_axi_interconnect_axi_bid       (transformation_engine_axi_bid),
    .transformation_engine_axi_interconnect_axi_bready    (transformation_engine_axi_bready),
    .transformation_engine_axi_interconnect_axi_bresp     (transformation_engine_axi_bresp),
    .transformation_engine_axi_interconnect_axi_bvalid    (transformation_engine_axi_bvalid),
    .transformation_engine_axi_interconnect_axi_rdata     (transformation_engine_axi_rdata),
    .transformation_engine_axi_interconnect_axi_rid       (transformation_engine_axi_rid),
    .transformation_engine_axi_interconnect_axi_rlast     (transformation_engine_axi_rlast),
    .transformation_engine_axi_interconnect_axi_rready    (transformation_engine_axi_rready),
    .transformation_engine_axi_interconnect_axi_rresp     (transformation_engine_axi_rresp),
    .transformation_engine_axi_interconnect_axi_rvalid    (transformation_engine_axi_rvalid),
    .transformation_engine_axi_interconnect_axi_wdata     (transformation_engine_axi_wdata),
    .transformation_engine_axi_interconnect_axi_wlast     (transformation_engine_axi_wlast),
    .transformation_engine_axi_interconnect_axi_wready    (transformation_engine_axi_wready),
    .transformation_engine_axi_interconnect_axi_wstrb     (transformation_engine_axi_wstrb),
    .transformation_engine_axi_interconnect_axi_wvalid    (transformation_engine_axi_wvalid)
);

// ====================================================================================
// AXI-L Register Control Crossbar
// ====================================================================================

// axil interconnect uses either M<x>_BASE_ADDR or M<x>_ADDR_WIDTH
// to calculate ranges for each master
// setting ADDR_WIDTH to 30 for each master leads to 4 regular ranges
// (see calcBaseAddrs function)
axil_interconnect_wrap_1x4 #(
    .ADDR_WIDTH     (32),
    
    .M00_ADDR_WIDTH (30),
    .M01_ADDR_WIDTH (30),
    .M02_ADDR_WIDTH (30),
    .M03_ADDR_WIDTH (30)
) axil_interconnect_i (
    .clk                            (regbank_clk),
    .rst                            (!regbank_resetn),

    /*
     * AXI lite slave interfaces
      */
    .s00_axil_awaddr                (host_axil_awaddr),
    .s00_axil_awprot                (host_axil_awprot),
    .s00_axil_awvalid               (host_axil_awvalid),
    .s00_axil_awready               (host_axil_awready),
    .s00_axil_wdata                 (host_axil_wdata),
    .s00_axil_wstrb                 (host_axil_wstrb),
    .s00_axil_wvalid                (host_axil_wvalid),
    .s00_axil_wready                (host_axil_wready),
    .s00_axil_bresp                 (host_axil_bresp),
    .s00_axil_bvalid                (host_axil_bvalid),
    .s00_axil_bready                (host_axil_bready),
    .s00_axil_araddr                (host_axil_araddr),
    .s00_axil_arprot                (host_axil_arprot),
    .s00_axil_arvalid               (host_axil_arvalid),
    .s00_axil_arready               (host_axil_arready),
    .s00_axil_rdata                 (host_axil_rdata),
    .s00_axil_rresp                 (host_axil_rresp),
    .s00_axil_rvalid                (host_axil_rvalid),
    .s00_axil_rready                (host_axil_rready),

    /*
     * AXI lite master interfaces
    */
    .m00_axil_awaddr                (axil_interconnect_m_axi_awaddr     [31:0]),
    .m00_axil_awprot                (axil_interconnect_m_axi_awprot     [2:0]),
    .m00_axil_awvalid               (axil_interconnect_m_axi_awvalid    [0]),
    .m00_axil_awready               (axil_interconnect_m_axi_awready    [0]),
    .m00_axil_wdata                 (axil_interconnect_m_axi_wdata      [31:0]),
    .m00_axil_wstrb                 (axil_interconnect_m_axi_wstrb      [3:0]),
    .m00_axil_wvalid                (axil_interconnect_m_axi_wvalid     [0]),
    .m00_axil_wready                (axil_interconnect_m_axi_wready     [0]),
    .m00_axil_bresp                 (axil_interconnect_m_axi_bresp      [1:0]),
    .m00_axil_bvalid                (axil_interconnect_m_axi_bvalid     [0]),
    .m00_axil_bready                (axil_interconnect_m_axi_bready     [0]),
    .m00_axil_araddr                (axil_interconnect_m_axi_araddr     [31:0]),
    .m00_axil_arprot                (axil_interconnect_m_axi_arprot     [2:0]),
    .m00_axil_arvalid               (axil_interconnect_m_axi_arvalid    [0]),
    .m00_axil_arready               (axil_interconnect_m_axi_arready    [0]),
    .m00_axil_rdata                 (axil_interconnect_m_axi_rdata      [31:0]),
    .m00_axil_rresp                 (axil_interconnect_m_axi_rresp      [1:0]),
    .m00_axil_rvalid                (axil_interconnect_m_axi_rvalid     [0]),
    .m00_axil_rready                (axil_interconnect_m_axi_rready     [0]),

    .m01_axil_awaddr                (axil_interconnect_m_axi_awaddr     [63:32]),
    .m01_axil_awprot                (axil_interconnect_m_axi_awprot     [5:3]),
    .m01_axil_awvalid               (axil_interconnect_m_axi_awvalid    [1:1]),
    .m01_axil_awready               (axil_interconnect_m_axi_awready    [1:1]),
    .m01_axil_wdata                 (axil_interconnect_m_axi_wdata      [63:32]),
    .m01_axil_wstrb                 (axil_interconnect_m_axi_wstrb      [7:4]),
    .m01_axil_wvalid                (axil_interconnect_m_axi_wvalid     [1:1]),
    .m01_axil_wready                (axil_interconnect_m_axi_wready     [1:1]),
    .m01_axil_bresp                 (axil_interconnect_m_axi_bresp      [3:2]),
    .m01_axil_bvalid                (axil_interconnect_m_axi_bvalid     [1:1]),
    .m01_axil_bready                (axil_interconnect_m_axi_bready     [1:1]),
    .m01_axil_araddr                (axil_interconnect_m_axi_araddr     [63:32]),
    .m01_axil_arprot                (axil_interconnect_m_axi_arprot     [5:3]),
    .m01_axil_arvalid               (axil_interconnect_m_axi_arvalid    [1:1]),
    .m01_axil_arready               (axil_interconnect_m_axi_arready    [1:1]),
    .m01_axil_rdata                 (axil_interconnect_m_axi_rdata      [63:32]),
    .m01_axil_rresp                 (axil_interconnect_m_axi_rresp      [3:2]),
    .m01_axil_rvalid                (axil_interconnect_m_axi_rvalid     [1:1]),
    .m01_axil_rready                (axil_interconnect_m_axi_rready     [1:1]),

    .m02_axil_awaddr                (axil_interconnect_m_axi_awaddr     [95:64]),
    .m02_axil_awprot                (axil_interconnect_m_axi_awprot     [8:6]),
    .m02_axil_awvalid               (axil_interconnect_m_axi_awvalid    [2:2]),
    .m02_axil_awready               (axil_interconnect_m_axi_awready    [2:2]),
    .m02_axil_wdata                 (axil_interconnect_m_axi_wdata      [95:64]),
    .m02_axil_wstrb                 (axil_interconnect_m_axi_wstrb      [11:8]),
    .m02_axil_wvalid                (axil_interconnect_m_axi_wvalid     [2:2]),
    .m02_axil_wready                (axil_interconnect_m_axi_wready     [2:2]),
    .m02_axil_bresp                 (axil_interconnect_m_axi_bresp      [5:4]),
    .m02_axil_bvalid                (axil_interconnect_m_axi_bvalid     [2:2]),
    .m02_axil_bready                (axil_interconnect_m_axi_bready     [2:2]),
    .m02_axil_araddr                (axil_interconnect_m_axi_araddr     [95:64]),
    .m02_axil_arprot                (axil_interconnect_m_axi_arprot     [8:6]),
    .m02_axil_arvalid               (axil_interconnect_m_axi_arvalid    [2:2]),
    .m02_axil_arready               (axil_interconnect_m_axi_arready    [2:2]),
    .m02_axil_rdata                 (axil_interconnect_m_axi_rdata      [95:64]),
    .m02_axil_rresp                 (axil_interconnect_m_axi_rresp      [5:4]),
    .m02_axil_rvalid                (axil_interconnect_m_axi_rvalid     [2:2]),
    .m02_axil_rready                (axil_interconnect_m_axi_rready     [2:2]),
 
    .m03_axil_awaddr                (axil_interconnect_m_axi_awaddr     [127:96]),
    .m03_axil_awprot                (axil_interconnect_m_axi_awprot     [11:9]),
    .m03_axil_awvalid               (axil_interconnect_m_axi_awvalid    [3:3]),
    .m03_axil_awready               (axil_interconnect_m_axi_awready    [3:3]),
    .m03_axil_wdata                 (axil_interconnect_m_axi_wdata      [127:96]),
    .m03_axil_wstrb                 (axil_interconnect_m_axi_wstrb      [15:12]),
    .m03_axil_wvalid                (axil_interconnect_m_axi_wvalid     [3:3]),
    .m03_axil_wready                (axil_interconnect_m_axi_wready     [3:3]),
    .m03_axil_bresp                 (axil_interconnect_m_axi_bresp      [7:6]),
    .m03_axil_bvalid                (axil_interconnect_m_axi_bvalid     [3:3]),
    .m03_axil_bready                (axil_interconnect_m_axi_bready     [3:3]),
    .m03_axil_araddr                (axil_interconnect_m_axi_araddr     [127:96]),
    .m03_axil_arprot                (axil_interconnect_m_axi_arprot     [11:9]),
    .m03_axil_arvalid               (axil_interconnect_m_axi_arvalid    [3:3]),
    .m03_axil_arready               (axil_interconnect_m_axi_arready    [3:3]),
    .m03_axil_rdata                 (axil_interconnect_m_axi_rdata      [127:96]),
    .m03_axil_rresp                 (axil_interconnect_m_axi_rresp      [7:6]),
    .m03_axil_rvalid                (axil_interconnect_m_axi_rvalid     [3:3]),
    .m03_axil_rready                (axil_interconnect_m_axi_rready     [3:3])
);

// ====================================================================================
// Weight RAM
// ====================================================================================

axi_ram #(
    .DATA_WIDTH(512),
    .ADDR_WIDTH(34),
    .ID_WIDTH(8)
) weight_ram_i (
    .clk                    (sys_clk),
    .rst                    (sys_rst),

    .s_axi_awid             (weight_bank_axi_awid),
    .s_axi_awaddr           (weight_bank_axi_awaddr),
    .s_axi_awlen            (weight_bank_axi_awlen),
    .s_axi_awsize           (weight_bank_axi_awsize),
    .s_axi_awburst          (weight_bank_axi_awburst),
    .s_axi_awlock           (weight_bank_axi_awlock),
    .s_axi_awcache          (weight_bank_axi_awcache),
    .s_axi_awprot           (weight_bank_axi_awprot),
    .s_axi_awvalid          (weight_bank_axi_awvalid),
    .s_axi_awready          (weight_bank_axi_awready),
    .s_axi_wdata            (weight_bank_axi_wdata),
    .s_axi_wstrb            (weight_bank_axi_wstrb),
    .s_axi_wlast            (weight_bank_axi_wlast),
    .s_axi_wvalid           (weight_bank_axi_wvalid),
    .s_axi_wready           (weight_bank_axi_wready),
    .s_axi_bid              (weight_bank_axi_bid),
    .s_axi_bresp            (weight_bank_axi_bresp),
    .s_axi_bvalid           (weight_bank_axi_bvalid),
    .s_axi_bready           (weight_bank_axi_bready),
    .s_axi_arid             (weight_bank_axi_arid),
    .s_axi_araddr           (weight_bank_axi_araddr),
    .s_axi_arlen            (weight_bank_axi_arlen),
    .s_axi_arsize           (weight_bank_axi_arsize),
    .s_axi_arburst          (weight_bank_axi_arburst),
    .s_axi_arlock           (weight_bank_axi_arlock),
    .s_axi_arcache          (weight_bank_axi_arcache),
    .s_axi_arprot           (weight_bank_axi_arprot),
    .s_axi_arvalid          (weight_bank_axi_arvalid),
    .s_axi_arready          (weight_bank_axi_arready),
    .s_axi_rid              (weight_bank_axi_rid),
    .s_axi_rdata            (weight_bank_axi_rdata),
    .s_axi_rresp            (weight_bank_axi_rresp),
    .s_axi_rlast            (weight_bank_axi_rlast),
    .s_axi_rvalid           (weight_bank_axi_rvalid),
    .s_axi_rready           (weight_bank_axi_rready)
);

endmodule