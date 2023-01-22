
`timescale 1 ps / 1 ps

module chip
   (
    aresetn,
  
    aclk
    );
  input aclk;
  input aresetn;
  

  wire aclk;
  wire aresetn;
  

  ex_sim ex_design
       (
        .aresetn(aresetn),
  
        .aclk(aclk)
        );
endmodule

