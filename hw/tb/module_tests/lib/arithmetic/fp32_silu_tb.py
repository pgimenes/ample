#!/usr/bin/env python3

import os, logging, sys
# from bitstring import BitArray

sys.path.append("/home/aw1223/ip/agile/hw/tb/module_tests")
sys.path.append("/home/aw1223/ip/agile/hw/tb/module_tests/mase_cocotb")

import cocotb
from cocotb.triggers import *
from mase_cocotb.testbench import Testbench
from mase_cocotb.interfaces.streaming import (
    StreamDriver,
    StreamMonitorFloat,
)
from mase_cocotb.runner import mase_runner

import pytest


import torch

logger = logging.getLogger("testbench")
logger.setLevel(logging.INFO)


class fixed_silu_tb(Testbench):
    def __init__(self, module, dut) -> None:
        super().__init__(dut, dut.sys_clk, dut.resetn)
        self.model = module

        self.x_data_driver = StreamDriver(
            dut.sys_clk, dut.x_data, dut.x_valid, dut.x_ready
        )

        self.result_monitor = StreamMonitorFloat(
            dut.sys_clk,
            dut.result_data,
            dut.result_valid,
            dut.result_ready
        )

    def exp(self):
      out = self.model(self.inputs)
      return out

  
    async def run_test(self):
        await self.reset()
        logger.info(f"Reset finished")
        self.result_monitor.ready.value = 1
        for _ in range(10):
            model_input = torch.randn(1, dtype=torch.float32)
            exp_out = self.exp(model_input)

            model_input = model_input.tolist()
            exp_out = exp_out.tolist()

            logger.info("Inputs and expected generated")
            logger.info(f"DUT IN: {model_input}")
            logger.info(f"DUT EXP OUT: {exp_out}")

            self.x_data_driver.load_driver(model_input)
            self.result_monitor.load_monitor(exp_out)

        await Timer(1000, units="us")
        assert self.result_monitor.exp_queue.empty()


@cocotb.test()
async def cocotb_test(dut):
    tb = fixed_silu_tb(torch.nn.SiLU(), dut)
    await tb.run_test()

torch.manual_seed(1)


@pytest.mark.dev
def test_fixed_silu():
   mase_runner()


if __name__ == "__main__":
    test_fixed_silu()