
import top_pkg::*;

module feature_transformation_core #(
    parameter PRECISION = top_pkg::FLOAT_32,
    parameter FLOAT_WIDTH = 32,
    parameter DATA_WIDTH = 32,

    parameter MATRIX_N = top_pkg::TRANSFORMATION_ROWS,
    parameter SYSTOLIC_MODULE_COUNT = 32
) (
    input logic                                                                                       core_clk,
    input logic                                                                                       resetn,

    // Node Scoreboard -> Transformation Engine Interface
    input  logic                                                                                      nsb_fte_req_valid,
    output logic                                                                                      nsb_fte_req_ready,
    input  NSB_FTE_REQ_t                                                                              nsb_fte_req,

    output logic                                                                                      nsb_fte_resp_valid,
    input  logic                                                                                      nsb_fte_resp_ready,
    output NSB_FTE_RESP_t                                                                             nsb_fte_resp,

    // Aggregation Buffer Interface
    input  logic [top_pkg::AGGREGATION_BUFFER_SLOTS-1:0] [top_pkg::NODE_ID_WIDTH-1:0]                 transformation_core_aggregation_buffer_node_id,
    output logic [top_pkg::AGGREGATION_BUFFER_SLOTS-1:0]                                              transformation_core_aggregation_buffer_pop,
    input  logic [top_pkg::AGGREGATION_BUFFER_SLOTS-1:0]                                              transformation_core_aggregation_buffer_out_feature_valid,
    input  logic [top_pkg::AGGREGATION_BUFFER_SLOTS-1:0] [top_pkg::AGGREGATION_BUFFER_READ_WIDTH-1:0] transformation_core_aggregation_buffer_out_feature,
    input  logic [top_pkg::AGGREGATION_BUFFER_SLOTS-1:0]                                              transformation_core_aggregation_buffer_slot_free,

    // Weight Channels: FTE -> Prefetcher Weight Bank (REQ)
    output logic                                                                                      weight_channel_req_valid,
    input  logic                                                                                      weight_channel_req_ready,
    output WEIGHT_CHANNEL_REQ_t                                                                       weight_channel_req,

    input  logic                                                                                      weight_channel_resp_valid,
    output logic                                                                                      weight_channel_resp_ready,
    input  WEIGHT_CHANNEL_RESP_t                                                                      weight_channel_resp,

    // Transformation Buffer Interface
    output logic [TRANSFORMATION_BUFFER_SLOTS-1:0]                                                    transformation_buffer_write_enable,
    output logic [TRANSFORMATION_BUFFER_SLOTS-1:0] [$clog2(TRANSFORMATION_BUFFER_WRITE_DEPTH)-1:0]    transformation_buffer_write_address,
    output logic [TRANSFORMATION_BUFFER_SLOTS-1:0] [TRANSFORMATION_BUFFER_WRITE_WIDTH-1:0]            transformation_buffer_write_data,
    input  logic [TRANSFORMATION_BUFFER_SLOTS-1:0]                                                    transformation_buffer_slot_free,

    // AXI Write Master Interface
    output logic                                                                                      axi_write_master_req_valid,
    input  logic                                                                                      axi_write_master_req_ready,
    output logic [33:0]                                                                               axi_write_master_req_start_address,
    output logic [7:0]                                                                                axi_write_master_req_len,

    input  logic                                                                                      axi_write_master_pop,
    output logic                                                                                      axi_write_master_data_valid,
    output logic [511:0]                                                                              axi_write_master_data,

    input  logic                                                                                      axi_write_master_resp_valid,
    output logic                                                                                      axi_write_master_resp_ready,

    // Layer configuration
    input  logic [9:0]                                                                                layer_config_in_features_count,
    input  logic [9:0]                                                                                layer_config_out_features_count,
    input  logic [1:0]                                                                                layer_config_out_features_address_msb_value,
    input  logic [31:0]                                                                               layer_config_out_features_address_lsb_value,
    input  logic [31:0]                                                                               layer_config_bias_value, //needs be paramterised to sytolic module count
    input  logic [1:0]                                                                                layer_config_activation_function_value,
    input  logic [31:0]                                                                               layer_config_leaky_relu_alpha_value,
    input  logic [0:0]                                                                                ctrl_buffering_enable_value,
    input  logic [0:0]                                                                                ctrl_writeback_enable_value
);

