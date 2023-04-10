import top_pkg::*;

module weight_buffer #(
    parameter AXI_ADDR_WIDTH = 34,
    parameter AXI_DATA_WIDTH = 512,
    parameter MAX_BYTE_COUNT = 4096
) (
    input logic core_clk,
    input logic resetn,

    // Controller -> Weight Buffer Interface
    input  logic                                                nsb_weight_buffer_req_valid,
    output logic                                                nsb_weight_buffer_req_ready,
    input  NSB_WBUFF_REQ_t                                      nsb_weight_buffer_req,
    output logic                                                nsb_weight_buffer_resp_valid, // valid only for now
    output NSB_WBUFF_RESP_t                                     nsb_weight_buffer_resp,

    // Weight Buffer -> AXI Memory Interconnect
    output logic [AXI_ADDR_WIDTH-1:0]                       weight_buffer_axi_interconnect_axi_araddr,
    output logic [1:0]                                      weight_buffer_axi_interconnect_axi_arburst,
    output logic [3:0]                                      weight_buffer_axi_interconnect_axi_arcache,
    output logic [3:0]                                      weight_buffer_axi_interconnect_axi_arid,
    output logic [7:0]                                      weight_buffer_axi_interconnect_axi_arlen,
    output logic [0:0]                                      weight_buffer_axi_interconnect_axi_arlock,
    output logic [2:0]                                      weight_buffer_axi_interconnect_axi_arprot,
    output logic [3:0]                                      weight_buffer_axi_interconnect_axi_arqos,
    output logic [2:0]                                      weight_buffer_axi_interconnect_axi_arsize,
    output logic                                            weight_buffer_axi_interconnect_axi_arvalid,
    input  logic                                            weight_buffer_axi_interconnect_axi_arready,
    input  logic [AXI_DATA_WIDTH-1:0]                       weight_buffer_axi_interconnect_axi_rdata,
    input  logic [3:0]                                      weight_buffer_axi_interconnect_axi_rid,
    input  logic                                            weight_buffer_axi_interconnect_axi_rlast,
    output logic                                            weight_buffer_axi_interconnect_axi_rready,
    input  logic [1:0]                                      weight_buffer_axi_interconnect_axi_rresp,
    input  logic                                            weight_buffer_axi_interconnect_axi_rvalid,
    
    output logic [AXI_ADDR_WIDTH-1:0]                       weight_buffer_axi_interconnect_axi_awaddr,
    output logic [1:0]                                      weight_buffer_axi_interconnect_axi_awburst,
    output logic [3:0]                                      weight_buffer_axi_interconnect_axi_awcache,
    output logic [3:0]                                      weight_buffer_axi_interconnect_axi_awid,
    output logic [7:0]                                      weight_buffer_axi_interconnect_axi_awlen,
    output logic [0:0]                                      weight_buffer_axi_interconnect_axi_awlock,
    output logic [2:0]                                      weight_buffer_axi_interconnect_axi_awprot,
    output logic [3:0]                                      weight_buffer_axi_interconnect_axi_awqos,
    input  logic                                            weight_buffer_axi_interconnect_axi_awready,
    output logic [2:0]                                      weight_buffer_axi_interconnect_axi_awsize,
    output logic                                            weight_buffer_axi_interconnect_axi_awvalid,
    input  logic [3:0]                                      weight_buffer_axi_interconnect_axi_bid,
    output logic                                            weight_buffer_axi_interconnect_axi_bready,
    input  logic [1:0]                                      weight_buffer_axi_interconnect_axi_bresp,
    input  logic                                            weight_buffer_axi_interconnect_axi_bvalid,
    output logic [AXI_DATA_WIDTH-1:0]                       weight_buffer_axi_interconnect_axi_wdata,
    output logic                                            weight_buffer_axi_interconnect_axi_wlast,
    input  logic                                            weight_buffer_axi_interconnect_axi_wready,
    output logic [63:0]                                     weight_buffer_axi_interconnect_axi_wstrb,
    output logic                                            weight_buffer_axi_interconnect_axi_wvalid
    
);

typedef enum logic [3:0] {
    IDLE            = 4'd0,
    REQUEST_READ    = 4'd1,
    WAIT_RESP       = 4'd2,
    WRITE_BUFFER    = 4'd3,
    SEND_DONE       = 4'd4
} fetch_state_e;


// ==================================================================================================================================================
// Declarations
// ==================================================================================================================================================

fetch_state_e fetch_state, fetch_state_n;
NSB_WBUFF_REQ_t nsb_request;

logic [$clog2(MAX_BYTE_COUNT)-1:0]          required_weight_bits;

// AXI Read Master
logic                                       fetch_req_valid;
logic                                       fetch_req_ready;
logic [31:0]                                fetch_start_address;
logic [$clog2(MAX_BYTE_COUNT)-1:0]          fetch_byte_count;

logic                                       fetch_resp_valid;
logic                                       fetch_resp_ready;
logic                                       fetch_resp_last;
logic [AXI_DATA_WIDTH-1:0]                      fetch_resp_data;



// ==================================================================================================================================================
// Instances
// ==================================================================================================================================================

// axi_read_master #(
//     .MAX_BYTE_COUNT                         (MAX_BYTE_COUNT),
//     .ADDRESS_WIDTH                          (AXI_ADDR_WIDTH),
//     .DATA_WIDTH                             (512)
// ) axi_read_master_i (
//     .clk                                    (core_clk),
//     .resetn                                 (resetn),

