
module top_wrapper (

    input  logic                                sys_clk,
    input  logic                                sys_rst,

    input  logic                                regbank_clk,
    input  logic                                regbank_resetn,

    // DDR4 Channel 0
    input  logic                                c0_sys_clk_p,
    input  logic                                c0_sys_clk_n,
    output logic                                c0_ddr4_act_n,
    output logic [16:0]                         c0_ddr4_adr,
    output logic [1:0]                          c0_ddr4_ba,
    output logic [1:0]                          c0_ddr4_bg,
    output logic [0:0]                          c0_ddr4_cke,
    output logic [0:0]                          c0_ddr4_odt,
    output logic [0:0]                          c0_ddr4_cs_n,
    output logic [0:0]                          c0_ddr4_ck_t,
    output logic [0:0]                          c0_ddr4_ck_c,
    output logic                                c0_ddr4_reset_n,
    output logic                                c0_ddr4_parity,
    inout  logic [71:0]                         c0_ddr4_dq,
    inout  logic [17:0]                         c0_ddr4_dqs_t,
    inout  logic [17:0]                         c0_ddr4_dqs_c,
    output logic                                c0_init_calib_complete,
    output logic                                c0_data_compare_error,

    // DDR4 Channel 1
    input  logic                                c1_sys_clk_p,
    input  logic                                c1_sys_clk_n,
    output logic                                c1_ddr4_act_n,
    output logic [16:0]                         c1_ddr4_adr,
    output logic [1:0]                          c1_ddr4_ba,
    output logic [1:0]                          c1_ddr4_bg,
    output logic [0:0]                          c1_ddr4_cke,
    output logic [0:0]                          c1_ddr4_odt,
    output logic [0:0]                          c1_ddr4_cs_n,
    output logic [0:0]                          c1_ddr4_ck_t,
    output logic [0:0]                          c1_ddr4_ck_c,
    output logic                                c1_ddr4_reset_n,
    output logic                                c1_ddr4_parity,
    inout  logic [71:0]                         c1_ddr4_dq,
    inout  logic [17:0]                         c1_ddr4_dqs_t,
    inout  logic [17:0]                         c1_ddr4_dqs_c,
    output logic                                c1_init_calib_complete,
    output logic                                c1_data_compare_error

);

// ====================================================================================
// Declarations
// ====================================================================================

// AXI-L Register Programming Interface
logic [31 : 0]                 host_axil_awaddr;
logic [2 : 0]                  host_axil_awprot;
logic [0 : 0]                  host_axil_awvalid;
logic [0 : 0]                  host_axil_awready;
logic [31 : 0]                 host_axil_wdata;
logic [3 : 0]                  host_axil_wstrb;
logic [0 : 0]                  host_axil_wvalid;
logic [0 : 0]                  host_axil_bready;
logic [31 : 0]                 host_axil_araddr;
logic [2 : 0]                  host_axil_arprot;
logic [0 : 0]                  host_axil_arvalid;
logic [0 : 0]                  host_axil_rready;
logic [0 : 0]                  host_axil_wready;
logic [1 : 0]                  host_axil_bresp;
logic [0 : 0]                  host_axil_bvalid;
logic [0 : 0]                  host_axil_arready;
logic [31 : 0]                 host_axil_rdata;
logic [1 : 0]                  host_axil_rresp;
logic [0 : 0]                  host_axil_rvalid;

