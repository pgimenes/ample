
import top_pkg::*;
import node_scoreboard_pkg::*;

module node_scoreboard #(
    parameter AXIL_ADDR_WIDTH = 32,
    parameter NODESLOT_COUNT = 64
) (
    input logic core_clk,
    input logic resetn,

    input  logic regbank_clk,
    input  logic regbank_resetn,

    // Regbank Slave AXI interface
    input  logic [AXIL_ADDR_WIDTH-1:0]                          s_axi_awaddr,
    input  logic [2:0]                                          s_axi_awprot,
    input  logic                                                s_axi_awvalid,
    output logic                                                s_axi_awready,
    input  logic [31:0]                                         s_axi_wdata,
    input  logic [3:0]                                          s_axi_wstrb,
    input  logic                                                s_axi_wvalid,
    output logic                                                s_axi_wready,
    input  logic [AXIL_ADDR_WIDTH-1:0]                          s_axi_araddr,
    input  logic [2:0]                                          s_axi_arprot,
    input  logic                                                s_axi_arvalid,
    output logic                                                s_axi_arready,
    output logic [31:0]                                         s_axi_rdata,
    output logic [1:0]                                          s_axi_rresp,
    output logic                                                s_axi_rvalid,
    input  logic                                                s_axi_rready,
    output logic [1:0]                                          s_axi_bresp,
    output logic                                                s_axi_bvalid,
    input  logic                                                s_axi_bready,

    // Controller -> Aggregation Engine Interface
    output logic                                                nsb_age_req_valid,
    input  logic                                                nsb_age_req_ready,
    output NSB_AGE_REQ_t                                        nsb_age_req,
    input  logic                                                nsb_age_resp_valid, // valid only for now
    input  NSB_AGE_RESP_t                                       nsb_age_resp,

    // Controller -> Transformation Engine Interface
    output logic                                                nsb_fte_req_valid,
    input  logic                                                nsb_fte_req_ready,
    output NSB_FTE_REQ_t                                        nsb_fte_req,
    input  logic                                                nsb_fte_resp_valid, // valid only for now
    input  NSB_FTE_RESP_t                                       nsb_fte_resp,

    // Controller -> Prefetcher Interface
    output logic                                                nsb_prefetcher_req_valid,
    input  logic                                                nsb_prefetcher_req_ready,
    output NSB_PREF_REQ_t                                       nsb_prefetcher_req,
    input  logic                                                nsb_prefetcher_resp_valid, // valid only for now
    input  NSB_PREF_RESP_t                                      nsb_prefetcher_resp
);

parameter AXI_ADDRESS_MSB_BITS = AXI_ADDRESS_WIDTH % 32;

// ==================================================================================================================================================
// Declarations
// ==================================================================================================================================================

// Regbank
// ------------------------------------------------------------

// Host Control
logic ctrl_fetch_layer_weights_strobe;                                  // strobe signal for register 'CTRL_FETCH_LAYER_WEIGHTS' (pulsed when the register is written from the bus)
logic [0:0] ctrl_fetch_layer_weights_fetch;                             // value of field 'CTRL_FETCH_LAYER_WEIGHTS.FETCH'

logic ctrl_fetch_layer_weights_precision_strobe;
logic [1:0] ctrl_fetch_layer_weights_precision_value;

logic ctrl_fetch_layer_weights_done_strobe;                             // strobe signal for register 'CTRL_FETCH_LAYER_WEIGHTS_DONE' (pulsed when the register is read from the bus)
logic [0:0] ctrl_fetch_layer_weights_done_done;                         // value of field 'CTRL_FETCH_LAYER_WEIGHTS_DONE.DONE'

logic ctrl_fetch_layer_weights_done_ack_strobe;                         // strobe signal for register 'CTRL_FETCH_LAYER_WEIGHTS_DONE_ACK' (pulsed when the register is written from the bus)
logic [0:0] ctrl_fetch_layer_weights_done_ack_ack;                      // value of field 'CTRL_FETCH_LAYER_WEIGHTS_DONE_ACK.ACK'

// Layer Config
logic layer_config_valid_strobe;
logic [0:0] layer_config_valid_value;

logic layer_config_in_features_strobe;
logic [9:0] layer_config_in_features_count;
logic layer_config_out_features_strobe;
logic [9:0] layer_config_out_features_count;

