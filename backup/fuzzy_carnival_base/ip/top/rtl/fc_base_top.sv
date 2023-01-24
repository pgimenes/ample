
module fc_base_top(

    input   logic                      default_300mhz_clk0_clk_n,
    input   logic                      default_300mhz_clk0_clk_p,
    input   logic                      resetn,

    // DDR 4 signals
    output  logic                      ddr4_sdram_c0_act_n,
    output  logic [16:0]               ddr4_sdram_c0_adr,
    output  logic [1:0]                ddr4_sdram_c0_ba,
    output  logic [1:0]                ddr4_sdram_c0_bg,
    output  logic                      ddr4_sdram_c0_ck_c,
    output  logic                      ddr4_sdram_c0_ck_t,
    output  logic                      ddr4_sdram_c0_cke,
    output  logic                      ddr4_sdram_c0_cs_n,
    inout   logic [71:0]               ddr4_sdram_c0_dq,
    inout   logic [17:0]               ddr4_sdram_c0_dqs_c,
    inout   logic [17:0]               ddr4_sdram_c0_dqs_t,
    output  logic                      ddr4_sdram_c0_odt,
    output  logic                      ddr4_sdram_c0_par,
    output  logic                      ddr4_sdram_c0_reset_n,

    output logic c0_init_calib_complete
);

parameter AXI_ADDR_WIDTH = 32;

// ===============================================================================================================
// Declarations
// ===============================================================================================================

logic core_clk;

logic [31:0]                                        C0_DDR4_S_AXI_CTRL_0_araddr;                // input   
logic                                               C0_DDR4_S_AXI_CTRL_0_arready;                // output  
logic                                               C0_DDR4_S_AXI_CTRL_0_arvalid;               // input   
logic [31:0]                                        C0_DDR4_S_AXI_CTRL_0_awaddr;                // input   
logic                                               C0_DDR4_S_AXI_CTRL_0_awready;                // output  
logic                                               C0_DDR4_S_AXI_CTRL_0_awvalid;               // input   
logic                                               C0_DDR4_S_AXI_CTRL_0_bready;                // input   
logic [1:0]                                         C0_DDR4_S_AXI_CTRL_0_bresp;              // output  
logic                                               C0_DDR4_S_AXI_CTRL_0_bvalid;             // output  
logic [31:0]                                        C0_DDR4_S_AXI_CTRL_0_rdata;              // output  
logic                                               C0_DDR4_S_AXI_CTRL_0_rready;                // input   
logic [1:0]                                         C0_DDR4_S_AXI_CTRL_0_rresp;              // output  
logic                                               C0_DDR4_S_AXI_CTRL_0_rvalid;             // output  
logic [31:0]                                        C0_DDR4_S_AXI_CTRL_0_wdata;             // input   
logic                                               C0_DDR4_S_AXI_CTRL_0_wready;             // output  
logic                                               C0_DDR4_S_AXI_CTRL_0_wvalid;                // input   

