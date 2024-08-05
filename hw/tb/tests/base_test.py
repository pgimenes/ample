
import os
import json
import logging

import torch

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge
from cocotb.utils import get_sim_time

import tb.scoreboard as sb
from tb.driver import Driver

from tb.utils.common import NodePrecision

from tb.variant import Variant
from tb.monitors.age_monitor import AGE_Monitor
from tb.monitors.nsb_monitor import NSB_Monitor
from tb.monitors.prefetcher_monitor import Prefetcher_Monitor
# from tb.monitors.fte_monitor import FTE_Monitor
# from tb.monitors.mase_cocotb.stream_monitor import StreamMonitor


from tb.utils.common import NodeState, NodePrecision
from tb.utils.common import delay, allocate_lsb

from tb.monitors.axi_write_master_monitor import AXIWriteMasterMonitor

from tb.monitors.bm_monitor import BM_Monitor

class BaseTest:
    def __init__(self, dut, nodeslot_count,tolerance, base_path=None):
        self.dut = dut
        self.driver = Driver(dut)
        self.nodeslot_count = nodeslot_count
        self.variant = Variant()
        self.tolerance = tolerance
        self.clk_period = 5
        # self.age_monitor = AGE_Monitor(dut.top_i.aggregation_engine_i, self.variant)
        self.nsb_monitor = NSB_Monitor(dut.top_i.node_scoreboard_i, self.variant)
        # self.prefetcher_monitor = Prefetcher_Monitor(dut.top_i.prefetcher_i, self.variant)

        # self.fte_monitor = FTE_Monitor(dut.top_i.transformation_engine_i, self.variant)

        # self.data_out_0_monitor = StreamMonitor(
        #         dut.sys_clk,
        #         dut.top_i.transformation_engine_i.axi_write_master_data,
        #         dut.top_i.transformation_engine_i.axi_write_master_data_valid,
        #         dut.top_i.transformation_engine_i.axi_write_master_data_valid,
        #         check=False,
        #     )

        self.axi_monitor = AXIWriteMasterMonitor(
            dut=dut,
            clk=dut.sys_clk,
            req_valid=dut.top_i.transformation_engine_i.axi_write_master_req_valid,
            req_ready=dut.top_i.transformation_engine_i.axi_write_master_req_ready,
            start_address=dut.top_i.transformation_engine_i.axi_write_master_req_start_address,
            req_len=dut.top_i.transformation_engine_i.axi_write_master_req_len,
            data_valid=dut.top_i.transformation_engine_i.axi_write_master_data_valid,
            data=dut.top_i.transformation_engine_i.transformation_core_axi_write_master_data_unreversed,
            pop=dut.top_i.transformation_engine_i.axi_write_master_pop,
            resp_valid=dut.top_i.transformation_engine_i.axi_write_master_resp_valid,
            resp_ready=dut.top_i.transformation_engine_i.axi_write_master_resp_ready,
            tolerance = self.tolerance 
            # log_level = #connect logging level from main test
        )


        # Buffer Manager Monitors
        # self.float_bm_monitors = [None] * self.variant.aggregation_buffer_slots
        # self.fixed_bm_monitors = [None] * self.variant.aggregation_buffer_slots
        # for id in range(self.variant.aggregation_buffer_slots):
        #         self.dut._log.info("%s", dir(dut.top_i.aggregation_engine_i.precision_block[0].aggregation_mesh_i))
        #         self.dut._log.info(f"Creating monitor for BM {id}")
        #         self.float_bm_monitors[id] = BM_Monitor(dut.top_i.aggregation_engine_i.precision_block[0].aggregation_mesh_i.bm_block[id].buffer_manager_i,
        #                                                         self.variant, NodePrecision.FLOAT_32.value, id)



        self.scoreboard = sb.Scoreboard(nodeslot_count=64)
        self.nodeslot_programming = {}
        self.edge_programming = {}

        self.global_config = {}
        self.layers = {}

        self.nsb_regbank = {}
        self.age_regbank = {}
        self.prefetcher_regbank = {}
        self.fte_regbank = {}

        # Paths
        self.base_path = base_path if base_path is not None else os.environ.get("WORKAREA")
        self.regbank_path = self.base_path + "/hw/build/regbanks"
        self.nodeslot_programming_file = self.base_path + "/hw/sim/layer_config/nodeslot_programming.json"
        self.layer_config_file = self.base_path + "/hw/sim/layer_config/layer_config.json"

    async def initialize(self):
        # Load nodeslot programming and layer config
        self.load_nodeslot_programming()
        # print(self.load_edge_programming())
        
        self.load_layer_config()
        self.load_regbanks()

        # Drive clock, reset
        await self.start_clocks()
        await self.driver.axil_driver.reset_axi_interface()
        await self.drive_reset()



        # Start monitors
        # self.nsb_monitor.running = True
        # self.nsb_monitor.start()
        # self.age_monitor.start()
        # self.prefetcher_monitor.start()
        # self.fte_monitor.start()

        # for id in range(self.variant.aggregation_buffer_slots):
        #     print(f"Binding monitor for BM {id}")
        #     self.float_bm_monitors[id].start()


    def load_layer_test(self,layer_features,layer_idx):
        self.dut._log.debug("Loading expected nodes into monitor")
        self.axi_monitor.load_layer_features(self.nodeslot_programming,layer_features,self.layers[layer_idx],self.global_config)

    async def start_monitors(self):

        self.axi_monitor.running = True
        cocotb.start_soon(self.axi_monitor.monitor_write_transactions())

        # self.fte_monitor.start()
        # cocotb.fork(self.axi_monitor._monitor_write_transactions())
        
    async def stop_monitors(self):
        # self.fte_monitor.stop()
        # self.axi_monitor._monitor_write_transactions.kill()
        pass

    async def end_test(self):
        # Stop monitors
        # self.nsb_monitor.running = False
        self.axi_monitor.running = False

        # await self.nsb_monitor.stop()
        # self.age_monitor.stop()
        # self.fte_monitor.stop()
        # self.data_out_0_monitor.kill()
        # self.axi_monitor.end()
        # pass

    def load_regbank(self, regbank):
        json_path = os.path.join(self.regbank_path, regbank, regbank + "_regs.json")
        self.dut._log.debug("Loading %s from %s", regbank, json_path)
        with open(json_path) as f:
            data = json.load(f)
        return data

    def load_regbanks(self):
        self.dut._log.debug("Loading register banks.")

        nsb_regmap = self.load_regbank("node_scoreboard_regbank")["registerMap"]
        prefetcher_regmap = self.load_regbank("prefetcher_regbank")["registerMap"]
        age_regmap = self.load_regbank("aggregation_engine_regbank")["registerMap"]
        fte_regmap = self.load_regbank("feature_transformation_engine_regbank")["registerMap"]

        self.nsb_regbank = {register["name"]: register for register in nsb_regmap["registers"]}
        self.prefetcher_regbank = {register["name"]: register for register in prefetcher_regmap["registers"]}
        self.age_regbank = {register["name"]: register for register in age_regmap["registers"]}
        self.fte_regbank = {register["name"]: register for register in fte_regmap["registers"]}

        self.driver.nsb_regs = {register["name"]: nsb_regmap["baseAddress"] + register["addressOffset"] for register in self.nsb_regbank.values()}
        self.driver.prefetcher_regs = {register["name"]: prefetcher_regmap["baseAddress"] + register["addressOffset"] for register in self.prefetcher_regbank.values()}
        self.driver.age_regs = {register["name"]: age_regmap["baseAddress"] + register["addressOffset"] for register in self.age_regbank.values()}
        self.driver.fte_regs = {register["name"]: fte_regmap["baseAddress"] + register["addressOffset"] for register in self.fte_regbank.values()}

    def load_nodeslot_programming(self):
        self.dut._log.debug("Loading nodeslot programming")
        with open(self.nodeslot_programming_file) as f:
            ns_programming = json.load(f)
        self.nodeslot_programming = ns_programming
        # return ns_programming


    # def load_edge_programming(self):
    #     self.dut._log.debug("Loading edge programming")
    #     with open(self.nodeslot_programming_file) as f:
    #         ns_programming = json.load(f)
    #     self.nodeslot_programming = ns_programming["edges"]
    #     return ns_programming["edges"]

    def load_layer_config(self):
        self.dut._log.debug("Loading layer configuration")
        with open(self.layer_config_file) as f:
            data = json.load(f)
        self.global_config = data["global_config"]
        self.layers = data["layers"]
        return data["layers"]

    # Test steps

    def program_layer_config (self, layer_id=0):
        self.driver.program_layer_config(self.layers[layer_id])

    async def wait_end(self, timeout=1, timeout_unit="ms"):
        while True:
            await RisingEdge(self.clk)
            break

    # CLOCK AND RESET

    async def start_clocks(self):
        cocotb.start_soon(Clock(self.dut.sys_clk, self.clk_period, units="ns").start())
        cocotb.start_soon(Clock(self.dut.regbank_clk, self.clk_period, units="ns").start())

    async def drive_reset(self):
        self.dut._log.debug("Driving reset")
        self.dut.sys_rst.value = 1
        self.dut.regbank_resetn.value = 0
        for _ in range(50):
            await RisingEdge(self.dut.regbank_clk)
        self.dut._log.debug("Reset done")
        self.dut.sys_rst.value = 0
        self.dut.regbank_resetn.value = 1

        self.dut._log.debug("Starting wait after reset")
        for _ in range(10):
            await RisingEdge(self.dut.regbank_clk)
        self.dut._log.debug("Done waiting after reset")


    async def drive_nodeslots(self,test):

        self.dut._log.debug("Starting nodeslot programming.")
        free_mask = "1" * self.nodeslot_count
        # print('ns_programmingI',self.nodeslot_programming)
        for ns_programming in self.nodeslot_programming:
            # print('ns_programmingII',ns_programming)
            # Skip nodeslots with no neighbours
            if (ns_programming["neighbour_count"] == 0):
                continue

            # Read empty_mask if all previously free nodeslots have been programmed
            if (free_mask == "0"*self.nodeslot_count):
                self.dut._log.debug("Waiting for free nodeslot.")
                while ("1" not in free_mask):
                    free_mask = ''
                    for i in range(0, int(self.nodeslot_count/32)):
                        empty_mask = await self.driver.axil_driver.axil_read(self.driver.nsb_regs["status_nodeslots_empty_mask_" + str(i)])
                        free_mask = empty_mask.binstr + free_mask
                    # self.dut._log.debug("Free nodeslots: %s", free_mask)

            # Check nodeslot range based on precision
            if (ns_programming["precision"] == "FLOAT_32"):
                chosen_ns = allocate_lsb(free_mask, bit_range=range(0, self.nodeslot_count))
            # elif (ns_programming["precision"] == "FIXED_8"):
            #     chosen_ns = allocate_lsb(free_mask, bit_range=range(16, self.nodeslot_count))
            else:
                raise ValueError(f"Unknown precision: {ns_programming['precision']}")

            if (chosen_ns is not None):
                ml = list(free_mask)
                ml[-(chosen_ns+1)] = '0'
                free_mask = ''.join(ml)

            self.dut._log.debug("Ready to program node ID %s into nodeslot %s.", ns_programming["node_id"], chosen_ns)

            await test.driver.program_nodeslot(ns_programming, chosen_ns)
            self.scoreboard.set_state(chosen_ns, NodeState["PROG_DONE"])
            self.scoreboard.set_programming(chosen_ns, ns_programming)

        self.dut._log.info("Nodeslot programming done.")



    async def flush_nodeslots(self,test):
        # Wait for work to finish
        self.dut._log.debug("Waiting for nodeslots to be empty.")
        while(True):
            # Build free mask
            free_mask = ''
            for i in range(0, int(self.nodeslot_count/32)):
                empty_mask = await self.driver.axil_driver.axil_read(self.driver.nsb_regs["status_nodeslots_empty_mask_" + str(i)])
                free_mask = empty_mask.binstr + free_mask
            
            # self.dut._log.debug("Free nodeslots: %s", free_mask)

            if (free_mask == "1" * self.nodeslot_count):
                break
            
            await delay(self.dut.regbank_clk, 10)

    def load_jit_model(self,model_path = '/home/aw1223/ip/agile/model.pt'):
        model = torch.jit.load(model_path)
        return model


    def load_graph(self,graph_path = '/home/aw1223/ip/agile/graph.pth'):
        graph = torch.load(graph_path)
        input_data = graph['input_data']
        x_loaded = input_data['x']
        edge_index_loaded = input_data['edge_index']

        # Check if edge attributes are present and load them if they are
        edge_attr_loaded = input_data.get('edge_attr', None)
        
        return (x_loaded, edge_index_loaded, edge_attr_loaded)
        

    def get_expected_outputs(self,model,data):
        ####Remove bias from the model, TODO Add biases####
        state_dict = model.state_dict()
        for name, param in state_dict.items():
            # print(name,param,'name,param')
            if 'bias' in name:
                # Reset the bias tensor to all zeros
                state_dict[name] = torch.zeros_like(param)

        model.load_state_dict(state_dict)
        
        x, edge_index, edge_attr = data
        # print('data')
        # print(x, edge_index, edge_attr)

        # edge_attr = self.trained_graph.dataset.edge_attr  # Edge attributes tensor
        # data = (x,edge_index,edge_attr) 

        model_input = (x, edge_index)
        if edge_attr is not None:
            model_input = model_input + (edge_attr,)  

        model.eval()
        with torch.no_grad():
            # if edge_attr is not None:
            output = model(*model_input)
            # else:
            #     output = model(x, edge_index)
            # output = model(x, edge_index, edge_attr) if edge_attr is not None else model(x, edge_index)
            # a = b
        del model

        return output
    
    def log_info(self,dut, message, border_char='*', width=60):
        border = border_char * width
        empty_line = border_char + ' ' * (width - 2) + border_char
        formatted_message = f"{border}\n{empty_line}\n"
        formatted_message += f"{border_char} {message.center(width - 4)} {border_char}\n"
        formatted_message += f"{empty_line}\n{border}"
        
        self.dut._log.info(formatted_message)

    def log_model_input(self, data):
        # x = data.get('x')
        # edge_index = data.get('edge_index')
        # edge_attr = data.get('edge_attr', None)
        
        #Temp change for when there is no edge_attr
        x, edge_index, edge_attr = data

        self.dut._log.debug("Input Tensors:")

        # Log node features (x)
        for idx, x_input in enumerate(x):
            self.dut._log.debug(f"Node Feature {idx}:")
            self.dut._log.debug(x_input)
            self.dut._log.debug("\n")

        # Log edge index
        self.dut._log.debug("Edge Index:")
        self.dut._log.debug(edge_index)
        self.dut._log.debug("\n")

        # Log edge attributes if they are provided
        if edge_attr is not None:
            self.dut._log.debug("Edge Attributes:")
            for idx, attr in enumerate(edge_attr):
                self.dut._log.debug(f"Edge Attribute {idx}:")
                self.dut._log.debug(attr)
                self.dut._log.debug("\n")


    def get_cycle_count(self,):
        current_time_ns = get_sim_time(units='ns')
        cycle_count = current_time_ns // self.clk_period 
        return cycle_count






