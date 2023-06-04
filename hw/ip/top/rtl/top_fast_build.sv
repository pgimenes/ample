
module top_fast_build
(
    input logic                           sys_clk,
    input logic                           sys_rst, //Common port for all controllers

    input  logic                          regbank_clk,
    input  logic                          regbank_resetn,

    // AXI-L interface to Host
    input  logic [31 : 0]                 host_axil_awaddr,
    input  logic [2 : 0]                  host_axil_awprot,
    input  logic [0 : 0]                  host_axil_awvalid,
    output logic [0 : 0]                  host_axil_awready,
    input  logic [31 : 0]                 host_axil_wdata,
    input  logic [3 : 0]                  host_axil_wstrb,
    input  logic [0 : 0]                  host_axil_wvalid,
    input  logic [0 : 0]                  host_axil_bready,
    input  logic [31 : 0]                 host_axil_araddr,
    input  logic [2 : 0]                  host_axil_arprot,
    input  logic [0 : 0]                  host_axil_arvalid,
    input  logic [0 : 0]                  host_axil_rready,
    output logic [0 : 0]                  host_axil_wready,
    output logic [1 : 0]                  host_axil_bresp,
    output logic [0 : 0]                  host_axil_bvalid,
    output logic [0 : 0]                  host_axil_arready,
    output logic [31 : 0]                 host_axil_rdata,
    output logic [1 : 0]                  host_axil_rresp,
    output logic [0 : 0]                  host_axil_rvalid

);

// ====================================================================================
// Declarations
// ====================================================================================

// AXI-L Interconnect (joint for all slaves)
logic [127 : 0]                   axil_interconnect_m_axi_awaddr;
logic [11 : 0]                    axil_interconnect_m_axi_awprot;
logic [3 : 0]                     axil_interconnect_m_axi_awvalid;
logic [3 : 0]                     axil_interconnect_m_axi_awready;
logic [127 : 0]                   axil_interconnect_m_axi_wdata;
logic [15 : 0]                    axil_interconnect_m_axi_wstrb;
logic [3 : 0]                     axil_interconnect_m_axi_wvalid;
logic [3 : 0]                     axil_interconnect_m_axi_wready;
logic [7 : 0]                     axil_interconnect_m_axi_bresp;
logic [3 : 0]                     axil_interconnect_m_axi_bvalid;
logic [3 : 0]                     axil_interconnect_m_axi_bready;
logic [127 : 0]                   axil_interconnect_m_axi_araddr;
logic [11 : 0]                    axil_interconnect_m_axi_arprot;
logic [3 : 0]                     axil_interconnect_m_axi_arvalid;
logic [3 : 0]                     axil_interconnect_m_axi_arready;
logic [127 : 0]                   axil_interconnect_m_axi_rdata;
logic [7 : 0]                     axil_interconnect_m_axi_rresp;
logic [3 : 0]                     axil_interconnect_m_axi_rvalid;
logic [3 : 0]                     axil_interconnect_m_axi_rready;

// NSB
// ------------------------------------------------------------

// Host Control
logic nsb_regbank_ctrl_fetch_layer_weights_strobe;                                  // strobe signal for register 'CTRL_FETCH_LAYER_WEIGHTS' (pulsed when the register is written from the bus)
logic [0:0] nsb_regbank_ctrl_fetch_layer_weights_fetch;                             // value of field 'CTRL_FETCH_LAYER_WEIGHTS.FETCH'
logic nsb_regbank_ctrl_fetch_layer_weights_done_strobe;                             // strobe signal for register 'CTRL_FETCH_LAYER_WEIGHTS_DONE' (pulsed when the register is read from the bus)
logic [0:0] nsb_regbank_ctrl_fetch_layer_weights_done_done;                         // value of field 'CTRL_FETCH_LAYER_WEIGHTS_DONE.DONE'
logic nsb_regbank_ctrl_fetch_layer_weights_done_ack_strobe;                         // strobe signal for register 'CTRL_FETCH_LAYER_WEIGHTS_DONE_ACK' (pulsed when the register is written from the bus)
logic [0:0] nsb_regbank_ctrl_fetch_layer_weights_done_ack_ack;                      // value of field 'CTRL_FETCH_LAYER_WEIGHTS_DONE_ACK.ACK'

// Layer Config
logic nsb_regbank_layer_config_in_features_strobe;
logic [9:0] nsb_regbank_layer_config_in_features_count;
logic nsb_regbank_layer_config_out_features_strobe;
logic [9:0] nsb_regbank_layer_config_out_features_count;
logic nsb_regbank_layer_config_weights_precision_strobe;
logic [2:0] nsb_regbank_layer_config_weights_precision_precision;
logic nsb_regbank_layer_config_activations_precision_strobe;
logic [2:0] nsb_regbank_layer_config_activations_precision_precision;

