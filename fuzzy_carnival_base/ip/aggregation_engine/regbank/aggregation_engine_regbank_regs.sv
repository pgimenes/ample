// -----------------------------------------------------------------------------
// 'aggregation_engine_regbank' Register Component
// Revision: 15
// -----------------------------------------------------------------------------
// Generated on 2022-12-29 at 17:55 (UTC) by airhdl version 2022.12.1-715060670
// -----------------------------------------------------------------------------
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.
// -----------------------------------------------------------------------------

`default_nettype none

module aggregation_engine_regbank_regs #(
    parameter AXI_ADDR_WIDTH = 32, // width of the AXI address bus
    parameter logic [31:0] BASEADDR = 32'h00000000 // the register file's system base address
    ) (
    // Clock and Reset
    input  wire                      axi_aclk,
    input  wire                      axi_aresetn,

    // AXI Write Address Channel
    input  wire [AXI_ADDR_WIDTH-1:0] s_axi_awaddr,
    input  wire [2:0]                s_axi_awprot,
    input  wire                      s_axi_awvalid,
    output wire                      s_axi_awready,

    // AXI Write Data Channel
    input  wire [31:0]               s_axi_wdata,
    input  wire [3:0]                s_axi_wstrb,
    input  wire                      s_axi_wvalid,
    output wire                      s_axi_wready,

    // AXI Read Address Channel
    input  wire [AXI_ADDR_WIDTH-1:0] s_axi_araddr,
    input  wire [2:0]                s_axi_arprot,
    input  wire                      s_axi_arvalid,
    output wire                      s_axi_arready,

    // AXI Read Data Channel
    output wire [31:0]               s_axi_rdata,
    output wire [1:0]                s_axi_rresp,
    output wire                      s_axi_rvalid,
    input  wire                      s_axi_rready,

    // AXI Write Response Channel
    output wire [1:0]                s_axi_bresp,
    output wire                      s_axi_bvalid,
    input  wire                      s_axi_bready,

    // User Ports
    output wire matrix_a_address_strobe, // Strobe logic for register 'matrix_a_address' (pulsed when the register is written from the bus)
    output wire [31:0] matrix_a_address_value, // Value of register 'matrix_a_address', field 'value'
    output wire matrix_b_address_strobe, // Strobe logic for register 'matrix_b_address' (pulsed when the register is written from the bus)
    output wire [31:0] matrix_b_address_value, // Value of register 'matrix_b_address', field 'value'
    output wire matrix_c_address_strobe, // Strobe logic for register 'matrix_c_address' (pulsed when the register is written from the bus)
    output wire [31:0] matrix_c_address_value, // Value of register 'matrix_c_address', field 'value'
    output wire [8:0] matrix_a_strobe, // Strobe logic for register 'matrix_a' (pulsed when the register is read from the bus)
    input wire [8:0] [31:0] matrix_a_value, // Value of register 'matrix_a', field 'value'
    output wire [8:0] matrix_b_strobe, // Strobe logic for register 'matrix_b' (pulsed when the register is read from the bus)
    input wire [8:0] [31:0] matrix_b_value, // Value of register 'matrix_b', field 'value'
    output wire config_strobe, // Strobe logic for register 'config' (pulsed when the register is written from the bus)
    output wire [0:0] config_matrix_a_valid, // Value of register 'config', field 'matrix_a_valid'
    output wire [0:0] config_matrix_b_valid, // Value of register 'config', field 'matrix_b_valid'
    output wire [0:0] config_start_mult, // Value of register 'config', field 'start_mult'
    output wire [0:0] config_mult_done // Value of register 'config', field 'mult_done'
    );

    // Constants
    localparam logic [1:0]                      AXI_OKAY        = 2'b00;
    localparam logic [1:0]                      AXI_DECERR      = 2'b11;

    // Registered signals
    logic                                       s_axi_awready_r;
    logic                                       s_axi_wready_r;
    logic [$bits(s_axi_awaddr)-1:0]             s_axi_awaddr_reg_r;
    logic                                       s_axi_bvalid_r;
    logic [$bits(s_axi_bresp)-1:0]              s_axi_bresp_r;
    logic                                       s_axi_arready_r;
    logic [$bits(s_axi_araddr)-1:0]             s_axi_araddr_reg_r;
    logic                                       s_axi_rvalid_r;
    logic [$bits(s_axi_rresp)-1:0]              s_axi_rresp_r;
    logic [$bits(s_axi_wdata)-1:0]              s_axi_wdata_reg_r;
    logic [$bits(s_axi_wstrb)-1:0]              s_axi_wstrb_reg_r;
    logic [$bits(s_axi_rdata)-1:0]              s_axi_rdata_r;

    // User-defined registers
    logic s_matrix_a_address_strobe_r;
    logic [31:0] s_reg_matrix_a_address_value_r;
    logic s_matrix_b_address_strobe_r;
    logic [31:0] s_reg_matrix_b_address_value_r;
    logic s_matrix_c_address_strobe_r;
    logic [31:0] s_reg_matrix_c_address_value_r;
    logic [8:0] s_matrix_a_strobe_r;
    logic [8:0] [31:0] s_reg_matrix_a_value;
    logic [8:0] s_matrix_b_strobe_r;
    logic [8:0] [31:0] s_reg_matrix_b_value;
    logic s_config_strobe_r;
    logic [0:0] s_reg_config_matrix_a_valid_r;
    logic [0:0] s_reg_config_matrix_b_valid_r;
    logic [0:0] s_reg_config_start_mult_r;
    logic [0:0] s_reg_config_mult_done_r;

    //--------------------------------------------------------------------------
    // Inputs
    //
    assign s_reg_matrix_a_value = matrix_a_value;
    assign s_reg_matrix_b_value = matrix_b_value;

    //--------------------------------------------------------------------------
    // Read-transaction FSM
    //
    localparam MAX_MEMORY_LATENCY = 5;

    typedef enum {
        READ_IDLE,
        READ_REGISTER,
        WAIT_MEMORY_RDATA,
        READ_RESPONSE,
        READ_DONE
    } read_state_t;

    always_ff@(posedge axi_aclk or negedge axi_aresetn) begin: read_fsm
        // registered state variables
        read_state_t v_state_r;
        logic [31:0] v_rdata_r;
        logic [1:0] v_rresp_r;
        logic [$clog2(MAX_MEMORY_LATENCY)-1:0] v_mem_wait_count_r;
        // combinatorial helper variables
        logic v_addr_hit;
        logic [AXI_ADDR_WIDTH-1:0] v_mem_addr;
        if (~axi_aresetn) begin
            v_state_r          <= READ_IDLE;
            v_rdata_r          <= '0;
            v_rresp_r          <= '0;
            v_mem_wait_count_r <= '0;
            s_axi_arready_r    <= '0;
            s_axi_rvalid_r     <= '0;
            s_axi_rresp_r      <= '0;
            s_axi_araddr_reg_r <= '0;
            s_axi_rdata_r      <= '0;
            s_matrix_a_strobe_r <= '0;
            s_matrix_b_strobe_r <= '0;
        end else begin
            // Default values:
            s_axi_arready_r <= 1'b0;
            s_matrix_a_strobe_r <= '0;
            s_matrix_b_strobe_r <= '0;

            case (v_state_r)

                // Wait for the start of a read transaction, which is
                // initiated by the assertion of ARVALID
                READ_IDLE: begin
                    if (s_axi_arvalid) begin
                        s_axi_araddr_reg_r <= s_axi_araddr;     // save the read address
                        s_axi_arready_r    <= 1'b1;             // acknowledge the read-address
                        v_state_r          <= READ_REGISTER;
                    end
                end

                // Read from the actual storage element
                READ_REGISTER: begin
                    // defaults:
                    v_addr_hit = 1'b0;
                    v_rdata_r  <= '0;

                    // register 'matrix_a_address' at address offset 0x0
                    if (s_axi_araddr_reg_r[AXI_ADDR_WIDTH-1:2] == BASEADDR[AXI_ADDR_WIDTH-1:2] + aggregation_engine_regbank_regs_pkg::MATRIX_A_ADDRESS_OFFSET[AXI_ADDR_WIDTH-1:2]) begin
                        v_addr_hit = 1'b1;
                        v_rdata_r[31:0] <= s_reg_matrix_a_address_value_r;
                        v_state_r <= READ_RESPONSE;
                    end
                    // register 'matrix_b_address' at address offset 0x4
                    if (s_axi_araddr_reg_r[AXI_ADDR_WIDTH-1:2] == BASEADDR[AXI_ADDR_WIDTH-1:2] + aggregation_engine_regbank_regs_pkg::MATRIX_B_ADDRESS_OFFSET[AXI_ADDR_WIDTH-1:2]) begin
                        v_addr_hit = 1'b1;
                        v_rdata_r[31:0] <= s_reg_matrix_b_address_value_r;
                        v_state_r <= READ_RESPONSE;
                    end
                    // register 'matrix_c_address' at address offset 0x8
                    if (s_axi_araddr_reg_r[AXI_ADDR_WIDTH-1:2] == BASEADDR[AXI_ADDR_WIDTH-1:2] + aggregation_engine_regbank_regs_pkg::MATRIX_C_ADDRESS_OFFSET[AXI_ADDR_WIDTH-1:2]) begin
                        v_addr_hit = 1'b1;
                        v_rdata_r[31:0] <= s_reg_matrix_c_address_value_r;
                        v_state_r <= READ_RESPONSE;
                    end
                    // register 'matrix_a[]' at address offset 0xC
                    for (int i = 0; i < 9; i++) begin
                        if (s_axi_araddr_reg_r[AXI_ADDR_WIDTH-1:2] == BASEADDR[AXI_ADDR_WIDTH-1:2] + aggregation_engine_regbank_regs_pkg::MATRIX_A_OFFSET[AXI_ADDR_WIDTH-1:2] + i * 1) begin
                            v_addr_hit = 1'b1;
                            v_rdata_r[31:0] <= s_reg_matrix_a_value[i];
                            s_matrix_a_strobe_r[i] <= 1'b1;
                            v_state_r <= READ_RESPONSE;
                        end
                    end
                    // register 'matrix_b[]' at address offset 0x30
                    for (int i = 0; i < 9; i++) begin
                        if (s_axi_araddr_reg_r[AXI_ADDR_WIDTH-1:2] == BASEADDR[AXI_ADDR_WIDTH-1:2] + aggregation_engine_regbank_regs_pkg::MATRIX_B_OFFSET[AXI_ADDR_WIDTH-1:2] + i * 1) begin
                            v_addr_hit = 1'b1;
                            v_rdata_r[31:0] <= s_reg_matrix_b_value[i];
                            s_matrix_b_strobe_r[i] <= 1'b1;
                            v_state_r <= READ_RESPONSE;
                        end
                    end
                    // register 'config' at address offset 0x54
                    if (s_axi_araddr_reg_r[AXI_ADDR_WIDTH-1:2] == BASEADDR[AXI_ADDR_WIDTH-1:2] + aggregation_engine_regbank_regs_pkg::CONFIG_OFFSET[AXI_ADDR_WIDTH-1:2]) begin
                        v_addr_hit = 1'b1;
                        v_rdata_r[0:0] <= s_reg_config_matrix_a_valid_r;
                        v_rdata_r[1:1] <= s_reg_config_matrix_b_valid_r;
                        v_rdata_r[2:2] <= s_reg_config_start_mult_r;
                        v_rdata_r[3:3] <= s_reg_config_mult_done_r;
                        v_state_r <= READ_RESPONSE;
                    end
                    if (v_addr_hit) begin
                        v_rresp_r <= AXI_OKAY;
                    end else begin
                        v_rresp_r <= AXI_DECERR;
                        // pragma translate_off
                        $warning("ARADDR decode error");
                        // pragma translate_on
                        v_state_r <= READ_RESPONSE;
                    end
                end

                // Wait for memory read data
                WAIT_MEMORY_RDATA: begin
                    if (v_mem_wait_count_r == 0) begin
                        v_state_r <= READ_RESPONSE;
                    end else begin
                        v_mem_wait_count_r <= v_mem_wait_count_r - 1;
                    end
                end

                // Generate read response
                READ_RESPONSE: begin
                    s_axi_rvalid_r <= 1'b1;
                    s_axi_rresp_r  <= v_rresp_r;
                    s_axi_rdata_r  <= v_rdata_r;
                    v_state_r      <= READ_DONE;
                end

                // Write transaction completed, wait for master RREADY to proceed
                READ_DONE: begin
                    if (s_axi_rready) begin
                        s_axi_rvalid_r <= 1'b0;
                        s_axi_rdata_r  <= '0;
                        v_state_r      <= READ_IDLE;
                    end
                end

            endcase
        end
    end: read_fsm

    //--------------------------------------------------------------------------
    // Write-transaction FSM
    //

    typedef enum {
        WRITE_IDLE,
        WRITE_ADDR_FIRST,
        WRITE_DATA_FIRST,
        WRITE_UPDATE_REGISTER,
        WRITE_DONE
    } write_state_t;

    always_ff@(posedge axi_aclk or negedge axi_aresetn) begin: write_fsm
        // registered state variables
        write_state_t v_state_r;
        // combinatorial helper variables
        logic v_addr_hit;
        logic [AXI_ADDR_WIDTH-1:0] v_mem_addr;
        if (~axi_aresetn) begin
            v_state_r                   <= WRITE_IDLE;
            s_axi_awready_r             <= 1'b0;
            s_axi_wready_r              <= 1'b0;
            s_axi_awaddr_reg_r          <= '0;
            s_axi_wdata_reg_r           <= '0;
            s_axi_wstrb_reg_r           <= '0;
            s_axi_bvalid_r              <= 1'b0;
            s_axi_bresp_r               <= '0;

            s_matrix_a_address_strobe_r <= '0;
            s_reg_matrix_a_address_value_r <= aggregation_engine_regbank_regs_pkg::MATRIX_A_ADDRESS_VALUE_RESET;
            s_matrix_b_address_strobe_r <= '0;
            s_reg_matrix_b_address_value_r <= aggregation_engine_regbank_regs_pkg::MATRIX_B_ADDRESS_VALUE_RESET;
            s_matrix_c_address_strobe_r <= '0;
            s_reg_matrix_c_address_value_r <= aggregation_engine_regbank_regs_pkg::MATRIX_C_ADDRESS_VALUE_RESET;
            s_config_strobe_r <= '0;
            s_reg_config_matrix_a_valid_r <= aggregation_engine_regbank_regs_pkg::CONFIG_MATRIX_A_VALID_RESET;
            s_reg_config_matrix_b_valid_r <= aggregation_engine_regbank_regs_pkg::CONFIG_MATRIX_B_VALID_RESET;
            s_reg_config_start_mult_r <= aggregation_engine_regbank_regs_pkg::CONFIG_START_MULT_RESET;
            s_reg_config_mult_done_r <= aggregation_engine_regbank_regs_pkg::CONFIG_MULT_DONE_RESET;

        end else begin
            // Default values:
            s_axi_awready_r <= 1'b0;
            s_axi_wready_r  <= 1'b0;
            s_matrix_a_address_strobe_r <= '0;
            s_matrix_b_address_strobe_r <= '0;
            s_matrix_c_address_strobe_r <= '0;
            s_config_strobe_r <= '0;
            v_addr_hit = 1'b0;

            case (v_state_r)

                // Wait for the start of a write transaction, which may be
                // initiated by either of the following conditions:
                //   * assertion of both AWVALID and WVALID
                //   * assertion of AWVALID
                //   * assertion of WVALID
                WRITE_IDLE: begin
                    if (s_axi_awvalid && s_axi_wvalid) begin
                        s_axi_awaddr_reg_r <= s_axi_awaddr; // save the write-address
                        s_axi_awready_r    <= 1'b1; // acknowledge the write-address
                        s_axi_wdata_reg_r  <= s_axi_wdata; // save the write-data
                        s_axi_wstrb_reg_r  <= s_axi_wstrb; // save the write-strobe
                        s_axi_wready_r     <= 1'b1; // acknowledge the write-data
                        v_state_r          <= WRITE_UPDATE_REGISTER;
                    end else if (s_axi_awvalid) begin
                        s_axi_awaddr_reg_r <= s_axi_awaddr; // save the write-address
                        s_axi_awready_r    <= 1'b1; // acknowledge the write-address
                        v_state_r          <= WRITE_ADDR_FIRST;
                    end else if (s_axi_wvalid) begin
                        s_axi_wdata_reg_r <= s_axi_wdata; // save the write-data
                        s_axi_wstrb_reg_r <= s_axi_wstrb; // save the write-strobe
                        s_axi_wready_r    <= 1'b1; // acknowledge the write-data
                        v_state_r         <= WRITE_DATA_FIRST;
                    end
                end

                // Address-first write transaction: wait for the write-data
                WRITE_ADDR_FIRST: begin
                    if (s_axi_wvalid) begin
                        s_axi_wdata_reg_r <= s_axi_wdata; // save the write-data
                        s_axi_wstrb_reg_r <= s_axi_wstrb; // save the write-strobe
                        s_axi_wready_r    <= 1'b1; // acknowledge the write-data
                        v_state_r         <= WRITE_UPDATE_REGISTER;
                    end
                end

                // Data-first write transaction: wait for the write-address
                WRITE_DATA_FIRST: begin
                    if (s_axi_awvalid) begin
                        s_axi_awaddr_reg_r <= s_axi_awaddr; // save the write-address
                        s_axi_awready_r    <= 1'b1; // acknowledge the write-address
                        v_state_r          <= WRITE_UPDATE_REGISTER;
                    end
                end

                // Update the actual storage element
                WRITE_UPDATE_REGISTER: begin
                    s_axi_bresp_r  <= AXI_OKAY; // default value, may be overriden in case of decode error
                    s_axi_bvalid_r <= 1'b1;

                    // register 'matrix_a_address' at address offset 0x0
                    if (s_axi_awaddr_reg_r[AXI_ADDR_WIDTH-1:2] == BASEADDR[AXI_ADDR_WIDTH-1:2] + aggregation_engine_regbank_regs_pkg::MATRIX_A_ADDRESS_OFFSET[AXI_ADDR_WIDTH-1:2]) begin
                        v_addr_hit = 1'b1;
                        s_matrix_a_address_strobe_r <= 1'b1;
                        // field 'value':
                        if (s_axi_wstrb_reg_r[0]) begin
                            s_reg_matrix_a_address_value_r[0] <= s_axi_wdata_reg_r[0]; // value[0]
                        end
                        if (s_axi_wstrb_reg_r[0]) begin
                            s_reg_matrix_a_address_value_r[1] <= s_axi_wdata_reg_r[1]; // value[1]
                        end
                        if (s_axi_wstrb_reg_r[0]) begin
                            s_reg_matrix_a_address_value_r[2] <= s_axi_wdata_reg_r[2]; // value[2]
                        end
                        if (s_axi_wstrb_reg_r[0]) begin
                            s_reg_matrix_a_address_value_r[3] <= s_axi_wdata_reg_r[3]; // value[3]
                        end
                        if (s_axi_wstrb_reg_r[0]) begin
                            s_reg_matrix_a_address_value_r[4] <= s_axi_wdata_reg_r[4]; // value[4]
                        end
                        if (s_axi_wstrb_reg_r[0]) begin
                            s_reg_matrix_a_address_value_r[5] <= s_axi_wdata_reg_r[5]; // value[5]
                        end
                        if (s_axi_wstrb_reg_r[0]) begin
                            s_reg_matrix_a_address_value_r[6] <= s_axi_wdata_reg_r[6]; // value[6]
                        end
                        if (s_axi_wstrb_reg_r[0]) begin
                            s_reg_matrix_a_address_value_r[7] <= s_axi_wdata_reg_r[7]; // value[7]
                        end
                        if (s_axi_wstrb_reg_r[1]) begin
                            s_reg_matrix_a_address_value_r[8] <= s_axi_wdata_reg_r[8]; // value[8]
                        end
                        if (s_axi_wstrb_reg_r[1]) begin
                            s_reg_matrix_a_address_value_r[9] <= s_axi_wdata_reg_r[9]; // value[9]
                        end
                        if (s_axi_wstrb_reg_r[1]) begin
                            s_reg_matrix_a_address_value_r[10] <= s_axi_wdata_reg_r[10]; // value[10]
                        end
                        if (s_axi_wstrb_reg_r[1]) begin
                            s_reg_matrix_a_address_value_r[11] <= s_axi_wdata_reg_r[11]; // value[11]
                        end
                        if (s_axi_wstrb_reg_r[1]) begin
                            s_reg_matrix_a_address_value_r[12] <= s_axi_wdata_reg_r[12]; // value[12]
                        end
                        if (s_axi_wstrb_reg_r[1]) begin
                            s_reg_matrix_a_address_value_r[13] <= s_axi_wdata_reg_r[13]; // value[13]
                        end
                        if (s_axi_wstrb_reg_r[1]) begin
                            s_reg_matrix_a_address_value_r[14] <= s_axi_wdata_reg_r[14]; // value[14]
                        end
                        if (s_axi_wstrb_reg_r[1]) begin
                            s_reg_matrix_a_address_value_r[15] <= s_axi_wdata_reg_r[15]; // value[15]
                        end
                        if (s_axi_wstrb_reg_r[2]) begin
                            s_reg_matrix_a_address_value_r[16] <= s_axi_wdata_reg_r[16]; // value[16]
                        end
                        if (s_axi_wstrb_reg_r[2]) begin
                            s_reg_matrix_a_address_value_r[17] <= s_axi_wdata_reg_r[17]; // value[17]
                        end
                        if (s_axi_wstrb_reg_r[2]) begin
                            s_reg_matrix_a_address_value_r[18] <= s_axi_wdata_reg_r[18]; // value[18]
                        end
                        if (s_axi_wstrb_reg_r[2]) begin
                            s_reg_matrix_a_address_value_r[19] <= s_axi_wdata_reg_r[19]; // value[19]
                        end
                        if (s_axi_wstrb_reg_r[2]) begin
                            s_reg_matrix_a_address_value_r[20] <= s_axi_wdata_reg_r[20]; // value[20]
                        end
                        if (s_axi_wstrb_reg_r[2]) begin
                            s_reg_matrix_a_address_value_r[21] <= s_axi_wdata_reg_r[21]; // value[21]
                        end
                        if (s_axi_wstrb_reg_r[2]) begin
                            s_reg_matrix_a_address_value_r[22] <= s_axi_wdata_reg_r[22]; // value[22]
                        end
                        if (s_axi_wstrb_reg_r[2]) begin
                            s_reg_matrix_a_address_value_r[23] <= s_axi_wdata_reg_r[23]; // value[23]
                        end
                        if (s_axi_wstrb_reg_r[3]) begin
                            s_reg_matrix_a_address_value_r[24] <= s_axi_wdata_reg_r[24]; // value[24]
                        end
                        if (s_axi_wstrb_reg_r[3]) begin
                            s_reg_matrix_a_address_value_r[25] <= s_axi_wdata_reg_r[25]; // value[25]
                        end
                        if (s_axi_wstrb_reg_r[3]) begin
                            s_reg_matrix_a_address_value_r[26] <= s_axi_wdata_reg_r[26]; // value[26]
                        end
                        if (s_axi_wstrb_reg_r[3]) begin
                            s_reg_matrix_a_address_value_r[27] <= s_axi_wdata_reg_r[27]; // value[27]
                        end
                        if (s_axi_wstrb_reg_r[3]) begin
                            s_reg_matrix_a_address_value_r[28] <= s_axi_wdata_reg_r[28]; // value[28]
                        end
                        if (s_axi_wstrb_reg_r[3]) begin
                            s_reg_matrix_a_address_value_r[29] <= s_axi_wdata_reg_r[29]; // value[29]
                        end
                        if (s_axi_wstrb_reg_r[3]) begin
                            s_reg_matrix_a_address_value_r[30] <= s_axi_wdata_reg_r[30]; // value[30]
                        end
                        if (s_axi_wstrb_reg_r[3]) begin
                            s_reg_matrix_a_address_value_r[31] <= s_axi_wdata_reg_r[31]; // value[31]
                        end
                    end

                    // register 'matrix_b_address' at address offset 0x4
                    if (s_axi_awaddr_reg_r[AXI_ADDR_WIDTH-1:2] == BASEADDR[AXI_ADDR_WIDTH-1:2] + aggregation_engine_regbank_regs_pkg::MATRIX_B_ADDRESS_OFFSET[AXI_ADDR_WIDTH-1:2]) begin
                        v_addr_hit = 1'b1;
                        s_matrix_b_address_strobe_r <= 1'b1;
                        // field 'value':
                        if (s_axi_wstrb_reg_r[0]) begin
                            s_reg_matrix_b_address_value_r[0] <= s_axi_wdata_reg_r[0]; // value[0]
                        end
                        if (s_axi_wstrb_reg_r[0]) begin
                            s_reg_matrix_b_address_value_r[1] <= s_axi_wdata_reg_r[1]; // value[1]
                        end
                        if (s_axi_wstrb_reg_r[0]) begin
                            s_reg_matrix_b_address_value_r[2] <= s_axi_wdata_reg_r[2]; // value[2]
                        end
                        if (s_axi_wstrb_reg_r[0]) begin
                            s_reg_matrix_b_address_value_r[3] <= s_axi_wdata_reg_r[3]; // value[3]
                        end
                        if (s_axi_wstrb_reg_r[0]) begin
                            s_reg_matrix_b_address_value_r[4] <= s_axi_wdata_reg_r[4]; // value[4]
                        end
                        if (s_axi_wstrb_reg_r[0]) begin
                            s_reg_matrix_b_address_value_r[5] <= s_axi_wdata_reg_r[5]; // value[5]
                        end
                        if (s_axi_wstrb_reg_r[0]) begin
                            s_reg_matrix_b_address_value_r[6] <= s_axi_wdata_reg_r[6]; // value[6]
                        end
                        if (s_axi_wstrb_reg_r[0]) begin
                            s_reg_matrix_b_address_value_r[7] <= s_axi_wdata_reg_r[7]; // value[7]
                        end
                        if (s_axi_wstrb_reg_r[1]) begin
                            s_reg_matrix_b_address_value_r[8] <= s_axi_wdata_reg_r[8]; // value[8]
                        end
                        if (s_axi_wstrb_reg_r[1]) begin
                            s_reg_matrix_b_address_value_r[9] <= s_axi_wdata_reg_r[9]; // value[9]
                        end
                        if (s_axi_wstrb_reg_r[1]) begin
                            s_reg_matrix_b_address_value_r[10] <= s_axi_wdata_reg_r[10]; // value[10]
                        end
                        if (s_axi_wstrb_reg_r[1]) begin
                            s_reg_matrix_b_address_value_r[11] <= s_axi_wdata_reg_r[11]; // value[11]
                        end
                        if (s_axi_wstrb_reg_r[1]) begin
                            s_reg_matrix_b_address_value_r[12] <= s_axi_wdata_reg_r[12]; // value[12]
                        end
                        if (s_axi_wstrb_reg_r[1]) begin
                            s_reg_matrix_b_address_value_r[13] <= s_axi_wdata_reg_r[13]; // value[13]
                        end
                        if (s_axi_wstrb_reg_r[1]) begin
                            s_reg_matrix_b_address_value_r[14] <= s_axi_wdata_reg_r[14]; // value[14]
                        end
                        if (s_axi_wstrb_reg_r[1]) begin
                            s_reg_matrix_b_address_value_r[15] <= s_axi_wdata_reg_r[15]; // value[15]
                        end
                        if (s_axi_wstrb_reg_r[2]) begin
                            s_reg_matrix_b_address_value_r[16] <= s_axi_wdata_reg_r[16]; // value[16]
                        end
                        if (s_axi_wstrb_reg_r[2]) begin
                            s_reg_matrix_b_address_value_r[17] <= s_axi_wdata_reg_r[17]; // value[17]
                        end
                        if (s_axi_wstrb_reg_r[2]) begin
                            s_reg_matrix_b_address_value_r[18] <= s_axi_wdata_reg_r[18]; // value[18]
                        end
                        if (s_axi_wstrb_reg_r[2]) begin
                            s_reg_matrix_b_address_value_r[19] <= s_axi_wdata_reg_r[19]; // value[19]
                        end
                        if (s_axi_wstrb_reg_r[2]) begin
                            s_reg_matrix_b_address_value_r[20] <= s_axi_wdata_reg_r[20]; // value[20]
                        end
                        if (s_axi_wstrb_reg_r[2]) begin
                            s_reg_matrix_b_address_value_r[21] <= s_axi_wdata_reg_r[21]; // value[21]
                        end
                        if (s_axi_wstrb_reg_r[2]) begin
                            s_reg_matrix_b_address_value_r[22] <= s_axi_wdata_reg_r[22]; // value[22]
                        end
                        if (s_axi_wstrb_reg_r[2]) begin
                            s_reg_matrix_b_address_value_r[23] <= s_axi_wdata_reg_r[23]; // value[23]
                        end
                        if (s_axi_wstrb_reg_r[3]) begin
                            s_reg_matrix_b_address_value_r[24] <= s_axi_wdata_reg_r[24]; // value[24]
                        end
                        if (s_axi_wstrb_reg_r[3]) begin
                            s_reg_matrix_b_address_value_r[25] <= s_axi_wdata_reg_r[25]; // value[25]
                        end
                        if (s_axi_wstrb_reg_r[3]) begin
                            s_reg_matrix_b_address_value_r[26] <= s_axi_wdata_reg_r[26]; // value[26]
                        end
                        if (s_axi_wstrb_reg_r[3]) begin
                            s_reg_matrix_b_address_value_r[27] <= s_axi_wdata_reg_r[27]; // value[27]
                        end
                        if (s_axi_wstrb_reg_r[3]) begin
                            s_reg_matrix_b_address_value_r[28] <= s_axi_wdata_reg_r[28]; // value[28]
                        end
                        if (s_axi_wstrb_reg_r[3]) begin
                            s_reg_matrix_b_address_value_r[29] <= s_axi_wdata_reg_r[29]; // value[29]
                        end
                        if (s_axi_wstrb_reg_r[3]) begin
                            s_reg_matrix_b_address_value_r[30] <= s_axi_wdata_reg_r[30]; // value[30]
                        end
                        if (s_axi_wstrb_reg_r[3]) begin
                            s_reg_matrix_b_address_value_r[31] <= s_axi_wdata_reg_r[31]; // value[31]
                        end
                    end

                    // register 'matrix_c_address' at address offset 0x8
                    if (s_axi_awaddr_reg_r[AXI_ADDR_WIDTH-1:2] == BASEADDR[AXI_ADDR_WIDTH-1:2] + aggregation_engine_regbank_regs_pkg::MATRIX_C_ADDRESS_OFFSET[AXI_ADDR_WIDTH-1:2]) begin
                        v_addr_hit = 1'b1;
                        s_matrix_c_address_strobe_r <= 1'b1;
                        // field 'value':
                        if (s_axi_wstrb_reg_r[0]) begin
                            s_reg_matrix_c_address_value_r[0] <= s_axi_wdata_reg_r[0]; // value[0]
                        end
                        if (s_axi_wstrb_reg_r[0]) begin
                            s_reg_matrix_c_address_value_r[1] <= s_axi_wdata_reg_r[1]; // value[1]
                        end
                        if (s_axi_wstrb_reg_r[0]) begin
                            s_reg_matrix_c_address_value_r[2] <= s_axi_wdata_reg_r[2]; // value[2]
                        end
                        if (s_axi_wstrb_reg_r[0]) begin
                            s_reg_matrix_c_address_value_r[3] <= s_axi_wdata_reg_r[3]; // value[3]
                        end
                        if (s_axi_wstrb_reg_r[0]) begin
                            s_reg_matrix_c_address_value_r[4] <= s_axi_wdata_reg_r[4]; // value[4]
                        end
                        if (s_axi_wstrb_reg_r[0]) begin
                            s_reg_matrix_c_address_value_r[5] <= s_axi_wdata_reg_r[5]; // value[5]
                        end
                        if (s_axi_wstrb_reg_r[0]) begin
                            s_reg_matrix_c_address_value_r[6] <= s_axi_wdata_reg_r[6]; // value[6]
                        end
                        if (s_axi_wstrb_reg_r[0]) begin
                            s_reg_matrix_c_address_value_r[7] <= s_axi_wdata_reg_r[7]; // value[7]
                        end
                        if (s_axi_wstrb_reg_r[1]) begin
                            s_reg_matrix_c_address_value_r[8] <= s_axi_wdata_reg_r[8]; // value[8]
                        end
                        if (s_axi_wstrb_reg_r[1]) begin
                            s_reg_matrix_c_address_value_r[9] <= s_axi_wdata_reg_r[9]; // value[9]
                        end
                        if (s_axi_wstrb_reg_r[1]) begin
                            s_reg_matrix_c_address_value_r[10] <= s_axi_wdata_reg_r[10]; // value[10]
                        end
                        if (s_axi_wstrb_reg_r[1]) begin
                            s_reg_matrix_c_address_value_r[11] <= s_axi_wdata_reg_r[11]; // value[11]
                        end
                        if (s_axi_wstrb_reg_r[1]) begin
                            s_reg_matrix_c_address_value_r[12] <= s_axi_wdata_reg_r[12]; // value[12]
                        end
                        if (s_axi_wstrb_reg_r[1]) begin
                            s_reg_matrix_c_address_value_r[13] <= s_axi_wdata_reg_r[13]; // value[13]
                        end
                        if (s_axi_wstrb_reg_r[1]) begin
                            s_reg_matrix_c_address_value_r[14] <= s_axi_wdata_reg_r[14]; // value[14]
                        end
                        if (s_axi_wstrb_reg_r[1]) begin
                            s_reg_matrix_c_address_value_r[15] <= s_axi_wdata_reg_r[15]; // value[15]
                        end
                        if (s_axi_wstrb_reg_r[2]) begin
                            s_reg_matrix_c_address_value_r[16] <= s_axi_wdata_reg_r[16]; // value[16]
                        end
                        if (s_axi_wstrb_reg_r[2]) begin
                            s_reg_matrix_c_address_value_r[17] <= s_axi_wdata_reg_r[17]; // value[17]
                        end
                        if (s_axi_wstrb_reg_r[2]) begin
                            s_reg_matrix_c_address_value_r[18] <= s_axi_wdata_reg_r[18]; // value[18]
                        end
                        if (s_axi_wstrb_reg_r[2]) begin
                            s_reg_matrix_c_address_value_r[19] <= s_axi_wdata_reg_r[19]; // value[19]
                        end
                        if (s_axi_wstrb_reg_r[2]) begin
                            s_reg_matrix_c_address_value_r[20] <= s_axi_wdata_reg_r[20]; // value[20]
                        end
                        if (s_axi_wstrb_reg_r[2]) begin
                            s_reg_matrix_c_address_value_r[21] <= s_axi_wdata_reg_r[21]; // value[21]
                        end
                        if (s_axi_wstrb_reg_r[2]) begin
                            s_reg_matrix_c_address_value_r[22] <= s_axi_wdata_reg_r[22]; // value[22]
                        end
                        if (s_axi_wstrb_reg_r[2]) begin
                            s_reg_matrix_c_address_value_r[23] <= s_axi_wdata_reg_r[23]; // value[23]
                        end
                        if (s_axi_wstrb_reg_r[3]) begin
                            s_reg_matrix_c_address_value_r[24] <= s_axi_wdata_reg_r[24]; // value[24]
                        end
                        if (s_axi_wstrb_reg_r[3]) begin
                            s_reg_matrix_c_address_value_r[25] <= s_axi_wdata_reg_r[25]; // value[25]
                        end
                        if (s_axi_wstrb_reg_r[3]) begin
                            s_reg_matrix_c_address_value_r[26] <= s_axi_wdata_reg_r[26]; // value[26]
                        end
                        if (s_axi_wstrb_reg_r[3]) begin
                            s_reg_matrix_c_address_value_r[27] <= s_axi_wdata_reg_r[27]; // value[27]
                        end
                        if (s_axi_wstrb_reg_r[3]) begin
                            s_reg_matrix_c_address_value_r[28] <= s_axi_wdata_reg_r[28]; // value[28]
                        end
                        if (s_axi_wstrb_reg_r[3]) begin
                            s_reg_matrix_c_address_value_r[29] <= s_axi_wdata_reg_r[29]; // value[29]
                        end
                        if (s_axi_wstrb_reg_r[3]) begin
                            s_reg_matrix_c_address_value_r[30] <= s_axi_wdata_reg_r[30]; // value[30]
                        end
                        if (s_axi_wstrb_reg_r[3]) begin
                            s_reg_matrix_c_address_value_r[31] <= s_axi_wdata_reg_r[31]; // value[31]
                        end
                    end



                    // register 'config' at address offset 0x54
                    if (s_axi_awaddr_reg_r[AXI_ADDR_WIDTH-1:2] == BASEADDR[AXI_ADDR_WIDTH-1:2] + aggregation_engine_regbank_regs_pkg::CONFIG_OFFSET[AXI_ADDR_WIDTH-1:2]) begin
                        v_addr_hit = 1'b1;
                        s_config_strobe_r <= 1'b1;
                        // field 'matrix_a_valid':
                        if (s_axi_wstrb_reg_r[0]) begin
                            s_reg_config_matrix_a_valid_r[0] <= s_axi_wdata_reg_r[0]; // matrix_a_valid[0]
                        end
                        // field 'matrix_b_valid':
                        if (s_axi_wstrb_reg_r[0]) begin
                            s_reg_config_matrix_b_valid_r[0] <= s_axi_wdata_reg_r[1]; // matrix_b_valid[0]
                        end
                        // field 'start_mult':
                        if (s_axi_wstrb_reg_r[0]) begin
                            s_reg_config_start_mult_r[0] <= s_axi_wdata_reg_r[2]; // start_mult[0]
                        end
                        // field 'mult_done':
                        if (s_axi_wstrb_reg_r[0]) begin
                            s_reg_config_mult_done_r[0] <= s_axi_wdata_reg_r[3]; // mult_done[0]
                        end
                    end

                    if (!v_addr_hit) begin
                        s_axi_bresp_r   <= AXI_DECERR;
                        // pragma translate_off
                        $warning("AWADDR decode error");
                        // pragma translate_on
                    end
                    v_state_r <= WRITE_DONE;
                end

                // Write transaction completed, wait for master BREADY to proceed
                WRITE_DONE: begin
                    if (s_axi_bready) begin
                        s_axi_bvalid_r <= 1'b0;
                        v_state_r      <= WRITE_IDLE;
                    end
                end
            endcase


        end
    end: write_fsm

    //--------------------------------------------------------------------------
    // Outputs
    //
    assign s_axi_awready = s_axi_awready_r;
    assign s_axi_wready  = s_axi_wready_r;
    assign s_axi_bvalid  = s_axi_bvalid_r;
    assign s_axi_bresp   = s_axi_bresp_r;
    assign s_axi_arready = s_axi_arready_r;
    assign s_axi_rvalid  = s_axi_rvalid_r;
    assign s_axi_rresp   = s_axi_rresp_r;
    assign s_axi_rdata   = s_axi_rdata_r;

    assign matrix_a_address_strobe = s_matrix_a_address_strobe_r;
    assign matrix_a_address_value = s_reg_matrix_a_address_value_r;
    assign matrix_b_address_strobe = s_matrix_b_address_strobe_r;
    assign matrix_b_address_value = s_reg_matrix_b_address_value_r;
    assign matrix_c_address_strobe = s_matrix_c_address_strobe_r;
    assign matrix_c_address_value = s_reg_matrix_c_address_value_r;
    assign matrix_a_strobe = s_matrix_a_strobe_r;
    assign matrix_b_strobe = s_matrix_b_strobe_r;
    assign config_strobe = s_config_strobe_r;
    assign config_matrix_a_valid = s_reg_config_matrix_a_valid_r;
    assign config_matrix_b_valid = s_reg_config_matrix_b_valid_r;
    assign config_start_mult = s_reg_config_start_mult_r;
    assign config_mult_done = s_reg_config_mult_done_r;

endmodule: aggregation_engine_regbank_regs

`resetall
