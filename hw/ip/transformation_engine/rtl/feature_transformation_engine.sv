
import top_pkg::*;

module feature_transformation_engine #(
    parameter FLOAT_WIDTH = 32,
    parameter AXI_ADDR_WIDTH = 32,
    parameter MATRIX_N = 16
) (
    input logic core_clk,
    input logic resetn,

    // Regbank Slave AXI interface
    input  logic [AXI_ADDR_WIDTH-1:0]             s_axi_awaddr,
    input  logic [2:0]                            s_axi_awprot,
    input  logic                                  s_axi_awvalid,
    output logic                                  s_axi_awready,
    input  logic [31:0]                           s_axi_wdata,
    input  logic [3:0]                            s_axi_wstrb,
    input  logic                                  s_axi_wvalid,
    output logic                                  s_axi_wready,
    input  logic [AXI_ADDR_WIDTH-1:0]             s_axi_araddr,
    input  logic [2:0]                            s_axi_arprot,
    input  logic                                  s_axi_arvalid,
    output logic                                  s_axi_arready,
    output logic [31:0]                           s_axi_rdata,
    output logic [1:0]                            s_axi_rresp,
    output logic                                  s_axi_rvalid,
    input  logic                                  s_axi_rready,
    output logic [1:0]                            s_axi_bresp,
    output logic                                  s_axi_bvalid,
    input  logic                                  s_axi_bready,

    // Node Scoreboard -> Transformation Engine Interface
    input  logic                                  nsb_fte_req_valid,
    output logic                                  nsb_fte_req_ready,
    input  NSB_FTE_REQ_t                          nsb_fte_req,
    output logic                                  nsb_fte_resp_valid, // valid only for now
    output NSB_FTE_RESP_t                         nsb_fte_resp,

    // Aggregation Buffer Interface
    output logic [top_pkg::AGGREGATION_BUFFER_SLOTS-1:0]                                              fte_aggregation_buffer_pop,
    input  logic [top_pkg::AGGREGATION_BUFFER_SLOTS-1:0]                                              aggregation_buffer_fte_out_feature_valid,
    input  logic [top_pkg::AGGREGATION_BUFFER_SLOTS-1:0] [top_pkg::AGGREGATION_BUFFER_READ_WIDTH-1:0] aggregation_buffer_fte_out_feature,
    input  logic [top_pkg::AGGREGATION_BUFFER_SLOTS-1:0]                                              aggregation_buffer_fte_slot_free,

    // Weight Channels: FTE -> Prefetcher Weight Bank (REQ)
    output logic                                              weight_channel_req_valid,
    input  logic                                              weight_channel_req_ready,
    output WEIGHT_CHANNEL_REQ_t                               weight_channel_req,

    input  logic                                              weight_channel_resp_valid,
    output logic                                              weight_channel_resp_ready,
    input  WEIGHT_CHANNEL_RESP_t                              weight_channel_resp,

    output logic [TRANSFORMATION_BUFFER_SLOTS-1:0]                                                 fte_transformation_buffer_write_enable,
    output logic [TRANSFORMATION_BUFFER_SLOTS-1:0] [$clog2(TRANSFORMATION_BUFFER_WRITE_DEPTH)-1:0] fte_transformation_buffer_write_address,
    output logic [TRANSFORMATION_BUFFER_SLOTS-1:0] [TRANSFORMATION_BUFFER_WRITE_WIDTH-1:0]         fte_transformation_buffer_write_data,
    input  logic [TRANSFORMATION_BUFFER_SLOTS-1:0]                                                 transformation_buffer_slot_free

);

// parameter SYSTOLIC_MODULE_COUNT = top_pkg::MAX_FEATURE_COUNT / MATRIX_N; // = 64
parameter SYSTOLIC_MODULE_COUNT = 1;

typedef enum logic [3:0] { 
    FTE_FSM_IDLE, FTE_FSM_REQ_WC, FTE_FSM_MULT, FTE_FSM_FLUSH, FTE_FSM_SHIFT, FTE_FSM_NSB_RESP
} FTE_FSM_e;

// ==================================================================================================================================================
// Declarations
// ==================================================================================================================================================

// Register Bank
// -------------------------------------------------------------------------------------

