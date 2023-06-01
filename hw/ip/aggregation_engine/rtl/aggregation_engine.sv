
import top_pkg::*;
import noc_params::*;
import age_pkg::*;

module aggregation_engine #(
    parameter AXI_ADDR_WIDTH = 32
) (
    input logic core_clk,
    input logic resetn,

    input logic regbank_clk,
    input logic regbank_resetn,
    
    // Regbank Slave AXI interface
    input  logic [AXI_ADDR_WIDTH-1:0]                           s_axi_awaddr,
    input  logic [2:0]                                          s_axi_awprot,
    input  logic                                                s_axi_awvalid,
    output logic                                                s_axi_awready,
    input  logic [31:0]                                         s_axi_wdata,
    input  logic [3:0]                                          s_axi_wstrb,
    input  logic                                                s_axi_wvalid,
    output logic                                                s_axi_wready,
    input  logic [AXI_ADDR_WIDTH-1:0]                           s_axi_araddr,
    input  logic [2:0]                                          s_axi_arprot,
    input  logic                                                s_axi_arvalid,
    output logic                                                s_axi_arready,
    output logic [31:0]                                         s_axi_rdata,
    output logic [1:0]                                          s_axi_rresp,
    output logic                                                s_axi_rvalid,
    input  logic                                                s_axi_rready,
    output logic [1:0]                                          s_axi_bresp,
    output logic                                                s_axi_bvalid,
    input  logic                                                s_axi_bready,

    // Node Scoreboard -> Aggregation Engine Interface
    input  logic                                                nsb_age_req_valid,
    output logic                                                nsb_age_req_ready,
    input  NSB_AGE_REQ_t                                        nsb_age_req,
    output logic                                                nsb_age_resp_valid, // valid only for now
    output NSB_AGE_RESP_t                                       nsb_age_resp,

    // Message Channel: AGE -> Prefetcher (request)
    output logic [MESSAGE_CHANNEL_COUNT-1:0]                  message_channel_req_valid,
    input  logic [MESSAGE_CHANNEL_COUNT-1:0]                  message_channel_req_ready,
    output MESSAGE_CHANNEL_REQ_t [MESSAGE_CHANNEL_COUNT-1:0]  message_channel_req,
    
    // Message Channel: Prefetcher -> AGE (response)
    input  logic [MESSAGE_CHANNEL_COUNT-1:0]                  message_channel_resp_valid,
    output logic [MESSAGE_CHANNEL_COUNT-1:0]                  message_channel_resp_ready,
    input  MESSAGE_CHANNEL_RESP_t [MESSAGE_CHANNEL_COUNT-1:0] message_channel_resp,

    // AGE -> Aggregation Buffer
    output logic [AGGREGATION_BUFFER_SLOTS-1:0]                                                       aggregation_buffer_slot_set_node_id_valid,
    output logic [AGGREGATION_BUFFER_SLOTS-1:0] [NODE_ID_WIDTH-1:0]                                   aggregation_buffer_slot_set_node_id,

    output logic [AGGREGATION_BUFFER_SLOTS-1:0]                                                       aggregation_buffer_slot_write_enable,
    output logic [AGGREGATION_BUFFER_SLOTS-1:0] [$clog2(top_pkg::AGGREGATION_BUFFER_WRITE_DEPTH)-1:0] aggregation_buffer_slot_write_address,
    output logic [AGGREGATION_BUFFER_SLOTS-1:0] [age_pkg::PAYLOAD_DATA_WIDTH-1:0]                     aggregation_buffer_slot_write_data,
    input  logic [AGGREGATION_BUFFER_SLOTS-1:0] [$clog2(top_pkg::AGGREGATION_BUFFER_READ_DEPTH)-1:0]  aggregation_buffer_slot_feature_count,
    input  logic [AGGREGATION_BUFFER_SLOTS-1:0]                                                       aggregation_buffer_slot_slot_free,

    output logic [TOTAL_AGGREGATION_MANAGERS-1:0]                                                  scale_factor_queue_pop,
    input  logic [TOTAL_AGGREGATION_MANAGERS-1:0] [SCALE_FACTOR_QUEUE_READ_WIDTH-1:0]              scale_factor_queue_out_data,
    input  logic [TOTAL_AGGREGATION_MANAGERS-1:0] [$clog2(SCALE_FACTOR_QUEUE_READ_DEPTH):0]        scale_factor_queue_count,
    input  logic [TOTAL_AGGREGATION_MANAGERS-1:0]                                                  scale_factor_queue_empty,
    input  logic [TOTAL_AGGREGATION_MANAGERS-1:0]                                                  scale_factor_queue_full

);

