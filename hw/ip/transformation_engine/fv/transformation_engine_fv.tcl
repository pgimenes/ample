clear -all

analyze -clear

analyze -sv \
    ../include/sys_array_pkg.sv \
    ../rtl/transformation_engine.sv \
    ../rtl/fixed_point_mac.sv \
    ../rtl/mac.sv \
    ../rtl/sys_array_pe.sv \
    ../rtl/sys_array.sv \
    +define+FORMAL_MAC

elaborate -bbox_mul 64 -top transformation_engine

# Setup global clocks and resets
clock core_clk
reset -expression !(rstn)

# Setup current task environment
task -set <embedded>
set_proofgrid_max_local_jobs 4
set_proofgrid_max_jobs 4
set_reset_max_iterations 2000