

module output_buffer #(
    parameter AXI_ADDR_WIDTH = 34
) (
    input logic core_clk,
    input logic resetn,

    // Prefetcher -> AXI Memory Interconnect
    output logic [33:0]                       output_buffer_axi_interconnect_axi_araddr,
    output logic [1:0]                        output_buffer_axi_interconnect_axi_arburst,
    output logic [3:0]                        output_buffer_axi_interconnect_axi_arcache,
    output logic [3:0]                        output_buffer_axi_interconnect_axi_arid,
    output logic [7:0]                        output_buffer_axi_interconnect_axi_arlen,
    output logic [0:0]                        output_buffer_axi_interconnect_axi_arlock,
    output logic [2:0]                        output_buffer_axi_interconnect_axi_arprot,
    output logic [3:0]                        output_buffer_axi_interconnect_axi_arqos,
    output logic [2:0]                        output_buffer_axi_interconnect_axi_arsize,
    output logic                              output_buffer_axi_interconnect_axi_arvalid,
    input  logic                              output_buffer_axi_interconnect_axi_arready,
    output logic [33:0]                       output_buffer_axi_interconnect_axi_awaddr,
    output logic [1:0]                        output_buffer_axi_interconnect_axi_awburst,
    output logic [3:0]                        output_buffer_axi_interconnect_axi_awcache,
    output logic [3:0]                        output_buffer_axi_interconnect_axi_awid,
    output logic [7:0]                        output_buffer_axi_interconnect_axi_awlen,
    output logic [0:0]                        output_buffer_axi_interconnect_axi_awlock,
    output logic [2:0]                        output_buffer_axi_interconnect_axi_awprot,
    output logic [3:0]                        output_buffer_axi_interconnect_axi_awqos,
    input  logic                              output_buffer_axi_interconnect_axi_awready,
    output logic [2:0]                        output_buffer_axi_interconnect_axi_awsize,
    output logic                              output_buffer_axi_interconnect_axi_awvalid,
    input  logic [3:0]                        output_buffer_axi_interconnect_axi_bid,
    output logic                              output_buffer_axi_interconnect_axi_bready,
    input  logic [1:0]                        output_buffer_axi_interconnect_axi_bresp,
    input  logic                              output_buffer_axi_interconnect_axi_bvalid,
    input  logic [511:0]                      output_buffer_axi_interconnect_axi_rdata,
    input  logic [3:0]                        output_buffer_axi_interconnect_axi_rid,
    input  logic                              output_buffer_axi_interconnect_axi_rlast,
    output logic                              output_buffer_axi_interconnect_axi_rready,
    input  logic [1:0]                        output_buffer_axi_interconnect_axi_rresp,
    input  logic                              output_buffer_axi_interconnect_axi_rvalid,
    output logic [511:0]                      output_buffer_axi_interconnect_axi_wdata,
    output logic                              output_buffer_axi_interconnect_axi_wlast,
    input  logic                              output_buffer_axi_interconnect_axi_wready,
    output logic [63:0]                       output_buffer_axi_interconnect_axi_wstrb,
    output logic                              output_buffer_axi_interconnect_axi_wvalid
    
);


// ==================================================================================================================================================
// Declarations
// ==================================================================================================================================================


// ==================================================================================================================================================
// Instances
// ==================================================================================================================================================


// ==================================================================================================================================================
// Logic
// ==================================================================================================================================================

always_comb begin
    output_buffer_axi_interconnect_axi_araddr      = '0;
    output_buffer_axi_interconnect_axi_arburst     = '0;
    output_buffer_axi_interconnect_axi_arcache     = '0;
    output_buffer_axi_interconnect_axi_arid        = '0;
    output_buffer_axi_interconnect_axi_arlen       = '0;
    output_buffer_axi_interconnect_axi_arlock      = '0;
    output_buffer_axi_interconnect_axi_arprot      = '0;
    output_buffer_axi_interconnect_axi_arqos       = '0;
    output_buffer_axi_interconnect_axi_arsize      = '0;
    output_buffer_axi_interconnect_axi_arvalid     = '0;
    output_buffer_axi_interconnect_axi_awaddr      = '0;
    output_buffer_axi_interconnect_axi_awburst     = '0;
    output_buffer_axi_interconnect_axi_awcache     = '0;
    output_buffer_axi_interconnect_axi_awid        = '0;
    output_buffer_axi_interconnect_axi_awlen       = '0;
    output_buffer_axi_interconnect_axi_awlock      = '0;
    output_buffer_axi_interconnect_axi_awprot      = '0;
    output_buffer_axi_interconnect_axi_awqos       = '0;
    output_buffer_axi_interconnect_axi_awsize      = '0;
    output_buffer_axi_interconnect_axi_awvalid     = '0;
    output_buffer_axi_interconnect_axi_bready      = '0;
    output_buffer_axi_interconnect_axi_rready      = '0;
    output_buffer_axi_interconnect_axi_wdata       = '0;
    output_buffer_axi_interconnect_axi_wlast       = '0;
    output_buffer_axi_interconnect_axi_wstrb       = '0;
    output_buffer_axi_interconnect_axi_wvalid      = '0;
end

// ==================================================================================================================================================
// Assertions
// ==================================================================================================================================================

endmodule