package noc_pkg;

// Mesh parameters
parameter MAX_AGGREGATION_ROWS = 64;
parameter MAX_AGGREGATION_COLS = 64;
parameter MAX_AGC_COUNT = MAX_AGGREGATION_ROWS * MAX_AGGREGATION_COLS;

parameter MAX_MESH_ROWS = MAX_AGGREGATION_ROWS + 1; // add row of aggregation managers
parameter MAX_MESH_COLS = MAX_AGGREGATION_COLS + 1; // add col of buffer managers
parameter MAX_MESH_NODES = MAX_MESH_ROWS * MAX_MESH_COLS;

// Referenced in NOC RTL
localparam MESH_SIZE_X = MAX_MESH_COLS;
localparam MESH_SIZE_Y = MAX_MESH_ROWS;

// Coordinates
localparam DEST_ADDR_SIZE_X = $clog2(MESH_SIZE_X); // == 7 (+1 bit for sign)
localparam DEST_ADDR_SIZE_Y = $clog2(MESH_SIZE_Y); // == 5 (+1 bit for sign)
parameter  MESH_NODE_ID_WIDTH = DEST_ADDR_SIZE_X + DEST_ADDR_SIZE_Y; // = 12

// Virtual channels
localparam VC_NUM = 1;
localparam VC_SIZE = $clog2(VC_NUM);

// Flit contents
parameter PAYLOAD_DATA_WIDTH = 512;
localparam HEAD_PAYLOAD_SIZE = PAYLOAD_DATA_WIDTH + DEST_ADDR_SIZE_X + DEST_ADDR_SIZE_Y;
localparam FLIT_DATA_SIZE = DEST_ADDR_SIZE_X + DEST_ADDR_SIZE_Y + HEAD_PAYLOAD_SIZE;

localparam PORT_NUM = 5;
localparam PORT_SIZE = $clog2(PORT_NUM);
typedef enum logic [2:0] {LOCAL, NORTH, SOUTH, WEST, EAST} port_t;

typedef enum logic [1:0] {HEAD, BODY, TAIL, HEADTAIL} flit_label_t;

typedef struct packed
{
    logic [DEST_ADDR_SIZE_X-1 : 0] 	x_dest;
    logic [DEST_ADDR_SIZE_Y-1 : 0] 	y_dest;
    logic [HEAD_PAYLOAD_SIZE-1: 0] 	head_pl;
} head_data_t;

typedef struct packed
{
    flit_label_t			flit_label;
    logic [VC_SIZE-1 : 0] 	vc_id;
    union packed
    {
        head_data_t 		head_data;
        logic [FLIT_DATA_SIZE-1 : 0] bt_pl;
    } data;
} flit_t;

// Utilities
// -------------------------------------------------------------------------------------

function logic [MESH_NODE_ID_WIDTH - 1 : 0] decode_packet_source (input noc_pkg::flit_t input_packet);
    logic [MESH_NODE_ID_WIDTH-1:0] packet_source;
    logic [$clog2(MAX_MESH_ROWS)-1:0]  packet_source_row;
    logic [$clog2(MAX_MESH_COLS)-1:0]  packet_source_col;

    packet_source = input_packet.data.head_data.head_pl[noc_pkg::HEAD_PAYLOAD_SIZE-1 : noc_pkg::HEAD_PAYLOAD_SIZE-MESH_NODE_ID_WIDTH];
    packet_source_col = packet_source[MESH_NODE_ID_WIDTH - 1 : MESH_NODE_ID_WIDTH - $clog2(MAX_MESH_COLS)];
    packet_source_row = packet_source[$clog2(MAX_MESH_ROWS)-1:0];
    
    return {packet_source_col, packet_source_row};
endfunction

function logic [MESH_NODE_ID_WIDTH - 1 : 0] decode_packet_destination (input noc_pkg::flit_t input_packet);
    logic [$clog2(MAX_MESH_ROWS)-1:0]  packet_dest_row;
    logic [$clog2(MAX_MESH_COLS)-1:0]  packet_dest_col;
    
    packet_dest_row = input_packet.data.head_data.y_dest;
    packet_dest_col = input_packet.data.head_data.x_dest;
    
    return {packet_dest_col, packet_dest_row};
endfunction

endpackage