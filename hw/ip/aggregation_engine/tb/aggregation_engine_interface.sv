import top_pkg::*;
import age_pkg::*;

interface aggregation_engine_interface (

    input logic core_clk,
    input logic resetn,
    
    // Regbank Slave AXI interface
    input logic [AXI_ADDRESS_WIDTH-1:0]                        s_axi_awaddr,
    input logic [2:0]                                          s_axi_awprot,
    input logic                                                s_axi_awvalid,
    input logic                                                s_axi_awready,
    input logic [31:0]                                         s_axi_wdata,
    input logic [3:0]                                          s_axi_wstrb,
    input logic                                                s_axi_wvalid,
    input logic                                                s_axi_wready,
    input logic [AXI_ADDRESS_WIDTH-1:0]                        s_axi_araddr,
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
    input logic [TOTAL_BUFFER_MANAGERS-1:0]                                                       age_buffer_manager_buffer_slot_write_enable,
    input logic [TOTAL_BUFFER_MANAGERS-1:0] [$clog2(top_pkg::AGGREGATION_BUFFER_WRITE_DEPTH)-1:0] age_buffer_manager_buffer_slot_write_address,
    input logic [TOTAL_BUFFER_MANAGERS-1:0] [age_pkg::PAYLOAD_DATA_WIDTH-1:0]                     age_buffer_manager_buffer_slot_write_data

);


endinterface