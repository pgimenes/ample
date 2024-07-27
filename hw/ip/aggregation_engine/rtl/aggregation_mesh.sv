
import top_pkg::*;
import noc_pkg::*;
import age_pkg::*;

module aggregation_mesh #(
    parameter AGGREGATION_ROWS = top_pkg::AGGREGATION_BUFFER_SLOTS,
    parameter AGGREGATION_COLS = top_pkg::MESSAGE_CHANNEL_COUNT/top_pkg::PRECISION_COUNT/top_pkg::MESH_MULTIPLIER,
    parameter PRECISION = top_pkg::FLOAT_32,
    parameter AGGREGATION_CORE_DATA_WIDTH = 32
) (

    input  logic                                                                              core_clk,
    input  logic                                                                              resetn,

    // AGE -> Aggregation Mesh: Request Interface
    input  logic                                                                              aggregation_req_valid,
    output logic                                                                              aggregation_req_ready,
    input  top_pkg::NSB_AGE_REQ_t                                                             aggregation_req,

    // Aggregation Mesh -> AGE : Response Interface
    output logic [AGGREGATION_ROWS-1:0]                                                       aggregation_manager_done_valid,
    output logic [AGGREGATION_ROWS-1:0] [$clog2(top_pkg::MAX_NODESLOT_COUNT)-1:0]             aggregation_manager_done_nodeslot,
    input  logic [AGGREGATION_ROWS-1:0]                                                       aggregation_manager_done_ready,

    // Message Channel: AGE -> Prefetcher (request)
    output logic [AGGREGATION_ROWS-1:0]                                                       message_channel_req_valid,
    input  logic [AGGREGATION_ROWS-1:0]                                                       message_channel_req_ready,
    output MESSAGE_CHANNEL_REQ_t [AGGREGATION_ROWS-1:0]                                       message_channel_req,
    
    // Message Channel: Prefetcher -> AGE (response)
    input  logic [AGGREGATION_ROWS-1:0]                                                       message_channel_resp_valid,
    output logic [AGGREGATION_ROWS-1:0]                                                       message_channel_resp_ready,
    input  MESSAGE_CHANNEL_RESP_t [AGGREGATION_ROWS-1:0]                                      message_channel_resp,

    // Aggregation Mesh -> Fetch Tag: Scale Factor Queue Interface
    output logic [AGGREGATION_ROWS-1:0]                                                       scale_factor_queue_pop,
    input  logic [AGGREGATION_ROWS-1:0] [SCALE_FACTOR_QUEUE_READ_WIDTH-1:0]                   scale_factor_queue_out_data,
    input  logic [AGGREGATION_ROWS-1:0]                                                       scale_factor_queue_out_valid,

    // AGE -> Aggregation Buffer
    output logic [AGGREGATION_ROWS-1:0]                                                       aggregation_buffer_slot_set_node_id_valid,
    input  logic [AGGREGATION_ROWS-1:0]                                                       aggregation_buffer_slot_set_node_id_ready,
    output logic [AGGREGATION_ROWS-1:0] [NODE_ID_WIDTH-1:0]                                   aggregation_buffer_slot_set_node_id,

    output logic [AGGREGATION_ROWS-1:0]                                                       aggregation_buffer_slot_write_enable,
    input  logic [AGGREGATION_ROWS-1:0]                                                       aggregation_buffer_slot_write_ready,
    output logic [AGGREGATION_ROWS-1:0] [$clog2(top_pkg::AGGREGATION_BUFFER_WRITE_DEPTH)-1:0] aggregation_buffer_slot_write_address,
    output logic [AGGREGATION_ROWS-1:0] [noc_pkg::PAYLOAD_DATA_WIDTH-1:0]                     aggregation_buffer_slot_write_data,
    
    input  logic [AGGREGATION_ROWS-1:0] [$clog2(top_pkg::AGGREGATION_BUFFER_READ_DEPTH)-1:0]  aggregation_buffer_slot_feature_count,
    input  logic [AGGREGATION_ROWS-1:0]                                                       aggregation_buffer_slot_slot_free,

    // Aggregation Mesh -> Buffer Manager Arbiter
    output logic [AGGREGATION_ROWS-1:0]                                                       buffer_manager_done,

    // Layer configuration parameters
    input  logic [9:0]                                                                        layer_config_in_features_count

);

parameter AGC_COUNT = AGGREGATION_ROWS * AGGREGATION_COLS;

// ==================================================================================================================================================
// Declarations
// ==================================================================================================================================================

