onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib buffer_bram_opt

do {wave.do}

view wave
view structure
view signals

do {buffer_bram.udo}

run -all

quit -force
