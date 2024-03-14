import top_pkg::*;
import noc_pkg::*;

module prefetcher #(
    parameter FETCH_TAG_COUNT = top_pkg::MESSAGE_CHANNEL_COUNT,
    parameter HBM_BANKS = 32
) (
    input logic                               core_clk,
    input logic                               resetn,

    input logic regbank_clk,
    input logic regbank_resetn,

    // NSB -> Prefetcher Interface
    input  logic                              nsb_prefetcher_req_valid,
    output logic                              nsb_prefetcher_req_ready,
    input  NSB_PREF_REQ_t                     nsb_prefetcher_req,

    output logic                              nsb_prefetcher_resp_valid, // valid only for now
    output NSB_PREF_RESP_t                    nsb_prefetcher_resp,

    // Register Bank
    input  logic [AXIL_ADDR_WIDTH-1:0]        s_axi_awaddr,
    input  logic [2:0]                        s_axi_awprot,
    input  logic                              s_axi_awvalid,
    output logic                              s_axi_awready,
    input  logic [31:0]                       s_axi_wdata,
    input  logic [3:0]                        s_axi_wstrb,
    input  logic                              s_axi_wvalid,
    output logic                              s_axi_wready,
    input  logic [AXIL_ADDR_WIDTH-1:0]        s_axi_araddr,
    input  logic [2:0]                        s_axi_arprot,
    input  logic                              s_axi_arvalid,
    output logic                              s_axi_arready,
    output logic [31:0]                       s_axi_rdata,
    output logic [1:0]                        s_axi_rresp,
    output logic                              s_axi_rvalid,
    input  logic                              s_axi_rready,
    output logic [1:0]                        s_axi_bresp,
    output logic                              s_axi_bvalid,
    input  logic                              s_axi_bready,

    // Prefetcher Read Master -> AXI Interface
    output logic [HBM_BANKS-1:0] [33:0]                       read_master_axi_araddr,
    output logic [HBM_BANKS-1:0] [1:0]                        read_master_axi_arburst,
    output logic [HBM_BANKS-1:0] [3:0]                        read_master_axi_arcache,
    output logic [HBM_BANKS-1:0] [3:0]                        read_master_axi_arid,
    output logic [HBM_BANKS-1:0] [7:0]                        read_master_axi_arlen,
    output logic [HBM_BANKS-1:0] [0:0]                        read_master_axi_arlock,
    output logic [HBM_BANKS-1:0] [2:0]                        read_master_axi_arprot,
    output logic [HBM_BANKS-1:0] [3:0]                        read_master_axi_arqos,
    output logic [HBM_BANKS-1:0] [2:0]                        read_master_axi_arsize,
    output logic [HBM_BANKS-1:0]                              read_master_axi_arvalid,
    input  logic [HBM_BANKS-1:0]                              read_master_axi_arready,
    output logic [HBM_BANKS-1:0] [33:0]                       read_master_axi_awaddr,
    output logic [HBM_BANKS-1:0] [1:0]                        read_master_axi_awburst,
    output logic [HBM_BANKS-1:0] [3:0]                        read_master_axi_awcache,
    output logic [HBM_BANKS-1:0] [3:0]                        read_master_axi_awid,
    output logic [HBM_BANKS-1:0] [7:0]                        read_master_axi_awlen,
    output logic [HBM_BANKS-1:0] [0:0]                        read_master_axi_awlock,
    output logic [HBM_BANKS-1:0] [2:0]                        read_master_axi_awprot,
    output logic [HBM_BANKS-1:0] [3:0]                        read_master_axi_awqos,
    input  logic [HBM_BANKS-1:0]                              read_master_axi_awready,
    output logic [HBM_BANKS-1:0] [2:0]                        read_master_axi_awsize,
    output logic [HBM_BANKS-1:0]                              read_master_axi_awvalid,
    input  logic [HBM_BANKS-1:0] [3:0]                        read_master_axi_bid,
    output logic [HBM_BANKS-1:0]                              read_master_axi_bready,
    input  logic [HBM_BANKS-1:0] [1:0]                        read_master_axi_bresp,
    input  logic [HBM_BANKS-1:0]                              read_master_axi_bvalid,
    input  logic [HBM_BANKS-1:0] [511:0]                      read_master_axi_rdata,
    input  logic [HBM_BANKS-1:0] [3:0]                        read_master_axi_rid,
    input  logic [HBM_BANKS-1:0]                              read_master_axi_rlast,
    output logic [HBM_BANKS-1:0]                              read_master_axi_rready,
    input  logic [HBM_BANKS-1:0] [1:0]                        read_master_axi_rresp,
    input  logic [HBM_BANKS-1:0]                              read_master_axi_rvalid,
    output logic [HBM_BANKS-1:0] [511:0]                      read_master_axi_wdata,
    output logic [HBM_BANKS-1:0]                              read_master_axi_wlast,
    input  logic [HBM_BANKS-1:0]                              read_master_axi_wready,
    output logic [HBM_BANKS-1:0] [63:0]                       read_master_axi_wstrb,
    output logic [HBM_BANKS-1:0]                              read_master_axi_wvalid,

    // Prefetcher Weight Bank Read Master -> AXI Memory Interconnect
    output logic [33:0]                       weight_bank_axi_araddr,
    output logic [1:0]                        weight_bank_axi_arburst,
    output logic [3:0]                        weight_bank_axi_arcache,
    output logic [3:0]                        weight_bank_axi_arid,
    output logic [7:0]                        weight_bank_axi_arlen,
    output logic [0:0]                        weight_bank_axi_arlock,
    output logic [2:0]                        weight_bank_axi_arprot,
    output logic [3:0]                        weight_bank_axi_arqos,
    output logic [2:0]                        weight_bank_axi_arsize,
    output logic                              weight_bank_axi_arvalid,
    input  logic                              weight_bank_axi_arready,
    output logic [33:0]                       weight_bank_axi_awaddr,
    output logic [1:0]                        weight_bank_axi_awburst,
    output logic [3:0]                        weight_bank_axi_awcache,
    output logic [3:0]                        weight_bank_axi_awid,
    output logic [7:0]                        weight_bank_axi_awlen,
    output logic [0:0]                        weight_bank_axi_awlock,
    output logic [2:0]                        weight_bank_axi_awprot,
    output logic [3:0]                        weight_bank_axi_awqos,
    input  logic                              weight_bank_axi_awready,
    output logic [2:0]                        weight_bank_axi_awsize,
    output logic                              weight_bank_axi_awvalid,
    input  logic [3:0]                        weight_bank_axi_bid,
    output logic                              weight_bank_axi_bready,
    input  logic [1:0]                        weight_bank_axi_bresp,
    input  logic                              weight_bank_axi_bvalid,
    input  logic [511:0]                      weight_bank_axi_rdata,
    input  logic [3:0]                        weight_bank_axi_rid,
    input  logic                              weight_bank_axi_rlast,
    output logic                              weight_bank_axi_rready,
    input  logic [1:0]                        weight_bank_axi_rresp,
    input  logic                              weight_bank_axi_rvalid,
    output logic [511:0]                      weight_bank_axi_wdata,
    output logic                              weight_bank_axi_wlast,
    input  logic                              weight_bank_axi_wready,
    output logic [63:0]                       weight_bank_axi_wstrb,
    output logic                              weight_bank_axi_wvalid,

    // Message Channels: AGE -> Prefetcher Feature Bank
    input  logic [MESSAGE_CHANNEL_COUNT-1:0]                  message_channel_req_valid,
    output logic [MESSAGE_CHANNEL_COUNT-1:0]                  message_channel_req_ready,
    input  MESSAGE_CHANNEL_REQ_t [MESSAGE_CHANNEL_COUNT-1:0]  message_channel_req,

    output logic [MESSAGE_CHANNEL_COUNT-1:0]                  message_channel_resp_valid,
    input  logic [MESSAGE_CHANNEL_COUNT-1:0]                  message_channel_resp_ready,
    output MESSAGE_CHANNEL_RESP_t [MESSAGE_CHANNEL_COUNT-1:0] message_channel_resp,

    // Weight Channels: FTE -> Prefetcher Weight Bank
    input  logic                [top_pkg::PRECISION_COUNT-1:0] weight_channel_req_valid,
    output logic                [top_pkg::PRECISION_COUNT-1:0] weight_channel_req_ready,
    input  WEIGHT_CHANNEL_REQ_t [top_pkg::PRECISION_COUNT-1:0] weight_channel_req,

    output logic                 [top_pkg::PRECISION_COUNT-1:0] weight_channel_resp_valid,
    input  logic                 [top_pkg::PRECISION_COUNT-1:0] weight_channel_resp_ready,
    output WEIGHT_CHANNEL_RESP_t [top_pkg::PRECISION_COUNT-1:0] weight_channel_resp,

    input  logic [MESSAGE_CHANNEL_COUNT-1:0]                                           scale_factor_queue_pop,
    output logic [MESSAGE_CHANNEL_COUNT-1:0] [SCALE_FACTOR_QUEUE_READ_WIDTH-1:0]       scale_factor_queue_out_data,
    output logic [MESSAGE_CHANNEL_COUNT-1:0]                                           scale_factor_queue_out_valid,
    output logic [MESSAGE_CHANNEL_COUNT-1:0] [$clog2(SCALE_FACTOR_QUEUE_READ_DEPTH):0] scale_factor_queue_count,
    output logic [MESSAGE_CHANNEL_COUNT-1:0]                                           scale_factor_queue_empty,
    output logic [MESSAGE_CHANNEL_COUNT-1:0]                                           scale_factor_queue_full
    
);