logic nsb_regbank_layer_config_adjacency_list_address_lsb_strobe;
logic [31:0] nsb_regbank_layer_config_adjacency_list_address_lsb_lsb;
logic nsb_regbank_layer_config_adjacency_list_address_msb_strobe;
logic [1:0] nsb_regbank_layer_config_adjacency_list_address_msb_msb;
logic nsb_regbank_layer_config_in_messages_address_lsb_strobe;
logic [31:0] nsb_regbank_layer_config_in_messages_address_lsb_lsb;
logic nsb_regbank_layer_config_in_messages_address_msb_strobe;
logic [1:0] nsb_regbank_layer_config_in_messages_address_msb_msb;
logic nsb_regbank_layer_config_weights_address_lsb_strobe;                          // strobe signal for register 'LAYER_CONFIG_WEIGHTS_ADDRESS_LSB' (pulsed when the register is written from the bus)
logic [31:0] nsb_regbank_layer_config_weights_address_lsb_lsb;                      // value of field 'LAYER_CONFIG_WEIGHTS_ADDRESS_LSB.LSB'
logic nsb_regbank_layer_config_weights_address_msb_strobe;                          // strobe signal for register 'LAYER_CONFIG_WEIGHTS_ADDRESS_MSB' (pulsed when the register is written from the bus)
logic [1:0] nsb_regbank_layer_config_weights_address_msb_msb;                       // value of field 'LAYER_CONFIG_WEIGHTS_ADDRESS_MSB.MSB'
logic nsb_regbank_layer_config_out_messages_address_lsb_strobe;
logic [31:0] nsb_regbank_layer_config_out_messages_address_lsb_lsb;
logic nsb_regbank_layer_config_out_messages_address_msb_strobe;
logic [1:0] nsb_regbank_layer_config_out_messages_address_msb_msb;

// Nodeslots
logic [31:0] nsb_regbank_nsb_nodeslot_neighbour_count_strobe;                       // strobe signal for register 'NSB_NODESLOT_NEIGHBOUR_COUNT' (pulsed when the register is written from the bus)
logic [31:0] [19:0] nsb_regbank_nsb_nodeslot_neighbour_count_count;                 // value of field 'NSB_NODESLOT_NEIGHBOUR_COUNT.COUNT'
logic [31:0] nsb_regbank_nsb_nodeslot_node_id_strobe;                               // strobe signal for register 'NSB_NODESLOT_NODE_ID' (pulsed when the register is written from the bus)
logic [31:0] [19:0] nsb_regbank_nsb_nodeslot_node_id_id;                            // value of field 'NSB_NODESLOT_NODE_ID.ID'
logic [31:0] nsb_regbank_nsb_nodeslot_node_state_strobe;                            // strobe signal for register 'NSB_NODESLOT_NODE_STATE' (pulsed when the register is written from the bus)
logic [31:0] [3:0] nsb_regbank_nsb_nodeslot_node_state_state;                       // value of field 'NSB_NODESLOT_NODE_STATE.STATE'
logic [31:0] nsb_regbank_nsb_nodeslot_precision_strobe;                             // strobe signal for register 'NSB_NODESLOT_PRECISION' (pulsed when the register is written from the bus)
logic [31:0] [1:0] nsb_regbank_nsb_nodeslot_precision_precision;                    // value of field 'NSB_NODESLOT_PRECISION.PRECISION'
logic [31:0] nsb_regbank_nsb_nodeslot_adjacency_list_address_lsb_strobe;            // strobe signal for register 'NSB_NODESLOT_ADJACENCY_LIST_ADDRESS_LSB' (pulsed when the register is written from the bus)
logic [31:0] [31:0] nsb_regbank_nsb_nodeslot_adjacency_list_address_lsb_lsb;        // value of field 'NSB_NODESLOT_ADJACENCY_LIST_ADDRESS_LSB.LSB'
logic [31:0] nsb_regbank_nsb_nodeslot_adjacency_list_address_msb_strobe;            // strobe signal for register 'NSB_NODESLOT_ADJACENCY_LIST_ADDRESS_MSB' (pulsed when the register is written from the bus)
logic [31:0] [1:0] nsb_regbank_nsb_nodeslot_adjacency_list_address_msb_msb;         // value of field 'NSB_NODESLOT_ADJACENCY_LIST_ADDRESS_MSB.MSB'
logic [31:0] nsb_regbank_nsb_nodeslot_out_messages_address_lsb_strobe;              // strobe signal for register 'NSB_NODESLOT_OUT_MESSAGES_ADDRESS_LSB' (pulsed when the register is written from the bus)
logic [31:0] [31:0] nsb_regbank_nsb_nodeslot_out_messages_address_lsb_lsb;          // value of field 'NSB_NODESLOT_OUT_MESSAGES_ADDRESS_LSB.LSB'
logic [31:0] nsb_regbank_nsb_nodeslot_out_messages_address_msb_strobe;              // strobe signal for register 'NSB_NODESLOT_OUT_MESSAGES_ADDRESS_MSB' (pulsed when the register is written from the bus)
logic [31:0] [1:0] nsb_regbank_nsb_nodeslot_out_messages_address_msb_msb;           // value of field 'NSB_NODESLOT_OUT_MESSAGES_ADDRESS_MSB.MSB'
logic [31:0] nsb_regbank_nsb_nodeslot_aggregation_function_strobe;                  // strobe signal for register 'nsb_nodeslot_aggregation_function' (pulsed when the register is written from the bus)
logic [31:0] [1:0] nsb_regbank_nsb_nodeslot_aggregation_function_value;             // value of field 'nsb_nodeslot_aggregation_function.value'
logic [31:0] nsb_regbank_nsb_nodeslot_scale_factors_address_lsb_strobe;             // strobe signal for register 'nsb_nodeslot_scale_factors_address_lsb' (pulsed when the register is written from the bus)
logic [31:0] [31:0] nsb_regbank_nsb_nodeslot_scale_factors_address_lsb_value;       // value of field 'nsb_nodeslot_scale_factors_address_lsb.value'
logic [31:0] nsb_regbank_nsb_nodeslot_scale_factors_address_msb_strobe;             // strobe signal for register 'nsb_nodeslot_scale_factors_address_msb' (pulsed when the register is written from the bus)
logic [31:0] [1:0] nsb_regbank_nsb_nodeslot_scale_factors_address_msb_value;        // value of field 'nsb_nodeslot_scale_factors_address_msb.value'