logic layer_config_in_features_strobe;
logic [9:0] layer_config_in_features_count;
logic layer_config_out_features_strobe;
logic [9:0] layer_config_out_features_count;

FTE_FSM_e fte_state, fte_state_n;

// NSB requests
logic [$clog2(top_pkg::MAX_NODESLOT_COUNT)-1:0] nodeslot_count;
logic [$clog2(top_pkg::MAX_NODESLOT_COUNT)-1:0] nodeslots_to_flush;

// Systolic modules
// -------------------------------------------------------------------------------------

// Driven from aggregation buffer
logic [MATRIX_N-1:0]                 sys_array_forward_valid; // 16
logic [MATRIX_N-1:0] [31:0]          sys_array_forward;

// Driven from weight channel
logic [MAX_FEATURE_COUNT-1:0]        sys_array_down_valid; // 1024
logic [MAX_FEATURE_COUNT-1:0] [31:0] sys_array_down;

logic [SYSTOLIC_MODULE_COUNT-1:0] [MATRIX_N-1:0] [MATRIX_N-1:0] [FLOAT_WIDTH-1:0] sys_array_pe_acc;

logic [SYSTOLIC_MODULE_COUNT-1:0] shift_sys_array;

// Driving systolic modules
// -------------------------------------------------------------------------------------

logic                                                 begin_feature_dump;
logic                                                 pulse_systolic_module;
logic [top_pkg::AGGREGATION_BUFFER_SLOTS-1:0]         slot_pop_shift;
logic [top_pkg::AGGREGATION_BUFFER_SLOTS-1:0]         busy_aggregation_slots_snapshot;

// Flushing logic
logic [top_pkg::TRANSFORMATION_BUFFER_SLOTS-1:0]         transformation_buffer_slot_arb_oh;

// ==================================================================================================================================================
// Instances
// ==================================================================================================================================================

// Regbank
// --------------------------------------------------------------------------------

feature_transformation_engine_regbank_regs feature_transformation_engine_regbank_i (
    // Clock and Reset
    .axi_aclk                        (core_clk),
    .axi_aresetn                     (resetn),

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
    .layer_config_in_features_strobe,
    .layer_config_in_features_count,
    .layer_config_out_features_strobe,
    .layer_config_out_features_count 
);

// Systolic Modules
// --------------------------------------------------------------------------------

for (genvar sys_module = 0; sys_module < SYSTOLIC_MODULE_COUNT; sys_module++) begin
    // Driving from weight channel
    always_comb begin
        sys_array_down_valid    [sys_module*MATRIX_N + (MATRIX_N-1) : sys_module*MATRIX_N] = {MATRIX_N{pulse_systolic_module}} & weight_channel_resp.valid_mask[sys_module*MATRIX_N + (MATRIX_N-1) : sys_module*MATRIX_N];
        sys_array_down          [sys_module*MATRIX_N + (MATRIX_N-1) : sys_module*MATRIX_N] = weight_channel_resp.data[sys_module*MATRIX_N + (MATRIX_N-1) : sys_module*MATRIX_N];
    end
    
    sys_array #(
        .FLOAT_WIDTH (FLOAT_WIDTH),
        .MATRIX_N    (MATRIX_N)
    ) sys_array_i (
        .core_clk,
        .rstn                    (resetn),

        .sys_array_forward_valid (sys_array_forward_valid), // TO DO: support >1 sys module
        .sys_array_forward       (sys_array_forward      ), // TO DO: support >1 sys module

        .sys_array_down_valid    (sys_array_down_valid    [sys_module*MATRIX_N + (MATRIX_N-1) : sys_module*MATRIX_N]),
        .sys_array_down          (sys_array_down          [sys_module*MATRIX_N + (MATRIX_N-1) : sys_module*MATRIX_N]),
        
        .sys_array_pe_acc        (sys_array_pe_acc        [sys_module]),

        .shift                   (shift_sys_array         [sys_module])
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
    .update_lru         (fte_state == FTE_FSM_FLUSH),
    .grant_oh           (transformation_buffer_slot_arb_oh)
);

// Driving Aggregation Buffer
// --------------------------------------------------------------------------------

