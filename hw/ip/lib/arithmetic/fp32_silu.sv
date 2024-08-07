module fp32_silu (
    input  logic        sys_clk,
    input  logic        resetn,
    input  logic [31:0] x_data, 
    input  logic        x_valid, 
    output logic        x_ready, 


    output logic [31:0] result_data,
    output logic        result_tvalid,
    input  logic        result_tready

);

    // ========================================
    logic        fp_add_ready;
    logic        exp_valid;


    logic [31:0] exp;
    logic [31:0] denom;
    logic [31:0] one = 32'h3F800000; // 1.0 in IEEE 754 floating-point representation

    // ========================================


    assign x_ready = 1'b1;
    assign result_tvalid = 1'b1;
    assign result_data = 0;


    // e^-x 
    fp32_exp exp_i (
      .aclk                 (aclk),                                 
      .s_axis_a_tvalid      (x_valid),          
      .s_axis_a_tready      (x_ready),          
      .s_axis_a_tdata       (-x_data),             
      .m_axis_result_tvalid (m_axis_result_tvalid), 
      .m_axis_result_tready (m_axis_result_tready), 
      .m_axis_result_tdata  (exp_result_data)   
    );

    //1 + e^-x
    fp_add adder_i (
      .in1            (one),
      .in2            (exp_result),
      .res            (fp_add_result_comb)
    );


    //Buffer here?



    //x / (1 + e^-x)
    fp32_divider div_i (
      .aclk(aclk),                                  
      .s_axis_a_tvalid      (exp_result_tvalid),         
      .s_axis_a_tready      (exp_result_tready),
      .s_axis_a_tdata       (fp_add_result_data),

      .s_axis_b_tvalid      (in_valid),   
      .s_axis_b_tready      (in_ready),   
      .s_axis_b_tdata       (in_data),

      .m_axis_result_tvalid (result_valid),
      .m_axis_result_tready (result_ready),
      .m_axis_result_tdata  (result_data) 
    );

    fp32_divider your_instance_name (
  .aclk(aclk),                                  // input wire aclk
  .s_axis_a_tvalid(s_axis_a_tvalid),            // input wire s_axis_a_tvalid
  .s_axis_a_tready(s_axis_a_tready),            // output wire s_axis_a_tready
  .s_axis_a_tdata(s_axis_a_tdata),              // input wire [31 : 0] s_axis_a_tdata
  .s_axis_b_tvalid(s_axis_b_tvalid),            // input wire s_axis_b_tvalid
  .s_axis_b_tready(s_axis_b_tready),            // output wire s_axis_b_tready
  .s_axis_b_tdata(s_axis_b_tdata),              // input wire [31 : 0] s_axis_b_tdata
  .m_axis_result_tvalid(m_axis_result_tvalid),  // output wire m_axis_result_tvalid
  .m_axis_result_tready(m_axis_result_tready),  // input wire m_axis_result_tready
  .m_axis_result_tdata(m_axis_result_tdata)    // output wire [31 : 0] m_axis_result_tdata
);




endmodule


