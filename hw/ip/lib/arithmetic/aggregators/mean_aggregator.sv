import top_pkg::*;

module mean_aggregator #(
    parameter DATA_WIDTH = 32,
    parameter MAX_ACC_COUNT = top_pkg::MAX_FEATURE_COUNT
) (
    input  logic                  core_clk,
    input  logic                  resetn,

    input  logic                  in_feature_valid,
    input  logic [DATA_WIDTH-1:0] in_feature,

    input  logic [DATA_WIDTH-1:0] acc_feature,

    output logic                  out_feature_valid,
    output logic [DATA_WIDTH-1:0] out_feature,

    input [$clog2(MAX_ACC_COUNT)-1:0] accumulation_count
);

// ==================================================================================================================================================
// Declarations
// ==================================================================================================================================================

logic [DATA_WIDTH-1:0] acc_feature_factor;
logic [DATA_WIDTH-1:0] weighted_acc_feature;
logic [DATA_WIDTH-1:0] weighted_acc_feature_q;

logic [DATA_WIDTH-1:0] in_feature_factor;
logic [DATA_WIDTH-1:0] weighted_in_feature_q;

logic [31:0] acc_cnt_padded;
logic [31:0] acc_cnt_float;

logic [31:0] acc_cnt_inc_padded;
logic [31:0] acc_cnt_inc_float;

logic in_feature_valid_q;
logic in_feature_valid_q2;
logic in_feature_valid_q3;

// ==================================================================================================================================================
// Instantiations
// ==================================================================================================================================================

int32_to_float32 acc_cnt_int2float_i (
  .aclk                 (core_clk),
  .aclken               ('1),
  .aresetn              (resetn),
  
  .s_axis_a_tvalid      (in_feature_valid),
  .s_axis_a_tdata       (acc_cnt_padded),
  
  .m_axis_result_tvalid (),
  .m_axis_result_tdata  (acc_cnt_float)
);

int32_to_float32 acc_cnt_inc_int2float_i (
  .aclk                 (core_clk),
  .aclken               ('1),
  .aresetn              (resetn),

  .s_axis_a_tvalid      (in_feature_valid),
  .s_axis_a_tdata       (acc_cnt_inc_padded),
  
  .m_axis_result_tvalid (),
  .m_axis_result_tdata  (acc_cnt_inc_float)
);

float_reciprocal acc_cnt_float_reciprocal (
  .aclk                 (core_clk),
  .aclken               ('1),
  .aresetn              (resetn),
  
  .s_axis_a_tvalid      (in_feature_valid_q),
  .s_axis_a_tdata       (acc_cnt_float),
  
  .m_axis_result_tvalid (),
  .m_axis_result_tdata  (in_feature_factor)
);

fp_div acc_feature_factor_div (
  .aclk                 (core_clk),
  .aclken               ('1),
  .aresetn              (resetn),
  
  .s_axis_a_tvalid      (in_feature_valid_q),
  .s_axis_a_tdata       (acc_cnt_float),
  
  .s_axis_b_tvalid      (in_feature_valid_q),
  .s_axis_b_tdata       (acc_cnt_inc_float),
  
  .m_axis_result_tvalid (),
  .m_axis_result_tdata  (acc_feature_factor)
);

// Multiplier is combinatorial
fp_mult weighted_acc_feat_factor_mult (
  .s_axis_a_tvalid(in_feature_valid_q2),
  .s_axis_a_tdata(acc_feature),

  .s_axis_b_tvalid(in_feature_valid_q2),
  .s_axis_b_tdata(acc_feature_factor),
  
  .m_axis_result_tvalid(),
  .m_axis_result_tdata(weighted_acc_feature)
);

// Multiplier is combinatorial
fp_mult weighted_in_feat_factor_mult (
  .s_axis_a_tvalid(in_feature_valid_q2),
  .s_axis_a_tdata(in_feature),

  .s_axis_b_tvalid(in_feature_valid_q2),
  .s_axis_b_tdata(in_feature_factor),
  
  .m_axis_result_tvalid(),
  .m_axis_result_tdata(weighted_in_feature)
);

// Adder is combinatorial
fp_add fp_add_i (
  .s_axis_a_tvalid              ('1),
  .s_axis_a_tdata               (weighted_acc_feature_q),
  
  .s_axis_b_tvalid              ('1),
  .s_axis_b_tdata               (weighted_in_feature_q),

  .m_axis_result_tvalid         (),
  .m_axis_result_tdata          (out_feature)
);

// ==================================================================================================================================================
// Logic
// ==================================================================================================================================================

always_ff @(posedge core_clk or negedge resetn) begin
    if (!resetn) begin
        in_feature_valid_q <= '0;
        in_feature_valid_q2 <= '0;
        in_feature_valid_q3 <= '0;

        weighted_acc_feature_q <= '0;
        weighted_in_feature_q <= '0;
    end else begin
        in_feature_valid_q <= in_feature_valid;
        in_feature_valid_q2 <= in_feature_valid_q;
        in_feature_valid_q3 <= in_feature_valid_q2;

        weighted_acc_feature_q <= weighted_acc_feature;
        weighted_in_feature_q <= weighted_in_feature;
    end
end

// assign acc_cnt_padded = {{(32 - $clog2(MAX_ACC_COUNT)){1'b0}}, accumulation_count};
assign acc_cnt_padded = accumulation_count;
assign acc_cnt_inc_padded = accumulation_count + 1'b1;

assign out_feature_valid = in_feature_valid_q3;

endmodule