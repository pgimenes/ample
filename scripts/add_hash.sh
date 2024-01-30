$WORKAREA/scripts/add_hash.py --source $WORKAREA/hw/ip/aggregation_engine/rtl/ --destination $WORKAREA/hw/build/ip/aggregation_engine/rtl
$WORKAREA/scripts/add_hash.py --source $WORKAREA/hw/ip/aggregation_engine/include/ --destination $WORKAREA/hw/build/ip/aggregation_engine/include
$WORKAREA/scripts/add_hash.py --source $WORKAREA/hw/ip/aggregation_engine/tb/ --destination $WORKAREA/hw/build/ip/aggregation_engine/tb

$WORKAREA/scripts/add_hash.py --source $WORKAREA/hw/ip/include --destination $WORKAREA/hw/build/ip/include

$WORKAREA/scripts/add_hash.py --source $WORKAREA/hw/ip/lib/arithmetic --destination $WORKAREA/hw/build/ip/lib/arithmetic
$WORKAREA/scripts/add_hash.py --source $WORKAREA/hw/ip/lib/arithmetic/aggregators --destination $WORKAREA/hw/build/ip/lib/arithmetic/aggregators
$WORKAREA/scripts/add_hash.py --source $WORKAREA/hw/ip/lib/axi --destination $WORKAREA/hw/build/ip/lib/axi
$WORKAREA/scripts/add_hash.py --source $WORKAREA/hw/ip/lib/base_components --destination $WORKAREA/hw/build/ip/lib/base_components
$WORKAREA/scripts/add_hash.py --source $WORKAREA/hw/ip/lib/buffers --destination $WORKAREA/hw/build/ip/lib/buffers
$WORKAREA/scripts/add_hash.py --source $WORKAREA/hw/ip/lib/buffers/hybrid_buffer --destination $WORKAREA/hw/build/ip/lib/buffers/hybrid_buffer
$WORKAREA/scripts/add_hash.py --source $WORKAREA/hw/ip/lib/systolic_modules --destination $WORKAREA/hw/build/ip/lib/systolic_modules

$WORKAREA/scripts/add_hash.py --source $WORKAREA/hw/ip/node_scoreboard/rtl --destination $WORKAREA/hw/build/ip/node_scoreboard/rtl
$WORKAREA/scripts/add_hash.py --source $WORKAREA/hw/ip/node_scoreboard/tb --destination $WORKAREA/hw/build/ip/node_scoreboard/tb
$WORKAREA/scripts/add_hash.py --source $WORKAREA/hw/ip/node_scoreboard/include --destination $WORKAREA/hw/build/ip/node_scoreboard/include

$WORKAREA/scripts/add_hash.py --source $WORKAREA/hw/ip/prefetcher/rtl --destination $WORKAREA/hw/build/ip/prefetcher/rtl
$WORKAREA/scripts/add_hash.py --source $WORKAREA/hw/ip/prefetcher/tb --destination $WORKAREA/hw/build/ip/prefetcher/tb
$WORKAREA/scripts/add_hash.py --source $WORKAREA/hw/ip/prefetcher/include --destination $WORKAREA/hw/build/ip/prefetcher/include

$WORKAREA/scripts/add_hash.py --source $WORKAREA/hw/ip/tb_lib --destination $WORKAREA/hw/build/ip/tb_lib
$WORKAREA/scripts/add_hash.py --source $WORKAREA/hw/ip/tb_lib --destination $WORKAREA/hw/build/ip/tb_lib

$WORKAREA/scripts/add_hash.py --source $WORKAREA/hw/ip/top/rtl --destination $WORKAREA/hw/build/ip/top/rtl
$WORKAREA/scripts/add_hash.py --source $WORKAREA/hw/ip/top/tb --destination $WORKAREA/hw/build/ip/top/tb

$WORKAREA/scripts/add_hash.py --source $WORKAREA/hw/ip/transformation_engine/rtl --destination $WORKAREA/hw/build/ip/transformation_engine/rtl