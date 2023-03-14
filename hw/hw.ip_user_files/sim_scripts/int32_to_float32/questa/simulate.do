onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib int32_to_float32_opt

do {wave.do}

view wave
view structure
view signals

do {int32_to_float32.udo}

run -all

quit -force
