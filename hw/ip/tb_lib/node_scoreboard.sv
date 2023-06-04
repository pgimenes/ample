import json::*;

class Node_Scoreboard;
    Object node_scoreboard [$];

    function new();
        // Initialize scoreboard
        for (int slot = 0; slot < 64; slot++) begin
            this.node_scoreboard[slot] = this.empty_nodeslot();
        end

    endfunction

    function Object empty_nodeslot();
        json::Object ns = new();
        json::Number zero = new(0);
        json::String empty_string = new("");

        ns.append("node_id", zero);
        ns.append("neighbour_count", zero);
        ns.append("precision", empty_string);
        ns.append("aggregation_function", empty_string);
        ns.append("adjacency_list_address_lsb", zero);
        ns.append("adjacency_list_address_msb", zero);
        ns.append("scale_factors_address_lsb", zero);
        ns.append("scale_factors_address_msb", zero);
        ns.append("out_messages_address_lsb", zero);
        ns.append("out_messages_address_msb", zero);

        return ns;
      endfunction
endclass