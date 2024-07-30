import os
import pdb

from cocotb.utils import get_sim_time

from tb.utils.common import NodePrecision
from tb.utils.common import delay
from tb.tests.base_test import BaseTest
import logging


def get_log_level():
    log_level = os.environ.get('AMPLE_GRAPH_TB_LOG_LEVEL', 'INFO')
    if log_level == 'DEBUG':
        return logging.DEBUG
    elif log_level == 'INFO':
        return logging.INFO
    elif log_level == 'WARNING':
        return logging.WARNING
    elif log_level == 'ERROR':
        return logging.ERROR
    elif log_level == 'CRITICAL':
        return logging.CRITICAL
    else:
        return logging.INFO


async def graph_test_runner(dut):
    tolerance = float(os.environ.get('AMPLE_GRAPH_TB_TOLERANCE', 1))
    log_level = get_log_level()
    dut._log.setLevel(log_level)  # Set to the desired level (DEBUG, INFO, WARNING, ERROR, CRITICAL)

    nodeslot_count = int(os.environ.get('AMPLE_GRAPH_TB_NODESLOT_COUNT', 64))
    test = BaseTest(dut,nodeslot_count, tolerance)
    test.log_info(dut, "Starting Graph Test")

    model = test.load_jit_model()
    x_loaded,edge_index_loaded = test.load_graph()
    output = test.get_expected_outputs(model, x_loaded, edge_index_loaded)
    test.log_model_input(x_loaded)
    

    # Load nodeslot/register programming and start clocks/reset
    await test.initialize()

    await test.driver.axil_driver.axil_write(test.driver.nsb_regs["graph_config_node_count"], test.global_config["node_count"])
    layer_cycle_count = []
    for layer_idx, layer in enumerate(test.layers):
        await test.start_monitors()
        layer_features = output[layer_idx]
        dut._log.info(f"Starting layer {layer_idx+1}")
        outs = output[layer_idx]
        dut._log.debug(f"Layer Out Expected {outs}")

        # Load monitor
        test.load_layer_test(layer_features,layer_idx)
        
        # test.start_monitors()
        # Layer configuration
        await test.driver.program_layer_config(layer)

        # Weights fetch
        await test.driver.request_weights_fetch(precision=NodePrecision.FLOAT_32)
        dut._log.debug("Weights fetch done.")

        # Program nodeslots
        # await drive_nodeslots(test)
        await test.driver.axil_driver.axil_write(test.driver.nsb_regs["ctrl_start_nodeslot_fetch"], 1)

        await test.driver.wait_done_ack(
            done_reg = test.driver.nsb_regs["ctrl_start_nodeslot_fetch_done"],
            ack_reg = test.driver.nsb_regs["ctrl_start_nodeslot_fetch_done_ack"],
            tries = 10000
        )

        dut._log.debug("Nodeslot fetching done, waiting for nodeslots to be flushed.")
        initial_cycle = test.get_cycle_count()

        await test.flush_nodeslots(test)
        final_cycle = test.get_cycle_count()
        layer_cycle_count.append(int(final_cycle - initial_cycle))

        await test.end_test()

        if test.axi_monitor.empty_expected_layer_features():
            dut._log.info("All nodes written.")
        else:
            dut._log.error("Not all nodes not written.")

  
        test.dut._log.info(f"Layer {layer_idx+1} finished.")

        await delay(dut.regbank_clk, 10)

    stime = get_sim_time("ms")
  
    # await test.stop_monitors()
    test.dut._log.info(f"Test finished. Simulation time: {stime}ms.")
   

    with open(f"sim_time.txt", "w") as f:
        f.write(str(stime))

    with open(f"sim_cycles.txt", "w") as f:
        for idx,item in enumerate(layer_cycle_count):
            dut._log.info(f"Layer {idx} cycles taken: {item}")
            f.write(f"Layer {idx} cycles: {item}")
            f.write("\n")
