
import top_pkg::*;
import prefetcher_pkg::*;

module prefetcher_fetch_tag #(
    parameter TAG = 0,
    parameter AXI_ADDRESS_WIDTH = 34,
    parameter AXI_DATA_WIDTH    = 512,

    parameter int ADJ_QUEUE_WIDTH   = 32,
    parameter int ADJ_QUEUE_DEPTH   = 64,
    parameter int MESSAGE_QUEUE_WIDTH = 512,
    parameter int MESSAGE_QUEUE_DEPTH = 4096

) (
    input logic core_clk,
    input logic resetn,

    // NSB -> Prefetcher Interface
    input  logic                                        nsb_prefetcher_req_valid,
    output logic                                        nsb_prefetcher_req_ready,
    input  NSB_PREF_REQ_t                               nsb_prefetcher_req,

    output logic                                        nsb_prefetcher_resp_valid,
    input  logic                                        nsb_prefetcher_resp_ready,
    output NSB_PREF_RESP_t                              nsb_prefetcher_resp,

    // Allocation interface
    input  logic                                        allocation_valid,
    input  logic [$clog2(MAX_NODESLOT_COUNT)-1:0]       allocation_nodeslot,
    input  logic [$clog2(MAX_FEATURE_COUNT)-1:0]        allocation_feature_count,
    input  logic                                        deallocation_valid,
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
    input  logic [3:0]                                  fetch_tag_msg_rm_resp_axi_id,

    // Message Channels: AGE -> Fetch Tags
    input  logic                                        message_channel_req_valid,
    output logic                                        message_channel_req_ready,
    input  MESSAGE_CHANNEL_REQ_t                        message_channel_req,
    
    output logic                                        message_channel_resp_valid,
    input  logic                                        message_channel_resp_ready,
    output MESSAGE_CHANNEL_RESP_t                       message_channel_resp,

    // Scale Factor Queue Interface: Fetch Tag -> AGE
    input  logic                                           scale_factor_queue_pop,
    output logic                                           scale_factor_queue_out_valid,
    output logic [SCALE_FACTOR_QUEUE_READ_WIDTH-1:0]       scale_factor_queue_out_data,
    output logic [$clog2(SCALE_FACTOR_QUEUE_READ_DEPTH):0] scale_factor_queue_count,
    output logic                                           scale_factor_queue_empty,
    output logic                                           scale_factor_queue_full,
    
    input  logic [31:0] layer_config_adjacency_list_address_lsb_value,
    input  logic [31:0] layer_config_in_messages_address_lsb_value,
    input  logic [31:0] layer_config_scale_factors_address_lsb_value,
    input  logic [1:0] layer_config_scale_factors_address_msb_value
);

// ==================================================================================================================================================
// Declarations
// ==================================================================================================================================================

// Allocation
logic [$clog2(MAX_NODESLOT_COUNT)-1:0]                        allocated_nodeslot;
logic [$clog2(MAX_FEATURE_COUNT)-1:0]                         allocated_feature_count;
logic                                                         make_tag_free;

prefetcher_pkg::FETCH_TAG_MESSAGE_FETCH_FSM_e                                 message_fetch_state, message_fetch_state_n;

// Address Queue
logic                                                         push_adj_queue, pop_adj_queue;
logic [ADJ_QUEUE_WIDTH-1:0]                                   adj_queue_write_data;
logic                                                         adj_queue_head_valid;
logic [ADJ_QUEUE_WIDTH-1:0]                                   adj_queue_head;
logic                                                         adj_queue_empty, adj_queue_full;
logic [$clog2(ADJ_QUEUE_DEPTH):0]                             adj_queue_count;
logic [$clog2(ADJ_QUEUE_DEPTH):0]                             adj_queue_slots_available; // how many ID's can currently be stored

