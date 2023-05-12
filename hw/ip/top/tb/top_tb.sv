
module top_tb;

    localparam ADDR_WIDTH                    = 17;
    localparam DQ_WIDTH                      = 72;
    localparam DQS_WIDTH                     = 18;
    localparam DM_WIDTH                      = 9;
    localparam DRAM_WIDTH                    = 4;
    localparam tCK                           = 833 ; //DDR4 interface clock period in ps
    localparam real SYSCLK_PERIOD            = tCK; 
    localparam NUM_PHYSICAL_PARTS = (DQ_WIDTH/DRAM_WIDTH) ;
    localparam           CLAMSHELL_PARTS = (NUM_PHYSICAL_PARTS/2);
    localparam           ODD_PARTS = ((CLAMSHELL_PARTS*2) < NUM_PHYSICAL_PARTS) ? 1 : 0;
    parameter RANK_WIDTH                       = 1;
    parameter CS_WIDTH                       = 1;
    parameter ODT_WIDTH                      = 1;
    parameter CA_MIRROR                      = "OFF";


    localparam MRS                           = 3'b000;
    localparam REF                           = 3'b001;
    localparam PRE                           = 3'b010;
    localparam ACT                           = 3'b011;
    localparam WR                            = 3'b100;
    localparam RD                            = 3'b101;
    localparam ZQC                           = 3'b110;
    localparam NOP                           = 3'b111;
    //Added to support RDIMM wrapper
    localparam ODT_WIDTH_RDIMM   = 1;
    localparam CKE_WIDTH_RDIMM   = 1;
    localparam CS_WIDTH_RDIMM   = 1;
    localparam RANK_WIDTH_RDIMM   = 1;
    localparam RDIMM_SLOTS   = 1;
    localparam BANK_WIDTH_RDIMM = 2;
    localparam BANK_GROUP_WIDTH_RDIMM     = 2;

    localparam DM_DBI                        = "NONE";
    localparam DM_WIDTH_RDIMM                  = 18;

    localparam MEM_PART_WIDTH       = "x4";
    localparam REG_CTRL             = "ON";

    import arch_package::*;
    parameter UTYPE_density CONFIGURED_DENSITY = _8G;

    // Input clock is assumed to be equal to the memory clock frequency
    // User should change the parameter as necessary if a different input
    // clock frequency is used
    localparam real CLKIN_PERIOD_NS = 3332 / 1000.0;

    // parameter SIMULATION = "TRUE"; // skip ddr4 calibration

    parameter CLK_PERIOD = (3332);

    // ------------------------

    logic                  sys_clk_i;
    logic                  sys_rst;
    logic                  c0_sys_clk_p;
    logic                  c0_sys_clk_n;

    logic  [16:0]          c0_ddr4_adr_sdram[1:0];
    logic  [1:0]           c0_ddr4_ba_sdram[1:0];
    logic  [1:0]           c0_ddr4_bg_sdram[1:0];
    logic                  c0_ddr4_act_n;
    logic  [16:0]          c0_ddr4_adr;
    logic  [1:0]           c0_ddr4_ba;
    logic  [1:0]           c0_ddr4_bg;
    logic  [0:0]           c0_ddr4_cke;
    logic  [0:0]           c0_ddr4_odt;
    logic  [0:0]           c0_ddr4_cs_n;
    logic  [0:0]           c0_ddr4_ck_t_int;
    logic  [0:0]           c0_ddr4_ck_c_int;
    logic                  c0_ddr4_ck_t;
    logic                  c0_ddr4_ck_c;
    logic                  c0_ddr4_reset_n;
    logic                  c0_ddr4_parity;
    wire [71:0]            c0_ddr4_dq;
    wire [17:0]            c0_ddr4_dqs_c;
    wire [17:0]            c0_ddr4_dqs_t;
    logic                  c0_init_calib_complete;

    logic  [31:0]          cmdName;
    logic [ADDR_WIDTH-1:0] DDR4_ADRMOD[RANK_WIDTH-1:0];

    // AXI-L interface to Host
    logic [31 : 0]    host_axil_awaddr;
    logic [2 : 0]     host_axil_awprot;
    logic [0 : 0]     host_axil_awvalid;
    logic [31 : 0]    host_axil_wdata;
    logic [3 : 0]     host_axil_wstrb;
    logic [0 : 0]     host_axil_wvalid;
    logic [0 : 0]     host_axil_bready;
    logic [31 : 0]    host_axil_araddr;
    logic [2 : 0]     host_axil_arprot;
    logic [0 : 0]     host_axil_arvalid;
    logic [0 : 0]     host_axil_rready;
    logic [0 : 0]     host_axil_awready;
    logic [0 : 0]     host_axil_wready;
    logic [1 : 0]     host_axil_bresp;
    logic [0 : 0]     host_axil_bvalid;
    logic [0 : 0]     host_axil_arready;
    logic [31 : 0]    host_axil_rdata;
    logic [1 : 0]     host_axil_rresp;
    logic [0 : 0]     host_axil_rvalid;

    logic  [7:0]                   axi_interconnect_memory_axi_awid; // output 
    logic  [33:0]                  axi_interconnect_memory_axi_awaddr; // output 
    logic  [7:0]                   axi_interconnect_memory_axi_awlen; // output 
    logic  [2:0]                   axi_interconnect_memory_axi_awsize; // output 
    logic  [1:0]                   axi_interconnect_memory_axi_awburst; // output 
    logic  [0:0]                   axi_interconnect_memory_axi_awlock; // output 
    logic  [3:0]                   axi_interconnect_memory_axi_awcache; // output 
    logic  [2:0]                   axi_interconnect_memory_axi_awprot; // output 
    logic  [3:0]                   axi_interconnect_memory_axi_awqos; // output 
    logic                          axi_interconnect_memory_axi_awvalid; // output 
    logic                          axi_interconnect_memory_axi_awready; // input  
    
    logic  [511:0]                 axi_interconnect_memory_axi_wdata; // output 
    logic  [63:0]                  axi_interconnect_memory_axi_wstrb; // output 
    logic                          axi_interconnect_memory_axi_wlast; // output 
    logic                          axi_interconnect_memory_axi_wvalid; // output 
    logic                          axi_interconnect_memory_axi_wready; // input  
    
    logic [7:0]                    axi_interconnect_memory_axi_bid; // input  
    logic [1:0]                    axi_interconnect_memory_axi_bresp; // input  
    logic                          axi_interconnect_memory_axi_bvalid; // input  
    logic                          axi_interconnect_memory_axi_bready; // output 
    
    logic  [7:0]                   axi_interconnect_memory_axi_arid; // output 
    logic  [33:0]                  axi_interconnect_memory_axi_araddr; // output 
    logic  [7:0]                   axi_interconnect_memory_axi_arlen; // output 
    logic  [2:0]                   axi_interconnect_memory_axi_arsize; // output 
    logic  [1:0]                   axi_interconnect_memory_axi_arburst; // output 
    logic  [0:0]                   axi_interconnect_memory_axi_arlock; // output 
    logic  [3:0]                   axi_interconnect_memory_axi_arcache; // output 
    logic  [2:0]                   axi_interconnect_memory_axi_arprot; // output 
    logic  [3:0]                   axi_interconnect_memory_axi_arqos; // output 
    logic                          axi_interconnect_memory_axi_arvalid; // output 
    logic                          axi_interconnect_memory_axi_arready; // input  
    
    logic [7:0]                    axi_interconnect_memory_axi_rid; // input  
    logic [511:0]                  axi_interconnect_memory_axi_rdata; // input  
    logic [1:0]                    axi_interconnect_memory_axi_rresp; // input  
    logic                          axi_interconnect_memory_axi_rlast; // input  
    logic                          axi_interconnect_memory_axi_rvalid; // input  
    logic                          axi_interconnect_memory_axi_rready; // output 

  // ============================================================================
  // Reset Generation
  // ============================================================================
  initial begin
     sys_rst = 1'b1;
     #(CLK_PERIOD*20)
     sys_rst = 1'b0;
  end

  // ============================================================================
  // Clock Generation
  // ============================================================================

  initial
    sys_clk_i = 1'b1;
  always
    sys_clk_i = #(CLK_PERIOD/2.0) ~sys_clk_i;

  assign c0_sys_clk_p = sys_clk_i;
  assign c0_sys_clk_n = ~sys_clk_i;

  assign c0_ddr4_ck_t = c0_ddr4_ck_t_int[0];
  assign c0_ddr4_ck_c = c0_ddr4_ck_c_int[0];

   always @( * ) begin
     c0_ddr4_adr_sdram[0]   <=  c0_ddr4_adr;
     c0_ddr4_adr_sdram[1]   <=  (CA_MIRROR == "ON") ?
                                       {c0_ddr4_adr[ADDR_WIDTH-1:14],
                                        c0_ddr4_adr[11], c0_ddr4_adr[12],
                                        c0_ddr4_adr[13], c0_ddr4_adr[10:9],
                                        c0_ddr4_adr[7], c0_ddr4_adr[8],
                                        c0_ddr4_adr[5], c0_ddr4_adr[6],
                                        c0_ddr4_adr[3], c0_ddr4_adr[4],
                                        c0_ddr4_adr[2:0]} :
                                        c0_ddr4_adr;
     c0_ddr4_ba_sdram[0]    <=  c0_ddr4_ba;
     c0_ddr4_ba_sdram[1]    <=  (CA_MIRROR == "ON") ?
                                        {c0_ddr4_ba[0],
                                         c0_ddr4_ba[1]} :
                                         c0_ddr4_ba;
     c0_ddr4_bg_sdram[0]    <=  c0_ddr4_bg;
     c0_ddr4_bg_sdram[1]    <=  (CA_MIRROR == "ON" && DRAM_WIDTH != 16) ?
                                        {c0_ddr4_bg[0],
                                         c0_ddr4_bg[1]} :
                                         c0_ddr4_bg;
    end


  //===========================================================================
  // Top RTL
  //===========================================================================

