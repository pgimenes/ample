
import top_pkg::*;
import noc_pkg::*;
import age_pkg::*;

module aggregation_engine #(
    parameter AXI_ADDR_WIDTH = 32,
    parameter MESH_MULTIPLPIER = top_pkg::MESH_MULTIPLIER
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
    output logic [top_pkg::PRECISION_COUNT-1:0] [AGGREGATION_BUFFER_SLOTS-1:0]                                                       aggregation_buffer_slot_set_node_id_valid,
    output logic [top_pkg::PRECISION_COUNT-1:0] [AGGREGATION_BUFFER_SLOTS-1:0] [NODE_ID_WIDTH-1:0]                                   aggregation_buffer_slot_set_node_id,
    
    output logic [top_pkg::PRECISION_COUNT-1:0] [AGGREGATION_BUFFER_SLOTS-1:0]                                                       aggregation_buffer_slot_write_enable,
    output logic [top_pkg::PRECISION_COUNT-1:0] [AGGREGATION_BUFFER_SLOTS-1:0] [$clog2(top_pkg::AGGREGATION_BUFFER_WRITE_DEPTH)-1:0] aggregation_buffer_slot_write_address,
    output logic [top_pkg::PRECISION_COUNT-1:0] [AGGREGATION_BUFFER_SLOTS-1:0] [noc_pkg::PAYLOAD_DATA_WIDTH-1:0]                     aggregation_buffer_slot_write_data,
    
    input  logic [top_pkg::PRECISION_COUNT-1:0] [AGGREGATION_BUFFER_SLOTS-1:0] [$clog2(top_pkg::AGGREGATION_BUFFER_READ_DEPTH)-1:0]  aggregation_buffer_slot_feature_count,
    input  logic [top_pkg::PRECISION_COUNT-1:0] [AGGREGATION_BUFFER_SLOTS-1:0]                                                       aggregation_buffer_slot_slot_free,

    output logic [MESSAGE_CHANNEL_COUNT-1:0]                                                  scale_factor_queue_pop,
    input  logic [MESSAGE_CHANNEL_COUNT-1:0] [SCALE_FACTOR_QUEUE_READ_WIDTH-1:0]              scale_factor_queue_out_data,
    input  logic [MESSAGE_CHANNEL_COUNT-1:0]                                                  scale_factor_queue_out_valid

);

// Aggregation meshes have symmetric dimensions
parameter AGGREGATION_ROWS = top_pkg::TRANSFORMATION_CHANNELS;
parameter AGGREGATION_COLS = top_pkg::AGGREGATION_CHANNELS;
parameter AGGREGATION_MANAGERS_PER_PRECISION = top_pkg::MESH_MULTIPLIER * AGGREGATION_ROWS;
parameter TOTAL_AGGREGATION_MANAGERS = top_pkg::PRECISION_COUNT * AGGREGATION_MANAGERS_PER_PRECISION;

// ==================================================================================================================================================
// Declarations
// ==================================================================================================================================================

// Regbank
// ------------------------------------------------------------

logic        layer_config_in_features_strobe;
logic [9:0]  layer_config_in_features_count;
logic        layer_config_out_features_strobe;
logic [3:0]  layer_config_out_features_count;
logic        layer_config_upsampling_parameter_strobe;
logic [31:0] layer_config_upsampling_parameter_value;

// Aggregation
// ------------------------------------------------------------

// AGE -> Aggregation Mesh: Request Interface
logic [top_pkg::PRECISION_COUNT-1:0] [MESH_MULTIPLIER-1:0]                                  aggregation_req_valid;
logic [top_pkg::PRECISION_COUNT-1:0] [MESH_MULTIPLIER-1:0]                                  aggregation_req_ready;
top_pkg::NSB_AGE_REQ_t                                                                      aggregation_req;

