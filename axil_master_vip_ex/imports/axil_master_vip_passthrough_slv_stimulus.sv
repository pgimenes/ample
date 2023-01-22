/***************************************************************************************************
* Description: 
* Considering different user cases, Passthrough VIP can be switched into either run time master
* mode or run time slave mode. When it is in run time slave mode, depends on situations, user may
* want to build their own memory model or using existing memory model. Passthrough VIP has two
* agents: passthrough_agent and passthrough_mem_agent.Passthrough_agent doesn't have memory model
* and user can build their own memory model and fill in write transaction and/or read transaction
* responses in their own way.Passthrough_mem_agent has memory model which user can use it directly.
* This file contains example on how Passthrough VIP switch into run time slave mode without 
* memory model responds 
* For Passthrough VIP in run time slave mode to work correctly, user environment MUST have the
* lists of item below and follow this order.
*    1. import two packages.(this information also shows at the xgui of the VIP)
*         import axi_vip_pkg::* 
*         import <component_name>_pkg::*;
*    2. delcare <component_name>_passthrough_t agent
*    3. new agent (passing instance IF correctly)
*    4. switch passthrough mode into run time slave mode
*    5. start_slave
*    6. wr/rd_response/ready_gen
* As for ready generation, if user enviroment doesn't do anything, it will randomly generate ready
* siganl, if user wants to create his own ready signal, please refer task user_gen_wready 
***************************************************************************************************/

import axi_vip_pkg::*;
import ex_sim_axi_vip_passthrough_0_pkg::*;