parameter SYS_MODULES_PER_BEAT = 512 / (FLOAT_WIDTH);
parameter MAX_WRITEBACK_BEATS_PER_NODESLOT = (SYSTOLIC_MODULE_COUNT*MATRIX_N) / SYS_MODULES_PER_BEAT;

typedef enum logic [3:0] {
    FTE_FSM_IDLE, FTE_FSM_REQ_WC, FTE_FSM_MULT_SLOW, FTE_FSM_MULT_FAST, FTE_FSM_BIAS, FTE_FSM_ACTIVATION, FTE_FSM_BUFFER, FTE_FSM_WRITEBACK_REQ, FTE_FSM_WRITEBACK_RESP, FTE_FSM_SHIFT, FTE_FSM_NSB_RESP
} FTE_FSM_e;

// ==================================================================================================================================================
// Declarations
// ==================================================================================================================================================

FTE_FSM_e fte_state, fte_state_n;
logic last_weight_resp_received;

logic [MATRIX_N:0] valid_row;


// NSB requests
logic [top_pkg::MAX_NODESLOT_COUNT-1:0]         nsb_req_nodeslots_q;
logic [$clog2(top_pkg::MAX_NODESLOT_COUNT)-1:0] nodeslot_count;
logic [$clog2(top_pkg::MAX_NODESLOT_COUNT)-1:0] nodeslots_to_buffer;
logic [$clog2(top_pkg::MAX_NODESLOT_COUNT)-1:0] nodeslots_to_writeback;

// Systolic modules
// -------------------------------------------------------------------------------------

// Driven from aggregation buffer
logic [SYSTOLIC_MODULE_COUNT:0] [MATRIX_N-1:0]                                  sys_module_forward_valid; // 16
logic [SYSTOLIC_MODULE_COUNT:0] [MATRIX_N-1:0] [DATA_WIDTH-1:0]                 sys_module_forward;

// Driven from weight channel
logic [MAX_FEATURE_COUNT-1:0]                                                   sys_module_down_in_valid;
logic [MAX_FEATURE_COUNT-1:0] [DATA_WIDTH-1:0]                                  sys_module_down_in;

logic [MAX_FEATURE_COUNT-1:0]                                                   sys_module_down_out_valid;
logic [MAX_FEATURE_COUNT-1:0] [DATA_WIDTH-1:0]                                  sys_module_down_out;

logic [SYSTOLIC_MODULE_COUNT-1:0]                                               sys_module_flush_done;

logic [SYSTOLIC_MODULE_COUNT-1:0] [MATRIX_N:0] [MATRIX_N-1:0] [DATA_WIDTH-1:0]  sys_module_pe_acc;



// logic  [MATRIX_N*2:0] [MATRIX_N-1:0] [DATA_WIDTH-1:0]  wide;

// assign wide = {sys_module_pe_acc[0],sys_module_pe_acc[1]};


logic [SYSTOLIC_MODULE_COUNT-1:0]                                               shift_sys_module;
logic                                                                           bias_valid;
logic                                                                           activation_valid;

// genvar j;
// generate
//     for (j = 0; j < SYSTOLIC_MODULE_COUNT; j++) begin
//         assign sys_module_pe_acc_row0 [MATRIX_N*j + (MATRIX_N-1) : MATRIX_N*j]  = sys_module_pe_acc [j][0] 
//     end
   
// endgenerate

// Driving systolic modules
// -------------------------------------------------------------------------------------

logic                                                 begin_feature_dump;
logic                                                 pulse_systolic_module;
logic [top_pkg::AGGREGATION_BUFFER_SLOTS-1:0]         slot_pop_shift;
logic [top_pkg::AGGREGATION_BUFFER_SLOTS-1:0]         busy_aggregation_slots_snapshot;
logic                                                 pe_delay_counter;

// Flushing logic
logic [top_pkg::TRANSFORMATION_BUFFER_SLOTS-1:0]     transformation_buffer_slot_arb_oh;

// Writeback logic
logic [$clog2(MAX_WRITEBACK_BEATS_PER_NODESLOT):0]   sent_writeback_beats;
logic [$clog2(MAX_WRITEBACK_BEATS_PER_NODESLOT):0]   writeback_required_beats;
logic [MATRIX_N:0] [top_pkg::NODE_ID_WIDTH-1:0]      sys_module_node_id_snapshot;
logic [$clog2(top_pkg::MAX_FEATURE_COUNT * 4) - 1:0] out_features_required_bytes;

