import cocotb
from cocotb.triggers import RisingEdge
from cocotb.log import SimLog
from cocotb.result import TestFailure
import numpy as np

import struct

import torch

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
        #Need to convert pytorch tensor to a dict of hex values of features and their expeted memory locaitons
        #Will also need to see the nodeslot programming and read in the address
        self.expected_layer_features = []
        self.log.info("load_layer_features")

        # Initialize an empty dictionary for quick lookups by address
        self.expected_layer_features_by_address = {}
        #or can just modify the node dict to be mapped by addresses

        # Process each node slot
        for nodslot in nodeslot_programming:
            node_id = nodslot['node_id']
            address = (nodslot['adjacency_list_address_msb'] << 32) | nodslot['adjacency_list_address_lsb']
            data = layer_features[node_id]
            out_messages_address_lsb = nodslot['out_messages_address_lsb']
            axi_write_master_address =int(out_messages_address_lsb-17408)
            # Create a dictionary entry for the current node
            # Subract 17408 to get the address of the read master - monitor axi signals to get actual write address
            node_dict = {
                'node_id': node_id,
                'address': axi_write_master_address, 
                'data': data
            }
            # Append the node_dict to the list
            self.expected_layer_features.append(node_dict)
            
            # Add the node_dict to the dictionary for quick lookups by address
            self.expected_layer_features_by_address[axi_write_master_address] = node_dict

        # Log the expected nodes
        for node in self.expected_layer_features:
            self.log.info(f"Expected Node: {node}")
        print(self.expected_layer_features_by_address)
          # Log the loading process
        # self.log.info("done")
        # self.running = True


    def get_node_by_address(self,address):
        # print('target',address)
        # print(self.expected_layer_features_by_address)
        return self.expected_layer_features_by_address.get(address, None)

      
        

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
    