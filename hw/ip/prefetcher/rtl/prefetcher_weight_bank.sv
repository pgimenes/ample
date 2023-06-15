import top_pkg::*;

/*

Features to implement:
- Resetting after layer finished. Accept NSB request while in FEATURES_WAITING,
  clear all counters and flags and transition to REQ_FETCH

*/

module prefetcher_weight_bank #(
    parameter PRECISION = top_pkg::FLOAT_32,
    parameter DATA_WIDTH = 32,
    parameter AXI_ADDRESS_WIDTH = 34,
    parameter AXI_DATA_WIDTH    = 512,
    parameter MAX_FEATURE_COUNT = (top_pkg::MAX_FEATURE_COUNT)
) (
    input logic                                               core_clk,
    input logic                                               resetn,

    // NSB -> Prefetcher Interface
    input  logic                                              nsb_prefetcher_weight_bank_req_valid,
    output logic                                              nsb_prefetcher_weight_bank_req_ready,
    input  NSB_PREF_REQ_t                                     nsb_prefetcher_weight_bank_req,

    output logic                                              nsb_prefetcher_weight_bank_resp_valid,
    output NSB_PREF_RESP_t                                    nsb_prefetcher_weight_bank_resp,

    // Prefetcher Adjacency Read Master -> AXI Memory Interconnect
    // Request interface
    output logic                                              weight_bank_axi_rm_fetch_req_valid,
    input  logic                                              weight_bank_axi_rm_fetch_req_ready,
    output logic [AXI_ADDRESS_WIDTH-1:0]                      weight_bank_axi_rm_fetch_start_address,
    output logic [$clog2(MAX_FETCH_REQ_BYTE_COUNT)-1:0]       weight_bank_axi_rm_fetch_byte_count,

    // Response interface
    input  logic                                              weight_bank_axi_rm_fetch_resp_valid,
    output logic                                              weight_bank_axi_rm_fetch_resp_ready,
    input  logic                                              weight_bank_axi_rm_fetch_resp_last,
    input  logic [AXI_DATA_WIDTH-1:0]                         weight_bank_axi_rm_fetch_resp_data,
    input  logic [3:0]                                        weight_bank_axi_rm_fetch_resp_axi_id,

    // Weight Channels: FTE -> Prefetcher Weight Bank
    input  logic                                              weight_channel_req_valid,
    output logic                                              weight_channel_req_ready,
    input  WEIGHT_CHANNEL_REQ_t                               weight_channel_req,

    output logic                                              weight_channel_resp_valid,
    input  logic                                              weight_channel_resp_ready,
    output WEIGHT_CHANNEL_RESP_t                              weight_channel_resp,

    input  logic [31:0]                                       layer_config_weights_address_lsb_value
    
);

typedef enum logic [3:0] {
    WEIGHT_BANK_FSM_IDLE             = 4'd0,
    WEIGHT_BANK_FSM_FETCH_REQ        = 4'd1,
    WEIGHT_BANK_FSM_WAIT_RESP        = 4'd2,
    WEIGHT_BANK_FSM_WRITE            = 4'd3,
    WEIGHT_BANK_FSM_WEIGHTS_WAITING  = 4'd4,
    WEIGHT_BANK_FSM_DUMP_WEIGHTS     = 4'd5
} WEIGHT_BANK_FSM_e;

// ==================================================================================================================================================
// Declarations
// ==================================================================================================================================================

NSB_PREF_REQ_t                                     nsb_prefetcher_weight_bank_req_q;
WEIGHT_BANK_FSM_e                                  weight_bank_state, weight_bank_state_n;
logic                                              accepting_weight_channel_resp;

// Weight Matrix row FIFOs
// ----------------------------------------------------------------

logic [MAX_FEATURE_COUNT-1:0]                               row_fifo_push;
logic [31:0]                                                row_fifo_in_data;

logic [MAX_FEATURE_COUNT-1:0]                               row_fifo_pop;
logic [MAX_FEATURE_COUNT-1:0]                               row_fifo_out_valid;
logic [MAX_FEATURE_COUNT-1:0] [31:0]                        row_fifo_out_data;

logic [MAX_FEATURE_COUNT-1:0] [$clog2(MAX_FEATURE_COUNT):0] row_fifo_count;
logic [MAX_FEATURE_COUNT-1:0]                               row_fifo_empty;
logic [MAX_FEATURE_COUNT-1:0]                               row_fifo_full;

// Fetching
// ----------------------------------------------------------------

