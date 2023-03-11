clear -all
analyze -clear
analyze -sv ../rtl/register_staller_simple.sv
analyze -sv register_staller_simple_intf.sv
elaborate -bbox_mul 64 -top register_staller_simple

# Setup global clocks and resets
clock core_clk
reset -expression !(resetn)

# Setup task
task -set <embedded>
set_proofgrid_max_jobs 4
set_proofgrid_max_local_jobs 4

# Assumptions
# =====================================

# Launch proof
# prove -all