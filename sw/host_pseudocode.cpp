
// host pseudocode

from enum import Enum

class Precision(Enum):
    FLOAT_32    = 0, FLOAT_16    = 1, FLOAT_8     = 2
    FIXED_32    = 3, FIXED_16    = 4, FIXED_8     = 5

dataset = 

def read_register (reg):
    return DATA[reg_to_addr_map[reg]]

def write_register (reg, idx, value):
    DATA[reg_to_addr_map[reg][idx]] = value

def write_scoreboard_register (reg, idx, value):
    // used for nodeslot registers since they are index by NS
    NODESLOT_SCOREBOARD[reg_to_addr_map[reg][idx]] = value

`define LAYER_IN_FEATURE_SIZE = 300
`define LAYER_OUT_FEATURE_SIZE = 300

while (pending_nodes.len > 0) {
    // pop node from pending queue
    node = pending_nodes.pop();

    // Assign the precision based on the neighbour count
    if node.in_neighbours > 300:
        node_precision = Precision(FLOAT_32);
    else if node.in_neighbours > 150:
        node_precision = Precision(FIXED_16)
    else:
        node_precision = Precision(FIXED_8);

    // Allocate memory for incoming messages
    node_incoming_messages = byte_list(node.neighbour_count * `LAYER_IN_FEATURE_SIZE * node_precision.byte_count);
    node_outgoing_messages = byte_list(node.neighbour_count * `LAYER_OUT_FEATURE_SIZE * node_precision.byte_count);

    // Store incoming messages in the required format
    for neighbour_id in node.neighbour_ids
        node_incoming_messages.append(cast_to_precision(FEATURES[neighbour_id], node_precision));

    // Choose a nodeslot
    evailable_nodeslots = read_register("NODE_SLOTS_EMPTY_MASK");
    chosen_nodeslot = choose_first(evailable_nodeslots);

    // Populate Nodeslot
    write_scoreboard_register("NODE_ID", chosen_nodeslot, node_id);
    write_scoreboard_register("PRECISION", chosen_nodeslot, node_precision);
    write_scoreboard_register("NEIGHBOUR_COUNT", chosen_nodeslot, node.neighbour_count);
    write_scoreboard_register("IN_MESSAGES_ADDR", chosen_nodeslot, &node_incoming_messages);
    write_scoreboard_register("OUT_MESSAGES_ADDR", chosen_nodeslot, &node_outgoing_messages);
    
    // Trigger GraphBoost
    write_register("NODESLOT_SCOREBOARD_MAKE_VALID", 1 << chosen_nodeslot);
}