// ==================================================================================================================================================
// Declarations
// ==================================================================================================================================================

// Regbank
// ------------------------------------------------------------

logic layer_config_in_features_strobe;
logic [9:0] layer_config_in_features_count;
logic layer_config_out_features_strobe;
logic [3:0] layer_config_out_features_count;
logic layer_config_upsampling_parameter_strobe;
logic [31:0] layer_config_upsampling_parameter_value;

// NOC Mesh
// ----------------------------------------------------

logic  [MESH_COLS-1:0][MESH_ROWS-1:0][VC_NUM-1:0]  node_router_on;
logic  [MESH_COLS-1:0][MESH_ROWS-1:0]              node_router_valid;
logic  [MESH_COLS-1:0][MESH_ROWS-1:0][VC_NUM-1:0]  node_router_ready;
noc_params::flit_t [MESH_COLS-1:0][MESH_ROWS-1:0]  node_router_data;

logic  [MESH_COLS-1:0][MESH_ROWS-1:0][VC_NUM-1:0]  router_node_on;
logic  [MESH_COLS-1:0][MESH_ROWS-1:0]              router_node_valid;
logic  [MESH_COLS-1:0][MESH_ROWS-1:0][VC_NUM-1:0]  router_node_ready;
noc_params::flit_t [MESH_COLS-1:0][MESH_ROWS-1:0]  router_node_data;

// Aggregation Managers
// ----------------------------------------------------

logic allocation_req_ready_float32;
logic allocation_req_ready_fixed16;

logic [TOTAL_AGGREGATION_MANAGERS-1:0]                                     age_agm_req_valid;
logic [TOTAL_AGGREGATION_MANAGERS-1:0]                                     age_agm_req_valid_float32;
logic [TOTAL_AGGREGATION_MANAGERS-1:0]                                     age_agm_req_valid_fixed16;

logic [TOTAL_AGGREGATION_MANAGERS-1:0]                                     age_agm_req_ready;

AGE_AGM_REQ_t [TOTAL_AGGREGATION_MANAGERS-1:0]                             age_agm_req;
AGE_AGM_REQ_t                                                              age_agm_req_float32;
AGE_AGM_REQ_t                                                              age_agm_req_fixed16;

logic [TOTAL_AGGREGATION_MANAGERS-1:0]                                     aggregation_manager_age_done_valid;
logic [TOTAL_AGGREGATION_MANAGERS-1:0]                                     aggregation_manager_age_done_ready;

// Buffer Manager Allocation
logic [TOTAL_AGGREGATION_MANAGERS-1:0]                                     age_agm_buffer_manager_allocation_valid;
logic [TOTAL_AGGREGATION_MANAGERS-1:0]                                     age_agm_buffer_manager_allocation_ready;
logic [$clog2(TOTAL_BUFFER_MANAGERS)-1:0]                                  age_agm_buffer_manager_allocation;

logic [TOTAL_AGGREGATION_MANAGERS-1:0]                                     aggregation_manager_router_on;
logic [TOTAL_AGGREGATION_MANAGERS-1:0]                                     aggregation_manager_router_valid;
logic [TOTAL_AGGREGATION_MANAGERS-1:0]                                     aggregation_manager_router_ready;
flit_t [TOTAL_AGGREGATION_MANAGERS-1:0]                                    aggregation_manager_router_data;

logic [TOTAL_AGGREGATION_MANAGERS-1:0]                                     router_aggregation_manager_on;
logic [TOTAL_AGGREGATION_MANAGERS-1:0]                                     router_aggregation_manager_valid;
logic [TOTAL_AGGREGATION_MANAGERS-1:0]                                     router_aggregation_manager_ready;
flit_t [TOTAL_AGGREGATION_MANAGERS-1:0]                                    router_aggregation_manager_data;

top_pkg::NSB_AGE_REQ_t [TOTAL_AGGREGATION_MANAGERS-1:0]                               agm_allocation;
logic [TOTAL_AGGREGATION_MANAGERS-1:0] [AGC_COUNT_FLOAT32-1:0]                        agm_allocated_agcs;
logic [TOTAL_AGGREGATION_MANAGERS-1:0] [$clog2(MAX_AGC_PER_NODE)-1:0]                 agm_allocated_agcs_count;
logic [TOTAL_AGGREGATION_MANAGERS-1:0] [MAX_AGC_PER_NODE-1:0] [$clog2(MESH_COLS)-1:0] agm_coords_buffer_x;
logic [TOTAL_AGGREGATION_MANAGERS-1:0] [MAX_AGC_PER_NODE-1:0] [$clog2(MESH_ROWS)-1:0] agm_coords_buffer_y;