logic                                                         adj_queue_manager_free;
logic                                                         adj_queue_manager_ready;
logic                                                         adj_queue_fetch_resp_valid;
logic                                                         adj_queue_fetch_resp_partial;

// Message Queue
logic                                                         push_message_queue, pop_message_queue;
logic                                                         message_queue_head_valid;
logic [MESSAGE_QUEUE_WIDTH-1:0]                               message_queue_head;
logic                                                         message_queue_empty, message_queue_full;
logic [$clog2(MESSAGE_QUEUE_DEPTH):0]                         message_queue_count;

logic                                                         accepting_nsb_req;
logic                                                         accepting_message_fetch_req;
logic                                                         accepting_msg_fetch_resp;

// Scale Factor Queue
logic                                        scale_factor_queue_push;
logic [SCALE_FACTOR_QUEUE_WRITE_WIDTH-1:0]   scale_factor_queue_in_data;
logic                                        scale_factor_fetch_req_ready;
logic                                        scale_factor_fetch_resp_valid;
logic                                        scale_factor_fetch_resp_partial;

logic                                        scale_factor_read_master_req_valid;
logic [AXI_ADDRESS_WIDTH-1:0]                scale_factor_read_master_start_address;
logic [$clog2(MAX_FETCH_REQ_BYTE_COUNT)-1:0] scale_factor_read_master_byte_count;
logic                                        scale_factor_read_master_resp_ready;

// Message request logic
top_pkg::NODE_PRECISION_e                                     msg_fetch_req_precision_q;
logic [$clog2(MAX_MSG_FETCH_RESPONSES)-1:0]                   msg_queue_expected_responses;

logic                                                         issue_nsb_partial_done_msg_fetch;
logic                                                         issue_nsb_partial_done_msg_fetch_q;

logic [MESSAGE_QUEUE_WIDTH-1:0]                               msg_queue_write_data;

// Message channel logic
logic accepted_message_channel_req;

// ==================================================================================================================================================
// Instances
// ==================================================================================================================================================

// Adjacency Queue
// -----------------------------------------------------------------------

