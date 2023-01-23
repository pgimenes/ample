add_files -fileset sources_1 ip/aggregation_engine/rtl
add_files -fileset sources_1 ip/aggregation_engine/regbank
add_files -fileset sim_1 ip/aggregation_engine/tb

add_files -fileset sources_1 ip/controller/rtl
add_files -fileset sim_1 ip/controller/tb

add_files -fileset sources_1 ip/output_buffer/rtl
add_files -fileset sim_1 ip/output_buffer/tb

add_files -fileset sources_1 ip/prefetcher/rtl
add_files -fileset sim_1 ip/prefetcher/tb

add_files -fileset sources_1 ip/lib/

add_files -fileset sources_1 ip/top/rtl
add_files -fileset sim_1 ip/top/tb

add_files -fileset sources_1 ip/transformation_engine/rtl
add_files -fileset sources_1 ip/transformation_engine/include
add_files -fileset sim_1 ip/transformation_engine/tb

add_files -fileset sources_1 ip/weight_buffer/rtl
add_files -fileset sim_1 ip/weight_buffer/tb

# Add packages at top of compile order