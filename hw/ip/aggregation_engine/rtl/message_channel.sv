import top_pkg::*;
import age_pkg::*;
import noc_params::*;

module message_channel #(

) (
    input logic           core_clk,
    input logic           resetn,

    // AGE requests
    input  logic          nsb_age_mc_req_valid,
    output logic          nsb_age_mc_req_ready,
    input  AGE_MC_REQ_t   nsb_age_mc_req,

    // Generated NSB responses
    output logic          nsb_age_mc_resp_valid,
    input  logic          nsb_age_mc_resp_ready,
    output NSB_AGE_RESP_t nsb_age_mc_resp,

    // Message Channel: AGE -> Prefetcher (request)
    output logic                    message_channel_req_valid,
    input  logic                    message_channel_req_ready,
    output MESSAGE_CHANNEL_REQ_t    message_channel_req,
    
    // Message Channel: Prefetcher -> AGE (response)
    input  logic                    message_channel_resp_valid,
    output logic                    message_channel_resp_ready,
    input  MESSAGE_CHANNEL_RESP_t   message_channel_resp,

    // Message Channel -> Router
    input  logic  message_channel_router_on,
    output logic  message_channel_router_valid,
    input  logic  message_channel_router_ready,
    output flit_t message_channel_router_data,

    // Router -> Message Channel
    output logic  router_message_channel_on,
    input  logic  router_message_channel_valid,
    output logic  router_message_channel_ready,
    input  flit_t router_message_channel_data
);

typedef enum logic [2:0] {
    MC_FSM_IDLE           = 3'd0,
    MC_FSM_PREF_REQ       = 3'd1,
    MC_FSM_WAIT_PREF_RESP = 3'd2,
    MC_FSM_SEND_ROUTER    = 3'd3,
    MC_FSM_NSB_RESP       = 3'd4
} mc_state_e;

// ==================================================================================================================================================
// Declarations
// ==================================================================================================================================================

logic [MAX_AC_PER_NODE-1:0] [$clog2(AC_COLS)-1:0] coords_buffer_x;
logic [MAX_AC_PER_NODE-1:0] [$clog2(AC_ROWS)-1:0] coords_buffer_y;
logic [$clog2(MAX_AC_PER_NODE)-1:0] coord_ptr;

logic [$clog2(TOTAL_AGGREGATION_CORES)-1:0]     nsb_req_ac_count_q;
logic [$clog2(top_pkg::MAX_NODESLOT_COUNT)-1:0] nsb_req_nodeslot_q;
logic [$clog2(top_pkg::FETCH_TAG_COUNT)-1:0]    nsb_req_fetch_tag_q;

mc_state_e mc_state, mc_state_n;

axi_packet_fsm_e packet_state, packet_state_n;
logic start_sending_pkt;
logic pkt_done;

MESSAGE_CHANNEL_RESP_t   message_channel_resp_q; // buffer MC response to send flits to network

// ==================================================================================================================================================
// Logic
// ==================================================================================================================================================

// Message channel state machine
// --------------------------------------------

always_ff @(posedge core_clk or negedge resetn) begin
    if (!resetn) begin
        mc_state <= MC_FSM_IDLE;
    end else begin
        mc_state <= mc_state_n;
    end
end

always_comb begin
    mc_state_n = mc_state;

    case(mc_state)

    MC_FSM_IDLE: begin
        mc_state_n = nsb_age_mc_req_valid ? MC_FSM_PREF_REQ
                    : MC_FSM_IDLE;
    end

    MC_FSM_PREF_REQ: begin
        mc_state_n = message_channel_req_ready ? MC_FSM_WAIT_PREF_RESP
                    : MC_FSM_PREF_REQ;
    end

    MC_FSM_WAIT_PREF_RESP: begin
        mc_state_n = message_channel_resp_valid ? MC_FSM_SEND_ROUTER
                    : MC_FSM_WAIT_PREF_RESP;
    end

    MC_FSM_SEND_ROUTER: begin
        mc_state_n = pkt_done && message_channel_resp_q.last ? MC_FSM_NSB_RESP
                    : pkt_done ? MC_FSM_WAIT_PREF_RESP
                    : MC_FSM_SEND_ROUTER;
    end

    MC_FSM_NSB_RESP: begin
        mc_state_n = nsb_age_mc_resp_ready ? MC_FSM_IDLE
                    : MC_FSM_NSB_RESP;
    end

    default: mc_state_n = MC_FSM_IDLE;

    endcase
end

// NSB REQ/RESP interface
// --------------------------------------------

// Buffer request payloads
always_ff @(posedge core_clk or negedge resetn) begin
    if (!resetn) begin
        nsb_req_ac_count_q <= '0;
        nsb_req_nodeslot_q <= '0;
        nsb_req_fetch_tag_q <= '0;

    end else if (nsb_age_mc_req_valid && nsb_age_mc_req_ready) begin
        nsb_req_ac_count_q <= nsb_age_mc_req.ac_count;
        nsb_req_nodeslot_q <= nsb_age_mc_req.nsb_req.nodeslot;
        nsb_req_fetch_tag_q <= nsb_age_mc_req.nsb_req.fetch_tag;
    end
end

always_comb begin
    nsb_age_mc_req_ready = (mc_state == MC_FSM_IDLE);

    nsb_age_mc_resp_valid = (mc_state == MC_FSM_NSB_RESP);
    nsb_age_mc_resp.nodeslot = nsb_req_nodeslot_q;
