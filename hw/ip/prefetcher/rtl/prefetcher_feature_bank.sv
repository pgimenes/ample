import top_pkg::*;
import noc_pkg::*;

module prefetcher_feature_bank #(
    parameter AXI_ADDRESS_WIDTH = 34,
    parameter AXI_DATA_WIDTH    = 512,
    parameter FETCH_TAG_COUNT   = top_pkg::MESSAGE_CHANNEL_COUNT
) (
    input logic core_clk,
    input logic resetn,

    // NSB -> Prefetcher Interface
    input  logic                                              nsb_prefetcher_feature_bank_req_valid,
    output logic                                              nsb_prefetcher_feature_bank_req_ready,
    input  NSB_PREF_REQ_t                                     nsb_prefetcher_feature_bank_req,

    output logic                                              nsb_prefetcher_feature_bank_resp_valid,
    output NSB_PREF_RESP_t                                    nsb_prefetcher_feature_bank_resp,

    // Adjacency Read Master
    output logic                                              adj_rm_fetch_req_valid,
    input  logic                                              adj_rm_fetch_req_ready,
    output logic [AXI_ADDRESS_WIDTH-1:0]                      adj_rm_fetch_start_address,
    output logic [$clog2(MAX_FETCH_REQ_BYTE_COUNT)-1:0]       adj_rm_fetch_byte_count,

    input  logic                                              adj_rm_fetch_resp_valid,
    output logic                                              adj_rm_fetch_resp_ready,
    input  logic                                              adj_rm_fetch_resp_last,
    input  logic [AXI_DATA_WIDTH-1:0]                         adj_rm_fetch_resp_data,
    input  logic [3:0]                                        adj_rm_fetch_resp_axi_id,

    // Message Read Master    
    output logic                                              msg_rm_fetch_req_valid,
    input  logic                                              msg_rm_fetch_req_ready,
    output logic [AXI_ADDRESS_WIDTH-1:0]                      msg_rm_fetch_start_address,
    output logic [$clog2(MAX_FETCH_REQ_BYTE_COUNT)-1:0]       msg_rm_fetch_byte_count,

    input  logic                                              msg_rm_fetch_resp_valid,
    output logic                                              msg_rm_fetch_resp_ready,
    input  logic                                              msg_rm_fetch_resp_last,
    input  logic [AXI_DATA_WIDTH-1:0]                         msg_rm_fetch_resp_data,
    input  logic [3:0]                                        msg_rm_fetch_resp_axi_id,

    // Message Channels: AGE -> Prefetcher Feature Bank
    input  logic [MESSAGE_CHANNEL_COUNT-1:0]                  message_channel_req_valid,
    output logic [MESSAGE_CHANNEL_COUNT-1:0]                  message_channel_req_ready,
    input  MESSAGE_CHANNEL_REQ_t [MESSAGE_CHANNEL_COUNT-1:0]  message_channel_req,

    output logic [MESSAGE_CHANNEL_COUNT-1:0]                  message_channel_resp_valid,
    input  logic [MESSAGE_CHANNEL_COUNT-1:0]                  message_channel_resp_ready,
    output MESSAGE_CHANNEL_RESP_t [MESSAGE_CHANNEL_COUNT-1:0] message_channel_resp,

    // Fetch tag -> AGM interface for scale factor queue
    input  logic [FETCH_TAG_COUNT-1:0]                                           scale_factor_queue_pop,
    output logic [FETCH_TAG_COUNT-1:0]                                           scale_factor_queue_out_valid,
    output logic [FETCH_TAG_COUNT-1:0] [SCALE_FACTOR_QUEUE_READ_WIDTH-1:0]       scale_factor_queue_out_data,
    output logic [FETCH_TAG_COUNT-1:0] [$clog2(SCALE_FACTOR_QUEUE_READ_DEPTH):0] scale_factor_queue_count,
    output logic [FETCH_TAG_COUNT-1:0]                                           scale_factor_queue_empty,
    output logic [FETCH_TAG_COUNT-1:0]                                           scale_factor_queue_full,

    input  logic [9:0] layer_config_in_features_count,
    input  logic [31:0] layer_config_adjacency_list_address_lsb_value,
    input  logic [31:0] layer_config_in_messages_address_lsb_value,
    input  logic [31:0] layer_config_scale_factors_address_lsb_value,
    input  logic [1:0] layer_config_scale_factors_address_msb_value
    
);


// ==================================================================================================================================================
// Declarations
// ==================================================================================================================================================

// Per fetch tag logic
// --------------------------------------------------------------------------

