
module fc_base_transformation_engine #(
    parameter FLOAT_WIDTH = 32,
    parameter AXI_ADDR_WIDTH = 32
) (
    input logic core_clk,
    input logic resetn,

    // Regbank Slave AXI interface
    input  logic [AXI_ADDR_WIDTH-1:0]                           s_axi_awaddr,
    input  logic [2:0]                                          s_axi_awprot,
    input  logic                                                s_axi_awvalid,
    output logic                                                s_axi_awready,
    input  logic [31:0]                                         s_axi_wdata,
    input  logic [3:0]                                          s_axi_wstrb,
    input  logic                                                s_axi_wvalid,
    output logic                                                s_axi_wready,
    input  logic [AXI_ADDR_WIDTH-1:0]                           s_axi_araddr,
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

    // Master AXI interface (to DRAM controller)
    input   logic [31:0]                                        m_axi_araddr,
    input   logic [1:0]                                         m_axi_arburst,
    input   logic [3:0]                                         m_axi_arcache,
    input   logic [0:0]                                         m_axi_arid,
    input   logic [7:0]                                         m_axi_arlen,
    input   logic [0:0]                                         m_axi_arlock,
    input   logic [2:0]                                         m_axi_arprot,
    input   logic [3:0]                                         m_axi_arqos,
    output  logic                                               m_axi_arready,
    input   logic [3:0]                                         m_axi_arregion,
    input   logic [2:0]                                         m_axi_arsize,
    input   logic                                               m_axi_arvalid,
    input   logic [31:0]                                        m_axi_awaddr,
    input   logic [1:0]                                         m_axi_awburst,
    input   logic [3:0]                                         m_axi_awcache,
    input   logic [0:0]                                         m_axi_awid,
    input   logic [7:0]                                         m_axi_awlen,
    input   logic [0:0]                                         m_axi_awlock,
    input   logic [2:0]                                         m_axi_awprot,
    input   logic [3:0]                                         m_axi_awqos,
    output  logic                                               m_axi_awready,
    input   logic [3:0]                                         m_axi_awregion,
    input   logic [2:0]                                         m_axi_awsize,
    input   logic                                               m_axi_awvalid,
    output  logic [0:0]                                         m_axi_bid,
    input   logic                                               m_axi_bready,
    output  logic [1:0]                                         m_axi_bresp,
    output  logic                                               m_axi_bvalid,
    output  logic [31:0]                                        m_axi_rdata,
    output  logic [0:0]                                         m_axi_rid,
    output  logic                                               m_axi_rlast,
    input   logic                                               m_axi_rready,
    output  logic [1:0]                                         m_axi_rresp,
    output  logic                                               m_axi_rvalid,
    input   logic [31:0]                                        m_axi_wdata,
    input   logic                                               m_axi_wlast,
    output  logic                                               m_axi_wready,
    input   logic [3:0]                                         m_axi_wstrb,
    input   logic                                               m_axi_wvalid
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

endmodule