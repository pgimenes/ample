import top_pkg::*;
import age_pkg::*;
import noc_pkg::*;

module buffer_manager #(
    parameter X_COORD = 0,
    parameter Y_COORD = 0,

    parameter AGGREGATION_ROWS = top_pkg::AGGREGATION_BUFFER_SLOTS,
    parameter AGGREGATION_COLS = top_pkg::MESSAGE_CHANNEL_COUNT/top_pkg::PRECISION_COUNT/top_pkg::MESH_MULTIPLIER,
    
    parameter BUFFER_SLOT_WRITE_DEPTH = 64,
    parameter BUFFER_SLOT_WRITE_WIDTH = 512
) (
    input  logic core_clk,
    input  logic resetn,

    // AGE -> Buffer Manager REQ
    input  logic                                                      age_buffer_manager_nodeslot_allocation_valid,
    output logic                                                      age_buffer_manager_nodeslot_allocation_ready,
    input  AGE_BUFF_MAN_ALLOC_t                                       age_buffer_manager_nodeslot_allocation,

    // Buffer Manager -> Buffer Manager Arbiter
    output logic                                                      buffer_manager_done,

    // Buffer Manager -> Router
    input  logic                                                      buffer_manager_router_on,
    output logic                                                      buffer_manager_router_valid,
    input  logic                                                      buffer_manager_router_ready,
    output flit_t                                                     buffer_manager_router_data,

    // Router -> Buffer Manager
    output logic                                                      router_buffer_manager_on,
    input  logic                                                      router_buffer_manager_valid,
    output logic                                                      router_buffer_manager_ready,
    input  flit_t                                                     router_buffer_manager_data,

    // Buffer Manager -> Aggregation Buffer slot
    output logic                                                      buffer_slot_set_node_id_valid,
    input  logic                                                      buffer_slot_set_node_id_ready,
    output logic [top_pkg::NODE_ID_WIDTH-1:0]                         buffer_slot_set_node_id,

    output logic                                                      bm_buffer_slot_write_enable,
    input  logic                                                      bm_buffer_slot_write_ready,
    output logic [$clog2(BUFFER_SLOT_WRITE_DEPTH)-1:0]                bm_buffer_slot_write_address,
    output logic [BUFFER_SLOT_WRITE_WIDTH-1:0]                        bm_buffer_slot_write_data,

    input  logic [$clog2(top_pkg::AGGREGATION_BUFFER_READ_DEPTH)-1:0] buffer_slot_bm_feature_count,
    input  logic                                                      buffer_slot_bm_slot_free
);

parameter EXPECTED_FLITS_PER_PACKET = 2;

typedef enum logic [3:0] {
    BM_FSM_IDLE,
    BM_FSM_SET_NODE_ID,
    BM_FSM_WAIT_FEATURES,
    BM_FSM_WAIT_SLOT_ALLOCATION,
    BM_FSM_SEND_READY,
    BM_FSM_WRITE,
    BM_FSM_SEND_DONE,
    BM_FSM_WAIT_DRAIN,
    BM_FSM_WAIT_TRANSFORMATION
} BM_FSM_e;

// ==================================================================================================================================================
// Declarations
// ==================================================================================================================================================

BM_FSM_e                                                   bm_state, bm_state_n;

logic [$clog2(MAX_AGGREGATION_ROWS)-1:0]                   allocated_agm_q;
logic [MAX_AGC_PER_NODE-1:0] [$clog2(MAX_MESH_COLS)-1:0]   allocated_agcs_x_coords_q;
logic [MAX_AGC_PER_NODE-1:0] [$clog2(MAX_MESH_ROWS)-1:0]   allocated_agcs_y_coords_q;
logic [$clog2(MAX_AGC_PER_NODE)-1:0]                       allocated_agcs_count_q;
logic [top_pkg::NODE_ID_WIDTH-1:0]                         allocated_node_id_q;

logic [MAX_AGC_PER_NODE-1:0]                               allocated_agcs_oh;
logic [MAX_AGC_PER_NODE-1:0]                               allocated_agcs;
logic [MAX_AGC_PER_NODE-1:0]                               agc_done;

flit_t                                                     received_flit;
logic [$clog2(MAX_AGC_PER_NODE)-1:0]                       agc_offset; // offset of the AGC that sent the last received packet flit

logic [$clog2(MAX_MESH_ROWS)-1:0]                          received_packet_source_row;
logic [$clog2(MAX_MESH_COLS)-1:0]                          received_packet_source_col;
logic [$clog2(MAX_MESH_ROWS)-1:0]                          incoming_packet_source_row;
logic [$clog2(MAX_MESH_COLS)-1:0]                          incoming_packet_source_col;

