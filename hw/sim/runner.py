import cocotb
import sys
import os
workarea = os.environ.get('WORKAREA')

if workarea is None:
    raise EnvironmentError("WORKAREA environment variable is not set")

sys.path.append(workarea)

from tb.runners.graph_test_runner import graph_test_runner
from cocotb.log import SimLog
@cocotb.test()
async def graph_test(dut):
    log = SimLog("cocotb.runner")
    await graph_test_runner(dut)
