// will not work if input not onehot

// TO DO: make registered

module onehot_to_binary #(
    parameter INPUT_WIDTH = 32
) (
	input logic                             core_clk,
  	input logic                             resetn,
	input logic [INPUT_WIDTH-1:0]           input_data,
  	output logic [$clog2(INPUT_WIDTH)-1:0]  output_data
);
  
// always_ff @(posedge clk or negedge resetn) begin
// 	if (!resetn) begin
// 		output_data <= 0;
//     end else begin
//       	for (int i = 0; i < INPUT_WIDTH; i++) begin
// 			if (input_data[i] == 1) begin
// 				output_data <= i;
//                 break;
// 			end
//         end
//     end
// end

endmodule