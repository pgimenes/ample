import top_pkg::*;
import age_pkg::*;
import noc_params::*;

module aggregation_core #(
    parameter X_COORD = 0,
    parameter Y_COORD = 0,

    parameter FEATURE_COUNT = 16,

    parameter DATA_WIDTH = 32,
    parameter FLOAT_WIDTH = 32,
    parameter PRECISION = "FLOAT_32"
) (
    input logic core_clk,
    input logic resetn,

    // Allocation interface
    output logic                                        aggregation_core_free,

    // Aggregation Core -> Router
    input  logic                                        aggregation_core_router_on,
    output logic                                        aggregation_core_router_valid,
    input  logic                                        aggregation_core_router_ready,
    output flit_t                                       aggregation_core_router_data,

    // Router -> Aggregation Core
    output logic                                        router_aggregation_core_on,
    input  logic                                        router_aggregation_core_valid,
    output logic                                        router_aggregation_core_ready,
    input  flit_t                                       router_aggregation_core_data
);

parameter ALLOCATION_PKT_AGGR_FUNC_OFFSET = $clog2(top_pkg::MAX_NODESLOT_COUNT);

typedef enum logic [3:0] {
    AGC_FSM_IDLE,
    AGC_FSM_NODESLOT_ALLOCATION,
    AGC_FSM_WAIT_FEATURE_HEAD,
    AGC_FSM_WAIT_FEATURE_BODY,
    AGC_FSM_UPDATE_ACCS,
    AGC_FSM_UPSAMPLE,
    AGC_FSM_WAIT_BUFFER_REQ,
    AGC_FSM_SEND_BUFF_MAN,
    AGC_FSM_WAIT_DRAIN
} aggregation_core_fsm_e;

function logic [$bits(aggregation_manager_packet_type_e)+1-1:0] decode_head_packet (input flit_t input_packet);
    logic [1:0] field;
    aggregation_manager_packet_type_e out_type;
    logic last_flag;

    field = input_packet.data.bt_pl[PAYLOAD_DATA_WIDTH-1 : PAYLOAD_DATA_WIDTH-$bits(aggregation_manager_packet_type_e)];
    out_type = field == 2'b00 ? AGC_NODESLOT_ALLOCATION
                : field == 2'b01 ? AGC_FEATURE_PACKET
                : field == 2'b10 ? BM_BUFFER_REQUEST
                : AGM_PKT_ERROR;

    last_flag = input_packet.data.bt_pl[PAYLOAD_DATA_WIDTH-$bits(aggregation_manager_packet_type_e)-1];
    
    return {out_type, last_flag};
endfunction

// ==================================================================================================================================================
// Declarations
// ==================================================================================================================================================

// Coordinates of this aggregation core
logic [$clog2(MESH_COLS)-1:0]                   x_coord;
logic [$clog2(MESH_ROWS)-1:0]                   y_coord;

aggregation_core_fsm_e                          agc_state, agc_state_n;

// Payloads from nodeslot allocation packet
logic [$clog2(top_pkg::MAX_NODESLOT_COUNT)-1:0] nodeslot_allocation_nodeslot;
top_pkg::AGGREGATION_FUNCTION_e                 nodeslot_allocation_aggregation_function;

logic [FEATURE_COUNT-1:0] [DATA_WIDTH-1:0]      features;

logic [FEATURE_COUNT-1:0]                       feature_aggregator_in_feature_valid;
logic [FEATURE_COUNT-1:0]                       feature_aggregator_in_feature_ready;
logic [FEATURE_COUNT-1:0] [DATA_WIDTH-1:0]      feature_aggregator_in_feature;
logic [FEATURE_COUNT-1:0]                       feature_aggregator_feature_updated;
logic [FEATURE_COUNT-1:0]                       feature_aggregator_reset_accumulator;

// Mask of features updated, updated every time a feature packet head is received
logic [FEATURE_COUNT-1:0]                       feature_updated;

// Packet decoding
// --------------------------------------------

flit_t                                          router_agc_pkt_q;
logic [3:0]                                     received_flits;

logic                                           head_packet;
logic                                           tail_packet;

