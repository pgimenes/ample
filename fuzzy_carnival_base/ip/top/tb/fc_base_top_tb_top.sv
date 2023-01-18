import arch_package::*;

module fc_base_top_tb_top;

// Parameters for Memory Model
// --------------------------------------------------------
localparam DQ_WIDTH                         = 72;
localparam DQS_WIDTH                        = 18;
localparam DM_WIDTH_RDIMM                   = 18;                           // ?
localparam CKE_WIDTH_RDIMM                  = 1;
localparam ODT_WIDTH_RDIMM                  = 1;
localparam ADDR_WIDTH                       = 17;
localparam BANK_WIDTH_RDIMM                 = 2;
localparam BANK_GROUP_WIDTH_RDIMM           = 2;
localparam CS_WIDTH_RDIMM                   = 1;
localparam RANK_WIDTH_RDIMM                 = 1;                            // ?
localparam DRAM_WIDTH                       = 4;                            // ?
localparam NUM_PHYSICAL_PARTS               = (DQ_WIDTH/DRAM_WIDTH);        // ?
localparam tCK                              = 833 ;                         // ??? // DDR4 interface clock period in ps
localparam MEM_PART_WIDTH                   = "x4";
parameter  CA_MIRROR                        = "OFF";                        // ?
localparam DM_DBI                           = "NONE";                       // ?
localparam REG_CTRL                         = "ON";
localparam RDIMM_SLOTS                      = 1;
parameter UTYPE_density CONFIGURED_DENSITY  = _8G;

parameter CLK_PERIOD                        = tCK*1000;

// ===============================================================================================================
// Declarations
// ===============================================================================================================

logic                      clk;
logic                      resetn;

logic                      default_300mhz_clk0_clk_n;
logic                      default_300mhz_clk0_clk_p;

logic                      ddr4_sdram_c0_act_n;
logic [16:0]               ddr4_sdram_c0_adr;
logic [1:0]                ddr4_sdram_c0_ba;
logic [1:0]                ddr4_sdram_c0_bg;
logic                      ddr4_sdram_c0_ck_c;
logic                      ddr4_sdram_c0_ck_t;
logic                      ddr4_sdram_c0_cke;
logic                      ddr4_sdram_c0_cs_n;
wire [71:0]                ddr4_sdram_c0_dq;     // wire for inout
wire [17:0]                ddr4_sdram_c0_dqs_c;      // wire for inout
wire [17:0]                ddr4_sdram_c0_dqs_t;      // wire for inout
logic                      ddr4_sdram_c0_odt;
logic                      ddr4_sdram_c0_par;
logic                      ddr4_sdram_c0_reset_n;

// ===============================================================================================================
// Instances
// ===============================================================================================================

fc_base_top fc_base_top_i (
    .default_300mhz_clk0_clk_n,
    .default_300mhz_clk0_clk_p,
    .resetn,
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
    .ddr4_sdram_c0_reset_n
);

// Memory Model
// --------------------------------------------------------

generate
    for(genvar rdimm_x=0; rdimm_x<RDIMM_SLOTS; rdimm_x=rdimm_x+1)
    begin: instance_of_rdimm_slots
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
        ) u_ddr4_rdimm_wrapper (
            .ddr4_act_n         (ddr4_sdram_c0_act_n        ), // input
            .ddr4_addr          (ddr4_sdram_c0_adr          ), // input
            .ddr4_ba            (ddr4_sdram_c0_ba           ), // input
            .ddr4_bg            (ddr4_sdram_c0_bg           ), // input
            .ddr4_ck_c          (ddr4_sdram_c0_ck_c         ), // input
            .ddr4_ck_t          (ddr4_sdram_c0_ck_t         ), // input
            .ddr4_cke           (ddr4_sdram_c0_cke          ), // input
            .ddr4_cs_n          (ddr4_sdram_c0_cs_n         ), // input
            .ddr4_dq            (ddr4_sdram_c0_dq           ), // inout
            .ddr4_dqs_c         (ddr4_sdram_c0_dqs_c        ), // inout
            .ddr4_dqs_t         (ddr4_sdram_c0_dqs_t        ), // inout
            .ddr4_odt           (ddr4_sdram_c0_odt          ), // input
            .ddr4_par           (ddr4_sdram_c0_par          ), // input
            .ddr4_reset_n       (ddr4_sdram_c0_reset_n      ), // input
            
            .ddr4_dm_dbi_n       (),
            .ddr4_alert_n        (), // inout

            .initDone           (1'b0                       ), // inout - not used

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

// ===============================================================================================================
// CLK, RESET
// ===============================================================================================================

initial begin
    clk = '1;
    forever #(CLK_PERIOD) clk = !clk;
end

assign default_300mhz_clk0_clk_p = clk;
assign default_300mhz_clk0_clk_n = !clk;

initial begin
    resetn = '0;
    #(10*CLK_PERIOD) resetn = '1;
end

// initial begin
//     // simulate for 1 ms
//     #1000000
//     $finish;
// end

endmodule