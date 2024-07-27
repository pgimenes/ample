
import top_pkg::*;

module feature_transformation_engine #(
    parameter FLOAT_WIDTH = 32,
    parameter AXIL_ADDR_WIDTH = 32,
    parameter MATRIX_N = top_pkg::TRANSFORMATION_ROWS,
    parameter SYSTOLIC_MODULE_COUNT = top_pkg::SYSTOLIC_MODULE_COUNT
) (
    input logic                                                 core_clk,
    input logic                                                 resetn,

    input logic                                                 regbank_clk,
    input logic                                                 regbank_resetn,

    // Regbank Slave AXI interface
    input  logic [AXIL_ADDR_WIDTH-1:0]                          s_axi_awaddr,
    input  logic [2:0]                                          s_axi_awprot,
    input  logic                                                s_axi_awvalid,
    output logic                                                s_axi_awready,
    input  logic [31:0]                                         s_axi_wdata,
    input  logic [3:0]                                          s_axi_wstrb,
    input  logic                                                s_axi_wvalid,
    output logic                                                s_axi_wready,
    input  logic [AXIL_ADDR_WIDTH-1:0]                          s_axi_araddr,
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

    // Node Scoreboard -> Transformation Engine Interface
    input  logic                                                nsb_fte_req_valid,
    output logic                                                nsb_fte_req_ready,
    input  NSB_FTE_REQ_t                                        nsb_fte_req,

    output logic                                                nsb_fte_resp_valid,
    output NSB_FTE_RESP_t                                       nsb_fte_resp,

    // Aggregation Buffer Interface
    input  logic [top_pkg::PRECISION_COUNT-1:0] [top_pkg::AGGREGATION_BUFFER_SLOTS-1:0] [top_pkg::NODE_ID_WIDTH-1:0]                 aggregation_buffer_node_id,
    output logic [top_pkg::PRECISION_COUNT-1:0] [top_pkg::AGGREGATION_BUFFER_SLOTS-1:0]                                              aggregation_buffer_pop,
    input  logic [top_pkg::PRECISION_COUNT-1:0] [top_pkg::AGGREGATION_BUFFER_SLOTS-1:0]                                              aggregation_buffer_out_feature_valid,
    input  logic [top_pkg::PRECISION_COUNT-1:0] [top_pkg::AGGREGATION_BUFFER_SLOTS-1:0] [top_pkg::AGGREGATION_BUFFER_READ_WIDTH-1:0] aggregation_buffer_out_feature,
    input  logic [top_pkg::PRECISION_COUNT-1:0] [top_pkg::AGGREGATION_BUFFER_SLOTS-1:0]                                              aggregation_buffer_slot_free,

    // Weight Channels: FTE -> Prefetcher Weight Bank (REQ)
    output logic                 [top_pkg::PRECISION_COUNT-1:0] weight_channel_req_valid,
    input  logic                 [top_pkg::PRECISION_COUNT-1:0] weight_channel_req_ready,
    output WEIGHT_CHANNEL_REQ_t  [top_pkg::PRECISION_COUNT-1:0] weight_channel_req,

    input  logic                 [top_pkg::PRECISION_COUNT-1:0] weight_channel_resp_valid,
    output logic                 [top_pkg::PRECISION_COUNT-1:0] weight_channel_resp_ready,
    input  WEIGHT_CHANNEL_RESP_t [top_pkg::PRECISION_COUNT-1:0] weight_channel_resp,

    // Transformation Buffer Interface
    output logic [top_pkg::PRECISION_COUNT-1:0] [TRANSFORMATION_BUFFER_SLOTS-1:0]                                                    transformation_buffer_write_enable,
    output logic [top_pkg::PRECISION_COUNT-1:0] [TRANSFORMATION_BUFFER_SLOTS-1:0] [$clog2(TRANSFORMATION_BUFFER_WRITE_DEPTH)-1:0]    transformation_buffer_write_address,
    output logic [top_pkg::PRECISION_COUNT-1:0] [TRANSFORMATION_BUFFER_SLOTS-1:0] [TRANSFORMATION_BUFFER_WRITE_WIDTH-1:0]            transformation_buffer_write_data,
    input  logic [top_pkg::PRECISION_COUNT-1:0] [TRANSFORMATION_BUFFER_SLOTS-1:0]                                                    transformation_buffer_slot_free,

    // Feature Transformation Engine -> AXI Interconnect
    output logic [33:0]                       transformation_engine_axi_interconnect_axi_araddr,
    output logic [1:0]                        transformation_engine_axi_interconnect_axi_arburst,
    output logic [3:0]                        transformation_engine_axi_interconnect_axi_arcache,
    output logic [3:0]                        transformation_engine_axi_interconnect_axi_arid,
    output logic [7:0]                        transformation_engine_axi_interconnect_axi_arlen,
    output logic [0:0]                        transformation_engine_axi_interconnect_axi_arlock,
    output logic [2:0]                        transformation_engine_axi_interconnect_axi_arprot,
    output logic [3:0]                        transformation_engine_axi_interconnect_axi_arqos,
    output logic [2:0]                        transformation_engine_axi_interconnect_axi_arsize,
    output logic                              transformation_engine_axi_interconnect_axi_arvalid,
    input  logic                              transformation_engine_axi_interconnect_axi_arready,

    input  logic [511:0]                      transformation_engine_axi_interconnect_axi_rdata,
    input  logic [3:0]                        transformation_engine_axi_interconnect_axi_rid,
    input  logic                              transformation_engine_axi_interconnect_axi_rlast,
    output logic                              transformation_engine_axi_interconnect_axi_rready,
    input  logic [1:0]                        transformation_engine_axi_interconnect_axi_rresp,
    input  logic                              transformation_engine_axi_interconnect_axi_rvalid,
    
    output logic [33:0]                       transformation_engine_axi_interconnect_axi_awaddr,
    output logic [1:0]                        transformation_engine_axi_interconnect_axi_awburst,
    output logic [3:0]                        transformation_engine_axi_interconnect_axi_awcache,
    output logic [3:0]                        transformation_engine_axi_interconnect_axi_awid,
    output logic [7:0]                        transformation_engine_axi_interconnect_axi_awlen,
    output logic [0:0]                        transformation_engine_axi_interconnect_axi_awlock,
    output logic [2:0]                        transformation_engine_axi_interconnect_axi_awprot,
    output logic [3:0]                        transformation_engine_axi_interconnect_axi_awqos,
    input  logic                              transformation_engine_axi_interconnect_axi_awready,
    output logic [2:0]                        transformation_engine_axi_interconnect_axi_awsize,
    output logic                              transformation_engine_axi_interconnect_axi_awvalid,
    
    output logic [511:0]                      transformation_engine_axi_interconnect_axi_wdata,
    output logic                              transformation_engine_axi_interconnect_axi_wlast,
    input  logic                              transformation_engine_axi_interconnect_axi_wready,
    output logic [63:0]                       transformation_engine_axi_interconnect_axi_wstrb,
    output logic                              transformation_engine_axi_interconnect_axi_wvalid,

    input  logic [3:0]                        transformation_engine_axi_interconnect_axi_bid,
    output logic                              transformation_engine_axi_interconnect_axi_bready,
    input  logic [1:0]                        transformation_engine_axi_interconnect_axi_bresp,
    input  logic                              transformation_engine_axi_interconnect_axi_bvalid
    

);

