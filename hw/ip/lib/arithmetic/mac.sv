//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:
// Design Name: 
// Module Name: mac
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

module mac #(
    parameter FLOAT_WIDTH = 32,
    parameter PRECISION = "FLOAT_32"
) (
    input  logic                              core_clk,            
    input  logic                              resetn,

    input  logic                              en,

    input  logic [FLOAT_WIDTH-1:0]            a,
    input  logic [FLOAT_WIDTH-1:0]            b,

    output logic [FLOAT_WIDTH-1:0]            acc,
    
    input  logic                              overwrite,
    input  logic [FLOAT_WIDTH-1:0]            overwrite_data
    
);

if (PRECISION == "FLOAT_32") begin
    float_mac #(
        .FLOAT_WIDTH(FLOAT_WIDTH)
    ) float_mac_i (
        .core_clk,
        .resetn,

        .en,
        .a,
        .b,
        
        .overwrite,
        .overwrite_data,

        .acc 
    );
end else if (PRECISION == "FIXED_16") begin

    fixed_point_mac #(
        .WIDTH          (FLOAT_WIDTH)
    ) fixed_point_mac_i (
        .core_clk,
        .resetn,
        .en,
        .a,
        .b,
        .acc 
    );

end

// ======================================================================================================
// Assertions
// ======================================================================================================

P_acc_grows: assert property (
    @(posedge core_clk) disable iff (!resetn)
    en |=> acc >= $past(acc, 1)
);

P_acc_constant: cover property (
    @(posedge core_clk) disable iff (!resetn)
    en |=> acc == $past(acc, 1)
);

endmodule