logic nsb_regbank_nsb_nodeslot_config_make_valid_msb_strobe; // strobe signal for register 'NSB_NODESLOT_CONFIG_MAKE_VALID_MSB' (pulsed when the register is written from the bus)
logic [31:0] nsb_regbank_nsb_nodeslot_config_make_valid_msb_make_valid; // value of field 'NSB_NODESLOT_CONFIG_MAKE_VALID_MSB.MAKE_VALID'
logic nsb_regbank_nsb_nodeslot_config_make_valid_lsb_strobe; // strobe signal for register 'NSB_NODESLOT_CONFIG_MAKE_VALID_LSB' (pulsed when the register is written from the bus)
logic [31:0] nsb_regbank_nsb_nodeslot_config_make_valid_lsb_make_valid;// value of field 'NSB_NODESLOT_CONFIG_MAKE_VALID_LSB.MAKE_VALID'

logic nsb_regbank_nsb_config_aggregation_wait_count_strobe; // strobe signal for register 'NSB_CONFIG_AGGREGATION_WAIT_COUNT' (pulsed when the register is written from the bus)
logic [5:0] nsb_regbank_nsb_config_aggregation_wait_count_count; // value of field 'NSB_CONFIG_AGGREGATION_WAIT_COUNT.COUNT'
logic nsb_regbank_nsb_config_transformation_wait_count_strobe; // strobe signal for register 'NSB_CONFIG_TRANSFORMATION_WAIT_COUNT' (pulsed when the register is written from the bus)
logic [5:0] nsb_regbank_nsb_config_transformation_wait_count_count;// value of field 'NSB_CONFIG_TRANSFORMATION_WAIT_COUNT.COUNT'

logic [31:0] nsb_regbank_nsb_nodeslot_allocated_fetch_tag_strobe;
logic [31:0] [5:0] nsb_regbank_nsb_nodeslot_allocated_fetch_tag_fetch_tag;

// Prefetcher
// --------------------------------------------------------------------------------------------

