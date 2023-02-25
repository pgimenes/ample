
import top_pkg::*;
import prefetcher_pkg::*;

/*

issue requests based on how many words can be stored in adjacency queue
In each iteration, determine how many neighbours left

// ROUND UP: (WIDTH_X - 1)/WIDTH_Y + 1 = WIDTH_X/WIDTH_Y

*/

module prefetcher_fetch_tag #(
    parameter AXI_ADDRESS_WIDTH = 34,
    parameter AXI_DATA_WIDTH    = 512,

    parameter ADJ_QUEUE_WIDTH   = 32,
    parameter ADJ_QUEUE_DEPTH   = 64,
    parameter MESSAGE_QUEUE_WIDTH = 512,
    parameter MESSAGE_QUEUE_DEPTH = 4096,

    parameter FEATURE_COUNT = top_pkg::MAX_FEATURE_COUNT
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
    input  logic                                        allocation_valid,
    input  logic [$clog2(MAX_NODESLOT_COUNT)-1:0]       allocation_nodeslot,
    input  logic [$clog2(MAX_FEATURE_COUNT)-1:0]        allocation_feature_count,
    output logic                                        tag_free,

    // Request interface to Adjacency AXI Master
    output logic                                        fetch_tag_adj_rm_req_valid,
    input  logic                                        fetch_tag_adj_rm_req_ready,
    output logic [AXI_ADDRESS_WIDTH-1:0]                fetch_tag_adj_rm_start_address,
    output logic [$clog2(MAX_FETCH_REQ_BYTE_COUNT)-1:0] fetch_tag_adj_rm_byte_count,

    // Response interface from Adjacency AXI Master
    input  logic                                        fetch_tag_adj_rm_resp_valid,
    output logic                                        fetch_tag_adj_rm_resp_ready,
    input  logic                                        fetch_tag_adj_rm_resp_last,
    input  logic [AXI_DATA_WIDTH-1:0]                   fetch_tag_adj_rm_resp_data,
    input  logic [3:0]                                  fetch_tag_adj_rm_resp_axi_id,

    // Request interface to Message AXI Master
    output logic                                        fetch_tag_msg_rm_req_valid,
    input  logic                                        fetch_tag_msg_rm_req_ready,
    output logic [AXI_ADDRESS_WIDTH-1:0]                fetch_tag_msg_rm_start_address,
    output logic [$clog2(MAX_FETCH_REQ_BYTE_COUNT)-1:0] fetch_tag_msg_rm_byte_count,

    // Response interface from Message AXI Master
    input  logic                                        fetch_tag_msg_rm_resp_valid,
    output logic                                        fetch_tag_msg_rm_resp_ready,
    input  logic                                        fetch_tag_msg_rm_resp_last,
    input  logic [AXI_DATA_WIDTH-1:0]                   fetch_tag_msg_rm_resp_data,
    input  logic [3:0]                                  fetch_tag_msg_rm_resp_axi_id
);

// ==================================================================================================================================================
// Declarations
// ==================================================================================================================================================

// Allocation
logic [$clog2(MAX_NODESLOT_COUNT)-1:0]                        allocated_nodeslot;
logic [$clog2(MAX_FEATURE_COUNT)-1:0]                         allocated_feature_count;
logic                                                         make_tag_free;

FETCH_TAG_ADJ_QUEUE_FETCH_FSM_e                               adj_queue_fetch_state, adj_queue_fetch_state_n;
FETCH_TAG_MESSAGE_FETCH_FSM_e                                 message_fetch_state, message_fetch_state_n;

// Address Queue
logic                                                         push_adj_queue, pop_adj_queue;
logic                                                         adj_queue_head_valid, adj_queue_head;
logic                                                         adj_queue_empty, adj_queue_full;
logic [$clog2(ADJ_QUEUE_DEPTH)-1:0]                           adj_queue_count;

logic [$clog2(ADJ_QUEUE_DEPTH)-1:0]                           adj_queue_slots_available; // how many ID's can currently be stored

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

// Adjacency request logic
logic [AXI_ADDRESS_WIDTH-1:0]                                 adj_fetch_req_address; // address pointer (updated in each fetch)
logic [$clog2(top_pkg::MAX_REQUIRED_BYTES_ADJ_FETCH_REQ)-1:0] adj_fetch_req_bytes; // bytes in current request
logic [$clog2(top_pkg::MAX_NEIGHBOURS)-1:0]                   adj_fetch_neighbours_remaining_fetch;
logic [$clog2(prefetcher_pkg::MAX_ADJ_FETCH_RESPONSES)-1:0]   adj_fetch_responses_pending;
logic [$clog2(AXI_DATA_WIDTH)-1:0]                            buffered_adj_fetch_resp_offset;

