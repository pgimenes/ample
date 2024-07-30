`timescale 1ns/100ps

import top_pkg::*;

// TO DO: handle case when some slots not valid, less than 8 nodeslots in the response beat

module nodeslot_prefetcher (
    input logic core_clk,
    input logic resetn,

    // Instruction fetching AXI interface
    output logic  [7:0]                   read_master_axi_awid,
    output logic  [33:0]                  read_master_axi_awaddr,
    output logic  [7:0]                   read_master_axi_awlen,
    output logic  [2:0]                   read_master_axi_awsize,
    output logic  [1:0]                   read_master_axi_awburst,
    output logic  [0:0]                   read_master_axi_awlock,
    output logic  [3:0]                   read_master_axi_awcache,
    output logic  [2:0]                   read_master_axi_awprot,
    output logic  [3:0]                   read_master_axi_awqos,
    output logic                          read_master_axi_awvalid,
    input  logic                          read_master_axi_awready,
    output logic  [511:0]                 read_master_axi_wdata,
    output logic  [63:0]                  read_master_axi_wstrb,
    output logic                          read_master_axi_wlast,
    output logic                          read_master_axi_wvalid,
    input  logic                          read_master_axi_wready,
    input  logic [7:0]                    read_master_axi_bid,
    input  logic [1:0]                    read_master_axi_bresp,
    input  logic                          read_master_axi_bvalid,
    output logic                          read_master_axi_bready,
    output logic  [7:0]                   read_master_axi_arid,
    output logic  [33:0]                  read_master_axi_araddr,
    output logic  [7:0]                   read_master_axi_arlen,
    output logic  [2:0]                   read_master_axi_arsize,
    output logic  [1:0]                   read_master_axi_arburst,
    output logic  [0:0]                   read_master_axi_arlock,
    output logic  [3:0]                   read_master_axi_arcache,
    output logic  [2:0]                   read_master_axi_arprot,
    output logic  [3:0]                   read_master_axi_arqos,
    output logic                          read_master_axi_arvalid,
    input  logic                          read_master_axi_arready,
    input  logic [7:0]                    read_master_axi_rid,
    input  logic [511:0]                  read_master_axi_rdata,
    input  logic [1:0]                    read_master_axi_rresp,
    input  logic                          read_master_axi_rlast,
    input  logic                          read_master_axi_rvalid,
    output logic                          read_master_axi_rready,

    output logic [255:0] [19:0] nsb_nodeslot_neighbour_count_count_hw,
    output logic [255:0] [19:0] nsb_nodeslot_node_id_id_hw,
    output logic [255:0] [1:0]  nsb_nodeslot_precision_precision_hw,
    output logic [255:0] [0:0]  nsb_nodeslot_config_make_valid_value_hw,

    output logic [255:0]        nsb_nodeslot_neighbour_count_strobe_hw,
    output logic [255:0]        nsb_nodeslot_node_id_strobe_hw,
    output logic [255:0]        nsb_nodeslot_precision_strobe_hw,
    output logic [255:0]        nsb_nodeslot_config_make_valid_strobe_hw,
    
    input  logic [31:0] status_nodeslots_empty_mask_0_value,
    input  logic [31:0] status_nodeslots_empty_mask_1_value,
    input  logic [31:0] status_nodeslots_empty_mask_2_value,
    input  logic [31:0] status_nodeslots_empty_mask_3_value,
    input  logic [31:0] status_nodeslots_empty_mask_4_value,
    input  logic [31:0] status_nodeslots_empty_mask_5_value,
    input  logic [31:0] status_nodeslots_empty_mask_6_value,
    input  logic [31:0] status_nodeslots_empty_mask_7_value,

    input  logic [31:0]         graph_config_node_count_value,
    input  logic [0:0]          ctrl_start_nodeslot_fetch_value,
    output logic                ctrl_start_nodeslot_fetch_done_value,
    input  logic                ctrl_start_nodeslot_fetch_done_ack_value,
    input  logic [top_pkg::MAX_NODESLOT_COUNT-1:0] nodeslot_finished
);

parameter MAX_BYTES = top_pkg::MAX_NODES * 8;
parameter BITS_PER_NODESLOT = 64;
parameter NODESLOTS_PER_BEAT = 8;
parameter NODESLOTS_PER_TRANSACTION_BOUNDARY = 4*1024/8; // 512

// ==================================================================================================================================================
// Declarations
// ==================================================================================================================================================

// Request interface
logic                                                 fetch_req_valid;
logic                                                 fetch_req_ready;
logic [33:0]                                          fetch_start_address;
logic [$clog2(MAX_BYTES)-1:0] required_bytes;

// Response interface
logic                                       fetch_resp_valid;
logic                                       fetch_resp_last;
logic [top_pkg::AXI_DATA_WIDTH:0]           fetch_resp_data;
logic [top_pkg::AXI_DATA_WIDTH:0]           fetch_resp_data_q;
logic [3:0]                                 fetch_resp_axi_id;

logic [top_pkg::MAX_NODESLOT_COUNT-1:0] nodeslots_empty_status_mask;
logic [top_pkg::MAX_NODESLOT_COUNT-1:0] nodeslots_programmed_mask;
logic [top_pkg::MAX_NODESLOT_COUNT-1:0] nodeslot_free_mask;

logic [top_pkg::MAX_NODESLOT_COUNT-1:0] granted_nodeslot_oh;
logic [$clog2(top_pkg::MAX_NODESLOT_COUNT)-1:0] granted_nodeslot_bin;

logic fetched_beat_valid; // FSM (2 state)
logic fetched_beat;

logic [2:0] slot_counter;

logic [255:0] [19:0] nsb_nodeslot_neighbour_count_count_hw_n;
logic [255:0] [19:0] nsb_nodeslot_node_id_id_hw_n;
logic [255:0] [1:0]  nsb_nodeslot_precision_precision_hw_n;
logic [255:0] [0:0]  nsb_nodeslot_config_make_valid_value_hw_n;

logic [31:0] required_transactions;
logic [7:0] [63:0] fetched_nodeslots;
logic [19:0] next_node_id;

// ==================================================================================================================================================
// Instances
// ==================================================================================================================================================

axi_read_master #(
    .MAX_BYTE_COUNT (MAX_BYTES),
    .DATA_WIDTH     (top_pkg::AXI_DATA_WIDTH)
) read_master_i (
    .core_clk    (core_clk),
    .resetn      (resetn),
    
    .fetch_req_valid            (fetch_req_valid),
    .fetch_req_ready            (fetch_req_ready),
    .fetch_start_address        (fetch_start_address),
    .fetch_byte_count           (required_bytes),
    
    .fetch_resp_valid           (fetch_resp_valid),
    .fetch_resp_ready           (!fetched_beat_valid),
    .fetch_resp_last            (fetch_resp_last),
    .fetch_resp_data            (fetch_resp_data),
    .fetch_resp_axi_id          (),

    // AXI Read-Only Interface
    .axi_araddr                  (read_master_axi_araddr),
    .axi_arburst                 (read_master_axi_arburst),
    .axi_arcache                 (read_master_axi_arcache),
    .axi_arid                    (read_master_axi_arid),
    .axi_arlen                   (read_master_axi_arlen),
    .axi_arlock                  (read_master_axi_arlock),
    .axi_arprot                  (read_master_axi_arprot),
    .axi_arqos                   (read_master_axi_arqos),
    .axi_arsize                  (read_master_axi_arsize),
    .axi_arvalid                 (read_master_axi_arvalid),
    .axi_arready                 (read_master_axi_arready),
    .axi_rdata                   (read_master_axi_rdata),
    .axi_rid                     (read_master_axi_rid),
    .axi_rlast                   (read_master_axi_rlast),
    .axi_rvalid                  (read_master_axi_rvalid),
    .axi_rready                  (read_master_axi_rready),
    .axi_rresp                   (read_master_axi_rresp)
);

rr_arbiter #(
    .NUM_REQUESTERS (top_pkg::MAX_NODESLOT_COUNT)
) fetch_tag_resp_arb_i (
    .clk        (core_clk),
    .resetn     (resetn),

    .request    (nodeslot_free_mask),
    .update_lru (fetched_beat_valid && |nodeslot_free_mask),
    .grant_oh   (granted_nodeslot_oh),
    .grant_bin  (granted_nodeslot_bin)
);

// ==================================================================================================================================================
// Logic
// ==================================================================================================================================================

// Drive requests
// ---------------------------------------------------------

// TO DO: remove this when axi read master is fixed to accept byte counts > 4kB

always_ff @(posedge core_clk or negedge resetn) begin
    if (!resetn) begin
        required_transactions <= '0;
        fetch_start_address   <= '0;

    end else begin
        if (ctrl_start_nodeslot_fetch_value) begin
            required_transactions <= (graph_config_node_count_value >> 9) + (|graph_config_node_count_value[8:0] ? 1'b1 : 1'b0); // Divide by 512 and round up
            fetch_start_address   <= '0;
        end 

        if (fetch_req_valid && fetch_req_ready) begin
            required_transactions <= required_transactions - 1'b1;
            fetch_start_address   <= fetch_start_address + 'd4096;
        end
    end
end

assign fetch_req_valid = |required_transactions && !fetched_beat_valid;

// assign required_bytes = `divide_round_up(graph_config_node_count_value, NODESLOTS_PER_BEAT) * 64;
// Divide round up by 8, multiply by 64 == multiply by 8
// assign required_bytes = ({graph_config_node_count_value[19:3], 3'b0} + (|graph_config_node_count_value[3:0] ? 1'b1 : 1'b0)) * 23'd64;

