onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib fixed16_upsampler_opt

do {wave.do}

view wave
view structure
view signals

do {fixed16_upsampler.udo}

run -all

quit -force