logic [MAX_AGC_PER_NODE-1:0]                               agc_source_oh;
logic [MAX_AGC_PER_NODE-1:0]                               agc_source_oh_early;
logic [MAX_AGC_PER_NODE-1:0] [3:0]                         flit_counter;

// Done packets
logic [$clog2(MAX_MESH_COLS)-1:0]                          outgoing_packet_dest_col;
logic [$clog2(MAX_MESH_ROWS)-1:0]                          outgoing_packet_dest_row;

logic                                                      noc_router_waiting;
logic                                                      done_head_sent;

// ==================================================================================================================================================
// Instances
// ==================================================================================================================================================

// Create one-hot mask of which AGCs were allocated based on AGC allocation count
// This is used to evaluate which flit counters should reach max value of 8
binary_to_onehot #(
    .WIDTH          ($clog2(MAX_AGC_PER_NODE))
) allocated_agcs_bin2oh (
    .binary_input     (allocated_agcs_count_q),
    .one_hot_output   (allocated_agcs_oh)
);

// Convert one hot mask of AGC source to AGC offset for buffer address
onehot_to_binary_comb #(
    .INPUT_WIDTH    (MAX_AGC_PER_NODE)
) agc_offset_oh2bin (
    .input_data     (agc_source_oh),
    .output_data    (agc_offset)
);

// ==================================================================================================================================================
// Logic
// ==================================================================================================================================================

// Set node ID for buffer slot
assign buffer_slot_set_node_id = allocated_node_id_q;
assign buffer_slot_set_node_id_valid = (bm_state == BM_FSM_SET_NODE_ID);

always_ff @(posedge core_clk or negedge resetn) begin
    if (!resetn) begin
        bm_state <= BM_FSM_IDLE;
    end else begin
        bm_state <= bm_state_n;
    end
end

always_comb begin
    bm_state_n = bm_state;

    case(bm_state)

        BM_FSM_IDLE: begin
            bm_state_n = age_buffer_manager_nodeslot_allocation_valid ? BM_FSM_SET_NODE_ID : BM_FSM_IDLE;
        end

        BM_FSM_SET_NODE_ID: begin
            bm_state_n = buffer_slot_set_node_id_ready ? BM_FSM_WAIT_FEATURES : BM_FSM_SET_NODE_ID;
        end

        BM_FSM_WAIT_FEATURES: begin
            bm_state_n = router_buffer_manager_valid ? BM_FSM_WRITE : BM_FSM_WAIT_FEATURES;
        end

        BM_FSM_WRITE: begin
            bm_state_n = &agc_done ? BM_FSM_SEND_DONE 
                        : bm_buffer_slot_write_ready ? BM_FSM_WAIT_FEATURES
                        : BM_FSM_WRITE;
        end

        BM_FSM_SEND_DONE: begin
            bm_state_n = noc_router_waiting && done_head_sent ? BM_FSM_WAIT_DRAIN : BM_FSM_SEND_DONE;
        end

        BM_FSM_WAIT_DRAIN: begin
            bm_state_n = noc_router_waiting ? BM_FSM_WAIT_TRANSFORMATION : BM_FSM_WAIT_DRAIN;
        end

        BM_FSM_WAIT_TRANSFORMATION: begin
            bm_state_n = buffer_slot_bm_slot_free ? BM_FSM_IDLE : BM_FSM_WAIT_TRANSFORMATION;
        end

        default: begin
            bm_state_n = BM_FSM_IDLE;
        end

    endcase
end

// AGE buffer requests (nodeslot allocation)
// -------------------------------------------------------------------------------------

assign age_buffer_manager_nodeslot_allocation_ready = (bm_state == BM_FSM_IDLE);

always_ff @(posedge core_clk or negedge resetn) begin
    if (!resetn) begin
        allocated_agm_q           <= '0;
        allocated_agcs_x_coords_q <= '0;
        allocated_agcs_y_coords_q <= '0;
        allocated_agcs_count_q    <= '0;
        allocated_node_id_q       <= '0;

    // Accepting the AGE buffer request
    end else if (age_buffer_manager_nodeslot_allocation_valid && age_buffer_manager_nodeslot_allocation_ready) begin
        allocated_agm_q           <= age_buffer_manager_nodeslot_allocation.aggregation_manager;
        allocated_agcs_x_coords_q <= age_buffer_manager_nodeslot_allocation.allocated_agcs_x_coords;
        allocated_agcs_y_coords_q <= age_buffer_manager_nodeslot_allocation.allocated_agcs_y_coords;
        allocated_agcs_count_q    <= age_buffer_manager_nodeslot_allocation.allocated_agcs_count;
        allocated_node_id_q       <= age_buffer_manager_nodeslot_allocation.node_id;
    end
end

assign allocated_agcs = allocated_agcs_oh - 1'b1;

assign buffer_manager_done = (bm_state == BM_FSM_WAIT_TRANSFORMATION) && (bm_state_n == BM_FSM_IDLE);

