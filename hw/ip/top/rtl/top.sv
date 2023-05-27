`timescale 1ps/1ps

import top_pkg::*;

module top
(
    input logic                           sys_clk,
    input                                 sys_rst, //Common port for all controllers
    
    // AXI-L interface to Host
    input  logic [31 : 0]                 host_axil_awaddr,
    input  logic [2 : 0]                  host_axil_awprot,
    input  logic [0 : 0]                  host_axil_awvalid,
    output logic [0 : 0]                  host_axil_awready,
    input  logic [31 : 0]                 host_axil_wdata,
    input  logic [3 : 0]                  host_axil_wstrb,
    input  logic [0 : 0]                  host_axil_wvalid,
    input  logic [0 : 0]                  host_axil_bready,
    input  logic [31 : 0]                 host_axil_araddr,
    input  logic [2 : 0]                  host_axil_arprot,
    input  logic [0 : 0]                  host_axil_arvalid,
    input  logic [0 : 0]                  host_axil_rready,
    output logic [0 : 0]                  host_axil_wready,
    output logic [1 : 0]                  host_axil_bresp,
    output logic [0 : 0]                  host_axil_bvalid,
    output logic [0 : 0]                  host_axil_arready,
    output logic [31 : 0]                 host_axil_rdata,
    output logic [1 : 0]                  host_axil_rresp,
    output logic [0 : 0]                  host_axil_rvalid,
       
    // AXI Memory Interconnect -> Memory (Routed to DRAM Controller if `DRAM_CONTROLLER defined)
    output logic  [7:0]                   c0_ddr4_s_axi_awid,
    output logic  [33:0]                  c0_ddr4_s_axi_awaddr,
    output logic  [7:0]                   c0_ddr4_s_axi_awlen,
    output logic  [2:0]                   c0_ddr4_s_axi_awsize,
    output logic  [1:0]                   c0_ddr4_s_axi_awburst,
    output logic  [0:0]                   c0_ddr4_s_axi_awlock,
    output logic  [3:0]                   c0_ddr4_s_axi_awcache,
    output logic  [2:0]                   c0_ddr4_s_axi_awprot,
    output logic  [3:0]                   c0_ddr4_s_axi_awqos,
    output logic                          c0_ddr4_s_axi_awvalid,
    input  logic                          c0_ddr4_s_axi_awready,

    output logic  [511:0]                 c0_ddr4_s_axi_wdata,
    output logic  [63:0]                  c0_ddr4_s_axi_wstrb,
    output logic                          c0_ddr4_s_axi_wlast,
    output logic                          c0_ddr4_s_axi_wvalid,
    input  logic                          c0_ddr4_s_axi_wready,
    
    input  logic [7:0]                    c0_ddr4_s_axi_bid,
    input  logic [1:0]                    c0_ddr4_s_axi_bresp,
    input  logic                          c0_ddr4_s_axi_bvalid,
    output logic                          c0_ddr4_s_axi_bready,
    
    output logic  [7:0]                   c0_ddr4_s_axi_arid,
    output logic  [33:0]                  c0_ddr4_s_axi_araddr,
    output logic  [7:0]                   c0_ddr4_s_axi_arlen,
    output logic  [2:0]                   c0_ddr4_s_axi_arsize,
    output logic  [1:0]                   c0_ddr4_s_axi_arburst,
    output logic  [0:0]                   c0_ddr4_s_axi_arlock,
    output logic  [3:0]                   c0_ddr4_s_axi_arcache,
    output logic  [2:0]                   c0_ddr4_s_axi_arprot,
    output logic  [3:0]                   c0_ddr4_s_axi_arqos,
    output logic                          c0_ddr4_s_axi_arvalid,
    input  logic                          c0_ddr4_s_axi_arready,
    
    input  logic [7:0]                    c0_ddr4_s_axi_rid,
    input  logic [511:0]                  c0_ddr4_s_axi_rdata,
    input  logic [1:0]                    c0_ddr4_s_axi_rresp,
    input  logic                          c0_ddr4_s_axi_rlast,
    input  logic                          c0_ddr4_s_axi_rvalid,
    output logic                          c0_ddr4_s_axi_rready,

    // DDR4
    input                                 c0_sys_clk_p,
    input                                 c0_sys_clk_n,
    output                                c0_ddr4_act_n,
    output [16:0]                         c0_ddr4_adr,
    output [1:0]                          c0_ddr4_ba,
    output [1:0]                          c0_ddr4_bg,
    output [0:0]                          c0_ddr4_cke,
    output [0:0]                          c0_ddr4_odt,
    output [0:0]                          c0_ddr4_cs_n,
    output [0:0]                          c0_ddr4_ck_t,
    output [0:0]                          c0_ddr4_ck_c,
    output                                c0_ddr4_reset_n,
    output                                c0_ddr4_parity,
    inout  [71:0]                         c0_ddr4_dq,
    inout  [17:0]                         c0_ddr4_dqs_t,
    inout  [17:0]                         c0_ddr4_dqs_c,
    output                                c0_init_calib_complete,
    output                                c0_data_compare_error
);

// ====================================================================================
// Declarations
// ====================================================================================

logic                             c0_ddr4_clk;
logic                             c0_ddr4_rst;
logic                             dbg_clk;
logic                             c0_ddr4_aresetn;

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

`ifdef DRAM_CONTROLLER
// Debug Bus
logic [511:0]                         dbg_bus;
`endif

logic c0_ddr4_reset_n_int;
assign c0_ddr4_reset_n = c0_ddr4_reset_n_int;

// Prefetcher Adj RM -> AXI Memory Interconnect (Read Only)
logic [33:0]                       prefetcher_adj_rm_axi_interconnect_axi_araddr;
logic [1:0]                        prefetcher_adj_rm_axi_interconnect_axi_arburst;
logic [3:0]                        prefetcher_adj_rm_axi_interconnect_axi_arcache;
logic [3:0]                        prefetcher_adj_rm_axi_interconnect_axi_arid;
logic [7:0]                        prefetcher_adj_rm_axi_interconnect_axi_arlen;
logic [0:0]                        prefetcher_adj_rm_axi_interconnect_axi_arlock;
logic [2:0]                        prefetcher_adj_rm_axi_interconnect_axi_arprot;
logic [3:0]                        prefetcher_adj_rm_axi_interconnect_axi_arqos;
logic [2:0]                        prefetcher_adj_rm_axi_interconnect_axi_arsize;
logic                              prefetcher_adj_rm_axi_interconnect_axi_arvalid;
logic                              prefetcher_adj_rm_axi_interconnect_axi_arready;
logic [33:0]                       prefetcher_adj_rm_axi_interconnect_axi_awaddr;
logic [1:0]                        prefetcher_adj_rm_axi_interconnect_axi_awburst;
logic [3:0]                        prefetcher_adj_rm_axi_interconnect_axi_awcache;
logic [3:0]                        prefetcher_adj_rm_axi_interconnect_axi_awid;
logic [7:0]                        prefetcher_adj_rm_axi_interconnect_axi_awlen;
logic [0:0]                        prefetcher_adj_rm_axi_interconnect_axi_awlock;
logic [2:0]                        prefetcher_adj_rm_axi_interconnect_axi_awprot;
logic [3:0]                        prefetcher_adj_rm_axi_interconnect_axi_awqos;
logic                              prefetcher_adj_rm_axi_interconnect_axi_awready;
logic [2:0]                        prefetcher_adj_rm_axi_interconnect_axi_awsize;
logic                              prefetcher_adj_rm_axi_interconnect_axi_awvalid;
logic [3:0]                        prefetcher_adj_rm_axi_interconnect_axi_bid;
logic                              prefetcher_adj_rm_axi_interconnect_axi_bready;
logic [1:0]                        prefetcher_adj_rm_axi_interconnect_axi_bresp;
logic                              prefetcher_adj_rm_axi_interconnect_axi_bvalid;
logic [511:0]                      prefetcher_adj_rm_axi_interconnect_axi_rdata;
logic [3:0]                        prefetcher_adj_rm_axi_interconnect_axi_rid;
logic                              prefetcher_adj_rm_axi_interconnect_axi_rlast;
logic                              prefetcher_adj_rm_axi_interconnect_axi_rready;
logic [1:0]                        prefetcher_adj_rm_axi_interconnect_axi_rresp;
logic                              prefetcher_adj_rm_axi_interconnect_axi_rvalid;
logic [511:0]                      prefetcher_adj_rm_axi_interconnect_axi_wdata;
logic                              prefetcher_adj_rm_axi_interconnect_axi_wlast;
logic                              prefetcher_adj_rm_axi_interconnect_axi_wready;
logic [63:0]                       prefetcher_adj_rm_axi_interconnect_axi_wstrb;
logic                              prefetcher_adj_rm_axi_interconnect_axi_wvalid;

// Prefetcher Msg RM -> AXI Memory Interconnect (Read Only)
logic [33:0]                       prefetcher_msg_rm_axi_interconnect_axi_araddr;
logic [1:0]                        prefetcher_msg_rm_axi_interconnect_axi_arburst;
logic [3:0]                        prefetcher_msg_rm_axi_interconnect_axi_arcache;
logic [3:0]                        prefetcher_msg_rm_axi_interconnect_axi_arid;
logic [7:0]                        prefetcher_msg_rm_axi_interconnect_axi_arlen;
logic [0:0]                        prefetcher_msg_rm_axi_interconnect_axi_arlock;
logic [2:0]                        prefetcher_msg_rm_axi_interconnect_axi_arprot;
logic [3:0]                        prefetcher_msg_rm_axi_interconnect_axi_arqos;
logic [2:0]                        prefetcher_msg_rm_axi_interconnect_axi_arsize;
logic                              prefetcher_msg_rm_axi_interconnect_axi_arvalid;
logic                              prefetcher_msg_rm_axi_interconnect_axi_arready;
logic [33:0]                       prefetcher_msg_rm_axi_interconnect_axi_awaddr;
logic [1:0]                        prefetcher_msg_rm_axi_interconnect_axi_awburst;
logic [3:0]                        prefetcher_msg_rm_axi_interconnect_axi_awcache;
logic [3:0]                        prefetcher_msg_rm_axi_interconnect_axi_awid;
logic [7:0]                        prefetcher_msg_rm_axi_interconnect_axi_awlen;
logic [0:0]                        prefetcher_msg_rm_axi_interconnect_axi_awlock;
logic [2:0]                        prefetcher_msg_rm_axi_interconnect_axi_awprot;
logic [3:0]                        prefetcher_msg_rm_axi_interconnect_axi_awqos;
logic                              prefetcher_msg_rm_axi_interconnect_axi_awready;
logic [2:0]                        prefetcher_msg_rm_axi_interconnect_axi_awsize;
logic                              prefetcher_msg_rm_axi_interconnect_axi_awvalid;
logic [3:0]                        prefetcher_msg_rm_axi_interconnect_axi_bid;
logic                              prefetcher_msg_rm_axi_interconnect_axi_bready;
logic [1:0]                        prefetcher_msg_rm_axi_interconnect_axi_bresp;
logic                              prefetcher_msg_rm_axi_interconnect_axi_bvalid;
logic [511:0]                      prefetcher_msg_rm_axi_interconnect_axi_rdata;
logic [3:0]                        prefetcher_msg_rm_axi_interconnect_axi_rid;
logic                              prefetcher_msg_rm_axi_interconnect_axi_rlast;
logic                              prefetcher_msg_rm_axi_interconnect_axi_rready;
logic [1:0]                        prefetcher_msg_rm_axi_interconnect_axi_rresp;
logic                              prefetcher_msg_rm_axi_interconnect_axi_rvalid;
logic [511:0]                      prefetcher_msg_rm_axi_interconnect_axi_wdata;
logic                              prefetcher_msg_rm_axi_interconnect_axi_wlast;
logic                              prefetcher_msg_rm_axi_interconnect_axi_wready;
logic [63:0]                       prefetcher_msg_rm_axi_interconnect_axi_wstrb;
logic                              prefetcher_msg_rm_axi_interconnect_axi_wvalid;

