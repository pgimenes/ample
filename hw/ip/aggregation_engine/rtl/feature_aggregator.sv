import top_pkg::*;

module feature_aggregator #(
    parameter DATA_WIDTH = 32
) (
    input  logic                  core_clk,
    input  logic                  resetn,

    input  logic                  in_feature_valid,
    output logic                  in_feature_ready,
    input  logic [DATA_WIDTH-1:0] in_feature,

    output logic                  feature_updated,
    
    input  logic                  reset_accumulator,
    input  AGGREGATION_FUNCTION_e aggregation_function_sel,

    output logic [DATA_WIDTH-1:0] accumulator
);

logic                                         passthrough_aggregator_in_feature_valid;
logic                                         sum_aggregator_in_feature_valid;
logic                                         mean_aggregator_in_feature_valid;

logic [DATA_WIDTH-1:0]                        passthrough_aggregator_out_feature;
logic                                         passthrough_aggregator_out_valid;

logic [DATA_WIDTH-1:0]                        sum_aggregator_out_feature;
logic                                         sum_aggregator_out_valid;

logic [DATA_WIDTH-1:0]                        mean_aggregator_out_feature;
logic                                         mean_aggregator_out_valid;

logic[$clog2(top_pkg::MAX_FEATURE_COUNT)-1:0] feature_accumulation_count;

logic                                         busy;

// ==================================================================================================================================================
// Aggregators
// ==================================================================================================================================================

passthrough_aggregator #(
    .DATA_WIDTH (DATA_WIDTH)
) passthrough_aggregator_i (
    .core_clk          (core_clk),
    .resetn            (resetn),
    .in_feature        (in_feature),
    .in_feature_valid  (passthrough_aggregator_in_feature_valid),
    .out_feature       (passthrough_aggregator_out_feature),
    .out_feature_valid (passthrough_aggregator_out_valid)
);

sum_aggregator #(
    .DATA_WIDTH (DATA_WIDTH)
) sum_aggregator_i (
    .core_clk,
    .resetn,
    .in_feature_valid  (sum_aggregator_in_feature_valid),
    .in_feature        (in_feature),

    .acc_feature       (accumulator),
    
    .out_feature_valid (sum_aggregator_out_valid),
    .out_feature       (sum_aggregator_out_feature)
);

// mean_aggregator #(
//     .DATA_WIDTH (DATA_WIDTH)
// ) mean_aggregator_i (
//     .core_clk,
//     .resetn,
//     .in_feature_valid   (mean_aggregator_in_feature_valid),
//     .in_feature         (in_feature),
//     .acc_feature        (accumulator),
//     .out_feature_valid  (mean_aggregator_out_valid),
//     .out_feature        (mean_aggregator_out_feature),
//     .accumulation_count (feature_accumulation_count)
// );

// === ADD AGGREGATOR INSTANCE

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
    // mean_aggregator_in_feature_valid = |feature_accumulation_count && in_feature_valid && (aggregation_function_sel == top_pkg::MEAN);

    feature_updated = busy && ((feature_accumulation_count == '0) ? passthrough_aggregator_out_valid
                                : (aggregation_function_sel == top_pkg::SUM) ? sum_aggregator_out_valid
                                // : (aggregation_function_sel == top_pkg::MEAN) ? mean_aggregator_out_valid
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
            // top_pkg::MEAN: accumulator <= mean_aggregator_out_feature;

            default: accumulator <= accumulator;

            endcase
        end
    end
end

endmodule