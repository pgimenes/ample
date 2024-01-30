import top_pkg::*;
import noc_pkg::*;

package age_pkg;

parameter MAX_AGC_PER_NODE = top_pkg::MAX_FEATURE_COUNT / 16;

parameter AGC_ALLOCATION_MODE_STATIC = 0;
parameter AGC_ALLOCATION_MODE_SEQUENTIAL_RR = 1;

// Types
// -------------------------------------------------------------------------------------

typedef struct packed {
    top_pkg::NSB_AGE_REQ_t nsb_req;
    
    // Maximum number of AGCs per precision group is for float
    // So mask of allocated cores needs to have width of AGC_COUNT_FLOAT32
    logic [noc_pkg::MAX_AGC_COUNT-1:0] allocated_cores;
    logic [$clog2(MAX_AGC_PER_NODE)-1:0] required_agcs;
    
    logic [MAX_AGC_PER_NODE-1:0] [$clog2(noc_pkg::MAX_MESH_COLS)-1:0] coords_x;
    logic [MAX_AGC_PER_NODE-1:0] [$clog2(noc_pkg::MAX_MESH_ROWS)-1:0] coords_y;
} AGE_AGM_REQ_t;

typedef struct packed {
    logic [$clog2(top_pkg::MAX_NODESLOT_COUNT)-1:0]     nodeslot;    
    logic [top_pkg::NODE_ID_WIDTH-1:0]                  node_id;
    logic [$clog2(noc_pkg::MAX_AGGREGATION_COLS)-1:0]   aggregation_manager;
    
    logic [MAX_AGC_PER_NODE-1:0] [$clog2(noc_pkg::MAX_MESH_COLS)-1:0] allocated_agcs_x_coords;
    logic [MAX_AGC_PER_NODE-1:0] [$clog2(noc_pkg::MAX_MESH_ROWS)-1:0] allocated_agcs_y_coords;
    logic [$clog2(MAX_AGC_PER_NODE)-1:0]                     allocated_agcs_count;
} AGE_BUFF_MAN_ALLOC_t;

typedef enum logic [1:0] {
    PKT_FSM_IDLE,
    PKT_FSM_HEAD,
    PKT_FSM_TAIL,
    PKT_FSM_RESERVED
} axi_packet_fsm_e;

typedef enum logic [1:0] {
    AGC_NODESLOT_ALLOCATION = 2'b00,
    AGC_FEATURE_PACKET      = 2'b01,
    BM_BUFFER_REQUEST       = 2'b10,
    AGM_PKT_ERROR           = 2'b11
} aggregation_manager_packet_type_e;

// Utilities
// -------------------------------------------------------------------------------------

function logic [7:0] features_per_aggregation_core (input top_pkg::NODE_PRECISION_e precision);
    logic [7:0] features;
    case(precision)
        top_pkg::FLOAT_32: features = 'd16;
        top_pkg::FIXED_16: features = 'd32;
        top_pkg::FIXED_8:  features = 'd64;
        top_pkg::FIXED_4:  features = 'd128;
        default:           features = 'd0;
    endcase
    return features;
endfunction

endpackage