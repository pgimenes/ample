//----------------------------------------------------------------------------------------------
// Description: 
// This file contains example test lists for one design which consistes of one AXI VIP
// in master mode, one AXI VIP in passthrough mode and one AXI VIP in slave mode.
// In the following scenarios,It demonstrates how master AXI VIP create transactions, slave AXI VIP 
// generate responses and also how passthrough AXI VIP switch into run time master or/and slave mode.
// It also has two simple scoreboards to do self-checking. One scoreboard checks master AXI VIP against
// passthrough AXI VIP and the other scoreboard checks slave AXI VIP against passthrough AXI VIP
// Three methods to setup the transaction after it is being created are done in some of the example tests

import axi_vip_pkg::*;

module axil_master_vip_exdes_generic(
  );

  typedef enum {
    EXDES_PASSTHROUGH,
    EXDES_PASSTHROUGH_MASTER,
    EXDES_PASSTHROUGH_SLAVE
  } exdes_passthrough_t;

  exdes_passthrough_t                     exdes_state = EXDES_PASSTHROUGH;

  // Error count to check how many comparison failed
  xil_axi_uint                            error_cnt = 0; 
  // Comparison count to check how many comparsion happened
  xil_axi_uint                            comparison_cnt = 0;


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
  // monitor transaction for slave VIP
  axi_monitor_transaction                 slv_monitor_transaction;
  // monitor transaction queue for slave VIP
  axi_monitor_transaction                 slave_moniter_transaction_queue[$];
  // size of slave_moniter_transaction_queue
  xil_axi_uint                            slave_moniter_transaction_queue_size =0;
  // scoreboard transaction from slave monitor transaction queue
  axi_monitor_transaction                 slv_scb_transaction;


  // master vip monitors all the transaction from interface and put then into transaction queue
  initial begin
    #2ps;
    mst_monitor_transaction = new("master monitor transaction");
    forever begin
      mst.agent.monitor.item_collected_port.get(mst_monitor_transaction);
      if(mst_monitor_transaction.get_cmd_type() == XIL_AXI_READ) begin
        monitor_rd_data_method_one(mst_monitor_transaction);
        monitor_rd_data_method_two(mst_monitor_transaction);
      end  
      master_moniter_transaction_queue.push_back(mst_monitor_transaction);
      master_moniter_transaction_queue_size++;
    end  
  end 

  // slave vip monitors all the transaction from interface and put then into transaction queue 
  initial begin
    #2ps;
    slv_monitor_transaction = new("slave monitor transaction");
    forever begin
      slv.agent.monitor.item_collected_port.get(slv_monitor_transaction);
      slave_moniter_transaction_queue.push_back(slv_monitor_transaction);
      slave_moniter_transaction_queue_size++;
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
        wait( master_moniter_transaction_queue_size>0) begin
          mst_scb_transaction = master_moniter_transaction_queue.pop_front;
          master_moniter_transaction_queue_size--;
          if (slv_scb_transaction.do_compare(mst_scb_transaction) == 0) begin
            $display("ERROR: Slave VIP against Master VIP scoreboard Compare failed");
            error_cnt++;
          end else begin
            $display("SUCCESS: Slave VIP against Master VIP scoreboard Compare passed");
          end
          comparison_cnt++;
        end  
      end 
    end
  end
 
  
  /*************************************************************************************************
  * There are two ways to get read data. One is to get it through the read driver of master agent
  * (refer to driver_rd_data_method_one, driver_rd_data_method_two in *mst_stimulus.sv file).
  * The other is to get it through the monitor of VIP,  
  * To get data from monitor, follow these steps:
  * step 1: Get the monitor transaction from item_collected_port. In this example, it comes 
  * from the master agent.
  * step 2: If the cmd type is XIL_AXI_READ in the monitor transaction, use get_data_beat,
  * get_data_block to get the read data. If the cmd type is XIL_AXI_WRITE in the monitor
  * transaction, use get_data_beat, get_data_block to get the write data
  *
  * monitor_rd_data_method_one shows how to get a data beat through the monitor transaction
  * monitor_rd_data_method_two shows how to get data block through the monitor transaction
  * 
  * Note on API get_data_beat: get_data_beat returns the value of the specified beat. 
  * It always returns 1024 bits. It aligns the signification bytes to the lower 
  * bytes and sets the unused bytes to zeros.
  * This is NOT always the RDATA representation. If the data width is 32-bit and 
  * the transaction is sub-size burst (1B in this example), only the last byte of 
  * get_data_beat is valid. This is very different from the Physical Bus.
  * 
  * get_data_bit             Physical Bus
  * 1024  ...      0          32        0
  * ----------------         -----------
  * |             X|         |        X| 
  * |             X|         |      X  |
  * |             X|         |    X    |
  * |             X|         | X       |
  * ----------------         -----------
  *
  * Note on API get_data_block: get_data_block returns 4K bytes of the payload
  * for the transaction. This is NOT always the RDATA representation.  If the data
  * width is 32-bit and the transaction is sub-size burst (1B in this example),
  * It will align the signification bytes to the lower bytes and set the unused 
  * bytes to zeros.
  *
  *   get_data_block          Physical Bus
  *   32    ...      0         32        0
  * 0 ----------------         -----------
  *   | D   C   B   A|         |        A| 
  *   | 0   0   0   0|         |      B  |
  *   | 0   0   0   0|         |    C    |
  *   | 0   0   0   0|         | D       |
  *   | 0   0   0   0|         -----------
  *   | 0   0   0   0|         
  * 1k----------------         
  *
  *************************************************************************************************/
  task monitor_rd_data_method_one(input axi_monitor_transaction updated);
    xil_axi_data_beat                       mtestDataBeat[];
    mtestDataBeat = new[updated.get_len()+1];
    for( xil_axi_uint beat=0; beat<updated.get_len()+1; beat++) begin
      mtestDataBeat[beat] = updated.get_data_beat(beat);
    //  $display(" Read data from Monitor: beat index %d, Data beat %h", beat, mtestDataBeat[beat]);
    end  
  endtask

  task monitor_rd_data_method_two(input axi_monitor_transaction updated);
    bit[8*4096-1:0]                         data_block;
    data_block = updated.get_data_block();
  //  $display(" Read data from Monitor: Block Data %h ", data_block);
  endtask


endmodule
