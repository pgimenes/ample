
// simplified version of register staller
// buffer stage for valid/ready protocol
// when stall occurs, wait to drain all data before accepting new transactions

module register_staller_simple #(
    parameter DATA_WIDTH = 32
) (
    input  logic core_clk,
    input  logic resetn,

    input  logic in_valid,
    input  logic [DATA_WIDTH-1:0] in_data,
    output logic in_ready,

    output logic out_valid,
    output logic [DATA_WIDTH-1:0] out_data,
    input  logic out_ready
);

logic [DATA_WIDTH-1:0] out;
logic                  out_full;
logic [DATA_WIDTH-1:0] hld;
logic                  hld_full;
logic                  accept_upstream;
logic                  accept_downstream;
logic                  write_out;
logic                  write_hld;

// Write logic
always_comb begin
    in_ready = !hld_full;
    accept_upstream = (in_valid && in_ready);
    
    write_out = !out_full || (out_full && accept_downstream);
    write_hld = out_full && !accept_downstream;
end

// OUT/HLD regs
always_ff @(posedge core_clk or negedge resetn) begin
    if (!resetn) begin
        out <= '0;
        hld <= '0;
    end else if (accept_upstream) begin
        if (write_out) begin
            out <= in_data;
        end else if (write_hld) begin
            hld <= in_data;
        end
    end
end

// Full flags
always_ff @(posedge core_clk or negedge resetn) begin
    if (!resetn) begin
        out_full <= '0;
        hld_full <= '0;
    end else begin
        out_full <= accept_upstream && write_out ? '1
                : accept_downstream && out_full ? '0
                : out_full;

        hld_full <= accept_upstream && write_hld ? '1
                : accept_downstream && !out_full && hld_full ? '0
                : hld_full;
    end
end

// Read logic
always_comb begin
    accept_downstream = (out_valid && out_ready);

    out_valid = out_full || hld_full;

    out_data = out_full ? out
            : hld_full ? hld
            : out;
end

endmodule