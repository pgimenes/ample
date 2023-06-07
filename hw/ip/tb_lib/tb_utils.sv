
package tb_utils;

parameter NUM_BITS = 32;

function logic [$clog2(NUM_BITS)-1:0] onehot_to_binary(input logic [NUM_BITS-1:0] onehot);
    logic [$clog2(NUM_BITS)-1:0] binary;
    integer i;

    for (i = 0; i < NUM_BITS; i = i + 1) begin
        if (onehot[i] == 1'b1) begin
        binary = i;
        break;
        end
    end

    return binary;
    endfunction

endpackage