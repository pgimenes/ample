
import top_pkg::*;
import node_scoreboard_regbank_regs_pkg::*;

class node_scoreboard_tb_monitor;

virtual node_scoreboard_interface nsb_vif;
logic expecting_make_valid_msb;
logic expecting_make_valid_lsb;

function new(virtual node_scoreboard_interface nsb_intf);
    $display("[TIMESTAMP]: %d, [NSB_MONITOR::DEBUG]: NSB monitor created", $time);
    this.nsb_vif = nsb_intf;
endfunction

function int one_hot_to_decimal (input logic [31:0] one_hot);
    int i;
    for (i = 0; i < 32; i++) begin
        if (one_hot[i] == 1'b1)
            return i;
    end
    return -1; // Error condition: no bits were set in the input
endfunction

task main();
    logic [31:0] msb_addr;
    logic [31:0] lsb_addr;

    $display("[TIMESTAMP]: %d, [NSB_MONITOR::DEBUG]: Checking for writes", $time);

    msb_addr = NODE_SCOREBOARD_REGBANK_DEFAULT_BASEADDR + NSB_NODESLOT_CONFIG_MAKE_VALID_MSB_OFFSET;
    msb_addr = NODE_SCOREBOARD_REGBANK_DEFAULT_BASEADDR + NSB_NODESLOT_CONFIG_MAKE_VALID_LSB_OFFSET;

    forever begin
        @(posedge nsb_vif.core_clk) begin

            if (nsb_vif.s_axi_awvalid && nsb_vif.s_axi_awready && (nsb_vif.s_axi_awaddr inside {msb_addr, lsb_addr})) begin
                // $display("[TIMESTAMP]: %d, Observed Host write to MAKE_VALID", $time);
                expecting_make_valid_msb <= (nsb_vif.s_axi_awaddr == msb_addr);
                expecting_make_valid_lsb <= (nsb_vif.s_axi_awaddr == lsb_addr);
            end

            if (nsb_vif.s_axi_wvalid && nsb_vif.s_axi_wready && (expecting_make_valid_msb || expecting_make_valid_lsb)) begin
                $display("[TIMESTAMP]: %t, [NSB_MONITOR::INFO]: Host set Nodeslot %d valid.", $time, one_hot_to_decimal(nsb_vif.s_axi_wdata));
                expecting_make_valid_msb <= '0;
                expecting_make_valid_lsb <= '0;
            end

            if (nsb_vif.nsb_prefetcher_req_valid && nsb_vif.nsb_prefetcher_req_ready) begin
                $display("[TIMESTAMP]: %t, [NSB_MONITOR::INFO]: Observed NSB->PREF request for Nodeslot %d with opcode %s", $time, nsb_vif.nsb_prefetcher_req.nodeslot, nsb_vif.nsb_prefetcher_req.req_opcode.name());
            end
        end
    end
endtask

endclass