logic layer_config_adjacency_list_address_lsb_strobe;
logic [31:0] layer_config_adjacency_list_address_lsb_lsb;
logic layer_config_adjacency_list_address_msb_strobe;
logic [1:0] layer_config_adjacency_list_address_msb_msb;
logic layer_config_in_messages_address_lsb_strobe;
logic [31:0] layer_config_in_messages_address_lsb_lsb;
logic layer_config_in_messages_address_msb_strobe;
logic [1:0] layer_config_in_messages_address_msb_msb;
logic layer_config_weights_address_lsb_strobe;                          // strobe signal for register 'LAYER_CONFIG_WEIGHTS_ADDRESS_LSB' (pulsed when the register is written from the bus)
logic [3:0] [31:0] layer_config_weights_address_lsb_lsb;                      // value of field 'LAYER_CONFIG_WEIGHTS_ADDRESS_LSB.LSB'
logic layer_config_weights_address_msb_strobe;                          // strobe signal for register 'LAYER_CONFIG_WEIGHTS_ADDRESS_MSB' (pulsed when the register is written from the bus)
logic [3:0] [1:0] layer_config_weights_address_msb_msb;                       // value of field 'LAYER_CONFIG_WEIGHTS_ADDRESS_MSB.MSB'
logic layer_config_out_messages_address_lsb_strobe;
logic [31:0] layer_config_out_messages_address_lsb_lsb;
logic layer_config_out_messages_address_msb_strobe;
logic [1:0] layer_config_out_messages_address_msb_msb;

// Nodeslots
logic [NODESLOT_COUNT-1:0] nsb_nodeslot_neighbour_count_strobe;                       // strobe signal for register 'NSB_NODESLOT_NEIGHBOUR_COUNT' (pulsed when the register is written from the bus)
logic [NODESLOT_COUNT-1:0] [19:0] nsb_nodeslot_neighbour_count_count;                 // value of field 'NSB_NODESLOT_NEIGHBOUR_COUNT.COUNT'
logic [NODESLOT_COUNT-1:0] nsb_nodeslot_node_id_strobe;                               // strobe signal for register 'NSB_NODESLOT_NODE_ID' (pulsed when the register is written from the bus)
logic [NODESLOT_COUNT-1:0] [19:0] nsb_nodeslot_node_id_id;                            // value of field 'NSB_NODESLOT_NODE_ID.ID'
logic [NODESLOT_COUNT-1:0] nsb_nodeslot_node_state_strobe;                            // strobe signal for register 'NSB_NODESLOT_NODE_STATE' (pulsed when the register is written from the bus)
logic [NODESLOT_COUNT-1:0] [3:0] nsb_nodeslot_node_state_state;                       // value of field 'NSB_NODESLOT_NODE_STATE.STATE'
logic [NODESLOT_COUNT-1:0] nsb_nodeslot_precision_strobe;                             // strobe signal for register 'NSB_NODESLOT_PRECISION' (pulsed when the register is written from the bus)
logic [NODESLOT_COUNT-1:0] [1:0] nsb_nodeslot_precision_precision;                    // value of field 'NSB_NODESLOT_PRECISION.PRECISION'
logic [NODESLOT_COUNT-1:0] nsb_nodeslot_adjacency_list_address_lsb_strobe;            // strobe signal for register 'NSB_NODESLOT_ADJACENCY_LIST_ADDRESS_LSB' (pulsed when the register is written from the bus)
logic [NODESLOT_COUNT-1:0] [31:0] nsb_nodeslot_adjacency_list_address_lsb_lsb;        // value of field 'NSB_NODESLOT_ADJACENCY_LIST_ADDRESS_LSB.LSB'
logic [NODESLOT_COUNT-1:0] nsb_nodeslot_adjacency_list_address_msb_strobe;            // strobe signal for register 'NSB_NODESLOT_ADJACENCY_LIST_ADDRESS_MSB' (pulsed when the register is written from the bus)
logic [NODESLOT_COUNT-1:0] [1:0] nsb_nodeslot_adjacency_list_address_msb_msb;         // value of field 'NSB_NODESLOT_ADJACENCY_LIST_ADDRESS_MSB.MSB'
logic [NODESLOT_COUNT-1:0] nsb_nodeslot_out_messages_address_lsb_strobe;              // strobe signal for register 'NSB_NODESLOT_OUT_MESSAGES_ADDRESS_LSB' (pulsed when the register is written from the bus)
logic [NODESLOT_COUNT-1:0] [31:0] nsb_nodeslot_out_messages_address_lsb_lsb;          // value of field 'NSB_NODESLOT_OUT_MESSAGES_ADDRESS_LSB.LSB'
logic [NODESLOT_COUNT-1:0] nsb_nodeslot_out_messages_address_msb_strobe;              // strobe signal for register 'NSB_NODESLOT_OUT_MESSAGES_ADDRESS_MSB' (pulsed when the register is written from the bus)
logic [NODESLOT_COUNT-1:0] [1:0] nsb_nodeslot_out_messages_address_msb_msb;           // value of field 'NSB_NODESLOT_OUT_MESSAGES_ADDRESS_MSB.MSB'
logic [NODESLOT_COUNT-1:0] nsb_nodeslot_aggregation_function_strobe;                  // strobe signal for register 'nsb_nodeslot_aggregation_function' (pulsed when the register is written from the bus)
logic [NODESLOT_COUNT-1:0] [1:0] nsb_nodeslot_aggregation_function_value;             // value of field 'nsb_nodeslot_aggregation_function.value'
logic [NODESLOT_COUNT-1:0] nsb_nodeslot_scale_factors_address_lsb_strobe;             // strobe signal for register 'nsb_nodeslot_scale_factors_address_lsb' (pulsed when the register is written from the bus)
logic [NODESLOT_COUNT-1:0] [31:0] nsb_nodeslot_scale_factors_address_lsb_value;       // value of field 'nsb_nodeslot_scale_factors_address_lsb.value'
logic [NODESLOT_COUNT-1:0] nsb_nodeslot_scale_factors_address_msb_strobe;             // strobe signal for register 'nsb_nodeslot_scale_factors_address_msb' (pulsed when the register is written from the bus)
logic [NODESLOT_COUNT-1:0] [1:0] nsb_nodeslot_scale_factors_address_msb_value;        // value of field 'nsb_nodeslot_scale_factors_address_msb.value'

