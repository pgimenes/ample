.PHONY: modelsim verilator clean

# Default target
all: modelsim


build:
	$(MAKE) -f Makefile.modelsim build

run_sim:
	$(MAKE) -f Makefile.modelsim run_sim

run_simgui:
	$(MAKE) -f Makefile.modelsim run_sim GUI=1


verilator:
	$(MAKE) -f Makefile.verilator

clean:
	$(MAKE) -f Makefile.modelsim clean
	$(MAKE) -f Makefile.verilator clean