top top_i (
    .sys_clk            (sys_clk_i),
    .sys_rst            (sys_rst),

    // AXI-L interface to Host
    .host_axil_awaddr       (host_axil_awaddr       ),
    .host_axil_awprot       (host_axil_awprot       ),
    .host_axil_awvalid      (host_axil_awvalid      ),
    .host_axil_wdata        (host_axil_wdata        ),
    .host_axil_wstrb        (host_axil_wstrb        ),
    .host_axil_wvalid       (host_axil_wvalid       ),
    .host_axil_bready       (host_axil_bready       ),
    .host_axil_araddr       (host_axil_araddr       ),
    .host_axil_arprot       (host_axil_arprot       ),
    .host_axil_arvalid      (host_axil_arvalid      ),
    .host_axil_rready       (host_axil_rready       ),
    .host_axil_awready      (host_axil_awready      ),
    .host_axil_wready       (host_axil_wready       ),
    .host_axil_bresp        (host_axil_bresp        ),
    .host_axil_bvalid       (host_axil_bvalid       ),
    .host_axil_arready      (host_axil_arready      ),
    .host_axil_rdata        (host_axil_rdata        ),
    .host_axil_rresp        (host_axil_rresp        ),
    .host_axil_rvalid       (host_axil_rvalid       ),

    // AXI Memory Master
    .top_axi_interconnect_axi_awid            (memory_intf.top_axi_interconnect_axi_awid),
    .top_axi_interconnect_axi_awaddr          (memory_intf.top_axi_interconnect_axi_awaddr),
    .top_axi_interconnect_axi_awlen           (memory_intf.top_axi_interconnect_axi_awlen),
    .top_axi_interconnect_axi_awsize          (memory_intf.top_axi_interconnect_axi_awsize),
    .top_axi_interconnect_axi_awburst         (memory_intf.top_axi_interconnect_axi_awburst),
    .top_axi_interconnect_axi_awlock          (memory_intf.top_axi_interconnect_axi_awlock),
    .top_axi_interconnect_axi_awcache         (memory_intf.top_axi_interconnect_axi_awcache),
    .top_axi_interconnect_axi_awprot          (memory_intf.top_axi_interconnect_axi_awprot),
    .top_axi_interconnect_axi_awqos           (memory_intf.top_axi_interconnect_axi_awqos),
    .top_axi_interconnect_axi_awvalid         (memory_intf.top_axi_interconnect_axi_awvalid),
    .top_axi_interconnect_axi_awready         (memory_intf.top_axi_interconnect_axi_awready),
    .top_axi_interconnect_axi_wdata           (memory_intf.top_axi_interconnect_axi_wdata),
    .top_axi_interconnect_axi_wstrb           (memory_intf.top_axi_interconnect_axi_wstrb),
    .top_axi_interconnect_axi_wlast           (memory_intf.top_axi_interconnect_axi_wlast),
    .top_axi_interconnect_axi_wvalid          (memory_intf.top_axi_interconnect_axi_wvalid),
    .top_axi_interconnect_axi_wready          (memory_intf.top_axi_interconnect_axi_wready),
    .top_axi_interconnect_axi_bid             (memory_intf.top_axi_interconnect_axi_bid),
    .top_axi_interconnect_axi_bresp           (memory_intf.top_axi_interconnect_axi_bresp),
    .top_axi_interconnect_axi_bvalid          (memory_intf.top_axi_interconnect_axi_bvalid),
    .top_axi_interconnect_axi_bready          (memory_intf.top_axi_interconnect_axi_bready),
    .top_axi_interconnect_axi_arid            (memory_intf.top_axi_interconnect_axi_arid),
    .top_axi_interconnect_axi_araddr          (memory_intf.top_axi_interconnect_axi_araddr),
    .top_axi_interconnect_axi_arlen           (memory_intf.top_axi_interconnect_axi_arlen),
    .top_axi_interconnect_axi_arsize          (memory_intf.top_axi_interconnect_axi_arsize),
    .top_axi_interconnect_axi_arburst         (memory_intf.top_axi_interconnect_axi_arburst),
    .top_axi_interconnect_axi_arlock          (memory_intf.top_axi_interconnect_axi_arlock),
    .top_axi_interconnect_axi_arcache         (memory_intf.top_axi_interconnect_axi_arcache),
    .top_axi_interconnect_axi_arprot          (memory_intf.top_axi_interconnect_axi_arprot),
    .top_axi_interconnect_axi_arqos           (memory_intf.top_axi_interconnect_axi_arqos),
    .top_axi_interconnect_axi_arvalid         (memory_intf.top_axi_interconnect_axi_arvalid),
    .top_axi_interconnect_axi_arready         (memory_intf.top_axi_interconnect_axi_arready),
    .top_axi_interconnect_axi_rid             (memory_intf.top_axi_interconnect_axi_rid),
    .top_axi_interconnect_axi_rdata           (memory_intf.top_axi_interconnect_axi_rdata),
    .top_axi_interconnect_axi_rresp           (memory_intf.top_axi_interconnect_axi_rresp),
    .top_axi_interconnect_axi_rlast           (memory_intf.top_axi_interconnect_axi_rlast),
    .top_axi_interconnect_axi_rvalid          (memory_intf.top_axi_interconnect_axi_rvalid),
    .top_axi_interconnect_axi_rready          (memory_intf.top_axi_interconnect_axi_rready),

    // DDR4
    .c0_sys_clk_p           (c0_sys_clk_p),
    .c0_sys_clk_n           (c0_sys_clk_n),
    .c0_ddr4_act_n          (c0_ddr4_act_n),
    .c0_ddr4_adr            (c0_ddr4_adr),
    .c0_ddr4_ba             (c0_ddr4_ba),
    .c0_ddr4_bg             (c0_ddr4_bg),
    .c0_ddr4_cke            (c0_ddr4_cke),
    .c0_ddr4_odt            (c0_ddr4_odt),
    .c0_ddr4_cs_n           (c0_ddr4_cs_n),
    .c0_ddr4_ck_t           (c0_ddr4_ck_t_int),
    .c0_ddr4_ck_c           (c0_ddr4_ck_c_int),
    .c0_ddr4_reset_n        (c0_ddr4_reset_n),
    .c0_ddr4_parity         (c0_ddr4_parity),
    .c0_ddr4_dq             (c0_ddr4_dq),
    .c0_ddr4_dqs_c          (c0_ddr4_dqs_c),
    .c0_ddr4_dqs_t          (c0_ddr4_dqs_t),

    .c0_ddr4_s_axi_awid         (axi_interconnect_memory_axi_awid),
    .c0_ddr4_s_axi_awaddr       (axi_interconnect_memory_axi_awaddr),
    .c0_ddr4_s_axi_awlen        (axi_interconnect_memory_axi_awlen),
    .c0_ddr4_s_axi_awsize       (axi_interconnect_memory_axi_awsize),
    .c0_ddr4_s_axi_awburst      (axi_interconnect_memory_axi_awburst),
    .c0_ddr4_s_axi_awlock       (axi_interconnect_memory_axi_awlock),
    .c0_ddr4_s_axi_awcache      (axi_interconnect_memory_axi_awcache),
    .c0_ddr4_s_axi_awprot       (axi_interconnect_memory_axi_awprot),
    .c0_ddr4_s_axi_awqos        (axi_interconnect_memory_axi_awqos),
    .c0_ddr4_s_axi_awvalid      (axi_interconnect_memory_axi_awvalid),
    .c0_ddr4_s_axi_awready      (axi_interconnect_memory_axi_awready),
    .c0_ddr4_s_axi_wdata        (axi_interconnect_memory_axi_wdata),
    .c0_ddr4_s_axi_wstrb        (axi_interconnect_memory_axi_wstrb),
    .c0_ddr4_s_axi_wlast        (axi_interconnect_memory_axi_wlast),
    .c0_ddr4_s_axi_wvalid       (axi_interconnect_memory_axi_wvalid),
    .c0_ddr4_s_axi_wready       (axi_interconnect_memory_axi_wready),
    .c0_ddr4_s_axi_bid          (axi_interconnect_memory_axi_bid),
    .c0_ddr4_s_axi_bresp        (axi_interconnect_memory_axi_bresp),
    .c0_ddr4_s_axi_bvalid       (axi_interconnect_memory_axi_bvalid),
    .c0_ddr4_s_axi_bready       (axi_interconnect_memory_axi_bready),
    .c0_ddr4_s_axi_arid         (axi_interconnect_memory_axi_arid),
    .c0_ddr4_s_axi_araddr       (axi_interconnect_memory_axi_araddr),
    .c0_ddr4_s_axi_arlen        (axi_interconnect_memory_axi_arlen),
    .c0_ddr4_s_axi_arsize       (axi_interconnect_memory_axi_arsize),
    .c0_ddr4_s_axi_arburst      (axi_interconnect_memory_axi_arburst),
    .c0_ddr4_s_axi_arlock       (axi_interconnect_memory_axi_arlock),
    .c0_ddr4_s_axi_arcache      (axi_interconnect_memory_axi_arcache),
    .c0_ddr4_s_axi_arprot       (axi_interconnect_memory_axi_arprot),
    .c0_ddr4_s_axi_arqos        (axi_interconnect_memory_axi_arqos),
    .c0_ddr4_s_axi_arvalid      (axi_interconnect_memory_axi_arvalid),
    .c0_ddr4_s_axi_arready      (axi_interconnect_memory_axi_arready),
    .c0_ddr4_s_axi_rid          (axi_interconnect_memory_axi_rid),
    .c0_ddr4_s_axi_rdata        (axi_interconnect_memory_axi_rdata),
    .c0_ddr4_s_axi_rresp        (axi_interconnect_memory_axi_rresp),
    .c0_ddr4_s_axi_rlast        (axi_interconnect_memory_axi_rlast),
    .c0_ddr4_s_axi_rvalid       (axi_interconnect_memory_axi_rvalid),
    .c0_ddr4_s_axi_rready       (axi_interconnect_memory_axi_rready),

    .c0_init_calib_complete (c0_init_calib_complete)
);

