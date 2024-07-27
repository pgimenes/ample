import age_pkg::*;
import noc_pkg::*;

module aggregation_core_allocator #(
    parameter NUM_CORES            = top_pkg::TRANSFORMATION_CHANNELS * top_pkg::AGGREGATION_CHANNELS,
    parameter NUM_MANAGERS         = top_pkg::TRANSFORMATION_CHANNELS,
    parameter AGGREGATION_COLUMNS  = top_pkg::AGGREGATION_CHANNELS,
    
    // TO DO: replace this with runtime parameter
    parameter ALLOCATION_MODE = age_pkg::AGC_ALLOCATION_MODE_STATIC
) (
    input  logic                                           core_clk,
    input  logic                                           resetn,

    // Allocation request
    input  logic                                           allocation_req_valid,
    output logic                                           allocation_req_ready,
    input  top_pkg::NSB_AGE_REQ_t                          allocation_req,

    // Generated AGM request
    output logic [NUM_MANAGERS-1:0]                        agm_req_valid,
    input  logic [NUM_MANAGERS-1:0]                        agm_req_ready,
    output age_pkg::AGE_AGM_REQ_t                          agm_req,
    
    // For sequential RR allocator
    input  logic [NUM_CORES-1:0]                           cores_free,
    input  logic [9:0]                                     layer_config_in_features_count,
    
    // Deallocation request
    input  logic                                           deallocation_valid,
    input  logic [NUM_CORES-1:0]                           deallocation_cores

);

// ==================================================================================================================================================
// Instances
// ==================================================================================================================================================

if (ALLOCATION_MODE == age_pkg::AGC_ALLOCATION_MODE_SEQUENTIAL_RR) begin

    aggregation_core_allocator_sequential_rr #(
        .NUM_CORES           (NUM_CORES),
        .NUM_MANAGERS        (NUM_MANAGERS),
        .AGGREGATION_COLUMNS (AGGREGATION_COLUMNS)
    ) aggregation_core_allocator_sequential_rr_i (
        .core_clk,
        .resetn,
        .allocation_req_valid,
        .allocation_req_ready,
        .allocation_req,
        .agm_req_valid,
        .agm_req_ready,
        .agm_req,
        .cores_free,
        .layer_config_in_features_count,
        .deallocation_valid,
        .deallocation_cores
    
    );

end

// ==================================================================================================================================================
// Logic
// ==================================================================================================================================================

if (ALLOCATION_MODE == age_pkg::AGC_ALLOCATION_MODE_STATIC) begin
    for (genvar agm = 0; agm < NUM_MANAGERS; agm++) begin
        assign agm_req_valid [agm] = allocation_req_valid && (allocation_req.nodeslot % NUM_MANAGERS == agm); // && (allocation_req_q.fetch_tag == (NUM_MANAGERS * PRECISION[$bits(top_pkg::NODE_PRECISION_e)-1:0] + agm))
    end
    assign allocation_req_ready = agm_req_ready[allocation_req.nodeslot % NUM_MANAGERS];

    always_comb begin
        agm_req.nsb_req = allocation_req;
        agm_req.required_agcs = layer_config_in_features_count[9:4] + (|layer_config_in_features_count[3:0] ? 1'b1 : '0);

        // Mask of allocated cores, size NUM_CORES = (AGGREGATION_ROWS * AGGREGATION_COLUMNS)
        // Used later for deallocating AGCs when AGM is finished so they become available for next AGM
        // Not needed here since allocation is static
        agm_req.allocated_cores = '0;
    end

    for (genvar allocation_slot = 0; allocation_slot < age_pkg::MAX_AGC_PER_NODE; allocation_slot++) begin
        always_comb begin
            agm_req.coords_x [allocation_slot] = 1'b1 + allocation_slot;
            agm_req.coords_y [allocation_slot] = (allocation_req.nodeslot % NUM_MANAGERS);
        end
    end

end

endmodule