import top_pkg::*;
import age_pkg::*;
import noc_params::*;

module aggregation_manager #(
    parameter X_COORD = 0,
    parameter Y_COORD = 0
) (
    input logic                                                 core_clk,
    input logic                                                 resetn,

    // AGE requests
    input  logic                                                age_aggregation_manager_req_valid,
    output logic                                                age_aggregation_manager_req_ready,
    input  AGE_AGM_REQ_t                                        age_aggregation_manager_req,

    // Done signals to pulse NSB response
    output logic                                                aggregation_manager_age_done_valid,
    input  logic                                                aggregation_manager_age_done_ready,

    // Buffer Manager Allocation
    input  logic                                                age_aggregation_manager_buffer_manager_allocation_valid,
    output logic                                                age_aggregation_manager_buffer_manager_allocation_ready,
    input  logic [$clog2(TOTAL_BUFFER_MANAGERS)-1:0]            age_aggregation_manager_buffer_manager_allocation,

    // Message Channel: AGE -> Prefetcher (request)
    output logic                                                message_channel_req_valid,
    input  logic                                                message_channel_req_ready,
    output MESSAGE_CHANNEL_REQ_t                                message_channel_req,
    
    // Message Channel: Prefetcher -> AGE (response)
    input  logic                                                message_channel_resp_valid,
    output logic                                                message_channel_resp_ready,
    input  MESSAGE_CHANNEL_RESP_t                               message_channel_resp,

    // Aggregation Manager -> Router
    input  logic                                                aggregation_manager_router_on,
    output logic                                                aggregation_manager_router_valid,
    input  logic                                                aggregation_manager_router_ready,
    output flit_t                                               aggregation_manager_router_data,

    // Router -> Aggregation Manager
    output logic                                                router_aggregation_manager_on,
    input  logic                                                router_aggregation_manager_valid,
    output logic                                                router_aggregation_manager_ready,
    input  flit_t                                               router_aggregation_manager_data,

    // Output AGM allocation payloads for AGE visibility
    output NSB_AGE_REQ_t                                        agm_allocation,
    output logic [AGC_COUNT_FLOAT32-1:0]                        agm_allocated_agcs,
    output logic [$clog2(MAX_AGC_PER_NODE)-1:0]                 agm_allocated_agcs_count,
    output logic [MAX_AGC_PER_NODE-1:0] [$clog2(MESH_COLS)-1:0] coords_buffer_x,
    output logic [MAX_AGC_PER_NODE-1:0] [$clog2(MESH_ROWS)-1:0] coords_buffer_y,

    output logic                                                scale_factor_queue_pop,
    input  logic [SCALE_FACTOR_QUEUE_READ_WIDTH-1:0]            scale_factor_queue_out_data,
    input  logic [$clog2(SCALE_FACTOR_QUEUE_READ_DEPTH):0]      scale_factor_queue_count,
    input  logic                                                scale_factor_queue_empty,
    input  logic                                                scale_factor_queue_full
);

typedef enum logic [4:0] {
    AGM_FSM_IDLE,
    AGM_FSM_AGC_ALLOC_PKT,
    AGM_FSM_WAIT_DRAIN1,
    AGM_FSM_PREF_REQ,
    AGM_FSM_WAIT_PREF_RESP,
    AGM_FSM_SEND_AGC,
    AGM_FSM_WAIT_DRAIN2,
    AGM_FSM_WAIT_BUFF_MAN_ALLOC,
    AGM_FSM_AGC_BUFFER_REQ,
    AGM_FSM_WAIT_DRAIN3,
    AGM_FSM_WAIT_BUFFER_DONE,
    AGM_FSM_NSB_RESP
} agm_state_e;

// ==================================================================================================================================================
// Declarations
// ==================================================================================================================================================

// Coordinates of this aggregation manager
logic [$clog2(MESH_COLS)-1:0]                       x_coord;
logic [$clog2(MESH_ROWS)-1:0]                       y_coord;

// Circular buffer for coordinates of the allocated aggregation cores
logic [$clog2(MAX_AGC_PER_NODE)-1:0] coord_ptr;

agm_state_e                                         agm_state, agm_state_n;
axi_packet_fsm_e                                    packet_state, packet_state_n;
logic                                               pkt_done;
logic                                               agc_pkt_head_sent;

MESSAGE_CHANNEL_RESP_t                              message_channel_resp_q; // buffer MC response to send flits to network