// ==================================================================================================================================================
// Declarations
// ==================================================================================================================================================

// Register Bank
// --------------------------------------------------------------------------------------------

logic layer_config_in_features_strobe;
logic [9:0] layer_config_in_features_count;

logic layer_config_out_features_strobe;
logic [9:0] layer_config_out_features_count;

logic layer_config_in_messages_address_lsb_strobe;
logic [31:0] layer_config_in_messages_address_lsb_value;

logic layer_config_in_messages_address_msb_strobe;
logic [1:0] layer_config_in_messages_address_msb_value;

logic layer_config_adjacency_list_address_lsb_strobe;
logic [31:0] layer_config_adjacency_list_address_lsb_value;

logic layer_config_adjacency_list_address_msb_strobe;
logic [1:0] layer_config_adjacency_list_address_msb_value;

logic [3:0] layer_config_weights_address_lsb_strobe;
logic [3:0] [31:0] layer_config_weights_address_lsb_value;

logic [3:0] layer_config_weights_address_msb_strobe;
logic [3:0] [1:0] layer_config_weights_address_msb_value;

logic layer_config_scale_factors_address_lsb_strobe;
logic [31:0] layer_config_scale_factors_address_lsb_value;

logic layer_config_scale_factors_address_msb_strobe;
logic [1:0] layer_config_scale_factors_address_msb_value;

