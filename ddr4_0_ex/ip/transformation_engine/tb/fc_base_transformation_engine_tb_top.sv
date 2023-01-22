
module transformation_engine_tb_top;

parameter FLOAT_WIDTH = 32;
parameter CLK_PERIOD = 10;

logic core_clk;
logic rstn;

// ========================================================================================================
// Declarations
// ========================================================================================================

logic                        float_mac_en;             // enable accumulator update
logic [FLOAT_WIDTH-1:0]      float_mac_a;
logic [FLOAT_WIDTH-1:0]      float_mac_b;
logic [FLOAT_WIDTH-1:0]      float_mac_acc;            // accumulator

// ========================================================================================================
// INST
// ========================================================================================================

float_mac #(
    .WIDTH(FLOAT_WIDTH)
) float_mac_i (
    .core_clk,
    .rstn,
    .en             (float_mac_en),
    .a              (float_mac_a),
    .b              (float_mac_b),
    .acc            (float_mac_acc)
);

// ========================================================================================================
// DRIVER
// ========================================================================================================

initial
begin
    float_mac_en = '0;
    float_mac_a = '0;
    float_mac_b = '0;

    delay(10);

    // With breaks
    repeat(5) begin
        drive_random();
        clear_mac();
    end

    // Every cycle
    // repeat(5) drive_random();

    delay(10);

    $finish;

end

// ========================================================================================================
// Move to TB lib
// ========================================================================================================

task drive_random();
    logic [31:0] a_trans, b_trans;
    shortreal num1, num2, den1, den2, f;

    num1 = $urandom_range(0, 100);
    num2 = $urandom_range(0, 100);
    den1 = $urandom_range(0, 100);
    den2 = $urandom_range(0, 100);

    a_trans = $shortrealtobits(num1/den1);
    b_trans = $shortrealtobits(num2/den2);

    @(posedge core_clk) begin
        $display("timestamp: %d, a: %b, b: %b", $time, a_trans, b_trans);
        $display("corresponds to a: %f, b: %f", $bitstoshortreal(a_trans), $bitstoshortreal(b_trans));
        // Drive
        float_mac_en <= '1;
        float_mac_a  <= a_trans;
        float_mac_b  <= b_trans;
    end
endtask

task clear_mac ();
    @(posedge core_clk) begin
        float_mac_en <= '0;
        float_mac_a <= '0;
        float_mac_b <= '0;
        $display("timestamp: %d, acc: %f", $time, $bitstoshortreal(float_mac_acc));
    end
endtask

task delay(input int n);
    // wait n cycles
    repeat(n) @(posedge core_clk);
endtask

// Clock
initial begin
    core_clk = '1;
    forever #(CLK_PERIOD) core_clk = !core_clk;
end

// Reset
initial begin
    rstn = '0;
    #(5*2*CLK_PERIOD) rstn = '1;
end

endmodule