// -----------------------------------------------------------------------------
// 'aggregation_engine_regbank' Register Definitions
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

package aggregation_engine_regbank_regs_pkg;


    // Revision number of the 'aggregation_engine_regbank' register map
    localparam AGGREGATION_ENGINE_REGBANK_REVISION = 15;

    // Default base address of the 'aggregation_engine_regbank' register map
    localparam logic [31:0] AGGREGATION_ENGINE_REGBANK_DEFAULT_BASEADDR = 32'h00000000;

    // Size of the 'aggregation_engine_regbank' register map, in bytes
    localparam AGGREGATION_ENGINE_REGBANK_RANGE_BYTES = 88;

    // Register 'matrix_a_address'
    localparam logic [31:0] MATRIX_A_ADDRESS_OFFSET = 32'h00000000; // address offset of the 'matrix_a_address' register
    // Field 'matrix_a_address.value'
    localparam MATRIX_A_ADDRESS_VALUE_BIT_OFFSET = 0; // bit offset of the 'value' field
    localparam MATRIX_A_ADDRESS_VALUE_BIT_WIDTH = 32; // bit width of the 'value' field
    localparam logic [31:0] MATRIX_A_ADDRESS_VALUE_RESET = 32'b00000000000000000000000000000000; // reset value of the 'value' field

    // Register 'matrix_b_address'
    localparam logic [31:0] MATRIX_B_ADDRESS_OFFSET = 32'h00000004; // address offset of the 'matrix_b_address' register
    // Field 'matrix_b_address.value'
    localparam MATRIX_B_ADDRESS_VALUE_BIT_OFFSET = 0; // bit offset of the 'value' field
    localparam MATRIX_B_ADDRESS_VALUE_BIT_WIDTH = 32; // bit width of the 'value' field
    localparam logic [31:0] MATRIX_B_ADDRESS_VALUE_RESET = 32'b00000000000000000000000000000000; // reset value of the 'value' field

    // Register 'matrix_c_address'
    localparam logic [31:0] MATRIX_C_ADDRESS_OFFSET = 32'h00000008; // address offset of the 'matrix_c_address' register
    // Field 'matrix_c_address.value'
    localparam MATRIX_C_ADDRESS_VALUE_BIT_OFFSET = 0; // bit offset of the 'value' field
    localparam MATRIX_C_ADDRESS_VALUE_BIT_WIDTH = 32; // bit width of the 'value' field
    localparam logic [31:0] MATRIX_C_ADDRESS_VALUE_RESET = 32'b00000000000000000000000000000000; // reset value of the 'value' field

    // Register 'matrix_a'
    localparam logic [31:0] MATRIX_A_OFFSET = 32'h0000000C; // address offset of the 'matrix_a' register
    localparam MATRIX_A_ARRAY_LENGTH = 9; // length of the 'matrix_a' register array, in elements
    // Field 'matrix_a.value'
    localparam MATRIX_A_VALUE_BIT_OFFSET = 0; // bit offset of the 'value' field
    localparam MATRIX_A_VALUE_BIT_WIDTH = 32; // bit width of the 'value' field
    localparam logic [31:0] MATRIX_A_VALUE_RESET = 32'b00000000000000000000000000000000; // reset value of the 'value' field

    // Register 'matrix_b'
    localparam logic [31:0] MATRIX_B_OFFSET = 32'h00000030; // address offset of the 'matrix_b' register
    localparam MATRIX_B_ARRAY_LENGTH = 9; // length of the 'matrix_b' register array, in elements
    // Field 'matrix_b.value'
    localparam MATRIX_B_VALUE_BIT_OFFSET = 0; // bit offset of the 'value' field
    localparam MATRIX_B_VALUE_BIT_WIDTH = 32; // bit width of the 'value' field
    localparam logic [31:0] MATRIX_B_VALUE_RESET = 32'b00000000000000000000000000000000; // reset value of the 'value' field

    // Register 'config'
    localparam logic [31:0] CONFIG_OFFSET = 32'h00000054; // address offset of the 'config' register
    // Field 'config.matrix_a_valid'
    localparam CONFIG_MATRIX_A_VALID_BIT_OFFSET = 0; // bit offset of the 'matrix_a_valid' field
    localparam CONFIG_MATRIX_A_VALID_BIT_WIDTH = 1; // bit width of the 'matrix_a_valid' field
    localparam logic [0:0] CONFIG_MATRIX_A_VALID_RESET = 1'b0; // reset value of the 'matrix_a_valid' field
    // Field 'config.matrix_b_valid'
    localparam CONFIG_MATRIX_B_VALID_BIT_OFFSET = 1; // bit offset of the 'matrix_b_valid' field
    localparam CONFIG_MATRIX_B_VALID_BIT_WIDTH = 1; // bit width of the 'matrix_b_valid' field
    localparam logic [1:1] CONFIG_MATRIX_B_VALID_RESET = 1'b0; // reset value of the 'matrix_b_valid' field
    // Field 'config.start_mult'
    localparam CONFIG_START_MULT_BIT_OFFSET = 2; // bit offset of the 'start_mult' field
    localparam CONFIG_START_MULT_BIT_WIDTH = 1; // bit width of the 'start_mult' field
    localparam logic [2:2] CONFIG_START_MULT_RESET = 1'b0; // reset value of the 'start_mult' field
    // Field 'config.mult_done'
    localparam CONFIG_MULT_DONE_BIT_OFFSET = 3; // bit offset of the 'mult_done' field
    localparam CONFIG_MULT_DONE_BIT_WIDTH = 1; // bit width of the 'mult_done' field
    localparam logic [3:3] CONFIG_MULT_DONE_RESET = 1'b0; // reset value of the 'mult_done' field

endpackage: aggregation_engine_regbank_regs_pkg