logic [TOTAL_AGGREGATION_MANAGERS-1:0]         aggregation_manager_resp_arbitration_oh;
logic [$clog2(TOTAL_AGGREGATION_MANAGERS)-1:0] aggregation_manager_resp_arbitration_bin;

// Aggregation Cores
// ----------------------------------------------------

logic  [AGC_ROWS-1:0] [AGC_COLS-1:0] aggregation_core_free;
logic  [AGC_ROWS-1:0] [AGC_COLS-1:0] aggregation_core_router_on;
logic  [AGC_ROWS-1:0] [AGC_COLS-1:0] aggregation_core_router_valid;
logic  [AGC_ROWS-1:0] [AGC_COLS-1:0] aggregation_core_router_ready;
flit_t [AGC_ROWS-1:0] [AGC_COLS-1:0] aggregation_core_router_data;
logic  [AGC_ROWS-1:0] [AGC_COLS-1:0] router_aggregation_core_on;
logic  [AGC_ROWS-1:0] [AGC_COLS-1:0] router_aggregation_core_valid;
logic  [AGC_ROWS-1:0] [AGC_COLS-1:0] router_aggregation_core_ready;
flit_t [AGC_ROWS-1:0] [AGC_COLS-1:0] router_aggregation_core_data;

// Buffer Managers
// ----------------------------------------------------

// Aggregation manager allocation
logic [TOTAL_BUFFER_MANAGERS-1:0]                         age_bm_nodeslot_allocation_valid;
logic [TOTAL_BUFFER_MANAGERS-1:0]                         age_bm_nodeslot_allocation_ready;
age_pkg::AGE_BUFF_MAN_ALLOC_t                             age_bm_nodeslot_allocation;
logic [$clog2(TOTAL_AGGREGATION_MANAGERS)-1:0]            agm_receiving_buffer_manager_allocation;

logic  [BM_ROWS-1:0] [BM_COLS-1:0] buffer_manager_router_on;
logic  [BM_ROWS-1:0] [BM_COLS-1:0] buffer_manager_router_valid;
logic  [BM_ROWS-1:0] [BM_COLS-1:0] buffer_manager_router_ready;
flit_t [BM_ROWS-1:0] [BM_COLS-1:0] buffer_manager_router_data;

logic  [BM_ROWS-1:0] [BM_COLS-1:0] router_buffer_manager_on;
logic  [BM_ROWS-1:0] [BM_COLS-1:0] router_buffer_manager_valid;
logic  [BM_ROWS-1:0] [BM_COLS-1:0] router_buffer_manager_ready;
flit_t [BM_ROWS-1:0] [BM_COLS-1:0] router_buffer_manager_data;

// AGC Allocation
// ----------------------------------------------------

logic [AGC_COUNT_FLOAT32-1:0]           agc_float32_free_mask;
logic [AGC_COUNT_FIXED16-1:0]           agc_fixed16_free_mask;

// (Aggregation <-> Buffer Manager) Allocation
logic [TOTAL_BUFFER_MANAGERS-1:0] buffer_master_allocation_oh;
logic agm_waiting;
logic bm_waiting;

// Other
// ----------------------------------------------------

// for visibility in the waveform
logic [VC_NUM-1:0] error_o [age_pkg::MESH_COLS-1:0][age_pkg::MESH_ROWS-1:0][PORT_NUM-1:0];

// ==================================================================================================================================================
// Instances
// ==================================================================================================================================================

// Register Bank
// ----------------------------------------------------

aggregation_engine_regbank_wrapper #(
    .AXI_ADDR_WIDTH(32)
) aggregation_engine_regbank_regs_i (
    .axi_aclk                       (regbank_clk),
    .axi_aresetn                    (regbank_resetn),
    .fast_clk                       (core_clk),
    .fast_resetn                    (resetn),

    .s_axi_awaddr,
    .s_axi_awprot,
    .s_axi_awvalid,
    .s_axi_awready,
    .s_axi_wdata,
    .s_axi_wstrb,
    .s_axi_wvalid,
    .s_axi_wready,
    .s_axi_araddr,
    .s_axi_arprot,
    .s_axi_arvalid,
    .s_axi_arready,
    .s_axi_rdata,
    .s_axi_rresp,
    .s_axi_rvalid,
    .s_axi_rready,
    .s_axi_bresp,
    .s_axi_bvalid,
    .s_axi_bready,

    .layer_config_in_features_count,
    .layer_config_out_features_count,
    .layer_config_upsampling_parameter_value,
    .*
);

// NOC Mesh
// ----------------------------------------------------

