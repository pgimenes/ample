
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
    output logic                              prefetcher_msg_rm_axi_interconnect_axi_wvalid
);

// ==================================================================================================================================================
// Declarations
// ==================================================================================================================================================

// ==================================================================================================================================================
// Instances
// ==================================================================================================================================================


// TO DO: finish
prefetcher prefetcher_i (
    .core_clk,
    .resetn,

    .nsb_prefetcher_feature_bank_req_valid    (nsb_prefetcher_req_valid),
    .nsb_prefetcher_feature_bank_req_ready    (nsb_prefetcher_req_ready),
    .nsb_prefetcher_feature_bank_req          (nsb_prefetcher_req),
    .nsb_prefetcher_feature_bank_resp_valid   (nsb_prefetcher_resp_valid),
    .nsb_prefetcher_feature_bank_resp         (nsb_prefetcher_resp),
    
);

// ==================================================================================================================================================
// Logic
// ==================================================================================================================================================

endmodule