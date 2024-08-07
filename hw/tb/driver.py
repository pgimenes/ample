from enum import Enum

from tb.utils.axil_driver import AXILDriver
from tb.utils.common import NodePrecision, AggregationFunction
from tb.utils.common import delay

class Driver():
    def __init__(self, dut):
        self.dut = dut
        self.axil_driver = AXILDriver(dut)

        self.nsb_regs = {}
        self.age_regs = {}
        self.prefetcher_regs = {}
        self.fte_regs = {}

    async def program_layer_config(self, layer):
        
        self.dut._log.debug("Ready to program layer configuration")

        self.dut._log.debug("Layer: %s", layer)

        # Prefetcher register bank
        self.dut._log.debug("Programming prefetcher register bank layer configuration.")

        await self.axil_driver.axil_write(self.prefetcher_regs["layer_config_in_features"], layer["in_feature_count"])
        await self.axil_driver.axil_write(self.prefetcher_regs["layer_config_out_features"], layer["out_feature_count"])
        # Addresses
        await self.axil_driver.axil_write(self.prefetcher_regs["layer_config_adjacency_list_address_lsb"], layer["adjacency_list_address"])
        # await self.axil_driver.axil_write(self.prefetcher_regs["layer_config_in_messages_address_lsb"], layer["in_messages_address"])

        await self.axil_driver.axil_write(self.prefetcher_regs["layer_config_weights_address_lsb"], layer["weights_address"])
        await self.axil_driver.axil_write(self.prefetcher_regs["layer_config_in_messages_address_lsb"], layer["in_messages_address"])

        # TO DO: second precision weights

        # AGE register bank
        self.dut._log.debug("Programming AGE register bank layer configuration.")
        await self.axil_driver.axil_write(self.age_regs["layer_config_in_features"], layer["in_feature_count"])
        await self.axil_driver.axil_write(self.age_regs["layer_config_out_features"], layer["out_feature_count"])

        # FTE register bank

        self.dut._log.debug("Programming FTE register bank layer configuration.")
        await self.axil_driver.axil_write(self.fte_regs["layer_config_in_features"], layer["in_feature_count"])
        await self.axil_driver.axil_write(self.fte_regs["layer_config_out_features"], layer["out_feature_count"])

        #LSB and MSB bug potential TODO Split into MSB and LSB
        await self.axil_driver.axil_write(self.fte_regs["layer_config_out_features_address_lsb"], layer["out_messages_address"])

        # NSB register bank
        self.dut._log.debug("Programming NSB register bank layer configuration.")
        await self.axil_driver.axil_write(self.nsb_regs["layer_config_in_features"], layer["in_feature_count"])
        await self.axil_driver.axil_write(self.nsb_regs["layer_config_out_features"], layer["out_feature_count"])
        # Addresses
        await self.axil_driver.axil_write(self.nsb_regs["layer_config_adjacency_list_address_lsb"], layer["adjacency_list_address"])
        await self.axil_driver.axil_write(self.nsb_regs["layer_config_weights_address_lsb"], layer["weights_address"])
        # Wait counts
        await self.axil_driver.axil_write(self.nsb_regs["NSB_CONFIG_AGGREGATION_WAIT_COUNT"], layer["aggregation_wait_count"])
        #Aggregate Enable
        await self.axil_driver.axil_write(self.nsb_regs["layer_config_aggregate_enable"], layer["aggregate_enable"])

        # Set config valid
        await self.axil_driver.axil_write(self.nsb_regs["layer_config_valid"], 1)


    async def program_nodeslot(self, programming, id):
        await self.write(self.nsb_regs["nsb_nodeslot_node_id"] + 4*id, programming["node_id"])
        await self.write(self.nsb_regs["nsb_nodeslot_neighbour_count"] + 4*id, programming["neighbour_count"])
        await self.write(self.nsb_regs["nsb_nodeslot_precision"] + 4*id, NodePrecision[programming["precision"]].value)
        await self.axil_driver.axil_write(self.nsb_regs["nsb_nodeslot_config_make_valid"] + 4*id, 1)

    # Timing optimization: skip writes to registers with value equal to their reset (0)
    async def write(self, address, data):
        if (data == 0):
            return
        else:
            await self.axil_driver.axil_write(address, data)

    async def wait_done_ack(self, done_reg, ack_reg, tries=100):
        done = False
        for _ in range(tries):
            done = await self.axil_driver.axil_read(done_reg)
            if (done):
                # Weights fetch done, write to ACK
                self.dut._log.debug(f"{done_reg} register is asserted")
                await self.axil_driver.axil_write(ack_reg, 1)
                break
            await delay(self.dut.regbank_clk, 10)
        
        if (not done):
            self.dut._log.info(f"Tried reading {done_reg} register {tries} times, but still not done. Simulation hung?")


    async def request_weights_fetch(self, precision=NodePrecision["FLOAT_32"]):
        self.dut._log.debug("Requesting weights fetch for precision %s.", precision.name)
        await self.axil_driver.axil_write(self.nsb_regs["ctrl_fetch_layer_weights_precision"], precision.value)
        await self.axil_driver.axil_write(self.nsb_regs["CTRL_FETCH_LAYER_WEIGHTS"], 1)

        await self.wait_done_ack(
            done_reg = self.nsb_regs["CTRL_FETCH_LAYER_WEIGHTS_DONE"],
            ack_reg = self.nsb_regs["CTRL_FETCH_LAYER_WEIGHTS_DONE_ACK"],
            tries = 100000
        )
