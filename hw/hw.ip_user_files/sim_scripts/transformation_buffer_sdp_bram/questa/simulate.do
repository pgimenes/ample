onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib transformation_buffer_sdp_bram_opt

do {wave.do}

view wave
view structure
view signals

do {transformation_buffer_sdp_bram.udo}

run -all

quit -force