mesh #(
    .BUFFER_SIZE(10),
    .MESH_SIZE_X(age_pkg::MESH_COLS),
    .MESH_SIZE_Y(age_pkg::MESH_ROWS)
) noc_mesh_i (
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

    .error_o            (error_o)
);

// Aggregation Managers
// ----------------------------------------------------

for (genvar agm = 0; agm < TOTAL_AGGREGATION_MANAGERS; agm = agm + 1) begin
    
    aggregation_manager #(
        .X_COORD(agm), // last row
        .Y_COORD(MESH_ROWS - 1)
    ) agm_i (
        .core_clk,
        .resetn,

        .age_aggregation_manager_req_valid                       (age_agm_req_valid [agm]),
        .age_aggregation_manager_req_ready                       (age_agm_req_ready [agm]),
        .age_aggregation_manager_req                             (age_agm_req       [agm]),

        .aggregation_manager_age_done_valid                      (aggregation_manager_age_done_valid [agm]),
        .aggregation_manager_age_done_ready                      (aggregation_manager_age_done_ready [agm]),

        .age_aggregation_manager_buffer_manager_allocation_valid (age_agm_buffer_manager_allocation_valid [agm]),
        .age_aggregation_manager_buffer_manager_allocation_ready (age_agm_buffer_manager_allocation_ready [agm]),
        .age_aggregation_manager_buffer_manager_allocation       (age_agm_buffer_manager_allocation),
        
        .message_channel_req_valid                               (message_channel_req_valid [agm]),
        .message_channel_req_ready                               (message_channel_req_ready [agm]),
        .message_channel_req                                     (message_channel_req [agm]),
                            
        .message_channel_resp_valid                              (message_channel_resp_valid [agm]),
        .message_channel_resp_ready                              (message_channel_resp_ready [agm]),
        .message_channel_resp                                    (message_channel_resp [agm]),
        
        .aggregation_manager_router_on                           (aggregation_manager_router_on [agm]),
        .aggregation_manager_router_valid                        (aggregation_manager_router_valid [agm]),
        .aggregation_manager_router_ready                        (aggregation_manager_router_ready [agm]),
        .aggregation_manager_router_data                         (aggregation_manager_router_data [agm]),
        
        .router_aggregation_manager_on                           (router_aggregation_manager_on [agm]),
        .router_aggregation_manager_valid                        (router_aggregation_manager_valid [agm]),
        .router_aggregation_manager_ready                        (router_aggregation_manager_ready [agm]),
        .router_aggregation_manager_data                         (router_aggregation_manager_data [agm]),
                         
        .agm_allocation                                          (agm_allocation [agm]),
        .agm_allocated_agcs                                      (agm_allocated_agcs [agm]),
        .agm_allocated_agcs_count                                (agm_allocated_agcs_count [agm]),
        .coords_buffer_x                                         (agm_coords_buffer_x [agm]),
        .coords_buffer_y                                         (agm_coords_buffer_y [agm]),

        .scale_factor_queue_pop                                  (scale_factor_queue_pop             [agm]),
        .scale_factor_queue_out_data                             (scale_factor_queue_out_data        [agm]),
        .scale_factor_queue_count                                (scale_factor_queue_count           [agm]),
        .scale_factor_queue_empty                                (scale_factor_queue_empty           [agm]),
        .scale_factor_queue_full                                 (scale_factor_queue_full            [agm])
    );


    always_comb begin
        aggregation_manager_age_done_ready[agm] = aggregation_manager_resp_arbitration_oh [agm];

        // Last row of NOC mesh is taken by message channels
        aggregation_manager_router_on    [agm]              = node_router_on                   [agm][MESH_ROWS-1][0];
        aggregation_manager_router_ready [agm]              = node_router_ready                [agm][MESH_ROWS-1][0];
        node_router_valid                [agm][MESH_ROWS-1] = aggregation_manager_router_valid [agm];
        node_router_data                 [agm][MESH_ROWS-1] = aggregation_manager_router_data  [agm];

        router_aggregation_manager_valid [agm]                 = router_node_valid                [agm][MESH_ROWS-1];
        router_aggregation_manager_data  [agm]                 = router_node_data                 [agm][MESH_ROWS-1];
        router_node_on                   [agm][MESH_ROWS-1][0] = router_aggregation_manager_on    [agm];
        router_node_ready                [agm][MESH_ROWS-1][0] = router_aggregation_manager_ready [agm];
    end

    assign age_agm_req [agm] = age_agm_req_valid_float32 [agm] ? age_agm_req_float32
                            : age_agm_req_valid_fixed16 [agm] ? age_agm_req_fixed16
                            : '0;

end

// Aggregation Cores: FLOAT32
// ----------------------------------------------------

