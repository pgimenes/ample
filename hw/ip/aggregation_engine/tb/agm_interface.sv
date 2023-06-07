import top_pkg::*;
import age_pkg::*;
import noc_pkg::*;

interface agm_interface (
    input logic                                                 core_clk,
    input logic                                                 resetn,

    // AGE requests
    input  logic                                                age_aggregation_manager_req_valid,
    input  logic                                                age_aggregation_manager_req_ready,
    input  AGE_AGM_REQ_t                                        age_aggregation_manager_req,

    // Done signals to pulse NSB response
    input  logic                                                aggregation_manager_age_done_valid,
    input  logic                                                aggregation_manager_age_done_ready,

    // Buffer Manager Allocation
    input  logic                                                age_aggregation_manager_buffer_manager_allocation_valid,
    input  logic                                                age_aggregation_manager_buffer_manager_allocation_ready,
    input  logic [$clog2(MAX_AGGREGATION_ROWS)-1:0]             age_aggregation_manager_buffer_manager_allocation,

    // Message Channel: AGE -> Prefetcher (request)
    input  logic                                                message_channel_req_valid,
    input  logic                                                message_channel_req_ready,
    input  MESSAGE_CHANNEL_REQ_t                                message_channel_req,
    
    // Message Channel: Prefetcher -> AGE (response)
    input  logic                                                message_channel_resp_valid,
    input  logic                                                message_channel_resp_ready,
    input  MESSAGE_CHANNEL_RESP_t                               message_channel_resp,

    // Aggregation Manager -> Router
    input  logic                                                aggregation_manager_router_on,
    input  logic                                                aggregation_manager_router_valid,
    input  logic                                                aggregation_manager_router_ready,
    input  flit_t                                               aggregation_manager_router_data,

    // Router -> Aggregation Manager
    input  logic                                                router_aggregation_manager_on,
    input  logic                                                router_aggregation_manager_valid,
    input  logic                                                router_aggregation_manager_ready,
    input  flit_t                                               router_aggregation_manager_data,

    // input  AGM allocation payloads for AGE visibility
    input  NSB_AGE_REQ_t                                            agm_allocation,
    input  logic [MAX_AGC_COUNT-1:0]                                agm_allocated_agcs,
    input  logic [$clog2(MAX_AGC_PER_NODE)-1:0]                     agm_allocated_agcs_count,
    input  logic [MAX_AGC_PER_NODE-1:0] [$clog2(MAX_MESH_COLS)-1:0] coords_buffer_x,
    input  logic [MAX_AGC_PER_NODE-1:0] [$clog2(MAX_MESH_ROWS)-1:0] coords_buffer_y,

    input  logic                                                scale_factor_queue_pop,
    input  logic [SCALE_FACTOR_QUEUE_READ_WIDTH-1:0]            scale_factor_queue_out_data,
    input  logic                                                scale_factor_queue_out_valid
);

parameter X_COORD = 0;
parameter Y_COORD = 0;
parameter AGGREGATION_ROWS = noc_pkg::MAX_AGGREGATION_ROWS;
parameter AGGREGATION_COLS = noc_pkg::MAX_AGGREGATION_COLS;

endinterface