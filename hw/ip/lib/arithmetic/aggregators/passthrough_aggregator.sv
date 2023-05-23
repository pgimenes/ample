import top_pkg::*;

module passthrough_aggregator #(
    parameter DATA_WIDTH = 32,
    parameter PRECISION = "FLOAT_32"
) (
    input  logic core_clk,
    input  logic resetn,

    input  logic                  in_feature_valid,
    input  logic [DATA_WIDTH-1:0] in_feature,
    output logic                  out_feature_valid,
    output logic [DATA_WIDTH-1:0] out_feature
);

assign out_feature       = in_feature;
assign out_feature_valid = in_feature_valid;

endmodule