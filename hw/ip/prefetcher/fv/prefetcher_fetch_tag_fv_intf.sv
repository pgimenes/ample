import top_pkg::*;
import prefetcher_pkg::*;

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
    input logic                                        deallocation_valid,
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
  @(posedge core_clk) disable iff (!resetn)
  (1 == 1)
);

/*

PROPERTIES TO DO

Deadlock:
- If receive NSB fetch req, eventually response with same type
- If receive NSB fetch req, eventually issue request to adj rm / msg rm

- Request correct number of bytes for adjacency queue
- Issue correct number of requests for message queue

Allocation
- If fetch tag not allocated, will stay idle forever (free and !ready)
*/

parameter AXI_DATA_WIDTH = 512;
parameter FEATURE_COUNT = top_pkg::MAX_FEATURE_COUNT;

parameter ADJ_QUEUE_MAX_BYTES = 64*4;
parameter MSG_QUEUE_DEPTH = 4096;

// Declarations
// --------------------------------------------------------

logic accepting_nsb_fetch_req;
logic accepted_adj_axi_req, accepted_msg_axi_req;

integer adj_axi_req_cnt, adj_axi_received_responses;
integer adj_req_expected_bytes, adj_req_requested_bytes, adj_req_received_bytes;
integer adj_req_neighbour_count;
integer adj_resp_count, adj_partial_resp_count;

integer msg_fetch_expected_axi_reqs, msg_fetch_expected_responses, msg_axi_req_cnt, msg_axi_received_responses;
integer msg_resp_count, msg_partial_resp_count;
integer msg_queue_neighbour_capacity;

integer msg_queue_beats_per_message;

integer nsb_adj_req_cnt;
integer nsb_msg_req_cnt;