// AXI Master Interface
logic  [7:0]                   c0_ddr4_s_axi_awid;
logic  [33:0]                  c0_ddr4_s_axi_awaddr;
logic  [7:0]                   c0_ddr4_s_axi_awlen;
logic  [2:0]                   c0_ddr4_s_axi_awsize;
logic  [1:0]                   c0_ddr4_s_axi_awburst;
logic  [0:0]                   c0_ddr4_s_axi_awlock;
logic  [3:0]                   c0_ddr4_s_axi_awcache;
logic  [2:0]                   c0_ddr4_s_axi_awprot;
logic  [3:0]                   c0_ddr4_s_axi_awqos;
logic                          c0_ddr4_s_axi_awvalid;
logic                          c0_ddr4_s_axi_awready;
logic  [511:0]                 c0_ddr4_s_axi_wdata;
logic  [63:0]                  c0_ddr4_s_axi_wstrb;
logic                          c0_ddr4_s_axi_wlast;
logic                          c0_ddr4_s_axi_wvalid;
logic                          c0_ddr4_s_axi_wready;
logic [7:0]                    c0_ddr4_s_axi_bid;
logic [1:0]                    c0_ddr4_s_axi_bresp;
logic                          c0_ddr4_s_axi_bvalid;
logic                          c0_ddr4_s_axi_bready;
logic  [7:0]                   c0_ddr4_s_axi_arid;
logic  [33:0]                  c0_ddr4_s_axi_araddr;
logic  [7:0]                   c0_ddr4_s_axi_arlen;
logic  [2:0]                   c0_ddr4_s_axi_arsize;
logic  [1:0]                   c0_ddr4_s_axi_arburst;
logic  [0:0]                   c0_ddr4_s_axi_arlock;
logic  [3:0]                   c0_ddr4_s_axi_arcache;
logic  [2:0]                   c0_ddr4_s_axi_arprot;
logic  [3:0]                   c0_ddr4_s_axi_arqos;
logic                          c0_ddr4_s_axi_arvalid;
logic                          c0_ddr4_s_axi_arready;
logic [7:0]                    c0_ddr4_s_axi_rid;
logic [511:0]                  c0_ddr4_s_axi_rdata;
logic [1:0]                    c0_ddr4_s_axi_rresp;
logic                          c0_ddr4_s_axi_rlast;
logic                          c0_ddr4_s_axi_rvalid;
logic                          c0_ddr4_s_axi_rready;

// AXI Master Interface
logic  [7:0]                   c1_ddr4_s_axi_awid;
logic  [33:0]                  c1_ddr4_s_axi_awaddr;
logic  [7:0]                   c1_ddr4_s_axi_awlen;
logic  [2:0]                   c1_ddr4_s_axi_awsize;
logic  [1:0]                   c1_ddr4_s_axi_awburst;
logic  [0:0]                   c1_ddr4_s_axi_awlock;
logic  [3:0]                   c1_ddr4_s_axi_awcache;
logic  [2:0]                   c1_ddr4_s_axi_awprot;
logic  [3:0]                   c1_ddr4_s_axi_awqos;
logic                          c1_ddr4_s_axi_awvalid;
logic                          c1_ddr4_s_axi_awready;
logic  [511:0]                 c1_ddr4_s_axi_wdata;
logic  [63:0]                  c1_ddr4_s_axi_wstrb;
logic                          c1_ddr4_s_axi_wlast;
logic                          c1_ddr4_s_axi_wvalid;
logic                          c1_ddr4_s_axi_wready;
logic [7:0]                    c1_ddr4_s_axi_bid;
logic [1:0]                    c1_ddr4_s_axi_bresp;
logic                          c1_ddr4_s_axi_bvalid;
logic                          c1_ddr4_s_axi_bready;
logic  [7:0]                   c1_ddr4_s_axi_arid;
logic  [33:0]                  c1_ddr4_s_axi_araddr;
logic  [7:0]                   c1_ddr4_s_axi_arlen;
logic  [2:0]                   c1_ddr4_s_axi_arsize;
logic  [1:0]                   c1_ddr4_s_axi_arburst;
logic  [0:0]                   c1_ddr4_s_axi_arlock;
logic  [3:0]                   c1_ddr4_s_axi_arcache;
logic  [2:0]                   c1_ddr4_s_axi_arprot;
logic  [3:0]                   c1_ddr4_s_axi_arqos;
logic                          c1_ddr4_s_axi_arvalid;
logic                          c1_ddr4_s_axi_arready;
logic [7:0]                    c1_ddr4_s_axi_rid;
logic [511:0]                  c1_ddr4_s_axi_rdata;
logic [1:0]                    c1_ddr4_s_axi_rresp;
logic                          c1_ddr4_s_axi_rlast;
logic                          c1_ddr4_s_axi_rvalid;
logic                          c1_ddr4_s_axi_rready;

logic c0_ddr4_aresetn;
logic c0_ddr4_reset_n_int;
logic c0_ddr4_clk;
logic c0_ddr4_rst;
logic dbg_clk_0;
logic [511:0] dbg_bus_1;

logic c1_ddr4_aresetn;
logic c1_ddr4_reset_n_int;
logic c1_ddr4_clk;
logic c1_ddr4_rst;
logic dbg_clk_1;
logic [511:0] dbg_bus_1;

assign c0_ddr4_reset_n = c0_ddr4_reset_n_int;
assign c1_ddr4_reset_n = c1_ddr4_reset_n_int;