for (genvar agc_float32_row = 0; agc_float32_row < AGC_FLOAT32_ROWS; agc_float32_row = agc_float32_row + 1) begin : float32_row_gen

    // Build mask of free aggregation cores for allocation
    // assign agc_float32_free_mask [((agc_float32_row+1)*AGC_FLOAT32_ROWS)-1:(agc_float32_row*AGC_FLOAT32_ROWS)] = aggregation_core_free[agc_float32_row];
    assign agc_float32_free_mask [((agc_float32_row+1)*AGC_FLOAT32_COLS)-1:(agc_float32_row*AGC_FLOAT32_COLS)] = aggregation_core_free[agc_float32_row] [AGC_FLOAT32_COLS-1:AGC_FLOAT32_COL_OFFSET];

    for (genvar agc_float32_col = 0; agc_float32_col < AGC_FLOAT32_COLS; agc_float32_col = agc_float32_col + 1) begin : float32_col_gen
    
        aggregation_core #(
            .X_COORD       (agc_float32_col),
            .Y_COORD       (agc_float32_row),

            .FEATURE_COUNT (16),
            .DATA_WIDTH    (32)

        ) agc_float32_i (
            .core_clk,
            .resetn,

            // Allocation interface
            .aggregation_core_free          (aggregation_core_free          [agc_float32_row][agc_float32_col]),

            // Aggregation Core -> Router
            .aggregation_core_router_on     (aggregation_core_router_on     [agc_float32_row][agc_float32_col]),
            .aggregation_core_router_valid  (aggregation_core_router_valid  [agc_float32_row][agc_float32_col]),
            .aggregation_core_router_ready  (aggregation_core_router_ready  [agc_float32_row][agc_float32_col]),
            .aggregation_core_router_data   (aggregation_core_router_data   [agc_float32_row][agc_float32_col]),

            // Router -> Aggregation Core
            .router_aggregation_core_on     (router_aggregation_core_on     [agc_float32_row][agc_float32_col]),
            .router_aggregation_core_valid  (router_aggregation_core_valid  [agc_float32_row][agc_float32_col]),
            .router_aggregation_core_ready  (router_aggregation_core_ready  [agc_float32_row][agc_float32_col]),
            .router_aggregation_core_data   (router_aggregation_core_data   [agc_float32_row][agc_float32_col]),

            .layer_config_upsampling_parameter  (layer_config_upsampling_parameter_value)
        );

        always_comb begin
            aggregation_core_router_on    [agc_float32_row][agc_float32_col] = node_router_on                [agc_float32_col][agc_float32_row][0];
            aggregation_core_router_ready [agc_float32_row][agc_float32_col] = node_router_ready             [agc_float32_col][agc_float32_row][0];
            node_router_valid             [agc_float32_col][agc_float32_row] = aggregation_core_router_valid [agc_float32_row][agc_float32_col];
            node_router_data              [agc_float32_col][agc_float32_row] = aggregation_core_router_data  [agc_float32_row][agc_float32_col];
            
            router_aggregation_core_valid [agc_float32_row][agc_float32_col] = router_node_valid             [agc_float32_col][agc_float32_row];
            router_aggregation_core_data  [agc_float32_row][agc_float32_col] = router_node_data              [agc_float32_col][agc_float32_row];
            router_node_on                [agc_float32_col][agc_float32_row][0] = router_aggregation_core_on    [agc_float32_row][agc_float32_col];
            router_node_ready             [agc_float32_col][agc_float32_row][0] = router_aggregation_core_ready [agc_float32_row][agc_float32_col];
        end
    end : float32_col_gen
end : float32_row_gen

// Aggregation Cores: FIXED_16
// ----------------------------------------------------

