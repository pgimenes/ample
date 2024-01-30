
import top_pkg::*;

/*
 * 
 * 
 * 
 */

module buffer_manager_arbiter #(
    parameter AGGREGATION_BUFFER_SLOTS = top_pkg::AGGREGATION_BUFFER_SLOTS
) (
    input  logic core_clk,
    input  logic resetn,

    // Valid-ready interface from buffer managers
    input  logic [top_pkg::PRECISION_COUNT-1:0] [top_pkg::MESH_MULTIPLIER-1:0] [AGGREGATION_BUFFER_SLOTS-1:0]                                                       input_bm_set_node_id_valid,
    output logic [top_pkg::PRECISION_COUNT-1:0] [top_pkg::MESH_MULTIPLIER-1:0] [AGGREGATION_BUFFER_SLOTS-1:0]                                                       input_bm_set_node_id_ready,
    input  logic [top_pkg::PRECISION_COUNT-1:0] [top_pkg::MESH_MULTIPLIER-1:0] [AGGREGATION_BUFFER_SLOTS-1:0] [NODE_ID_WIDTH-1:0]                                   input_bm_set_node_id,
    
    input  logic [top_pkg::PRECISION_COUNT-1:0] [top_pkg::MESH_MULTIPLIER-1:0] [AGGREGATION_BUFFER_SLOTS-1:0]                                                       input_bm_write_enable,
    output logic [top_pkg::PRECISION_COUNT-1:0] [top_pkg::MESH_MULTIPLIER-1:0] [AGGREGATION_BUFFER_SLOTS-1:0]                                                       input_bm_write_ready,
    input  logic [top_pkg::PRECISION_COUNT-1:0] [top_pkg::MESH_MULTIPLIER-1:0] [AGGREGATION_BUFFER_SLOTS-1:0] [$clog2(top_pkg::AGGREGATION_BUFFER_WRITE_DEPTH)-1:0] input_bm_write_address,
    input  logic [top_pkg::PRECISION_COUNT-1:0] [top_pkg::MESH_MULTIPLIER-1:0] [AGGREGATION_BUFFER_SLOTS-1:0] [noc_pkg::PAYLOAD_DATA_WIDTH-1:0]                     input_bm_write_data,

    // AGGREGATION BUFFER SLOTS == AGGREGATION ROWS
    // Valid-only interface to buffer slots
    output logic [top_pkg::PRECISION_COUNT-1:0] [AGGREGATION_BUFFER_SLOTS-1:0]                                                       slot_set_node_id_valid,
    output logic [top_pkg::PRECISION_COUNT-1:0] [AGGREGATION_BUFFER_SLOTS-1:0] [NODE_ID_WIDTH-1:0]                                   slot_set_node_id,

    output logic [top_pkg::PRECISION_COUNT-1:0] [AGGREGATION_BUFFER_SLOTS-1:0]                                                       slot_write_enable,
    output logic [top_pkg::PRECISION_COUNT-1:0] [AGGREGATION_BUFFER_SLOTS-1:0] [$clog2(top_pkg::AGGREGATION_BUFFER_WRITE_DEPTH)-1:0] slot_write_address,
    output logic [top_pkg::PRECISION_COUNT-1:0] [AGGREGATION_BUFFER_SLOTS-1:0] [noc_pkg::PAYLOAD_DATA_WIDTH-1:0]                     slot_write_data,

    input  logic [top_pkg::PRECISION_COUNT-1:0] [top_pkg::MESH_MULTIPLIER-1:0] [AGGREGATION_BUFFER_SLOTS-1:0] buffer_manager_done
);

// ==================================================================================================================================================
// Declarations
// ==================================================================================================================================================

logic [top_pkg::PRECISION_COUNT-1:0] [AGGREGATION_BUFFER_SLOTS-1:0] [top_pkg::MESH_MULTIPLIER-1:0]         requesting_bms;
logic [top_pkg::PRECISION_COUNT-1:0] [AGGREGATION_BUFFER_SLOTS-1:0] [top_pkg::MESH_MULTIPLIER-1:0]         granted_bm_oh;
logic [top_pkg::PRECISION_COUNT-1:0] [AGGREGATION_BUFFER_SLOTS-1:0] [$clog2(top_pkg::MESH_MULTIPLIER)-1:0] granted_bm_bin;

