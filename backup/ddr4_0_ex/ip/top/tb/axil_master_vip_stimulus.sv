
import axi_vip_pkg::*;
import axil_master_vip_pkg::*;
import aggregation_engine_regbank_regs_pkg::*;

`define AXIL_MASTER_VIP_IF top_tb.axil_master_vip_i.inst.IF

module axil_master_vip_stimulus(
    input logic ddr4_c0_init_calib_complete
);

axil_master_vip_mst_t agent;

xil_axi_uint                                             mtestWID;            // Write ID  
bit [63:0]                                               mtestWData;         // Write Data

initial begin
    // Initialize AXI-L agent
    agent = new("AXI-L VIP Agent", `AXIL_MASTER_VIP_IF);
    agent.start_master();

    // Wait for DDR4 calibration to complete
    wait(ddr4_c0_init_calib_complete);
    $display("[TIMESTAMP]: %d, DDR4 C0 Calibration Complete", $time);

    $display("[TIMESTAMP]: %d, Begin issuing AXI-L transactions into Aggregation Bank", $time);

    mtestWID = $urandom_range(0,(1<<(0)-1)); 
    mtestWData = $urandom();

    single_axil_write_transaction("Write Matrix A Address",
                                .id(mtestWID),
                                .addr(aggregation_engine_regbank_regs_pkg::MATRIX_A_ADDRESS_OFFSET),
                                .data(mtestWData) );

    $display("[TIMESTAMP]: %d, Issued first AXI-L transaction into Aggregation Bank", $time);

    mtestWID = $urandom_range(0,(1<<(0)-1)); 
    mtestWData = $urandom();
    single_axil_write_transaction("Write Matrix B Address",
                                .id(mtestWID),
                                .addr(aggregation_engine_regbank_regs_pkg::MATRIX_B_ADDRESS_OFFSET),
                                .data(mtestWData) );

    $display("[TIMESTAMP]: %d, Issued second AXI-L transaction into Aggregation Bank", $time);


end

// ========================================================================================
// Utilities
// ========================================================================================

  /************************************************************************************************
  *  task single_axil_write_transaction is to create a single write transaction, fill in transaction 
  *  by using APIs and send it to write driver.
  *   1. declare write transction
  *   2. Create the write transaction
  *   3. set addr, burst,ID,length,size by calling set_write_cmd(addr, burst,ID,length,size), 
  *   4. set prot.lock, cache,region and qos
  *   5. set beats
  *   6. set AWUSER if AWUSER_WIDH is bigger than 0
  *   7. set WUSER if WUSR_WIDTH is bigger than 0
  *************************************************************************************************/
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
    wr_trans = agent.wr_driver.create_transaction(name);
    wr_trans.set_write_cmd(addr,burst,id,len,size);
    wr_trans.set_prot(prot);
    wr_trans.set_lock(lock);
    wr_trans.set_cache(cache);
    wr_trans.set_region(region);
    wr_trans.set_qos(qos);
    wr_trans.set_data_block(data);
    $display("ready to send transaction");
    agent.wr_driver.send(wr_trans);   
    $display("just sent transaction");

endtask  : single_axil_write_transaction

endmodule