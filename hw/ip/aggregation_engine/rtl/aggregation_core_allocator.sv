
module aggregation_core_allocator #(
    parameter NUM_CORES = age_pkg::TOTAL_AGGREGATION_CORES
) (
    input  logic                 core_clk,
    input  logic                 resetn,
    
    input  logic [NUM_CORES-1:0] cores_free,
    input  logic                 accept_allocation,
    output logic [NUM_CORES-1:0] allocated_core,

    input  logic                 deallocation_valid,
    input  logic [NUM_CORES-1:0] deallocation_cores
);

// Keep track of allocated cores that haven't yet received allocation packet
logic [NUM_CORES-1:0] allocatable_cores;

// TO DO: replace with sequential round robin or multiple-grant round-robin
rr_arbiter #(
    .NUM_REQUESTERS (NUM_CORES)
) arbiter_i (
    .clk            (core_clk),
    .resetn         (resetn),
    .request        (cores_free & allocatable_cores),
    .update_lru     (accept_allocation),
    .grant_oh       (allocated_core)
);

// Keep snapshot of allocated aggregation cores when NSB request is accepted
// This accounts for race condition between AGC aggregation and message channel (aggregation manager)
//      sending nodeslot allocation packet to AGC

always_ff @(posedge core_clk or negedge resetn) begin
    if (!resetn) begin
        allocatable_cores <= '1;
    
    // When accepting NSB request, AGC has been allocated
    end else if (accept_allocation) begin
        allocatable_cores <= allocatable_cores & (~allocated_core);

    // When sending response to NSB, aggregation has completed for that nodeslot and AGCs have been cleared
    end else if (deallocation_valid) begin // valid only response
        allocatable_cores <= allocatable_cores & (~deallocation_cores);
    end
end

endmodule