// Aggregation Mesh -> AGE : Request Interface
logic [top_pkg::PRECISION_COUNT-1:0] [MESH_MULTIPLIER-1:0] [AGGREGATION_ROWS-1:0]                                           aggregation_manager_done_valid;
logic [top_pkg::PRECISION_COUNT-1:0] [MESH_MULTIPLIER-1:0] [AGGREGATION_ROWS-1:0] [$clog2(top_pkg::MAX_NODESLOT_COUNT)-1:0] aggregation_manager_done_nodeslot;
logic [top_pkg::PRECISION_COUNT-1:0] [MESH_MULTIPLIER-1:0] [AGGREGATION_ROWS-1:0]                                           aggregation_manager_done_ready;

// AGM-wise signal for reading from AGM resp arbitration
logic [top_pkg::PRECISION_COUNT * MESH_MULTIPLIER * AGGREGATION_ROWS -1:0] [$clog2(top_pkg::MAX_NODESLOT_COUNT)-1:0] agm_nodeslot;

// NSB Response Arbitration
// ------------------------------------------------------------

logic [top_pkg::PRECISION_COUNT * MESH_MULTIPLIER * AGGREGATION_ROWS - 1 : 0] aggregation_manager_resp_arbitration_oh;
logic [$clog2(top_pkg::PRECISION_COUNT * MESH_MULTIPLIER * AGGREGATION_ROWS) - 1 : 0] aggregation_manager_resp_arbitration_bin;

// Buffer manager arbiter
// ------------------------------------------------------------

logic [top_pkg::PRECISION_COUNT-1:0] [top_pkg::MESH_MULTIPLIER-1:0] [AGGREGATION_BUFFER_SLOTS-1:0]                                                       bm_set_node_id_valid;
logic [top_pkg::PRECISION_COUNT-1:0] [top_pkg::MESH_MULTIPLIER-1:0] [AGGREGATION_BUFFER_SLOTS-1:0]                                                       bm_set_node_id_ready;
logic [top_pkg::PRECISION_COUNT-1:0] [top_pkg::MESH_MULTIPLIER-1:0] [AGGREGATION_BUFFER_SLOTS-1:0] [NODE_ID_WIDTH-1:0]                                   bm_set_node_id;
logic [top_pkg::PRECISION_COUNT-1:0] [top_pkg::MESH_MULTIPLIER-1:0] [AGGREGATION_BUFFER_SLOTS-1:0]                                                       bm_write_enable;
logic [top_pkg::PRECISION_COUNT-1:0] [top_pkg::MESH_MULTIPLIER-1:0] [AGGREGATION_BUFFER_SLOTS-1:0]                                                       bm_write_ready;
logic [top_pkg::PRECISION_COUNT-1:0] [top_pkg::MESH_MULTIPLIER-1:0] [AGGREGATION_BUFFER_SLOTS-1:0] [$clog2(top_pkg::AGGREGATION_BUFFER_WRITE_DEPTH)-1:0] bm_write_address;
logic [top_pkg::PRECISION_COUNT-1:0] [top_pkg::MESH_MULTIPLIER-1:0] [AGGREGATION_BUFFER_SLOTS-1:0] [noc_pkg::PAYLOAD_DATA_WIDTH-1:0]                     bm_write_data;

logic [top_pkg::PRECISION_COUNT-1:0] [top_pkg::MESH_MULTIPLIER-1:0] [AGGREGATION_ROWS-1:0] buffer_manager_done;

// ==================================================================================================================================================
// Instances
// ==================================================================================================================================================

// Register Bank
// ----------------------------------------------------

aggregation_engine_regbank_wrapper #(
    .AXI_ADDR_WIDTH                 (32)
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

// Aggregation Meshes (per precision)
// ----------------------------------------------------

