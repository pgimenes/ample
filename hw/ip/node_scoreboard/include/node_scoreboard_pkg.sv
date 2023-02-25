
package node_scoreboard_pkg;
    
typedef enum logic [3:0] {
    EMPTY               = 4'd0,
    PROG_DONE           = 4'd1,
    FETCH_NB_LIST       = 4'd2,
    FETCH_NEIGHBOURS    = 4'd3,
    AGGR                = 4'd4,
    TRANS               = 4'd5,
    PASS                = 4'd6,
    WRITEBACK           = 4'd7,
    HALT                = 4'd8
} NSB_NODESLOT_STATE_e;

endpackage