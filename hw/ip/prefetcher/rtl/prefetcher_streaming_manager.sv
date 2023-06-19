import top_pkg::*;

`define min(a,b) ((a > b) ? b : a)
`define divide_round_up(a,b) (a - 1)/b + 1

module prefetcher_streaming_manager #(
    parameter NSB_PREF_OPCODE_e FETCH_TYPE = top_pkg::ADJACENCY_LIST,

    parameter QUEUE_WIDTH = 512,
    parameter QUEUE_DEPTH = 64,

    parameter MAX_OBJECTS = top_pkg::MAX_NEIGHBOURS,
    
    parameter STREAMING_ENABLED = 1,
    parameter UNPACKING_ENABLED = 1
) (

    input  logic core_clk,
    input  logic resetn,

    output logic free,

    // REQ/RESP interface
    input  logic                                        fetch_req_valid,
    output logic                                        fetch_req_ready,
    input  NSB_PREF_OPCODE_e                            fetch_req_opcode,
    input  logic [AXI_ADDRESS_WIDTH-1:0]                fetch_req_start_address,
    input  logic [$clog2(MAX_OBJECTS)-1:0]              fetch_req_obj_count,

    output logic                                        fetch_resp_valid,
    input  logic                                        fetch_resp_ready,
    output logic                                        fetch_resp_partial,

    input  logic [AXI_ADDRESS_WIDTH-1:0]                fetch_memory_range_start_address,

    // Read Master request interface
    output logic                                        read_master_req_valid,
    input  logic                                        read_master_req_ready,
    output logic [AXI_ADDRESS_WIDTH-1:0]                read_master_start_address,
    output logic [$clog2(MAX_FETCH_REQ_BYTE_COUNT)-1:0] read_master_byte_count,

    // Read Master response interface
    input  logic                                        read_master_resp_valid,
    output logic                                        read_master_resp_ready,
    input  logic                                        read_master_resp_last,
    input  logic [AXI_DATA_WIDTH-1:0]                   read_master_resp_data,
    input  logic [3:0]                                  read_master_resp_axi_id,

    // Queue interface
    output logic                                        push_queue,
    output logic [QUEUE_WIDTH-1:0]                      push_data,
    input  logic [$clog2(QUEUE_DEPTH):0]                queue_slots_available,
    input  logic                                        queue_empty,
    input  logic                                        queue_full
);

typedef enum logic [2:0] {
    FETCH_IDLE,
    FETCH_RM_REQ,
    FETCH_WAIT_RESP,
    FETCH_STORE,
    FETCH_PAUSE,
    FETCH_DONE
} STREAMING_FETCH_FSM_e;

// ==================================================================================================================================================
// Declarations
// ==================================================================================================================================================

STREAMING_FETCH_FSM_e fetch_state, fetch_state_n;

logic accepting_fetch_req;
logic accepting_rm_req, accepting_rm_resp;

logic [AXI_ADDRESS_WIDTH-1:0]                                    fetch_req_address_offset; // address pointer (updated in each fetch)
logic [$clog2(top_pkg::MAX_REQUIRED_BYTES_FETCH_REQ)-1:0] fetch_req_bytes; // bytes in current request
logic [$clog2(top_pkg::MAX_NEIGHBOURS)-1:0]                      fetch_obj_remaining;
logic [$clog2(prefetcher_pkg::MAX_FETCH_RESPONSES)-1:0]   fetch_responses_pending;
logic [$clog2(AXI_DATA_WIDTH)-1:0]                               buffered_fetch_resp_offset;

logic                                                            issue_partial_done;
logic                                                            issue_partial_done_q;
logic                                                            trigger_partial_resp;

// Store logic
logic [$clog2(top_pkg::MAX_NEIGHBOURS)-1:0]                      obj_remaining_store;
logic [AXI_DATA_WIDTH-1:0]                                       rm_resp_data_q;

// ==================================================================================================================================================
// Logic
// ==================================================================================================================================================

always_comb begin
    accepting_fetch_req = fetch_req_valid && fetch_req_ready;
    accepting_rm_req = read_master_req_valid && read_master_req_ready;
    accepting_rm_resp = read_master_resp_valid && read_master_resp_ready;
end

// State machine
// ----------------------------------------------------

always_ff @(posedge core_clk or negedge resetn) begin
    if (!resetn) begin
        fetch_state <= FETCH_IDLE;
    end else begin
        fetch_state <= fetch_state_n;
    end
end