// Feature Bank
// --------------------------------------------------------------------------------------------

logic                                              nsb_prefetcher_feature_bank_req_valid;
logic                                              nsb_prefetcher_feature_bank_req_ready;
logic                                              nsb_prefetcher_feature_bank_resp_valid;
NSB_PREF_RESP_t                                    nsb_prefetcher_feature_bank_resp;

// Adjacency Read Master
logic [HBM_BANKS-1:0]                                              read_master_req_valid;
logic [HBM_BANKS-1:0]                                              read_master_req_ready;
logic [HBM_BANKS-1:0] [AXI_ADDRESS_WIDTH-1:0]                      read_master_start_address;
logic [HBM_BANKS-1:0] [$clog2(MAX_FETCH_REQ_BYTE_COUNT)-1:0]       read_master_byte_count;
logic [HBM_BANKS-1:0]                                              read_master_resp_valid;
logic [HBM_BANKS-1:0]                                              read_master_resp_ready;
logic [HBM_BANKS-1:0]                                              read_master_resp_last;
logic [HBM_BANKS-1:0] [AXI_DATA_WIDTH-1:0]                         read_master_resp_data;
logic [HBM_BANKS-1:0] [3:0]                                        read_master_resp_axi_id;

// Weight Bank
// --------------------------------------------------------------------------------------------

logic           [top_pkg::PRECISION_COUNT-1:0]                                              nsb_prefetcher_weight_bank_req_valid;
logic           [top_pkg::PRECISION_COUNT-1:0]                                              nsb_prefetcher_weight_bank_req_ready;

logic           [top_pkg::PRECISION_COUNT-1:0]                                              nsb_prefetcher_weight_bank_resp_valid;
NSB_PREF_RESP_t [top_pkg::PRECISION_COUNT-1:0]                                              nsb_prefetcher_weight_bank_resp;

