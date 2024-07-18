import cocotb
from cocotb.triggers import RisingEdge
from cocotb.log import SimLog
from cocotb.result import TestFailure
import numpy as np

import struct

import torch

from cocotb.binary import BinaryValue


#Debugging
from tb.utils.common import delay, allocate_lsb
from cocotb.decorators import coroutine

from torch import tensor
class AXIWriteMasterMonitor:
    def __init__(self, clk, req_valid, req_ready, start_address, req_len, data_valid, data,pop, resp_valid, resp_ready):
        self.clk = clk
        self.req_valid = req_valid
        self.req_ready = req_ready
        self.start_address = start_address
        self.req_len = req_len
        self.data_valid = data_valid
        self.data = data
        self.pop = pop
        self.resp_valid = resp_valid
        self.resp_ready = resp_ready
        self.transactions = {}  # Tracking ongoing transactions
        self.log = SimLog("cocotb.AXIWriteMasterMonitor")
        self.expected = {}  # Tracking ongoing transactions

        # self._thread = cocotb.scheduler.add(self.monitor_write_transactions())

        cocotb.start_soon(self.monitor_write_transactions())
        self.expected_layer_features_by_address = {}


    async def monitor_write_transactions(self):
        current_transaction = None
        while True:
            await RisingEdge(self.clk)

            # Handle write request
            if self.req_valid.value and self.req_ready.value:
                start_addr = int(self.start_address.value)
                # data = int(self.data.value)
                length = int(self.req_len.value)

                # data_chunk = hex(self.data.value)

                current_transaction = {
                    'start_address': start_addr,
                    'data': [],
                    'expected_length': length+1
                }

                self.transactions[start_addr] = current_transaction
                self.log.info(f"Transaction {current_transaction}")

            # Handle data writing
            if self.data_valid.value and self.pop.value and current_transaction:
                data_chunk = hex(self.data.value)
                # print(data_chunk)
                current_transaction['data'].append(self.hex_to_floats(data_chunk))
                # self.log.info(f"Data {self.hex_to_floats(data_chunk)}")
              

            # Handle response (transaction end)
            if self.resp_valid.value and self.resp_ready.value:
                if current_transaction and ((len(current_transaction['data']) != current_transaction['expected_length'])):
                    self.log.error(f"Transaction data length mismatch at address {current_transaction['start_address']}")
                    # raise TestFailure("Data length mismatch")
                
                else:
                    self.log.info("getting node")

                    expected_node = self.get_node_by_address(current_transaction['start_address'])
                    
                    if expected_node:
                        self.log.info("--------------------")
                        self.log.info("")
                        self.log.info(f"Node found: {expected_node['node_id']}, Address: {expected_node['address']}")
                   

                        # Check if the data written matches the expected data
                        self.log.info(f"Data expected {expected_node['data']}")
                        current_transaction['data'] = tensor([item for sublist in current_transaction['data'] for item in sublist[::-1]])
                        print(current_transaction['data'].dtype)
                        print(expected_node['data'].dtype)

                        self.log.info(f"Data gotten {current_transaction['data']}")

                        if current_transaction['data'].shape != expected_node['data'].shape:
                            self.log.error(f"Data size mismatch for address {current_transaction['start_address']}")
                        else:

                            if not torch.allclose(current_transaction['data'], expected_node['data'],atol=1e-3):
                                self.log.error(f"Data mismatch for address {current_transaction['start_address']}")


                        
                        self.log.info(" ")
                        self.log.info("--------------------")
                    else:
                        self.log.error(f"No node found with address {current_transaction['start_address']}")
                    
                       

                # Clean up transaction
                del self.transactions[current_transaction['start_address']]
                current_transaction = None


    # async def end(self):
    #     self.running = False  # Set to False to stop the loop
    #     await cocotb.triggers.Join(self._monitor_write_transactions())

    def load_layer_features(self, nodeslot_programming,layer_features):
      
        self.log.info("load_layer_features")

        self.expected_layer_features_by_address = {}

        for nodslot in nodeslot_programming:

            node_id = nodslot['node_id']
            # if node_id == 0:
            #     offset = out_messages_address_lsb = nodslot['out_messages_address_lsb']

            # address = (nodslot['adjacency_list_address_msb'] << 32) | nodslot['adjacency_list_address_lsb']

            data = layer_features[node_id]
            out_messages_address_lsb = nodslot['out_messages_address_lsb']
            axi_write_master_address =int(out_messages_address_lsb)
            
            node_dict = {
                'node_id': node_id,
                'address': axi_write_master_address, 
                'data': data
            }

            self.expected_layer_features_by_address[axi_write_master_address] = node_dict

    
        # print(self.expected_layer_features_by_address)


    def get_node_by_address(self,address):

        return self.expected_layer_features_by_address.pop(address, None)

      
    def empty_expected_layer_features(self):
        return (self.expected_layer_features_by_address == {})

    def expected_layer_features(self):
        return self.expected_layer_features_by_address
    


    def hex_to_floats(self,hex_string):
        # Remove '0x' prefix if present
        if hex_string.startswith('0x'):
            hex_string = hex_string[2:]
        
        hex_string = hex_string.replace(' ', '').replace('\n', '')
        
        # Check for invalid characters in the hex string
        if any(c not in '0123456789abcdefABCDEF' for c in hex_string):
            raise ValueError("Non-hexadecimal character found in input string")
        
        if not hex_string:
            return []
        
        if len(hex_string) % 8 != 0:
            hex_string = hex_string.ljust((len(hex_string) + 7) // 8 * 8, '0')
        
        # Convert the hex string to bytes
        byte_data = bytes.fromhex(hex_string)
        
        num_floats = len(byte_data) // 4
        
        # Unpack the byte data into 32-bit floats
        floats = struct.unpack('>' + 'f' * num_floats, byte_data)
        
        return floats
    
    # #temp TODO reverse float order at input
    # def reverse_bin_float_order(self,msg_queue_write_data):
    #     # MESSAGE_QUEUE_WIDTH is the length of the binary string
    #     MESSAGE_QUEUE_WIDTH = len(msg_queue_write_data)
        
    #     # Number of 32-bit floats in the input data
    #     NUM_FLOATS = MESSAGE_QUEUE_WIDTH // 32
    #     print(msg_queue_write_data)
    #     # Split the input data into 32-bit chunks
    #     # float_chunks = [msg_queue_write_data[i*32:(i+1)*32] for i in range(NUM_FLOATS-1)]
    #     float_chunks = [str(msg_queue_write_data[i*32:(i+1)*32]) for i in range(NUM_FLOATS-1)]

    #     # Reverse the order of the chunks
    #     reversed_chunks = float_chunks[::-1]
        
    #     # Concatenate the reversed chunks back into a single binary string
    #     reversed_data = ''.join(reversed_chunks)
    #     reversed_data = BinaryValue(reversed_data)
    #     return reversed_data

    