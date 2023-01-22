onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib axi_memory_interconnect_opt

do {wave.do}

view wave
view structure
view signals

do {axi_memory_interconnect.udo}

run -all

quit -force
