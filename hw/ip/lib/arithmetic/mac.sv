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
    parameter DATA_WIDTH  = 32,
    parameter PRECISION   = "FLOAT_32"
) (
    input  logic                              core_clk,            
    input  logic                              resetn,

    input  logic                              in_valid,
    output logic                              in_ready,

    input  logic [DATA_WIDTH-1:0]             a,
    input  logic [DATA_WIDTH-1:0]             b,

    output logic [DATA_WIDTH-1:0]             accumulator,
    
    input  logic                              overwrite,
    input  logic [DATA_WIDTH-1:0]             overwrite_data
    
);

if (PRECISION == "FLOAT_32") begin

    float_mac #(
        .FLOAT_WIDTH(FLOAT_WIDTH)
    ) float_mac_i (
        .core_clk,            
        .resetn,
        
        .in_valid,
        .in_ready,
        
        .a,
        .b,
        
        .overwrite,
        .overwrite_data,
        
        .accumulator
    );

end else if (PRECISION == "FIXED_16") begin

    fixed_point_mac #(
        .WIDTH          (FLOAT_WIDTH),
        .DATA_WIDTH     (DATA_WIDTH)
    ) fixed_point_mac_i (
        .core_clk,            
        .resetn,
        
        .in_valid,
        .in_ready,
        
        .a,
        .b,
        
        .overwrite,
        .overwrite_data,
        
        .accumulator
    );

end

// ======================================================================================================
// Assertions
// ======================================================================================================

P_acc_constant: cover property (
    @(posedge core_clk) disable iff (!resetn)
    (in_valid && in_ready) |=> (accumulator == $past(accumulator, 1))
);

endmodule

