onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib aggregation_buffer_sdp_bram_opt

do {wave.do}

view wave
view structure
view signals

do {aggregation_buffer_sdp_bram.udo}

run -all

quit -force
