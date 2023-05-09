
import axi_vip_pkg::*;
import axil_master_vip_pkg::*;
import axi_memory_master_vip_pkg::*;
import node_scoreboard_regbank_regs_pkg::*;

`define AXIL_MASTER_VIP_IF top_tb.axil_master_vip_i.inst.IF
`define AXI_MEMORY_MASTER_VIP_IF top_tb.axi_memory_master_vip_i.inst.IF

program top_test #(
    parameter CLK_PERIOD = 3332
) (
    // top_memory_axi_interface memory_intf,
    node_scoreboard_interface nsb_intf,
    aggregation_engine_interface age_intf,
    prefetcher_interface prefetcher_intf
);

// AXI master to memory
// logic [3:0]                     top_axi_interconnect_axi_awid; // output
// logic [33:0]                    top_axi_interconnect_axi_awaddr; // output
// logic [7:0]                     top_axi_interconnect_axi_awlen; // output
// logic [2:0]                     top_axi_interconnect_axi_awsize; // output
// logic [1:0]                     top_axi_interconnect_axi_awburst; // output
// logic [0:0]                     top_axi_interconnect_axi_awlock; // output
// logic [3:0]                     top_axi_interconnect_axi_awcache; // output
// logic [2:0]                     top_axi_interconnect_axi_awprot; // output
// logic [3:0]                     top_axi_interconnect_axi_awqos; // output
// logic                           top_axi_interconnect_axi_awvalid; // output
// logic                          top_axi_interconnect_axi_awready; // input
// logic [511:0]                   top_axi_interconnect_axi_wdata; // output
// logic [63:0]                    top_axi_interconnect_axi_wstrb; // output
// logic                           top_axi_interconnect_axi_wlast; // output
// logic                           top_axi_interconnect_axi_wvalid; // output
// logic                          top_axi_interconnect_axi_wready; // input
// logic [3:0]                    top_axi_interconnect_axi_bid; // input
// logic [1:0]                    top_axi_interconnect_axi_bresp; // input
// logic                          top_axi_interconnect_axi_bvalid; // input
// logic                           top_axi_interconnect_axi_bready; // output
// logic [3:0]                     top_axi_interconnect_axi_arid; // output
// logic [33:0]                    top_axi_interconnect_axi_araddr; // output
// logic [7:0]                     top_axi_interconnect_axi_arlen; // output
// logic [2:0]                     top_axi_interconnect_axi_arsize; // output
// logic [1:0]                     top_axi_interconnect_axi_arburst; // output
// logic [0:0]                     top_axi_interconnect_axi_arlock; // output
// logic [3:0]                     top_axi_interconnect_axi_arcache; // output
// logic [2:0]                     top_axi_interconnect_axi_arprot; // output
// logic [3:0]                     top_axi_interconnect_axi_arqos; // output
// logic                           top_axi_interconnect_axi_arvalid; // output
// logic                          top_axi_interconnect_axi_arready; // input
// logic [3:0]                    top_axi_interconnect_axi_rid; // input
// logic [511:0]                  top_axi_interconnect_axi_rdata; // input
// logic [1:0]                    top_axi_interconnect_axi_rresp; // input
// logic                          top_axi_interconnect_axi_rlast; // input
// logic                          top_axi_interconnect_axi_rvalid; // input
// logic                           top_axi_interconnect_axi_rready; // output

parameter IN_FEATURES = 4;
parameter OUT_FEATURES = 4;

axil_master_vip_mst_t axil_agent;
axi_memory_master_vip_mst_t axi_memory_agent;

// Environment
node_scoreboard_tb_monitor nsb_monitor_i;
aggregation_engine_tb_monitor age_monitor_i;
prefetcher_tb_monitor prefetcher_monitor_i;

logic [33:0] WEIGHTS_DRAM_ADDRESS;

logic [IN_FEATURES-1:0] [OUT_FEATURES-1:0] [31:0] weights;

initial begin

    $display("[TIMESTAMP]: %d, Starting simulation", $time);
    