logic nsb_config_aggregation_wait_count_strobe; // strobe signal for register 'NSB_CONFIG_AGGREGATION_WAIT_COUNT' (pulsed when the register is written from the bus)
logic [5:0] nsb_config_aggregation_wait_count_count; // value of field 'NSB_CONFIG_AGGREGATION_WAIT_COUNT.COUNT'
logic nsb_config_transformation_wait_count_strobe; // strobe signal for register 'NSB_CONFIG_TRANSFORMATION_WAIT_COUNT' (pulsed when the register is written from the bus)
logic [5:0] nsb_config_transformation_wait_count_count;// value of field 'NSB_CONFIG_TRANSFORMATION_WAIT_COUNT.COUNT'

logic [NODESLOT_COUNT-1:0] nsb_nodeslot_allocated_fetch_tag_strobe;
logic [NODESLOT_COUNT-1:0] [5:0] nsb_nodeslot_allocated_fetch_tag_fetch_tag;

// STATUS
logic [31:0] status_nodeslots_empty_mask_0_value;
logic [31:0] status_nodeslots_empty_mask_1_value;
logic [31:0] status_nodeslots_empty_mask_2_value;
logic [31:0] status_nodeslots_empty_mask_3_value;
logic [31:0] status_nodeslots_empty_mask_4_value;
logic [31:0] status_nodeslots_empty_mask_5_value;
logic [31:0] status_nodeslots_empty_mask_6_value;
logic [31:0] status_nodeslots_empty_mask_7_value;

// Other
// ------------------------------------------------------------

logic [NODESLOT_COUNT-1:0] [3:0] nodeslot_state, nodeslot_state_n; // not defined as enum to avoid VRFC 10-2649
logic [NODESLOT_COUNT-1:0] nsb_nodeslot_config_make_valid_value;

// Done masks
logic [NODESLOT_COUNT-1:0] fetch_nb_list_resp_received;
logic [NODESLOT_COUNT-1:0] fetch_scale_factors_resp_received;
logic [NODESLOT_COUNT-1:0] fetch_nbs_resp_received;
logic [NODESLOT_COUNT-1:0] aggregation_done;
logic [NODESLOT_COUNT-1:0] transformation_done;

// State masks
logic [NODESLOT_COUNT-1:0] nodeslots_waiting_nb_list_fetch;
logic [NODESLOT_COUNT-1:0] nodeslots_waiting_neighbour_fetch;
logic [NODESLOT_COUNT-1:0] nodeslots_waiting_scale_factor_fetch;

logic [NODESLOT_COUNT-1:0] nodeslots_waiting_prefetcher;
logic [NODESLOT_COUNT-1:0] nodeslots_waiting_aggregation;
logic [NODESLOT_COUNT-1:0] nodeslots_waiting_transformation;

logic accepting_prefetch_request;
logic accepting_aggregation_request;
logic accepting_transformation_request;

logic [top_pkg::PRECISION_COUNT-1:0] [5:0] aggregation_buffer_population_count;

logic [NODESLOT_COUNT-1:0]         prefetcher_arbiter_grant_oh;
logic [$clog2(NODESLOT_COUNT)-1:0] prefetcher_arbiter_grant_bin;
logic [$clog2(NODESLOT_COUNT)-1:0] age_arbiter_grant_bin;

