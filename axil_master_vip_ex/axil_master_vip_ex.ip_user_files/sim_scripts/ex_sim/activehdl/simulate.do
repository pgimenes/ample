onbreak {quit -force}
onerror {quit -force}

asim -t 1ps +access +r +m+ex_sim -L xilinx_vip -L axi_infrastructure_v1_1_0 -L xil_defaultlib -L axi_vip_v1_1_6 -L xilinx_vip -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.ex_sim xil_defaultlib.glbl

do {wave.do}

view wave
view structure

do {ex_sim.udo}

run -all

endsim

quit -force