logic prefetcher_regbank_layer_config_in_features_strobe;
logic [9:0] prefetcher_regbank_layer_config_in_features_count;
logic prefetcher_regbank_layer_config_out_features_strobe;
logic [9:0] prefetcher_regbank_layer_config_out_features_count;
logic prefetcher_regbank_layer_config_in_messages_address_lsb_strobe;
logic [31:0] prefetcher_regbank_layer_config_in_messages_address_lsb_value;
logic prefetcher_regbank_layer_config_in_messages_address_msb_strobe;
logic [1:0] prefetcher_regbank_layer_config_in_messages_address_msb_value;
logic prefetcher_regbank_layer_config_adjacency_list_address_lsb_strobe;
logic [31:0] prefetcher_regbank_layer_config_adjacency_list_address_lsb_value;
logic prefetcher_regbank_layer_config_adjacency_list_address_msb_strobe;
logic [1:0] prefetcher_regbank_layer_config_adjacency_list_address_msb_value;
logic prefetcher_regbank_layer_config_weights_address_lsb_strobe;
logic [3:0] [31:0] prefetcher_regbank_layer_config_weights_address_lsb_value;
logic [3:0] prefetcher_regbank_layer_config_weights_address_msb_strobe;
logic [3:0] [1:0] prefetcher_regbank_layer_config_weights_address_msb_value;
logic [3:0] prefetcher_regbank_layer_config_scale_factors_address_lsb_strobe;
logic [31:0] prefetcher_regbank_layer_config_scale_factors_address_lsb_value;
logic prefetcher_regbank_layer_config_scale_factors_address_msb_strobe;
logic [1:0] prefetcher_regbank_layer_config_scale_factors_address_msb_value;

// Aggregation Engine
// ------------------------------------------------------------

logic age_regbank_layer_config_in_features_strobe;
logic [9:0] age_regbank_layer_config_in_features_count;
logic age_regbank_layer_config_out_features_strobe;
logic [3:0] age_regbank_layer_config_out_features_count;
logic age_regbank_layer_config_upsampling_parameter_strobe;
logic [31:0] age_regbank_layer_config_upsampling_parameter_value;

// FTE
// -------------------------------------------------------------------------------------

logic        fte_regbank_layer_config_in_features_strobe;
logic [9:0]  fte_regbank_layer_config_in_features_count;
logic        fte_regbank_layer_config_out_features_strobe;
logic [9:0]  fte_regbank_layer_config_out_features_count;
logic        fte_regbank_layer_config_activation_function_strobe;
logic [1:0]  fte_regbank_layer_config_activation_function_value;
logic        fte_regbank_layer_config_bias_strobe;
logic [31:0] fte_regbank_layer_config_bias_value;
logic        fte_regbank_layer_config_leaky_relu_alpha_strobe;
logic [31:0] fte_regbank_layer_config_leaky_relu_alpha_value;
logic        fte_regbank_layer_config_out_features_address_msb_strobe;
logic [1:0]  fte_regbank_layer_config_out_features_address_msb_value;
logic        fte_regbank_layer_config_out_features_address_lsb_strobe;
logic [31:0] fte_regbank_layer_config_out_features_address_lsb_value;
logic       fte_regbank_ctrl_buffering_enable_strobe;
logic [0:0] fte_regbank_ctrl_buffering_enable_value;
logic       fte_regbank_ctrl_writeback_enable_strobe;
logic [0:0] fte_regbank_ctrl_writeback_enable_value;

// ====================================================================================
// AXI-L Register Control Crossbar
// ====================================================================================

// M00: AGE
// M01: FTE
// M02: NSB
// M03: Prefetcher