logic [top_pkg::PRECISION_COUNT-1:0] weights_fetched;

logic                     waiting_weights_fetch_req;
top_pkg::NODE_PRECISION_e active_weights_fetch_precision;

logic [top_pkg::PRECISION_COUNT-1:0] aggregation_buffer_waiting_transformation;
logic [$clog2(top_pkg::PRECISION_COUNT)-1:0] aggregation_buffer_precision_arb_bin;

// temporary fix
logic [31:0] status_nodeslots_empty_mask_0_value;
logic [31:0] status_nodeslots_empty_mask_1_value;
logic [31:0] status_nodeslots_empty_mask_2_value;
logic [31:0] status_nodeslots_empty_mask_3_value;
logic [31:0] status_nodeslots_empty_mask_4_value;
logic [31:0] status_nodeslots_empty_mask_5_value;
logic [31:0] status_nodeslots_empty_mask_6_value;
logic [31:0] status_nodeslots_empty_mask_7_value;

// ==================================================================================================================================================
// Instances
// ==================================================================================================================================================

// Regbank
// ------------------------------------------------------------
node_scoreboard_regbank_wrapper node_scoreboard_regbank_i (
    // Clock and Reset (SLOW)
    .axi_aclk                       (regbank_clk),
    .axi_aresetn                    (regbank_resetn),

    // Clock and Reset (FAST)
    .fast_clk                       (core_clk),
    .fast_resetn                    (resetn),

    // AXI Write Address Channel
    .s_axi_awaddr,
    .s_axi_awprot,
    .s_axi_awvalid,
    .s_axi_awready,
    .s_axi_wdata,
    .s_axi_wstrb,
    .s_axi_wvalid,
    .s_axi_wready,
    .s_axi_araddr,
    .s_axi_arprot,
    .s_axi_arvalid,
    .s_axi_arready,
    .s_axi_rdata,
    .s_axi_rresp,
    .s_axi_rvalid,
    .s_axi_rready,
    .s_axi_bresp,
    .s_axi_bvalid,
    .s_axi_bready,

    // User Ports
    .layer_config_in_features_count,
    .layer_config_out_features_count,

    .layer_config_adjacency_list_address_lsb_lsb,
    .layer_config_adjacency_list_address_msb_msb,
    .layer_config_in_messages_address_lsb_lsb,
    .layer_config_in_messages_address_msb_msb,
    .layer_config_weights_address_lsb_lsb,
    .layer_config_weights_address_msb_msb,
    .layer_config_out_messages_address_lsb_lsb,
    .layer_config_out_messages_address_msb_msb,

    .ctrl_fetch_layer_weights_fetch,
    .ctrl_fetch_layer_weights_done_done,
    .ctrl_fetch_layer_weights_done_ack_ack,
    .ctrl_fetch_layer_weights_precision_value,
    .nsb_nodeslot_neighbour_count_count,
    .nsb_nodeslot_node_id_id,
    .nsb_nodeslot_node_state_state,
    .nsb_nodeslot_precision_precision,
    .nsb_nodeslot_adjacency_list_address_lsb_lsb,
    .nsb_nodeslot_adjacency_list_address_msb_msb,
    .nsb_nodeslot_out_messages_address_lsb_lsb,
    .nsb_nodeslot_out_messages_address_msb_msb,
    .nsb_nodeslot_scale_factors_address_lsb_value,
    .nsb_nodeslot_scale_factors_address_msb_value,
    .nsb_config_aggregation_wait_count_count,
    .nsb_config_transformation_wait_count_count,
    .status_nodeslots_empty_mask_0_value,
    .status_nodeslots_empty_mask_1_value,
    .status_nodeslots_empty_mask_2_value,
    .status_nodeslots_empty_mask_3_value,
    .status_nodeslots_empty_mask_4_value,
    .status_nodeslots_empty_mask_5_value,
    .status_nodeslots_empty_mask_6_value,
    .status_nodeslots_empty_mask_7_value,
    .*
);

// ==================================================================================================================================================
// Logic
// ==================================================================================================================================================

assign accepting_prefetch_request = nsb_prefetcher_req_valid && nsb_prefetcher_req_ready;
assign accepting_aggregation_request = nsb_age_req_valid && nsb_age_req_ready;

assign accepting_transformation_request = nsb_fte_req_valid && nsb_fte_req_ready;

// Per-Nodeslot Logic
// ------------------------------------------------------------