logic [31:0]                       fast_pulse_counter;

logic [SYSTOLIC_MODULE_COUNT-1:0] [MATRIX_N-1:0] [MATRIX_N-1:0] [31:0] debug_update_counter;
logic [SYSTOLIC_MODULE_COUNT-1:0] [MATRIX_N-1:0] [MATRIX_N-1:0] [31:0] debug_update_counter_inv;

assign debug_update_counter_inv = ~debug_update_counter;

logic bias_applied, activation_applied;

// ==================================================================================================================================================
// Instances
// ==================================================================================================================================================

// Systolic Modules
// --------------------------------------------------------------------------------

//Concat top row so that axi_write_data can interate over it and not worry about meshes
logic  [MATRIX_N*SYSTOLIC_MODULE_COUNT-1:0] [DATA_WIDTH-1:0]  sys_module_pe_acc_row0;

// int index_loop

for (genvar j = 0; j < SYSTOLIC_MODULE_COUNT*MATRIX_N ; j++) begin
    always_comb begin
        sys_module_down_in_valid[j] = weight_channel_resp_valid & weight_channel_resp.valid_mask[j];
        sys_module_down_in[j] = sys_module_down_in_valid[j] ? weight_channel_resp.data[j] : 1'b0; // Is this needed can use in PE
    end
end 


for (genvar sys_module = 0; sys_module < SYSTOLIC_MODULE_COUNT; sys_module++) begin : sys_modules
    // Driving from weight channel
    always_comb begin
        sys_module_pe_acc_row0 [sys_module*MATRIX_N + (MATRIX_N-1) : sys_module*MATRIX_N]  = sys_module_pe_acc [sys_module][0];
        // sys_module_down_in       [sys_module*MATRIX_N + (MATRIX_N-1) : sys_module*MATRIX_N] = weight_channel_resp.data[sys_module*MATRIX_N + (MATRIX_N-1) : sys_module*MATRIX_N];
        // sys_module_down_in_valid [sys_module*MATRIX_N + (MATRIX_N-1) : sys_module*MATRIX_N] = {MATRIX_N{weight_channel_resp_valid}} & weight_channel_resp.valid_mask[sys_module*MATRIX_N + (MATRIX_N-1) : sys_module*MATRIX_N];
        shift_sys_module[sys_module] = (fte_state == FTE_FSM_SHIFT);

   end
    
    systolic_module #(
        .PRECISION (PRECISION),
        .FLOAT_WIDTH (FLOAT_WIDTH),
        .DATA_WIDTH  (DATA_WIDTH),
        .MATRIX_N    (MATRIX_N)
    ) sys_module_i (
        .core_clk                            (core_clk),
        .resetn                              (resetn),

        .pulse_systolic_module               (pulse_systolic_module),

        .sys_module_forward_in_valid         (sys_module_forward_valid  [sys_module]),
        .sys_module_forward_in               (sys_module_forward        [sys_module]),

        .sys_module_down_in_valid            (sys_module_down_in_valid  [sys_module*MATRIX_N + (MATRIX_N-1) : sys_module*MATRIX_N]),
        .sys_module_down_in                  (sys_module_down_in        [sys_module*MATRIX_N + (MATRIX_N-1) : sys_module*MATRIX_N]),

        .sys_module_forward_out_valid        (sys_module_forward_valid  [sys_module+1]),
        .sys_module_forward_out              (sys_module_forward        [sys_module+1]),

        .sys_module_down_out_valid           (sys_module_down_out_valid [sys_module*MATRIX_N + (MATRIX_N-1) : sys_module*MATRIX_N]),
        .sys_module_down_out                 (sys_module_down_out       [sys_module*MATRIX_N + (MATRIX_N-1) : sys_module*MATRIX_N]),
        
        .bias_valid                          (bias_valid),
        .bias                                (layer_config_bias_value [DATA_WIDTH-1:0]),
        
        .activation_valid                    (activation_valid),
        .activation                          (layer_config_activation_function_value),

        .shift_valid                         (shift_sys_module         [sys_module]),

        .sys_module_pe_acc                   (sys_module_pe_acc        [sys_module]),

        .diagonal_flush_done                 (sys_module_flush_done    [sys_module]),

        .layer_config_leaky_relu_alpha_value (layer_config_leaky_relu_alpha_value [DATA_WIDTH-1:0]),

        .debug_update_counter                (debug_update_counter     [sys_module])
    );

    



