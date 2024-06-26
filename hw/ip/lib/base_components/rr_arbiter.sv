//
// Round robin arbiter
// Units that want to access a shared resource assert their bit in the 'request'
// bitmap. The arbiter picks a unit and sets the appropriate bit in the one hot
// signal grant_oh. This does not register grant_oh, which is valid the same
// cycle as the request. The update_lru signal indicates the granted unit has
// used the resource and should not receive access again until other requestors
// have had a turn.
//

module rr_arbiter #(
    parameter NUM_REQUESTERS = 4
) (
    input                                      clk,
    input                                      resetn,
    
    input        [NUM_REQUESTERS - 1:0]        request,
    input                                      update_lru,
    
    output logic [NUM_REQUESTERS - 1:0]        grant_oh,
    output logic [$clog2(NUM_REQUESTERS)-1:0]  grant_bin
);

    logic[NUM_REQUESTERS - 1:0] priority_oh_nxt;
    logic[NUM_REQUESTERS - 1:0] priority_oh;
  	
  	localparam BIT_IDX_WIDTH = $clog2(NUM_REQUESTERS);

    // always_comb
    // begin
    //     for (int grant_idx = 0; grant_idx < NUM_REQUESTERS; grant_idx++)
    //     begin
    //         grant_oh[grant_idx] = 0;
    //         for (int priority_idx = 0; priority_idx < NUM_REQUESTERS; priority_idx++)
    //         begin
    //             logic is_granted;
    //             is_granted = request[grant_idx] & priority_oh[priority_idx];
              
    //           	for (logic[BIT_IDX_WIDTH - 1:0] bit_idx = priority_idx[BIT_IDX_WIDTH - 1:0]; bit_idx != grant_idx[BIT_IDX_WIDTH - 1:0]; bit_idx++)
    //             begin 
    //                 is_granted &= !request[bit_idx];
    //             end

    //             grant_oh[grant_idx] |= is_granted;
    //         end
    //     end
    // end

    // // rotate left
    // assign priority_oh_nxt = {grant_oh[NUM_REQUESTERS - 2:0], grant_oh[NUM_REQUESTERS - 1]};

    // always_ff @(posedge clk or negedge resetn)
    // begin
    //     if (!resetn)
    //         priority_oh <= 1;
    //     else if (request != 0 && update_lru)
    //     begin
    //         priority_oh <= priority_oh_nxt;
    //     end
    // end

    always_comb begin
        grant_oh = '0;
        grant_bin = '0;

        for (int i = 0; i < NUM_REQUESTERS; i++) begin
            if (request[i]) begin
                grant_oh = ({{(NUM_REQUESTERS-1){1'b0}}, 1'b1} << i);
                grant_bin = i;
                break;
            end
        end
    end

    // onehot_to_binary_comb #(
    //     .INPUT_WIDTH (NUM_REQUESTERS)
    // ) oh2bin (
    //     .input_data         (grant_oh),
    //     .output_data        (grant_bin)
    // );

endmodule
