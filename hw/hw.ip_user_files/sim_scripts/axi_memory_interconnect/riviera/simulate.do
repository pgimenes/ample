onbreak {quit -force}
onerror {quit -force}

asim -t 1ps +access +r +m+axi_memory_interconnect -L xilinx_vip -L xpm -L fifo_generator_v13_2_5 -L axi_interconnect_v1_7_17 -L xil_defaultlib -L xilinx_vip -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.axi_memory_interconnect xil_defaultlib.glbl

do {wave.do}

view wave
view structure

do {axi_memory_interconnect.udo}

run -all

endsim

quit -force
