
import top_pkg::*;

module feature_transformation_engine #(
    parameter FLOAT_WIDTH = 32,
    parameter AXI_ADDR_WIDTH = 32,
    parameter MATRIX_N = 16
) (
    input logic                                                                                       core_clk,
    input logic                                                                                       resetn,

    input logic regbank_clk,
    input logic regbank_resetn,

    // Regbank Slave AXI interface
    input  logic [AXI_ADDR_WIDTH-1:0]                                                                 s_axi_awaddr,
    input  logic [2:0]                                                                                s_axi_awprot,
    input  logic                                                                                      s_axi_awvalid,
    output logic                                                                                      s_axi_awready,
    input  logic [31:0]                                                                               s_axi_wdata,
    input  logic [3:0]                                                                                s_axi_wstrb,
    input  logic                                                                                      s_axi_wvalid,
    output logic                                                                                      s_axi_wready,
    input  logic [AXI_ADDR_WIDTH-1:0]                                                                 s_axi_araddr,
    input  logic [2:0]                                                                                s_axi_arprot,
    input  logic                                                                                      s_axi_arvalid,
    output logic                                                                                      s_axi_arready,
    output logic [31:0]                                                                               s_axi_rdata,
    output logic [1:0]                                                                                s_axi_rresp,
    output logic                                                                                      s_axi_rvalid,
    input  logic                                                                                      s_axi_rready,
    output logic [1:0]                                                                                s_axi_bresp,
    output logic                                                                                      s_axi_bvalid,
    input  logic                                                                                      s_axi_bready,

    // Node Scoreboard -> Transformation Engine Interface
    input  logic                                                                                      nsb_fte_req_valid,
    output logic                                                                                      nsb_fte_req_ready,
    input  NSB_FTE_REQ_t                                                                              nsb_fte_req,

    output logic                                                                                      nsb_fte_resp_valid, // valid only for now
    output NSB_FTE_RESP_t                                                                             nsb_fte_resp,

    // Aggregation Buffer Interface
    input  logic [top_pkg::AGGREGATION_BUFFER_SLOTS-1:0] [top_pkg::NODE_ID_WIDTH-1:0]                 aggregation_buffer_node_id,
    output logic [top_pkg::AGGREGATION_BUFFER_SLOTS-1:0]                                              aggregation_buffer_pop,
    input  logic [top_pkg::AGGREGATION_BUFFER_SLOTS-1:0]                                              aggregation_buffer_out_feature_valid,
    input  logic [top_pkg::AGGREGATION_BUFFER_SLOTS-1:0] [top_pkg::AGGREGATION_BUFFER_READ_WIDTH-1:0] aggregation_buffer_out_feature,
    input  logic [top_pkg::AGGREGATION_BUFFER_SLOTS-1:0]                                              aggregation_buffer_slot_free,

    // Weight Channels: FTE -> Prefetcher Weight Bank (REQ)
    output logic                                                                                      weight_channel_req_valid,
    input  logic                                                                                      weight_channel_req_ready,
    output WEIGHT_CHANNEL_REQ_t                                                                       weight_channel_req,

    input  logic                                                                                      weight_channel_resp_valid,
    output logic                                                                                      weight_channel_resp_ready,
    input  WEIGHT_CHANNEL_RESP_t                                                                      weight_channel_resp,

    // Transformation Buffer Interface
    output logic [TRANSFORMATION_BUFFER_SLOTS-1:0]                                                    transformation_buffer_write_enable,
    output logic [TRANSFORMATION_BUFFER_SLOTS-1:0] [$clog2(TRANSFORMATION_BUFFER_WRITE_DEPTH)-1:0]    transformation_buffer_write_address,
    output logic [TRANSFORMATION_BUFFER_SLOTS-1:0] [TRANSFORMATION_BUFFER_WRITE_WIDTH-1:0]            transformation_buffer_write_data,
    input  logic [TRANSFORMATION_BUFFER_SLOTS-1:0]                                                    transformation_buffer_slot_free,

    // Feature Transformation Engine -> AXI Interconnect
    output logic [33:0]                       transformation_engine_axi_interconnect_axi_araddr,
    output logic [1:0]                        transformation_engine_axi_interconnect_axi_arburst,
    output logic [3:0]                        transformation_engine_axi_interconnect_axi_arcache,
    output logic [3:0]                        transformation_engine_axi_interconnect_axi_arid,
    output logic [7:0]                        transformation_engine_axi_interconnect_axi_arlen,
    output logic [0:0]                        transformation_engine_axi_interconnect_axi_arlock,
    output logic [2:0]                        transformation_engine_axi_interconnect_axi_arprot,
    output logic [3:0]                        transformation_engine_axi_interconnect_axi_arqos,
    output logic [2:0]                        transformation_engine_axi_interconnect_axi_arsize,
    output logic                              transformation_engine_axi_interconnect_axi_arvalid,
    input  logic                              transformation_engine_axi_interconnect_axi_arready,

    input  logic [511:0]                      transformation_engine_axi_interconnect_axi_rdata,
    input  logic [3:0]                        transformation_engine_axi_interconnect_axi_rid,
    input  logic                              transformation_engine_axi_interconnect_axi_rlast,
    output logic                              transformation_engine_axi_interconnect_axi_rready,
    input  logic [1:0]                        transformation_engine_axi_interconnect_axi_rresp,
    input  logic                              transformation_engine_axi_interconnect_axi_rvalid,
    
    output logic [33:0]                       transformation_engine_axi_interconnect_axi_awaddr,
    output logic [1:0]                        transformation_engine_axi_interconnect_axi_awburst,
    output logic [3:0]                        transformation_engine_axi_interconnect_axi_awcache,
    output logic [3:0]                        transformation_engine_axi_interconnect_axi_awid,
    output logic [7:0]                        transformation_engine_axi_interconnect_axi_awlen,
    output logic [0:0]                        transformation_engine_axi_interconnect_axi_awlock,
    output logic [2:0]                        transformation_engine_axi_interconnect_axi_awprot,
    output logic [3:0]                        transformation_engine_axi_interconnect_axi_awqos,
    input  logic                              transformation_engine_axi_interconnect_axi_awready,
    output logic [2:0]                        transformation_engine_axi_interconnect_axi_awsize,
    output logic                              transformation_engine_axi_interconnect_axi_awvalid,
    
    output logic [511:0]                      transformation_engine_axi_interconnect_axi_wdata,
    output logic                              transformation_engine_axi_interconnect_axi_wlast,
    input  logic                              transformation_engine_axi_interconnect_axi_wready,
    output logic [63:0]                       transformation_engine_axi_interconnect_axi_wstrb,
    output logic                              transformation_engine_axi_interconnect_axi_wvalid,

    input  logic [3:0]                        transformation_engine_axi_interconnect_axi_bid,
    output logic                              transformation_engine_axi_interconnect_axi_bready,
    input  logic [1:0]                        transformation_engine_axi_interconnect_axi_bresp,
    input  logic                              transformation_engine_axi_interconnect_axi_bvalid
    

);

