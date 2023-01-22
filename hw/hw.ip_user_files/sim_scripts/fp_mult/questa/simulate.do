onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib fp_mult_opt

do {wave.do}

view wave
view structure
view signals

do {fp_mult.udo}

run -all

quit -force
