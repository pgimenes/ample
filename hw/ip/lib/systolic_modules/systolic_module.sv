//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:
// Design Name: 
// Module Name: systolic_module
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

module systolic_module #(
    parameter FLOAT_WIDTH = 32,
    parameter MATRIX_N = 4
) (
    input  logic                                                 core_clk,            
    input  logic                                                 resetn,

    input  logic                                                 pulse_systolic_module,
    
    input  logic [MATRIX_N-1:0]                                  sys_module_forward_valid,
    input  logic [MATRIX_N-1:0] [31:0]                           sys_module_forward,
    
    input  logic [MATRIX_N-1:0]                                  sys_module_down_valid,
    input  logic [MATRIX_N-1:0] [31:0]                           sys_module_down,

    input  logic                                                 bias_valid,
    input  logic [FLOAT_WIDTH-1:0]                               bias,

    input  logic                                                 activation_valid,
    input  logic [$bits(top_pkg::ACTIVATION_FUNCTION_e)-1:0]     activation,
    
    input  logic                                                 shift_valid,

    // Accumulators for each Processing Element, from which output matrix can be constructed
    // One more row than required to shift in zeros into last row during SHIFT phase
    output logic [MATRIX_N:0] [MATRIX_N-1:0] [FLOAT_WIDTH-1:0]   sys_module_pe_acc,

    output logic                                                 diagonal_flush_done,

    input logic [31:0]                                           layer_config_leaky_relu_alpha_value
);

// ============================================================================================
// Declarations
// ============================================================================================

//   <    row    > <    col   > <      data      >
logic [MATRIX_N-1:0] [MATRIX_N-1:0] [0:0]                      sys_module_pe_forward_valid;
logic [MATRIX_N-1:0] [MATRIX_N-1:0] [FLOAT_WIDTH-1:0]          sys_module_pe_forward;
logic [MATRIX_N-1:0] [MATRIX_N-1:0] [0:0]                      sys_module_pe_down_valid;
logic [MATRIX_N-1:0] [MATRIX_N-1:0] [FLOAT_WIDTH-1:0]          sys_module_pe_down;

logic [MATRIX_N-1:0] forward_flush_done;
logic [MATRIX_N-1:0] down_flush_done;

// ============================================================================================
// Instances
// ============================================================================================

for (genvar row = 0; row < MATRIX_N; row++) begin : rows_gen
    for (genvar col = 0; col < MATRIX_N; col++) begin : cols_gen
  
        processing_element #(
            .FLOAT_WIDTH(FLOAT_WIDTH)
        ) pe_i (
            .core_clk,
            .resetn,

            .pulse_systolic_module      (pulse_systolic_module),

            .pe_forward_in_valid        (sys_module_pe_forward_valid      [row]   [col]   ),
            .pe_forward_in              (sys_module_pe_forward            [row]   [col]   ),
            
            .pe_down_in_valid           (sys_module_pe_down_valid         [row]   [col]   ),
            .pe_down_in                 (sys_module_pe_down               [row]   [col]   ),
            
            .pe_forward_out_valid       (sys_module_pe_forward_valid      [row]   [col+1] ),
            .pe_forward_out             (sys_module_pe_forward            [row]   [col+1] ),
            
            .pe_down_out_valid          (sys_module_pe_down_valid         [row+1] [col] ),
            .pe_down_out                (sys_module_pe_down               [row+1] [col] ),

            .bias_valid                 (bias_valid),
            .bias                       (bias),

            .activation_valid           (activation_valid),
            .activation                 (activation),

            .shift_valid                (shift_valid                                     ),
            .shift_data                 (sys_module_pe_acc                [row+1]   [col]),

            .pe_acc                     (sys_module_pe_acc                [row]   [col]   ),

            .layer_config_leaky_relu_alpha_value (layer_config_leaky_relu_alpha_value)
        );

    end : cols_gen
end : rows_gen

// Input to lowest row during SHIFT phase
assign sys_module_pe_acc [MATRIX_N] = '0;

// ============================================================================================
// Logic
// ============================================================================================

for (genvar row=0; row < MATRIX_N; row++) begin
    assign sys_module_pe_forward         [row][0] = sys_module_forward      [row];
    assign sys_module_pe_forward_valid   [row][0] = sys_module_forward_valid[row];

    assign forward_flush_done [row] = !sys_module_pe_forward_valid [row] [MATRIX_N-1];
end

for (genvar col=0; col < MATRIX_N; col++) begin
    assign sys_module_pe_down            [0][col] = sys_module_down      [col];
    assign sys_module_pe_down_valid      [0][col] = sys_module_down_valid[col];
    
    assign down_flush_done [col] = !sys_module_pe_down_valid [MATRIX_N-1] [col];
end

assign diagonal_flush_done = &forward_flush_done && &down_flush_done;


// ============================================================================================
// Assertions
// ============================================================================================

// for (genvar row=0; row < MATRIX_N; row++) begin

//     P_forward_valid_propagates: assert property (
//         @(posedge core_clk) disable iff (!resetn)
//         sys_module_forward_valid[row] |-> ##(MATRIX_N) sys_module_pe_forward_valid[row][MATRIX_N]
//     );

// end

// for (genvar col=0; col < MATRIX_N; col++) begin

//     P_down_valid_propagates: assert property (
//         @(posedge core_clk) disable iff (!resetn)
//         sys_module_down_valid[col] |-> ##(MATRIX_N) sys_module_pe_down_valid[MATRIX_N][col]
//     );

// end


endmodule