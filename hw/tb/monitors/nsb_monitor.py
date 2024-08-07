
from typing import Dict

from cocotb.queue import Queue
from cocotb.triggers import RisingEdge

from tb.monitor import Monitor

class NSB_Monitor (Monitor):
    def __init__(self, dut, variant,logger):
        super().__init__(dut, variant)

        self.age_reqs = Queue[Dict[str, int]]()
        self.fte_reqs = Queue[Dict[str, int]]()
        self.prefetcher_reqs = Queue[Dict[str, int]]()
        self.running = False
        self._log = logger
        # self._log.info("NSB_Monitor initialized with log level: %s", self._log.level)


    async def _run(self) -> None:
        while True:
            if self.running == False:
                return
            # print('NSB')
            await RisingEdge(self.dut.core_clk)
            # AGE Requests
            if (self.dut.nsb_age_req_valid.value and self.dut.nsb_age_req_ready.value):
                data = {
                    "nodeslot"             : self.dut.nsb_age_req.nodeslot,
                    "node_id"              : self.dut.nsb_age_req.node_id,
                    "fetch_tag"            : self.dut.nsb_age_req.fetch_tag,
                    "node_precision"       : self.dut.nsb_age_req.node_precision,
                    "aggregation_function" : self.dut.nsb_age_req.aggregation_function
                }
                sampled_value = self._sample(data, self.age_reqs)
                self._log.debug("Observed NSB request to AGE for Nodeslot %d", data["nodeslot"].value)
            
            # FTE Requests
            if (self.dut.nsb_fte_req_valid.value and self.dut.nsb_fte_req_ready.value):
                data = {
                    "nodeslots"             : self.dut.nsb_fte_req.nodeslots,
                    "precision"              : self.dut.nsb_fte_req.precision
                }
                sampled_value = self._sample(data, self.fte_reqs)
                self._log.debug("Observed NSB request to FTE for Nodeslots %s", data["nodeslots"].value)
            
            # Prefetcher Requests
            if (self.dut.nsb_prefetcher_req_valid.value and self.dut.nsb_prefetcher_req_ready.value):
                data = {
                    "req_opcode":         self.dut.nsb_prefetcher_req.req_opcode,
                    "start_address":      self.dut.nsb_prefetcher_req.start_address,
                    "in_features":        self.dut.nsb_prefetcher_req.in_features,
                    "out_features":       self.dut.nsb_prefetcher_req.out_features,
                    "nodeslot":           self.dut.nsb_prefetcher_req.nodeslot,
                    "nodeslot_precision": self.dut.nsb_prefetcher_req.nodeslot_precision,
                    "neighbour_count":    self.dut.nsb_prefetcher_req.neighbour_count
                }
                sampled_value = self._sample(data, self.prefetcher_reqs)
                self._log.debug("Observed Prefetcher request: %s for Nodeslot %d", data["req_opcode"].value, data["nodeslot"])



            #for ns in self.nodeslots:
                