end

// Message channel REQ/RESP interface
// --------------------------------------------

always_comb begin
    message_channel_req_valid    <= (mc_state == MC_FSM_PREF_REQ);
    message_channel_req.nodeslot <= nsb_req_nodeslot_q;
    message_channel_req.nodeslot <= nsb_req_fetch_tag_q;

    message_channel_resp_ready   <= (mc_state == MC_FSM_WAIT_PREF_RESP);
end

always_ff @(posedge core_clk or negedge resetn) begin
    if (!resetn) begin
        message_channel_resp_q <= '0;
    end else if ((mc_state == MC_FSM_WAIT_PREF_RESP) && message_channel_resp_valid) begin
        message_channel_resp_q <= message_channel_resp;
    end
end

// Network packet state machine
// --------------------------------------------

always_ff @(posedge core_clk or negedge resetn) begin
    if (!resetn) begin
        packet_state <= PKT_FSM_IDLE;
    end else begin
        packet_state <= packet_state_n;
    end
end

always_comb begin
    start_sending_pkt = (mc_state == MC_FSM_WAIT_PREF_RESP) && message_channel_resp_valid;
    pkt_done          = (packet_state == PKT_FSM_TAIL) && message_channel_router_ready;
    
    packet_state_n = packet_state;

    case(packet_state)

    age_pkg::PKT_FSM_IDLE: packet_state_n  = (message_channel_router_on && start_sending_pkt) ? PKT_FSM_HEAD : PKT_FSM_IDLE;
    age_pkg::PKT_FSM_HEAD: packet_state_n  = message_channel_router_ready ? PKT_FSM_BODY1 : PKT_FSM_HEAD;
    age_pkg::PKT_FSM_BODY1: packet_state_n = message_channel_router_ready ? PKT_FSM_BODY2 : PKT_FSM_BODY1;
    age_pkg::PKT_FSM_BODY2: packet_state_n = message_channel_router_ready ? PKT_FSM_BODY3 : PKT_FSM_BODY2;
    age_pkg::PKT_FSM_BODY3: packet_state_n = message_channel_router_ready ? PKT_FSM_BODY4 : PKT_FSM_BODY3;
    age_pkg::PKT_FSM_BODY4: packet_state_n = message_channel_router_ready ? PKT_FSM_BODY5 : PKT_FSM_BODY4;
    age_pkg::PKT_FSM_BODY5: packet_state_n = message_channel_router_ready ? PKT_FSM_BODY6 : PKT_FSM_BODY5;
    age_pkg::PKT_FSM_BODY6: packet_state_n = message_channel_router_ready ? PKT_FSM_TAIL : PKT_FSM_BODY6;
    age_pkg::PKT_FSM_TAIL: packet_state_n  = message_channel_router_ready ? PKT_FSM_IDLE : PKT_FSM_TAIL;

    default: packet_state_n = PKT_FSM_IDLE;

    endcase
end

// Build network packet
always_comb begin
    message_channel_router_valid = (packet_state != PKT_FSM_IDLE);
    
    message_channel_router_data.flit_label = (packet_state == PKT_FSM_HEAD) ? noc_params::HEAD
                                            : (packet_state == PKT_FSM_TAIL) ? noc_params::TAIL
                                            : noc_params::BODY;
    message_channel_router_data.vc_id = '0; // TO DO: consider using both VCs?
    
    message_channel_router_data.data.head_data.x_dest  = coords_buffer_x[coord_ptr];
    message_channel_router_data.data.head_data.y_dest  = coords_buffer_y[coord_ptr];

    message_channel_router_data.data.head_data.head_pl = (packet_state == PKT_FSM_HEAD)   ? message_channel_resp_q.data[63:0]
                                        : (packet_state == PKT_FSM_BODY1) ? message_channel_resp_q.data[127:64]
                                        : (packet_state == PKT_FSM_BODY2) ? message_channel_resp_q.data[191:128]
                                        : (packet_state == PKT_FSM_BODY3) ? message_channel_resp_q.data[255:192]
                                        : (packet_state == PKT_FSM_BODY4) ? message_channel_resp_q.data[319:256]
                                        : (packet_state == PKT_FSM_BODY5) ? message_channel_resp_q.data[383:320]
                                        : (packet_state == PKT_FSM_BODY6) ? message_channel_resp_q.data[447:384]
                                        : message_channel_resp_q.data[511:448];

    // Drop all packets from network into MC
    router_message_channel_on    = '1;
    router_message_channel_ready = '1;
end

// Circular buffer for aggregation core coordinates
// -----------------------------------------------

always_ff @(posedge core_clk or negedge resetn) begin
    if (!resetn) begin
        coords_buffer_x    <= '0;
        coords_buffer_y    <= '0;
        coord_ptr          <= '0;

    // Accepting NSB request
    end else if (nsb_age_mc_req_valid && nsb_age_mc_req_ready) begin
        coords_buffer_x      <= nsb_age_mc_req.coords_x;
        coords_buffer_y      <= nsb_age_mc_req.coords_y;
        coord_ptr          <= '0;
    
    // Sending final flit into network: increment pointer or bring back to 0 if done sending to all ACs
    end else if (pkt_done) begin
        coord_ptr          <= (coord_ptr == nsb_req_ac_count_q) ? '0 : (coord_ptr + 1);
    end

end

// ==================================================================================================================================================
// Assertions
// ==================================================================================================================================================

endmodule