// parameter SYSTOLIC_MODULE_COUNT = top_pkg::MAX_FEATURE_COUNT / MATRIX_N; // = 64
parameter SYSTOLIC_MODULE_COUNT = 4;

typedef enum logic [3:0] { 
    FTE_FSM_IDLE, FTE_FSM_REQ_WC, FTE_FSM_MULT_SLOW, FTE_FSM_MULT_FAST, FTE_FSM_BIAS, FTE_FSM_ACTIVATION, FTE_FSM_BUFFER, FTE_FSM_WRITEBACK, FTE_FSM_SHIFT, FTE_FSM_NSB_RESP
} FTE_FSM_e;

typedef enum logic [1:0] {
    AXI_IDLE, AXI_AW, AXI_W, AXI_B
} AXI_WRITE_STATE_e;

// ==================================================================================================================================================
// Declarations
// ==================================================================================================================================================

FTE_FSM_e fte_state, fte_state_n;
logic last_weight_resp_received;

// Register Bank
// -------------------------------------------------------------------------------------

logic        layer_config_in_features_strobe;
logic [9:0]  layer_config_in_features_count;
logic        layer_config_out_features_strobe;
logic [9:0]  layer_config_out_features_count;
                                    
logic        layer_config_activation_function_strobe;
logic [1:0]  layer_config_activation_function_value;
                                    
logic        layer_config_bias_strobe;
logic [31:0] layer_config_bias_value;
                                    
