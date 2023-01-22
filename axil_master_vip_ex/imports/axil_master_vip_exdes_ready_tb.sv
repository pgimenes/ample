/************************************************************************************************
* Description: 
* This file contains example test lists for one design which consistes of one AXI VIP
* in master mode, one AXI VIP in passthrough mode and one AXI VIP in slave mode.
* Ready signals of write command channel,write data channel, write response channel,read command
* channel and read data channel are generated independently from axi_transaction. The axi_ready_gen
* is the class used for ready generation. Please refer PG267 about READY Generation section for 
* more details.
* Once ready policy is being created, it won't change until user change the ready policy. 

* The main purpose in this example design is to demonstrate how to generate noback pressure ready 
* patterns being followed by random policy in AXI Master/Slave/PASSTHROUGH VIP, other ready 
* signals can be generated similarly.
* 
* It also has two simple scoreboards to do self-checking. One scoreboard checks master AXI VIP against
* passthrough AXI VIP and the other scoreboard checks slave AXI VIP against passthrough AXI VIP
***********************************************************************************************/

`timescale 1ns / 1ps
// import package 
import axi_vip_pkg::*;
import ex_sim_axi_vip_mst_0_pkg::*;
import ex_sim_axi_vip_slv_0_pkg::*;
import ex_sim_axi_vip_passthrough_0_pkg::*;

module axil_master_vip_exdes_ready_tb(
  );

  typedef enum {
    EXDES_PASSTHROUGH,
    EXDES_PASSTHROUGH_MASTER,
    EXDES_PASSTHROUGH_SLAVE
  } exdes_passthrough_t;

  exdes_passthrough_t                     exdes_state = EXDES_PASSTHROUGH;

  //Simple loop integer
  integer                                 i; 
  // Simple loop integer. 
  integer                                 j; 
  // Error count to check how many comparison failed
  xil_axi_uint                            error_cnt = 0; 
  // Comparison count to check how many comparsion happened
  xil_axi_uint                            comparison_cnt = 0;

  axi_transaction                                          wr_trans;            // Write transaction
  axi_transaction                                          rd_trans;            // Read transaction
  xil_axi_uint                                             mtestWID;            // Write ID  
  xil_axi_ulong                                            mtestWADDR;          // Write ADDR  
  xil_axi_len_t                                            mtestWBurstLength;   // Write Burst Length   
  xil_axi_size_t                                           mtestWDataSize;      // Write SIZE  
  xil_axi_burst_t                                          mtestWBurstType;     // Write Burst Type  
  xil_axi_uint                                             mtestRID;            // Read ID  
  xil_axi_ulong                                            mtestRADDR;          // Read ADDR  
  xil_axi_len_t                                            mtestRBurstLength;   // Read Burst Length   
  xil_axi_size_t                                           mtestRDataSize;      // Read SIZE  
  xil_axi_burst_t                                          mtestRBurstType;     // Read Burst Type  

  /*************************************************************************************************  
  * the following monitor transactions are for simple scoreboards doing self-checking
  * two Scoreboards are built here
  * one scoreboard checks master vip against passthrough VIP (scoreboard 1)
  * the other one checks passthrough VIP against slave VIP (scoreboard 2)
  * monitor transaction from master VIP
  ***********************************************************************************************/
  axi_monitor_transaction                 mst_monitor_transaction;
  axi_monitor_transaction                 master_moniter_transaction_queue[$];
  xil_axi_uint                            master_moniter_transaction_queue_size =0;
  axi_monitor_transaction                 mst_scb_transaction;
  axi_monitor_transaction                 passthrough_monitor_transaction;
  axi_monitor_transaction                 passthrough_master_moniter_transaction_queue[$];
  xil_axi_uint                            passthrough_master_moniter_transaction_queue_size =0;
  axi_monitor_transaction                 passthrough_mst_scb_transaction;
  axi_monitor_transaction                 passthrough_slave_moniter_transaction_queue[$];
  xil_axi_uint                            passthrough_slave_moniter_transaction_queue_size =0;
  axi_monitor_transaction                 passthrough_slv_scb_transaction;
  axi_monitor_transaction                 slv_monitor_transaction;
  axi_monitor_transaction                 slave_moniter_transaction_queue[$];
  xil_axi_uint                            slave_moniter_transaction_queue_size =0;
  axi_monitor_transaction                 slv_scb_transaction;
  /*************************************************************************************************  
  * verbosity level which specifies how much debug information to produce
  * 0       - No information will be printed out.
  * 400      - All information will be printed out.
  * master VIP agent verbosity level
  ***********************************************************************************************/
  xil_axi_uint                           mst_agent_verbosity = 0;
  xil_axi_uint                           mem_agent_verbosity = 0;
  xil_axi_uint                           passthrough_agent_verbosity = 0;
  /*************************************************************************************************  
  * Parameterized agents which customer needs to declare according to AXI VIP configuration
  * If AXI VIP is being configured in master mode, axi_mst_agent has to declared 
  * If AXI VIP is being configured in slave mode, axi_mem_agent has to be declared 
  * If AXI VIP is being configured in pass-through mode, axi_passthrough_agent has to be declared
  * "component_name"_mst_t for master agent
  * "component_name"_slv_t for slave agent
  * "component_name"_passthrough_t for passthrough agent
  * "component_name can be easily found in vivado bd design: click on the instance, 
  * then click CONFIG under Properties window and Component_Name will be shown
  * more details please refer PG267 for more details
  ***********************************************************************************************/
  ex_sim_axi_vip_mst_0_mst_t                                      mst_agent;
  ex_sim_axi_vip_slv_0_slv_mem_t                                  mem_agent;
  ex_sim_axi_vip_passthrough_0_passthrough_mem_t                  passthrough_mem_agent;

  
     
  // Clock signal
  bit                                     clock;
  // Reset signal
  bit                                     reset;

  // instantiate bd
    chip DUT(
        .aresetn(reset),
  
      .aclk(clock)
    );

  initial begin
    reset <= 1'b1;
    repeat (5) @(negedge clock);
  end
  
  always #10 clock <= ~clock;

  //Main process
  initial begin
    // create master and slave monitor transaction
    mst_monitor_transaction = new("master monitor transaction");
    slv_monitor_transaction = new("slave monitor transaction");
    /*************************************************************************************************  
    * The hierarchy path of the AXI VIP's interface is passed to the agent when it is newed. 
    * Method to find the hierarchy path of AXI VIP is to run simulation without agents being newed, 
    * message like "Xilinx AXI VIP Found at Path: my_ip_exdes_ready_tb.DUT.ex_design.axi_vip_mst.inst" will 
    * be printed out.
    ***********************************************************************************************/
    mst_agent = new("master vip agent",DUT.ex_design.axi_vip_mst.inst.IF);
    mem_agent = new("slave vip agent with memory model",DUT.ex_design.axi_vip_slv.inst.IF);
    passthrough_mem_agent = new("passthrough vip agent with memory model",DUT.ex_design.axi_vip_passthrough.inst.IF);
    $timeformat (-12, 1, " ps", 1);
    /*************************************************************************************************  
    * set tag for agents for easy debug,if not set here, it will be hard to tell which driver is filing 
    * if multiple agents are called in one testbench
    ***********************************************************************************************/
    mst_agent.set_agent_tag("Master VIP");
    mem_agent.set_agent_tag("Slave VIP");
    passthrough_mem_agent.set_agent_tag("Passthrough VIP");
    // set print out verbosity level.
    mst_agent.set_verbosity(mst_agent_verbosity);
    mem_agent.set_verbosity(mem_agent_verbosity);
    passthrough_mem_agent.set_verbosity(passthrough_agent_verbosity);
    /*************************************************************************************************  
    * master,slave agents start to run 
    * turn monitor on passthrough agent
    ***********************************************************************************************/
    mst_agent.start_master();
    mem_agent.start_slave();
    passthrough_mem_agent.start_monitor();
    /*************************************************************************************************  
    * parallel process 
    * 1. Master VIP create write/read transaction,
    * 2. Master VIP and Slave VIP generate no backpressure signals.
    *  2.1 generate an no backpressure arready signal  
    *  2.2 generate an no backpressure awready signal  
    *  2.3 generate an no backpressure wready signal  
    *  2.4 generate an no backpressure rready signal  
    *  2.5 generate an no backpressure bready signal  
    ***********************************************************************************************/
    slv_no_backpressure_readies();
    mst_no_backpressure_readies();
    fork
 
      begin
        mtestWID = $urandom_range(0,(1<<(0)-1)); 
        mtestWADDR = 0;
        mtestWBurstLength = 0;
        mtestWDataSize = xil_axi_size_t'(xil_clog2((32)/8));
        mtestWBurstType = XIL_AXI_BURST_TYPE_INCR;
        //multiple write transactions with the same inline randomization 
        multiple_write_transaction_partial_rand(.num_xfer(10),
                                              .start_addr(mtestWADDR),
                                              .id(mtestWID),
                                              .len(mtestWBurstLength),
                                              .size(mtestWDataSize),
                                              .burst(mtestWBurstType),
                                              .no_xfer_delays(1)
                                             );
       end
 
      begin
        mtestRID = $urandom_range(0,(1<<(0)-1));
        mtestRADDR = $urandom_range(0,(1<<(32)-1));
        mtestRBurstLength = 0;
        mtestRDataSize = xil_axi_size_t'(xil_clog2((32)/8)); 
        mtestRBurstType = XIL_AXI_BURST_TYPE_INCR;
        multiple_read_transaction_partial_rand( .num_xfer(10),
                                                .start_addr(mtestRADDR),
                                                .id(mtestRID),
                                                .len(mtestRBurstLength),
                                                .size(mtestRDataSize),
                                                .burst(mtestRBurstType),
                                                .no_xfer_delays(1)
                                               ); 
      end  
  
    join
    mst_agent.wait_drivers_idle();

    /*************************************************************************************************  
    * Change READY POLICY
    * parallel process 
    * 1. Master VIP create write/read transaction,
    * 2. Master VIP and Slave VIP generate randomized ready signals.
    *  2.1 generate an randomized arready signal  
    *  2.2 generate an randomized awready signal  
    *  2.3 generate an randomized wready signal  
    *  2.4 generate an randomized rready signal  
    *  2.5 generate an randomized bready signal  
    ***********************************************************************************************/

    slv_random_backpressure_readies();
    
    fork
 
       begin
         mtestWID = $urandom_range(0,(1<<(0)-1)); 
         mtestWADDR = 0;
         mtestWBurstLength = 0;
         mtestWDataSize = xil_axi_size_t'(xil_clog2((32)/8));
         mtestWBurstType = XIL_AXI_BURST_TYPE_INCR;
         //multiple write transactions with the same inline randomization 
         multiple_write_transaction_partial_rand(.num_xfer(15),
                                                .start_addr(mtestWADDR),
                                                .id(mtestWID),
                                                .len(mtestWBurstLength),
                                                .size(mtestWDataSize),
                                                .burst(mtestWBurstType),
                                                .no_xfer_delays(1)
                                               );
      end
 
      begin
        mtestRID = $urandom_range(0,(1<<(0)-1));
        mtestRADDR = $urandom_range(0,(1<<(32)-1));
        mtestRBurstLength = 0;
        mtestRDataSize = xil_axi_size_t'(xil_clog2((32)/8)); 
        mtestRBurstType = XIL_AXI_BURST_TYPE_INCR;
        multiple_read_transaction_partial_rand( .num_xfer(15),
                                                .start_addr(mtestRADDR),
                                                .id(mtestRID),
                                                .len(mtestRBurstLength),
                                                .size(mtestRDataSize),
                                                .burst(mtestRBurstType),
                                                .no_xfer_delays(1)
                                               ); 
      end  
    join
    mst_agent.wait_drivers_idle();


    /************************************************************************************************* 
    * Change READY POLICY
    * parallel process 
    * 1. Master VIP create write/read transaction,
    * 2. Master VIP and Slave VIP generate no backpressure signals through port.
    *  2.1 generate an no backpressure arready signal through port.  
    *  2.2 generate an no backpressure awready signal through port. 
    *  2.3 generate an no backpressure wready signal through port. 
    *  2.4 generate an no backpressure rready signal through port. 
    *  2.5 generate an no backpressure bready signal through port.
    ***********************************************************************************************/
    slv_no_backpressure_readies_port();
    mst_no_backpressure_readies_port();
    fork
 
      begin
        mtestWID = $urandom_range(0,(1<<(0)-1)); 
        mtestWADDR = 0;
        mtestWBurstLength = 0;
        mtestWDataSize = xil_axi_size_t'(xil_clog2((32)/8));
        mtestWBurstType = XIL_AXI_BURST_TYPE_INCR;
        //multiple write transactions with the same inline randomization 
        multiple_write_transaction_partial_rand(.num_xfer(10),
                                              .start_addr(mtestWADDR),
                                              .id(mtestWID),
                                              .len(mtestWBurstLength),
                                              .size(mtestWDataSize),
                                              .burst(mtestWBurstType),
                                              .no_xfer_delays(1)
                                             );
       end
 
      begin
        mtestRID = $urandom_range(0,(1<<(0)-1));
        mtestRADDR = $urandom_range(0,(1<<(32)-1));
        mtestRBurstLength = 0;
        mtestRDataSize = xil_axi_size_t'(xil_clog2((32)/8)); 
        mtestRBurstType = XIL_AXI_BURST_TYPE_INCR;
        multiple_read_transaction_partial_rand( .num_xfer(10),
                                                .start_addr(mtestRADDR),
                                                .id(mtestRID),
                                                .len(mtestRBurstLength),
                                                .size(mtestRDataSize),
                                                .burst(mtestRBurstType),
                                                .no_xfer_delays(1)
                                               ); 
      end  
  
    join
    mst_agent.wait_drivers_idle();

    /*************************************************************************************************  
    * Change READY POLICY
    * parallel process 
    * 1. Master VIP create write/read transaction,
    * 2. Master VIP and Slave VIP generate randomized signals through port.
    *  2.1 generate an randomized arready signal through port.  
    *  2.2 generate an randomized awready signal through port.  
    *  2.3 generate an randomized wready signal through port. 
    *  2.4 generate an randomized rready signal through port. 
    *  2.5 generate an randomized bready signal through port. 
    ***********************************************************************************************/

    slv_random_backpressure_readies_port();
    mst_random_backpressure_readies_port();
    fork
 
       begin
         mtestWID = $urandom_range(0,(1<<(0)-1)); 
         mtestWADDR = 0;
         mtestWBurstLength = 0;
         mtestWDataSize = xil_axi_size_t'(xil_clog2((32)/8));
         mtestWBurstType = XIL_AXI_BURST_TYPE_INCR;
         //multiple write transactions with the same inline randomization 
         multiple_write_transaction_partial_rand(.num_xfer(15),
                                                .start_addr(mtestWADDR),
                                                .id(mtestWID),
                                                .len(mtestWBurstLength),
                                                .size(mtestWDataSize),
                                                .burst(mtestWBurstType),
                                                .no_xfer_delays(1)
                                               );
      end
 
      begin
        mtestRID = $urandom_range(0,(1<<(0)-1));
        mtestRADDR = $urandom_range(0,(1<<(32)-1));
        mtestRBurstLength = 0;
        mtestRDataSize = xil_axi_size_t'(xil_clog2((32)/8)); 
        mtestRBurstType = XIL_AXI_BURST_TYPE_INCR;
        multiple_read_transaction_partial_rand( .num_xfer(15),
                                                .start_addr(mtestRADDR),
                                                .id(mtestRID),
                                                .len(mtestRBurstLength),
                                                .size(mtestRDataSize),
                                                .burst(mtestRBurstType),
                                                .no_xfer_delays(1)
                                               ); 
      end  
    join
    mst_agent.wait_drivers_idle();

    /*************************************************************************************************  
    * Switch PASSTHROUGH VIP into Runtime master mode
    * parallel process 
    * 1. Passthrough VIP in runtime master mode create write/read transaction,
    * 2. Passthrough VIP in runtime master mode and Slave VIP generate no backpressure signals.
    *  2.1 generate an no backpressure arready signal  
    *  2.2 generate an no backpressure awready signal  
    *  2.3 generate an no backpressure wready signal  
    *  2.4 generate an no backpressure rready signal  
    *  2.5 generate an no backpressure bready signal  
    ***********************************************************************************************/
    axil_master_vip_exdes_ready_tb.DUT.ex_design.axi_vip_passthrough.inst.set_master_mode();
    exdes_state = EXDES_PASSTHROUGH_MASTER;
    passthrough_mem_agent.set_agent_tag("Passthrough VIP in Master mode");
    passthrough_mem_agent.start_master();

    slv_no_backpressure_readies();
    passthrough_runtime_mst_no_backpressure_readies();
    fork
 
      begin
        mtestWID = $urandom_range(0,(1<<(0)-1)); 
        mtestWADDR = 0;
        mtestWBurstLength = 0;
        mtestWDataSize = xil_axi_size_t'(xil_clog2((32)/8));
        mtestWBurstType = XIL_AXI_BURST_TYPE_INCR;
        //multiple write transactions with the same inline randomization 
        passthrough_multiple_write_transaction_partial_rand(.num_xfer(10),
                                              .start_addr(mtestWADDR),
                                              .id(mtestWID),
                                              .len(mtestWBurstLength),
                                              .size(mtestWDataSize),
                                              .burst(mtestWBurstType),
                                              .no_xfer_delays(1)
                                             );
       end
 
      begin
        mtestRID = $urandom_range(0,(1<<(0)-1));
        mtestRADDR = $urandom_range(0,(1<<(32)-1));
        mtestRBurstLength = 0;
        mtestRDataSize = xil_axi_size_t'(xil_clog2((32)/8)); 
        mtestRBurstType = XIL_AXI_BURST_TYPE_INCR;
        passthrough_multiple_read_transaction_partial_rand( .num_xfer(10),
                                                .start_addr(mtestRADDR),
                                                .id(mtestRID),
                                                .len(mtestRBurstLength),
                                                .size(mtestRDataSize),
                                                .burst(mtestRBurstType),
                                                .no_xfer_delays(1)
                                               ); 
      end  
  
    join
    passthrough_mem_agent.wait_mst_drivers_idle();
   
   /*************************************************************************************************  
    * PASSTHROUGH VIP into Runtime master mode
    * Change READY POLICY
    * parallel process 
    * 1. Passthrough VIP in runtime master mode create write/read transaction,
    * 2. Passthrough VIP in runtime master mode and Slave VIP generate randomzied backpressure signals.
    *  2.1 generate an randomzied backpressure arready signal  
    *  2.2 generate an randomzied backpressure awready signal  
    *  2.3 generate an randomzied backpressure wready signal  
    *  2.4 generate an randomzied backpressure rready signal  
    *  2.5 generate an randomzied backpressure bready signal  
    ***********************************************************************************************/

    slv_random_backpressure_readies();
    passthrough_runtime_mst_random_backpressure_readies();
   fork
 
      begin
        mtestWID = $urandom_range(0,(1<<(0)-1)); 
        mtestWADDR = 0;
        mtestWBurstLength = 0;
        mtestWDataSize = xil_axi_size_t'(xil_clog2((32)/8));
        mtestWBurstType = XIL_AXI_BURST_TYPE_INCR;
        //multiple write transactions with the same inline randomization 
        passthrough_multiple_write_transaction_partial_rand(.num_xfer(10),
                                              .start_addr(mtestWADDR),
                                              .id(mtestWID),
                                              .len(mtestWBurstLength),
                                              .size(mtestWDataSize),
                                              .burst(mtestWBurstType),
                                              .no_xfer_delays(1)
                                             );
       end
 
      begin
        mtestRID = $urandom_range(0,(1<<(0)-1));
        mtestRADDR = $urandom_range(0,(1<<(32)-1));
        mtestRBurstLength = 0;
        mtestRDataSize = xil_axi_size_t'(xil_clog2((32)/8)); 
        mtestRBurstType = XIL_AXI_BURST_TYPE_INCR;
        passthrough_multiple_read_transaction_partial_rand( .num_xfer(10),
                                                .start_addr(mtestRADDR),
                                                .id(mtestRID),
                                                .len(mtestRBurstLength),
                                                .size(mtestRDataSize),
                                                .burst(mtestRBurstType),
                                                .no_xfer_delays(1)
                                               ); 
      end  
  
    join
    passthrough_mem_agent.wait_mst_drivers_idle();

    /*************************************************************************************************  
    * PASSTHROUGH VIP into Runtime master mode and Change READY Policy
    * parallel process 
    * 1. Passthrough VIP in runtime master mode create write/read transaction,
    * 2. Passthrough VIP in runtime master mode and Slave VIP generate no backpressure signals through port.
    *  2.1 generate an no backpressure arready signal through port. 
    *  2.2 generate an no backpressure awready signal through port. 
    *  2.3 generate an no backpressure wready signal through port. 
    *  2.4 generate an no backpressure rready signal through port. 
    *  2.5 generate an no backpressure bready signal through port. 
    ***********************************************************************************************/
    slv_no_backpressure_readies_port();
    passthrough_runtime_mst_no_backpressure_readies_port();
    fork
 
      begin
        mtestWID = $urandom_range(0,(1<<(0)-1)); 
        mtestWADDR = 0;
        mtestWBurstLength = 0;
        mtestWDataSize = xil_axi_size_t'(xil_clog2((32)/8));
        mtestWBurstType = XIL_AXI_BURST_TYPE_INCR;
        //multiple write transactions with the same inline randomization 
        passthrough_multiple_write_transaction_partial_rand(.num_xfer(10),
                                              .start_addr(mtestWADDR),
                                              .id(mtestWID),
                                              .len(mtestWBurstLength),
                                              .size(mtestWDataSize),
                                              .burst(mtestWBurstType),
                                              .no_xfer_delays(1)
                                             );
       end
 
      begin
        mtestRID = $urandom_range(0,(1<<(0)-1));
        mtestRADDR = $urandom_range(0,(1<<(32)-1));
        mtestRBurstLength = 0;
        mtestRDataSize = xil_axi_size_t'(xil_clog2((32)/8)); 
        mtestRBurstType = XIL_AXI_BURST_TYPE_INCR;
        passthrough_multiple_read_transaction_partial_rand( .num_xfer(10),
                                                .start_addr(mtestRADDR),
                                                .id(mtestRID),
                                                .len(mtestRBurstLength),
                                                .size(mtestRDataSize),
                                                .burst(mtestRBurstType),
                                                .no_xfer_delays(1)
                                               ); 
      end  
  
    join
    passthrough_mem_agent.wait_mst_drivers_idle();

    /*************************************************************************************************  
    * PASSTHROUGH VIP into Runtime master mode and Change READY Policy
    * parallel process 
    * 1. Passthrough VIP in runtime master mode create write/read transaction,
    * 2. Passthrough VIP in runtime master mode and Slave VIP generate randomized signals through port.
    *  2.1 generate an randomized arready signal through port. 
    *  2.2 generate an randomized awready signal through port. 
    *  2.3 generate an randomized wready signal through port. 
    *  2.4 generate an randomized rready signal through port. 
    *  2.5 generate an randomized bready signal through port. 
    ***********************************************************************************************/

    slv_random_backpressure_readies_port();
    passthrough_runtime_mst_random_backpressure_readies_port();
   fork
 
      begin
        mtestWID = $urandom_range(0,(1<<(0)-1)); 
        mtestWADDR = 0;
        mtestWBurstLength = 0;
        mtestWDataSize = xil_axi_size_t'(xil_clog2((32)/8));
        mtestWBurstType = XIL_AXI_BURST_TYPE_INCR;
        //multiple write transactions with the same inline randomization 
        passthrough_multiple_write_transaction_partial_rand(.num_xfer(10),
                                              .start_addr(mtestWADDR),
                                              .id(mtestWID),
                                              .len(mtestWBurstLength),
                                              .size(mtestWDataSize),
                                              .burst(mtestWBurstType),
                                              .no_xfer_delays(1)
                                             );
       end
 
      begin
        mtestRID = $urandom_range(0,(1<<(0)-1));
        mtestRADDR = $urandom_range(0,(1<<(32)-1));
        mtestRBurstLength = 0;
        mtestRDataSize = xil_axi_size_t'(xil_clog2((32)/8)); 
        mtestRBurstType = XIL_AXI_BURST_TYPE_INCR;
        passthrough_multiple_read_transaction_partial_rand( .num_xfer(10),
                                                .start_addr(mtestRADDR),
                                                .id(mtestRID),
                                                .len(mtestRBurstLength),
                                                .size(mtestRDataSize),
                                                .burst(mtestRBurstType),
                                                .no_xfer_delays(1)
                                               ); 
      end  
  
    join
    passthrough_mem_agent.wait_mst_drivers_idle();


    #1ns;
    if(error_cnt ==0) begin
      $display("EXAMPLE TEST DONE : Test Completed Successfully");
    end else begin  
      $display("EXAMPLE TEST DONE ",$sformatf("Test Failed: %d Comparison Failed", error_cnt));
    end 
    $finish;
  end



  // master vip monitors all the transaction from interface and put then into transaction queue
  initial begin
    forever begin
      mst_agent.monitor.item_collected_port.get(mst_monitor_transaction);
      master_moniter_transaction_queue.push_back(mst_monitor_transaction);
      master_moniter_transaction_queue_size++;
    end  
  end 

  // slave vip monitors all the transaction from interface and put then into transaction queue 
  initial begin
    forever begin
      mem_agent.monitor.item_collected_port.get(slv_monitor_transaction);
      slave_moniter_transaction_queue.push_back(slv_monitor_transaction);
      slave_moniter_transaction_queue_size++;
    end
  end
 
  // passthrough vip monitors all the transaction from interface and put then into transaction queue
  initial begin
    forever begin
      passthrough_mem_agent.monitor.item_collected_port.get(passthrough_monitor_transaction);
      if (exdes_state != EXDES_PASSTHROUGH_SLAVE) begin
        passthrough_master_moniter_transaction_queue.push_back(passthrough_monitor_transaction);
        passthrough_master_moniter_transaction_queue_size++;
      end
      if (exdes_state != EXDES_PASSTHROUGH_MASTER) begin
        passthrough_slave_moniter_transaction_queue.push_back(passthrough_monitor_transaction);
        passthrough_slave_moniter_transaction_queue_size++;
      end
    end  
  end 

  /*************************************************************************************************  
  *simple scoreboard doing self checking 
  *comparing transaction from master VIP monitor with transaction from passsthrough VIP in slave side
  * if they are match, SUCCESS. else, ERROR
  ***********************************************************************************************/
  initial begin
   forever begin
      wait (master_moniter_transaction_queue_size>0 ) begin
        mst_scb_transaction = master_moniter_transaction_queue.pop_front;
        master_moniter_transaction_queue_size--;
        wait( passthrough_slave_moniter_transaction_queue_size>0) begin
          passthrough_slv_scb_transaction = passthrough_slave_moniter_transaction_queue.pop_front;
          passthrough_slave_moniter_transaction_queue_size--;
          if (passthrough_slv_scb_transaction.do_compare(mst_scb_transaction) == 0) begin
            $display("ERROR:  Master VIP against passthrough VIP scoreboard Compare failed");
            error_cnt++;
          end else begin
            $display("SUCCESS: Master VIP against passthrough VIP scoreboard Compare passed");
          end
          comparison_cnt++;
        end  
      end 
    end
  end
 
  /*************************************************************************************************  
  *comparing transaction from passthrough in master side with transaction from Slave VIP 
  * if they are match, SUCCESS. else, ERROR
  ***********************************************************************************************/
  initial begin
    forever begin
      wait (slave_moniter_transaction_queue_size>0 ) begin
        slv_scb_transaction = slave_moniter_transaction_queue.pop_front;
        slave_moniter_transaction_queue_size--;
        wait( passthrough_master_moniter_transaction_queue_size>0) begin
          passthrough_mst_scb_transaction = passthrough_master_moniter_transaction_queue.pop_front;
          passthrough_master_moniter_transaction_queue_size--;
          if (slv_scb_transaction.do_compare(passthrough_mst_scb_transaction) == 0) begin
            $display("ERROR: Slave VIP against passthrough VIP scoreboard Compare failed");
            error_cnt++;
          end else begin
            $display("SUCCESS: Slave VIP against passthrough VIP scoreboard Compare passed");
          end   

          comparison_cnt++;
        end  
      end 
    end
  end

  /*************************************************************************************************  
  * This task is to queue up multiple transactions with the same id, length,size, burst type
  * and incrementd addr with different data in Master VIP. then it send out all these transactions 
  * 1. Declare a handle for write transaction
  * 2. set delay range if user set there transction is of no delay
  * 3. constraint randomize the transaction
  * 4. increment the addr
  * 5. repeat 1-4 to generate num_xfer transaction
  * 6. send out the transaction
  *************************************************************************************************/
  
  task automatic multiple_write_transaction_partial_rand(
                              input xil_axi_uint    num_xfer =1,
                              input xil_axi_ulong   start_addr =0,
                              input xil_axi_uint    id =0,
                              input xil_axi_len_t   len =0,
                              input xil_axi_size_t  size =xil_axi_size_t'(xil_clog2((32)/8)),
                              input xil_axi_burst_t burst = XIL_AXI_BURST_TYPE_INCR,
                              input bit             no_xfer_delays =0  
                                        );
    axi_transaction                                          wr_tran[];
    xil_axi_ulong                                            addr;

    wr_tran =new[num_xfer];
    addr = start_addr;

    // queue up transactions
    for (int i =0; i <num_xfer; i++) begin
      wr_tran[i] = mst_agent.wr_driver.create_transaction($sformatf("write_multiple_transaction id =%0d",i));
      if(no_xfer_delays ==1) begin
        wr_tran[i].set_data_insertion_delay_range(0,0);
        wr_tran[i].set_addr_delay_range(0,0);
        wr_tran[i].set_beat_delay_range(0,0);
      end  
      inline_randomize_transaction(.trans(wr_tran[i]), 
                                   .id_val(id), 
                                   .addr_val(addr),
                                   .len_val(len),
                                   .size_val(size), 
                                   .burst_val(burst));
      addr += wr_tran[i].get_num_bytes_in_transaction();
    end
    //send out transaction
    for (int i =0; i <num_xfer; i++) begin
       mst_agent.wr_driver.send(wr_tran[i]);
    end
  endtask :multiple_write_transaction_partial_rand


  /*************************************************************************************************  
  * This task is to queue up multiple transactions with the same id, length,size, burst type
  * and incrementd addr with different data in Passthrough VIP in runtime master mode.
  * then it send out all these transactions 
  * 1. Declare a handle for write transaction
  * 2. set delay range if user set there transction is of no delay
  * 3. constraint randomize the transaction
  * 4. increment the addr
  * 5. repeat 1-4 to generate num_xfer transaction
  * 6. send out the transaction
  *************************************************************************************************/
  
  task automatic passthrough_multiple_write_transaction_partial_rand(
                              input xil_axi_uint    num_xfer =1,
                              input xil_axi_ulong   start_addr =0,
                              input xil_axi_uint    id =0,
                              input xil_axi_len_t   len =0,
                              input xil_axi_size_t  size =xil_axi_size_t'(xil_clog2((32)/8)),
                              input xil_axi_burst_t burst = XIL_AXI_BURST_TYPE_INCR,
                              input bit             no_xfer_delays =0  
                                        );
    axi_transaction                                          wr_tran[];
    xil_axi_ulong                                            addr;

    wr_tran =new[num_xfer];
    addr = start_addr;

    // queue up transactions
    for (int i =0; i <num_xfer; i++) begin
      wr_tran[i] = passthrough_mem_agent.mst_wr_driver.create_transaction($sformatf("write_multiple_transaction id =%0d",i));
      if(no_xfer_delays ==1) begin
        wr_tran[i].set_data_insertion_delay_range(0,0);
        wr_tran[i].set_addr_delay_range(0,0);
        wr_tran[i].set_beat_delay_range(0,0);
      end  
      inline_randomize_transaction(.trans(wr_tran[i]), 
                                   .id_val(id), 
                                   .addr_val(addr),
                                   .len_val(len),
                                   .size_val(size), 
                                   .burst_val(burst));
      addr += wr_tran[i].get_num_bytes_in_transaction();
    end
    //send out transaction
    for (int i =0; i <num_xfer; i++) begin
      passthrough_mem_agent.mst_wr_driver.send(wr_tran[i]);
    end
  endtask :passthrough_multiple_write_transaction_partial_rand

  /*************************************************************************************************
  * Partial randomization of transaction
  * This simple task shows paritaly randomize one transaction with fixed value for ID,ADDR,LENGTH,
  * SIZE and BURST.User can following this task and create some other partial randomized transaction
  * Fatal will show up if randomizaiton failed
  * NOTE: Please don't use this task in VIVADO Simulator for it's limitiaton of SV support.
  *************************************************************************************************/

  task automatic inline_randomize_transaction(inout axi_transaction trans,
                                              input xil_axi_uint id_val,
                                              input xil_axi_ulong addr_val,
                                              input xil_axi_len_t len_val,
                                              input xil_axi_size_t size_val,
                                              input xil_axi_burst_t burst_val); 
    if(! ((trans.randomize() with {
         id == id_val; 
         addr==addr_val; 
         len==len_val;
         size ==size_val;
         burst ==burst_val;
     }))) begin
        $fatal(1,"inline_randomize_transaction of %s failed at time =%t",trans.get_name(), $realtime);     
       end
  endtask : inline_randomize_transaction


  /*************************************************************************************************
  * This task is to queue up multiple transactions with the same id, length,size, burst type
  * and incrementd addr with different data in Master VIP. then it send out all these transactions
  * 1. Declare a handle for read transaction
  * 2. set delay range if user set there transction is of no delay
  * 3. constraint randomize the transaction
  * 4. increment the addr
  * 5. repeat 1-4 to generate num_xfer transaction
  * 6. send out the transaction
  *************************************************************************************************/
  
  task automatic multiple_read_transaction_partial_rand(
                              input xil_axi_uint    num_xfer =1,
                              input xil_axi_ulong   start_addr =0,
                              input xil_axi_uint    id =0,
                              input xil_axi_len_t   len =0,
                              input xil_axi_size_t  size =xil_axi_size_t'(xil_clog2((32)/8)),
                              input xil_axi_burst_t burst = XIL_AXI_BURST_TYPE_INCR,
                              input bit             no_xfer_delays =0  
                                        );
    axi_transaction                                          rd_tran[];
    xil_axi_ulong                                            addr;

    rd_tran =new[num_xfer];
    addr = start_addr;

    // queue up transactions
    for (int i =0; i <num_xfer; i++) begin
      rd_tran[i] = mst_agent.rd_driver.create_transaction($sformatf("read_multiple_transaction id =%0d",i));
      if(no_xfer_delays ==1) begin
        rd_tran[i].set_data_insertion_delay_range(0,0);
        rd_tran[i].set_addr_delay_range(0,0);
        rd_tran[i].set_beat_delay_range(0,0);
      end  
      inline_randomize_transaction(.trans(rd_tran[i]), 
                                   .id_val(id), 
                                   .addr_val(addr),
                                   .len_val(len),
                                   .size_val(size), 
                                   .burst_val(burst));
      addr += rd_tran[i].get_num_bytes_in_transaction();
    end
    //send out transaction
    for (int i =0; i <num_xfer; i++) begin
      mst_agent.rd_driver.send(rd_tran[i]);
    end
  endtask :multiple_read_transaction_partial_rand


  /*************************************************************************************************
  * This task is to queue up multiple transactions with the same id, length,size, burst type
  * and incrementd addr with different data in Passthrough VIP in runtime master mode.
  * then it send out all these transactions.
  * 1. Declare a handle for read transaction
  * 2. set delay range if user set there transction is of no delay
  * 3. constraint randomize the transaction
  * 4. increment the addr
  * 5. repeat 1-4 to generate num_xfer transaction
  * 6. send out the transaction
  *************************************************************************************************/
  
  task automatic passthrough_multiple_read_transaction_partial_rand(
                              input xil_axi_uint    num_xfer =1,
                              input xil_axi_ulong   start_addr =0,
                              input xil_axi_uint    id =0,
                              input xil_axi_len_t   len =0,
                              input xil_axi_size_t  size =xil_axi_size_t'(xil_clog2((32)/8)),
                              input xil_axi_burst_t burst = XIL_AXI_BURST_TYPE_INCR,
                              input bit             no_xfer_delays =0  
                                        );
    axi_transaction                                          rd_tran[];
    xil_axi_ulong                                            addr;

    rd_tran =new[num_xfer];
    addr = start_addr;

    // queue up transactions
    for (int i =0; i <num_xfer; i++) begin
      rd_tran[i] = passthrough_mem_agent.mst_rd_driver.create_transaction($sformatf("read_multiple_transaction id =%0d",i));
      if(no_xfer_delays ==1) begin
        rd_tran[i].set_data_insertion_delay_range(0,0);
        rd_tran[i].set_addr_delay_range(0,0);
        rd_tran[i].set_beat_delay_range(0,0);
      end  
      inline_randomize_transaction(.trans(rd_tran[i]), 
                                   .id_val(id), 
                                   .addr_val(addr),
                                   .len_val(len),
                                   .size_val(size), 
                                   .burst_val(burst));
      addr += rd_tran[i].get_num_bytes_in_transaction();
    end
    //send out transaction
    for (int i =0; i <num_xfer; i++) begin
      passthrough_mem_agent.mst_rd_driver.send(rd_tran[i]);
    end
  endtask :passthrough_multiple_read_transaction_partial_rand


/***********************************************************************************************
 
  Collection of policies that describe how the xREADY signals will behave. These policies can 
  introduce backpressure into the system to find design faults.

      XIL_AXI_READY_GEN_NO_BACKPRESSURE    - Ready stays asserted and will not change. The driver
                                             will still check for policy changes.
     XIL_AXI_READY_GEN_SINGLE             - Ready stays 0 for low_time clock cycles and then
                                             drives 1 until one ready/valid handshake occurs,
                                             the policy repeats until the channel is given
                                             different policy.
     XIL_AXI_READY_GEN_EVENTS             - Ready stays 0 for low_time clock cycles and then
                                             drives 1 until event_count ready/valid handshakes
                                             occur,the policy repeats until the channel is given
                                             different policy.
     XIL_AXI_READY_GEN_OSC                - Ready stays 0 for low_time and then goes to 1 and      
                                             stays 1 for high_time,the policy repeats until the
                                             channel is given different policy.
     XIL_AXI_READY_GEN_RANDOM             - This policy generate random ready policy and uses
                                             min/max pair of low_time, high_time and event_count to
                                             generate low_time, high_time and event_count.
     XIL_AXI_READY_GEN_AFTER_VALID_SINGLE - This policy is active when VALID is detected to be
                                             asserted, Ready stays 0 for low_time clock cycles and
                                             then drives 1 until one ready/valid handshake occurs,
                                             the policy repeats until the channel is given
                                             different policy.
     XIL_AXI_READY_GEN_AFTER_VALID_EVENTS - This policy is active when VALID is detected to be
                                             asserted, Ready stays 0 for low_time clock cycles and
                                             then drives 1 until event_count ready/valid handshake
                                             occurs,the policy repeats until the channel is given
                                             different policy.
     XIL_AXI_READY_GEN_AFTER_VALID_OSC    - This policy is active when VALID is detected to be
                                             asserted, Ready stays 0 for low_time and then goes to
                                             1 and stays 1 for high_time,the policy repeats until
                                             the channel is given different policy.
**********************************************************************************************/

  /************************************************************************************************
  * Below are tasks used to generate xREADY signals through
  * 1. construct a axi_ready_gen object
  * 2. Set the ready policy to be XIL_AXI_READY_GEN_NO_BACKPRESSURE 
  * 3. Put the xREADY object into xREADY queue. xREADY pattern keeps the same till xREADY policy is 
  *    being changed
  *************************************************************************************************/

  /**********************************************************************************************************
    slv_no_backpressure_wready :
    1. create a ready class object rgen
    2. set ready policy of this rgen to be XIL_AXI_READY_GEN_NO_BACKPRESSURE
    3. put rgen into wready queue of write driver of Slave VIP, Wready generation is no backpressure till the
       wready policy is being changed.
  **********************************************************************************************************/
  task automatic slv_no_backpressure_wready();
    axi_ready_gen rgen;
    $display("%t,- Applying slv_no_backpressure_wready", $time);

    rgen = new("slv_no_backpressure_wready");
    rgen.set_ready_policy(XIL_AXI_READY_GEN_NO_BACKPRESSURE);
    mem_agent.wr_driver.set_wready_gen(rgen);
  endtask : slv_no_backpressure_wready

  /**********************************************************************************************************
    slv_no_backpressure_awready :
    1. create a ready class object rgen
    2. set ready policy of this rgen to be XIL_AXI_READY_GEN_NO_BACKPRESSURE
    3. put rgen into awready queue of write driver of Slave VIP, AWready generation is no backpressure till the
       awready policy is being changed.
  **********************************************************************************************************/
  task automatic slv_no_backpressure_awready();
    axi_ready_gen rgen;
    $display("%t,- Applying slv_no_backpressure_awready", $time);

    rgen = new("slv_no_backpressure_awready");
    rgen.set_ready_policy(XIL_AXI_READY_GEN_NO_BACKPRESSURE);
    mem_agent.wr_driver.set_awready_gen(rgen);
  endtask : slv_no_backpressure_awready

  /**********************************************************************************************************
    slv_no_backpressure_arready :
    1. create a ready class object rgen
    2. set ready policy of this rgen to be XIL_AXI_READY_GEN_NO_BACKPRESSURE
    3. put rgen into arready queue of read driver of Slave VIP, ARready generation is no backpressure till the
       arready policy is being changed.
  **********************************************************************************************************/
  task automatic slv_no_backpressure_arready();
    axi_ready_gen rgen;
    $display("%t,- Applying slv_no_backpressure_arready", $time);

    rgen = new("slv_no_backpressure_arready");
    rgen.set_ready_policy(XIL_AXI_READY_GEN_NO_BACKPRESSURE);
    mem_agent.rd_driver.set_arready_gen(rgen);
  endtask : slv_no_backpressure_arready

  /**********************************************************************************************************
    slv_no_backpressure_readies :
    set ready policy of awready, wready and arready all to be XIL_AXI_READY_GEN_NO_BACKPRESSURE through 
    putting ready class into ready queue.
  **********************************************************************************************************/
  task automatic slv_no_backpressure_readies();
    slv_no_backpressure_wready();
    slv_no_backpressure_awready();
    slv_no_backpressure_arready();
  endtask  : slv_no_backpressure_readies

  /**********************************************************************************************************
    mst_no_backpressure_rready :
    1. create a ready class object rgen
    2. set ready policy of this rgen to be XIL_AXI_READY_GEN_NO_BACKPRESSURE
    3. put rgen into rready queue of read driver of Master VIP, RRready generation is no backpressure till the
       rready policy is being changed.
  **********************************************************************************************************/
  task automatic mst_no_backpressure_rready();
    axi_ready_gen rgen;
    $display("%t,- Applying mst_no_backpressure_rready", $time);

    rgen = new("mst_no_backpressure_rready");
    rgen.set_ready_policy(XIL_AXI_READY_GEN_NO_BACKPRESSURE);
    mst_agent.rd_driver.set_rready_gen(rgen);
  endtask : mst_no_backpressure_rready

  /**********************************************************************************************************
    mst_no_backpressure_bready :
    1. create a ready class object rgen
    2. set ready policy of this rgen to be XIL_AXI_READY_GEN_NO_BACKPRESSURE
    3. put rgen into bready queue of read driver of Master VIP, BRready generation is no backpressure till the
       bready policy is being changed.
  **********************************************************************************************************/
  task automatic mst_no_backpressure_bready();
    axi_ready_gen rgen;
    $display("%t,- Applying mst_no_backpressure_bready", $time);

    rgen = new("mst_no_backpressure_bready");
    rgen.set_ready_policy(XIL_AXI_READY_GEN_NO_BACKPRESSURE);
    mst_agent.wr_driver.set_bready_gen(rgen);
  endtask : mst_no_backpressure_bready

  /**********************************************************************************************************
    mst_no_backpressure_readies :
    set ready policy of rready and bready all to be XIL_AXI_READY_GEN_NO_BACKPRESSURE  through 
    putting ready class into ready queue.
  **********************************************************************************************************/
  task automatic mst_no_backpressure_readies();
    mst_no_backpressure_bready();
    mst_no_backpressure_rready();
  endtask  : mst_no_backpressure_readies
 
  /**********************************************************************************************************
    passthrough_no_backpressure_wready :
    1. create a ready class object rgen
    2. set ready policy of this rgen to be XIL_AXI_READY_GEN_NO_BACKPRESSURE
    3. put rgen into wready queue of slave write driver of Passthrough VIP, Wready generation is no
       backpressure till the wready policy is being changed.
  **********************************************************************************************************/
  task automatic passthrough_no_backpressure_wready();
    axi_ready_gen rgen;
    $display("%t,- Applying passthrough_no_backpressure_wready", $time);

    rgen = new("passthrough_no_backpressure_wready");
    rgen.set_ready_policy(XIL_AXI_READY_GEN_NO_BACKPRESSURE);
    passthrough_mem_agent.slv_wr_driver.set_wready_gen(rgen);
  endtask : passthrough_no_backpressure_wready

  /**********************************************************************************************************
    passthrough_no_backpressure_awready :
    1. create a ready class object rgen
    2. set ready policy of this rgen to be XIL_AXI_READY_GEN_NO_BACKPRESSURE
    3. put rgen into awready queue of slave write driver of Passthrough VIP, AWready generation is no
       backpressure till the awready policy is being changed.
  **********************************************************************************************************/
  task automatic passthrough_no_backpressure_awready();
    axi_ready_gen rgen;
    $display("%t,- Applying passthrough_no_backpressure_awready", $time);

    rgen = new("passthrough_no_backpressure_awready");
    rgen.set_ready_policy(XIL_AXI_READY_GEN_NO_BACKPRESSURE);
    passthrough_mem_agent.slv_wr_driver.set_awready_gen(rgen);
  endtask : passthrough_no_backpressure_awready

  /**********************************************************************************************************
    passthrough_no_backpressure_arready :
    1. create a ready class object rgen
    2. set ready policy of this rgen to be XIL_AXI_READY_GEN_NO_BACKPRESSURE
    3. put rgen into arready queue of slave read driver of Passthrough VIP, ARready generation is no
       backpressure till the arready policy is being changed.
  **********************************************************************************************************/
  task automatic passthrough_no_backpressure_arready();
    axi_ready_gen rgen;
    $display("%t,- Applying passthrough_no_backpressure_arready", $time);

    rgen = new("passthrough_no_backpressure_arready");
    rgen.set_ready_policy(XIL_AXI_READY_GEN_NO_BACKPRESSURE);
    passthrough_mem_agent.slv_rd_driver.set_arready_gen(rgen);
  endtask : passthrough_no_backpressure_arready

  /**********************************************************************************************************
    passthrough_no_backpressure_rready :
    1. create a ready class object rgen
    2. set ready policy of this rgen to be XIL_AXI_READY_GEN_NO_BACKPRESSURE
    3. put rgen into rready queue of master read driver of Passthrough VIP, Rready generation is no
       backpressure till the rready policy is being changed.
  **********************************************************************************************************/
  task automatic passthrough_no_backpressure_rready();
    axi_ready_gen rgen;
    $display("%t,- Applying passthrough_no_backpressure_rready", $time);

    rgen = new("passthrough_no_backpressure_rready");
    rgen.set_ready_policy(XIL_AXI_READY_GEN_NO_BACKPRESSURE);
    passthrough_mem_agent.mst_rd_driver.set_rready_gen(rgen);
  endtask : passthrough_no_backpressure_rready

  /**********************************************************************************************************
    passthrough_no_backpressure_bready :
    1. create a ready class object rgen
    2. set ready policy of this rgen to be XIL_AXI_READY_GEN_NO_BACKPRESSURE
    3. put rgen into bready queue of master write driver of Passthrough VIP, bready generation is no
       backpressure till the bready policy is being changed.
  **********************************************************************************************************/
  task automatic passthrough_no_backpressure_bready();
    axi_ready_gen rgen;
    $display("%t,- Applying passthrough_no_backpressure_bready", $time);

    rgen = new("passthrough_no_backpressure_bready");
    rgen.set_ready_policy(XIL_AXI_READY_GEN_NO_BACKPRESSURE);
    passthrough_mem_agent.mst_wr_driver.set_bready_gen(rgen);
  endtask : passthrough_no_backpressure_bready


  /**********************************************************************************************************
    passthrough_runtime_mst_no_backpressure_readies :
    set ready policy of rready and bready all to be XIL_AXI_READY_GEN_NO_BACKPRESSURE when Passthrough VIP
    in runtime master mode through putting ready class into ready queue.
  **********************************************************************************************************/
  task automatic passthrough_runtime_mst_no_backpressure_readies();
    passthrough_no_backpressure_bready();
    passthrough_no_backpressure_rready();
  endtask: passthrough_runtime_mst_no_backpressure_readies

  /**********************************************************************************************************
    passthrough_runtime_slv_no_backpressure_readies :
    set ready policy of awready, wready and arready all to be XIL_AXI_READY_GEN_NO_BACKPRESSURE when Passthrough
    VIP in runtime slave mode through putting ready class into ready queue.
  **********************************************************************************************************/
  task automatic passthrough_runtime_slv_no_backpressure_readies();
    passthrough_no_backpressure_wready();
    passthrough_no_backpressure_awready();
    passthrough_no_backpressure_arready();
  endtask: passthrough_runtime_slv_no_backpressure_readies

  /************************************************************************************************
  * Below are tasks used to generate xREADY signals through
  * 1. create an axi_ready_gen object through create_ready API and return its handle back to rgen
  * 2. Set the ready policy of rgen to be XIL_AXI_READY_GEN_NO_BACKPRESSURE
  * 3. Send the xREADY object into xREADY port. xREADY pattern keeps the same till xREADY policy is 
  *    being changed
  *************************************************************************************************/
  
  /**********************************************************************************************************
    slv_no_backpressure_wready_port :
    1. create an axi_ready_gen object through create_ready API and return its handle back to rgen
    2. set ready policy of this rgen to be XIL_AXI_READY_GEN_NO_BACKPRESSURE
    3. Send the WREADY object into WREADY port of write driver of Slave VIP, 
       Wready generation is no backpressure till the wready policy is being changed.
  **********************************************************************************************************/
  task automatic slv_no_backpressure_wready_port();
    axi_ready_gen rgen;
    $display("%t,- Applying slv_no_backpressure_wready_port", $time);

    rgen = mem_agent.wr_driver.create_ready("slv_no_backpressure_wready_port");
    rgen.set_ready_policy(XIL_AXI_READY_GEN_NO_BACKPRESSURE);
    mem_agent.wr_driver.send_wready(rgen);
  endtask : slv_no_backpressure_wready_port

  /**********************************************************************************************************
    slv_no_backpressure_awready_port :
    1. create an axi_ready_gen object through create_ready API and return its handle back to rgen
    2. set ready policy of this rgen to be XIL_AXI_READY_GEN_NO_BACKPRESSURE
    3. Send the AWREADY object into AWREADY port of write driver of Slave VIP, 
       AWready generation is no backpressure till the awready policy is being changed.
  **********************************************************************************************************/
  task automatic slv_no_backpressure_awready_port();
    axi_ready_gen rgen;
    $display("%t,- Applying slv_no_backpressure_awready_port", $time);

    rgen = mem_agent.wr_driver.create_ready("slv_no_backpressure_awready_port");
    rgen.set_ready_policy(XIL_AXI_READY_GEN_NO_BACKPRESSURE);
    mem_agent.wr_driver.send_awready(rgen);
  endtask : slv_no_backpressure_awready_port

  /**********************************************************************************************************
    slv_no_backpressure_arready_port :
    1. create an axi_ready_gen object through create_ready API and return its handle back to rgen
    2. set ready policy of this rgen to be XIL_AXI_READY_GEN_NO_BACKPRESSURE
    3. Send the ARREADY object into ARREADY port of read driver of Slave VIP, 
       ARready generation is no backpressure till the arready policy is being changed.
  **********************************************************************************************************/
  task automatic slv_no_backpressure_arready_port();
    axi_ready_gen rgen;
    $display("%t,- Applying slv_no_backpressure_arready_port", $time);

    rgen = mem_agent.rd_driver.create_ready("slv_no_backpressure_arready_port");
    rgen.set_ready_policy(XIL_AXI_READY_GEN_NO_BACKPRESSURE);
    mem_agent.rd_driver.send_arready(rgen);
  endtask : slv_no_backpressure_arready_port

  /**********************************************************************************************************
    slv_no_backpressure_readies :
    set ready policy of awready, wready and arready all to be XIL_AXI_READY_GEN_NO_BACKPRESSURE and send 
    them to ready ports in Slave VIP
  **********************************************************************************************************/
  task automatic slv_no_backpressure_readies_port();
    slv_no_backpressure_wready_port();
    slv_no_backpressure_awready_port();
    slv_no_backpressure_arready_port();
  endtask  : slv_no_backpressure_readies_port

  /**********************************************************************************************************
    mst_no_backpressure_rready_port :
    1. create an axi_ready_gen object through create_ready API and return its handle back to rgen
    2. set ready policy of this rgen to be XIL_AXI_READY_GEN_NO_BACKPRESSURE
    3. Send the RREADY object into RREADY port of read driver of Master VIP.
       Rready generation is no backpressure till the rready policy is being changed.
  **********************************************************************************************************/
  task automatic mst_no_backpressure_rready_port();
    axi_ready_gen rgen;
    $display("%t,- Applying mst_no_backpressure_rready_port", $time);

    rgen = mst_agent.rd_driver.create_ready("mst_no_backpressure_rready_port");
    rgen.set_ready_policy(XIL_AXI_READY_GEN_NO_BACKPRESSURE);
    mst_agent.rd_driver.send_rready(rgen);
  endtask : mst_no_backpressure_rready_port

  /**********************************************************************************************************
    mst_no_backpressure_bready_port :
    1. create an axi_ready_gen object through create_ready API and return its handle back to rgen
    2. set ready policy of this rgen to be XIL_AXI_READY_GEN_NO_BACKPRESSURE
    3. Send the BREADY object into BREADY port of write driver of Master VIP.
       bready generation is no backpressure till the bready policy is being changed.
  **********************************************************************************************************/
  task automatic mst_no_backpressure_bready_port();
    axi_ready_gen rgen;
    $display("%t,- Applying mst_no_backpressure_bready_port", $time);

    rgen = mst_agent.wr_driver.create_ready("mst_no_backpressure_bready_port");
    rgen.set_ready_policy(XIL_AXI_READY_GEN_NO_BACKPRESSURE);
    mst_agent.wr_driver.send_bready(rgen);
  endtask : mst_no_backpressure_bready_port

  /**********************************************************************************************************
    mst_no_backpressure_readies :
    set ready policy of rready and bready all to be XIL_AXI_READY_GEN_NO_BACKPRESSURE and send 
    them to ready ports in Master VIP
  **********************************************************************************************************/
  task automatic mst_no_backpressure_readies_port();
    mst_no_backpressure_bready_port();
    mst_no_backpressure_rready_port();
  endtask  : mst_no_backpressure_readies_port


  /**********************************************************************************************************
    passthrough_no_backpressure_wready_port :
    1. create an axi_ready_gen object through create_ready API and return its handle back to rgen
    2. set ready policy of this rgen to be XIL_AXI_READY_GEN_NO_BACKPRESSURE
    3. Send the WREADY object into WREADY port of slave write driver of Passthrough VIP, 
       wready generation is no backpressure till the wready policy is being changed.
  **********************************************************************************************************/
  task automatic passthrough_no_backpressure_wready_port();
    axi_ready_gen rgen;
    $display("%t,- Applying passthrough_no_backpressure_wready_port", $time);

    rgen = passthrough_mem_agent.slv_wr_driver.create_ready("passthrough_no_backpressure_wready_port");
    rgen.set_ready_policy(XIL_AXI_READY_GEN_NO_BACKPRESSURE);
    passthrough_mem_agent.slv_wr_driver.send_wready(rgen);
  endtask : passthrough_no_backpressure_wready_port

  /**********************************************************************************************************
    passthrough_no_backpressure_awready_port :
    1. create an axi_ready_gen object through create_ready API and return its handle back to rgen
    2. set ready policy of this rgen to be XIL_AXI_READY_GEN_NO_BACKPRESSURE
    3. Send the WREADY object into WREADY port of slave write driver of Passthrough VIP, 
       awready generation is no backpressure till the awready policy is being changed.
  **********************************************************************************************************/
  task automatic passthrough_no_backpressure_awready_port();
    axi_ready_gen rgen;
    $display("%t,- Applying passthrough_no_backpressure_awready_port", $time);

    rgen = passthrough_mem_agent.slv_wr_driver.create_ready("passthrough_no_backpressure_awready_port");
    rgen.set_ready_policy(XIL_AXI_READY_GEN_NO_BACKPRESSURE);
    passthrough_mem_agent.slv_wr_driver.send_awready(rgen);
  endtask : passthrough_no_backpressure_awready_port

  /**********************************************************************************************************
    passthrough_no_backpressure_arready_port :
    1. create an axi_ready_gen object through create_ready API and return its handle back to rgen
    2. set ready policy of this rgen to be XIL_AXI_READY_GEN_NO_BACKPRESSURE
    3. Send the ARREADY object into ARREADY port of slave read driver of Passthrough VIP, 
       arready generation is no backpressure till the arready policy is being changed.
  **********************************************************************************************************/
  task automatic passthrough_no_backpressure_arready_port();
    axi_ready_gen rgen;
    $display("%t,- Applying passthrough_no_backpressure_arready_port", $time);

    rgen = passthrough_mem_agent.slv_rd_driver.create_ready("passthrough_no_backpressure_arready_port");
    rgen.set_ready_policy(XIL_AXI_READY_GEN_NO_BACKPRESSURE);
    passthrough_mem_agent.slv_rd_driver.send_arready(rgen);
  endtask : passthrough_no_backpressure_arready_port

  /**********************************************************************************************************
    passthrough_no_backpressure_rready_port :
    1. create an axi_ready_gen object through create_ready API and return its handle back to rgen
    2. set ready policy of this rgen to be XIL_AXI_READY_GEN_NO_BACKPRESSURE
    3. Send the RREADY object into RREADY port of master read driver of Passthrough VIP, 
       rready generation is no backpressure till the rready policy is being changed.
  **********************************************************************************************************/
  task automatic passthrough_no_backpressure_rready_port();
    axi_ready_gen rgen;
    $display("%t,- Applying passthrough_no_backpressure_rready_port", $time);

    rgen = passthrough_mem_agent.mst_rd_driver.create_ready("passthrough_no_backpressure_rready_port");
    rgen.set_ready_policy(XIL_AXI_READY_GEN_NO_BACKPRESSURE);
    passthrough_mem_agent.mst_rd_driver.send_rready(rgen);
  endtask : passthrough_no_backpressure_rready_port

  /**********************************************************************************************************
    passthrough_no_backpressure_bready_port :
    1. create an axi_ready_gen object through create_ready API and return its handle back to rgen
    2. set ready policy of this rgen to be XIL_AXI_READY_GEN_NO_BACKPRESSURE
    3. Send the BREADY object into BREADY port of master write driver of Passthrough VIP, 
       bready generation is no backpressure till the bready policy is being changed.
  **********************************************************************************************************/
  task automatic passthrough_no_backpressure_bready_port();
    axi_ready_gen rgen;
    $display("%t,- Applying passthrough_no_backpressure_bready_port", $time);

    rgen = passthrough_mem_agent.mst_wr_driver.create_ready("passthrough_no_backpressure_bready_port");
    rgen.set_ready_policy(XIL_AXI_READY_GEN_NO_BACKPRESSURE);
    passthrough_mem_agent.mst_wr_driver.send_bready(rgen);
  endtask : passthrough_no_backpressure_bready_port

  /**********************************************************************************************************
    passthrough_runtime_mst_no_backpressure_readies :
    set ready policy of rready and bready all to be XIL_AXI_READY_GEN_NO_BACKPRESSURE and send 
    them to ready ports of passthrough VIP in runtime master mode
  **********************************************************************************************************/
  task automatic passthrough_runtime_mst_no_backpressure_readies_port();
    passthrough_no_backpressure_bready_port();
    passthrough_no_backpressure_rready_port();
  endtask: passthrough_runtime_mst_no_backpressure_readies_port

  /**********************************************************************************************************
    passthrough_runtime_mst_no_backpressure_readies :
    set ready policy of wready,awready and arready all to be XIL_AXI_READY_GEN_NO_BACKPRESSURE and send 
    them to ready ports of passthrough VIP in runtime slave mode
  **********************************************************************************************************/
  task automatic passthrough_runtime_slv_no_backpressure_readies_port();
    passthrough_no_backpressure_wready_port();
    passthrough_no_backpressure_awready_port();
    passthrough_no_backpressure_arready_port();
  endtask: passthrough_runtime_slv_no_backpressure_readies_port

  /************************************************************************************************
  * Below are tasks used to generate xREADY signals through
  * 1. construct a axi_ready_gen object
  * 2. Set the ready policy to be XIL_AXI_READY_GEN_RANDOM 
  * 3. Put the xREADY object into xREADY queue. xREADY pattern keeps the same till xREADY policy is 
  *    being changed
  *************************************************************************************************/

  /**********************************************************************************************************
    slv_random_backpressure_wready :
    1. create a ready class object rgen
    2. set ready policy of this rgen to be XIL_AXI_READY_GEN_RANDOM
    3. set low time range, high time range and event count range(low time, high time and events(ready/valid 
       handshake event) will be randomly picked inside these range) of rgen.
    4. put rgen into wready queue of write driver of Slave VIP, wready generation is randomized
       till the wready policy is being changed.
  **********************************************************************************************************/
  task automatic slv_random_backpressure_wready();
    axi_ready_gen rgen;
    $display("%t,- Applying slv_random_backpressure_wready", $time);

    rgen = new("slv_random_backpressure_wready");
    rgen.set_ready_policy(XIL_AXI_READY_GEN_RANDOM);
    rgen.set_low_time_range(0,12);
    rgen.set_high_time_range(1,12);
    rgen.set_event_count_range(3,3);
    mem_agent.wr_driver.set_wready_gen(rgen);
  endtask : slv_random_backpressure_wready

  /**********************************************************************************************************
    slv_random_backpressure_awready :
    1. create a ready class object rgen
    2. set ready policy of this rgen to be XIL_AXI_READY_GEN_RANDOM
    3. set low time range, high time range and event count range(low time, high time and events(ready/valid 
       handshake event) will be randomly picked inside these range) of rgen.
    4. put rgen into awready queue of write driver of Slave VIP, awready generation is randomized
       till the awready policy is being changed.
  **********************************************************************************************************/
  task automatic slv_random_backpressure_awready();
    axi_ready_gen rgen;
    $display("%t,- Applying slv_random_backpressure_awready", $time);

    rgen = new("slv_random_backpressure_awready");
    rgen.set_ready_policy(XIL_AXI_READY_GEN_RANDOM);
    rgen.set_low_time_range(0,12);
    rgen.set_high_time_range(1,12);
    rgen.set_event_count_range(3,3);
    mem_agent.wr_driver.set_awready_gen(rgen);
  endtask : slv_random_backpressure_awready

  /**********************************************************************************************************
    slv_random_backpressure_arready :
    1. create a ready class object rgen
    2. set ready policy of this rgen to be XIL_AXI_READY_GEN_RANDOM
    3. set low time range, high time range and event count range(low time, high time and events(ready/valid 
       handshake event) will be randomly picked inside these range) of rgen.
    4. put rgen into arready queue of read driver of Slave VIP, arready generation is randomized
       till the arready policy is being changed.
  **********************************************************************************************************/
  task automatic slv_random_backpressure_arready();
    axi_ready_gen rgen;
    $display("%t,- Applying slv_random_backpressure_arready", $time);

    rgen = new("slv_random_backpressure_arready");
    rgen.set_ready_policy(XIL_AXI_READY_GEN_RANDOM);
    rgen.set_low_time_range(0,12);
    rgen.set_high_time_range(1,12);
    rgen.set_event_count_range(3,3);
    mem_agent.rd_driver.set_arready_gen(rgen);
  endtask : slv_random_backpressure_arready

  /**********************************************************************************************************
    slv_random_backpressure_readies :
    set ready policy of awready, wready and arready all to be XIL_AXI_READY_GEN_RANDOM,set low time range
    high time range and event count range, then put ready class into ready queueof Slave VIP.
  **********************************************************************************************************/
  task automatic slv_random_backpressure_readies();
    slv_random_backpressure_wready();
    slv_random_backpressure_awready();
    slv_random_backpressure_arready();
  endtask  : slv_random_backpressure_readies

  /**********************************************************************************************************
    mst_random_backpressure_rready :
    1. create a ready class object rgen
    2. set ready policy of this rgen to be XIL_AXI_READY_GEN_RANDOM
    3. set low time range, high time range and event count range(low time, high time and events(ready/valid 
       handshake event) will be randomly picked inside these range) of rgen.
    4. put rgen into rready queue of read driver of Master VIP, rready generation is randomized
       till the rready policy is being changed.
  **********************************************************************************************************/
  task automatic mst_random_backpressure_rready();
    axi_ready_gen rgen;
    $display("%t,- Applying mst_random_backpressure_rready", $time);

    rgen = new("mst_random_backpressure_rready");
    rgen.set_ready_policy(XIL_AXI_READY_GEN_RANDOM);
    rgen.set_low_time_range(0,12);
    rgen.set_high_time_range(1,12);
    rgen.set_event_count_range(3,3);
    mst_agent.rd_driver.set_rready_gen(rgen);
  endtask : mst_random_backpressure_rready

  /**********************************************************************************************************
    mst_random_backpressure_bready :
    1. create a ready class object rgen
    2. set ready policy of this rgen to be XIL_AXI_READY_GEN_RANDOM
    3. set low time range, high time range and event count range(low time, high time and events(ready/valid 
       handshake event) will be randomly picked inside these range) of rgen.
    4. put rgen into bready queue of write driver of Master VIP, bready generation is randomized
       till the bready policy is being changed.
  **********************************************************************************************************/
  task automatic mst_random_backpressure_bready();
    axi_ready_gen rgen;
    $display("%t,- Applying mst_random_backpressure_bready", $time);

    rgen = new("mst_random_backpressure_bready");
    rgen.set_ready_policy(XIL_AXI_READY_GEN_RANDOM);
    rgen.set_low_time_range(0,12);
    rgen.set_high_time_range(1,12);
    rgen.set_event_count_range(3,3);
    mst_agent.wr_driver.set_bready_gen(rgen);
  endtask : mst_random_backpressure_bready

  /**********************************************************************************************************
    mst_random_backpressure_readies :
    set ready policy of bready, rready to be XIL_AXI_READY_GEN_RANDOM,set low time range
    high time range and event count range, then put ready class into ready queue of Master VIP.
  **********************************************************************************************************/
  task automatic mst_random_backpressure_readies();
    mst_random_backpressure_bready();
    mst_random_backpressure_rready();
  endtask  : mst_random_backpressure_readies

  /**********************************************************************************************************
    passthrough_random_backpressure_wready :
    1. create a ready class object rgen
    2. set ready policy of this rgen to be XIL_AXI_READY_GEN_RANDOM
    3. set low time range, high time range and event count range(low time, high time and events(ready/valid 
       handshake event) will be randomly picked inside these range) of rgen.
    4. put rgen into wready queue of slave write driver of Passthrough VIP, wready generation is randomized
       till the wready policy is being changed.
  **********************************************************************************************************/
  task automatic passthrough_random_backpressure_wready();
    axi_ready_gen rgen;
    $display("%t,- Applying passthrough_random_backpressure_wready", $time);

    rgen = new("passthrough_random_backpressure_wready");
    rgen.set_ready_policy(XIL_AXI_READY_GEN_RANDOM);
    rgen.set_low_time_range(0,12);
    rgen.set_high_time_range(1,12);
    rgen.set_event_count_range(3,3);
    passthrough_mem_agent.slv_wr_driver.set_wready_gen(rgen);
  endtask : passthrough_random_backpressure_wready

  /**********************************************************************************************************
    passthrough_random_backpressure_awready :
    1. create a ready class object rgen
    2. set ready policy of this rgen to be XIL_AXI_READY_GEN_RANDOM
    3. set low time range, high time range and event count range(low time, high time and events(ready/valid 
       handshake event) will be randomly picked inside these range) of rgen.
    4. put rgen into awready queue of slave write driver of Passthrough VIP, awready generation is randomized
       till the awready policy is being changed.
  **********************************************************************************************************/
  task automatic passthrough_random_backpressure_awready();
    axi_ready_gen rgen;
    $display("%t,- Applying passthrough_random_backpressure_awready", $time);

    rgen = new("passthrough_random_backpressure_awready");
    rgen.set_ready_policy(XIL_AXI_READY_GEN_RANDOM);
    rgen.set_low_time_range(0,12);
    rgen.set_high_time_range(1,12);
    rgen.set_event_count_range(3,3);
    passthrough_mem_agent.slv_wr_driver.set_awready_gen(rgen);
  endtask : passthrough_random_backpressure_awready

  /**********************************************************************************************************
    passthrough_random_backpressure_arready :
    1. create a ready class object rgen
    2. set ready policy of this rgen to be XIL_AXI_READY_GEN_RANDOM
    3. set low time range, high time range and event count range(low time, high time and events(ready/valid 
       handshake event) will be randomly picked inside these range) of rgen.
    4. put rgen into arready queue of slave read driver of Passthrough VIP, arready generation is randomized
       till the arready policy is being changed.
  **********************************************************************************************************/
  task automatic passthrough_random_backpressure_arready();
    axi_ready_gen rgen;
    $display("%t,- Applying passthrough_random_backpressure_arready", $time);

    rgen = new("passthrough_random_backpressure_arready");
    rgen.set_ready_policy(XIL_AXI_READY_GEN_RANDOM);
    rgen.set_low_time_range(0,12);
    rgen.set_high_time_range(1,12);
    rgen.set_event_count_range(3,3);
    passthrough_mem_agent.slv_rd_driver.set_arready_gen(rgen);
  endtask : passthrough_random_backpressure_arready

  /**********************************************************************************************************
    passthrough_random_backpressure_rready :
    1. create a ready class object rgen
    2. set ready policy of this rgen to be XIL_AXI_READY_GEN_RANDOM
    3. set low time range, high time range and event count range(low time, high time and events(ready/valid 
       handshake event) will be randomly picked inside these range) of rgen.
    4. put rgen into rready queue of master read driver of Passthrough VIP, rready generation is randomized
       till the rready policy is being changed.
  **********************************************************************************************************/
  task automatic passthrough_random_backpressure_rready();
    axi_ready_gen rgen;
    $display("%t,- Applying mst_random_backpressure_rready", $time);

    rgen = new("passthrough_random_backpressure_rready");
    rgen.set_ready_policy(XIL_AXI_READY_GEN_RANDOM);
    rgen.set_low_time_range(0,12);
    rgen.set_high_time_range(1,12);
    rgen.set_event_count_range(3,3);
    passthrough_mem_agent.mst_rd_driver.set_rready_gen(rgen);
  endtask : passthrough_random_backpressure_rready

  /**********************************************************************************************************
    passthrough_random_backpressure_bready :
    1. create a ready class object rgen
    2. set ready policy of this rgen to be XIL_AXI_READY_GEN_RANDOM
    3. set low time range, high time range and event count range(low time, high time and events(ready/valid 
       handshake event) will be randomly picked inside these range) of rgen.
    4. put rgen into bready queue of master write driver of Passthrough VIP, bready generation is randomized
       till the bready policy is being changed.
  **********************************************************************************************************/
  task automatic passthrough_random_backpressure_bready();
    axi_ready_gen rgen;
    $display("%t,- Applying passthrough_random_backpressure_bready", $time);

    rgen = new("passthrough_random_backpressure_bready");
    rgen.set_ready_policy(XIL_AXI_READY_GEN_RANDOM);
    rgen.set_low_time_range(0,12);
    rgen.set_high_time_range(1,12);
    rgen.set_event_count_range(3,3);
    passthrough_mem_agent.mst_wr_driver.set_bready_gen(rgen);
  endtask : passthrough_random_backpressure_bready

  /**********************************************************************************************************
    passthrough_runtime_mst_random_backpressure_readies :
    set ready policy of bready, rready to be XIL_AXI_READY_GEN_RANDOM,set low time range
    high time range and event count range, then put ready class into ready queue of Passthrough VIP in
    runtime master mode.
  **********************************************************************************************************/
  task automatic passthrough_runtime_mst_random_backpressure_readies();
    passthrough_random_backpressure_bready();
    passthrough_random_backpressure_rready();
  endtask: passthrough_runtime_mst_random_backpressure_readies

  /**********************************************************************************************************
    passthrough_runtime_slv_random_backpressure_readies :
    set ready policy of awready, wready and arready all to be XIL_AXI_READY_GEN_RANDOM,set low time range
    high time range and event count range, then put ready class into ready queue of Passthrough VIP in
    runtime slave mode.
  **********************************************************************************************************/
  task automatic passthrough_runtime_slv_random_backpressure_readies();
    passthrough_random_backpressure_wready();
    passthrough_random_backpressure_awready();
    passthrough_random_backpressure_arready();
  endtask: passthrough_runtime_slv_random_backpressure_readies

  /************************************************************************************************
  * Below are tasks used to generate xREADY signals through
  * 1. create an axi_ready_gen object through create_ready API and return its handle back to rgen
  * 2. Set the ready policy of rgen to be XIL_AXI_READY_GEN_RANDOM
  * 3. set low time range, high time range and event count range(low time, high time and events(ready/valid 
       handshake event) will be randomly picked inside these range) of rgen. 
  * 4. Send the xREADY object into xREADY port. xREADY pattern keeps the same till xREADY policy is 
  *    being changed
  *************************************************************************************************/

  
  /**********************************************************************************************************
    slv_random_backpressure_wready_port :
    1. create an axi_ready_gen object through create_ready API and return its handle back to rgen
    2. set ready policy of this rgen to be XIL_AXI_READY_GEN_RANDOM
    3. set low time range, high time range and event count range(low time, high time and events(ready/valid 
       handshake event) will be randomly picked inside these range) of rgen. 
    4. Send the WREADY object into WREADY port of write driver of Slave VIP, 
       wready generation is no backpressure till the wready policy is being changed.
  **********************************************************************************************************/
  task automatic slv_random_backpressure_wready_port();
    axi_ready_gen rgen;
    $display("%t,- Applying slv_random_backpressure_wready_port", $time);

    rgen = mem_agent.wr_driver.create_ready("slv_random_backpressure_wready_port");
    rgen.set_ready_policy(XIL_AXI_READY_GEN_RANDOM);
    rgen.set_low_time_range(0,12);
    rgen.set_high_time_range(1,12);
    rgen.set_event_count_range(3,3);
    mem_agent.wr_driver.send_wready(rgen);
  endtask : slv_random_backpressure_wready_port

  /**********************************************************************************************************
    slv_random_backpressure_awready_port :
    1. create an axi_ready_gen object through create_ready API and return its handle back to rgen
    2. set ready policy of this rgen to be XIL_AXI_READY_GEN_RANDOM
    3. set low time range, high time range and event count range(low time, high time and events(ready/valid 
       handshake event) will be randomly picked inside these range) of rgen. 
    4. Send the AWREADY object into AWREADY port of write driver of Slave VIP, 
       awready generation is random backpressure till the awready policy is being changed.
  **********************************************************************************************************/
  task automatic slv_random_backpressure_awready_port();
    axi_ready_gen rgen;
    $display("%t,- Applying slv_random_backpressure_awready_port", $time);

    rgen = mem_agent.wr_driver.create_ready("slv_random_backpressure_awready_port");
    rgen.set_ready_policy(XIL_AXI_READY_GEN_RANDOM);
    rgen.set_low_time_range(0,12);
    rgen.set_high_time_range(1,12);
    rgen.set_event_count_range(3,3);
    mem_agent.wr_driver.send_awready(rgen);
  endtask : slv_random_backpressure_awready_port

  /**********************************************************************************************************
    slv_random_backpressure_arready_port :
    1. create an axi_ready_gen object through create_ready API and return its handle back to rgen
    2. set ready policy of this rgen to be XIL_AXI_READY_GEN_RANDOM
    3. set low time range, high time range and event count range(low time, high time and events(ready/valid 
       handshake event) will be randomly picked inside these range) of rgen. 
    4. Send the ARREADY object into ARREADY port of read driver of Slave VIP, 
       arready generation is random backpressure till the arready policy is being changed.
  **********************************************************************************************************/
  task automatic slv_random_backpressure_arready_port();
    axi_ready_gen rgen;
    $display("%t,- Applying slv_random_backpressure_arready_port", $time);

    rgen = mem_agent.rd_driver.create_ready("slv_random_backpressure_arready_port");
    rgen.set_ready_policy(XIL_AXI_READY_GEN_RANDOM);
    rgen.set_low_time_range(0,12);
    rgen.set_high_time_range(1,12);
    rgen.set_event_count_range(3,3);
    mem_agent.rd_driver.send_arready(rgen);
  endtask : slv_random_backpressure_arready_port

  /**********************************************************************************************************
    slv_random_backpressure_readies_port :
    set ready policy of awready, wready and arready all to be XIL_AXI_READY_GEN_RANDOM,set low time range
    high time range and event count range, then send ready class into ready port of Slave VIP.
  **********************************************************************************************************/
  task automatic slv_random_backpressure_readies_port();
    slv_random_backpressure_wready_port();
    slv_random_backpressure_awready_port();
    slv_random_backpressure_arready_port();
  endtask  : slv_random_backpressure_readies_port

  /**********************************************************************************************************
    mst_random_backpressure_rready_port :
    1. create an axi_ready_gen object through create_ready API and return its handle back to rgen
    2. set ready policy of this rgen to be XIL_AXI_READY_GEN_RANDOM
    3. set low time range, high time range and event count range(low time, high time and events(ready/valid 
       handshake event) will be randomly picked inside these range) of rgen. 
    4. Send the RREADY object into RREADY port of read driver of Master VIP, 
       rready generation is random backpressure till the rready policy is being changed.
  **********************************************************************************************************/
  task automatic mst_random_backpressure_rready_port();
    axi_ready_gen rgen;
    $display("%t,- Applying mst_random_backpressure_rready_port", $time);

    rgen = new("mst_random_backpressure_rready_port");
    rgen.set_ready_policy(XIL_AXI_READY_GEN_RANDOM);
    rgen.set_low_time_range(0,12);
    rgen.set_high_time_range(1,12);
    rgen.set_event_count_range(3,3);
    mst_agent.rd_driver.send_rready(rgen);
  endtask : mst_random_backpressure_rready_port

  /**********************************************************************************************************
    mst_random_backpressure_bready_port :
    1. create an axi_ready_gen object through create_ready API and return its handle back to rgen
    2. set ready policy of this rgen to be XIL_AXI_READY_GEN_RANDOM
    3. set low time range, high time range and event count range(low time, high time and events(ready/valid 
       handshake event) will be randomly picked inside these range) of rgen. 
    4. Send the BREADY object into BREADY port of write driver of Master VIP, 
       bready generation is random backpressure till the bready policy is being changed.
  **********************************************************************************************************/
  task automatic mst_random_backpressure_bready_port();
    axi_ready_gen rgen;
    $display("%t,- Applying mst_random_backpressure_bready_port", $time);

    rgen = new("mst_random_backpressure_bready_port");
    rgen.set_ready_policy(XIL_AXI_READY_GEN_RANDOM);
    rgen.set_low_time_range(0,12);
    rgen.set_high_time_range(1,12);
    rgen.set_event_count_range(3,3);
    mst_agent.wr_driver.send_bready(rgen);
  endtask : mst_random_backpressure_bready_port

  /**********************************************************************************************************
    mst_no_backpressure_readies :
    set ready policy of bready and rready all to be XIL_AXI_READY_GEN_RANDOM and send 
    them to ready ports in Master VIP
  **********************************************************************************************************/
  task automatic mst_random_backpressure_readies_port();
    mst_random_backpressure_bready_port();
    mst_random_backpressure_rready_port();
  endtask  : mst_random_backpressure_readies_port

  /**********************************************************************************************************
    passthrough_random_backpressure_wready_port :
    1. create an axi_ready_gen object through create_ready API and return its handle back to rgen
    2. set ready policy of this rgen to be XIL_AXI_READY_GEN_RANDOM
    3. set low time range, high time range and event count range(low time, high time and events(ready/valid 
       handshake event) will be randomly picked inside these range) of rgen. 
    4. Send the WREADY object into WREADY port of slave write driver of Passthrough VIP, 
       wready generation is no backpressure till the wready policy is being changed.
  **********************************************************************************************************/
  task automatic passthrough_random_backpressure_wready_port();
    axi_ready_gen rgen;
    $display("%t,- Applying passthrough_random_backpressure_wready_port", $time);

    rgen = new("passthrough_random_backpressure_wready_port");
    rgen.set_ready_policy(XIL_AXI_READY_GEN_RANDOM);
    rgen.set_low_time_range(0,12);
    rgen.set_high_time_range(1,12);
    rgen.set_event_count_range(3,3);
    passthrough_mem_agent.slv_wr_driver.set_wready_gen(rgen);
  endtask : passthrough_random_backpressure_wready_port

  /**********************************************************************************************************
    passthrough_random_backpressure_awready_port :
    1. create an axi_ready_gen object through create_ready API and return its handle back to rgen
    2. set ready policy of this rgen to be XIL_AXI_READY_GEN_RANDOM
    3. set low time range, high time range and event count range(low time, high time and events(ready/valid 
       handshake event) will be randomly picked inside these range) of rgen. 
    4. Send the AWREADY object into AWREADY port of slave write driver of Passthrough VIP, 
       awready generation is random backpressure till the awready policy is being changed.
  **********************************************************************************************************/
  task automatic passthrough_random_backpressure_awready_port();
    axi_ready_gen rgen;
    $display("%t,- Applying passthrough_random_backpressure_awready_port", $time);

    rgen = new("slv_random_backpressure_awready_port");
    rgen.set_ready_policy(XIL_AXI_READY_GEN_RANDOM);
    rgen.set_low_time_range(0,12);
    rgen.set_high_time_range(1,12);
    rgen.set_event_count_range(3,3);
    passthrough_mem_agent.slv_wr_driver.set_awready_gen(rgen);
  endtask : passthrough_random_backpressure_awready_port

  /**********************************************************************************************************
    passthrough_random_backpressure_arready_port :
    1. create an axi_ready_gen object through create_ready API and return its handle back to rgen
    2. set ready policy of this rgen to be XIL_AXI_READY_GEN_RANDOM
    3. set low time range, high time range and event count range(low time, high time and events(ready/valid 
       handshake event) will be randomly picked inside these range) of rgen. 
    4. Send the ARREADY object into ARREADY port of slave read driver of Passthrough VIP, 
       arready generation is random backpressure till the arready policy is being changed.
  **********************************************************************************************************/
  task automatic passthrough_random_backpressure_arready_port();
    axi_ready_gen rgen;
    $display("%t,- Applying passthrough_random_backpressure_arready_port", $time);

    rgen = new("passthrough_random_backpressure_arready_port");
    rgen.set_ready_policy(XIL_AXI_READY_GEN_RANDOM);
    rgen.set_low_time_range(0,12);
    rgen.set_high_time_range(1,12);
    rgen.set_event_count_range(3,3);
    passthrough_mem_agent.slv_rd_driver.set_arready_gen(rgen);
  endtask : passthrough_random_backpressure_arready_port

  /**********************************************************************************************************
    passthrough_random_backpressure_rready_port :
    1. create an axi_ready_gen object through create_ready API and return its handle back to rgen
    2. set ready policy of this rgen to be XIL_AXI_READY_GEN_RANDOM
    3. set low time range, high time range and event count range(low time, high time and events(ready/valid 
       handshake event) will be randomly picked inside these range) of rgen. 
    4. Send the RREADY object into RREADY port of master read driver of Passthrough VIP. 
       rready generation is random backpressure till the rready policy is being changed.
  **********************************************************************************************************/
  task automatic passthrough_random_backpressure_rready_port();
    axi_ready_gen rgen;
    $display("%t,- Applying mst_random_backpressure_rready_port", $time);

    rgen = new("mst_random_backpressure_rready_port");
    rgen.set_ready_policy(XIL_AXI_READY_GEN_RANDOM);
    rgen.set_low_time_range(0,12);
    rgen.set_high_time_range(1,12);
    rgen.set_event_count_range(3,3);
    passthrough_mem_agent.mst_rd_driver.set_rready_gen(rgen);
  endtask : passthrough_random_backpressure_rready_port

  /**********************************************************************************************************
    passthrough_random_backpressure_bready_port :
    1. create an axi_ready_gen object through create_ready API and return its handle back to rgen
    2. set ready policy of this rgen to be XIL_AXI_READY_GEN_RANDOM
    3. set low time range, high time range and event count range(low time, high time and events(ready/valid 
       handshake event) will be randomly picked inside these range) of rgen. 
    4. Send the BREADY object into BREADY port of master write driver of Passthrough VIP, 
       bready generation is random backpressure till the bready policy is being changed.
  **********************************************************************************************************/
  task automatic passthrough_random_backpressure_bready_port();
    axi_ready_gen rgen;
    $display("%t,- Applying passthrough_random_backpressure_bready_port", $time);

    rgen = new("passthrough_random_backpressure_bready_port");
    rgen.set_ready_policy(XIL_AXI_READY_GEN_RANDOM);
    rgen.set_low_time_range(0,12);
    rgen.set_high_time_range(1,12);
    rgen.set_event_count_range(3,3);
    passthrough_mem_agent.mst_wr_driver.set_bready_gen(rgen);
  endtask : passthrough_random_backpressure_bready_port

  /**********************************************************************************************************
    passthrough_runtime_mst_random_backpressure_readies_port :
    set ready policy of awready, wready and arready all to be XIL_AXI_READY_GEN_RANDOM,set low time range
    high time range and event count range, then send ready class into ready port of Passthrough VIP.
    in runtime master mode
  **********************************************************************************************************/
  task automatic passthrough_runtime_mst_random_backpressure_readies_port();
    passthrough_random_backpressure_bready_port();
    passthrough_random_backpressure_rready_port();
  endtask: passthrough_runtime_mst_random_backpressure_readies_port

  /**********************************************************************************************************
    passthrough_runtime_slv_random_backpressure_readies_port :
    set ready policy of awready, wready and arready all to be XIL_AXI_READY_GEN_RANDOM,set low time range
    high time range and event count range, then send ready class into ready port of Passthrough VIP.
    in runtime slave mode
  **********************************************************************************************************/
  task automatic passthrough_runtime_slv_random_backpressure_readies_port();
    passthrough_random_backpressure_wready_port();
    passthrough_random_backpressure_awready_port();
    passthrough_random_backpressure_arready_port();
  endtask: passthrough_runtime_slv_random_backpressure_readies_port

endmodule
