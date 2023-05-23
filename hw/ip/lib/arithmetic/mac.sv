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
    parameter FLOAT_WIDTH = 32
) (
    input  logic                              core_clk,            
    input  logic                              resetn,

`ifdef FLOAT_MAC
    input  logic [31:0]                       a,
    input  logic [31:0]                       b,
    output logic [31:0]                       acc,
    input  logic [31:0]                       overwrite_data,
`elsif BFP_MAC
    input  bfp_msfp12_s                       a,
    input  bfp_msfp12_s                       b,
    output bfp_msfp12_s                       acc,
`elsif FORMAL_MAC
    input  fv_fixed_point_s                   a,
    input  fv_fixed_point_s                   b,
    output fv_fixed_point_s                   acc,
`endif
    
    input  logic                              en,
    input  logic                              overwrite
);

// TO DO: define bfp_msfp12_s, fv_fixed_point_s types

`ifdef FLOAT_MAC

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

`elsif BFP_MAC

`elsif FORMAL_MAC

    fixed_point_mac #(
        .WIDTH(FLOAT_WIDTH)
    ) fixed_point_mac_i (
        .core_clk,
        .resetn,
        .en,
        .a,
        .b,
        .acc 
    );

`endif

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