// Aggregation Engine -> AXI
logic                                               aggregation_engine_axi_interconnect_aclk;             // input   
logic                                               aggregation_engine_axi_interconnect_aresetn;              // input   
logic [31:0]                                        aggregation_engine_axi_interconnect_araddr;               // input   
logic [1:0]                                         aggregation_engine_axi_interconnect_arburst;              // input   
logic [3:0]                                         aggregation_engine_axi_interconnect_arcache;              // input   
logic [0:0]                                         aggregation_engine_axi_interconnect_arid;             // input   
logic [7:0]                                         aggregation_engine_axi_interconnect_arlen;                // input   
logic [0:0]                                         aggregation_engine_axi_interconnect_arlock;               // input   
logic [2:0]                                         aggregation_engine_axi_interconnect_arprot;               // input   
logic [3:0]                                         aggregation_engine_axi_interconnect_arqos;                // input   
logic                                               aggregation_engine_axi_interconnect_arready;               // output  
logic [3:0]                                         aggregation_engine_axi_interconnect_arregion;             // input   
logic [2:0]                                         aggregation_engine_axi_interconnect_arsize;               // input   
logic                                               aggregation_engine_axi_interconnect_arvalid;              // input   
logic [31:0]                                        aggregation_engine_axi_interconnect_awaddr;               // input   
logic [1:0]                                         aggregation_engine_axi_interconnect_awburst;              // input   
logic [3:0]                                         aggregation_engine_axi_interconnect_awcache;              // input   
logic [0:0]                                         aggregation_engine_axi_interconnect_awid;             // input   
logic [7:0]                                         aggregation_engine_axi_interconnect_awlen;                // input   
logic [0:0]                                         aggregation_engine_axi_interconnect_awlock;               // input   
logic [2:0]                                         aggregation_engine_axi_interconnect_awprot;               // input   
logic [3:0]                                         aggregation_engine_axi_interconnect_awqos;                // input   
logic                                               aggregation_engine_axi_interconnect_awready;               // output  
logic [3:0]                                         aggregation_engine_axi_interconnect_awregion;             // input   
logic [2:0]                                         aggregation_engine_axi_interconnect_awsize;               // input   
logic                                               aggregation_engine_axi_interconnect_awvalid;              // input   
logic [0:0]                                         aggregation_engine_axi_interconnect_bid;               // output  
logic                                               aggregation_engine_axi_interconnect_bready;               // input   
logic [1:0]                                         aggregation_engine_axi_interconnect_bresp;             // output  
logic                                               aggregation_engine_axi_interconnect_bvalid;                // output  
logic [31:0]                                        aggregation_engine_axi_interconnect_rdata;             // output  
logic [0:0]                                         aggregation_engine_axi_interconnect_rid;               // output  
logic                                               aggregation_engine_axi_interconnect_rlast;             // output  
logic                                               aggregation_engine_axi_interconnect_rready;               // input   
logic [1:0]                                         aggregation_engine_axi_interconnect_rresp;             // output  
logic                                               aggregation_engine_axi_interconnect_rvalid;                // output  
logic [31:0]                                        aggregation_engine_axi_interconnect_wdata;                // input   
logic                                               aggregation_engine_axi_interconnect_wlast;                // input   
logic                                               aggregation_engine_axi_interconnect_wready;                // output  
logic [3:0]                                         aggregation_engine_axi_interconnect_wstrb;                // input   
logic                                               aggregation_engine_axi_interconnect_wvalid;               // input   

// Transformation Engine -> AXI
logic                                               transformation_engine_axi_interconnect_aclk;             // input   
logic                                               transformation_engine_axi_interconnect_aresetn;              // input   
logic [31:0]                                        transformation_engine_axi_interconnect_araddr;               // input   
logic [1:0]                                         transformation_engine_axi_interconnect_arburst;              // input   
logic [3:0]                                         transformation_engine_axi_interconnect_arcache;              // input   
logic [0:0]                                         transformation_engine_axi_interconnect_arid;             // input   
logic [7:0]                                         transformation_engine_axi_interconnect_arlen;                // input   
logic [0:0]                                         transformation_engine_axi_interconnect_arlock;               // input   
logic [2:0]                                         transformation_engine_axi_interconnect_arprot;               // input   
logic [3:0]                                         transformation_engine_axi_interconnect_arqos;                // input   
logic                                               transformation_engine_axi_interconnect_arready;               // output  
logic [3:0]                                         transformation_engine_axi_interconnect_arregion;             // input   
logic [2:0]                                         transformation_engine_axi_interconnect_arsize;               // input   
logic                                               transformation_engine_axi_interconnect_arvalid;              // input   
logic [31:0]                                        transformation_engine_axi_interconnect_awaddr;               // input   
logic [1:0]                                         transformation_engine_axi_interconnect_awburst;              // input   
logic [3:0]                                         transformation_engine_axi_interconnect_awcache;              // input   
logic [0:0]                                         transformation_engine_axi_interconnect_awid;             // input   
logic [7:0]                                         transformation_engine_axi_interconnect_awlen;                // input   
logic [0:0]                                         transformation_engine_axi_interconnect_awlock;               // input   
logic [2:0]                                         transformation_engine_axi_interconnect_awprot;               // input   
logic [3:0]                                         transformation_engine_axi_interconnect_awqos;                // input   
logic                                               transformation_engine_axi_interconnect_awready;               // output  
logic [3:0]                                         transformation_engine_axi_interconnect_awregion;             // input   
logic [2:0]                                         transformation_engine_axi_interconnect_awsize;               // input   
logic                                               transformation_engine_axi_interconnect_awvalid;              // input   
logic [0:0]                                         transformation_engine_axi_interconnect_bid;               // output  
logic                                               transformation_engine_axi_interconnect_bready;               // input   
logic [1:0]                                         transformation_engine_axi_interconnect_bresp;             // output  
logic                                               transformation_engine_axi_interconnect_bvalid;                // output  
logic [31:0]                                        transformation_engine_axi_interconnect_rdata;             // output  
logic [0:0]                                         transformation_engine_axi_interconnect_rid;               // output  
logic                                               transformation_engine_axi_interconnect_rlast;             // output  
logic                                               transformation_engine_axi_interconnect_rready;               // input   
logic [1:0]                                         transformation_engine_axi_interconnect_rresp;             // output  
logic                                               transformation_engine_axi_interconnect_rvalid;                // output  
logic [31:0]                                        transformation_engine_axi_interconnect_wdata;                // input   
logic                                               transformation_engine_axi_interconnect_wlast;                // input   
logic                                               transformation_engine_axi_interconnect_wready;                // output  
logic [3:0]                                         transformation_engine_axi_interconnect_wstrb;                // input   
logic                                               transformation_engine_axi_interconnect_wvalid;               // input   

