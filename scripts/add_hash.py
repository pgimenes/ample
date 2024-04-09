#!/usr/bin/env python3

import os
import hashlib
import argparse
import logging

logging.basicConfig(level=logging.DEBUG, format='[%(asctime)s]:%(levelname)s:: %(message)s')

def add_lines_to_sv_files(source_directory, destination_directory):
    logging.info(f"Parsing files in {source_directory}")
    for filename in os.listdir(source_directory):
        if filename.endswith(".sv") or filename.endswith(".v"):
            source_file_path = os.path.join(source_directory, filename)
            destination_file_path = os.path.join(destination_directory, filename)
            define_directive = os.path.abspath(source_file_path).replace('/', '_').replace('.', '_')[1:].upper()

            with open(source_file_path, 'r') as source_file:
                content = source_file.read()

                # Check if ifndef directive is present in the first line
                lines = content.split("\n")
                ifndef_present = lines[0].startswith("`ifndef")

                if not ifndef_present:
                    content = f'`ifndef {define_directive}\n`define {define_directive}\n{content}\n`endif'

            with open(destination_file_path, 'w') as destination_file:
                destination_file.write(content)

directory_path = "."

def main(args):
    os.makedirs(args.destination, exist_ok=True)
    add_lines_to_sv_files(args.source, args.destination)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Add ifndef and endif directives to SystemVerilog files')
    parser.add_argument('--source', '-s', type=str, help='Directory path to add ifndef and endif directives to SystemVerilog files')
    parser.add_argument('--destination', '-d', type=str, help='Directory path to add ifndef and endif directives to SystemVerilog files')
    args = parser.parse_args()
    main(args)