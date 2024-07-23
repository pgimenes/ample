
from cocotb.triggers import RisingEdge, Timer, Event
from cocotb.utils import get_sim_time

from tb.utils.common import NodeState, NodePrecision
from tb.utils.common import delay, allocate_lsb
from tb.tests.base_test import BaseTest
import pdb
# from tb.monitors.mase_cocotb.stream_monitor import StreamMonitor

# from sdk.models.models import GCN_Model, GAT_Model, GraphSAGE_Model, GIN_Model, GCN_MLP_Model, MLP_Model
# from sdk.models.models import GCN_Model, GAT_Model, GraphSAGE_Model, GIN_Model, GCN_MLP_Model, MLP_Model
# from sdk.graphs.matrix_graph import MatrixGraph
# from sdk.graphs.karate_club import KarateClubGraph
# from sdk.graphs.random_graph import RandomGraph
# from sdk.graphs.planetoid_graph import PlanetoidGraph
# from sdk.graphs.large_graphs import RedditGraph, FlickrGraph, YelpGraph, AmazonProductsGraph

# import onnx
import torch

NODESLOT_COUNT = 64 #Load from initialisation

async def drive_nodeslots(test):

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
                test.dut._log.debug("Free nodeslots: %s", free_mask)

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

    test.dut._log.info("Nodeslot programming done.")

async def flush_nodeslots(test):
    # Wait for work to finish
    test.dut._log.info("Waiting for nodeslots to be empty.")
    while(True):
        # Build free mask
        free_mask = ''
        for i in range(0, int(NODESLOT_COUNT/32)):
            empty_mask = await test.driver.axil_driver.axil_read(test.driver.nsb_regs["status_nodeslots_empty_mask_" + str(i)])
            free_mask = empty_mask.binstr + free_mask
        
        test.dut._log.debug("Free nodeslots: %s", free_mask)

        if (free_mask == "1" * NODESLOT_COUNT):
            break
        
        await delay(test.dut.regbank_clk, 10)

def load_jit_model(model_path = '/home/aw1223/ip/agile/model.pt'):
    model = torch.jit.load("/home/aw1223/ip/agile/model.pt")
    return model


def load_graph(graph_path = '/home/aw1223/ip/agile/graph.pth'):
    graph = torch.load('/home/aw1223/ip/agile/graph.pth')
    # Access the saved inputs
    input_data = graph['input_data']
    x_loaded = input_data['x']
    edge_index_loaded = input_data['edge_index']

    return x_loaded,edge_index_loaded


def get_expected_outputs(model, x, edge_index):
    ####Remove bias from the model TODO Add biases####
    state_dict = model.state_dict()
    for name, param in state_dict.items():
        if 'bias' in name:
            # Reset the bias tensor to all zeros
            state_dict[name] = torch.zeros_like(param)

    model.load_state_dict(state_dict)
    ###################################################
    model.eval()
    with torch.no_grad():
        output = model(x, edge_index)

    return output

async def graph_test_runner(dut):
    # global sim_running_event

    # sim_running_event.set()
    dut._log.info("Starting Graph Test")
    dut._log.info("*********************************************************")
    dut._log.info("")
    dut._log.info("*******************Starting Graph Test*******************")
    dut._log.info("")
    dut._log.info("*********************************************************")

    test = BaseTest(dut)

    model = load_jit_model()
    x_loaded,edge_index_loaded = load_graph()
    output = get_expected_outputs(model, x_loaded, edge_index_loaded)
    
    dut._log.debug(f"Input ")
    for idx,item in enumerate(x_loaded):
        dut._log.debug(idx)
        dut._log.debug(item)


    dut._log.debug(f"Output {output}")

    del model


    # Load nodeslot/register programming and start clocks/reset
    await test.initialize()

    await test.driver.axil_driver.axil_write(test.driver.nsb_regs["graph_config_node_count"], test.global_config["node_count"])

    for layer_idx, layer in enumerate(test.layers):
        await test.start_monitors()

        
        layer_features = output[layer_idx]
        dut._log.info(f"Starting layer {layer_idx}")
        outs = output[layer_idx]
        dut._log.debug(f"Layer Out Expected {outs}")

        # Load monitor
        test.load_layer_test(layer_features)
        


        # test.start_monitors()
        # Layer configuration
        await test.driver.program_layer_config(layer)

        # Weights fetch
        await test.driver.request_weights_fetch(precision=NodePrecision.FLOAT_32)
        dut._log.info("Weights fetch done.")

        # Program nodeslots
        # await drive_nodeslots(test)
        await test.driver.axil_driver.axil_write(test.driver.nsb_regs["ctrl_start_nodeslot_fetch"], 1)
        

        await test.driver.wait_done_ack(
            done_reg = test.driver.nsb_regs["ctrl_start_nodeslot_fetch_done"],
            ack_reg = test.driver.nsb_regs["ctrl_start_nodeslot_fetch_done_ack"],
            tries = 10000
        )
        
        dut._log.info("Nodeslot fetching done, waiting for nodeslots to be flushed.")
        # test.fte_monitor.start = True
        await flush_nodeslots(test)
        # test.fte_monitor.start = False
        await test.end_test()

        if test.axi_monitor.empty_expected_layer_features():
            dut._log.info("All nodes written.")
        else:
            dut._log.info("Not all nodes not written.")

            # print(test.axi_monitor.expected_layer_features_by_address)


        test.dut._log.info("Layer finished.")
        # del test.axi_monitor

        await delay(dut.regbank_clk, 10)
    # test.axi_monitor.kill()
    # sim_running_event.clear()

    stime = get_sim_time("ms")
    # raise TestFailure("Finished")
    # await test.stop_monitors()
    test.dut._log.info(f"Test finished. Simulation time: {stime}ms.")

    # raise TestFailure("Finished")

    with open(f"sim_time.txt", "w") as f:
        f.write(str(stime))
    # 
    # a
    # await delay(dut.regbank_clk, 10000)
    # assert data_out_0_monitor.exp_queue.empty()
    # a


async def my_loop_test(dut):
    dut._log.info("Starting loop test")

    for _ in range(10):
        await RisingEdge(dut.clk)
        dut._log.info("Loop iteration")
        # Perform operations per iteration
        dut.input_signal <= ~dut.input_signal
    
    dut._log.info("Ending loop test")