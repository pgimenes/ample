
import top_pkg::*;
import noc_pkg::*;
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
    output logic [top_pkg::PRECISION_COUNT-1:0] [AGGREGATION_BUFFER_SLOTS-1:0]                                                       aggregation_buffer_slot_set_node_id_valid,
    output logic [top_pkg::PRECISION_COUNT-1:0] [AGGREGATION_BUFFER_SLOTS-1:0] [NODE_ID_WIDTH-1:0]                                   aggregation_buffer_slot_set_node_id,

    output logic [top_pkg::PRECISION_COUNT-1:0] [AGGREGATION_BUFFER_SLOTS-1:0]                                                       aggregation_buffer_slot_write_enable,
    output logic [top_pkg::PRECISION_COUNT-1:0] [AGGREGATION_BUFFER_SLOTS-1:0] [$clog2(top_pkg::AGGREGATION_BUFFER_WRITE_DEPTH)-1:0] aggregation_buffer_slot_write_address,
    output logic [top_pkg::PRECISION_COUNT-1:0] [AGGREGATION_BUFFER_SLOTS-1:0] [noc_pkg::PAYLOAD_DATA_WIDTH-1:0]                     aggregation_buffer_slot_write_data,
    
    input  logic [top_pkg::PRECISION_COUNT-1:0] [AGGREGATION_BUFFER_SLOTS-1:0] [$clog2(top_pkg::AGGREGATION_BUFFER_READ_DEPTH)-1:0]  aggregation_buffer_slot_feature_count,
    input  logic [top_pkg::PRECISION_COUNT-1:0] [AGGREGATION_BUFFER_SLOTS-1:0]                                                       aggregation_buffer_slot_slot_free,

    output logic [MESSAGE_CHANNEL_COUNT-1:0]                                                  scale_factor_queue_pop,
    input  logic [MESSAGE_CHANNEL_COUNT-1:0] [SCALE_FACTOR_QUEUE_READ_WIDTH-1:0]              scale_factor_queue_out_data

);

// Aggregation meshes have symmetric dimensions
parameter AGGREGATION_ROWS = top_pkg::AGGREGATION_BUFFER_SLOTS;
parameter AGGREGATION_COLS = top_pkg::MESSAGE_CHANNEL_COUNT/top_pkg::PRECISION_COUNT;
parameter TOTAL_AGGREGATION_MANAGERS = top_pkg::PRECISION_COUNT * AGGREGATION_COLS;

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
logic [top_pkg::PRECISION_COUNT-1:0]                                                        aggregation_req_valid;
logic [top_pkg::PRECISION_COUNT-1:0]                                                        aggregation_req_ready;
top_pkg::NSB_AGE_REQ_t                                                                      aggregation_req;

// Aggregation Mesh -> AGE : Request Interface
logic [top_pkg::PRECISION_COUNT-1:0] [AGGREGATION_COLS-1:0]                                 aggregation_manager_done_valid;
logic [top_pkg::PRECISION_COUNT-1:0] [AGGREGATION_COLS-1:0]                                 aggregation_manager_done_ready;

// NSB Response Arbitration
// ------------------------------------------------------------

logic [top_pkg::PRECISION_COUNT * AGGREGATION_COLS - 1 : 0] aggregation_manager_resp_arbitration_oh;
logic [$clog2(top_pkg::PRECISION_COUNT * AGGREGATION_COLS) - 1 : 0] aggregation_manager_resp_arbitration_bin;

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

// Aggregation Meshes (per precision)
// ----------------------------------------------------

