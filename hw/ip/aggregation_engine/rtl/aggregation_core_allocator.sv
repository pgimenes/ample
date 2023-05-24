import age_pkg::*;

module aggregation_core_allocator #(
    parameter NUM_CORES            = age_pkg::TOTAL_AGGREGATION_CORES,
    parameter PRECISION_COL_OFFSET = age_pkg::AGC_FLOAT32_COL_OFFSET
) (
    input  logic                                           core_clk,
    input  logic                                           resetn,

    // Allocation request
    input  logic                                           allocation_req_valid,
    output logic                                           allocation_req_ready,
    input  top_pkg::NSB_AGE_REQ_t                          allocation_req,

    input  logic [NUM_CORES-1:0]                           cores_free,
    input  logic [9:0]                                     layer_config_in_features_count,
    
    // Deallocation request
    input  logic                                           deallocation_valid,
    input  logic [NUM_CORES-1:0]                           deallocation_cores,

    // Generated AGM request
    output logic [age_pkg::TOTAL_AGGREGATION_MANAGERS-1:0] age_agm_req_valid,
    input  logic [age_pkg::TOTAL_AGGREGATION_MANAGERS-1:0] age_agm_req_ready,
    output age_pkg::AGE_AGM_REQ_t                          age_agm_req

);

logic                                         busy;
logic                                         done;

top_pkg::NSB_AGE_REQ_t                        allocation_req_q;

// Keep track of allocated cores that haven't yet received allocation packet
logic [NUM_CORES-1:0]                         allocatable_cores;

logic [$clog2(age_pkg::MAX_AGC_PER_NODE)-1:0] agc_counter;
logic [$clog2(age_pkg::MAX_AGC_PER_NODE)-1:0] required_agcs;

logic [NUM_CORES-1:0]                         allocated_core;
logic [$clog2(NUM_CORES)-1:0]                 allocated_core_bin;

// ==================================================================================================================================================
// Instances
// ==================================================================================================================================================

rr_arbiter #(
    .NUM_REQUESTERS (NUM_CORES)
) arbiter_i (
    .clk            (core_clk),
    .resetn         (resetn),

    .request        (cores_free & allocatable_cores),
    .update_lru     (busy && !done),

    .grant_oh       (allocated_core)
);

onehot_to_binary #(
    .INPUT_WIDTH (NUM_CORES)
) allocated_core_oh2bin (
	.clk            (core_clk),
  	.resetn         (resetn),
	.input_data     (allocated_core),
  	.output_data    (allocated_core_bin)
);

// ==================================================================================================================================================
// Logic
// ==================================================================================================================================================

always_comb begin
    // Static AGM req payloads
    age_agm_req.nsb_req = allocation_req_q;
    age_agm_req.required_agcs = layer_config_in_features_count[9:4] + (|layer_config_in_features_count[3:0] ? 1'b1 : '0);

    allocation_req_ready = !busy;
    done = (agc_counter == age_agm_req.required_agcs);
end

always_ff @(posedge core_clk or negedge resetn) begin
    if (!resetn) begin
        busy <= '0;
        allocation_req_q <= '0;

        agc_counter <= '0;
        age_agm_req      <= '0;
    
    // Accepting allocation request
    end else if (!busy & allocation_req_valid) begin
        busy             <= '1;
        allocation_req_q <= allocation_req;

        agc_counter      <= '0;
        age_agm_req      <= '0;
    
    end else if (busy && !done) begin
        agc_counter                 <= agc_counter + 1'b1;
        age_agm_req.allocated_cores <= age_agm_req.allocated_cores | allocated_core;
    
    // AGM accepting request with allocated AGCs
    end else if (|(age_agm_req_valid & age_agm_req_ready)) begin
        busy <= '0;
    end
end

for (genvar allocation_slot = 0; allocation_slot < age_pkg::MAX_AGC_PER_NODE; allocation_slot++) begin
    always_ff @(posedge core_clk or negedge resetn) begin
        if (!resetn) begin
            age_agm_req.coords_x [allocation_slot] <= '0;
            age_agm_req.coords_y [allocation_slot] <= '0;
            
        end else if (busy && !done && (agc_counter == allocation_slot)) begin
            age_agm_req.coords_x [allocation_slot] <= PRECISION_COL_OFFSET[$clog2(MESH_COLS)-1:0] + allocated_core_bin[3:0]; // % 16
            age_agm_req.coords_y [allocation_slot] <= allocated_core_bin[$clog2(AGC_COUNT_FIXED16)-1:4]; // div 16
        end
    end
end

// Keep snapshot of allocated aggregation cores when NSB request is accepted
// This accounts for race condition between AGC aggregation and message channel (aggregation manager)
//      sending nodeslot allocation packet to AGC

always_ff @(posedge core_clk or negedge resetn) begin
    if (!resetn) begin
        allocatable_cores <= '1;

    end else begin
        // This operation is 8 gates deep
        // done: 3 gates (agc_count bitwise AND with required_agcs), AND reduction, inverse
        // allocation_valid: 1 gate (done && !busy)

        allocatable_cores <= 
                            // Inverse and bitwise AND to drop cores being allocated
                            // But only drop when allocation is valid (i.e. busy && !done)
                            allocatable_cores & ~(allocated_core & {NUM_CORES{busy && !done}}) 
                            
                            // Bitwise OR to assert cores being deallocated
                            // But only assert when deallocation is valid
                            | (deallocation_cores & {NUM_CORES{deallocation_valid}});
    end
end

for (genvar agm = 0; agm < TOTAL_AGGREGATION_MANAGERS; agm++) begin
    assign age_agm_req_valid [agm] = busy && done && (allocation_req_q.fetch_tag == agm);
end

endmodule