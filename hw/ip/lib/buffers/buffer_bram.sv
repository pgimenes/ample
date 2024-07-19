

module buffer_bram #(
    parameter DATA_WIDTH_A = 512, // Total data width for port A
    parameter ADDR_WIDTH_A = 6,   // Address width for port A
    parameter DATA_WIDTH_B = 32,  // Data width for port B
    parameter ADDR_WIDTH_B = 10   // Address width for port B, expanded to include byte addressing within 512-bit blocks
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

    // Calculating number of 32-bit blocks in a 512-bit word
    localparam NUM_BLOCKS = DATA_WIDTH_A / DATA_WIDTH_B;

    // Memory array declaration: same number of 512-bit rows, but each element now has sub-word access
    logic [DATA_WIDTH_A-1:0] bram [(2**ADDR_WIDTH_A)-1:0];

    // Port A operations
    always_ff @(posedge clka) begin
        if (ena) begin
            if (wea) begin
                bram[addra] <= dina; // Write entire 512-bit word
            end
        end
    end

    // Port B operations
    always_ff @(posedge clkb) begin
        if (enb) begin
            // Compute which 32-bit word within the 512-bit block to read
            automatic int block_index = addrb % NUM_BLOCKS; // Calculate which block to access within the 512-bit word
            automatic int block_addr = addrb / NUM_BLOCKS;  // Calculate the row in the BRAM

            // Access the specific 32-bit word
            doutb <= bram[block_addr][block_index*DATA_WIDTH_B +: DATA_WIDTH_B];
        end
    end

endmodule
