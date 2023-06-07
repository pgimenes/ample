
import top_pkg::*;
import age_pkg::*;

interface bm_interface (
    input  logic core_clk,
    input  logic resetn,

    // AGE -> Buffer Manager REQ
    input  logic                                                      age_buffer_manager_nodeslot_allocation_valid,
    output logic                                                      age_buffer_manager_nodeslot_allocation_ready,
    input  AGE_BUFF_MAN_ALLOC_t                                       age_buffer_manager_nodeslot_allocation,

    // Buffer Manager -> Router
    input  logic                                                      buffer_manager_router_on,
    output logic                                                      buffer_manager_router_valid,
    input  logic                                                      buffer_manager_router_ready,
    output flit_t                                                     buffer_manager_router_data,

    // Router -> Buffer Manager
    output logic                                                      router_buffer_manager_on,
    input  logic                                                      router_buffer_manager_valid,
    output logic                                                      router_buffer_manager_ready,
    input  flit_t                                                     router_buffer_manager_data,

    // Buffer Manager -> Aggregation Buffer slot
    output logic                                                      buffer_slot_set_node_id_valid,
    output logic [NODE_ID_WIDTH-1:0]                                  buffer_slot_set_node_id,
    output logic                                                      bm_buffer_slot_write_enable,
    output logic [$clog2(BUFFER_SLOT_WRITE_DEPTH)-1:0]                bm_buffer_slot_write_address,
    output logic [BUFFER_SLOT_WRITE_WIDTH-1:0]                        bm_buffer_slot_write_data,
    input  logic [$clog2(top_pkg::AGGREGATION_BUFFER_READ_DEPTH)-1:0] buffer_slot_bm_feature_count,
    input  logic                                                      buffer_slot_bm_slot_free
);

parameter BUFFER_SLOT_WRITE_DEPTH = 512;
parameter BUFFER_SLOT_WRITE_WIDTH = 64;

endinterface