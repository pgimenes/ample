clear -all
analyze -clear
analyze -sv ../rtl/axi_read_master.sv
analyze -sv axi_read_master_fv_intf.sv
elaborate -bbox_mul 64 -top axi_read_master

# Setup global clocks and resets
clock clk
reset -expression !(resetn)

# Setup task
task -set <embedded>
set_proofgrid_max_jobs 4
set_proofgrid_max_local_jobs 4

# Assumptions
# =====================================

# Launch proof
# prove -all