
from typing import Dict

from cocotb.queue import Queue
from cocotb.triggers import RisingEdge

from tb.monitor import Monitor

class FTE_Monitor (Monitor):
    def __init__(self, dut, variant):
        super().__init__(dut, variant)

        self.nsb_responses = Queue[Dict[str, int]]()
        self.weight_channel_reqs = [Queue[Dict[str, int]]() for _ in range(self.precision_count)]


    async def _run(self) -> None:
        while True:
            await RisingEdge(self.dut.core_clk)

            # NSB responses
            if (self.dut.nsb_fte_resp_valid and self.dut.nsb_fte_resp_ready):
                data = {
                    "nodeslots": self.dut.nsb_age_resp.nodeslots,
                    "precision": self.dut.nsb_age_resp.precision
                }
                self._sample(data, self.nsb_responses)
                self.dut._log.debug("Observed response to NSB for nodeslots: %s, precision: %s", data["nodeslots"].value, data["precision"].value)

            # Weight Channel requests
            for wc in range(self.message_channel_count):
                if (self.dut.weight_channel_req_valid[wc].value and self.dut.weight_channel_req_ready[wc].value):
                    data = {
                        "in_features": self.dut.weight_channel_req[wc].in_features,
                        "out_features": self.dut.weight_channel_req[wc].out_features
                    }
                    _ = self._sample(data, self.weight_channel_reqs[wc])
                    self.dut._log.debug("Observed Weight Channel request for Nodeslot: %s, Fetch Tag: ", data["nodeslot"].value, data["fetch_tag"].value)