end : sys_modules

// Transformation Buffer slot arbitration
// --------------------------------------------------------------------------------

rr_arbiter #(
    .NUM_REQUESTERS     (top_pkg::TRANSFORMATION_BUFFER_SLOTS)
) prefetcher_req_arb (
    .clk                (core_clk),
    .resetn             (resetn),
    .request            (transformation_buffer_slot_free),

    // update when starting to flush new row
    .update_lru         (fte_state == FTE_FSM_BUFFER),
    .grant_oh           (transformation_buffer_slot_arb_oh)
);

// Driving Aggregation Buffer
// --------------------------------------------------------------------------------

hybrid_buffer_driver #(
    .BUFFER_SLOTS (top_pkg::AGGREGATION_BUFFER_SLOTS),
    .MAX_PULSES_PER_SLOT (top_pkg::MAX_FEATURE_COUNT)
) aggregation_buffer_driver_i (
    .core_clk,
    .resetn,

    .begin_dump     (begin_feature_dump),
    .pulse          (pulse_systolic_module),

    .pulse_limit    (layer_config_in_features_count),

    .slot_pop_shift (slot_pop_shift)
);

// ==================================================================================================================================================
// Logic
// ==================================================================================================================================================

// FTE State Machine
// -------------------------------------------------------------------------------------

always_ff @(posedge core_clk or negedge resetn) begin
    if (!resetn) begin
        fte_state <= FTE_FSM_IDLE;
    end else begin
        fte_state <= fte_state_n;
    end
end

