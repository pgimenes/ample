
// import axi_vip_pkg::*;
// import axil_master_vip_pkg::*;
// // import axi_memory_master_vip_pkg::*;
// import node_scoreboard_regbank_regs_pkg::*;

// `define AXIL_MASTER_VIP_IF top_tb.axil_master_vip_i.inst.IF
// // `define AXI_MEMORY_MASTER_VIP_IF top_tb.axi_memory_master_vip_i.inst.IF

// module nsb_nodeslot_programming_test ( input logic ddr4_c0_init_calib_complete );

// parameter CLK_PERIOD = 3332;

// axil_master_vip_mst_t axil_agent;
// // axi_memory_master_vip_mst_t axi_memory_agent;

// logic [33:0] WEIGHTS_DRAM_ADDRESS;

// logic [IN_FEATURES-1:0] [OUT_FEATURES-1:0] [31:0] weights;

// initial begin
//     // Initialize AXI-L agent
//     axil_agent = new("AXI-L VIP Agent", `AXIL_MASTER_VIP_IF);
//     axil_agent.start_master();
//     run_test();

// end

// task automatic run_test();
//     delay(5);
//     write_nsb_regbank("Define Nodeslot neighbour count", NSB_NODESLOT_NEIGHBOUR_COUNT_OFFSET, 32'd45);
// endtask

// // ========================================================================================
// // Utilities
// // ========================================================================================

// task automatic write_nsb_regbank(
//     input string                     name ="single_write",
//     input xil_axi_ulong              offset,
//     input bit [63:0]                 data = 0
// );
//     single_axil_write_transaction(name, .id('0),
//                                 .addr(CONTROLLER_REGBANK_DEFAULT_BASEADDR + offset),
//                                 .data(data));
// endtask

//   /************************************************************************************************
//   *  task single_axil_write_transaction is to create a single write transaction, fill in transaction 
//   *  by using APIs and send it to write driver.
//   *   1. declare write transction
//   *   2. Create the write transaction
//   *   3. set addr, burst,ID,length,size by calling set_write_cmd(addr, burst,ID,length,size), 
//   *   4. set prot.lock, cache,region and qos
//   *   5. set beats
//   *   6. set AWUSER if AWUSER_WIDH is bigger than 0
//   *   7. set WUSER if WUSR_WIDTH is bigger than 0
//   *************************************************************************************************/
// task automatic single_axil_write_transaction ( 
//     input string                     name ="single_write",
//     input xil_axi_uint               id =0, 
//     input xil_axi_ulong              addr =0,
//     input xil_axi_len_t              len =0, 
//     input xil_axi_size_t             size =xil_axi_size_t'(xil_clog2((32)/8)),
//     input xil_axi_burst_t            burst =XIL_AXI_BURST_TYPE_FIXED,
//     input xil_axi_lock_t             lock = XIL_AXI_ALOCK_NOLOCK,
//     input xil_axi_cache_t            cache =0,
//     input xil_axi_prot_t             prot =0,
//     input xil_axi_region_t           region =0,
//     input xil_axi_qos_t              qos =0,
//     input xil_axi_data_beat [255:0]  wuser =0, 
//     input xil_axi_data_beat          awuser =0,
//     input bit [63:0]                 data =0
// );

//     axi_transaction wr_trans;
//     wr_trans = axil_agent.wr_driver.create_transaction(name);
//     wr_trans.set_write_cmd(addr,burst,id,len,size);
//     wr_trans.set_prot(prot);
//     wr_trans.set_lock(lock);
//     wr_trans.set_cache(cache);
//     wr_trans.set_region(region);
//     wr_trans.set_qos(qos);
//     wr_trans.set_data_block(data);
//     axil_agent.wr_driver.send(wr_trans);   

// endtask  : single_axil_write_transaction

// task automatic delay(input integer cycles);
//    repeat(cycles) #(CLK_PERIOD);
// endtask

// endmodule