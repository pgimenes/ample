# #!/usr/bin/env python

import argparse
import json
import os

def run_pass (data, line_start="",
                declaration=False, 
                port=False, 
                declare_postfix="",
                
                assignment=False, 
                assign_lhs_postfix="", 
                assign_rhs_postfix="", 

                instance=False,
                instance_lhs_postfix="", 
                instance_rhs_postfix="", 
                
                line_end="", 
                final_char="",
                
                filter_out=[], 
                only_allow=["READ_WRITE", "READ_ONLY", "WRITE_ONLY", "INTERRUPT"]
                ):

    out_str = ""
    for reg_idx, register in enumerate(data["registerMap"]["registers"]):        
        name = register["name"]
        is_register_array = (register["type"] == "RegisterArray")
        array_length = register.get("arrayLength", 1)

        if (register["access"] in filter_out) or (register["access"] not in only_allow):
            continue

        fields = register["fields"]
        # if (not assignment):
        #     fields += [{"name": "strobe", "bitWidth": 1}]

        for field_idx, field in enumerate(fields):
            field_name = field["name"]
            width = field["bitWidth"]
            
            array_suffix = f"[{array_length-1}:0] " if is_register_array else ""
            size_suffix = f"{array_suffix}[{width-1}:0]"

            # out_str += dump_reg
            if declaration:
                declaration_prefix = "input  logic" if register["access"] == "READ_ONLY" else "output logic"
                declaration_prefix = "logic" if not port else declaration_prefix
                out_str += (f"{line_start}{declaration_prefix} {size_suffix} {name.lower()}_{field_name.lower()}{declare_postfix}")
            
            elif assignment:
                out_str += f"{line_start} {name.lower()}_{field_name.lower()}{assign_lhs_postfix} <= {name.lower()}_{field_name.lower()}{assign_rhs_postfix}"
            
            elif instance and register["access"]:
                out_str += f".{name.lower()}_{field_name.lower()}{instance_lhs_postfix} ({name.lower()}_{field_name.lower()}{instance_rhs_postfix})"

            else:
                out_str += (f"{line_start} {name.lower()}_{field_name.lower()}")

            # Add either comma or semicolon
            if reg_idx == len(data["registerMap"]["registers"]) - 1 and field_idx == len(fields) - 1:
                out_str += final_char
            else:
                out_str += f"{line_end}\n"

    return out_str