logic        layer_config_leaky_relu_alpha_strobe;
logic [31:0] layer_config_leaky_relu_alpha_value;
                                    
logic        layer_config_out_features_address_msb_strobe;
logic [1:0]  layer_config_out_features_address_msb_value;
logic        layer_config_out_features_address_lsb_strobe;
logic [31:0] layer_config_out_features_address_lsb_value;

logic       ctrl_buffering_enable_strobe;
logic [0:0] ctrl_buffering_enable_value;
logic       ctrl_writeback_enable_strobe;
logic [0:0] ctrl_writeback_enable_value;

// NSB requests
logic [$clog2(top_pkg::MAX_NODESLOT_COUNT)-1:0] nodeslot_count;
logic [$clog2(top_pkg::MAX_NODESLOT_COUNT)-1:0] nodeslots_to_buffer;
logic [$clog2(top_pkg::MAX_NODESLOT_COUNT)-1:0] nodeslots_to_writeback;

// Systolic modules
// -------------------------------------------------------------------------------------

// Driven from aggregation buffer
logic [SYSTOLIC_MODULE_COUNT:0] [MATRIX_N-1:0]                                  sys_module_forward_valid; // 16
logic [SYSTOLIC_MODULE_COUNT:0] [MATRIX_N-1:0] [31:0]                           sys_module_forward;

// Driven from weight channel
logic [MAX_FEATURE_COUNT-1:0]                                                   sys_module_down_in_valid;
logic [MAX_FEATURE_COUNT-1:0] [31:0]                                            sys_module_down_in;

logic [MAX_FEATURE_COUNT-1:0]                                                   sys_module_down_out_valid;
logic [MAX_FEATURE_COUNT-1:0] [31:0]                                            sys_module_down_out;

logic [SYSTOLIC_MODULE_COUNT-1:0]                                               sys_module_flush_done;

logic [SYSTOLIC_MODULE_COUNT-1:0] [MATRIX_N:0] [MATRIX_N-1:0] [FLOAT_WIDTH-1:0] sys_module_pe_acc;

logic [SYSTOLIC_MODULE_COUNT-1:0]                                               shift_sys_module;
logic                                                                           bias_valid;
logic                                                                           activation_valid;


// Driving systolic modules
// -------------------------------------------------------------------------------------

logic                                                 begin_feature_dump;
logic                                                 pulse_systolic_module;
logic [top_pkg::AGGREGATION_BUFFER_SLOTS-1:0]         slot_pop_shift;
logic [top_pkg::AGGREGATION_BUFFER_SLOTS-1:0]         busy_aggregation_slots_snapshot;
logic                                                 pe_delay_counter;

// Flushing logic
logic [top_pkg::TRANSFORMATION_BUFFER_SLOTS-1:0]         transformation_buffer_slot_arb_oh;

// Writeback logic
logic                                                start_memory_dump;
AXI_WRITE_STATE_e                                    axi_write_state, axi_write_state_n;
logic [$clog2(SYSTOLIC_MODULE_COUNT)-1:0]            sys_module_counter;
logic [MATRIX_N:0] [top_pkg::NODE_ID_WIDTH-1:0]      sys_module_node_id_snapshot;
logic [$clog2(top_pkg::MAX_FEATURE_COUNT * 4) - 1:0] out_features_required_bytes;


// ==================================================================================================================================================
// Instances
// ==================================================================================================================================================

// Regbank
// --------------------------------------------------------------------------------

feature_transformation_engine_regbank_wrapper feature_transformation_engine_regbank_i (
    // Clock and Reset
    .axi_aclk                       (regbank_clk),
    .axi_aresetn                    (regbank_resetn),
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
    .layer_config_activation_function_value,
    .layer_config_bias_value,
    .layer_config_leaky_relu_alpha_value,
    .layer_config_out_features_address_msb_value,
    .layer_config_out_features_address_lsb_value,
    .ctrl_buffering_enable_value,
    .ctrl_writeback_enable_value
);

// Systolic Modules
// --------------------------------------------------------------------------------