// Fetch tag allocation
logic [FETCH_TAG_COUNT-1:0]                                        allocation_valid;
logic [FETCH_TAG_COUNT-1:0] [$clog2(MAX_NODESLOT_COUNT)-1:0]       allocation_nodeslot;
logic [FETCH_TAG_COUNT-1:0] [$clog2(MAX_FEATURE_COUNT)-1:0]        allocation_feature_count;
logic [FETCH_TAG_COUNT-1:0]                                        deallocation_valid;
logic [FETCH_TAG_COUNT-1:0]                                        tag_free;

logic [FETCH_TAG_COUNT-1:0]                                        fetch_tag_adj_rm_req_valid;
logic [FETCH_TAG_COUNT-1:0]                                        fetch_tag_adj_rm_req_ready;
logic [FETCH_TAG_COUNT-1:0] [AXI_ADDRESS_WIDTH-1:0]                fetch_tag_adj_rm_start_address;
logic [FETCH_TAG_COUNT-1:0] [$clog2(MAX_FETCH_REQ_BYTE_COUNT)-1:0] fetch_tag_adj_rm_byte_count;

logic [FETCH_TAG_COUNT-1:0]                                        fetch_tag_adj_rm_resp_valid;
logic [FETCH_TAG_COUNT-1:0]                                        fetch_tag_adj_rm_resp_ready;
logic [FETCH_TAG_COUNT-1:0]                                        fetch_tag_adj_rm_resp_last;
logic [FETCH_TAG_COUNT-1:0] [AXI_DATA_WIDTH-1:0]                   fetch_tag_adj_rm_resp_data;
logic [FETCH_TAG_COUNT-1:0] [3:0]                                  fetch_tag_adj_rm_resp_axi_id;

logic [FETCH_TAG_COUNT-1:0]                                        fetch_tag_msg_rm_req_valid;
logic [FETCH_TAG_COUNT-1:0]                                        fetch_tag_msg_rm_req_ready;
logic [FETCH_TAG_COUNT-1:0] [AXI_ADDRESS_WIDTH-1:0]                fetch_tag_msg_rm_start_address;
logic [FETCH_TAG_COUNT-1:0] [$clog2(MAX_FETCH_REQ_BYTE_COUNT)-1:0] fetch_tag_msg_rm_byte_count;

logic [FETCH_TAG_COUNT-1:0]                                        fetch_tag_msg_rm_resp_valid;
logic [FETCH_TAG_COUNT-1:0]                                        fetch_tag_msg_rm_resp_ready;
logic [FETCH_TAG_COUNT-1:0]                                        fetch_tag_msg_rm_resp_last;
logic [FETCH_TAG_COUNT-1:0] [AXI_DATA_WIDTH-1:0]                   fetch_tag_msg_rm_resp_data;
logic [FETCH_TAG_COUNT-1:0] [3:0]                                  fetch_tag_msg_rm_resp_axi_id;

logic [FETCH_TAG_COUNT-1:0]                                        nsb_prefetcher_fetch_tag_req_valid;
logic [FETCH_TAG_COUNT-1:0]                                        nsb_prefetcher_fetch_tag_req_ready;
NSB_PREF_REQ_t [FETCH_TAG_COUNT-1:0]                               nsb_prefetcher_fetch_tag_req;
logic [FETCH_TAG_COUNT-1:0]                                        nsb_prefetcher_fetch_tag_resp_valid;
NSB_PREF_RESP_t [FETCH_TAG_COUNT-1:0]                              nsb_prefetcher_fetch_tag_resp;

// Fetch tag response arbitration
logic [FETCH_TAG_COUNT-1:0]                                        fetch_tag_resp_arb;
logic [$clog2(FETCH_TAG_COUNT)-1:0]                                fetch_tag_resp_arb_bin;

// Adjacency Read Master request arbitration
logic [FETCH_TAG_COUNT-1:0]         chosen_fetch_tag_adj_rm_req;
logic [$clog2(FETCH_TAG_COUNT)-1:0] chosen_fetch_tag_adj_rm_req_bin;
logic [$clog2(FETCH_TAG_COUNT)-1:0] chosen_fetch_tag_adj_rm_req_bin_q;

// Message Read Master request arbitration
logic [FETCH_TAG_COUNT-1:0]         chosen_fetch_tag_msg_rm_req;
logic [$clog2(FETCH_TAG_COUNT)-1:0] chosen_fetch_tag_msg_rm_req_bin;
logic [$clog2(FETCH_TAG_COUNT)-1:0] chosen_fetch_tag_msg_rm_req_bin_q;

