//Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2019.2.1 (lin64) Build 2729669 Thu Dec  5 04:48:12 MST 2019
//Date        : Sun Jan 22 15:42:48 2023
//Host        : ee-mill3.ee.ic.ac.uk running 64-bit CentOS Linux release 7.9.2009 (Core)
//Command     : generate_target ex_sim_wrapper.bd
//Design      : ex_sim_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module ex_sim_wrapper
   (aclk,
    aresetn);
  input aclk;
  input aresetn;

  wire aclk;
  wire aresetn;

  ex_sim ex_sim_i
       (.aclk(aclk),
        .aresetn(aresetn));
endmodule
