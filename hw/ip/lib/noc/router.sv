import noc_pkg::*;

module router (
    input  logic core_clk,
    input  logic resetn,

    input  logic  in_west_valid,
    output logic  in_west_ready,
    input  flit_t in_west,
    
    output logic  out_west_valid,
    input  logic  out_west_ready,
    output flit_t out_west,

    input  logic  in_east_valid,
    output logic  in_east_ready,
    input  flit_t in_east,

    output logic  out_east_valid,
    input  logic  out_east_ready,
    output flit_t out_east,

    input  logic  in_local_valid,
    output logic  in_local_ready,
    input  flit_t in_local,    
    
    output logic  out_local_valid,
    input  logic  out_local_ready,
    output flit_t out_local
);

// ================================================
// Logic
// ================================================

// Internal connections
// --------------------------------------------

logic  west_internal_out_valid;
logic  west_internal_out_ready;
flit_t west_internal_out;

logic  east_internal_out_valid;
logic  east_internal_out_ready;
flit_t east_internal_out;

logic  local_internal_out_valid;
logic  local_internal_out_ready;
flit_t local_internal_out;

// ================================================
// Instances
// ================================================

port west_port (
    .core_clk,
    .resetn,

    .external_in_valid  (in_west_valid),
    .external_in_ready  (in_west_ready),
    .external_in_data   (in_west),
    
    .external_out_valid (out_west_valid),
    .external_out_ready (out_west_ready),
    .external_out_data  (out_west),

    .internal_in_0_valid (east_internal_out),
    .internal_in_0_ready (east_internal_out),
    .internal_in_0_data  (east_internal_out),
    
    .internal_in_1_valid    (local_internal_out),
    .internal_in_1_ready    (local_internal_out),
    .internal_in_1_data     (local_internal_out),

    .internal_out_valid     (west_internal_out_valid),
    .internal_out_ready     (west_internal_out_ready),
    .internal_out_data      (west_internal_out)
);

port east_port (
    .core_clk,
    .resetn,

    .external_in_valid  (in_east_valid),
    .external_in_ready  (in_east_ready),
    .external_in_data   (in_east),
    
    .external_out_valid (out_east_valid),
    .external_out_ready (out_east_ready),
    .external_out_data  (out_east),

    .internal_in_0_valid (west_internal_out),
    .internal_in_0_ready (west_internal_out),
    .internal_in_0_data  (west_internal_out),
    
    .internal_in_1_valid    (local_internal_out),
    .internal_in_1_ready    (local_internal_out),
    .internal_in_1_data     (local_internal_out),

    .internal_out_valid     (east_internal_out_valid),
    .internal_out_ready     (east_internal_out_ready),
    .internal_out_data      (east_internal_out)
);

port local_port (
    .core_clk,
    .resetn,

    .external_in_valid  (in_local_valid),
    .external_in_ready  (in_local_ready),
    .external_in_data   (in_local),
    
    .external_out_valid (out_local_valid),
    .external_out_ready (out_local_ready),
    .external_out_data  (out_local),

    .internal_in_0_valid (west_internal_out),
    .internal_in_0_ready (west_internal_out),
    .internal_in_0_data  (west_internal_out),
    
    .internal_in_1_valid    (east_internal_out),
    .internal_in_1_ready    (east_internal_out),
    .internal_in_1_data     (east_internal_out),

    .internal_out_valid     (local_internal_out_valid),
    .internal_out_ready     (local_internal_out_ready),
    .internal_out_data      (local_internal_out)
);

endmodule