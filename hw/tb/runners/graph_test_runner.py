
from cocotb.triggers import RisingEdge, Timer

from tb.utils.common import NodeState, NodePrecision
from tb.utils.common import delay, allocate_lsb
from tb.tests.base_test import BaseTest

async def graph_test_runner(dut):
    dut._log.info("Starting Graph Test")

    test = BaseTest(dut)

    # Load nodeslot/register programming and start clocks/reset
    await test.initialize()

    for layer in test.layers:
        # Layer configuration
        await test.driver.program_layer_config(layer)

        # Weights fetch
        await test.driver.request_weights_fetch(precision=NodePrecision.FLOAT_32)
        await test.driver.request_weights_fetch(precision=NodePrecision.FIXED_8)

        # Program nodeslots
        test.dut._log.info("Starting nodeslot programming.")
        for ns_programming in test.nodeslot_programming:

            # Skip nodeslots with no neighbours
            if (ns_programming["neighbour_count"] == 0):
                continue

            test.dut._log.info("Waiting for free nodeslot.")
            while(True):
                empty_mask = await test.driver.axil_driver.axil_read(test.driver.nsb_regs["status_nodeslots_empty_mask_lsb"])
                bin_str = empty_mask.binstr
                test.dut._log.debug("Free nodeslots: %s", bin_str)

                # Check nodeslot range based on precision
                if (ns_programming["precision"] == "FLOAT_32"):
                    ns_id = allocate_lsb(bin_str, bit_range=range(0, 16))
                elif (ns_programming["precision"] == "FIXED_8"):
                    ns_id = allocate_lsb(bin_str, bit_range=range(16, 64))
                else:
                    raise ValueError(f"Unknown precision: {ns_programming['precision']}")

                if (ns_id is not None):
                    break

            test.dut._log.info("Ready to program node ID %s into nodeslot %s.", ns_programming["node_id"], ns_id)

            await test.driver.program_nodeslot(ns_programming, ns_id)
            await delay(dut.sys_clk, 10)

            test.scoreboard.set_state(ns_id, NodeState["PROG_DONE"])
            test.scoreboard.set_programming(ns_id, ns_programming)

        # Wait for work to finish
        test.dut._log.info("Nodeslot programming done. Waiting for nodeslots to be empty.")
        while(True):
            empty_mask = await test.driver.axil_driver.axil_read(test.driver.nsb_regs["status_nodeslots_empty_mask_lsb"])
            if (empty_mask == 0xFFFFFFFF):
                break
            await delay(dut.regbank_clk, 10)

        test.dut._log.info("Layer finished.")
        await delay(dut.regbank_clk, 10)

    test.dut._log.info("Test finished.")
    test.end_test()