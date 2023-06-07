
import top_pkg::*;
import tb_utils::*;

class agc_monitor;

virtual agc_interface vif;
Node_Scoreboard sb;

integer x, y;
top_pkg::NODE_PRECISION_e precision;

function new(virtual agc_interface vif, top_pkg::NODE_PRECISION_e precision, integer x, integer y, ref Node_Scoreboard node_scoreboard);
    $display("[TIMESTAMP]: %t, [AGC::INFO]: AGC monitor instantiated. Co-ordinates: (%0d, %0d), precision: %0s. ", $time, x, y, precision.name());
    this.vif = vif;
    this.sb = node_scoreboard;
endfunction

task main();
    forever begin
        @(posedge vif.core_clk) begin

            // AGC -> Router packets
            if (vif.aggregation_core_router_valid) begin
                $display("[TIMESTAMP]: %t, [AGC]::INFO: (%0d, %0d) AGC is sending %0s flit to destination (%0d, %0d).", $time, x, y, vif.aggregation_core_router_data.flit_label.name(), vif.aggregation_core_router_data.data.head_data.y_dest, vif.aggregation_core_router_data.data.head_data.x_dest);
            end

            // Router -> AGC packets
            if (vif.router_aggregation_core_valid && vif.router_aggregation_core_ready) begin
                $display("[TIMESTAMP]: %t, [AGC]::INFO: (%0d, %0d) AGC is receiving %0s flit from source node (%0d, %0d).", $time, x, y, vif.router_aggregation_core_data.flit_label.name(), vif.router_aggregation_core_data.data.head_data.y_dest, vif.router_aggregation_core_data.data.head_data.x_dest);
            end

        end

    end
endtask

endclass