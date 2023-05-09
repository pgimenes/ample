
import top_pkg::*;

module transformation_engine #(
    parameter FLOAT_WIDTH = 32,
    parameter AXI_ADDR_WIDTH = 32
) (
    input logic core_clk,
    input logic resetn,

    // Regbank Slave AXI interface
    input  logic [AXI_ADDR_WIDTH-1:0]             s_axi_awaddr,
    input  logic [2:0]                            s_axi_awprot,
    input  logic                                  s_axi_awvalid,
    output logic                                  s_axi_awready,
    input  logic [31:0]                           s_axi_wdata,
    input  logic [3:0]                            s_axi_wstrb,
    input  logic                                  s_axi_wvalid,
    output logic                                  s_axi_wready,
    input  logic [AXI_ADDR_WIDTH-1:0]             s_axi_araddr,
    input  logic [2:0]                            s_axi_arprot,
    input  logic                                  s_axi_arvalid,
    output logic                                  s_axi_arready,
    output logic [31:0]                           s_axi_rdata,
    output logic [1:0]                            s_axi_rresp,
    output logic                                  s_axi_rvalid,
    input  logic                                  s_axi_rready,
    output logic [1:0]                            s_axi_bresp,
    output logic                                  s_axi_bvalid,
    input  logic                                  s_axi_bready,

    // Controller -> Aggregation Engine Interface
    input  logic                                  nsb_fte_req_valid,
    output logic                                  nsb_fte_req_ready,
    input  NSB_FTE_REQ_t                          nsb_fte_req,
    output logic                                  nsb_fte_resp_valid, // valid only for now
    output NSB_FTE_RESP_t                         nsb_fte_resp,

    output logic [top_pkg::AGGREGATION_BUFFER_SLOTS-1:0]                                              fte_aggregation_buffer_pop,
    input  logic [top_pkg::AGGREGATION_BUFFER_SLOTS-1:0]                                              aggregation_buffer_fte_out_feature_valid,
    input  logic [top_pkg::AGGREGATION_BUFFER_SLOTS-1:0] [top_pkg::AGGREGATION_BUFFER_READ_WIDTH-1:0] aggregation_buffer_fte_out_feature

);

parameter MATRIX_N = 4;

logic [MATRIX_N-1:0] [31:0]          sys_array_forward;             // input  
logic [MATRIX_N-1:0]                 sys_array_forward_valid;       // input  
logic [MATRIX_N-1:0] [31:0]          sys_array_down;                // input  
logic [MATRIX_N-1:0]                 sys_array_down_valid;          // input  
logic [MATRIX_N-1:0] [MATRIX_N-1:0]  sys_array_pe_acc;               // output 

assign sys_array_forward            = '0;
assign sys_array_forward_valid      = '0;
assign sys_array_down               = '0;
assign sys_array_down_valid         = '0;

sys_array #(
    .FLOAT_WIDTH(FLOAT_WIDTH),
    .MATRIX_N(MATRIX_N)
) sys_array_i (
    .core_clk,
    .rstn (resetn),
    .sys_array_forward,
    .sys_array_forward_valid,
    .sys_array_down,
    .sys_array_down_valid,
    .sys_array_pe_acc
);

assign nsb_fte_req_ready           = '0;
assign nsb_fte_resp_valid          = '0;
assign nsb_fte_resp                = '0;

endmodule