// TO DO: replace with above
// 4kB if requesting full transaction, otherwise modulus by number of nodeslots per transaction block (512), then multiply by num of bytes per nodeslot (8)
assign required_bytes = required_transactions == 'd1 ? (graph_config_node_count_value[8:0] << 3) : 'd4096;

// Handle responses
// ---------------------------------------------------------

// 2 state FSM, IDLE and PROGRAMMING
// Keep pointer of programmed nodeslots 0...7

always_ff @(posedge core_clk or negedge resetn) begin
    if (!resetn) begin
        fetched_beat_valid <= '0;
        slot_counter <= '0;

    end else begin        
        // FSM
        if (!fetched_beat_valid && fetch_resp_valid) begin
            fetched_beat_valid <= '1;
            fetch_resp_data_q <= fetch_resp_data;
        end else if (fetched_beat_valid && slot_counter == 3'd7 && |nodeslot_free_mask) begin
            fetched_beat_valid <= '0;
        end

        // Slot counter
        if (fetched_beat_valid && |nodeslot_free_mask) begin
            slot_counter <= slot_counter + 1'b1;
        end
    end
end

// Nodeslot arbitration
// ---------------------------------------------------------

always_comb begin
    nodeslots_empty_status_mask = {
        status_nodeslots_empty_mask_7_value,
        status_nodeslots_empty_mask_6_value,
        status_nodeslots_empty_mask_5_value,
        status_nodeslots_empty_mask_4_value,
        status_nodeslots_empty_mask_3_value,
        status_nodeslots_empty_mask_2_value,
        status_nodeslots_empty_mask_1_value,
        status_nodeslots_empty_mask_0_value
    };
    
    nodeslot_free_mask = nodeslots_empty_status_mask & ~nodeslots_programmed_mask;
end

for (genvar nodeslot = 0; nodeslot < top_pkg::MAX_NODESLOT_COUNT; nodeslot++) begin : nodeslot_arbitration_logic
    // Race condition between make_valid and nodeslots_empty_status_mask
    // It takes 3 cycles for nodeslots_empty_status_mask to be updated after make_valid_hw_n is asserted
    always_ff @(posedge core_clk or negedge resetn) begin
        if (!resetn) begin
            nodeslots_programmed_mask [nodeslot] <= '0;
            
        // Nodeslot just been programmed by the hardware
        end else if (nsb_nodeslot_config_make_valid_value_hw_n[nodeslot]) begin
            nodeslots_programmed_mask [nodeslot] <= '1;
            
            // Nodeslot just finished
        end else if (nodeslot_finished[nodeslot]) begin
            nodeslots_programmed_mask [nodeslot] <= '0;

        end

    end
end : nodeslot_arbitration_logic


// Nodeslot programming
// ---------------------------------------------------------

for (genvar slot = 0; slot < 8; slot++) begin
    assign fetched_nodeslots[slot] = fetch_resp_data_q[(slot+1)*64 - 1 : slot * 64];
end

for (genvar nodeslot = 0; nodeslot < top_pkg::MAX_NODESLOT_COUNT; nodeslot++) begin : nodeslot_logic

    // Determine next values for hardware signals
    always_comb begin
        // Default values
        nsb_nodeslot_node_id_id_hw_n              [nodeslot] = nsb_nodeslot_node_id_id_hw                [nodeslot];
        nsb_nodeslot_neighbour_count_count_hw_n   [nodeslot] = nsb_nodeslot_neighbour_count_count_hw     [nodeslot];
        nsb_nodeslot_precision_precision_hw_n     [nodeslot] = nsb_nodeslot_precision_precision_hw       [nodeslot];
        nsb_nodeslot_config_make_valid_value_hw_n [nodeslot] = nsb_nodeslot_config_make_valid_value_hw_n [nodeslot]; //Is this a bug .._n = .._n
        
        // Auto clear make valid register
        if (nsb_nodeslot_config_make_valid_value_hw[nodeslot]) begin
            nsb_nodeslot_config_make_valid_value_hw_n [nodeslot] = '0;
        end
        
        if (fetched_beat_valid && |nodeslot_free_mask && (nodeslot == granted_nodeslot_bin)) begin
            nsb_nodeslot_node_id_id_hw_n              [nodeslot] = fetched_nodeslots [slot_counter] [19 : 0];
            nsb_nodeslot_neighbour_count_count_hw_n   [nodeslot] = fetched_nodeslots [slot_counter] [39 : 20];
            nsb_nodeslot_precision_precision_hw_n     [nodeslot] = fetched_nodeslots [slot_counter] [41 : 40];
            // Only program valid nodeslots with neighbour count > 0
            nsb_nodeslot_config_make_valid_value_hw_n [nodeslot] = fetched_nodeslots [slot_counter] [63] && |fetched_nodeslots [slot_counter] [39 : 20];
        end
    end

    // Update hardware signal values
    always_ff @(posedge core_clk or negedge resetn) begin
        if (!resetn) begin
            nsb_nodeslot_neighbour_count_count_hw   [nodeslot] <= '0;
            nsb_nodeslot_node_id_id_hw              [nodeslot] <= '0;
            nsb_nodeslot_precision_precision_hw     [nodeslot] <= '0;
            nsb_nodeslot_config_make_valid_value_hw [nodeslot] <= '0;
        
        end else begin
            nsb_nodeslot_node_id_id_hw              [nodeslot] <= nsb_nodeslot_node_id_id_hw_n              [nodeslot];
            nsb_nodeslot_neighbour_count_count_hw   [nodeslot] <= nsb_nodeslot_neighbour_count_count_hw_n   [nodeslot];
            nsb_nodeslot_precision_precision_hw     [nodeslot] <= nsb_nodeslot_precision_precision_hw_n     [nodeslot];
            nsb_nodeslot_config_make_valid_value_hw [nodeslot] <= nsb_nodeslot_config_make_valid_value_hw_n [nodeslot];
        end
    end

    // Handle strobes
    always_ff @(posedge core_clk or negedge resetn) begin
        if (!resetn) begin
            nsb_nodeslot_neighbour_count_strobe_hw   [nodeslot] <= '0;
            nsb_nodeslot_node_id_strobe_hw           [nodeslot] <= '0;
            nsb_nodeslot_precision_strobe_hw         [nodeslot] <= '0;
            nsb_nodeslot_config_make_valid_strobe_hw [nodeslot] <= '0;
        
        // Only condition in which registers get updated
        // This way, avoid needing to use comparators
        end else if (fetched_beat_valid && |nodeslot_free_mask && (nodeslot == granted_nodeslot_bin)) begin
            nsb_nodeslot_neighbour_count_strobe_hw   [nodeslot] <= '1; // (nsb_nodeslot_node_id_id_hw_n              [nodeslot] != nsb_nodeslot_node_id_id_hw              [nodeslot]);
            nsb_nodeslot_node_id_strobe_hw           [nodeslot] <= '1; // (nsb_nodeslot_neighbour_count_count_hw_n   [nodeslot] != nsb_nodeslot_neighbour_count_count_hw   [nodeslot]);
            nsb_nodeslot_precision_strobe_hw         [nodeslot] <= '1; // (nsb_nodeslot_precision_precision_hw_n     [nodeslot] != nsb_nodeslot_precision_precision_hw     [nodeslot]);
            nsb_nodeslot_config_make_valid_strobe_hw [nodeslot] <= '1; // (nsb_nodeslot_config_make_valid_value_hw_n [nodeslot] != nsb_nodeslot_config_make_valid_value_hw [nodeslot]);
        end
    end

end : nodeslot_logic

// Fetch done/ack
// ---------------------------------------------------------

always_ff @(posedge core_clk or negedge resetn) begin
    if (!resetn) begin
        ctrl_start_nodeslot_fetch_done_value <= '0;
    end else begin
        if (ctrl_start_nodeslot_fetch_done_ack_value) begin
            ctrl_start_nodeslot_fetch_done_value <= '0;
        end else if (fetched_beat_valid && |nodeslot_free_mask && (next_node_id == (graph_config_node_count_value - 1'b1))) begin
            // Programming the last nodeslot
            ctrl_start_nodeslot_fetch_done_value <= '1;
        end
    end
end

// Read only interface
// ---------------------------------------------------------

always_comb begin
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
end

// Debug
// ---------------------------------------------------------

assign next_node_id = fetched_nodeslots [slot_counter] [19 : 0];

endmodule