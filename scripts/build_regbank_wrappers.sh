python3.6 $FYP_DIR/scripts/update_regbanks.py
python3.10 $FYP_DIR/scripts/regbank_wrapper.py --regbank_name node_scoreboard_regbank
python3.10 $FYP_DIR/scripts/regbank_wrapper.py --regbank_name aggregation_engine_regbank
python3.10 $FYP_DIR/scripts/regbank_wrapper.py --regbank_name feature_transformation_engine_regbank
python3.10 $FYP_DIR/scripts/regbank_wrapper.py --regbank_name prefetcher_regbank
vivado -mode batch -source $FYP_DIR/hw/update_regbanks.tcl