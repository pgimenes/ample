
program top_test #(
    parameter CLK_PERIOD = 3332
) (
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
        graph_test.run_test();
        graph_test.start_environment();
    join
`endif

end

// task automatic nsb_nodeslot_programming_test();
//     logic [63:0] busy_nodeslots_mask;
//     integer chosen_nodeslot;
    
//     // Initialize
//     $display("[TIMESTAMP]: %d, Starting Nodeslot Programming Test", $time);
//     chosen_nodeslot = 0;
//     busy_nodeslots_mask = '0;
//     delay(30); // wait reset done (lasts 20 cycles)

//     // Program random nodeslots
//     repeat (10) begin
//         while( (busy_nodeslots_mask != '1) && (busy_nodeslots_mask[chosen_nodeslot] == '1)) chosen_nodeslot = $urandom_range(0, 63);
//         busy_nodeslots_mask[chosen_nodeslot] = 1'b1;
//         $display("TIMESTAMP: %d, NSB_NODESLOT_PROGRAMMING: Chose Nodeslot %d", $time, chosen_nodeslot);
//         program_random_nodeslot(chosen_nodeslot, 64);
//     end
// endtask

// ========================================================================================
// Utilities
// ========================================================================================

task automatic delay(input integer cycles);
   repeat(cycles) @(posedge nsb_intf.core_clk);
endtask

endprogram