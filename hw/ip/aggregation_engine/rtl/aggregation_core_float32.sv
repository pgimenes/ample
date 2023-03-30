import top_pkg::*;
import noc_params::*;

module aggregation_core_float32 #(
    parameter FEATURE_COUNT = 16,
    parameter DATA_WIDTH = 32
) (
    input logic core_clk,
    input logic resetn,

    // Message Channel -> Router
    input  logic  aggregation_core_router_on,
    output logic  aggregation_core_router_valid,
    input  logic  aggregation_core_router_ready,
    output flit_t aggregation_core_router_data,

    // Router -> Message Channel
    output logic  router_aggregation_core_on,
    input  logic  router_aggregation_core_valid,
    output logic  router_aggregation_core_ready,
    input  flit_t router_aggregation_core_data
);

typedef enum logic [2:0] {
    AGC_FSM_IDLE                = 2'd0,
    AGC_FSM_NODESLOT_ALLOCATION = 2'd1,
    AGC_FSM_WAIT_FEATURE_PKT    = 2'd2,
    AGC_FSM_UPDATE_ACCS         = 2'd3,
    AGC_FSM_DONE                = 2'd4
} aggregation_core_fsm_e;

aggregation_core_fsm_e agc_state, agc_state_n;
age_pkg::axi_packet_fsm_e feature_packet_state, feature_packet_state_n;
parameter ALLOCATION_PKT_AGGR_FUNC_OFFSET = $clog2(top_pkg::MAX_NODESLOT_COUNT);

// Payloads from nodeslot allocation packet
logic [$clog2(top_pkg::MAX_NODESLOT_COUNT)-1:0] nodeslot_allocation_nodeslot;
top_pkg::AGGREGATION_FUNCTION_e                 nodeslot_allocation_aggregation_function;

logic [FEATURE_COUNT-1:0] [DATA_WIDTH-1:0] features;

logic [FEATURE_COUNT-1:0]                  feature_aggregator_in_feature_valid;
logic [FEATURE_COUNT-1:0]                  feature_aggregator_in_feature_ready;
logic [FEATURE_COUNT-1:0] [DATA_WIDTH-1:0] feature_aggregator_in_feature;
logic [FEATURE_COUNT-1:0]                  feature_aggregator_reset_accumulator;

for (genvar feature = 0; feature < FEATURE_COUNT; feature = feature + 1) begin
    feature_aggregator #(
        .DATA_WIDTH(DATA_WIDTH)
    ) feature_aggregator_i (
        .core_clk,
        .resetn,
        .in_feature_valid              (feature_aggregator_in_feature_valid      [feature]),
        .in_feature_ready              (feature_aggregator_in_feature_ready      [feature]),
        .in_feature                    (feature_aggregator_in_feature            [feature]),
        .reset_accumulator             (feature_aggregator_reset_accumulator     [feature]),
        .aggregation_function_sel      (nodeslot_allocation_aggregation_function [feature]),
        .accumulator                   (features                                 [feature])
    );
end

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
        agc_state_n <= router_aggregation_core_valid && (router_aggregation_core_data.flit_label == noc_params::HEAD) ? AGC_FSM_NODESLOT_ALLOCATION : AGC_FSM_IDLE;
    end

    AGC_FSM_NODESLOT_ALLOCATION: begin
        agc_state_n <= router_aggregation_core_valid && (router_aggregation_core_data.flit_label == noc_params::TAIL) ? AGC_FSM_NODESLOT_ALLOCATION : AGC_FSM_IDLE;
    end

    AGC_FSM_WAIT_FEATURE_PKT: begin
        
    end
    
    AGC_FSM_UPDATE_ACCS: begin
        
    end
    
    AGC_FSM_DONE: begin
        
    end

    default: agc_state_n = AGC_FSM_IDLE;

    endcase
end

// Nodeslot allocation
// --------------------------------------------

always_ff @(posedge core_clk or negedge resetn) begin
    if (!resetn) begin
        nodeslot_allocation_nodeslot             <= '0;
        nodeslot_allocation_aggregation_function <= top_pkg::SUM;
    
    end else if (AGC_FSM_IDLE && router_aggregation_core_valid && (router_aggregation_core_data.flit_label == noc_params::HEAD)) begin 
        nodeslot_allocation_nodeslot             <= router_aggregation_core_data.head_data [$clog2(top_pkg::MAX_NODESLOT_COUNT)-1:0];
        nodeslot_allocation_aggregation_function <= router_aggregation_core_data.head_data [ALLOCATION_PKT_AGGR_FUNC_OFFSET+$bits(top_pkg::AGGREGATION_FUNCTION_e) - 1 : ALLOCATION_PKT_AGGR_FUNC_OFFSET];
    end
end

endmodule