logic [$clog2(MAX_FEATURE_COUNT):0]   features_written;
logic [$clog2(MAX_FEATURE_COUNT):0]   rows_fetched;
logic [$clog2(AXI_DATA_WIDTH/32)-1:0] feature_offset;
logic [4:0]                           expected_responses;
logic                                 weight_bank_axi_rm_fetch_resp_last_q;
logic [AXI_DATA_WIDTH-1:0]            weight_bank_axi_rm_fetch_resp_data_q;
logic [3:0]                           weight_bank_axi_rm_fetch_resp_axi_id_q;


logic [$clog2(MAX_FEATURE_COUNT*4)-1:0] bytes_per_row;
logic [$clog2(MAX_FEATURE_COUNT*4)-1:0] bytes_per_row_padded;

// Driving weight channel responses
logic [$clog2(MAX_FEATURE_COUNT)-1:0] required_pulses;
logic [MAX_FEATURE_COUNT-1:0]                      row_pop_shift;
logic [$clog2(MAX_FEATURE_COUNT):0]                row_counter;

logic reset_weights;

// ==================================================================================================================================================
// Instances
// ==================================================================================================================================================

for (genvar row = 0; row < MAX_FEATURE_COUNT; row++) begin
    ultraram_fifo #(
        .WIDTH (32),
        .DEPTH (MAX_FEATURE_COUNT)
    ) weight_matrix_row (
        .core_clk,
        .resetn,
        
        .push       (row_fifo_push      [row]),
        .in_data    (row_fifo_in_data),
        
        .pop            (row_fifo_pop       [row]),
        .reset_read_ptr (reset_weights),
        .out_valid  (row_fifo_out_valid [row]),
        .out_data   (row_fifo_out_data  [row]),
        
        .count      (row_fifo_count     [row]),
        .empty      (row_fifo_empty     [row]),
        .full       (row_fifo_full      [row])
    );

    assign row_fifo_push      [row] = (weight_bank_state == WEIGHT_BANK_FSM_WRITE) & (row == (rows_fetched - 1));
    
    // Pop FIFO when currently valid rows are being dumped
    assign row_fifo_pop       [row] = (weight_bank_state == WEIGHT_BANK_FSM_DUMP_WEIGHTS) && row_pop_shift[row] && !row_fifo_empty[row] && accepting_weight_channel_resp;
end

// ==================================================================================================================================================
// Logic
// ==================================================================================================================================================

always_ff @(posedge core_clk or negedge resetn) begin
    if (!resetn) begin
        weight_bank_state <= WEIGHT_BANK_FSM_IDLE;
    end else begin
        weight_bank_state <= weight_bank_state_n;
    end
end

