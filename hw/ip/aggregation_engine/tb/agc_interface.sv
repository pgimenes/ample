import noc_pkg::*;

interface agc_interface (
    input logic core_clk,
    input logic resetn,

    // Allocation interface
    input  logic                                        aggregation_core_free,

    // Aggregation Core -> Router
    input  logic                                        aggregation_core_router_on,
    input  logic                                        aggregation_core_router_valid,
    input  logic                                        aggregation_core_router_ready,
    input  flit_t                                       aggregation_core_router_data,

    // Router -> Aggregation Core
    input  logic                                        router_aggregation_core_on,
    input  logic                                        router_aggregation_core_valid,
    input  logic                                        router_aggregation_core_ready,
    input  flit_t                                       router_aggregation_core_data
);

endinterface