`ifdef DRAM_MODEL
    // Wait for DDR4 calibration to complete
    wait(ddr4_c0_init_calib_complete);
    $display("[TIMESTAMP]: %d, DDR4 C0 Calibration Complete", $time);
`endif

    // Initialize AXI-L agent
    axil_agent = new("AXI-L VIP Agent", `AXIL_MASTER_VIP_IF);
    axil_agent.start_master();

    // Initialize AXI Memory Master VIP agent
    axi_memory_agent = new("AXI Memory Master VIP Agent", `AXI_MEMORY_MASTER_VIP_IF);
    axi_memory_agent.start_master();

    // Start tests

`ifdef NSB_NODESLOT_PROGRAMMING_TEST
    nsb_nodeslot_programming_test();
`endif

`ifdef MATRIX_MULT_TEST
    matrix_mult_test();
`endif

`ifdef KARATE_TEST
    karate_test();
`endif

end

// Initialize environment
initial begin
    nsb_monitor_i        = new(nsb_intf);
    age_monitor_i        = new(age_intf);
    prefetcher_monitor_i = new(prefetcher_intf);

    // Run monitors
    fork
        nsb_monitor_i.main();
        age_monitor_i.main();
        prefetcher_monitor_i.main();
    join
end

task automatic nsb_nodeslot_programming_test();
    logic [63:0] busy_nodeslots_mask;
    integer chosen_nodeslot;
    axi_transaction mem_init_check_read;
    axi_transaction mem_init_check_read_resp;
    
    // Initialize
    $display("[TIMESTAMP]: %d, Starting Nodeslot Programming Test", $time);
    chosen_nodeslot = 0;
    busy_nodeslots_mask = '0;
    delay(30); // wait reset done (lasts 20 cycles)

    // Program random nodeslots
    repeat (10) begin
        while( (busy_nodeslots_mask != '1) && (busy_nodeslots_mask[chosen_nodeslot] == '1)) chosen_nodeslot = $urandom_range(0, 63);
        busy_nodeslots_mask[chosen_nodeslot] = 1'b1;
        $display("TIMESTAMP: %d, NSB_NODESLOT_PROGRAMMING: Chose Nodeslot %d", $time, chosen_nodeslot);
        program_random_nodeslot(chosen_nodeslot, 64);
    end
endtask

Graph graph;


task automatic matrix_mult_test();
    // TO DO
endtask