ultraram_fifo #(
    .WIDTH(ADJ_QUEUE_WIDTH),
    .DEPTH(ADJ_QUEUE_DEPTH)
) adjacency_queue (
    .core_clk       (core_clk),
    .resetn         (resetn),
    .push           (push_adj_queue),
    .in_data        (adj_queue_write_data),
    .pop            (pop_adj_queue),
    .reset_read_ptr ('0),
    .out_valid      (adj_queue_head_valid),
    .out_data       (adj_queue_head),
    .count          (adj_queue_count),
    .empty          (adj_queue_empty),
    .full           (adj_queue_full)
);

prefetcher_streaming_manager #(
    .FETCH_TYPE          (top_pkg::ADJACENCY_LIST),
    .QUEUE_WIDTH         (ADJ_QUEUE_WIDTH),
    .QUEUE_DEPTH         (ADJ_QUEUE_DEPTH),
    .STREAMING_ENABLED   (1),
    .UNPACKING_ENABLED   (1)
) adj_queue_manager_i (

    .core_clk                         (core_clk),
    .resetn                           (resetn),

    .free                             (adj_queue_manager_free),

    .fetch_req_valid                  (!tag_free && nsb_prefetcher_req_valid),
    .fetch_req_ready                  (adj_queue_manager_ready),
    .fetch_req_opcode                 (nsb_prefetcher_req.req_opcode),
    .fetch_req_start_address          (nsb_prefetcher_req.start_address),
    .fetch_req_obj_count              (nsb_prefetcher_req.neighbour_count),

    .fetch_resp_valid                 (adj_queue_fetch_resp_valid),
    .fetch_resp_ready                 (nsb_prefetcher_resp_ready),
    .fetch_resp_partial               (adj_queue_fetch_resp_partial),

    .fetch_memory_range_start_address ({2'd0, layer_config_adjacency_list_address_lsb_value}),

    .read_master_req_valid            (fetch_tag_adj_rm_req_valid),
    .read_master_req_ready            (fetch_tag_adj_rm_req_ready),
    .read_master_start_address        (fetch_tag_adj_rm_start_address),
    .read_master_byte_count           (fetch_tag_adj_rm_byte_count),
    
    .read_master_resp_valid           (fetch_tag_adj_rm_resp_valid),
    .read_master_resp_ready           (fetch_tag_adj_rm_resp_ready),
    .read_master_resp_last            (fetch_tag_adj_rm_resp_last),
    .read_master_resp_data            (fetch_tag_adj_rm_resp_data),
    .read_master_resp_axi_id          (fetch_tag_adj_rm_resp_axi_id),
    
    .push_queue                       (push_adj_queue),
    .push_data                        (adj_queue_write_data),
    .queue_slots_available            (adj_queue_slots_available),
    .queue_empty                      (adj_queue_empty),
    .queue_full                       (adj_queue_full)
);

// Message Queue
// -----------------------------------------------------------------------

ultraram_fifo #(
    .WIDTH(MESSAGE_QUEUE_WIDTH),
    .DEPTH(MESSAGE_QUEUE_DEPTH)
) message_queue (
    .core_clk       (core_clk),
    .resetn         (resetn),
    
    .push           (push_message_queue),
    .in_data        (msg_queue_write_data),
    
    .pop            (pop_message_queue),
    .reset_read_ptr ('0),
    .out_valid      (message_queue_head_valid),
    .out_data       (message_queue_head),
    
    .count          (message_queue_count),
    .empty          (message_queue_empty),
    .full           (message_queue_full)
);

// Scale Factor Queue
// -----------------------------------------------------------------------

bram_fifo #(
    .WRITE_WIDTH (SCALE_FACTOR_QUEUE_WRITE_WIDTH),
    .WRITE_DEPTH (SCALE_FACTOR_QUEUE_WRITE_DEPTH),
    .READ_WIDTH  (SCALE_FACTOR_QUEUE_READ_WIDTH),
    .READ_DEPTH  (SCALE_FACTOR_QUEUE_READ_DEPTH),
    .BRAM_TYPE   (0)
) scale_factor_queue (
    .core_clk                   (core_clk),
    .resetn                     (resetn),
    
    .push                       (scale_factor_queue_push),
    .in_data                    (scale_factor_queue_in_data),

    .pop                        (scale_factor_queue_pop),
    .out_valid                  (scale_factor_queue_out_valid),
    .out_data                   (scale_factor_queue_out_data),    
    
    .count                      (scale_factor_queue_count),
    .empty                      (scale_factor_queue_empty),
    .full                       (scale_factor_queue_full)
);

prefetcher_streaming_manager #(
    .FETCH_TYPE          (top_pkg::SCALE_FACTOR),
    .QUEUE_WIDTH         (SCALE_FACTOR_QUEUE_WRITE_WIDTH),
    .QUEUE_DEPTH         (SCALE_FACTOR_QUEUE_WRITE_DEPTH),
    .STREAMING_ENABLED   (0),
    .UNPACKING_ENABLED   (0)
) scale_factor_queue_manager (

    .core_clk                         (core_clk),
    .resetn                           (resetn),

    .free                             (),

    .fetch_req_valid                  (!tag_free && nsb_prefetcher_req_valid),
    .fetch_req_ready                  (scale_factor_fetch_req_ready),
    .fetch_req_opcode                 (nsb_prefetcher_req.req_opcode),
    .fetch_req_start_address          (nsb_prefetcher_req.start_address),
    .fetch_req_obj_count              (nsb_prefetcher_req.neighbour_count),

    .fetch_resp_valid                 (scale_factor_fetch_resp_valid),
    .fetch_resp_ready                 (nsb_prefetcher_resp_ready),
    .fetch_resp_partial               (scale_factor_fetch_resp_partial),

    .fetch_memory_range_start_address ({layer_config_scale_factors_address_msb_value, layer_config_scale_factors_address_lsb_value}),

    .read_master_req_valid            (scale_factor_read_master_req_valid),
    .read_master_req_ready            (fetch_tag_msg_rm_req_ready),
    .read_master_start_address        (scale_factor_read_master_start_address),
    .read_master_byte_count           (scale_factor_read_master_byte_count),
    
    .read_master_resp_valid           (fetch_tag_msg_rm_resp_valid),
    .read_master_resp_ready           (scale_factor_read_master_resp_ready),
    .read_master_resp_last            (fetch_tag_msg_rm_resp_last),
    .read_master_resp_data            (fetch_tag_msg_rm_resp_data),
    .read_master_resp_axi_id          (fetch_tag_msg_rm_resp_axi_id),
    
    .push_queue                       (scale_factor_queue_push),
    .push_data                        (scale_factor_queue_in_data),
    
    .queue_slots_available            ('1), // streaming disabled
    .queue_empty                      (scale_factor_queue_empty),
    .queue_full                       (scale_factor_queue_full)
);

// ==================================================================================================================================================
// Logic
// ==================================================================================================================================================

always_comb begin
    accepting_nsb_req           = nsb_prefetcher_req_valid && nsb_prefetcher_req_ready;

    accepting_message_fetch_req = fetch_tag_msg_rm_req_valid && fetch_tag_msg_rm_req_ready;    
    accepting_msg_fetch_resp    = fetch_tag_msg_rm_resp_valid && fetch_tag_msg_rm_resp_ready;
end

always_comb begin
    adj_queue_slots_available = ADJ_QUEUE_DEPTH - adj_queue_count;
    // adj_queue_slots_available = 7'd64 - adj_queue_count;
end

// Message queue fetch state machine
// ----------------------------------------------------

always_ff @(posedge core_clk or negedge resetn) begin
    if (!resetn) begin
        message_fetch_state        <= prefetcher_pkg::MSG_IDLE;
    end else begin
        message_fetch_state        <= message_fetch_state_n;
    end
end

always_comb begin
    message_fetch_state_n = message_fetch_state;

    case (message_fetch_state)
    
    prefetcher_pkg::MSG_IDLE: begin
        message_fetch_state_n = !tag_free && accepting_nsb_req
                                        && (nsb_prefetcher_req.req_opcode == MESSAGES) && !adj_queue_empty
                                        && (nsb_prefetcher_req.nodeslot == allocated_nodeslot)
                                        ? prefetcher_pkg::MSG_FETCH
                            : prefetcher_pkg::MSG_IDLE;
    end

    prefetcher_pkg::MSG_FETCH: begin
        message_fetch_state_n = accepting_message_fetch_req ? prefetcher_pkg::MSG_STORE
                            : prefetcher_pkg::MSG_FETCH;
    end

    prefetcher_pkg::MSG_STORE: begin
        message_fetch_state_n = accepting_msg_fetch_resp && (msg_queue_expected_responses == 1'b1) && adj_queue_empty ? prefetcher_pkg::MSG_DONE
                            : accepting_msg_fetch_resp && (msg_queue_expected_responses == 1'b1) && !adj_queue_empty && message_queue_full ? prefetcher_pkg::MSG_PAUSE
                            : accepting_msg_fetch_resp && (msg_queue_expected_responses == 1'b1) && !adj_queue_empty && !message_queue_full ? prefetcher_pkg::MSG_FETCH
                            : prefetcher_pkg::MSG_STORE;
    end

    prefetcher_pkg::MSG_PAUSE: begin
        message_fetch_state_n = adj_queue_empty ? MSG_DONE // defensive
                            : !adj_queue_empty && !message_queue_full ? prefetcher_pkg::MSG_FETCH // keep fetching when message queue clears
                            : prefetcher_pkg::MSG_PAUSE;
    end

    prefetcher_pkg::MSG_DONE: begin
        message_fetch_state_n = nsb_prefetcher_resp_valid && nsb_prefetcher_resp_ready && (nsb_prefetcher_resp.response_type == MESSAGES) ? prefetcher_pkg::MSG_IDLE
                            : prefetcher_pkg::MSG_DONE;
    end

    endcase
end

// Message queue logic
// ----------------------------------------------------

// Message read master is shared between Message Queue and Scale Factor queue requests

logic [$clog2(MAX_FETCH_REQ_BYTE_COUNT)-1:0] msg_fetch_required_bytes;

assign msg_fetch_required_bytes = (allocated_feature_count << 2);

always_comb begin
    fetch_tag_msg_rm_req_valid      = scale_factor_read_master_req_valid || ((message_fetch_state == prefetcher_pkg::MSG_FETCH) && !adj_queue_empty && adj_queue_head_valid && !message_queue_full);
    
    fetch_tag_msg_rm_start_address  = scale_factor_read_master_req_valid ? scale_factor_read_master_start_address
                                    : {2'd0, layer_config_in_messages_address_lsb_value} + adj_queue_head;
    
    fetch_tag_msg_rm_byte_count     = scale_factor_read_master_req_valid ? scale_factor_read_master_byte_count

                                    // For message fetch, find lowest multiple of 64 bytes greater than the required byte count
                                    : {msg_fetch_required_bytes[$clog2(MAX_FETCH_REQ_BYTE_COUNT)-1:6], 6'd0} + (|msg_fetch_required_bytes[5:0] ? 1'b1 : 1'b0);

    fetch_tag_msg_rm_resp_ready = (message_fetch_state == prefetcher_pkg::MSG_STORE) || scale_factor_read_master_resp_ready;

    push_message_queue   = (message_fetch_state == prefetcher_pkg::MSG_STORE) && accepting_msg_fetch_resp;
    msg_queue_write_data = fetch_tag_msg_rm_resp_data;
    
    pop_adj_queue = (message_fetch_state == prefetcher_pkg::MSG_FETCH) && accepting_message_fetch_req;
end

always_ff @(posedge core_clk or negedge resetn) begin
    if (!resetn) begin
        msg_fetch_req_precision_q    <= FLOAT_32; // 0 by default
        msg_queue_expected_responses <= '0;
        issue_nsb_partial_done_msg_fetch <= '0;
    
    // Accepting MSG fetch request from NSB
    end else if ((message_fetch_state == prefetcher_pkg::MSG_IDLE) && (message_fetch_state_n == prefetcher_pkg::MSG_FETCH)) begin // && accepting_nsb_req && (nsb_prefetcher_req.req_opcode == MESSAGES)
        msg_fetch_req_precision_q        <= nsb_prefetcher_req.nodeslot_precision;
        msg_queue_expected_responses     <= '0;
        issue_nsb_partial_done_msg_fetch <= '0;
    
    // Acceoting MSG fetch req to MSG read master
    end else if (accepting_message_fetch_req) begin
        msg_queue_expected_responses <= (fetch_tag_msg_rm_byte_count - 1)/64 + 1;
    
    end else begin
        // Accepting response from MSG read master
        if (accepting_msg_fetch_resp) begin
            msg_queue_expected_responses <= msg_queue_expected_responses - 1;
        end

        if ((message_fetch_state == prefetcher_pkg::MSG_STORE) && (message_fetch_state_n == prefetcher_pkg::MSG_PAUSE)) begin
            issue_nsb_partial_done_msg_fetch <= '1;
        end
        issue_nsb_partial_done_msg_fetch_q <= issue_nsb_partial_done_msg_fetch;
    end
end

// NSB interface
// ----------------------------------------------------

logic trigger_msg_partial_resp;

assign trigger_msg_partial_resp = (issue_nsb_partial_done_msg_fetch && !issue_nsb_partial_done_msg_fetch_q);

always_comb begin
    nsb_prefetcher_req_ready = !tag_free && (nsb_prefetcher_req.nodeslot == allocated_nodeslot) &&
                                (nsb_prefetcher_req.req_opcode == top_pkg::ADJACENCY_LIST ? adj_queue_manager_ready
                                : nsb_prefetcher_req.req_opcode == top_pkg::SCALE_FACTOR ? scale_factor_fetch_req_ready
                                : nsb_prefetcher_req.req_opcode == top_pkg::MESSAGES ? ((message_fetch_state == prefetcher_pkg::MSG_IDLE) && (nsb_prefetcher_req.req_opcode == top_pkg::MESSAGES) && !adj_queue_empty)
                                : '0 );

    nsb_prefetcher_resp_valid = adj_queue_fetch_resp_valid
                            || (message_fetch_state == prefetcher_pkg::MSG_DONE) || trigger_msg_partial_resp
                            || scale_factor_fetch_resp_valid;

    nsb_prefetcher_resp.nodeslot = allocated_nodeslot;
    nsb_prefetcher_resp.response_type = adj_queue_fetch_resp_valid ? ADJACENCY_LIST
                                        : scale_factor_fetch_resp_valid ? SCALE_FACTOR
                                        : trigger_msg_partial_resp || (message_fetch_state == prefetcher_pkg::MSG_DONE) ? MESSAGES
                                        : FETCH_RESERVED;

    nsb_prefetcher_resp.allocated_fetch_tag = TAG[$clog2(top_pkg::MESSAGE_CHANNEL_COUNT)-1:0];

    nsb_prefetcher_resp.partial = adj_queue_fetch_resp_partial || trigger_msg_partial_resp || scale_factor_fetch_resp_partial;
end

// Message Channel interface
// ----------------------------------------------------

always_ff @(posedge core_clk or negedge resetn) begin
    if (!resetn) begin
        accepted_message_channel_req <= '0;

    // Reset flag when receiving new nodeslot allocation
    end else if (tag_free && allocation_valid) begin
        accepted_message_channel_req <= '0;

    // latch flag to 1 when accepting message channel req (only service once per nodeslot allocation)
    end else if (message_channel_req_valid && message_channel_req_ready) begin
        accepted_message_channel_req <= '1;
    end
end

always_comb begin
    // Accept message channel req when completed message fetching
    message_channel_req_ready = !message_queue_empty && (message_fetch_state == prefetcher_pkg::MSG_IDLE)
                                    && (message_channel_req.nodeslot == allocated_nodeslot);

    message_channel_resp_valid = accepted_message_channel_req && message_queue_head_valid && !message_queue_empty;

    message_channel_resp.data = message_queue_head;
    // message_channel_resp.last = (message_queue_count == {{($clog2(MESSAGE_QUEUE_DEPTH)-1){1'b0}}, 1'b1});
    
    // When message queue count reaches feature count / 16 (rounded up), sending last neighbour's features
    message_channel_resp.last_neighbour = message_queue_count <= ({allocated_feature_count[$clog2(MAX_FEATURE_COUNT)-1:4], 4'd0} + (|allocated_feature_count[3:0] ? 1'b1 : 1'b0));

    // Sending last feature when message queue count == 1
    message_channel_resp.last_feature = (message_queue_count[$clog2(MESSAGE_QUEUE_DEPTH)-1:1] == '0) && message_queue_count[0];

    // Pop message queue when accepting message channel resp
    pop_message_queue = message_channel_resp_valid && message_channel_resp_ready;
end

// Allocation
// ----------------------------------------------------

assign make_tag_free = deallocation_valid && adj_queue_empty && message_queue_empty
            && adj_queue_manager_free
            && (message_fetch_state == prefetcher_pkg::MSG_IDLE);

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