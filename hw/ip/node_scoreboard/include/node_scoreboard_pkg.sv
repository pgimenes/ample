
package node_scoreboard_pkg;
    
typedef enum logic [3:0] {
    EMPTY,
    PROG_DONE,
    FETCH_NB_LIST,
    FETCH_SCALE_FACTORS,
    FETCH_NEIGHBOURS,
    AGGREGATION,
    TRANSFORMATION,
    PASS,
    WRITEBACK,
    HALT
} NSB_NODESLOT_STATE_e;

endpackage