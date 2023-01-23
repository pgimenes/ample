
import top_pkg::*;

module controller #(
    parameter AXIL_ADDR_WIDTH = 32
) (
    input logic core_clk,
    input logic resetn,

    // Regbank Slave AXI interface
    input  logic [AXIL_ADDR_WIDTH-1:0]                          s_axi_awaddr,
    input  logic [2:0]                                          s_axi_awprot,
    input  logic                                                s_axi_awvalid,
    output logic                                                s_axi_awready,
    input  logic [31:0]                                         s_axi_wdata,
    input  logic [3:0]                                          s_axi_wstrb,
    input  logic                                                s_axi_wvalid,
    output logic                                                s_axi_wready,
    input  logic [AXIL_ADDR_WIDTH-1:0]                          s_axi_araddr,
    input  logic [2:0]                                          s_axi_arprot,
    input  logic                                                s_axi_arvalid,
    output logic                                                s_axi_arready,
    output logic [31:0]                                         s_axi_rdata,
    output logic [1:0]                                          s_axi_rresp,
    output logic                                                s_axi_rvalid,
    input  logic                                                s_axi_rready,
    output logic [1:0]                                          s_axi_bresp,
    output logic                                                s_axi_bvalid,
    input  logic                                                s_axi_bready,

    // Controller -> Aggregation Engine Interface
    output logic                                                controller_aggregation_engine_req_valid,
    input  logic                                                controller_aggregation_engine_req_ready,
    output CONTROLLER_AGG_REQ_t                                 controller_aggregation_engine_req,
    input  logic                                                controller_aggregation_engine_resp_valid, // valid only for now
    input  CONTROLLER_AGG_RESP_t                                controller_aggregation_engine_resp,

    // Controller -> Transformation Engine Interface
    output logic                                                controller_transformation_engine_req_valid,
    input  logic                                                controller_transformation_engine_req_ready,
    output CONTROLLER_TRANS_REQ_t                               controller_transformation_engine_req,
    input  logic                                                controller_transformation_engine_resp_valid, // valid only for now
    input  CONTROLLER_TRANS_RESP_t                              controller_transformation_engine_resp,

    // Controller -> Prefetcher Interface
    output logic                                                controller_prefetcher_req_valid,
    input  logic                                                controller_prefetcher_req_ready,
    output CONTROLLER_PREF_REQ_t                                controller_prefetcher_req,
    input  logic                                                controller_prefetcher_resp_valid, // valid only for now
    input  CONTROLLER_PREF_RESP_t                               controller_prefetcher_resp,

    // Controller -> Weight Buffer Interface
    output logic                                                controller_weight_buffer_req_valid,
    input  logic                                                controller_weight_buffer_req_ready,
    output CONTROLLER_WBUFF_REQ_t                               controller_weight_buffer_req,
    input  logic                                                controller_weight_buffer_resp_valid, // valid only for now
    input  CONTROLLER_WBUFF_RESP_t                              controller_weight_buffer_resp,

    // Controller -> Output Buffer Interface
    output logic                                                controller_output_buffer_req_valid,
    input  logic                                                controller_output_buffer_req_ready,
    output CONTROLLER_OUT_BUFF_REQ_t                            controller_output_buffer_req,
    input  logic                                                controller_output_buffer_resp_valid, // valid only for now
    input  CONTROLLER_OUT_BUFF_RESP_t                           controller_output_buffer_resp
);


// ==================================================================================================================================================
// Declarations
// ==================================================================================================================================================

// Regbank
// ------------------------------------------------------------


// ==================================================================================================================================================
// Instances
// ==================================================================================================================================================



// ==================================================================================================================================================
// Logic
// ==================================================================================================================================================

always_comb begin
    s_axi_awready   = '0;
    s_axi_wready    = '0;
    s_axi_arready   = '0;
    s_axi_rdata     = '0;
    s_axi_rresp     = '0;
    s_axi_rvalid    = '0;
    s_axi_bresp     = '0;
    s_axi_bvalid    = '0;
end

// ==================================================================================================================================================
// Assertions
// ==================================================================================================================================================

endmodule