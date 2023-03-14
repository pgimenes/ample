
import top_pkg::*;
import noc_params::*;
import age_pkg::*;

module aggregation_engine #(
    parameter AXI_ADDR_WIDTH = 32
) (
    input logic core_clk,
    input logic resetn,
    
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
    input  MESSAGE_CHANNEL_RESP_t [MESSAGE_CHANNEL_COUNT-1:0] message_channel_resp
);


// ==================================================================================================================================================
// Declarations
// ==================================================================================================================================================

// Regbank
// ------------------------------------------------------------

logic                         matrix_a_address_strobe;
logic                         matrix_b_address_strobe;
logic                         matrix_c_address_strobe;

logic [31:0]                  matrix_a_address_value;
logic [31:0]                  matrix_b_address_value;
logic [31:0]                  matrix_c_address_value;

logic [8:0]                   matrix_a_strobe;
logic [8:0]                   matrix_b_strobe;

logic [8:0] [31:0]            matrix_a_value;
logic [8:0] [31:0]            matrix_b_value;

logic                         config_strobe;

logic [0:0]                   config_matrix_a_valid;
logic [0:0]                   config_matrix_b_valid;
logic [0:0]                   config_start_mult;
logic [0:0]                   config_mult_done;

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

// Message Channels
// ----------------------------------------------------

logic [MESSAGE_CHANNEL_COUNT-1:0]                   nsb_mc_req_valid;
logic [MESSAGE_CHANNEL_COUNT-1:0]                   nsb_mc_req_ready;
AGE_MC_REQ_t [MESSAGE_CHANNEL_COUNT-1:0]            nsb_mc_req;

logic [MESSAGE_CHANNEL_COUNT-1:0]                   nsb_mc_resp_valid;
logic [MESSAGE_CHANNEL_COUNT-1:0]                   nsb_mc_resp_ready;
NSB_AGE_RESP_t [MESSAGE_CHANNEL_COUNT-1:0]          nsb_mc_resp;

logic [MESSAGE_CHANNEL_COUNT-1:0]                   message_channel_router_on;
logic [MESSAGE_CHANNEL_COUNT-1:0]                   message_channel_router_valid;
logic [MESSAGE_CHANNEL_COUNT-1:0]                   message_channel_router_ready;
flit_t [MESSAGE_CHANNEL_COUNT-1:0]                  message_channel_router_data;

logic [MESSAGE_CHANNEL_COUNT-1:0]                   router_message_channel_on;
logic [MESSAGE_CHANNEL_COUNT-1:0]                   router_message_channel_valid;
logic [MESSAGE_CHANNEL_COUNT-1:0]                   router_message_channel_ready;
flit_t [MESSAGE_CHANNEL_COUNT-1:0]                  router_message_channel_data;

// ==================================================================================================================================================
// Instances
// ==================================================================================================================================================

// Register Bank
// ----------------------------------------------------

aggregation_engine_regbank_regs #(
    .AXI_ADDR_WIDTH(32),
    .BASEADDR(32'b0) // use regbank parameter
) aggregation_engine_regbank_regs_i (
    .axi_aclk                       (core_clk),
    .axi_aresetn                    (resetn),
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
    .matrix_a_address_strobe,
    .matrix_a_address_value,
    .matrix_b_address_strobe,
    .matrix_b_address_value,
    .matrix_c_address_strobe,
    .matrix_c_address_value,
    .matrix_a_strobe,
    .matrix_a_value,
    .matrix_b_strobe,
    .matrix_b_value,
    .config_strobe,
    .config_matrix_a_valid,
    .config_matrix_b_valid,
    .config_start_mult,
    .config_mult_done 
);

// NOC Mesh
// ----------------------------------------------------

mesh #(
    .BUFFER_SIZE(8),
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

    .error_o            ()
);

// Message Channels
// ----------------------------------------------------

for (genvar mc = 0; mc < MESSAGE_CHANNEL_COUNT; mc = mc + 1) begin
    
    message_channel mc_i (
        .core_clk,
        .resetn,

        .nsb_age_mc_req_valid         (nsb_mc_req_valid [mc]),
        .nsb_age_mc_req_ready         (nsb_mc_req_ready [mc]),
        .nsb_age_mc_req               (nsb_mc_req [mc]),

        .nsb_age_mc_resp_valid        (nsb_mc_resp_valid [mc]), // TO DO: change (MS2)
        .nsb_age_mc_resp_ready        (nsb_mc_resp_ready [mc]),
        .nsb_age_mc_resp              (nsb_mc_resp [mc]),
        
        .message_channel_req_valid    (message_channel_req_valid [mc]),
        .message_channel_req_ready    (message_channel_req_ready [mc]),
        .message_channel_req          (message_channel_req [mc]),
        
        .message_channel_resp_valid   (message_channel_resp_valid [mc]),
        .message_channel_resp_ready   (message_channel_resp_ready [mc]),
        .message_channel_resp         (message_channel_resp [mc]),
        
        .message_channel_router_on    (message_channel_router_on [mc]),
        .message_channel_router_valid (message_channel_router_valid [mc]),
        .message_channel_router_ready (message_channel_router_ready [mc]),
        .message_channel_router_data  (message_channel_router_data [mc]),
        
        .router_message_channel_on    (router_message_channel_on [mc]),
        .router_message_channel_valid (router_message_channel_valid [mc]),
        .router_message_channel_ready (router_message_channel_ready [mc]),
        .router_message_channel_data  (router_message_channel_data [mc])
    );

    always_comb begin
        nsb_mc_req_valid[mc] = nsb_age_req_valid && (nsb_age_req.nodeslot == mc);

        // Last row of NOC mesh is taken by message channels
        message_channel_router_on [mc]      = node_router_on    [mc][MESH_ROWS-1];
        message_channel_router_ready [mc]   = node_router_ready [mc][MESH_ROWS-1];
        node_router_valid [mc][MESH_ROWS-1] = message_channel_router_valid [mc];
        node_router_data  [mc][MESH_ROWS-1] = message_channel_router_data [mc];

        router_message_channel_valid [mc]   = router_node_valid [mc][MESH_ROWS-1];
        router_message_channel_data [mc]    = router_node_data  [mc][MESH_ROWS-1];
        router_node_on    [mc][MESH_ROWS-1] = router_message_channel_on [mc];
        router_node_ready [mc][MESH_ROWS-1] = router_message_channel_ready [mc];
    end

end


// ==================================================================================================================================================
// Logic
// ==================================================================================================================================================

assign nsb_age_req_ready = |nsb_mc_req_ready; // TO DO: change
assign nsb_age_resp_valid = '0;
assign nsb_age_resp = '0;

// ==================================================================================================================================================
// Assertions
// ==================================================================================================================================================

endmodule