for (genvar nodeslot = 0; nodeslot < NODESLOT_COUNT; nodeslot = nodeslot + 1) begin : per_nodeslot_logic

    assign nodeslot_state[nodeslot] = nsb_nodeslot_node_state_state[nodeslot];

    always_ff @( posedge core_clk or negedge resetn) begin
        if (!resetn) begin
            nsb_nodeslot_node_state_state     [nodeslot] <= node_scoreboard_pkg::EMPTY;
            fetch_nb_list_resp_received       [nodeslot] <= '0;
            fetch_scale_factors_resp_received [nodeslot] <= '0;
            fetch_nbs_resp_received           [nodeslot] <= '0;
            aggregation_done                  [nodeslot] <= '0;
            transformation_done               [nodeslot] <= '0;

        end else if (nodeslot_state_n[nodeslot] == node_scoreboard_pkg::EMPTY) begin
            nsb_nodeslot_node_state_state[nodeslot] <= nodeslot_state_n[nodeslot];

            // Update done mask from prefetcher response
            fetch_nb_list_resp_received       [nodeslot] <= '0;
            fetch_scale_factors_resp_received [nodeslot] <= '0;
            fetch_nbs_resp_received           [nodeslot] <= '0;
            aggregation_done                  [nodeslot] <= '0;
            transformation_done               [nodeslot] <= '0;

        end else begin
            nsb_nodeslot_node_state_state[nodeslot] <= nodeslot_state_n[nodeslot];

            if ((nodeslot_state[nodeslot] == node_scoreboard_pkg::FETCH_NB_LIST) && nsb_prefetcher_resp_valid && (nsb_prefetcher_resp.nodeslot == nodeslot) && (nsb_prefetcher_resp.response_type == top_pkg::ADJACENCY_LIST)) begin
                fetch_nb_list_resp_received[nodeslot]         <= 1'b1;

            end else if ((nodeslot_state[nodeslot] == node_scoreboard_pkg::FETCH_SCALE_FACTORS) && nsb_prefetcher_resp_valid && (nsb_prefetcher_resp.nodeslot == nodeslot) && (nsb_prefetcher_resp.response_type == top_pkg::SCALE_FACTOR)) begin
                fetch_scale_factors_resp_received[nodeslot]   <= 1'b1;

            end else if ((nodeslot_state[nodeslot] == node_scoreboard_pkg::FETCH_NEIGHBOURS) && nsb_prefetcher_resp_valid && (nsb_prefetcher_resp.nodeslot == nodeslot) && (nsb_prefetcher_resp.response_type == top_pkg::MESSAGES)) begin
                fetch_nbs_resp_received[nodeslot]             <= 1'b1;

            end else if ((nodeslot_state[nodeslot] == node_scoreboard_pkg::AGGREGATION) && nsb_age_resp_valid && (nsb_age_resp.nodeslot == nodeslot)) begin
                aggregation_done[nodeslot]                    <= 1'b1;

            end else if ((nodeslot_state[nodeslot] == node_scoreboard_pkg::TRANSFORMATION) && nsb_fte_resp_valid && nsb_fte_resp.nodeslots[nodeslot]) begin
                transformation_done[nodeslot]                    <= 1'b1;
            end
        end
    end

    // Nodeslot State Machine
    // ------------------------------------------------------------

    always_comb begin
        nodeslot_state_n[nodeslot] = node_scoreboard_pkg::EMPTY;

        case (nodeslot_state[nodeslot])
            node_scoreboard_pkg::EMPTY: begin
                nodeslot_state_n[nodeslot] = nsb_nodeslot_config_make_valid_value[nodeslot] ? node_scoreboard_pkg::PROG_DONE
                                    : node_scoreboard_pkg::EMPTY;
            end

            node_scoreboard_pkg::PROG_DONE: begin
                nodeslot_state_n[nodeslot] = accepting_prefetch_request && (nsb_prefetcher_req.nodeslot == nodeslot) && (nsb_prefetcher_req.req_opcode == top_pkg::ADJACENCY_LIST) ? node_scoreboard_pkg::FETCH_NB_LIST
                                    : node_scoreboard_pkg::PROG_DONE;
            end

            node_scoreboard_pkg::FETCH_NB_LIST: begin // move when resp received and pref ready
                nodeslot_state_n[nodeslot] = fetch_nb_list_resp_received[nodeslot] && accepting_prefetch_request && (nsb_prefetcher_req.nodeslot == nodeslot) && (nsb_prefetcher_req.req_opcode == SCALE_FACTOR) ? node_scoreboard_pkg::FETCH_SCALE_FACTORS
                                    : node_scoreboard_pkg::FETCH_NB_LIST;
            end

            node_scoreboard_pkg::FETCH_SCALE_FACTORS: begin // move when resp received and pref ready
                nodeslot_state_n[nodeslot] = fetch_scale_factors_resp_received[nodeslot] && accepting_prefetch_request && (nsb_prefetcher_req.nodeslot == nodeslot) && (nsb_prefetcher_req.req_opcode == MESSAGES) ? node_scoreboard_pkg::FETCH_NEIGHBOURS
                                    : node_scoreboard_pkg::FETCH_SCALE_FACTORS;
            end

            node_scoreboard_pkg::FETCH_NEIGHBOURS: begin // move when resp received and age ready
                nodeslot_state_n[nodeslot] = fetch_nbs_resp_received[nodeslot] && accepting_aggregation_request && (nsb_age_req.nodeslot == nodeslot) ? node_scoreboard_pkg::AGGREGATION
                                    : node_scoreboard_pkg::FETCH_NEIGHBOURS;
            end

            node_scoreboard_pkg::AGGREGATION: begin
                nodeslot_state_n[nodeslot] = aggregation_done[nodeslot] && accepting_transformation_request && nsb_fte_req.nodeslots [nodeslot] ? node_scoreboard_pkg::TRANSFORMATION
                                    : node_scoreboard_pkg::AGGREGATION;
            end

            node_scoreboard_pkg::TRANSFORMATION: begin
                nodeslot_state_n[nodeslot] = nsb_fte_resp_valid && nsb_fte_resp.nodeslots[nodeslot] ? node_scoreboard_pkg::EMPTY
                                    : node_scoreboard_pkg::TRANSFORMATION;
            end

            node_scoreboard_pkg::PASS: begin // TO DO: implement (MS4)
                nodeslot_state_n[nodeslot] = node_scoreboard_pkg::EMPTY;
            end

            node_scoreboard_pkg::HALT: begin // TO DO: implement (MS5)
                nodeslot_state_n[nodeslot] = node_scoreboard_pkg::EMPTY;
            end

        endcase
    end

    // State masks for request logic
    assign nodeslots_waiting_nb_list_fetch       [nodeslot] = (nodeslot_state[nodeslot] == node_scoreboard_pkg::PROG_DONE);
    assign nodeslots_waiting_scale_factor_fetch  [nodeslot] = (nodeslot_state[nodeslot] == node_scoreboard_pkg::FETCH_NB_LIST) && fetch_nb_list_resp_received[nodeslot];
    assign nodeslots_waiting_neighbour_fetch     [nodeslot] = (nodeslot_state[nodeslot] == node_scoreboard_pkg::FETCH_SCALE_FACTORS) && fetch_scale_factors_resp_received[nodeslot];
    assign nodeslots_waiting_prefetcher          [nodeslot] = nodeslots_waiting_nb_list_fetch[nodeslot] || nodeslots_waiting_neighbour_fetch[nodeslot] || nodeslots_waiting_scale_factor_fetch[nodeslot];

    assign nodeslots_waiting_aggregation         [nodeslot] = (nodeslot_state[nodeslot] == node_scoreboard_pkg::FETCH_NEIGHBOURS) && fetch_nbs_resp_received[nodeslot];
    assign nodeslots_waiting_transformation      [nodeslot] = (nodeslot_state[nodeslot] == node_scoreboard_pkg::AGGREGATION) && aggregation_done[nodeslot];

    // Read-only status flags
    always_ff @(posedge core_clk or negedge resetn) begin
        if (!resetn) begin
            nsb_nodeslot_allocated_fetch_tag_fetch_tag [nodeslot] <= '0;
        
        // Reset flags if clearing nodeslot
        end else if (nodeslot_state_n[nodeslot] == node_scoreboard_pkg::EMPTY) begin
            nsb_nodeslot_allocated_fetch_tag_fetch_tag [nodeslot] <= '0;
            
        end else if (nsb_prefetcher_resp_valid && (nsb_prefetcher_resp.response_type == ADJACENCY_LIST) && (nsb_prefetcher_resp.nodeslot == nodeslot)) begin
                // TO DO: update this to use dynamically allocated fetch tags (MS3)
                nsb_nodeslot_allocated_fetch_tag_fetch_tag[nodeslot] <= nsb_prefetcher_resp.allocated_fetch_tag;
        end
    end

    assign nsb_fte_req.nodeslots [nodeslot] = nodeslots_waiting_transformation [nodeslot] && aggregation_buffer_waiting_transformation[nsb_nodeslot_precision_precision[nodeslot]];

    if (nodeslot > 223) begin
        assign status_nodeslots_empty_mask_7_value [nodeslot % 32] = (nodeslot_state[nodeslot] == node_scoreboard_pkg::EMPTY);
    end else if (nodeslot > 191) begin
        assign status_nodeslots_empty_mask_6_value [nodeslot % 32] = (nodeslot_state[nodeslot] == node_scoreboard_pkg::EMPTY);
    end else if (nodeslot > 159) begin
        assign status_nodeslots_empty_mask_5_value [nodeslot % 32] = (nodeslot_state[nodeslot] == node_scoreboard_pkg::EMPTY);
    end else if (nodeslot > 127) begin
        assign status_nodeslots_empty_mask_4_value [nodeslot % 32] = (nodeslot_state[nodeslot] == node_scoreboard_pkg::EMPTY);
    end else if (nodeslot > 95) begin
        assign status_nodeslots_empty_mask_3_value [nodeslot % 32] = (nodeslot_state[nodeslot] == node_scoreboard_pkg::EMPTY);
    end else if (nodeslot > 63) begin
        assign status_nodeslots_empty_mask_2_value [nodeslot % 32] = (nodeslot_state[nodeslot] == node_scoreboard_pkg::EMPTY);
    end else if (nodeslot > 31) begin
        assign status_nodeslots_empty_mask_1_value [nodeslot % 32] = (nodeslot_state[nodeslot] == node_scoreboard_pkg::EMPTY);
    end else begin
        assign status_nodeslots_empty_mask_0_value [nodeslot % 32] = (nodeslot_state[nodeslot] == node_scoreboard_pkg::EMPTY);
    end

