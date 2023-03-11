parameter DATA_WIDTH = 32;

interface register_staller_simple_intf (

    input logic                  core_clk,
    input logic                  resetn,
    input logic                  in_valid,
    input logic [DATA_WIDTH-1:0] in_data,
    input logic                  in_ready,
    input logic                  out_valid,
    input logic [DATA_WIDTH-1:0] out_data,
    input logic                  out_ready
);



endinterface

bind register_staller_simple register_staller_simple_intf props (.*);