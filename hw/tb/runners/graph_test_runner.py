
from cocotb.triggers import RisingEdge, Timer

from tb.utils.common import node_state_e, precision_e, aggregation_function_e
from tb.tests.base_test import BaseTest

async def graph_test_runner(dut):
    dut.log.info("Starting Graph Test")

    test = BaseTest(dut)

    # Load nodeslot/register programming and start clocks/reset
    await test.initialize()

    for layer in test.layers:
        # Layer configuration
        await test.driver.program_layer_config(layer)

        # Weights fetch
        await test.driver.request_weights_fetch(precision=precision_e.FLOAT_32)

        # Program nodeslots
        test.dut.log.info("Starting nodeslot programming.")
        for ns_programming in test.nodeslots:
            ns_id = test.scoreboard.get_empty_nodeslot()
            test.dut.log.info("Ready to program node ID %s into nodeslot %s.", ns_programming["node_id"], ns_id)
            await test.driver.program_nodeslot(ns_programming, ns_id)
            test.scoreboard.set_state(ns_id, node_state_e.PROG_DONE)

    await Timer(1000, units="ns")
    await RisingEdge(dut.sys_clk)