for (genvar agc_fixed16_row = 0; agc_fixed16_row < AGC_FIXED16_ROWS; agc_fixed16_row = agc_fixed16_row + 1) begin : fixed16_row_gen

    // Build mask of free aggregation cores for allocation
    assign agc_fixed16_free_mask [((agc_fixed16_row+1)*AGC_FIXED16_COLS)-1:(agc_fixed16_row*AGC_FIXED16_COLS)] = aggregation_core_free[agc_fixed16_row] [AGC_FIXED16_COL_OFFSET + AGC_FIXED16_COLS - 1 : AGC_FIXED16_COL_OFFSET];

    for (genvar agc_fixed16_col = AGC_FIXED16_COL_OFFSET; agc_fixed16_col < (AGC_FIXED16_COL_OFFSET + AGC_FIXED16_COLS); agc_fixed16_col++) begin : fixed16_col_gen
    
        aggregation_core #(
            .X_COORD       (agc_fixed16_col),
            .Y_COORD       (agc_fixed16_row),

            .FEATURE_COUNT (16),
            .DATA_WIDTH    (16),

            .PRECISION     ("FIXED_16")

        ) agc_fixed16_i (
            .core_clk,
            .resetn,

            // Allocation interface
            .aggregation_core_free          (aggregation_core_free          [agc_fixed16_row][agc_fixed16_col]),

            // Aggregation Core -> Router
            .aggregation_core_router_on     (aggregation_core_router_on     [agc_fixed16_row][agc_fixed16_col]),
            .aggregation_core_router_valid  (aggregation_core_router_valid  [agc_fixed16_row][agc_fixed16_col]),
            .aggregation_core_router_ready  (aggregation_core_router_ready  [agc_fixed16_row][agc_fixed16_col]),
            .aggregation_core_router_data   (aggregation_core_router_data   [agc_fixed16_row][agc_fixed16_col]),

            // Router -> Aggregation Core
            .router_aggregation_core_on     (router_aggregation_core_on     [agc_fixed16_row][agc_fixed16_col]),
            .router_aggregation_core_valid  (router_aggregation_core_valid  [agc_fixed16_row][agc_fixed16_col]),
            .router_aggregation_core_ready  (router_aggregation_core_ready  [agc_fixed16_row][agc_fixed16_col]),
            .router_aggregation_core_data   (router_aggregation_core_data   [agc_fixed16_row][agc_fixed16_col]),

            .layer_config_upsampling_parameter  (layer_config_upsampling_parameter_value)
        );

        always_comb begin
            aggregation_core_router_on    [agc_fixed16_row][agc_fixed16_col] = node_router_on                [agc_fixed16_col][agc_fixed16_row][0];
            aggregation_core_router_ready [agc_fixed16_row][agc_fixed16_col] = node_router_ready             [agc_fixed16_col][agc_fixed16_row][0];
            node_router_valid             [agc_fixed16_col][agc_fixed16_row] = aggregation_core_router_valid [agc_fixed16_row][agc_fixed16_col];
            node_router_data              [agc_fixed16_col][agc_fixed16_row] = aggregation_core_router_data  [agc_fixed16_row][agc_fixed16_col];
            
            router_aggregation_core_valid [agc_fixed16_row][agc_fixed16_col] = router_node_valid             [agc_fixed16_col][agc_fixed16_row];
            router_aggregation_core_data  [agc_fixed16_row][agc_fixed16_col] = router_node_data              [agc_fixed16_col][agc_fixed16_row];
            router_node_on                [agc_fixed16_col][agc_fixed16_row][0] = router_aggregation_core_on    [agc_fixed16_row][agc_fixed16_col];
            router_node_ready             [agc_fixed16_col][agc_fixed16_row][0] = router_aggregation_core_ready [agc_fixed16_row][agc_fixed16_col];
        end
    end : fixed16_col_gen
end : fixed16_row_gen

// Unused nodes for other aggregation cores
// TO DO: fill (MS3)
for (genvar col = AGC_UNUSED_COLS_OFFSET; col < AGC_COLS; col++) begin
    for (genvar row = 0; row < 8; row++) begin
        always_comb begin
            node_router_valid             [col][row] = '0;
            node_router_data              [col][row] = '0;
            router_node_on                [col][row] = '0;
            router_node_ready             [col][row] = '0;
        end
    end
end

// Buffer Managers
// ----------------------------------------------------

