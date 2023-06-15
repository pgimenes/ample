# Launch synthesis
launch_runs synth_1 -jobs 40
wait_on_run synth_1 -quiet

# Open design and generate timing report
open_run synth_1 -name synth_1
report_timing_summary -delay_type min_max -report_unconstrained -check_timing_verbose -max_paths 10 -input_pins -routable_nets -name timing_1