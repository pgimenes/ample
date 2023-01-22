//-------------------------------------------------------------------------------------------------------------
// Description: 
// This file contains example test which shows how Passthrough VIP in run time master mode generate transaction 
// and how Slave VIP (without memory model) responds
// The example design consists of one AXI VIP in master mode, one AXI VIP in passthrough mode 
// and one AXI VIP in slave mode.
// It includes master agent stimulus, slave memory agent stimulus and generic testbench file. 
// Please refer axil_master_vip_passthrough_mst_stimulus.sv for usage of Passthrough VIP in run time master mode
// generating stimulus
// Please refer axil_master_vip_slv_stimulus.sv for usage of Slave VIP agent responding
// Please refer axil_master_vip_exdes_generic.sv for simple scoreboarding,how to get monitor 
// transaction from Passthrough VIP monitor and Slave VIP monitor 
//-------------------------------------------------------------------------------------------------------------

`timescale 1ns / 1ps

`include "axil_master_vip_exdes_generic.sv"
`include "axil_master_vip_passthrough_mst_stimulus.sv"
`include "axil_master_vip_slv_stimulus.sv"

module axil_master_vip_exdes_adv_mst_passive__pt_mst__slv_comb(
  );
     
  // Clock signal
  bit                                     clock;
  // Reset signal
  bit                                     reset;
  // event to stop simulation
  event                                   done_event;


  axil_master_vip_exdes_generic  generic_tb();
  axil_master_vip_passthrough_mst_stimulus mst();
  axil_master_vip_slv_stimulus slv();

  // instantiate bd
  chip DUT(
      .aresetn(reset),
  
    .aclk(clock)
  );

  initial begin
    reset <= 1'b1;
  end
  
  always #10 clock <= ~clock;

endmodule