// AXI-L -> Aggregation Engine: Regbank Interface
logic [AXI_ADDR_WIDTH-1:0] fc_base_aggregation_engine_s_axi_awaddr;
logic [2:0]                fc_base_aggregation_engine_s_axi_awprot;
logic                      fc_base_aggregation_engine_s_axi_awvalid;
logic                      fc_base_aggregation_engine_s_axi_awready;
logic [31:0]               fc_base_aggregation_engine_s_axi_wdata;
logic [3:0]                fc_base_aggregation_engine_s_axi_wstrb;
logic                      fc_base_aggregation_engine_s_axi_wvalid;
logic                      fc_base_aggregation_engine_s_axi_wready;
logic [AXI_ADDR_WIDTH-1:0] fc_base_aggregation_engine_s_axi_araddr;
logic [2:0]                fc_base_aggregation_engine_s_axi_arprot;
logic                      fc_base_aggregation_engine_s_axi_arvalid;
logic                      fc_base_aggregation_engine_s_axi_arready;
logic [31:0]               fc_base_aggregation_engine_s_axi_rdata;
logic [1:0]                fc_base_aggregation_engine_s_axi_rresp;
logic                      fc_base_aggregation_engine_s_axi_rvalid;
logic                      fc_base_aggregation_engine_s_axi_rready;
logic [1:0]                fc_base_aggregation_engine_s_axi_bresp;
logic                      fc_base_aggregation_engine_s_axi_bvalid;
logic                      fc_base_aggregation_engine_s_axi_bready;

// AXI-L -> Transformation Engine: Regbank Interface
logic [AXI_ADDR_WIDTH-1:0] fc_base_transformation_engine_s_axi_awaddr;
logic [2:0]                fc_base_transformation_engine_s_axi_awprot;
logic                      fc_base_transformation_engine_s_axi_awvalid;
logic                      fc_base_transformation_engine_s_axi_awready;
logic [31:0]               fc_base_transformation_engine_s_axi_wdata;
logic [3:0]                fc_base_transformation_engine_s_axi_wstrb;
logic                      fc_base_transformation_engine_s_axi_wvalid;
logic                      fc_base_transformation_engine_s_axi_wready;
logic [AXI_ADDR_WIDTH-1:0] fc_base_transformation_engine_s_axi_araddr;
logic [2:0]                fc_base_transformation_engine_s_axi_arprot;
logic                      fc_base_transformation_engine_s_axi_arvalid;
logic                      fc_base_transformation_engine_s_axi_arready;
logic [31:0]               fc_base_transformation_engine_s_axi_rdata;
logic [1:0]                fc_base_transformation_engine_s_axi_rresp;
logic                      fc_base_transformation_engine_s_axi_rvalid;
logic                      fc_base_transformation_engine_s_axi_rready;
logic [1:0]                fc_base_transformation_engine_s_axi_bresp;
logic                      fc_base_transformation_engine_s_axi_bvalid;
logic                      fc_base_transformation_engine_s_axi_bready;

logic c0_init_calib_complete_0;
assign c0_init_calib_complete = c0_init_calib_complete_0;

// ===============================================================================================================
// Instances
// ===============================================================================================================