// NOC Mesh
// ----------------------------------------------------

logic  [AGGREGATION_COLS+1:0] [AGGREGATION_ROWS:0] [VC_NUM-1:0]   node_router_on;
logic  [AGGREGATION_COLS+1:0] [AGGREGATION_ROWS:0]                node_router_valid;
logic  [AGGREGATION_COLS+1:0] [AGGREGATION_ROWS:0] [VC_NUM-1:0]   node_router_ready;
noc_pkg::flit_t [AGGREGATION_COLS+1:0] [AGGREGATION_ROWS:0]    node_router_data;
                                                                                                                                       
logic  [AGGREGATION_COLS+1:0] [AGGREGATION_ROWS:0] [VC_NUM-1:0] router_node_on;
logic  [AGGREGATION_COLS+1:0] [AGGREGATION_ROWS:0]              router_node_valid;
logic  [AGGREGATION_COLS+1:0] [AGGREGATION_ROWS:0] [VC_NUM-1:0] router_node_ready;
noc_pkg::flit_t [AGGREGATION_COLS+1:0] [AGGREGATION_ROWS:0]  router_node_data;

// Aggregation Managers
// ----------------------------------------------------

// NOC signals
logic [AGGREGATION_ROWS-1:0]                                                       aggregation_manager_router_on;
logic [AGGREGATION_ROWS-1:0]                                                       aggregation_manager_router_valid;
logic [AGGREGATION_ROWS-1:0]                                                       aggregation_manager_router_ready;
flit_t [AGGREGATION_ROWS-1:0]                                                      aggregation_manager_router_data;
                                                                                                                               
logic [AGGREGATION_ROWS-1:0]                                                       router_aggregation_manager_on;
logic [AGGREGATION_ROWS-1:0]                                                       router_aggregation_manager_valid;
logic [AGGREGATION_ROWS-1:0]                                                       router_aggregation_manager_ready;
flit_t [AGGREGATION_ROWS-1:0]                                                      router_aggregation_manager_data;
                                                                                                                               
logic [AGGREGATION_ROWS-1:0]                                                       agm_req_valid;
logic [AGGREGATION_ROWS-1:0]                                                       agm_req_ready;
AGE_AGM_REQ_t                                                                      agm_req;

// Buffer Manager Allocation
logic [AGGREGATION_ROWS-1:0]                                                       buffer_manager_allocation_valid;
logic [AGGREGATION_ROWS-1:0]                                                       buffer_manager_allocation_ready;
logic [$clog2(AGGREGATION_ROWS)-1:0]                                               buffer_manager_allocation;

top_pkg::NSB_AGE_REQ_t [AGGREGATION_ROWS-1:0]                                      agm_allocation;
logic [AGGREGATION_ROWS-1:0] [AGC_COUNT-1:0]                                       agm_allocated_agcs;
logic [AGGREGATION_ROWS-1:0] [$clog2(MAX_AGC_PER_NODE)-1:0]                        agm_allocated_agcs_count;
logic [AGGREGATION_ROWS-1:0] [MAX_AGC_PER_NODE-1:0] [$clog2(AGGREGATION_COLS)-1:0] agm_coords_buffer_x;
logic [AGGREGATION_ROWS-1:0] [MAX_AGC_PER_NODE-1:0] [$clog2(AGGREGATION_ROWS)-1:0] agm_coords_buffer_y;

// Aggregation Cores
// ----------------------------------------------------

logic  [AGGREGATION_ROWS-1:0] [AGGREGATION_COLS-1:0] aggregation_core_free;
logic  [AGGREGATION_ROWS-1:0] [AGGREGATION_COLS-1:0] aggregation_core_router_on;
logic  [AGGREGATION_ROWS-1:0] [AGGREGATION_COLS-1:0] aggregation_core_router_valid;
logic  [AGGREGATION_ROWS-1:0] [AGGREGATION_COLS-1:0] aggregation_core_router_ready;
flit_t [AGGREGATION_ROWS-1:0] [AGGREGATION_COLS-1:0] aggregation_core_router_data;

logic  [AGGREGATION_ROWS-1:0] [AGGREGATION_COLS-1:0] router_aggregation_core_on;
logic  [AGGREGATION_ROWS-1:0] [AGGREGATION_COLS-1:0] router_aggregation_core_valid;
logic  [AGGREGATION_ROWS-1:0] [AGGREGATION_COLS-1:0] router_aggregation_core_ready;
flit_t [AGGREGATION_ROWS-1:0] [AGGREGATION_COLS-1:0] router_aggregation_core_data;

