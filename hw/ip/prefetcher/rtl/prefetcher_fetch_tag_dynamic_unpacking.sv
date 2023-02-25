
import top_pkg::*;
import prefetcher_pkg::*;

/*

issue requests based on how many words can be stored in adjacency queue
In each iteration, determine how many neighbours left

Combinatorial:
assign slot_capacity = depth - pop_count
assign byte_capacity = slot_capacity * 20 / 8 (rounded up)

assign slots_pending = neighbour_count
assign bytes_pending = slots_pending * 20 / 8 (rounded up)

State machine:
If (adj queue not full and bytes_pending > 0):
    req_bytes = bytes_pending > byte_capacity ? byte_capacity : bytes_pending
    request(req_address, req_bytes)
    bytes_pending = bytes_pending - req_bytes
    address = address + req_bytes

============================

TO DO:
- How to identify responses from AXI RM as either ADJ or MSG? ----> 2 separate AXI read masters

*/

module prefetcher_fetch_tag #(
    parameter AXI_ADDRESS_WIDTH = 34,

    parameter ADDRESS_QUEUE_WIDTH = top_pkg::NODE_SLOT_ID_WIDTH,
    parameter ADDRESS_QUEUE_DEPTH = 64,

    // Cannot predict message width (depends on feature count and precision), so store 512b AXI beats directly
    // This corresponds to different feature counts depending on precision
    parameter MESSAGE_QUEUE_WIDTH = 512,
    parameter MESSAGE_QUEUE_DEPTH = 4096
) (
    input logic core_clk,
    input logic resetn,

    // NSB -> Prefetcher Interface
    input  logic                                        nsb_prefetcher_req_valid,
    output logic                                        nsb_prefetcher_req_ready,
    input  NSB_PREF_REQ_t                               nsb_prefetcher_req,
    output logic                                        nsb_prefetcher_resp_valid,
    output NSB_PREF_RESP_t                              nsb_prefetcher_resp,

    // Allocation interface
    output logic                                        free,

    // Request interface to Adjacency AXI Master
    output logic                                        fetch_tag_axi_rm_adj_req_valid,
    input  logic                                        fetch_tag_axi_rm_adj_req_ready,
    output logic [AXI_ADDRESS_WIDTH-1:0]                fetch_tag_axi_rm_adj_start_address,
    output logic [$clog2(MAX_FETCH_REQ_BYTE_COUNT)-1:0] fetch_tag_axi_rm_adj_byte_count,

    // Request interface to Message AXI Master
    output logic                                        fetch_tag_axi_rm_message_req_valid,
    input  logic                                        fetch_tag_axi_rm_message_req_ready,
    output logic [AXI_ADDRESS_WIDTH-1:0]                fetch_tag_axi_rm_message_start_address,
    output logic [$clog2(MAX_FETCH_REQ_BYTE_COUNT)-1:0] fetch_tag_axi_rm_message_byte_count,

    // Response interface from Adjacency AXI Master
    input  logic                                        adj_rm_fetch_tag_resp_valid,
    output logic                                        adj_rm_fetch_tag_resp_ready,
    input  logic                                        adj_rm_fetch_tag_resp_last,
    input  logic [DATA_WIDTH-1:0]                       adj_rm_fetch_tag_resp_data,
    input  logic [3:0]                                  adj_rm_fetch_tag_resp_axi_id,

    // Response interface from Message AXI Master
    input  logic                                        msg_rm_fetch_tag_resp_valid,
    output logic                                        msg_rm_fetch_tag_resp_ready,
    input  logic                                        msg_rm_fetch_tag_resp_last,
    input  logic [DATA_WIDTH-1:0]                       msg_rm_fetch_tag_resp_data,
    input  logic [3:0]                                  msg_rm_fetch_tag_resp_axi_id
);

// ==================================================================================================================================================
// Declarations
// ==================================================================================================================================================

FETCH_TAG_ADJ_LIST_FETCH_FSM_e                                adjacency_list_fetch_state, adjacency_list_fetch_state_n;
FETCH_TAG_MESSAGE_FETCH_FSM_e                                 message_fetch_state, message_fetch_state_n;

