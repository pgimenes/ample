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
        self.dut._log.info("Ready to program layer configuration")

        self.dut._log.info("Layer: %s", layer)

        # Prefetcher register bank
        self.dut._log.info("Programming prefetcher register bank layer configuration.")
        await self.axil_driver.axil_write(self.prefetcher_regs["layer_config_in_features"], layer["in_feature_count"])
        await self.axil_driver.axil_write(self.prefetcher_regs["layer_config_out_features"], layer["out_feature_count"])
        # Addresses
        await self.axil_driver.axil_write(self.prefetcher_regs["layer_config_adjacency_list_address_lsb"], layer["adjacency_list_address"])
        await self.axil_driver.axil_write(self.prefetcher_regs["layer_config_in_messages_address_lsb"], layer["in_messages_address"])
        await self.axil_driver.axil_write(self.prefetcher_regs["layer_config_weights_address_lsb"], layer["weights_address"])
        # TO DO: second precision weights

        # AGE register bank
        self.dut._log.info("Programming AGE register bank layer configuration.")
        await self.axil_driver.axil_write(self.age_regs["layer_config_in_features"], layer["in_feature_count"])
        await self.axil_driver.axil_write(self.age_regs["layer_config_out_features"], layer["out_feature_count"])

        # FTE register bank
        self.dut._log.info("Programming FTE register bank layer configuration.")
        await self.axil_driver.axil_write(self.fte_regs["layer_config_in_features"], layer["in_feature_count"])
        await self.axil_driver.axil_write(self.fte_regs["layer_config_out_features"], layer["out_feature_count"])

        # NSB register bank
        self.dut._log.info("Programming NSB register bank layer configuration.")
        await self.axil_driver.axil_write(self.nsb_regs["layer_config_in_features"], layer["in_feature_count"])
        await self.axil_driver.axil_write(self.nsb_regs["layer_config_out_features"], layer["out_feature_count"])
        # Addresses
        await self.axil_driver.axil_write(self.nsb_regs["layer_config_adjacency_list_address_lsb"], layer["adjacency_list_address"])
        await self.axil_driver.axil_write(self.nsb_regs["layer_config_in_messages_address_lsb"], layer["in_messages_address"])
        await self.axil_driver.axil_write(self.nsb_regs["layer_config_out_messages_address_lsb"], layer["out_messages_address"])
        await self.axil_driver.axil_write(self.nsb_regs["layer_config_weights_address_lsb"], layer["weights_address"])
        # Wait counts
        await self.axil_driver.axil_write(self.nsb_regs["NSB_CONFIG_AGGREGATION_WAIT_COUNT"], layer["aggregation_wait_count"])
        await self.axil_driver.axil_write(self.nsb_regs["NSB_CONFIG_TRANSFORMATION_WAIT_COUNT"], layer["transformation_wait_count"])

        # Set config valid
        await self.axil_driver.axil_write(self.nsb_regs["layer_config_valid"], 1)


    async def program_nodeslot(self, programming, id):
        await self.write(self.nsb_regs["nsb_nodeslot_node_id"] + 4*id, programming["node_id"])
        await self.write(self.nsb_regs["nsb_nodeslot_neighbour_count"] + 4*id, programming["neighbour_count"])
        await self.write(self.nsb_regs["nsb_nodeslot_precision"] + 4*id, NodePrecision[programming["precision"]].value)
        # await self.write(self.nsb_regs["nsb_nodeslot_aggregation_function"] + 4*id, AggregationFunction[programming["aggregation_function"]].value)
        await self.write(self.nsb_regs["nsb_nodeslot_adjacency_list_address_lsb"] + 4*id, programming["adjacency_list_address_lsb"])
        await self.write(self.nsb_regs["nsb_nodeslot_scale_factors_address_lsb"] + 4*id, programming["scale_factors_address_lsb"])
        await self.write(self.nsb_regs["nsb_nodeslot_out_messages_address_lsb"] + 4*id, programming["out_messages_address_lsb"])

        await self.axil_driver.axil_write(self.nsb_regs["nsb_nodeslot_config_make_valid"] + 4*id, 1)

    # Timing optimization: skip writes to registers with value equal to their reset (0)
    async def write(self, address, data):
        if (data == 0):
            return
        else:
            await self.axil_driver.axil_write(address, data)

    async def request_weights_fetch(self, precision=NodePrecision["FLOAT_32"]):
        self.dut._log.info("Requesting weights fetch for precision %s.", precision.name)
        await self.axil_driver.axil_write(self.nsb_regs["ctrl_fetch_layer_weights_precision"], precision.value)
        await self.axil_driver.axil_write(self.nsb_regs["CTRL_FETCH_LAYER_WEIGHTS"], 1)

        while(True):
            done = await self.axil_driver.axil_read(self.nsb_regs["CTRL_FETCH_LAYER_WEIGHTS_DONE"])
            if (done):
                break
            await delay(self.dut.regbank_clk, 10)

        # Weights fetch done, write to ACK
        await self.axil_driver.axil_write(self.nsb_regs["CTRL_FETCH_LAYER_WEIGHTS_DONE_ACK"], 1)