// Buffer Managers
// ----------------------------------------------------

// Aggregation manager allocation
logic [AGGREGATION_ROWS-1:0]            buffer_manager_nodeslot_allocation_valid;
logic [AGGREGATION_ROWS-1:0]            buffer_manager_nodeslot_allocation_ready;
age_pkg::AGE_BUFF_MAN_ALLOC_t           buffer_manager_nodeslot_allocation;
logic [$clog2(AGGREGATION_COLS)-1:0]    aggregation_manager_allocation;

logic  [AGGREGATION_ROWS-1:0]           buffer_manager_router_on;
logic  [AGGREGATION_ROWS-1:0]           buffer_manager_router_valid;
logic  [AGGREGATION_ROWS-1:0]           buffer_manager_router_ready;
flit_t [AGGREGATION_ROWS-1:0]           buffer_manager_router_data;
logic  [AGGREGATION_ROWS-1:0]           router_buffer_manager_on;
logic  [AGGREGATION_ROWS-1:0]           router_buffer_manager_valid;
logic  [AGGREGATION_ROWS-1:0]           router_buffer_manager_ready;
flit_t [AGGREGATION_ROWS-1:0]           router_buffer_manager_data;

// AGC Allocation
// ----------------------------------------------------

logic [AGC_COUNT-1:0]     agc_free_mask;

// (Aggregation <-> Buffer Manager) Allocation
logic [AGGREGATION_ROWS-1:0] buffer_manager_allocation_oh;

logic [AGGREGATION_ROWS-1:0] agm_allocation_oh;
logic [$clog2(AGGREGATION_ROWS)-1:0] agm_receiving_buffer_manager_allocation;

logic                        agm_waiting;
logic                        bm_waiting;

logic [AGGREGATION_ROWS-1:0]         agm_sending_done_oh;
logic [$clog2(AGGREGATION_ROWS)-1:0] agm_sending_done_bin;

// Other
// ----------------------------------------------------

// for visibility in the waveform
// logic [VC_NUM-1:0] error_o [AGGREGATION_COLS+2:0][AGGREGATION_ROWS:0][PORT_NUM-1:0];

// ==================================================================================================================================================
// Instances
// ==================================================================================================================================================

// AGC Allocator
// ----------------------------------------------------

assign agm_sending_done_oh = (aggregation_manager_done_valid & aggregation_manager_done_ready);

aggregation_core_allocator #(
    .NUM_CORES            (AGC_COUNT),
    .NUM_MANAGERS         (AGGREGATION_ROWS)

) agc_allocator (
    .core_clk               (core_clk),
    .resetn                 (resetn),

    .allocation_req_valid           (aggregation_req_valid),
    .allocation_req_ready           (aggregation_req_ready),
    .allocation_req                 (aggregation_req),

    .cores_free                     (agc_free_mask),
    .layer_config_in_features_count (layer_config_in_features_count),
    
    .deallocation_valid             (|agm_sending_done_oh),
    .deallocation_cores             (agm_allocated_agcs [agm_sending_done_bin]),
    
    .agm_req_valid              (agm_req_valid),
    .agm_req_ready              (agm_req_ready),
    .agm_req                    (agm_req)
);

onehot_to_binary_comb #(
    .INPUT_WIDTH (AGGREGATION_ROWS)
) agm_done_oh2bin (
	.input_data    (agm_sending_done_oh),
  	.output_data   (agm_sending_done_bin)
);

// NOC Mesh
// ----------------------------------------------------

mesh #(
    .BUFFER_SIZE (top_pkg::MESH_INPUT_BLOCK_BUFFER_SIZE),
    .MESH_SIZE_X (AGGREGATION_COLS + 2),
    .MESH_SIZE_Y (AGGREGATION_ROWS + 1)
) aggregation_mesh_i (
    .clk                (core_clk),
    .rst                (!resetn),

    .is_on_off_o        (node_router_on),
    .is_valid_i         (node_router_valid),
    .is_allocatable_o   (node_router_ready),
    .data_i             (node_router_data),

    .is_on_off_i        (router_node_on),
    .is_valid_o         (router_node_valid),
    .is_allocatable_i   (router_node_ready),
    .data_o             (router_node_data),

    .error_o            ()
);

// Aggregation Managers
// ----------------------------------------------------

