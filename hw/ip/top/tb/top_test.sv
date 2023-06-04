
program top_test (
    // top_memory_axi_interface memory_intf,
    node_scoreboard_interface nsb_intf,
    aggregation_engine_interface age_intf,
    prefetcher_interface prefetcher_intf
);

GraphTest graph_test;

initial begin

    // Run tests

`ifdef NSB_NODESLOT_PROGRAMMING_TEST
    nsb_nodeslot_programming_test();
`endif

`ifdef MATRIX_MULT_TEST
    matrix_mult_test();
`endif

`ifdef GRAPH_TEST
    graph_test = new(nsb_intf, age_intf, prefetcher_intf);
    fork
        graph_test.start_environment();
        graph_test.run_test();
    join
`endif

end

// ========================================================================================
// Utilities
// ========================================================================================

task automatic delay(input integer cycles);
   repeat(cycles) @(posedge nsb_intf.core_clk);
endtask

endprogram