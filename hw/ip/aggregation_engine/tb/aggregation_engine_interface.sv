import top_pkg::*;
import age_pkg::*;
import noc_pkg::*;

interface aggregation_engine_interface (

    input logic core_clk,
    input logic resetn,

    input logic regbank_clk,
    input logic regbank_resetn,
    
    // Regbank Slave AXI interface
    input logic [AXIL_ADDR_WIDTH-1:0]                          s_axi_awaddr,
    input logic [2:0]                                          s_axi_awprot,
    input logic                                                s_axi_awvalid,
    input logic                                                s_axi_awready,
    input logic [31:0]                                         s_axi_wdata,
    input logic [3:0]                                          s_axi_wstrb,
    input logic                                                s_axi_wvalid,
    input logic                                                s_axi_wready,
    input logic [AXIL_ADDR_WIDTH-1:0]                          s_axi_araddr,
    input logic [2:0]                                          s_axi_arprot,
    input logic                                                s_axi_arvalid,
    input logic                                                s_axi_arready,
    input logic [31:0]                                         s_axi_rdata,
    input logic [1:0]                                          s_axi_rresp,
    input logic                                                s_axi_rvalid,
    input logic                                                s_axi_rready,
    input logic [1:0]                                          s_axi_bresp,
    input logic                                                s_axi_bvalid,
    input logic                                                s_axi_bready,

    // Node Scoreboard -> Aggregation Engine Interface
    input logic                                                nsb_age_req_valid,
    input logic                                                nsb_age_req_ready,
    input NSB_AGE_REQ_t                                        nsb_age_req,

    input logic                                                nsb_age_resp_valid, // valid only for now
    input NSB_AGE_RESP_t                                       nsb_age_resp,

    // Message Channel: AGE -> Prefetcher (request)
    input logic [MESSAGE_CHANNEL_COUNT-1:0]                  message_channel_req_valid,
    input logic [MESSAGE_CHANNEL_COUNT-1:0]                  message_channel_req_ready,
    input MESSAGE_CHANNEL_REQ_t [MESSAGE_CHANNEL_COUNT-1:0]  message_channel_req,
    
    // Message Channel: Prefetcher -> AGE (response)
    input logic [MESSAGE_CHANNEL_COUNT-1:0]                  message_channel_resp_valid,
    input logic [MESSAGE_CHANNEL_COUNT-1:0]                  message_channel_resp_ready,
    input MESSAGE_CHANNEL_RESP_t [MESSAGE_CHANNEL_COUNT-1:0] message_channel_resp,

    // AGE -> Aggregation Buffer
    input  logic [top_pkg::PRECISION_COUNT-1:0] [AGGREGATION_BUFFER_SLOTS-1:0]                                                       aggregation_buffer_slot_set_node_id_valid,
    input  logic [top_pkg::PRECISION_COUNT-1:0] [AGGREGATION_BUFFER_SLOTS-1:0] [NODE_ID_WIDTH-1:0]                                   aggregation_buffer_slot_set_node_id,
    input  logic [top_pkg::PRECISION_COUNT-1:0] [AGGREGATION_BUFFER_SLOTS-1:0]                                                       aggregation_buffer_slot_write_enable,
    input  logic [top_pkg::PRECISION_COUNT-1:0] [AGGREGATION_BUFFER_SLOTS-1:0] [$clog2(top_pkg::AGGREGATION_BUFFER_WRITE_DEPTH)-1:0] aggregation_buffer_slot_write_address,
    input  logic [top_pkg::PRECISION_COUNT-1:0] [AGGREGATION_BUFFER_SLOTS-1:0] [noc_pkg::PAYLOAD_DATA_WIDTH-1:0]                     aggregation_buffer_slot_write_data,
    input  logic [top_pkg::PRECISION_COUNT-1:0] [AGGREGATION_BUFFER_SLOTS-1:0] [$clog2(top_pkg::AGGREGATION_BUFFER_READ_DEPTH)-1:0]  aggregation_buffer_slot_feature_count,
    input  logic [top_pkg::PRECISION_COUNT-1:0] [AGGREGATION_BUFFER_SLOTS-1:0]                                                       aggregation_buffer_slot_slot_free,

    input  logic [MESSAGE_CHANNEL_COUNT-1:0]                                                                                         scale_factor_queue_pop,
    input  logic [MESSAGE_CHANNEL_COUNT-1:0] [SCALE_FACTOR_QUEUE_READ_WIDTH-1:0]                                                     scale_factor_queue_out_data,
    input  logic [MESSAGE_CHANNEL_COUNT-1:0]                                                                                         scale_factor_queue_out_valid

);


endinterface