// Prefetcher Weight Bank Read Master -> AXI Memory Interconnect (Read Only)
logic [33:0]                       prefetcher_weight_bank_rm_axi_interconnect_axi_araddr;
logic [1:0]                        prefetcher_weight_bank_rm_axi_interconnect_axi_arburst;
logic [3:0]                        prefetcher_weight_bank_rm_axi_interconnect_axi_arcache;
logic [3:0]                        prefetcher_weight_bank_rm_axi_interconnect_axi_arid;
logic [7:0]                        prefetcher_weight_bank_rm_axi_interconnect_axi_arlen;
logic [0:0]                        prefetcher_weight_bank_rm_axi_interconnect_axi_arlock;
logic [2:0]                        prefetcher_weight_bank_rm_axi_interconnect_axi_arprot;
logic [3:0]                        prefetcher_weight_bank_rm_axi_interconnect_axi_arqos;
logic [2:0]                        prefetcher_weight_bank_rm_axi_interconnect_axi_arsize;
logic                              prefetcher_weight_bank_rm_axi_interconnect_axi_arvalid;
logic                              prefetcher_weight_bank_rm_axi_interconnect_axi_arready;
logic [33:0]                       prefetcher_weight_bank_rm_axi_interconnect_axi_awaddr;
logic [1:0]                        prefetcher_weight_bank_rm_axi_interconnect_axi_awburst;
logic [3:0]                        prefetcher_weight_bank_rm_axi_interconnect_axi_awcache;
logic [3:0]                        prefetcher_weight_bank_rm_axi_interconnect_axi_awid;
logic [7:0]                        prefetcher_weight_bank_rm_axi_interconnect_axi_awlen;
logic [0:0]                        prefetcher_weight_bank_rm_axi_interconnect_axi_awlock;
logic [2:0]                        prefetcher_weight_bank_rm_axi_interconnect_axi_awprot;
logic [3:0]                        prefetcher_weight_bank_rm_axi_interconnect_axi_awqos;
logic                              prefetcher_weight_bank_rm_axi_interconnect_axi_awready;
logic [2:0]                        prefetcher_weight_bank_rm_axi_interconnect_axi_awsize;
logic                              prefetcher_weight_bank_rm_axi_interconnect_axi_awvalid;
logic [3:0]                        prefetcher_weight_bank_rm_axi_interconnect_axi_bid;
logic                              prefetcher_weight_bank_rm_axi_interconnect_axi_bready;
logic [1:0]                        prefetcher_weight_bank_rm_axi_interconnect_axi_bresp;
logic                              prefetcher_weight_bank_rm_axi_interconnect_axi_bvalid;
logic [511:0]                      prefetcher_weight_bank_rm_axi_interconnect_axi_rdata;
logic [3:0]                        prefetcher_weight_bank_rm_axi_interconnect_axi_rid;
logic                              prefetcher_weight_bank_rm_axi_interconnect_axi_rlast;
logic                              prefetcher_weight_bank_rm_axi_interconnect_axi_rready;
logic [1:0]                        prefetcher_weight_bank_rm_axi_interconnect_axi_rresp;
logic                              prefetcher_weight_bank_rm_axi_interconnect_axi_rvalid;
logic [511:0]                      prefetcher_weight_bank_rm_axi_interconnect_axi_wdata;
logic                              prefetcher_weight_bank_rm_axi_interconnect_axi_wlast;
logic                              prefetcher_weight_bank_rm_axi_interconnect_axi_wready;
logic [63:0]                       prefetcher_weight_bank_rm_axi_interconnect_axi_wstrb;
logic                              prefetcher_weight_bank_rm_axi_interconnect_axi_wvalid;

// Output Buffer -> AXI Memory Interconnect (Write Only)
logic [33:0]                       output_buffer_axi_interconnect_axi_araddr;
logic [1:0]                        output_buffer_axi_interconnect_axi_arburst;
logic [3:0]                        output_buffer_axi_interconnect_axi_arcache;
logic [3:0]                        output_buffer_axi_interconnect_axi_arid;
logic [7:0]                        output_buffer_axi_interconnect_axi_arlen;
logic [0:0]                        output_buffer_axi_interconnect_axi_arlock;
logic [2:0]                        output_buffer_axi_interconnect_axi_arprot;
logic [3:0]                        output_buffer_axi_interconnect_axi_arqos;
logic [2:0]                        output_buffer_axi_interconnect_axi_arsize;
logic                              output_buffer_axi_interconnect_axi_arvalid;
logic                              output_buffer_axi_interconnect_axi_arready;
logic [33:0]                       output_buffer_axi_interconnect_axi_awaddr;
logic [1:0]                        output_buffer_axi_interconnect_axi_awburst;
logic [3:0]                        output_buffer_axi_interconnect_axi_awcache;
logic [3:0]                        output_buffer_axi_interconnect_axi_awid;
logic [7:0]                        output_buffer_axi_interconnect_axi_awlen;
logic [0:0]                        output_buffer_axi_interconnect_axi_awlock;
logic [2:0]                        output_buffer_axi_interconnect_axi_awprot;
logic [3:0]                        output_buffer_axi_interconnect_axi_awqos;
logic                              output_buffer_axi_interconnect_axi_awready;
logic [2:0]                        output_buffer_axi_interconnect_axi_awsize;
logic                              output_buffer_axi_interconnect_axi_awvalid;
logic [3:0]                        output_buffer_axi_interconnect_axi_bid;
logic                              output_buffer_axi_interconnect_axi_bready;
logic [1:0]                        output_buffer_axi_interconnect_axi_bresp;
logic                              output_buffer_axi_interconnect_axi_bvalid;
logic [511:0]                      output_buffer_axi_interconnect_axi_rdata;
logic [3:0]                        output_buffer_axi_interconnect_axi_rid;
logic                              output_buffer_axi_interconnect_axi_rlast;
logic                              output_buffer_axi_interconnect_axi_rready;
logic [1:0]                        output_buffer_axi_interconnect_axi_rresp;
logic                              output_buffer_axi_interconnect_axi_rvalid;
logic [511:0]                      output_buffer_axi_interconnect_axi_wdata;
logic                              output_buffer_axi_interconnect_axi_wlast;
logic                              output_buffer_axi_interconnect_axi_wready;
logic [63:0]                       output_buffer_axi_interconnect_axi_wstrb;
logic                              output_buffer_axi_interconnect_axi_wvalid;

logic S00_AXI_ARESET_OUT_N;
logic S01_AXI_ARESET_OUT_N;
logic S02_AXI_ARESET_OUT_N;
logic S03_AXI_ARESET_OUT_N;
logic S04_AXI_ARESET_OUT_N;
logic S05_AXI_ARESET_OUT_N;
logic S06_AXI_ARESET_OUT_N;
logic S07_AXI_ARESET_OUT_N;
logic M00_AXI_ARESET_OUT_N;

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

// NSB -> Output Buffer Interface
logic                                                nsb_output_buffer_req_valid;
logic                                                nsb_output_buffer_req_ready;
NSB_OUT_BUFF_REQ_t                                   nsb_output_buffer_req;
logic                                                nsb_output_buffer_resp_valid; // valid only for now
NSB_OUT_BUFF_RESP_t                                  nsb_output_buffer_resp;

// Message Channels: AGE -> Prefetcher
logic [MESSAGE_CHANNEL_COUNT-1:0]                  message_channel_req_valid;
logic [MESSAGE_CHANNEL_COUNT-1:0]                  message_channel_req_ready;
MESSAGE_CHANNEL_REQ_t [MESSAGE_CHANNEL_COUNT-1:0]  message_channel_req;

logic [MESSAGE_CHANNEL_COUNT-1:0]                  message_channel_resp_valid;
logic [MESSAGE_CHANNEL_COUNT-1:0]                  message_channel_resp_ready;
MESSAGE_CHANNEL_RESP_t [MESSAGE_CHANNEL_COUNT-1:0] message_channel_resp;

// Weight Channel: FTE -> Prefetcher
logic                                              weight_channel_req_valid;
logic                                              weight_channel_req_ready;
WEIGHT_CHANNEL_REQ_t                               weight_channel_req;

logic                                              weight_channel_resp_valid;
logic                                              weight_channel_resp_ready;
WEIGHT_CHANNEL_RESP_t                              weight_channel_resp;

// AGE -> Aggregation Buffer Interface
logic [AGGREGATION_BUFFER_SLOTS-1:0]                                              aggregation_buffer_write_enable;
logic [AGGREGATION_BUFFER_SLOTS-1:0] [$clog2(AGGREGATION_BUFFER_WRITE_DEPTH)-1:0] aggregation_buffer_write_address;
logic [AGGREGATION_BUFFER_SLOTS-1:0] [AGGREGATION_BUFFER_WRITE_WIDTH-1:0]         aggregation_buffer_write_data;
logic [AGGREGATION_BUFFER_SLOTS-1:0] [$clog2(AGGREGATION_BUFFER_READ_DEPTH)-1:0]  aggregation_buffer_feature_count;

// FTE -> Aggregation Buffer Interface
logic [AGGREGATION_BUFFER_SLOTS-1:0]                                              aggregation_buffer_pop;
logic [AGGREGATION_BUFFER_SLOTS-1:0] [AGGREGATION_BUFFER_READ_WIDTH-1:0]          aggregation_buffer_out_feature;
logic [AGGREGATION_BUFFER_SLOTS-1:0]                                              aggregation_buffer_slot_free;

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
logic [FETCH_TAG_COUNT-1:0]                                           scale_factor_queue_pop;
logic [FETCH_TAG_COUNT-1:0] [SCALE_FACTOR_QUEUE_READ_WIDTH-1:0]       scale_factor_queue_out_data;
logic [FETCH_TAG_COUNT-1:0] [$clog2(SCALE_FACTOR_QUEUE_READ_DEPTH):0] scale_factor_queue_count;
logic [FETCH_TAG_COUNT-1:0]                                           scale_factor_queue_empty;
logic [FETCH_TAG_COUNT-1:0]                                           scale_factor_queue_full;