hybrid_buffer_driver #(
    .BUFFER_SLOTS (16)
) aggregation_buffer_driver_i (
    .core_clk,
    .resetn,

    .begin_dump     (begin_feature_dump),
    .pulse          (pulse_systolic_module),

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
            fte_state_n = weight_channel_req_ready ? FTE_FSM_MULT : FTE_FSM_REQ_WC;
        end

        FTE_FSM_MULT: begin
            // TO DO: wait until forward valid and down valid all propagated to 0s in last col and row
            fte_state_n = weight_channel_resp_valid && weight_channel_resp.done ? FTE_FSM_FLUSH : FTE_FSM_MULT;
        end

        FTE_FSM_FLUSH: begin
            fte_state_n = (nodeslots_to_flush == 'd1) ? FTE_FSM_NSB_RESP : FTE_FSM_SHIFT;
        end

        FTE_FSM_SHIFT: begin
            fte_state_n = FTE_FSM_FLUSH;
        end

        FTE_FSM_NSB_RESP: begin
            fte_state_n = FTE_FSM_NSB_RESP;
        end

        default: begin
            fte_state_n = FTE_FSM_IDLE;
        end

    endcase
end

// Take snapshot of busy slots after NSB request
// -------------------------------------------------------------------------------------

always_ff @(posedge core_clk or negedge resetn) begin
    if (!resetn) begin
        busy_aggregation_slots_snapshot <= '0;
    
    // Starting multiplication
    end else if ((fte_state == FTE_FSM_IDLE) && (fte_state_n == FTE_FSM_REQ_WC)) begin
        busy_aggregation_slots_snapshot <= ~aggregation_buffer_fte_slot_free;
    end
end

// Driving systolic module
// -------------------------------------------------------------------------------------

always_comb begin
    // Begin feature dump when weight channel request accepted
    begin_feature_dump = (fte_state == FTE_FSM_REQ_WC) && (fte_state_n == FTE_FSM_MULT);

    // Pulse module when features ready in aggregation buffer and weights ready in weight channel
    pulse_systolic_module = (fte_state_n == FTE_FSM_MULT) && (&aggregation_buffer_fte_out_feature_valid) && weight_channel_resp_valid;

    // Drive systolic module from aggregation buffer (on the left)
    sys_array_forward_valid      = slot_pop_shift & {MATRIX_N{pulse_systolic_module}} & busy_aggregation_slots_snapshot;
    sys_array_forward            = aggregation_buffer_fte_out_feature;

    fte_aggregation_buffer_pop = slot_pop_shift & {MATRIX_N{pulse_systolic_module}} & busy_aggregation_slots_snapshot;
end
    
// Shift systolic module upwards when done flushing top row
assign shift_sys_array = (fte_state == FTE_FSM_SHIFT) ? '1 : '0;

// Buffer updated features
// -------------------------------------------------------------------------------------

for (genvar slot = 0; slot < TRANSFORMATION_BUFFER_SLOTS; slot++) begin
    always_comb begin
        fte_transformation_buffer_write_enable  [slot] = transformation_buffer_slot_arb_oh[slot] && (fte_state == FTE_FSM_FLUSH);
        fte_transformation_buffer_write_address [slot] = '0;
        fte_transformation_buffer_write_data    [slot] = sys_array_pe_acc [0] [0]; // 16*32 bits = 512b
    end    
end

always_ff @(posedge core_clk or negedge resetn) begin
    if (!resetn) begin
        nodeslots_to_flush <= '0;
    
    // Accepting NSB request
    end else if (nsb_fte_req_valid && nsb_fte_req_ready) begin
        nodeslots_to_flush <= nodeslot_count;
    
    // Done flushing a row of features
    end else if (fte_state == FTE_FSM_FLUSH) begin
        nodeslots_to_flush <= nodeslots_to_flush - 1'b1;
        
    end
end

count_ones #(
    .INPUT_WIDTH (top_pkg::MAX_NODESLOT_COUNT)
) count_nodeslots (
    .data (nsb_fte_req.nodeslots),
    .count (nodeslot_count)
);

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
    weight_channel_req.in_features  = top_pkg::MAX_FEATURE_COUNT;
    weight_channel_req.out_features = top_pkg::MAX_FEATURE_COUNT;

    // Accept weight bank response when pulsing systolic module (i.e. aggregation buffer is also ready)
    weight_channel_resp_ready = (fte_state == FTE_FSM_MULT) && (pulse_systolic_module || weight_channel_resp.done);
end

endmodule