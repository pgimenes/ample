//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:
// Design Name: 
// Module Name: float_mac
// Project Name:
// Target Devices:
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module float_mac #(
    parameter FLOAT_WIDTH = 32
) (
    input  logic                              core_clk,            
    input  logic                              rstn,

    input  logic                              en,             // enable accumulator update
    input  logic [FLOAT_WIDTH-1:0]            a,
    input  logic [FLOAT_WIDTH-1:0]            b,
    
    output logic [FLOAT_WIDTH-1:0]            acc             // accumulator
);

logic [FLOAT_WIDTH-1:0] acc_reg;
logic [FLOAT_WIDTH-1:0] fp_add_result;
logic             fp_add_result_valid;
logic [FLOAT_WIDTH-1:0] fp_mult_result;
logic             fp_mult_result_valid;

fp_mult fp_mult_i (
  .s_axis_a_tvalid(en),
  .s_axis_a_tdata(a),

  .s_axis_b_tvalid(en),
  .s_axis_b_tdata(b),
  
  .m_axis_result_tvalid(fp_mult_result_valid),
  .m_axis_result_tdata(fp_mult_result)
);

fp_add fp_add_i (
  .s_axis_a_tvalid              (en),
  .s_axis_a_tdata               (fp_mult_result),
  
  .s_axis_b_tvalid              (en),
  .s_axis_b_tdata               (acc_reg),

  .m_axis_result_tvalid         (fp_add_result_valid),
  .m_axis_result_tdata          (fp_add_result)
);

// Accumulator
always_ff @(posedge core_clk or negedge rstn) begin
    if (!rstn) begin
        acc_reg <= '0;
    end else begin
        acc_reg <= en && fp_mult_result_valid && fp_add_result_valid ? fp_add_result : acc_reg;
    end
end

assign acc = acc_reg;

endmodule