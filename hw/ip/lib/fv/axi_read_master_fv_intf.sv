
interface axi_read_master_fv_intf (
    input logic clk,
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

endinterface

bind axi_read_master axi_read_master_fv_intf props (.*);