def dump_wrapper_file(base_path, regbank_name, data):
    with open(base_path + regbank_name + "_wrapper.sv", "w") as dump_file:
        dump_file.write(f"""

module {regbank_name}_wrapper #(
    parameter AXI_ADDR_WIDTH = 32 // width of the AXI address bus
) (

    // Clock and Reset (SLOW SIDE)
    input  wire                      axi_aclk,
    input  wire                      axi_aresetn,

    // Clock and Reset (FAST SIDE)
    input  logic                     fast_clk,
    input  logic                     fast_resetn,

    // AXI Write Address Channel
    input  wire [AXI_ADDR_WIDTH-1:0] s_axi_awaddr,
    input  wire [2:0]                s_axi_awprot,
    input  wire                      s_axi_awvalid,
    output wire                      s_axi_awready,

    // AXI Write Data Channel
    input  wire [31:0]               s_axi_wdata,
    input  wire [3:0]                s_axi_wstrb,
    input  wire                      s_axi_wvalid,
    output wire                      s_axi_wready,

    // AXI Read Address Channel
    input  wire [AXI_ADDR_WIDTH-1:0] s_axi_araddr,
    input  wire [2:0]                s_axi_arprot,
    input  wire                      s_axi_arvalid,
    output wire                      s_axi_arready,

    // AXI Read Data Channel
    output wire [31:0]               s_axi_rdata,
    output wire [1:0]                s_axi_rresp,
    output wire                      s_axi_rvalid,
    input  wire                      s_axi_rready,

    // AXI Write Response Channel
    output wire [1:0]                s_axi_bresp,
    output wire                      s_axi_bvalid,
    input  wire                      s_axi_bready,

    // User Ports

{run_pass(data, declaration=True, port=True, line_start="    ", line_end=",", final_char="")}
);

// ====================================================================================================================
// Declarations
// ====================================================================================================================

{run_pass(data, declaration=True, line_start="", declare_postfix="_slow", line_end=";", final_char=";")}

{run_pass(data, declaration=True, line_start="", declare_postfix="_q", line_end=";", final_char=";")}

// ====================================================================================================================
// Register Bank Instance
// ====================================================================================================================

{regbank_name}_regs {regbank_name}_i (

// Clock and Reset
.axi_aclk                       (axi_aclk),
.axi_aresetn                    (axi_aresetn),

// AXI Write Address Channel
.s_axi_awaddr                   (s_axi_awaddr),
.s_axi_awprot                   (s_axi_awprot),
.s_axi_awvalid                  (s_axi_awvalid),
.s_axi_awready                  (s_axi_awready),
.s_axi_wdata                    (s_axi_wdata),
.s_axi_wstrb                    (s_axi_wstrb),
.s_axi_wvalid                   (s_axi_wvalid),
.s_axi_wready                   (s_axi_wready),
.s_axi_araddr                   (s_axi_araddr),
.s_axi_arprot                   (s_axi_arprot),
.s_axi_arvalid                  (s_axi_arvalid),
.s_axi_arready                  (s_axi_arready),
.s_axi_rdata                    (s_axi_rdata),
.s_axi_rresp                    (s_axi_rresp),
.s_axi_rvalid                   (s_axi_rvalid),
.s_axi_rready                   (s_axi_rready),
.s_axi_bresp                    (s_axi_bresp),
.s_axi_bvalid                   (s_axi_bvalid),
.s_axi_bready                   (s_axi_bready),

{run_pass(data, instance=True, line_start=".", instance_rhs_postfix="_slow", line_end=",", final_char="")}

);

// ====================================================================================================================
// Synchronization Logic
// ====================================================================================================================

// FAST to SLOW
// --------------------------------------------------------------------

always_ff @(posedge axi_aclk or negedge axi_aresetn) begin

    if (!axi_aresetn) begin

{run_pass(data, line_start="       ", line_end="_q <= '0;", final_char="_q <= '0;", only_allow=["READ_ONLY"])}

{run_pass(data, line_start="       ", line_end="_slow <= '0;", final_char="_slow <= '0;", only_allow=["READ_ONLY"])}

    end else begin

{run_pass(data, assignment=True, line_start="       ", assign_lhs_postfix="_q", assign_rhs_postfix="", line_end=";", final_char=";", only_allow=["READ_ONLY"])}

{run_pass(data, assignment=True, line_start="       ", assign_lhs_postfix="_slow", assign_rhs_postfix="_q", line_end=";", final_char=";", only_allow=["READ_ONLY"])}

    end

end

// SLOW to FAST
// --------------------------------------------------------------------

always_ff @(posedge fast_clk or negedge fast_resetn) begin

    if (!fast_resetn) begin

{run_pass(data, line_start="       ", line_end="_q <= '0;", final_char="_q <= '0;", filter_out=["READ_ONLY"])}

{run_pass(data, line_start="       ", line_end=" <= '0;", final_char=" <= '0;", filter_out=["READ_ONLY"])}

    end else begin

{run_pass(data, assignment=True, line_start="       ", assign_lhs_postfix="_q", assign_rhs_postfix="_slow", line_end=";", final_char=";", filter_out=["READ_ONLY"])}

{run_pass(data, assignment=True, line_start="       ", assign_lhs_postfix="", assign_rhs_postfix="_q", line_end=";", final_char=";", filter_out=["READ_ONLY"])}

    end

end

endmodule
    """)
        
def main(args):
    with open(args.base_path + args.regbank_name + "/" + args.regbank_name + "_regs.json") as f:
        data = json.load(f)
    dump_wrapper_file(args.base_path + args.regbank_name + "/", args.regbank_name, data)

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    
    parser.add_argument("--regbank_name", help="Name of the register bank")
    
    default_path = os.path.join(os.environ["WORKAREA"], "hw/build/regbanks/")
    parser.add_argument("--base_path", default=default_path, help="Name of the register bank")
    
    args = parser.parse_args()
    main(args)