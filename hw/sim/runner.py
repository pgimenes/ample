import cocotb

from tb.runners.graph_test_runner import graph_test_runner

@cocotb.test()
async def graph_test(dut):
    await graph_test_runner(dut)