logic           [top_pkg::PRECISION_COUNT-1:0]                                              weight_bank_axi_rm_fetch_req_valid;
logic                                                                                       weight_read_master_fetch_req_ready;
logic           [top_pkg::PRECISION_COUNT-1:0]                                              weight_bank_axi_rm_fetch_req_ready;
logic           [top_pkg::PRECISION_COUNT-1:0] [AXI_ADDRESS_WIDTH-1:0]                      weight_bank_axi_rm_fetch_start_address;
logic           [top_pkg::PRECISION_COUNT-1:0] [$clog2(MAX_FETCH_REQ_BYTE_COUNT)-1:0]       weight_bank_axi_rm_fetch_byte_count;

logic                                                                                       weight_read_master_fetch_resp_valid;
logic           [top_pkg::PRECISION_COUNT-1:0]                                              weight_bank_axi_rm_fetch_resp_valid;
logic           [top_pkg::PRECISION_COUNT-1:0]                                              weight_bank_axi_rm_fetch_resp_ready;
logic                                                                                       weight_read_master_resp_last;
logic           [AXI_DATA_WIDTH-1:0]                                                        weight_read_master_resp_data;
logic           [3:0]                                                                       weight_read_master_resp_axi_id;

top_pkg::NODE_PRECISION_e active_weight_fetch_precision;

// ==================================================================================================================================================
// Instances
// ==================================================================================================================================================

prefetcher_regbank_wrapper prefetcher_regbank_i (
    // Clock and Reset
    .axi_aclk                       (regbank_clk),
    .axi_aresetn                    (regbank_resetn),
    .fast_clk                       (core_clk),
    .fast_resetn                    (resetn),

    // AXI Write Address Channel
    .s_axi_awaddr                   (s_axi_awaddr),
    .s_axi_awprot                   (s_axi_awprot),
    .s_axi_awvalid                  (s_axi_awvalid),
    .s_axi_awready                  (s_axi_awready),
    .s_axi_wdata                    (s_axi_wdata),
    .s_axi_wstrb                    (s_axi_wstrb),
    .s_axi_wvalid                   (s_axi_wvalid),
    .s_axi_wready                   (s_axi_wready),
    .s_axi_araddr                   (s_axi_araddr),
    .s_axi_arprot                   (s_axi_arprot),
    .s_axi_arvalid                  (s_axi_arvalid),
    .s_axi_arready                  (s_axi_arready),
    .s_axi_rdata                    (s_axi_rdata),
    .s_axi_rresp                    (s_axi_rresp),
    .s_axi_rvalid                   (s_axi_rvalid),
    .s_axi_rready                   (s_axi_rready),
    .s_axi_bresp                    (s_axi_bresp),
    .s_axi_bvalid                   (s_axi_bvalid),
    .s_axi_bready                   (s_axi_bready),

    // User Ports
    .layer_config_in_features_count,
    .layer_config_out_features_count,
    .layer_config_adjacency_list_address_lsb_value,
    .layer_config_adjacency_list_address_msb_value,
    .layer_config_weights_address_lsb_value,
    .layer_config_weights_address_msb_value,
    .layer_config_in_messages_address_lsb_value,
    .layer_config_in_messages_address_msb_value,
    .layer_config_scale_factors_address_lsb_value,
    .layer_config_scale_factors_address_msb_value
);

// Feature Bank
// --------------------------------------------------------------------------------------------

