FYP_PROJECT ?= fuzzy_carnival_base

UNIT ?= fyp_top
TB_TOP ?= $(UNIT)_tb_top

WORKLIB ?= work

XVLOG_OPTS := --relax --define FLOAT_MAC=1
XVHDL_OPTS := --relax
XELAB_OPTS := --relax --debug typical --mt auto
XSIM_OPTS := --onfinish stop -tclbatch $(FYP_PROJECT)/xsim/cmd.tcl

SIM_ARGS := work_opt
TESTNAME ?= CORE_TEST

COVON ?= 0
GUI ?= 0
WATCHDOG ?= 1

# ============================== HANDLE UNIT COVERAGE
# ifeq ($(COVON), 1)
#   COMP_OPTS := $(COMP_OPTS) +cover +fcover
#   SIM_ARGS := $(SIM_ARGS) -coverage -voptargs="+cover=bcefst"
# endif

ifeq ($(GUI), 1)
  XSIM_OPTS := $(XSIM_OPTS) --gui
endif

all:
	worklib parse elab sim

worklib:
	@echo "====================================="
	@echo "Generating work library"
	@echo "====================================="

parse:
	@echo "====================================="
	@echo "Parsing Design Files"
	@echo "====================================="
	
	xvlog $(XVLOG_OPTS) \
		-prj $(FYP_PROJECT)/xsim/vlog.prj \
		2>&1 | tee $(FYP_PROJECT)/xsim/compile.log

	xvhdl $(XVHDL_OPTS) \
		-prj $(FYP_PROJECT)/xsim/vhdl.prj \
		2>&1 | tee $(FYP_PROJECT)/xsim/compile.log

elab:
	@echo "====================================="
	@echo "Perform elaboration stage"
	@echo "====================================="

	xelab $(XELAB_OPTS) \
	-L microblaze_v11_0_2 -L xil_defaultlib -L lib_cdc_v1_0_2 -L proc_sys_reset_v5_0_13 -L lmb_v10_v3_0_10 -L lmb_bram_if_cntlr_v4_0_17 -L blk_mem_gen_v8_4_4 -L iomodule_v3_1_5 -L xbip_utils_v3_0_10 -L axi_utils_v2_0_6 -L xbip_pipe_v3_0_6 -L xbip_dsp48_wrapper_v3_0_4 -L xbip_dsp48_addsub_v3_0_6 -L xbip_dsp48_multadd_v3_0_6 -L xbip_bram18k_v3_0_6 -L mult_gen_v12_0_16 -L floating_point_v7_1_9 -L generic_baseblocks_v2_1_0 -L axi_infrastructure_v1_1_0 -L axi_register_slice_v2_1_20 -L fifo_generator_v13_2_5 -L axi_data_fifo_v2_1_19 -L axi_crossbar_v2_1_21 -L util_vector_logic_v2_0_1 -L axi_protocol_converter_v2_1_20 -L axi_clock_converter_v2_1_19 -L axi_dwidth_converter_v2_1_20 -L unisims_ver -L unimacro_ver -L secureip -L xpm \
	--snapshot fc_base_top_tb_top xil_defaultlib.fc_base_top_tb_top xil_defaultlib.glbl \
	-log elaborate.log

sim:
	@echo "====================================="
	@echo "Launch simulation"
	@echo "====================================="

	xsim fc_base_top_tb_top \
		$(XSIM_OPTS) \
		-key {Behavioral:sim_1:Functional:fc_base_top_tb_top} \
		-protoinst "protoinst_files/bd_f308.protoinst" -protoinst "protoinst_files/axi_interconnect_bd.protoinst" -protoinst "protoinst_files/bd_9054.protoinst" \
		-log simulate.log

clean:
	@echo "====================================="
	@echo "Cleaning simulation payloads"
	@echo "====================================="