// ====================================================================================
// Node Scoreboard
// ====================================================================================

node_scoreboard node_scoreboard_i (
    .core_clk                       (sys_clk),
    .resetn                         (!sys_rst),
    
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
    .nsb_prefetcher_resp                                (nsb_prefetcher_resp),

    // Node Scoreboard -> Output Buffer Interface
    .nsb_output_buffer_req_valid                        (nsb_output_buffer_req_valid),
    .nsb_output_buffer_req_ready                        (nsb_output_buffer_req_ready),
    .nsb_output_buffer_req                              (nsb_output_buffer_req),
    .nsb_output_buffer_resp_valid                       (nsb_output_buffer_resp_valid),
    .nsb_output_buffer_resp                             (nsb_output_buffer_resp)
);

// ====================================================================================
// Prefetcher
// ====================================================================================

prefetcher #(
    .FETCH_TAG_COUNT (top_pkg::MAX_NODESLOT_COUNT)
) prefetcher_i (
    .core_clk                                                  (sys_clk),
    .resetn                                                    (!sys_rst),

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

    // Prefetcher Adj RM -> AXI Memory Interconnect
    .prefetcher_adj_rm_axi_interconnect_axi_araddr             (prefetcher_adj_rm_axi_interconnect_axi_araddr),
    .prefetcher_adj_rm_axi_interconnect_axi_arburst            (prefetcher_adj_rm_axi_interconnect_axi_arburst),
    .prefetcher_adj_rm_axi_interconnect_axi_arcache            (prefetcher_adj_rm_axi_interconnect_axi_arcache),
    .prefetcher_adj_rm_axi_interconnect_axi_arid               (prefetcher_adj_rm_axi_interconnect_axi_arid),
    .prefetcher_adj_rm_axi_interconnect_axi_arlen              (prefetcher_adj_rm_axi_interconnect_axi_arlen),
    .prefetcher_adj_rm_axi_interconnect_axi_arlock             (prefetcher_adj_rm_axi_interconnect_axi_arlock),
    .prefetcher_adj_rm_axi_interconnect_axi_arprot             (prefetcher_adj_rm_axi_interconnect_axi_arprot),
    .prefetcher_adj_rm_axi_interconnect_axi_arqos              (prefetcher_adj_rm_axi_interconnect_axi_arqos),
    .prefetcher_adj_rm_axi_interconnect_axi_arsize             (prefetcher_adj_rm_axi_interconnect_axi_arsize),
    .prefetcher_adj_rm_axi_interconnect_axi_arvalid            (prefetcher_adj_rm_axi_interconnect_axi_arvalid),
    .prefetcher_adj_rm_axi_interconnect_axi_arready            (prefetcher_adj_rm_axi_interconnect_axi_arready),
    .prefetcher_adj_rm_axi_interconnect_axi_awaddr             (prefetcher_adj_rm_axi_interconnect_axi_awaddr),
    .prefetcher_adj_rm_axi_interconnect_axi_awburst            (prefetcher_adj_rm_axi_interconnect_axi_awburst),
    .prefetcher_adj_rm_axi_interconnect_axi_awcache            (prefetcher_adj_rm_axi_interconnect_axi_awcache),
    .prefetcher_adj_rm_axi_interconnect_axi_awid               (prefetcher_adj_rm_axi_interconnect_axi_awid),
    .prefetcher_adj_rm_axi_interconnect_axi_awlen              (prefetcher_adj_rm_axi_interconnect_axi_awlen),
    .prefetcher_adj_rm_axi_interconnect_axi_awlock             (prefetcher_adj_rm_axi_interconnect_axi_awlock),
    .prefetcher_adj_rm_axi_interconnect_axi_awprot             (prefetcher_adj_rm_axi_interconnect_axi_awprot),
    .prefetcher_adj_rm_axi_interconnect_axi_awqos              (prefetcher_adj_rm_axi_interconnect_axi_awqos),
    .prefetcher_adj_rm_axi_interconnect_axi_awready            (prefetcher_adj_rm_axi_interconnect_axi_awready),
    .prefetcher_adj_rm_axi_interconnect_axi_awsize             (prefetcher_adj_rm_axi_interconnect_axi_awsize),
    .prefetcher_adj_rm_axi_interconnect_axi_awvalid            (prefetcher_adj_rm_axi_interconnect_axi_awvalid),
    .prefetcher_adj_rm_axi_interconnect_axi_bid                (prefetcher_adj_rm_axi_interconnect_axi_bid),
    .prefetcher_adj_rm_axi_interconnect_axi_bready             (prefetcher_adj_rm_axi_interconnect_axi_bready),
    .prefetcher_adj_rm_axi_interconnect_axi_bresp              (prefetcher_adj_rm_axi_interconnect_axi_bresp),
    .prefetcher_adj_rm_axi_interconnect_axi_bvalid             (prefetcher_adj_rm_axi_interconnect_axi_bvalid),
    .prefetcher_adj_rm_axi_interconnect_axi_rdata              (prefetcher_adj_rm_axi_interconnect_axi_rdata),
    .prefetcher_adj_rm_axi_interconnect_axi_rid                (prefetcher_adj_rm_axi_interconnect_axi_rid),
    .prefetcher_adj_rm_axi_interconnect_axi_rlast              (prefetcher_adj_rm_axi_interconnect_axi_rlast),
    .prefetcher_adj_rm_axi_interconnect_axi_rready             (prefetcher_adj_rm_axi_interconnect_axi_rready),
    .prefetcher_adj_rm_axi_interconnect_axi_rresp              (prefetcher_adj_rm_axi_interconnect_axi_rresp),
    .prefetcher_adj_rm_axi_interconnect_axi_rvalid             (prefetcher_adj_rm_axi_interconnect_axi_rvalid),
    .prefetcher_adj_rm_axi_interconnect_axi_wdata              (prefetcher_adj_rm_axi_interconnect_axi_wdata),
    .prefetcher_adj_rm_axi_interconnect_axi_wlast              (prefetcher_adj_rm_axi_interconnect_axi_wlast),
    .prefetcher_adj_rm_axi_interconnect_axi_wready             (prefetcher_adj_rm_axi_interconnect_axi_wready),
    .prefetcher_adj_rm_axi_interconnect_axi_wstrb              (prefetcher_adj_rm_axi_interconnect_axi_wstrb),
    .prefetcher_adj_rm_axi_interconnect_axi_wvalid             (prefetcher_adj_rm_axi_interconnect_axi_wvalid),

    // Prefetcher Msg RM -> AXI Memory Interconnect
    .prefetcher_msg_rm_axi_interconnect_axi_araddr             (prefetcher_msg_rm_axi_interconnect_axi_araddr),
    .prefetcher_msg_rm_axi_interconnect_axi_arburst            (prefetcher_msg_rm_axi_interconnect_axi_arburst),
    .prefetcher_msg_rm_axi_interconnect_axi_arcache            (prefetcher_msg_rm_axi_interconnect_axi_arcache),
    .prefetcher_msg_rm_axi_interconnect_axi_arid               (prefetcher_msg_rm_axi_interconnect_axi_arid),
    .prefetcher_msg_rm_axi_interconnect_axi_arlen              (prefetcher_msg_rm_axi_interconnect_axi_arlen),
    .prefetcher_msg_rm_axi_interconnect_axi_arlock             (prefetcher_msg_rm_axi_interconnect_axi_arlock),
    .prefetcher_msg_rm_axi_interconnect_axi_arprot             (prefetcher_msg_rm_axi_interconnect_axi_arprot),
    .prefetcher_msg_rm_axi_interconnect_axi_arqos              (prefetcher_msg_rm_axi_interconnect_axi_arqos),
    .prefetcher_msg_rm_axi_interconnect_axi_arsize             (prefetcher_msg_rm_axi_interconnect_axi_arsize),
    .prefetcher_msg_rm_axi_interconnect_axi_arvalid            (prefetcher_msg_rm_axi_interconnect_axi_arvalid),
    .prefetcher_msg_rm_axi_interconnect_axi_arready            (prefetcher_msg_rm_axi_interconnect_axi_arready),
    .prefetcher_msg_rm_axi_interconnect_axi_awaddr             (prefetcher_msg_rm_axi_interconnect_axi_awaddr),
    .prefetcher_msg_rm_axi_interconnect_axi_awburst            (prefetcher_msg_rm_axi_interconnect_axi_awburst),
    .prefetcher_msg_rm_axi_interconnect_axi_awcache            (prefetcher_msg_rm_axi_interconnect_axi_awcache),
    .prefetcher_msg_rm_axi_interconnect_axi_awid               (prefetcher_msg_rm_axi_interconnect_axi_awid),
    .prefetcher_msg_rm_axi_interconnect_axi_awlen              (prefetcher_msg_rm_axi_interconnect_axi_awlen),
    .prefetcher_msg_rm_axi_interconnect_axi_awlock             (prefetcher_msg_rm_axi_interconnect_axi_awlock),
    .prefetcher_msg_rm_axi_interconnect_axi_awprot             (prefetcher_msg_rm_axi_interconnect_axi_awprot),
    .prefetcher_msg_rm_axi_interconnect_axi_awqos              (prefetcher_msg_rm_axi_interconnect_axi_awqos),
    .prefetcher_msg_rm_axi_interconnect_axi_awready            (prefetcher_msg_rm_axi_interconnect_axi_awready),
    .prefetcher_msg_rm_axi_interconnect_axi_awsize             (prefetcher_msg_rm_axi_interconnect_axi_awsize),
    .prefetcher_msg_rm_axi_interconnect_axi_awvalid            (prefetcher_msg_rm_axi_interconnect_axi_awvalid),
    .prefetcher_msg_rm_axi_interconnect_axi_bid                (prefetcher_msg_rm_axi_interconnect_axi_bid),
    .prefetcher_msg_rm_axi_interconnect_axi_bready             (prefetcher_msg_rm_axi_interconnect_axi_bready),
    .prefetcher_msg_rm_axi_interconnect_axi_bresp              (prefetcher_msg_rm_axi_interconnect_axi_bresp),
    .prefetcher_msg_rm_axi_interconnect_axi_bvalid             (prefetcher_msg_rm_axi_interconnect_axi_bvalid),
    .prefetcher_msg_rm_axi_interconnect_axi_rdata              (prefetcher_msg_rm_axi_interconnect_axi_rdata),
    .prefetcher_msg_rm_axi_interconnect_axi_rid                (prefetcher_msg_rm_axi_interconnect_axi_rid),
    .prefetcher_msg_rm_axi_interconnect_axi_rlast              (prefetcher_msg_rm_axi_interconnect_axi_rlast),
    .prefetcher_msg_rm_axi_interconnect_axi_rready             (prefetcher_msg_rm_axi_interconnect_axi_rready),
    .prefetcher_msg_rm_axi_interconnect_axi_rresp              (prefetcher_msg_rm_axi_interconnect_axi_rresp),
    .prefetcher_msg_rm_axi_interconnect_axi_rvalid             (prefetcher_msg_rm_axi_interconnect_axi_rvalid),
    .prefetcher_msg_rm_axi_interconnect_axi_wdata              (prefetcher_msg_rm_axi_interconnect_axi_wdata),
    .prefetcher_msg_rm_axi_interconnect_axi_wlast              (prefetcher_msg_rm_axi_interconnect_axi_wlast),
    .prefetcher_msg_rm_axi_interconnect_axi_wready             (prefetcher_msg_rm_axi_interconnect_axi_wready),
    .prefetcher_msg_rm_axi_interconnect_axi_wstrb              (prefetcher_msg_rm_axi_interconnect_axi_wstrb),
    .prefetcher_msg_rm_axi_interconnect_axi_wvalid             (prefetcher_msg_rm_axi_interconnect_axi_wvalid),

    // Prefetcher Weights RM -> AXI Memory Interconnect
    .prefetcher_weight_bank_rm_axi_interconnect_axi_araddr     (prefetcher_weight_bank_rm_axi_interconnect_axi_araddr),
    .prefetcher_weight_bank_rm_axi_interconnect_axi_arburst    (prefetcher_weight_bank_rm_axi_interconnect_axi_arburst),
    .prefetcher_weight_bank_rm_axi_interconnect_axi_arcache    (prefetcher_weight_bank_rm_axi_interconnect_axi_arcache),
    .prefetcher_weight_bank_rm_axi_interconnect_axi_arid       (prefetcher_weight_bank_rm_axi_interconnect_axi_arid),
    .prefetcher_weight_bank_rm_axi_interconnect_axi_arlen      (prefetcher_weight_bank_rm_axi_interconnect_axi_arlen),
    .prefetcher_weight_bank_rm_axi_interconnect_axi_arlock     (prefetcher_weight_bank_rm_axi_interconnect_axi_arlock),
    .prefetcher_weight_bank_rm_axi_interconnect_axi_arprot     (prefetcher_weight_bank_rm_axi_interconnect_axi_arprot),
    .prefetcher_weight_bank_rm_axi_interconnect_axi_arqos      (prefetcher_weight_bank_rm_axi_interconnect_axi_arqos),
    .prefetcher_weight_bank_rm_axi_interconnect_axi_arsize     (prefetcher_weight_bank_rm_axi_interconnect_axi_arsize),
    .prefetcher_weight_bank_rm_axi_interconnect_axi_arvalid    (prefetcher_weight_bank_rm_axi_interconnect_axi_arvalid),
    .prefetcher_weight_bank_rm_axi_interconnect_axi_arready    (prefetcher_weight_bank_rm_axi_interconnect_axi_arready),
    .prefetcher_weight_bank_rm_axi_interconnect_axi_awaddr     (prefetcher_weight_bank_rm_axi_interconnect_axi_awaddr),
    .prefetcher_weight_bank_rm_axi_interconnect_axi_awburst    (prefetcher_weight_bank_rm_axi_interconnect_axi_awburst),
    .prefetcher_weight_bank_rm_axi_interconnect_axi_awcache    (prefetcher_weight_bank_rm_axi_interconnect_axi_awcache),
    .prefetcher_weight_bank_rm_axi_interconnect_axi_awid       (prefetcher_weight_bank_rm_axi_interconnect_axi_awid),
    .prefetcher_weight_bank_rm_axi_interconnect_axi_awlen      (prefetcher_weight_bank_rm_axi_interconnect_axi_awlen),
    .prefetcher_weight_bank_rm_axi_interconnect_axi_awlock     (prefetcher_weight_bank_rm_axi_interconnect_axi_awlock),
    .prefetcher_weight_bank_rm_axi_interconnect_axi_awprot     (prefetcher_weight_bank_rm_axi_interconnect_axi_awprot),
    .prefetcher_weight_bank_rm_axi_interconnect_axi_awqos      (prefetcher_weight_bank_rm_axi_interconnect_axi_awqos),
    .prefetcher_weight_bank_rm_axi_interconnect_axi_awready    (prefetcher_weight_bank_rm_axi_interconnect_axi_awready),
    .prefetcher_weight_bank_rm_axi_interconnect_axi_awsize     (prefetcher_weight_bank_rm_axi_interconnect_axi_awsize),
    .prefetcher_weight_bank_rm_axi_interconnect_axi_awvalid    (prefetcher_weight_bank_rm_axi_interconnect_axi_awvalid),
    .prefetcher_weight_bank_rm_axi_interconnect_axi_bid        (prefetcher_weight_bank_rm_axi_interconnect_axi_bid),
    .prefetcher_weight_bank_rm_axi_interconnect_axi_bready     (prefetcher_weight_bank_rm_axi_interconnect_axi_bready),
    .prefetcher_weight_bank_rm_axi_interconnect_axi_bresp      (prefetcher_weight_bank_rm_axi_interconnect_axi_bresp),
    .prefetcher_weight_bank_rm_axi_interconnect_axi_bvalid     (prefetcher_weight_bank_rm_axi_interconnect_axi_bvalid),
    .prefetcher_weight_bank_rm_axi_interconnect_axi_rdata      (prefetcher_weight_bank_rm_axi_interconnect_axi_rdata),
    .prefetcher_weight_bank_rm_axi_interconnect_axi_rid        (prefetcher_weight_bank_rm_axi_interconnect_axi_rid),
    .prefetcher_weight_bank_rm_axi_interconnect_axi_rlast      (prefetcher_weight_bank_rm_axi_interconnect_axi_rlast),
    .prefetcher_weight_bank_rm_axi_interconnect_axi_rready     (prefetcher_weight_bank_rm_axi_interconnect_axi_rready),
    .prefetcher_weight_bank_rm_axi_interconnect_axi_rresp      (prefetcher_weight_bank_rm_axi_interconnect_axi_rresp),
    .prefetcher_weight_bank_rm_axi_interconnect_axi_rvalid     (prefetcher_weight_bank_rm_axi_interconnect_axi_rvalid),
    .prefetcher_weight_bank_rm_axi_interconnect_axi_wdata      (prefetcher_weight_bank_rm_axi_interconnect_axi_wdata),
    .prefetcher_weight_bank_rm_axi_interconnect_axi_wlast      (prefetcher_weight_bank_rm_axi_interconnect_axi_wlast),
    .prefetcher_weight_bank_rm_axi_interconnect_axi_wready     (prefetcher_weight_bank_rm_axi_interconnect_axi_wready),
    .prefetcher_weight_bank_rm_axi_interconnect_axi_wstrb      (prefetcher_weight_bank_rm_axi_interconnect_axi_wstrb),
    .prefetcher_weight_bank_rm_axi_interconnect_axi_wvalid     (prefetcher_weight_bank_rm_axi_interconnect_axi_wvalid),

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
    .scale_factor_queue_count                                  (scale_factor_queue_count),
    .scale_factor_queue_empty                                  (scale_factor_queue_empty),
    .scale_factor_queue_full                                   (scale_factor_queue_full)
);