prefetcher_feature_bank #(
    .FETCH_TAG_COUNT(FETCH_TAG_COUNT)
) feature_bank_i (
    .core_clk,
    .resetn,

    .nsb_prefetcher_feature_bank_req_valid                              (nsb_prefetcher_feature_bank_req_valid),
    .nsb_prefetcher_feature_bank_req_ready                              (nsb_prefetcher_feature_bank_req_ready),
    .nsb_prefetcher_feature_bank_req                                    (nsb_prefetcher_req),

    .nsb_prefetcher_feature_bank_resp_valid                             (nsb_prefetcher_feature_bank_resp_valid),
    .nsb_prefetcher_feature_bank_resp                                   (nsb_prefetcher_feature_bank_resp),

    // Read Masters
    .read_master_fetch_req_valid                                             (read_master_req_valid),
    .read_master_fetch_req_ready                                             (read_master_req_ready),
    .read_master_fetch_start_address                                         (read_master_start_address),
    .read_master_fetch_byte_count                                            (read_master_byte_count),

    .read_master_fetch_resp_valid                                            (read_master_resp_valid),
    .read_master_fetch_resp_ready                                            (read_master_resp_ready),
    .read_master_fetch_resp_last                                             (read_master_resp_last),
    .read_master_fetch_resp_data                                             (read_master_resp_data),
    .read_master_fetch_resp_axi_id                                           (read_master_resp_axi_id),

    // Message Channels
    .message_channel_req_valid                                          (message_channel_req_valid),
    .message_channel_req_ready                                          (message_channel_req_ready),
    .message_channel_req                                                (message_channel_req),

    .message_channel_resp_valid                                         (message_channel_resp_valid),
    .message_channel_resp_ready                                         (message_channel_resp_ready),
    .message_channel_resp                                               (message_channel_resp),

    .scale_factor_queue_pop                                             (scale_factor_queue_pop),
    .scale_factor_queue_out_data                                        (scale_factor_queue_out_data),
    .scale_factor_queue_out_valid                                       (scale_factor_queue_out_valid),
    .scale_factor_queue_count                                           (scale_factor_queue_count),
    .scale_factor_queue_empty                                           (scale_factor_queue_empty),
    .scale_factor_queue_full                                            (scale_factor_queue_full),

    .layer_config_in_features_count                                     (layer_config_in_features_count),
    .layer_config_adjacency_list_address_lsb_value                      (layer_config_adjacency_list_address_lsb_value),
    .layer_config_in_messages_address_lsb_value                         (layer_config_in_messages_address_lsb_value),
    .layer_config_scale_factors_address_lsb_value,
    .layer_config_scale_factors_address_msb_value
    
);

// Weight Bank
// --------------------------------------------------------------------------------------------

for (genvar precision = top_pkg::FLOAT_32; precision < top_pkg::PRECISION_COUNT; precision++) begin
    prefetcher_weight_bank #(
        .PRECISION         (precision),
        .AXI_ADDRESS_WIDTH (34),
        .AXI_DATA_WIDTH    (512),
        .MAX_FEATURE_COUNT (top_pkg::MAX_FEATURE_COUNT)
        ) weight_bank_i (
            .core_clk,
            .resetn,
            
            .nsb_prefetcher_weight_bank_req_valid   (nsb_prefetcher_weight_bank_req_valid [precision]),
            .nsb_prefetcher_weight_bank_req_ready   (nsb_prefetcher_weight_bank_req_ready [precision]),
            .nsb_prefetcher_weight_bank_req         (nsb_prefetcher_req),
            
            .nsb_prefetcher_weight_bank_resp_valid  (nsb_prefetcher_weight_bank_resp_valid [precision]),
            .nsb_prefetcher_weight_bank_resp        (nsb_prefetcher_weight_bank_resp       [precision]),
            
            .weight_bank_axi_rm_fetch_req_valid     (weight_bank_axi_rm_fetch_req_valid     [precision]),
            .weight_bank_axi_rm_fetch_req_ready     (weight_bank_axi_rm_fetch_req_ready     [precision]),
            .weight_bank_axi_rm_fetch_start_address (weight_bank_axi_rm_fetch_start_address [precision]),
            .weight_bank_axi_rm_fetch_byte_count    (weight_bank_axi_rm_fetch_byte_count    [precision]),
            
            .weight_bank_axi_rm_fetch_resp_valid    (weight_bank_axi_rm_fetch_resp_valid  [precision]),
            .weight_bank_axi_rm_fetch_resp_ready    (weight_bank_axi_rm_fetch_resp_ready  [precision]),
            .weight_bank_axi_rm_fetch_resp_last     (weight_read_master_resp_last  ),
            .weight_bank_axi_rm_fetch_resp_data     (weight_read_master_resp_data  ),
            .weight_bank_axi_rm_fetch_resp_axi_id   (weight_read_master_resp_axi_id),
            
            .weight_channel_req_valid               (weight_channel_req_valid [precision]),
            .weight_channel_req_ready               (weight_channel_req_ready [precision]),
            .weight_channel_req                     (weight_channel_req       [precision]),
            
            .weight_channel_resp_valid              (weight_channel_resp_valid [precision]),
            .weight_channel_resp_ready              (weight_channel_resp_ready [precision]),
            .weight_channel_resp                    (weight_channel_resp       [precision]),
            
            .layer_config_weights_address_lsb_value (layer_config_weights_address_lsb_value [precision])
            );
            
end

// Read Masters
// ----------------------------------------------------------------------------------

