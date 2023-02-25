
package axi_pkg;

typedef struct packed {
    logic [33:0]                                axi_araddr;
    logic [1:0]                                 axi_arburst;
    logic [3:0]                                 axi_arcache;
    logic [3:0]                                 axi_arid;
    logic [7:0]                                 axi_arlen;
    logic [0:0]                                 axi_arlock;
    logic [2:0]                                 axi_arprot;
    logic [3:0]                                 axi_arqos;
    logic [2:0]                                 axi_arsize;
    logic                                       axi_arvalid;
    logic                                       axi_arready;
    logic [511:0]                               axi_rdata;
    logic [3:0]                                 axi_rid;
    logic                                       axi_rlast;
    logic                                       axi_rready;
    logic [1:0]                                 axi_rresp;
    logic [33:0]                                axi_awaddr;
    logic [1:0]                                 axi_awburst;
    logic [3:0]                                 axi_awcache;
    logic [3:0]                                 axi_awid;
    logic [7:0]                                 axi_awlen;
    logic [0:0]                                 axi_awlock;
    logic [2:0]                                 axi_awprot;
    logic [3:0]                                 axi_awqos;
    logic                                       axi_awready;
    logic [2:0]                                 axi_awsize;
    logic                                       axi_awvalid;
    logic [511:0]                               axi_wdata;
    logic                                       axi_wlast;
    logic                                       axi_wready;
    logic [63:0]                                axi_wstrb;
    logic                                       axi_wvali;
    logic [3:0]                                 axi_bid;
    logic                                       axi_bready;
    logic [1:0]                                 axi_bresp;
    logic                                       axi_bvalid;
    logic                                       axi_rvalid;
} AXI_SIGNALS_S;

// need modport to define direction?

endpackage