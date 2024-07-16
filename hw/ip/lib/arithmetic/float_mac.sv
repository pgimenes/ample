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
    input  logic                              resetn,

    input  logic                              in_valid,
    output logic                              in_ready,
    input  logic [FLOAT_WIDTH-1:0]            a,
    input  logic [FLOAT_WIDTH-1:0]            b,

    input  logic                              overwrite,
    input  logic [FLOAT_WIDTH-1:0]            overwrite_data,
    
    output logic [FLOAT_WIDTH-1:0]            accumulator             // accumulator
);

// ==================================================================================================================================================
// Declarations
// ==================================================================================================================================================

logic [FLOAT_WIDTH-1:0] acc_reg;

logic                   fp_mult_result_valid_comb;
logic [FLOAT_WIDTH-1:0] fp_mult_result_comb;

logic                   fp_mult_result_valid_q;
logic [FLOAT_WIDTH-1:0] fp_mult_result_q;

logic                   fp_add_result_valid_comb;
logic [FLOAT_WIDTH-1:0] fp_add_result_comb;
logic                   fp_add_result_valid;
logic [FLOAT_WIDTH-1:0] fp_add_result;


logic                   busy;

// ==================================================================================================================================================
// Instances
// ==================================================================================================================================================


`ifdef SIMULATION_QUICK

assign fp_mult_result_valid_comb = in_valid; //&& in_ready;
assign fp_mult_result_comb = a;
assign fp_add_result_valid_comb = fp_mult_result_valid_q;
assign fp_add_result_comb = acc_reg;

`else
logic [FLOAT_WIDTH-1:0] a_gated;
logic [FLOAT_WIDTH-1:0] b_gated;

// logic [FLOAT_WIDTH-1:0] fp_mult_result_q_gated;
logic [FLOAT_WIDTH-1:0] acc_reg_gated;



assign a_gated = in_valid ? a : '0;
assign b_gated = in_valid ? b : '0;

// assign fp_mult_result_q_gated = fp_mult_result_valid_q ? fp_mult_result_q : '0;

fp_mult multiplier_i (
//   .s_axis_a_tvalid(in_valid && in_ready),
  .in1(a_gated),

//   .s_axis_b_tvalid(in_valid && in_ready),
  .in2(b_gated),
  
//   .m_axis_result_tvalid(fp_mult_result_valid_comb),
  .res(fp_mult_result_comb)
);
assign fp_mult_result_valid_comb = in_valid; //&& in_ready;

fp_add adder_i (
//   .s_axis_a_tvalid              (busy && fp_mult_result_valid_q),


  .in1               (fp_mult_result_q),
  
//   .s_axis_b_tvalid              (busy && fp_mult_result_valid_q),
  .in2               (acc_reg),

//   .m_axis_result_tvalid         (fp_add_result_valid_comb),
  .res          (fp_add_result_comb)
);
assign fp_add_result_valid_comb =  fp_mult_result_valid_q;

`endif



// ==================================================================================================================================================
// Logic
// ==================================================================================================================================================

// Register multiplication output
// -----------------------------------

always_ff @(posedge core_clk or negedge resetn) begin
    if (!resetn) begin
        fp_mult_result_valid_q <= '0;
        fp_mult_result_q       <= '0;

        fp_add_result_valid <= '0;
        // fp_add_result <= '0;
    end else begin
        fp_mult_result_valid_q <= fp_mult_result_valid_comb;
        fp_mult_result_q       <= fp_mult_result_comb;

        fp_add_result_valid <= fp_add_result_valid_comb;
        // fp_add_result <= fp_add_result_comb;
    end
end

// Accumulator
// -----------------------------------

always_ff @(posedge core_clk or negedge resetn) begin
    if (!resetn) begin
        acc_reg <= '0;
    end else begin
        acc_reg <= overwrite ? overwrite_data
                    : fp_add_result_valid_comb ? fp_add_result_comb
                    : acc_reg;
    end
end

assign accumulator = acc_reg;

// // Handle backpressure
// // -----------------------------------

// always_ff @(posedge core_clk or negedge resetn) begin
//     if (!resetn) begin
//         busy <= '0;

//     end else begin
//         busy <= 
//                 // Accepting new update request
//                 in_valid && in_ready ? 1'b1
                
//                 // Done with update request
//                 : busy && fp_add_result_valid ? 1'b0

//                 : busy;
//     end
// end

assign in_ready = !busy;

endmodule