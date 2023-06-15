
from typing import Any, Dict

import cocotb
from cocotb.handle import SimHandleBase

class Monitor:
    def __init__(self, dut, variant):
        self.dut = dut
        self._coro = None
        self.variant = variant

        self.message_channel_count = variant.message_channel_count
        self.precision_count = variant.precision_count
        self.aggregation_buffer_slots = variant.aggregation_buffer_slots

    def start(self) -> None:
        """Start monitor"""
        if self._coro is not None:
            raise RuntimeError("Monitor already started")
        self._coro = cocotb.start_soon(self._run())

    def stop(self) -> None:
        """Stop monitor"""
        if self._coro is None:
            raise RuntimeError("AGE Monitor never started")
        self._coro.kill()
        self._coro = None

    async def _run(self) -> None:
        pass

    def _sample(self, data, queue) -> Dict[str, Any]:
        """
        Samples the data signals and builds a transaction object
        """
        queue.put_nowait({name: handle.value for name, handle in data.items()})
        return {name: handle.value for name, handle in data.items()}