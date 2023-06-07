
import top_pkg::*;
import json::*;
import tb_utils::*;

class agc_allocator_monitor;

virtual agc_allocator_interface vif;
Node_Scoreboard sb;

top_pkg::NODE_PRECISION_e precision;

function new(virtual agc_allocator_interface vif, top_pkg::NODE_PRECISION_e precision, ref Node_Scoreboard node_scoreboard);
    $display("[TIMESTAMP]: %t, [AGC_ALLOCATOR::INFO]: Allocator monitor instantiated for precision: %0s", $time, precision.name());
    this.vif = vif;
    this.precision = precision;
    this.sb = node_scoreboard;
endfunction

task main();
    forever begin
        @(posedge vif.core_clk) begin

            // AGC Allocation requests
            if (vif.allocation_req_valid && vif.allocation_req_ready) begin
                $display("[TIMESTAMP]: %t, [AGC_ALLOCATOR]::INFO: %0s Allocator is receiving aggregation request for NS%0d.", $time, this.precision, vif.allocation_req.nodeslot);
            end

            // Deallocation
            if (vif.deallocation_valid) begin
                $display("[TIMESTAMP]: %t, [AGC_ALLOCATOR]::INFO: %0s Allocator is receiving deallocation request for the following cores: %0b.", $time, this.precision, vif.deallocation_cores);
            end

            // AGM requests
            if (|(vif.agm_req_valid && vif.agm_req_ready)) begin
                $display("[TIMESTAMP]: %t, [AGC_ALLOCATOR]::INFO: %0s Allocator is triggering AGM %0d to perform aggregation for NS%0d.", $time, this.precision, tb_utils::onehot_to_binary(vif.agm_req_valid), vif.agm_req.nsb_req.nodeslot);
            end

        end

    end
endtask

task display_req(top_pkg::NSB_AGE_REQ_t allocation_req);
    $display("                                              | --------------------------------------- |");
    $display("                                              | node_id              | %-20d | ", allocation_req.node_id);
    $display("                                              | fetch_tag            | %-20d | ", allocation_req.fetch_tag);
    $display("                                              | aggregation_function | %-20s | ", allocation_req.aggregation_function.name());
    $display("                                              | --------------------------------------- |");
endtask

endclass