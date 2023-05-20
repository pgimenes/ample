import top_pkg::*;

module feature_aggregator #(
    parameter DATA_WIDTH = 32,
    parameter FLOAT_WIDTH = 32,
    parameter PRECISION = "FLOAT_32"
) (
    input  logic                   core_clk,
    input  logic                   resetn,

    input  AGGREGATION_FUNCTION_e  aggregation_function_sel,

    input  logic                   in_feature_valid,
    output logic                   in_feature_ready,
    input  logic [DATA_WIDTH-1:0]  in_feature,

    output logic                   feature_updated,
    output logic [DATA_WIDTH-1:0]  accumulator,
    
    input  logic                   reset_accumulator,

    input  logic                   upsample,
    output logic                   upsampled_accumulator_valid,
    output logic [FLOAT_WIDTH-1:0] upsampled_accumulator

);

logic                                         passthrough_aggregator_in_feature_valid;
logic                                         sum_aggregator_in_feature_valid;
logic                                         mean_aggregator_in_feature_valid;

logic [DATA_WIDTH-1:0]                        passthrough_aggregator_out_feature;
logic                                         passthrough_aggregator_out_valid;

logic [DATA_WIDTH-1:0]                        sum_aggregator_out_feature;
logic                                         sum_aggregator_out_valid;

// === ADD AGGREGATOR DECLARATIONS

logic[$clog2(top_pkg::MAX_FEATURE_COUNT)-1:0] feature_accumulation_count;

logic                                         busy;

logic                   upsampled_accumulator_valid_comb;
logic [FLOAT_WIDTH-1:0] upsampled_accumulator_comb;

// ==================================================================================================================================================
// Aggregators
// ==================================================================================================================================================

passthrough_aggregator #(
    .DATA_WIDTH (DATA_WIDTH),
    .PRECISION  (PRECISION)
) passthrough_aggregator_i (
    .core_clk          (core_clk),
    .resetn            (resetn),
    .in_feature        (in_feature),
    .in_feature_valid  (passthrough_aggregator_in_feature_valid),
    .out_feature       (passthrough_aggregator_out_feature),
    .out_feature_valid (passthrough_aggregator_out_valid)
);

sum_aggregator #(
    .DATA_WIDTH (DATA_WIDTH),
    .PRECISION  (PRECISION)
) sum_aggregator_i (
    .core_clk,
    .resetn,
    .in_feature_valid  (sum_aggregator_in_feature_valid),
    .in_feature        (in_feature),

    .acc_feature       (accumulator),
    
    .out_feature_valid (sum_aggregator_out_valid),
    .out_feature       (sum_aggregator_out_feature)
);

// === ADD AGGREGATOR INSTANCE

// ==================================================================================================================================================
// Upsamplers
// ==================================================================================================================================================

if (PRECISION == "FIXED_16") begin
    
    fixed16_upsampler upsampler_i (
        .aclk               (core_clk),
        .aresetn            (resetn),

        .s_axis_a_tvalid    (upsample),
        .s_axis_a_tdata     (accumulator),
        
        .m_axis_result_tvalid (upsampled_accumulator_valid_comb),
        .m_axis_result_tdata  (upsampled_accumulator_comb)
    );

end else if (PRECISION == "FIXED_8") begin
    
    fixed8_upsampler upsampler_i (
        .aclk               (core_clk),
        .aresetn            (resetn),

        .s_axis_a_tvalid    (upsample),
        .s_axis_a_tdata     (accumulator),
        
        .m_axis_result_tvalid (upsampled_accumulator_valid_comb),
        .m_axis_result_tdata  (upsampled_accumulator_comb)
    );

end else if (PRECISION == "FIXED_4") begin
    
    fixed4_upsampler upsampler_i (
        .aclk               (core_clk),
        .aresetn            (resetn),

        .s_axis_a_tvalid    (upsample),
        .s_axis_a_tdata     (accumulator),
        
        .m_axis_result_tvalid (upsampled_accumulator_valid_comb),
        .m_axis_result_tdata  (upsampled_accumulator_comb)
    );

end

// ==================================================================================================================================================
// Logic
// ==================================================================================================================================================

always_ff @(posedge core_clk or negedge resetn) begin
    if (!resetn) begin
        busy <= '0;

    // Accepting new update request
    end else if (in_feature_valid && in_feature_ready) begin
        busy <= 1'b1;

    // Done with update request
    end else if (feature_updated) begin
        busy <= 1'b0;
    end
end

always_comb begin
    // Write first feature into accumulator directly regardless of chosen aggregation function
    passthrough_aggregator_in_feature_valid = (feature_accumulation_count == '0) && in_feature_valid && in_feature_ready;
    sum_aggregator_in_feature_valid = |feature_accumulation_count && in_feature_valid && in_feature_ready && (aggregation_function_sel == top_pkg::SUM);

    // === ADD AGGREGATOR VALID DRIVER

    feature_updated = busy && ((feature_accumulation_count == '0) ? passthrough_aggregator_out_valid
                                : (aggregation_function_sel == top_pkg::SUM) ? sum_aggregator_out_valid
                                
                                // === ADD AGGREGATOR OPTION
                                : '0);

    // If feature waiting, apply backpressure until appropriate aggregator is ready.
    // Otherwise, assert ready so that staller can drive valids
    in_feature_ready = !busy;
end

always_ff @(posedge core_clk or negedge resetn) begin
    if (!resetn) begin
        feature_accumulation_count <= '0;
        accumulator                <= '0;
    
    end else if (reset_accumulator) begin
        feature_accumulation_count <= '0;
        accumulator                <= '0;
        
    end else if (feature_updated) begin
        feature_accumulation_count <= feature_accumulation_count + 1'b1;

        if (feature_accumulation_count == '0) begin
            accumulator <= passthrough_aggregator_out_feature;
        end else begin
            
            case (aggregation_function_sel)

            top_pkg::SUM: accumulator <= sum_aggregator_out_feature;

            // === ADD AGGREGATOR UPDATE OPTION

            default: accumulator <= accumulator;

            endcase
        end
    end
end

// Multi-precision support
// --------------------------------------------

if (PRECISION == "FIXED_16" || PRECISION == "FIXED_8" || PRECISION == "FIXED_4") begin
    
    // Latch results in the cycle after upsample request
    always_ff @(posedge core_clk or negedge resetn) begin
        if (!resetn) begin
            upsampled_accumulator       <= '0;
            upsampled_accumulator_valid <= '0;
        
        end else if (upsampled_accumulator_valid_comb) begin
            upsampled_accumulator       <= upsampled_accumulator_comb;
            upsampled_accumulator_valid <= upsampled_accumulator_valid_comb;
        end
    end

end else begin

    // Latch results in the cycle after upsample request
    always_ff @(posedge core_clk or negedge resetn) begin
        if (!resetn) begin
            upsampled_accumulator       <= '0;
            upsampled_accumulator_valid <= '0;
        
        end else if (upsample) begin
            upsampled_accumulator       <= accumulator;
            upsampled_accumulator_valid <= '1;
        end
    end

end

endmodule