always_comb begin
    fte_state_n = fte_state;

    case(fte_state)

        FTE_FSM_IDLE: begin
            fte_state_n = nsb_fte_req_valid ? FTE_FSM_REQ_WC : FTE_FSM_IDLE;
        end

        FTE_FSM_REQ_WC: begin
            fte_state_n = weight_channel_req_ready ? FTE_FSM_MULT_SLOW : FTE_FSM_REQ_WC;
        end

        FTE_FSM_MULT_SLOW: begin
            fte_state_n = last_weight_resp_received ? FTE_FSM_MULT_FAST : FTE_FSM_MULT_SLOW;
        end

        FTE_FSM_MULT_FAST: begin
            fte_state_n = (fast_pulse_counter == MATRIX_N * 2) ? FTE_FSM_BIAS : FTE_FSM_MULT_FAST;
        end

        FTE_FSM_BIAS: begin
            fte_state_n = bias_applied ? FTE_FSM_ACTIVATION : FTE_FSM_BIAS;
        end

        FTE_FSM_ACTIVATION: begin
            fte_state_n = activation_applied && ctrl_buffering_enable_value ? FTE_FSM_BUFFER
                        : activation_applied ? FTE_FSM_WRITEBACK_REQ
                        : FTE_FSM_ACTIVATION;
        end
        
        FTE_FSM_BUFFER: begin
            fte_state_n = FTE_FSM_WRITEBACK_REQ; // buffering takes a single cycle
        end

        FTE_FSM_WRITEBACK_REQ: begin
            fte_state_n = (!valid_row[0]) ?  FTE_FSM_SHIFT : axi_write_master_req_ready ? FTE_FSM_WRITEBACK_RESP : FTE_FSM_WRITEBACK_REQ;
        end

        FTE_FSM_WRITEBACK_RESP: begin
            fte_state_n =
                        // Sending last beat for last nodeslot
                        (nodeslots_to_writeback == 'd1) && (sent_writeback_beats == writeback_required_beats) && axi_write_master_resp_valid ? FTE_FSM_NSB_RESP

                        // Sending last beat, more nodeslots to go - or row not valid, shift in next row
                        : ((sent_writeback_beats == writeback_required_beats | !valid_row[0]) && axi_write_master_resp_valid) ? FTE_FSM_SHIFT
                        : FTE_FSM_WRITEBACK_RESP;
        end

        FTE_FSM_SHIFT: begin
            fte_state_n = ctrl_buffering_enable_value ? FTE_FSM_BUFFER
                        : ctrl_writeback_enable_value ? FTE_FSM_WRITEBACK_REQ
                        : FTE_FSM_NSB_RESP;
        end

        FTE_FSM_NSB_RESP: begin
            fte_state_n = nsb_fte_resp_ready ? FTE_FSM_IDLE : FTE_FSM_NSB_RESP;
        end

        default: begin
            fte_state_n = FTE_FSM_IDLE;
        end

    endcase
end

// Bias and activation applied flag
always_ff @(posedge core_clk or negedge resetn) begin

    if (!resetn) begin
        bias_applied <= '0;
        activation_applied <= '0;

    end else begin
        bias_applied <= (fte_state == FTE_FSM_MULT_FAST && fte_state_n == FTE_FSM_BIAS) ? '0
                    : fte_state == FTE_FSM_BIAS ? '1
                    : bias_applied;

        activation_applied <= fte_state == FTE_FSM_BIAS && fte_state_n == FTE_FSM_ACTIVATION ? '0
                            : fte_state == FTE_FSM_ACTIVATION ? '1
                            : activation_applied;

    end
end

// Take snapshot of busy slots and respective node IDs after NSB request
// -------------------------------------------------------------------------------------

for (genvar slot = 0; slot < top_pkg::AGGREGATION_BUFFER_SLOTS; slot++) begin : slot_logic
    always_ff @(posedge core_clk or negedge resetn) begin
        if (!resetn) begin
            busy_aggregation_slots_snapshot [slot] <= '0;
        end else begin
            // Assert snapshot flag for given slot when starting transformation, if the slot is currently filled
            if ((fte_state == FTE_FSM_IDLE) && (fte_state_n == FTE_FSM_REQ_WC)) begin
                busy_aggregation_slots_snapshot [slot] <= !transformation_core_aggregation_buffer_slot_free[slot] && nsb_fte_req.slots[slot];

            // Drop the snapshot bit during transformation when the slot becomes free, i.e. the slot was fully driven
            // This prevents reading from the slot while it's being populated by a buffer manager for the next systolic array pass
            end else if (fte_state != FTE_FSM_IDLE && transformation_core_aggregation_buffer_slot_free[slot]) begin
                busy_aggregation_slots_snapshot [slot] <= '0;
            end
        end
    end
end : slot_logic


always_ff @(posedge core_clk or negedge resetn) begin
    if (!resetn) begin
        nsb_req_nodeslots_q <= '0;
        
    // Starting multiplication
    end else if ((fte_state == FTE_FSM_IDLE) && (fte_state_n == FTE_FSM_REQ_WC)) begin
        nsb_req_nodeslots_q <= nsb_fte_req.nodeslots;
    end
end

for (genvar row = 0; row < MATRIX_N; row++) begin : per_row_logic
    always_ff @(posedge core_clk or negedge resetn) begin
        if (!resetn) begin
            sys_module_node_id_snapshot [row]          <= '0;
            
        // Starting multiplication
        end else if ((fte_state == FTE_FSM_IDLE) && (fte_state_n == FTE_FSM_REQ_WC)) begin
            sys_module_node_id_snapshot [row]          <= transformation_core_aggregation_buffer_node_id [row];
        
        // Shift node IDs
        end else if (fte_state == FTE_FSM_SHIFT) begin
            sys_module_node_id_snapshot [row]          <= sys_module_node_id_snapshot [row+1];
        end
    end
end : per_row_logic

assign sys_module_node_id_snapshot [MATRIX_N] = '0;

// Driving systolic module
// -------------------------------------------------------------------------------------

always_comb begin
    // Begin feature dump when weight channel request accepted
    begin_feature_dump = (fte_state == FTE_FSM_REQ_WC) && (fte_state_n == FTE_FSM_MULT_SLOW);

    // Pulse module when features ready in aggregation buffer and weights ready in weight channel
    pulse_systolic_module = ((fte_state_n == FTE_FSM_MULT_SLOW) && &transformation_core_aggregation_buffer_out_feature_valid && weight_channel_resp_valid) || fte_state == FTE_FSM_MULT_FAST;

    // Drive systolic module from aggregation buffer (on the left)
    sys_module_forward_valid [0] = slot_pop_shift & busy_aggregation_slots_snapshot;
    sys_module_forward       [0] = transformation_core_aggregation_buffer_out_feature;

    transformation_core_aggregation_buffer_pop = slot_pop_shift & {MATRIX_N{pulse_systolic_module}} & busy_aggregation_slots_snapshot & ~transformation_core_aggregation_buffer_slot_free;
end

// After SLOW phase done, pulse every cycle until last element propagates down to the end
always_ff @(posedge core_clk or negedge resetn) begin
    if (!resetn) begin
        fast_pulse_counter <= '0;

    end else if (fte_state == FTE_FSM_MULT_SLOW && fte_state_n == FTE_FSM_MULT_FAST) begin
        fast_pulse_counter <= '0;

    end else if (fte_state == FTE_FSM_MULT_FAST) begin
        fast_pulse_counter <= fast_pulse_counter + 1'b1;
    end
end
    
always_comb begin
//     // Bias and activation after multiplication finished
    bias_valid       = (fte_state == FTE_FSM_BIAS);
    activation_valid = (fte_state == FTE_FSM_ACTIVATION);
end

// Buffering Logic
// -------------------------------------------------------------------------------------

for (genvar slot = 0; slot < TRANSFORMATION_BUFFER_SLOTS; slot++) begin : slot_buffering_logic
    always_comb begin
        transformation_buffer_write_enable  [slot] = transformation_buffer_slot_arb_oh[slot] && (fte_state == FTE_FSM_BUFFER);
        transformation_buffer_write_address [slot] = '0;
        transformation_buffer_write_data    [slot] = sys_module_pe_acc [0] [0]; // 16*32 bits = 512b
    end    
end : slot_buffering_logic

always_ff @(posedge core_clk or negedge resetn) begin
    if (!resetn) begin
        nodeslots_to_buffer <= '0;
        
    // Accepting NSB request
    end else if (nsb_fte_req_valid && nsb_fte_req_ready) begin
        nodeslots_to_buffer    <= ctrl_buffering_enable_value ? nodeslot_count : nodeslots_to_buffer;
    
    // Done flushing a row of features
    end else if (fte_state == FTE_FSM_BUFFER) begin
        nodeslots_to_buffer <= nodeslots_to_buffer - 1'b1;
    end
end

count_ones #(
    .INPUT_WIDTH (top_pkg::MAX_NODESLOT_COUNT)
) count_nodeslots (
    .data (nsb_fte_req.nodeslots),
    .count (nodeslot_count)
);

