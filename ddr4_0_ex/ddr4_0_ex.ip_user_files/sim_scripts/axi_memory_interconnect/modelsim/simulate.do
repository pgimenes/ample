onbreak {quit -f}
onerror {quit -f}

vsim -voptargs="+acc" -t 1ps -L xpm -L fifo_generator_v13_2_5 -L axi_interconnect_v1_7_17 -L xil_defaultlib -L unisims_ver -L unimacro_ver -L secureip -lib xil_defaultlib xil_defaultlib.axi_memory_interconnect xil_defaultlib.glbl

do {wave.do}

view wave
view structure
view signals

do {axi_memory_interconnect.udo}

run -all

quit -force