for (genvar precision = 0; precision < top_pkg::PRECISION_COUNT; precision++) begin : precision_block

    // Multiple mesh blocks to interleave columns of aggregation managers
    for (genvar mesh = 0; mesh < MESH_MULTIPLPIER; mesh++) begin : mesh_block

        aggregation_mesh #(
            .AGGREGATION_ROWS            (AGGREGATION_ROWS),
            .AGGREGATION_COLS            (AGGREGATION_COLS),
            .PRECISION                   (precision),
            .AGGREGATION_CORE_DATA_WIDTH (top_pkg::bits_per_precision(top_pkg::NODE_PRECISION_e'(precision)))
        ) aggregation_mesh_i (
        
            .core_clk                                                      (core_clk),
            .resetn                                                        (resetn),
        
            // AGE -> Aggregation Mesh: Request Interface
            .aggregation_req_valid                                         (aggregation_req_valid                     [precision] [mesh]),
            .aggregation_req_ready                                         (aggregation_req_ready                     [precision] [mesh]),
            .aggregation_req                                               (aggregation_req),                         

            // Aggregation Mesh -> AGE : Response Interface
            .aggregation_manager_done_valid                                (aggregation_manager_done_valid            [precision] [mesh]),
            .aggregation_manager_done_nodeslot                             (aggregation_manager_done_nodeslot         [precision] [mesh]),
            .aggregation_manager_done_ready                                (aggregation_manager_done_ready            [precision] [mesh]),

            // Message Channel: AGE -> Prefetcher (request)
            .message_channel_req_valid                                     (message_channel_req_valid                 [(precision * AGGREGATION_MANAGERS_PER_PRECISION) + (mesh + 1) * AGGREGATION_ROWS - 1 : (precision * AGGREGATION_MANAGERS_PER_PRECISION) + mesh * AGGREGATION_ROWS]),
            .message_channel_req_ready                                     (message_channel_req_ready                 [(precision * AGGREGATION_MANAGERS_PER_PRECISION) + (mesh + 1) * AGGREGATION_ROWS - 1 : (precision * AGGREGATION_MANAGERS_PER_PRECISION) + mesh * AGGREGATION_ROWS]),
            .message_channel_req                                           (message_channel_req                       [(precision * AGGREGATION_MANAGERS_PER_PRECISION) + (mesh + 1) * AGGREGATION_ROWS - 1 : (precision * AGGREGATION_MANAGERS_PER_PRECISION) + mesh * AGGREGATION_ROWS]),

            // Message Channel: Prefetcher -> AGE (response)
            .message_channel_resp_valid                                    (message_channel_resp_valid                [(precision * AGGREGATION_MANAGERS_PER_PRECISION) + (mesh + 1) * AGGREGATION_ROWS - 1 : (precision * AGGREGATION_MANAGERS_PER_PRECISION) + mesh * AGGREGATION_ROWS]),
            .message_channel_resp_ready                                    (message_channel_resp_ready                [(precision * AGGREGATION_MANAGERS_PER_PRECISION) + (mesh + 1) * AGGREGATION_ROWS - 1 : (precision * AGGREGATION_MANAGERS_PER_PRECISION) + mesh * AGGREGATION_ROWS]),
            .message_channel_resp                                          (message_channel_resp                      [(precision * AGGREGATION_MANAGERS_PER_PRECISION) + (mesh + 1) * AGGREGATION_ROWS - 1 : (precision * AGGREGATION_MANAGERS_PER_PRECISION) + mesh * AGGREGATION_ROWS]),

            // Aggregation Mesh -> Fetch Tag: Scale Factor Queue Interface
            .scale_factor_queue_pop                                        (scale_factor_queue_pop                    [(precision * AGGREGATION_MANAGERS_PER_PRECISION) + (mesh + 1) * AGGREGATION_ROWS - 1 : (precision * AGGREGATION_MANAGERS_PER_PRECISION) + mesh * AGGREGATION_ROWS]),
            .scale_factor_queue_out_data                                   (scale_factor_queue_out_data               [(precision * AGGREGATION_MANAGERS_PER_PRECISION) + (mesh + 1) * AGGREGATION_ROWS - 1 : (precision * AGGREGATION_MANAGERS_PER_PRECISION) + mesh * AGGREGATION_ROWS]),
            .scale_factor_queue_out_valid                                  (scale_factor_queue_out_valid              [(precision * AGGREGATION_MANAGERS_PER_PRECISION) + (mesh + 1) * AGGREGATION_ROWS - 1 : (precision * AGGREGATION_MANAGERS_PER_PRECISION) + mesh * AGGREGATION_ROWS]),
            
            // AGE -> Aggregation Buffer
            .aggregation_buffer_slot_set_node_id_valid                     (bm_set_node_id_valid [precision][mesh]),
            .aggregation_buffer_slot_set_node_id_ready                     (bm_set_node_id_ready [precision][mesh]),
            .aggregation_buffer_slot_set_node_id                           (bm_set_node_id       [precision][mesh]),
            
            .aggregation_buffer_slot_write_enable                          (bm_write_enable      [precision][mesh]),
            .aggregation_buffer_slot_write_ready                           (bm_write_ready       [precision][mesh]),
            .aggregation_buffer_slot_write_address                         (bm_write_address     [precision][mesh]),
            .aggregation_buffer_slot_write_data                            (bm_write_data        [precision][mesh]),
            
            .aggregation_buffer_slot_feature_count                         (aggregation_buffer_slot_feature_count     [precision]),
            .aggregation_buffer_slot_slot_free                             (aggregation_buffer_slot_slot_free         [precision]),
            
            // Layer configuration parameters
            .layer_config_in_features_count                                (layer_config_in_features_count),

            .buffer_manager_done                                           (buffer_manager_done [precision] [mesh])
        
        );

        assign aggregation_req_valid [precision] [mesh] = nsb_age_req_valid && (nsb_age_req.node_precision == precision) && ((nsb_age_req.nodeslot / AGGREGATION_ROWS) == mesh);
        assign aggregation_manager_done_ready [precision] [mesh] = aggregation_manager_resp_arbitration_oh [(precision * AGGREGATION_MANAGERS_PER_PRECISION) + (mesh + 1) * AGGREGATION_ROWS - 1 : (precision * AGGREGATION_MANAGERS_PER_PRECISION) + mesh * AGGREGATION_ROWS];

    end : mesh_block

end : precision_block

assign aggregation_req = nsb_age_req;

// Aggregation Manager Response Arbitration
// ----------------------------------------------------

rr_arbiter #(
    .NUM_REQUESTERS(TOTAL_AGGREGATION_MANAGERS)
) aggregation_manager_resp_arbiter (
    .clk        (core_clk),
    .resetn     (resetn),
    
    .request    (aggregation_manager_done_valid),
    .update_lru (|aggregation_manager_done_valid),
    .grant_oh   (aggregation_manager_resp_arbitration_oh),
    .grant_bin  (aggregation_manager_resp_arbitration_bin)
);

