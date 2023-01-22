add_files -fileset sources_1 ip/aggregation_engine/rtl
add_files -fileset sources_1 ip/aggregation_engine/regbank
add_files -fileset sim_1 ip/aggregation_engine/tb

add_files -fileset sources_1 ip/lib/

add_files -fileset sources_1 ip/top/rtl
add_files -fileset sim_1 ip/top/tb

add_files -fileset sources_1 ip/transformation_engine/rtl
add_files -fileset sources_1 ip/transformation_engine/include
add_files -fileset sim_1 ip/transformation_engine/tb

# Add packages at top of compile order