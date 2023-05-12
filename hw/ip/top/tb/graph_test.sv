
import json::*;
import node_scoreboard_regbank_regs_pkg::*;
import prefetcher_regbank_regs_pkg::*;
import aggregation_engine_regbank_regs_pkg::*;
import feature_transformation_engine_regbank_regs_pkg::*;

`include "json.svh"

class GraphTest extends Test;

    function new(virtual node_scoreboard_interface nsb_intf, virtual aggregation_engine_interface age_intf, virtual prefetcher_interface prefetcher_intf);
        super.new(nsb_intf, age_intf, prefetcher_intf);
        this.TESTNAME = "GRAPH_TEST";
    endfunction

    task automatic run_test();

        Object root, nodeslots, chosen_node_programming;
        int nodeslot_idx;
        integer chosen_nodeslot;

        root = json::Load("nodeslot_programming.json");
        assert (root!=null) else $fatal(1, "Failed to load JSON file");
        nodeslots = root.getByKey("nodeslots");

        // Program Layer Configuration
        $display("[TIMESTAMP]: %t, [%0s::DEBUG]: Ready to program layer configuration to Prefetcher regbank.", $time, TESTNAME);
        this.write_prefetcher_regbank("Define Feature Count", prefetcher_regbank_regs_pkg::LAYER_CONFIG_IN_FEATURES_OFFSET, 'd4);
        
        $display("[TIMESTAMP]: %t, [%0s::DEBUG]: Ready to program layer configuration to AGE regbank.", $time, TESTNAME);
        this.write_age_regbank("Define Feature Count", aggregation_engine_regbank_regs_pkg::LAYER_CONFIG_IN_FEATURES_OFFSET, 'd4);
        
        $display("[TIMESTAMP]: %t, [%0s::DEBUG]: Ready to program layer configuration to FTE regbank.", $time, TESTNAME);
        this.write_fte_regbank("Define Feature Count", feature_transformation_engine_regbank_regs_pkg::LAYER_CONFIG_IN_FEATURES_OFFSET, 'd4);

        // Program nodeslots from JSON dump
        nodeslot_idx = 0;
        while (nodeslot_idx < nodeslots.size()) begin
            choose_nodeslot(chosen_nodeslot);

            // Get nodeslot from JSON object and display
            chosen_node_programming = new();
            chosen_node_programming = nodeslots.getByIndex(nodeslot_idx);
            
            $display("[TIMESTAMP]: %t, [%0s::INFO]: Ready to program Node ID %0d into Nodeslot %0d.", $time, TESTNAME, chosen_node_programming.getByKey("node_id").asInt(), chosen_nodeslot);

            program_nodeslot(chosen_node_programming, chosen_nodeslot);
            
            nodeslot_idx++;
        end

    endtask

    task automatic choose_nodeslot(output int chosen_nodeslot);
        chosen_nodeslot = 0;
        
        // Wait for a nodeslot to be free
        while (this.busy_nodeslots_mask == '1) begin end

        while( (this.busy_nodeslots_mask[chosen_nodeslot] == '1) ) this.choose_least_significant(this.busy_nodeslots_mask, chosen_nodeslot);
        this.busy_nodeslots_mask[chosen_nodeslot] = 1'b1;
    endtask

    task automatic choose_least_significant (input logic [63:0] busy_nodeslots, output integer chosen_nodeslot);
        for (integer i=0; i < 64; i++) begin
            if (!busy_nodeslots[i]) begin
                chosen_nodeslot = i;
                return;
            end
        end
        chosen_nodeslot = -1;
    endtask

    task automatic program_nodeslot(Object nodeslot, integer chosen_nodeslot);
        integer node_id, neighbour_count;
        string precision;
        integer adjacency_list_address_lsb, adjacency_list_address_msb;
        integer out_messages_address_lsb, out_messages_address_msb;

        // Obtain values from JSON object
        node_id = nodeslot.getByKey("node_id").asInt();
        neighbour_count = nodeslot.getByKey("neighbour_count").asInt();
        adjacency_list_address_lsb = nodeslot.getByKey("adjacency_list_address_lsb").asInt();
        adjacency_list_address_msb = nodeslot.getByKey("adjacency_list_address_msb").asInt();
        out_messages_address_lsb = nodeslot.getByKey("out_messages_address_lsb").asInt();
        out_messages_address_msb = nodeslot.getByKey("out_messages_address_msb").asInt();

        $display("[TIMESTAMP]: %t, [%0s::DEBUG]: Programming node %0d with neighbour_count %0d into nodeslot %0d", $time, TESTNAME, node_id, neighbour_count, chosen_nodeslot);

        this.write_nsb_regbank("Define Node ID",            NSB_NODESLOT_NODE_ID_OFFSET + 4*chosen_nodeslot, node_id); // node x goes into nodeslot x
        this.write_nsb_regbank("Define Neighbour count",    NSB_NODESLOT_NEIGHBOUR_COUNT_OFFSET + 4*chosen_nodeslot, neighbour_count);
        this.write_nsb_regbank("Define Precision",          NSB_NODESLOT_PRECISION_OFFSET + 4*chosen_nodeslot, 0); // 0 for float (MS2)
        this.write_nsb_regbank("Define Adjacency List LSB", NSB_NODESLOT_ADJACENCY_LIST_ADDRESS_LSB_OFFSET + 4*chosen_nodeslot, adjacency_list_address_lsb);
        this.write_nsb_regbank("Define Adjacency List MSB", NSB_NODESLOT_ADJACENCY_LIST_ADDRESS_MSB_OFFSET + 4*chosen_nodeslot, adjacency_list_address_msb);
        this.write_nsb_regbank("Define Out Messages LSB",   NSB_NODESLOT_OUT_MESSAGES_ADDRESS_LSB_OFFSET + 4*chosen_nodeslot, out_messages_address_lsb);
        this.write_nsb_regbank("Define Out Messages MSB",   NSB_NODESLOT_OUT_MESSAGES_ADDRESS_MSB_OFFSET + 4*chosen_nodeslot, out_messages_address_msb);

        if (chosen_nodeslot > 31) begin
            this.write_nsb_regbank("Make Valid (MSB)", NSB_NODESLOT_CONFIG_MAKE_VALID_MSB_OFFSET, (1 << (chosen_nodeslot % 32)) );
        end else begin
            this.write_nsb_regbank("Make Valid (LSB)", NSB_NODESLOT_CONFIG_MAKE_VALID_LSB_OFFSET, (1 << chosen_nodeslot ));
        end

    endtask

    // TO DO: replace with function to generate random JSON nodeslot programming object, then call program_nodeslot
    task program_random_nodeslot (integer nodeslot_id, integer max_neighbour_count);
        this.write_nsb_regbank("Define Node ID", NSB_NODESLOT_NODE_ID_OFFSET + nodeslot_id, $urandom);
        this.write_nsb_regbank("Define Neighbour count", NSB_NODESLOT_NEIGHBOUR_COUNT_OFFSET + nodeslot_id, 4);
        this.write_nsb_regbank("Define Precision", NSB_NODESLOT_PRECISION_OFFSET + nodeslot_id, '0); // 0 for float (MS2)
        this.write_nsb_regbank("Define Adjacency List LSB", NSB_NODESLOT_ADJACENCY_LIST_ADDRESS_LSB_OFFSET + nodeslot_id, $urandom_range(0, 1024));
        this.write_nsb_regbank("Define Adjacency List MSB", NSB_NODESLOT_ADJACENCY_LIST_ADDRESS_MSB_OFFSET + nodeslot_id, '0);
        this.write_nsb_regbank("Define Out Messages LSB", NSB_NODESLOT_OUT_MESSAGES_ADDRESS_LSB_OFFSET + nodeslot_id, $urandom);
        this.write_nsb_regbank("Define Out Messages MSB", NSB_NODESLOT_OUT_MESSAGES_ADDRESS_MSB_OFFSET + nodeslot_id, $urandom);
        
        if (nodeslot_id > 31) begin
            this.write_nsb_regbank("Make Valid (MSB)", NSB_NODESLOT_CONFIG_MAKE_VALID_MSB_OFFSET, (1 << (nodeslot_id % 32)) );
        end else begin
            this.write_nsb_regbank("Make Valid (LSB)", NSB_NODESLOT_CONFIG_MAKE_VALID_LSB_OFFSET, (1 << nodeslot_id ));
        end
    endtask

    task automatic write_nsb_regbank(
        input string                     name ="single_write",
        input xil_axi_ulong              offset,
        input bit [63:0]                 data = 0
    );
        $display("[TIMESTAMP]: %t, [%0s::DEBUG]: Writing to NSB regbank, address: %0x", $time, TESTNAME, offset);
        this.single_axil_write_transaction(name, .id('0),
                                    .addr(NODE_SCOREBOARD_REGBANK_DEFAULT_BASEADDR + offset),
                                    .data(data));
    endtask

    task automatic write_prefetcher_regbank(
        input string                     name ="single_write",
        input xil_axi_ulong              offset,
        input bit [63:0]                 data = 0
    );
        this.single_axil_write_transaction(name, .id('0),
                                    .addr(PREFETCHER_REGBANK_DEFAULT_BASEADDR + offset),
                                    .data(data));
    endtask

    task automatic write_age_regbank(
        input string                     name ="single_write",
        input xil_axi_ulong              offset,
        input bit [63:0]                 data = 0
    );
        this.single_axil_write_transaction(name, .id('0),
                                    .addr(AGGREGATION_ENGINE_REGBANK_DEFAULT_BASEADDR + offset),
                                    .data(data));
    endtask

    task automatic write_fte_regbank(
        input string                     name ="single_write",
        input xil_axi_ulong              offset,
        input bit [63:0]                 data = 0
    );
        this.single_axil_write_transaction(name, .id('0),
                                    .addr(FEATURE_TRANSFORMATION_ENGINE_REGBANK_DEFAULT_BASEADDR + offset),
                                    .data(data));
    endtask

endclass