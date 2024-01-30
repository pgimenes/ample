for i in range(256):
    signal_name = f"node_state_{i}"
    signal_path = f"sim:/top_wrapper_tb/top_i/node_scoreboard_i/nsb_nodeslot_node_state_state[{i}]"
    add_wave_command = f"add wave -noupdate -group NSB -label {signal_name} {signal_path}"
    print(add_wave_command)