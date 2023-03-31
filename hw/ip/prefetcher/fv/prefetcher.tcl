clear -all
analyze -clear

analyze -sv ../../include/top_pkg.sv
analyze -sv ../include/prefetcher_pkg.sv

analyze -sv ../../lib/rtl/axi_read_master.sv
analyze -verilog ../../lib/rtl/ultraram.v +define+FORMAL

analyze -sv ../rtl/ultraram_fifo.sv

analyze -sv ../rtl/prefetcher_fetch_tag.sv
analyze -sv prefetcher_fetch_tag_fv_intf.sv

analyze -sv ../rtl/prefetcher.sv
analyze -sv prefetcher_fv_intf.sv

elaborate -bbox_mul 64 -top prefetcher_fetch_tag

# Setup global clocks and resets
clock core_clk
reset -expression !(resetn)

# Setup task
task -set <embedded>
set_proofgrid_max_jobs 4
set_proofgrid_max_local_jobs 4

# Assumptions
# =====================================

assume {nsb_prefetcher_req.req_opcode == 1 || nsb_prefetcher_req.req_opcode == 2}
assume {deallocation_valid == 0}

# To support MS2: drop this assumption for later milestones
assume {nsb_prefetcher_req.neighbour_count < 10'd65}

# Launch proof
# prove -all