module axil_master_vip_passthrough_slv_stimulus(
  );
  /*************************************************************************************************
  * Description: byte based memory model 
  * Data_mem is associated array for memory model. It's size can be infinitely theorically.
  * User can load all data into data_mem as they want.
  * In this simple example. Memory is empty until a read response occurs and 
  * data is being filled into memory whenever an address is being read.
  * Read data channel uses data_mem[addr] if it exist, otherwise, it generates randomized data
  *************************************************************************************************/
  xil_axi_payload_byte                    data_mem[xil_axi_ulong];

  /*************************************************************************************************
  * Declare <component_name>_passthrough_t for passthrough agent
  * <component_name> can be easily found in vivado bd design: click on the instance, 
  * Then click CONFIG under Properties window and Component_Name will be shown
  * More details please refer PG267 for more details
  *************************************************************************************************/

  ex_sim_axi_vip_passthrough_0_passthrough_t              agent;

  initial begin
    /***********************************************************************************************    * Before agent is newed, user has to run simulation with an empty testbench to find the
    * hierarchy path of the AXI VIP's instance.Message like
    * "Xilinx AXI VIP Found at Path: my_ip_exdes_tb.DUT.ex_design.axi_vip_mst.inst" will be printed 
    * out. Pass this path to the new function. 
    ***********************************************************************************************/
    agent = new("passthrough vip agent",DUT.ex_design.axi_vip_passthrough.inst.IF);

    /***********************************************************************************************    * Set tag for agents for easy debug especially multiple agents are called in one testbench
    ***********************************************************************************************/
    agent.set_agent_tag("My Passthrough VIP");

    /***********************************************************************************************    * Set verbosity of agent - default is no print out 
    * Verbosity level which specifies how much debug information to produce
    *    0       - No information will be printed out.
    *   400      - All information will be printed out
    ***********************************************************************************************/
    agent.set_verbosity(0);

    DUT.ex_design.axi_vip_passthrough.inst.set_slave_mode();  //Switch passthrough VIP into 
                                                              // run time slave mode
    agent.start_slave();                                     //agent starts to run

    //Fork off arready generation and write/read response
    fork
      user_gen_arready();
      wr_response();
      rd_response();
    join_none

  end

  /*************************************************************************************************
  * Task user_gen_wready shows how slave VIP agent generates one customerized arready signal. 
  * declare axi_ready_gen  arready_gen
  * call create_ready from agent's write driver to create a new class of axi_ready_gen 
  * set the poicy of ready generation in this example, it select XIL_AXI_READY_GEN_OSC 
  * set low time 
  * set high time
  * agent's write driver send_arready out
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
  task user_gen_arready();
    axi_ready_gen                           arready_gen;
    arready_gen = agent.slv_rd_driver.create_ready("arready");
    arready_gen.set_ready_policy(XIL_AXI_READY_GEN_OSC);
    arready_gen.set_low_time(1);
    arready_gen.set_high_time(2);
    agent.slv_rd_driver.send_arready(arready_gen);
  endtask
  
  /*************************************************************************************************
  * wr_response: Task which slave write driver in slave agent waits till it sees a write transaction
  * and then user enviroment fill in write response, write driver send it over to VIP interface
  * When slave VIP is configured in READ_WRITE/WRITE_ONLY mode,user environment must call this task
  * Otherwise, the simulation will hang there waiting for BRESP from slave till time out.
  *************************************************************************************************/
  task wr_response();
    axi_transaction                         wr_reactive;
    forever begin  :slv_run
      agent.slv_wr_driver.get_wr_reactive(wr_reactive);
      fill_wr_reactive(wr_reactive);
      agent.slv_wr_driver.send(wr_reactive);
    end
  endtask

  /*************************************************************************************************
  * rd_response: Task which slave read driver in slave agent waits till it sees a read transaction
  * and then user enviroment fill in read data channel,read driver send it over to VIP interface
  * When slave VIP is configured in READ_WRITE/READ_ONLY mode,user environment must call this task
  * Otherwise, the simulation will hang there waiting for data channel from slave till time out.
  *************************************************************************************************/
  task rd_response();
    axi_transaction                         rd_reactive;
    forever begin
      agent.slv_rd_driver.get_rd_reactive(rd_reactive);
      fill_rd_reactive(rd_reactive);
      agent.slv_rd_driver.send(rd_reactive);
    end  
  endtask

  /*************************************************************************************************
  * Fill_rd_reactive: Task fills in data and user(when RUSR_WIDH>0) info for read data channel
  * Fill data into transaction according to related address of the transaction and 
  * existence in memory
  * Fill in user into transaction when RUSER width is bigger than 0
  * When fill in data information, user has to take into account address, burst type, length 
  * and size
  *************************************************************************************************/
  function automatic void fill_rd_reactive(inout axi_transaction t);
    longint unsigned               current_addr;     //Declare current address of the transaction
    longint unsigned               addr_max;         //Declare maximum address of the transaction
    xil_axi_payload_byte           beat[];           //Declare dynamic array of beat 
    xil_axi_uint                   start_address;    //Declare start address of the transaction
    xil_axi_uint                   number_bytes;     //Declare number of bytes of the transaction
    xil_axi_uint                   burst_length;     //Declare burst length of the transaction
    xil_axi_uint                   wrap_boundary;    //Declare wrap boundry of the transaction
    xil_axi_uint                   bytes_in_burst;   //Declare number of bytes in each burst
    xil_axi_user_beat              ruser;            //Declare ruser of the transaction


    current_addr   = t.get_addr();                   //Assign current address
    start_address  = t.get_addr();                   //Assign start address
    number_bytes   = (1<<t.get_size());              //Get number of bytes of beat
    burst_length   = t.get_len() + 1;                //Get burst length of the transaction
    bytes_in_burst = number_bytes * burst_length ;
    //Calculate wrap boundry 
    wrap_boundary = (start_address/(bytes_in_burst)) * (bytes_in_burst);
    beat = new[number_bytes];                  //Allocating size for beat 
    /***********************************************************************************************
    *  Below code is filling in read data byte by byte from data_mem 
    *  Transaction has differnt burst type and all being taken into account 
    ***********************************************************************************************/
    //For loop for whole burst
    for (int beat_cnt = 0; beat_cnt < burst_length; beat_cnt++) begin
      //For loop for one beat, it has busrt_size bytes. each byte will be assigned 
      //value from related data_mem
      for (int byte_cnt = 0; byte_cnt < number_bytes ; byte_cnt++) begin
        // If current_addr doesn't exists in the memory, get a randomzied value.
        if (!data_mem.exists(current_addr)) begin
          data_mem[current_addr] = {$random};
        end 
        //Data assignment
        beat[byte_cnt] = data_mem[current_addr];
        //increment current_addr
        current_addr += 1;
      end
      //If burst type is WRAP and current_addr increments higher than
      // (wrap boundry+1)*(bytes_in_burst), wrap current address to the lowest address  
      if(t.get_burst() == XIL_AXI_BURST_TYPE_WRAP) begin
        if (current_addr >= ((wrap_boundary +1)*(bytes_in_burst))) begin
          current_addr = wrap_boundary * (bytes_in_burst);
        end else begin
          current_addr = current_addr;
        end 
      //If burst type is FIXED, address is fixed  
      end else if(t.get_burst() == XIL_AXI_BURST_TYPE_FIXED) begin
        current_addr = start_address;
      //If burst type is INCR,address keep incrementing
      end else if(t.get_burst() == XIL_AXI_BURST_TYPE_INCR) begin
        current_addr = current_addr;
      // If burst type is none of the above. something is wrong  
      end else begin
        $fatal(0,"Read transaction burst type is out of range");
      end
      // set beat to specified beat index 
      t.set_data_beat_unpacked(t.get_beat_index(),beat);
      // Increment beat_index
      t.increment_beat_index();
    end
    //Clear beat index 
    t.clr_beat_index();
  endfunction: fill_rd_reactive


  /*************************************************************************************************
  * Fill_wr_reactive: Task fills in BREPS,BUSER(when BUSER_WIDTH>0) and bresp_delay for write
  * response channel.
  * This task show simple example so buser is being set to 0 and bresp is XIL_AXI_RESP_OKAY
  * Fill in all these information into reactive response.
  *************************************************************************************************/
  function automatic void fill_wr_reactive(inout axi_transaction t);
    t.set_bresp(XIL_AXI_RESP_OKAY);
  endfunction: fill_wr_reactive

 
endmodule
