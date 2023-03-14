import top_pkg::*;

package age_pkg;

parameter AC_ROWS = 8;
parameter AC_COLS = 16;

parameter TOTAL_AGGREGATION_CORES = AC_ROWS * AC_COLS; // TO DO: change (MS3), MS2 only supports float 32

parameter MAX_AC_PER_NODE = 32;

parameter MESH_ROWS = AC_ROWS + 1; // row of message channels
parameter MESH_COLS = AC_COLS + 2; // columns of buffer managers

typedef struct packed {
    top_pkg::NSB_AGE_REQ_t nsb_req;
    logic [MAX_AC_PER_NODE-1:0] [$clog2(AC_COLS)-1:0] coords_x;
    logic [MAX_AC_PER_NODE-1:0] [$clog2(AC_ROWS)-1:0] coords_y;
    logic [$clog2(TOTAL_AGGREGATION_CORES)-1:0] ac_count;
} AGE_MC_REQ_t;

typedef enum logic [3:0] {
    PKT_FSM_IDLE   = 4'd0,
    PKT_FSM_HEAD   = 4'd1,
    PKT_FSM_BODY1  = 4'd2,
    PKT_FSM_BODY2  = 4'd3,
    PKT_FSM_BODY3  = 4'd4,
    PKT_FSM_BODY4  = 4'd5,
    PKT_FSM_BODY5  = 4'd6,
    PKT_FSM_BODY6  = 4'd7,
    PKT_FSM_TAIL   = 4'd8
} axi_packet_fsm_e;

endpackage