// ====================================================================================
// Output Buffer
// ====================================================================================

output_buffer output_buffer_i (
    .core_clk                                              (sys_clk),
    .resetn                                                (!sys_rst),

    // Node Scoreboard -> Output Buffer Interface
    .nsb_output_buffer_req_valid                           (nsb_output_buffer_req_valid),
    .nsb_output_buffer_req_ready                           (nsb_output_buffer_req_ready),
    .nsb_output_buffer_req                                 (nsb_output_buffer_req),
    .nsb_output_buffer_resp_valid                          (nsb_output_buffer_resp_valid),
    .nsb_output_buffer_resp                                (nsb_output_buffer_resp),

    // Prefetcher -> AXI Memory Interconnect
    .output_buffer_axi_interconnect_axi_araddr             (output_buffer_axi_interconnect_axi_araddr),
    .output_buffer_axi_interconnect_axi_arburst            (output_buffer_axi_interconnect_axi_arburst),
    .output_buffer_axi_interconnect_axi_arcache            (output_buffer_axi_interconnect_axi_arcache),
    .output_buffer_axi_interconnect_axi_arid               (output_buffer_axi_interconnect_axi_arid),
    .output_buffer_axi_interconnect_axi_arlen              (output_buffer_axi_interconnect_axi_arlen),
    .output_buffer_axi_interconnect_axi_arlock             (output_buffer_axi_interconnect_axi_arlock),
    .output_buffer_axi_interconnect_axi_arprot             (output_buffer_axi_interconnect_axi_arprot),
    .output_buffer_axi_interconnect_axi_arqos              (output_buffer_axi_interconnect_axi_arqos),
    .output_buffer_axi_interconnect_axi_arsize             (output_buffer_axi_interconnect_axi_arsize),
    .output_buffer_axi_interconnect_axi_arvalid            (output_buffer_axi_interconnect_axi_arvalid),
    .output_buffer_axi_interconnect_axi_arready            (output_buffer_axi_interconnect_axi_arready),
    .output_buffer_axi_interconnect_axi_awaddr             (output_buffer_axi_interconnect_axi_awaddr),
    .output_buffer_axi_interconnect_axi_awburst            (output_buffer_axi_interconnect_axi_awburst),
    .output_buffer_axi_interconnect_axi_awcache            (output_buffer_axi_interconnect_axi_awcache),
    .output_buffer_axi_interconnect_axi_awid               (output_buffer_axi_interconnect_axi_awid),
    .output_buffer_axi_interconnect_axi_awlen              (output_buffer_axi_interconnect_axi_awlen),
    .output_buffer_axi_interconnect_axi_awlock             (output_buffer_axi_interconnect_axi_awlock),
    .output_buffer_axi_interconnect_axi_awprot             (output_buffer_axi_interconnect_axi_awprot),
    .output_buffer_axi_interconnect_axi_awqos              (output_buffer_axi_interconnect_axi_awqos),
    .output_buffer_axi_interconnect_axi_awready            (output_buffer_axi_interconnect_axi_awready),
    .output_buffer_axi_interconnect_axi_awsize             (output_buffer_axi_interconnect_axi_awsize),
    .output_buffer_axi_interconnect_axi_awvalid            (output_buffer_axi_interconnect_axi_awvalid),
    .output_buffer_axi_interconnect_axi_bid                (output_buffer_axi_interconnect_axi_bid),
    .output_buffer_axi_interconnect_axi_bready             (output_buffer_axi_interconnect_axi_bready),
    .output_buffer_axi_interconnect_axi_bresp              (output_buffer_axi_interconnect_axi_bresp),
    .output_buffer_axi_interconnect_axi_bvalid             (output_buffer_axi_interconnect_axi_bvalid),
    .output_buffer_axi_interconnect_axi_rdata              (output_buffer_axi_interconnect_axi_rdata),
    .output_buffer_axi_interconnect_axi_rid                (output_buffer_axi_interconnect_axi_rid),
    .output_buffer_axi_interconnect_axi_rlast              (output_buffer_axi_interconnect_axi_rlast),
    .output_buffer_axi_interconnect_axi_rready             (output_buffer_axi_interconnect_axi_rready),
    .output_buffer_axi_interconnect_axi_rresp              (output_buffer_axi_interconnect_axi_rresp),
    .output_buffer_axi_interconnect_axi_rvalid             (output_buffer_axi_interconnect_axi_rvalid),
    .output_buffer_axi_interconnect_axi_wdata              (output_buffer_axi_interconnect_axi_wdata),
    .output_buffer_axi_interconnect_axi_wlast              (output_buffer_axi_interconnect_axi_wlast),
    .output_buffer_axi_interconnect_axi_wready             (output_buffer_axi_interconnect_axi_wready),
    .output_buffer_axi_interconnect_axi_wstrb              (output_buffer_axi_interconnect_axi_wstrb),
    .output_buffer_axi_interconnect_axi_wvalid             (output_buffer_axi_interconnect_axi_wvalid)
);

