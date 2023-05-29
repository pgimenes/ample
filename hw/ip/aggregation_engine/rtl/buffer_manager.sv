import top_pkg::*;
import age_pkg::*;
import noc_params::*;

module buffer_manager #(
    parameter X_COORD = 0,
    parameter Y_COORD = 0,
    parameter BUFFER_SLOT_WRITE_DEPTH = 512,
    parameter BUFFER_SLOT_WRITE_WIDTH = 64
) (
    input  logic core_clk,
    input  logic resetn,

    // AGE -> Buffer Manager REQ
    input  logic                                                      age_buffer_manager_nodeslot_allocation_valid,
    output logic                                                      age_buffer_manager_nodeslot_allocation_ready,
    input  AGE_BUFF_MAN_ALLOC_t                                       age_buffer_manager_nodeslot_allocation,

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
    output logic [NODE_ID_WIDTH-1:0]                                  buffer_slot_set_node_id,
    output logic                                                      bm_buffer_slot_write_enable,
    output logic [$clog2(BUFFER_SLOT_WRITE_DEPTH)-1:0]                bm_buffer_slot_write_address,
    output logic [BUFFER_SLOT_WRITE_WIDTH-1:0]                        bm_buffer_slot_write_data,
    input  logic [$clog2(top_pkg::AGGREGATION_BUFFER_READ_DEPTH)-1:0] buffer_slot_bm_feature_count,
    input  logic                                                      buffer_slot_bm_slot_free
);

typedef enum logic [2:0] { BM_FSM_IDLE, BM_FSM_WAIT_FEATURES, BM_FSM_WRITE, BM_FSM_SEND_DONE, BM_FSM_WAIT_DRAIN, BM_FSM_WAIT_TRANSFORMATION} BM_FSM_e;

// ==================================================================================================================================================
// Declarations
// ==================================================================================================================================================

BM_FSM_e                                                  bm_state, bm_state_n;

logic [TOTAL_AGGREGATION_MANAGERS-1:0]                    allocated_agm_q;
logic [MAX_AGC_PER_NODE-1:0] [$clog2(MESH_COLS)-1:0]       allocated_agcs_x_coords_q;
logic [MAX_AGC_PER_NODE-1:0] [$clog2(MESH_ROWS)-1:0]       allocated_agcs_y_coords_q;
logic [$clog2(MAX_AGC_PER_NODE)-1:0]                       allocated_agcs_count_q;

logic [MAX_AGC_PER_NODE-1:0]                               allocated_agcs_oh;
logic [MAX_AGC_PER_NODE-1:0]                               allocated_agcs;
logic [MAX_AGC_PER_NODE-1:0]                               agc_done;

flit_t                                                    received_flit;
logic [$clog2(MAX_AGC_PER_NODE)-1:0]                       agc_offset; // offset of the AGC that sent the last received packet flit

logic [$clog2(MESH_ROWS)-1:0]                             received_packet_source_row;
logic [$clog2(MESH_COLS)-1:0]                             received_packet_source_col;
logic [$clog2(MESH_ROWS)-1:0]                             incoming_packet_source_row;
logic [$clog2(MESH_COLS)-1:0]                             incoming_packet_source_col;

logic [MAX_AGC_PER_NODE-1:0]                               agc_source_oh;
logic [MAX_AGC_PER_NODE-1:0]                               agc_source_oh_early;
logic [MAX_AGC_PER_NODE-1:0] [3:0]                         flit_counter;

// Done packets
logic [$clog2(MESH_COLS)-1:0]                             outgoing_packet_dest_col;
logic [$clog2(MESH_ROWS)-1:0]                             outgoing_packet_dest_row;