// ==================================================================================================================================================
// Instances
// ==================================================================================================================================================

// Fetch Tags
// ----------------------------------------------------------------------------------

for (genvar fetch_tag = 0; fetch_tag < FETCH_TAG_COUNT; fetch_tag = fetch_tag + 1) begin
    prefetcher_fetch_tag #(
        .TAG                  (fetch_tag),
        .ADJ_QUEUE_WIDTH      (prefetcher_pkg::ADJACENCY_QUEUE_WIDTH),
        .ADJ_QUEUE_DEPTH      (prefetcher_pkg::ADJACENCY_QUEUE_DEPTH),
        .MESSAGE_QUEUE_WIDTH  (prefetcher_pkg::MESSAGE_QUEUE_WIDTH),
        .MESSAGE_QUEUE_DEPTH  (prefetcher_pkg::MESSAGE_QUEUE_DEPTH)
    ) fetch_tag_i (
        .core_clk,
        .resetn,

        // Allocation interface
        .allocation_valid                               (allocation_valid                    [fetch_tag]),
        .allocation_nodeslot                            (allocation_nodeslot                 [fetch_tag]),
        .allocation_feature_count                       (allocation_feature_count            [fetch_tag]),
        .deallocation_valid                             (deallocation_valid                  [fetch_tag]),
        .tag_free                                       (tag_free                            [fetch_tag]),

        // NSB -> Prefetcher Interface
        .nsb_prefetcher_req_valid                       (nsb_prefetcher_fetch_tag_req_valid  [fetch_tag]),
        .nsb_prefetcher_req_ready                       (nsb_prefetcher_fetch_tag_req_ready  [fetch_tag]),
        .nsb_prefetcher_req                             (nsb_prefetcher_fetch_tag_req        [fetch_tag]),

        .nsb_prefetcher_resp_valid                      (nsb_prefetcher_fetch_tag_resp_valid [fetch_tag]),
        .nsb_prefetcher_resp_ready                      (fetch_tag_resp_arb                  [fetch_tag]),
        .nsb_prefetcher_resp                            (nsb_prefetcher_fetch_tag_resp       [fetch_tag]),

        // Request interface to Adjacency AXI Master
        .fetch_tag_adj_rm_req_valid                     (fetch_tag_adj_rm_req_valid     [fetch_tag]),
        .fetch_tag_adj_rm_req_ready                     (fetch_tag_adj_rm_req_ready     [fetch_tag]),
        .fetch_tag_adj_rm_start_address                 (fetch_tag_adj_rm_start_address [fetch_tag]),
        .fetch_tag_adj_rm_byte_count                    (fetch_tag_adj_rm_byte_count    [fetch_tag]),

        // Response interface from Adjacency AXI Master
        .fetch_tag_adj_rm_resp_valid                    (fetch_tag_adj_rm_resp_valid    [fetch_tag]),
        .fetch_tag_adj_rm_resp_ready                    (fetch_tag_adj_rm_resp_ready    [fetch_tag]),
        .fetch_tag_adj_rm_resp_last                     (fetch_tag_adj_rm_resp_last     [fetch_tag]),
        .fetch_tag_adj_rm_resp_data                     (fetch_tag_adj_rm_resp_data     [fetch_tag]),
        .fetch_tag_adj_rm_resp_axi_id                   (fetch_tag_adj_rm_resp_axi_id   [fetch_tag]),

        // Request interface to Message AXI Master
        .fetch_tag_msg_rm_req_valid                     (fetch_tag_msg_rm_req_valid     [fetch_tag]),
        .fetch_tag_msg_rm_req_ready                     (fetch_tag_msg_rm_req_ready     [fetch_tag]),
        .fetch_tag_msg_rm_start_address                 (fetch_tag_msg_rm_start_address [fetch_tag]),
        .fetch_tag_msg_rm_byte_count                    (fetch_tag_msg_rm_byte_count    [fetch_tag]),

        // Response interface from Message AXI Master
        .fetch_tag_msg_rm_resp_valid                    (fetch_tag_msg_rm_resp_valid    [fetch_tag]),
        .fetch_tag_msg_rm_resp_ready                    (fetch_tag_msg_rm_resp_ready    [fetch_tag]),
        .fetch_tag_msg_rm_resp_last                     (fetch_tag_msg_rm_resp_last     [fetch_tag]),
        .fetch_tag_msg_rm_resp_data                     (fetch_tag_msg_rm_resp_data     [fetch_tag]),
        .fetch_tag_msg_rm_resp_axi_id                   (fetch_tag_msg_rm_resp_axi_id   [fetch_tag]),

        .message_channel_req_valid                      (message_channel_req_valid    [fetch_tag]),
        .message_channel_req_ready                      (message_channel_req_ready    [fetch_tag]),
        .message_channel_req                            (message_channel_req          [fetch_tag]),

        .message_channel_resp_valid                     (message_channel_resp_valid   [fetch_tag]),
        .message_channel_resp_ready                     (message_channel_resp_ready   [fetch_tag]),
        .message_channel_resp                           (message_channel_resp         [fetch_tag]),

        .scale_factor_queue_pop                         (scale_factor_queue_pop       [fetch_tag]),   
        .scale_factor_queue_out_valid                   (scale_factor_queue_out_valid [fetch_tag]),
        .scale_factor_queue_out_data                    (scale_factor_queue_out_data  [fetch_tag]),  
        .scale_factor_queue_count                       (scale_factor_queue_count     [fetch_tag]), 
        .scale_factor_queue_empty                       (scale_factor_queue_empty     [fetch_tag]), 
        .scale_factor_queue_full                        (scale_factor_queue_full      [fetch_tag]),  

        .layer_config_adjacency_list_address_lsb_value  (layer_config_adjacency_list_address_lsb_value),
        .layer_config_in_messages_address_lsb_value     (layer_config_in_messages_address_lsb_value),
        .layer_config_scale_factors_address_lsb_value,
        .layer_config_scale_factors_address_msb_value
    );

    // Fetch tag allocation/de-allocation
    // --------------------------------------------------------------------------------------------------

    // TO DO: parameterize feature count (read from prefetcher regbank), currently hard coded to support MS2
    always_comb begin
        allocation_valid            [fetch_tag] = (nsb_prefetcher_feature_bank_req_valid && (nsb_prefetcher_feature_bank_req.req_opcode == top_pkg::ADJACENCY_LIST) && (nsb_prefetcher_feature_bank_req.nodeslot == fetch_tag));
        allocation_nodeslot         [fetch_tag] = nsb_prefetcher_feature_bank_req.nodeslot;
        allocation_feature_count    [fetch_tag] = layer_config_in_features_count;
    end

    always_ff @(posedge core_clk or negedge resetn) begin
        if (!resetn) begin
            deallocation_valid[fetch_tag] <= '0;
        end else begin
            // If last beat sent to AGE, deallocate fetch tag
            deallocation_valid[fetch_tag] <= message_channel_resp_valid[fetch_tag] && message_channel_resp_ready[fetch_tag] && message_channel_resp[fetch_tag].last_feature ? '1
                                : '0;
        end
    end

    // Distribute NSB requests to correct fetch tag
    // --------------------------------------------------------------------------------------------------

    always_comb begin
        nsb_prefetcher_fetch_tag_req_valid  [fetch_tag]  = nsb_prefetcher_feature_bank_req_valid && (nsb_prefetcher_feature_bank_req.nodeslot == fetch_tag);
        nsb_prefetcher_fetch_tag_req        [fetch_tag]  = nsb_prefetcher_feature_bank_req;
    end

    // Accept read master requests for chosen fetch tags
    assign fetch_tag_adj_rm_req_ready [fetch_tag] = chosen_fetch_tag_adj_rm_req [fetch_tag] && adj_rm_fetch_req_ready;
    assign fetch_tag_msg_rm_req_ready [fetch_tag] = chosen_fetch_tag_msg_rm_req [fetch_tag] && msg_rm_fetch_req_ready;

    // Drive read master responses to appropriate fetch tag
    always_comb begin 
        fetch_tag_adj_rm_resp_valid  [fetch_tag] = adj_rm_fetch_resp_valid && (chosen_fetch_tag_adj_rm_req_bin_q == fetch_tag);
        fetch_tag_adj_rm_resp_last   [fetch_tag] = adj_rm_fetch_resp_last;
        fetch_tag_adj_rm_resp_data   [fetch_tag] = adj_rm_fetch_resp_data;
        fetch_tag_adj_rm_resp_axi_id [fetch_tag] = adj_rm_fetch_resp_axi_id;

        fetch_tag_msg_rm_resp_valid  [fetch_tag] = msg_rm_fetch_resp_valid && (chosen_fetch_tag_msg_rm_req_bin_q == fetch_tag);
        fetch_tag_msg_rm_resp_last   [fetch_tag] = msg_rm_fetch_resp_last;
        fetch_tag_msg_rm_resp_data   [fetch_tag] = msg_rm_fetch_resp_data;
        fetch_tag_msg_rm_resp_axi_id [fetch_tag] = msg_rm_fetch_resp_axi_id;
    end

