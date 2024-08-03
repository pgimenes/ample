import os
import pdb
# from tqdm import tqdm
from tqdm.asyncio import tqdm as tqdm_asyncio

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
    test = BaseTest(dut,nodeslot_count,tolerance)
    
    test.log_info(dut, "Starting Graph Test")

    model  = test.load_jit_model()
    inputs = test.load_graph()
    output = test.get_expected_outputs(model,inputs)
    test.log_model_input(inputs)
    
    # Load nodeslot/register programming and start clocks/reset
    await test.initialize()

    #if layer edge - load edge count


    layer_cycle_count = []
    # print(output)

    # for layer_idx, layer in tqdm_asyncio(enumerate(test.layers), total=len(test.layers)):
    for layer_idx, layer in enumerate(test.layers):

        await test.start_monitors()
        # print('layer features')

        layer_features = output[layer_idx]
        dut._log.info(f"Starting layer {layer_idx}")
        dut._log.debug(f"Layer Out Expected {layer_features}")

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

        #Should only fetch every time nodeslots change
        # print(f"Layer {layer_idx} nodeslot count: {test.layers[layer_idx]['nodeslot_count']}")
        await test.driver.axil_driver.axil_write(test.driver.nsb_regs["graph_config_node_count"], test.layers[layer_idx]['nodeslot_count'])
       
        #Temp TODO program nodeslot start address for layer
        # print(f"Layer {layer_idx} nodeslot start address: {test.layers[layer_idx]['nodeslot_start_address']}")
        
        await test.driver.axil_driver.axil_write(test.driver.nsb_regs["ctrl_start_nodeslot_fetch_start_addr"], test.layers[layer_idx]['nodeslot_start_address'])


        await test.driver.axil_driver.axil_write(test.driver.nsb_regs["ctrl_start_nodeslot_fetch"], 1)

        await test.driver.wait_done_ack(
            done_reg = test.driver.nsb_regs["ctrl_start_nodeslot_fetch_done"],
            ack_reg = test.driver.nsb_regs["ctrl_start_nodeslot_fetch_done_ack"],
            tries = 10000
        )

        dut._log.debug("Nodeslot fetching done, waiting for nodeslots to be flushed.")
        # print('cycle start, layer:',layer_idx)
        initial_cycle = test.get_cycle_count()

        await test.flush_nodeslots(test)
        final_cycle = test.get_cycle_count()
        # print('cycle startend')

        layer_cycle_count.append(int(final_cycle - initial_cycle))

        await test.end_test()
        # assert test.axi_monitor.empty_expected_layer_features() == True, f"Not all nodeslots written back {layer_idx}"

        if test.axi_monitor.empty_expected_layer_features():
            dut._log.info("All nodes written.")
        else:
            dut._log.error("Not all nodes not written.")

  
        test.dut._log.info(f"Layer {layer_idx} finished.")

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
