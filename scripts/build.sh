#!/bin/bash -f

cd $WORKAREA

# Build submodules
echo "======================================================="
echo "[$(date +%Y-%m-%d\ %H:%M:%S)]: Building submodules."
echo "======================================================="

git submodule update --init --recursive
git submodule foreach git pull origin master
git submodule foreach git checkout master

# Build register banks
echo "======================================================="
echo "[$(date +%Y-%m-%d\ %H:%M:%S)]: Building register banks."
echo "======================================================="

python $WORKAREA/scripts/build_register_banks.py

# Build Xilinx IP
echo "======================================================="
echo "[$(date +%Y-%m-%d\ %H:%M:%S)]: Generate Build Project."
echo "======================================================="

mkdir -p $WORKAREA/hw/build && cd $WORKAREA/hw/build || cd $WORKAREA/hw/build
vivado -mode batch -source $WORKAREA/scripts/build_project.tcl

cd $WORKAREA