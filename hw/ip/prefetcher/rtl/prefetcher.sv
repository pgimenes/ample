import top_pkg::*;

module prefetcher #(
    parameter AXI_ADDRESS_WIDTH = 34,
    parameter AXI_DATA_WIDTH    = 32,
    parameter FETCH_TAG_COUNT   = 1
) (
    input logic core_clk,
    input logic resetn,

    // NSB -> Prefetcher Interface
    input  logic                              nsb_prefetcher_req_valid,
    output logic                              nsb_prefetcher_req_ready,
    input  NSB_PREF_REQ_t                     nsb_prefetcher_req,
    output logic                              nsb_prefetcher_resp_valid, // valid only for now
    output NSB_PREF_RESP_t                    nsb_prefetcher_resp,

    // // Message Channels: AGE -> Prefetcher
    // input  logic [MESSAGE_CHANNEL_COUNT-1:0]                  message_channel_req_valid,
    // output logic [MESSAGE_CHANNEL_COUNT-1:0]                  message_channel_req_ready,
    // input  MESSAGE_CHANNEL_REQ_t [MESSAGE_CHANNEL_COUNT-1:0]  message_channel_req,

    // output logic [MESSAGE_CHANNEL_COUNT-1:0]                  message_channel_resp_valid,
    // input  logic [MESSAGE_CHANNEL_COUNT-1:0]                  message_channel_resp_ready,
    // output MESSAGE_CHANNEL_RESP_t [MESSAGE_CHANNEL_COUNT-1:0] message_channel_resp,

    // Prefetcher -> AXI Memory Interconnect
    output logic [33:0]                       prefetcher_axi_interconnect_axi_araddr,
    output logic [1:0]                        prefetcher_axi_interconnect_axi_arburst,
    output logic [3:0]                        prefetcher_axi_interconnect_axi_arcache,
    output logic [3:0]                        prefetcher_axi_interconnect_axi_arid,
    output logic [7:0]                        prefetcher_axi_interconnect_axi_arlen,
    output logic [0:0]                        prefetcher_axi_interconnect_axi_arlock,
    output logic [2:0]                        prefetcher_axi_interconnect_axi_arprot,
    output logic [3:0]                        prefetcher_axi_interconnect_axi_arqos,
    output logic [2:0]                        prefetcher_axi_interconnect_axi_arsize,
    output logic                              prefetcher_axi_interconnect_axi_arvalid,
    input  logic                              prefetcher_axi_interconnect_axi_arready,
    output logic [33:0]                       prefetcher_axi_interconnect_axi_awaddr,
    output logic [1:0]                        prefetcher_axi_interconnect_axi_awburst,
    output logic [3:0]                        prefetcher_axi_interconnect_axi_awcache,
    output logic [3:0]                        prefetcher_axi_interconnect_axi_awid,
    output logic [7:0]                        prefetcher_axi_interconnect_axi_awlen,
    output logic [0:0]                        prefetcher_axi_interconnect_axi_awlock,
    output logic [2:0]                        prefetcher_axi_interconnect_axi_awprot,
    output logic [3:0]                        prefetcher_axi_interconnect_axi_awqos,
    input  logic                              prefetcher_axi_interconnect_axi_awready,
    output logic [2:0]                        prefetcher_axi_interconnect_axi_awsize,
    output logic                              prefetcher_axi_interconnect_axi_awvalid,
    input  logic [3:0]                        prefetcher_axi_interconnect_axi_bid,
    output logic                              prefetcher_axi_interconnect_axi_bready,
    input  logic [1:0]                        prefetcher_axi_interconnect_axi_bresp,
    input  logic                              prefetcher_axi_interconnect_axi_bvalid,
    input  logic [511:0]                      prefetcher_axi_interconnect_axi_rdata,
    input  logic [3:0]                        prefetcher_axi_interconnect_axi_rid,
    input  logic                              prefetcher_axi_interconnect_axi_rlast,
    output logic                              prefetcher_axi_interconnect_axi_rready,
    input  logic [1:0]                        prefetcher_axi_interconnect_axi_rresp,
    input  logic                              prefetcher_axi_interconnect_axi_rvalid,
    output logic [511:0]                      prefetcher_axi_interconnect_axi_wdata,
    output logic                              prefetcher_axi_interconnect_axi_wlast,
    input  logic                              prefetcher_axi_interconnect_axi_wready,
    output logic [63:0]                       prefetcher_axi_interconnect_axi_wstrb,
    output logic                              prefetcher_axi_interconnect_axi_wvalid
    
);


