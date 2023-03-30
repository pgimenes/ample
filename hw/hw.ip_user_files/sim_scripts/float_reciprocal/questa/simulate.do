onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib float_reciprocal_opt

do {wave.do}

view wave
view structure
view signals

do {float_reciprocal.udo}

run -all

quit -force
