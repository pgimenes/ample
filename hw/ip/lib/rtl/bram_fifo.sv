
/*

When FIFO receives pop, read pointer is updated directly but new data is available
on out_data when out_valid is asserted (RAM reads take 3 cycles)

*/

module bram_fifo #(
    parameter WRITE_WIDTH = 64,
    parameter WRITE_DEPTH = 512,
    parameter READ_WIDTH = 32,
    parameter READ_DEPTH = 1024,
) (
    input  logic                        core_clk,
    input  logic                        resetn,

    input  logic                        push,
    input  logic [WRITE_WIDTH-1:0]      in_data,
    
    input  logic                        pop,
    output logic                        out_valid,
    output logic [READ_WIDTH-1:0]       out_data,
    
    output logic [$clog2(READ_DEPTH):0] count,
    output logic                        empty,
    output logic                        full
);

parameter WRITE_ADDR_WIDTH = $clog2(WRITE_DEPTH);
parameter READ_ADDR_WIDTH = $clog2(READ_DEPTH);

// ==================================================================================================================================================
// Declarations
// ==================================================================================================================================================

logic [WRITE_ADDR_WIDTH-1:0] wr_ptr;
logic [READ_ADDR_WIDTH-1:0] rd_ptr;

logic pop1, pop2;
logic wr_wrap, rd_wrap;

// ==================================================================================================================================================
// Logic
// ==================================================================================================================================================

aggregation_buffer_sdp_bram fifo (
  .clka     (core_clk),    // input wire clka
  .ena      ('1),      // input wire ena
  .wea      (push),      // input wire [0 : 0] wea
  .addra    (wr_ptr),  // input wire [8 : 0] addra
  .dina     (in_data),    // input wire [63 : 0] dina
  
  .clkb     (core_clk),    // input wire clkb
  .enb      ('1),      // input wire enb
  .addrb    (rd_ptr),  // input wire [9 : 0] addrb
  .doutb    (out_data),  // output wire [31 : 0] doutb
  
  .sleep    ('0)  // input wire sleep
);

always_ff @(posedge core_clk or negedge resetn) begin
    if (!resetn) begin
        wr_ptr <= '0;
        rd_ptr <= '0;

        pop1      <= '0;
        pop2      <= '0;
        out_valid <= '1;

        wr_wrap   <= '0;
        rd_wrap   <= '0;

        count     <= '0;
    end else begin
        if (push) begin
            wr_ptr <= wr_ptr + 1'b1;
            count <= count + 1'b1;
        end
        
        if (pop) begin
            rd_ptr <= rd_ptr + 1'b1;
            count <= count - 1'b1;
        end

        // Latch out_valid to 0 when pop or to 1, 3 cycles later
        // This accounts for RAM delay
        if (pop) out_valid <= '0;
        else if (pop2) out_valid <= '1;

        pop1 <= pop;
        pop2 <= pop1;

        if (wr_ptr == {AWIDTH{1'b1}} && push) wr_wrap <= !wr_wrap;
        if (rd_ptr == {AWIDTH{1'b1}} && pop) rd_wrap <= !rd_wrap;
    end
end

assign empty = (wr_ptr == rd_ptr) && !(wr_wrap ^ rd_wrap);
assign full = (wr_ptr == rd_ptr) && (wr_wrap ^ rd_wrap);

endmodule