for (genvar bm = 0; bm < TOTAL_BUFFER_MANAGERS; bm++) begin

    buffer_manager #(
        .X_COORD(AGC_COLS), // columns are positioned to the right of AGCs
        .Y_COORD(bm)
    ) buffer_manager_i (
        .core_clk,
        .resetn,

        .age_buffer_manager_nodeslot_allocation_valid  (age_bm_nodeslot_allocation_valid [bm]),
        .age_buffer_manager_nodeslot_allocation_ready  (age_bm_nodeslot_allocation_ready [bm]),
        .age_buffer_manager_nodeslot_allocation        (age_bm_nodeslot_allocation),

        .buffer_manager_router_on     (buffer_manager_router_on      [bm]),
        .buffer_manager_router_valid  (buffer_manager_router_valid   [bm]),
        .buffer_manager_router_ready  (buffer_manager_router_ready   [bm]),
        .buffer_manager_router_data   (buffer_manager_router_data    [bm]),

        .router_buffer_manager_on     (router_buffer_manager_on      [bm]),
        .router_buffer_manager_valid  (router_buffer_manager_valid   [bm]),
        .router_buffer_manager_ready  (router_buffer_manager_ready   [bm]),
        .router_buffer_manager_data   (router_buffer_manager_data    [bm]),

        .buffer_slot_set_node_id_valid (aggregation_buffer_slot_set_node_id_valid [bm]),
        .buffer_slot_set_node_id       (aggregation_buffer_slot_set_node_id  [bm]),
        .bm_buffer_slot_write_enable  (aggregation_buffer_slot_write_enable  [bm]),
        .bm_buffer_slot_write_address (aggregation_buffer_slot_write_address [bm]),
        .bm_buffer_slot_write_data    (aggregation_buffer_slot_write_data    [bm]),
        .buffer_slot_bm_feature_count (aggregation_buffer_slot_feature_count [bm]),
        .buffer_slot_bm_slot_free     (aggregation_buffer_slot_slot_free     [bm])
    );
    
    always_comb begin
        buffer_manager_router_on    [bm]           = node_router_on              [AGC_COLS][bm][0];
        buffer_manager_router_ready [bm]           = node_router_ready           [AGC_COLS][bm][0];
        node_router_valid           [AGC_COLS][bm] = buffer_manager_router_valid [bm];
        node_router_data            [AGC_COLS][bm] = buffer_manager_router_data  [bm];

        router_buffer_manager_valid [bm]           = router_node_valid           [AGC_COLS][bm];
        router_buffer_manager_data  [bm]           = router_node_data            [AGC_COLS][bm];
        router_node_on              [AGC_COLS][bm][0] = router_buffer_manager_on    [bm];
        router_node_ready           [AGC_COLS][bm][0] = router_buffer_manager_ready [bm];
    end
end

// Unused aggregation buffer slots
for (genvar row = TOTAL_BUFFER_MANAGERS; row < AGGREGATION_BUFFER_SLOTS; row++) begin

    assign aggregation_buffer_slot_write_enable = '0;
    assign aggregation_buffer_slot_write_address = '0;
    assign aggregation_buffer_slot_write_data = '0;

end

// Aggregation Core (FLOAT32) Allocation
// ----------------------------------------------------

aggregation_core_allocator #(
    .NUM_CORES            (age_pkg::AGC_COUNT_FLOAT32),
    .PRECISION_COL_OFFSET (AGC_FLOAT32_COL_OFFSET)

) agc_float32_allocator (
    .core_clk               (core_clk),
    .resetn                 (resetn),

    .allocation_req_valid   (nsb_age_req_valid && (nsb_age_req.node_precision == top_pkg::FLOAT_32)),
    .allocation_req_ready   (allocation_req_ready_float32),
    .allocation_req         (nsb_age_req),

    .cores_free             (agc_float32_free_mask),
    .layer_config_in_features_count (layer_config_in_features_count),

    .deallocation_valid     (nsb_age_resp_valid && agm_allocation[aggregation_manager_resp_arbitration_bin].node_precision == top_pkg::FLOAT_32),
    .deallocation_cores     (agm_allocated_agcs [aggregation_manager_resp_arbitration_bin]),

    .age_agm_req_valid      (age_agm_req_valid_float32),
    .age_agm_req_ready      (age_agm_req_ready),
    .age_agm_req            (age_agm_req_float32)
);

// Aggregation Core (FIXED_16) Allocation
// ----------------------------------------------------

aggregation_core_allocator #(
    .NUM_CORES            (age_pkg::AGC_COUNT_FIXED16),
    .PRECISION_COL_OFFSET (AGC_FIXED16_COL_OFFSET)

) agc_fixed16_allocator (
    .core_clk               (core_clk),
    .resetn                 (resetn),

    .allocation_req_valid   (nsb_age_req_valid && (nsb_age_req.node_precision == top_pkg::FIXED_16)),
    .allocation_req_ready   (allocation_req_ready_fixed16),
    .allocation_req         (nsb_age_req),

    .cores_free                     (agc_fixed16_free_mask),
    .layer_config_in_features_count (layer_config_in_features_count),

    .deallocation_valid     (nsb_age_resp_valid && agm_allocation[aggregation_manager_resp_arbitration_bin].node_precision == top_pkg::FIXED_16),
    .deallocation_cores     (agm_allocated_agcs [aggregation_manager_resp_arbitration_bin]),

    .age_agm_req_valid      (age_agm_req_valid_fixed16),
    .age_agm_req_ready      (age_agm_req_ready),
    .age_agm_req            (age_agm_req_fixed16)
);

// ==================================================================================================================================================
// Logic
// ==================================================================================================================================================

// Allocation Managers -> AGM requests
// ----------------------------------------------------

