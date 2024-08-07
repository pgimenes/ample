
from typing import Dict

from cocotb.queue import Queue
from cocotb.triggers import RisingEdge

from tb.monitor import Monitor

class Prefetcher_Monitor (Monitor):
    def __init__(self, dut, variant, logger):
        super().__init__(dut, variant)

        self.message_channel_responses = [Queue[Dict[str, int]]() for _ in range(self.message_channel_count)]
        self.weight_channel_responses = [Queue[Dict[str, int]]() for _ in range(self.precision_count)]
        self.nsb_responses = Queue[Dict[str, int]]()

        self._log = logger
        self.running = False

    async def _run(self) -> None:
        while True:
            if self.running == False:
                return
            await RisingEdge(self.dut.core_clk)

            # NSB responses
            if (self.dut.nsb_prefetcher_resp_valid.value):
                data = {
                    "nodeslot": self.dut.nsb_prefetcher_resp.nodeslot,
                    "response_type": self.dut.nsb_prefetcher_resp.response_type,
                    "allocated_fetch_tag": self.dut.nsb_prefetcher_resp.allocated_fetch_tag,
                    "partial": self.dut.nsb_prefetcher_resp.partial
                }
                _ = self._sample(data, self.nsb_responses) #TODO make queue
                self._log.debug("Observed %s response to NSB for Nodeslot: %s", data["response_type"].value, data["nodeslot"].value)

            # Message Channel Response
            for mc in range(self.message_channel_count):
                if (self.dut.message_channel_resp_valid[mc].value and self.dut.message_channel_resp_ready[mc].value):
                    data = {
                        "data": self.dut.message_channel_resp[mc].data,
                        "last_neighbour": self.dut.message_channel_resp[mc].last_neighbour,
                        "last_feature": self.dut.message_channel_resp[mc].last_feature
                    }
                    self._sample(data, self.message_channel_responses[mc])
                    # self._log.debug("Observed Message Channel response through MC %d.", mc)
                    self.dut._log.debug("Observed Message Channel response through MC %s. Last Feature: %s", mc, data["last_feature"].value)

            # Weight Channel Response
            for wc in range(self.precision_count):
                if (self.dut.weight_channel_resp_valid[wc].value and self.dut.weight_channel_resp_ready[wc].value):
                    data = {
                        "data":       self.dut.weight_channel_resp[wc].data,
                        "valid_mask": self.dut.weight_channel_resp[wc].valid_mask,
                        "done":       self.dut.weight_channel_resp[wc].done
                    }
                    self._sample(data, self.weight_channel_responses[wc])
                    # self._log.debug("Observed Weight Channel response through WC %d.", wc)
                    self._log.debug("Observed Weight Channel response through WC %d. Done: %s", wc, data["done"].value)