end

// Fetch Tag response arbitration
// --------------------------------------------------------------------------------------------------

rr_arbiter #(
    .NUM_REQUESTERS (FETCH_TAG_COUNT)
) fetch_tag_resp_arb_i (
    .clk        (core_clk),
    .resetn     (resetn),

    .request    (nsb_prefetcher_fetch_tag_resp_valid),
    .update_lru (|nsb_prefetcher_fetch_tag_resp_valid),
    .grant_oh   (fetch_tag_resp_arb),
    .grant_bin  (fetch_tag_resp_arb_bin)
);

// Adjacency Read Master request arbitration
// --------------------------------------------------------------------------------------------------

rr_arbiter #(
    .NUM_REQUESTERS (FETCH_TAG_COUNT)
) adj_rm_req_arb (
    .clk        (core_clk),
    .resetn     (resetn),

    .request    (fetch_tag_adj_rm_req_valid),
    .update_lru (adj_rm_fetch_req_ready),
    .grant_oh   (chosen_fetch_tag_adj_rm_req),
    .grant_bin  (chosen_fetch_tag_adj_rm_req_bin)
);


// Message Read Master request arbitration
// --------------------------------------------------------------------------------------------------

rr_arbiter #(
    .NUM_REQUESTERS (FETCH_TAG_COUNT)
) msg_rm_req_arb (
    .clk        (core_clk),
    .resetn     (resetn),

    .request    (fetch_tag_msg_rm_req_valid),
    .update_lru (msg_rm_fetch_req_ready),
    .grant_oh   (chosen_fetch_tag_msg_rm_req),
    .grant_bin  (chosen_fetch_tag_msg_rm_req_bin)
);

