
import top_pkg::*;
import tb_utils::*;
import noc_pkg::*;

class agm_monitor;

virtual agm_interface vif;
Node_Scoreboard sb;

integer x, y;
top_pkg::NODE_PRECISION_e precision;

function new(virtual agm_interface vif, top_pkg::NODE_PRECISION_e precision, integer x, integer y, ref Node_Scoreboard node_scoreboard);
    $display("[TIMESTAMP]: %t, [AGM::INFO]: AGM monitor instantiated. Co-ordinates: (%0d, %0d), precision: %0s. ", $time, x, y, precision.name());
    this.vif = vif;
    this.precision = precision;
    this.sb = node_scoreboard;
    this.x = x;
    this.y = y;
endfunction

task main();
    forever begin
        @(posedge vif.core_clk) begin

            // AGC Allocation requests
            if (vif.age_aggregation_manager_req_valid && vif.age_aggregation_manager_req_ready) begin
                $display("[TIMESTAMP]: %t, [AGM]::INFO: (%0d, %0d) AGM is accepting aggregation request for NS%0d with %0s precision.", $time, x, y, vif.age_aggregation_manager_req.nsb_req.nodeslot, this.precision);
            end

            // Done response
            if (vif.aggregation_manager_age_done_valid && vif.aggregation_manager_age_done_ready) begin
                $display("[TIMESTAMP]: %t, [AGM]::INFO: (%0d, %0d) AGM is issuing done response for aggregation of NS%0d with %0s precision.", $time, x, y, vif.agm_allocation.nodeslot, this.precision);
            end

            // Buffer Manager cross-allocation
            if (vif.age_aggregation_manager_buffer_manager_allocation_valid && vif.age_aggregation_manager_buffer_manager_allocation_ready) begin
                $display("[TIMESTAMP]: %t, [AGM]::INFO: (%0d, %0d) AGM is accepting allocation to BM %0d.", $time, x, y, vif.age_aggregation_manager_buffer_manager_allocation);
            end

            // Message Channel requests
            if (vif.message_channel_req_valid && vif.message_channel_req_ready) begin
                $display("[TIMESTAMP]: %t, [AGM]::INFO: (%0d, %0d) AGM is requesting features from Fetch Tag %0d.", $time, x, y, vif.message_channel_req.fetch_tag);
            end

            // Message Channel responses
            if (vif.message_channel_resp_valid && vif.message_channel_resp_ready) begin
                $display("[TIMESTAMP]: %t, [AGM]::INFO: (%0d, %0d) AGM receiving feature beat from Fetch Tag %0d.", $time, x, y, vif.message_channel_req.fetch_tag);
            end

            // AGM -> Router packets
            if (vif.aggregation_manager_router_valid) begin
                $display("[TIMESTAMP]: %t, [AGM]::INFO: (%0d, %0d) AGM is sending %0s flit to destination (%0d, %0d).", $time, x, y, vif.aggregation_manager_router_data.flit_label.name(), vif.aggregation_manager_router_data.data.head_data.y_dest, vif.aggregation_manager_router_data.data.head_data.x_dest);
            end

            // Router -> AGM packets
            if (vif.router_aggregation_manager_valid && vif.router_aggregation_manager_ready) begin
                $display("[TIMESTAMP]: %t, [AGM]::INFO: (%0d, %0d) AGM is receiving %0s flit from source node (%0d, %0d).", $time, x, y, vif.router_aggregation_manager_data.flit_label.name(), vif.router_aggregation_manager_data.data.head_data.y_dest, vif.router_aggregation_manager_data.data.head_data.x_dest);
            end

            // Scale factor queue interface
            if (vif.scale_factor_queue_pop) begin
                $display("[TIMESTAMP]: %t, [AGM]::INFO: (%0d, %0d) AGM has popped scale factor queue element with data %0h.", $time, x, y, vif.router_aggregation_manager_data.flit_label.name(), vif.scale_factor_queue_out_data);
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