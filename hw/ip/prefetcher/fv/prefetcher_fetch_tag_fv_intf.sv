
interface prefetcher_fetch_tag_fv_intf(

    input logic core_clk,
    input logic resetn,

    // NSB -> Prefetcher Interface
    input logic                                        nsb_prefetcher_req_valid,
    input logic                                        nsb_prefetcher_req_ready,
    input NSB_PREF_REQ_t                               nsb_prefetcher_req,

    input logic                                        nsb_prefetcher_resp_valid,
    input NSB_PREF_RESP_t                              nsb_prefetcher_resp,

    // Allocation interface
    input logic                                        allocation_valid,
    input logic [$clog2(MAX_NODESLOT_COUNT)-1:0]       allocation_nodeslot,
    input logic [$clog2(MAX_FEATURE_COUNT)-1:0]        allocation_feature_count,
    input logic                                        tag_free,

    // Request interface to Adjacency AXI Master
    input logic                                        fetch_tag_adj_rm_req_valid,
    input logic                                        fetch_tag_adj_rm_req_ready,
    input logic [AXI_ADDRESS_WIDTH-1:0]                fetch_tag_adj_rm_start_address,
    input logic [$clog2(MAX_FETCH_REQ_BYTE_COUNT)-1:0] fetch_tag_adj_rm_byte_count,

    // Response interface from Adjacency AXI Master
    input logic                                        fetch_tag_adj_rm_resp_valid,
    input logic                                        fetch_tag_adj_rm_resp_ready,
    input logic                                        fetch_tag_adj_rm_resp_last,
    input logic [AXI_DATA_WIDTH-1:0]                   fetch_tag_adj_rm_resp_data,
    input logic [3:0]                                  fetch_tag_adj_rm_resp_axi_id,

    // Request interface to Message AXI Master
    input logic                                        fetch_tag_msg_rm_req_valid,
    input logic                                        fetch_tag_msg_rm_req_ready,
    input logic [AXI_ADDRESS_WIDTH-1:0]                fetch_tag_msg_rm_start_address,
    input logic [$clog2(MAX_FETCH_REQ_BYTE_COUNT)-1:0] fetch_tag_msg_rm_byte_count,

    // Response interface from Message AXI Master
    input logic                                        fetch_tag_msg_rm_resp_valid,
    input logic                                        fetch_tag_msg_rm_resp_ready,
    input logic                                        fetch_tag_msg_rm_resp_last,
    input logic [AXI_DATA_WIDTH-1:0]                   fetch_tag_msg_rm_resp_data,
    input logic [3:0]                                  fetch_tag_msg_rm_resp_axi_id

);

P_one: assert property (
  @(posedge clk) disable iff (!resetn)
  1
);

endinterface