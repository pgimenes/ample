module aggregation_buffer #(
    parameter NUM_SLOTS = 16,
    parameter WRITE_WIDTH = 64,
    parameter WRITE_DEPTH = 512,
    parameter READ_WIDTH = 32,
    parameter READ_DEPTH = 1024
) (
    input  logic                                           core_clk,
    input  logic                                           resetn,

    input  logic [NUM_SLOTS-1:0]                           write_enable,
    input  logic [NUM_SLOTS-1:0] [$clog2(WRITE_DEPTH)-1:0] write_address,
    input  logic [NUM_SLOTS-1:0] [WRITE_WIDTH-1:0]         write_data,

    input  logic [NUM_SLOTS-1:0]                           pop,
    output logic [NUM_SLOTS-1:0]                           out_feature_valid,
    output logic [NUM_SLOTS-1:0] [READ_WIDTH-1:0]          out_feature,
    
    output logic [NUM_SLOTS-1:0] [$clog2(READ_DEPTH)-1:0]  feature_count,
    output logic [NUM_SLOTS-1:0]                           slot_free
);

for (genvar slot = 0; slot < NUM_SLOTS; slot++) begin
    aggregation_buffer_slot #(
        .WRITE_WIDTH (WRITE_WIDTH),
        .WRITE_DEPTH (WRITE_DEPTH),
        .READ_WIDTH  (READ_WIDTH),
        .READ_DEPTH  (READ_DEPTH)
    ) slot_i (
        .core_clk           (core_clk),
        .resetn             (resetn),

        .write_enable       (write_enable   [slot]),
        .write_address      (write_address  [slot]),
        .write_data         (write_data     [slot]),

        .pop                (pop               [slot]),
        .out_feature_valid  (out_feature_valid [slot]),
        .out_feature        (out_feature       [slot]),

        .feature_count      (feature_count     [slot]),
        .slot_free          (slot_free         [slot])
    );
end

endmodule