// Writeback Logic
// -------------------------------------------------------------------------------------

integer index;
integer sys_mods;

integer sys_module;


logic [$clog2(MATRIX_N*SYSTOLIC_MODULE_COUNT)-1:0] module_index;

always_comb begin
    out_features_required_bytes = layer_config_out_features_count * 4; // 4 bytes per feature
    out_features_required_bytes = {out_features_required_bytes[$clog2(top_pkg::MAX_FEATURE_COUNT * 4) - 1 : 6], 6'd0} + (out_features_required_bytes[5:0] ? 'd64 : 1'b0); // nearest multiple of 64
    // Div feautre count by 16, round up - *float32/512 - paramterize for different data widths
    writeback_required_beats = (layer_config_out_features_count >> 4) + (layer_config_out_features_count[3:0] ? 1'b1 : 1'b0);

    // Request
    axi_write_master_req_valid = (fte_state == FTE_FSM_WRITEBACK_REQ && valid_row[0]); ;
    axi_write_master_req_start_address = {layer_config_out_features_address_msb_value, layer_config_out_features_address_lsb_value}
                                            + sys_module_node_id_snapshot[0] * out_features_required_bytes;

    axi_write_master_req_len = writeback_required_beats - 1'b1;

    sys_mods = SYS_MODULES_PER_BEAT;
    index = sent_writeback_beats*512;
    // sys_module = index

    // Data
    axi_write_master_data_valid = (fte_state == FTE_FSM_WRITEBACK_RESP) & valid_row[0];
    module_index = sent_writeback_beats*SYS_MODULES_PER_BEAT;
    
    // axi_write_master_data = sys_module_pe_acc_row0[SYS_MODULES_PER_BEAT*DATA_WIDTH*sent_writeback_beats + SYS_MODULES_PER_BEAT*DATA_WIDTH + 'd0: SYS_MODULES_PER_BEAT*DATA_WIDTH*sent_writeback_beats];
    
    //Vector bit-select and part-select addressing


    
    axi_write_master_data = sys_module_pe_acc_row0[sent_writeback_beats*SYS_MODULES_PER_BEAT +: SYS_MODULES_PER_BEAT];

    
    // axi_write_master_data = {sys_module_pe_acc [SYS_MODULES_PER_BEAT*sent_writeback_beats + 'd3][0],
    //                         sys_module_pe_acc  [SYS_MODULES_PER_BEAT*sent_writeback_beats + 'd2][0],
    //                         sys_module_pe_acc  [SYS_MODULES_PER_BEAT*sent_writeback_beats + 'd1][0],
    //                         sys_module_pe_acc  [module_index + 'd0][0]
    //                     };

    // Response
    axi_write_master_resp_ready = (fte_state == FTE_FSM_WRITEBACK_RESP);
end


always_ff @(posedge core_clk or negedge resetn) begin
    if (!resetn) begin
        nodeslots_to_writeback <= '0;
        sent_writeback_beats <= '0;

        // Accepting NSB request
    end else if (nsb_fte_req_valid && nsb_fte_req_ready) begin
        nodeslots_to_writeback <= ctrl_writeback_enable_value ? nodeslot_count : nodeslots_to_writeback;
        sent_writeback_beats <= '0;

    // Accepting AXI Write Master request
    end else if (axi_write_master_req_valid && axi_write_master_req_ready) begin
        sent_writeback_beats <= '0;

    // Sent 512b beat
    end else if (axi_write_master_pop) begin
        sent_writeback_beats <= sent_writeback_beats + 1'b1;

    // Accepting write response
    end else if (valid_row[0] && fte_state == FTE_FSM_WRITEBACK_RESP && axi_write_master_resp_valid && sent_writeback_beats == writeback_required_beats) begin
        nodeslots_to_writeback <= nodeslots_to_writeback - 1'b1;
    end
end

// NSB Interface
// -------------------------------------------------------------------------------------

always_comb begin
    nsb_fte_req_ready           = (fte_state == FTE_FSM_IDLE);
    
    nsb_fte_resp_valid          = (fte_state == FTE_FSM_NSB_RESP);
    nsb_fte_resp.nodeslots      = nsb_req_nodeslots_q;
end

// Weight Channel Interface
// -------------------------------------------------------------------------------------

always_comb begin
    weight_channel_req_valid  = (fte_state == FTE_FSM_REQ_WC);

    // Feature counts aren't used by weight bank
    weight_channel_req.in_features  = top_pkg::MAX_FEATURE_COUNT;
    weight_channel_req.out_features = top_pkg::MAX_FEATURE_COUNT;

    // Accept weight bank response when pulsing systolic module (i.e. aggregation buffer is also ready)
    weight_channel_resp_ready = (fte_state == FTE_FSM_MULT_SLOW) && (pulse_systolic_module || weight_channel_resp.done);
end

// Raise flag as pre-condition for transitioning from MULT state
always_ff @(posedge core_clk or negedge resetn) begin
    if (!resetn) begin
        last_weight_resp_received <= '0;
        
    // Starting new request
    end else if ((fte_state == FTE_FSM_IDLE) && nsb_fte_req_valid) begin
        last_weight_resp_received <= '0;
    
    end else if (weight_channel_resp_valid && weight_channel_resp.done) begin
        last_weight_resp_received <= '1;
    end
end

assign valid_row[MATRIX_N] = 0;

for (genvar k = 0; k < MATRIX_N ; k++) begin
    always_ff @(posedge core_clk or negedge resetn) begin
        if(!resetn) begin
            valid_row[k] = 0;             //[0]th column, jth row

        end
        // else if (fte_state == FTE_FSM_IDLE) begin
        //     valid_row[k] = 0;
        // end

        else if(fte_state == FTE_FSM_SHIFT)begin
            valid_row[k] = valid_row[k+1];
        end
        // else if(transformation_core_aggregation_buffer_out_feature_valid)begin
        //     valid_row[k] = 1;
        // end
        else if(fte_state_n == FTE_FSM_MULT_SLOW)begin
            valid_row[k] = nsb_req_nodeslots_q[k];
        end 

    end
end 



endmodule