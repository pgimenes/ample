onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib axil_master_vip_opt

do {wave.do}

view wave
view structure
view signals

do {axil_master_vip.udo}

run -all

quit -force