// ==================================================================================================================================================
// Logic
// ==================================================================================================================================================

// NSB REQ/RESP
// ----------------------------------------------------------------------------------

always_comb begin
    nsb_prefetcher_feature_bank_req_ready    = nsb_prefetcher_fetch_tag_req_ready [nsb_prefetcher_feature_bank_req.nodeslot];

    // NSB responses
    nsb_prefetcher_feature_bank_resp_valid   = |nsb_prefetcher_fetch_tag_resp_valid;
    nsb_prefetcher_feature_bank_resp         = nsb_prefetcher_fetch_tag_resp [fetch_tag_resp_arb_bin];
end


// Drive Read Master requests
// ----------------------------------------------------------------------------------

// Keep track of chosen fetch tag for read master requests in-flight
always_ff @(posedge core_clk or negedge resetn) begin
    if (!resetn) begin
        chosen_fetch_tag_adj_rm_req_bin_q <= '0;
        chosen_fetch_tag_msg_rm_req_bin_q <= '0;

    end else begin
        // Accepting adjacency read master request
        if (adj_rm_fetch_req_valid && adj_rm_fetch_req_ready) begin
            chosen_fetch_tag_adj_rm_req_bin_q <= chosen_fetch_tag_adj_rm_req_bin;
        end

        // Accepting message read master request
        if (msg_rm_fetch_req_valid && msg_rm_fetch_req_ready) begin
            chosen_fetch_tag_msg_rm_req_bin_q <= chosen_fetch_tag_msg_rm_req_bin;
        end
    end
end

// Drive adjacency read master requests
always_comb begin
    adj_rm_fetch_req_valid              = |fetch_tag_adj_rm_req_valid;
    adj_rm_fetch_start_address          = fetch_tag_adj_rm_start_address [chosen_fetch_tag_adj_rm_req_bin];
    adj_rm_fetch_byte_count             = fetch_tag_adj_rm_byte_count    [chosen_fetch_tag_adj_rm_req_bin];

    adj_rm_fetch_resp_ready             = fetch_tag_adj_rm_resp_ready [chosen_fetch_tag_adj_rm_req_bin_q];
end

// Drive message read master requests
always_comb begin
    msg_rm_fetch_req_valid     = |fetch_tag_msg_rm_req_valid;
    msg_rm_fetch_start_address = fetch_tag_msg_rm_start_address [chosen_fetch_tag_msg_rm_req_bin];
    msg_rm_fetch_byte_count    = fetch_tag_msg_rm_byte_count    [chosen_fetch_tag_msg_rm_req_bin];

    msg_rm_fetch_resp_ready  = fetch_tag_msg_rm_resp_ready [chosen_fetch_tag_msg_rm_req_bin_q];
end

// ==================================================================================================================================================
// Assertions
// ==================================================================================================================================================

endmodule