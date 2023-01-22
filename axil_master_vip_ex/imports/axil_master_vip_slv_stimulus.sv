/**************************************************************************************************** Description:
* Considering different user cases, Slave VIP has two agents: slv_agent and slv_mem_agent.
* Slv_agent doesn't have memory model and user can build their own memory model and fill in write
* transaction and/or read transaction responses in their own way.slv_mem_agent has memory model
* which user can use it directly.
* This file contains example on how Slave VIP withput memory model responds 
* For Slave VIP to work correctly, user environment MUST have the lists of item below and follow
* this order.
*    1. import two packages.(this information also shows at the xgui of the VIP)
*         import axi_vip_pkg::* 
*         import <component_name>_pkg::*;
*    2. delcare <component_name>_slv_t agent
*    3. new agent (passing instance IF correctly)
*    4. start_slave
* As for ready generation, if user enviroment doesn't do anything, it will randomly generate ready
* siganl,if user wants to create his own ready signal, please refer task user_gen_wready. 
***************************************************************************************************/
import axi_vip_pkg::*;
import ex_sim_axi_vip_slv_0_pkg::*;

module axil_master_vip_slv_stimulus(
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

  /*************************************************************************************************  * Declare <component_name>_slv_t for slave mem agent
  * <component_name> can be easily found in vivado bd design: click on the instance, 
  * Then click CONFIG under Properties window and Component_Name will be shown
  * More details please refer PG267 for more details
  *************************************************************************************************/
  ex_sim_axi_vip_slv_0_slv_t              agent;

  initial begin
    /***********************************************************************************************    * Before agent is newed, user has to run simulation with an empty testbench to find the
    * hierarchy path of the AXI VIP's instance.Message like
    * "Xilinx AXI VIP Found at Path: my_ip_exdes_tb.DUT.ex_design.axi_vip_mst.inst" will be printed 
    * out. Pass this path to the new function. 
    ***********************************************************************************************/
    agent = new("slave vip agent",DUT.ex_design.axi_vip_slv.inst.IF);
    
   /***********************************************************************************************    * Set tag for agents for easy debug especially multiple agents are called in one testbench
   ************************************************************************************************/
    agent.set_agent_tag("My Slave VIP");

    /***********************************************************************************************
    * Set verbosity of agent - default is no print out 
    * Verbosity level which specifies how much debug information to produce
    *    0       - No information will be printed out.
    *   400      - All information will be printed out
    ***********************************************************************************************/
    agent.set_verbosity(0);                                  // set verbosity of agent
    agent.start_slave();                                     //agent starts to run

    //fork off the process of awready generation, write response and read response
    fork
      user_gen_awready();
      wr_response();
      rd_response();
    join_none
  end

  /*************************************************************************************************
  * Task user_gen_awready shows how slave VIP agent generates one customerized awready signal. 
  * Declare axi_ready_gen  awready_gen
  * Call create_ready from agent's write driver to create a new class of axi_ready_gen 
  * Set the poicy of ready generation in this example, it select XIL_AXI_READY_GEN_OSC 
  * Set low time 
  * Set high time
  * Agent's write driver send_awready out
  * Ready generation policy are listed below:
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
    awready_gen = agent.wr_driver.create_ready("awready");
    awready_gen.set_ready_policy(XIL_AXI_READY_GEN_OSC);
    awready_gen.set_low_time(1);
    awready_gen.set_high_time(2);
    agent.wr_driver.send_awready(awready_gen);
  endtask

 
  /*************************************************************************************************
  * wr_response: Task which write driver in slave agent waits till it sees a write transaction
  * and then user enviroment fill in write response, write driver send it over to VIP interface
  * When slave VIP is configured in READ_WRITE/WRITE_ONLY mode,user environment must call this task
  * Otherwise, the simulation will hang there waiting for BRESP from slave till time out.
  *************************************************************************************************/
  task wr_response();
    axi_transaction                         wr_reactive;
    forever begin  :slv_run
      agent.wr_driver.get_wr_reactive(wr_reactive);
      fill_wr_reactive(wr_reactive);
      agent.wr_driver.send(wr_reactive);
    end
  endtask

  /*************************************************************************************************
  * rd_response: Task which read driver in slave agent waits till it sees a read transaction
  * and then user enviroment fill in read data channel,read driver send it over to VIP interface
  * When slave VIP is configured in READ_WRITE/READ_ONLY mode,user environment must call this task
  * Otherwise, the simulation will hang there waiting for data channel from slave till time out.
  *************************************************************************************************/
  task rd_response();
    axi_transaction                         rd_reactive;
    forever begin
      agent.rd_driver.get_rd_reactive(rd_reactive);
      fill_rd_reactive(rd_reactive);
      agent.rd_driver.send(rd_reactive);
    end  
  endtask

  /*************************************************************************************************
  * Fill_rd_reactive: Task fills in data and user(when RUSR_WIDH>0) info for read data channel
  * Fill data into transaction according to related address of the transaction and 
  * existence in memory
  * Fill in user into transaction when RUSER width is bigger than 0
  * When fill in data information, user has to take into account address, burst type, length 
  * and size
  *************************************************************************************************/  function automatic void fill_rd_reactive(inout axi_transaction t);
    longint unsigned                 current_addr;
    longint unsigned                 addr_max;  
    xil_axi_payload_byte             beat[];
    xil_axi_uint                     start_address;
    xil_axi_uint                     number_bytes;
    xil_axi_uint                     aligned_address;
    xil_axi_uint                     burst_length;
    xil_axi_uint                     address_n;
    xil_axi_uint                     wrap_boundary;
    xil_axi_user_beat                ruser;

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

  endfunction: fill_rd_reactive


  /*************************************************************************************************
  * Fill_wr_reactive: Task fills in BREPS,BUSER(when BUSER_WIDTH>0) for write response channel
  * This task show simple example so buser is being set to 0 and bresp is XIL_AXI_RESP_OKAY
  * Fill in all these information into reactive response
  *************************************************************************************************/
  function automatic void fill_wr_reactive(inout axi_transaction t);
    xil_axi_resp_t       bresp;
    xil_axi_user_beat    buser;
    xil_axi_uint         bresp_delay;
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
  endfunction: fill_wr_reactive

endmodule
