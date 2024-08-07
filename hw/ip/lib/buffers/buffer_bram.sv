

module buffer_bram #(
    parameter DATA_WIDTH_A = 512,
    parameter ADDR_WIDTH_A = 6,   
    parameter DATA_WIDTH_B = 32, 
    parameter ADDR_WIDTH_B = 10  
) (
    input logic                    clka,
    input logic                    ena,
    input logic                    wea,
    input logic [ADDR_WIDTH_A-1:0] addra,
    input logic [DATA_WIDTH_A-1:0] dina,

    input logic                    clkb,
    input logic                    enb,
    input logic [ADDR_WIDTH_B-1:0] addrb,
    output logic [DATA_WIDTH_B-1:0] doutb
);

    localparam NUM_BLOCKS = DATA_WIDTH_A / DATA_WIDTH_B;

    logic [DATA_WIDTH_A-1:0] bram [(2**ADDR_WIDTH_A)-1:0];

    always_ff @(posedge clka) begin
        if (ena) begin
            if (wea) begin
                bram[addra] <= dina; // Write entire 512-bit word
            end
        end
    end

    always_ff @(posedge clkb) begin
        if (enb) begin
            automatic int block_index = addrb % NUM_BLOCKS; // Calculate which block to access within the 512-bit word
            automatic int block_addr = addrb / NUM_BLOCKS;  // Calculate the row in the BRAM

            doutb <= bram[block_addr][block_index*DATA_WIDTH_B +: DATA_WIDTH_B];
        end
    end

endmodule
