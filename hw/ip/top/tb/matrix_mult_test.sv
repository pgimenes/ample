
import axi_vip_pkg::*;
import axil_master_vip_pkg::*;
import axi_memory_master_vip_pkg::*;
import node_scoreboard_regbank_regs_pkg::*;

`define AXIL_MASTER_VIP_IF top_tb.axil_master_vip_i.inst.IF
`define AXI_MEMORY_MASTER_VIP_IF top_tb.axi_memory_master_vip_i.inst.IF

program matrix_mult_test #(
    parameter CLK_PERIOD = 3332
) (
    // top_memory_axi_interface memory_intf,
    node_scoreboard_interface nsb_intf
);

// AXI master to memory
logic [3:0]                     top_axi_interconnect_axi_awid; // output
logic [33:0]                    top_axi_interconnect_axi_awaddr; // output
logic [7:0]                     top_axi_interconnect_axi_awlen; // output
logic [2:0]                     top_axi_interconnect_axi_awsize; // output
logic [1:0]                     top_axi_interconnect_axi_awburst; // output
logic [0:0]                     top_axi_interconnect_axi_awlock; // output
logic [3:0]                     top_axi_interconnect_axi_awcache; // output
logic [2:0]                     top_axi_interconnect_axi_awprot; // output
logic [3:0]                     top_axi_interconnect_axi_awqos; // output
logic                           top_axi_interconnect_axi_awvalid; // output
logic                          top_axi_interconnect_axi_awready; // input
logic [511:0]                   top_axi_interconnect_axi_wdata; // output
logic [63:0]                    top_axi_interconnect_axi_wstrb; // output
logic                           top_axi_interconnect_axi_wlast; // output
logic                           top_axi_interconnect_axi_wvalid; // output
logic                          top_axi_interconnect_axi_wready; // input
logic [3:0]                    top_axi_interconnect_axi_bid; // input
logic [1:0]                    top_axi_interconnect_axi_bresp; // input
logic                          top_axi_interconnect_axi_bvalid; // input
logic                           top_axi_interconnect_axi_bready; // output
logic [3:0]                     top_axi_interconnect_axi_arid; // output
logic [33:0]                    top_axi_interconnect_axi_araddr; // output
logic [7:0]                     top_axi_interconnect_axi_arlen; // output
logic [2:0]                     top_axi_interconnect_axi_arsize; // output
logic [1:0]                     top_axi_interconnect_axi_arburst; // output
logic [0:0]                     top_axi_interconnect_axi_arlock; // output
logic [3:0]                     top_axi_interconnect_axi_arcache; // output
logic [2:0]                     top_axi_interconnect_axi_arprot; // output
logic [3:0]                     top_axi_interconnect_axi_arqos; // output
logic                           top_axi_interconnect_axi_arvalid; // output
logic                          top_axi_interconnect_axi_arready; // input
logic [3:0]                    top_axi_interconnect_axi_rid; // input
logic [511:0]                  top_axi_interconnect_axi_rdata; // input
logic [1:0]                    top_axi_interconnect_axi_rresp; // input
logic                          top_axi_interconnect_axi_rlast; // input
logic                          top_axi_interconnect_axi_rvalid; // input
logic                           top_axi_interconnect_axi_rready; // output

parameter IN_FEATURES = 4;
parameter OUT_FEATURES = 4;

axil_master_vip_mst_t axil_agent;
axi_memory_master_vip_mst_t axi_memory_agent;

// Environment
node_scoreboard_tb_monitor nsb_monitor_i;

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

`ifdef MATRIX_MULT_TEST
    matrix_mult_test();
`endif

`ifdef NSB_NODESLOT_PROGRAMMING_TEST
    nsb_nodeslot_programming_test();
`endif
end

initial begin
    // Initialize environment
    nsb_monitor_i = new(nsb_intf);

    // Run monitors
    fork
        nsb_monitor_i.main();
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
    delay(10); // wait reset done

    // Read memory contents to check initialization
    // read_transaction(.rd_trans(mem_init_check_read));
    // send_wait_rd(
    //     .rd_trans           (mem_init_check_read),
    //     .return_trans       (mem_init_check_read_resp)
    // );

    // $display("[TIMESTAMP]: %d, Memory Initialization Check read: %h", $time, mem_init_check_read_resp.get_data_beat(0));

    // Program random nodeslots
    repeat (10) begin
        while( (busy_nodeslots_mask != '1) && (busy_nodeslots_mask[chosen_nodeslot] == '1)) chosen_nodeslot = $urandom_range(0, 63);
        busy_nodeslots_mask[chosen_nodeslot] = 1'b1;
        $display("TIMESTAMP: %d, NSB_NODESLOT_PROGRAMMING: Chose Nodeslot %d", $time, chosen_nodeslot);
        program_random_nodeslot(chosen_nodeslot);
    end