// axi_interconnect_bd_wrapper contains AXI interconnect and DRAM controller
// -------------------------------------------------------------------
axi_interconnect_bd_wrapper axi_interconnect_bd_wrapper_i (
    .default_300mhz_clk0_clk_n,
    .default_300mhz_clk0_clk_p,
    .resetn,

    // DDR4 AXI CTRL
    .C0_DDR4_S_AXI_CTRL_0_araddr,
    .C0_DDR4_S_AXI_CTRL_0_arready,
    .C0_DDR4_S_AXI_CTRL_0_arvalid,
    .C0_DDR4_S_AXI_CTRL_0_awaddr,
    .C0_DDR4_S_AXI_CTRL_0_awready,
    .C0_DDR4_S_AXI_CTRL_0_awvalid,
    .C0_DDR4_S_AXI_CTRL_0_bready,
    .C0_DDR4_S_AXI_CTRL_0_bresp,
    .C0_DDR4_S_AXI_CTRL_0_bvalid,
    .C0_DDR4_S_AXI_CTRL_0_rdata,
    .C0_DDR4_S_AXI_CTRL_0_rready,
    .C0_DDR4_S_AXI_CTRL_0_rresp,
    .C0_DDR4_S_AXI_CTRL_0_rvalid,
    .C0_DDR4_S_AXI_CTRL_0_wdata,
    .C0_DDR4_S_AXI_CTRL_0_wready,
    .C0_DDR4_S_AXI_CTRL_0_wvalid,

    // S00 - Aggregation Engine
    .S00_ACLK_0                                         (aggregation_engine_axi_interconnect_aclk),
    .S00_ARESETN_0                                      (aggregation_engine_axi_interconnect_aresetn),
    .S00_AXI_0_araddr                                   (aggregation_engine_axi_interconnect_araddr),
    .S00_AXI_0_arburst                                  (aggregation_engine_axi_interconnect_arburst),
    .S00_AXI_0_arcache                                  (aggregation_engine_axi_interconnect_arcache),
    .S00_AXI_0_arid                                     (aggregation_engine_axi_interconnect_arid),
    .S00_AXI_0_arlen                                    (aggregation_engine_axi_interconnect_arlen),
    .S00_AXI_0_arlock                                   (aggregation_engine_axi_interconnect_arlock),
    .S00_AXI_0_arprot                                   (aggregation_engine_axi_interconnect_arprot),
    .S00_AXI_0_arqos                                    (aggregation_engine_axi_interconnect_arqos),
    .S00_AXI_0_arready                                  (aggregation_engine_axi_interconnect_arready),
    .S00_AXI_0_arregion                                 (aggregation_engine_axi_interconnect_arregion),
    .S00_AXI_0_arsize                                   (aggregation_engine_axi_interconnect_arsize),
    .S00_AXI_0_arvalid                                  (aggregation_engine_axi_interconnect_arvalid),
    .S00_AXI_0_awaddr                                   (aggregation_engine_axi_interconnect_awaddr),
    .S00_AXI_0_awburst                                  (aggregation_engine_axi_interconnect_awburst),
    .S00_AXI_0_awcache                                  (aggregation_engine_axi_interconnect_awcache),
    .S00_AXI_0_awid                                     (aggregation_engine_axi_interconnect_awid),
    .S00_AXI_0_awlen                                    (aggregation_engine_axi_interconnect_awlen),
    .S00_AXI_0_awlock                                   (aggregation_engine_axi_interconnect_awlock),
    .S00_AXI_0_awprot                                   (aggregation_engine_axi_interconnect_awprot),
    .S00_AXI_0_awqos                                    (aggregation_engine_axi_interconnect_awqos),
    .S00_AXI_0_awready                                  (aggregation_engine_axi_interconnect_awready),
    .S00_AXI_0_awregion                                 (aggregation_engine_axi_interconnect_awregion),
    .S00_AXI_0_awsize                                   (aggregation_engine_axi_interconnect_awsize),
    .S00_AXI_0_awvalid                                  (aggregation_engine_axi_interconnect_awvalid),
    .S00_AXI_0_bid                                      (aggregation_engine_axi_interconnect_bid),
    .S00_AXI_0_bready                                   (aggregation_engine_axi_interconnect_bready),
    .S00_AXI_0_bresp                                    (aggregation_engine_axi_interconnect_bresp),
    .S00_AXI_0_bvalid                                   (aggregation_engine_axi_interconnect_bvalid),
    .S00_AXI_0_rdata                                    (aggregation_engine_axi_interconnect_rdata),
    .S00_AXI_0_rid                                      (aggregation_engine_axi_interconnect_rid),
    .S00_AXI_0_rlast                                    (aggregation_engine_axi_interconnect_rlast),
    .S00_AXI_0_rready                                   (aggregation_engine_axi_interconnect_rready),
    .S00_AXI_0_rresp                                    (aggregation_engine_axi_interconnect_rresp),
    .S00_AXI_0_rvalid                                   (aggregation_engine_axi_interconnect_rvalid),
    .S00_AXI_0_wdata                                    (aggregation_engine_axi_interconnect_wdata),
    .S00_AXI_0_wlast                                    (aggregation_engine_axi_interconnect_wlast),
    .S00_AXI_0_wready                                   (aggregation_engine_axi_interconnect_wready),
    .S00_AXI_0_wstrb                                    (aggregation_engine_axi_interconnect_wstrb),
    .S00_AXI_0_wvalid                                   (aggregation_engine_axi_interconnect_wvalid),

    // S01 - Transformation Engine
    .S01_ACLK_0                                         (transformation_engine_axi_interconnect_aclk),
    .S01_ARESETN_0                                      (transformation_engine_axi_interconnect_aresetn),
    .S01_AXI_0_araddr                                   (transformation_engine_axi_interconnect_araddr),
    .S01_AXI_0_arburst                                  (transformation_engine_axi_interconnect_arburst),
    .S01_AXI_0_arcache                                  (transformation_engine_axi_interconnect_arcache),
    .S01_AXI_0_arid                                     (transformation_engine_axi_interconnect_arid),
    .S01_AXI_0_arlen                                    (transformation_engine_axi_interconnect_arlen),
    .S01_AXI_0_arlock                                   (transformation_engine_axi_interconnect_arlock),
    .S01_AXI_0_arprot                                   (transformation_engine_axi_interconnect_arprot),
    .S01_AXI_0_arqos                                    (transformation_engine_axi_interconnect_arqos),
    .S01_AXI_0_arready                                  (transformation_engine_axi_interconnect_arready),
    .S01_AXI_0_arregion                                 (transformation_engine_axi_interconnect_arregion),
    .S01_AXI_0_arsize                                   (transformation_engine_axi_interconnect_arsize),
    .S01_AXI_0_arvalid                                  (transformation_engine_axi_interconnect_arvalid),
    .S01_AXI_0_awaddr                                   (transformation_engine_axi_interconnect_awaddr),
    .S01_AXI_0_awburst                                  (transformation_engine_axi_interconnect_awburst),
    .S01_AXI_0_awcache                                  (transformation_engine_axi_interconnect_awcache),
    .S01_AXI_0_awid                                     (transformation_engine_axi_interconnect_awid),
    .S01_AXI_0_awlen                                    (transformation_engine_axi_interconnect_awlen),
    .S01_AXI_0_awlock                                   (transformation_engine_axi_interconnect_awlock),
    .S01_AXI_0_awprot                                   (transformation_engine_axi_interconnect_awprot),
    .S01_AXI_0_awqos                                    (transformation_engine_axi_interconnect_awqos),
    .S01_AXI_0_awready                                  (transformation_engine_axi_interconnect_awready),
    .S01_AXI_0_awregion                                 (transformation_engine_axi_interconnect_awregion),
    .S01_AXI_0_awsize                                   (transformation_engine_axi_interconnect_awsize),
    .S01_AXI_0_awvalid                                  (transformation_engine_axi_interconnect_awvalid),
    .S01_AXI_0_bid                                      (transformation_engine_axi_interconnect_bid),
    .S01_AXI_0_bready                                   (transformation_engine_axi_interconnect_bready),
    .S01_AXI_0_bresp                                    (transformation_engine_axi_interconnect_bresp),
    .S01_AXI_0_bvalid                                   (transformation_engine_axi_interconnect_bvalid),
    .S01_AXI_0_rdata                                    (transformation_engine_axi_interconnect_rdata),
    .S01_AXI_0_rid                                      (transformation_engine_axi_interconnect_rid),
    .S01_AXI_0_rlast                                    (transformation_engine_axi_interconnect_rlast),
    .S01_AXI_0_rready                                   (transformation_engine_axi_interconnect_rready),
    .S01_AXI_0_rresp                                    (transformation_engine_axi_interconnect_rresp),
    .S01_AXI_0_rvalid                                   (transformation_engine_axi_interconnect_rvalid),
    .S01_AXI_0_wdata                                    (transformation_engine_axi_interconnect_wdata),
    .S01_AXI_0_wlast                                    (transformation_engine_axi_interconnect_wlast),
    .S01_AXI_0_wready                                   (transformation_engine_axi_interconnect_wready),
    .S01_AXI_0_wstrb                                    (transformation_engine_axi_interconnect_wstrb),
    .S01_AXI_0_wvalid                                   (transformation_engine_axi_interconnect_wvalid),

    // DDR4
    .ddr4_sdram_c0_act_n,
    .ddr4_sdram_c0_adr,
    .ddr4_sdram_c0_ba,
    .ddr4_sdram_c0_bg,
    .ddr4_sdram_c0_ck_c,
    .ddr4_sdram_c0_ck_t,
    .ddr4_sdram_c0_cke,
    .ddr4_sdram_c0_cs_n,
    .ddr4_sdram_c0_dq,
    .ddr4_sdram_c0_dqs_c,
    .ddr4_sdram_c0_dqs_t,
    .ddr4_sdram_c0_odt,
    .ddr4_sdram_c0_par,
    .ddr4_sdram_c0_reset_n,

    .c0_init_calib_complete_0
);

