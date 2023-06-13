
import os
import json

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge

import tb.scoreboard as sb
from tb.driver import Driver

class BaseTest:
    def __init__(self, dut, base_path=None):
        self.dut = dut

        self.driver = Driver(dut)

        self.scoreboard = sb.Scoreboard()
        self.nodeslot_programming = {}
        self.layers = {}

        self.nsb_regbank = {}
        self.age_regbank = {}
        self.prefetcher_regbank = {}
        self.fte_regbank = {}

        # Paths
        self.base_path = base_path if base_path is not None else os.environ.get("FYP_DIR")
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

    def load_regbank(self, regbank):
        json_path = os.path.join(self.regbank_path, regbank, regbank + "_regs.json")
        self.dut.log.info("Loading %s from %s", regbank, json_path)
        with open(json_path) as f:
            data = json.load(f)
        return data

    def load_regbanks(self):
        self.dut.log.info("Loading register banks.")

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
        self.dut.log.info("Loading nodeslot programming")
        with open(self.nodeslot_programming_file) as f:
            ns_programming = json.load(f)
        self.nodeslot_programming = ns_programming["nodeslots"]

    def load_layer_config(self):
        self.dut.log.info("Loading layer configuration")
        with open(self.layer_config_file) as f:
            layers = json.load(f)
        self.layers = layers["layers"]

    # Test steps

    def program_layer_config (self, layer_id=0):
        self.driver.program_layer_config(self.layers[layer_id])

    # CLOCK AND RESET

    async def start_clocks(self):
        cocotb.start_soon(Clock(self.dut.sys_clk, 5, units="ns").start())
        cocotb.start_soon(Clock(self.dut.regbank_clk, 20, units="ns").start())

    async def drive_reset(self):
        self.dut._log.info("Driving reset")
        self.dut.sys_rst = 1
        self.dut.regbank_resetn = 0
        for _ in range(50):
            await RisingEdge(self.dut.regbank_clk)
        self.dut._log.info("Reset done")
        self.dut.sys_rst = 0
        self.dut.regbank_resetn = 1

        self.dut.log.info("Starting wait after reset")
        for _ in range(10):
            await RisingEdge(self.dut.regbank_clk)
        self.dut.log.info("Done waiting after reset")