for (genvar agm = 0; agm < AGGREGATION_ROWS; agm = agm + 1) begin : agm_block
    
    aggregation_manager #(
        .X_COORD  (0),
        .Y_COORD  (agm),
        .AGGREGATION_COLS (AGGREGATION_COLS),
        .AGGREGATION_ROWS (AGGREGATION_ROWS)
    ) agm_i (
        .core_clk,
        .resetn,

        // Request interface
        .age_aggregation_manager_req_valid                       (agm_req_valid [agm]),
        .age_aggregation_manager_req_ready                       (agm_req_ready [agm]),
        .age_aggregation_manager_req                             (agm_req            ),

        // Response interface
        .aggregation_manager_age_done_valid                      (aggregation_manager_done_valid [agm]),
        .aggregation_manager_age_done_ready                      (aggregation_manager_done_ready [agm]),

        // NOC signals
        .aggregation_manager_router_on                           (aggregation_manager_router_on    [agm]),
        .aggregation_manager_router_valid                        (aggregation_manager_router_valid [agm]),
        .aggregation_manager_router_ready                        (aggregation_manager_router_ready [agm]),
        .aggregation_manager_router_data                         (aggregation_manager_router_data  [agm]),
        
        .router_aggregation_manager_on                           (router_aggregation_manager_on    [agm]),
        .router_aggregation_manager_valid                        (router_aggregation_manager_valid [agm]),
        .router_aggregation_manager_ready                        (router_aggregation_manager_ready [agm]),
        .router_aggregation_manager_data                         (router_aggregation_manager_data  [agm]),
        
        // Message channel requests
        .message_channel_req_valid                               (message_channel_req_valid [agm]),
        .message_channel_req_ready                               (message_channel_req_ready [agm]),
        .message_channel_req                                     (message_channel_req       [agm]),
        
        // Message channel responses
        .message_channel_resp_valid                              (message_channel_resp_valid [agm]),
        .message_channel_resp_ready                              (message_channel_resp_ready [agm]),
        .message_channel_resp                                    (message_channel_resp [agm]),
        
        .scale_factor_queue_pop                                  (scale_factor_queue_pop             [agm]),
        .scale_factor_queue_out_data                             (scale_factor_queue_out_data        [agm]),
        .scale_factor_queue_out_valid                            (scale_factor_queue_out_valid       [agm]),
        
        // Buffer Manager allocation
        .age_aggregation_manager_buffer_manager_allocation_valid (buffer_manager_allocation_valid [agm]),
        .age_aggregation_manager_buffer_manager_allocation_ready (buffer_manager_allocation_ready [agm]),
        .age_aggregation_manager_buffer_manager_allocation       (buffer_manager_allocation),
                         
        // Buffered allocation payloads
        .agm_allocation                                          (agm_allocation [agm]),
        .agm_allocated_agcs                                      (agm_allocated_agcs [agm]),
        .agm_allocated_agcs_count                                (agm_allocated_agcs_count [agm]),
        .coords_buffer_x                                         (agm_coords_buffer_x [agm]),
        .coords_buffer_y                                         (agm_coords_buffer_y [agm])

    );


    always_comb begin
        // First column of NOC mesh is taken by message channels
        aggregation_manager_router_on    [agm]                     = node_router_on                   [0][agm][0];
        aggregation_manager_router_ready [agm]                     = node_router_ready                [0][agm][0];
        node_router_valid                [0][agm] = aggregation_manager_router_valid [agm];
        node_router_data                 [0][agm] = aggregation_manager_router_data  [agm];

        router_aggregation_manager_valid [agm]                 = router_node_valid                [0][agm];
        router_aggregation_manager_data  [agm]                 = router_node_data                 [0][agm];
        router_node_on                   [0][agm][0] = router_aggregation_manager_on    [agm];
        router_node_ready                [0][agm][0] = router_aggregation_manager_ready [agm];
    end

    assign aggregation_manager_done_nodeslot [agm] = agm_allocation[agm].nodeslot;

end : agm_block

// Aggregation Cores
// ----------------------------------------------------

