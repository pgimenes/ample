onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /top/sys_clk
add wave -noupdate /top/sys_rst
add wave -noupdate /top/regbank_clk
add wave -noupdate /top/regbank_resetn
add wave -noupdate -group AXI-L /top/host_axil_awaddr
add wave -noupdate -group AXI-L /top/host_axil_awprot
add wave -noupdate -group AXI-L /top/host_axil_awvalid
add wave -noupdate -group AXI-L /top/host_axil_awready
add wave -noupdate -group AXI-L /top/host_axil_wdata
add wave -noupdate -group AXI-L /top/host_axil_wstrb
add wave -noupdate -group AXI-L /top/host_axil_wvalid
add wave -noupdate -group AXI-L /top/host_axil_bready
add wave -noupdate -group AXI-L /top/host_axil_araddr
add wave -noupdate -group AXI-L /top/host_axil_arprot
add wave -noupdate -group AXI-L /top/host_axil_arvalid
add wave -noupdate -group AXI-L /top/host_axil_rready
add wave -noupdate -group AXI-L /top/host_axil_wready
add wave -noupdate -group AXI-L /top/host_axil_bresp
add wave -noupdate -group AXI-L /top/host_axil_bvalid
add wave -noupdate -group AXI-L /top/host_axil_arready
add wave -noupdate -group AXI-L /top/host_axil_rdata
add wave -noupdate -group AXI-L /top/host_axil_rresp
add wave -noupdate -group AXI-L /top/host_axil_rvalid
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {1011 ps}
