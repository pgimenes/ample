import age_pkg::*;
import noc_pkg::*;

module aggregation_core_allocator #(
    parameter NUM_CORES            = top_pkg::TRANSFORMATION_CHANNELS * top_pkg::AGGREGATION_CHANNELS,
    parameter NUM_MANAGERS         = top_pkg::TRANSFORMATION_CHANNELS,
    parameter AGGREGATION_COLUMNS  = top_pkg::AGGREGATION_CHANNELS
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
    output logic [NUM_MANAGERS-1:0]                        agm_req_valid,
    input  logic [NUM_MANAGERS-1:0]                        agm_req_ready,
    output age_pkg::AGE_AGM_REQ_t                          agm_req

);

logic                                         busy;
logic                                         done;

top_pkg::NSB_AGE_REQ_t                        allocation_req_q;

// Keep track of allocated cores that haven't yet received allocation packet
logic [NUM_CORES-1:0]                         allocatable_cores;

logic [$clog2(age_pkg::MAX_AGC_PER_NODE)-1:0] agc_counter;

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

    .grant_oh       (allocated_core),
    .grant_bin      (allocated_core_bin)
);

// ==================================================================================================================================================
// Logic
// ==================================================================================================================================================

always_comb begin
    // Static AGM req payloads
    agm_req.nsb_req = allocation_req_q;
    agm_req.required_agcs = layer_config_in_features_count[9:4] + (|layer_config_in_features_count[3:0] ? 1'b1 : '0);

    allocation_req_ready = !busy;
    done = (agc_counter == agm_req.required_agcs);
end

always_ff @(posedge core_clk or negedge resetn) begin
    if (!resetn) begin
        busy <= '0;
        allocation_req_q <= '0;

        agm_req.allocated_cores <= '0;
        agc_counter <= '0;

        // Accepting allocation request
    end else if (!busy & allocation_req_valid) begin
        busy             <= '1;
        allocation_req_q <= allocation_req;

        agm_req.allocated_cores <= '0;
        agc_counter      <= '0;
    
    end else if (busy && !done) begin
        agc_counter                 <= agc_counter + 1'b1;
        agm_req.allocated_cores <= agm_req.allocated_cores | allocated_core;
    
    // AGM accepting request with allocated AGCs
    end else if (|(agm_req_valid & agm_req_ready)) begin
        busy <= '0;
    end
end

for (genvar allocation_slot = 0; allocation_slot < age_pkg::MAX_AGC_PER_NODE; allocation_slot++) begin
    always_ff @(posedge core_clk or negedge resetn) begin
        if (!resetn) begin
            agm_req.coords_x [allocation_slot] <= '0;
            agm_req.coords_y [allocation_slot] <= '0;
            
        end else if (busy && !done && (agc_counter == allocation_slot)) begin
            agm_req.coords_x [allocation_slot] <= 1'b1 + (allocated_core_bin % AGGREGATION_COLUMNS); // TO DO: replace with AGGREGATION_COLS when merging with generalized aggregation mesh
            agm_req.coords_y [allocation_slot] <= allocated_core_bin / AGGREGATION_COLUMNS;
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

for (genvar agm = 0; agm < NUM_MANAGERS; agm++) begin
    assign agm_req_valid [agm] = busy && done && (allocation_req_q.nodeslot % NUM_MANAGERS == agm); // && (allocation_req_q.fetch_tag == (NUM_MANAGERS * PRECISION[$bits(top_pkg::NODE_PRECISION_e)-1:0] + agm))
end

endmodule