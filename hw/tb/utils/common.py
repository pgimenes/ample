from enum import Enum

import cocotb
from cocotb.triggers import RisingEdge

async def delay(clk, cycles):
    for _ in range(cycles):
        await RisingEdge(clk)

def allocate_lsb(bit_str, bit_range=(0, 256)):
    available_bits = bit_str[::-1]
    # Replace values outside the range with 0
    available_bits = ''.join(char if i in bit_range else '0' for i, char in enumerate(available_bits))
    print(f"Available bits: {available_bits}")
    # Choose least significant
    for i, bit in enumerate(available_bits):
        if bit == '1':
            return i
    return None

class NodeState(Enum):
    EMPTY               = 0
    PROG_DONE           = 1
    FETCH_NB_LIST       = 2
    FETCH_SCALE_FACTORS = 3
    FETCH_NEIGHBOURS    = 4
    AGGREGATION         = 5
    TRANSFORMATION      = 6

class NodePrecision(Enum):
    FLOAT_32 = 0
    FIXED_8 = 1

class AggregationFunction(Enum):
    SUM          = 0
    MEAN         = 1
    WEIGHTED_SUM = 2

class Regbanks(Enum):
    NSB        = 0
    PREFETCHER = 1
    AGE        = 2
    FTE        = 3