onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib fixed4_upsampler_opt

do {wave.do}

view wave
view structure
view signals

do {fixed4_upsampler.udo}

run -all

quit -force
