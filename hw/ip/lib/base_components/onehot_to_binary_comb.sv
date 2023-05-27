/*
 * Does what it says on the tin basically
 */

module onehot_to_binary_comb #(
    parameter INPUT_WIDTH = 32
) (
	input logic [INPUT_WIDTH-1:0]           input_data,
  	output logic [$clog2(INPUT_WIDTH)-1:0]  output_data
);

always_comb begin
    if (input_data == '0) output_data = '0;
    else begin
        for (int i = 0; i < INPUT_WIDTH; i++) begin
            if (input_data[i]) begin
                output_data = i;
                break;
            end
        end
    end
end

endmodule