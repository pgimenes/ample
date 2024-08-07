
from typing import Dict

from cocotb.queue import Queue
from cocotb.triggers import RisingEdge

from tb.monitor import Monitor
from tb.utils.common import NodePrecision

class BM_Monitor (Monitor):
    def __init__(self, dut, variant, precision, id, logger):
        super().__init__(dut, variant)

        self.precision = precision
        self.id = id

        self.buffer_reqs = Queue[Dict[str, int]]()
        self.running == False
        self.nodeslot = 0
        self.node_id = 0
        self._log = logger
        self.running = False


    async def _run(self) -> None:
         while True:
            if self.running == False:
                return
            # AGE Requests
            if (self.dut.age_buffer_manager_nodeslot_allocation_valid.value and self.dut.age_buffer_manager_nodeslot_allocation_ready.value):
                data = {
                    "nodeslot"             : self.dut.age_buffer_manager_nodeslot_allocation.nodeslot,
                    "node_id"             : self.dut.age_buffer_manager_nodeslot_allocation.node_id
                }
                sampled_value = self._sample(data, self.buffer_reqs)
                self._log.debug("Buffer Manager %d received allocation to Nodeslot: %d, node ID: %d", self.id, data["nodeslot"].value, data["node_id"].value)
            
           