for (genvar sys_module = 0; sys_module < SYSTOLIC_MODULE_COUNT; sys_module++) begin
    // Driving from weight channel
    always_comb begin
        sys_module_down_in_valid [sys_module*MATRIX_N + (MATRIX_N-1) : sys_module*MATRIX_N] = {MATRIX_N{weight_channel_resp_valid}} & weight_channel_resp.valid_mask[sys_module*MATRIX_N + (MATRIX_N-1) : sys_module*MATRIX_N];
        sys_module_down_in       [sys_module*MATRIX_N + (MATRIX_N-1) : sys_module*MATRIX_N] = weight_channel_resp.data[sys_module*MATRIX_N + (MATRIX_N-1) : sys_module*MATRIX_N];
    end
    
    systolic_module #(
        .FLOAT_WIDTH (FLOAT_WIDTH),
        .MATRIX_N    (MATRIX_N)
    ) sys_module_i (
        .core_clk                            (core_clk),
        .resetn                              (resetn),

        .pulse_systolic_module               (pulse_systolic_module),

        .sys_module_forward_in_valid         (sys_module_forward_valid  [sys_module]),
        .sys_module_forward_in               (sys_module_forward        [sys_module]),

        .sys_module_down_in_valid            (sys_module_down_in_valid  [sys_module*MATRIX_N + (MATRIX_N-1) : sys_module*MATRIX_N]),
        .sys_module_down_in                  (sys_module_down_in        [sys_module*MATRIX_N + (MATRIX_N-1) : sys_module*MATRIX_N]),

        .sys_module_forward_out_valid        (sys_module_forward_valid  [sys_module+1]),
        .sys_module_forward_out              (sys_module_forward        [sys_module+1]),

        .sys_module_down_out_valid           (sys_module_down_out_valid [sys_module*MATRIX_N + (MATRIX_N-1) : sys_module*MATRIX_N]),
        .sys_module_down_out                 (sys_module_down_out       [sys_module*MATRIX_N + (MATRIX_N-1) : sys_module*MATRIX_N]),
        
        .bias_valid                          (bias_valid),
        .bias                                (layer_config_bias_value),
        
        .activation_valid                    (activation_valid),
        .activation                          (layer_config_activation_function_value),

        .shift_valid                         (shift_sys_module         [sys_module]),

        .sys_module_pe_acc                   (sys_module_pe_acc        [sys_module]),

        .diagonal_flush_done                 (sys_module_flush_done    [sys_module]),

        .layer_config_leaky_relu_alpha_value (layer_config_leaky_relu_alpha_value)
    );

end

// Transformation Buffer slot arbitration
// --------------------------------------------------------------------------------

rr_arbiter #(
    .NUM_REQUESTERS     (top_pkg::TRANSFORMATION_BUFFER_SLOTS)
) prefetcher_req_arb (
    .clk                (core_clk),
    .resetn             (resetn),
    .request            (transformation_buffer_slot_free),

    // update when starting to flush new row
    .update_lru         (fte_state == FTE_FSM_WRITEBACK),
    .grant_oh           (transformation_buffer_slot_arb_oh)
);

// Driving Aggregation Buffer
// --------------------------------------------------------------------------------

hybrid_buffer_driver #(
    .BUFFER_SLOTS (top_pkg::AGGREGATION_BUFFER_SLOTS),
    .MAX_PULSES_PER_SLOT (top_pkg::MAX_FEATURE_COUNT)
) aggregation_buffer_driver_i (
    .core_clk,
    .resetn,

    .begin_dump     (begin_feature_dump),
    .pulse          (pulse_systolic_module),

    .pulse_limit    (layer_config_in_features_count),

    .slot_pop_shift (slot_pop_shift)
);

// ==================================================================================================================================================
// Logic
// ==================================================================================================================================================

// FTE State Machine
// -------------------------------------------------------------------------------------

always_ff @(posedge core_clk or negedge resetn) begin
    if (!resetn) begin
        fte_state <= FTE_FSM_IDLE;
    end else begin
        fte_state <= fte_state_n;
    end
end