// ==================================================================================================================================================
// Declarations
// ==================================================================================================================================================

// Register Bank
// -------------------------------------------------------------------------------------

logic        layer_config_in_features_strobe;
logic [9:0]  layer_config_in_features_count;
logic        layer_config_out_features_strobe;
logic [9:0]  layer_config_out_features_count;
                                    
logic        layer_config_activation_function_strobe;
logic [1:0]  layer_config_activation_function_value;

logic        layer_config_bias_strobe;
logic [31:0] layer_config_bias_value;

logic        layer_config_leaky_relu_alpha_strobe;
logic [31:0] layer_config_leaky_relu_alpha_value;

logic        layer_config_out_features_address_msb_strobe;
logic        layer_config_out_features_address_lsb_strobe;
logic [1:0]  layer_config_out_features_address_msb_value;
logic [31:0] layer_config_out_features_address_lsb_value;

logic       ctrl_buffering_enable_strobe;
logic [0:0] ctrl_buffering_enable_value;
logic       ctrl_writeback_enable_strobe;
logic [0:0] ctrl_writeback_enable_value;

// AXI Write Master
// -------------------------------------------------------------------------------------

logic                              axi_write_master_req_valid;
logic                              axi_write_master_req_ready;
logic [33:0]                       axi_write_master_req_start_address;
logic [7:0]                        axi_write_master_req_len;