end : per_nodeslot_logic

// Layer weights fetching logic
// ------------------------------------------------------------

always_ff @(posedge core_clk or negedge resetn) begin
    if (!resetn) begin
        waiting_weights_fetch_req <= '0;
        ctrl_fetch_layer_weights_done_done <= '0;
        active_weights_fetch_precision <= top_pkg::FLOAT_32;

    end else if (ctrl_fetch_layer_weights_fetch) begin
        waiting_weights_fetch_req <= '1;
        ctrl_fetch_layer_weights_done_done <= '0;

    end else if (nsb_prefetcher_req_valid && nsb_prefetcher_req.req_opcode == top_pkg::WEIGHTS) begin
        waiting_weights_fetch_req <= '0;
        ctrl_fetch_layer_weights_done_done <= '0;
        active_weights_fetch_precision <= nsb_prefetcher_req.nodeslot_precision;

    end else if (nsb_prefetcher_resp_valid && nsb_prefetcher_resp.response_type == top_pkg::WEIGHTS) begin
        waiting_weights_fetch_req <= '0;
        ctrl_fetch_layer_weights_done_done <= '1;
        
    end else if (ctrl_fetch_layer_weights_done_ack_ack) begin
        waiting_weights_fetch_req <= '0;
        ctrl_fetch_layer_weights_done_done <= '0;
        
    end
