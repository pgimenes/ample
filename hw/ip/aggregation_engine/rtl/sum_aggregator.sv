import top_pkg::*;

module sum_aggregator #(
    parameter DATA_WIDTH = 32
) (
    input  logic core_clk,
    input  logic resetn,

    input  logic                  in_feature_valid,
    input  logic [DATA_WIDTH-1:0] in_feature,
    
    input  logic [DATA_WIDTH-1:0] acc_feature,

    output logic                  out_feature_valid,
    output logic [DATA_WIDTH-1:0] out_feature
);

// Adder is combinatorial
fp_add fp_add_i (
  .s_axis_a_tvalid              (in_feature_valid),
  .s_axis_a_tdata               (acc_feature),
  
  .s_axis_b_tvalid              (in_feature_valid),
  .s_axis_b_tdata               (in_feature),

  .m_axis_result_tvalid         (out_feature_valid),
  .m_axis_result_tdata          (out_feature)
);

endmodule