axi_L_register_control_crossbar axi_L_register_control_crossbar_i (
  .aclk                                 (regbank_clk),                    // input wire aclk
  .aresetn                              (regbank_resetn),              // input wire aresetn

  .s_axi_awaddr                         (host_axil_awaddr),    // input wire [31 : 0] s_axi_awaddr
  .s_axi_awprot                         (host_axil_awprot),    // input wire [2 : 0] s_axi_awprot
  .s_axi_awvalid                        (host_axil_awvalid),  // input wire [0 : 0] s_axi_awvalid
  .s_axi_awready                        (host_axil_awready),  // output wire [0 : 0] s_axi_awready
  .s_axi_wdata                          (host_axil_wdata),      // input wire [31 : 0] s_axi_wdata
  .s_axi_wstrb                          (host_axil_wstrb),      // input wire [3 : 0] s_axi_wstrb
  .s_axi_wvalid                         (host_axil_wvalid),    // input wire [0 : 0] s_axi_wvalid
  .s_axi_wready                         (host_axil_wready),    // output wire [0 : 0] s_axi_wready
  .s_axi_bresp                          (host_axil_bresp),      // output wire [1 : 0] s_axi_bresp
  .s_axi_bvalid                         (host_axil_bvalid),    // output wire [0 : 0] s_axi_bvalid
  .s_axi_bready                         (host_axil_bready),    // input wire [0 : 0] s_axi_bready
  .s_axi_araddr                         (host_axil_araddr),    // input wire [31 : 0] s_axi_araddr
  .s_axi_arprot                         (host_axil_arprot),    // input wire [2 : 0] s_axi_arprot
  .s_axi_arvalid                        (host_axil_arvalid),  // input wire [0 : 0] s_axi_arvalid
  .s_axi_arready                        (host_axil_arready),  // output wire [0 : 0] s_axi_arready
  .s_axi_rdata                          (host_axil_rdata),      // output wire [31 : 0] s_axi_rdata
  .s_axi_rresp                          (host_axil_rresp),      // output wire [1 : 0] s_axi_rresp
  .s_axi_rvalid                         (host_axil_rvalid),    // output wire [0 : 0] s_axi_rvalid
  .s_axi_rready                         (host_axil_rready),    // input wire [0 : 0] s_axi_rready

  .m_axi_awaddr                         (axil_interconnect_m_axi_awaddr),    // output wire [127 : 0] m_axi_awaddr
  .m_axi_awprot                         (axil_interconnect_m_axi_awprot),    // output wire [11 : 0] m_axi_awprot
  .m_axi_awvalid                        (axil_interconnect_m_axi_awvalid),  // output wire [3 : 0] m_axi_awvalid
  .m_axi_awready                        (axil_interconnect_m_axi_awready),  // input wire [3 : 0] m_axi_awready
  .m_axi_wdata                          (axil_interconnect_m_axi_wdata),      // output wire [127 : 0] m_axi_wdata
  .m_axi_wstrb                          (axil_interconnect_m_axi_wstrb),      // output wire [15 : 0] m_axi_wstrb
  .m_axi_wvalid                         (axil_interconnect_m_axi_wvalid),    // output wire [3 : 0] m_axi_wvalid
  .m_axi_wready                         (axil_interconnect_m_axi_wready),    // input wire [3 : 0] m_axi_wready
  .m_axi_bresp                          (axil_interconnect_m_axi_bresp),      // input wire [7 : 0] m_axi_bresp
  .m_axi_bvalid                         (axil_interconnect_m_axi_bvalid),    // input wire [3 : 0] m_axi_bvalid
  .m_axi_bready                         (axil_interconnect_m_axi_bready),    // output wire [3 : 0] m_axi_bready
  .m_axi_araddr                         (axil_interconnect_m_axi_araddr),    // output wire [127 : 0] m_axi_araddr
  .m_axi_arprot                         (axil_interconnect_m_axi_arprot),    // output wire [11 : 0] m_axi_arprot
  .m_axi_arvalid                        (axil_interconnect_m_axi_arvalid),  // output wire [3 : 0] m_axi_arvalid
  .m_axi_arready                        (axil_interconnect_m_axi_arready),  // input wire [3 : 0] m_axi_arready
  .m_axi_rdata                          (axil_interconnect_m_axi_rdata),      // input wire [127 : 0] m_axi_rdata
  .m_axi_rresp                          (axil_interconnect_m_axi_rresp),      // input wire [7 : 0] m_axi_rresp
  .m_axi_rvalid                         (axil_interconnect_m_axi_rvalid),    // input wire [3 : 0] m_axi_rvalid
  .m_axi_rready                         (axil_interconnect_m_axi_rready)    // output wire [3 : 0] m_axi_rready
);

// ====================================================================================
// NSB Register Bank
// ====================================================================================

