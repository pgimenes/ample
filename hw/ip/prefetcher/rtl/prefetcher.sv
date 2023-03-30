
module prefetcher (
    input logic                               core_clk,
    input logic                               resetn,

    // NSB -> Prefetcher Interface
    input  logic                              nsb_prefetcher_req_valid,
    output logic                              nsb_prefetcher_req_ready,
    input  NSB_PREF_REQ_t                     nsb_prefetcher_req,
    output logic                              nsb_prefetcher_resp_valid, // valid only for now
    output NSB_PREF_RESP_t                    nsb_prefetcher_resp,

    // Prefetcher Adjacency Read Master -> AXI Memory Interconnect
    output logic [33:0]                       prefetcher_adj_rm_axi_interconnect_axi_araddr,
    output logic [1:0]                        prefetcher_adj_rm_axi_interconnect_axi_arburst,
    output logic [3:0]                        prefetcher_adj_rm_axi_interconnect_axi_arcache,
    output logic [3:0]                        prefetcher_adj_rm_axi_interconnect_axi_arid,
    output logic [7:0]                        prefetcher_adj_rm_axi_interconnect_axi_arlen,
    output logic [0:0]                        prefetcher_adj_rm_axi_interconnect_axi_arlock,
    output logic [2:0]                        prefetcher_adj_rm_axi_interconnect_axi_arprot,
    output logic [3:0]                        prefetcher_adj_rm_axi_interconnect_axi_arqos,
    output logic [2:0]                        prefetcher_adj_rm_axi_interconnect_axi_arsize,
    output logic                              prefetcher_adj_rm_axi_interconnect_axi_arvalid,
    input  logic                              prefetcher_adj_rm_axi_interconnect_axi_arready,
    output logic [33:0]                       prefetcher_adj_rm_axi_interconnect_axi_awaddr,
    output logic [1:0]                        prefetcher_adj_rm_axi_interconnect_axi_awburst,
    output logic [3:0]                        prefetcher_adj_rm_axi_interconnect_axi_awcache,
    output logic [3:0]                        prefetcher_adj_rm_axi_interconnect_axi_awid,
    output logic [7:0]                        prefetcher_adj_rm_axi_interconnect_axi_awlen,
    output logic [0:0]                        prefetcher_adj_rm_axi_interconnect_axi_awlock,
    output logic [2:0]                        prefetcher_adj_rm_axi_interconnect_axi_awprot,
    output logic [3:0]                        prefetcher_adj_rm_axi_interconnect_axi_awqos,
    input  logic                              prefetcher_adj_rm_axi_interconnect_axi_awready,
    output logic [2:0]                        prefetcher_adj_rm_axi_interconnect_axi_awsize,
    output logic                              prefetcher_adj_rm_axi_interconnect_axi_awvalid,
    input  logic [3:0]                        prefetcher_adj_rm_axi_interconnect_axi_bid,
    output logic                              prefetcher_adj_rm_axi_interconnect_axi_bready,
    input  logic [1:0]                        prefetcher_adj_rm_axi_interconnect_axi_bresp,
    input  logic                              prefetcher_adj_rm_axi_interconnect_axi_bvalid,
    input  logic [511:0]                      prefetcher_adj_rm_axi_interconnect_axi_rdata,
    input  logic [3:0]                        prefetcher_adj_rm_axi_interconnect_axi_rid,
    input  logic                              prefetcher_adj_rm_axi_interconnect_axi_rlast,
    output logic                              prefetcher_adj_rm_axi_interconnect_axi_rready,
    input  logic [1:0]                        prefetcher_adj_rm_axi_interconnect_axi_rresp,
    input  logic                              prefetcher_adj_rm_axi_interconnect_axi_rvalid,
    output logic [511:0]                      prefetcher_adj_rm_axi_interconnect_axi_wdata,
    output logic                              prefetcher_adj_rm_axi_interconnect_axi_wlast,
    input  logic                              prefetcher_adj_rm_axi_interconnect_axi_wready,
    output logic [63:0]                       prefetcher_adj_rm_axi_interconnect_axi_wstrb,
    output logic                              prefetcher_adj_rm_axi_interconnect_axi_wvalid,

    // Prefetcher Message Read Master -> AXI Memory Interconnect
    output logic [33:0]                       prefetcher_msg_rm_axi_interconnect_axi_araddr,
    output logic [1:0]                        prefetcher_msg_rm_axi_interconnect_axi_arburst,
    output logic [3:0]                        prefetcher_msg_rm_axi_interconnect_axi_arcache,
    output logic [3:0]                        prefetcher_msg_rm_axi_interconnect_axi_arid,
    output logic [7:0]                        prefetcher_msg_rm_axi_interconnect_axi_arlen,
    output logic [0:0]                        prefetcher_msg_rm_axi_interconnect_axi_arlock,
    output logic [2:0]                        prefetcher_msg_rm_axi_interconnect_axi_arprot,
    output logic [3:0]                        prefetcher_msg_rm_axi_interconnect_axi_arqos,
    output logic [2:0]                        prefetcher_msg_rm_axi_interconnect_axi_arsize,
    output logic                              prefetcher_msg_rm_axi_interconnect_axi_arvalid,
    input  logic                              prefetcher_msg_rm_axi_interconnect_axi_arready,
    output logic [33:0]                       prefetcher_msg_rm_axi_interconnect_axi_awaddr,
    output logic [1:0]                        prefetcher_msg_rm_axi_interconnect_axi_awburst,
    output logic [3:0]                        prefetcher_msg_rm_axi_interconnect_axi_awcache,
    output logic [3:0]                        prefetcher_msg_rm_axi_interconnect_axi_awid,
    output logic [7:0]                        prefetcher_msg_rm_axi_interconnect_axi_awlen,
    output logic [0:0]                        prefetcher_msg_rm_axi_interconnect_axi_awlock,
    output logic [2:0]                        prefetcher_msg_rm_axi_interconnect_axi_awprot,
    output logic [3:0]                        prefetcher_msg_rm_axi_interconnect_axi_awqos,
    input  logic                              prefetcher_msg_rm_axi_interconnect_axi_awready,
    output logic [2:0]                        prefetcher_msg_rm_axi_interconnect_axi_awsize,
    output logic                              prefetcher_msg_rm_axi_interconnect_axi_awvalid,
    input  logic [3:0]                        prefetcher_msg_rm_axi_interconnect_axi_bid,
    output logic                              prefetcher_msg_rm_axi_interconnect_axi_bready,
    input  logic [1:0]                        prefetcher_msg_rm_axi_interconnect_axi_bresp,
    input  logic                              prefetcher_msg_rm_axi_interconnect_axi_bvalid,
    input  logic [511:0]                      prefetcher_msg_rm_axi_interconnect_axi_rdata,
    input  logic [3:0]                        prefetcher_msg_rm_axi_interconnect_axi_rid,
    input  logic                              prefetcher_msg_rm_axi_interconnect_axi_rlast,
    output logic                              prefetcher_msg_rm_axi_interconnect_axi_rready,
    input  logic [1:0]                        prefetcher_msg_rm_axi_interconnect_axi_rresp,
    input  logic                              prefetcher_msg_rm_axi_interconnect_axi_rvalid,
    output logic [511:0]                      prefetcher_msg_rm_axi_interconnect_axi_wdata,
    output logic                              prefetcher_msg_rm_axi_interconnect_axi_wlast,
    input  logic                              prefetcher_msg_rm_axi_interconnect_axi_wready,
    output logic [63:0]                       prefetcher_msg_rm_axi_interconnect_axi_wstrb,
    output logic                              prefetcher_msg_rm_axi_interconnect_axi_wvalid,

    // Message Channels: AGE -> Prefetcher
    input  logic [MESSAGE_CHANNEL_COUNT-1:0]                  message_channel_req_valid,
    output logic [MESSAGE_CHANNEL_COUNT-1:0]                  message_channel_req_ready,
    input  MESSAGE_CHANNEL_REQ_t [MESSAGE_CHANNEL_COUNT-1:0]  message_channel_req,

    output logic [MESSAGE_CHANNEL_COUNT-1:0]                  message_channel_resp_valid,
    input  logic [MESSAGE_CHANNEL_COUNT-1:0]                  message_channel_resp_ready,
    output MESSAGE_CHANNEL_RESP_t [MESSAGE_CHANNEL_COUNT-1:0] message_channel_resp
    
);