always_comb begin
    fte_state_n = fte_state;

    case(fte_state)

        FTE_FSM_IDLE: begin
            fte_state_n = nsb_fte_req_valid ? FTE_FSM_REQ_WC : FTE_FSM_IDLE;
        end

        FTE_FSM_REQ_WC: begin
            fte_state_n = weight_channel_req_ready ? FTE_FSM_MULT_SLOW : FTE_FSM_REQ_WC;
        end

        FTE_FSM_MULT_SLOW: begin
            fte_state_n = last_weight_resp_received ? FTE_FSM_MULT_FAST : FTE_FSM_MULT_SLOW;
        end

        FTE_FSM_MULT_FAST: begin
            fte_state_n = FTE_FSM_MULT_FAST;
        end

        FTE_FSM_BIAS: begin
            fte_state_n = FTE_FSM_ACTIVATION;
        end

        FTE_FSM_ACTIVATION: begin
            fte_state_n = ctrl_buffering_enable_value ? FTE_FSM_BUFFER : FTE_FSM_WRITEBACK;
        end
        
        FTE_FSM_BUFFER: begin
            fte_state_n = FTE_FSM_WRITEBACK; // buffering takes a single cycle
        end

        FTE_FSM_WRITEBACK: begin
            fte_state_n = (nodeslots_to_writeback == 'd1) && (sys_module_counter == SYSTOLIC_MODULE_COUNT) && transformation_engine_axi_interconnect_axi_bvalid ? FTE_FSM_NSB_RESP 
                        : (sys_module_counter == SYSTOLIC_MODULE_COUNT) && transformation_engine_axi_interconnect_axi_bvalid ? FTE_FSM_SHIFT
                        : FTE_FSM_WRITEBACK;
        end

        FTE_FSM_SHIFT: begin
            fte_state_n = ctrl_buffering_enable_value ? FTE_FSM_BUFFER
                        : ctrl_writeback_enable_value ? FTE_FSM_WRITEBACK
                        : FTE_FSM_NSB_RESP;
        end

        FTE_FSM_NSB_RESP: begin
            fte_state_n = FTE_FSM_NSB_RESP;
        end

        default: begin
            fte_state_n = FTE_FSM_IDLE;
        end

    endcase
end

// Take snapshot of busy slots and respective node IDs after NSB request
// -------------------------------------------------------------------------------------

always_ff @(posedge core_clk or negedge resetn) begin
    if (!resetn) begin
        busy_aggregation_slots_snapshot <= '0;
        
    // Starting multiplication
    end else if ((fte_state == FTE_FSM_IDLE) && (fte_state_n == FTE_FSM_REQ_WC)) begin
        busy_aggregation_slots_snapshot <= ~aggregation_buffer_slot_free;    
    end
end

for (genvar row = 0; row < MATRIX_N; row++) begin
    always_ff @(posedge core_clk or negedge resetn) begin
        if (!resetn) begin
            sys_module_node_id_snapshot [row]          <= '0;
            
        // Starting multiplication
        end else if ((fte_state == FTE_FSM_IDLE) && (fte_state_n == FTE_FSM_REQ_WC)) begin
            sys_module_node_id_snapshot [row]          <= aggregation_buffer_node_id [row];
        
        // Shift node IDs
        end else if (fte_state == FTE_FSM_SHIFT) begin
            sys_module_node_id_snapshot [row]          <= sys_module_node_id_snapshot [row+1];
        end
    end
end

assign sys_module_node_id_snapshot [MATRIX_N] = '0;

// Driving systolic module
// -------------------------------------------------------------------------------------

always_comb begin
    // Begin feature dump when weight channel request accepted
    begin_feature_dump = (fte_state == FTE_FSM_REQ_WC) && (fte_state_n == FTE_FSM_MULT_SLOW);

    // Pulse module when features ready in aggregation buffer and weights ready in weight channel
    pulse_systolic_module = ((fte_state_n == FTE_FSM_MULT_SLOW) && &aggregation_buffer_out_feature_valid && weight_channel_resp_valid) || fte_state == FTE_FSM_MULT_FAST;

    // Drive systolic module from aggregation buffer (on the left)
    sys_module_forward_valid [0] = slot_pop_shift & busy_aggregation_slots_snapshot;
    sys_module_forward       [0] = aggregation_buffer_out_feature;

    aggregation_buffer_pop = slot_pop_shift & {MATRIX_N{pulse_systolic_module}} & busy_aggregation_slots_snapshot & ~aggregation_buffer_slot_free;
end

// 1-bit toggle to account for PE delay
// TO DO: reconsider if necessary. May be able to just wait until aggregation_buffer_out_feature_valid
// since this takes 2 cycles after pop
always_ff @(posedge core_clk or negedge resetn) begin
    if (!resetn) begin
        pe_delay_counter <= '1;
    end else begin
        pe_delay_counter <= begin_feature_dump ? 1'b1
                            
                            // Don't toggle before starting MULT
                            : !(fte_state == FTE_FSM_MULT_SLOW) ? pe_delay_counter

                            // Toggle every cycle during MULT
                            : !pe_delay_counter;
    end
end
    
always_comb begin
    // Bias and activation after multiplication finished
    bias_valid       = (fte_state == FTE_FSM_BIAS);
    activation_valid = (fte_state == FTE_FSM_ACTIVATION);
    shift_sys_module = (fte_state == FTE_FSM_SHIFT);
end

// Buffering Logic
// -------------------------------------------------------------------------------------

for (genvar slot = 0; slot < TRANSFORMATION_BUFFER_SLOTS; slot++) begin
    always_comb begin
        transformation_buffer_write_enable  [slot] = transformation_buffer_slot_arb_oh[slot] && (fte_state == FTE_FSM_BUFFER);
        transformation_buffer_write_address [slot] = '0;
        transformation_buffer_write_data    [slot] = sys_module_pe_acc [0] [0]; // 16*32 bits = 512b
    end    
end

always_ff @(posedge core_clk or negedge resetn) begin
    if (!resetn) begin
        nodeslots_to_buffer <= '0;
        nodeslots_to_writeback <= '0;
        
        // Accepting NSB request
    end else if (nsb_fte_req_valid && nsb_fte_req_ready) begin
        nodeslots_to_buffer    <= ctrl_buffering_enable_value ? nodeslot_count : nodeslots_to_buffer;
        nodeslots_to_writeback <= ctrl_writeback_enable_value ? nodeslot_count : nodeslots_to_writeback;
    
    // Done flushing a row of features
    end else if (fte_state == FTE_FSM_BUFFER) begin
        nodeslots_to_buffer <= nodeslots_to_buffer - 1'b1;
    
    end else if (fte_state == FTE_FSM_WRITEBACK && transformation_engine_axi_interconnect_axi_bvalid) begin
        nodeslots_to_writeback <= nodeslots_to_writeback - 1'b1;
    end
end

count_ones #(
    .INPUT_WIDTH (top_pkg::MAX_NODESLOT_COUNT)
) count_nodeslots (
    .data (nsb_fte_req.nodeslots),
    .count (nodeslot_count)
);

