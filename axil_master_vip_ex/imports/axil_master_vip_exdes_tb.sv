//----------------------------------------------------------------------------------------------
// Description: 
// This file contains example test lists for one design which consistes of one AXI VIP
// in master mode, one AXI VIP in passthrough mode and one AXI VIP in slave mode.
// In the following scenarios,It demonstrates how master AXI VIP create transactions, slave AXI VIP 
// generate responses and also how passthrough AXI VIP switch into run time master or/and slave mode.
// It also has two simple scoreboards to do self-checking. One scoreboard checks master AXI VIP against
// passthrough AXI VIP and the other scoreboard checks slave AXI VIP against passthrough AXI VIP
// Three methods to setup the transaction after it is being created are done in some of the example tests
// It first shows examples which is strongly recommended to AXI VIP user for its powerful
// randomization of transaction and worry free of protocol violation
// Secondly it shows examples which is very similar to AXI BFM for migration purpose
// Thirdly it shows how to use APIs to set up the transaction 
// 1. Looped Simple sequential Write/Read transfer example
// 1.a Using inline Randomization
// 1.b Using Similar Way of AXI BFM methods 
// When using similar methods of AXI BFM WRITE_BURST and READ_BURST. special care needs to be 
// done here.
// according to protocl type, use different tasks 
// AXI4:  AXI4_WRITE_BURST and AXI4_READ_BURST 
// AXI3:  AXI3_WRITE_BURST and AXI3_READ_BURST
// AXI4-LITE:  AXI4LIET_WRITED_BURST and AXI4LIET_READ_BURST
// AXI4_WRITE_BURST (id, addr, len,size,burst,lock,cache,prot,region,qos,awuser,data,wuser,resp)
// AXI3_WRITE_BURST (id, addr, len,size,burst,lock,cache,prot,data,resp)
// AXI4LITE_WRITE_BURST (addr,prot,data,resp)
// AXI4_READ_BURST (id, addr, len,size,burst,lock,cache,prot,region,qos,awuser,data,wuser,resp)
// AXI3_READ_BURST (id, addr, len,size,burst,lock,cache,prot,data,resp)
// AXI4LITE_READ_BURST (addr,prot,data,resp)
//generate inputs as needed for WRITE_BURST/READ_BURST (similiar to AXI BFM WRITE_BURST, READ_BURST)
// 1.c Using exisiting APIs to set up transactions
// 1.2  Parallel write/read transfer example 
// 1.2a Using inline Randomization
// 1.2b Using Similar Way of AXI BFM methods 
// 1.2c Using exisiting APIs to set up transactions
// 2. Narrow write and/or read transfer example when AXI VIP is configured to supports narrow
// 2.a Using inline randomization
// 2.b Using Similar Way of AXI BFM methods 
// 2.c Using exisiting APIs to set up transactions
// 3. Unaligned write and/or read transfer example when AXI VIP is configured to HAS_WSTRB  
// 3.a Using inline randomization
// 3.b Using Similar Way of AXI BFM methods 
// 3.c Using exisiting APIs to set up transactions
// 4. Outstanding transactions example
// 4.a Using inline randomization
// 4.b Using Similar Way of AXI BFM methods 
// 4.c Using exisiting APIs to set up transactions
// 5. Switch Passthrough AXI VIP into run time master mode
// 6. Switch Passthrough AXI VIP into run time slave mode
//----------------------------------------------------------------------------------------------

