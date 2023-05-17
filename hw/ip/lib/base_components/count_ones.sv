module count_ones #(
    parameter INPUT_WIDTH = 32
) (
  input  logic [INPUT_WIDTH-1:0]         data,
  output logic [$clog2(INPUT_WIDTH)-1:0] count
);
  
  always_comb begin
    count = '0;
    for (int i = 0; i < INPUT_WIDTH; i++) begin
      if (data[i] == 1'b1)
        count = count + 1'b1;
    end
  end
  
endmodule