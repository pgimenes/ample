from enum import Enum

import cocotb
from cocotb.triggers import RisingEdge

async def delay(clk, cycles):
    for _ in range(cycles):
        await RisingEdge(clk)

node_state_e = Enum('state', [
    'EMPTY',
    'PROG_DONE',
    'FETCH_NB_LIST',
    'FETCH_SCALE_FACTORS',
    'FETCH_NEIGHBOURS',
    'AGGREGATION',
    'TRANSFORMATION'
])

precision_e = Enum('precision', [
    'FLOAT_32',
    'FIXED_8'
])

aggregation_function_e = Enum('function', [
    'SUM',
    'MEAN',
    'WEIGHTED_SUM'
])

regbanks_e = Enum('regbank', [
    'NSB',
    'PREFETCHER',
    'AGE',
    'FTE'
])