
import top_pkg::*;
import node_scoreboard_regbank_regs_pkg::*;

class node_scoreboard_tb_monitor;

virtual node_scoreboard_interface nsb_vif;
logic expecting_make_valid_msb;
logic expecting_make_valid_lsb;

function new(virtual node_scoreboard_interface nsb_intf);
    $display("NSB monitor created");
    this.nsb_vif = nsb_intf;
endfunction

task main();
    $display("Checking for writes");
    forever begin
        @(posedge nsb_vif.core_clk) begin
            if (nsb_vif.s_axi_awvalid && nsb_vif.s_axi_awready && (nsb_vif.s_axi_awaddr == node_scoreboard_regbank_regs_pkg::NSB_NODESLOT_CONFIG_MAKE_VALID_MSB_OFFSET || nsb_vif.s_axi_awaddr == node_scoreboard_regbank_regs_pkg::NSB_NODESLOT_CONFIG_MAKE_VALID_LSB_OFFSET)) begin
                $display("[TIMESTAMP]: %d, Observed Host write to MAKE_VALID", $time);
                expecting_make_valid_msb <= (nsb_vif.s_axi_awaddr == node_scoreboard_regbank_regs_pkg::NSB_NODESLOT_CONFIG_MAKE_VALID_MSB_OFFSET);
                expecting_make_valid_lsb <= (nsb_vif.s_axi_awaddr == node_scoreboard_regbank_regs_pkg::NSB_NODESLOT_CONFIG_MAKE_VALID_LSB_OFFSET);
            end

            if (nsb_vif.s_axi_wvalid && nsb_vif.s_axi_wready && (expecting_make_valid_msb || expecting_make_valid_lsb)) begin
                $display("[TIMESTAMP]: %d, Host set Nodeslot %d valid.", $time, nsb_vif.s_axi_wdata);
                expecting_make_valid_msb <= '0;
                expecting_make_valid_lsb <= '0;
            end

            if (nsb_vif.nsb_prefetcher_req_valid && nsb_vif.nsb_prefetcher_req_ready) begin
                $display("[TIMESTAMP]: %d, Observed NSB->PREF request for Nodeslot %d with opcode %h", $time, nsb_vif.nsb_prefetcher_req.nodeslot, nsb_vif.nsb_prefetcher_req.req_opcode);
            end
        end
    end
endtask

endclass