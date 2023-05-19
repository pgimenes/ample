//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:
// Design Name: 
// Module Name: fixed_point_mac
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

module fixed_point_mac #(
    parameter WIDTH = 32
) (
    input  logic                              core_clk,            
    input  logic                              resetn,

    input  logic                              en,             // enable accumulator update
    input  logic [WIDTH-1:0]                  a,
    input  logic [WIDTH-1:0]                  b,

    output logic [WIDTH-1:0]                  acc             // accumulator
);

logic [WIDTH-1:0] acc_reg;

// Accumulator
always_ff @(posedge core_clk or negedge resetn) begin
    if (!resetn) begin
        acc_reg <= '0;
    end else begin
        acc_reg <= en ? (acc_reg + a*b) : acc_reg;
    end
end

assign acc = acc_reg;


endmodule