always_comb begin
    weight_bank_state_n = weight_bank_state;

    case (weight_bank_state)

    WEIGHT_BANK_FSM_IDLE: begin
        weight_bank_state_n = nsb_prefetcher_weight_bank_req_valid && (nsb_prefetcher_weight_bank_req.req_opcode == top_pkg::WEIGHTS) ? WEIGHT_BANK_FSM_FETCH_REQ : WEIGHT_BANK_FSM_IDLE;
    end

    WEIGHT_BANK_FSM_FETCH_REQ: begin
        weight_bank_state_n = weight_bank_axi_rm_fetch_req_ready ? WEIGHT_BANK_FSM_WAIT_RESP : WEIGHT_BANK_FSM_FETCH_REQ;
    end

    WEIGHT_BANK_FSM_WAIT_RESP: begin
        weight_bank_state_n = weight_bank_axi_rm_fetch_resp_valid ? WEIGHT_BANK_FSM_WRITE : WEIGHT_BANK_FSM_WAIT_RESP;
    end

    WEIGHT_BANK_FSM_WRITE: begin
        weight_bank_state_n = 
                            // Finished writing all features for entire matrix
                            (feature_offset == 4'd15) && (rows_fetched == nsb_prefetcher_weight_bank_req_q.out_features) && (expected_responses == '0) ? WEIGHT_BANK_FSM_WEIGHTS_WAITING
                            
                            // Finished writing all features for current row
                            : (feature_offset == 4'd15) && (expected_responses == '0) ? WEIGHT_BANK_FSM_FETCH_REQ
                            
                            // Finished writing all features for current AXI response beat
                            : (feature_offset == 4'd15) ? WEIGHT_BANK_FSM_WAIT_RESP
                            
                            // Still writing features for current AXI response beat
                            : WEIGHT_BANK_FSM_WRITE;
    end

    WEIGHT_BANK_FSM_WEIGHTS_WAITING: begin
        weight_bank_state_n = weight_channel_req_valid ? WEIGHT_BANK_FSM_DUMP_WEIGHTS : WEIGHT_BANK_FSM_WEIGHTS_WAITING;
    end

    WEIGHT_BANK_FSM_DUMP_WEIGHTS: begin
        weight_bank_state_n = weight_channel_resp_valid && weight_channel_resp_ready && weight_channel_resp.done ? WEIGHT_BANK_FSM_WEIGHTS_WAITING
                            : WEIGHT_BANK_FSM_DUMP_WEIGHTS;
    end

    endcase
end

// NSB requests
// ----------------------------------------------------------------

always_ff @(posedge core_clk or negedge resetn) begin
    if (!resetn) begin
        nsb_prefetcher_weight_bank_req_q <= '0;

    // Receiving a request from the NSB
    end else if (nsb_prefetcher_weight_bank_req_valid && nsb_prefetcher_weight_bank_req_ready) begin
        nsb_prefetcher_weight_bank_req_q <= nsb_prefetcher_weight_bank_req;
    end
end

always_comb begin
    nsb_prefetcher_weight_bank_req_ready = (weight_bank_state == WEIGHT_BANK_FSM_IDLE);
    
    nsb_prefetcher_weight_bank_resp_valid = (weight_bank_state == WEIGHT_BANK_FSM_WRITE) && (weight_bank_state_n == WEIGHT_BANK_FSM_WEIGHTS_WAITING);
    
    nsb_prefetcher_weight_bank_resp.response_type = top_pkg::WEIGHTS;
    nsb_prefetcher_weight_bank_resp.nodeslot = '0; // not used
    nsb_prefetcher_weight_bank_resp.partial = ~row_fifo_full; // 0 when row FIFOs are saturated

end

// Weight read master fetch request logic
// ----------------------------------------------------------------

always_comb begin
    weight_bank_axi_rm_fetch_req_valid = (weight_bank_state == WEIGHT_BANK_FSM_FETCH_REQ);
    weight_bank_axi_rm_fetch_byte_count = nsb_prefetcher_weight_bank_req_q.in_features * 4;
    
    bytes_per_row = nsb_prefetcher_weight_bank_req_q.in_features * 4;
    bytes_per_row_padded = {bytes_per_row[$clog2(MAX_FEATURE_COUNT*4)-1:6], 6'b0} + (|bytes_per_row[5:0] ? 'd64 : '0); // round up to nearest multiple of 64
    weight_bank_axi_rm_fetch_start_address = nsb_prefetcher_weight_bank_req_q.start_address + rows_fetched * bytes_per_row_padded;
end

always_ff @(posedge core_clk or negedge resetn) begin
    if (!resetn) begin
        rows_fetched <= '0;
        expected_responses <= '0;

        weight_bank_axi_rm_fetch_resp_last_q   <= '0;
        weight_bank_axi_rm_fetch_resp_data_q   <= '0;
        weight_bank_axi_rm_fetch_resp_axi_id_q <= '0;

    // Accepting request to weight read master
    end else if (weight_bank_axi_rm_fetch_req_valid && weight_bank_axi_rm_fetch_req_ready) begin
        rows_fetched <= rows_fetched + 1'b1;
        
        // divide by 16 (features per AXI beat), round up
        expected_responses <= nsb_prefetcher_weight_bank_req_q.in_features[$clog2(MAX_FEATURE_COUNT):4] + (|nsb_prefetcher_weight_bank_req_q.in_features[3:0] ? 1'b1 : 1'b0);

    // Accepting response from weight read master
    end else if (weight_bank_axi_rm_fetch_resp_valid && weight_bank_axi_rm_fetch_resp_ready) begin
        expected_responses <= expected_responses - 1'b1;

        // Register response payloads
        weight_bank_axi_rm_fetch_resp_last_q   <= weight_bank_axi_rm_fetch_resp_last;
        weight_bank_axi_rm_fetch_resp_data_q   <= weight_bank_axi_rm_fetch_resp_data;
        weight_bank_axi_rm_fetch_resp_axi_id_q <= weight_bank_axi_rm_fetch_resp_axi_id;
    end
end

assign weight_bank_axi_rm_fetch_resp_ready = (weight_bank_state == WEIGHT_BANK_FSM_WAIT_RESP);

// Weight FIFO write logic
// ----------------------------------------------------------------

always_comb begin
    row_fifo_in_data = 
                        feature_offset == '0        ? weight_bank_axi_rm_fetch_resp_data_q [511 : 480]
                        : feature_offset == 1'b1    ? weight_bank_axi_rm_fetch_resp_data_q [479 : 448]
                        : feature_offset == 2'b10   ? weight_bank_axi_rm_fetch_resp_data_q [447 : 416]
                        : feature_offset == 2'b11   ? weight_bank_axi_rm_fetch_resp_data_q [415 : 384]
                        : feature_offset == 3'b100  ? weight_bank_axi_rm_fetch_resp_data_q [383 : 352]
                        : feature_offset == 3'b101  ? weight_bank_axi_rm_fetch_resp_data_q [351 : 320]
                        : feature_offset == 3'b110  ? weight_bank_axi_rm_fetch_resp_data_q [319 : 288]
                        : feature_offset == 3'b111  ? weight_bank_axi_rm_fetch_resp_data_q [287 : 256]
                        : feature_offset == 4'b1000 ? weight_bank_axi_rm_fetch_resp_data_q [255 : 224]
                        : feature_offset == 4'b1001 ? weight_bank_axi_rm_fetch_resp_data_q [223 : 192]
                        : feature_offset == 4'b1010 ? weight_bank_axi_rm_fetch_resp_data_q [191 : 160]
                        : feature_offset == 4'b1011 ? weight_bank_axi_rm_fetch_resp_data_q [159 : 128]
                        : feature_offset == 4'b1100 ? weight_bank_axi_rm_fetch_resp_data_q [127 : 96]
                        : feature_offset == 4'b1101 ? weight_bank_axi_rm_fetch_resp_data_q [95 : 64]
                        : feature_offset == 4'b1110 ? weight_bank_axi_rm_fetch_resp_data_q [63 : 32]
                        : feature_offset == 4'b1111 ? weight_bank_axi_rm_fetch_resp_data_q [31 : 0]
                        : '0;
end

always_ff @(posedge core_clk or negedge resetn) begin
    if (!resetn) begin
        feature_offset <= '0;
        features_written <= '0;

    // Write into weight FIFO
    end else if (weight_bank_state == WEIGHT_BANK_FSM_WRITE) begin
        feature_offset <= feature_offset == 4'd15 ? '0 : (feature_offset + 1'b1);
        features_written <= features_written + 1'b1;
    end
end

// Weight dumping through Weight Channel
// ----------------------------------------------------------------

assign weight_channel_req_ready = (weight_bank_state == WEIGHT_BANK_FSM_WEIGHTS_WAITING);

// Shift register to flush through weights matrix diagonally
for (genvar row = 1; row < MAX_FEATURE_COUNT; row++) begin
    always_ff @(posedge core_clk or negedge resetn) begin
        if (!resetn) begin
            row_pop_shift[row] <= '0;

        // Clear shift register when starting new weight dump
        end else if ((weight_bank_state == WEIGHT_BANK_FSM_WEIGHTS_WAITING) && (weight_bank_state_n == WEIGHT_BANK_FSM_DUMP_WEIGHTS)) begin
            row_pop_shift[row] <= '0;

        // Shift register when accepting weight channel response
        end else if (weight_channel_resp_valid && weight_channel_resp_ready) begin
            row_pop_shift[row] <= row_pop_shift[row-1];
        end
    end
end

// Round up in features to the nearest multiple of 16
assign required_pulses = {nsb_prefetcher_weight_bank_req_q.in_features[$clog2(MAX_FEATURE_COUNT)-1:4], 4'd0} + (|nsb_prefetcher_weight_bank_req_q.in_features[3:0] ? 'd16 : '0);

always_ff @(posedge core_clk or negedge resetn) begin
    if (!resetn) begin
        row_pop_shift[0] <= '0; // Head of shift register
        row_counter <= '0;
    
    // Starting new feature dump, reset all flags and counters
    end else if ((weight_bank_state == WEIGHT_BANK_FSM_WEIGHTS_WAITING) && (weight_bank_state_n == WEIGHT_BANK_FSM_DUMP_WEIGHTS)) begin
        row_pop_shift[0] <= '1;
        row_counter <= '0;

    // Pulse matrix
    end else if (|row_fifo_pop) begin
        // Increment when popping any rows, but latch at '1
        row_counter <= (row_counter == required_pulses) ? row_counter : (row_counter + 1'b1);

        // If accepting weight channel response, new data is available on all row FIFOs
        // so shift register and clear popped rows flag
        row_pop_shift[0] <= !(row_counter >= (required_pulses - 1'b1));

    end
end

always_comb begin
    // Issue weight channel response when new data is available on all row FIFOs following a pop
    weight_channel_resp_valid = (weight_bank_state == WEIGHT_BANK_FSM_DUMP_WEIGHTS) && (&row_fifo_out_valid) && |row_pop_shift;

    weight_channel_resp.data       = row_fifo_out_data;
    weight_channel_resp.valid_mask = row_pop_shift & ~row_fifo_empty;
    
    weight_channel_resp.done       = (weight_channel_resp.valid_mask == '0);
    
    accepting_weight_channel_resp = (weight_channel_resp_valid && weight_channel_resp_ready);
end

// When finished dumping weights, reset read pointer so the same weights can be used for the next FTE pass
assign reset_weights = (weight_bank_state == WEIGHT_BANK_FSM_DUMP_WEIGHTS) && (weight_bank_state_n == WEIGHT_BANK_FSM_WEIGHTS_WAITING);

endmodule