logic [$clog2(MESH_ROWS)-1:0]                   packet_dest_row;
logic [$clog2(MESH_COLS)-1:0]                   packet_dest_col;
logic correct_pkt_dest;

logic [$clog2(MESH_ROWS)-1:0]                   packet_source_row;
logic [$clog2(MESH_COLS)-1:0]                   packet_source_col;

// Aggregation Manager packets
logic                                           aggregation_manager_pkt;
aggregation_manager_packet_type_e               aggregation_manager_packet_type; // 0 for allocation, 1 for feature
logic                                           aggregation_manager_packet_last;
logic                                           aggregation_manager_packet_last_q;

logic                                           received_buffer_req_head;
logic [$clog2(MESH_ROWS)-1:0]                   buffer_manager_pkt_dest_row;
logic [$clog2(MESH_COLS)-1:0]                   buffer_manager_pkt_dest_col;

logic [63:0]                                    bm_chosen_data;
logic [$clog2(FEATURE_COUNT/2)-1:0]             sent_flits_counter;

logic                                           noc_router_waiting;

// Multi-precision support
logic                                       upsample;
logic [FEATURE_COUNT-1:0]                   upsampled_accumulator_valid;
logic [FEATURE_COUNT-1:0] [FLOAT_WIDTH-1:0] upsampled_features;

// ==================================================================================================================================================
// Instantiations
// ==================================================================================================================================================

for (genvar feature = 0; feature < FEATURE_COUNT; feature = feature + 1) begin
    feature_aggregator #(
        .DATA_WIDTH (DATA_WIDTH),
        .PRECISION  (PRECISION)
    ) feature_aggregator_i (
        .core_clk,
        .resetn,

        .aggregation_function_sel      (nodeslot_allocation_aggregation_function),

        .in_feature_valid              (feature_aggregator_in_feature_valid      [feature]),
        .in_feature_ready              (feature_aggregator_in_feature_ready      [feature]),
        .in_feature                    (feature_aggregator_in_feature            [feature]),

        .feature_updated               (feature_aggregator_feature_updated       [feature]),
        .accumulator                   (features                                 [feature]),
        
        .reset_accumulator             (feature_aggregator_reset_accumulator     [feature]),

        .upsample                       (upsample),
        .upsampled_accumulator_valid    (upsampled_accumulator_valid             [feature]),
        .upsampled_accumulator          (upsampled_features                      [feature])
    );

    // Update mask of updated features for the current packet
    always_ff @(posedge core_clk or negedge resetn) begin
        if (!resetn) begin
            feature_updated [feature] <= '0;

        // Receiving head flit for new feature packet
        end else if (router_aggregation_core_valid && router_aggregation_core_ready && aggregation_manager_pkt && head_packet) begin
            feature_updated [feature] <= '0;

        // Assert flag when feature is updated
        end else if (feature_aggregator_feature_updated[feature]) begin
            feature_updated [feature] <= '1;
        end
    end
end

// ==================================================================================================================================================
// Logic
// ==================================================================================================================================================

// Coordinates of this aggregation core
assign x_coord = X_COORD;
assign y_coord = Y_COORD;

// Aggregation Core state machine
// --------------------------------------------

always_ff @(posedge core_clk or negedge resetn) begin
    if (!resetn) begin
        agc_state <= AGC_FSM_IDLE;
    end else begin
        agc_state <= agc_state_n;
    end
end