// Writeback Logic
// -------------------------------------------------------------------------------------

assign start_memory_dump = (fte_state == FTE_FSM_BUFFER) && (fte_state_n == FTE_FSM_WRITEBACK);

always_ff @(posedge core_clk or negedge resetn) begin
    if (!resetn) begin
        sys_module_counter <= '0;
        
    // Starting to flush row from systolic array
    end else if (fte_state == FTE_FSM_BUFFER && fte_state_n == FTE_FSM_WRITEBACK) begin
        sys_module_counter <= '0;
    
    // Finished current systolic module
    end else if (transformation_engine_axi_interconnect_axi_wvalid && transformation_engine_axi_interconnect_axi_wready) begin
        sys_module_counter <= sys_module_counter + 1'b1;
    end
end

always_ff @(posedge core_clk or negedge resetn) begin
    if (!resetn) begin
        axi_write_state <= AXI_IDLE;
    end else begin
        axi_write_state <= axi_write_state_n;
    end
end

always_comb begin
    axi_write_state_n = axi_write_state;

    case (axi_write_state)
        AXI_IDLE: begin
            axi_write_state_n = start_memory_dump ? AXI_AW
                              : AXI_IDLE;
        end

        AXI_AW: begin
            axi_write_state_n = transformation_engine_axi_interconnect_axi_awready ? AXI_W
                              : AXI_AW;
        end

        AXI_W: begin
            axi_write_state_n = transformation_engine_axi_interconnect_axi_wvalid && transformation_engine_axi_interconnect_axi_wready && transformation_engine_axi_interconnect_axi_wlast ? AXI_B
                              : AXI_W;
        end

        AXI_B: begin
            axi_write_state_n = transformation_engine_axi_interconnect_axi_bvalid ? AXI_IDLE
                              : AXI_B;
        end

    endcase

