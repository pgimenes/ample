
interface top_memory_axi_interface (
    input logic clk,
    input logic resetn
);

logic [3:0]                     top_axi_interconnect_axi_awid;  // output 
logic [33:0]                    top_axi_interconnect_axi_awaddr;  // output 
logic [7:0]                     top_axi_interconnect_axi_awlen;  // output 
logic [2:0]                     top_axi_interconnect_axi_awsize;  // output 
logic [1:0]                     top_axi_interconnect_axi_awburst;  // output 
logic [0:0]                     top_axi_interconnect_axi_awlock;  // output 
logic [3:0]                     top_axi_interconnect_axi_awcache;  // output 
logic [2:0]                     top_axi_interconnect_axi_awprot;  // output 
logic [3:0]                     top_axi_interconnect_axi_awqos;  // output 
logic                           top_axi_interconnect_axi_awvalid;  // output 
logic                          top_axi_interconnect_axi_awready;  // input  
logic [511:0]                   top_axi_interconnect_axi_wdata;  // output 
logic [63:0]                    top_axi_interconnect_axi_wstrb;  // output 
logic                           top_axi_interconnect_axi_wlast;  // output 
logic                           top_axi_interconnect_axi_wvalid;  // output 
logic                          top_axi_interconnect_axi_wready;  // input  
logic [3:0]                    top_axi_interconnect_axi_bid;  // input  
logic [1:0]                    top_axi_interconnect_axi_bresp;  // input  
logic                          top_axi_interconnect_axi_bvalid;  // input  
logic                           top_axi_interconnect_axi_bready;  // output 
logic [3:0]                     top_axi_interconnect_axi_arid;  // output 
logic [33:0]                    top_axi_interconnect_axi_araddr;  // output 
logic [7:0]                     top_axi_interconnect_axi_arlen;  // output 
logic [2:0]                     top_axi_interconnect_axi_arsize;  // output 
logic [1:0]                     top_axi_interconnect_axi_arburst;  // output 
logic [0:0]                     top_axi_interconnect_axi_arlock;  // output 
logic [3:0]                     top_axi_interconnect_axi_arcache;  // output 
logic [2:0]                     top_axi_interconnect_axi_arprot;  // output 
logic [3:0]                     top_axi_interconnect_axi_arqos;  // output 
logic                           top_axi_interconnect_axi_arvalid;  // output 
logic                          top_axi_interconnect_axi_arready;  // input  
logic [3:0]                    top_axi_interconnect_axi_rid;  // input  
logic [511:0]                  top_axi_interconnect_axi_rdata;  // input  
logic [1:0]                    top_axi_interconnect_axi_rresp;  // input  
logic                          top_axi_interconnect_axi_rlast;  // input  
logic                          top_axi_interconnect_axi_rvalid;  // input  
logic                           top_axi_interconnect_axi_rready; // output 

endinterface