module binary_to_onehot
#(
    parameter WIDTH = 4 // The input width of the binary number
) (
    input wire [WIDTH-1:0] binary_input, // The input binary number
    output wire [(1<<WIDTH)-1:0] one_hot_output // The output one-hot representation
);

for (genvar i = 0; i < (1<<WIDTH); i++) begin : one_hot_gen
    assign one_hot_output[i] = (i == binary_input);
end

endmodule