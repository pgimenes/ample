
import top_pkg::*;

class prefetcher_tb_monitor;

virtual prefetcher_interface prefetcher_vif;

function new(virtual prefetcher_interface prefetcher_intf);
    $display("Prefetcher monitor created");
    this.prefetcher_vif = prefetcher_intf;
endfunction

task main();
    $display("Main function in prefetcher monitor");
    fork
        nsb_req();
    join
endtask

// Monitor NSB requests
task nsb_req();
    forever begin
        @(posedge prefetcher_vif.core_clk) begin
            if (prefetcher_vif.nsb_prefetcher_req_valid && prefetcher_vif.nsb_prefetcher_req_ready && (prefetcher_vif.nsb_prefetcher_req.nodeslot == '0)) begin
                $display("[TIMESTAMP]: %t, [PREFETCHER_MONITOR]::INFO: Prefetcher is accepting %s request from NSB for Nodeslot %d. Request payloads:", $time, prefetcher_vif.nsb_prefetcher_req.req_opcode.name(), prefetcher_vif.nsb_prefetcher_req.nodeslot);
                display_nsb_req(prefetcher_vif.nsb_prefetcher_req);
            end
        end
    end
endtask

task display_nsb_req(top_pkg::NSB_PREF_REQ_t pref_req);
    $display("                                              | ----------------------------------------- |");
    $display("                                              | req_opcode         | %-20s | ", pref_req.req_opcode.name());
    $display("                                              | start_address      | %-20h | ", pref_req.start_address);
    $display("                                              | in_features        | %-20d | ", pref_req.in_features);
    $display("                                              | out_features       | %-20d | ", pref_req.out_features);
    $display("                                              | nodeslot           | %-20d | ", pref_req.nodeslot);
    $display("                                              | nodeslot_precision | %-20s | ", pref_req.nodeslot_precision.name());
    $display("                                              | neighbour_count    | %-20d | ", pref_req.neighbour_count);
    $display("                                              | ----------------------------------------- |");
endtask

endclass