end

always_comb begin
    out_features_required_bytes = layer_config_out_features_count * 4; // 4 bytes per feature
    out_features_required_bytes = {out_features_required_bytes[$clog2(top_pkg::MAX_FEATURE_COUNT * 4) - 1 : 6], 6'd0} + (out_features_required_bytes[5:0] ? 'd64 : 1'b0); // nearest multiple of 64
    
    transformation_engine_axi_interconnect_axi_awvalid = (axi_write_state == AXI_AW);
    
    transformation_engine_axi_interconnect_axi_awaddr = {layer_config_out_features_address_msb_value, layer_config_out_features_address_lsb_value}
                                                        + sys_module_node_id_snapshot[0] * out_features_required_bytes;

    transformation_engine_axi_interconnect_axi_awsize  = 3'b110; // 64 bytes
    transformation_engine_axi_interconnect_axi_awburst = 2'b01; // INCR mode (increment by 64 bytes for each beat)
    transformation_engine_axi_interconnect_axi_awlen   = (SYSTOLIC_MODULE_COUNT[7:0] - 1'b1);
    
    // Unused features
    transformation_engine_axi_interconnect_axi_awcache = '0;
    transformation_engine_axi_interconnect_axi_awid    = '0;
    transformation_engine_axi_interconnect_axi_awlock  = '0;
    transformation_engine_axi_interconnect_axi_awprot  = '0;
    transformation_engine_axi_interconnect_axi_awqos   = '0;

    transformation_engine_axi_interconnect_axi_wvalid = (axi_write_state == AXI_W);
    transformation_engine_axi_interconnect_axi_wdata  = sys_module_pe_acc [sys_module_counter] [0];         // Top row of systolic module
    transformation_engine_axi_interconnect_axi_wlast  = (sys_module_counter == (SYSTOLIC_MODULE_COUNT-1));
    transformation_engine_axi_interconnect_axi_wstrb  = '1;

    transformation_engine_axi_interconnect_axi_bready = (axi_write_state == AXI_B);
end

// NSB Interface
// -------------------------------------------------------------------------------------

always_comb begin
    nsb_fte_req_ready           = (fte_state == FTE_FSM_IDLE);
    
    // TO DO: NSB resp
    nsb_fte_resp_valid          = (fte_state == FTE_FSM_NSB_RESP);
    nsb_fte_resp                = '0;
end

// Weight Channel Interface
// -------------------------------------------------------------------------------------

always_comb begin
    weight_channel_req_valid  = (fte_state == FTE_FSM_REQ_WC);

    // Feature counts aren't used by weight bank
    weight_channel_req.in_features  = top_pkg::MAX_FEATURE_COUNT;
    weight_channel_req.out_features = top_pkg::MAX_FEATURE_COUNT;

    // Accept weight bank response when pulsing systolic module (i.e. aggregation buffer is also ready)
    weight_channel_resp_ready = (fte_state == FTE_FSM_MULT_SLOW) && (pulse_systolic_module || weight_channel_resp.done);
end

// Raise flag as pre-condition for transitioning from MULT state
always_ff @(posedge core_clk or negedge resetn) begin
    if (!resetn) begin
        last_weight_resp_received <= '0;
    
    end else if (weight_channel_resp_valid && weight_channel_resp.done) begin
        last_weight_resp_received <= '1;
    end
end

always_comb begin
    transformation_engine_axi_interconnect_axi_araddr  = '0;
    transformation_engine_axi_interconnect_axi_arburst = '0;
    transformation_engine_axi_interconnect_axi_arcache = '0;
    transformation_engine_axi_interconnect_axi_arid    = '0;
    transformation_engine_axi_interconnect_axi_arlen   = '0;
    transformation_engine_axi_interconnect_axi_arlock  = '0;
    transformation_engine_axi_interconnect_axi_arprot  = '0;
    transformation_engine_axi_interconnect_axi_arqos   = '0;
    transformation_engine_axi_interconnect_axi_arsize  = '0;
    transformation_engine_axi_interconnect_axi_arvalid = '0;
    transformation_engine_axi_interconnect_axi_rready  = '0;
end

endmodule