logic                                                     noc_router_waiting;
logic                                                     done_head_sent;

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
assign buffer_slot_set_node_id = age_buffer_manager_nodeslot_allocation.node_id;
assign buffer_slot_set_node_id_valid = (bm_state == BM_FSM_IDLE) && age_buffer_manager_nodeslot_allocation_valid;

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
            bm_state_n = age_buffer_manager_nodeslot_allocation_valid ? BM_FSM_WAIT_FEATURES : BM_FSM_IDLE;
        end

        BM_FSM_WAIT_FEATURES: begin
            bm_state_n = router_buffer_manager_valid ? BM_FSM_WRITE : BM_FSM_WAIT_FEATURES;
        end

        BM_FSM_WRITE: begin
            bm_state_n = &agc_done ? BM_FSM_SEND_DONE : BM_FSM_WAIT_FEATURES;
        end

        BM_FSM_SEND_DONE: begin
            bm_state_n = noc_router_waiting && done_head_sent ? BM_FSM_WAIT_DRAIN : BM_FSM_SEND_DONE;
        end

        BM_FSM_WAIT_DRAIN: begin
            bm_state_n = noc_router_waiting ? BM_FSM_IDLE : BM_FSM_WAIT_TRANSFORMATION;
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

    // Accepting the AGE buffer request
    end else if (age_buffer_manager_nodeslot_allocation_valid && age_buffer_manager_nodeslot_allocation_ready) begin
        allocated_agm_q           <= age_buffer_manager_nodeslot_allocation.aggregation_manager;
        allocated_agcs_x_coords_q <= age_buffer_manager_nodeslot_allocation.allocated_agcs_x_coords;
        allocated_agcs_y_coords_q <= age_buffer_manager_nodeslot_allocation.allocated_agcs_y_coords;
        allocated_agcs_count_q    <= age_buffer_manager_nodeslot_allocation.allocated_agcs_count;
    end
end

assign allocated_agcs = allocated_agcs_oh - 1'b1;

// Decode incoming packets
// -------------------------------------------------------------------------------------

always_comb begin
    {received_packet_source_col, received_packet_source_row} = age_pkg::decode_packet_source(received_flit);

    // Decode packets arriving during handshake
    {incoming_packet_source_col, incoming_packet_source_row} = age_pkg::decode_packet_source(router_buffer_manager_data);
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
            flit_counter[agc_source] <= agc_source_oh_early[agc_source] ? flit_counter[agc_source] + 1 : flit_counter[agc_source];
        end
    end

    assign agc_done[agc_source] = allocated_agcs[agc_source] ? flit_counter[agc_source] == 'd8 : '1;
end

// Drive aggregation buffer slot
// -------------------------------------------------------------------------------------

always_comb begin
    bm_buffer_slot_write_enable = (bm_state == BM_FSM_WRITE);
    bm_buffer_slot_write_address = {agc_offset, flit_counter[agc_offset] - 1'b1};
    bm_buffer_slot_write_data = received_flit.data.bt_pl[63:0];
end

// Send done packet to Aggregation Manager
// -------------------------------------------------------------------------------------

always_comb begin
    buffer_manager_router_valid = (bm_state == BM_FSM_SEND_DONE);

    outgoing_packet_dest_col = allocated_agm_q;
    outgoing_packet_dest_row = age_pkg::MESH_ROWS - 1;

    buffer_manager_router_data.vc_id = '0; // TO DO: consider using both VCs?
    buffer_manager_router_data.flit_label = done_head_sent ? noc_params::TAIL : noc_params::HEAD;

    buffer_manager_router_data.data.bt_pl = { outgoing_packet_dest_col, outgoing_packet_dest_row,
                                                X_COORD[$clog2(MESH_COLS)-1:0], Y_COORD[$clog2(MESH_COLS)-1:0],
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
    end else if (buffer_manager_router_valid && (buffer_manager_router_data.flit_label == noc_params::HEAD)) begin
        done_head_sent     <= '1;
        
    
    end else if (buffer_manager_router_valid && (buffer_manager_router_data.flit_label == noc_params::TAIL)) begin
        noc_router_waiting <= '0;
        done_head_sent     <= '0;
    end
end

endmodule