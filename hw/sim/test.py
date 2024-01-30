import cocotb
from cocotb.triggers import RisingEdge, FallingEdge, Timer
from cocotb.clock import Clock
# from cocotbext.axi import AxiBus, AxiLiteMaster

import json
import os

base_path = os.environ.get("WORKAREA")

regbank_path = base_path + "/hw/build/regbanks"
ns_programming_file = base_path + "/hw/sim/layer_config/nodeslot_programming.json"
layer_config_file = base_path + "/hw/sim/layer_config/layer_config.json"

def load_regbank(dut, regbank):
    dut.log.info("Loading %s", regbank)
    json_path = os.path.join(regbank_path, regbank, regbank + "_regs.json")
    with open(json_path) as f:
        regbank = json.load(f)
    return regbank["registerMap"]["baseAddress"], {register["name"]: register for register in regbank["registerMap"]["registers"]}

def load_nodeslot_programming(dut):
    dut.log.info("Loading nodeslot programming")
    with open(ns_programming_file) as f:
        ns_programming = json.load(f)
    return ns_programming["nodeslots"]

def load_layer_config(dut):
    dut.log.info("Loading layer configuration")
    with open(layer_config_file) as f:
        layers = json.load(f)
    return layers["layers"]

async def drive_reset(dut):
    dut._log.info("Driving reset")
    dut.sys_rst = 1
    dut.regbank_resetn = 0
    for _ in range(50):
        await RisingEdge(dut.regbank_clk)
    dut._log.info("Reset done")
    dut.sys_rst = 0
    dut.regbank_resetn = 1

@cocotb.test()
async def graph_test(dut):

    dut.log.info("Starting Graph Test")

    # Drive clock, reset
    cocotb.start_soon(Clock(dut.sys_clk, 5, units="ns").start())
    cocotb.start_soon(Clock(dut.regbank_clk, 20, units="ns").start())

    await reset_axi_interface(dut)

    # Drive reset
    dut._log.info("Driving reset")
    dut.sys_rst = 1
    dut.regbank_resetn = 0
    for _ in range(50):
        await RisingEdge(dut.regbank_clk)
    dut._log.info("Reset done")
    dut.sys_rst = 0
    dut.regbank_resetn = 1

    dut.log.info("Starting wait after reset")
    for _ in range(10):
        await RisingEdge(dut.regbank_clk)
    dut.log.info("Done waiting after reset")

    nodeslots = load_nodeslot_programming(dut)
    layer = load_layer_config(dut)[0]

    dut.log.info("Loading register banks.")
    age_base_address, age_registers = load_regbank(dut, "aggregation_engine_regbank")
    fte_base_address, fte_registers = load_regbank(dut, "feature_transformation_engine_regbank")
    nsb_base_address, nsb_registers = load_regbank(dut, "node_scoreboard_regbank")
    prefetcher_base_address, prefetcher_registers = load_regbank(dut, "prefetcher_regbank")

    # dut._log.info("Define AXI Master")
    # axil_master = AxiLiteMaster(AxiBus.from_prefix(dut, "host_axil"), dut.regbank_clk, dut.regbank_resetn)

    dut._log.info("Setting weights fetch precision...")
    await axil_write(dut, nsb_base_address + nsb_registers["ctrl_fetch_layer_weights_precision"]["addressOffset"], 1)
    dut._log.info("Done.")

    delay(dut, 10)

    dut._log.info("Reading weights fetch precision...")
    data = await axil_read(dut, nsb_base_address + nsb_registers["ctrl_fetch_layer_weights_precision"]["addressOffset"])
    dut._log.info("Weights fetch precision reg has data %s", data)
    assert(data)

    await Timer(1000, units="ns")  # wait a bit
    await RisingEdge(dut.sys_clk)  # wait for falling edge/"negedge"

async def reset_axi_interface(dut):
    dut.host_axil_awvalid.value = 0
    dut.host_axil_awaddr.value = 0
    dut.host_axil_awprot.value = 0
    dut.host_axil_wvalid.value = 0
    dut.host_axil_wdata.value = 0
    dut.host_axil_wstrb.value = 15
    dut.host_axil_bready.value = 0
    dut.host_axil_arvalid.value = 0
    dut.host_axil_araddr.value = 0
    dut.host_axil_arprot.value = 0
    dut.host_axil_rready.value = 0

async def axil_write(dut, address, data):
    # Reset signals
    dut.host_axil_awvalid.value = 0
    dut.host_axil_awaddr.value = 0
    dut.host_axil_wvalid.value = 0
    dut.host_axil_wdata.value = 0
    dut.host_axil_bready.value = 0

    await RisingEdge(dut.regbank_clk)

    # AW phase
    dut.host_axil_awvalid.value = 1
    dut.host_axil_awaddr.value = address
    # Wait to accept address
    while(True):
        await RisingEdge(dut.regbank_clk)
        if (dut.host_axil_awready.value):
            break

    dut.host_axil_awvalid.value = 0

    # W phase
    dut.host_axil_wvalid.value = 1
    dut.host_axil_wdata.value = data
    # Wait to accept data
    while(True):
        await RisingEdge(dut.regbank_clk)
        if (dut.host_axil_wready.value):
            break

    dut.host_axil_wvalid.value = 0
    dut.host_axil_bready.value = 1
    while(True):
        await RisingEdge(dut.regbank_clk)
        if (dut.host_axil_bvalid.value):
            break

async def axil_read(dut, address):
    dut.host_axil_arvalid.value = 0
    dut.host_axil_araddr.value = 0
    dut.host_axil_arprot.value = 0
    dut.host_axil_rready.value = 0

    await RisingEdge(dut.regbank_clk)

    # AR phase
    dut.host_axil_arvalid.value = 1
    dut.host_axil_araddr.value = address

    # Wait to accept address
    while(True):
        await RisingEdge(dut.regbank_clk)
        if (dut.host_axil_arready.value):
            break

    # R phase
    dut.host_axil_arvalid.value = 0
    dut.host_axil_rready.value = 1

    # Wait to accept data
    while(True):
        await RisingEdge(dut.regbank_clk)
        if (dut.host_axil_rvalid.value):
            return dut.host_axil_rdata.value

async def delay(dut, cycles):
    for _ in range(cycles):
        await RisingEdge(dut.regbank_clk)