`timescale 1ns / 1ps
// import package 
import axi_vip_pkg::*;
import ex_sim_axi_vip_mst_0_pkg::*;
import ex_sim_axi_vip_slv_0_pkg::*;
import ex_sim_axi_vip_passthrough_0_pkg::*;

module axil_master_vip_exdes_tb(
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
  // Total number of transactions occur before passthrough VIP switch to runtime Master mode
   xil_axi_uint                            trans_cnt_before_switch = 36;
  
  // Counts of passthrough VIP switch to runtime master or slave mode 
  xil_axi_uint                            passthrough_cmd_switch_cnt = 0;
  // Event when passthrough VIP in runtime Master mode start
  event                                   passthrough_mastermode_start_event;
  // Event when passthrough VIP in runtime master mode finish
  event                                   passthrough_mastermode_end_event;
  // Event when passthrough VIP in runtime slave mode finish
  event                                   passthrough_slavemode_end_event;
  // ID value for WRITE/READ_BURST transaction
  xil_axi_uint                            mtestID;
  // ADDR value for WRITE/READ_BURST transaction
  xil_axi_ulong                           mtestADDR;
  // Burst Length value for WRITE/READ_BURST transaction
  xil_axi_len_t                           mtestBurstLength;
  // SIZE value for WRITE/READ_BURST transaction
  xil_axi_size_t                          mtestDataSize; 
  // Burst Type value for WRITE/READ_BURST transaction
  xil_axi_burst_t                         mtestBurstType; 
  // LOCK value for WRITE/READ_BURST transaction
  xil_axi_lock_t                          mtestLOCK;
  // Cache Type value for WRITE/READ_BURST transaction
  xil_axi_cache_t                         mtestCacheType = 0;
  // Protection Type value for WRITE/READ_BURST transaction
  xil_axi_prot_t                          mtestProtectionType = 3'b000;
  // Region value for WRITE/READ_BURST transaction
  xil_axi_region_t                        mtestRegion = 4'b000;
  // QOS value for WRITE/READ_BURST transaction
  xil_axi_qos_t                           mtestQOS = 4'b000;
  // Data beat value for WRITE/READ_BURST transaction
  xil_axi_data_beat                       dbeat;
  // User beat value for WRITE/READ_BURST transaction
  xil_axi_user_beat                       usrbeat;
  // Wuser value for WRITE/READ_BURST transaction
  xil_axi_data_beat [255:0]               mtestWUSER; 
  // Awuser value for WRITE/READ_BURST transaction
  xil_axi_data_beat                       mtestAWUSER = 'h0;
  // Aruser value for WRITE/READ_BURST transaction
  xil_axi_data_beat                       mtestARUSER = 0;
  // Ruser value for WRITE/READ_BURST transaction
  xil_axi_data_beat [255:0]               mtestRUSER;    
  // Buser value for WRITE/READ_BURST transaction
  xil_axi_uint                            mtestBUSER = 0;
  // Bresp value for WRITE/READ_BURST transaction
  xil_axi_resp_t                          mtestBresp;
  // Rresp value for WRITE/READ_BURST transaction
  xil_axi_resp_t[255:0]                   mtestRresp;
  //----------------------------------------------------------------------------------------------
  // no burst for AXI4LITE and maximum data bits is 64
  // Write Data Value for WRITE_BURST transaction
  // Read Data Value for READ_BURST transaction
  //----------------------------------------------------------------------------------------------
  bit [63:0]                              mtestWData;
  bit [63:0]                              mtestRData;
  // write transaction created by master VIP 
  axi_transaction                         wr_transaction; 
  // read transaction created by master VIP 
  axi_transaction                         rd_transaction; 
  // write transaction created by passthrough VIP in runtime master mode  
  axi_transaction                         pss_wr_transaction; 
  // write and read transaction created by passthrough VIP in runtime slave mode 
  axi_transaction                         pss_rd_transaction; 
  // transaction for write response 
  axi_transaction                         reactive_transaction; 
  // transaction for read response 
  axi_transaction                         rd_payload_transaction;
  // transaction used for constraint randomization purpose
  axi_transaction                         wr_rand;
  // transaction used for constraint randomization purpose
  axi_transaction                         rd_rand;
  // response for write transaction for master VIP
  axi_transaction                         wr_reactive;
  // response for read transaction for master VIP
  axi_transaction                         rd_reactive;
  // response for write transaction for passthrough VIP in runtime master mode
  axi_transaction                         wr_reactive2; 
  // response for read transaction for passthrough VIP in runtime master mode
  axi_transaction                         rd_reactive2;
  //----------------------------------------------------------------------------------------------
  // associated array for read data 
  // read data channel uses data_mem[addr] if it exist, otherwise, it generates randomized data
  // fill in data_mem and send it to read data transaction
  //----------------------------------------------------------------------------------------------
  xil_axi_payload_byte                    data_mem[xil_axi_ulong];
  //----------------------------------------------------------------------------------------------
  // the following monitor transactions are for simple scoreboards doing self-checking
  // two Scoreboards are built here
  // one scoreboard checks master vip against passthrough VIP (scoreboard 1)
  // the other one checks passthrough VIP against slave VIP (scoreboard 2)
  // monitor transaction from master VIP
  //----------------------------------------------------------------------------------------------
  axi_monitor_transaction                 mst_monitor_transaction;
  // monitor transaction queue for master VIP 
  axi_monitor_transaction                 master_moniter_transaction_queue[$];
  // size of master_moniter_transaction_queue
  xil_axi_uint                           master_moniter_transaction_queue_size =0;
  //scoreboard transaction from master monitor transaction queue
  axi_monitor_transaction                 mst_scb_transaction;
  //monitor transaction from passthrough VIP
  axi_monitor_transaction                 passthrough_monitor_transaction;
  // monitor transaction queue for passthrough VIP for scoreboard 1
  axi_monitor_transaction                 passthrough_master_moniter_transaction_queue[$];
  // size of passthrough_master_moniter_transaction_queue;
  xil_axi_uint                            passthrough_master_moniter_transaction_queue_size =0;
  // scoreboard transaction from passthrough VIP monitor transaction queue 
  axi_monitor_transaction                 passthrough_mst_scb_transaction;
  // monitor transaction queue for passthrough VIP for scoreboard 2 
  axi_monitor_transaction                 passthrough_slave_moniter_transaction_queue[$];
  // size of passthrough_slave_moniter_transaction_queue;
  xil_axi_uint                            passthrough_slave_moniter_transaction_queue_size =0;
  // scoreboard transaction from Passthrough VIP monitor transaction queue
  axi_monitor_transaction                 passthrough_slv_scb_transaction;
  // monitor transaction for slave VIP
  axi_monitor_transaction                 slv_monitor_transaction;
  // monitor transaction queue for slave VIP
  axi_monitor_transaction                 slave_moniter_transaction_queue[$];
  // size of slave_moniter_transaction_queue
  xil_axi_uint                            slave_moniter_transaction_queue_size =0;
  // scoreboard transaction from slave monitor transaction queue
  axi_monitor_transaction                 slv_scb_transaction;
  //----------------------------------------------------------------------------------------------
  // verbosity level which specifies how much debug information to produce
  // 0       - No information will be printed out.
  // 400      - All information will be printed out.
  // master VIP agent verbosity level
  //----------------------------------------------------------------------------------------------
  xil_axi_uint                           mst_agent_verbosity = 0;
  // slave VIP agent verbosity level
  xil_axi_uint                           slv_agent_verbosity = 0;
  // passthrough VIP agent verbosity level
  xil_axi_uint                           passthrough_agent_verbosity = 0;
  //----------------------------------------------------------------------------------------------
  // Parameterized agents which customer needs to declare according to AXI VIP configuration
  // If AXI VIP is being configured in master mode, axi_mst_agent has to declared 
  // If AXI VIP is being configured in slave mode, axi_slv_agent has to be declared 
  // If AXI VIP is being configured in pass-through mode, axi_passthrough_agent has to be declared
  // "component_name"_mst_t for master agent
  // "component_name"_slv_t for slave agent
  // "component_name"_passthrough_t for passthrough agent
  // "component_name can be easily found in vivado bd design: click on the instance, 
  // then click CONFIG under Properties window and Component_Name will be shown
  // more details please refer PG267 for more details
  //----------------------------------------------------------------------------------------------
  ex_sim_axi_vip_mst_0_mst_t                              mst_agent;
  ex_sim_axi_vip_slv_0_slv_t                              slv_agent;
  ex_sim_axi_vip_passthrough_0_passthrough_t              passthrough_agent;

  
     
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
    //----------------------------------------------------------------------------------------------
    // The hierarchy path of the AXI VIP's interface is passed to the agent when it is newed. 
    // Method to find the hierarchy path of AXI VIP is to run simulation without agents being newed, 
    // message like "Xilinx AXI VIP Found at Path: my_ip_exdes_tb.DUT.ex_design.axi_vip_mst.inst" will 
    // be printed out.
    //----------------------------------------------------------------------------------------------
    mst_agent = new("master vip agent",DUT.ex_design.axi_vip_mst.inst.IF);
    slv_agent = new("slave vip agent",DUT.ex_design.axi_vip_slv.inst.IF);
    passthrough_agent = new("passthrough vip agent",DUT.ex_design.axi_vip_passthrough.inst.IF);
    $timeformat (-12, 1, " ps", 1);
    //----------------------------------------------------------------------------------------------
    // set tag for agents for easy debug,if not set here, it will be hard to tell which driver is filing 
    // if multiple agents are called in one testbench
    //----------------------------------------------------------------------------------------------
    mst_agent.set_agent_tag("Master VIP");
    slv_agent.set_agent_tag("Slave VIP");
    passthrough_agent.set_agent_tag("Passthrough VIP");
    // set print out verbosity level.
    mst_agent.set_verbosity(mst_agent_verbosity);
    slv_agent.set_verbosity(slv_agent_verbosity);
    passthrough_agent.set_verbosity(passthrough_agent_verbosity);
    //----------------------------------------------------------------------------------------------
    // master,slave agents start to run 
    // turn monitor on passthrough agent
    //----------------------------------------------------------------------------------------------
    mst_agent.start_master();
    slv_agent.start_slave();
    exdes_state = EXDES_PASSTHROUGH;
    passthrough_agent.start_monitor();
    //----------------------------------------------------------------------------------------------
    // AXI VIP has its own way to generate transaction. 
    // For customer who are used to AXI BFM, examples similar to AXI BFM  
    // WRITE/READ_BURST is shown below.
    // It shows two ways to fill_in inputs for WRITE_BURST/ READ_BURST, 
    // 1. Fill in all these data by customer directly
    // 2. Create randomization transaction from AXI VIP and then assign it to test info.
    //    --this is recommended way because it make full use of exisiting constraints 
    //     of transaction from AXI VIP and worry free of protcol violation, wr_rand
    //     and rd_rand serve for this purpose, they will be used in late examples
    //----------------------------------------------------------------------------------------------
    fork
      wr_rand = mst_agent.wr_driver.create_transaction("master agent create write transaction for ranmoization purpose");
      rd_rand = mst_agent.rd_driver.create_transaction("master agent create read transaction for randomization purpose");
    join
    // generate mtestWData       
    for(int i = 0; i < 8; i++) begin
      mtestWData[i+:8] = $urandom_range(0, 255);
    end  
    //----------------------------------------------------------------------------------------------
    //  EXAMPLE TEST :
    // DESCRIPTION:
    // Simple sequential write and/or read burst transfers example
    // The following scenario is a simple INCR write/read burst
    // Three methods being used here
    // a.AXI VIP randomization 
    // b.AXI BFM WRITE_BURST and/or READ_BURST
    // c.AXI VIP APIs
    //----------------------------------------------------------------------------------------------
   
    $display("Sequential write transfers example  with randomization starts");
    //----------------------------------------------------------------------------------------------
    // Master create write transcation
    // Randomize the transaction with Burst type is INCR
    // Send the transaction 
    //----------------------------------------------------------------------------------------------
    wr_transaction = mst_agent.wr_driver.create_transaction("write transaction in sequential write transafer example with full randomization");
    WR_TRANSACTION_FAIL_1a: assert(wr_transaction.randomize() with {
        burst == XIL_AXI_BURST_TYPE_INCR; 
    });
    mst_agent.wr_driver.send(wr_transaction);
    $display("Sequential write transfers example with randomization completes");
    $display("Sequential write transfers example similar to  AXI BFM WRITE_BURST method starts");
    //----------------------------------------------------------------------------------------------
    // generate inputs as needed for WRITE_BURST/READ_BURST tassk (similiar to AXI BFM WRITE_BURST, 
    // READ_BURST) with INCR Burst type
    //----------------------------------------------------------------------------------------------
    mtestID = 0;
    mtestADDR = 0;
    mtestBurstLength = 0;
    mtestDataSize = xil_axi_size_t'(xil_clog2(32/8));
    mtestBurstType = XIL_AXI_BURST_TYPE_INCR; 
    mtestLOCK = XIL_AXI_ALOCK_NOLOCK; 
    mtestProtectionType = 0; 
    mtestRegion = 0;
    mtestQOS = 0;
    for(int i = 0; i < 256;i++) begin
      mtestWUSER = 'h0;
    end  
    mst_agent.AXI4LITE_WRITE_BURST(
          mtestADDR,
          mtestProtectionType,
          mtestWData,
          mtestBresp
        );
   
    $display("Sequential write transfers example similar to  AXI BFM WRITE_BURST method completes");
    //----------------------------------------------------------------------------------------------
    // Master create write transcation
    // use APIs to set up the content of transaction. please refer documentation for usage of APIs.
    // Send the transaction 
    //----------------------------------------------------------------------------------------------
    $display("Sequential write transfers example with AXI VIP APIs starts");
    wr_transaction = mst_agent.wr_driver.create_transaction("write transaction in sequential write transafer example with API");
    wr_transaction.set_write_cmd(mtestADDR,mtestBurstType,mtestID,mtestBurstLength,mtestDataSize);
    wr_transaction.set_cache(mtestCacheType);
    wr_transaction.set_data_block(mtestWData);
    wr_transaction.set_awuser(mtestAWUSER);
    for(int beat=0; beat< wr_transaction.get_len()+1; beat++) begin
      wr_transaction.set_wuser(beat,mtestWUSER[beat]); 
    end  
    mst_agent.wr_driver.send(wr_transaction);
    $display("Sequential write transfers example with AXI VIP API completes");
   
    //----------------------------------------------------------------------------------------------
    // master create read commond transaction
    // randomize the transaction 
    // send the transaction out
    //----------------------------------------------------------------------------------------------
    $display("Sequential read transfers example with randomization starts");
    rd_transaction = mst_agent.rd_driver.create_transaction("read transaction in sequential read transafer example with full randomization");
    RD_TRANSACTION_FAIL_1a:assert(rd_transaction.randomize());
    mst_agent.rd_driver.send(rd_transaction);
    $display("Sequential read transfers example with randomization completes");
    //----------------------------------------------------------------------------------------------
    // generate inputs as needed for READ_BURST 
    //----------------------------------------------------------------------------------------------
    $display("Sequential read transfers example similar to  AXI BFM READ_BURST method starts");
    mtestID = 0;
    mtestADDR = 0;
    mtestBurstLength = 0;
    mtestDataSize = xil_axi_size_t'(xil_clog2(32/8));
    mtestBurstType = XIL_AXI_BURST_TYPE_INCR; 
    mtestLOCK = XIL_AXI_ALOCK_NOLOCK; 
    mtestProtectionType = 0; 
    mtestRegion = 0;
    mtestQOS = 0;
    for(int i = 0; i < 256;i++) begin
      mtestWUSER = 'h0;
    end  
    mst_agent.AXI4LITE_READ_BURST(
          mtestADDR,
          mtestProtectionType,
          mtestRData,
          mtestRresp
        );
   
    $display("Sequential read transfers example similar to  AXI BFM READ_BURST method completes");

    $display("Sequential read transfers example with AXI VIP API starts");
    rd_transaction = mst_agent.rd_driver.create_transaction("read transaction in sequential read transafer example with API");
    rd_transaction.set_read_cmd(mtestADDR,mtestBurstType,mtestID,mtestBurstLength,mtestDataSize);
    rd_transaction.set_cache(mtestCacheType);
    mst_agent.rd_driver.send(rd_transaction);
    $display("Sequential read transfers example with AXI VIP API completes");
   
    $display("Parallel write and read transfers example with AXI VIP randomization start ");
    fork
      //----------------------------------------------------------------------------------------------
      // master agent create write transcation
      // randomize the transaction
      // send the transaction out
      //----------------------------------------------------------------------------------------------
      begin
        wr_transaction = mst_agent.wr_driver.create_transaction("write transaction in parallel write/read transafer example with inline randomization");
        WR_TRANSACTION_FAIL_1b:assert(wr_transaction.randomize() with {
          burst == XIL_AXI_BURST_TYPE_INCR; 
        });
        mst_agent.wr_driver.send(wr_transaction);
      end
      //----------------------------------------------------------------------------------------------
      // master agent create read command transaction
      // randomize the transaction
      // send the transaction out
      //----------------------------------------------------------------------------------------------
      begin
        rd_transaction = mst_agent.rd_driver.create_transaction("read transaction in parallel write/read transafer example with inline randomization");
        RD_TRANSACTION_FAIL_1b:assert(rd_transaction.randomize());
        mst_agent.rd_driver.send(rd_transaction);
      end
    join
    $display("Parallel write and read transfers example with AXI VIP randomization completesd");
    $display("Parellel write transfers example similar to  AXI BFM WRITE_BURST/READ_BURST method starts");
    fork
      mst_agent.AXI4LITE_WRITE_BURST(
          mtestADDR,
          mtestProtectionType,
          mtestWData,
          mtestBresp
        );
      mst_agent.AXI4LITE_READ_BURST(
          mtestADDR,
          mtestProtectionType,
          mtestRData,
          mtestRresp
        );
    join  
   
    $display("Parellel write transfers example similar to  AXI BFM WRITE_BURST/READ_BURST method completes");
    $display("Parallel read transfers example with AXI VIP API starts");
    fork 
      begin
        wr_transaction = mst_agent.wr_driver.create_transaction("write transaction in parallel write/read transafer example with API");
        mst_agent.wr_driver.set_transaction_depth(2);
        wr_transaction.set_write_cmd(mtestADDR,mtestBurstType,mtestID,mtestBurstLength,mtestDataSize);
        wr_transaction.set_cache(mtestCacheType);
        wr_transaction.set_data_block(mtestWData);
        wr_transaction.set_awuser(mtestAWUSER);
        for(int beat=0; beat< wr_transaction.get_len()+1; beat++) begin
          wr_transaction.set_wuser(beat,mtestWUSER[beat]); 
        end  
        mst_agent.wr_driver.send(wr_transaction);
      end 
      begin
        rd_transaction = mst_agent.rd_driver.create_transaction("read transaction in parallel write/read transafer example with API");
        mst_agent.rd_driver.set_transaction_depth(2);
        rd_transaction.set_read_cmd(mtestADDR,mtestBurstType,mtestID,mtestBurstLength,mtestDataSize);
        rd_transaction.set_cache(mtestCacheType);
        mst_agent.rd_driver.send(rd_transaction);
      end   
    join
    $display("Parallel read transfers example with AXI VIP API completes");
    //---------------------------------------------------------------------
    // EXAMPLE TEST :
    // Outstanding transactions example -default is 16. here shows how to 
    // can set from agent level or driver level. agent level will set up
    // both read channle and write channel to the same value
    // Read driver will set up read channel. write driver will setup write 
    // channel
    //---------------------------------------------------------------------
  
    $display(" Outstanding Write transfers example with randomization starts");
    //----------------------------------------------------------------------------------------------
    // master create write transcation
    // set outstanding transaction to be 10
    // randomize the transaction 
    // send the transaction out
    //----------------------------------------------------------------------------------------------
    wr_transaction = mst_agent.wr_driver.create_transaction("write transaction in outstanding transaction example with full randomization");
    mst_agent.wr_driver.set_transaction_depth(10);
    WR_TRANSACTION_FAIL_4a: assert(wr_transaction.randomize());
    mst_agent.wr_driver.send(wr_transaction);
    $display(" Outstanding Write transfers example with randomization completess");
    $display("Outstanding Write transfers example similar to AXI BFM methos starts");
    mst_agent.wr_driver.set_transaction_depth(10);
    WR_TRANSACTION_FAIL_4b:assert(wr_rand.randomize()with {
     burst == XIL_AXI_BURST_TYPE_INCR; 
     });
    mtestID = wr_rand.get_id();
    mtestADDR = wr_rand.get_addr();
    mtestBurstLength = wr_rand.get_len();
    mtestDataSize = wr_rand.get_size();
    mtestBurstType = wr_rand.get_burst(); 
    mtestLOCK = wr_rand.get_lock(); 
    mtestCacheType = wr_rand.get_cache(); 
    mtestProtectionType = wr_rand.get_prot(); 
    mtestRegion = wr_rand.get_region();
    mtestQOS =  wr_rand.get_qos(); 
    mst_agent.AXI4LITE_WRITE_BURST(
        mtestADDR,
        mtestProtectionType,
        mtestWData,
        mtestBresp
      );
    $display("Outstanding Write transfers example similar to AXI BFM methos starts");
   
   $display("Outstanding Write transfers example with AXI VIP API starts");
    //----------------------------------------------------------------------------------------------
    // master create write transcation
    // set outstanding transaction to be 10
    // use AXI VIP APIs to set up the transaction 
    // send the transaction 
    //----------------------------------------------------------------------------------------------
    wr_transaction = mst_agent.wr_driver.create_transaction("write transaction in outstanding transaction example with API");
    mst_agent.wr_driver.set_transaction_depth(10);
    wr_transaction.set_write_cmd(mtestADDR,mtestBurstType,mtestID,mtestBurstLength,mtestDataSize); 
    wr_transaction.set_cache(mtestCacheType);
    wr_transaction.set_data_block(mtestWData);
    wr_transaction.set_awuser(mtestAWUSER);
    for(int beat=0; beat< wr_transaction.get_len()+1; beat++) begin
      wr_transaction.set_wuser(beat,mtestWUSER[beat]); 
    end  
    mst_agent.wr_driver.send(wr_transaction);
   $display("Outstanding Write transfers example with AXI VIP API method completes");
 
    //----------------------------------------------------------------------------------------------
    // master create read transcation
    // set_transaction_depth is used to setup maximum outstanding read transaction
    // randomize the transaction 
    // send the transaction out
    //----------------------------------------------------------------------------------------------
    $display("Outstanding Read transfers example with randomization starts");
    rd_transaction = mst_agent.rd_driver.create_transaction("read transaction in outstanding transaction example with full randomization");
    mst_agent.rd_driver.set_transaction_depth(2);
    RD_TRANSACTION_FAIL_4a:assert(rd_transaction.randomize() );
    mst_agent.rd_driver.send(rd_transaction);
    $display("Outstanding read transfers example with randomization completeed");

    $display("EXAMPLE TEST  : Outstanding READ transfers example simiar to AXI BFM starts");
    mst_agent.rd_driver.set_transaction_depth(8);
    RD_TRANSACTION_FAIL_4b: assert(rd_rand.randomize()with {
     burst == XIL_AXI_BURST_TYPE_INCR; 
     });
    mtestID = rd_rand.get_id();
    mtestADDR = rd_rand.get_addr();
    mtestBurstLength = rd_rand.get_len();
    mtestDataSize = rd_rand.get_size();
    mtestBurstType = rd_rand.get_burst(); 
    mtestLOCK = rd_rand.get_lock(); 
    mtestCacheType = rd_rand.get_cache(); 
    mtestProtectionType = rd_rand.get_prot(); 
    mtestRegion = rd_rand.get_region();
    mtestQOS =  rd_rand.get_qos();
    mst_agent.AXI4LITE_READ_BURST(
        mtestADDR,
        mtestProtectionType,
        mtestRData,
        mtestRresp
      );
 
     $display("Outstanding read transfers example similar to AXI BFM READ_BURST method completes");        
    //----------------------------------------------------------------------------------------------
    // master create read transcation
    // set outstanding transaction to be 10
    // use AXI VIP APIs to set up the transaction 
    // send the transaction 
    //----------------------------------------------------------------------------------------------
    $display("Outstanding read transfers example with AXI VIP API starts");
    rd_transaction = mst_agent.rd_driver.create_transaction("read transaction in outstanding transaction example with API");
    mst_agent.rd_driver.set_transaction_depth(2);
    rd_transaction.set_read_cmd(mtestADDR,mtestBurstType,mtestID,mtestBurstLength,mtestDataSize);
    rd_transaction.set_cache(mtestCacheType);
    mst_agent.rd_driver.send(rd_transaction);
    $display("Outstanding read transfers example with AXI VIP API completes");
   
    //----------------------------------------------------------------------------------------------
    // EXAMPLE TEST :
    // DESCRIPTION:
    // Passthrough VIP being turned into run time master mode
    // The following code shows how to set up passthrough VIP into run time
    // Master mode and generate write and/or read transactions  
    //----------------------------------------------------------------------------------------------
    while(passthrough_cmd_switch_cnt ==0) begin
      @(passthrough_mastermode_start_event);
      passthrough_cmd_switch_cnt++;
    end
    #1ns;
    //----------------------------------------------------------------------------------------------
    // switch passthrough VIP inst to run time master mode by call task set_master_mode
    //----------------------------------------------------------------------------------------------
    axil_master_vip_exdes_tb.DUT.ex_design.axi_vip_passthrough.inst.set_master_mode();
    exdes_state = EXDES_PASSTHROUGH_MASTER;
    passthrough_agent.set_agent_tag("Passthrough VIP in Master mode");
    passthrough_agent.start_master();
   
    $display("Change Passthrough IP into runtime master mode and generate write transfers with Randomization");
    //----------------------------------------------------------------------------------------------
    // run time master mode create write transcation
    // set transaction depth
    // randomize transaction
    // send transaction 
    //----------------------------------------------------------------------------------------------
    pss_wr_transaction = passthrough_agent.mst_wr_driver.create_transaction("Passthrough VIP in runtime master mode: create write transaction(1)");
    passthrough_agent.mst_wr_driver.set_transaction_depth(2);
    for(int i = 0; i < 2;i++) begin
      WR_TRANSACTION_FAIL_5a: assert(pss_wr_transaction.randomize() );
      passthrough_agent.mst_wr_driver.send(pss_wr_transaction);
    end  
    $display("Passthrough IP change into runtime master write transfers example with randomization completes");
   
    $display("Change Passthrough IP into runtime master mode and generate Read transfers with Randomization");
    //----------------------------------------------------------------------------------------------
    // runtime master mode create read transcation
    // set transaction depth
    // randomize transaction
    // send the transaction out
    //----------------------------------------------------------------------------------------------
    pss_rd_transaction = passthrough_agent.mst_rd_driver.create_transaction("Passthrough VIP in runtime master mode: create read transaction(1)");
    passthrough_agent.mst_rd_driver.set_transaction_depth(2);
    for(int i = 0; i < 2;i++) begin
      RD_TRANSACTION_FAIL_5a: assert(pss_rd_transaction.randomize());
      passthrough_agent.mst_rd_driver.send(pss_rd_transaction);
    end  
    $display("Passthrough IP change into runtime master read transfers example with randomization completes");
    $display("Change Passthrough IP into runtime master mode and generate parallel Write/Read transfers with Randomization");
    //----------------------------------------------------------------------------------------------
    // Passthrough VIP agent in run time master mode
    // below shows parallel write/read transaction process  
    //----------------------------------------------------------------------------------------------
    fork 
      //----------------------------------------------------------------------------------------------
      // runtime master mode create write transaction
      // randomize transaction
      // send transaction
      //----------------------------------------------------------------------------------------------
      begin 
        pss_wr_transaction = passthrough_agent.mst_wr_driver.create_transaction("Passthrough VIP in runtime master mode: create write transaction(2)");
        passthrough_agent.mst_wr_driver.set_transaction_depth(4);
        for(int i = 0; i < 2;i++) begin
          WR_TRANSACTION_FAIL_5b: assert(pss_wr_transaction.randomize() );
          passthrough_agent.mst_wr_driver.send(pss_wr_transaction);
        end 
      end
      //----------------------------------------------------------------------------------------------
      // runtime master mode create read transaction
      // randomize transaction
      // send transaction
      //----------------------------------------------------------------------------------------------
      begin
        pss_rd_transaction = passthrough_agent.mst_rd_driver.create_transaction("Passthrough VIP in runtime master mode: create write transaction(2)");
        passthrough_agent.mst_rd_driver.set_transaction_depth(5);
        for(int i = 0; i < 2;i++) begin
          RD_TRANSACTION_FAIL_5b: assert(pss_rd_transaction.randomize());
          passthrough_agent.mst_rd_driver.send(pss_rd_transaction);
        end  
      end 
    join
    $display("Change Passthrough IP into runtime master mode with parallel Write/Read transfers completes");
    while(passthrough_cmd_switch_cnt ==1) begin
      @(passthrough_mastermode_end_event);
      passthrough_cmd_switch_cnt++;
    end
    //----------------------------------------------------------------------------------------------
    // EXAMPLE TEST :
    // DESCRIPTION:
    // Passthrough VIP being turned into run time slave mode
    // The following code shows how to set up passthrough VIP into run time
    // slave mode and how to respond to Master VIP write and/or read transactions  
    // switch passthrough VIP inst to run time slave mode by call task set_slave_mode
    //----------------------------------------------------------------------------------------------
    #1ns;
    axil_master_vip_exdes_tb.DUT.ex_design.axi_vip_passthrough.inst.set_slave_mode();
    exdes_state = EXDES_PASSTHROUGH_SLAVE;
    passthrough_agent.set_agent_tag("Passthrough VIP in Slave mode");
    passthrough_agent.stop_master();
    passthrough_agent.start_slave();
   
    $display("EXAMPLE TEST  : Change Passthrough IP into runtime slave mode and generate write transfers with Randomization");
    fork
      begin
        pss_wr_transaction = mst_agent.wr_driver.create_transaction("Passthrough VIP in slave mode: Master VIP create write transaction(1)");
        mst_agent.wr_driver.set_transaction_depth(5);
        for(int i = 0; i < 2;i++) begin
          WR_TRANSACTION_FAIL_6a: assert(pss_wr_transaction.randomize());
          mst_agent.wr_driver.send(pss_wr_transaction);
        end
      end
      begin
        for(int i =0; i<2; i++) begin
          passthrough_agent.slv_wr_driver.get_wr_reactive(wr_reactive2);
          fill_reactive(wr_reactive2);
          passthrough_agent.slv_wr_driver.send(wr_reactive2);
        end
      end
    join
   
    $display("Change Passthrough IP into runtime slave mode and generate read transfers with Randomization");
    fork
      //----------------------------------------------------------------------------------------------
      // Passthrough VIP agent in run time slave mode
      // it gets write transaction cmd information,fill in response and send it back
      // to Passthrough VIP interface
      //----------------------------------------------------------------------------------------------
      begin
        pss_rd_transaction = mst_agent.rd_driver.create_transaction("Passthrough VIP in slave mode: Master VIP create read transaction(1)");
        mst_agent.rd_driver.set_transaction_depth(5);
        for(int i = 0; i < 2;i++) begin
          RD_TRANSACTION_FAIL_6a: assert(pss_rd_transaction.randomize());
          mst_agent.rd_driver.send(pss_rd_transaction);
        end  
      end
      //----------------------------------------------------------------------------------------------
      // Passthrough VIP agent in run time slave mode
      // it gets read transaction cmd information,fill in data information and send it back 
      // Passthrough VIP interface
      //----------------------------------------------------------------------------------------------
      begin
        for(int i = 0; i < 2;i++) begin
          passthrough_agent.slv_rd_driver.get_rd_reactive(rd_reactive2);
          fill_payload(rd_reactive2);
          fill_beat_delay(rd_reactive2);
          passthrough_agent.slv_rd_driver.send(rd_reactive2);
        end
      end  
    join
   
    $display("Change Passthrough IP into runtime slave mode and generate parallel write/read transfers with Randomization");
    //----------------------------------------------------------------------------------------------
    // Passthrough VIP agent in run time slave mode
    // below shows parallel write/read response process  
    //----------------------------------------------------------------------------------------------
    fork
      begin
        pss_wr_transaction = mst_agent.wr_driver.create_transaction("Passthrough VIP in slave mode: Master VIP create write transaction(2)");
        mst_agent.wr_driver.set_transaction_depth(5);
        for(int i = 0; i < 2;i++) begin
          WR_TRANSACTION_FAIL_6b: assert(pss_wr_transaction.randomize());
          mst_agent.wr_driver.send(pss_wr_transaction);
        end  
      end
      begin
        pss_rd_transaction = mst_agent.rd_driver.create_transaction("Passthrough VIP in slave mode: Master VIP create read transaction(2)");
        mst_agent.rd_driver.set_transaction_depth(5);
        for(int i = 0; i < 2;i++) begin
          RD_TRANSACTION_FAIL_6b: assert(pss_rd_transaction.randomize());
          mst_agent.rd_driver.send(pss_rd_transaction);
        end  
      end      
      begin
        for(int i = 0; i < 2; i++) begin
          passthrough_agent.slv_wr_driver.get_wr_reactive(wr_reactive2);
          fill_reactive(wr_reactive2);
          passthrough_agent.slv_wr_driver.send(wr_reactive2);
        end
      end
      begin
        for(int i = 0; i < 2;i++) begin
          passthrough_agent.slv_rd_driver.get_rd_reactive(rd_reactive2);
          fill_payload(rd_reactive2);
          fill_beat_delay(rd_reactive2);
          passthrough_agent.slv_rd_driver.send(rd_reactive2);
        end
      end  
    join
    while(passthrough_cmd_switch_cnt ==2) begin
      @(passthrough_slavemode_end_event);
      passthrough_cmd_switch_cnt++;
    end
    #1ns;
    if(error_cnt ==0) begin
      $display("EXAMPLE TEST DONE : Test Completed Successfully");
    end else begin  
      $display("EXAMPLE TEST DONE ",$sformatf("Test Failed: %d Comparison Failed", error_cnt));
    end 
    $finish;
  end

  //slave VIP agent gets write transaction cmd information,fill in response and send it back to Slave VIP interface
  initial begin
    forever begin  :slv_run
      slv_agent.wr_driver.get_wr_reactive(wr_reactive);
      fill_reactive(wr_reactive);
      slv_agent.wr_driver.send(wr_reactive);
    end
  end

  //slave VIP agent gets read transaction cmd information,fill in data information and send it back to Slave VIP interface
  initial begin
    forever begin
      slv_agent.rd_driver.get_rd_reactive(rd_reactive);
      fill_payload(rd_reactive);
      fill_beat_delay(rd_reactive);
      slv_agent.rd_driver.send(rd_reactive);
    end  
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
      slv_agent.monitor.item_collected_port.get(slv_monitor_transaction);
      slave_moniter_transaction_queue.push_back(slv_monitor_transaction);
      slave_moniter_transaction_queue_size++;
    end
  end

  // passthrough vip monitors all the transaction from interface and put then into transaction queue
  initial begin
    forever begin
      passthrough_agent.monitor.item_collected_port.get(passthrough_monitor_transaction);
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

  // event to trigger passthrough vip switch to runtime master/slave mode
  always @(comparison_cnt) begin
    if(comparison_cnt == trans_cnt_before_switch) begin
      -> passthrough_mastermode_start_event;
    end 
    if(comparison_cnt == trans_cnt_before_switch+8) begin
      -> passthrough_mastermode_end_event;
    end 
    if(comparison_cnt == trans_cnt_before_switch+16) begin
      -> passthrough_slavemode_end_event;
    end 
  end

  //----------------------------------------------------------------------------------------------
  //simple scoreboard doing self checking 
  //comparing transaction from master VIP monitor with transaction from passsthrough VIP in slave side
  // if they are match, SUCCESS. else, ERROR
  //----------------------------------------------------------------------------------------------
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
 
  //----------------------------------------------------------------------------------------------
  //comparing transaction from passthrough in master side with transaction from Slave VIP 
  // if they are match, SUCCESS. else, ERROR
  //----------------------------------------------------------------------------------------------
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

  //----------------------------------------------------------------------------------------------
  //function for read transaction which fill data into transaction according to related address of the transaction 
  //and existence in memory
  //----------------------------------------------------------------------------------------------
  function automatic void fill_payload(inout axi_transaction t);
    longint unsigned                 current_addr;
    longint unsigned                 addr_max;  
    xil_axi_payload_byte             beat[];
    xil_axi_uint                     start_address;
    xil_axi_uint                     number_bytes;
    xil_axi_uint                     aligned_address;
    xil_axi_uint                     burst_length;
    xil_axi_uint                     address_n;
    xil_axi_uint                     wrap_boundary;

    current_addr  = t.get_addr();
    start_address  = t.get_addr();
    number_bytes = xil_pow2(t.get_size());
    burst_length = t.get_len() + 1;
    aligned_address = (start_address/number_bytes) * number_bytes;
    wrap_boundary = (start_address/(number_bytes * burst_length)) * (number_bytes * burst_length);
    beat = new[(1<<t.get_size())];
      for (int beat_cnt = 0; beat_cnt <= t.get_len();beat_cnt++) begin
        for (int byte_cnt = 0; byte_cnt < (1<<t.get_size());byte_cnt++) begin
          if (!data_mem.exists(current_addr)) begin
            data_mem[current_addr] = {$random};
          end  
          beat[byte_cnt] = data_mem[current_addr];
          current_addr += 1;
        end
        if(t.get_burst() == XIL_AXI_BURST_TYPE_WRAP) begin
           if (current_addr >= wrap_boundary + (number_bytes*burst_length)) begin
            current_addr = wrap_boundary + (current_addr - wrap_boundary - (number_bytes*burst_length));
          end
        end else if(t.get_burst() == XIL_AXI_BURST_TYPE_FIXED) begin
          current_addr = start_address;
        end else begin
          current_addr = current_addr;
        end  
        t.set_data_beat_unpacked(t.get_beat_index(),beat);
        t.increment_beat_index();
      end
      t.clr_beat_index();
  endfunction: fill_payload

  //fill beat delay into transaction
  function automatic void fill_beat_delay(inout axi_transaction t);
    integer unsigned              current_addr;
    xil_axi_uint                  beat_delay[];
    xil_axi_uint                  delay;
    
    current_addr  = t.get_addr();
    beat_delay = new[(1<<t.get_size())];
    for (int beat_cnt = 0; beat_cnt <= t.get_len();beat_cnt++) begin
      delay = {$urandom_range(0,10)};
      t.set_beat_delay(beat_cnt,delay);
    end
  endfunction: fill_beat_delay 

  // fill user info into transaction
  function automatic void fill_ruser(inout axi_transaction t);
    xil_axi_user_beat            ruser;
    for (int beat_cnt = 0; beat_cnt <= t.get_len();beat_cnt++) begin
      ruser = {$random};
      t.set_ruser(beat_cnt,ruser);
    end 
  endfunction: fill_ruser

  //fill reactive response for write transaction
  function automatic void fill_reactive(inout axi_transaction t);
    xil_axi_resp_t       bresp;
    xil_axi_user_beat  buser;
    buser = $urandom_range(0,1<< 0 -1);
    if( 1== 0) begin
      bresp = XIL_AXI_RESP_OKAY; 
    end else begin
      if(t.get_all_resp_okay() == XIL_AXI_TRUE) begin
        bresp = XIL_AXI_RESP_OKAY;
      end else begin
        if(t.get_axi_version() != XIL_VERSION_LITE) begin
           if (t.get_exclude_resp_exokay() == XIL_AXI_TRUE) begin
                void'(randomize(bresp)with{bresp inside {XIL_AXI_RESP_OKAY, XIL_AXI_RESP_DECERR, XIL_AXI_RESP_SLVERR };});
           end else begin
                bresp = XIL_AXI_RESP_DECERR;
           end
          end else begin
             void'(randomize(bresp) with {bresp inside {XIL_AXI_RESP_OKAY, XIL_AXI_RESP_DECERR, XIL_AXI_RESP_SLVERR};});
         end
      end
    end
    t.set_buser(buser);
    t.set_bresp(bresp);
  endfunction: fill_reactive

endmodule
