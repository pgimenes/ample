import top_pkg::*;

module sum_aggregator #(
    parameter DATA_WIDTH = 32,
    parameter PRECISION = top_pkg::FLOAT_32
) (
    input  logic                   core_clk,
    input  logic                   resetn,

    input  logic                   in_feature_valid,
    input  logic [DATA_WIDTH-1:0]  in_feature,
    
    input  logic [DATA_WIDTH-1:0]  acc_feature,

    output logic                   out_feature_valid,
    output logic [DATA_WIDTH-1:0]  out_feature
);

if (PRECISION == top_pkg::FLOAT_32) begin
  
`ifdef SIMULATION_QUICK

    assign out_feature_valid = in_feature_valid;
    assign out_feature = in_feature;

`else

    // Adder is combinatorial
    fp_add fp_add_i (
        .in1               (acc_feature),
        .in2               (in_feature),
        .res          (out_feature)
    );
    assign out_feature_valid = in_feature_valid;
    
`endif

end else begin

    // All other precisions have simple full adder
    assign out_feature_valid = in_feature_valid;
    assign out_feature       = acc_feature + in_feature;

end 

endmodule