endtask

task program_random_nodeslot (integer nodeslot_id);
    write_nsb_regbank("Define Node ID", NSB_NODESLOT_NODE_ID_OFFSET + nodeslot_id, $urandom);
    write_nsb_regbank("Define Precision", NSB_NODESLOT_PRECISION_OFFSET + nodeslot_id, $urandom);
    write_nsb_regbank("Define Adjacency List LSB", NSB_NODESLOT_ADJACENCY_LIST_ADDRESS_LSB_OFFSET + nodeslot_id, $urandom);
    write_nsb_regbank("Define Adjacency List MSB", NSB_NODESLOT_ADJACENCY_LIST_ADDRESS_MSB_OFFSET + nodeslot_id, $urandom);
    write_nsb_regbank("Define Out Messages LSB", NSB_NODESLOT_OUT_MESSAGES_ADDRESS_LSB_OFFSET + nodeslot_id, $urandom);
    write_nsb_regbank("Define Out Messages MSB", NSB_NODESLOT_OUT_MESSAGES_ADDRESS_MSB_OFFSET + nodeslot_id, $urandom);
    
    if (nodeslot_id > 31) begin
        write_nsb_regbank("Make Valid (MSB)", NSB_NODESLOT_CONFIG_MAKE_VALID_MSB_OFFSET, (1 << (nodeslot_id % 32)) );
    end else begin
        write_nsb_regbank("Make Valid (LSB)", NSB_NODESLOT_CONFIG_MAKE_VALID_LSB_OFFSET, (1 << nodeslot_id ));
    end
endtask

task automatic matrix_mult_test();
    // Define random address for weight memory
    // WEIGHTS_DRAM_ADDRESS = $urandom(45);
    // $display("[TIMESTAMP]: %d, Defined Weights Address as %h", $time, WEIGHTS_DRAM_ADDRESS);
    
    // // randomize weights
    // weights = $urandom(45);
    // $display("[TIMESTAMP]: %d, Defined Weights as:", $time);
    // $display("[ %f, %f, %f, %f ]", weights[0][0], weights[0][1], weights[0][2], weights[0][3]);
    // $display("[ %f, %f, %f, %f ]", weights[1][0], weights[1][1], weights[1][2], weights[1][3]);
    // $display("[ %f, %f, %f, %f ]", weights[2][0], weights[2][1], weights[2][2], weights[2][3]);
    // $display("[ %f, %f, %f, %f ]", weights[3][0], weights[3][1], weights[3][2], weights[3][3]);

    // // ================ UNCOMMENT WHEN VIP WORKING
    // // Write Weights data into DRAM
    // // write_memory_beat ("Write WEIGHTS into memory",
    // //                     .addr(WEIGHTS_DRAM_ADDRESS),
    // //                     .data(weights));
    // // axi_memory_agent.wr_driver.wait_driver_idle();

    // brute_memory_beat(.addr(WEIGHTS_DRAM_ADDRESS),
    //                     .data(weights));

    // $display("[TIMESTAMP]: %d, Wrote weights into memory at address %h", $time, WEIGHTS_DRAM_ADDRESS);

    // $display("[TIMESTAMP]: %d, Begin writing Layer Config into Controller Register Bank", $time);

    // write_nsb_regbank("Define IN_FEATURES", LAYER_IN_FEATURES_OFFSET, 32'd4);
    // write_nsb_regbank("Define OUT_FEATURES", LAYER_OUT_FEATURES_OFFSET, 32'd4);
    // write_nsb_regbank("Define LAYER_PRECISION", LAYER_PRECISION_OFFSET, LAYER_PRECISION_PRECISION_FLOAT32);
    // write_nsb_regbank("Define WEIGHTS_ADDRESS_LSB", LAYER_WEIGHTS_ADDRESS_LSB_OFFSET, WEIGHTS_DRAM_ADDRESS[31:0]);
    // write_nsb_regbank("Define WEIGHTS_ADDRESS_MSB", LAYER_WEIGHTS_ADDRESS_MSB_OFFSET, WEIGHTS_DRAM_ADDRESS[33:32]);

    // // Initialize weight fetching
    // write_nsb_regbank("Pulse to FETCH_WEIGHTS", CTRL_FETCH_LAYER_WEIGHTS_OFFSET, '1);

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