// Aggregation Engine
// -------------------------------------------------------------------

fc_base_aggregation_engine fc_base_aggregation_engine_i (
    .core_clk,
    .resetn,
    // Regbank Slave AXI interface
    .s_axi_awaddr                                           (fc_base_aggregation_engine_s_axi_awaddr),
    .s_axi_awprot                                           (fc_base_aggregation_engine_s_axi_awprot),
    .s_axi_awvalid                                          (fc_base_aggregation_engine_s_axi_awvalid),
    .s_axi_awready                                          (fc_base_aggregation_engine_s_axi_awready),
    .s_axi_wdata                                            (fc_base_aggregation_engine_s_axi_wdata),
    .s_axi_wstrb                                            (fc_base_aggregation_engine_s_axi_wstrb),
    .s_axi_wvalid                                           (fc_base_aggregation_engine_s_axi_wvalid),
    .s_axi_wready                                           (fc_base_aggregation_engine_s_axi_wready),
    .s_axi_araddr                                           (fc_base_aggregation_engine_s_axi_araddr),
    .s_axi_arprot                                           (fc_base_aggregation_engine_s_axi_arprot),
    .s_axi_arvalid                                          (fc_base_aggregation_engine_s_axi_arvalid),
    .s_axi_arready                                          (fc_base_aggregation_engine_s_axi_arready),
    .s_axi_rdata                                            (fc_base_aggregation_engine_s_axi_rdata),
    .s_axi_rresp                                            (fc_base_aggregation_engine_s_axi_rresp),
    .s_axi_rvalid                                           (fc_base_aggregation_engine_s_axi_rvalid),
    .s_axi_rready                                           (fc_base_aggregation_engine_s_axi_rready),
    .s_axi_bresp                                            (fc_base_aggregation_engine_s_axi_bresp),
    .s_axi_bvalid                                           (fc_base_aggregation_engine_s_axi_bvalid),
    .s_axi_bready                                           (fc_base_aggregation_engine_s_axi_bready),
    // Master AXI interface (to DRAM controller)
    .m_axi_araddr                                           (aggregation_engine_axi_interconnect_araddr),
    .m_axi_arburst                                          (aggregation_engine_axi_interconnect_arburst),
    .m_axi_arcache                                          (aggregation_engine_axi_interconnect_arcache),
    .m_axi_arid                                             (aggregation_engine_axi_interconnect_arid),
    .m_axi_arlen                                            (aggregation_engine_axi_interconnect_arlen),
    .m_axi_arlock                                           (aggregation_engine_axi_interconnect_arlock),
    .m_axi_arprot                                           (aggregation_engine_axi_interconnect_arprot),
    .m_axi_arqos                                            (aggregation_engine_axi_interconnect_arqos),
    .m_axi_arready                                          (aggregation_engine_axi_interconnect_arready),
    .m_axi_arregion                                         (aggregation_engine_axi_interconnect_arregion),
    .m_axi_arsize                                           (aggregation_engine_axi_interconnect_arsize),
    .m_axi_arvalid                                          (aggregation_engine_axi_interconnect_arvalid),
    .m_axi_awaddr                                           (aggregation_engine_axi_interconnect_awaddr),
    .m_axi_awburst                                          (aggregation_engine_axi_interconnect_awburst),
    .m_axi_awcache                                          (aggregation_engine_axi_interconnect_awcache),
    .m_axi_awid                                             (aggregation_engine_axi_interconnect_awid),
    .m_axi_awlen                                            (aggregation_engine_axi_interconnect_awlen),
    .m_axi_awlock                                           (aggregation_engine_axi_interconnect_awlock),
    .m_axi_awprot                                           (aggregation_engine_axi_interconnect_awprot),
    .m_axi_awqos                                            (aggregation_engine_axi_interconnect_awqos),
    .m_axi_awready                                          (aggregation_engine_axi_interconnect_awready),
    .m_axi_awregion                                         (aggregation_engine_axi_interconnect_awregion),
    .m_axi_awsize                                           (aggregation_engine_axi_interconnect_awsize),
    .m_axi_awvalid                                          (aggregation_engine_axi_interconnect_awvalid),
    .m_axi_bid                                              (aggregation_engine_axi_interconnect_bid),
    .m_axi_bready                                           (aggregation_engine_axi_interconnect_bready),
    .m_axi_bresp                                            (aggregation_engine_axi_interconnect_bresp),
    .m_axi_bvalid                                           (aggregation_engine_axi_interconnect_bvalid),
    .m_axi_rdata                                            (aggregation_engine_axi_interconnect_rdata),
    .m_axi_rid                                              (aggregation_engine_axi_interconnect_rid),
    .m_axi_rlast                                            (aggregation_engine_axi_interconnect_rlast),
    .m_axi_rready                                           (aggregation_engine_axi_interconnect_rready),
    .m_axi_rresp                                            (aggregation_engine_axi_interconnect_rresp),
    .m_axi_rvalid                                           (aggregation_engine_axi_interconnect_rvalid),
    .m_axi_wdata                                            (aggregation_engine_axi_interconnect_wdata),
    .m_axi_wlast                                            (aggregation_engine_axi_interconnect_wlast),
    .m_axi_wready                                           (aggregation_engine_axi_interconnect_wready),
    .m_axi_wstrb                                            (aggregation_engine_axi_interconnect_wstrb),
    .m_axi_wvalid                                           (aggregation_engine_axi_interconnect_wvalid),

    // from dram for debug
    .c0_init_calib_complete_0
);