for (genvar bank = 0; bank < HBM_BANKS; bank++) begin : read_master_block
    axi_read_master #(
        .MAX_BYTE_COUNT (MAX_FETCH_REQ_BYTE_COUNT),
        .DATA_WIDTH     (AXI_DATA_WIDTH)
    ) read_master_i (
        .core_clk    (core_clk),
        .resetn      (resetn),
        
        .fetch_req_valid            (read_master_req_valid     [bank]),
        .fetch_req_ready            (read_master_req_ready     [bank]),
        .fetch_start_address        (read_master_start_address [bank]),
        .fetch_byte_count           (read_master_byte_count    [bank]),
        
        .fetch_resp_valid           (read_master_resp_valid    [bank]),
        .fetch_resp_ready           (read_master_resp_ready    [bank]),
        .fetch_resp_last            (read_master_resp_last     [bank]),
        .fetch_resp_data            (read_master_resp_data     [bank]),
        .fetch_resp_axi_id          (read_master_resp_axi_id   [bank]),
    
        // AXI Read-Only Interface
       .axi_araddr                  (read_master_axi_araddr    [bank]),
       .axi_arburst                 (read_master_axi_arburst   [bank]),
       .axi_arcache                 (read_master_axi_arcache   [bank]),
       .axi_arid                    (read_master_axi_arid      [bank]),
       .axi_arlen                   (read_master_axi_arlen     [bank]),
       .axi_arlock                  (read_master_axi_arlock    [bank]),
       .axi_arprot                  (read_master_axi_arprot    [bank]),
       .axi_arqos                   (read_master_axi_arqos     [bank]),
       .axi_arsize                  (read_master_axi_arsize    [bank]),
       .axi_arvalid                 (read_master_axi_arvalid   [bank]),
       .axi_arready                 (read_master_axi_arready   [bank]),
       .axi_rdata                   (read_master_axi_rdata     [bank]),
       .axi_rid                     (read_master_axi_rid       [bank]),
       .axi_rlast                   (read_master_axi_rlast     [bank]),
       .axi_rvalid                  (read_master_axi_rvalid    [bank]),
       .axi_rready                  (read_master_axi_rready    [bank]),
       .axi_rresp                   (read_master_axi_rresp     [bank])
    );
end : read_master_block

// Weight Bank AXI Read Master
// --------------------------------------------------------------------------------------------

axi_read_master #(
    .MAX_BYTE_COUNT    (MAX_FETCH_REQ_BYTE_COUNT)
) weight_read_master_i (
    .core_clk,
    .resetn,

    // Request interface
    .fetch_req_valid      (weight_bank_axi_rm_fetch_req_valid     [active_weight_fetch_precision]),
    .fetch_req_ready      (weight_read_master_fetch_req_ready),
    .fetch_start_address  (weight_bank_axi_rm_fetch_start_address [active_weight_fetch_precision]),
    .fetch_byte_count     (weight_bank_axi_rm_fetch_byte_count    [active_weight_fetch_precision]),

    .fetch_resp_valid     (weight_read_master_fetch_resp_valid),
    .fetch_resp_ready     (weight_bank_axi_rm_fetch_resp_ready [active_weight_fetch_precision]),
    .fetch_resp_data      (weight_read_master_resp_data),
    .fetch_resp_last      (weight_read_master_resp_last),
    .fetch_resp_axi_id    (weight_read_master_resp_axi_id),

    // AXI Read-Only Interface
    .axi_araddr  (weight_bank_axi_araddr),
    .axi_arburst (weight_bank_axi_arburst),
    .axi_arcache (weight_bank_axi_arcache),
    .axi_arid    (weight_bank_axi_arid),
    .axi_arlen   (weight_bank_axi_arlen),
    .axi_arlock  (weight_bank_axi_arlock),
    .axi_arprot  (weight_bank_axi_arprot),
    .axi_arqos   (weight_bank_axi_arqos),
    .axi_arsize  (weight_bank_axi_arsize),
    .axi_arvalid (weight_bank_axi_arvalid),
    .axi_arready (weight_bank_axi_arready),
    .axi_rdata   (weight_bank_axi_rdata),
    .axi_rid     (weight_bank_axi_rid),
    .axi_rlast   (weight_bank_axi_rlast),
    .axi_rvalid  (weight_bank_axi_rvalid),
    .axi_rready  (weight_bank_axi_rready),
    .axi_rresp   (weight_bank_axi_rresp)
);