// ====================================================================================
// Aggregation Engine
// ====================================================================================

aggregation_engine aggregation_engine_i (
    .core_clk                                     (sys_clk),
    .resetn                                       (!sys_rst),
    
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

    .aggregation_buffer_slot_write_enable         (aggregation_buffer_write_enable),
    .aggregation_buffer_slot_write_address        (aggregation_buffer_write_address),
    .aggregation_buffer_slot_write_data           (aggregation_buffer_write_data),
    .aggregation_buffer_slot_feature_count        (aggregation_buffer_feature_count),
    .aggregation_buffer_slot_slot_free            (aggregation_buffer_slot_free),

    .scale_factor_queue_pop                       (scale_factor_queue_pop),
    .scale_factor_queue_out_data                  (scale_factor_queue_out_data),
    .scale_factor_queue_count                     (scale_factor_queue_count),
    .scale_factor_queue_empty                     (scale_factor_queue_empty),
    .scale_factor_queue_full                      (scale_factor_queue_full)
);

// ====================================================================================
// Aggregation Buffer
// ====================================================================================

hybrid_buffer #(
    .NUM_SLOTS   (top_pkg::AGGREGATION_BUFFER_SLOTS),
    .WRITE_WIDTH (top_pkg::AGGREGATION_BUFFER_WRITE_WIDTH),
    .WRITE_DEPTH (top_pkg::AGGREGATION_BUFFER_WRITE_DEPTH),
    .READ_WIDTH  (top_pkg::AGGREGATION_BUFFER_READ_WIDTH),
    .READ_DEPTH  (top_pkg::AGGREGATION_BUFFER_READ_DEPTH)
) aggregation_buffer_i (
    .core_clk           (sys_clk),
    .resetn             (!sys_rst),

    .write_enable       (aggregation_buffer_write_enable),
    .write_address      (aggregation_buffer_write_address),
    .write_data         (aggregation_buffer_write_data),
    .feature_count      (aggregation_buffer_feature_count),

    .pop                (aggregation_buffer_pop),
    .out_feature        (aggregation_buffer_out_feature),
    .slot_free          (aggregation_buffer_slot_free)

);

// ====================================================================================
// Transformation Engine
// ====================================================================================

feature_transformation_engine transformation_engine_i (
    .core_clk                                           (sys_clk),
    .resetn                                             (!sys_rst),

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

    .aggregation_buffer_pop                             (aggregation_buffer_pop),
    .aggregation_buffer_out_feature                     (aggregation_buffer_out_feature),
    .aggregation_buffer_slot_free                       (aggregation_buffer_slot_free),

    .weight_channel_req_valid                           (weight_channel_req_valid),
    .weight_channel_req_ready                           (weight_channel_req_ready),
    .weight_channel_req                                 (weight_channel_req),
    .weight_channel_resp_valid                          (weight_channel_resp_valid),
    .weight_channel_resp_ready                          (weight_channel_resp_ready),
    .weight_channel_resp                                (weight_channel_resp),

    .transformation_buffer_write_enable                 (transformation_buffer_write_enable),
    .transformation_buffer_write_address                (transformation_buffer_write_address),
    .transformation_buffer_write_data                   (transformation_buffer_write_data),

    .transformation_buffer_slot_free                    (transformation_buffer_slot_free)
);


// ====================================================================================
// Transformation Buffer
// ====================================================================================

hybrid_buffer #(
    .NUM_SLOTS   (top_pkg::TRANSFORMATION_BUFFER_SLOTS),
    .WRITE_WIDTH (top_pkg::TRANSFORMATION_BUFFER_WRITE_WIDTH),
    .WRITE_DEPTH (top_pkg::TRANSFORMATION_BUFFER_WRITE_DEPTH),
    .READ_WIDTH  (top_pkg::TRANSFORMATION_BUFFER_READ_WIDTH),
    .READ_DEPTH  (top_pkg::TRANSFORMATION_BUFFER_READ_DEPTH),
    .BUFFER_TYPE ("TRANSFORMATION")
) transformation_buffer_i (
    .core_clk           (sys_clk),
    .resetn             (!sys_rst),

    .write_enable       (transformation_buffer_write_enable),
    .write_address      (transformation_buffer_write_address),
    .write_data         (transformation_buffer_write_data),
    .feature_count      (transformation_buffer_feature_count),

    .pop                (transformation_buffer_pop),
    .out_feature        (transformation_buffer_out_feature),
    .slot_free          (transformation_buffer_slot_free)
);

// ====================================================================================
// AXI-L Register Control Crossbar
// ====================================================================================

// M00: AGE
// M01: FTE
// M02: NSB
// M03: Prefetcher

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

// S00: Prefetcher (adj rm) ---------------- / read-only
// S01: Prefetcher (weight bank) --------- / read-only
// S02: top (TB) --------------------------- / read-write
// S03: output buffer ---------------------- / write-only
// S04: Prefetcher (message read master) --- / read-only

// S05: unused ----------------------------- / read-write
// S06: unused ----------------------------- / read-write
// S07: unused ----------------------------- / read-write

