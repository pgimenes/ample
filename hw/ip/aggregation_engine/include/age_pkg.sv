import top_pkg::*;
import noc_params::*;

package age_pkg;

// Float 32 Aggregation Cores
parameter AGC_FLOAT32_ROWS = 4;
parameter AGC_FLOAT32_COLS = 16;
parameter AGC_FLOAT32_COL_OFFSET = 0;
parameter AGC_COUNT_FLOAT32 = AGC_FLOAT32_ROWS * AGC_FLOAT32_COLS;

// Fixed 16 Aggregation Cores
parameter AGC_FIXED16_ROWS = 4;
parameter AGC_FIXED16_COLS = 16;
parameter AGC_FIXED16_COL_OFFSET = 16;
parameter AGC_COUNT_FIXED16 = AGC_FIXED16_ROWS * AGC_FIXED16_COLS;

parameter AGC_UNUSED_COLS_OFFSET = 32;

// Total Aggregation Cores
parameter AGC_ROWS = 4;
parameter AGC_COLS = 64;
parameter TOTAL_AGGREGATION_CORES = AGC_ROWS * AGC_COLS; // TO DO: change (MS3), MS2 only supports float 32

// Aggregation Managers
parameter AGM_ROWS = 1;
parameter AGM_COLS = 64;
parameter TOTAL_AGGREGATION_MANAGERS = AGM_ROWS * AGM_COLS;

// Buffer Managers
parameter BM_ROWS = 4;
parameter BM_COLS = 1;
parameter TOTAL_BUFFER_MANAGERS = BM_ROWS * BM_COLS;

// Mesh parameters
parameter MESH_ROWS = AGC_ROWS + AGM_ROWS; // row of aggregation managers
parameter MESH_COLS = AGC_COLS + BM_COLS; // col of buffer managers
parameter TOTAL_MESH_NODES = MESH_ROWS * MESH_COLS;

parameter BUFFER_MANAGER_COLUMN = age_pkg::MESH_COLS - 1;

parameter PAYLOAD_DATA_WIDTH = 64;
parameter MESH_NODE_ID_WIDTH = $clog2(MESH_ROWS) + $clog2(MESH_COLS); // = 12

parameter MAX_AGC_PER_NODE = top_pkg::MAX_FEATURE_COUNT / 16;

// Types
// -------------------------------------------------------------------------------------

typedef struct packed {
    top_pkg::NSB_AGE_REQ_t nsb_req;
    
    // Maximum number of AGCs per precision group is for float
    // So mask of allocated cores needs to have width of AGC_COUNT_FLOAT32
    logic [AGC_COUNT_FLOAT32-1:0] allocated_cores;
    logic [$clog2(MAX_AGC_PER_NODE)-1:0] required_agcs;
    
    logic [MAX_AGC_PER_NODE-1:0] [$clog2(MESH_COLS)-1:0] coords_x;
    logic [MAX_AGC_PER_NODE-1:0] [$clog2(MESH_ROWS)-1:0] coords_y;
} AGE_AGM_REQ_t;

typedef struct packed {
    logic [$clog2(top_pkg::MAX_NODESLOT_COUNT)-1:0]     nodeslot;
    logic [$clog2(TOTAL_AGGREGATION_MANAGERS)-1:0]      aggregation_manager;
    
    logic [MAX_AGC_PER_NODE-1:0] [$clog2(MESH_COLS)-1:0] allocated_agcs_x_coords;
    logic [MAX_AGC_PER_NODE-1:0] [$clog2(MESH_ROWS)-1:0] allocated_agcs_y_coords;
    logic [$clog2(MAX_AGC_PER_NODE)-1:0]                 allocated_agcs_count;
} AGE_BUFF_MAN_ALLOC_t;

typedef enum logic [3:0] {
    PKT_FSM_IDLE  = 4'd0,
    PKT_FSM_HEAD  = 4'd1,
    PKT_FSM_BODY1 = 4'd2,
    PKT_FSM_BODY2 = 4'd3,
    PKT_FSM_BODY3 = 4'd4,
    PKT_FSM_BODY4 = 4'd5,
    PKT_FSM_BODY5 = 4'd6,
    PKT_FSM_BODY6 = 4'd7,
    PKT_FSM_BODY7 = 4'd8,
    PKT_FSM_TAIL  = 4'd9
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

function logic [MESH_NODE_ID_WIDTH - 1 : 0] decode_packet_source (input noc_params::flit_t input_packet);
    logic [age_pkg::MESH_NODE_ID_WIDTH-1:0] packet_source;
    logic [$clog2(MESH_ROWS)-1:0]  packet_source_row;
    logic [$clog2(MESH_COLS)-1:0]  packet_source_col;

    packet_source = input_packet.data.head_data.head_pl[noc_params::HEAD_PAYLOAD_SIZE-1 : noc_params::HEAD_PAYLOAD_SIZE-MESH_NODE_ID_WIDTH];
    packet_source_col = packet_source[MESH_NODE_ID_WIDTH - 1 : MESH_NODE_ID_WIDTH - $clog2(age_pkg::MESH_COLS)];
    packet_source_row = packet_source[$clog2(age_pkg::MESH_ROWS)-1:0];
    
    return {packet_source_col, packet_source_row};
endfunction


function logic [MESH_NODE_ID_WIDTH - 1 : 0] decode_packet_destination (input noc_params::flit_t input_packet);
    logic [$clog2(MESH_ROWS)-1:0]  packet_dest_row;
    logic [$clog2(MESH_COLS)-1:0]  packet_dest_col;
    
    packet_dest_row = input_packet.data.head_data.y_dest;
    packet_dest_col = input_packet.data.head_data.x_dest;
    
    return {packet_dest_col, packet_dest_row};
endfunction

endpackage