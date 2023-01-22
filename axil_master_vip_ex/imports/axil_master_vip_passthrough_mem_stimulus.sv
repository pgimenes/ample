/***************************************************************************************************
* Description:
* Considering different user cases, Passthrough VIP can be switched into either run time master
* mode or run time slave mode. When it is in run time slave mode, depends on situations, user may
* want to build their own memory model or using existing memory model.Passthrough VIP has two
* agents: passthrough_agent and passthrough_mem_agent to suit user needs.Passthrough_agent doesn't
* have memory model and user can build their own memory model and fill in write transaction and/or
* read transaction responses in their own way.Passthrough_mem_agent has memory model which user can
* use it directly.
* This file shows how Passthrough VIP switch into run time slave mode with memory model and
* basic features. 
* In order to make Passthrough VIP in run time slave mode with memory model work, user environment
* MUST have the lists of item below and follow this order.
*    1. import two packages.(this information also shows at the xgui of the VIP)
*         import axi_vip_pkg::* 
*         import <component_name>_pkg::*;
*    2. delcare <component_name>_passthrough_mem_t agent
*    3. new agent (passing instance IF correctly)
*    4. switch passthrough VIP into run time slave mode
*    5. start_slave
* As for ready generation, if user enviroment doesn't do anything, it will randomly generate ready
* siganl,if user wants to create his own ready signal, please refer task user_gen_wready 
***************************************************************************************************/

import axi_vip_pkg::*;
import ex_sim_axi_vip_passthrough_0_pkg::*;

