package prefetcher_pkg;

parameter ADJ_QUEUE_WIDTH   = 32; // next version will take top_pkg::NODE_ID_WIDTH
parameter ADJ_QUEUE_DEPTH   = 64;

// Cannot predict message width (depends on feature count and precision), so store 512b AXI beats directly
// This corresponds to different feature counts depending on precision
parameter MESSAGE_QUEUE_WIDTH = 512;
parameter MESSAGE_QUEUE_DEPTH = 4096;

// Scale factor queue
parameter SCALE_FACTOR_QUEUE_WRITE_WIDTH = 512;
parameter SCALE_FACTOR_QUEUE_WRITE_DEPTH = 64;
parameter SCALE_FACTOR_QUEUE_READ_WIDTH = 32;
parameter SCALE_FACTOR_QUEUE_READ_DEPTH = 1024;

parameter MAX_ADJ_FETCH_RESPONSES = `divide_round_up(ADJ_QUEUE_DEPTH * ADJ_QUEUE_WIDTH, top_pkg::AXI_DATA_WIDTH);
parameter MAX_MSG_FETCH_RESPONSES = `divide_round_up(top_pkg::MAX_FEATURE_COUNT * top_pkg::MAX_PRECISION_BYTE_COUNT,  (top_pkg::AXI_DATA_WIDTH/8));
parameter MAX_FETCH_RESPONSES = `max(MAX_ADJ_FETCH_RESPONSES, MAX_MSG_FETCH_RESPONSES);

typedef enum logic [2:0] {
    ADJ_IDLE                = 3'd0,
    ADJ_FETCH               = 3'd1,
    ADJ_WAIT_RESP           = 3'd2,
    ADJ_STORE               = 3'd3,
    ADJ_PAUSE               = 3'd4,
    ADJ_DONE                = 3'd5
} FETCH_TAG_ADJ_QUEUE_FETCH_FSM_e;

typedef enum logic [2:0] {
    MSG_IDLE = 0,
    MSG_FETCH = 1,
    MSG_STORE = 2,
    MSG_PAUSE = 3,
    MSG_DONE = 4
} FETCH_TAG_MESSAGE_FETCH_FSM_e;

endpackage