
import top_pkg::*;
import json::*;

class agc_allocator_monitor;

virtual agc_allocator_interface allocator_vif;
Node_Scoreboard sb;

top_pkg::NODE_PRECISION_e precision;

function new(virtual agc_allocator_interface allocator_vif, top_pkg::NODE_PRECISION_e precision, ref Node_Scoreboard node_scoreboard);
    $display("[TIMESTAMP]: %t, [AGC_ALLOCATOR::INFO]: Allocator monitor instantiated for precision: %0s", $time, precision.name());
    this.allocator_vif = allocator_vif;
    this.sb = node_scoreboard;
    this.precision = precision;
endfunction

task main();
    fork
        $display("[TIMESTAMP]: %t, [AGC_ALLOCATOR::INFO]: Allocator monitor activated for precision: %0s", $time, this.precision.name());
        allocation_reqs();
    join_any
endtask

task allocation_reqs();
    forever begin
        @(posedge allocator_vif.core_clk) begin
            if (allocator_vif.allocation_req_valid && allocator_vif.allocation_req_ready) begin
                $display("[TIMESTAMP]: %t, [AGC_ALLOCATOR]::INFO: %0s Allocator is receiving aggregation request for NS%0d.", $time, this.precision, allocator_vif.allocation_req.nodeslot);
                display_req(allocator_vif.allocation_req);
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