//Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2019.2.1 (lin64) Build 2729669 Thu Dec  5 04:48:12 MST 2019
//Date        : Sun Jan 22 15:42:48 2023
//Host        : ee-mill3.ee.ic.ac.uk running 64-bit CentOS Linux release 7.9.2009 (Core)
//Command     : generate_target ex_sim.bd
//Design      : ex_sim
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CORE_GENERATION_INFO = "ex_sim,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=ex_sim,x_ipVersion=1.00.a,x_ipLanguage=VERILOG,numBlks=3,numReposBlks=3,numNonXlnxBlks=0,numHierBlks=0,maxHierDepth=0,numSysgenBlks=0,numHlsBlks=0,numHdlrefBlks=0,numPkgbdBlks=0,bdsource=USER,synth_mode=OOC_per_IP}" *) (* HW_HANDOFF = "ex_sim.hwdef" *) 
module ex_sim
   (aclk,
    aresetn);
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK.ACLK CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK.ACLK, ASSOCIATED_RESET aresetn, CLK_DOMAIN design_sim_clk_wiz_0_0_clk_out1, FREQ_HZ 300000000, INSERT_VIP 0, PHASE 0.0" *) input aclk;
  (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 RST.ARESETN RST" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME RST.ARESETN, INSERT_VIP 0, POLARITY ACTIVE_LOW" *) input aresetn;

  wire aclk_1;
  wire aresetn_1;
  wire [31:0]axi_vip_mst_M_AXI_ARADDR;
  wire [2:0]axi_vip_mst_M_AXI_ARPROT;
  wire axi_vip_mst_M_AXI_ARREADY;
  wire axi_vip_mst_M_AXI_ARVALID;
  wire [31:0]axi_vip_mst_M_AXI_AWADDR;
  wire [2:0]axi_vip_mst_M_AXI_AWPROT;
  wire axi_vip_mst_M_AXI_AWREADY;
  wire axi_vip_mst_M_AXI_AWVALID;
  wire axi_vip_mst_M_AXI_BREADY;
  wire [1:0]axi_vip_mst_M_AXI_BRESP;
  wire axi_vip_mst_M_AXI_BVALID;
  wire [31:0]axi_vip_mst_M_AXI_RDATA;
  wire axi_vip_mst_M_AXI_RREADY;
  wire [1:0]axi_vip_mst_M_AXI_RRESP;
  wire axi_vip_mst_M_AXI_RVALID;
  wire [31:0]axi_vip_mst_M_AXI_WDATA;
  wire axi_vip_mst_M_AXI_WREADY;
  wire [3:0]axi_vip_mst_M_AXI_WSTRB;
  wire axi_vip_mst_M_AXI_WVALID;
  wire [31:0]axi_vip_passthrough_M_AXI_ARADDR;
  wire [2:0]axi_vip_passthrough_M_AXI_ARPROT;
  wire axi_vip_passthrough_M_AXI_ARREADY;
  wire axi_vip_passthrough_M_AXI_ARVALID;
  wire [31:0]axi_vip_passthrough_M_AXI_AWADDR;
  wire [2:0]axi_vip_passthrough_M_AXI_AWPROT;
  wire axi_vip_passthrough_M_AXI_AWREADY;
  wire axi_vip_passthrough_M_AXI_AWVALID;
  wire axi_vip_passthrough_M_AXI_BREADY;
  wire [1:0]axi_vip_passthrough_M_AXI_BRESP;
  wire axi_vip_passthrough_M_AXI_BVALID;
  wire [31:0]axi_vip_passthrough_M_AXI_RDATA;
  wire axi_vip_passthrough_M_AXI_RREADY;
  wire [1:0]axi_vip_passthrough_M_AXI_RRESP;
  wire axi_vip_passthrough_M_AXI_RVALID;
  wire [31:0]axi_vip_passthrough_M_AXI_WDATA;
  wire axi_vip_passthrough_M_AXI_WREADY;
  wire [3:0]axi_vip_passthrough_M_AXI_WSTRB;
  wire axi_vip_passthrough_M_AXI_WVALID;

  assign aclk_1 = aclk;
  assign aresetn_1 = aresetn;
  ex_sim_axi_vip_mst_0 axi_vip_mst
       (.aclk(aclk_1),
        .aresetn(aresetn_1),
        .m_axi_araddr(axi_vip_mst_M_AXI_ARADDR),
        .m_axi_arprot(axi_vip_mst_M_AXI_ARPROT),
        .m_axi_arready(axi_vip_mst_M_AXI_ARREADY),
        .m_axi_arvalid(axi_vip_mst_M_AXI_ARVALID),
        .m_axi_awaddr(axi_vip_mst_M_AXI_AWADDR),
        .m_axi_awprot(axi_vip_mst_M_AXI_AWPROT),
        .m_axi_awready(axi_vip_mst_M_AXI_AWREADY),
        .m_axi_awvalid(axi_vip_mst_M_AXI_AWVALID),
        .m_axi_bready(axi_vip_mst_M_AXI_BREADY),
        .m_axi_bresp(axi_vip_mst_M_AXI_BRESP),
        .m_axi_bvalid(axi_vip_mst_M_AXI_BVALID),
        .m_axi_rdata(axi_vip_mst_M_AXI_RDATA),
        .m_axi_rready(axi_vip_mst_M_AXI_RREADY),
        .m_axi_rresp(axi_vip_mst_M_AXI_RRESP),
        .m_axi_rvalid(axi_vip_mst_M_AXI_RVALID),
        .m_axi_wdata(axi_vip_mst_M_AXI_WDATA),
        .m_axi_wready(axi_vip_mst_M_AXI_WREADY),
        .m_axi_wstrb(axi_vip_mst_M_AXI_WSTRB),
        .m_axi_wvalid(axi_vip_mst_M_AXI_WVALID));
  ex_sim_axi_vip_passthrough_0 axi_vip_passthrough
       (.aclk(aclk_1),
        .aresetn(aresetn_1),
        .m_axi_araddr(axi_vip_passthrough_M_AXI_ARADDR),
        .m_axi_arprot(axi_vip_passthrough_M_AXI_ARPROT),
        .m_axi_arready(axi_vip_passthrough_M_AXI_ARREADY),
        .m_axi_arvalid(axi_vip_passthrough_M_AXI_ARVALID),
        .m_axi_awaddr(axi_vip_passthrough_M_AXI_AWADDR),
        .m_axi_awprot(axi_vip_passthrough_M_AXI_AWPROT),
        .m_axi_awready(axi_vip_passthrough_M_AXI_AWREADY),
        .m_axi_awvalid(axi_vip_passthrough_M_AXI_AWVALID),
        .m_axi_bready(axi_vip_passthrough_M_AXI_BREADY),
        .m_axi_bresp(axi_vip_passthrough_M_AXI_BRESP),
        .m_axi_bvalid(axi_vip_passthrough_M_AXI_BVALID),
        .m_axi_rdata(axi_vip_passthrough_M_AXI_RDATA),
        .m_axi_rready(axi_vip_passthrough_M_AXI_RREADY),
        .m_axi_rresp(axi_vip_passthrough_M_AXI_RRESP),
        .m_axi_rvalid(axi_vip_passthrough_M_AXI_RVALID),
        .m_axi_wdata(axi_vip_passthrough_M_AXI_WDATA),
        .m_axi_wready(axi_vip_passthrough_M_AXI_WREADY),
        .m_axi_wstrb(axi_vip_passthrough_M_AXI_WSTRB),
        .m_axi_wvalid(axi_vip_passthrough_M_AXI_WVALID),
        .s_axi_araddr(axi_vip_mst_M_AXI_ARADDR),
        .s_axi_arprot(axi_vip_mst_M_AXI_ARPROT),
        .s_axi_arready(axi_vip_mst_M_AXI_ARREADY),
        .s_axi_arvalid(axi_vip_mst_M_AXI_ARVALID),
        .s_axi_awaddr(axi_vip_mst_M_AXI_AWADDR),
        .s_axi_awprot(axi_vip_mst_M_AXI_AWPROT),
        .s_axi_awready(axi_vip_mst_M_AXI_AWREADY),
        .s_axi_awvalid(axi_vip_mst_M_AXI_AWVALID),
        .s_axi_bready(axi_vip_mst_M_AXI_BREADY),
        .s_axi_bresp(axi_vip_mst_M_AXI_BRESP),
        .s_axi_bvalid(axi_vip_mst_M_AXI_BVALID),
        .s_axi_rdata(axi_vip_mst_M_AXI_RDATA),
        .s_axi_rready(axi_vip_mst_M_AXI_RREADY),
        .s_axi_rresp(axi_vip_mst_M_AXI_RRESP),
        .s_axi_rvalid(axi_vip_mst_M_AXI_RVALID),
        .s_axi_wdata(axi_vip_mst_M_AXI_WDATA),
        .s_axi_wready(axi_vip_mst_M_AXI_WREADY),
        .s_axi_wstrb(axi_vip_mst_M_AXI_WSTRB),
        .s_axi_wvalid(axi_vip_mst_M_AXI_WVALID));
  ex_sim_axi_vip_slv_0 axi_vip_slv
       (.aclk(aclk_1),
        .aresetn(aresetn_1),
        .s_axi_araddr(axi_vip_passthrough_M_AXI_ARADDR),
        .s_axi_arprot(axi_vip_passthrough_M_AXI_ARPROT),
        .s_axi_arready(axi_vip_passthrough_M_AXI_ARREADY),
        .s_axi_arvalid(axi_vip_passthrough_M_AXI_ARVALID),
        .s_axi_awaddr(axi_vip_passthrough_M_AXI_AWADDR),
        .s_axi_awprot(axi_vip_passthrough_M_AXI_AWPROT),
        .s_axi_awready(axi_vip_passthrough_M_AXI_AWREADY),
        .s_axi_awvalid(axi_vip_passthrough_M_AXI_AWVALID),
        .s_axi_bready(axi_vip_passthrough_M_AXI_BREADY),
        .s_axi_bresp(axi_vip_passthrough_M_AXI_BRESP),
        .s_axi_bvalid(axi_vip_passthrough_M_AXI_BVALID),
        .s_axi_rdata(axi_vip_passthrough_M_AXI_RDATA),
        .s_axi_rready(axi_vip_passthrough_M_AXI_RREADY),
        .s_axi_rresp(axi_vip_passthrough_M_AXI_RRESP),
        .s_axi_rvalid(axi_vip_passthrough_M_AXI_RVALID),
        .s_axi_wdata(axi_vip_passthrough_M_AXI_WDATA),
        .s_axi_wready(axi_vip_passthrough_M_AXI_WREADY),
        .s_axi_wstrb(axi_vip_passthrough_M_AXI_WSTRB),
        .s_axi_wvalid(axi_vip_passthrough_M_AXI_WVALID));
endmodule