node_scoreboard_regbank_wrapper node_scoreboard_regbank_i (
    // Clock and Reset (SLOW)
    .axi_aclk                       (regbank_clk),
    .axi_aresetn                    (regbank_resetn),

    // Clock and Reset (FAST)
    .fast_clk                       (sys_clk),
    .fast_resetn                    (!sys_rst),

    // AXI Write Address Channel
    .s_axi_awaddr                   (axil_interconnect_m_axi_awaddr     [95:64]),
    .s_axi_awprot                   (axil_interconnect_m_axi_awprot     [8:6]),
    .s_axi_awvalid                  (axil_interconnect_m_axi_awvalid    [2:2]),
    .s_axi_awready                  (axil_interconnect_m_axi_awready    [2:2]),
    .s_axi_wdata                    (axil_interconnect_m_axi_wdata      [95:64]),
    .s_axi_wstrb                    (axil_interconnect_m_axi_wstrb      [11:8]),
    .s_axi_wvalid                   (axil_interconnect_m_axi_wvalid     [2:2]),
    .s_axi_wready                   (axil_interconnect_m_axi_wready     [2:2]),

    .s_axi_araddr                   (axil_interconnect_m_axi_araddr     [95:64]),
    .s_axi_arprot                   (axil_interconnect_m_axi_arprot     [8:6]),
    .s_axi_arvalid                  (axil_interconnect_m_axi_arvalid    [2:2]),
    .s_axi_arready                  (axil_interconnect_m_axi_arready    [2:2]),

    .s_axi_rdata                    (axil_interconnect_m_axi_rdata      [95:64]),
    .s_axi_rresp                    (axil_interconnect_m_axi_rresp      [5:4]),
    .s_axi_rvalid                   (axil_interconnect_m_axi_rvalid     [2:2]),
    .s_axi_rready                   (axil_interconnect_m_axi_rready     [2:2]),

    .s_axi_bresp                    (axil_interconnect_m_axi_bresp      [5:4]),
    .s_axi_bvalid                   (axil_interconnect_m_axi_bvalid     [2:2]),
    .s_axi_bready                   (axil_interconnect_m_axi_bready     [2:2]),

    // User Ports
    .layer_config_weights_address_lsb_lsb               (nsb_regbank_layer_config_weights_address_lsb_lsb),
    .layer_config_weights_address_msb_msb               (nsb_regbank_layer_config_weights_address_msb_msb),
    .ctrl_fetch_layer_weights_fetch                     (nsb_regbank_ctrl_fetch_layer_weights_fetch),
    .ctrl_fetch_layer_weights_done_done                 (nsb_regbank_ctrl_fetch_layer_weights_done_done),
    .ctrl_fetch_layer_weights_done_ack_ack              (nsb_regbank_ctrl_fetch_layer_weights_done_ack_ack),
    .layer_config_in_messages_address_lsb_lsb           (nsb_regbank_layer_config_in_messages_address_lsb_lsb),
    .layer_config_in_messages_address_msb_msb           (nsb_regbank_layer_config_in_messages_address_msb_msb),
    .layer_config_out_messages_address_lsb_lsb          (nsb_regbank_layer_config_out_messages_address_lsb_lsb),
    .layer_config_out_messages_address_msb_msb          (nsb_regbank_layer_config_out_messages_address_msb_msb),
    .nsb_nodeslot_neighbour_count_count                 (nsb_regbank_nsb_nodeslot_neighbour_count_count),
    .nsb_nodeslot_node_id_id                            (nsb_regbank_nsb_nodeslot_node_id_id),
    .nsb_nodeslot_node_state_state                      (nsb_regbank_nsb_nodeslot_node_state_state),
    .nsb_nodeslot_precision_precision                   (nsb_regbank_nsb_nodeslot_precision_precision),
    .nsb_nodeslot_adjacency_list_address_lsb_lsb        (nsb_regbank_nsb_nodeslot_adjacency_list_address_lsb_lsb),
    .nsb_nodeslot_adjacency_list_address_msb_msb        (nsb_regbank_nsb_nodeslot_adjacency_list_address_msb_msb),
    .nsb_nodeslot_out_messages_address_lsb_lsb          (nsb_regbank_nsb_nodeslot_out_messages_address_lsb_lsb),
    .nsb_nodeslot_out_messages_address_msb_msb          (nsb_regbank_nsb_nodeslot_out_messages_address_msb_msb),
    .nsb_nodeslot_config_make_valid_msb_make_valid      (nsb_regbank_nsb_nodeslot_config_make_valid_msb_make_valid),
    .nsb_nodeslot_config_make_valid_lsb_make_valid      (nsb_regbank_nsb_nodeslot_config_make_valid_lsb_make_valid),
    .nsb_config_aggregation_wait_count_count            (nsb_regbank_nsb_config_aggregation_wait_count_count),
    .nsb_config_transformation_wait_count_count         (nsb_regbank_nsb_config_transformation_wait_count_count),
    .nsb_nodeslot_allocated_fetch_tag_fetch_tag         (nsb_regbank_nsb_nodeslot_allocated_fetch_tag_fetch_tag),
    .layer_config_in_features_count                     (nsb_regbank_layer_config_in_features_count),
    .layer_config_out_features_count                    (nsb_regbank_layer_config_out_features_count),
    .layer_config_adjacency_list_address_lsb_lsb        (nsb_regbank_layer_config_adjacency_list_address_lsb_lsb),
    .layer_config_adjacency_list_address_msb_msb        (nsb_regbank_layer_config_adjacency_list_address_msb_msb),
    .nsb_nodeslot_aggregation_function_value            (nsb_regbank_nsb_nodeslot_aggregation_function_value),
    .nsb_nodeslot_scale_factors_address_lsb_value       (nsb_regbank_nsb_nodeslot_scale_factors_address_lsb_value),
    .nsb_nodeslot_scale_factors_address_msb_value       (nsb_regbank_nsb_nodeslot_scale_factors_address_msb_value),
    .ctrl_fetch_layer_weights_precision_value           (nsb_regbank_ctrl_fetch_layer_weights_precision_value),
    .layer_config_valid_value                           (nsb_regbank_layer_config_valid_value),
    .status_nodeslots_empty_mask_msb_value              (nsb_regbank_status_nodeslots_empty_mask_msb_value),
    .status_nodeslots_empty_mask_lsb_value              (nsb_regbank_status_nodeslots_empty_mask_lsb_value),
    .*
);

