
import top_pkg::*;
import tb_utils::*;
import noc_pkg::*;

class bm_monitor;

virtual bm_interface vif;
Node_Scoreboard sb;

integer x, y;
top_pkg::NODE_PRECISION_e precision;

function new(virtual bm_interface vif, top_pkg::NODE_PRECISION_e precision, integer x, integer y, ref Node_Scoreboard node_scoreboard);
    $display("[TIMESTAMP]: %t, [BM::INFO]: BM monitor instantiated. Co-ordinates: (%0d, %0d), precision: %0s. ", $time, x, y, precision.name());
    this.vif = vif;
    this.sb = node_scoreboard;
endfunction

task main();
    forever begin
        @(posedge vif.core_clk) begin

            // BM -> Router packets
            if (vif.buffer_manager_router_valid) begin
                $display("[TIMESTAMP]: %t, [BM]::INFO: (%0d, %0d) BM is sending %0s flit to destination (%0d, %0d).", $time, x, y, vif.buffer_manager_router_data.flit_label.name(), vif.buffer_manager_router_data.data.head_data.y_dest, vif.buffer_manager_router_data.data.head_data.x_dest);
            end

            // Router -> BM packets
            if (vif.router_buffer_manager_valid && vif.router_buffer_manager_ready) begin
                $display("[TIMESTAMP]: %t, [BM]::INFO: (%0d, %0d) BM is receiving %0s flit from source node (%0d, %0d).", $time, x, y, vif.router_buffer_manager_data.flit_label.name(), vif.router_buffer_manager_data.data.head_data.y_dest, vif.router_buffer_manager_data.data.head_data.x_dest);
            end

        end

    end
endtask

endclass