// ==================================================================================================================================================
// Declarations
// ==================================================================================================================================================

// Adjacency Read Master
logic                                        adj_rm_fetch_req_valid;
logic                                        adj_rm_fetch_req_ready;
logic [AXI_ADDRESS_WIDTH-1:0]                adj_rm_fetch_start_address;
logic [$clog2(MAX_FETCH_REQ_BYTE_COUNT)-1:0] adj_rm_fetch_byte_count;

logic                                        adj_rm_fetch_resp_valid;
logic                                        adj_rm_fetch_resp_ready;
logic                                        adj_rm_fetch_resp_last;
logic [AXI_DATA_WIDTH-1:0]                   adj_rm_fetch_resp_data;
logic [3:0]                                  adj_rm_fetch_resp_axi_id;

// Adjacency Read Master
logic                                        msg_rm_fetch_req_valid;
logic                                        msg_rm_fetch_req_ready;
logic [AXI_ADDRESS_WIDTH-1:0]                msg_rm_fetch_start_address;
logic [$clog2(MAX_FETCH_REQ_BYTE_COUNT)-1:0] msg_rm_fetch_byte_count;

logic                                        msg_rm_fetch_resp_valid;
logic                                        msg_rm_fetch_resp_ready;
logic                                        msg_rm_fetch_resp_last;
logic [AXI_DATA_WIDTH-1:0]                   msg_rm_fetch_resp_data;
logic [3:0]                                  msg_rm_fetch_resp_axi_id;

// Fetch tag allocation
logic [FETCH_TAG_COUNT-1:0]                                        allocation_valid;
logic [FETCH_TAG_COUNT-1:0] [$clog2(MAX_NODESLOT_COUNT)-1:0]       allocation_nodeslot;
logic [FETCH_TAG_COUNT-1:0] [$clog2(MAX_FEATURE_COUNT)-1:0]        allocation_feature_count;
logic [FETCH_TAG_COUNT-1:0]                                        tag_free;

logic [FETCH_TAG_COUNT-1:0]                                        fetch_tag_adj_rm_req_valid;
logic [FETCH_TAG_COUNT-1:0]                                        fetch_tag_adj_rm_req_ready;
logic [FETCH_TAG_COUNT-1:0] [AXI_ADDRESS_WIDTH-1:0]                fetch_tag_adj_rm_start_address;
logic [FETCH_TAG_COUNT-1:0] [$clog2(MAX_FETCH_REQ_BYTE_COUNT)-1:0] fetch_tag_adj_rm_byte_count;

logic [FETCH_TAG_COUNT-1:0]                                       fetch_tag_adj_rm_resp_valid;
logic [FETCH_TAG_COUNT-1:0]                                       fetch_tag_adj_rm_resp_ready;
logic [FETCH_TAG_COUNT-1:0]                                       fetch_tag_adj_rm_resp_last;
logic [FETCH_TAG_COUNT-1:0] [AXI_DATA_WIDTH-1:0]                  fetch_tag_adj_rm_resp_data;
logic [FETCH_TAG_COUNT-1:0] [3:0]                                 fetch_tag_adj_rm_resp_axi_id;

logic [FETCH_TAG_COUNT-1:0]                                        fetch_tag_msg_rm_req_valid;
logic [FETCH_TAG_COUNT-1:0]                                        fetch_tag_msg_rm_req_ready;
logic [FETCH_TAG_COUNT-1:0] [AXI_ADDRESS_WIDTH-1:0]                fetch_tag_msg_rm_start_address;
logic [FETCH_TAG_COUNT-1:0] [$clog2(MAX_FETCH_REQ_BYTE_COUNT)-1:0] fetch_tag_msg_rm_byte_count;

logic [FETCH_TAG_COUNT-1:0]                                       fetch_tag_msg_rm_resp_valid;
logic [FETCH_TAG_COUNT-1:0]                                       fetch_tag_msg_rm_resp_ready;
logic [FETCH_TAG_COUNT-1:0]                                       fetch_tag_msg_rm_resp_last;
logic [FETCH_TAG_COUNT-1:0] [AXI_DATA_WIDTH-1:0]                  fetch_tag_msg_rm_resp_data;
logic [FETCH_TAG_COUNT-1:0] [3:0]                                 fetch_tag_msg_rm_resp_axi_id;