top_memory_axi_interface memory_intf (
    .clk                 (sys_clk_i),                    // input wire aclk
    .resetn              (!sys_rst)              // input wire aresetn
);

//===========================================================================
// AXI-L VIP
//===========================================================================

axil_master_vip axil_master_vip_i (
  .aclk                 (sys_clk_i),                    // input wire aclk
  .aresetn              (!sys_rst),              // input wire aresetn
  
  .m_axi_awaddr         (host_axil_awaddr),    // output wire [31 : 0] m_axi_awaddr
  .m_axi_awprot         (host_axil_awprot),    // output wire [2 : 0] m_axi_awprot
  .m_axi_awvalid        (host_axil_awvalid),  // output wire m_axi_awvalid
  .m_axi_awready        (host_axil_awready),  // input wire m_axi_awready
  .m_axi_wdata          (host_axil_wdata),      // output wire [31 : 0] m_axi_wdata
  .m_axi_wstrb          (host_axil_wstrb),      // output wire [3 : 0] m_axi_wstrb
  .m_axi_wvalid         (host_axil_wvalid),    // output wire m_axi_wvalid
  .m_axi_wready         (host_axil_wready),    // input wire m_axi_wready
  .m_axi_bresp          (host_axil_bresp),      // input wire [1 : 0] m_axi_bresp
  .m_axi_bvalid         (host_axil_bvalid),    // input wire m_axi_bvalid
  .m_axi_bready         (host_axil_bready),    // output wire m_axi_bready
  .m_axi_araddr         (host_axil_araddr),    // output wire [31 : 0] m_axi_araddr
  .m_axi_arprot         (host_axil_arprot),    // output wire [2 : 0] m_axi_arprot
  .m_axi_arvalid        (host_axil_arvalid),  // output wire m_axi_arvalid
  .m_axi_arready        (host_axil_arready),  // input wire m_axi_arready
  .m_axi_rdata          (host_axil_rdata),      // input wire [31 : 0] m_axi_rdata
  .m_axi_rresp          (host_axil_rresp),      // input wire [1 : 0] m_axi_rresp
  .m_axi_rvalid         (host_axil_rvalid),    // input wire m_axi_rvalid
  .m_axi_rready         (host_axil_rready)    // output wire m_axi_rready
);