logic [$clog2(TOTAL_BUFFER_MANAGERS)-1:0]           buffer_manager_allocation_q;

// Decode incoming packet source
logic [$clog2(MESH_ROWS)-1:0]                       packet_source_row;
logic [$clog2(MESH_COLS)-1:0]                       packet_source_col;

logic                                               noc_router_waiting;

// ==================================================================================================================================================
// Logic
// ==================================================================================================================================================

// Coordinates of this aggregation manager
assign x_coord = X_COORD;
assign y_coord = Y_COORD;

// Message channel state machine
// --------------------------------------------

always_ff @(posedge core_clk or negedge resetn) begin
    if (!resetn) begin
        agm_state <= AGM_FSM_IDLE;
    end else begin
        agm_state <= agm_state_n;
    end
end

always_comb begin
    agm_state_n = agm_state;

    case(agm_state)

    AGM_FSM_IDLE: begin
        agm_state_n = age_aggregation_manager_req_valid ? AGM_FSM_AGC_ALLOC_PKT
                    : AGM_FSM_IDLE;
    end

    AGM_FSM_AGC_ALLOC_PKT: begin
        agm_state_n = (aggregation_manager_router_data.flit_label == noc_params::TAIL) && (coord_ptr == agm_allocated_agcs_count - 1'b1) ? AGM_FSM_WAIT_DRAIN1
                    : AGM_FSM_AGC_ALLOC_PKT;
    end

    AGM_FSM_WAIT_DRAIN1: begin
        agm_state_n = noc_router_waiting ? AGM_FSM_PREF_REQ : AGM_FSM_WAIT_DRAIN1;
    end

    AGM_FSM_PREF_REQ: begin
        agm_state_n = message_channel_req_ready ? AGM_FSM_WAIT_PREF_RESP
                    : AGM_FSM_PREF_REQ;
    end

    AGM_FSM_WAIT_PREF_RESP: begin
        agm_state_n = message_channel_resp_valid ? AGM_FSM_SEND_AGC
                    : AGM_FSM_WAIT_PREF_RESP;
    end

    AGM_FSM_SEND_AGC: begin
        agm_state_n = pkt_done && message_channel_resp_q.last_feature ? AGM_FSM_WAIT_DRAIN2
                    : pkt_done ? AGM_FSM_WAIT_PREF_RESP
                    : AGM_FSM_SEND_AGC;
    end

    AGM_FSM_WAIT_DRAIN2: begin
        agm_state_n = noc_router_waiting ? AGM_FSM_WAIT_BUFF_MAN_ALLOC : AGM_FSM_WAIT_DRAIN2;
    end

    AGM_FSM_WAIT_BUFF_MAN_ALLOC: begin
        agm_state_n = age_aggregation_manager_buffer_manager_allocation_valid ? AGM_FSM_AGC_BUFFER_REQ : AGM_FSM_WAIT_BUFF_MAN_ALLOC;
    end

    AGM_FSM_AGC_BUFFER_REQ: begin
        agm_state_n = (coord_ptr == agm_allocated_agcs_count - 1'b1) && agc_pkt_head_sent ? AGM_FSM_WAIT_DRAIN3
                    : AGM_FSM_AGC_BUFFER_REQ;
    end

    AGM_FSM_WAIT_DRAIN3: begin
        agm_state_n = noc_router_waiting ? AGM_FSM_WAIT_BUFFER_DONE : AGM_FSM_WAIT_DRAIN3;
    end

    AGM_FSM_WAIT_BUFFER_DONE: begin
        agm_state_n = router_aggregation_manager_valid && (packet_source_col == age_pkg::MESH_COLS - 1) && (packet_source_row == buffer_manager_allocation_q) ? AGM_FSM_NSB_RESP
                    : AGM_FSM_WAIT_BUFFER_DONE;
    end

    AGM_FSM_NSB_RESP: begin
        agm_state_n = aggregation_manager_age_done_ready ? AGM_FSM_IDLE
                    : AGM_FSM_NSB_RESP;
    end

    default: agm_state_n = AGM_FSM_IDLE;

    endcase
end

// NSB REQ/RESP interface
// --------------------------------------------

// Buffer NSB request payloads
always_ff @(posedge core_clk or negedge resetn) begin
    if (!resetn) begin
        agm_allocation.nodeslot               <= '0;
        agm_allocation.fetch_tag              <= '0;
        agm_allocation.node_precision         <= top_pkg::FLOAT_32;
        agm_allocation.aggregation_function   <= top_pkg::SUM;
        
        agm_allocated_agcs               <= '0;
        agm_allocated_agcs_count         <= '0;
        

    end else if (age_aggregation_manager_req_valid && age_aggregation_manager_req_ready) begin
        agm_allocation.nodeslot             <= age_aggregation_manager_req.nsb_req.nodeslot;
        agm_allocation.fetch_tag            <= age_aggregation_manager_req.nsb_req.fetch_tag;
        agm_allocation.node_precision       <= age_aggregation_manager_req.nsb_req.node_precision;
        agm_allocation.aggregation_function <= age_aggregation_manager_req.nsb_req.aggregation_function;
        agm_allocated_agcs_count            <= age_aggregation_manager_req.required_agcs;
        agm_allocated_agcs                  <= age_aggregation_manager_req.allocated_cores;
    end
end

always_comb begin
    age_aggregation_manager_req_ready = (agm_state == AGM_FSM_IDLE) && (packet_state == PKT_FSM_IDLE);

    aggregation_manager_age_done_valid = (agm_state == AGM_FSM_NSB_RESP);
end

// Message channel REQ/RESP interface
// --------------------------------------------

always_comb begin
    message_channel_req_valid     = (agm_state == AGM_FSM_PREF_REQ);
    message_channel_req.nodeslot  = agm_allocation.nodeslot;
    message_channel_req.fetch_tag = agm_allocation.fetch_tag;
    message_channel_resp_ready    = (agm_state == AGM_FSM_WAIT_PREF_RESP);
end

always_ff @(posedge core_clk or negedge resetn) begin
    if (!resetn) begin
        message_channel_resp_q <= '0;
    
    end else if ((agm_state == AGM_FSM_WAIT_PREF_RESP) && message_channel_resp_valid) begin
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
    pkt_done = (packet_state == PKT_FSM_TAIL);
    packet_state_n = packet_state;

    case(packet_state)

    age_pkg::PKT_FSM_IDLE: packet_state_n  = (aggregation_manager_router_on && (agm_state == AGM_FSM_SEND_AGC) && noc_router_waiting) ? PKT_FSM_HEAD : PKT_FSM_IDLE;
    age_pkg::PKT_FSM_HEAD: packet_state_n  = PKT_FSM_BODY1;
    age_pkg::PKT_FSM_BODY1: packet_state_n = PKT_FSM_BODY2;
    age_pkg::PKT_FSM_BODY2: packet_state_n = PKT_FSM_BODY3;
    age_pkg::PKT_FSM_BODY3: packet_state_n = PKT_FSM_BODY4;
    age_pkg::PKT_FSM_BODY4: packet_state_n = PKT_FSM_BODY5;
    age_pkg::PKT_FSM_BODY5: packet_state_n = PKT_FSM_BODY6;
    age_pkg::PKT_FSM_BODY6: packet_state_n = PKT_FSM_BODY7;
    age_pkg::PKT_FSM_BODY7: packet_state_n = PKT_FSM_TAIL;
    age_pkg::PKT_FSM_TAIL: packet_state_n  = PKT_FSM_IDLE;

    default: packet_state_n = PKT_FSM_IDLE;

    endcase
end

// Router allocatable flag
always_ff @(posedge core_clk or negedge resetn) begin
    if (!resetn) begin
        noc_router_waiting <= '1;

    // Assert flag when router pulses allocatable
    end else if (aggregation_manager_router_ready) begin
        noc_router_waiting <= '1;

    // Drop when sending the tail packet and wait for router to be allocatable again        
    end else if (aggregation_manager_router_valid && (aggregation_manager_router_data.flit_label == noc_params::TAIL)) begin
        noc_router_waiting <= '0;
    end
end

// Build network packet
// --------------------------------------------

always_comb begin
    // Sending allocation or feature packet
    aggregation_manager_router_valid = (packet_state != PKT_FSM_IDLE) || (agm_state == AGM_FSM_AGC_ALLOC_PKT) || (agm_state == AGM_FSM_AGC_BUFFER_REQ);
    
    aggregation_manager_router_data.vc_id = '0; // TO DO: consider using both VCs?

    // Nodeslot allocation packet
    if (agm_state == AGM_FSM_AGC_ALLOC_PKT) begin
        aggregation_manager_router_data.flit_label = agc_pkt_head_sent ? noc_params::TAIL : noc_params::HEAD;

        aggregation_manager_router_data.data.bt_pl = 
                                            // Tail packet contains aggregation function and nodeslot
                                            agc_pkt_head_sent ? {coords_buffer_x[coord_ptr], coords_buffer_y[coord_ptr],
                                                                        x_coord, y_coord, // source node coordinates
                                                                        {(PAYLOAD_DATA_WIDTH - $bits(AGGREGATION_FUNCTION_e) - $bits(agm_allocation.nodeslot)){1'b0}}, // 56 zeros
                                                                        agm_allocation.aggregation_function, agm_allocation.nodeslot
                                                                    }
                                            
                                            // Head packet contains packet type and last flag (always set to 1 for allocation packets)
                                            : {coords_buffer_x[coord_ptr], coords_buffer_y[coord_ptr],
                                                x_coord, y_coord,
                                                age_pkg::AGC_NODESLOT_ALLOCATION, 1'b1, 
                                                {(PAYLOAD_DATA_WIDTH - $bits(aggregation_manager_packet_type_e) - 1){1'b0}}
                                            };

    // Feature packet to AGCs
    end else if (agm_state == AGM_FSM_SEND_AGC) begin
        aggregation_manager_router_data.flit_label = (packet_state == PKT_FSM_HEAD) ? noc_params::HEAD
                                                : (packet_state == PKT_FSM_TAIL) ? noc_params::TAIL
                                                : noc_params::BODY;
        
        aggregation_manager_router_data.data.bt_pl = 
                                            // Head packet contains packet type and last flag (always set to 1 for allocation packets)
                                            (packet_state == PKT_FSM_HEAD)   ? {coords_buffer_x[coord_ptr], coords_buffer_y[coord_ptr], // destination node coordinates
                                                                                    x_coord, y_coord, // source node coordinates

                                                                                    age_pkg::AGC_FEATURE_PACKET, message_channel_resp_q.last_neighbour,
                                                                                    {(PAYLOAD_DATA_WIDTH - $bits(aggregation_manager_packet_type_e) - 1 - SCALE_FACTOR_QUEUE_READ_WIDTH){1'b0}},
                                                                                    scale_factor_queue_out_data
                                                                                }

                                            // Subsequent packets contain message channel response split into 64-bit chunks
                                            : (packet_state == PKT_FSM_BODY1) ? {coords_buffer_x[coord_ptr], coords_buffer_y[coord_ptr], x_coord, y_coord, message_channel_resp_q.data[511:448]}
                                            : (packet_state == PKT_FSM_BODY2) ? {coords_buffer_x[coord_ptr], coords_buffer_y[coord_ptr], x_coord, y_coord, message_channel_resp_q.data[447:384]}
                                            : (packet_state == PKT_FSM_BODY3) ? {coords_buffer_x[coord_ptr], coords_buffer_y[coord_ptr], x_coord, y_coord, message_channel_resp_q.data[383:320]}
                                            : (packet_state == PKT_FSM_BODY4) ? {coords_buffer_x[coord_ptr], coords_buffer_y[coord_ptr], x_coord, y_coord, message_channel_resp_q.data[319:256]}
                                            : (packet_state == PKT_FSM_BODY5) ? {coords_buffer_x[coord_ptr], coords_buffer_y[coord_ptr], x_coord, y_coord, message_channel_resp_q.data[255:192]}
                                            : (packet_state == PKT_FSM_BODY6) ? {coords_buffer_x[coord_ptr], coords_buffer_y[coord_ptr], x_coord, y_coord, message_channel_resp_q.data[191:128]}
                                            : (packet_state == PKT_FSM_BODY7) ? {coords_buffer_x[coord_ptr], coords_buffer_y[coord_ptr], x_coord, y_coord, message_channel_resp_q.data[127:64]}
                                            : (packet_state == PKT_FSM_TAIL) ?  {coords_buffer_x[coord_ptr], coords_buffer_y[coord_ptr], x_coord, y_coord, message_channel_resp_q.data[63:0]} : '0;
    
    // Buffer request packets to AGCs
    end else if (agm_state == AGM_FSM_AGC_BUFFER_REQ) begin
        aggregation_manager_router_data.flit_label = agc_pkt_head_sent ? noc_params::TAIL : noc_params::HEAD;

        aggregation_manager_router_data.data.bt_pl = // Tail packet contains allocated buffer manager coordinates
                                            agc_pkt_head_sent ? {coords_buffer_x[coord_ptr], coords_buffer_y[coord_ptr],
                                                                        x_coord, y_coord, // source node coordinates

                                                                        {(PAYLOAD_DATA_WIDTH - $bits(buffer_manager_allocation_q)){1'b0}}, // 56 zeros
                                                                        buffer_manager_allocation_q
                                                                    }
                                            
                                            // Head packet contains packet type and last flag (always set to 1 for buffer req packets)
                                            : {coords_buffer_x[coord_ptr], coords_buffer_y[coord_ptr],
                                                x_coord, y_coord,

                                                age_pkg::BM_BUFFER_REQUEST, 1'b1,
                                                {(PAYLOAD_DATA_WIDTH - $bits(aggregation_manager_packet_type_e) - 1){1'b0}}
                                            };

    // Not sending anything
    end else begin
        aggregation_manager_router_data.flit_label = noc_params::HEAD; // i.e. '0
        aggregation_manager_router_data.data.bt_pl = '0;
    end

    router_aggregation_manager_on    = (agm_state == AGM_FSM_WAIT_BUFFER_DONE);
    router_aggregation_manager_ready = (agm_state == AGM_FSM_WAIT_BUFFER_DONE);
end

// Circular buffer for aggregation core coordinates
// -----------------------------------------------

always_ff @(posedge core_clk or negedge resetn) begin
    if (!resetn) begin
        coords_buffer_x    <= '0;
        coords_buffer_y    <= '0;
        coord_ptr          <= '0;
        
        agc_pkt_head_sent <= '0;

    // Accepting NSB request
    end else if (age_aggregation_manager_req_valid && age_aggregation_manager_req_ready) begin
        coords_buffer_x      <= age_aggregation_manager_req.coords_x;
        coords_buffer_y      <= age_aggregation_manager_req.coords_y;
        coord_ptr            <= '0;
        
        agc_pkt_head_sent <= '0;

    // Sending final flit into network
    end else if (aggregation_manager_router_valid) begin // add && aggregation_manager_router_ready
        
        // Update buffer pointer if sending tail beat for feature packet or allocation packet
        if (((agm_state == AGM_FSM_SEND_AGC) && (packet_state == PKT_FSM_TAIL)) || ((agm_state == AGM_FSM_AGC_ALLOC_PKT) && agc_pkt_head_sent) || ((agm_state == AGM_FSM_AGC_BUFFER_REQ) && agc_pkt_head_sent)) begin
            // Bring back to 0 if full otherwise increment
            coord_ptr          <= (coord_ptr == agm_allocated_agcs_count - 1'b1) ? '0 : (coord_ptr + 1);
        end

        // Raise flag when sending a head flit, drop when sending tail
        if (noc_router_waiting && ((agm_state == AGM_FSM_AGC_ALLOC_PKT) || (agm_state == AGM_FSM_AGC_BUFFER_REQ))) begin
            agc_pkt_head_sent <= (aggregation_manager_router_data.flit_label == noc_params::HEAD) ? '1
                                    : (aggregation_manager_router_data.flit_label == noc_params::TAIL) ? '0
                                    : agc_pkt_head_sent; // latch
        end
    end
end

// Pop the scale factor queue when sending the last feature to the last AGC
assign scale_factor_queue_pop = (agm_state == AGM_FSM_SEND_AGC) && aggregation_manager_router_valid && (packet_state == PKT_FSM_TAIL) && (coord_ptr == agm_allocated_agcs_count - 1'b1);

// AGC buffering requests
// -----------------------------------------------

assign age_aggregation_manager_buffer_manager_allocation_ready = (agm_state == AGM_FSM_WAIT_BUFF_MAN_ALLOC);

always_ff @( posedge core_clk or negedge resetn ) begin
    if (!resetn) begin
        buffer_manager_allocation_q <= '0;

    // Receiving buffer manager allocation
    end else if ((agm_state == AGM_FSM_WAIT_BUFF_MAN_ALLOC) && age_aggregation_manager_buffer_manager_allocation_valid) begin
        buffer_manager_allocation_q <= age_aggregation_manager_buffer_manager_allocation;
    end
end

// Decode incoming network packets
assign {packet_source_col, packet_source_row} = age_pkg::decode_packet_source(router_aggregation_manager_data);

// ==================================================================================================================================================
// Assertions
// ==================================================================================================================================================

endmodule