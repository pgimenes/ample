
// import aggregation_engine_regbank_regs_pkg::*;

module fc_base_aggregation_engine #(
    parameter AXI_ADDR_WIDTH = 32
) (
    input logic core_clk,
    input logic resetn,
    
    // Regbank Slave AXI interface
    input  logic [AXI_ADDR_WIDTH-1:0] s_axi_awaddr,
    input  logic [2:0]                s_axi_awprot,
    input  logic                      s_axi_awvalid,
    output logic                      s_axi_awready,
    input  logic [31:0]               s_axi_wdata,
    input  logic [3:0]                s_axi_wstrb,
    input  logic                      s_axi_wvalid,
    output logic                      s_axi_wready,
    input  logic [AXI_ADDR_WIDTH-1:0] s_axi_araddr,
    input  logic [2:0]                s_axi_arprot,
    input  logic                      s_axi_arvalid,
    output logic                      s_axi_arready,
    output logic [31:0]               s_axi_rdata,
    output logic [1:0]                s_axi_rresp,
    output logic                      s_axi_rvalid,
    input  logic                      s_axi_rready,
    output logic [1:0]                s_axi_bresp,
    output logic                      s_axi_bvalid,
    input  logic                      s_axi_bready,

    // Master AXI interface (to DRAM controller)
    output   logic [31:0]                                       m_axi_araddr,
    output   logic [1:0]                                        m_axi_arburst,
    output   logic [3:0]                                        m_axi_arcache,
    output   logic [0:0]                                        m_axi_arid,
    output   logic [7:0]                                        m_axi_arlen,
    output   logic [0:0]                                        m_axi_arlock,
    output   logic [2:0]                                        m_axi_arprot,
    output   logic [3:0]                                        m_axi_arqos,
    input   logic                                               m_axi_arready,
    output  logic [3:0]                                         m_axi_arregion,
    output  logic [2:0]                                         m_axi_arsize,
    output  logic                                               m_axi_arvalid,
    output  logic [31:0]                                        m_axi_awaddr,
    output  logic [1:0]                                         m_axi_awburst,
    output  logic [3:0]                                         m_axi_awcache,
    output  logic [0:0]                                         m_axi_awid,
    output  logic [7:0]                                         m_axi_awlen,
    output  logic [0:0]                                         m_axi_awlock,
    output  logic [2:0]                                         m_axi_awprot,
    output  logic [3:0]                                         m_axi_awqos,
    input   logic                                               m_axi_awready,
    output  logic [3:0]                                         m_axi_awregion,
    output  logic [2:0]                                         m_axi_awsize,
    output  logic                                               m_axi_awvalid,
    input   logic [0:0]                                         m_axi_bid,
    output  logic                                               m_axi_bready,
    input   logic [1:0]                                         m_axi_bresp,
    input   logic                                               m_axi_bvalid,
    input   logic [31:0]                                        m_axi_rdata,
    input   logic [0:0]                                         m_axi_rid,
    input   logic                                               m_axi_rlast,
    output  logic                                               m_axi_rready,
    input   logic [1:0]                                         m_axi_rresp,
    input   logic                                               m_axi_rvalid,
    output  logic [31:0]                                        m_axi_wdata,
    output  logic                                               m_axi_wlast,
    input   logic                                               m_axi_wready,
    output  logic [3:0]                                         m_axi_wstrb,
    output  logic                                               m_axi_wvalid,

    input logic c0_init_calib_complete_0
);


// ==================================================================================================================================================
// Declarations
// ==================================================================================================================================================

// Regbank
// ------------------------------------------------------------

logic                         matrix_a_address_strobe;
logic                         matrix_b_address_strobe;
logic                         matrix_c_address_strobe;

logic [31:0]                  matrix_a_address_value;
logic [31:0]                  matrix_b_address_value;
logic [31:0]                  matrix_c_address_value;

logic [8:0]                   matrix_a_strobe;
logic [8:0]                   matrix_b_strobe;

logic [8:0] [31:0]            matrix_a_value;
logic [8:0] [31:0]            matrix_b_value;

logic                         config_strobe;

logic [0:0]                   config_matrix_a_valid;
logic [0:0]                   config_matrix_b_valid;
logic [0:0]                   config_start_mult;
logic [0:0]                   config_mult_done;

// Base AGG - single reg write
// ------------------------------------------------------------

typedef enum {
    IDLE            = 4'd0,
    AW_STATE        = 4'd1,
    W_STATE         = 4'd2,
    B_STATE         = 4'd3,
    WAIT_STATE      = 4'd4,
    AR_STATE        = 4'd5,
    R_STATE         = 4'd6,
    CHECK_STATE     = 4'd7,
    DONE_STATE      = 4'd8
} fsm_e;

fsm_e state, state_n;
logic [3:0] wait_cnt;

// ==================================================================================================================================================
// Instances
// ==================================================================================================================================================

// Register Bank
// ----------------------------------------------------