always_comb begin
    accepting_nsb_fetch_req = nsb_prefetcher_req_valid && nsb_prefetcher_req_ready;
    
    msg_queue_beats_per_message = `divide_round_up(FEATURE_COUNT * top_pkg::bits_per_precision(nsb_prefetcher_req.nodeslot_precision), AXI_DATA_WIDTH);
end

// Counters
// --------------------------------------------------------

always_ff @( posedge core_clk or negedge resetn ) begin
    if(!resetn) begin
        accepted_adj_axi_req          <= '0;
        accepted_msg_axi_req          <= '0;

        adj_axi_req_cnt               <= 0;
        adj_axi_received_responses    <= 0;
        adj_req_expected_bytes        <= 0;
        adj_req_requested_bytes       <= 0;
        adj_req_received_bytes        <= 0;
        adj_resp_count                <= 0;
        adj_partial_resp_count        <= 0;
        nsb_adj_req_cnt               <= 0;
        adj_req_neighbour_count       <= '0;
        
        msg_fetch_expected_axi_reqs   <= 0;
        msg_fetch_expected_responses  <= 0;
        msg_axi_req_cnt               <= 0;
        msg_axi_received_responses    <= 0;
        msg_resp_count                <= 0;
        msg_partial_resp_count        <= 0;
        nsb_msg_req_cnt               <= 0;

    end else begin
    
        // Accepting NSB request for adjacency list
        if (!accepted_adj_axi_req && accepting_nsb_fetch_req && nsb_prefetcher_req.req_opcode == top_pkg::ADJACENCY_LIST) begin
            nsb_adj_req_cnt <= nsb_adj_req_cnt + 1;
            accepted_adj_axi_req <= '1;

            adj_req_expected_bytes <= nsb_prefetcher_req.neighbour_count * 4;
            adj_req_neighbour_count <= nsb_prefetcher_req.neighbour_count;

            adj_axi_req_cnt               <= 0;
            adj_req_requested_bytes       <= 0;
            adj_req_received_bytes        <= 0;

            adj_resp_count                <= 0;
            adj_partial_resp_count        <= 0;
        end

        // Accepting NSB request for message queue
        if (!accepted_msg_axi_req && accepting_nsb_fetch_req && nsb_prefetcher_req.req_opcode == top_pkg::MESSAGES) begin
            nsb_msg_req_cnt <= nsb_msg_req_cnt + 1;
            accepted_msg_axi_req <= '1;

            msg_fetch_expected_axi_reqs       <= adj_req_neighbour_count; // instead of nsb_prefetcher_req.neighbour_count
            msg_fetch_expected_responses      <= msg_queue_beats_per_message;

            msg_axi_req_cnt              <= 0;
            msg_axi_received_responses   <= 0;

            msg_resp_count                <= 0;
            msg_partial_resp_count        <= 0;

            msg_queue_neighbour_capacity <= MSG_QUEUE_DEPTH / msg_queue_beats_per_message; // round down if decimal number of neighbours
        end

        // Accepting request to adjacency read master
        if (fetch_tag_adj_rm_req_valid && fetch_tag_adj_rm_req_ready) begin
            adj_axi_req_cnt <= adj_axi_req_cnt + 1;
            adj_req_requested_bytes <= adj_req_requested_bytes + fetch_tag_adj_rm_byte_count;
        end

        // Receiving response beat from ADJ read master
        if (fetch_tag_adj_rm_resp_valid && fetch_tag_adj_rm_resp_ready) begin
            adj_req_received_bytes <= adj_req_received_bytes + 64;
        end

        // Accepting request to message read master
        if (fetch_tag_msg_rm_req_valid && fetch_tag_msg_rm_req_ready) begin
            msg_axi_req_cnt         <= msg_axi_req_cnt + 1;
        end

        // NSB responses
        if (nsb_prefetcher_resp_valid) begin
            case(nsb_prefetcher_resp.response_type)
                top_pkg::ADJACENCY_LIST: begin
                    adj_resp_count <= adj_resp_count + 1;
                    if (nsb_prefetcher_resp.partial) adj_partial_resp_count <= adj_partial_resp_count + 1;
                    else begin
                        accepted_adj_axi_req <= '0;
                    end
                end

                top_pkg::MESSAGES: begin
                    msg_resp_count <= msg_resp_count + 1;
                    if (nsb_prefetcher_resp.partial) msg_partial_resp_count <= msg_partial_resp_count + 1;
                    else begin
                        accepted_msg_axi_req <= '0;
                    end
                end
            endcase
        end
    end
end

// Assumptions
// ----------------------------------------------------

A_single_adj_req: assume property (
    @(posedge core_clk) disable iff (!resetn)
        nsb_prefetcher_req_valid && (nsb_prefetcher_req.req_opcode == top_pkg::ADJACENCY_LIST)
        |-> (nsb_adj_req_cnt == 0) // received at least a partial response
);

A_single_msg_req: assume property (
    @(posedge core_clk) disable iff (!resetn)
        nsb_prefetcher_req_valid && (nsb_prefetcher_req.req_opcode == top_pkg::MESSAGES)
        |-> (nsb_msg_req_cnt == 0) // received at least a partial response
);

A_msg_req_after_adj_resp: assume property (
    @(posedge core_clk) disable iff (!resetn)
        nsb_prefetcher_req_valid && (nsb_prefetcher_req.req_opcode == top_pkg::MESSAGES)
        |-> adj_resp_count > 0 // received at least a partial response
);

// Assertions
// --------------------------------------------------------

// MS2: consider only normal responses (no streaming)

// NON-PARTIAL RESPONSE: may take place if required_bytes < queue capacity, or partial response has previously been sent
P_adj_normal_resp: assert property (
    @(posedge core_clk) disable iff (!resetn)
        nsb_prefetcher_resp_valid && (nsb_prefetcher_resp.response_type == top_pkg::ADJACENCY_LIST) && !nsb_prefetcher_resp.partial
        |-> (adj_req_requested_bytes == adj_req_expected_bytes) && (adj_req_received_bytes >= adj_req_expected_bytes)
);

P_msg_normal_resp: assert property (
    @(posedge core_clk) disable iff (!resetn)
        nsb_prefetcher_resp_valid && (nsb_prefetcher_resp.response_type == top_pkg::MESSAGES) && !nsb_prefetcher_resp.partial
        |-> (msg_fetch_expected_axi_reqs == msg_axi_req_cnt)
);

// PARTIAL RESPONSE: should only be sent when adj queue is full and expected bytes is greater than 4*64
// TO DO: add assumption that message fetch request will not arrive until response sent to NSB
P_adj_correct_partial_response: assert property (
    @(posedge core_clk) disable iff (!resetn)
        nsb_prefetcher_resp_valid && (nsb_prefetcher_resp.response_type == top_pkg::ADJACENCY_LIST) && nsb_prefetcher_resp.partial
        |-> (adj_req_expected_bytes > ADJ_QUEUE_MAX_BYTES) && (adj_req_requested_bytes == ADJ_QUEUE_MAX_BYTES)
);

P_msg_correct_partial_response: assert property (
    @(posedge core_clk) disable iff (!resetn)
        nsb_prefetcher_resp_valid && (nsb_prefetcher_resp.response_type == top_pkg::MESSAGES) && nsb_prefetcher_resp.partial
        |-> (msg_fetch_expected_axi_reqs > msg_queue_neighbour_capacity) && (msg_axi_req_cnt == msg_queue_neighbour_capacity)
);

P_single_adj_partial_response: assert property (
    @(posedge core_clk) disable iff (!resetn)
        !(adj_partial_resp_count > 1)
);

P_single_msg_partial_response: assert property (
    @(posedge core_clk) disable iff (!resetn)
        !(msg_partial_resp_count > 1)
);

// Liveness (need to use symbiosis?)
// ----------------------------------------------------

// P_NSB_adj_req_eventual_resp: assert property (
//     @(posedge core_clk) disable iff (!resetn)
//         !tag_free && accepting_nsb_fetch_req && (nsb_prefetcher_req.req_opcode == top_pkg::ADJACENCY_LIST) |-> s_eventually(nsb_prefetcher_resp_valid && (nsb_prefetcher_resp.response_type == top_pkg::ADJACENCY_LIST))
// );

// P_NSB_msg_req_eventual_resp: assert property (
//     @(posedge core_clk) disable iff (!resetn)
//         !tag_free && accepting_nsb_fetch_req && (nsb_prefetcher_req.req_opcode == top_pkg::MESSAGES) |-> s_eventually(nsb_prefetcher_resp_valid && (nsb_prefetcher_resp.response_type == top_pkg::MESSAGES))
// );

// Coverage
// ----------------------------------------------------

C_fill_adj_queue: cover property (
    @(posedge core_clk) disable iff (!resetn)
        nsb_prefetcher_resp_valid && (nsb_prefetcher_resp.response_type == top_pkg::ADJACENCY_LIST)
        && (adj_req_requested_bytes == adj_req_expected_bytes)
        && (adj_req_expected_bytes == 256)
);

endinterface

bind prefetcher_fetch_tag prefetcher_fetch_tag_fv_intf prefetcher_fetch_tag_fv_intf_bind (.*);