for (genvar precision = top_pkg::FLOAT_32; precision < top_pkg::PRECISION_COUNT; precision++) begin : precision_block

    aggregation_mesh #(
        .AGGREGATION_ROWS            (AGGREGATION_ROWS),
        .AGGREGATION_COLS            (AGGREGATION_COLS),
        .PRECISION                   (precision),
        .AGGREGATION_CORE_DATA_WIDTH (top_pkg::bits_per_precision(top_pkg::NODE_PRECISION_e'(precision)))
    ) aggregation_mesh_i (
    
        .core_clk,
        .resetn,
    
        // AGE -> Aggregation Mesh: Request Interface
        .aggregation_req_valid                                         (aggregation_req_valid                     [precision]),
        .aggregation_req_ready                                         (aggregation_req_ready                     [precision]),
        .aggregation_req                                               (aggregation_req),                         

        // Aggregation Mesh -> AGE : Response Interface
        .aggregation_manager_done_valid                                (aggregation_manager_done_valid            [precision]),
        .aggregation_manager_done_ready                                (aggregation_manager_done_ready            [precision]),

        // Message Channel: AGE -> Prefetcher (request)
        .message_channel_req_valid                                     (message_channel_req_valid                 [(precision + 1) * AGGREGATION_COLS - 1 : precision * AGGREGATION_COLS]),
        .message_channel_req_ready                                     (message_channel_req_ready                 [(precision + 1) * AGGREGATION_COLS - 1 : precision * AGGREGATION_COLS]),
        .message_channel_req                                           (message_channel_req                       [(precision + 1) * AGGREGATION_COLS - 1 : precision * AGGREGATION_COLS]),

        // Message Channel: Prefetcher -> AGE (response)
        .message_channel_resp_valid                                    (message_channel_resp_valid                [(precision + 1) * AGGREGATION_COLS - 1 : precision * AGGREGATION_COLS]),
        .message_channel_resp_ready                                    (message_channel_resp_ready                [(precision + 1) * AGGREGATION_COLS - 1 : precision * AGGREGATION_COLS]),
        .message_channel_resp                                          (message_channel_resp                      [(precision + 1) * AGGREGATION_COLS - 1 : precision * AGGREGATION_COLS]),

        // Aggregation Mesh -> Fetch Tag: Scale Factor Queue Interface
        .scale_factor_queue_pop                                        (scale_factor_queue_pop                    [(precision + 1) * AGGREGATION_COLS - 1 : precision * AGGREGATION_COLS]),
        .scale_factor_queue_out_data                                   (scale_factor_queue_out_data               [(precision + 1) * AGGREGATION_COLS - 1 : precision * AGGREGATION_COLS]),
        
        // AGE -> Aggregation Buffer
        .aggregation_buffer_slot_set_node_id_valid                     (aggregation_buffer_slot_set_node_id_valid [precision]),
        .aggregation_buffer_slot_set_node_id                           (aggregation_buffer_slot_set_node_id       [precision]),
        
        .aggregation_buffer_slot_write_enable                          (aggregation_buffer_slot_write_enable      [precision]),
        .aggregation_buffer_slot_write_address                         (aggregation_buffer_slot_write_address     [precision]),
        .aggregation_buffer_slot_write_data                            (aggregation_buffer_slot_write_data        [precision]),
        
        .aggregation_buffer_slot_feature_count                         (aggregation_buffer_slot_feature_count     [precision]),
        .aggregation_buffer_slot_slot_free                             (aggregation_buffer_slot_slot_free         [precision]),
        
        // Layer configuration parameters
        .layer_config_in_features_count                                (layer_config_in_features_count)
    
    );

    assign aggregation_req_valid [precision] = nsb_age_req_valid && (nsb_age_req.node_precision == precision);

end : precision_block

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

// ==================================================================================================================================================
// Logic
// ==================================================================================================================================================

// NSB Interface
// ----------------------------------------------------

// Accept NSB request when correct AGC allocator accepts it
always_comb begin
    nsb_age_req_ready = |(aggregation_req_valid & aggregation_req_ready);
    nsb_age_resp_valid = |aggregation_manager_done_valid;
    // TO DO: fix
    nsb_age_resp.nodeslot = '0;
end

// ==================================================================================================================================================
// Assertions
// ==================================================================================================================================================

endmodule