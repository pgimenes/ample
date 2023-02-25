
import top_pkg::*;

interface node_scoreboard_interface(
    input logic core_clk,
    input logic resetn,

    // Regbank Slave AXI interface
    input logic [31:0]                                         s_axi_awaddr,
    input logic [2:0]                                          s_axi_awprot,
    input logic                                                s_axi_awvalid,
    input logic                                                s_axi_awready,
    input logic [31:0]                                         s_axi_wdata,
    input logic [3:0]                                          s_axi_wstrb,
    input logic                                                s_axi_wvalid,
    input logic                                                s_axi_wready,
    input logic [31:0]                                         s_axi_araddr,
    input logic [2:0]                                          s_axi_arprot,
    input logic                                                s_axi_arvalid,
    input logic                                                s_axi_arready,
    input logic [31:0]                                         s_axi_rdata,
    input logic [1:0]                                          s_axi_rresp,
    input logic                                                s_axi_rvalid,
    input logic                                                s_axi_rready,
    input logic [1:0]                                          s_axi_bresp,
    input logic                                                s_axi_bvalid,
    input logic                                                s_axi_bready,

    // Controller -> Aggregation Engine Interface
    input logic                                                nsb_age_req_valid,
    input logic                                                nsb_age_req_ready,
    input NSB_AGE_REQ_t                                        nsb_age_req,
    input NSB_AGE_RESP_t                                       nsb_age_resp,
    input logic                                                nsb_age_resp_valid, // valid only for now

    // Controller -> Transformation Engine Interface
    input logic                                                nsb_fte_req_valid,
    input logic                                                nsb_fte_req_ready,
    input NSB_FTE_REQ_t                                        nsb_fte_req,
    input NSB_FTE_RESP_t                                       nsb_fte_resp,
    input logic                                                nsb_fte_resp_valid, // valid only for now

    // Controller -> Prefetcher Interface
    input logic                                                nsb_prefetcher_req_valid,
    input logic                                                nsb_prefetcher_req_ready,
    input NSB_PREF_REQ_t                                       nsb_prefetcher_req,
    input NSB_PREF_RESP_t                                      nsb_prefetcher_resp,
    input logic                                                nsb_prefetcher_resp_valid, // valid only for now

    // Controller -> Output Buffer Interface
    input logic                                                nsb_output_buffer_req_valid,
    input logic                                                nsb_output_buffer_req_ready,
    input NSB_OUT_BUFF_REQ_t                                   nsb_output_buffer_req,
    input logic                                                nsb_output_buffer_resp_valid, // valid only for now
    input NSB_OUT_BUFF_RESP_t                                  nsb_output_buffer_resp
);

parameter AXIL_ADDR_WIDTH = 32;


endinterface