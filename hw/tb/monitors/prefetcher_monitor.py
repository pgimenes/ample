
from typing import Dict

from cocotb.queue import Queue
from cocotb.triggers import RisingEdge

from tb.monitor import Monitor

class Prefetcher_Monitor (Monitor):
    def __init__(self, dut, variant):
        super().__init__(dut, variant)

        self.message_channel_responses = [Queue[Dict[str, int]]() for _ in range(self.message_channel_count)]
        self.weight_channel_responses = [Queue[Dict[str, int]]() for _ in range(self.precision_count)]

    async def _run(self) -> None:
        while True:
            await RisingEdge(self.dut.core_clk)

            # NSB responses
            if (self.dut.nsb_prefetcher_resp_valid.value):
                data = {
                    "nodeslot": self.dut.nsb_prefetcher_resp.nodeslot,
                    "response_type": self.dut.nsb_prefetcher_resp.response_type,
                    "allocated_fetch_tag": self.dut.nsb_prefetcher_resp.allocated_fetch_tag,
                    "partial": self.dut.nsb_prefetcher_resp.partial
                }
                _ = self._sample(data, self.nsb_responses)
                self.dut._log.debug("Observed %s response to NSB for Nodeslot: %s", data["response_type"].value, data["nodeslot"].value)

            # Message Channel Response
            for mc in self.message_channel_count:
                if (self.dut.message_channel_resp_valid[mc].value and self.dut.message_channel_resp_ready[mc].value):
                    data = {
                        "data": self.dut.message_channel_resp[mc].data,
                        "valid_mask": self.dut.message_channel_resp[mc].valid_mask,
                        "done": self.dut.message_channel_resp[mc].done
                    }
                    self._sample(data, self.message_channel_responses[mc])
                    self.dut._log.debug("Observed Message Channel response through MC %d. Done: %s", self.dut.message_channel_resp_valid.value, data["done"].value)

            # Weight Channel Response
            for wc in self.weight_channel_count:
                if (self.dut.weight_channel_resp_valid[wc].value and self.dut.weight_channel_resp_ready[wc].value):
                    data = {
                        "data":       self.dut.weight_channel_resp[wc].data,
                        "valid_mask": self.dut.weight_channel_resp[wc].valid_mask,
                        "done":       self.dut.weight_channel_resp[wc].done
                    }
                    self._sample(data, self.weight_channel_responses[wc])
                    self.dut._log.debug("Observed Weight Channel response through WC %d. Done: %s", self.dut.weight_channel_resp_valid, data["done"].value)