logic                              axi_write_master_pop;
logic                              axi_write_master_data_valid;
logic [511:0]                      axi_write_master_data;

logic                              axi_write_master_resp_valid;
logic                              axi_write_master_resp_ready;

// Transformation Cores
// -------------------------------------------------------------------------------------

logic [top_pkg::PRECISION_COUNT-1:0]          transformation_core_req_ready;

logic          [top_pkg::PRECISION_COUNT-1:0] transformation_core_resp_valid;
logic          [top_pkg::PRECISION_COUNT-1:0] transformation_core_resp_ready;
NSB_FTE_RESP_t [top_pkg::PRECISION_COUNT-1:0] transformation_core_resp;

logic [top_pkg::PRECISION_COUNT-1:0]          transformation_core_axi_write_master_req_valid;
logic [top_pkg::PRECISION_COUNT-1:0]          transformation_core_axi_write_master_req_ready;
logic [top_pkg::PRECISION_COUNT-1:0] [33:0]   transformation_core_axi_write_master_req_start_address;
logic [top_pkg::PRECISION_COUNT-1:0] [7:0]    transformation_core_axi_write_master_req_len;

logic [top_pkg::PRECISION_COUNT-1:0]          transformation_core_axi_write_master_pop;
logic [top_pkg::PRECISION_COUNT-1:0]          transformation_core_axi_write_master_data_valid;
logic [top_pkg::PRECISION_COUNT-1:0] [511:0]  transformation_core_axi_write_master_data;
logic [top_pkg::PRECISION_COUNT-1:0] [511:0]  transformation_core_axi_write_master_data_unreversed;

logic [top_pkg::PRECISION_COUNT-1:0]          transformation_core_axi_write_master_resp_valid;
logic [top_pkg::PRECISION_COUNT-1:0]          transformation_core_axi_write_master_resp_ready;

logic [$clog2(top_pkg::PRECISION_COUNT)-1:0] transformation_core_resp_valid_bin;

logic [$clog2(top_pkg::PRECISION_COUNT)-1:0] transformation_core_write_master_alloc_bin;
logic [$clog2(top_pkg::PRECISION_COUNT)-1:0] transformation_core_write_master_alloc_bin_q;

// ==================================================================================================================================================
// Instances
// ==================================================================================================================================================

// Regbank
// --------------------------------------------------------------------------------

feature_transformation_engine_regbank_wrapper feature_transformation_engine_regbank_i (
    // Clock and Reset
    .axi_aclk                       (regbank_clk),
    .axi_aresetn                    (regbank_resetn),
    .fast_clk                       (core_clk),
    .fast_resetn                    (resetn),

    // AXI Write Address Channel
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

    // User Ports
    .layer_config_in_features_count,
    .layer_config_out_features_count,
    .layer_config_activation_function_value,
    .layer_config_bias_value,
    .layer_config_leaky_relu_alpha_value,
    .layer_config_out_features_address_msb_value,
    .layer_config_out_features_address_lsb_value,
    .ctrl_buffering_enable_value,
    .ctrl_writeback_enable_value
);

// Transformation Cores
// --------------------------------------------------------------------------------