//===========================================================================
// AXI Memory Master VIP
//===========================================================================

axi_memory_master_vip axi_memory_master_vip_i (
  .aclk               (sys_clk_i),                    // input wire aclk
  .aresetn            (!sys_rst),              // input wire aresetn

  .m_axi_awid         (memory_intf.top_axi_interconnect_axi_awid),        // output wire [3 : 0] m_axi_awid
  .m_axi_awaddr       (memory_intf.top_axi_interconnect_axi_awaddr),    // output wire [33 : 0] m_axi_awaddr
  .m_axi_awlen        (memory_intf.top_axi_interconnect_axi_awlen),      // output wire [7 : 0] m_axi_awlen
  .m_axi_awsize       (memory_intf.top_axi_interconnect_axi_awsize),    // output wire [2 : 0] m_axi_awsize
  .m_axi_awburst      (memory_intf.top_axi_interconnect_axi_awburst),  // output wire [1 : 0] m_axi_awburst
  .m_axi_awlock       (memory_intf.top_axi_interconnect_axi_awlock),    // output wire [0 : 0] m_axi_awlock
  .m_axi_awcache      (memory_intf.top_axi_interconnect_axi_awcache),  // output wire [3 : 0] m_axi_awcache
  .m_axi_awprot       (memory_intf.top_axi_interconnect_axi_awprot),    // output wire [2 : 0] m_axi_awprot
  .m_axi_awqos        (memory_intf.top_axi_interconnect_axi_awqos),      // output wire [3 : 0] m_axi_awqos
  .m_axi_awvalid      (memory_intf.top_axi_interconnect_axi_awvalid),  // output wire m_axi_awvalid
  .m_axi_awready      (memory_intf.top_axi_interconnect_axi_awready),  // input wire m_axi_awready
  .m_axi_wdata        (memory_intf.top_axi_interconnect_axi_wdata),      // output wire [511 : 0] m_axi_wdata
  .m_axi_wstrb        (memory_intf.top_axi_interconnect_axi_wstrb),      // output wire [63 : 0] m_axi_wstrb
  .m_axi_wlast        (memory_intf.top_axi_interconnect_axi_wlast),      // output wire m_axi_wlast
  .m_axi_wvalid       (memory_intf.top_axi_interconnect_axi_wvalid),    // output wire m_axi_wvalid
  .m_axi_wready       (memory_intf.top_axi_interconnect_axi_wready),    // input wire m_axi_wready
  .m_axi_bid          (memory_intf.top_axi_interconnect_axi_bid),          // input wire [3 : 0] m_axi_bid
  .m_axi_bresp        (memory_intf.top_axi_interconnect_axi_bresp),      // input wire [1 : 0] m_axi_bresp
  .m_axi_bvalid       (memory_intf.top_axi_interconnect_axi_bvalid),    // input wire m_axi_bvalid
  .m_axi_bready       (memory_intf.top_axi_interconnect_axi_bready),    // output wire m_axi_bready
  .m_axi_arid         (memory_intf.top_axi_interconnect_axi_arid),        // output wire [3 : 0] m_axi_arid
  .m_axi_araddr       (memory_intf.top_axi_interconnect_axi_araddr),    // output wire [33 : 0] m_axi_araddr
  .m_axi_arlen        (memory_intf.top_axi_interconnect_axi_arlen),      // output wire [7 : 0] m_axi_arlen
  .m_axi_arsize       (memory_intf.top_axi_interconnect_axi_arsize),    // output wire [2 : 0] m_axi_arsize
  .m_axi_arburst      (memory_intf.top_axi_interconnect_axi_arburst),  // output wire [1 : 0] m_axi_arburst
  .m_axi_arlock       (memory_intf.top_axi_interconnect_axi_arlock),    // output wire [0 : 0] m_axi_arlock
  .m_axi_arcache      (memory_intf.top_axi_interconnect_axi_arcache),  // output wire [3 : 0] m_axi_arcache
  .m_axi_arprot       (memory_intf.top_axi_interconnect_axi_arprot),    // output wire [2 : 0] m_axi_arprot
  .m_axi_arqos        (memory_intf.top_axi_interconnect_axi_arqos),      // output wire [3 : 0] m_axi_arqos
  .m_axi_arvalid      (memory_intf.top_axi_interconnect_axi_arvalid),  // output wire m_axi_arvalid
  .m_axi_arready      (memory_intf.top_axi_interconnect_axi_arready),  // input wire m_axi_arready
  .m_axi_rid          (memory_intf.top_axi_interconnect_axi_rid),          // input wire [3 : 0] m_axi_rid
  .m_axi_rdata        (memory_intf.top_axi_interconnect_axi_rdata),      // input wire [511 : 0] m_axi_rdata
  .m_axi_rresp        (memory_intf.top_axi_interconnect_axi_rresp),      // input wire [1 : 0] m_axi_rresp
  .m_axi_rlast        (memory_intf.top_axi_interconnect_axi_rlast),      // input wire m_axi_rlast
  .m_axi_rvalid       (memory_intf.top_axi_interconnect_axi_rvalid),    // input wire m_axi_rvalid
  .m_axi_rready       (memory_intf.top_axi_interconnect_axi_rready)    // output wire m_axi_rready
);

