import top_pkg::*;

module feature_aggregator #(
    parameter DATA_WIDTH = 32
) (
    input  logic                  core_clk,
    input  logic                  resetn,

    input  logic                  in_feature_valid,
    output logic                  in_feature_ready,
    input  logic [DATA_WIDTH-1:0] in_feature,
    input  logic                  reset_accumulator,
    input  AGGREGATION_FUNCTION_e aggregation_function_sel,

    output logic [DATA_WIDTH-1:0] accumulator
);

logic passthrough_aggregator_in_feature_valid;
logic sum_aggregator_in_feature_valid;
logic mean_aggregator_in_feature_valid;

logic [DATA_WIDTH-1:0] passthrough_aggregator_out_feature;
logic                  passthrough_aggregator_out_valid;

logic [DATA_WIDTH-1:0] sum_aggregator_out_feature;
logic                  sum_aggregator_out_valid;

logic [DATA_WIDTH-1:0] mean_aggregator_out_feature;
logic                  mean_aggregator_out_valid;

logic[$clog2(top_pkg::MAX_FEATURE_COUNT)-1:0] feature_accumulation_count;

logic updated_feature_ready;

// ==================================================================================================================================================
// Aggregators
// ==================================================================================================================================================

passthrough_aggregator #(
    .DATA_WIDTH (DATA_WIDTH)
) passthrough_aggregator_i (
    .core_clk,
    .resetn,
    .in_feature        (in_feature),
    .in_feature_valid  (passthrough_aggregator_in_feature_valid),
    .out_feature       (passthrough_aggregator_out_feature),
    .out_feature_valid (passthrough_aggregator_out_valid),
);


sum_aggregator #(
    .DATA_WIDTH (DATA_WIDTH)
) sum_aggregator_i (
    .core_clk,
    .resetn,
    .in_feature        (in_feature),
    .in_feature_valid  (sum_aggregator_in_feature_valid),
    .acc_feature       (accumulator),
    .out_feature       (sum_aggregator_out_feature),
    .out_feature_valid (sum_aggregator_out_valid),
);

mean_aggregator #(
    .DATA_WIDTH (DATA_WIDTH)
) mean_aggregator_i (
    .core_clk,
    .resetn,
    .in_feature_valid   (mean_aggregator_in_feature_valid),
    .in_feature         (in_feature),
    .acc_feature        (accumulator),
    .out_feature_valid  (mean_aggregator_out_valid),
    .out_feature        (mean_aggregator_out_feature),
    .accumulation_count (feature_accumulation_count)
);

// === ADD AGGREGATOR INSTANCE

always_comb begin
    // Write first feature into accumulator directly regardless of chosen aggregation function
    passthrough_aggregator_in_feature_valid = ~feature_accumulation_count && in_feature_valid;

    sum_aggregator_in_feature_valid = |feature_accumulation_count && in_feature_valid && (aggregation_function_sel == top_pkg::SUM);
    mean_aggregator_in_feature_valid = |feature_accumulation_count && in_feature_valid && (aggregation_function_sel == top_pkg::MEAN);

    updated_feature_ready = ~feature_accumulation_count ? passthrough_aggregator_out_valid
                            : (aggregation_function_sel == top_pkg::SUM) ? sum_aggregator_out_valid
                            : (aggregation_function_sel == top_pkg::MEAN) ? mean_aggregator_out_valid
                            : '0;

    in_feature_ready = in_feature_valid && updated_feature_ready;
end

always_ff @(posedge core_clk or negedge resetn) begin
    if (!resetn) begin
        feature_accumulation_count <= '0;
        accumulator                <= '0;
    
    end else if (reset_accumulator) begin
        feature_accumulation_count <= '0;
        accumulator                <= '0;
        
    end else if (updated_feature_ready) begin
        feature_accumulation_count <= feature_accumulation_count + 1'b1;

        if (~feature_accumulation_count) begin
            accumulator <= passthrough_aggregator_out_feature;
        end else begin
            
            case (aggregation_function_sel)

            top_pkg::SUM: accumulator <= sum_aggregator_out_feature;
            top_pkg::MEAN: accumulator <= mean_aggregator_out_feature;

            endcase
        end
    end
end

endmodule