// ====================================================================================
// Prefetcher Register Bank
// ====================================================================================

prefetcher_regbank_wrapper prefetcher_regbank_i (
    // Clock and Reset
    .axi_aclk                       (regbank_clk),
    .axi_aresetn                    (regbank_resetn),

    .fast_clk                       (sys_clk),
    .fast_resetn                    (!sys_rst),

    // AXI Write Address Channel
    .s_axi_awaddr                   (axil_interconnect_m_axi_awaddr     [127:96]),
    .s_axi_awprot                   (axil_interconnect_m_axi_awprot     [11:9]),
    .s_axi_awvalid                  (axil_interconnect_m_axi_awvalid    [3:3]),
    .s_axi_awready                  (axil_interconnect_m_axi_awready    [3:3]),
    .s_axi_wdata                    (axil_interconnect_m_axi_wdata      [127:96]),
    .s_axi_wstrb                    (axil_interconnect_m_axi_wstrb      [15:12]),
    .s_axi_wvalid                   (axil_interconnect_m_axi_wvalid     [3:3]),
    .s_axi_wready                   (axil_interconnect_m_axi_wready     [3:3]),
    .s_axi_araddr                   (axil_interconnect_m_axi_araddr     [127:96]),
    .s_axi_arprot                   (axil_interconnect_m_axi_arprot     [11:9]),
    .s_axi_arvalid                  (axil_interconnect_m_axi_arvalid    [3:3]),
    .s_axi_arready                  (axil_interconnect_m_axi_arready    [3:3]),
    .s_axi_rdata                    (axil_interconnect_m_axi_rdata      [127:96]),
    .s_axi_rresp                    (axil_interconnect_m_axi_rresp      [7:6]),
    .s_axi_rvalid                   (axil_interconnect_m_axi_rvalid     [3:3]),
    .s_axi_rready                   (axil_interconnect_m_axi_rready     [3:3]),
    .s_axi_bresp                    (axil_interconnect_m_axi_bresp      [7:6]),
    .s_axi_bvalid                   (axil_interconnect_m_axi_bvalid     [3:3]),
    .s_axi_bready                   (axil_interconnect_m_axi_bready     [3:3]),

    // User Ports
    .layer_config_in_features_count                         (prefetcher_regbank_layer_config_in_features_count),
    .layer_config_out_features_count                        (prefetcher_regbank_layer_config_out_features_count),
    .layer_config_adjacency_list_address_lsb_value          (prefetcher_regbank_layer_config_adjacency_list_address_lsb_value),
    .layer_config_adjacency_list_address_msb_value          (prefetcher_regbank_layer_config_adjacency_list_address_msb_value),
    .layer_config_weights_address_lsb_value                 (prefetcher_regbank_layer_config_weights_address_lsb_value),
    .layer_config_weights_address_msb_value                 (prefetcher_regbank_layer_config_weights_address_msb_value),
    .layer_config_in_messages_address_lsb_value             (prefetcher_regbank_layer_config_in_messages_address_lsb_value),
    .layer_config_in_messages_address_msb_value             (prefetcher_regbank_layer_config_in_messages_address_msb_value),
    .layer_config_scale_factors_address_lsb_value           (prefetcher_regbank_layer_config_scale_factors_address_lsb_value),
    .layer_config_scale_factors_address_msb_value           (prefetcher_regbank_layer_config_scale_factors_address_msb_value)
);

// ====================================================================================
// AGE
// ====================================================================================