// Decode incoming packets
// -------------------------------------------------------------------------------------

always_comb begin
    {received_packet_source_col, received_packet_source_row} = noc_pkg::decode_packet_source(received_flit);

    // Decode packets arriving during handshake
    {incoming_packet_source_col, incoming_packet_source_row} = noc_pkg::decode_packet_source(router_buffer_manager_data);
end

// Register incoming features
// -------------------------------------------------------------------------------------

always_comb begin
    router_buffer_manager_on = (bm_state == BM_FSM_WAIT_FEATURES);
    router_buffer_manager_ready = (bm_state == BM_FSM_WAIT_FEATURES);
end

always_ff @(posedge core_clk or negedge resetn) begin
    if (!resetn) begin
        received_flit <= '0;
    
    end else if (router_buffer_manager_on && router_buffer_manager_valid && router_buffer_manager_ready) begin
        received_flit <= router_buffer_manager_data;
    end
end

// Flit counter for each AGC allocated to the current nodeslot
// -------------------------------------------------------------------------------------

for (genvar agc_source = 0; agc_source < MAX_AGC_PER_NODE; agc_source++) begin

    // One hot mask indicating which AGC in the allocation list is the source of the current packet
    assign agc_source_oh[agc_source] = (allocated_agcs_x_coords_q[agc_source] == received_packet_source_col)
                                        && (allocated_agcs_y_coords_q[agc_source] == received_packet_source_row);
    
    assign agc_source_oh_early[agc_source] = (allocated_agcs_x_coords_q[agc_source] == incoming_packet_source_col)
                                        && (allocated_agcs_y_coords_q[agc_source] == incoming_packet_source_row);
    
    always_ff @(posedge core_clk or negedge resetn) begin
        if (!resetn) begin
            flit_counter[agc_source] <= '0;

        // Receiving new nodeslot allocation
        end else if ((bm_state == BM_FSM_IDLE) && age_buffer_manager_nodeslot_allocation_valid) begin
            flit_counter[agc_source] <= '0;

        // Accepting the feature flit from an AGC
        end else if (router_buffer_manager_on && router_buffer_manager_valid && router_buffer_manager_ready) begin
            // Read AGC source combinatorially from incoming packet (not registered yet)
            flit_counter[agc_source] <= agc_source_oh_early[agc_source] ? flit_counter[agc_source] + 1'b1 : flit_counter[agc_source];
        end
    end

    assign agc_done[agc_source] = allocated_agcs[agc_source] ? (flit_counter[agc_source] == EXPECTED_FLITS_PER_PACKET[3:0]) : '1;
end

// Drive aggregation buffer slot
// -------------------------------------------------------------------------------------

always_comb begin
    bm_buffer_slot_write_enable = (bm_state == BM_FSM_WRITE) && !(&agc_done); // at least one agc isn't done yet
    bm_buffer_slot_write_address = agc_offset;
    bm_buffer_slot_write_data = received_flit.data.bt_pl;
end

// Send done packet to Aggregation Manager
// -------------------------------------------------------------------------------------

always_comb begin
    buffer_manager_router_valid = (bm_state == BM_FSM_SEND_DONE);

    outgoing_packet_dest_col = 0; // column width always 1 bit larger than AGM width
    outgoing_packet_dest_row = {1'b0, allocated_agm_q};

    buffer_manager_router_data.vc_id = '0;
    buffer_manager_router_data.flit_label = done_head_sent ? noc_pkg::TAIL : noc_pkg::HEAD;

    buffer_manager_router_data.data.bt_pl = { outgoing_packet_dest_col, outgoing_packet_dest_row,
                                                X_COORD[$clog2(MAX_MESH_COLS)-1:0], Y_COORD[$clog2(MAX_MESH_ROWS)-1:0],
                                                // packet is empty since any packet received by an AGM from a BM indicates buffering done
                                                {PAYLOAD_DATA_WIDTH{1'b0}} }; // 64 zeros
end

// Router allocatable flag for outgoing packets
always_ff @(posedge core_clk or negedge resetn) begin
    if (!resetn) begin
        noc_router_waiting <= '1;
        done_head_sent     <= '0;

    // Assert flag when router pulses allocatable
    end else if (buffer_manager_router_ready) begin
        noc_router_waiting <= '1;

    // Drop when sending the tail packet and wait for router to be allocatable again        
    end else if (buffer_manager_router_valid && (buffer_manager_router_data.flit_label == noc_pkg::HEAD)) begin
        done_head_sent     <= '1;
        
    
    end else if (buffer_manager_router_valid && (buffer_manager_router_data.flit_label == noc_pkg::TAIL)) begin
        noc_router_waiting <= '0;
        done_head_sent     <= '0;
    end
end

endmodule