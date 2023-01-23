

module controller #(
    parameter AXIL_ADDR_WIDTH = 32
) (
    input logic core_clk,
    input logic resetn,
    
    // Regbank Slave AXI interface
    input  logic [AXIL_ADDR_WIDTH-1:0]                           s_axi_awaddr,
    input  logic [2:0]                                          s_axi_awprot,
    input  logic                                                s_axi_awvalid,
    output logic                                                s_axi_awready,
    input  logic [31:0]                                         s_axi_wdata,
    input  logic [3:0]                                          s_axi_wstrb,
    input  logic                                                s_axi_wvalid,
    output logic                                                s_axi_wready,
    input  logic [AXIL_ADDR_WIDTH-1:0]                           s_axi_araddr,
    input  logic [2:0]                                          s_axi_arprot,
    input  logic                                                s_axi_arvalid,
    output logic                                                s_axi_arready,
    output logic [31:0]                                         s_axi_rdata,
    output logic [1:0]                                          s_axi_rresp,
    output logic                                                s_axi_rvalid,
    input  logic                                                s_axi_rready,
    output logic [1:0]                                          s_axi_bresp,
    output logic                                                s_axi_bvalid,
    input  logic                                                s_axi_bready
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