
import os
import json

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge

import tb.scoreboard as sb
from tb.driver import Driver

from tb.utils.common import NodePrecision

from tb.variant import Variant
# from tb.monitors.age_monitor import AGE_Monitor
# from tb.monitors.nsb_monitor import NSB_Monitor
from tb.monitors.prefetcher_monitor import Prefetcher_Monitor
from tb.monitors.fte_monitor import FTE_Monitor

from tb.monitors.bm_monitor import BM_Monitor

class BaseTest:
    def __init__(self, dut, base_path=None):
        self.dut = dut

        self.driver = Driver(dut)

        self.variant = Variant()

        # self.age_monitor = AGE_Monitor(dut.top_i.aggregation_engine_i, self.variant)
        # self.nsb_monitor = NSB_Monitor(dut.top_i.node_scoreboard_i, self.variant)
        # self.prefetcher_monitor = Prefetcher_Monitor(dut.top_i.prefetcher_i, self.variant)
        # self.fte_monitor = FTE_Monitor(dut.top_i.transformation_engine_i, self.variant)

        # Buffer Manager Monitors
        # self.float_bm_monitors = [None] * self.variant.aggregation_buffer_slots
        # self.fixed_bm_monitors = [None] * self.variant.aggregation_buffer_slots
        # for id in range(self.variant.aggregation_buffer_slots):
        #         self.dut._log.info("%s", dir(dut.top_i.aggregation_engine_i.precision_block[0].aggregation_mesh_i))
        #         self.dut._log.info(f"Creating monitor for BM {id}")
        #         self.float_bm_monitors[id] = BM_Monitor(dut.top_i.aggregation_engine_i.precision_block[0].aggregation_mesh_i.bm_block[id].buffer_manager_i,
        #                                                         self.variant, NodePrecision.FLOAT_32.value, id)

        self.scoreboard = sb.Scoreboard(nodeslot_count=256)
        self.nodeslot_programming = {}
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
        self.load_layer_config()
        self.load_regbanks()

        # Drive clock, reset
        await self.start_clocks()
        await self.driver.axil_driver.reset_axi_interface()
        await self.drive_reset()

        # Start monitors
        # self.nsb_monitor.start()
        # self.age_monitor.start()
        # self.prefetcher_monitor.start()
        # self.fte_monitor.start()

        # for id in range(self.variant.aggregation_buffer_slots):
        #     print(f"Binding monitor for BM {id}")
        #     self.float_bm_monitors[id].start()

    async def end_test(self):
        # Stop monitors
        # self.nsb_monitor.stop()
        # self.age_monitor.stop()
        pass

    def load_regbank(self, regbank):
        json_path = os.path.join(self.regbank_path, regbank, regbank + "_regs.json")
        self.dut._log.info("Loading %s from %s", regbank, json_path)
        with open(json_path) as f:
            data = json.load(f)
        return data

    def load_regbanks(self):
        self.dut._log.info("Loading register banks.")

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
        self.dut._log.info("Loading nodeslot programming")
        with open(self.nodeslot_programming_file) as f:
            ns_programming = json.load(f)
        self.nodeslot_programming = ns_programming["nodeslots"]
        return ns_programming["nodeslots"]

    def load_layer_config(self):
        self.dut._log.info("Loading layer configuration")
        with open(self.layer_config_file) as f:
            layers = json.load(f)
        self.layers = layers["layers"]
        return layers["layers"]

    # Test steps

    def program_layer_config (self, layer_id=0):
        self.driver.program_layer_config(self.layers[layer_id])

    # CLOCK AND RESET

    async def start_clocks(self):
        cocotb.start_soon(Clock(self.dut.sys_clk, 5, units="ns").start())
        cocotb.start_soon(Clock(self.dut.regbank_clk, 5, units="ns").start())

    async def drive_reset(self):
        self.dut._log.info("Driving reset")
        self.dut.sys_rst = 1
        self.dut.regbank_resetn = 0
        for _ in range(50):
            await RisingEdge(self.dut.regbank_clk)
        self.dut._log.info("Reset done")
        self.dut.sys_rst = 0
        self.dut.regbank_resetn = 1

        self.dut._log.info("Starting wait after reset")
        for _ in range(10):
            await RisingEdge(self.dut.regbank_clk)
        self.dut._log.info("Done waiting after reset")