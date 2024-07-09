import cocotb
from cocotb.triggers import RisingEdge
from cocotb.log import SimLog
from cocotb.result import TestFailure
import numpy as np

class AXIWriteMasterMonitor:
    def __init__(self, clk, req_valid, req_ready, start_address, req_len, data_valid, data, resp_valid, resp_ready):
        self.clk = clk
        self.req_valid = req_valid
        self.req_ready = req_ready
        self.start_address = start_address
        self.req_len = req_len
        self.data_valid = data_valid
        self.data = data
        self.resp_valid = resp_valid
        self.resp_ready = resp_ready
        self.transactions = {}  # Tracking ongoing transactions
        self.log = SimLog("cocotb.AXIWriteMasterMonitor")

        cocotb.fork(self._monitor_write_transactions())

    async def _monitor_write_transactions(self):
        current_transaction = None
        while True:
            await RisingEdge(self.clk)

            # Handle write request
            if self.req_valid.value and self.req_ready.value:
                start_addr = int(self.start_address.value)
                length = int(self.req_len.value)
                current_transaction = {
                    'start_address': start_addr,
                    'data': [],
                    'expected_length': length
                }
                self.transactions[start_addr] = current_transaction

            # Handle data writing
            if self.data_valid.value and current_transaction:
                data_chunk = int(self.data.value)
                current_transaction['data'].append(data_chunk)

            # Handle response (transaction end)
            if self.resp_valid.value and self.resp_ready.value:
                if current_transaction and len(current_transaction['data']) != current_transaction['expected_length']:
                    self.log.error(f"Transaction data length mismatch at address {current_transaction['start_address']}")
                    # raise TestFailure("Data length mismatch")

                # Optionally, check the data integrity here
                # Example:
                # expected_data = self.expected_data_for_address(current_transaction['start_address'])
                # if not np.array_equal(current_transaction['data'], expected_data):
                #     self.log.error(f"Data mismatch for address {current_transaction['start_address']}")
                #     raise TestFailure("Data mismatch")

                # Clean up transaction
                del self.transactions[current_transaction['start_address']]
                current_transaction = None

    # Helper function to get expected data based on address
    # def expected_data_for_address(self, address):
    #     return some_lookup_function(address)