logic                                                         issue_nsb_partial_done_adj_fetch;
logic                                                         issue_nsb_partial_done_adj_fetch_q;

// Message request logic
top_pkg::NODE_PRECISION_e                                     msg_fetch_req_precision_q;
logic [$clog2(MAX_MSG_FETCH_RESPONSES)-1:0]                   msg_queue_expected_responses;

logic                                                         issue_nsb_partial_done_msg_fetch;
logic                                                         issue_nsb_partial_done_msg_fetch_q;

// Store logic
logic [$clog2(top_pkg::MAX_NEIGHBOURS)-1:0]                   adj_fetch_neighbours_remaining_store;
logic [AXI_DATA_WIDTH-1:0]                                    fetch_tag_adj_rm_resp_data_q;
logic [ADJ_QUEUE_WIDTH-1:0]                                   adj_queue_write_data;
logic [ADJ_QUEUE_WIDTH-1:0]                                   msg_queue_write_data;

// ==================================================================================================================================================
// Instances
// ==================================================================================================================================================

ultraram_fifo #(
    .WIDTH(ADJ_QUEUE_WIDTH),
    .DEPTH(ADJ_QUEUE_DEPTH)
) adjacency_queue (
    .core_clk       (core_clk),
    .resetn         (resetn),
    .push           (push_adj_queue),
    .in_data        (adj_queue_write_data),
    .pop            (pop_adj_queue),
    .out_valid      (adj_queue_head_valid),
    .out_data       (adj_queue_head),
    .count          (adj_queue_count),
    .empty          (adj_queue_empty),
    .full           (adj_queue_full)
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
    accepting_nsb_req           = nsb_prefetcher_req_valid && nsb_prefetcher_req_ready;

    accepting_adj_fetch_req     = fetch_tag_adj_rm_req_valid && fetch_tag_adj_rm_req_ready;
    accepting_message_fetch_req = fetch_tag_msg_rm_req_valid && fetch_tag_msg_rm_req_ready;
    
    accepting_adj_fetch_resp    = fetch_tag_adj_rm_resp_valid && fetch_tag_adj_rm_resp_ready;
    accepting_msg_fetch_resp    = fetch_tag_msg_rm_resp_valid && fetch_tag_msg_rm_resp_ready;
end

// Adjacency queue fetch state machine
// ----------------------------------------------------

always_ff @(posedge core_clk or negedge resetn) begin
    if (!resetn) begin
        adj_queue_fetch_state <= ADJ_IDLE;
    end else begin
        adj_queue_fetch_state <= adj_queue_fetch_state_n;
    end
end

always_comb begin
    adj_queue_fetch_state_n = adj_queue_fetch_state;

    case (adj_queue_fetch_state)
    ADJ_IDLE: begin
        adj_queue_fetch_state_n = accepting_nsb_req && (nsb_prefetcher_req.req_opcode == ADJACENCY_LIST) ? ADJ_FETCH
                                    : ADJ_IDLE;
    end

    ADJ_FETCH: begin
        adj_queue_fetch_state_n = accepting_adj_fetch_req ? ADJ_WAIT_RESP : ADJ_FETCH;
    end

    ADJ_WAIT_RESP: begin
        adj_queue_fetch_state_n = accepting_adj_fetch_resp ? ADJ_STORE : ADJ_WAIT_RESP;
    end

    ADJ_STORE: begin
        adj_queue_fetch_state_n = |adj_fetch_neighbours_remaining_store && |adj_fetch_responses_pending && !adj_queue_full && buffered_adj_fetch_resp_offset == 9'd480 ? ADJ_WAIT_RESP
                                    : |adj_fetch_neighbours_remaining_store && ~adj_fetch_responses_pending && !adj_queue_full ? ADJ_FETCH
                                    : |adj_fetch_neighbours_remaining_store && ~adj_fetch_responses_pending && adj_queue_full ? ADJ_PAUSE
                                    : ~adj_fetch_neighbours_remaining_store && ~adj_fetch_responses_pending ? ADJ_DONE
                                    : ADJ_STORE;
    end

    ADJ_PAUSE: begin
        adj_queue_fetch_state_n = |adj_fetch_neighbours_remaining_store && !adj_queue_full ? ADJ_FETCH
                                    : ~adj_fetch_neighbours_remaining_store ? ADJ_IDLE // defensive
                                    : ADJ_PAUSE;
    end

    ADJ_DONE: begin
        adj_queue_fetch_state_n = nsb_prefetcher_resp_valid && (nsb_prefetcher_resp.response_type == ADJACENCY_LIST) ? ADJ_IDLE
                                : ADJ_DONE;
    end
    endcase
end

// Adjacency queue request logic
// ----------------------------------------------------

always_comb begin
    adj_queue_slots_available = ADJ_QUEUE_DEPTH - adj_queue_count;
end

always_ff @(posedge core_clk or negedge resetn) begin
    if (!resetn) begin
        adj_fetch_req_address                   <= '0;
        adj_fetch_neighbours_remaining_fetch    <= '0;
        adj_fetch_responses_pending             <= '0;
        fetch_tag_adj_rm_resp_data_q            <= '0;
        issue_nsb_partial_done_adj_fetch        <= '0;
        issue_nsb_partial_done_adj_fetch_q      <= '0;
    end else begin
        // Accepting adjacency list fetch request
        if (accepting_nsb_req && (nsb_prefetcher_req.req_opcode == ADJACENCY_LIST)) begin 
            // Initialize AXI request according to Nodeslot programming
            adj_fetch_req_address                 <= nsb_prefetcher_req.start_address;
            adj_fetch_neighbours_remaining_fetch  <= nsb_prefetcher_req.neighbour_count;
            issue_nsb_partial_done_adj_fetch      <= '0;
        
        end else if (accepting_adj_fetch_req) begin
            // When accepting adjacency fetch request, update address and pending_bytes counters
            adj_fetch_req_address                <= adj_fetch_req_address + adj_fetch_req_bytes;
            adj_fetch_neighbours_remaining_fetch <= adj_fetch_neighbours_remaining_fetch - adj_queue_slots_available;
            adj_fetch_responses_pending          <= (adj_fetch_req_bytes - 1'b1)/64 + 1'b1; // req_bytes / 64, rounded up

        end else if (accepting_adj_fetch_resp) begin
            adj_fetch_responses_pending    <= adj_fetch_responses_pending - 1'b1;
            fetch_tag_adj_rm_resp_data_q   <= fetch_tag_adj_rm_resp_data;
        end

        if (adj_queue_fetch_state == ADJ_STORE && adj_queue_fetch_state_n == ADJ_PAUSE) begin
            // Raise partial done resp flag. This latches at 1 until new NSB req received, so that
            // the response is only sent the first time the adjacency queue gets full
            issue_nsb_partial_done_adj_fetch <= '1;
        end

        issue_nsb_partial_done_adj_fetch_q <= issue_nsb_partial_done_adj_fetch;
    end
end

// Read master logic
always_comb begin
    // Request
    adj_fetch_req_bytes                 = 4 * adj_queue_slots_available; // each neighbour ID is 32b integer
    fetch_tag_adj_rm_byte_count     = adj_fetch_req_bytes;
    fetch_tag_adj_rm_req_valid      = (adj_queue_fetch_state == ADJ_FETCH);
    fetch_tag_adj_rm_start_address  = adj_fetch_req_address;

    // Response
    fetch_tag_adj_rm_resp_ready         = (adj_queue_fetch_state == ADJ_WAIT_RESP);
end

// Adjacency queue store logic
// ----------------------------------------------------

always_comb begin
    push_adj_queue = (adj_queue_fetch_state == ADJ_STORE) && !adj_queue_full;

    // Cannot address register by non-constant expression like below:
    // adj_queue_write_data = fetch_tag_adj_rm_resp_data_q [buffered_adj_fetch_resp_offset + 5'd31 : buffered_adj_fetch_resp_offset];

    // TO DO: simplify
    adj_queue_write_data = (buffered_adj_fetch_resp_offset == '0) ? fetch_tag_adj_rm_resp_data_q [31:0]
                        : (buffered_adj_fetch_resp_offset == 9'd32) ? fetch_tag_adj_rm_resp_data_q [63:32]
                        : (buffered_adj_fetch_resp_offset == 9'd64) ? fetch_tag_adj_rm_resp_data_q [95:64]
                        : (buffered_adj_fetch_resp_offset == 9'd96) ? fetch_tag_adj_rm_resp_data_q [127:96]
                        : (buffered_adj_fetch_resp_offset == 9'd128) ? fetch_tag_adj_rm_resp_data_q [159:128]
                        : (buffered_adj_fetch_resp_offset == 9'd160) ? fetch_tag_adj_rm_resp_data_q [191:160]
                        : (buffered_adj_fetch_resp_offset == 9'd192) ? fetch_tag_adj_rm_resp_data_q [223:192]
                        : (buffered_adj_fetch_resp_offset == 9'd224) ? fetch_tag_adj_rm_resp_data_q [255:224]
                        : (buffered_adj_fetch_resp_offset == 9'd256) ? fetch_tag_adj_rm_resp_data_q [287:256]
                        : (buffered_adj_fetch_resp_offset == 9'd288) ? fetch_tag_adj_rm_resp_data_q [319:288]
                        : (buffered_adj_fetch_resp_offset == 9'd320) ? fetch_tag_adj_rm_resp_data_q [351:320]
                        : (buffered_adj_fetch_resp_offset == 9'd352) ? fetch_tag_adj_rm_resp_data_q [383:352]
                        : (buffered_adj_fetch_resp_offset == 9'd384) ? fetch_tag_adj_rm_resp_data_q [415:384]
                        : (buffered_adj_fetch_resp_offset == 9'd416) ? fetch_tag_adj_rm_resp_data_q [447:416]
                        : (buffered_adj_fetch_resp_offset == 9'd448) ? fetch_tag_adj_rm_resp_data_q [479:448]
                        : (buffered_adj_fetch_resp_offset == 9'd480) ? fetch_tag_adj_rm_resp_data_q [511:480]
                        : '0;
end

always_ff @(posedge core_clk or negedge resetn) begin
    if (!resetn) begin
        adj_fetch_neighbours_remaining_store <= '0;
        buffered_adj_fetch_resp_offset       <= '0;
    
    // Accepting NSB fetch request
    end else if (accepting_nsb_req && (nsb_prefetcher_req.req_opcode == ADJACENCY_LIST)) begin
        adj_fetch_neighbours_remaining_store <= nsb_prefetcher_req.neighbour_count;
        buffered_adj_fetch_resp_offset       <= '0;
    
    end else begin

        // Response offset counter
        if ((adj_queue_fetch_state_n == ADJ_STORE) || (buffered_adj_fetch_resp_offset == 9'd480)) begin // 480+32 = 512
            buffered_adj_fetch_resp_offset <= '0;
        end else if (push_adj_queue) begin
            buffered_adj_fetch_resp_offset <= buffered_adj_fetch_resp_offset + 5'd32;
        end

        if (push_adj_queue) begin
            adj_fetch_neighbours_remaining_store = adj_fetch_neighbours_remaining_store - 1'b1;
        end

    end
end

// Message queue fetch state machine
// ----------------------------------------------------

always_ff @(posedge core_clk or negedge resetn) begin
    if (!resetn) begin
        message_fetch_state        <= MSG_IDLE;
    end else begin
        message_fetch_state        <= message_fetch_state_n;
    end
end

always_comb begin
    message_fetch_state_n = message_fetch_state;

    case (message_fetch_state)
    
    MSG_IDLE: begin
        message_fetch_state_n = accepting_nsb_req && (nsb_prefetcher_req.req_opcode == MESSAGES) && !adj_queue_empty ? MSG_FETCH
                            : MSG_IDLE;
    end

    MSG_FETCH: begin
        message_fetch_state_n = accepting_message_fetch_req ? MSG_STORE
                            : MSG_FETCH;
    end

    MSG_STORE: begin
        message_fetch_state_n = accepting_msg_fetch_resp && (msg_queue_expected_responses == 1'b1) && adj_queue_empty ? MSG_DONE
                            : accepting_msg_fetch_resp && (msg_queue_expected_responses == 1'b1) && !adj_queue_empty && message_queue_full ? MSG_PAUSE
                            : accepting_msg_fetch_resp && (msg_queue_expected_responses == 1'b1) && !adj_queue_empty && !message_queue_full ? MSG_FETCH
                            : MSG_STORE;
    end

    MSG_PAUSE: begin
        message_fetch_state_n = adj_queue_empty ? MSG_DONE // defensive
                            : !adj_queue_empty && !message_queue_full ? MSG_FETCH // keep fetching when message queue clears
                            : MSG_PAUSE;
    end

    MSG_DONE: begin
        message_fetch_state_n = nsb_prefetcher_resp_valid && (nsb_prefetcher_resp.response_type == MESSAGES) ? MSG_IDLE
                            : MSG_DONE;
    end

    endcase
end

// Message queue logic
// ----------------------------------------------------

always_comb begin
    fetch_tag_msg_rm_req_valid      = (message_fetch_state == MSG_FETCH) && adj_queue_head_valid && !message_queue_full;
    fetch_tag_msg_rm_start_address  = adj_queue_head;
    fetch_tag_msg_rm_byte_count     = FEATURE_COUNT * top_pkg::bits_per_precision(msg_fetch_req_precision_q) / 8;

    fetch_tag_msg_rm_resp_ready = (message_fetch_state == MSG_STORE);
    push_message_queue   = accepting_msg_fetch_resp;
    msg_queue_write_data = fetch_tag_msg_rm_resp_data;
    
    pop_adj_queue = accepting_message_fetch_req;
end

always_ff @(posedge core_clk or negedge resetn) begin
    if (!resetn) begin
        msg_fetch_req_precision_q    <= FLOAT_32; // 0 by default
        msg_queue_expected_responses <= '0;
        issue_nsb_partial_done_msg_fetch <= '0;
    
    end else if (accepting_nsb_req && (nsb_prefetcher_req.req_opcode == MESSAGES)) begin
        msg_fetch_req_precision_q        <= nsb_prefetcher_req.nodeslot_precision;
        msg_queue_expected_responses     <= '0;
        issue_nsb_partial_done_msg_fetch <= '0;
    
    end else if (accepting_message_fetch_req) begin
        msg_queue_expected_responses <= `divide_round_up(fetch_tag_msg_rm_byte_count, 64);
    
    end else begin
        if (accepting_msg_fetch_resp) begin
            msg_queue_expected_responses <= msg_queue_expected_responses - 1;
        end

        if ((message_fetch_state == MSG_STORE) && (message_fetch_state_n == MSG_PAUSE)) begin
            issue_nsb_partial_done_msg_fetch <= '1;
        end
        issue_nsb_partial_done_msg_fetch_q <= issue_nsb_partial_done_msg_fetch;
    end
end

// NSB interface
// ----------------------------------------------------

always_comb begin
    nsb_prefetcher_req_ready = tag_free && (adj_queue_fetch_state == ADJ_IDLE) || (message_fetch_state == MSG_IDLE);

    nsb_prefetcher_resp_valid = (adj_queue_fetch_state == ADJ_DONE) || (issue_nsb_partial_done_adj_fetch && !issue_nsb_partial_done_adj_fetch)
                            || (message_fetch_state == MSG_DONE) || (issue_nsb_partial_done_msg_fetch && !issue_nsb_partial_done_msg_fetch);

    nsb_prefetcher_resp.nodeslot = allocated_nodeslot;
    nsb_prefetcher_resp.response_type = (issue_nsb_partial_done_adj_fetch && !issue_nsb_partial_done_adj_fetch) ? ADJACENCY_LIST
                                        : (issue_nsb_partial_done_msg_fetch && !issue_nsb_partial_done_msg_fetch_q) ? MESSAGES
                                        : (adj_queue_fetch_state == ADJ_DONE) ? ADJACENCY_LIST
                                        : (message_fetch_state == MSG_DONE) ? MESSAGES
                                        : ERROR;

    nsb_prefetcher_resp.partial = (issue_nsb_partial_done_adj_fetch && !issue_nsb_partial_done_adj_fetch);
end

// Allocation
// ----------------------------------------------------

assign make_tag_free = adj_queue_empty && message_queue_empty
            && (adj_queue_fetch_state == ADJ_IDLE)
            && (message_fetch_state == MSG_IDLE);

always_ff @(posedge core_clk or negedge resetn) begin
    if (!resetn) begin
        tag_free                    <= '1;
        allocated_nodeslot      <= '0;
        allocated_feature_count <= '0;
    end else if (tag_free && allocation_valid) begin
        allocated_nodeslot      <= allocation_nodeslot;
        allocated_feature_count <= allocation_feature_count;
        tag_free                    <= '0;
    end else if (make_tag_free) begin
        tag_free                    <= '1;
        // allocation payloads remain written
    end
end


endmodule