// ==================================================================================================================================================
// Logic
// ==================================================================================================================================================

// NSB request/responses
// --------------------------------------------------------------------------------------------

// TO DO: when edge bank implemented, buffer responses from weight/feature/edge banks and send them to NSB in order

always_comb begin 
    nsb_prefetcher_feature_bank_req_valid = nsb_prefetcher_req_valid && ((nsb_prefetcher_req.req_opcode == ADJACENCY_LIST) || (nsb_prefetcher_req.req_opcode == MESSAGES) || (nsb_prefetcher_req.req_opcode == SCALE_FACTOR));

    nsb_prefetcher_req_ready              = (nsb_prefetcher_req.req_opcode == top_pkg::WEIGHTS) ? |(nsb_prefetcher_weight_bank_req_valid & nsb_prefetcher_weight_bank_req_ready)
                                            : nsb_prefetcher_feature_bank_req_ready;
    
    // Weight bank response should never happen at the same time as feature bank, so simple MUX is enough
    nsb_prefetcher_resp_valid             = nsb_prefetcher_feature_bank_resp_valid || |nsb_prefetcher_weight_bank_resp_valid;

    nsb_prefetcher_resp                   = |nsb_prefetcher_weight_bank_resp_valid ? nsb_prefetcher_weight_bank_resp [active_weight_fetch_precision]
                                            : nsb_prefetcher_feature_bank_resp;
end

// Multi-precision support
// --------------------------------------------------------------------------------------------

always_ff @(posedge core_clk or negedge resetn) begin
    if (!resetn) begin
        active_weight_fetch_precision <= top_pkg::FLOAT_32;

    // Accepting weight fetch request from NSB
    end else begin
        if (nsb_prefetcher_req_valid && nsb_prefetcher_req_ready && nsb_prefetcher_req.req_opcode == WEIGHTS) begin
            active_weight_fetch_precision <= nsb_prefetcher_req.nodeslot_precision;
        end
    end
end

// Drive weight bank request
for (genvar precision = top_pkg::FLOAT_32; precision < top_pkg::PRECISION_COUNT; precision++) begin
    assign nsb_prefetcher_weight_bank_req_valid [precision]  = nsb_prefetcher_req_valid && (nsb_prefetcher_req.req_opcode == WEIGHTS) && (precision == nsb_prefetcher_req.nodeslot_precision);

    assign weight_bank_axi_rm_fetch_req_ready [precision] = weight_read_master_fetch_req_ready && (precision == active_weight_fetch_precision);

    assign weight_bank_axi_rm_fetch_resp_valid [precision] = weight_read_master_fetch_resp_valid && (precision == active_weight_fetch_precision);
end

// Read-only interfaces
// --------------------------------------------------------------------------------------------

always_comb begin 
    // Adjacency read master
    read_master_axi_awaddr  = '0;
    read_master_axi_awburst = '0;
    read_master_axi_awcache = '0;
    read_master_axi_awid    = '0;
    read_master_axi_awlen   = '0;
    read_master_axi_awlock  = '0;
    read_master_axi_awprot  = '0;
    read_master_axi_awqos   = '0;
    read_master_axi_awsize  = '0;
    read_master_axi_awvalid = '0;
    read_master_axi_bready  = '0;
    read_master_axi_wdata   = '0;
    read_master_axi_wlast   = '0;
    read_master_axi_wstrb   = '0;
    read_master_axi_wvalid  = '0;

    // Weight Bank
    weight_bank_axi_awaddr   = '0;
    weight_bank_axi_awburst  = '0;
    weight_bank_axi_awcache  = '0;
    weight_bank_axi_awid     = '0;
    weight_bank_axi_awlen    = '0;
    weight_bank_axi_awlock   = '0;
    weight_bank_axi_awprot   = '0;
    weight_bank_axi_awqos    = '0;
    weight_bank_axi_awsize   = '0;
    weight_bank_axi_awvalid  = '0;
    weight_bank_axi_bready   = '0;
    weight_bank_axi_wdata    = '0;
    weight_bank_axi_wlast    = '0;
    weight_bank_axi_wstrb    = '0;
    weight_bank_axi_wvalid   = '0;
end

// ==================================================================================================================================================
// Assertions
// ==================================================================================================================================================

endmodule