logic [FETCH_TAG_COUNT-1:0]                                        nsb_prefetcher_fetch_tag_req_valid;
logic [FETCH_TAG_COUNT-1:0]                                        nsb_prefetcher_fetch_tag_req_ready;
NSB_PREF_REQ_t [FETCH_TAG_COUNT-1:0]                               nsb_prefetcher_fetch_tag_req;
logic [FETCH_TAG_COUNT-1:0]                                        nsb_prefetcher_fetch_tag_resp_valid;
NSB_PREF_RESP_t [FETCH_TAG_COUNT-1:0]                              nsb_prefetcher_fetch_tag_resp;

// ==================================================================================================================================================
// Instances
// ==================================================================================================================================================

for (genvar fetch_tag = 0; fetch_tag < FETCH_TAG_COUNT; fetch_tag = fetch_tag + 1) begin
    prefetcher_fetch_tag #(
        .ADJ_QUEUE_WIDTH      (32),
        .ADJ_QUEUE_DEPTH      (64),
        .MESSAGE_QUEUE_WIDTH  (512),
        .MESSAGE_QUEUE_DEPTH  (4096)
    ) fetch_tag_i (
        .core_clk,
        .resetn,

        // NSB -> Prefetcher Interface
        .nsb_prefetcher_req_valid                       (nsb_prefetcher_fetch_tag_req_valid  [fetch_tag]),
        .nsb_prefetcher_req_ready                       (nsb_prefetcher_fetch_tag_req_ready  [fetch_tag]),
        .nsb_prefetcher_req                             (nsb_prefetcher_fetch_tag_req        [fetch_tag]),
        .nsb_prefetcher_resp_valid                      (nsb_prefetcher_fetch_tag_resp_valid [fetch_tag]),
        .nsb_prefetcher_resp                            (nsb_prefetcher_fetch_tag_resp       [fetch_tag]),

        // Allocation interface
        .allocation_valid                               (allocation_valid                    [fetch_tag]),
        .allocation_nodeslot                            (allocation_nodeslot                 [fetch_tag]),
        .allocation_feature_count                       (allocation_feature_count            [fetch_tag]),
        .tag_free                                       (tag_free                            [fetch_tag]),

        // Request interface to Adjacency AXI Master
        .fetch_tag_adj_rm_req_valid                     (fetch_tag_adj_rm_req_valid     [fetch_tag]),
        .fetch_tag_adj_rm_req_ready                     (fetch_tag_adj_rm_req_ready     [fetch_tag]),
        .fetch_tag_adj_rm_start_address                 (fetch_tag_adj_rm_start_address [fetch_tag]),
        .fetch_tag_adj_rm_byte_count                    (fetch_tag_adj_rm_byte_count    [fetch_tag]),

        // Response interface from Adjacency AXI Master
        .fetch_tag_adj_rm_resp_valid                    (fetch_tag_adj_rm_resp_valid    [fetch_tag]),
        .fetch_tag_adj_rm_resp_ready                    (fetch_tag_adj_rm_resp_ready    [fetch_tag]),
        .fetch_tag_adj_rm_resp_last                     (fetch_tag_adj_rm_resp_last     [fetch_tag]),
        .fetch_tag_adj_rm_resp_data                     (fetch_tag_adj_rm_resp_data     [fetch_tag]),
        .fetch_tag_adj_rm_resp_axi_id                   (fetch_tag_adj_rm_resp_axi_id   [fetch_tag]),

        // Request interface to Message AXI Master
        .fetch_tag_msg_rm_req_valid                     (fetch_tag_msg_rm_req_valid     [fetch_tag]),
        .fetch_tag_msg_rm_req_ready                     (fetch_tag_msg_rm_req_ready     [fetch_tag]),
        .fetch_tag_msg_rm_start_address                 (fetch_tag_msg_rm_start_address [fetch_tag]),
        .fetch_tag_msg_rm_byte_count                    (fetch_tag_msg_rm_byte_count    [fetch_tag]),

        // Response interface from Message AXI Master
        .fetch_tag_msg_rm_resp_valid                    (fetch_tag_msg_rm_resp_valid    [fetch_tag]),
        .fetch_tag_msg_rm_resp_ready                    (fetch_tag_msg_rm_resp_ready    [fetch_tag]),
        .fetch_tag_msg_rm_resp_last                     (fetch_tag_msg_rm_resp_last     [fetch_tag]),
        .fetch_tag_msg_rm_resp_data                     (fetch_tag_msg_rm_resp_data     [fetch_tag]),
        .fetch_tag_msg_rm_resp_axi_id                   (fetch_tag_msg_rm_resp_axi_id   [fetch_tag])
);
end