//===========================================================================
// Tests
//===========================================================================

node_scoreboard_interface node_scoreboard_interface_i 
(
    .core_clk ('0),
    .resetn ('0),

    // Regbank Slave AXI interface
    .s_axi_awaddr       ('0),
    .s_axi_awprot       ('0),
    .s_axi_awvalid      ('0),
    .s_axi_awready      ('0),
    .s_axi_wdata        ('0),
    .s_axi_wstrb        ('0),
    .s_axi_wvalid       ('0),
    .s_axi_wready       ('0),
    .s_axi_araddr       ('0),
    .s_axi_arprot       ('0),
    .s_axi_arvalid      ('0),
    .s_axi_arready      ('0),
    .s_axi_rdata        ('0),
    .s_axi_rresp        ('0),
    .s_axi_rvalid       ('0),
    .s_axi_rready       ('0),
    .s_axi_bresp        ('0),
    .s_axi_bvalid       ('0),
    .s_axi_bready       ('0),
    .nsb_age_req_valid      ('0),
    .nsb_age_req_ready      ('0),
    .nsb_age_req        ('0),
    .nsb_age_resp       ('0),
    .nsb_age_resp_valid     ('0), // valid only for now
    .nsb_fte_req_valid      ('0),
    .nsb_fte_req_ready      ('0),
    .nsb_fte_req        ('0),
    .nsb_fte_resp       ('0),
    .nsb_fte_resp_valid     ('0), // valid only for now
    .nsb_prefetcher_req_valid       ('0),
    .nsb_prefetcher_req_ready       ('0),
    .nsb_prefetcher_req     ('0),
    .nsb_prefetcher_resp        ('0),
    .nsb_prefetcher_resp_valid      ('0), // valid only for now
    .nsb_output_buffer_req_valid        ('0),
    .nsb_output_buffer_req_ready        ('0),
    .nsb_output_buffer_req      ('0),
    .nsb_output_buffer_resp_valid       ('0), // valid only for now
    .nsb_output_buffer_resp     ('0)
);

aggregation_engine_interface aggregation_engine_interface_i 
(

    .core_clk ('0),
    .resetn ('0),
    
    // Regbank Slave AXI interface
    .s_axi_awaddr ('0),
    .s_axi_awprot ('0),
    .s_axi_awvalid ('0),
    .s_axi_awready ('0),
    .s_axi_wdata ('0),
    .s_axi_wstrb ('0),
    .s_axi_wvalid ('0),
    .s_axi_wready ('0),
    .s_axi_araddr ('0),
    .s_axi_arprot ('0),
    .s_axi_arvalid ('0),
    .s_axi_arready ('0),
    .s_axi_rdata ('0),
    .s_axi_rresp ('0),
    .s_axi_rvalid ('0),
    .s_axi_rready ('0),
    .s_axi_bresp ('0),
    .s_axi_bvalid ('0),
    .s_axi_bready ('0),
    .nsb_age_req_valid ('0),
    .nsb_age_req_ready ('0),
    .nsb_age_req ('0),
    .nsb_age_resp_valid ('0), // valid only for now
    .nsb_age_resp ('0),
    .message_channel_req_valid ('0),
    .message_channel_req_ready ('0),
    .message_channel_req ('0),
    .message_channel_resp_valid ('0),
    .message_channel_resp_ready ('0),
    .message_channel_resp ('0),
    .age_buffer_manager_buffer_slot_write_enable ('0),
    .age_buffer_manager_buffer_slot_write_address ('0),
    .age_buffer_manager_buffer_slot_write_data ('0)
);

prefetcher_interface prefetcher_interface_i 
(
    .core_clk ('0),
    .resetn ('0),
    .nsb_prefetcher_req_valid ('0),
    .nsb_prefetcher_req_ready ('0),
    .nsb_prefetcher_req ('0),
    .nsb_prefetcher_resp_valid ('0), // valid only for now
    .nsb_prefetcher_resp ('0),
    .prefetcher_adj_rm_axi_interconnect_axi_araddr ('0),
    .prefetcher_adj_rm_axi_interconnect_axi_arburst ('0),
    .prefetcher_adj_rm_axi_interconnect_axi_arcache ('0),
    .prefetcher_adj_rm_axi_interconnect_axi_arid ('0),
    .prefetcher_adj_rm_axi_interconnect_axi_arlen ('0),
    .prefetcher_adj_rm_axi_interconnect_axi_arlock ('0),
    .prefetcher_adj_rm_axi_interconnect_axi_arprot ('0),
    .prefetcher_adj_rm_axi_interconnect_axi_arqos ('0),
    .prefetcher_adj_rm_axi_interconnect_axi_arsize ('0),
    .prefetcher_adj_rm_axi_interconnect_axi_arvalid ('0),
    .prefetcher_adj_rm_axi_interconnect_axi_arready ('0),
    .prefetcher_adj_rm_axi_interconnect_axi_awaddr ('0),
    .prefetcher_adj_rm_axi_interconnect_axi_awburst ('0),
    .prefetcher_adj_rm_axi_interconnect_axi_awcache ('0),
    .prefetcher_adj_rm_axi_interconnect_axi_awid ('0),
    .prefetcher_adj_rm_axi_interconnect_axi_awlen ('0),
    .prefetcher_adj_rm_axi_interconnect_axi_awlock ('0),
    .prefetcher_adj_rm_axi_interconnect_axi_awprot ('0),
    .prefetcher_adj_rm_axi_interconnect_axi_awqos ('0),
    .prefetcher_adj_rm_axi_interconnect_axi_awready ('0),
    .prefetcher_adj_rm_axi_interconnect_axi_awsize ('0),
    .prefetcher_adj_rm_axi_interconnect_axi_awvalid ('0),
    .prefetcher_adj_rm_axi_interconnect_axi_bid ('0),
    .prefetcher_adj_rm_axi_interconnect_axi_bready ('0),
    .prefetcher_adj_rm_axi_interconnect_axi_bresp ('0),
    .prefetcher_adj_rm_axi_interconnect_axi_bvalid ('0),
    .prefetcher_adj_rm_axi_interconnect_axi_rdata ('0),
    .prefetcher_adj_rm_axi_interconnect_axi_rid ('0),
    .prefetcher_adj_rm_axi_interconnect_axi_rlast ('0),
    .prefetcher_adj_rm_axi_interconnect_axi_rready ('0),
    .prefetcher_adj_rm_axi_interconnect_axi_rresp ('0),
    .prefetcher_adj_rm_axi_interconnect_axi_rvalid ('0),
    .prefetcher_adj_rm_axi_interconnect_axi_wdata ('0),
    .prefetcher_adj_rm_axi_interconnect_axi_wlast ('0),
    .prefetcher_adj_rm_axi_interconnect_axi_wready ('0),
    .prefetcher_adj_rm_axi_interconnect_axi_wstrb ('0),
    .prefetcher_adj_rm_axi_interconnect_axi_wvalid ('0),
    .prefetcher_msg_rm_axi_interconnect_axi_araddr ('0),
    .prefetcher_msg_rm_axi_interconnect_axi_arburst ('0),
    .prefetcher_msg_rm_axi_interconnect_axi_arcache ('0),
    .prefetcher_msg_rm_axi_interconnect_axi_arid ('0),
    .prefetcher_msg_rm_axi_interconnect_axi_arlen ('0),
    .prefetcher_msg_rm_axi_interconnect_axi_arlock ('0),
    .prefetcher_msg_rm_axi_interconnect_axi_arprot ('0),
    .prefetcher_msg_rm_axi_interconnect_axi_arqos ('0),
    .prefetcher_msg_rm_axi_interconnect_axi_arsize ('0),
    .prefetcher_msg_rm_axi_interconnect_axi_arvalid ('0),
    .prefetcher_msg_rm_axi_interconnect_axi_arready ('0),
    .prefetcher_msg_rm_axi_interconnect_axi_awaddr ('0),
    .prefetcher_msg_rm_axi_interconnect_axi_awburst ('0),
    .prefetcher_msg_rm_axi_interconnect_axi_awcache ('0),
    .prefetcher_msg_rm_axi_interconnect_axi_awid ('0),
    .prefetcher_msg_rm_axi_interconnect_axi_awlen ('0),
    .prefetcher_msg_rm_axi_interconnect_axi_awlock ('0),
    .prefetcher_msg_rm_axi_interconnect_axi_awprot ('0),
    .prefetcher_msg_rm_axi_interconnect_axi_awqos ('0),
    .prefetcher_msg_rm_axi_interconnect_axi_awready ('0),
    .prefetcher_msg_rm_axi_interconnect_axi_awsize ('0),
    .prefetcher_msg_rm_axi_interconnect_axi_awvalid ('0),
    .prefetcher_msg_rm_axi_interconnect_axi_bid ('0),
    .prefetcher_msg_rm_axi_interconnect_axi_bready ('0),
    .prefetcher_msg_rm_axi_interconnect_axi_bresp ('0),
    .prefetcher_msg_rm_axi_interconnect_axi_bvalid ('0),
    .prefetcher_msg_rm_axi_interconnect_axi_rdata ('0),
    .prefetcher_msg_rm_axi_interconnect_axi_rid ('0),
    .prefetcher_msg_rm_axi_interconnect_axi_rlast ('0),
    .prefetcher_msg_rm_axi_interconnect_axi_rready ('0),
    .prefetcher_msg_rm_axi_interconnect_axi_rresp ('0),
    .prefetcher_msg_rm_axi_interconnect_axi_rvalid ('0),
    .prefetcher_msg_rm_axi_interconnect_axi_wdata ('0),
    .prefetcher_msg_rm_axi_interconnect_axi_wlast ('0),
    .prefetcher_msg_rm_axi_interconnect_axi_wready ('0),
    .prefetcher_msg_rm_axi_interconnect_axi_wstrb ('0),
    .prefetcher_msg_rm_axi_interconnect_axi_wvalid ('0),
    .prefetcher_weight_bank_rm_axi_interconnect_axi_araddr ('0),
    .prefetcher_weight_bank_rm_axi_interconnect_axi_arburst ('0),
    .prefetcher_weight_bank_rm_axi_interconnect_axi_arcache ('0),
    .prefetcher_weight_bank_rm_axi_interconnect_axi_arid ('0),
    .prefetcher_weight_bank_rm_axi_interconnect_axi_arlen ('0),
    .prefetcher_weight_bank_rm_axi_interconnect_axi_arlock ('0),
    .prefetcher_weight_bank_rm_axi_interconnect_axi_arprot ('0),
    .prefetcher_weight_bank_rm_axi_interconnect_axi_arqos ('0),
    .prefetcher_weight_bank_rm_axi_interconnect_axi_arsize ('0),
    .prefetcher_weight_bank_rm_axi_interconnect_axi_arvalid ('0),
    .prefetcher_weight_bank_rm_axi_interconnect_axi_arready ('0),
    .prefetcher_weight_bank_rm_axi_interconnect_axi_awaddr ('0),
    .prefetcher_weight_bank_rm_axi_interconnect_axi_awburst ('0),
    .prefetcher_weight_bank_rm_axi_interconnect_axi_awcache ('0),
    .prefetcher_weight_bank_rm_axi_interconnect_axi_awid ('0),
    .prefetcher_weight_bank_rm_axi_interconnect_axi_awlen ('0),
    .prefetcher_weight_bank_rm_axi_interconnect_axi_awlock ('0),
    .prefetcher_weight_bank_rm_axi_interconnect_axi_awprot ('0),
    .prefetcher_weight_bank_rm_axi_interconnect_axi_awqos ('0),
    .prefetcher_weight_bank_rm_axi_interconnect_axi_awready ('0),
    .prefetcher_weight_bank_rm_axi_interconnect_axi_awsize ('0),
    .prefetcher_weight_bank_rm_axi_interconnect_axi_awvalid ('0),
    .prefetcher_weight_bank_rm_axi_interconnect_axi_bid ('0),
    .prefetcher_weight_bank_rm_axi_interconnect_axi_bready ('0),
    .prefetcher_weight_bank_rm_axi_interconnect_axi_bresp ('0),
    .prefetcher_weight_bank_rm_axi_interconnect_axi_bvalid ('0),
    .prefetcher_weight_bank_rm_axi_interconnect_axi_rdata ('0),
    .prefetcher_weight_bank_rm_axi_interconnect_axi_rid ('0),
    .prefetcher_weight_bank_rm_axi_interconnect_axi_rlast ('0),
    .prefetcher_weight_bank_rm_axi_interconnect_axi_rready ('0),
    .prefetcher_weight_bank_rm_axi_interconnect_axi_rresp ('0),
    .prefetcher_weight_bank_rm_axi_interconnect_axi_rvalid ('0),
    .prefetcher_weight_bank_rm_axi_interconnect_axi_wdata ('0),
    .prefetcher_weight_bank_rm_axi_interconnect_axi_wlast ('0),
    .prefetcher_weight_bank_rm_axi_interconnect_axi_wready ('0),
    .prefetcher_weight_bank_rm_axi_interconnect_axi_wstrb ('0),
    .prefetcher_weight_bank_rm_axi_interconnect_axi_wvalid ('0),
    .message_channel_req_valid ('0),
    .message_channel_req_ready ('0),
    .message_channel_req ('0),
    .message_channel_resp_valid ('0),
    .message_channel_resp_ready ('0),
    .message_channel_resp ('0),
    .weight_channel_req_valid ('0),
    .weight_channel_req_ready ('0),
    .weight_channel_req ('0),
    .weight_channel_resp_valid ('0),
    .weight_channel_resp_ready ('0),
    .weight_channel_resp ('0)
);

top_test top_test_i (
    // .memory_intf                    (memory_intf),
    .nsb_intf                       (top_i.node_scoreboard_i.nsb_interface),   //   node_scoreboard_interface_i
    .age_intf                       (top_i.aggregation_engine_i.age_interface),   //   aggregation_engine_interface_i
    .prefetcher_intf                (top_i.prefetcher_i.prefetcher_interface)  //   prefetcher_interface_i
 );

//===========================================================================
//                         DRAM Model
//===========================================================================

`ifdef DRAM_MODEL

genvar rdimm_x;
			      
generate    
    for(rdimm_x=0; rdimm_x<RDIMM_SLOTS; rdimm_x=rdimm_x+1) begin: instance_of_rdimm_slots
        ddr4_rdimm_wrapper #(
                    .MC_DQ_WIDTH(DQ_WIDTH),
                    .MC_DQS_BITS(DQS_WIDTH),
                    .MC_DM_WIDTH(DM_WIDTH_RDIMM),
                    .MC_CKE_NUM(CKE_WIDTH_RDIMM),
                    .MC_ODT_WIDTH(ODT_WIDTH_RDIMM),
                    .MC_ABITS(ADDR_WIDTH),
                    .MC_BANK_WIDTH(BANK_WIDTH_RDIMM),
                    .MC_BANK_GROUP(BANK_GROUP_WIDTH_RDIMM),
                    .MC_CS_NUM(CS_WIDTH_RDIMM),
                    .MC_RANKS_NUM(RANK_WIDTH_RDIMM),
                    .NUM_PHYSICAL_PARTS(NUM_PHYSICAL_PARTS),
                    .CALIB_EN("NO"),
                    .tCK(tCK),
                    .tPDM(),
                    .MIN_TOTAL_R2R_DELAY(),
                    .MAX_TOTAL_R2R_DELAY(),
                    .TOTAL_FBT_DELAY(),
                    .MEM_PART_WIDTH(MEM_PART_WIDTH),
                    .MC_CA_MIRROR(CA_MIRROR),
        `ifdef SAMSUNG
                    .DDR_SIM_MODEL("SAMSUNG"),

        `else         
                    .DDR_SIM_MODEL("MICRON"),
        `endif
                    .DM_DBI(DM_DBI),
                    .MC_REG_CTRL(REG_CTRL),
                    .DIMM_MODEL ("RDIMM"),
                    .RDIMM_SLOTS (RDIMM_SLOTS),
                    .CONFIGURED_DENSITY (CONFIGURED_DENSITY)
        ) u_ddr4_rdimm_wrapper  (
                    .ddr4_act_n(c0_ddr4_act_n), // input
                    .ddr4_addr(c0_ddr4_adr), // input
                    .ddr4_ba(c0_ddr4_ba), // input
                    .ddr4_bg(c0_ddr4_bg), // input
                    .ddr4_par(c0_ddr4_parity), // input
                    .ddr4_cke(c0_ddr4_cke[CKE_WIDTH_RDIMM-1:0]), // input
                    .ddr4_odt(c0_ddr4_odt[ODT_WIDTH_RDIMM-1:0]), // input
                    .ddr4_cs_n(c0_ddr4_cs_n[CS_WIDTH_RDIMM-1:0]), // input
                    .ddr4_ck_t(c0_ddr4_ck_t), // input
                    .ddr4_ck_c(c0_ddr4_ck_c), // input
                    .ddr4_reset_n(c0_ddr4_reset_n), // input
                    .ddr4_dm_dbi_n       (),
                    .ddr4_dq(c0_ddr4_dq), // inout
                    .ddr4_dqs_t(c0_ddr4_dqs_t), // inout
                    .ddr4_dqs_c(c0_ddr4_dqs_c), // inout
                    .ddr4_alert_n(), // inout
                    .initDone(c0_init_calib_complete), // inout
                    .scl(), // input
                    .sa0(), // input
                    .sa1(), // input
                    .sa2(), // input
                    .sda(), // inout
                    .bfunc(), // input
                    .vddspd() // input
        );
    end
endgenerate

always @(*) begin
    if (c0_ddr4_cs_n == 4'b1111)
        cmdName = "DSEL";
    else
    if (c0_ddr4_act_n)
        casez (DDR4_ADRMOD[0][16:14])
        MRS:     cmdName = "MRS";
        REF:     cmdName = "REF";
        PRE:     cmdName = "PRE";
        WR:      cmdName = "WR";
        RD:      cmdName = "RD";
        ZQC:     cmdName = "ZQC";
        NOP:     cmdName = "NOP";
        default:  cmdName = "***";
        endcase
    else
        cmdName = "ACT";
end

reg wr_en ;
always@(posedge c0_ddr4_ck_t)begin
    if(!c0_ddr4_reset_n)begin
    wr_en <= #100 1'b0 ;
    end else begin
    if(cmdName == "WR")begin
        wr_en <= #100 1'b1 ;
    end else if (cmdName == "RD")begin
        wr_en <= #100 1'b0 ;
    end
    end
end

genvar rnk;

generate
for (rnk = 0; rnk < CS_WIDTH; rnk++) begin:rankup
 always @(*)
    if (c0_ddr4_act_n)
        casez (c0_ddr4_adr_sdram[0][16:14])
        WR, RD: begin
        DDR4_ADRMOD[rnk] = c0_ddr4_adr_sdram[rnk] & 18'h1C7FF;
        end
        default: begin
        DDR4_ADRMOD[rnk] = c0_ddr4_adr_sdram[rnk];
        end
        endcase
    else begin
        DDR4_ADRMOD[rnk] = c0_ddr4_adr_sdram[rnk];
    end
end
endgenerate

`endif

//===========================================================================
//                         RAM Model
//===========================================================================

`ifdef RAM_MODEL

axi_ram #(
    .DATA_WIDTH(512),
    .ADDR_WIDTH(34),
    .ID_WIDTH(8)
) ram_model (
    .clk                    (sys_clk_i),
    .rst                    (sys_rst),

    .s_axi_awid             (axi_interconnect_memory_axi_awid),
    .s_axi_awaddr           (axi_interconnect_memory_axi_awaddr),
    .s_axi_awlen            (axi_interconnect_memory_axi_awlen),
    .s_axi_awsize           (axi_interconnect_memory_axi_awsize),
    .s_axi_awburst          (axi_interconnect_memory_axi_awburst),
    .s_axi_awlock           (axi_interconnect_memory_axi_awlock),
    .s_axi_awcache          (axi_interconnect_memory_axi_awcache),
    .s_axi_awprot           (axi_interconnect_memory_axi_awprot),
    .s_axi_awvalid          (axi_interconnect_memory_axi_awvalid),
    .s_axi_awready          (axi_interconnect_memory_axi_awready),
    .s_axi_wdata            (axi_interconnect_memory_axi_wdata),
    .s_axi_wstrb            (axi_interconnect_memory_axi_wstrb),
    .s_axi_wlast            (axi_interconnect_memory_axi_wlast),
    .s_axi_wvalid           (axi_interconnect_memory_axi_wvalid),
    .s_axi_wready           (axi_interconnect_memory_axi_wready),
    .s_axi_bid              (axi_interconnect_memory_axi_bid),
    .s_axi_bresp            (axi_interconnect_memory_axi_bresp),
    .s_axi_bvalid           (axi_interconnect_memory_axi_bvalid),
    .s_axi_bready           (axi_interconnect_memory_axi_bready),
    .s_axi_arid             (axi_interconnect_memory_axi_arid),
    .s_axi_araddr           (axi_interconnect_memory_axi_araddr),
    .s_axi_arlen            (axi_interconnect_memory_axi_arlen),
    .s_axi_arsize           (axi_interconnect_memory_axi_arsize),
    .s_axi_arburst          (axi_interconnect_memory_axi_arburst),
    .s_axi_arlock           (axi_interconnect_memory_axi_arlock),
    .s_axi_arcache          (axi_interconnect_memory_axi_arcache),
    .s_axi_arprot           (axi_interconnect_memory_axi_arprot),
    .s_axi_arvalid          (axi_interconnect_memory_axi_arvalid),
    .s_axi_arready          (axi_interconnect_memory_axi_arready),
    .s_axi_rid              (axi_interconnect_memory_axi_rid),
    .s_axi_rdata            (axi_interconnect_memory_axi_rdata),
    .s_axi_rresp            (axi_interconnect_memory_axi_rresp),
    .s_axi_rlast            (axi_interconnect_memory_axi_rlast),
    .s_axi_rvalid           (axi_interconnect_memory_axi_rvalid),
    .s_axi_rready           (axi_interconnect_memory_axi_rready)
);

`endif

//===========================================================================
//                         Binds
//===========================================================================

bind top_i.node_scoreboard_i node_scoreboard_interface nsb_interface (
    .*
);

bind top_i.aggregation_engine_i aggregation_engine_interface age_interface (
    .*
);

bind top_i.prefetcher_i prefetcher_interface prefetcher_interface (
    .*
);

endmodule