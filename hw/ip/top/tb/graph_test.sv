
import json::*;
import node_scoreboard_regbank_regs_pkg::*;
import prefetcher_regbank_regs_pkg::*;
import aggregation_engine_regbank_regs_pkg::*;
import feature_transformation_engine_regbank_regs_pkg::*;
import top_pkg::*;

class GraphTest extends Test;

    function new(virtual node_scoreboard_interface nsb_intf,
                    virtual aggregation_engine_interface age_intf,
                    virtual prefetcher_interface prefetcher_intf,

                    virtual agc_allocator_interface agc_allocator_intf
                    // virtual agm_interface agm_intf,
                    // virtual agc_interface agc_intf,
                    // virtual bm_interface bm_intf
    );

        super.new(nsb_intf, age_intf, prefetcher_intf
                    , agc_allocator_intf
                    // , agm_intf
                    // , agc_intf
                    // , bm_intf
        );

        this.TESTNAME = "GRAPH_TEST";
    endfunction

    task automatic run_test();

        Object chosen_node_programming;
        Object layer;
        int nodeslot_idx;
        integer chosen_nodeslot;
        string precision;
        xil_axi_data_beat nodeslots_empty_resp[];

        // System reset drops after regbank reset
        wait(this.nsb_intf.resetn == '1);
        $display("[TIMESTAMP]: %t, [%0s::DEBUG]: Initiating %0s.", $time, TESTNAME, TESTNAME);

        // Load layer configuration
        this.layers = json::Load("layer_config.json");
        assert (this.layers!=null) else $fatal(1, "Failed to load layer configuration from JSON file");
        this.layers = this.layers.getByKey("layers");
        layer = this.layers.getByIndex(0);
        $display("[TIMESTAMP]: %t, [%0s::DEBUG]: Finished loading layer configuration.", $time, TESTNAME);

        program_layer_config(layer);
        this.write_nsb_regbank("Layer Config Valid", node_scoreboard_regbank_regs_pkg::LAYER_CONFIG_VALID_OFFSET, '1);

        // Fetch layer weights for all supported precisions
        req_weight_fetch(top_pkg::FLOAT_32);
        req_weight_fetch(top_pkg::FIXED_8);

        // Load nodeslot programming
        this.nodeslots = json::Load("nodeslot_programming.json");
        assert (this.nodeslots!=null) else $fatal(1, "Failed to load nodeslot programming from JSON file");
        this.nodeslots = this.nodeslots.getByKey("nodeslots");
        $display("[TIMESTAMP]: %t, [%0s::DEBUG]: Finished loading nodeslot programming.", $time, TESTNAME);

        // Program nodeslots from JSON dump
        nodeslot_idx = 0;
        while (nodeslot_idx < this.nodeslots.size()) begin
            // Get nodeslot from JSON object and display
            chosen_node_programming = new();
            chosen_node_programming = this.nodeslots.getByIndex(nodeslot_idx);
            precision = chosen_node_programming.getByKey("precision").asString();
            nodeslot_idx++;

            if (chosen_node_programming.getByKey("neighbour_count").asInt() == 0) begin
                continue;
            end

            choose_nodeslot(precision, chosen_nodeslot);

            this.sb.node_scoreboard[chosen_nodeslot] = chosen_node_programming;
            $display("[TIMESTAMP]: %t, [%0s::INFO]: Ready to program Node ID %0d into Nodeslot %0d.", $time, TESTNAME, chosen_node_programming.getByKey("node_id").asInt(), chosen_nodeslot);
            program_nodeslot(chosen_node_programming, chosen_nodeslot);
            this.busy_nodeslots_mask[chosen_nodeslot] = 1'b1; // Mark nodeslot busy
            
        end

        // Wait for all nodeslots to be finished
        while ('1) begin
            nodeslots_empty_resp[0] = '0;
            this.axil_read(.addr(NODE_SCOREBOARD_REGBANK_DEFAULT_BASEADDR + node_scoreboard_regbank_regs_pkg::STATUS_NODESLOTS_EMPTY_MASK_LSB_OFFSET), .Rdatabeat(nodeslots_empty_resp));
            if (nodeslots_empty_resp[0] == '1) begin
                $display("[TIMESTAMP]: %t, [%0s::DEBUG]: All nodeslots empty, finishing test.", $time, TESTNAME);
                $display("[TIMESTAMP]: %t, [%0s::DEBUG]:    nodeslots_empty: %0h", $time, TESTNAME, nodeslots_empty_resp[0]);
                break;
            end else begin
                $display("[TIMESTAMP]: %t, [%0s::DEBUG]: Test not finished yet, some nodeslots are valid.", $time, TESTNAME);
                $display("[TIMESTAMP]: %t, [%0s::DEBUG]:    nodeslots_empty: %0h", $time, TESTNAME, nodeslots_empty_resp[0]);
            end
            delay(10);
        end

        $finish;

    endtask

    task req_weight_fetch(top_pkg::NODE_PRECISION_e precision);
        xil_axi_data_beat fetch_weights_done_resp[];

        $display("[TIMESTAMP]: %t, [%0s::DEBUG]: Requesting weights fetch for precision: %0s.", $time, TESTNAME, precision.name());
        this.write_nsb_regbank("Set weights fetch precision", node_scoreboard_regbank_regs_pkg::CTRL_FETCH_LAYER_WEIGHTS_PRECISION_OFFSET, precision);
        this.write_nsb_regbank("Fetch Weights", node_scoreboard_regbank_regs_pkg::CTRL_FETCH_LAYER_WEIGHTS_OFFSET, '1);

        // Wait for done flag to be asserted
        fetch_weights_done_resp[0] = '0;
        while ('1) begin

            $display("[TIMESTAMP]: %t, [%0s::DEBUG]: Issuing read to weights fetch done flag.", $time, TESTNAME);
            this.axil_read(.addr(NODE_SCOREBOARD_REGBANK_DEFAULT_BASEADDR + CTRL_FETCH_LAYER_WEIGHTS_DONE_OFFSET), .Rdatabeat(fetch_weights_done_resp));

            if (|fetch_weights_done_resp[0]) begin
                $display("[TIMESTAMP]: %t, [%0s::DEBUG]: Layer weights fetch done for precision: %0s.", $time, TESTNAME, precision.name());
                break;
            end else begin
                $display("[TIMESTAMP]: %t, [%0s::DEBUG]: Prefetcher not yet finished with weight fetching for precision: %0s.", $time, TESTNAME, precision.name());
            end

            this.delay(10);
        end

        $display("[TIMESTAMP]: %t, [%0s::DEBUG]: Acknowledging weights fetch is done for precision: %0s.", $time, TESTNAME, precision.name());
        this.write_nsb_regbank("Ack fetch weights", node_scoreboard_regbank_regs_pkg::CTRL_FETCH_LAYER_WEIGHTS_DONE_ACK_OFFSET, '1);
        this.delay(100);
    endtask

    task automatic program_layer_config (Object layer_config);
    
        // Prefetcher regbank
        $display("[TIMESTAMP]: %t, [%0s::DEBUG]: Ready to program layer configuration to Prefetcher regbank.", $time, TESTNAME);

        this.write_prefetcher_regbank("Define IN Feature Count", prefetcher_regbank_regs_pkg::LAYER_CONFIG_IN_FEATURES_OFFSET, layer_config.getByKey("in_feature_count").asInt());
        this.write_prefetcher_regbank("Define OUT Feature Count", prefetcher_regbank_regs_pkg::LAYER_CONFIG_OUT_FEATURES_OFFSET, layer_config.getByKey("out_feature_count").asInt());
        this.write_prefetcher_regbank("Define Adjacency List Address LSB", prefetcher_regbank_regs_pkg::LAYER_CONFIG_ADJACENCY_LIST_ADDRESS_LSB_OFFSET, layer_config.getByKey("adjacency_list_address").asInt());
        this.write_prefetcher_regbank("Define Adjacency List Address MSB", prefetcher_regbank_regs_pkg::LAYER_CONFIG_ADJACENCY_LIST_ADDRESS_MSB_OFFSET, '0);
        
        this.write_prefetcher_regbank("Define IN Messages Address LSB", prefetcher_regbank_regs_pkg::LAYER_CONFIG_IN_MESSAGES_ADDRESS_LSB_OFFSET, layer_config.getByKey("in_messages_address").asInt());
        this.write_prefetcher_regbank("Define IN Messages Address MSB", prefetcher_regbank_regs_pkg::LAYER_CONFIG_IN_MESSAGES_ADDRESS_MSB_OFFSET, '0);

        this.write_prefetcher_regbank("Define Weights Address LSB", prefetcher_regbank_regs_pkg::LAYER_CONFIG_WEIGHTS_ADDRESS_LSB_OFFSET + 4 * top_pkg::FLOAT_32, layer_config.getByKey("weights_address").asInt());
        this.write_prefetcher_regbank("Define Weights Address MSB", prefetcher_regbank_regs_pkg::LAYER_CONFIG_WEIGHTS_ADDRESS_LSB_OFFSET + 4 * top_pkg::FLOAT_32, '0);

        this.write_prefetcher_regbank("Define Weights Address LSB", prefetcher_regbank_regs_pkg::LAYER_CONFIG_WEIGHTS_ADDRESS_LSB_OFFSET + 4 * top_pkg::FIXED_8, layer_config.getByKey("weights_address").asInt());
        this.write_prefetcher_regbank("Define Weights Address MSB", prefetcher_regbank_regs_pkg::LAYER_CONFIG_WEIGHTS_ADDRESS_LSB_OFFSET + 4 * top_pkg::FIXED_8, '0);

        // AGE regbank
        $display("[TIMESTAMP]: %t, [%0s::DEBUG]: Ready to program layer configuration to AGE regbank.", $time, TESTNAME);

        this.write_age_regbank("Define IN Feature Count", aggregation_engine_regbank_regs_pkg::LAYER_CONFIG_IN_FEATURES_OFFSET, layer_config.getByKey("in_feature_count").asInt());
        this.write_age_regbank("Define OUT Feature Count", aggregation_engine_regbank_regs_pkg::LAYER_CONFIG_OUT_FEATURES_OFFSET, layer_config.getByKey("out_feature_count").asInt());
        
        // FTE regbank
        $display("[TIMESTAMP]: %t, [%0s::DEBUG]: Ready to program layer configuration to FTE regbank.", $time, TESTNAME);

        this.write_fte_regbank("Define IN Feature Count", feature_transformation_engine_regbank_regs_pkg::LAYER_CONFIG_IN_FEATURES_OFFSET, layer_config.getByKey("in_feature_count").asInt());
        this.write_fte_regbank("Define OUT Feature Count", feature_transformation_engine_regbank_regs_pkg::LAYER_CONFIG_OUT_FEATURES_OFFSET, layer_config.getByKey("out_feature_count").asInt());

        // NSB regbank
        // NSB Layer configuration
        $display("[TIMESTAMP]: %t, [%0s::DEBUG]: Ready to program layer configuration to NSB regbank.", $time, TESTNAME);

        this.write_nsb_regbank("Define Feature Count", node_scoreboard_regbank_regs_pkg::LAYER_CONFIG_IN_FEATURES_OFFSET, layer_config.getByKey("in_feature_count").asInt());
        this.write_nsb_regbank("Define Feature Count", node_scoreboard_regbank_regs_pkg::LAYER_CONFIG_OUT_FEATURES_OFFSET, layer_config.getByKey("out_feature_count").asInt());
        
        // Addresses
        this.write_nsb_regbank("Define Adjacency List Address LSB", node_scoreboard_regbank_regs_pkg::LAYER_CONFIG_ADJACENCY_LIST_ADDRESS_LSB_OFFSET, layer_config.getByKey("adjacency_list_address").asInt());
        this.write_nsb_regbank("Define Adjacency List Address MSB", node_scoreboard_regbank_regs_pkg::LAYER_CONFIG_ADJACENCY_LIST_ADDRESS_MSB_OFFSET, '0);
        this.write_nsb_regbank("Define IN Messages Address LSB", node_scoreboard_regbank_regs_pkg::LAYER_CONFIG_IN_MESSAGES_ADDRESS_LSB_OFFSET, layer_config.getByKey("in_messages_address").asInt());
        this.write_nsb_regbank("Define IN Messages Address MSB", node_scoreboard_regbank_regs_pkg::LAYER_CONFIG_IN_MESSAGES_ADDRESS_MSB_OFFSET, '0);

        // FLOAT_32 address
        this.write_nsb_regbank("Define Weights Address LSB", node_scoreboard_regbank_regs_pkg::LAYER_CONFIG_WEIGHTS_ADDRESS_LSB_OFFSET, layer_config.getByKey("weights_address").asInt());
        this.write_nsb_regbank("Define Weights Address MSB", node_scoreboard_regbank_regs_pkg::LAYER_CONFIG_WEIGHTS_ADDRESS_MSB_OFFSET, '0);
        // FIXED_8 address
        this.write_nsb_regbank("Define Weights Address LSB", node_scoreboard_regbank_regs_pkg::LAYER_CONFIG_WEIGHTS_ADDRESS_LSB_OFFSET + 4 * top_pkg::FIXED_8, layer_config.getByKey("weights_address").asInt());
        this.write_nsb_regbank("Define Weights Address MSB", node_scoreboard_regbank_regs_pkg::LAYER_CONFIG_WEIGHTS_ADDRESS_MSB_OFFSET + 4 * top_pkg::FIXED_8, '0);

        this.write_nsb_regbank("Define OUT Messages Address LSB", node_scoreboard_regbank_regs_pkg::LAYER_CONFIG_OUT_MESSAGES_ADDRESS_LSB_OFFSET, layer_config.getByKey("out_messages_address").asInt());
        this.write_nsb_regbank("Define OUT Messages Address MSB", node_scoreboard_regbank_regs_pkg::LAYER_CONFIG_OUT_MESSAGES_ADDRESS_MSB_OFFSET, '0);

        this.write_nsb_regbank("Define Aggregation Wait Count", node_scoreboard_regbank_regs_pkg::NSB_CONFIG_AGGREGATION_WAIT_COUNT_OFFSET, layer_config.getByKey("aggregation_wait_count").asInt());
        this.write_nsb_regbank("Define Transformation Wait Count", node_scoreboard_regbank_regs_pkg::NSB_CONFIG_TRANSFORMATION_WAIT_COUNT_OFFSET, layer_config.getByKey("transformation_wait_count").asInt());
    endtask

    task automatic choose_nodeslot(input string precision, output int chosen_nodeslot);
        logic [63:0] busy_nodeslots_precision;

        busy_nodeslots_precision = '1;
        chosen_nodeslot = 0;
        
        // Wait for a nodeslot to be free
        while (busy_nodeslots_precision == '1) begin
            // Precision filter
            if (precision == "FLOAT_32") begin
                busy_nodeslots_precision = {{56{1'b1}}, this.busy_nodeslots_mask[7:0]};
            end else begin
                busy_nodeslots_precision = {{48{1'b1}}, this.busy_nodeslots_mask[15:8], {8{1'b1}}};
            end
        end

        while( (busy_nodeslots_precision[chosen_nodeslot]) ) this.choose_least_significant(busy_nodeslots_precision, chosen_nodeslot);
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

    function automatic int get_precision(string precision_str);
        case (precision_str)
            "FLOAT_32": return 0;
            "FIXED_8": return 1;
            "FIXED_16": return 2;
            "FIXED_4": return 3;
            default: return -1;
        endcase
    endfunction

    function automatic int get_aggregation_function(string func);
        case (func)
            "SUM": return 0;
            "MEAN": return 1;
            "WEIGHTED_SUM": return 2;
            "RESERVED": return 3;
            default: return -1;
        endcase
    endfunction

    task automatic program_nodeslot(Object nodeslot, integer chosen_nodeslot);
        integer node_id, neighbour_count;
        string precision;
        integer adjacency_list_address_lsb, adjacency_list_address_msb;
        integer scale_factors_address_lsb, scale_factors_address_msb;
        integer out_messages_address_lsb, out_messages_address_msb;

        // Obtain values from JSON object
        node_id = nodeslot.getByKey("node_id").asInt();
        neighbour_count = nodeslot.getByKey("neighbour_count").asInt();
        
        adjacency_list_address_lsb = nodeslot.getByKey("adjacency_list_address_lsb").asInt();
        adjacency_list_address_msb = nodeslot.getByKey("adjacency_list_address_msb").asInt();
        
        scale_factors_address_lsb = nodeslot.getByKey("scale_factors_address_lsb").asInt();
        scale_factors_address_msb = nodeslot.getByKey("scale_factors_address_msb").asInt();
        
        out_messages_address_lsb = nodeslot.getByKey("out_messages_address_lsb").asInt();
        out_messages_address_msb = nodeslot.getByKey("out_messages_address_msb").asInt();

        $display("[TIMESTAMP]: %t, [%0s::DEBUG]: Programming node %0d with neighbour_count %0d into nodeslot %0d", $time, TESTNAME, node_id, neighbour_count, chosen_nodeslot);

        this.write_nsb_regbank("Define Node ID",            NSB_NODESLOT_NODE_ID_OFFSET + 4*chosen_nodeslot, node_id); // node x goes into nodeslot x
        this.write_nsb_regbank("Define Neighbour count",    NSB_NODESLOT_NEIGHBOUR_COUNT_OFFSET + 4*chosen_nodeslot, neighbour_count);
        this.write_nsb_regbank("Define Precision",          NSB_NODESLOT_PRECISION_OFFSET + 4*chosen_nodeslot, this.get_precision(nodeslot.getByKey("precision").asString()));
        this.write_nsb_regbank("Define Aggregation Function", NSB_NODESLOT_AGGREGATION_FUNCTION_OFFSET + 4*chosen_nodeslot, this.get_aggregation_function(nodeslot.getByKey("aggregation_function").asString()));
        
        this.write_nsb_regbank("Define Adjacency List LSB", NSB_NODESLOT_ADJACENCY_LIST_ADDRESS_LSB_OFFSET + 4*chosen_nodeslot, adjacency_list_address_lsb);
        this.write_nsb_regbank("Define Adjacency List MSB", NSB_NODESLOT_ADJACENCY_LIST_ADDRESS_MSB_OFFSET + 4*chosen_nodeslot, adjacency_list_address_msb);
        
        this.write_nsb_regbank("Define Scale Factors Address LSB", NSB_NODESLOT_SCALE_FACTORS_ADDRESS_LSB_OFFSET + 4*chosen_nodeslot, scale_factors_address_lsb);
        this.write_nsb_regbank("Define Scale Factors Address MSB", NSB_NODESLOT_SCALE_FACTORS_ADDRESS_MSB_OFFSET + 4*chosen_nodeslot, scale_factors_address_msb);
        
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
        this.axil_write(name, .id('0),
                            .addr(NODE_SCOREBOARD_REGBANK_DEFAULT_BASEADDR + offset),
                            .data(data));
        $display("[TIMESTAMP]: %t, [%0s::DEBUG]: NSB REGBANK: Sent write: %s.", $time, TESTNAME, name);
    endtask

    task automatic write_prefetcher_regbank(
        input string                     name ="single_write",
        input xil_axi_ulong              offset,
        input bit [63:0]                 data = 0
    );
        this.axil_write(name, .id('0),
                            .addr(PREFETCHER_REGBANK_DEFAULT_BASEADDR + offset),
                            .data(data));
        $display("[TIMESTAMP]: %t, [%0s::DEBUG]: PREFETCHER REGBANK: Sent write: %s.", $time, TESTNAME, name);
    endtask

    task automatic write_age_regbank(
        input string                     name ="single_write",
        input xil_axi_ulong              offset,
        input bit [63:0]                 data = 0
    );
        this.axil_write(name, .id('0),
                            .addr(AGGREGATION_ENGINE_REGBANK_DEFAULT_BASEADDR + offset),
                            .data(data));
        $display("[TIMESTAMP]: %t, [%0s::DEBUG]: AGE REGBANK: Sent write: %s.", $time, TESTNAME, name);
    endtask

    task automatic write_fte_regbank(
        input string                     name ="single_write",
        input xil_axi_ulong              offset,
        input bit [63:0]                 data = 0
    );
        this.axil_write(name, .id('0),
                            .addr(FEATURE_TRANSFORMATION_ENGINE_REGBANK_DEFAULT_BASEADDR + offset),
                            .data(data));
        $display("[TIMESTAMP]: %t, [%0s::DEBUG]: FTE REGBANK: Sent write: %s.", $time, TESTNAME, name);
    endtask

endclass