
from typing import Dict

from cocotb.queue import Queue
from cocotb.triggers import RisingEdge

from tb.monitor import Monitor

class FTE_Monitor (Monitor):
    def __init__(self, dut, variant,logger):
        super().__init__(dut, variant)

        self.nsb_responses = Queue[Dict[str, int]]()
        self.weight_channel_reqs = [Queue[Dict[str, int]]() for _ in range(self.precision_count)]
        self._log = logger
        self.running = False


    async def _run(self) -> None:
        while True:
            if self.running == False:
                return

            await RisingEdge(self.dut.core_clk)

            # NSB responses
            if (self.dut.nsb_fte_resp_valid.value): #and self.dut.nsb_fte_resp_ready
                data = {
                    "nodeslots": self.dut.nsb_fte_resp.nodeslots,
                    "precision": self.dut.nsb_fte_resp.precision
                }
                self._sample(data, self.nsb_responses)
                self._log.debug("Observed response to NSB for nodeslots: %s, precision: %s", data["nodeslots"].value, data["precision"].value)

            # Weight Channel requests
            for wc in range(self.precision_count):
                if (self.dut.weight_channel_req_valid[wc].value and self.dut.weight_channel_req_ready[wc].value):
                    data = {
                        "in_features": self.dut.weight_channel_req[wc].in_features,
                        "out_features": self.dut.weight_channel_req[wc].out_features
                    }
                    _ = self._sample(data, self.weight_channel_reqs[wc])
                    self._log.debug("Observed Weight Channel request out features: %s, in features %s  ", data["in_features"].value, data["out_features"].value)