for (genvar precision = 0; precision < top_pkg::PRECISION_COUNT; precision++) begin
    feature_transformation_core #(
        .PRECISION             (top_pkg::NODE_PRECISION_e'(precision)),
        .FLOAT_WIDTH           (FLOAT_WIDTH),
        .DATA_WIDTH            (top_pkg::bits_per_precision(top_pkg::NODE_PRECISION_e'(precision))),

        .MATRIX_N              (MATRIX_N),
        .SYSTOLIC_MODULE_COUNT (SYSTOLIC_MODULE_COUNT)
    ) feature_transformation_core_i (
        .core_clk                                                   (core_clk),
        .resetn                                                     (resetn),

        // Node Scoreboard -> Transformation Engine Interface
        .nsb_fte_req_valid                                          (nsb_fte_req_valid && (nsb_fte_req.precision == precision)),
        .nsb_fte_req_ready                                          (transformation_core_req_ready [precision]),
        .nsb_fte_req                                                (nsb_fte_req),

        .nsb_fte_resp_valid                                         (transformation_core_resp_valid                         [precision]),
        .nsb_fte_resp_ready                                         (transformation_core_resp_ready                         [precision]),
        .nsb_fte_resp                                               (transformation_core_resp                               [precision]),

        // Aggregation Buffer Interface
        .transformation_core_aggregation_buffer_node_id             (aggregation_buffer_node_id                             [precision]),
        .transformation_core_aggregation_buffer_pop                 (aggregation_buffer_pop                                 [precision]),
        .transformation_core_aggregation_buffer_out_feature_valid   (aggregation_buffer_out_feature_valid                   [precision]),
        .transformation_core_aggregation_buffer_out_feature         (aggregation_buffer_out_feature                         [precision]),
        .transformation_core_aggregation_buffer_slot_free           (aggregation_buffer_slot_free                           [precision]),

        // Weight Channels: FTE -> Prefetcher Weight Bank (REQ)
        .weight_channel_req_valid                                   (weight_channel_req_valid                               [precision]),
        .weight_channel_req_ready                                   (weight_channel_req_ready                               [precision]),
        .weight_channel_req                                         (weight_channel_req                                     [precision]),
        .weight_channel_resp_valid                                  (weight_channel_resp_valid                              [precision]),
        .weight_channel_resp_ready                                  (weight_channel_resp_ready                              [precision]),
        .weight_channel_resp                                        (weight_channel_resp                                    [precision]),

        // Transformation Buffer Interface
        .transformation_buffer_write_enable                         (transformation_buffer_write_enable                     [precision]),
        .transformation_buffer_write_address                        (transformation_buffer_write_address                    [precision]),
        .transformation_buffer_write_data                           (transformation_buffer_write_data                       [precision]),
        .transformation_buffer_slot_free                            (transformation_buffer_slot_free                        [precision]),

        // AXI Write Master Interface
        .axi_write_master_req_valid                                 (transformation_core_axi_write_master_req_valid         [precision]),
        .axi_write_master_req_ready                                 (transformation_core_axi_write_master_req_ready         [precision]),
        .axi_write_master_req_start_address                         (transformation_core_axi_write_master_req_start_address [precision]),
        .axi_write_master_req_len                                   (transformation_core_axi_write_master_req_len           [precision]),

        .axi_write_master_pop                                       (transformation_core_axi_write_master_pop               [precision]),
        .axi_write_master_data_valid                                (transformation_core_axi_write_master_data_valid        [precision]),
        .axi_write_master_data                                      (transformation_core_axi_write_master_data              [precision]),
        
        .axi_write_master_data_unreversed                           (transformation_core_axi_write_master_data_unreversed   [precision]), //Temp

        .axi_write_master_resp_valid                                (transformation_core_axi_write_master_resp_valid        [precision]),
        .axi_write_master_resp_ready                                (transformation_core_axi_write_master_resp_ready        [precision]),

        // Layer configuration
        .layer_config_in_features_count                             (layer_config_in_features_count),
        .layer_config_out_features_count                            (layer_config_out_features_count),
        .layer_config_out_features_address_msb_value                (layer_config_out_features_address_msb_value),
        .layer_config_out_features_address_lsb_value                (layer_config_out_features_address_lsb_value),
        .layer_config_bias_value                                    (layer_config_bias_value),
        .layer_config_activation_function_value                     (layer_config_activation_function_value),
        .layer_config_leaky_relu_alpha_value                        (layer_config_leaky_relu_alpha_value),
        .ctrl_buffering_enable_value                                (ctrl_buffering_enable_value),
        .ctrl_writeback_enable_value                                (ctrl_writeback_enable_value)
    );
end

// AXI Write Master
// -------------------------------------------------------------------------------------

axi_write_master write_master_i (
    .core_clk                   (core_clk),
    .resetn                     (resetn),

    // Request interface
    .axi_write_master_req_valid         (axi_write_master_req_valid),
    .axi_write_master_req_ready         (axi_write_master_req_ready),
    .axi_write_master_req_start_address (axi_write_master_req_start_address),
    .axi_write_master_req_len           (axi_write_master_req_len),

    // Data interface
    .data_queue_pop                     (axi_write_master_pop),
    .data_queue_data_valid              (axi_write_master_data_valid),
    .data_queue_data                    (axi_write_master_data),

    // Response interface
    .axi_write_master_resp_valid        (axi_write_master_resp_valid),
    .axi_write_master_resp_ready        (axi_write_master_resp_ready),

    // AXI Write Master -> AXI Interconnect
    .axi_awaddr         (transformation_engine_axi_interconnect_axi_awaddr),
    .axi_awburst        (transformation_engine_axi_interconnect_axi_awburst),
    .axi_awcache        (transformation_engine_axi_interconnect_axi_awcache),
    .axi_awid           (transformation_engine_axi_interconnect_axi_awid),
    .axi_awlen          (transformation_engine_axi_interconnect_axi_awlen),
    .axi_awlock         (transformation_engine_axi_interconnect_axi_awlock),
    .axi_awprot         (transformation_engine_axi_interconnect_axi_awprot),
    .axi_awqos          (transformation_engine_axi_interconnect_axi_awqos),
    .axi_awready        (transformation_engine_axi_interconnect_axi_awready),
    .axi_awsize         (transformation_engine_axi_interconnect_axi_awsize),
    .axi_awvalid        (transformation_engine_axi_interconnect_axi_awvalid),

    .axi_wdata          (transformation_engine_axi_interconnect_axi_wdata),
    .axi_wlast          (transformation_engine_axi_interconnect_axi_wlast),
    .axi_wready         (transformation_engine_axi_interconnect_axi_wready),
    .axi_wstrb          (transformation_engine_axi_interconnect_axi_wstrb),
    .axi_wvalid         (transformation_engine_axi_interconnect_axi_wvalid),

    .axi_bid            (transformation_engine_axi_interconnect_axi_bid),
    .axi_bready         (transformation_engine_axi_interconnect_axi_bready),
    .axi_bresp          (transformation_engine_axi_interconnect_axi_bresp),
    .axi_bvalid         (transformation_engine_axi_interconnect_axi_bvalid),

    .axi_araddr         (transformation_engine_axi_interconnect_axi_araddr),
    .axi_arburst        (transformation_engine_axi_interconnect_axi_arburst),
    .axi_arcache        (transformation_engine_axi_interconnect_axi_arcache),
    .axi_arid           (transformation_engine_axi_interconnect_axi_arid),
    .axi_arlen          (transformation_engine_axi_interconnect_axi_arlen),
    .axi_arlock         (transformation_engine_axi_interconnect_axi_arlock),
    .axi_arprot         (transformation_engine_axi_interconnect_axi_arprot),
    .axi_arqos          (transformation_engine_axi_interconnect_axi_arqos),
    .axi_arsize         (transformation_engine_axi_interconnect_axi_arsize),
    .axi_arvalid        (transformation_engine_axi_interconnect_axi_arvalid),
    .axi_arready        (transformation_engine_axi_interconnect_axi_arready),

    .axi_rdata          (transformation_engine_axi_interconnect_axi_rdata),
    .axi_rid            (transformation_engine_axi_interconnect_axi_rid),
    .axi_rlast          (transformation_engine_axi_interconnect_axi_rlast),
    .axi_rready         (transformation_engine_axi_interconnect_axi_rready),
    .axi_rresp          (transformation_engine_axi_interconnect_axi_rresp),
    .axi_rvalid         (transformation_engine_axi_interconnect_axi_rvalid)
);

// NSB Response Arbitration
// -------------------------------------------------------------------------------------

rr_arbiter #(
    .NUM_REQUESTERS     (top_pkg::PRECISION_COUNT)
) nsb_response_arb (
    .clk                (core_clk),
    .resetn             (resetn),

    .request            (transformation_core_resp_valid),

    // update when starting to flush new row
    .update_lru         (|transformation_core_resp_valid),
    .grant_oh           (transformation_core_resp_ready),
    .grant_bin          (transformation_core_resp_valid_bin)
);

// AXI Write Master Request Arbitration
// -------------------------------------------------------------------------------------

rr_arbiter #(
    .NUM_REQUESTERS     (top_pkg::PRECISION_COUNT)
) prefetcher_req_arb (
    .clk                (core_clk),
    .resetn             (resetn),

    .request            (transformation_core_axi_write_master_req_valid),

    // update when starting to flush new row
    .update_lru         (axi_write_master_req_ready),
    .grant_oh           (),
    .grant_bin          (transformation_core_write_master_alloc_bin)
);

