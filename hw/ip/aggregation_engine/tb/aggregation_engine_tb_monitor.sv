
import top_pkg::*;
import json::*;

class aggregation_engine_tb_monitor;

virtual aggregation_engine_interface age_vif;

Node_Scoreboard sb;

function new(virtual aggregation_engine_interface age_intf, ref Node_Scoreboard node_scoreboard);
    $display("[TIMESTAMP]: %t, [AGE_MONITOR::DEBUG]: AGE monitor instantiated.", $time);
    this.age_vif = age_intf;
    this.sb = node_scoreboard;
endfunction

task main();
    fork
        $display("[TIMESTAMP]: %t, [AGE_MONITOR::DEBUG]: AGE monitor activated.", $time);
        nsb_req();
    join_any
endtask

// Monitor NSB requests
task nsb_req();
    forever begin
        @(posedge age_vif.core_clk) begin
            if (age_vif.nsb_age_req_valid && age_vif.nsb_age_req_ready) begin
                $display("[TIMESTAMP]: %t, [AGE_MONITOR]::INFO: Aggregation Engine is accepting NSB request for Nodeslot %d.", $time, age_vif.nsb_age_req.nodeslot);
                display_nsb_req(age_vif.nsb_age_req);
            end
        end
    end
endtask

task display_nsb_req(top_pkg::NSB_AGE_REQ_t nsb_req);
    $display("                                              | --------------------------------------- |");
    $display("                                              | nodeslot             | %-20d | ", nsb_req.nodeslot);
    $display("                                              | fetch_tag            | %-20d | ", nsb_req.fetch_tag);
    $display("                                              | node_precision       | %-20s | ", nsb_req.node_precision.name());
    $display("                                              | aggregation_function | %-20s | ", nsb_req.aggregation_function.name());
    $display("                                              | --------------------------------------- |");
endtask

endclass