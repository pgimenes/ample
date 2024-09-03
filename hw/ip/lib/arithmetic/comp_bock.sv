
import comp_block_pkg::*;

module comp_block #(
  parameter WIDTH = 32
) (
  input logic [WIDTH-1:0] a,
  input logic a_valid,
  output logic a_ready,

  input logic [WIDTH-1:0] b,
  input logic b_valid,
  output logic b_ready,

  input logic [3:0] op,

  output logic [WIDTH-1:0] out,
  input logic out_ready,
  output logic out_valid

);
//Can make this a seperate thing as it does not fit into the tfe model - have to strobe values in
//Or might be more useful in TFE for GAT - keeps exp features loaded
//Look at papers
//Make this the activaiton unit?
//instruction buffer? Sequence of instructions to perform operation?
//Instruction needs to have external, or internal inputs a,b, which modules, and how many operations and what order

//Use float SiLu tb
//e.g SiLU

// logic buffer [WIDTH-1:0] out_buffer;
// logic out_ready;

logic [WIDTH-1:0]exp_a, exp_b;
logic [WIDTH-1:0]exp_out;
logic exp_in_ready,exp_out_valid;

logic [WIDTH-1:0]mul_a, mul_b;
logic [WIDTH-1:0]mul_out;
logic mul_in_ready,mul_out_valid;

logic [WIDTH-1:0]div_a, div_b;
logic [WIDTH-1:0]div_out;
logic div_in_ready,div_out_valid;

logic [WIDTH-1:0]add_a, add_b;
logic [WIDTH-1:0]add_out;
logic add_in_ready,add_out_valid;

logic [WIDTH-1:0]sub_a, sub_b;
logic [WIDTH-1:0]sub_out;
logic sub_in_ready,sub_out_valid;




always_comb begin
  case(op)
    out = 0;
    out_valid = 0;

    in_ready = 0;

    exp_a = 0;
    exp_in_valid = 0;

    mul_a = 0;
    mul_b = 0;
    mul_in_valid = 0;

    div_a = 0;
    div_b = 0;
    div_in_valid = 0;

    add_a = 0;
    add_b = 0;
    add_in_valid = 0;

    sub_a = 0;
    sub_b = 0;
    sub_in_valid = 0;

    EXP: begin
      exp_a = a;

      out = exp_out;
      out_valid = exp_out_valid;

      in_ready = exp_in_ready;
      exp_in_valid = a_valid;

    end

    MUL: begin
      mul_a = a;
      mul_b = b;

      out = mul_out;
      out_valid = mul_out_valid;

      in_ready = mul_in_ready;
      mul_in_valid = a_valid && b_valid; 
    end

    DIV: begin
      div_a = a;
      div_b = b;

      out = div_out;
      out_valid = div_out_valid;

      in_ready = div_in_ready;
      div_in_valid = a_valid && b_valid;
    end

    ADD: begin
      add_a = a;
      add_b = b;

      out = add_out;
      out_valid = add_out_valid;

      in_ready = add_in_ready;
      add_in_valid = a_valid && b_valid;
    end

    SUB: begin
      sub_a = a;
      sub_b = b;

      out = sub_out;
      out_valid = sub_out_valid;


      in_ready = sub_in_ready;
      sub_in_valid = a_valid && b_valid;
    end

    default: out = 0;


  endcase





end





endmodule