axi_memory_interconnect axi_memory_interconnect_i (
    .INTERCONNECT_ACLK            (sys_clk),        // input wire INTERCONNECT_ACLK
    .INTERCONNECT_ARESETN         (!sys_rst),  // input wire INTERCONNECT_ARESETN

    // S00: Prefetcher (ADJ RM)
    .S00_AXI_ACLK                 (sys_clk),                  // input wire S00_AXI_ACLK
    .S00_AXI_ARESET_OUT_N         (S00_AXI_ARESET_OUT_N),  // output wire S00_AXI_ARESET_OUT_N

    .S00_AXI_ARADDR               (prefetcher_adj_rm_axi_interconnect_axi_araddr     ),              // input wire [33 : 0] S00_AXI_ARADDR
    .S00_AXI_ARBURST              (prefetcher_adj_rm_axi_interconnect_axi_arburst        ),            // input wire [1 : 0] S00_AXI_ARBURST
    .S00_AXI_ARCACHE              (prefetcher_adj_rm_axi_interconnect_axi_arcache        ),            // input wire [3 : 0] S00_AXI_ARCACHE
    .S00_AXI_ARID                 (prefetcher_adj_rm_axi_interconnect_axi_arid       ),                  // input wire [0 : 0] S00_AXI_ARID
    .S00_AXI_ARLEN                (prefetcher_adj_rm_axi_interconnect_axi_arlen      ),                // input wire [7 : 0] S00_AXI_ARLEN
    .S00_AXI_ARLOCK               (prefetcher_adj_rm_axi_interconnect_axi_arlock     ),                               // input wire S00_AXI_ARLOCK
    .S00_AXI_ARPROT               (prefetcher_adj_rm_axi_interconnect_axi_arprot     ),                               // input wire [2 : 0] S00_AXI_ARPROT
    .S00_AXI_ARQOS                (prefetcher_adj_rm_axi_interconnect_axi_arqos      ),                               // input wire [3 : 0] S00_AXI_ARQOS
    .S00_AXI_ARSIZE               (prefetcher_adj_rm_axi_interconnect_axi_arsize     ),              // input wire [2 : 0] S00_AXI_ARSIZE
    .S00_AXI_ARVALID              (prefetcher_adj_rm_axi_interconnect_axi_arvalid        ),            // input wire S00_AXI_ARVALID
    .S00_AXI_ARREADY              (prefetcher_adj_rm_axi_interconnect_axi_arready        ),            // output wire S00_AXI_ARREADY
    .S00_AXI_AWADDR               (prefetcher_adj_rm_axi_interconnect_axi_awaddr     ),              // input wire [33 : 0] S00_AXI_AWADDR
    .S00_AXI_AWBURST              (prefetcher_adj_rm_axi_interconnect_axi_awburst        ),            // input wire [1 : 0] S00_AXI_AWBURST
    .S00_AXI_AWCACHE              (prefetcher_adj_rm_axi_interconnect_axi_awcache        ),            // input wire [3 : 0] S00_AXI_AWCACHE
    .S00_AXI_AWID                 (prefetcher_adj_rm_axi_interconnect_axi_awid       ),                  // input wire [0 : 0] S00_AXI_AWID
    .S00_AXI_AWLEN                (prefetcher_adj_rm_axi_interconnect_axi_awlen      ),                // input wire [7 : 0] S00_AXI_AWLEN
    .S00_AXI_AWLOCK               (prefetcher_adj_rm_axi_interconnect_axi_awlock     ),                               // input wire S00_AXI_AWLOCK
    .S00_AXI_AWPROT               (prefetcher_adj_rm_axi_interconnect_axi_awprot     ),              // input wire [2 : 0] S00_AXI_AWPROT
    .S00_AXI_AWQOS                (prefetcher_adj_rm_axi_interconnect_axi_awqos      ),                               // input wire [3 : 0] S00_AXI_AWQOS
    .S00_AXI_AWREADY              (prefetcher_adj_rm_axi_interconnect_axi_awready        ),            // output wire S00_AXI_AWREADY
    .S00_AXI_AWSIZE               (prefetcher_adj_rm_axi_interconnect_axi_awsize     ),              // input wire [2 : 0] S00_AXI_AWSIZE
    .S00_AXI_AWVALID              (prefetcher_adj_rm_axi_interconnect_axi_awvalid        ),            // input wire S00_AXI_AWVALID
    .S00_AXI_BID                  (prefetcher_adj_rm_axi_interconnect_axi_bid        ),                    // output wire [0 : 0] S00_AXI_BID
    .S00_AXI_BREADY               (prefetcher_adj_rm_axi_interconnect_axi_bready     ),              // input wire S00_AXI_BREADY
    .S00_AXI_BRESP                (prefetcher_adj_rm_axi_interconnect_axi_bresp      ),                // output wire [1 : 0] S00_AXI_BRESP
    .S00_AXI_BVALID               (prefetcher_adj_rm_axi_interconnect_axi_bvalid     ),              // output wire S00_AXI_BVALID
    .S00_AXI_RDATA                (prefetcher_adj_rm_axi_interconnect_axi_rdata      ),                // output wire [511 : 0] S00_AXI_RDATA
    .S00_AXI_RID                  (prefetcher_adj_rm_axi_interconnect_axi_rid        ),                    // output wire [0 : 0] S00_AXI_RID
    .S00_AXI_RLAST                (prefetcher_adj_rm_axi_interconnect_axi_rlast      ),                // output wire S00_AXI_RLAST
    .S00_AXI_RREADY               (prefetcher_adj_rm_axi_interconnect_axi_rready     ),              // input wire S00_AXI_RREADY
    .S00_AXI_RRESP                (prefetcher_adj_rm_axi_interconnect_axi_rresp      ),                // output wire [1 : 0] S00_AXI_RRESP
    .S00_AXI_RVALID               (prefetcher_adj_rm_axi_interconnect_axi_rvalid     ),              // output wire S00_AXI_RVALID
    .S00_AXI_WDATA                (prefetcher_adj_rm_axi_interconnect_axi_wdata      ),                // input wire [511 : 0] S00_AXI_WDATA
    .S00_AXI_WLAST                (prefetcher_adj_rm_axi_interconnect_axi_wlast      ),                // input wire S00_AXI_WLAST
    .S00_AXI_WREADY               (prefetcher_adj_rm_axi_interconnect_axi_wready     ),              // output wire S00_AXI_WREADY
    .S00_AXI_WSTRB                (prefetcher_adj_rm_axi_interconnect_axi_wstrb      ),                // input wire [63 : 0] S00_AXI_WSTRB
    .S00_AXI_WVALID               (prefetcher_adj_rm_axi_interconnect_axi_wvalid     ),              // input wire S00_AXI_WVALID


    // S01: Prefetcher Weight Bank
    .S01_AXI_ACLK                 (sys_clk),                  // input wire S01_AXI_ACLK
    .S01_AXI_ARESET_OUT_N         (S01_AXI_ARESET_OUT_N),  // output wire S01_AXI_ARESET_OUT_N

    .S01_AXI_ARADDR               (prefetcher_weight_bank_rm_axi_interconnect_axi_araddr),
    .S01_AXI_ARBURST              (prefetcher_weight_bank_rm_axi_interconnect_axi_arburst),
    .S01_AXI_ARCACHE              (prefetcher_weight_bank_rm_axi_interconnect_axi_arcache),
    .S01_AXI_ARID                 (prefetcher_weight_bank_rm_axi_interconnect_axi_arid),
    .S01_AXI_ARLEN                (prefetcher_weight_bank_rm_axi_interconnect_axi_arlen),
    .S01_AXI_ARLOCK               (prefetcher_weight_bank_rm_axi_interconnect_axi_arlock),
    .S01_AXI_ARPROT               (prefetcher_weight_bank_rm_axi_interconnect_axi_arprot),
    .S01_AXI_ARQOS                (prefetcher_weight_bank_rm_axi_interconnect_axi_arqos),
    .S01_AXI_ARSIZE               (prefetcher_weight_bank_rm_axi_interconnect_axi_arsize),
    .S01_AXI_ARVALID              (prefetcher_weight_bank_rm_axi_interconnect_axi_arvalid),
    .S01_AXI_ARREADY              (prefetcher_weight_bank_rm_axi_interconnect_axi_arready),
    .S01_AXI_AWADDR               (prefetcher_weight_bank_rm_axi_interconnect_axi_awaddr),
    .S01_AXI_AWBURST              (prefetcher_weight_bank_rm_axi_interconnect_axi_awburst),
    .S01_AXI_AWCACHE              (prefetcher_weight_bank_rm_axi_interconnect_axi_awcache),
    .S01_AXI_AWID                 (prefetcher_weight_bank_rm_axi_interconnect_axi_awid),
    .S01_AXI_AWLEN                (prefetcher_weight_bank_rm_axi_interconnect_axi_awlen),
    .S01_AXI_AWLOCK               (prefetcher_weight_bank_rm_axi_interconnect_axi_awlock),
    .S01_AXI_AWPROT               (prefetcher_weight_bank_rm_axi_interconnect_axi_awprot),
    .S01_AXI_AWQOS                (prefetcher_weight_bank_rm_axi_interconnect_axi_awqos),
    .S01_AXI_AWREADY              (prefetcher_weight_bank_rm_axi_interconnect_axi_awready),
    .S01_AXI_AWSIZE               (prefetcher_weight_bank_rm_axi_interconnect_axi_awsize),
    .S01_AXI_AWVALID              (prefetcher_weight_bank_rm_axi_interconnect_axi_awvalid),
    .S01_AXI_BID                  (prefetcher_weight_bank_rm_axi_interconnect_axi_bid),
    .S01_AXI_BREADY               (prefetcher_weight_bank_rm_axi_interconnect_axi_bready),
    .S01_AXI_BRESP                (prefetcher_weight_bank_rm_axi_interconnect_axi_bresp),
    .S01_AXI_BVALID               (prefetcher_weight_bank_rm_axi_interconnect_axi_bvalid),
    .S01_AXI_RDATA                (prefetcher_weight_bank_rm_axi_interconnect_axi_rdata),
    .S01_AXI_RID                  (prefetcher_weight_bank_rm_axi_interconnect_axi_rid),
    .S01_AXI_RLAST                (prefetcher_weight_bank_rm_axi_interconnect_axi_rlast),
    .S01_AXI_RREADY               (prefetcher_weight_bank_rm_axi_interconnect_axi_rready),
    .S01_AXI_RRESP                (prefetcher_weight_bank_rm_axi_interconnect_axi_rresp),
    .S01_AXI_RVALID               (prefetcher_weight_bank_rm_axi_interconnect_axi_rvalid),
    .S01_AXI_WDATA                (prefetcher_weight_bank_rm_axi_interconnect_axi_wdata),
    .S01_AXI_WLAST                (prefetcher_weight_bank_rm_axi_interconnect_axi_wlast),
    .S01_AXI_WREADY               (prefetcher_weight_bank_rm_axi_interconnect_axi_wready),
    .S01_AXI_WSTRB                (prefetcher_weight_bank_rm_axi_interconnect_axi_wstrb),
    .S01_AXI_WVALID               (prefetcher_weight_bank_rm_axi_interconnect_axi_wvalid),

    // S02: TOP TB
    .S02_AXI_ACLK                 (sys_clk),                  // input wire S02_AXI_ACLK
    .S02_AXI_ARESET_OUT_N         (S02_AXI_ARESET_OUT_N),  // output wire S02_AXI_ARESET_OUT_N

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

    // S03: OUTPUT BUFFER
    .S03_AXI_ACLK                 (sys_clk),                  // input wire S02_AXI_ACLK
    .S03_AXI_ARESET_OUT_N         (S03_AXI_ARESET_OUT_N),  // output wire S02_AXI_ARESET_OUT_N

    .S03_AXI_AWID                 (output_buffer_axi_interconnect_axi_awid),                  // input wire [0 : 0] S02_AXI_AWID
    .S03_AXI_AWADDR               (output_buffer_axi_interconnect_axi_awaddr),              // input wire [33 : 0] S02_AXI_AWADDR
    .S03_AXI_AWLEN                (output_buffer_axi_interconnect_axi_awlen),                // input wire [7 : 0] S02_AXI_AWLEN
    .S03_AXI_AWSIZE               (output_buffer_axi_interconnect_axi_awsize),              // input wire [2 : 0] S02_AXI_AWSIZE
    .S03_AXI_AWBURST              (output_buffer_axi_interconnect_axi_awburst),            // input wire [1 : 0] S02_AXI_AWBURST
    .S03_AXI_AWLOCK               (output_buffer_axi_interconnect_axi_awlock),              // input wire S02_AXI_AWLOCK
    .S03_AXI_AWCACHE              (output_buffer_axi_interconnect_axi_awcache),            // input wire [3 : 0] S02_AXI_AWCACHE
    .S03_AXI_AWPROT               (output_buffer_axi_interconnect_axi_awprot),              // input wire [2 : 0] S02_AXI_AWPROT
    .S03_AXI_AWQOS                (output_buffer_axi_interconnect_axi_awqos),                // input wire [3 : 0] S02_AXI_AWQOS
    .S03_AXI_AWVALID              (output_buffer_axi_interconnect_axi_awvalid),            // input wire S02_AXI_AWVALID
    .S03_AXI_AWREADY              (output_buffer_axi_interconnect_axi_awready),            // output wire S02_AXI_AWREADY
    .S03_AXI_WDATA                (output_buffer_axi_interconnect_axi_wdata),                // input wire [511 : 0] S02_AXI_WDATA
    .S03_AXI_WSTRB                (output_buffer_axi_interconnect_axi_wstrb),                // input wire [63 : 0] S02_AXI_WSTRB
    .S03_AXI_WLAST                (output_buffer_axi_interconnect_axi_wlast),                // input wire S02_AXI_WLAST
    .S03_AXI_WVALID               (output_buffer_axi_interconnect_axi_wvalid),              // input wire S02_AXI_WVALID
    .S03_AXI_WREADY               (output_buffer_axi_interconnect_axi_wready),              // output wire S02_AXI_WREADY
    .S03_AXI_BID                  (output_buffer_axi_interconnect_axi_bid),                    // output wire [0 : 0] S02_AXI_BID
    .S03_AXI_BRESP                (output_buffer_axi_interconnect_axi_bresp),                // output wire [1 : 0] S02_AXI_BRESP
    .S03_AXI_BVALID               (output_buffer_axi_interconnect_axi_bvalid),              // output wire S02_AXI_BVALID
    .S03_AXI_BREADY               (output_buffer_axi_interconnect_axi_bready),              // input wire S02_AXI_BREADY
    .S03_AXI_ARID                 (output_buffer_axi_interconnect_axi_arid),                  // input wire [0 : 0] S02_AXI_ARID
    .S03_AXI_ARADDR               (output_buffer_axi_interconnect_axi_araddr),              // input wire [33 : 0] S02_AXI_ARADDR
    .S03_AXI_ARLEN                (output_buffer_axi_interconnect_axi_arlen),                // input wire [7 : 0] S02_AXI_ARLEN
    .S03_AXI_ARSIZE               (output_buffer_axi_interconnect_axi_arsize),              // input wire [2 : 0] S02_AXI_ARSIZE
    .S03_AXI_ARBURST              (output_buffer_axi_interconnect_axi_arburst),            // input wire [1 : 0] S02_AXI_ARBURST
    .S03_AXI_ARLOCK               (output_buffer_axi_interconnect_axi_arlock),              // input wire S02_AXI_ARLOCK
    .S03_AXI_ARCACHE              (output_buffer_axi_interconnect_axi_arcache),            // input wire [3 : 0] S02_AXI_ARCACHE
    .S03_AXI_ARPROT               (output_buffer_axi_interconnect_axi_arprot),              // input wire [2 : 0] S02_AXI_ARPROT
    .S03_AXI_ARQOS                (output_buffer_axi_interconnect_axi_arqos),                // input wire [3 : 0] S02_AXI_ARQOS
    .S03_AXI_ARVALID              (output_buffer_axi_interconnect_axi_arvalid),            // input wire S02_AXI_ARVALID
    .S03_AXI_ARREADY              (output_buffer_axi_interconnect_axi_arready),            // output wire S02_AXI_ARREADY
    .S03_AXI_RID                  (output_buffer_axi_interconnect_axi_rid),                    // output wire [0 : 0] S02_AXI_RID
    .S03_AXI_RDATA                (output_buffer_axi_interconnect_axi_rdata),                // output wire [511 : 0] S02_AXI_RDATA
    .S03_AXI_RRESP                (output_buffer_axi_interconnect_axi_rresp),                // output wire [1 : 0] S02_AXI_RRESP
    .S03_AXI_RLAST                (output_buffer_axi_interconnect_axi_rlast),                // output wire S02_AXI_RLAST
    .S03_AXI_RVALID               (output_buffer_axi_interconnect_axi_rvalid),              // output wire S02_AXI_RVALID
    .S03_AXI_RREADY               (output_buffer_axi_interconnect_axi_rready),              // input wire S02_AXI_RREADY

    // S04: PREFETCHER (MSG RM)
    .S04_AXI_ACLK                 (sys_clk),         // input wire S00_AXI_ACLK
    .S04_AXI_ARESET_OUT_N         (S04_AXI_ARESET_OUT_N),  // outpmsg_rm_ut wire S00_AXI_ARESET_OUT_N
    .S04_AXI_ARADDR               (prefetcher_msg_rm_axi_interconnect_axi_araddr     ),              // input wire [33 : 0] S00_AXI_ARADDR
    .S04_AXI_ARBURST              (prefetcher_msg_rm_axi_interconnect_axi_arburst        ),            // input wire [1 : 0] S00_AXI_ARBURST
    .S04_AXI_ARCACHE              (prefetcher_msg_rm_axi_interconnect_axi_arcache        ),            // input wire [3 : 0] S00_AXI_ARCACHE
    .S04_AXI_ARID                 (prefetcher_msg_rm_axi_interconnect_axi_arid       ),                  // input wire [0 : 0] S00_AXI_ARID
    .S04_AXI_ARLEN                (prefetcher_msg_rm_axi_interconnect_axi_arlen      ),                // input wire [7 : 0] S00_AXI_ARLEN
    .S04_AXI_ARLOCK               (prefetcher_msg_rm_axi_interconnect_axi_arlock     ),                               // input wire S00_AXI_ARLOCK
    .S04_AXI_ARPROT               (prefetcher_msg_rm_axi_interconnect_axi_arprot     ),                               // input wire [2 : 0] S00_AXI_ARPROT
    .S04_AXI_ARQOS                (prefetcher_msg_rm_axi_interconnect_axi_arqos      ),                               // input wire [3 : 0] S00_AXI_ARQOS
    .S04_AXI_ARSIZE               (prefetcher_msg_rm_axi_interconnect_axi_arsize     ),              // input wire [2 : 0] S00_AXI_ARSIZE
    .S04_AXI_ARVALID              (prefetcher_msg_rm_axi_interconnect_axi_arvalid        ),            // input wire S00_AXI_ARVALID
    .S04_AXI_ARREADY              (prefetcher_msg_rm_axi_interconnect_axi_arready        ),            // output wire S00_AXI_ARREADY
    .S04_AXI_AWADDR               (prefetcher_msg_rm_axi_interconnect_axi_awaddr     ),              // input wire [33 : 0] S00_AXI_AWADDR
    .S04_AXI_AWBURST              (prefetcher_msg_rm_axi_interconnect_axi_awburst        ),            // input wire [1 : 0] S00_AXI_AWBURST
    .S04_AXI_AWCACHE              (prefetcher_msg_rm_axi_interconnect_axi_awcache        ),            // input wire [3 : 0] S00_AXI_AWCACHE
    .S04_AXI_AWID                 (prefetcher_msg_rm_axi_interconnect_axi_awid       ),                  // input wire [0 : 0] S00_AXI_AWID
    .S04_AXI_AWLEN                (prefetcher_msg_rm_axi_interconnect_axi_awlen      ),                // input wire [7 : 0] S00_AXI_AWLEN
    .S04_AXI_AWLOCK               (prefetcher_msg_rm_axi_interconnect_axi_awlock     ),                               // input wire S00_AXI_AWLOCK
    .S04_AXI_AWPROT               (prefetcher_msg_rm_axi_interconnect_axi_awprot     ),              // input wire [2 : 0] S00_AXI_AWPROT
    .S04_AXI_AWQOS                (prefetcher_msg_rm_axi_interconnect_axi_awqos      ),                               // input wire [3 : 0] S00_AXI_AWQOS
    .S04_AXI_AWREADY              (prefetcher_msg_rm_axi_interconnect_axi_awready        ),            // output wire S00_AXI_AWREADY
    .S04_AXI_AWSIZE               (prefetcher_msg_rm_axi_interconnect_axi_awsize     ),              // input wire [2 : 0] S00_AXI_AWSIZE
    .S04_AXI_AWVALID              (prefetcher_msg_rm_axi_interconnect_axi_awvalid        ),            // input wire S00_AXI_AWVALID
    .S04_AXI_BID                  (prefetcher_msg_rm_axi_interconnect_axi_bid        ),                    // output wire [0 : 0] S00_AXI_BID
    .S04_AXI_BREADY               (prefetcher_msg_rm_axi_interconnect_axi_bready     ),              // input wire S00_AXI_BREADY
    .S04_AXI_BRESP                (prefetcher_msg_rm_axi_interconnect_axi_bresp      ),                // output wire [1 : 0] S00_AXI_BRESP
    .S04_AXI_BVALID               (prefetcher_msg_rm_axi_interconnect_axi_bvalid     ),              // output wire S00_AXI_BVALID
    .S04_AXI_RDATA                (prefetcher_msg_rm_axi_interconnect_axi_rdata      ),                // output wire [511 : 0] S00_AXI_RDATA
    .S04_AXI_RID                  (prefetcher_msg_rm_axi_interconnect_axi_rid        ),                    // output wire [0 : 0] S00_AXI_RID
    .S04_AXI_RLAST                (prefetcher_msg_rm_axi_interconnect_axi_rlast      ),                // output wire S00_AXI_RLAST
    .S04_AXI_RREADY               (prefetcher_msg_rm_axi_interconnect_axi_rready     ),              // input wire S00_AXI_RREADY
    .S04_AXI_RRESP                (prefetcher_msg_rm_axi_interconnect_axi_rresp      ),                // output wire [1 : 0] S00_AXI_RRESP
    .S04_AXI_RVALID               (prefetcher_msg_rm_axi_interconnect_axi_rvalid     ),              // output wire S00_AXI_RVALID
    .S04_AXI_WDATA                (prefetcher_msg_rm_axi_interconnect_axi_wdata      ),                // input wire [511 : 0] S00_AXI_WDATA
    .S04_AXI_WLAST                (prefetcher_msg_rm_axi_interconnect_axi_wlast      ),                // input wire S00_AXI_WLAST
    .S04_AXI_WREADY               (prefetcher_msg_rm_axi_interconnect_axi_wready     ),              // output wire S00_AXI_WREADY
    .S04_AXI_WSTRB                (prefetcher_msg_rm_axi_interconnect_axi_wstrb      ),                // input wire [63 : 0] S00_AXI_WSTRB
    .S04_AXI_WVALID               (prefetcher_msg_rm_axi_interconnect_axi_wvalid     ),              // input wire S00_AXI_WVALID

    // S05: unused
    .S05_AXI_ACLK                 (sys_clk), // input wire S00_AXI_ACLK
    .S05_AXI_ARESET_OUT_N         (S05_AXI_ARESET_OUT_N),   // output wire S00_AXI_ARESET_OUT_N
    .S05_AXI_ARADDR               ('0), // input wire [33 : 0] S00_AXI_ARADDR
    .S05_AXI_ARBURST              ('0), // input wire [1 : 0] S00_AXI_ARBURST
    .S05_AXI_ARCACHE              ('0), // input wire [3 : 0] S00_AXI_ARCACHE
    .S05_AXI_ARID                 ('0), // input wire [0 : 0] S00_AXI_ARID
    .S05_AXI_ARLEN                ('0), // input wire [7 : 0] S00_AXI_ARLEN
    .S05_AXI_ARLOCK               ('0), // input wire S00_AXI_ARLOCK
    .S05_AXI_ARPROT               ('0), // input wire [2 : 0] S00_AXI_ARPROT
    .S05_AXI_ARQOS                ('0), // input wire [3 : 0] S00_AXI_ARQOS
    .S05_AXI_ARSIZE               ('0), // input wire [2 : 0] S00_AXI_ARSIZE
    .S05_AXI_ARVALID              ('0), // input wire S00_AXI_ARVALID
    .S05_AXI_ARREADY              (),   // output wire S00_AXI_ARREADY
    .S05_AXI_AWADDR               ('0), // input wire [33 : 0] S00_AXI_AWADDR
    .S05_AXI_AWBURST              ('0), // input wire [1 : 0] S00_AXI_AWBURST
    .S05_AXI_AWCACHE              ('0), // input wire [3 : 0] S00_AXI_AWCACHE
    .S05_AXI_AWID                 ('0), // input wire [0 : 0] S00_AXI_AWID
    .S05_AXI_AWLEN                ('0), // input wire [7 : 0] S00_AXI_AWLEN
    .S05_AXI_AWLOCK               ('0), // input wire S00_AXI_AWLOCK
    .S05_AXI_AWPROT               ('0), // input wire [2 : 0] S00_AXI_AWPROT
    .S05_AXI_AWQOS                ('0), // input wire [3 : 0] S00_AXI_AWQOS
    .S05_AXI_AWREADY              (),   // output wire S00_AXI_AWREADY
    .S05_AXI_AWSIZE               ('0), // input wire [2 : 0] S00_AXI_AWSIZE
    .S05_AXI_AWVALID              ('0), // input wire S00_AXI_AWVALID
    .S05_AXI_BID                  (),   // output wire [0 : 0] S00_AXI_BID
    .S05_AXI_BREADY               ('0), // input wire S00_AXI_BREADY
    .S05_AXI_BRESP                (),   // output wire [1 : 0] S00_AXI_BRESP
    .S05_AXI_BVALID               (),   // output wire S00_AXI_BVALID
    .S05_AXI_RDATA                (),   // output wire [511 : 0] S00_AXI_RDATA
    .S05_AXI_RID                  (),   // output wire [0 : 0] S00_AXI_RID
    .S05_AXI_RLAST                (),   // output wire S00_AXI_RLAST
    .S05_AXI_RREADY               ('0), // input wire S00_AXI_RREADY
    .S05_AXI_RRESP                (),   // output wire [1 : 0] S00_AXI_RRESP
    .S05_AXI_RVALID               (),   // output wire S00_AXI_RVALID
    .S05_AXI_WDATA                ('0), // input wire [511 : 0] S00_AXI_WDATA
    .S05_AXI_WLAST                ('0), // input wire S00_AXI_WLAST
    .S05_AXI_WREADY               (),   // output wire S00_AXI_WREADY
    .S05_AXI_WSTRB                ('0), // input wire [63 : 0] S00_AXI_WSTRB
    .S05_AXI_WVALID               ('0), // input wire S00_AXI_WVALID

    // S06: unused
    .S06_AXI_ACLK                 (sys_clk), // input wire S00_AXI_ACLK
    .S06_AXI_ARESET_OUT_N         (S06_AXI_ARESET_OUT_N),   // output wire S00_AXI_ARESET_OUT_N
    .S06_AXI_ARADDR               ('0), // input wire [33 : 0] S00_AXI_ARADDR
    .S06_AXI_ARBURST              ('0), // input wire [1 : 0] S00_AXI_ARBURST
    .S06_AXI_ARCACHE              ('0), // input wire [3 : 0] S00_AXI_ARCACHE
    .S06_AXI_ARID                 ('0), // input wire [0 : 0] S00_AXI_ARID
    .S06_AXI_ARLEN                ('0), // input wire [7 : 0] S00_AXI_ARLEN
    .S06_AXI_ARLOCK               ('0), // input wire S00_AXI_ARLOCK
    .S06_AXI_ARPROT               ('0), // input wire [2 : 0] S00_AXI_ARPROT
    .S06_AXI_ARQOS                ('0), // input wire [3 : 0] S00_AXI_ARQOS
    .S06_AXI_ARSIZE               ('0), // input wire [2 : 0] S00_AXI_ARSIZE
    .S06_AXI_ARVALID              ('0), // input wire S00_AXI_ARVALID
    .S06_AXI_ARREADY              (),   // output wire S00_AXI_ARREADY
    .S06_AXI_AWADDR               ('0), // input wire [33 : 0] S00_AXI_AWADDR
    .S06_AXI_AWBURST              ('0), // input wire [1 : 0] S00_AXI_AWBURST
    .S06_AXI_AWCACHE              ('0), // input wire [3 : 0] S00_AXI_AWCACHE
    .S06_AXI_AWID                 ('0), // input wire [0 : 0] S00_AXI_AWID
    .S06_AXI_AWLEN                ('0), // input wire [7 : 0] S00_AXI_AWLEN
    .S06_AXI_AWLOCK               ('0), // input wire S00_AXI_AWLOCK
    .S06_AXI_AWPROT               ('0), // input wire [2 : 0] S00_AXI_AWPROT
    .S06_AXI_AWQOS                ('0), // input wire [3 : 0] S00_AXI_AWQOS
    .S06_AXI_AWREADY              (),   // output wire S00_AXI_AWREADY
    .S06_AXI_AWSIZE               ('0), // input wire [2 : 0] S00_AXI_AWSIZE
    .S06_AXI_AWVALID              ('0), // input wire S00_AXI_AWVALID
    .S06_AXI_BID                  (),   // output wire [0 : 0] S00_AXI_BID
    .S06_AXI_BREADY               ('0), // input wire S00_AXI_BREADY
    .S06_AXI_BRESP                (),   // output wire [1 : 0] S00_AXI_BRESP
    .S06_AXI_BVALID               (),   // output wire S00_AXI_BVALID
    .S06_AXI_RDATA                (),   // output wire [511 : 0] S00_AXI_RDATA
    .S06_AXI_RID                  (),   // output wire [0 : 0] S00_AXI_RID
    .S06_AXI_RLAST                (),   // output wire S00_AXI_RLAST
    .S06_AXI_RREADY               ('0), // input wire S00_AXI_RREADY
    .S06_AXI_RRESP                (),   // output wire [1 : 0] S00_AXI_RRESP
    .S06_AXI_RVALID               (),   // output wire S00_AXI_RVALID
    .S06_AXI_WDATA                ('0), // input wire [511 : 0] S00_AXI_WDATA
    .S06_AXI_WLAST                ('0), // input wire S00_AXI_WLAST
    .S06_AXI_WREADY               (),   // output wire S00_AXI_WREADY
    .S06_AXI_WSTRB                ('0), // input wire [63 : 0] S00_AXI_WSTRB
    .S06_AXI_WVALID               ('0), // input wire S00_AXI_WVALID

    // S07: unused
    .S07_AXI_ACLK                 (sys_clk), // input wire S00_AXI_ACLK
    .S07_AXI_ARESET_OUT_N         (S07_AXI_ARESET_OUT_N),   // output wire S00_AXI_ARESET_OUT_N
    .S07_AXI_ARADDR               ('0), // input wire [33 : 0] S00_AXI_ARADDR
    .S07_AXI_ARBURST              ('0), // input wire [1 : 0] S00_AXI_ARBURST
    .S07_AXI_ARCACHE              ('0), // input wire [3 : 0] S00_AXI_ARCACHE
    .S07_AXI_ARID                 ('0), // input wire [0 : 0] S00_AXI_ARID
    .S07_AXI_ARLEN                ('0), // input wire [7 : 0] S00_AXI_ARLEN
    .S07_AXI_ARLOCK               ('0), // input wire S00_AXI_ARLOCK
    .S07_AXI_ARPROT               ('0), // input wire [2 : 0] S00_AXI_ARPROT
    .S07_AXI_ARQOS                ('0), // input wire [3 : 0] S00_AXI_ARQOS
    .S07_AXI_ARSIZE               ('0), // input wire [2 : 0] S00_AXI_ARSIZE
    .S07_AXI_ARVALID              ('0), // input wire S00_AXI_ARVALID
    .S07_AXI_ARREADY              (),   // output wire S00_AXI_ARREADY
    .S07_AXI_AWADDR               ('0), // input wire [33 : 0] S00_AXI_AWADDR
    .S07_AXI_AWBURST              ('0), // input wire [1 : 0] S00_AXI_AWBURST
    .S07_AXI_AWCACHE              ('0), // input wire [3 : 0] S00_AXI_AWCACHE
    .S07_AXI_AWID                 ('0), // input wire [0 : 0] S00_AXI_AWID
    .S07_AXI_AWLEN                ('0), // input wire [7 : 0] S00_AXI_AWLEN
    .S07_AXI_AWLOCK               ('0), // input wire S00_AXI_AWLOCK
    .S07_AXI_AWPROT               ('0), // input wire [2 : 0] S00_AXI_AWPROT
    .S07_AXI_AWQOS                ('0), // input wire [3 : 0] S00_AXI_AWQOS
    .S07_AXI_AWREADY              (),   // output wire S00_AXI_AWREADY
    .S07_AXI_AWSIZE               ('0), // input wire [2 : 0] S00_AXI_AWSIZE
    .S07_AXI_AWVALID              ('0), // input wire S00_AXI_AWVALID
    .S07_AXI_BID                  (),   // output wire [0 : 0] S00_AXI_BID
    .S07_AXI_BREADY               ('0), // input wire S00_AXI_BREADY
    .S07_AXI_BRESP                (),   // output wire [1 : 0] S00_AXI_BRESP
    .S07_AXI_BVALID               (),   // output wire S00_AXI_BVALID
    .S07_AXI_RDATA                (),   // output wire [511 : 0] S00_AXI_RDATA
    .S07_AXI_RID                  (),   // output wire [0 : 0] S00_AXI_RID
    .S07_AXI_RLAST                (),   // output wire S00_AXI_RLAST
    .S07_AXI_RREADY               ('0), // input wire S00_AXI_RREADY
    .S07_AXI_RRESP                (),   // output wire [1 : 0] S00_AXI_RRESP
    .S07_AXI_RVALID               (),   // output wire S00_AXI_RVALID
    .S07_AXI_WDATA                ('0), // input wire [511 : 0] S00_AXI_WDATA
    .S07_AXI_WLAST                ('0), // input wire S00_AXI_WLAST
    .S07_AXI_WREADY               (),   // output wire S00_AXI_WREADY
    .S07_AXI_WSTRB                ('0), // input wire [63 : 0] S00_AXI_WSTRB
    .S07_AXI_WVALID               ('0), // input wire S00_AXI_WVALID

    // M00: DDR4 controller or RAM model (depending on DRAM_CONTROLLER and RAM_MODEL macros)
    .M00_AXI_ACLK                 (sys_clk),                  // input wire M00_AXI_ACLK
    .M00_AXI_ARESET_OUT_N         (M00_AXI_ARESET_OUT_N),  // output wire M00_AXI_ARESET_OUT_N

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

`ifdef DRAM_CONTROLLER

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

// Deactivate AXI interface to RAM model since this is routed internally to DRAM controller
assign c0_ddr4_s_axi_awid       = '0;
assign c0_ddr4_s_axi_awaddr     = '0;
assign c0_ddr4_s_axi_awlen      = '0;
assign c0_ddr4_s_axi_awsize     = '0;
assign c0_ddr4_s_axi_awburst    = '0;
assign c0_ddr4_s_axi_awlock     = '0;
assign c0_ddr4_s_axi_awcache    = '0;
assign c0_ddr4_s_axi_awprot     = '0;
assign c0_ddr4_s_axi_awqos      = '0;
assign c0_ddr4_s_axi_awvalid    = '0;
assign c0_ddr4_s_axi_wdata      = '0;
assign c0_ddr4_s_axi_wstrb      = '0;
assign c0_ddr4_s_axi_wlast      = '0;
assign c0_ddr4_s_axi_wvalid     = '0;
assign c0_ddr4_s_axi_bready     = '0;
assign c0_ddr4_s_axi_arid       = '0;
assign c0_ddr4_s_axi_araddr     = '0;
assign c0_ddr4_s_axi_arlen      = '0;
assign c0_ddr4_s_axi_arsize     = '0;
assign c0_ddr4_s_axi_arburst    = '0;
assign c0_ddr4_s_axi_arlock     = '0;
assign c0_ddr4_s_axi_arcache    = '0;
assign c0_ddr4_s_axi_arprot     = '0;
assign c0_ddr4_s_axi_arqos      = '0;
assign c0_ddr4_s_axi_arvalid    = '0;
assign c0_ddr4_s_axi_rready     = '0;

`else

// Drive DDR4 interface low since DRAM model is not used
assign c0_ddr4_act_n            = '0;
assign c0_ddr4_adr              = '0;
assign c0_ddr4_ba               = '0;
assign c0_ddr4_bg               = '0;
assign c0_ddr4_cke              = '0;
assign c0_ddr4_odt              = '0;
assign c0_ddr4_cs_n             = '0;
assign c0_ddr4_ck_t             = '0;
assign c0_ddr4_ck_c             = '0;
assign c0_ddr4_reset_n          = '0;
assign c0_ddr4_parity           = '0;
assign c0_ddr4_dq               = '0;
assign c0_ddr4_dqs_t            = '0;
assign c0_ddr4_dqs_c            = '0;
assign c0_init_calib_complete   = '0;
assign c0_data_compare_error    = '0;

`endif

always @(posedge c0_ddr4_clk) begin
  c0_ddr4_aresetn <= ~c0_ddr4_rst;
end

endmodule