import struct
import numpy as np

def binary_to_hex(bin):
    n = int(bin, 2)
    return hex(n).split("0x")[1]

def int_list_to_byte_list(in_list, align=False, alignment=None, pad_side='right'):
    '''
    Convert to list of bytes in hex
    '''
    memory_hex, new_elements = [], []
    in_list = [0] if (in_list == []) else in_list

    new_elements = np.array([f"{dest_node:08x}" for dest_node in in_list])
    new_elements = [s[i:i+2] for s in new_elements for i in range(0, 8, 2)]

    if (align and alignment is not None):
        zeros = (alignment - len(new_elements) % alignment)
        zeros = 0 if (zeros == 64) else zeros

        if (pad_side == 'right'):
            memory_hex = new_elements + ['00'] * zeros
        elif (pad_side == 'left'):
            memory_hex = ['00'] * zeros + new_elements

        return memory_hex
    
    else:
        return new_elements

def float_list_to_byte_list(in_list, align=False, alignment=None, pad_side='right'):
    
    hex_list, new_elements = [], []

    new_elements = [struct.pack('!f', i).hex() for i in in_list]
    new_elements = [s[i:i+2] for s in new_elements for i in range(0, 8, 2)]
    if (align and alignment is not None):
        zeros = (alignment - len(new_elements) % alignment)
        zeros = 0 if (zeros == 64) else zeros
        if (pad_side == 'right'):
            hex_list = new_elements + ['00'] * zeros
        elif (pad_side == 'left'):
            hex_list = ['00'] * zeros + new_elements
    return hex_list

def dump_byte_list(byte_list, dump_file):
    with open(dump_file, 'w') as file:
        for i in range(len(byte_list)//64):
            file.write(''.join(byte_list[i*64:(i+1)*64]))
            file.write('\n')
        file.write(''.join(byte_list[64*(len(byte_list)//64):]))
        file.write('\n')