always_comb begin
    agc_state_n = agc_state;

    case(agc_state)

    AGC_FSM_IDLE: begin
        agc_state_n <= router_aggregation_core_valid && head_packet && aggregation_manager_pkt && correct_pkt_dest && (aggregation_manager_packet_type == AGC_NODESLOT_ALLOCATION) ? AGC_FSM_NODESLOT_ALLOCATION : AGC_FSM_IDLE;
    end

    AGC_FSM_NODESLOT_ALLOCATION: begin
        agc_state_n <= router_aggregation_core_valid && tail_packet && aggregation_manager_pkt && correct_pkt_dest ? AGC_FSM_WAIT_FEATURE_HEAD
                    : AGC_FSM_NODESLOT_ALLOCATION;
    end

    AGC_FSM_WAIT_FEATURE_HEAD: begin
        agc_state_n <= router_aggregation_core_valid && head_packet && aggregation_manager_pkt && correct_pkt_dest && (aggregation_manager_packet_type == AGC_FEATURE_PACKET) ? AGC_FSM_WAIT_FEATURE_BODY // receiving feature packet
                    : AGC_FSM_WAIT_FEATURE_HEAD;
    end

    AGC_FSM_WAIT_FEATURE_BODY: begin
        agc_state_n <= router_aggregation_core_valid && aggregation_manager_pkt && correct_pkt_dest ? AGC_FSM_UPDATE_ACCS // receiving feature packet
                    : AGC_FSM_WAIT_FEATURE_BODY;
    end
    
    AGC_FSM_UPDATE_ACCS: begin
        agc_state_n <= 
                    // Updating last feature accumulator and last packet flag has already been received
                    (received_flits == 4'd8) && feature_updated[FEATURE_COUNT-1] && feature_updated[FEATURE_COUNT-2] && aggregation_manager_packet_last_q ? AGC_FSM_UPSAMPLE // updating final features

                    // Updating last feature accumulator but packets still pending
                    : (received_flits == 4'd8) && feature_updated[FEATURE_COUNT-1] && feature_updated[FEATURE_COUNT-2] ? AGC_FSM_WAIT_FEATURE_HEAD

                    // Feature accumulators accepting update but flits still pending for this packet
                    : feature_updated[2*(received_flits-1)] && feature_updated[2*(received_flits-1) + 1] ? AGC_FSM_WAIT_FEATURE_BODY
                    : AGC_FSM_UPDATE_ACCS;
    end

    AGC_FSM_UPSAMPLE: begin
        agc_state_n <= &upsampled_accumulator_valid ? AGC_FSM_WAIT_BUFFER_REQ : AGC_FSM_UPSAMPLE;
    end
    
    AGC_FSM_WAIT_BUFFER_REQ: begin
        agc_state_n <= router_aggregation_core_valid && aggregation_manager_pkt && received_buffer_req_head && tail_packet && correct_pkt_dest ? AGC_FSM_SEND_BUFF_MAN
                    : AGC_FSM_WAIT_BUFFER_REQ;
    end

    AGC_FSM_SEND_BUFF_MAN: begin
        agc_state_n <= (sent_flits_counter == 'd7) ? AGC_FSM_IDLE : AGC_FSM_SEND_BUFF_MAN;
    end

    AGC_FSM_WAIT_DRAIN: begin
        agc_state_n <= noc_router_waiting ? AGC_FSM_IDLE : AGC_FSM_WAIT_DRAIN;
    end

    default: agc_state_n = AGC_FSM_IDLE;

    endcase
end

// Packet decoding
// --------------------------------------------------------------------------------------------

logic [age_pkg::MESH_NODE_ID_WIDTH-1:0] packet_source;

// All packets
always_comb begin    
    head_packet = (router_aggregation_core_data.flit_label == noc_params::HEAD);
    tail_packet = (router_aggregation_core_data.flit_label == noc_params::TAIL);

    packet_source = router_aggregation_core_data.data.head_data.head_pl[noc_params::HEAD_PAYLOAD_SIZE-1 : noc_params::HEAD_PAYLOAD_SIZE-MESH_NODE_ID_WIDTH];    
    packet_source_col = packet_source[MESH_NODE_ID_WIDTH - 1 : MESH_NODE_ID_WIDTH - $clog2(age_pkg::MESH_COLS)];
    packet_source_row = packet_source[$clog2(age_pkg::MESH_ROWS)-1:0];
    
    packet_dest_col = router_aggregation_core_data.data.head_data.x_dest;
    packet_dest_row = router_aggregation_core_data.data.head_data.y_dest;

    correct_pkt_dest = (packet_dest_row == y_coord) && (packet_dest_col == x_coord);
end

// Aggregation Manager Packets
always_comb begin
    aggregation_manager_pkt = (packet_source_row == age_pkg::AGC_ROWS); // 16th row, 0 indexed = last row
    {aggregation_manager_packet_type, aggregation_manager_packet_last} = decode_head_packet(router_aggregation_core_data);
end

// Packet counter
always_ff @(posedge core_clk or negedge resetn) begin
    if (!resetn) begin
        router_agc_pkt_q                  <= '0;
        received_flits                    <= '0;
        aggregation_manager_packet_last_q <= '0;
        received_buffer_req_head          <= '0;
        sent_flits_counter                <= '0;

    // Nodeslot allocation finished OR finished updating accumulators, wait for next packet
    end else if ((agc_state_n == AGC_FSM_IDLE) || (agc_state_n == AGC_FSM_WAIT_FEATURE_HEAD)) begin
        router_agc_pkt_q                  <= router_aggregation_core_data; // for completeness: ignore this packet
        received_flits                    <= '0;
        aggregation_manager_packet_last_q <= '0;
        received_buffer_req_head          <= '0;
        sent_flits_counter                <= '0;

    // Accepting packet from router - either nodeslot allocation or feature packet
    end else if (router_aggregation_core_valid && router_aggregation_core_ready && aggregation_manager_pkt) begin
        if (head_packet) begin
            aggregation_manager_packet_last_q <= aggregation_manager_packet_last; // last packet flag
            received_buffer_req_head <= (aggregation_manager_packet_type == BM_BUFFER_REQUEST); // buffer request head flag
        
        end else begin
            // Only update flits counter for body and tail flits
            received_flits <= received_flits + 1;
        end

        router_agc_pkt_q <= router_aggregation_core_data;
    
    // Sending packet to buffer manager
    end else if (aggregation_core_router_valid && noc_router_waiting) begin
        sent_flits_counter <= sent_flits_counter + 1;
    end
end

// Router allocatable flag for outgoing packets
always_ff @(posedge core_clk or negedge resetn) begin
    if (!resetn) begin
        noc_router_waiting <= '1;

    // Assert flag when router pulses allocatable
    end else if (aggregation_core_router_ready) begin
        noc_router_waiting <= '1;

    // Drop when sending the tail packet and wait for router to be allocatable again        
    end else if (aggregation_core_router_valid && (aggregation_core_router_data.flit_label == noc_params::TAIL)) begin
        noc_router_waiting <= '0;
    end
end

// Feature accumulators
// --------------------------------------------------------------------------------------------

// Reset all accumulators when receiving new nodeslot allocation
assign feature_aggregator_reset_accumulator = (agc_state == AGC_FSM_IDLE) && (agc_state_n == AGC_FSM_NODESLOT_ALLOCATION) ? '1 : '0;

// Update accumulators depending on number of packet beats received
// Update both accumulators at the same time by waiting for both ready signals to be asserted
for (genvar pkt = 0; pkt < 8; pkt++) begin
    always_comb begin
        feature_aggregator_in_feature_valid [2*pkt]     = (agc_state == AGC_FSM_UPDATE_ACCS) && (received_flits == (pkt+1)) && !feature_updated[2*pkt];
        feature_aggregator_in_feature       [2*pkt]     = router_agc_pkt_q.data.bt_pl[63:32];

        feature_aggregator_in_feature_valid [2*pkt + 1] = (agc_state == AGC_FSM_UPDATE_ACCS) && (received_flits == (pkt+1)) && !feature_updated[2*pkt + 1];
        feature_aggregator_in_feature       [2*pkt + 1] = router_agc_pkt_q.data.bt_pl[31:0];
    end
end

// Multi-precision support
// --------------------------------------------------------------------------------------------

assign upsample = (agc_state == AGC_FSM_UPSAMPLE);

// AGC/Router interface
// ----------------------------------------------------

always_comb begin
    buffer_manager_pkt_dest_row = router_agc_pkt_q[$clog2(TOTAL_BUFFER_MANAGERS)-1:0];
    buffer_manager_pkt_dest_col = age_pkg::BUFFER_MANAGER_COLUMN;

    // Packets from Aggregation manager
    router_aggregation_core_ready = !(agc_state == AGC_FSM_UPDATE_ACCS) && !(agc_state == AGC_FSM_SEND_BUFF_MAN);
    router_aggregation_core_on = router_aggregation_core_ready;
    
    aggregation_core_router_valid = (agc_state == AGC_FSM_SEND_BUFF_MAN);
    
    bm_chosen_data = (sent_flits_counter == 'd0) ?  {upsampled_features[1],  upsampled_features[0]}
                    : (sent_flits_counter == 'd1) ? {upsampled_features[3],  upsampled_features[2]}
                    : (sent_flits_counter == 'd2) ? {upsampled_features[5],  upsampled_features[4]}
                    : (sent_flits_counter == 'd3) ? {upsampled_features[7],  upsampled_features[6]}
                    : (sent_flits_counter == 'd4) ? {upsampled_features[9],  upsampled_features[8]}
                    : (sent_flits_counter == 'd5) ? {upsampled_features[11], upsampled_features[10]}
                    : (sent_flits_counter == 'd6) ? {upsampled_features[13], upsampled_features[12]}
                    : (sent_flits_counter == 'd7) ? {upsampled_features[15], upsampled_features[14]}
                    : '0;

    aggregation_core_router_data.vc_id = '0; // TO DO: consider using both VCs?
    
    aggregation_core_router_data.flit_label = sent_flits_counter == '0 ? noc_params::HEAD
                                            : sent_flits_counter == 'd7 ? noc_params::TAIL
                                            : noc_params::BODY;

    aggregation_core_router_data.data.bt_pl = {buffer_manager_pkt_dest_col, buffer_manager_pkt_dest_row,
                                                x_coord, y_coord, // source node coordinates
                                                bm_chosen_data };
end

// Nodeslot allocation
// --------------------------------------------

always_ff @(posedge core_clk or negedge resetn) begin
    if (!resetn) begin
        aggregation_core_free                    <= '1;
        nodeslot_allocation_nodeslot             <= '0;
        nodeslot_allocation_aggregation_function <= top_pkg::SUM;
    
    // Sent last packet to Buffer Manager: free AGC
    end else if ((agc_state == AGC_FSM_WAIT_DRAIN) && (agc_state_n == AGC_FSM_IDLE)) begin
        aggregation_core_free                    <= '1;
        nodeslot_allocation_nodeslot             <= '0;
        nodeslot_allocation_aggregation_function <= top_pkg::SUM;

    // Allocation packet head = drop AGC free flag
    end else if ((agc_state == AGC_FSM_IDLE) && (agc_state_n == AGC_FSM_NODESLOT_ALLOCATION)) begin 
        aggregation_core_free                    <= '0;
        
    // Allocation packet tail: take nodeslot and aggregation function
    end else if ((agc_state == AGC_FSM_NODESLOT_ALLOCATION) && (agc_state_n == AGC_FSM_WAIT_FEATURE_HEAD)) begin
        nodeslot_allocation_nodeslot             <= router_aggregation_core_data.data.bt_pl [$clog2(top_pkg::MAX_NODESLOT_COUNT)-1:0];
        
        // potentially read from NSB regbank instead, indexed by nodeslot_allocation_nodeslot?
        nodeslot_allocation_aggregation_function <= router_aggregation_core_data.data.bt_pl [ALLOCATION_PKT_AGGR_FUNC_OFFSET + $bits(top_pkg::AGGREGATION_FUNCTION_e) - 1 : ALLOCATION_PKT_AGGR_FUNC_OFFSET] == 2'd0 ? top_pkg::SUM
                                                : router_aggregation_core_data.data.bt_pl [ALLOCATION_PKT_AGGR_FUNC_OFFSET + $bits(top_pkg::AGGREGATION_FUNCTION_e) - 1 : ALLOCATION_PKT_AGGR_FUNC_OFFSET] == 2'd1 ? top_pkg::MEAN
                                                : router_aggregation_core_data.data.bt_pl [ALLOCATION_PKT_AGGR_FUNC_OFFSET + $bits(top_pkg::AGGREGATION_FUNCTION_e) - 1 : ALLOCATION_PKT_AGGR_FUNC_OFFSET] == 2'd2 ? top_pkg::RESERVED
                                                : RESERVED2;

    end
end


endmodule