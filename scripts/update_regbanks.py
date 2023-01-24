import os
import subprocess
import json


DOWNLOAD_SCRIPT = "/scratch/pg519/fuzzy_carnival/scripts/download_regbank.py"
REGBANK_LIST = "/scratch/pg519/fuzzy_carnival/hw/regbanks.json"
BUILD_DIR = "/scratch/pg519/fuzzy_carnival/hw/build"
REGBANKS_BUILD = BUILD_DIR + "/regbanks"
FILESET = "sources_1"

def download_regbank_files(regbank_id):
    os.system("python3.6 " + DOWNLOAD_SCRIPT + " " + str(regbank_id) + " all")

def update_vivado_project(regbank_list):
    tcl_file = "/scratch/pg519/fuzzy_carnival/hw/update_regbanks.tcl"
    os.system("touch " + tcl_file)

    with open(tcl_file, "w") as tfile:
        # Open project
        tfile.write("open_project $::env(FYP_DIR)/hw/hw.xpr \n")

        for rb in regbank_list:
            tfile.write("add_files -fileset sources_1 build/regbanks/" + rb + " \n")

    # Run tcl script
    os.system("cd $FYP_DIR/hw; vivado -mode batch -source " + tcl_file)

# READ JSON

def main():

    json_file = open(REGBANK_LIST)
    regbanks = json.load(json_file)

    os.system("mkdir " + BUILD_DIR)
    os.system("mkdir " + REGBANKS_BUILD)

    regbank_list = []

    for regbank in regbanks["regbanks"]:
        regbank_list = regbank_list + [regbank["name"]]
        print(f"Regbank " + regbank["name"] + " has ID " + str(regbank["ID"]))
        download_regbank_files(regbank["ID"])

        # Move zipfile to build directory
        zip_file = regbank["name"] + "_regs.zip "
        os.system("mv " + zip_file + " " + REGBANKS_BUILD)

        # Unzip into appropriate directory within build
        REGBANK_DIR = REGBANKS_BUILD + "/" + regbank["name"]
        os.system("mkdir " + REGBANK_DIR)
        os.system("unzip -o " + REGBANKS_BUILD + "/" + zip_file + " -d " + REGBANK_DIR)

    update_vivado_project(regbank_list)

if __name__ == "__main__": main()