// Address Queue
logic                                                         push_address_queue, pop_address_queue;
logic                                                         address_queue_head_valid, address_queue_head;
logic                                                         address_queue_empty, address_queue_full;
logic [$clog2(ADDRESS_QUEUE_DEPTH)-1:0]                       address_queue_count;

logic [$clog2(ADDRESS_QUEUE_DEPTH)-1:0]                       address_queue_free_capacity_slots; // how many ID's can currently be stored
logic [$clog2(top_pkg::MAX_REQUIRED_BYTES_ADJ_FETCH_REQ)-1:0] address_queue_free_capacity_bytes; // address_queue_free_capacity_slots, in bytes (rounded up)

// Message Queue
logic                                                         push_message_queue, pop_message_queue;
logic                                                         message_queue_head_valid, message_queue_head;
logic                                                         message_queue_empty, message_queue_full;
logic [$clog2(MESSAGE_QUEUE_DEPTH)-1:0]                       message_queue_count;

logic                                                         accepting_nsb_req;
logic                                                         accepting_adj_fetch_req;
logic                                                         accepting_message_fetch_req;
logic                                                         accepting_adj_fetch_resp;
logic                                                         accepting_msg_fetch_resp;

// Registered NSB request payloads
logic [AXI_ADDRESS_WIDTH-1:0]                                 adj_fetch_req_neighbour_count_q;

// Request logic
logic [AXI_ADDRESS_WIDTH-1:0]                                 adj_fetch_req_address; // address pointer (updated in each fetch)
logic [$clog2(top_pkg::MAX_REQUIRED_BYTES_ADJ_FETCH_REQ)-1:0] adj_fetch_pending_bytes; // bytes left
logic [$clog2(top_pkg::MAX_REQUIRED_BYTES_ADJ_FETCH_REQ)-1:0] adj_fetch_req_bytes; // bytes in current request

// Store logic
logic [ADDRESS_QUEUE_WIDTH-1:0]                               adj_queue_write_data;
logic [ADDRESS_QUEUE_WIDTH-1:0]                               msg_queue_write_data;

// ==================================================================================================================================================
// Instances
// ==================================================================================================================================================

ultraram_fifo #(
    .WIDTH(ADDRESS_QUEUE_WIDTH),
    .DEPTH(ADDRESS_QUEUE_DEPTH)
) address_queue (
    .core_clk       (core_clk),
    .resetn         (resetn),
    .push           (push_address_queue),
    .in_data        (adj_queue_write_data),
    .pop            (pop_address_queue),
    .out_valid      (address_queue_head_valid),
    .out_data       (address_queue_head),
    .count          (address_queue_count),
    .empty          (address_queue_empty),
    .full           (address_queue_full)
);

ultraram_fifo #(
    .WIDTH(MESSAGE_QUEUE_WIDTH),
    .DEPTH(MESSAGE_QUEUE_DEPTH)
) message_queue (
    .core_clk       (core_clk),
    .resetn         (resetn),
    .push           (push_message_queue),
    .in_data        (msg_queue_write_data),
    .pop            (pop_message_queue),
    .out_valid      (message_queue_head_valid),
    .out_data       (message_queue_head),
    .count          (message_queue_count),
    .empty          (message_queue_empty),
    .full           (message_queue_full)
);

// ==================================================================================================================================================
// Logic
// ==================================================================================================================================================

always_comb begin
    accepting_nsb_req = nsb_prefetcher_req_valid && nsb_prefetcher_req_ready;
    accepting_adj_fetch_req = fetch_tag_axi_rm_adj_req_valid && fetch_tag_axi_rm_adj_req_ready;
    accepting_message_fetch_req = fetch_tag_axi_rm_message_req_valid && fetch_tag_axi_rm_message_req_ready;
    
    accepting_adj_fetch_resp    = adj_rm_fetch_tag_resp_valid && adj_rm_fetch_tag_resp_ready;
    accepting_msg_fetch_resp    = msg_rm_fetch_tag_resp_valid && msg_rm_fetch_tag_resp_ready;
end

