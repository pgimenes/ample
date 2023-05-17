//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:
// Design Name: 
// Module Name: sys_array
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

module sys_array #(
    parameter FLOAT_WIDTH = 32,
    parameter MATRIX_N = 4
) (
    input  logic                                                 core_clk,            
    input  logic                                                 rstn,
    
    input  logic [MATRIX_N-1:0] [31:0]                           sys_array_forward,
    input  logic [MATRIX_N-1:0]                                  sys_array_forward_valid,
    input  logic [MATRIX_N-1:0] [31:0]                           sys_array_down,
    input  logic [MATRIX_N-1:0]                                  sys_array_down_valid,

    input  logic                                                 shift,

    // Accumulators for each Processing Element, from which output matrix can be constructed
    output logic [MATRIX_N-1:0] [MATRIX_N-1:0] [FLOAT_WIDTH-1:0] sys_array_pe_acc
);

// ============================================================================================
// Declarations
// ============================================================================================

//   <    row    > <    col   > <      data      >
logic [MATRIX_N:0] [MATRIX_N:0] [FLOAT_WIDTH-1:0]          sys_array_pe_forward;
logic [MATRIX_N:0] [MATRIX_N:0] [0:0]                      sys_array_pe_forward_valid;
logic [MATRIX_N:0] [MATRIX_N:0] [FLOAT_WIDTH-1:0]          sys_array_pe_down;
logic [MATRIX_N:0] [MATRIX_N:0] [0:0]                      sys_array_pe_down_valid;

logic [MATRIX_N:0] [MATRIX_N:0]                            overwrite;
logic [MATRIX_N:0] [MATRIX_N:0] [FLOAT_WIDTH-1:0]          overwrite_data;

// ============================================================================================
// Instances
// ============================================================================================

for (genvar row = 0; row < MATRIX_N; row++) begin : rows_gen
    for (genvar col = 0; col < MATRIX_N; col++) begin : cols_gen
  
        sys_array_pe #(
            .FLOAT_WIDTH(FLOAT_WIDTH)
        ) sys_array_pe_i (
            .core_clk,
            .rstn,
            .pe_forward_in              (sys_array_pe_forward            [row]   [col]   ),
            .pe_forward_in_valid        (sys_array_pe_forward_valid      [row]   [col]   ),
            .pe_down_in                 (sys_array_pe_down               [row]   [col]   ),
            .pe_down_in_valid           (sys_array_pe_down_valid         [row]   [col]   ),
            .pe_forward_out             (sys_array_pe_forward            [row]   [col+1] ),
            .pe_forward_out_valid       (sys_array_pe_forward_valid      [row]   [col+1] ),
            .pe_down_out                (sys_array_pe_down               [row+1] [col] ),
            .pe_down_out_valid          (sys_array_pe_down_valid         [row+1] [col] ),

            .overwrite                  (overwrite                       [row]   [col]   ),
            .overwrite_data             (sys_array_pe_acc                [row+1]   [col]),

            .pe_acc                     (sys_array_pe_acc                [row]   [col]   )
        );

    end : cols_gen
end : rows_gen

// ============================================================================================
// Logic
// ============================================================================================

for (genvar row=0; row < MATRIX_N; row++) begin
    assign sys_array_pe_forward         [row][0] = sys_array_forward      [row];
    assign sys_array_pe_forward_valid   [row][0] = sys_array_forward_valid[row];
end

for (genvar col=0; col < MATRIX_N; col++) begin
    assign sys_array_pe_down            [0][col] = sys_array_down      [col];
    assign sys_array_pe_down_valid      [0][col] = sys_array_down_valid[col];
end

assign overwrite = shift ? '1 : '0;

// ============================================================================================
// Assertions
// ============================================================================================

// for (genvar row=0; row < MATRIX_N; row++) begin

//     P_forward_valid_propagates: assert property (
//         @(posedge core_clk) disable iff (!rstn)
//         sys_array_forward_valid[row] |-> ##(MATRIX_N) sys_array_pe_forward_valid[row][MATRIX_N]
//     );

// end

// for (genvar col=0; col < MATRIX_N; col++) begin

//     P_down_valid_propagates: assert property (
//         @(posedge core_clk) disable iff (!rstn)
//         sys_array_down_valid[col] |-> ##(MATRIX_N) sys_array_pe_down_valid[MATRIX_N][col]
//     );

// end


endmodule