// ====================================================================================
// TOP RTL
// ====================================================================================

top top_i
(
    .sys_clk                              (sys_clk),
    .sys_rst                              (sys_rst),

    .regbank_clk                          (regbank_clk),
    .regbank_resetn                       (regbank_resetn),
    
    // AXI-L Register Programming Interface
    .host_axil_awaddr                     (host_axil_awaddr),
    .host_axil_awprot                     (host_axil_awprot),
    .host_axil_awvalid                    (host_axil_awvalid),
    .host_axil_awready                    (host_axil_awready),
    .host_axil_wdata                      (host_axil_wdata),
    .host_axil_wstrb                      (host_axil_wstrb),
    .host_axil_wvalid                     (host_axil_wvalid),
    .host_axil_bready                     (host_axil_bready),
    .host_axil_araddr                     (host_axil_araddr),
    .host_axil_arprot                     (host_axil_arprot),
    .host_axil_arvalid                    (host_axil_arvalid),
    .host_axil_rready                     (host_axil_rready),
    .host_axil_wready                     (host_axil_wready),
    .host_axil_bresp                      (host_axil_bresp),
    .host_axil_bvalid                     (host_axil_bvalid),
    .host_axil_arready                    (host_axil_arready),
    .host_axil_rdata                      (host_axil_rdata),
    .host_axil_rresp                      (host_axil_rresp),
    .host_axil_rvalid                     (host_axil_rvalid),

    // AXI Master -> DDR4 Interface
    .read_master_axi_awid                   (c0_ddr4_s_axi_awid),
    .read_master_axi_awaddr                 (c0_ddr4_s_axi_awaddr),
    .read_master_axi_awlen                  (c0_ddr4_s_axi_awlen),
    .read_master_axi_awsize                 (c0_ddr4_s_axi_awsize),
    .read_master_axi_awburst                (c0_ddr4_s_axi_awburst),
    .read_master_axi_awlock                 (c0_ddr4_s_axi_awlock),
    .read_master_axi_awcache                (c0_ddr4_s_axi_awcache),
    .read_master_axi_awprot                 (c0_ddr4_s_axi_awprot),
    .read_master_axi_awqos                  (c0_ddr4_s_axi_awqos),
    .read_master_axi_awvalid                (c0_ddr4_s_axi_awvalid),
    .read_master_axi_awready                (c0_ddr4_s_axi_awready),
    .read_master_axi_wdata                  (c0_ddr4_s_axi_wdata),
    .read_master_axi_wstrb                  (c0_ddr4_s_axi_wstrb),
    .read_master_axi_wlast                  (c0_ddr4_s_axi_wlast),
    .read_master_axi_wvalid                 (c0_ddr4_s_axi_wvalid),
    .read_master_axi_wready                 (c0_ddr4_s_axi_wready),
    .read_master_axi_bid                    (c0_ddr4_s_axi_bid),
    .read_master_axi_bresp                  (c0_ddr4_s_axi_bresp),
    .read_master_axi_bvalid                 (c0_ddr4_s_axi_bvalid),
    .read_master_axi_bready                 (c0_ddr4_s_axi_bready),
    .read_master_axi_arid                   (c0_ddr4_s_axi_arid),
    .read_master_axi_araddr                 (c0_ddr4_s_axi_araddr),
    .read_master_axi_arlen                  (c0_ddr4_s_axi_arlen),
    .read_master_axi_arsize                 (c0_ddr4_s_axi_arsize),
    .read_master_axi_arburst                (c0_ddr4_s_axi_arburst),
    .read_master_axi_arlock                 (c0_ddr4_s_axi_arlock),
    .read_master_axi_arcache                (c0_ddr4_s_axi_arcache),
    .read_master_axi_arprot                 (c0_ddr4_s_axi_arprot),
    .read_master_axi_arqos                  (c0_ddr4_s_axi_arqos),
    .read_master_axi_arvalid                (c0_ddr4_s_axi_arvalid),
    .read_master_axi_arready                (c0_ddr4_s_axi_arready),
    .read_master_axi_rid                    (c0_ddr4_s_axi_rid),
    .read_master_axi_rdata                  (c0_ddr4_s_axi_rdata),
    .read_master_axi_rresp                  (c0_ddr4_s_axi_rresp),
    .read_master_axi_rlast                  (c0_ddr4_s_axi_rlast),
    .read_master_axi_rvalid                 (c0_ddr4_s_axi_rvalid),
    .read_master_axi_rready                 (c0_ddr4_s_axi_rready),

    .nodeslot_fetch_axi_awid                (c1_ddr4_s_axi_awid),
    .nodeslot_fetch_axi_awaddr              (c1_ddr4_s_axi_awaddr),
    .nodeslot_fetch_axi_awlen               (c1_ddr4_s_axi_awlen),
    .nodeslot_fetch_axi_awsize              (c1_ddr4_s_axi_awsize),
    .nodeslot_fetch_axi_awburst             (c1_ddr4_s_axi_awburst),
    .nodeslot_fetch_axi_awlock              (c1_ddr4_s_axi_awlock),
    .nodeslot_fetch_axi_awcache             (c1_ddr4_s_axi_awcache),
    .nodeslot_fetch_axi_awprot              (c1_ddr4_s_axi_awprot),
    .nodeslot_fetch_axi_awqos               (c1_ddr4_s_axi_awqos),
    .nodeslot_fetch_axi_awvalid             (c1_ddr4_s_axi_awvalid),
    .nodeslot_fetch_axi_awready             (c1_ddr4_s_axi_awready),
    .nodeslot_fetch_axi_wdata               (c1_ddr4_s_axi_wdata),
    .nodeslot_fetch_axi_wstrb               (c1_ddr4_s_axi_wstrb),
    .nodeslot_fetch_axi_wlast               (c1_ddr4_s_axi_wlast),
    .nodeslot_fetch_axi_wvalid              (c1_ddr4_s_axi_wvalid),
    .nodeslot_fetch_axi_wready              (c1_ddr4_s_axi_wready),
    .nodeslot_fetch_axi_bid                 (c1_ddr4_s_axi_bid),
    .nodeslot_fetch_axi_bresp               (c1_ddr4_s_axi_bresp),
    .nodeslot_fetch_axi_bvalid              (c1_ddr4_s_axi_bvalid),
    .nodeslot_fetch_axi_bready              (c1_ddr4_s_axi_bready),
    .nodeslot_fetch_axi_arid                (c1_ddr4_s_axi_arid),
    .nodeslot_fetch_axi_araddr              (c1_ddr4_s_axi_araddr),
    .nodeslot_fetch_axi_arlen               (c1_ddr4_s_axi_arlen),
    .nodeslot_fetch_axi_arsize              (c1_ddr4_s_axi_arsize),
    .nodeslot_fetch_axi_arburst             (c1_ddr4_s_axi_arburst),
    .nodeslot_fetch_axi_arlock              (c1_ddr4_s_axi_arlock),
    .nodeslot_fetch_axi_arcache             (c1_ddr4_s_axi_arcache),
    .nodeslot_fetch_axi_arprot              (c1_ddr4_s_axi_arprot),
    .nodeslot_fetch_axi_arqos               (c1_ddr4_s_axi_arqos),
    .nodeslot_fetch_axi_arvalid             (c1_ddr4_s_axi_arvalid),
    .nodeslot_fetch_axi_arready             (c1_ddr4_s_axi_arready),
    .nodeslot_fetch_axi_rid                 (c1_ddr4_s_axi_rid),
    .nodeslot_fetch_axi_rdata               (c1_ddr4_s_axi_rdata),
    .nodeslot_fetch_axi_rresp               (c1_ddr4_s_axi_rresp),
    .nodeslot_fetch_axi_rlast               (c1_ddr4_s_axi_rlast),
    .nodeslot_fetch_axi_rvalid              (c1_ddr4_s_axi_rvalid),
    .nodeslot_fetch_axi_rready              (c1_ddr4_s_axi_rready)
);

