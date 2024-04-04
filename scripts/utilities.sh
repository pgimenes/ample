

# >>> handled by agile >>>

# Initial setup
# --------------------------------------------------------------------

# Modelsim paths
export PATH=$(echo "$PATH" | sed -e 's,/mnt/applications/mentor/modelsim-10.6d/modelsim/modeltech/bin:,,g' -e 's,/mnt/applications/mentor/modelsim-10.6d/modelsim/modeltech/linux_x86_64:,,g')
export PATH="/mnt/applications/mentor/modelsim-2019.2/modelsim/modeltech/bin:$PATH"
export PATH="/mnt/applications/mentor/modelsim-2019.2/modelsim/modeltech/linux_x86_64:$PATH"
LD_LIBRARY_PATH=vish

# Setup standard workarea for single clone use case
export WORKAREA=$(pwd)

# Setup Vivado version
# --------------------------------------------------------------------

setup_vivado() {
    local version="$1"

    if [ -z "$version" ]; then
        echo "Please provide a Vivado version (e.g., 20.1)"
        return 1
    fi

    local vivado_path="/home/applications/Xilinx/$version/Vivado/20$version"
    local vitis_path="/home/applications/Xilinx/$version/Vitis/20$version"

    source "$vivado_path/settings64.sh"
    source "$vitis_path/settings64.sh"
    export LD_LIBRARY_PATH="$vivado_path/lib/lnx64.o/SuSE:$LD_LIBRARY_PATH"

}

# Handle workareas
# --------------------------------------------------------------------

update_path_aliases() {
    export PYTHONPATH="${WORKAREA}:${WORKAREA}/hw:${WORKAREA}/hw/tb:${PATH}"
    # More aliases if you like...
}

wa() {
    if [[ $1 =~ ^[0-9]+$ ]]; then
#         echo "Setting up workarea $1."
        export WORKAREA="/home/pg519/wa$1"
        update_path_aliases
    else
        echo "Invalid argument. Please provide a number."
    fi
}

here() {
    export WORKAREA=$(pwd)
    update_path_aliases
}

# Aliases
# --------------------------------------------------------------------

alias open_tcl="vivado -mode tcl -source open_project build_project.xpr"
alias open_gui="vivado -source open_project build_project.xpr"

# >>> handled by agile <<<