for (genvar agc_row = 0; agc_row < AGGREGATION_ROWS; agc_row = agc_row + 1) begin : row_gen

    // Build mask of free aggregation cores for allocation
    assign agc_free_mask [((agc_row+1)*AGGREGATION_COLS)-1:(agc_row*AGGREGATION_COLS)] = aggregation_core_free[agc_row] [AGGREGATION_COLS-1:0];

    for (genvar agc_col = 0; agc_col < AGGREGATION_COLS; agc_col = agc_col + 1) begin : col_gen
    
        aggregation_core #(
            .X_COORD       (agc_col + 1),
            .Y_COORD       (agc_row),

            .FEATURE_COUNT (16),
            .PRECISION     (PRECISION),
            .DATA_WIDTH    (AGGREGATION_CORE_DATA_WIDTH),

            .AGGREGATION_ROWS (AGGREGATION_ROWS),
            .AGGREGATION_COLS (AGGREGATION_COLS)

        ) agc_i (
            .core_clk                       (core_clk),
            .resetn                         (resetn),

            // Allocation interface
            .aggregation_core_free          (aggregation_core_free          [agc_row][agc_col]),

            // Aggregation Core -> Router
            .aggregation_core_router_on     (aggregation_core_router_on     [agc_row][agc_col]),
            .aggregation_core_router_valid  (aggregation_core_router_valid  [agc_row][agc_col]),
            .aggregation_core_router_ready  (aggregation_core_router_ready  [agc_row][agc_col]),
            .aggregation_core_router_data   (aggregation_core_router_data   [agc_row][agc_col]),

            // Router -> Aggregation Core
            .router_aggregation_core_on     (router_aggregation_core_on     [agc_row][agc_col]),
            .router_aggregation_core_valid  (router_aggregation_core_valid  [agc_row][agc_col]),
            .router_aggregation_core_ready  (router_aggregation_core_ready  [agc_row][agc_col]),
            .router_aggregation_core_data   (router_aggregation_core_data   [agc_row][agc_col])
        );

        always_comb begin
            aggregation_core_router_on    [agc_row][agc_col] = node_router_on                [agc_col+1][agc_row][0];
            aggregation_core_router_ready [agc_row][agc_col] = node_router_ready             [agc_col+1][agc_row][0];
            node_router_valid             [agc_col+1][agc_row] = aggregation_core_router_valid [agc_row][agc_col];
            node_router_data              [agc_col+1][agc_row] = aggregation_core_router_data  [agc_row][agc_col];
            
            router_aggregation_core_valid [agc_row][agc_col]    = router_node_valid             [agc_col+1][agc_row];
            router_aggregation_core_data  [agc_row][agc_col]    = router_node_data              [agc_col+1][agc_row];
            router_node_on                [agc_col+1][agc_row][0] = router_aggregation_core_on    [agc_row][agc_col];
            router_node_ready             [agc_col+1][agc_row][0] = router_aggregation_core_ready [agc_row][agc_col];
        end
    end : col_gen
end : row_gen

// Buffer Managers
// ----------------------------------------------------

for (genvar bm = 0; bm < AGGREGATION_ROWS; bm++) begin : bm_block

    buffer_manager #(
        .X_COORD (AGGREGATION_COLS + 1),
        .Y_COORD (bm),

        .AGGREGATION_ROWS (AGGREGATION_ROWS),
        .AGGREGATION_COLS (AGGREGATION_COLS)
    ) buffer_manager_i (
        .core_clk,
        .resetn,

        .age_buffer_manager_nodeslot_allocation_valid  (buffer_manager_nodeslot_allocation_valid [bm]),
        .age_buffer_manager_nodeslot_allocation_ready  (buffer_manager_nodeslot_allocation_ready [bm]),
        .age_buffer_manager_nodeslot_allocation        (buffer_manager_nodeslot_allocation),

        .buffer_manager_done                           (buffer_manager_done [bm]),

        .buffer_manager_router_on                      (buffer_manager_router_on      [bm]),
        .buffer_manager_router_valid                   (buffer_manager_router_valid   [bm]),
        .buffer_manager_router_ready                   (buffer_manager_router_ready   [bm]),
        .buffer_manager_router_data                    (buffer_manager_router_data    [bm]),
        
        .router_buffer_manager_on                      (router_buffer_manager_on      [bm]),
        .router_buffer_manager_valid                   (router_buffer_manager_valid   [bm]),
        .router_buffer_manager_ready                   (router_buffer_manager_ready   [bm]),
        .router_buffer_manager_data                    (router_buffer_manager_data    [bm]),
        
        .buffer_slot_set_node_id_valid                 (aggregation_buffer_slot_set_node_id_valid [bm]),
        .buffer_slot_set_node_id_ready                 (aggregation_buffer_slot_set_node_id_ready [bm]),
        .buffer_slot_set_node_id                       (aggregation_buffer_slot_set_node_id  [bm]),
        
        .bm_buffer_slot_write_enable                   (aggregation_buffer_slot_write_enable  [bm]),
        .bm_buffer_slot_write_ready                    (aggregation_buffer_slot_write_ready  [bm]),
        .bm_buffer_slot_write_address                  (aggregation_buffer_slot_write_address [bm]),
        .bm_buffer_slot_write_data                     (aggregation_buffer_slot_write_data    [bm]),
        
        .buffer_slot_bm_feature_count                  (aggregation_buffer_slot_feature_count [bm]),
        .buffer_slot_bm_slot_free                      (aggregation_buffer_slot_slot_free     [bm])
    );
    
    always_comb begin
        buffer_manager_router_on    [bm]                   = node_router_on              [AGGREGATION_COLS+1][bm][0];
        buffer_manager_router_ready [bm]                   = node_router_ready           [AGGREGATION_COLS+1][bm][0];
        node_router_valid           [AGGREGATION_COLS+1][bm] = buffer_manager_router_valid [bm];
        node_router_data            [AGGREGATION_COLS+1][bm] = buffer_manager_router_data  [bm];

        router_buffer_manager_valid [bm]                      = router_node_valid           [AGGREGATION_COLS+1][bm];
        router_buffer_manager_data  [bm]                      = router_node_data            [AGGREGATION_COLS+1][bm];
        router_node_on              [AGGREGATION_COLS+1][bm][0] = router_buffer_manager_on    [bm];
        router_node_ready           [AGGREGATION_COLS+1][bm][0] = router_buffer_manager_ready [bm];
    end
