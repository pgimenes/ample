
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

    // Node Scoreboard -> Aggregation Engine Interface
    input  logic                                  nsb_fte_req_valid,
    output logic                                  nsb_fte_req_ready,
    input  NSB_FTE_REQ_t                          nsb_fte_req,
    output logic                                  nsb_fte_resp_valid, // valid only for now
    output NSB_FTE_RESP_t                         nsb_fte_resp,

    // Aggregation Buffer Interface
    output logic [top_pkg::AGGREGATION_BUFFER_SLOTS-1:0]                                              fte_aggregation_buffer_pop,
    input  logic [top_pkg::AGGREGATION_BUFFER_SLOTS-1:0]                                              aggregation_buffer_fte_out_feature_valid,
    input  logic [top_pkg::AGGREGATION_BUFFER_SLOTS-1:0] [top_pkg::AGGREGATION_BUFFER_READ_WIDTH-1:0] aggregation_buffer_fte_out_feature,

    // Weight Channels: FTE -> Prefetcher Weight Bank (REQ)
    output logic                                              weight_channel_req_valid,
    input  logic                                              weight_channel_req_ready,
    output WEIGHT_CHANNEL_REQ_t                               weight_channel_req,

    // Weight Channels: FTE -> Prefetcher Weight Bank (RESP)
    input  logic                                              weight_channel_resp_valid,
    output logic                                              weight_channel_resp_ready,
    input  WEIGHT_CHANNEL_RESP_t                              weight_channel_resp

);

// parameter SYSTOLIC_MODULE_COUNT = top_pkg::MAX_FEATURE_COUNT / MATRIX_N; // = 64
parameter SYSTOLIC_MODULE_COUNT = 1;

typedef enum logic [3:0] { 
    FTE_FSM_IDLE, FTE_FSM_REQ_WC, FTE_FSM_MULT
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

// Systolic modules
// -------------------------------------------------------------------------------------

// Driven from aggregation buffer
logic [MATRIX_N-1:0]                 sys_array_forward_valid; // 16
logic [MATRIX_N-1:0] [31:0]          sys_array_forward;

// Driven from weight channel
logic [MAX_FEATURE_COUNT-1:0]        sys_array_down_valid; // 1024
logic [MAX_FEATURE_COUNT-1:0] [31:0] sys_array_down;

// logic [SYSTOLIC_MODULE_COUNT-1:0] [MATRIX_N-1:0] [MATRIX_N-1:0] sys_array_pe_acc;

// Driving systolic modules
// -------------------------------------------------------------------------------------

logic                                                 begin_feature_dump;
logic                                                 pulse_systolic_module;
logic [top_pkg::AGGREGATION_BUFFER_SLOTS-1:0]         slot_pop_shift;
logic [$clog2(top_pkg::AGGREGATION_BUFFER_SLOTS)-1:0] slot_pop_counter;

// ==================================================================================================================================================
// Instances
// ==================================================================================================================================================

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

for (genvar sys_module = 0; sys_module < SYSTOLIC_MODULE_COUNT; sys_module++) begin
    sys_array #(
        .FLOAT_WIDTH (FLOAT_WIDTH),
        .MATRIX_N    (MATRIX_N)
    ) sys_array_i (
        .core_clk,
        .rstn                    (resetn),

        .sys_array_forward_valid (sys_array_forward_valid [sys_module]),
        .sys_array_forward       (sys_array_forward       [sys_module]),

        .sys_array_down_valid    (sys_array_down_valid    [sys_module]),
        .sys_array_down          (sys_array_down          [sys_module]),
        
        .sys_array_pe_acc        ()
    );

    // Driving from weight channel
    always_comb begin
        sys_array_down_valid    [sys_module] = pulse_systolic_module && weight_channel_resp.valid_mask[sys_module*MATRIX_N + (MATRIX_N-1) : sys_module*MATRIX_N];
        sys_array_down          [sys_module] = weight_channel_resp.data[sys_module*MATRIX_N + (MATRIX_N-1) : sys_module*MATRIX_N];
    end
end

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
            fte_state_n = FTE_FSM_MULT;
        end

        default: begin
            fte_state_n = FTE_FSM_IDLE;
        end

    endcase
end

// Driving systolic module
// -------------------------------------------------------------------------------------

always_comb begin
    // Begin feature dump when weight channel request accepted
    begin_feature_dump = (fte_state == FTE_FSM_REQ_WC) && (fte_state_n == FTE_FSM_MULT);

    // Pulse module when features ready in aggregation buffer and weights ready in weight channel
    pulse_systolic_module = (fte_state_n == FTE_FSM_MULT) && (&aggregation_buffer_fte_out_feature_valid) && weight_channel_resp_valid;

    // Drive systolic module from aggregation buffer (on the left)
    sys_array_forward_valid      = slot_pop_shift & {MATRIX_N{pulse_systolic_module}};
    sys_array_forward            = aggregation_buffer_fte_out_feature;

    fte_aggregation_buffer_pop = slot_pop_shift & {MATRIX_N{pulse_systolic_module}};

end

// Shift register to flush through weights matrix diagonally
for (genvar slot = 1; slot < AGGREGATION_BUFFER_SLOTS; slot++) begin
    always_ff @(posedge core_clk or negedge resetn) begin
        if (!resetn) begin
            slot_pop_shift[slot] <= '0;

        // Clear shift register when starting new weight dump
        end else if (begin_feature_dump) begin
            slot_pop_shift[slot] <= '0;

        // Shift register when accepting weight channel response
        end else if (pulse_systolic_module) begin
            slot_pop_shift[slot] <= slot_pop_shift[slot-1];
        end
    end
end

always_ff @(posedge core_clk or negedge resetn) begin
    if (!resetn) begin
        slot_pop_shift[0] <= '0; // Head of shift register
        slot_pop_counter <= '0;
    
    // Starting new feature dump, reset all flags and counters
    end else if (begin_feature_dump) begin
        slot_pop_shift[0] <= '1;
        slot_pop_counter <= '0;

    end else if (pulse_systolic_module) begin
        // Increment when popping any slots, but latch at '1
        slot_pop_counter <= (slot_pop_counter == '1) ? slot_pop_counter : (slot_pop_counter + 1'b1);

        // If accepting weight channel response, new data is available on all slot FIFOs so shift register
        slot_pop_shift[0] <= (slot_pop_counter != '1);

    end
end

// NSB Interface
// -------------------------------------------------------------------------------------

always_comb begin
    nsb_fte_req_ready           = (fte_state == FTE_FSM_IDLE);
    
    // TO DO: NSB resp
    nsb_fte_resp_valid          = '0;
    nsb_fte_resp                = '0;
end

// Weight Channel Interface
// -------------------------------------------------------------------------------------

always_comb begin
    weight_channel_req_valid  = (fte_state == FTE_FSM_REQ_WC);
    weight_channel_req.in_features  = top_pkg::MAX_FEATURE_COUNT;
    weight_channel_req.out_features = top_pkg::MAX_FEATURE_COUNT;

    // Accept weight bank response when pulsing systolic module (i.e. aggregation buffer is also ready)
    weight_channel_resp_ready = (fte_state == FTE_FSM_MULT) && pulse_systolic_module;
end

endmodule