
import top_pkg::*;
import age_pkg::*;

parameter BUFFER_SLOT_WRITE_DEPTH = 512;
parameter BUFFER_SLOT_WRITE_WIDTH = 64;

interface bm_interface (
    input  logic core_clk,
    input  logic resetn,

    // AGE -> Buffer Manager REQ
    input  logic                                                      age_buffer_manager_nodeslot_allocation_valid,
    input  logic                                                      age_buffer_manager_nodeslot_allocation_ready,
    input  age_pkg::AGE_BUFF_MAN_ALLOC_t                              age_buffer_manager_nodeslot_allocation,

    // Buffer Manager -> Router
    input  logic                                                      buffer_manager_router_on,
    input  logic                                                      buffer_manager_router_valid,
    input  logic                                                      buffer_manager_router_ready,
    input  noc_pkg::flit_t                                                     buffer_manager_router_data,

    // Router -> Buffer Manager
    input  logic                                                      router_buffer_manager_on,
    input  logic                                                      router_buffer_manager_valid,
    input  logic                                                      router_buffer_manager_ready,
    input  noc_pkg::flit_t                                                     router_buffer_manager_data,

    // Buffer Manager -> Aggregation Buffer slot
    input  logic                                                       buffer_slot_set_node_id_valid,
    input  logic [top_pkg::NODE_ID_WIDTH-1:0]                          buffer_slot_set_node_id,
    input  logic                                                       bm_buffer_slot_write_enable,
    input  logic [$clog2(top_pkg::AGGREGATION_BUFFER_WRITE_DEPTH)-1:0] bm_buffer_slot_write_address,
    input  logic [top_pkg::AGGREGATION_BUFFER_WRITE_WIDTH-1:0]         bm_buffer_slot_write_data,
    input  logic [$clog2(top_pkg::AGGREGATION_BUFFER_READ_DEPTH)-1:0]  buffer_slot_bm_feature_count,
    input  logic                                                       buffer_slot_bm_slot_free
);

endinterface