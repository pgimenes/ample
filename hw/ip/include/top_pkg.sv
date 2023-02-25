
package top_pkg;

// Utilities
// ----------------------------------------------------

`define max(a,b) (a > b) ? a : b;
`define min(a,b) (a > b) ? b : a;
`define divide_round_up(a,b) (a - 1)/b + 1;

// Global parameters
// ----------------------------------------------------

parameter MAX_NODES = 1024*1024; // 1M
parameter NODE_ID_WIDTH = $clog2(MAX_NODES); // 20
parameter MAX_NODESLOT_COUNT = 64;
parameter MAX_NEIGHBOURS = 1024;
parameter MAX_FEATURE_COUNT = 1024;

parameter AXI_ADDRESS_WIDTH = 34;
parameter AXI_DATA_WIDTH = 512;
parameter AXI_ADDR_MSB_BITS = 43 % 32;

parameter LARGE_FEATURE_COUNT = 1024;
parameter LARGE_PRECISION_BYTE_COUNT = 4;
parameter LARGE_MSG_QUEUE_DEPTH = 64;

parameter MAX_REQUIRED_BYTES_ADJ_FETCH_REQ = MAX_NEIGHBOURS * NODE_ID_WIDTH / 8;
parameter MAX_REQUIRED_BYTES_MSG_FETCH_REQ = LARGE_FEATURE_COUNT * LARGE_PRECISION_BYTE_COUNT * LARGE_MSG_QUEUE_DEPTH;

parameter MAX_FETCH_REQ_BYTE_COUNT = `max(MAX_REQUIRED_BYTES_ADJ_FETCH_REQ, MAX_REQUIRED_BYTES_MSG_FETCH_REQ);
parameter MAX_PRECISION_BYTE_COUNT = 4;

// Supported modes
// ----------------------------------------------------

typedef enum logic [1:0] {
    FLOAT_32 = 0,
    FIXED_16 = 1,
    FIXED_8 = 2,
    FIXED_4 = 3
} NODE_PRECISION_e;

function logic [2:0] bits_per_precision (input NODE_PRECISION_e precision);
    case(precision)
        top_pkg::FLOAT_32: bits_per_precision = 3'd32;
        top_pkg::FIXED_16: bits_per_precision = 3'd16;
        top_pkg::FIXED_8:  bits_per_precision = 3'd8;
        top_pkg::FIXED_4:  bits_per_precision = 3'd4;
    endcase
endfunction

typedef enum logic [1:0] {
    SUM = 0,
    MEAN = 1,
    RESERVED = 2,
    RESERVED2 = 3
} AGGREGATION_FUNCTION_e;

// Internal request/response interfaces
// ----------------------------------------------------

typedef struct packed {
    logic [$clog2(MAX_NODESLOT_COUNT)-1:0] nodeslot;
    NODE_PRECISION_e node_precision;
    AGGREGATION_FUNCTION_e aggregation_function;
} NSB_AGE_REQ_t;

typedef struct packed {
    logic [$clog2(MAX_NODESLOT_COUNT)-1:0] nodeslot;
} NSB_AGE_RESP_t;

typedef struct packed {
    logic [MAX_NODESLOT_COUNT-1:0] nodeslots;
} NSB_FTE_REQ_t;

typedef struct packed {
    logic [$clog2(MAX_NODESLOT_COUNT)-1:0] nodeslot;
} NSB_FTE_RESP_t;

typedef enum logic [1:0] {
    WEIGHTS         = 0,
    ADJACENCY_LIST  = 1,
    MESSAGES        = 2,
    ERROR           = 3
} NSB_PREF_OPCODE_e;

typedef struct packed {
    NSB_PREF_OPCODE_e [3:0]                req_opcode;
    logic [$clog2(MAX_NODESLOT_COUNT)-1:0] nodeslot;
    NODE_PRECISION_e                       nodeslot_precision;

    // For adjacency list request
    logic [AXI_ADDRESS_WIDTH-1:0]          start_address;
    logic [$clog2(MAX_NEIGHBOURS)-1:0]     neighbour_count;
} NSB_PREF_REQ_t;

typedef struct packed {
    logic [$clog2(MAX_NODESLOT_COUNT)-1:0] nodeslot;
    NSB_PREF_OPCODE_e [3:0] response_type;
    logic partial;
} NSB_PREF_RESP_t;

typedef struct packed {
    logic [MAX_NODESLOT_COUNT-1:0] nodeslots;
} NSB_OUT_BUFF_REQ_t;

typedef struct packed {
    logic [$clog2(MAX_NODESLOT_COUNT)-1:0] nodeslot;
} NSB_OUT_BUFF_RESP_t;

endpackage