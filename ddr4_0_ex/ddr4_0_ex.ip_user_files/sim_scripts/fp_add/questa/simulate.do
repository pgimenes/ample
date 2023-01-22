onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib fp_add_opt

do {wave.do}

view wave
view structure
view signals

do {fp_add.udo}

run -all

quit -force
