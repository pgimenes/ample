parameter MAX_BYTE_COUNT = 10000000;
parameter DATA_WIDTH     = 512;
parameter ADDRESS_WIDTH  = 34;

interface axi_read_master_fv_intf (
    input logic core_clk,
    input logic resetn,

    // Request interface
    input logic                                       fetch_req_valid,
    input logic                                       fetch_req_ready,
    input logic [31:0]                                fetch_start_address,
    input logic [$clog2(MAX_BYTE_COUNT)-1:0]          fetch_byte_count,

    // Response interface
    input logic                                       fetch_resp_valid,
    input logic                                       fetch_resp_ready,
    input logic                                       fetch_resp_last,
    input logic [DATA_WIDTH-1:0]                      fetch_resp_data,

    // AXI Read-Only Interface
    input logic [ADDRESS_WIDTH-1:0]                   axi_araddr,
    input logic [1:0]                                 axi_arburst,
    input logic [3:0]                                 axi_arcache,
    input logic [3:0]                                 axi_arid,
    input logic [7:0]                                 axi_arlen,
    input logic [0:0]                                 axi_arlock,
    input logic [2:0]                                 axi_arprot,
    input logic [3:0]                                 axi_arqos,
    input logic [2:0]                                 axi_arsize,
    input logic                                       axi_arvalid,
    input logic                                       axi_arready,
    input logic [DATA_WIDTH-1:0]                      axi_rdata,
    input logic [3:0]                                 axi_rid,
    input logic                                       axi_rlast,
    input logic                                       axi_rvalid,
    input logic                                       axi_rready,
    input logic [1:0]                                 axi_rresp
);

logic accept_req;
logic accept_axi_req;

integer transaction_count, beat_count, byte_count;
integer beats_expectation, trans_expectation;

assign accept_req = fetch_req_valid && fetch_req_ready;
assign accept_axi_req = axi_arvalid && axi_arready;

// assign beats_expectation = (byte_count % 64 > 0) ? (byte_count / 64) + 1 : (byte_count / 64);
// assign trans_expectation = (beats_expectation % 64 > 0) ? (beats_expectation / 64) + 1 : (beats_expectation / 64);

always_ff @(posedge core_clk or negedge resetn) begin
    if (!resetn) begin
        byte_count          = 0;
        transaction_count   = 0;
        beat_count          = 0;
        beats_expectation   = 0;
        trans_expectation   = 0;
    end else if (fetch_req_ready) // starting to issue fetch responses
        byte_count          = 0;
        transaction_count   = 0;
        beat_count          = 0;
        beats_expectation   = 0;
        trans_expectation   = 0;
    begin
        if (accept_req) begin
            byte_count          = fetch_byte_count;

            beats_expectation = byte_count / 64;
            if (byte_count % 64 > 0) beats_expectation = beats_expectation + 1;

            trans_expectation = beats_expectation / 64;
            if (beats_expectation % 64 > 0) trans_expectation = trans_expectation + 1;
        end

        if (accept_axi_req) begin 
            transaction_count   = transaction_count + 1;
            beat_count          = beat_count + axi_arlen + 1;
        end
    end
end

P_Drive_AXI_after_fetch_request: assert property (
  @(posedge core_clk) disable iff (!resetn)
  (accept_req && fetch_byte_count > 0) |=> axi_arvalid );

// If making a request, burst size should not exceed 64
P_Never_overflow_data_bus: assert property (
  @(posedge core_clk) disable iff (!resetn)
  (axi_arvalid && axi_arready) |=> !(axi_arlen > 63) );

// If making a request, burst size should not exceed 64
P_Fill_data_bus: assert property (
  @(posedge core_clk) disable iff (!resetn)
  (axi_arvalid && axi_arready) |=> (axi_arsize == 3'b110) );

// C_Eventually_Drain: cover property (
//   @(posedge clk) disable iff (!resetn)
//   accept_req |-> s_eventually fetch_resp_valid );

// When responses begin, number of beats requested should equal expectation from byte count
P_Correct_Beat_Count: assert property (
  @(posedge core_clk) disable iff (!resetn)
  fetch_resp_valid && fetch_resp_ready |-> beat_count == beats_expectation );

// When responses begin, number of issued transactions should equal expectation from byte count
P_Correct_Transaction_Count: assert property (
  @(posedge core_clk) disable iff (!resetn)
  fetch_resp_valid && fetch_resp_ready |-> transaction_count == trans_expectation );

// Multiple transactions
C_Multiple_Transactions: cover property (
  @(posedge core_clk) disable iff (!resetn)
  (trans_expectation == 10) && (transaction_count == trans_expectation) );

P_example: assert property (
  @(posedge core_clk) disable iff (!resetn)
  byte_count == 8000 && fetch_resp_valid |-> transaction_count == 2 );

endinterface

bind axi_read_master axi_read_master_fv_intf props (.*);