module axil_master_vip_passthrough_mem_stimulus(
  );
 
  /*************************************************************************************************  * Declare <component_name>_passhthrough_mem_t for passthrough with memory model agent
  * <component_name> can be easily found in vivado bd design: click on the instance, 
  * Then click CONFIG under Properties window and Component_Name will be shown
  * More details please refer PG267 for more details
  *************************************************************************************************/
  ex_sim_axi_vip_passthrough_0_passthrough_mem_t          agent;
 
  /************************************************************************************************
  * Declare payload, address, data and strobe for back door memory write/read
  * xil_axi_ulong                                           mem_wr_addr;
  * xil_axi_ulong                                           mem_rd_addr;
  * bit[DATA_WIDTH-1:0]                                     mem_wr_data;
  * bit[(DATA_WIDTH/8)-1:0]                                 mem_wr_strb;
  * bit[DATA_WIDTH-1:0]                                     mem_rd_data;
  * bit[DATA_WIDTH-1:0]                                     mem_fill_payload;
  ***********************************************************************************************/

  xil_axi_ulong                                           mem_wr_addr;
  xil_axi_ulong                                           mem_rd_addr;
  bit[32-1:0]                              mem_wr_data;
  bit[(32/8)-1:0]                          mem_wr_strb;
  bit[32-1:0]                              mem_rd_data;
  bit[32-1:0]                              mem_fill_payload;


  initial begin
    /***********************************************************************************************
    * Before agent is newed, user has to run simulation with an empty testbench to find the
    * hierarchy path of the AXI VIP's instance.Message like
    * "Xilinx AXI VIP Found at Path: my_ip_exdes_tb.DUT.ex_design.axi_vip_mst.inst" will be printed 
    * out. Pass this path to the new function. 
    ***********************************************************************************************/
    agent = new("passthrough vip mem agent",DUT.ex_design.axi_vip_passthrough.inst.IF);
    
    /***********************************************************************************************    * Set tag for agents for easy debug especially multiple agents are called in one testbench
    ***********************************************************************************************/
    agent.set_agent_tag("My Passthrough VIP");

    /***********************************************************************************************    * Set verbosity of agent - default is no print out 
    * Verbosity level which specifies how much debug information to produce
    *    0       - No information will be printed out.
    *   400      - All information will be printed out
    ***********************************************************************************************/
    agent.set_verbosity(0);

    DUT.ex_design.axi_vip_passthrough.inst.set_slave_mode(); // Switch Passthrough VIP into run
                                                             // time slave mode
    agent.start_slave();                                     //Agent starts to run
   
    /***********************************************************************************************
    * Backdoor memory tasks
    * 1.fill fixed default value to memory 
    *    user can choose task set_mem_default_value_fixed or set_mem_default_value_rand
    *    in this testcase the former is being used
    * 2. do a backdoor memory write
    * 3. do a backdoor memory read
    ***********************************************************************************************/
    mem_fill_payload = 1;
    set_mem_default_value_fixed(mem_fill_payload); // Call task to do fill in memory with default fixed value
    mem_wr_data = 20;
    mem_wr_addr= 0;
    mem_wr_strb = 1;
    backdoor_mem_write(mem_wr_addr, mem_wr_data, mem_wr_strb); //Call task to do back doore memory wirte
    mem_rd_addr =0;
    backdoor_mem_read(mem_rd_addr, mem_rd_data);   // Call task to do back door memory read
    user_gen_awready();                                     //Generate awready
  end

  /*************************************************************************************************
  * Task user_gen_wready shows how passthrough VIP agent generates one customerized wready signal. 
  * declare axi_ready_gen  awready_gen
  * call create_ready from agent's slave write driver to create a new class of axi_ready_gen 
  * set the poicy of ready generation in this example, it select XIL_AXI_READY_GEN_OSC 
  * set low time 
  * set high time
  * agent's slave write driver send_awready out
  * ready generation policy are listed below:
  *  XIL_AXI_READY_GEN_NO_BACKPRESSURE     - Ready stays asserted and will not change. The driver
                                             will still check for policy changes.

  *   XIL_AXI_READY_GEN_SINGLE             - Ready stays 0 for low_time clock cycles and then
                                             dirves 1 until one ready/valid handshake occurs,
                                             the policy repeats until the channel is given
                                             different policy.
  *   XIL_AXI_READY_GEN_EVENTS             - Ready stays 0 for low_time clock cycles and then
                                             dirves 1 until event_count ready/valid handshakes
                                             occur,the policy repeats until the channel is given
                                             different policy.
  *   XIL_AXI_READY_GEN_OSC                - Ready stays 0 for low_time and then goes to 1 and      
                                             stays 1 for high_time,the policy repeats until the
                                             channel is given different policy.
  *   XIL_AXI_READY_GEN_RANDOM             - This policy generate random ready policy and uses
                                             min/max pair of low_time, high_time and event_count to
                                             generate low_time, high_time and event_count.
  *   XIL_AXI_READY_GEN_AFTER_VALID_SINGLE - This policy is active when VALID is detected to be
                                             asserted, Ready stays 0 for low_time clock cycles and
                                             then dirves 1 until one ready/valid handshake occurs,
                                             the policy repeats until the channel is given
                                             different policy.
  *   XIL_AXI_READY_GEN_AFTER_VALID_EVENTS - This policy is active when VALID is detected to be
                                             asserted, Ready stays 0 for low_time clock cycles and
                                             then dirves 1 until event_count ready/valid handshake
                                             occurs,the policy repeats until the channel is given
                                             different policy.
  *   XIL_AXI_READY_GEN_AFTER_VALID_OSC    - This policy is active when VALID is detected to be
                                             asserted, Ready stays 0 for low_time and then goes to
                                             1 and  stays 1 for high_time,the policy repeats until
                                             the channel is given different policy.
  *************************************************************************************************/
  task user_gen_awready();
    axi_ready_gen                           awready_gen;
    awready_gen = agent.slv_wr_driver.create_ready("awready");
    awready_gen.set_ready_policy(XIL_AXI_READY_GEN_OSC);
    awready_gen.set_low_time(1);
    awready_gen.set_high_time(2);
    agent.slv_wr_driver.send_awready(awready_gen);
  endtask : user_gen_awready

   /*************************************************************************************************
  *  Task set_mem_default_value_fixed is to first fill in memory with policy
  *   XIL_AXI_MEMORY_FILL_FIXED, then it will fill in default memory value with
  *   input bit[DATA_WIDTH-1:0] fill_payload
  *   Note: user has to make sure that fill_payload is DATA_WIDTH wide bit to match
  *   memory model width. 
  *************************************************************************************************/
  task set_mem_default_value_fixed(input bit [32-1:0] fill_payload);
    agent.mem_model.set_memory_fill_policy(XIL_AXI_MEMORY_FILL_FIXED);
    agent.mem_model.set_default_memory_value(fill_payload);
  endtask

  /*************************************************************************************************
  * Task set_mem_default_value_rand is to fill in memory with policy
  * XIL_AXI_MEMORY_FILL_RADNOM, default memory value will be randomized generated
  * when the address is being accessed 
  *************************************************************************************************/
  task set_mem_default_value_rand();
    agent.mem_model.set_memory_fill_policy(XIL_AXI_MEMORY_FILL_RANDOM);
  endtask

  /*************************************************************************************************
  * Task backdoor_mem_write shows how to write to some address of memory with data and strobe 
  * information.
  * User has to make sure that the inputs to this task has to follow below rules to match
  * memory width, also user has to make sure that strobe bits can not be asserted on if lower 
  * than the address offset.
  * Address offset calculation is: address offset = address &((1 << (log2(DATA_WIDTH/8)) -1))
  *  input xil_axi_ulong                         addr, 
  *  input bit [DATA_WIDTH-1:0]                  wr_data
  *  input bit [(DATA_WIDTH/8)-1:0]              wr_strb 
  *************************************************************************************************/
  task backdoor_mem_write(
    input xil_axi_ulong                         addr, 
    input bit [32-1:0]           wr_data,
    input bit [(32/8)-1:0]       wr_strb ={(32/8){1'b1}}
  );
    agent.mem_model.backdoor_memory_write(addr, wr_data, wr_strb);

  endtask

  /*************************************************************************************************
  * Task backdoor_mem_read shows how user can do backdoor read data from memory model
  * it has one input which is backdoor memory read address and one output which is read out data
  * User has to note to declare memory read address and data like below
  * input xil_axi_ulong mem_rd_addr,
  * output bit [DATA_WIDTH-1:0] mem_rd_data 
  *************************************************************************************************/
  task backdoor_mem_read(
    input xil_axi_ulong mem_rd_addr,
    output bit [32-1:0] mem_rd_data
   );
    mem_rd_data= agent.mem_model.backdoor_memory_read(mem_rd_addr);

  endtask

endmodule