end

// Precision-wise logic
// ------------------------------------------------------------

for (genvar precision = 0; precision < top_pkg::PRECISION_COUNT; precision++) begin
    always_ff @(posedge core_clk or negedge resetn) begin
        if (!resetn) begin
            weights_fetched [precision] <= '0;

        end else if (nsb_prefetcher_resp_valid && nsb_prefetcher_resp.response_type == top_pkg::WEIGHTS && (active_weights_fetch_precision == precision)) begin
            weights_fetched [precision] <= '1;

        end
    end

    // Population counts
    always_ff @(posedge core_clk or negedge resetn) begin
        if (!resetn) begin
            aggregation_buffer_population_count    [precision] <= '0;

        // AGE sending aggregation response
        end else if (nsb_age_resp_valid && (nsb_nodeslot_precision_precision[nsb_age_resp.nodeslot] == precision)) begin
                aggregation_buffer_population_count [precision] <= aggregation_buffer_population_count [precision] + 1'b1;

        // FTE accepting transformation request
        end else if (accepting_transformation_request && (nsb_fte_req.precision == precision)) begin
            aggregation_buffer_population_count [precision] <= '0;
        end
    end

    assign aggregation_buffer_waiting_transformation [precision] = (aggregation_buffer_population_count[precision] >= nsb_config_aggregation_wait_count_count) && weights_fetched [precision] && layer_config_valid_value;
end


// Prefetcher requests
// ------------------------------------------------------------

rr_arbiter #(
    .NUM_REQUESTERS     (NODESLOT_COUNT)
) prefetcher_req_arb (
    .clk                (core_clk),
    .resetn             (resetn),
    .request            (nodeslots_waiting_prefetcher),
    .update_lru         (nsb_prefetcher_req_valid && nsb_prefetcher_req_ready),
    .grant_oh           (prefetcher_arbiter_grant_oh),
    .grant_bin          (prefetcher_arbiter_grant_bin)
);