always_comb begin

    // Accept NSB request when correct AGC allocator accepts it
    nsb_age_req_ready = (nsb_age_req.node_precision == top_pkg::FLOAT_32) ? allocation_req_ready_float32
                        : (nsb_age_req.node_precision == top_pkg::FIXED_16) ? allocation_req_ready_fixed16
                        : '0;

    // Drive AGM request from either allocator
    age_agm_req_valid = age_agm_req_valid_float32 | age_agm_req_valid_fixed16;
end

assign nsb_age_resp_valid = |aggregation_manager_age_done_valid;
assign nsb_age_resp.nodeslot = agm_allocation[aggregation_manager_resp_arbitration_bin].nodeslot;

rr_arbiter #(
    .NUM_REQUESTERS(TOTAL_AGGREGATION_MANAGERS)
) aggregation_manager_resp_arbiter (
    .clk        (core_clk),
    .resetn     (resetn),
    
    .request    (aggregation_manager_age_done_valid),
    .update_lru (|aggregation_manager_age_done_valid),
    .grant_oh   (aggregation_manager_resp_arbitration_oh)
);

onehot_to_binary_comb #(
    .INPUT_WIDTH    (TOTAL_AGGREGATION_MANAGERS)
) bm_alloc_oh2bin (
    .input_data     (aggregation_manager_resp_arbitration_oh),
    .output_data    (aggregation_manager_resp_arbitration_bin)
);


// Aggregation Manager Arbitration (to be allocated a buffer manager)
// ----------------------------------------------------

assign agm_waiting = (age_agm_buffer_manager_allocation_ready != '0);
assign bm_waiting = (age_bm_nodeslot_allocation_ready != '0);

logic [TOTAL_AGGREGATION_MANAGERS-1:0] agm_allocation_oh;

rr_arbiter #(
    .NUM_REQUESTERS(TOTAL_AGGREGATION_MANAGERS)
) free_agm_arbiter (
    .clk        (core_clk),
    .resetn     (resetn),

    .request    (age_agm_buffer_manager_allocation_ready),
    .update_lru (agm_waiting && bm_waiting), // update when agm accepting buffer manager allocation
    .grant_oh   (agm_allocation_oh)
);

onehot_to_binary_comb #(
    .INPUT_WIDTH    (TOTAL_AGGREGATION_MANAGERS)
) agm_alloc_req_oh2bin (
    .input_data     (agm_allocation_oh),
    .output_data    (agm_receiving_buffer_manager_allocation)
);

// Drive valid allocation to AGM when it has been arbitrated and a buffer manager is waiting
assign age_agm_buffer_manager_allocation_valid = agm_allocation_oh & {TOTAL_AGGREGATION_MANAGERS{bm_waiting}};

// Buffer Manager arbitration (to be allocated an aggregation manager)
// ----------------------------------------------------

rr_arbiter #(
    .NUM_REQUESTERS (TOTAL_BUFFER_MANAGERS)
) free_buffer_manager_arbiter (
    .clk        (core_clk),
    .resetn     (resetn),
    
    .request    (age_bm_nodeslot_allocation_ready),
    .update_lru (agm_waiting && bm_waiting), // accepting when buffer manager accepting allocation
    .grant_oh   (buffer_master_allocation_oh)
);

onehot_to_binary_comb #(
    .INPUT_WIDTH    (TOTAL_BUFFER_MANAGERS)
) agm_resp_arb_oh2bin (
    .input_data     (buffer_master_allocation_oh),
    .output_data    (age_agm_buffer_manager_allocation) // buffer manager receiving allocation
);

// Drive valid allocation to buffer manager when it has been arbitrated and an AGM is waiting
assign age_bm_nodeslot_allocation_valid = buffer_master_allocation_oh & {TOTAL_BUFFER_MANAGERS{agm_waiting}};

// Allocation payloads
always_comb begin
    // Tell the chosen buffer manager which AGM was chosen
    age_bm_nodeslot_allocation.nodeslot                = agm_receiving_buffer_manager_allocation;
    age_bm_nodeslot_allocation.node_id                 = agm_allocation[agm_receiving_buffer_manager_allocation].node_id;
    age_bm_nodeslot_allocation.aggregation_manager     = agm_receiving_buffer_manager_allocation;
    age_bm_nodeslot_allocation.allocated_agcs_x_coords = agm_coords_buffer_x       [agm_receiving_buffer_manager_allocation];
    age_bm_nodeslot_allocation.allocated_agcs_y_coords = agm_coords_buffer_y       [agm_receiving_buffer_manager_allocation];
    age_bm_nodeslot_allocation.allocated_agcs_count    = agm_allocated_agcs_count  [agm_receiving_buffer_manager_allocation];
end

// ==================================================================================================================================================
// Assertions
// ==================================================================================================================================================

endmodule