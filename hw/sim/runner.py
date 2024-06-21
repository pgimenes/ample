import cocotb
import sys
sys.path.append('/home/aw1223/ip/agile')
from tb.runners.graph_test_runner import graph_test_runner

@cocotb.test()
async def graph_test(dut):
    await graph_test_runner(dut)