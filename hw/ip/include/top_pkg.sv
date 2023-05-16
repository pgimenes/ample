
package top_pkg;

// Utilities
// ----------------------------------------------------

`define max(a,b) ((a > b) ? a : b)
`define min(a,b) ((a > b) ? b : a)
`define divide_round_up(a,b) (a - 1)/b + 1

// Global parameters
// ----------------------------------------------------

// Graph parameters
parameter MAX_NODES = 1024*1024; // 1M
parameter MAX_NODESLOT_COUNT = 64;
parameter MAX_NEIGHBOURS = 1024;
parameter MAX_FEATURE_COUNT = 1024;

parameter NODE_ID_WIDTH = $clog2(MAX_NODES); // 20

// AXI parameters
parameter AXI_ADDRESS_WIDTH = 34;
parameter AXI_DATA_WIDTH = 512;
parameter AXI_ADDR_MSB_BITS = 43 % 32;

// Register Bank interface
parameter AXIL_ADDR_WIDTH = 32;

parameter LARGE_FEATURE_COUNT = 1024;
parameter LARGE_PRECISION_BYTE_COUNT = 4;
parameter LARGE_MSG_QUEUE_DEPTH = 64;

parameter MAX_REQUIRED_BYTES_ADJ_FETCH_REQ = MAX_NEIGHBOURS * NODE_ID_WIDTH / 8;
parameter MAX_REQUIRED_BYTES_MSG_FETCH_REQ = LARGE_FEATURE_COUNT * LARGE_PRECISION_BYTE_COUNT * LARGE_MSG_QUEUE_DEPTH;
parameter MAX_REQUIRED_BYTES_WEIGHTS_FETCH_REQ = LARGE_FEATURE_COUNT * LARGE_FEATURE_COUNT * LARGE_PRECISION_BYTE_COUNT;

parameter MAX_FETCH_REQ_BYTE_COUNT = `max(MAX_REQUIRED_BYTES_ADJ_FETCH_REQ, MAX_REQUIRED_BYTES_MSG_FETCH_REQ);
parameter MAX_PRECISION_BYTE_COUNT = 4; 

// Prefetcher
parameter FETCH_TAG_COUNT = MAX_NODESLOT_COUNT;
parameter MESSAGE_CHANNEL_COUNT = MAX_NODESLOT_COUNT;

// Aggregation Buffer
parameter AGGREGATION_BUFFER_SLOTS = 16;
parameter AGGREGATION_BUFFER_WRITE_DEPTH = MAX_FEATURE_COUNT * 4 / 8; // 8 bytes per 64b flit
parameter AGGREGATION_BUFFER_WRITE_WIDTH = 64;
parameter AGGREGATION_BUFFER_READ_DEPTH = MAX_FEATURE_COUNT * 4 / 4; // 4 bytes per float
parameter AGGREGATION_BUFFER_READ_WIDTH = 32;

// Supported modes
// ----------------------------------------------------

typedef enum logic [1:0] {
    FLOAT_32 = 2'd0,
    FIXED_16 = 2'd1,
    FIXED_8  = 2'd2,
    FIXED_4  = 2'd3
} NODE_PRECISION_e;

function logic [5:0] bits_per_precision (input NODE_PRECISION_e precision);
    logic [5:0] bits;
    case(precision)
        top_pkg::FLOAT_32: bits = 6'd32;
        top_pkg::FIXED_16: bits = 6'd16;
        top_pkg::FIXED_8:  bits = 6'd8;
        top_pkg::FIXED_4:  bits = 6'd4;
        default:           bits = 6'd0;
    endcase
    return bits;
endfunction

typedef enum logic [1:0] {
    SUM       = 2'd0,
    MEAN      = 2'd1,
    RESERVED  = 2'd2,
    RESERVED2 = 2'd3
} AGGREGATION_FUNCTION_e;

// Internal request/response interfaces
// ----------------------------------------------------

typedef struct packed {
    logic [$clog2(MAX_NODESLOT_COUNT)-1:0] nodeslot;
    logic [$clog2(FETCH_TAG_COUNT)-1:0]    fetch_tag;

    NODE_PRECISION_e                       node_precision;
    AGGREGATION_FUNCTION_e                 aggregation_function;
} NSB_AGE_REQ_t;

typedef struct packed {
    logic [$clog2(MAX_NODESLOT_COUNT)-1:0] nodeslot;
} NSB_AGE_RESP_t;

typedef struct packed {
    logic [MAX_NODESLOT_COUNT-1:0] nodeslots;
} NSB_FTE_REQ_t;

typedef struct packed {
    logic [MAX_NODESLOT_COUNT-1:0] nodeslot;
} NSB_FTE_RESP_t;

typedef enum logic [1:0] {
    WEIGHTS         = 2'd0,
    ADJACENCY_LIST  = 2'd1,
    MESSAGES        = 2'd2,
    ERROR           = 2'd3
} NSB_PREF_OPCODE_e;

typedef struct packed {
    NSB_PREF_OPCODE_e                      req_opcode;
    logic [AXI_ADDRESS_WIDTH-1:0]          start_address;

    // Weight bank requests
    logic [$clog2(MAX_FEATURE_COUNT):0]    in_features;
    logic [$clog2(MAX_FEATURE_COUNT):0]    out_features;

    // For feature bank requests
    logic [$clog2(MAX_NODESLOT_COUNT)-1:0] nodeslot;
    NODE_PRECISION_e                       nodeslot_precision;
    logic [$clog2(MAX_NEIGHBOURS)-1:0]     neighbour_count;
} NSB_PREF_REQ_t;

typedef struct packed {
    logic [$clog2(MAX_NODESLOT_COUNT)-1:0] nodeslot;
    NSB_PREF_OPCODE_e                      response_type;
    logic                                  partial;
} NSB_PREF_RESP_t;

typedef struct packed {
    logic [$clog2(MAX_NODESLOT_COUNT)-1:0] nodeslot;
    logic [$clog2(FETCH_TAG_COUNT)-1:0] fetch_tag;
} MESSAGE_CHANNEL_REQ_t;

typedef struct packed {
    logic [AXI_DATA_WIDTH-1:0] data;
    logic last;
} MESSAGE_CHANNEL_RESP_t;

typedef struct packed {
    // Check request payloads match NSB payloads
    logic [$clog2(MAX_FEATURE_COUNT):0]    in_features;
    logic [$clog2(MAX_FEATURE_COUNT):0]    out_features;
} WEIGHT_CHANNEL_REQ_t;

typedef struct packed {
    logic [MAX_FEATURE_COUNT-1:0] [31:0] data;
    logic [MAX_FEATURE_COUNT-1:0] valid_mask;
    logic                         done;
} WEIGHT_CHANNEL_RESP_t;

typedef struct packed {
    logic [MAX_NODESLOT_COUNT-1:0] nodeslots;
} NSB_OUT_BUFF_REQ_t;

typedef struct packed {
    logic [$clog2(MAX_NODESLOT_COUNT)-1:0] nodeslot;
} NSB_OUT_BUFF_RESP_t;

endpackage