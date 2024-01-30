
from cocotb.triggers import RisingEdge, Timer

from tb.utils.common import NodeState, NodePrecision
from tb.utils.common import delay, allocate_lsb
from tb.tests.base_test import BaseTest

NODESLOT_COUNT = 256

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
        # await test.driver.request_weights_fetch(precision=NodePrecision.FIXED_8)

        # Program nodeslots
        test.dut._log.info("Starting nodeslot programming.")
        free_mask = "1" * NODESLOT_COUNT
        
        for ns_programming in test.nodeslot_programming:

            # Skip nodeslots with no neighbours
            if (ns_programming["neighbour_count"] == 0):
                continue

            # Read empty_mask if all previously free nodeslots have been programmed
            if (free_mask == "0"*NODESLOT_COUNT):
                test.dut._log.info("Waiting for free nodeslot.")
                while ("1" not in free_mask):
                    free_mask = ''
                    for i in range(0, int(NODESLOT_COUNT/32)):
                        empty_mask = await test.driver.axil_driver.axil_read(test.driver.nsb_regs["status_nodeslots_empty_mask_" + str(i)])
                        free_mask = empty_mask.binstr + free_mask
                    test.dut._log.info("Free nodeslots: %s", free_mask)

            # Check nodeslot range based on precision
            if (ns_programming["precision"] == "FLOAT_32"):
                chosen_ns = allocate_lsb(free_mask, bit_range=range(0, NODESLOT_COUNT))
            # elif (ns_programming["precision"] == "FIXED_8"):
            #     chosen_ns = allocate_lsb(free_mask, bit_range=range(16, NODESLOT_COUNT))
            else:
                raise ValueError(f"Unknown precision: {ns_programming['precision']}")

            if (chosen_ns is not None):
                ml = list(free_mask)
                ml[-(chosen_ns+1)] = '0'
                free_mask = ''.join(ml)

            test.dut._log.info("Ready to program node ID %s into nodeslot %s.", ns_programming["node_id"], chosen_ns)

            await test.driver.program_nodeslot(ns_programming, chosen_ns)
            test.scoreboard.set_state(chosen_ns, NodeState["PROG_DONE"])
            test.scoreboard.set_programming(chosen_ns, ns_programming)

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
    await test.end_test()