always_comb begin
    fetch_state_n = fetch_state;

    case (fetch_state)

    FETCH_IDLE: begin
        fetch_state_n = accepting_fetch_req && (fetch_req_opcode == FETCH_TYPE) && queue_empty ? FETCH_RM_REQ : FETCH_IDLE;
    end

    FETCH_RM_REQ: begin
        fetch_state_n = accepting_rm_req ? FETCH_WAIT_RESP : FETCH_RM_REQ;
    end

    FETCH_WAIT_RESP: begin
        fetch_state_n = accepting_rm_resp ? FETCH_STORE : FETCH_WAIT_RESP;
    end

    FETCH_STORE: begin
        fetch_state_n = 
                        // Done storing all objects
                        (obj_remaining_store == '0) ? FETCH_DONE

                        // Saturated queue while storing current read master response
                        : queue_full ? FETCH_PAUSE

                        // Done unpacking current response but more responses pending
                        : |fetch_responses_pending && buffered_fetch_resp_offset == 'd15 ? FETCH_WAIT_RESP


                        : (fetch_responses_pending == '0) && |fetch_obj_remaining ? FETCH_RM_REQ
                        : FETCH_STORE;
    end

    FETCH_PAUSE: begin
        fetch_state_n = |obj_remaining_store && !queue_full ? FETCH_RM_REQ
                        : (obj_remaining_store == '0) ? FETCH_IDLE // defensive
                        : FETCH_PAUSE;
    end

    FETCH_DONE: begin
        fetch_state_n = fetch_resp_ready ? FETCH_IDLE
                        : FETCH_DONE;
    end

    endcase
end

assign fetch_req_ready = (fetch_state == FETCH_IDLE) && fetch_req_opcode == FETCH_TYPE;
assign free = (fetch_state == FETCH_IDLE);

// Fetch counters
// ----------------------------------------------------

always_ff @(posedge core_clk or negedge resetn) begin
    if (!resetn) begin
        fetch_req_address_offset       <= '0;
        fetch_obj_remaining     <= '0;
        fetch_responses_pending <= '0;
        
        rm_resp_data_q <= '0;
        
        issue_partial_done    <= '0;
        issue_partial_done_q  <= '0;

        obj_remaining_store <= '0;
        buffered_fetch_resp_offset       <= '0;
    
    end else begin
        // Accepting fetch request
        if ((fetch_state == FETCH_IDLE) && accepting_fetch_req && (fetch_req_opcode == FETCH_TYPE) ) begin 
            fetch_req_address_offset    <= fetch_req_start_address;
            fetch_obj_remaining         <= fetch_req_obj_count;
            issue_partial_done          <= '0;
            fetch_responses_pending     <= '0;

            obj_remaining_store         <= fetch_req_obj_count;
            buffered_fetch_resp_offset  <= '0;
        
        // Accepting read master request
        end else if (accepting_rm_req) begin
            fetch_req_address_offset <= fetch_req_address_offset + fetch_req_bytes;
            fetch_obj_remaining      <= fetch_obj_remaining - `min(fetch_obj_remaining, queue_slots_available);
            fetch_responses_pending  <= `divide_round_up(fetch_req_bytes, 64); // 64 bytes per response beat

        // Accepting read master response
        end else if (accepting_rm_resp) begin
            fetch_responses_pending    <= fetch_responses_pending - 1'b1;
            rm_resp_data_q             <= read_master_resp_data;
            buffered_fetch_resp_offset <= '0;

        // Storing beat into queue
        end else if (fetch_state == FETCH_STORE) begin

            if (push_queue) begin
                buffered_fetch_resp_offset <= buffered_fetch_resp_offset + 1'b1;
                obj_remaining_store <= obj_remaining_store - 1'b1;
            end

            if (fetch_state_n == FETCH_PAUSE) begin
                // Raise partial done resp flag. This latches at 1 until new request is received, so that
                // the response is only sent the first time the queue gets full
                issue_partial_done <= '1;
            end
        end

        issue_partial_done_q <= issue_partial_done;
    end
end

// Read master logic
always_comb begin
    fetch_req_bytes            = `min(fetch_obj_remaining, queue_slots_available) * 4;

    read_master_req_valid      = (fetch_state == FETCH_RM_REQ);
    read_master_start_address  = fetch_memory_range_start_address + fetch_req_address_offset;
    read_master_byte_count     = fetch_req_bytes;

    // Response
    read_master_resp_ready     = (fetch_state == FETCH_WAIT_RESP);
end

// Adjacency queue store logic
// ----------------------------------------------------

assign push_queue = (fetch_state == FETCH_STORE) && !queue_full && |obj_remaining_store;

// TO DO: cannot address register by non-constant expression like below:
// push_data = rm_resp_data_q [buffered_fetch_resp_offset + 9'd31 : buffered_fetch_resp_offset];

if (UNPACKING_ENABLED) begin
    assign push_data = (buffered_fetch_resp_offset == 'd0)  ? rm_resp_data_q [511:480]
                    : (buffered_fetch_resp_offset == 'd1)  ? rm_resp_data_q [479:448]
                    : (buffered_fetch_resp_offset == 'd2)  ? rm_resp_data_q [447:416]
                    : (buffered_fetch_resp_offset == 'd3)  ? rm_resp_data_q [415:384]
                    : (buffered_fetch_resp_offset == 'd4)  ? rm_resp_data_q [383:352]
                    : (buffered_fetch_resp_offset == 'd5)  ? rm_resp_data_q [351:320]
                    : (buffered_fetch_resp_offset == 'd6)  ? rm_resp_data_q [319:288]
                    : (buffered_fetch_resp_offset == 'd7)  ? rm_resp_data_q [287:256]
                    : (buffered_fetch_resp_offset == 'd8)  ? rm_resp_data_q [255:224]
                    : (buffered_fetch_resp_offset == 'd9)  ? rm_resp_data_q [223:192]
                    : (buffered_fetch_resp_offset == 'd10) ? rm_resp_data_q [191:160]
                    : (buffered_fetch_resp_offset == 'd11) ? rm_resp_data_q [159:128]
                    : (buffered_fetch_resp_offset == 'd12) ? rm_resp_data_q [127:96]
                    : (buffered_fetch_resp_offset == 'd13) ? rm_resp_data_q [95:64]
                    : (buffered_fetch_resp_offset == 'd14) ? rm_resp_data_q [63:32]
                    : (buffered_fetch_resp_offset == 'd15) ? rm_resp_data_q [31:0]
                    : '0;
end else begin
    assign push_data = rm_resp_data_q;
end

always_comb begin
    trigger_partial_resp = issue_partial_done && !issue_partial_done_q;

    fetch_resp_valid = (fetch_state == FETCH_DONE);
    fetch_resp_partial = '0;
end

endmodule