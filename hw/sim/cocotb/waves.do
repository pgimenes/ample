add wave -noupdate /top/sys_clk
add wave -noupdate /top/sys_rst
add wave -noupdate /top/regbank_clk
add wave -noupdate /top/regbank_resetn

add wave -noupdate -group AXI-L sim:/top/host_axil_awvalid
add wave -noupdate -group AXI-L sim:/top/host_axil_awready
add wave -noupdate -group AXI-L sim:/top/host_axil_awaddr
add wave -noupdate -group AXI-L sim:/top/host_axil_awprot
add wave -noupdate -group AXI-L sim:/top/host_axil_wvalid
add wave -noupdate -group AXI-L sim:/top/host_axil_wready
add wave -noupdate -group AXI-L sim:/top/host_axil_wdata
add wave -noupdate -group AXI-L sim:/top/host_axil_wstrb
add wave -noupdate -group AXI-L sim:/top/host_axil_bvalid
add wave -noupdate -group AXI-L sim:/top/host_axil_bready
add wave -noupdate -group AXI-L sim:/top/host_axil_bresp
add wave -noupdate -group AXI-L sim:/top/host_axil_arvalid
add wave -noupdate -group AXI-L sim:/top/host_axil_arready
add wave -noupdate -group AXI-L sim:/top/host_axil_araddr
add wave -noupdate -group AXI-L sim:/top/host_axil_arprot
add wave -noupdate -group AXI-L sim:/top/host_axil_rvalid
add wave -noupdate -group AXI-L sim:/top/host_axil_rready
add wave -noupdate -group AXI-L sim:/top/host_axil_rdata
add wave -noupdate -group AXI-L sim:/top/host_axil_rresp

add wave -noupdate sim:/top/node_scoreboard_i/nsb_nodeslot_node_state_state

TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0