always_comb begin : nsb_prefetcher_req_logic
    nsb_prefetcher_req_valid         = |nodeslots_waiting_prefetcher || waiting_weights_fetch_req;

    nsb_prefetcher_req.req_opcode    = waiting_weights_fetch_req ? top_pkg::WEIGHTS
                                        : |(nodeslots_waiting_nb_list_fetch & prefetcher_arbiter_grant_oh) ? top_pkg::ADJACENCY_LIST
                                        : |(nodeslots_waiting_scale_factor_fetch & prefetcher_arbiter_grant_oh) ? top_pkg::SCALE_FACTOR
                                        : |(nodeslots_waiting_neighbour_fetch & prefetcher_arbiter_grant_oh) ? top_pkg::MESSAGES
                                        : top_pkg::FETCH_RESERVED;

    nsb_prefetcher_req.nodeslot      = prefetcher_arbiter_grant_bin;
    
    nsb_prefetcher_req.start_address = nsb_prefetcher_req.req_opcode == top_pkg::WEIGHTS ? {layer_config_weights_address_msb_msb [ctrl_fetch_layer_weights_precision_value], layer_config_weights_address_lsb_lsb [ctrl_fetch_layer_weights_precision_value]}
                                    : nsb_prefetcher_req.req_opcode == top_pkg::ADJACENCY_LIST ? {nsb_nodeslot_adjacency_list_address_msb_msb[prefetcher_arbiter_grant_bin], nsb_nodeslot_adjacency_list_address_lsb_lsb[prefetcher_arbiter_grant_bin]}
                                    : nsb_prefetcher_req.req_opcode == top_pkg::SCALE_FACTOR ? {nsb_nodeslot_scale_factors_address_msb_value[prefetcher_arbiter_grant_bin], nsb_nodeslot_scale_factors_address_lsb_value[prefetcher_arbiter_grant_bin]}
                                    : '0;
    

    nsb_prefetcher_req.neighbour_count = nsb_nodeslot_neighbour_count_count[prefetcher_arbiter_grant_bin];

    nsb_prefetcher_req.nodeslot_precision = nsb_prefetcher_req.req_opcode == WEIGHTS ? top_pkg::NODE_PRECISION_e'(ctrl_fetch_layer_weights_precision_value)
                                        : top_pkg::NODE_PRECISION_e'(nsb_nodeslot_precision_precision[prefetcher_arbiter_grant_bin]);

    nsb_prefetcher_req.in_features  = layer_config_in_features_count;
    nsb_prefetcher_req.out_features = layer_config_out_features_count;
end

// Aggregation requests
// ------------------------------------------------------------

rr_arbiter #(
    .NUM_REQUESTERS     (NODESLOT_COUNT)
) age_req_arb (
    .clk                (core_clk),
    .resetn             (resetn),
    .request            (nodeslots_waiting_aggregation),
    .update_lru         (accepting_aggregation_request),
    .grant_oh           (),
    .grant_bin          (age_arbiter_grant_bin)
);

always_comb begin
    nsb_age_req_valid                = |nodeslots_waiting_aggregation;
    nsb_age_req.nodeslot             = age_arbiter_grant_bin;
    nsb_age_req.node_id              = nsb_nodeslot_node_id_id [age_arbiter_grant_bin];
    nsb_age_req.node_precision       = NODE_PRECISION_e'(nsb_nodeslot_precision_precision[age_arbiter_grant_bin]);
    nsb_age_req.aggregation_function = AGGREGATION_FUNCTION_e'(nsb_nodeslot_aggregation_function_value[age_arbiter_grant_bin]);
    nsb_age_req.fetch_tag            = nsb_nodeslot_allocated_fetch_tag_fetch_tag[age_arbiter_grant_bin];
end

// Transformation requests
// ------------------------------------------------------------

rr_arbiter #(
    .NUM_REQUESTERS     (top_pkg::PRECISION_COUNT)
) aggregation_buffer_precision_arb (
    .clk                (core_clk),
    .resetn             (resetn),
    .request            (aggregation_buffer_waiting_transformation),
    .update_lru         (accepting_transformation_request),
    .grant_oh           (),
    .grant_bin          (aggregation_buffer_precision_arb_bin)
);

always_comb begin
    nsb_fte_req_valid     = |aggregation_buffer_waiting_transformation;
    nsb_fte_req.precision = top_pkg::NODE_PRECISION_e'(aggregation_buffer_precision_arb_bin);
end

// ==================================================================================================================================================
// Assertions
// ==================================================================================================================================================

endmodule