// import _pkg::*;


paramter MAX_OPCODES = 4;

typedef struct packed {
    logic [4:0]     op;    
    logic [2:0]     input_type;
    logic           output;
    
} ACT_OPCODE;



module comp_block #(
  parameter WIDTH = 32
) (
  input sys_clk,
  input sys_rstn,
  input logic [WIDTH-1:0] in1,
  input logic in1_valid,
  output logic in1_ready,

  input logic [WIDTH-1:0] in2,
  input logic in2_valid,
  output logic in2_ready,

  input ACT_OPCODE [MAX_OPCODES-1:0] op_list,
  input logic op_list_valid,

  output logic [WIDTH-1:0] out,
  input logic out_ready,
  output logic out_valid

);

logic [MAX_OPCODES-1:0]       idx;
logic [WIDTH-1:0]             result_buffer;
logic                         result_buffer_valid;
ACT_OPCODE [MAX_OPCODES-1:0]  op_list_q;



//Buffer Op List
always_ff @(posedge sys_clk or negedge sys_rstn) begin 
  if(!sys_rstn)
    op_list_q <= 0;
  else if (op_list_valid)
    op_list_q <= op_list;
  
  
end

//Iterate through Op List
always_ff @(posedge sys_clk or negedge sys_rstn) begin 
  if(!sys_rstn)
    idx <= 0;
  else if (comp_block_out_ready && comp_block_out_valid)
    idx <= idx + 1; 

  else if (out_valid)
    idx <= 0; //IDLE state
end

//Assign Op
assign opcode = op_list_q[idx];

//Buffer Result
always_ff @(posedge sys_clk or negedge sys_rstn) begin 
  if(!sys_rstn)
    result_buffer <= 0;
    result_buffer_valid <= 0;
  else if (comp_block_out_ready && comp_block_out_valid)
    result_buffer <= comp_block_out;
    result_buffer_valid <= comp_block_out_valid;
end



//Code
//A,B
//A,Internal
//Internal


//External or Internal Inputs
//Op Code
always_comb begin
  case(opcode.input_type)
  //Case external inputs

  0: begin
    a = in1;
    b = in2;

    a_valid = in1_valid;
    b_valid = in2_valid;

    in1_ready = a_ready;
    in2_ready = b_ready;
  end
  //Case Internal and External Inputs
  1: begin
    a = result_buffer;
    a_valid = result_buffer_valid;

    b = in2;
    b_valid = in2_valid;
    in2_ready = b_ready;

  end
  //Case Internal Input Only
  2: begin
    a = result_buffer;
    a_valid = result_buffer_valid;
  end
  endcase
end


assign out_valid = (opcode.output && result_buffer_valid)? 1'b1 : 1'b0;
assign out = result_buffer;


//Compute Op
comp_block #(
  .WIDTH(WIDTH)
) comp_block_inst (
  .a(a),
  .a_valid(a_valid),
  .a_ready(a_ready),

  .b(b),
  .b_valid(b_valid),
  .b_ready(b_ready),

  .op(opcode.op),

  .out(out),
  .out_ready(comp_block_out_ready),
  .out_valid(comp_block_out_valid)
);



endmodule