// ==================================================================================================================================================
// Declarations
// ==================================================================================================================================================

// ==================================================================================================================================================
// Instances
// ==================================================================================================================================================


prefetcher_feature_bank feature_bank_i (
    .core_clk,
    .resetn,

    .nsb_prefetcher_feature_bank_req_valid    (nsb_prefetcher_req_valid),
    .nsb_prefetcher_feature_bank_req_ready    (nsb_prefetcher_req_ready),
    .nsb_prefetcher_feature_bank_req          (nsb_prefetcher_req),
    .nsb_prefetcher_feature_bank_resp_valid   (nsb_prefetcher_resp_valid),
    .nsb_prefetcher_feature_bank_resp         (nsb_prefetcher_resp),

    .prefetcher_feature_bank_adj_rm_axi_interconnect_axi_araddr         (prefetcher_adj_rm_axi_interconnect_axi_araddr),
    .prefetcher_feature_bank_adj_rm_axi_interconnect_axi_arburst        (prefetcher_adj_rm_axi_interconnect_axi_arburst),
    .prefetcher_feature_bank_adj_rm_axi_interconnect_axi_arcache        (prefetcher_adj_rm_axi_interconnect_axi_arcache),
    .prefetcher_feature_bank_adj_rm_axi_interconnect_axi_arid           (prefetcher_adj_rm_axi_interconnect_axi_arid),
    .prefetcher_feature_bank_adj_rm_axi_interconnect_axi_arlen          (prefetcher_adj_rm_axi_interconnect_axi_arlen),
    .prefetcher_feature_bank_adj_rm_axi_interconnect_axi_arlock         (prefetcher_adj_rm_axi_interconnect_axi_arlock),
    .prefetcher_feature_bank_adj_rm_axi_interconnect_axi_arprot         (prefetcher_adj_rm_axi_interconnect_axi_arprot),
    .prefetcher_feature_bank_adj_rm_axi_interconnect_axi_arqos          (prefetcher_adj_rm_axi_interconnect_axi_arqos),
    .prefetcher_feature_bank_adj_rm_axi_interconnect_axi_arsize         (prefetcher_adj_rm_axi_interconnect_axi_arsize),
    .prefetcher_feature_bank_adj_rm_axi_interconnect_axi_arvalid        (prefetcher_adj_rm_axi_interconnect_axi_arvalid),
    .prefetcher_feature_bank_adj_rm_axi_interconnect_axi_arready        (prefetcher_adj_rm_axi_interconnect_axi_arready),
    .prefetcher_feature_bank_adj_rm_axi_interconnect_axi_awaddr         (prefetcher_adj_rm_axi_interconnect_axi_awaddr),
    .prefetcher_feature_bank_adj_rm_axi_interconnect_axi_awburst        (prefetcher_adj_rm_axi_interconnect_axi_awburst),
    .prefetcher_feature_bank_adj_rm_axi_interconnect_axi_awcache        (prefetcher_adj_rm_axi_interconnect_axi_awcache),
    .prefetcher_feature_bank_adj_rm_axi_interconnect_axi_awid           (prefetcher_adj_rm_axi_interconnect_axi_awid),
    .prefetcher_feature_bank_adj_rm_axi_interconnect_axi_awlen          (prefetcher_adj_rm_axi_interconnect_axi_awlen),
    .prefetcher_feature_bank_adj_rm_axi_interconnect_axi_awlock         (prefetcher_adj_rm_axi_interconnect_axi_awlock),
    .prefetcher_feature_bank_adj_rm_axi_interconnect_axi_awprot         (prefetcher_adj_rm_axi_interconnect_axi_awprot),
    .prefetcher_feature_bank_adj_rm_axi_interconnect_axi_awqos          (prefetcher_adj_rm_axi_interconnect_axi_awqos),
    .prefetcher_feature_bank_adj_rm_axi_interconnect_axi_awready        (prefetcher_adj_rm_axi_interconnect_axi_awready),
    .prefetcher_feature_bank_adj_rm_axi_interconnect_axi_awsize         (prefetcher_adj_rm_axi_interconnect_axi_awsize),
    .prefetcher_feature_bank_adj_rm_axi_interconnect_axi_awvalid        (prefetcher_adj_rm_axi_interconnect_axi_awvalid),
    .prefetcher_feature_bank_adj_rm_axi_interconnect_axi_bid            (prefetcher_adj_rm_axi_interconnect_axi_bid),
    .prefetcher_feature_bank_adj_rm_axi_interconnect_axi_bready         (prefetcher_adj_rm_axi_interconnect_axi_bready),
    .prefetcher_feature_bank_adj_rm_axi_interconnect_axi_bresp          (prefetcher_adj_rm_axi_interconnect_axi_bresp),
    .prefetcher_feature_bank_adj_rm_axi_interconnect_axi_bvalid         (prefetcher_adj_rm_axi_interconnect_axi_bvalid),
    .prefetcher_feature_bank_adj_rm_axi_interconnect_axi_rdata          (prefetcher_adj_rm_axi_interconnect_axi_rdata),
    .prefetcher_feature_bank_adj_rm_axi_interconnect_axi_rid            (prefetcher_adj_rm_axi_interconnect_axi_rid),
    .prefetcher_feature_bank_adj_rm_axi_interconnect_axi_rlast          (prefetcher_adj_rm_axi_interconnect_axi_rlast),
    .prefetcher_feature_bank_adj_rm_axi_interconnect_axi_rready         (prefetcher_adj_rm_axi_interconnect_axi_rready),
    .prefetcher_feature_bank_adj_rm_axi_interconnect_axi_rresp          (prefetcher_adj_rm_axi_interconnect_axi_rresp),
    .prefetcher_feature_bank_adj_rm_axi_interconnect_axi_rvalid         (prefetcher_adj_rm_axi_interconnect_axi_rvalid),
    .prefetcher_feature_bank_adj_rm_axi_interconnect_axi_wdata          (prefetcher_adj_rm_axi_interconnect_axi_wdata),
    .prefetcher_feature_bank_adj_rm_axi_interconnect_axi_wlast          (prefetcher_adj_rm_axi_interconnect_axi_wlast),
    .prefetcher_feature_bank_adj_rm_axi_interconnect_axi_wready         (prefetcher_adj_rm_axi_interconnect_axi_wready),
    .prefetcher_feature_bank_adj_rm_axi_interconnect_axi_wstrb          (prefetcher_adj_rm_axi_interconnect_axi_wstrb),
    .prefetcher_feature_bank_adj_rm_axi_interconnect_axi_wvalid         (prefetcher_adj_rm_axi_interconnect_axi_wvalid),

    .prefetcher_feature_bank_msg_rm_axi_interconnect_axi_araddr         (prefetcher_msg_rm_axi_interconnect_axi_araddr),
    .prefetcher_feature_bank_msg_rm_axi_interconnect_axi_arburst        (prefetcher_msg_rm_axi_interconnect_axi_arburst),
    .prefetcher_feature_bank_msg_rm_axi_interconnect_axi_arcache        (prefetcher_msg_rm_axi_interconnect_axi_arcache),
    .prefetcher_feature_bank_msg_rm_axi_interconnect_axi_arid           (prefetcher_msg_rm_axi_interconnect_axi_arid),
    .prefetcher_feature_bank_msg_rm_axi_interconnect_axi_arlen          (prefetcher_msg_rm_axi_interconnect_axi_arlen),
    .prefetcher_feature_bank_msg_rm_axi_interconnect_axi_arlock         (prefetcher_msg_rm_axi_interconnect_axi_arlock),
    .prefetcher_feature_bank_msg_rm_axi_interconnect_axi_arprot         (prefetcher_msg_rm_axi_interconnect_axi_arprot),
    .prefetcher_feature_bank_msg_rm_axi_interconnect_axi_arqos          (prefetcher_msg_rm_axi_interconnect_axi_arqos),
    .prefetcher_feature_bank_msg_rm_axi_interconnect_axi_arsize         (prefetcher_msg_rm_axi_interconnect_axi_arsize),
    .prefetcher_feature_bank_msg_rm_axi_interconnect_axi_arvalid        (prefetcher_msg_rm_axi_interconnect_axi_arvalid),
    .prefetcher_feature_bank_msg_rm_axi_interconnect_axi_arready        (prefetcher_msg_rm_axi_interconnect_axi_arready),
    .prefetcher_feature_bank_msg_rm_axi_interconnect_axi_awaddr         (prefetcher_msg_rm_axi_interconnect_axi_awaddr),
    .prefetcher_feature_bank_msg_rm_axi_interconnect_axi_awburst        (prefetcher_msg_rm_axi_interconnect_axi_awburst),
    .prefetcher_feature_bank_msg_rm_axi_interconnect_axi_awcache        (prefetcher_msg_rm_axi_interconnect_axi_awcache),
    .prefetcher_feature_bank_msg_rm_axi_interconnect_axi_awid           (prefetcher_msg_rm_axi_interconnect_axi_awid),
    .prefetcher_feature_bank_msg_rm_axi_interconnect_axi_awlen          (prefetcher_msg_rm_axi_interconnect_axi_awlen),
    .prefetcher_feature_bank_msg_rm_axi_interconnect_axi_awlock         (prefetcher_msg_rm_axi_interconnect_axi_awlock),
    .prefetcher_feature_bank_msg_rm_axi_interconnect_axi_awprot         (prefetcher_msg_rm_axi_interconnect_axi_awprot),
    .prefetcher_feature_bank_msg_rm_axi_interconnect_axi_awqos          (prefetcher_msg_rm_axi_interconnect_axi_awqos),
    .prefetcher_feature_bank_msg_rm_axi_interconnect_axi_awready        (prefetcher_msg_rm_axi_interconnect_axi_awready),
    .prefetcher_feature_bank_msg_rm_axi_interconnect_axi_awsize         (prefetcher_msg_rm_axi_interconnect_axi_awsize),
    .prefetcher_feature_bank_msg_rm_axi_interconnect_axi_awvalid        (prefetcher_msg_rm_axi_interconnect_axi_awvalid),
    .prefetcher_feature_bank_msg_rm_axi_interconnect_axi_bid            (prefetcher_msg_rm_axi_interconnect_axi_bid),
    .prefetcher_feature_bank_msg_rm_axi_interconnect_axi_bready         (prefetcher_msg_rm_axi_interconnect_axi_bready),
    .prefetcher_feature_bank_msg_rm_axi_interconnect_axi_bresp          (prefetcher_msg_rm_axi_interconnect_axi_bresp),
    .prefetcher_feature_bank_msg_rm_axi_interconnect_axi_bvalid         (prefetcher_msg_rm_axi_interconnect_axi_bvalid),
    .prefetcher_feature_bank_msg_rm_axi_interconnect_axi_rdata          (prefetcher_msg_rm_axi_interconnect_axi_rdata),
    .prefetcher_feature_bank_msg_rm_axi_interconnect_axi_rid            (prefetcher_msg_rm_axi_interconnect_axi_rid),
    .prefetcher_feature_bank_msg_rm_axi_interconnect_axi_rlast          (prefetcher_msg_rm_axi_interconnect_axi_rlast),
    .prefetcher_feature_bank_msg_rm_axi_interconnect_axi_rready         (prefetcher_msg_rm_axi_interconnect_axi_rready),
    .prefetcher_feature_bank_msg_rm_axi_interconnect_axi_rresp          (prefetcher_msg_rm_axi_interconnect_axi_rresp),
    .prefetcher_feature_bank_msg_rm_axi_interconnect_axi_rvalid         (prefetcher_msg_rm_axi_interconnect_axi_rvalid),
    .prefetcher_feature_bank_msg_rm_axi_interconnect_axi_wdata          (prefetcher_msg_rm_axi_interconnect_axi_wdata),
    .prefetcher_feature_bank_msg_rm_axi_interconnect_axi_wlast          (prefetcher_msg_rm_axi_interconnect_axi_wlast),
    .prefetcher_feature_bank_msg_rm_axi_interconnect_axi_wready         (prefetcher_msg_rm_axi_interconnect_axi_wready),
    .prefetcher_feature_bank_msg_rm_axi_interconnect_axi_wstrb          (prefetcher_msg_rm_axi_interconnect_axi_wstrb),
    .prefetcher_feature_bank_msg_rm_axi_interconnect_axi_wvalid         (prefetcher_msg_rm_axi_interconnect_axi_wvalid),

    .message_channel_req_valid                                          (message_channel_req_valid),
    .message_channel_req_ready                                          (message_channel_req_ready),
    .message_channel_req                                                (message_channel_req),
    .message_channel_resp_valid                                         (message_channel_resp_valid),
    .message_channel_resp_ready                                         (message_channel_resp_ready),
    .message_channel_resp                                               (message_channel_resp)
    
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