task send_wait_rd(
    input  axi_transaction rd_trans,
    output axi_transaction return_trans
);
    rd_trans.set_driver_return_item_policy(XIL_AXI_PAYLOAD_RETURN);
    axi_memory_agent.rd_driver.send(rd_trans);
    axi_memory_agent.rd_driver.wait_rsp(return_trans);
endtask

task automatic read_transaction ( 
    input string                     name ="single_read",
    input xil_axi_uint               id =0, 
    input xil_axi_ulong              addr =0,
    input xil_axi_len_t              len =0, 
    input xil_axi_size_t             size =xil_axi_size_t'(xil_clog2((512)/8)),
    input xil_axi_burst_t            burst =XIL_AXI_BURST_TYPE_INCR,
    input xil_axi_lock_t             lock =XIL_AXI_ALOCK_NOLOCK ,
    input xil_axi_cache_t            cache =3,
    input xil_axi_prot_t             prot =0,
    input xil_axi_region_t           region =0,
    input xil_axi_qos_t              qos =0,
    input xil_axi_data_beat          aruser =0,

    output axi_transaction           rd_trans
);
    // axi_transaction                               rd_trans;
    rd_trans = axi_memory_agent.rd_driver.create_transaction(name);
    rd_trans.set_read_cmd(addr,burst,id,len,size);
    rd_trans.set_prot(prot);
    rd_trans.set_lock(lock);
    rd_trans.set_cache(cache);
    rd_trans.set_region(region);
    rd_trans.set_qos(qos);
    // axi_memory_agent.rd_driver.send(rd_trans);   
endtask  : read_transaction

task automatic write_memory_beat ( 
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
    input bit [511:0]                data =0
);

    axi_transaction wr_trans;
    wr_trans = axi_memory_agent.wr_driver.create_transaction(name);
    wr_trans.set_write_cmd(addr,burst,id,len,size);
    wr_trans.set_prot(prot);
    wr_trans.set_lock(lock);
    wr_trans.set_cache(cache);
    wr_trans.set_region(region);
    wr_trans.set_qos(qos);
    wr_trans.set_data_block(data);
    axi_memory_agent.wr_driver.send(wr_trans);   

endtask  : write_memory_beat

// task automatic brute_memory_beat ( 
//     input xil_axi_ulong              addr =0,
//     input bit [511:0]                data =0
// );

//     // AW PHASE
//     @(posedge nsb_intf.core_clk) set_aw_fields('1, addr);
//     wait(top_axi_interconnect_axi_awready);
//     @(posedge nsb_intf.core_clk) set_aw_fields('0, '0);
//     delay(2);

//     // W PHASE
//     @(posedge nsb_intf.core_clk) set_w_fields('1, data);
//     wait(top_axi_interconnect_axi_wready);
//     @(posedge nsb_intf.core_clk) set_w_fields('0, '0);
//     delay(2);

//     // B PHASE
//     @(posedge nsb_intf.core_clk) top_axi_interconnect_axi_bready = '1;
//     wait(top_axi_interconnect_axi_bvalid);
//     $display("[TIMESTAMP]: %t, Received BRESP %h for transaction ID %h", $time, top_axi_interconnect_axi_bresp, top_axi_interconnect_axi_bid);
//     assert(top_axi_interconnect_axi_bresp == '0);
//     delay(2);

// endtask  : brute_memory_beat

// task automatic set_aw_fields (input logic valid, input logic [63:0] addr);
//     $display("[TIMESTAMP]: %t, BRUTE_VIP: Writing to addr %h", $time, addr);
//     top_axi_interconnect_axi_awvalid    = valid;
//     top_axi_interconnect_axi_awaddr     = addr;
//     top_axi_interconnect_axi_awid       = '0;
//     top_axi_interconnect_axi_awlen      = '0;
//     top_axi_interconnect_axi_awsize     = '0;
//     top_axi_interconnect_axi_awburst    = '0;
//     top_axi_interconnect_axi_awlock     = '0;
//     top_axi_interconnect_axi_awcache    = '0;
//     top_axi_interconnect_axi_awprot     = '0;
//     top_axi_interconnect_axi_awqos      = '0;
// endtask

// task automatic set_w_fields (input logic valid, input logic [511:0] data);
//     $display("[TIMESTAMP]: %t, BRUTE_VIP: Writing data %h", $time, data);
//     top_axi_interconnect_axi_wstrb      = '1;
//     top_axi_interconnect_axi_wlast      = '1;
//     top_axi_interconnect_axi_wvalid     = valid;
// endtask

task automatic delay(input integer cycles);
   repeat(cycles) @(posedge nsb_intf.core_clk);
endtask

endprogram