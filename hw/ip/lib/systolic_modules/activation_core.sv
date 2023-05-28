import top_pkg::*;

module activation_core #(
    parameter FLOAT_WIDTH = 32
) (
    input  logic [$bits(ACTIVATION_FUNCTION_e)-1:0] sel_activation,
    
    input  logic                                    in_feature_valid,
    input  logic [FLOAT_WIDTH-1:0]                  in_feature,
    
    output logic                                    activated_feature_valid,
    output logic [FLOAT_WIDTH-1:0]                  activated_feature,

    input  logic [31:0]                             layer_config_leaky_relu_alpha_value
);

logic                   leaky_relu_activation_valid;
logic [FLOAT_WIDTH-1:0] leaky_relu_activation;

always_comb begin
    case (sel_activation)

    top_pkg::NONE: begin
        activated_feature = in_feature;
    end

    top_pkg::RELU: begin
        activated_feature = in_feature[FLOAT_WIDTH-1] ? '0 : in_feature;
    end

    top_pkg::LEAKY_RELU: begin
        activated_feature = in_feature[FLOAT_WIDTH-1] ? leaky_relu_activation : in_feature;
    end

    endcase
end

fp_mult upsampler_mult (
    .s_axis_a_tvalid      (in_feature_valid),
    .s_axis_a_tdata       (in_feature),

    .s_axis_b_tvalid      ('1),
    .s_axis_b_tdata       (layer_config_leaky_relu_alpha_value),
    
    .m_axis_result_tvalid (leaky_relu_activation_valid),
    .m_axis_result_tdata  (leaky_relu_activation)
);

assign activated_feature_valid = (sel_activation == top_pkg::NONE) ? in_feature_valid
                               : (sel_activation == top_pkg::RELU) ? in_feature_valid
                               : (sel_activation == top_pkg::LEAKY_RELU) ? leaky_relu_activation_valid
                               : '0;

endmodule