/******************************************************************************
// (c) Copyright 2016 Xilinx, Inc. All rights reserved.
//
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
//
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
//
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
//
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
******************************************************************************/
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor             : Xilinx
// \   \   \/     Version            : 1.0
//  \   \         Application        : MIG
//  /   /         Filename           : ddr4_v2_2_8_data_gen.sv
// /___/   /\     Date Last Modified : $Date: 2014/09/03 $
// \   \  /  \    Date Created       : Wed Jan 13 2016
//  \___\/\___\
//
//Device: UltraScale
//Design Name: AXI TG
//Purpose:
//  This module generates data ans strobe that will be sent out on the write data bus.   
//  We can get prbs/fixed0,1/walking1,0/a5a5 patterns based on the data_pattern signal.
//  The strobe can be default/walking0,1. Default mode corresponds to the default strb pattren recommended by the axi4 protocol ans is most commonly used. walking1/0 strb patterns are for testing the axi slave by enabling only one byte(wstrb=0001,0010,0100...)
//  pattern_init pulse indicated the start of a new axi transaction and initialises all the registers with the seed and pattern values. seed, data_pattern/strb+pattern should be kept at the same value even after the pattern_init pulse has been deasserted. The data/strb will be available after two clks.
//  data_en (active high) indicates the next data beat to be sent. Corresponding data/strb will be available on the following posedge of clk. data_en can be asserted only two clk after pattern_init has been asserted
//last signal can be tied to wlast signal and indicates that the last data beat has been sent
//Reference:
//Revision History:
//*****************************************************************************
`timescale 1ps/1ps 
module ddr4_v2_2_8_data_gen # (
   parameter C_AXI_ID_WIDTH           = 10,
   parameter C_AXI_ADDR_WIDTH         = 32, 
   parameter C_AXI_DATA_WIDTH         = 32,
   parameter C_WSTRB_WIDTH            = C_AXI_DATA_WIDTH/8,
   parameter C_DATA_PATTERN_PRBS      = 3'd1,
   parameter C_DATA_PATTERN_WALKING0  = 3'd2,
   parameter C_DATA_PATTERN_WALKING1  = 3'd3,
   parameter C_DATA_PATTERN_ALL_F     = 3'd4,
   parameter C_DATA_PATTERN_ALL_0     = 3'd5,
   parameter C_DATA_PATTERN_A5A5      = 3'd6,
   parameter C_STRB_PATTERN_DEFAULT   = 3'd1,
   parameter C_STRB_PATTERN_WALKING1  = 3'd2,
   parameter C_STRB_PATTERN_WALKING0  = 3'd3,
   parameter TCQ                      = 100
  ) 
  (
   input                               tg_rst,
   input                               clk,
   input                               data_en, //when enabled generate next data pattern
   input [2:0]                         data_pattern, //can be PRBS, ALL_0 etc
   input                               pattern_init,//indicates that data for first transfer needs to be generated
   input [C_AXI_ID_WIDTH -1 :0]        prbs_seed_i,
   input [2:0]                         strb_pattern, //can be DEFAULT,WALKING1
   input [7:0]                         len_in,
   input [2:0]                         size_in, //size of the current axi transfer
   input [1:0]                         burst_in,
   input                               last, //indicates that the last axi beat has been sent
   input [6:0]                         start_addr, //start addr of the current axi transfer
   output wire [C_AXI_DATA_WIDTH-1:0]  data_out,// generated data from this block; can be connected to axi o/p
   output reg [C_AXI_DATA_WIDTH/8-1:0] wstrb_out, //generated strb from this block; can be connected to axi o/p
   output reg [C_AXI_DATA_WIDTH/8-1:0]     wstrb_out_default //used only in data chk module
  );

//Simple Log2 calculation function
function integer clogb2 (input integer in);
  begin
    in = in - 1;
    for (clogb2=1; in>1; clogb2=clogb2+1)
      in = in >> 1;
  end
endfunction
localparam C_WSTRB_WIDTH_LOG2 = clogb2(C_WSTRB_WIDTH);

//*****************************************************************************
// Data generate segment
//*****************************************************************************
genvar i;
generate 
 for(i=0; i< C_AXI_DATA_WIDTH/32 ;i++ )begin : prbs_data_gen //each prbs_data_gen can generate 32 bits of prbs data. So depending on AXI_DATA_WIDTH we generate the number of prbs_gen as required
   prbs_data_gen #(
   .C_AXI_ID_WIDTH(C_AXI_ID_WIDTH),
   .C_DATA_PATTERN_PRBS(C_DATA_PATTERN_PRBS),
   .C_DATA_PATTERN_WALKING0(C_DATA_PATTERN_WALKING0),
   .C_DATA_PATTERN_WALKING1(C_DATA_PATTERN_WALKING1),
   .C_DATA_PATTERN_ALL_F(C_DATA_PATTERN_ALL_F),
   .C_DATA_PATTERN_ALL_0(C_DATA_PATTERN_ALL_0),
   .C_DATA_PATTERN_A5A5(C_DATA_PATTERN_A5A5),
   .TCQ(TCQ)
   ) 
   u_prbs_data_gen(
    .clk(clk),
    .data_en(data_en),
    .data_pattern(data_pattern),
    .pattern_init(pattern_init),
    .prbs_seed_i({{(32 -C_AXI_ID_WIDTH){1'b0}},prbs_seed_i} + i),
    .data_o(data_out[(i*32)+:32]) 
  );
 end
endgenerate

//*****************************************************************************
// strb generate segment
//*****************************************************************************
//axi size decoder
reg [7:0] size;
always @ (posedge clk)begin
 case(size_in)
  3'b000: size <= #TCQ 8'd1; //1 byte
  3'b001: size <= #TCQ 8'd2;
  3'b010: size <= #TCQ 8'd4;
  3'b011: size <= #TCQ 8'd8;
  3'b100: size <= #TCQ 8'd16;
  3'b101: size <= #TCQ 8'd32;
  3'b110: size <= #TCQ 8'd64;
  3'b111: size <= #TCQ 8'd128;
 default: size <= #TCQ 8'd0;
 endcase
end
reg [127:0] wstrb_initial; //initial value of wstrb as on first beat
reg [127:0] wstrb_initial_default = 128'd0; 
reg [127:0] wstrb_initial_walking1 = 128'd0; 
reg [127:0] wstrb_initial_walking0 = 128'd0; 

//based on the strb_pattern and size we generate the wstrb_initial
//if strb_pattern == C_STRB_PATTERN_DEFAULT => we generate default wstrbs. So based on size, the necessary bits are 1 for the first beat. The wstrbs for later beats are determined by shifting the wstrb_initial
//default wstrb
//wstrb_initial_default is the initial wstrb on the first transfer if we have default strb pattern. This is used by the data_chk block to see if background data was written in these locations.
always @ (posedge clk)begin
  case(size_in)
    3'b000: wstrb_initial_default <= #TCQ 128'h0000_0000_0000_0000_0000_0000_0000_0001;
    3'b001: wstrb_initial_default <= #TCQ 128'h0000_0000_0000_0000_0000_0000_0000_0003;
    3'b010: wstrb_initial_default <= #TCQ 128'h0000_0000_0000_0000_0000_0000_0000_000F;
    3'b011: wstrb_initial_default <= #TCQ 128'h0000_0000_0000_0000_0000_0000_0000_00FF;
    3'b100: wstrb_initial_default <= #TCQ 128'h0000_0000_0000_0000_0000_0000_0000_FFFF;
    3'b101: wstrb_initial_default <= #TCQ 128'h0000_0000_0000_0000_0000_0000_FFFF_FFFF;
    3'b110: wstrb_initial_default <= #TCQ 128'h0000_0000_0000_0000_FFFF_FFFF_FFFF_FFFF;
    3'b111: wstrb_initial_default <= #TCQ 128'hFFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF;
   default: wstrb_initial_default <= #TCQ 128'h0000_0000_0000_0000_0000_0000_0000_0000;
  endcase
end
always @ (posedge clk)begin
  wstrb_initial_walking1 <= #TCQ 128'h0000_0000_0000_0000_0000_0000_0000_0001;
end
always @ (posedge clk)begin
  case(size_in)
    3'b000: wstrb_initial_walking0 <= #TCQ 128'h0000_0000_0000_0000_0000_0000_0000_0000;
    3'b001: wstrb_initial_walking0 <= #TCQ 128'h0000_0000_0000_0000_0000_0000_0000_0002;
    3'b010: wstrb_initial_walking0 <= #TCQ 128'h0000_0000_0000_0000_0000_0000_0000_000E;
    3'b011: wstrb_initial_walking0 <= #TCQ 128'h0000_0000_0000_0000_0000_0000_0000_00FE;
    3'b100: wstrb_initial_walking0 <= #TCQ 128'h0000_0000_0000_0000_0000_0000_0000_FFFE;
    3'b101: wstrb_initial_walking0 <= #TCQ 128'h0000_0000_0000_0000_0000_0000_FFFF_FFFE;
    3'b110: wstrb_initial_walking0 <= #TCQ 128'h0000_0000_0000_0000_FFFF_FFFF_FFFF_FFFE;
    3'b111: wstrb_initial_walking0 <= #TCQ 128'hFFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFE;
   default: wstrb_initial_walking0 <= #TCQ 128'h0000_0000_0000_0000_0000_0000_0000_0000;
  endcase
end

always @ (posedge clk)begin
  if(strb_pattern == C_STRB_PATTERN_DEFAULT)begin
    wstrb_initial <= #TCQ wstrb_initial_default;
  end   
  else if(strb_pattern == C_STRB_PATTERN_WALKING1)begin
    wstrb_initial <= #TCQ wstrb_initial_walking1;
  end   
  else if(strb_pattern == C_STRB_PATTERN_WALKING0)begin
    wstrb_initial <= #TCQ wstrb_initial_walking0;
  end 
  else begin
    wstrb_initial <= #TCQ 128'h0000_0000_0000_0000_0000_0000_0000_0000;
  end 
end

//based on size, only some lower bits of the addr are used to determine if the address is aligned or not. So the required lower bits are extracted here.
reg [6:0] start_addr_lower_bits;
always @ (posedge clk)begin
  case(size_in)
    3'b000: start_addr_lower_bits  <= #TCQ 7'd0;
    3'b001: start_addr_lower_bits  <= #TCQ {6'd0,start_addr[0]};
    3'b010: start_addr_lower_bits  <= #TCQ {5'd0,start_addr[1:0]};
    3'b011: start_addr_lower_bits  <= #TCQ {4'd0,start_addr[2:0]};
    3'b100: start_addr_lower_bits  <= #TCQ {3'd0,start_addr[3:0]};
    3'b101: start_addr_lower_bits  <= #TCQ {2'd0,start_addr[4:0]};
    3'b110: start_addr_lower_bits  <= #TCQ {1'd0,start_addr[5:0]};
    3'b111: start_addr_lower_bits  <= #TCQ  start_addr[6:0];
   default: start_addr_lower_bits  <= #TCQ 7'd0;
  endcase
end
reg [6:0] first_beat_shift_by;
always @ (posedge clk)begin
 case(size_in)
  3'b000: first_beat_shift_by <= #TCQ 7'b111_1111;
  3'b001: first_beat_shift_by <= #TCQ 7'b111_1110;
  3'b010: first_beat_shift_by <= #TCQ 7'b111_1100;
  3'b011: first_beat_shift_by <= #TCQ 7'b111_1000;
  3'b100: first_beat_shift_by <= #TCQ 7'b111_0000;
  3'b101: first_beat_shift_by <= #TCQ 7'b110_0000;
  3'b110: first_beat_shift_by <= #TCQ 7'b100_0000;
  3'b111: first_beat_shift_by <= #TCQ 7'b000_0000;
 default: first_beat_shift_by <= #TCQ 7'b111_1111;
 endcase
end

//first_transfer is asserted for the first beat in the axi data
reg first_transfer;
reg second_transfer;
always @ (posedge clk)begin
  if(pattern_init && ~first_transfer) begin
    first_transfer <= #TCQ 1'b1;
    second_transfer <= #TCQ 1'b0;
  end  
  else if(first_transfer && ~second_transfer) begin
    first_transfer <= #TCQ 1'b0;
    second_transfer <= #TCQ 1'b1;
  end  
  else begin
    first_transfer <= #TCQ 1'b0;
    second_transfer <= #TCQ 1'b0;
 end   
end

reg [6:0] shift_by;
reg [6:0] strb_walking_pattern_additional_shift;
wire shift_by_overflow;
wire strb_walking_pattern_additional_shift_overflow;

//below variables are used for wrap txns
reg [3:0] len_in_clogb2;
always @ (*)begin
  len_in_clogb2 = 0;
  if(pattern_init) begin
    case(len_in)
      8'd1  : len_in_clogb2 = 1;
      8'd3  : len_in_clogb2 = 2;
      8'd7  : len_in_clogb2 = 3;
      8'd15 : len_in_clogb2 = 4;
     default: len_in_clogb2 = 0;
    endcase
  end 
end


reg [5:0] wrap_boundary_mask;
reg [6:0] wrap_boundary_add;
always @ (posedge clk)begin
 case(size_in + len_in_clogb2)
  3'd1: begin wrap_boundary_mask <= #TCQ 6'b11_1110; wrap_boundary_add <= #TCQ 7'b000_0010; end
  3'd2: begin wrap_boundary_mask <= #TCQ 6'b11_1100; wrap_boundary_add <= #TCQ 7'b000_0100; end
  3'd3: begin wrap_boundary_mask <= #TCQ 6'b11_1000; wrap_boundary_add <= #TCQ 7'b000_1000; end
  3'd4: begin wrap_boundary_mask <= #TCQ 6'b11_0000; wrap_boundary_add <= #TCQ 7'b001_0000; end
  3'd5: begin wrap_boundary_mask <= #TCQ 6'b10_0000; wrap_boundary_add <= #TCQ 7'b010_0000; end
  3'd6: begin wrap_boundary_mask <= #TCQ 6'b00_0000; wrap_boundary_add <= #TCQ 7'b100_0000; end
 default: begin wrap_boundary_mask <= #TCQ 6'b00_0000;  wrap_boundary_add <= #TCQ 7'b100_0000; end
 endcase
end

localparam [C_WSTRB_WIDTH_LOG2 : 0] UPPER_BOUNDARY = 1 << C_WSTRB_WIDTH_LOG2;
reg [C_WSTRB_WIDTH_LOG2    :0] upper_boundary; //if (next_addr == upper_boundary) shift_overflow = 1;
reg [C_WSTRB_WIDTH_LOG2 -1 :0] lower_boundary; // if(shift_overflow) next_addr = lower_boundary;

wire [C_WSTRB_WIDTH_LOG2    :0] wrap_upper_boundary;
assign wrap_upper_boundary = (start_addr[C_WSTRB_WIDTH_LOG2 -1:0] &  wrap_boundary_mask) + wrap_boundary_add;
always @ (posedge clk)begin
  if(tg_rst || (last && data_en))begin
    lower_boundary <= #TCQ 0;  
    upper_boundary <= #TCQ UPPER_BOUNDARY;  
  end
  else if(first_transfer && (burst_in == 'd2)) begin
    lower_boundary <= #TCQ start_addr[C_WSTRB_WIDTH_LOG2 -1:0] &  wrap_boundary_mask;  
    upper_boundary <= #TCQ (wrap_upper_boundary == 0)? UPPER_BOUNDARY : wrap_upper_boundary;  //if wrap boundary exceeded the data_width, set upper boundary as data_width
  end 
end


//strb generation
//data_width=64 size=2B
//strb_pattern == C_STRB_PATTERN_DEFAULT
//wstrb_initial = 00_00_00_11
//first   transfer : wstrb= 00_00_00_11 shift_by =0 shift_by_overflow=0
//second  transfer : wstrb= 00_00_11_00 shift_by =2 shift_by_overflow=0
//third   transfer : wstrb= 00_11_00_00 shift_by =4 shift_by_overflow=0
//fourth  transfer : wstrb= 11_00_00_00 shift_by =6 shift_by_overflow=1
//fifth   transfer : wstrb= 00_00_00_11 shift_by =0 shift_by_overflow=0
//sixth   transfer : wstrb= 00_00_11_00 shift_by =2 shift_by_overflow=0
//     :

//strb_pattern == C_STRB_PATTERN_WALKING1
//wstrb_initial = 00_00_00_01
//first   transfer : wstrb= 00_00_00_01 shift_by =0 shift_by_overflow=0 strb_walking_pattern_additional_shift_overflow=0
//second  transfer : wstrb= 00_00_01_00 shift_by =2 shift_by_overflow=0 strb_walking_pattern_additional_shift_overflow=0
//third   transfer : wstrb= 00_01_00_00 shift_by =4 shift_by_overflow=0 strb_walking_pattern_additional_shift_overflow=0
//fourth  transfer : wstrb= 01_00_00_00 shift_by =6 shift_by_overflow=1 strb_walking_pattern_additional_shift_overflow=0
//fifth   transfer : wstrb= 00_00_00_10 shift_by =1 shift_by_overflow=0 strb_walking_pattern_additional_shift_overflow=0
//sixth   transfer : wstrb= 00_00_10_00 shift_by =3 shift_by_overflow=0 strb_walking_pattern_additional_shift_overflow=0
//seventh transfer : wstrb= 00_10_00_00 shift_by =5 shift_by_overflow=0 strb_walking_pattern_additional_shift_overflow=0
//eigth   transfer : wstrb= 10_00_00_00 shift_by =7 shift_by_overflow=1 strb_walking_pattern_additional_shift_overflow=1
//ninth   transfer : wstrb= 00_00_00_01 shift_by =0 shift_by_overflow=0 strb_walking_pattern_additional_shift_overflow=0
//     :
//reg [C_WSTRB_WIDTH_LOG2 :0] shift_by_counter;
//assign shift_by_counter = shift_by + size;
//assign shift_by_overflow = ~(|(shift_by_counter ^ upper_boundary));
assign shift_by_overflow = (shift_by >= (upper_boundary - size))? 1'b1:1'b0;
assign strb_walking_pattern_additional_shift_overflow = (strb_walking_pattern_additional_shift == (size - 1'b1))? 1'b1:1'b0;

always @(posedge clk)begin
  if(tg_rst || (last && data_en))begin
    shift_by <= #TCQ 7'd0;  
    strb_walking_pattern_additional_shift <= #TCQ 7'd0;
  end  
  else if(first_transfer && !shift_by_overflow)begin
//    shift_by <= #TCQ (start_addr[C_WSTRB_WIDTH_LOG2 -1:0]>>size_in) << size_in;  
    shift_by <= #TCQ start_addr[C_WSTRB_WIDTH_LOG2 -1:0] &  first_beat_shift_by[C_WSTRB_WIDTH_LOG2 -1:0];  
    strb_walking_pattern_additional_shift <= #TCQ 7'd0;
  end
  else if((second_transfer || data_en) && !shift_by_overflow)begin
    shift_by <= #TCQ shift_by + size;
    strb_walking_pattern_additional_shift <= #TCQ strb_walking_pattern_additional_shift;
  end
  else if((second_transfer || data_en) && shift_by_overflow && (strb_pattern == C_STRB_PATTERN_DEFAULT))begin
    shift_by <= #TCQ lower_boundary;
    strb_walking_pattern_additional_shift <= #TCQ 0;
  end
  else if((second_transfer || data_en) && shift_by_overflow && (strb_pattern != C_STRB_PATTERN_DEFAULT) && !strb_walking_pattern_additional_shift_overflow) begin
    shift_by <= #TCQ lower_boundary + strb_walking_pattern_additional_shift + 1'b1;
    strb_walking_pattern_additional_shift <= #TCQ strb_walking_pattern_additional_shift + 1'b1;
  end
  else if((second_transfer || data_en) && shift_by_overflow && (strb_pattern != C_STRB_PATTERN_DEFAULT) && strb_walking_pattern_additional_shift_overflow) begin
    shift_by <= #TCQ lower_boundary;
    strb_walking_pattern_additional_shift <= #TCQ 0;
  end
  else begin
    shift_by <= #TCQ shift_by;
    strb_walking_pattern_additional_shift <= #TCQ strb_walking_pattern_additional_shift;
  end  
end

reg [C_WSTRB_WIDTH -1:0] wstrb;
//only for the first transfer, wstrb depends on the unaligned portion of the axi_addr. The next transfers are obtained by simply shifting the wstrb_initial
//only for the first transfer we shall consider the default wstrb_initial. For the next beats we shall use the wstrb_initial (which is dependent on strb_pattern). This is necessary for unaligned transfers with strb_pattern=WALKING
always @(posedge clk)begin
  if(first_transfer) begin
    wstrb <= #TCQ ((wstrb_initial_default[C_WSTRB_WIDTH -1:0] << start_addr_lower_bits) & wstrb_initial_default[C_WSTRB_WIDTH -1:0]);
  end  
  else begin
    wstrb <= #TCQ wstrb_initial[C_WSTRB_WIDTH -1:0];
  end  
end

always @(posedge clk)begin
  if(tg_rst)begin
    wstrb_out <= #TCQ {(C_AXI_DATA_WIDTH/8){1'b0}};
  end
  else if(data_en || second_transfer) begin
    wstrb_out <= #TCQ (wstrb << shift_by);
  end 
  else begin
    wstrb_out <= #TCQ wstrb_out;
  end  
end
//assign  wstrb_out = wstrb << shift_by; //generated strb going out from the data_gen block

//shift_by_default is similar to shift_by except that _default is calculated for default strb mode and aligned addr
reg [6:0] shift_by_default;
wire shift_by_default_overflow;
assign shift_by_default_overflow = (shift_by_default >= (upper_boundary - size))? 1'b1:1'b0;
always @(posedge clk)begin
  if(tg_rst || (last && data_en))begin
    shift_by_default <= #TCQ 7'd0;  
  end  
  else if(first_transfer && !shift_by_default_overflow)begin
//    shift_by_default <= #TCQ (start_addr[C_WSTRB_WIDTH_LOG2 -1:0]>>size_in) << size_in;  
    shift_by_default <= #TCQ start_addr[C_WSTRB_WIDTH_LOG2 -1:0] &  first_beat_shift_by[C_WSTRB_WIDTH_LOG2 -1:0];  
  end
  else if((second_transfer || data_en) && !shift_by_default_overflow)begin
      shift_by_default <= #TCQ shift_by_default + size;
  end
  else if((second_transfer || data_en) && shift_by_default_overflow)begin
      shift_by_default <= #TCQ lower_boundary;
  end
  else begin
      shift_by_default <= #TCQ shift_by_default;
  end
end
always @(posedge clk)begin
  if(tg_rst)begin
    wstrb_out_default <= #TCQ {(C_AXI_DATA_WIDTH/8){1'b0}};
  end
  else if(data_en || second_transfer) begin
    wstrb_out_default <= #TCQ (wstrb_initial_default[C_WSTRB_WIDTH -1:0] << shift_by_default);
  end 
  else begin
    wstrb_out_default <= #TCQ wstrb_out;
  end  
end

//assign  wstrb_out_default = wstrb_initial_default_reg[C_WSTRB_WIDTH -1:0] << shift_by_default;

endmodule

//this module generates 32 bit prbs data
module prbs_data_gen
#( parameter C_AXI_ID_WIDTH           = 10,
   parameter C_DATA_PATTERN_PRBS      = 3'd1,
   parameter C_DATA_PATTERN_WALKING0  = 3'd2,
   parameter C_DATA_PATTERN_WALKING1  = 3'd3,
   parameter C_DATA_PATTERN_ALL_F     = 3'd4,
   parameter C_DATA_PATTERN_ALL_0     = 3'd5,
   parameter C_DATA_PATTERN_A5A5      = 3'd6,
   parameter TCQ                      = 100
)
(
   input                               clk,
   input                               data_en,
   input [2:0]                         data_pattern,
   input                               pattern_init,    // when high the patterns are initialized
   input [31 :0]                       prbs_seed_i,
   output reg [31:0]                   data_o           // generated data
);

  reg [31:0]                          prbs;  
  reg [32:1]                          lfsr_q;
  reg [31:0]                          walk0;
  reg [31:0]                          walk1;
 (* dont_touch = "true" *) reg [32:1] lfsr_q_nxt;
  always @ (*) begin
    lfsr_q_nxt <= lfsr_q;
    if (pattern_init) begin //pattern initialisation
      lfsr_q_nxt <= #TCQ {prbs_seed_i + 32'h55555555};
    end
    else if (data_en) begin //generate next data packet
      lfsr_q_nxt[32:9] <= lfsr_q[31:8];
      lfsr_q_nxt[8]    <= lfsr_q[32] ^ lfsr_q[7];
      lfsr_q_nxt[7]    <= lfsr_q[32] ^ lfsr_q[6];
      lfsr_q_nxt[6:4]  <= lfsr_q[5:3];
      
      lfsr_q_nxt[3]    <= lfsr_q[32] ^ lfsr_q[2];
      lfsr_q_nxt[2]    <= lfsr_q[1] ;
      lfsr_q_nxt[1]    <= lfsr_q[32];
    end
  end
  
  always @ (posedge clk) begin
    lfsr_q    <= #TCQ lfsr_q_nxt;
  end

   always @(posedge clk)
     if (pattern_init)
       walk0 <= #TCQ 32'hFFFF_FFFE;
     else if (data_en)
       walk0 <= #TCQ {walk0[30:0],walk0[31]};
     else
       walk0 <= #TCQ walk0;
  
  always @(posedge clk)
    if (pattern_init)
      walk1 <= #TCQ 32'h0000_0001;
    else if (data_en)
      walk1 <= #TCQ {walk1[30:0],walk1[31]};
    else
      walk1 <= #TCQ walk1;
  
  always @(*) begin
    prbs = lfsr_q[32:1];
  end
  
  always @(*) begin
    case (data_pattern)
      C_DATA_PATTERN_PRBS: data_o = prbs; // PRBS pattern
      C_DATA_PATTERN_WALKING0: data_o = walk0; // Walking zeros
      C_DATA_PATTERN_WALKING1: data_o = walk1; // Walking ones
      C_DATA_PATTERN_ALL_F: data_o = 32'hFFFF_FFFF; // All ones
      C_DATA_PATTERN_ALL_0: data_o = 32'h0000_0000; // All zeros
      C_DATA_PATTERN_A5A5: data_o = 32'h5A5A_A5A5; //background pattern
      default: data_o = 32'h0000_0000;//reset value
    endcase
  end
endmodule




