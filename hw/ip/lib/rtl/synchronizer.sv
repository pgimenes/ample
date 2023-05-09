
// Only drive both outputs when both readys asserted and both in valids asserted

module synchronizer (
    input logic core_clk,
    input logic resetn,

    input logic  in_valid_0,
    output logic in_ready_0,
    
    input logic  in_valid_1,
    output logic in_ready_1,

    output logic out_valid_0,
    input logic  out_ready_0,

    output logic out_valid_1,
    input logic  out_ready_1


);

/ ---------------------- in ------------------------- /---/ ---------------------- out ------------------------ /
/ in_valid_0 / in_valid_1 / out_ready_0 / out_ready_1 /---/ in_ready_0 / in_ready_1 / out_valid_0 / out_valid_1 / 
/     0      /     0      /      0      /       0     /---/      0     /      0     /      0      /      0      /
/     0      /     0      /      0      /       1     /---/      0     /      0     /      0      /      0      /
/     0      /     0      /      1      /       0     /---/      0     /      0     /      0      /      0      /
/     0      /     0      /      1      /       1     /---/      0     /      0     /      0      /      0      /

/     0      /     1      /      0      /       0     /---/      0     /      0     /      0      /      0      /
/     0      /     1      /      0      /       1     /---/      0     /      0     /      0      /      0      /
/     0      /     1      /      1      /       0     /---/      0     /      0     /      0      /      0      /
/     0      /     1      /      1      /       1     /---/      0     /      0     /      0      /      0      /

/     1      /     0      /      0      /       0     /---/      0     /      0     /      0      /      0      /
/     1      /     0      /      0      /       1     /---/      0     /      0     /      0      /      0      /
/     1      /     0      /      1      /       0     /---/      0     /      0     /      0      /      0      /
/     1      /     0      /      1      /       1     /---/      0     /      0     /      0      /      0      /

/     1      /     1      /      0      /       0     /---/      0     /      0     /      0      /      0      /
/     1      /     1      /      0      /       1     /---/      0     /      0     /      0      /      0      /
/     1      /     1      /      1      /       0     /---/      0     /      0     /      0      /      0      /
/     1      /     1      /      1      /       1     /---/      0     /      0     /      0      /      0      /


endmodule