always_ff @(posedge core_clk or negedge resetn) begin
    if (!resetn) begin
        adjacency_list_fetch_state <= ADJ_IDLE;
        message_fetch_state        <= MSG_IDLE;

        adj_fetch_req_address  <= '0;
        adj_fetch_req_neighbour_count_q     <= '0;
    end else begin
        adjacency_list_fetch_state <= adjacency_list_fetch_state_n;
        message_fetch_state        <= message_fetch_state_n;

        // Accepting adjacency list fetch request
        if (accepting_nsb_req && (nsb_prefetcher_req.req_opcode == ADJACENCY_LIST)) begin
            // Initialize AXI request according to Nodeslot programming
            adj_fetch_req_address   <= nsb_prefetcher_req.start_address;
            adj_fetch_req_neighbour_count_q <= nsb_prefetcher_req.neighbour_count;
            // (WIDTH_X - 1)/WIDTH_Y + 1 = WIDTH_X/WIDTH_Y (rounded up)
            adj_fetch_pending_bytes    <= (nsb_prefetcher_req.neighbour_count * top_pkg::NODE_SLOT_ID_WIDTH - 1) / 8 + 1;
        end

        // When accepting adjacency fetch request, update address and pending_bytes counters
        if (accepting_adj_fetch_req) begin
            adj_fetch_req_address       <= adj_fetch_req_address + adj_fetch_req_bytes;
            adj_fetch_pending_bytes     <= adj_fetch_pending_bytes - adj_fetch_req_bytes;
        end

    end
end

always_comb begin
    // how many ID's can currently be stored
    address_queue_free_capacity_slots = ADDRESS_QUEUE_DEPTH - address_queue_count;
    // (WIDTH_X - 1)/WIDTH_Y + 1 = WIDTH_X/WIDTH_Y (rounded up)
    address_queue_free_capacity_bytes = (address_queue_free_capacity_slots * 20 - 1) / 8 + 1; // rounded down
end

// Adjacency list fetch state machine
// ----------------------------------------------------

always_comb begin
    adjacency_list_fetch_state_n = adjacency_list_fetch_state;

    case (adjacency_list_fetch_state)
    ADJ_IDLE: begin
        adjacency_list_fetch_state_n = accepting_nsb_req && (nsb_prefetcher_req.req_opcode == ADJACENCY_LIST) ? ADJ_FETCH
                                    : ADJ_IDLE;
    end

    ADJ_FETCH: begin
        adjacency_list_fetch_state_n = accepting_adj_fetch_req ? ADJ_WAIT_RESP : ADJ_FETCH;
    end

    ADJ_WAIT_RESP: begin
        adjacency_list_fetch_state_n = accepting_adj_fetch_resp ? ADJ_STORE : ADJ_WAIT_RESP;
    end

    ADJ_STORE: begin
        adjacency_list_fetch_state_n = ADJ_IDLE;
    end

    ADJ_PAUSE: begin
        adjacency_list_fetch_state_n = ADJ_IDLE;
    end

    ADJ_DONE: begin
        adjacency_list_fetch_state_n = ADJ_IDLE;
    end
    endcase
end

assign free = address_queue_empty && message_queue_empty
            && (adjacency_list_fetch_state == IDLE)
            && (messafe_fetch_state == IDLE);

// Adjacency list fetch request logic
always_comb begin
    adj_fetch_req_bytes                 = top_pkg::min(adj_fetch_pending_bytes, address_queue_free_capacity_bytes);
    fetch_tag_axi_rm_adj_req_valid      = (adjacency_list_fetch_state == ADJ_FETCH);
    fetch_tag_axi_rm_adj_start_address  = adj_fetch_req_address;
    fetch_tag_axi_rm_adj_byte_count     = address_queue_free_capacity_bytes;
end

// logic issue_adj_partial_resp;
// logic issue_adj_done_resp;

always_comb begin
    nsb_prefetcher_req_ready = (adjacency_list_fetch_state == ADJ_IDLE) || (message_fetch_state == MSG_IDLE);
    
    // issue_adj_partial_resp = adjacency_list_fetch_state == ADJ_STORE && adjacency_list_fetch_state_n == ADJ_PAUSE;
    // issue_adj_done_resp = adjacency_list_fetch_state == ADJ_STORE && adjacency_list_fetch_state_n == ADJ_IDLE;

    // // TO DO: account for message fetch responses
    // nsb_prefetcher_resp_valid = issue_adj_done_resp || issue_adj_partial_resp;
    
    // nsb_prefetcher_resp.response_type = issue_adj_done_resp ? 
end

endmodule