// ====================================================================================
// DDR4 Controller
// ====================================================================================

ddr4_0 u_ddr4_0
(
    .sys_rst                          (sys_rst),

    .c0_sys_clk_p                     (c0_sys_clk_p),
    .c0_sys_clk_n                     (c0_sys_clk_n),
    .c0_init_calib_complete           (c0_init_calib_complete),
    .c0_ddr4_act_n                    (c0_ddr4_act_n),
    .c0_ddr4_adr                      (c0_ddr4_adr),
    .c0_ddr4_ba                       (c0_ddr4_ba),
    .c0_ddr4_bg                       (c0_ddr4_bg),
    .c0_ddr4_cke                      (c0_ddr4_cke),
    .c0_ddr4_odt                      (c0_ddr4_odt),
    .c0_ddr4_cs_n                     (c0_ddr4_cs_n),
    .c0_ddr4_ck_t                     (c0_ddr4_ck_t),
    .c0_ddr4_ck_c                     (c0_ddr4_ck_c),
    .c0_ddr4_reset_n                  (c0_ddr4_reset_n_int),

    .c0_ddr4_parity                   (c0_ddr4_parity),
    .c0_ddr4_dq                       (c0_ddr4_dq),
    .c0_ddr4_dqs_c                    (c0_ddr4_dqs_c),
    .c0_ddr4_dqs_t                    (c0_ddr4_dqs_t),

    .c0_ddr4_ui_clk                   (c0_ddr4_clk),
    .c0_ddr4_ui_clk_sync_rst          (c0_ddr4_rst),
    .addn_ui_clkout1                  (),
    .dbg_clk                          (dbg_clk_0),

    // AXI CTRL port
    .c0_ddr4_s_axi_ctrl_awvalid       (1'b0),
    .c0_ddr4_s_axi_ctrl_awready       (),
    .c0_ddr4_s_axi_ctrl_awaddr        (32'b0),
    // Slave Interface Write Data Ports
    .c0_ddr4_s_axi_ctrl_wvalid        (1'b0),
    .c0_ddr4_s_axi_ctrl_wready        (),
    .c0_ddr4_s_axi_ctrl_wdata         (32'b0),
    // Slave Interface Write Response Ports
    .c0_ddr4_s_axi_ctrl_bvalid        (),
    .c0_ddr4_s_axi_ctrl_bready        (1'b1),
    .c0_ddr4_s_axi_ctrl_bresp         (),
    // Slave Interface Read Address Ports
    .c0_ddr4_s_axi_ctrl_arvalid       (1'b0),
    .c0_ddr4_s_axi_ctrl_arready       (),
    .c0_ddr4_s_axi_ctrl_araddr        (32'b0),
    // Slave Interface Read Data Ports
    .c0_ddr4_s_axi_ctrl_rvalid        (),
    .c0_ddr4_s_axi_ctrl_rready        (1'b1),
    .c0_ddr4_s_axi_ctrl_rdata         (),
    .c0_ddr4_s_axi_ctrl_rresp         (),


    // Interrupt output
    .c0_ddr4_interrupt                (),

    // Slave Interface AXI ports
    .c0_ddr4_aresetn                     (c0_ddr4_aresetn),
    .c0_ddr4_s_axi_awid                  (c0_ddr4_s_axi_awid),
    .c0_ddr4_s_axi_awaddr                (c0_ddr4_s_axi_awaddr),
    .c0_ddr4_s_axi_awlen                 (c0_ddr4_s_axi_awlen),
    .c0_ddr4_s_axi_awsize                (c0_ddr4_s_axi_awsize),
    .c0_ddr4_s_axi_awburst               (c0_ddr4_s_axi_awburst),
    .c0_ddr4_s_axi_awlock                (c0_ddr4_s_axi_awlock),
    .c0_ddr4_s_axi_awcache               (c0_ddr4_s_axi_awcache),
    .c0_ddr4_s_axi_awprot                (c0_ddr4_s_axi_awprot),
    .c0_ddr4_s_axi_awqos                 (c0_ddr4_s_axi_awqos),
    .c0_ddr4_s_axi_awvalid               (c0_ddr4_s_axi_awvalid),
    .c0_ddr4_s_axi_awready               (c0_ddr4_s_axi_awready),
    .c0_ddr4_s_axi_wdata                 (c0_ddr4_s_axi_wdata),
    .c0_ddr4_s_axi_wstrb                 (c0_ddr4_s_axi_wstrb),
    .c0_ddr4_s_axi_wlast                 (c0_ddr4_s_axi_wlast),
    .c0_ddr4_s_axi_wvalid                (c0_ddr4_s_axi_wvalid),
    .c0_ddr4_s_axi_wready                (c0_ddr4_s_axi_wready),
    .c0_ddr4_s_axi_bid                   (c0_ddr4_s_axi_bid),
    .c0_ddr4_s_axi_bresp                 (c0_ddr4_s_axi_bresp),
    .c0_ddr4_s_axi_bvalid                (c0_ddr4_s_axi_bvalid),
    .c0_ddr4_s_axi_bready                (c0_ddr4_s_axi_bready),
    .c0_ddr4_s_axi_arid                  (c0_ddr4_s_axi_arid),
    .c0_ddr4_s_axi_araddr                (c0_ddr4_s_axi_araddr),
    .c0_ddr4_s_axi_arlen                 (c0_ddr4_s_axi_arlen),
    .c0_ddr4_s_axi_arsize                (c0_ddr4_s_axi_arsize),
    .c0_ddr4_s_axi_arburst               (c0_ddr4_s_axi_arburst),
    .c0_ddr4_s_axi_arlock                (c0_ddr4_s_axi_arlock),
    .c0_ddr4_s_axi_arcache               (c0_ddr4_s_axi_arcache),
    .c0_ddr4_s_axi_arprot                (c0_ddr4_s_axi_arprot),
    .c0_ddr4_s_axi_arqos                 (c0_ddr4_s_axi_arqos),
    .c0_ddr4_s_axi_arvalid               (c0_ddr4_s_axi_arvalid),
    .c0_ddr4_s_axi_arready               (c0_ddr4_s_axi_arready),
    .c0_ddr4_s_axi_rid                   (c0_ddr4_s_axi_rid),
    .c0_ddr4_s_axi_rdata                 (c0_ddr4_s_axi_rdata),
    .c0_ddr4_s_axi_rresp                 (c0_ddr4_s_axi_rresp),
    .c0_ddr4_s_axi_rlast                 (c0_ddr4_s_axi_rlast),
    .c0_ddr4_s_axi_rvalid                (c0_ddr4_s_axi_rvalid),
    .c0_ddr4_s_axi_rready                (c0_ddr4_s_axi_rready),

    // Debug Port
    .dbg_bus         (dbg_bus_0)                                             

);

ddr4_1 u_ddr4_1
(
    .sys_rst                          (sys_rst),

    .c0_sys_clk_p                     (c1_sys_clk_p),
    .c0_sys_clk_n                     (c1_sys_clk_n),
    .c0_init_calib_complete           (c1_init_calib_complete),
    .c0_ddr4_act_n                    (c1_ddr4_act_n),
    .c0_ddr4_adr                      (c1_ddr4_adr),
    .c0_ddr4_ba                       (c1_ddr4_ba),
    .c0_ddr4_bg                       (c1_ddr4_bg),
    .c0_ddr4_cke                      (c1_ddr4_cke),
    .c0_ddr4_odt                      (c1_ddr4_odt),
    .c0_ddr4_cs_n                     (c1_ddr4_cs_n),
    .c0_ddr4_ck_t                     (c1_ddr4_ck_t),
    .c0_ddr4_ck_c                     (c1_ddr4_ck_c),
    .c0_ddr4_reset_n                  (c1_ddr4_reset_n_int),

    .c0_ddr4_parity                   (c1_ddr4_parity),
    .c0_ddr4_dq                       (c1_ddr4_dq),
    .c0_ddr4_dqs_c                    (c1_ddr4_dqs_c),
    .c0_ddr4_dqs_t                    (c1_ddr4_dqs_t),

    .c0_ddr4_ui_clk                   (c1_ddr4_clk),
    .c0_ddr4_ui_clk_sync_rst          (c1_ddr4_rst),
    .addn_ui_clkout1                  (),
    .dbg_clk                          (dbg_clk_1),

    // AXI CTRL port
    .c0_ddr4_s_axi_ctrl_awvalid       (1'b0),
    .c0_ddr4_s_axi_ctrl_awready       (),
    .c0_ddr4_s_axi_ctrl_awaddr        (32'b0),
    // Slave Interface Write Data Ports
    .c0_ddr4_s_axi_ctrl_wvalid        (1'b0),
    .c0_ddr4_s_axi_ctrl_wready        (),
    .c0_ddr4_s_axi_ctrl_wdata         (32'b0),
    // Slave Interface Write Response Ports
    .c0_ddr4_s_axi_ctrl_bvalid        (),
    .c0_ddr4_s_axi_ctrl_bready        (1'b1),
    .c0_ddr4_s_axi_ctrl_bresp         (),
    // Slave Interface Read Address Ports
    .c0_ddr4_s_axi_ctrl_arvalid       (1'b0),
    .c0_ddr4_s_axi_ctrl_arready       (),
    .c0_ddr4_s_axi_ctrl_araddr        (32'b0),
    // Slave Interface Read Data Ports
    .c0_ddr4_s_axi_ctrl_rvalid        (),
    .c0_ddr4_s_axi_ctrl_rready        (1'b1),
    .c0_ddr4_s_axi_ctrl_rdata         (),
    .c0_ddr4_s_axi_ctrl_rresp         (),


    // Interrupt output
    .c0_ddr4_interrupt                (),

    // Slave Interface AXI ports
    .c0_ddr4_aresetn                     (c1_ddr4_aresetn),
    .c0_ddr4_s_axi_awid                  (c1_ddr4_s_axi_awid),
    .c0_ddr4_s_axi_awaddr                (c1_ddr4_s_axi_awaddr),
    .c0_ddr4_s_axi_awlen                 (c1_ddr4_s_axi_awlen),
    .c0_ddr4_s_axi_awsize                (c1_ddr4_s_axi_awsize),
    .c0_ddr4_s_axi_awburst               (c1_ddr4_s_axi_awburst),
    .c0_ddr4_s_axi_awlock                (c1_ddr4_s_axi_awlock),
    .c0_ddr4_s_axi_awcache               (c1_ddr4_s_axi_awcache),
    .c0_ddr4_s_axi_awprot                (c1_ddr4_s_axi_awprot),
    .c0_ddr4_s_axi_awqos                 (c1_ddr4_s_axi_awqos),
    .c0_ddr4_s_axi_awvalid               (c1_ddr4_s_axi_awvalid),
    .c0_ddr4_s_axi_awready               (c1_ddr4_s_axi_awready),
    .c0_ddr4_s_axi_wdata                 (c1_ddr4_s_axi_wdata),
    .c0_ddr4_s_axi_wstrb                 (c1_ddr4_s_axi_wstrb),
    .c0_ddr4_s_axi_wlast                 (c1_ddr4_s_axi_wlast),
    .c0_ddr4_s_axi_wvalid                (c1_ddr4_s_axi_wvalid),
    .c0_ddr4_s_axi_wready                (c1_ddr4_s_axi_wready),
    .c0_ddr4_s_axi_bid                   (c1_ddr4_s_axi_bid),
    .c0_ddr4_s_axi_bresp                 (c1_ddr4_s_axi_bresp),
    .c0_ddr4_s_axi_bvalid                (c1_ddr4_s_axi_bvalid),
    .c0_ddr4_s_axi_bready                (c1_ddr4_s_axi_bready),
    .c0_ddr4_s_axi_arid                  (c1_ddr4_s_axi_arid),
    .c0_ddr4_s_axi_araddr                (c1_ddr4_s_axi_araddr),
    .c0_ddr4_s_axi_arlen                 (c1_ddr4_s_axi_arlen),
    .c0_ddr4_s_axi_arsize                (c1_ddr4_s_axi_arsize),
    .c0_ddr4_s_axi_arburst               (c1_ddr4_s_axi_arburst),
    .c0_ddr4_s_axi_arlock                (c1_ddr4_s_axi_arlock),
    .c0_ddr4_s_axi_arcache               (c1_ddr4_s_axi_arcache),
    .c0_ddr4_s_axi_arprot                (c1_ddr4_s_axi_arprot),
    .c0_ddr4_s_axi_arqos                 (c1_ddr4_s_axi_arqos),
    .c0_ddr4_s_axi_arvalid               (c1_ddr4_s_axi_arvalid),
    .c0_ddr4_s_axi_arready               (c1_ddr4_s_axi_arready),
    .c0_ddr4_s_axi_rid                   (c1_ddr4_s_axi_rid),
    .c0_ddr4_s_axi_rdata                 (c1_ddr4_s_axi_rdata),
    .c0_ddr4_s_axi_rresp                 (c1_ddr4_s_axi_rresp),
    .c0_ddr4_s_axi_rlast                 (c1_ddr4_s_axi_rlast),
    .c0_ddr4_s_axi_rvalid                (c1_ddr4_s_axi_rvalid),
    .c0_ddr4_s_axi_rready                (c1_ddr4_s_axi_rready),

    // Debug Port
    .dbg_bus         (dbg_bus_1)                                             

);

always @(posedge c0_ddr4_clk) begin
  c0_ddr4_aresetn <= ~c0_ddr4_rst;
end

always @(posedge c1_ddr4_clk) begin
  c1_ddr4_aresetn <= ~c1_ddr4_rst;
end

endmodule