aggregation_engine_regbank_wrapper #(
    .AXI_ADDR_WIDTH(32)
) aggregation_engine_regbank_regs_i (
    .axi_aclk                       (regbank_clk),
    .axi_aresetn                    (regbank_resetn),
    .fast_clk                       (sys_clk),
    .fast_resetn                    (!sys_rst),

    .s_axi_awaddr                   (axil_interconnect_m_axi_awaddr     [31:0]),
    .s_axi_awprot                   (axil_interconnect_m_axi_awprot     [2:0]),
    .s_axi_awvalid                  (axil_interconnect_m_axi_awvalid    [0]),
    .s_axi_awready                  (axil_interconnect_m_axi_awready    [0]),
    .s_axi_wdata                    (axil_interconnect_m_axi_wdata      [31:0]),
    .s_axi_wstrb                    (axil_interconnect_m_axi_wstrb      [3:0]),
    .s_axi_wvalid                   (axil_interconnect_m_axi_wvalid     [0]),
    .s_axi_wready                   (axil_interconnect_m_axi_wready     [0]),
    .s_axi_araddr                   (axil_interconnect_m_axi_araddr     [31:0]),
    .s_axi_arprot                   (axil_interconnect_m_axi_arprot     [2:0]),
    .s_axi_arvalid                  (axil_interconnect_m_axi_arvalid    [0]),
    .s_axi_arready                  (axil_interconnect_m_axi_arready    [0]),
    .s_axi_rdata                    (axil_interconnect_m_axi_rdata      [31:0]),
    .s_axi_rresp                    (axil_interconnect_m_axi_rresp      [1:0]),
    .s_axi_rvalid                   (axil_interconnect_m_axi_rvalid     [0]),
    .s_axi_rready                   (axil_interconnect_m_axi_rready     [0]),
    .s_axi_bresp                    (axil_interconnect_m_axi_bresp      [1:0]),
    .s_axi_bvalid                   (axil_interconnect_m_axi_bvalid     [0]),
    .s_axi_bready                   (axil_interconnect_m_axi_bready     [0]),

    .layer_config_in_features_count             (age_regbank_layer_config_in_features_count),
    .layer_config_out_features_count            (age_regbank_layer_config_out_features_count),
    .layer_config_upsampling_parameter_value    (age_regbank_layer_config_upsampling_parameter_value),
    .*
);

// ====================================================================================
// FTE
// ====================================================================================

feature_transformation_engine_regbank_wrapper feature_transformation_engine_regbank_i (
    // Clock and Reset
    .axi_aclk                       (regbank_clk),
    .axi_aresetn                    (regbank_resetn),
    .fast_clk                       (sys_clk),
    .fast_resetn                    (!sys_rst),

    // AXI Write Address Channel
    .s_axi_awaddr                   (axil_interconnect_m_axi_awaddr     [63:32]),
    .s_axi_awprot                   (axil_interconnect_m_axi_awprot     [5:3]),
    .s_axi_awvalid                  (axil_interconnect_m_axi_awvalid    [1:1]),
    .s_axi_awready                  (axil_interconnect_m_axi_awready    [1:1]),
    .s_axi_wdata                    (axil_interconnect_m_axi_wdata      [63:32]),
    .s_axi_wstrb                    (axil_interconnect_m_axi_wstrb      [7:4]),
    .s_axi_wvalid                   (axil_interconnect_m_axi_wvalid     [1:1]),
    .s_axi_wready                   (axil_interconnect_m_axi_wready     [1:1]),
    .s_axi_araddr                   (axil_interconnect_m_axi_araddr     [63:32]),
    .s_axi_arprot                   (axil_interconnect_m_axi_arprot     [5:3]),
    .s_axi_arvalid                  (axil_interconnect_m_axi_arvalid    [1:1]),
    .s_axi_arready                  (axil_interconnect_m_axi_arready    [1:1]),
    .s_axi_rdata                    (axil_interconnect_m_axi_rdata      [63:32]),
    .s_axi_rresp                    (axil_interconnect_m_axi_rresp      [3:2]),
    .s_axi_rvalid                   (axil_interconnect_m_axi_rvalid     [1:1]),
    .s_axi_rready                   (axil_interconnect_m_axi_rready     [1:1]),
    .s_axi_bresp                    (axil_interconnect_m_axi_bresp      [3:2]),
    .s_axi_bvalid                   (axil_interconnect_m_axi_bvalid     [1:1]),
    .s_axi_bready                   (axil_interconnect_m_axi_bready     [1:1]),

    // User Ports
    .layer_config_in_features_count                 (fte_regbank_layer_config_in_features_count),
    .layer_config_out_features_count                (fte_regbank_layer_config_out_features_count),
    .layer_config_activation_function_value         (fte_regbank_layer_config_activation_function_value),
    .layer_config_bias_value                        (fte_regbank_layer_config_bias_value),
    .layer_config_leaky_relu_alpha_value            (fte_regbank_layer_config_leaky_relu_alpha_value),
    .layer_config_out_features_address_msb_value    (fte_regbank_layer_config_out_features_address_msb_value),
    .layer_config_out_features_address_lsb_value    (fte_regbank_layer_config_out_features_address_lsb_value),
    .ctrl_buffering_enable_value                    (fte_regbank_ctrl_buffering_enable_value),
    .ctrl_writeback_enable_value                    (fte_regbank_ctrl_writeback_enable_value),
    .*
);

endmodule