task automatic karate_test();
    logic [33:0] adj_list_addr;

    graph = new();

    // Program Nodeslots
    for (int node = 0; node < graph.node_count; node++) begin
        write_nsb_regbank("Define Node ID", NSB_NODESLOT_NODE_ID_OFFSET + node, node); // node x goes into nodeslot x
        write_nsb_regbank("Define Neighbour count", NSB_NODESLOT_NEIGHBOUR_COUNT_OFFSET + node, graph.neighbour_count[node]);
        
        write_nsb_regbank("Define Precision", NSB_NODESLOT_PRECISION_OFFSET + node, '0); // 0 for float (MS2)

        write_nsb_regbank("Define Adjacency List LSB", NSB_NODESLOT_ADJACENCY_LIST_ADDRESS_LSB_OFFSET + node, graph.node_offsets[node]);
        write_nsb_regbank("Define Adjacency List MSB", NSB_NODESLOT_ADJACENCY_LIST_ADDRESS_MSB_OFFSET + node, '0);
        write_nsb_regbank("Define Out Messages LSB", NSB_NODESLOT_OUT_MESSAGES_ADDRESS_LSB_OFFSET + node, graph.out_messages_offset);
        write_nsb_regbank("Define Out Messages MSB", NSB_NODESLOT_OUT_MESSAGES_ADDRESS_MSB_OFFSET + node, '0);
        
        if (node > 31) begin
            write_nsb_regbank("Make Valid (MSB)", NSB_NODESLOT_CONFIG_MAKE_VALID_MSB_OFFSET, (1 << (node % 32)) );
        end else begin
            write_nsb_regbank("Make Valid (LSB)", NSB_NODESLOT_CONFIG_MAKE_VALID_LSB_OFFSET, (1 << node ));
        end
    end

endtask

task program_random_nodeslot (integer nodeslot_id, integer max_neighbour_count);
    write_nsb_regbank("Define Node ID", NSB_NODESLOT_NODE_ID_OFFSET + nodeslot_id, $urandom);
    
    // TO DO: test neighbour counts higher than 64 for MS3
    write_nsb_regbank("Define Neighbour count", NSB_NODESLOT_NEIGHBOUR_COUNT_OFFSET + nodeslot_id, 4);
    
    // TO DO: test other precisions (MS3)
    write_nsb_regbank("Define Precision", NSB_NODESLOT_PRECISION_OFFSET + nodeslot_id, '0); // 0 for float (MS2)

    // Only supporting memory initialization up to 1024 words of 512 bits for now (64kB) - MS2
    write_nsb_regbank("Define Adjacency List LSB", NSB_NODESLOT_ADJACENCY_LIST_ADDRESS_LSB_OFFSET + nodeslot_id, $urandom_range(0, 1024));
    write_nsb_regbank("Define Adjacency List MSB", NSB_NODESLOT_ADJACENCY_LIST_ADDRESS_MSB_OFFSET + nodeslot_id, '0);
    write_nsb_regbank("Define Out Messages LSB", NSB_NODESLOT_OUT_MESSAGES_ADDRESS_LSB_OFFSET + nodeslot_id, $urandom);
    write_nsb_regbank("Define Out Messages MSB", NSB_NODESLOT_OUT_MESSAGES_ADDRESS_MSB_OFFSET + nodeslot_id, $urandom);
    
    if (nodeslot_id > 31) begin
        write_nsb_regbank("Make Valid (MSB)", NSB_NODESLOT_CONFIG_MAKE_VALID_MSB_OFFSET, (1 << (nodeslot_id % 32)) );
    end else begin
        write_nsb_regbank("Make Valid (LSB)", NSB_NODESLOT_CONFIG_MAKE_VALID_LSB_OFFSET, (1 << nodeslot_id ));
    end
endtask

// ========================================================================================
// Utilities
// ========================================================================================

task automatic write_nsb_regbank(
    input string                     name ="single_write",
    input xil_axi_ulong              offset,
    input bit [63:0]                 data = 0
);
    single_axil_write_transaction(name, .id('0),
                                .addr(NODE_SCOREBOARD_REGBANK_DEFAULT_BASEADDR + offset),
                                .data(data));
endtask

task automatic single_axil_write_transaction ( 
    input string                     name ="single_write",
    input xil_axi_uint               id =0, 
    input xil_axi_ulong              addr =0,
    input xil_axi_len_t              len =0, 
    input xil_axi_size_t             size =xil_axi_size_t'(xil_clog2((32)/8)),
    input xil_axi_burst_t            burst =XIL_AXI_BURST_TYPE_FIXED,
    input xil_axi_lock_t             lock = XIL_AXI_ALOCK_NOLOCK,
    input xil_axi_cache_t            cache =0,
    input xil_axi_prot_t             prot =0,
    input xil_axi_region_t           region =0,
    input xil_axi_qos_t              qos =0,
    input xil_axi_data_beat [255:0]  wuser =0, 
    input xil_axi_data_beat          awuser =0,
    input bit [63:0]                 data =0
);

    axi_transaction wr_trans;
    wr_trans = axil_agent.wr_driver.create_transaction(name);
    wr_trans.set_write_cmd(addr,burst,id,len,size);
    wr_trans.set_prot(prot);
    wr_trans.set_lock(lock);
    wr_trans.set_cache(cache);
    wr_trans.set_region(region);
    wr_trans.set_qos(qos);
    wr_trans.set_data_block(data);
    axil_agent.wr_driver.send(wr_trans);   

endtask  : single_axil_write_transaction

task automatic delay(input integer cycles);
   repeat(cycles) @(posedge nsb_intf.core_clk);
endtask

endprogram