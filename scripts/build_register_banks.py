#!/usr/bin/env python3.10

import os
import subprocess
import json

import argparse
import logging

logging.basicConfig(level=logging.DEBUG, format='[%(asctime)s]:%(levelname)s:: %(message)s')

def download_regbank_files(regbank_id, script_file):
    os.system("python3.6 " + script_file + " " + str(regbank_id) + " all")

def update_vivado_project(BASE_PATH, regbank_list):
    tcl_file = BASE_PATH + "/hw/update_regbanks.tcl"
    os.system("touch " + tcl_file)

    with open(tcl_file, "w") as tfile:
        # Open project
        tfile.write("open_project $::env(FYP_DIR)/hw/build/build_project.xpr \n")

        for rb in regbank_list:
            tfile.write("add_files -fileset sources_1 " + BASE_PATH + "/hw/build/regbanks/" + rb + " \n")

    # Run tcl script
    os.system("cd " + BASE_PATH + "/hw/build; vivado -mode batch -source " + tcl_file)

def main(args):

    json_file = open(args.regbank_list)
    regbanks = json.load(json_file)

    regbanks_dir = args.build_directory + "/regbanks"
    os.system("mkdir " + args.build_directory)
    os.system("mkdir " + regbanks_dir)

    regbank_list = []

    for regbank in regbanks["regbanks"]:
        regbank_list = regbank_list + [regbank["name"]]
        logging.info(f"Regbank " + regbank["name"] + " has ID " + str(regbank["ID"]))
        download_regbank_files(regbank["ID"], args.download_script)

        # Move zipfile to build directory
        zip_file = regbank["name"] + "_regs.zip "
        os.system("mv " + zip_file + " " + regbanks_dir)

        # Unzip into appropriate directory within build
        REGBANK_DIR = regbanks_dir + "/" + regbank["name"]
        os.system("mkdir " + REGBANK_DIR)
        os.system("unzip -o " + regbanks_dir + "/" + zip_file + " -d " + REGBANK_DIR)

    # Build register bank wrappers
    for regbank in regbanks["regbanks"]:
        logging.info(f"Building CDC wrapper for {regbank['name']}.")
        os.system("python3.10 $FYP_DIR/scripts/regbank_wrapper.py --regbank_name " + regbank["name"])

    if (args.update_project):
        logging.info("Updating Vivado project with new regbanks.")
        update_vivado_project(args.base_path, regbank_list)

    logging.info(f"Register Bank build completed successfully.")

def parse_arguments():
    parser = argparse.ArgumentParser()

    default_base_path = os.environ.get("FYP_DIR")
    parser.add_argument('--base_path', default=default_base_path, help='Base path (default: $FYP_DIR)')
    parser.add_argument('--download_script', default=default_base_path+"/scripts/download_regbank.py", help='AirHDL Download Script (default: $FYP_DIR/scripts/download_regbank.py)')
    parser.add_argument('--regbank_list', default=default_base_path+"/hw/regbanks.json", help='Register bank JSON file (default: $FYP_DIR/hw/regbanks.json)')
    parser.add_argument('--build_directory', default=default_base_path+"/hw/build", help='Build directory path (default: $FYP_DIR/hw/build)')
    parser.add_argument('--skip_wrappers', action='store_true', help='Skip building register bank wrappers')
    parser.add_argument('--update_project', action='store_true', help='Update Vivado project with new regbanks')

    return parser.parse_args()

if __name__ == "__main__":
    args = parse_arguments()
    main(args)