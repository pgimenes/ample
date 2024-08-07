import os

def convert_do_file_to_vcd(do_file_path):
    with open(do_file_path, 'r') as file:
        lines = file.readlines()
    
    vcd_lines = []
    for line in lines:
        line = line.strip()
        if line.startswith("add wave -noupdate"):
            signal_path = line.split(" ")[-1]
            vcd_lines.append(f"vcd add -r {signal_path}")
    
    return vcd_lines

def create_vcd_file(do_file_paths, output_vcd_file):
    vcd_content = []
    vcd_content.append("# Create and open the VCD file")
    vcd_content.append(f"vcd file open -new {output_vcd_file}")
    vcd_content.append("")
    
    for do_file_path in do_file_paths:
        vcd_content.extend(convert_do_file_to_vcd(do_file_path))
        vcd_content.append("")
    
    vcd_content.append("# Start recording VCD")
    vcd_content.append("vcd file start")
    
    return vcd_content

def main(do_file_paths, output_vcd_file, output_script_file):
    vcd_content = create_vcd_file(do_file_paths, output_vcd_file)

    with open(output_script_file, 'w') as file:
        for line in vcd_content:
            file.write(line + '\n')
    
    print(f"VCD script written to {output_script_file}")

if __name__ == "__main__":
    # Define the list of .do files you want to convert
    do_files = ["waves.do", "fte.do", "nsb.do", "pref.do", "age.do"]
    
    # Define the name of the output VCD file
    output_vcd_filename = "waves.vcd"
    
    # Define the name of the output VCD script file
    output_script_filename = "vcd_add_signals.do"
    
    main(do_files, output_vcd_filename, output_script_filename)