// Transformation Engine
// -------------------------------------------------------------------

fc_base_transformation_engine transformation_engine_i (
    .core_clk,
    .resetn,
    // Regbank Slave AXI interface
    .s_axi_awaddr                                           (fc_base_transformation_engine_s_axi_awaddr),
    .s_axi_awprot                                           (fc_base_transformation_engine_s_axi_awprot),
    .s_axi_awvalid                                          (fc_base_transformation_engine_s_axi_awvalid),
    .s_axi_awready                                          (fc_base_transformation_engine_s_axi_awready),
    .s_axi_wdata                                            (fc_base_transformation_engine_s_axi_wdata),
    .s_axi_wstrb                                            (fc_base_transformation_engine_s_axi_wstrb),
    .s_axi_wvalid                                           (fc_base_transformation_engine_s_axi_wvalid),
    .s_axi_wready                                           (fc_base_transformation_engine_s_axi_wready),
    .s_axi_araddr                                           (fc_base_transformation_engine_s_axi_araddr),
    .s_axi_arprot                                           (fc_base_transformation_engine_s_axi_arprot),
    .s_axi_arvalid                                          (fc_base_transformation_engine_s_axi_arvalid),
    .s_axi_arready                                          (fc_base_transformation_engine_s_axi_arready),
    .s_axi_rdata                                            (fc_base_transformation_engine_s_axi_rdata),
    .s_axi_rresp                                            (fc_base_transformation_engine_s_axi_rresp),
    .s_axi_rvalid                                           (fc_base_transformation_engine_s_axi_rvalid),
    .s_axi_rready                                           (fc_base_transformation_engine_s_axi_rready),
    .s_axi_bresp                                            (fc_base_transformation_engine_s_axi_bresp),
    .s_axi_bvalid                                           (fc_base_transformation_engine_s_axi_bvalid),
    .s_axi_bready                                           (fc_base_transformation_engine_s_axi_bready),
    // Master AXI interface (to DRAM controller)
    .m_axi_araddr                                           (transformation_engine_axi_interconnect_araddr),
    .m_axi_arburst                                          (transformation_engine_axi_interconnect_arburst),
    .m_axi_arcache                                          (transformation_engine_axi_interconnect_arcache),
    .m_axi_arid                                             (transformation_engine_axi_interconnect_arid),
    .m_axi_arlen                                            (transformation_engine_axi_interconnect_arlen),
    .m_axi_arlock                                           (transformation_engine_axi_interconnect_arlock),
    .m_axi_arprot                                           (transformation_engine_axi_interconnect_arprot),
    .m_axi_arqos                                            (transformation_engine_axi_interconnect_arqos),
    .m_axi_arready                                          (transformation_engine_axi_interconnect_arready),
    .m_axi_arregion                                         (transformation_engine_axi_interconnect_arregion),
    .m_axi_arsize                                           (transformation_engine_axi_interconnect_arsize),
    .m_axi_arvalid                                          (transformation_engine_axi_interconnect_arvalid),
    .m_axi_awaddr                                           (transformation_engine_axi_interconnect_awaddr),
    .m_axi_awburst                                          (transformation_engine_axi_interconnect_awburst),
    .m_axi_awcache                                          (transformation_engine_axi_interconnect_awcache),
    .m_axi_awid                                             (transformation_engine_axi_interconnect_awid),
    .m_axi_awlen                                            (transformation_engine_axi_interconnect_awlen),
    .m_axi_awlock                                           (transformation_engine_axi_interconnect_awlock),
    .m_axi_awprot                                           (transformation_engine_axi_interconnect_awprot),
    .m_axi_awqos                                            (transformation_engine_axi_interconnect_awqos),
    .m_axi_awready                                          (transformation_engine_axi_interconnect_awready),
    .m_axi_awregion                                         (transformation_engine_axi_interconnect_awregion),
    .m_axi_awsize                                           (transformation_engine_axi_interconnect_awsize),
    .m_axi_awvalid                                          (transformation_engine_axi_interconnect_awvalid),
    .m_axi_bid                                              (transformation_engine_axi_interconnect_bid),
    .m_axi_bready                                           (transformation_engine_axi_interconnect_bready),
    .m_axi_bresp                                            (transformation_engine_axi_interconnect_bresp),
    .m_axi_bvalid                                           (transformation_engine_axi_interconnect_bvalid),
    .m_axi_rdata                                            (transformation_engine_axi_interconnect_rdata),
    .m_axi_rid                                              (transformation_engine_axi_interconnect_rid),
    .m_axi_rlast                                            (transformation_engine_axi_interconnect_rlast),
    .m_axi_rready                                           (transformation_engine_axi_interconnect_rready),
    .m_axi_rresp                                            (transformation_engine_axi_interconnect_rresp),
    .m_axi_rvalid                                           (transformation_engine_axi_interconnect_rvalid),
    .m_axi_wdata                                            (transformation_engine_axi_interconnect_wdata),
    .m_axi_wlast                                            (transformation_engine_axi_interconnect_wlast),
    .m_axi_wready                                           (transformation_engine_axi_interconnect_wready),
    .m_axi_wstrb                                            (transformation_engine_axi_interconnect_wstrb),
    .m_axi_wvalid                                           (transformation_engine_axi_interconnect_wvalid)
);

