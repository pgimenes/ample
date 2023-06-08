import axi_vip_pkg::*;
import axil_master_vip_pkg::*;
import json::*;
// import axi_memory_master_vip_pkg::*;

`define AXIL_MASTER_VIP_IF top_tb.axil_master_vip_i.inst.IF
class Test;

    virtual node_scoreboard_interface nsb_intf;
    virtual aggregation_engine_interface age_intf;
    virtual prefetcher_interface prefetcher_intf;

    virtual agc_allocator_interface agc_allocator_float_intf;
    virtual agm_interface agm_intf;
    virtual agc_interface agc_intf;
    virtual bm_interface bm_intf;

    axil_master_vip_mst_t axil_agent;
    
    // Environment
    node_scoreboard_tb_monitor nsb_monitor_i;
    aggregation_engine_tb_monitor age_monitor_i;
    prefetcher_tb_monitor prefetcher_monitor_i;

    agc_allocator_monitor agc_allocator_float_monitor_i;
    agm_monitor agm_monitor_i;
    agc_monitor agc_monitor_i;
    bm_monitor bm_monitor_i;
    
    logic [63:0] busy_nodeslots_mask;
    string TESTNAME;

    protected Object layers;
    protected Object nodeslots;

    Node_Scoreboard sb;

    function new(virtual node_scoreboard_interface nsb_intf,
        virtual aggregation_engine_interface age_intf,
        virtual prefetcher_interface prefetcher_intf,
        virtual agc_allocator_interface agc_allocator_float_intf
        // virtual agm_interface agm_intf,
        // virtual agc_interface agc_intf,
        // virtual bm_interface bm_intf
        );

        // Interfaces
        this.nsb_intf = nsb_intf;
        this.age_intf = age_intf;
        this.prefetcher_intf = prefetcher_intf;

        this.agc_allocator_float_intf = agc_allocator_float_intf;
        // this.agm_intf = agm_intf;
        // this.agc_intf = agc_intf;
        // this.bm_intf = bm_intf;

        $display("[TIMESTAMP]: %d, [TOP_TEST::INFO]: Starting simulation", $time);

`ifdef DRAM_MODEL
        // Wait for DDR4 calibration to complete
        wait(ddr4_c0_init_calib_complete);
        $display("[TIMESTAMP]: %d, DDR4 C0 Calibration Complete", $time);
`endif

        // Initialize AXI-L agent
        this.axil_agent = new("AXI-L VIP Agent", `AXIL_MASTER_VIP_IF);

        // Initialize AXI Memory Master VIP agent
        // this.axi_memory_agent = new("AXI Memory Master VIP Agent", `AXI_MEMORY_MASTER_VIP_IF);

        // Initialize nodeslots mask as all free
        this.busy_nodeslots_mask = '0;
        this.sb = new();

        // Environment
        this.nsb_monitor_i        = new(this.nsb_intf, sb);
        this.age_monitor_i        = new(this.age_intf, sb);
        this.prefetcher_monitor_i = new(this.prefetcher_intf, sb);

        this.agc_allocator_float_monitor_i = new(this.agc_allocator_float_intf, top_pkg::FIXED_8, sb);
        // this.agm_monitor_i                 = new(this.agm_intf, top_pkg::FIXED_8, 4, 0, sb);
        // this.agc_monitor_i                 = new(this.agc_intf, top_pkg::FIXED_8, 0, 0, sb);
        // this.bm_monitor_i                  = new(this.bm_intf, top_pkg::FIXED_8, 0, 8, sb);

        this.nodeslots = new();
        this.layers = new();
    endfunction

    task automatic start_environment();
        // Initialize AXI VIP agents
        $display("[TIMESTAMP]: %t, [CORE_TEST::DEBUG]: Ready to initialize AXI-L Master.", $time);
        this.axil_agent.start_master();
        $display("[TIMESTAMP]: %t, [CORE_TEST::DEBUG]: Done initializing AXI-L Master.", $time);

        // Run monitors
        fork
            this.nsb_monitor_i.main();
            this.age_monitor_i.main();
            this.prefetcher_monitor_i.main();

            this.agc_allocator_float_monitor_i.main();
            // this.agm_monitor_i.main();
            // this.agc_monitor_i.main();
            // this.bm_monitor_i.main();
        join
    endtask

    task automatic axil_write ( 
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
        wr_trans = this.axil_agent.wr_driver.create_transaction(name);
        wr_trans.set_write_cmd(addr,burst,id,len,size);
        wr_trans.set_prot(prot);
        wr_trans.set_lock(lock);
        wr_trans.set_cache(cache);
        wr_trans.set_region(region);
        wr_trans.set_qos(qos);
        wr_trans.set_data_block(data);
        this.axil_agent.wr_driver.send(wr_trans);

    endtask  : axil_write

    task automatic axil_read ( 
                                input string                     name ="single_read",
                                input xil_axi_uint               id =0, 
                                input xil_axi_ulong              addr =0,
                                input xil_axi_len_t              len =0, 
                                input xil_axi_size_t             size =xil_axi_size_t'(xil_clog2((32)/8)),
                                input xil_axi_burst_t            burst =XIL_AXI_BURST_TYPE_INCR,
                                input xil_axi_lock_t             lock =XIL_AXI_ALOCK_NOLOCK ,
                                input xil_axi_cache_t            cache =0,
                                input xil_axi_prot_t             prot =0,
                                input xil_axi_region_t           region =0,
                                input xil_axi_qos_t              qos =0,
                                input xil_axi_data_beat          aruser =0,
                                
                                // Response beats
                                output xil_axi_data_beat Rdatabeat []
    );
        axi_transaction rd_trans;
        Rdatabeat = new[0];
        rd_trans = this.axil_agent.rd_driver.create_transaction(name);
        rd_trans.set_read_cmd(addr,burst,id,len,size);
        rd_trans.set_prot(prot);
        rd_trans.set_lock(lock);
        rd_trans.set_cache(cache);
        rd_trans.set_region(region);
        rd_trans.set_qos(qos);
        this.get_rd_data_beat_back(rd_trans, Rdatabeat);
  endtask  : axil_read

    /************************************************************************************************
    * Task send_wait_rd is a task which set_driver_return_item_policy of the read transaction, 
    * send the transaction to the driver and wait till it is done
    *************************************************************************************************/
    task send_wait_rd(inout axi_transaction rd_trans);
        rd_trans.set_driver_return_item_policy(XIL_AXI_PAYLOAD_RETURN);
        this.axil_agent.rd_driver.send(rd_trans);
        this.axil_agent.rd_driver.wait_rsp(rd_trans);
    endtask

    /************************************************************************************************
    * Task get_rd_data_beat_back is to get read data back from read driver with
    *  data beat format.
    *************************************************************************************************/
    task get_rd_data_beat_back(inout axi_transaction rd_trans, 
                                    output xil_axi_data_beat Rdatabeat[]
                            );  
        this.send_wait_rd(rd_trans);
        Rdatabeat = new[rd_trans.get_len()+1];
        for( xil_axi_uint beat=0; beat<rd_trans.get_len()+1; beat++) begin
            Rdatabeat[beat] = rd_trans.get_data_beat(beat);
        end
    endtask

    task delay(integer cycle_count);
        repeat (cycle_count) @(posedge this.nsb_intf.core_clk);
    endtask

endclass