end : bm_block

// Aggregation Manager Arbitration (to be allocated a buffer manager)
// ----------------------------------------------------

assign agm_waiting = (buffer_manager_allocation_ready != '0);
assign bm_waiting = (buffer_manager_nodeslot_allocation_ready != '0);

rr_arbiter #(
    .NUM_REQUESTERS (AGGREGATION_ROWS)
) free_agm_arbiter (
    .clk        (core_clk),
    .resetn     (resetn),

    .request    (buffer_manager_allocation_ready),
    .update_lru (agm_waiting && bm_waiting), // update when agm accepting buffer manager allocation
    .grant_oh   (agm_allocation_oh),
    .grant_bin  (agm_receiving_buffer_manager_allocation)
);

// Drive valid allocation to AGM when it has been arbitrated and a buffer manager is waiting
assign buffer_manager_allocation_valid = agm_allocation_oh & {AGGREGATION_ROWS{bm_waiting}};

// Buffer Manager arbitration (to be allocated an aggregation manager)
// ----------------------------------------------------

// rr_arbiter #(
//     .NUM_REQUESTERS (AGGREGATION_ROWS)
// ) free_buffer_manager_arbiter (
//     .clk        (core_clk),
//     .resetn     (resetn),
    
//     .request    (buffer_manager_nodeslot_allocation_ready),
//     .update_lru (agm_waiting && bm_waiting), // accepting when buffer manager accepting allocation
//     .grant_oh   (buffer_manager_allocation_oh),
//     .grant_bin  (buffer_manager_allocation)
// );

// TO DO: generalize.
// Temporarily always assign each BM to the AGM on the same row.
// Later leave this as a runtime config
// Put these in a module called AGM-BM cross arbiter

assign buffer_manager_allocation_oh = agm_allocation_oh;
assign buffer_manager_allocation = agm_receiving_buffer_manager_allocation;

// Drive valid allocation to buffer manager when it has been arbitrated and an AGM is waiting
assign buffer_manager_nodeslot_allocation_valid = buffer_manager_allocation_oh & {AGGREGATION_ROWS{agm_waiting}};

// Allocation payloads
always_comb begin
    // Tell the chosen buffer manager which AGM was chosen
    buffer_manager_nodeslot_allocation.nodeslot                = agm_receiving_buffer_manager_allocation;
    buffer_manager_nodeslot_allocation.node_id                 = agm_allocation[agm_receiving_buffer_manager_allocation].node_id;
    buffer_manager_nodeslot_allocation.aggregation_manager     = agm_receiving_buffer_manager_allocation;
    buffer_manager_nodeslot_allocation.allocated_agcs_x_coords = agm_coords_buffer_x       [agm_receiving_buffer_manager_allocation];
    buffer_manager_nodeslot_allocation.allocated_agcs_y_coords = agm_coords_buffer_y       [agm_receiving_buffer_manager_allocation];
    buffer_manager_nodeslot_allocation.allocated_agcs_count    = agm_allocated_agcs_count  [agm_receiving_buffer_manager_allocation];
end

endmodule