// ==================================================================================================================================================
// Logic
// ==================================================================================================================================================

// NSB Interface
// -------------------------------------------------------------------------------------

always_comb begin
    nsb_fte_req_ready           = nsb_fte_req.precision == top_pkg::FLOAT_32 ? transformation_core_req_ready [top_pkg::FLOAT_32]
                                : nsb_fte_req.precision == top_pkg::FIXED_8 ? transformation_core_req_ready [top_pkg::FIXED_8]
                                : '0;

    // Response
    nsb_fte_resp_valid          = |transformation_core_resp_valid;
    nsb_fte_resp = transformation_core_resp [transformation_core_resp_valid_bin];
end

// Transformation Core Allocation for AXI Write Master
// -------------------------------------------------------------------------------------

always_ff @(posedge core_clk) begin
    if (!resetn) begin
        transformation_core_write_master_alloc_bin_q <= '0;

    // AXI Write Master accepting request
    end else if (axi_write_master_req_ready && axi_write_master_req_valid) begin
        transformation_core_write_master_alloc_bin_q <= transformation_core_write_master_alloc_bin;
    end
end

always_comb begin
    axi_write_master_req_valid         = |transformation_core_axi_write_master_req_valid;
    axi_write_master_req_start_address = transformation_core_axi_write_master_req_start_address [transformation_core_write_master_alloc_bin];
    axi_write_master_req_len           = transformation_core_axi_write_master_req_len           [transformation_core_write_master_alloc_bin];

    axi_write_master_data_valid = transformation_core_axi_write_master_data_valid [transformation_core_write_master_alloc_bin_q];
    axi_write_master_data       = transformation_core_axi_write_master_data       [transformation_core_write_master_alloc_bin_q];
    axi_write_master_resp_ready = transformation_core_axi_write_master_resp_ready [transformation_core_write_master_alloc_bin_q];
end

for (genvar precision = top_pkg::FLOAT_32; precision < top_pkg::PRECISION_COUNT; precision++) begin

    always_comb begin
        transformation_core_axi_write_master_req_ready [precision] = axi_write_master_req_ready && (transformation_core_write_master_alloc_bin == precision);
        transformation_core_axi_write_master_pop       [precision] = axi_write_master_pop && (transformation_core_write_master_alloc_bin_q == precision);

        transformation_core_axi_write_master_resp_valid [precision] = axi_write_master_resp_valid && (transformation_core_write_master_alloc_bin_q == precision);
    end
end

endmodule