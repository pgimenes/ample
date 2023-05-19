import top_pkg::*;

module activation_core #(
    parameter FLOAT_WIDTH = 32
) (
    input  logic core_clk,
    input  logic resetn,

    input  logic [$bits(ACTIVATION_FUNCTION_e)-1:0] activation,
    input  logic [FLOAT_WIDTH-1:0] in_feature,
    output logic [FLOAT_WIDTH-1:0] out_feature
);

always_comb begin
    case (activation)

    top_pkg::NONE: begin
        out_feature = in_feature;
    end

    top_pkg::RELU: begin
        out_feature = in_feature[FLOAT_WIDTH-1] ? '0 : in_feature;
    end

    endcase
end

endmodule