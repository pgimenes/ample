
from typing import Dict

from cocotb.queue import Queue
from cocotb.triggers import RisingEdge

from tb.monitor import Monitor
from tb.utils.common import NodePrecision

class AGE_Monitor (Monitor):
    def __init__(self, dut, variant):
        super().__init__(dut, variant)

        # Observation queues
        self.nsb_reqs = Queue[Dict[str, int]]()
        self.nsb_responses = Queue[Dict[str, int]]()
        self.message_channel_reqs = [Queue[Dict[str, int]]() for _ in range(self.message_channel_count)]
        self.scale_factors = [Queue[Dict[str, int]]() for _ in range(self.message_channel_count)]
        self.buffer_writes = [[Queue[Dict[str, int]]() for _ in range(self.aggregation_buffer_slots)] for _ in range (self.precision_count)]


    async def _run(self) -> None:
        while True:
            await RisingEdge(self.dut.core_clk)

            # NSB responses
            if (self.dut.nsb_age_resp_valid.value):
                data = {
                    "nodeslot": self.dut.nsb_age_resp.nodeslot
                }
                sampled_value = self._sample(data, self.nsb_responses)
                self.dut._log.info("Observed AGE response to NSB for Nodeslot: %d", data["nodeslot"].value)

            # Message Channel requests
            for mc in range(self.message_channel_count):
                if (self.dut.message_channel_req_valid[mc].value and self.dut.message_channel_req_ready[mc].value):
                    data = {
                        "nodeslot": self.dut.message_channel_req[mc].nodeslot,
                        "fetch_tag": self.dut.message_channel_req[mc].fetch_tag
                    }
                    _ = self._sample(data, self.message_channel_reqs[mc])
                    self.dut._log.info("Observed Message Channel request for Nodeslot: %d, Fetch Tag: %d", data["nodeslot"].value, data["fetch_tag"].value)

                # Scale Factor Queue
                if (self.dut.scale_factor_queue_pop[mc].value):
                    assert (self.dut.scale_factor_queue_out_valid[mc].value), f"AGE popped {mc} scale factor when data is not valid."
                    data = {
                        "data": self.dut.scale_factor_queue_out_data[mc]
                    }
                    _ = self._sample(data, self.scale_factors[mc])
                    self.dut._log.debug("Observed scale factor pop for fetch tag %d with data: %s", mc, data["data"].value)

            # Aggregation Buffer Writes
            for precision in range(self.precision_count):
                for slot in range(self.aggregation_buffer_slots):
                    if (self.dut.aggregation_buffer_slot_write_enable[precision][slot].value):
                        data = {
                            "address": self.dut.aggregation_buffer_slot_write_address[precision][slot],
                            "data": self.dut.aggregation_buffer_slot_write_data[precision][slot]
                        }
                        _ = self._sample(data, self.buffer_writes[precision][slot])
                        self.dut._log.debug("Observing %s Aggregation Buffer write to slot %d", NodePrecision(precision).name, slot)