// Aggregation Manager Response Arbitration
// ----------------------------------------------------

buffer_manager_arbiter bm_arb_i (
    .core_clk                    (core_clk),
    .resetn                      (resetn),

    // Valid-ready interface from buffer managers
    .input_bm_set_node_id_valid  (bm_set_node_id_valid),
    .input_bm_set_node_id_ready  (bm_set_node_id_ready),
    .input_bm_set_node_id        (bm_set_node_id),

    .input_bm_write_enable       (bm_write_enable),
    .input_bm_write_ready        (bm_write_ready),
    .input_bm_write_address      (bm_write_address),
    .input_bm_write_data         (bm_write_data),

    // Valid-only interface to buffer slots
    .slot_set_node_id_valid (aggregation_buffer_slot_set_node_id_valid),
    .slot_set_node_id       (aggregation_buffer_slot_set_node_id),
    
    .slot_write_enable      (aggregation_buffer_slot_write_enable),
    .slot_write_address     (aggregation_buffer_slot_write_address),
    .slot_write_data        (aggregation_buffer_slot_write_data),
    
    .buffer_manager_done    (buffer_manager_done)
);

// ==================================================================================================================================================
// Logic
// ==================================================================================================================================================

// NSB Interface
// ----------------------------------------------------

// Cast to AGM-wise signal
assign agm_nodeslot = aggregation_manager_done_nodeslot;

// Accept NSB request when correct AGC allocator accepts it
always_comb begin
    nsb_age_req_ready = |(aggregation_req_valid & aggregation_req_ready);
    nsb_age_resp_valid = |aggregation_manager_done_valid;
    nsb_age_resp.nodeslot = agm_nodeslot [aggregation_manager_resp_arbitration_bin];
end

// ==================================================================================================================================================
// Assertions
// ==================================================================================================================================================

endmodule