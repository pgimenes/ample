.PHONY: modelsim verilator clean

# Default target
all: modelsim

modelsim:
	$(MAKE) -f Makefile.modelsim

verilator:
	$(MAKE) -f Makefile.verilator

clean:
	$(MAKE) -f Makefile.modelsim clean
	$(MAKE) -f Makefile.verilator clean