// TO DO: add msg read master

axi_read_master #(
    .MAX_BYTE_COUNT (MAX_FETCH_REQ_BYTE_COUNT)
) adj_read_master (
    .clk         (core_clk),
    .resetn      (resetn),
    
    .fetch_req_valid            (adj_rm_fetch_req_valid),
    .fetch_req_ready            (adj_rm_fetch_req_ready),
    .fetch_start_address        (adj_rm_fetch_start_address),
    .fetch_byte_count           (adj_rm_fetch_byte_count),

    // Response interface
    .fetch_resp_valid           (adj_rm_fetch_resp_valid),
    .fetch_resp_ready           (adj_rm_fetch_resp_ready),
    .fetch_resp_last            (adj_rm_fetch_resp_last),
    .fetch_resp_data            (adj_rm_fetch_resp_data),
    .fetch_resp_axi_id          (adj_rm_fetch_resp_axi_id),

    // AXI Read-Only Interface
   .axi_araddr                  (prefetcher_axi_interconnect_axi_araddr),
   .axi_arburst                 (prefetcher_axi_interconnect_axi_arburst),
   .axi_arcache                 (prefetcher_axi_interconnect_axi_arcache),
   .axi_arid                    (prefetcher_axi_interconnect_axi_arid),
   .axi_arlen                   (prefetcher_axi_interconnect_axi_arlen),
   .axi_arlock                  (prefetcher_axi_interconnect_axi_arlock),
   .axi_arprot                  (prefetcher_axi_interconnect_axi_arprot),
   .axi_arqos                   (prefetcher_axi_interconnect_axi_arqos),
   .axi_arsize                  (prefetcher_axi_interconnect_axi_arsize),
   .axi_arvalid                 (prefetcher_axi_interconnect_axi_arvalid),
   .axi_arready                 (prefetcher_axi_interconnect_axi_arready),
   .axi_rdata                   (prefetcher_axi_interconnect_axi_rdata),
   .axi_rid                     (prefetcher_axi_interconnect_axi_rid),
   .axi_rlast                   (prefetcher_axi_interconnect_axi_rlast),
   .axi_rvalid                  (prefetcher_axi_interconnect_axi_rvalid),
   .axi_rready                  (prefetcher_axi_interconnect_axi_rready),
   .axi_rresp                   (prefetcher_axi_interconnect_axi_rresp)
);

// ==================================================================================================================================================
// Logic
// ==================================================================================================================================================

// Fetch tag allocation
// ----------------------------------------------------------------------------------

assign nsb_prefetcher_fetch_tag_req_valid  [0] = nsb_prefetcher_req_valid;
assign nsb_prefetcher_fetch_tag_req_ready  [0] = nsb_prefetcher_req_ready;
assign nsb_prefetcher_fetch_tag_req        [0] = nsb_prefetcher_req;
assign nsb_prefetcher_fetch_tag_resp_valid [0] = nsb_prefetcher_resp_valid;
assign nsb_prefetcher_fetch_tag_resp       [0] = nsb_prefetcher_resp;

always_comb begin
    // Read-only interface
    prefetcher_axi_interconnect_axi_awaddr      = '0;
    prefetcher_axi_interconnect_axi_awburst     = '0;
    prefetcher_axi_interconnect_axi_awcache     = '0;
    prefetcher_axi_interconnect_axi_awid        = '0;
    prefetcher_axi_interconnect_axi_awlen       = '0;
    prefetcher_axi_interconnect_axi_awlock      = '0;
    prefetcher_axi_interconnect_axi_awprot      = '0;
    prefetcher_axi_interconnect_axi_awqos       = '0;
    prefetcher_axi_interconnect_axi_awsize      = '0;
    prefetcher_axi_interconnect_axi_awvalid     = '0;
    prefetcher_axi_interconnect_axi_bready      = '0;
    prefetcher_axi_interconnect_axi_wdata       = '0;
    prefetcher_axi_interconnect_axi_wlast       = '0;
    prefetcher_axi_interconnect_axi_wstrb       = '0;
    prefetcher_axi_interconnect_axi_wvalid      = '0;

    // NSB interface
    nsb_prefetcher_req_ready                    = '1; // drop all requests
    nsb_prefetcher_resp_valid                   = '0;
    nsb_prefetcher_resp                         = '0;
end

// ==================================================================================================================================================
// Assertions
// ==================================================================================================================================================

endmodule