import noc_pkg::*;

module port #(
    parameter PORT_TYPE = "LOCAL",
    parameter ROUTER_X = 0,
    parameter ROUTER_Y = 0,
    parameter NUM_INPUT_PORTS = 2,
    parameter BUFFER_SIZE = 8
) (
    input  logic core_clk,
    input  logic resetn,

    input  logic  external_in_valid,
    output logic  external_in_ready,
    input flit_t  external_in_data,
    
    output logic  external_out_valid,
    input  logic  external_out_ready,
    output flit_t external_out_data,

    input  logic  internal_in_0_valid,
    output logic  internal_in_0_ready,
    input flit_t  internal_in_0_data,
    
    input  logic  internal_in_1_valid,
    output logic  internal_in_1_ready,
    input flit_t  internal_in_1_data,

    output logic  internal_out_valid,
    input  logic [NUM_INPUT_PORTS-1:0] internal_out_ready,
    output flit_t internal_out_data
);

typedef enum logic [0:0] {
    IDLE,
    TRANSFER_PACKET
} port_fsm_e;

// ================================================
// Declarations
// ================================================

port_fsm_e port_state, port_state_n;

logic [0:0] granted_input;
logic [0:0] granted_input_q;

logic [NUM_INPUT_PORTS-1:0] internal_input_valid;
flit_t [NUM_INPUT_PORTS-1:0] internal_input;

logic port_buffer_full;
logic [$bits(noc_pkg::flit_t)-1:0] port_buffer_out;

// ================================================
// Instances
// ================================================

ultraram_fifo #(
    .WIDTH ($bits(noc_pkg::flit_t)),
    .DEPTH (BUFFER_SIZE)
) port_buffer_i (
    .core_clk,
    .resetn,

    .push      (external_in_valid && external_in_ready),
    .in_data   (external_in_data),
    
    .pop       (internal_out_valid && |internal_out_ready),
    .out_valid (internal_out_valid),
    .out_data  (port_buffer_out),

    .reset_read_ptr ('0),
    .count     (),
    .empty     (),
    .full      (port_buffer_full)
);

assign internal_out_data = noc_pkg::flit_t(port_buffer_out);

register_staller_simple #(
    .DATA_WIDTH ($bits(noc_pkg::flit_t))
) rstl_i (
    .core_clk,
    .resetn,

    .in_valid   (|internal_input_valid),
    .in_data    (),
    .in_ready   (),

    .out_valid  (),
    .out_data   (),
    .out_ready  ()
);

// ================================================
// Logic
// ================================================

always_ff @(posedge core_clk or negedge resetn) begin
    if (!resetn) begin
        port_state <= IDLE;
        granted_input_q <= '1;
    end else begin
        port_state <= port_state_n;

        if (port_state == IDLE && port_state_n == TRANSFER_PACKET) begin
            granted_input_q <= !granted_input;
        end
    end
end

// Internal connections
// --------------------------------------------

always_comb begin
    port_state_n = port_state;
    
    // TO DO: change to round-robin
    // Currently grant to input 1 only if input 0 not requesting
    granted_input = internal_input_valid[1] && !internal_input_valid[0];

    case (post_state)

        IDLE: begin
            port_state_n = |internal_input_valid && (internal_input[granted_input].flit_label == noc_pkg::HEAD) ? TRANSFER_PACKET
                            : IDLE;
        end

        TRANSFER_PACKET: begin
            port_state_n = internal_input_valid[granted_input_q] && (internal_input[granted_input].flit_label == noc_pkg::TAIL) ? IDLE
                            : TRANSFER_PACKET;
        end

    endcase
end

// Decode where incoming packet should go
// --------------------------------------------

if (PORT_TYPE == "LOCAL") begin
    assign internal_input_valid = {
        internal_in_0_valid && (internal_in_0_data.head_data.x_dest == ROUTER_X),
        internal_in_1_valid && (internal_in_1_data.head_data.x_dest == ROUTER_X)
    };
end

else if (PORT_TYPE == "WEST") begin
    assign internal_input_valid = {
        internal_in_0_valid && (internal_in_0_data.head_data.x_dest < ROUTER_X),
        internal_in_1_valid && (internal_in_1_data.head_data.x_dest < ROUTER_X)
    };
end

else if (PORT_TYPE == "EAST") begin
    assign internal_input_valid = {
        internal_in_0_valid && (internal_in_0_data.head_data.x_dest > ROUTER_X),
        internal_in_1_valid && (internal_in_1_data.head_data.x_dest > ROUTER_X)
    };
end

else begin
    assign internal_input_valid = '0;
end
    
// For readability
assign internal_input = {internal_in_0_data, internal_in_1_data};

// Interface
// --------------------------------------------

always_comb begin
    external_in_ready = !port_buffer_full;
    
    internal_in_0_ready = 
    internal_in_1_ready = 
end

endmodule