// ===============================================================================================================
// Logic
// ===============================================================================================================

assign core_clk = default_300mhz_clk0_clk_p;
assign aggregation_engine_axi_interconnect_aclk     = core_clk;
assign transformation_engine_axi_interconnect_aclk  = core_clk;

assign aggregation_engine_axi_interconnect_aresetn      = resetn;
assign transformation_engine_axi_interconnect_aresetn   = resetn;

assign C0_DDR4_S_AXI_CTRL_0_araddr          = '0;
assign C0_DDR4_S_AXI_CTRL_0_arvalid         = '0;
assign C0_DDR4_S_AXI_CTRL_0_awaddr          = '0;
assign C0_DDR4_S_AXI_CTRL_0_awvalid         = '0;
assign C0_DDR4_S_AXI_CTRL_0_bready          = '0;
assign C0_DDR4_S_AXI_CTRL_0_rready          = '0;
assign C0_DDR4_S_AXI_CTRL_0_wdata           = '0;
assign C0_DDR4_S_AXI_CTRL_0_wvalid          = '0;

assign fc_base_aggregation_engine_s_axi_awaddr      = '0;
assign fc_base_aggregation_engine_s_axi_awprot      = '0;
assign fc_base_aggregation_engine_s_axi_awvalid     = '0;
assign fc_base_aggregation_engine_s_axi_wdata       = '0;
assign fc_base_aggregation_engine_s_axi_wstrb       = '0;
assign fc_base_aggregation_engine_s_axi_wvalid      = '0;
assign fc_base_aggregation_engine_s_axi_araddr      = '0;
assign fc_base_aggregation_engine_s_axi_arprot      = '0;
assign fc_base_aggregation_engine_s_axi_arvalid     = '0;
assign fc_base_aggregation_engine_s_axi_rready      = '0;
assign fc_base_aggregation_engine_s_axi_bready      = '0;

assign fc_base_transformation_engine_s_axi_awaddr   = '0;
assign fc_base_transformation_engine_s_axi_awprot   = '0;
assign fc_base_transformation_engine_s_axi_awvalid  = '0;
assign fc_base_transformation_engine_s_axi_wdata    = '0;
assign fc_base_transformation_engine_s_axi_wstrb    = '0;
assign fc_base_transformation_engine_s_axi_wvalid   = '0;
assign fc_base_transformation_engine_s_axi_araddr   = '0;
assign fc_base_transformation_engine_s_axi_arprot   = '0;
assign fc_base_transformation_engine_s_axi_arvalid  = '0;
assign fc_base_transformation_engine_s_axi_rready   = '0;
assign fc_base_transformation_engine_s_axi_bready   = '0;

endmodule