aggregation_engine_regbank_regs #(
    .AXI_ADDR_WIDTH(32),
    .BASEADDR(32'b0) // use regbank parameter
) aggregation_engine_regbank_regs_i (
    .axi_aclk                       (core_clk),
    .axi_aresetn                    (resetn),
    .s_axi_awaddr,
    .s_axi_awprot,
    .s_axi_awvalid,
    .s_axi_awready,
    .s_axi_wdata,
    .s_axi_wstrb,
    .s_axi_wvalid,
    .s_axi_wready,
    .s_axi_araddr,
    .s_axi_arprot,
    .s_axi_arvalid,
    .s_axi_arready,
    .s_axi_rdata,
    .s_axi_rresp,
    .s_axi_rvalid,
    .s_axi_rready,
    .s_axi_bresp,
    .s_axi_bvalid,
    .s_axi_bready,
    .matrix_a_address_strobe,
    .matrix_a_address_value,
    .matrix_b_address_strobe,
    .matrix_b_address_value,
    .matrix_c_address_strobe,
    .matrix_c_address_value,
    .matrix_a_strobe,
    .matrix_a_value,
    .matrix_b_strobe,
    .matrix_b_value,
    .config_strobe,
    .config_matrix_a_valid,
    .config_matrix_b_valid,
    .config_start_mult,
    .config_mult_done 
);

// ==================================================================================================================================================
// Logic
// ==================================================================================================================================================

// State Machine
// ----------------------------------------------------

always_ff @(posedge core_clk or negedge resetn) begin
    if (!resetn) begin
        state   <= IDLE;
    end else begin
        state   <= state_n;
    end
end

always_comb begin
    state_n = state;
    case(state)
        IDLE:           state_n = c0_init_calib_complete_0 ? AW_STATE : IDLE;
        AW_STATE:       state_n = (m_axi_awvalid && m_axi_awready) ? W_STATE : AW_STATE;
        W_STATE:        state_n = (m_axi_wvalid && m_axi_wready) ? B_STATE : W_STATE;
        B_STATE:        state_n = (m_axi_bvalid && m_axi_bready) ? WAIT_STATE : B_STATE;
        WAIT_STATE:     state_n = (wait_cnt == '1) ? AR_STATE : WAIT_STATE;
        AR_STATE:       state_n = (m_axi_arvalid && m_axi_arready) ? R_STATE : AR_STATE;
        R_STATE:        state_n = (m_axi_rvalid && m_axi_rready) ? CHECK_STATE : R_STATE;
        CHECK_STATE:    state_n = DONE_STATE;
        DONE_STATE:     state_n = DONE_STATE;
        default:        state_n = IDLE;
    endcase
end

// Wait counter
// ----------------------------------------------------

always_ff @(posedge core_clk or negedge resetn) begin
    if (!resetn) begin
        wait_cnt <= '0;
    end else begin
        wait_cnt <= (state == B_STATE) && (state_n == WAIT_STATE) ? '0
                    : WAIT_STATE ? wait_cnt + 1'b1
                    : wait_cnt;
    end
end

// Checker
// ----------------------------------------------------

logic [31:0] received_data;
logic check_pass, check_fail;

always_ff @( posedge core_clk or negedge resetn ) begin : reg_checker
    if (!resetn) begin
        received_data <= '0;
        check_pass    <= '0;
        check_fail    <= '0;
    end else begin
        received_data <= (state == R_STATE) && m_axi_rvalid ? m_axi_rdata
                        : received_data;

        if (state == CHECK_STATE) begin
            check_pass <= (received_data == TEST_DATA);
            check_fail <= (received_data != TEST_DATA);
        end
    end
end

// AXI signals
// ----------------------------------------------------

parameter TEST_ADDR = 32'hDBADD000;
parameter TEST_DATA = 32'hDEADBEEF;

always_comb begin
    // AW stage
    m_axi_awaddr        = TEST_ADDR;
    m_axi_awburst       = '0;
    m_axi_awcache       = '0;
    m_axi_awid          = '0; // why single bit?
    m_axi_awlen         = '0;
    m_axi_awlock        = '0;
    m_axi_awprot        = '0; // 010 for non-secure?
    m_axi_awqos         = '0; // try with '1 to use as ID
    m_axi_awregion      = '0;
    m_axi_awsize        = '0;
    m_axi_awvalid       = (state == AW_STATE);

    m_axi_wdata         = TEST_DATA;
    m_axi_wlast         = (state == W_STATE);
    m_axi_wstrb         = '1;
    m_axi_wvalid        = (state == W_STATE);

    m_axi_bready        = '1;

    m_axi_araddr        = TEST_ADDR;
    m_axi_arburst       = '0;
    m_axi_arcache       = '0;
    m_axi_arid          = '0;
    m_axi_arlen         = '0;
    m_axi_arlock        = '0;
    m_axi_arprot        = '0;
    m_axi_arqos         = '0;
    m_axi_arregion      = '0;
    m_axi_arsize        = '0;
    m_axi_arvalid       = (state == AR_STATE);

    m_axi_rready        = (state == R_STATE);
end

// ==================================================================================================================================================
// Assertions
// ==================================================================================================================================================

endmodule