//     .fetch_req_valid,
//     .fetch_req_ready,
//     .fetch_start_address,
//     .fetch_byte_count,
//     .fetch_resp_valid,
//     .fetch_resp_ready,
//     .fetch_resp_last,
//     .fetch_resp_data,

//     // AXI interface
//     .axi_araddr                             (weight_buffer_axi_interconnect_axi_araddr),
//     .axi_arburst                            (weight_buffer_axi_interconnect_axi_arburst),
//     .axi_arcache                            (weight_buffer_axi_interconnect_axi_arcache),
//     .axi_arid                               (weight_buffer_axi_interconnect_axi_arid),
//     .axi_arlen                              (weight_buffer_axi_interconnect_axi_arlen),
//     .axi_arlock                             (weight_buffer_axi_interconnect_axi_arlock),
//     .axi_arprot                             (weight_buffer_axi_interconnect_axi_arprot),
//     .axi_arqos                              (weight_buffer_axi_interconnect_axi_arqos),
//     .axi_arsize                             (weight_buffer_axi_interconnect_axi_arsize),
//     .axi_arvalid                            (weight_buffer_axi_interconnect_axi_arvalid),
//     .axi_arready                            (weight_buffer_axi_interconnect_axi_arready),
//     .axi_rdata                              (weight_buffer_axi_interconnect_axi_rdata),
//     .axi_rid                                (weight_buffer_axi_interconnect_axi_rid),
//     .axi_rlast                              (weight_buffer_axi_interconnect_axi_rlast),
//     .axi_rvalid                             (weight_buffer_axi_interconnect_axi_rvalid),
//     .axi_rready                             (weight_buffer_axi_interconnect_axi_rready),
//     .axi_rresp                              (weight_buffer_axi_interconnect_axi_rresp)
// );

// ==================================================================================================================================================
// Logic
// ==================================================================================================================================================

logic [AXI_DATA_WIDTH-1:0] received_beat;
logic received_final_beat;

// always_comb begin
//     required_weight_bits = nsb_request.in_features * nsb_request.out_features * weight_width;
// end

// always_ff @(posedge core_clk or negedge resetn) begin
//     if (!resetn) begin
//         fetch_state             <= IDLE;
//         nsb_request      <= '0;
//     end else begin
//         fetch_state <= fetch_state_n;

//         if (nsb_weight_buffer_req_valid && nsb_weight_buffer_req_ready) begin
//             nsb_request      <= nsb_weight_buffer_req;
//         end
//     end
// end

// always_comb begin
//     fetch_state_n = fetch_state;

//     case (fetch_state_n)
//         IDLE:         fetch_state_n = (nsb_weight_buffer_req_valid && nsb_weight_buffer_req_ready) ? REQUEST_READ : IDLE;
//         REQUEST_READ: fetch_state_n = fetch_req_ready ? WAIT_RESP : REQUEST_READ;
//         WAIT_RESP:    fetch_state_n = fetch_resp_valid ? WRITE_BUFFER : WAIT_RESP;
//         WRITE_BUFFER: fetch_state_n = received_final_beat ? SEND_DONE : WAIT_RESP;
//         SEND_DONE:    fetch_state_n = IDLE;
//     endcase
// end

// TO DO
// always_comb begin
//     fetch_req_valid         = (fetch_state == REQUEST_READ);
//     fetch_start_address     = nsb_request.starting_address;
//     fetch_resp_ready        = (fetch_state == WAIT_RESP);
// end

// always_comb begin
//     nsb_weight_buffer_req_ready = (fetch_state == IDLE);
//     nsb_weight_buffer_resp_valid = '0; // TO DO
//     nsb_weight_buffer_resp = '0; // TO DO
// end


// Tie AXI read signals to 0
always_comb begin
    weight_buffer_axi_interconnect_axi_araddr       = '0;
    weight_buffer_axi_interconnect_axi_arburst      = '0;
    weight_buffer_axi_interconnect_axi_arcache      = '0;
    weight_buffer_axi_interconnect_axi_arid         = '0;
    weight_buffer_axi_interconnect_axi_arlen        = '0;
    weight_buffer_axi_interconnect_axi_arlock       = '0;
    weight_buffer_axi_interconnect_axi_arprot       = '0;
    weight_buffer_axi_interconnect_axi_arqos        = '0;
    weight_buffer_axi_interconnect_axi_arsize       = '0;
    weight_buffer_axi_interconnect_axi_arvalid      = '0;
    weight_buffer_axi_interconnect_axi_rready       = '0;
end

// Tie AXI Write Signals to 0
always_comb begin
    weight_buffer_axi_interconnect_axi_awaddr      = '0;
    weight_buffer_axi_interconnect_axi_awburst     = '0;
    weight_buffer_axi_interconnect_axi_awcache     = '0;
    weight_buffer_axi_interconnect_axi_awid        = '0;
    weight_buffer_axi_interconnect_axi_awlen       = '0;
    weight_buffer_axi_interconnect_axi_awlock      = '0;
    weight_buffer_axi_interconnect_axi_awprot      = '0;
    weight_buffer_axi_interconnect_axi_awqos       = '0;
    weight_buffer_axi_interconnect_axi_awsize      = '0;
    weight_buffer_axi_interconnect_axi_awvalid     = '0;
    weight_buffer_axi_interconnect_axi_bready      = '0;
    weight_buffer_axi_interconnect_axi_wdata       = '0;
    weight_buffer_axi_interconnect_axi_wlast       = '0;
    weight_buffer_axi_interconnect_axi_wstrb       = '0;
    weight_buffer_axi_interconnect_axi_wvalid      = '0;
end

// ==================================================================================================================================================
// Assertions
// ==================================================================================================================================================

endmodule