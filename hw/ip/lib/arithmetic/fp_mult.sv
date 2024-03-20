module fp_mult (
	input  logic [31:0]	in1,
	input  logic [31:0] in2,
	output logic [31:0] res
);

wire [7:0] exp1 = in1[30:23];
wire [7:0] exp2 = in2[30:23];
wire [22:0] mant1 = in1[22:0];
wire [22:0] mant2 = in2[22:0];

wire [64:0] shifted_man = ({1'b1,mant1}*{1'b1,mant2});

wire [7:0] corrected_exponent = exp1 + exp2 - (shifted_man[47] ? 8'd126 : 8'd127);
wire [22:0] corrected_man = shifted_man[47] ? shifted_man[46:24] : shifted_man[45:23];

assign res = (in1 == 0 | in2 == 0) ? 0 : {in1[31] ^ in2[31], corrected_exponent, corrected_man};

endmodule