logic [top_pkg::PRECISION_COUNT-1:0] [AGGREGATION_BUFFER_SLOTS-1:0] slot_busy;
logic [top_pkg::PRECISION_COUNT-1:0] [AGGREGATION_BUFFER_SLOTS-1:0] [$clog2(top_pkg::MESH_MULTIPLIER)-1:0] granted_bm_bin_q;

// ==================================================================================================================================================
// Instances
// ==================================================================================================================================================

for (genvar precision = 0; precision < top_pkg::PRECISION_COUNT; precision++) begin : precision_block_inst
    for (genvar slot = 0; slot < AGGREGATION_BUFFER_SLOTS; slot++) begin : slot_block_inst
        // For each slot, in each precision block, arbitrate among the BM's from each mesh attempting to write to it
        rr_arbiter #(
            .NUM_REQUESTERS(top_pkg::MESH_MULTIPLIER)
        ) bm_arb_per_slot (
            .clk        (core_clk),
            .resetn     (resetn),
            
            .request    (requesting_bms  [precision] [slot]),
            .update_lru (!slot_busy[precision][slot] && |requesting_bms [precision] [slot]),
            .grant_oh   (granted_bm_oh   [precision] [slot]),
            .grant_bin  (granted_bm_bin  [precision] [slot])
        );
    end : slot_block_inst
end : precision_block_inst

// ==================================================================================================================================================
// Logic
// ==================================================================================================================================================

for (genvar precision = 0; precision < top_pkg::PRECISION_COUNT; precision++) begin : precision_block_logic
    for (genvar slot = 0; slot < AGGREGATION_BUFFER_SLOTS; slot++) begin : slot_block_logic
        
        for (genvar bm = 0; bm < top_pkg::MESH_MULTIPLIER; bm++) begin : bm_block
            // Reshape set_node_id_valid tensor to create mask of requesting BMs for each precision and buffer slot
            assign requesting_bms [precision] [slot] [bm] = input_bm_set_node_id_valid [precision][bm][slot];

            // Handle buffer manager backpressure
            always_comb begin
                input_bm_set_node_id_ready [precision][bm][slot] = !slot_busy [precision][slot] && (bm == granted_bm_bin [precision][slot]);
                input_bm_write_ready [precision][bm][slot] = slot_busy [precision][slot] && (bm == granted_bm_bin_q [precision][slot]);
            end
        end : bm_block
    
        // Update slot_busy flag and granted_bm reg for each slot in each precision block when the first BM tries
        // to write to it
        always_ff @(posedge core_clk or negedge resetn) begin
            if (!resetn) begin
                slot_busy [precision] [slot]        <= '0;
                granted_bm_bin_q [precision] [slot] <= '0;
                
            end else if (!slot_busy [precision][slot] && |requesting_bms [precision][slot]) begin
                slot_busy [precision] [slot]        <= '1;
                granted_bm_bin_q [precision] [slot] <= granted_bm_bin  [precision][slot];
                
                // Reset the flag when the BM is done
            end else if (slot_busy [precision][slot] && buffer_manager_done [precision][granted_bm_bin_q[precision][slot]][slot]) begin
                slot_busy [precision] [slot] <= '0;
                
            end
        end
        
        // Drive each buffer slot in each aggregation mesh from the arbitration decision
        always_comb begin
            slot_set_node_id_valid [precision] [slot] = |requesting_bms [precision] [slot] && !slot_busy [precision][slot];
            slot_set_node_id [precision] [slot]       = input_bm_set_node_id [precision] [granted_bm_bin [precision] [slot]] [slot];
            
            // Write to each slot from the allocated mesh
            slot_write_enable [precision][slot]  = input_bm_write_enable  [precision] [granted_bm_bin [precision] [slot]] [slot];
            slot_write_address [precision][slot] = input_bm_write_address [precision] [granted_bm_bin [precision] [slot]] [slot];
            slot_write_data [precision][slot]    = input_bm_write_data    [precision] [granted_bm_bin [precision] [slot]] [slot];
        end
    end : slot_block_logic
end : precision_block_logic

endmodule