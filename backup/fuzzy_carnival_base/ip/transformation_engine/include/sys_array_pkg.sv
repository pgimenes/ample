
package sys_array_pkg;

parameter BFP_BOUNDING_BOX = 16;

typedef struct packed {
    logic [31:0] n;
} ieee_sp_float_s;

typedef struct packed {
    logic [7:0] exponent;
    logic [BFP_BOUNDING_BOX-1:0] [3:0] num;
} bfp_msfp12_s;

typedef struct packed {
    logic [31:0] n;
} fv_fixed_point_s;

endpackage