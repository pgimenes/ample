module bram_fifo (
	core_clk,
	resetn,
	push,
	in_data,
	pop,
	out_data,
	count,
	empty,
	full
);
	parameter WRITE_WIDTH = 64;
	parameter WRITE_DEPTH = 512;
	parameter READ_WIDTH = 32;
	parameter READ_DEPTH = 1024;
	parameter BRAM_TYPE = 0;
	input wire core_clk;
	input wire resetn;
	input wire push;
	input wire [WRITE_WIDTH - 1:0] in_data;
	input wire pop;
	output wire [READ_WIDTH - 1:0] out_data;
	output reg [$clog2(READ_DEPTH):0] count;
	output wire empty;
	output wire full;
	parameter WRITE_ADDR_WIDTH = $clog2(WRITE_DEPTH);
	parameter READ_ADDR_WIDTH = $clog2(READ_DEPTH);
	reg [WRITE_ADDR_WIDTH - 1:0] wr_ptr;
	reg [READ_ADDR_WIDTH - 1:0] rd_ptr;
	wire [READ_ADDR_WIDTH - 1:0] read_address;
	assign read_address = (pop ? rd_ptr + 1'b1 : rd_ptr);
	reg wr_wrap;
	reg rd_wrap;
	generate
		if (BRAM_TYPE == 0) begin : genblk1
			scale_factor_queue scale_factor_queue_i(
				.clka(core_clk),
				.ena(1'b1),
				.wea(push),
				.addra(wr_ptr),
				.dina(in_data),
				.clkb(core_clk),
				.enb(1'b1),
				.addrb(read_address),
				.doutb(out_data),
				.sleep(1'b0)
			);
		end
		else if (BRAM_TYPE == 1) begin : genblk1
			router_fifo_sdp_bram router_fifo_sdp_bram_i(
				.clka(core_clk),
				.ena(1'b1),
				.wea(push),
				.addra(wr_ptr),
				.dina(in_data),
				.clkb(core_clk),
				.enb(1'b1),
				.addrb(read_address),
				.doutb(out_data)
			);
		end
		else begin : genblk1
			assign out_data = 1'sb0;
		end
	endgenerate
	always @(posedge core_clk or negedge resetn)
		if (!resetn) begin
			wr_ptr <= 1'sb0;
			rd_ptr <= 1'sb0;
			wr_wrap <= 1'sb0;
			rd_wrap <= 1'sb0;
			count <= 1'sb0;
		end
		else begin
			if (push)
				wr_ptr <= (wr_ptr == (WRITE_DEPTH - 1) ? {WRITE_ADDR_WIDTH {1'sb0}} : wr_ptr + 1'b1);
			if (pop)
				rd_ptr <= (rd_ptr == (READ_DEPTH - 1) ? {READ_ADDR_WIDTH {1'sb0}} : rd_ptr + 1'b1);
			count <= (push && pop ? count : (push ? count + 1'b1 : (pop ? count - 1'b1 : count)));
			if ((wr_ptr == (WRITE_DEPTH - 1)) && push)
				wr_wrap <= !wr_wrap;
			if ((rd_ptr == (READ_DEPTH - 1)) && pop)
				rd_wrap <= !rd_wrap;
		end
	assign empty = (wr_ptr == rd_ptr) && !(wr_wrap ^ rd_wrap);
	assign full = (wr_ptr == rd_ptr) && (wr_wrap ^ rd_wrap);
endmodule
module round_robin_arbiter (
	rst,
	clk,
	requests_i,
	grants_o
);
	parameter AGENTS_NUM = 4;
	input rst;
	input clk;
	input [AGENTS_NUM - 1:0] requests_i;
	output reg [AGENTS_NUM - 1:0] grants_o;
	localparam [31:0] AGENTS_PTR_SIZE = $clog2(AGENTS_NUM);
	reg [AGENTS_PTR_SIZE - 1:0] highest_priority;
	reg [AGENTS_PTR_SIZE - 1:0] highest_priority_next;
	always @(posedge clk or posedge rst)
		if (rst)
			highest_priority <= 0;
		else
			highest_priority <= highest_priority_next;
	always @(*) begin : sv2v_autoblock_1
		reg [0:1] _sv2v_jump;
		_sv2v_jump = 2'b00;
		grants_o = {AGENTS_NUM {1'b0}};
		highest_priority_next = highest_priority;
		begin : sv2v_autoblock_2
			reg signed [31:0] i;
			begin : sv2v_autoblock_3
				reg signed [31:0] _sv2v_value_on_break;
				for (i = 0; i < AGENTS_NUM; i = i + 1)
					if (_sv2v_jump < 2'b10) begin
						_sv2v_jump = 2'b00;
						if (requests_i[(highest_priority + i) % AGENTS_NUM]) begin
							grants_o[(highest_priority + i) % AGENTS_NUM] = 1'b1;
							highest_priority_next = ((highest_priority + i) + 1) % AGENTS_NUM;
							_sv2v_jump = 2'b10;
						end
						_sv2v_value_on_break = i;
					end
				if (!(_sv2v_jump < 2'b10))
					i = _sv2v_value_on_break;
				if (_sv2v_jump != 2'b11)
					_sv2v_jump = 2'b00;
			end
		end
	end
endmodule
module separable_input_first_allocator (
	rst,
	clk,
	request_i,
	out_port_i,
	grant_o
);
	parameter VC_NUM = 2;
	input rst;
	input clk;
	localparam noc_params_PORT_NUM = 5;
	input [(5 * VC_NUM) - 1:0] request_i;
	input wire [((5 * VC_NUM) * 3) - 1:0] out_port_i;
	output reg [(5 * VC_NUM) - 1:0] grant_o;
	reg [24:0] out_request;
	wire [24:0] ip_grant;
	wire [(5 * VC_NUM) - 1:0] vc_grant;
	genvar in_arb;
	generate
		for (in_arb = 0; in_arb < noc_params_PORT_NUM; in_arb = in_arb + 1) begin : generate_input_round_robin_arbiters
			round_robin_arbiter #(.AGENTS_NUM(VC_NUM)) round_robin_arbiter(
				.rst(rst),
				.clk(clk),
				.requests_i(request_i[in_arb * VC_NUM+:VC_NUM]),
				.grants_o(vc_grant[in_arb * VC_NUM+:VC_NUM])
			);
		end
	endgenerate
	genvar out_arb;
	generate
		for (out_arb = 0; out_arb < noc_params_PORT_NUM; out_arb = out_arb + 1) begin : generate_output_round_robin_arbiters
			round_robin_arbiter #(.AGENTS_NUM(noc_params_PORT_NUM)) round_robin_arbiter(
				.rst(rst),
				.clk(clk),
				.requests_i(out_request[out_arb * 5+:5]),
				.grants_o(ip_grant[out_arb * 5+:5])
			);
		end
	endgenerate
	always @(*) begin : sv2v_autoblock_1
		reg [0:1] _sv2v_jump;
		_sv2v_jump = 2'b00;
		out_request = {25 {1'b0}};
		grant_o = {noc_params_PORT_NUM * VC_NUM {1'b0}};
		begin : sv2v_autoblock_2
			reg signed [31:0] in_port;
			begin : sv2v_autoblock_3
				reg signed [31:0] _sv2v_value_on_break;
				for (in_port = 0; in_port < noc_params_PORT_NUM; in_port = in_port + 1)
					if (_sv2v_jump < 2'b10) begin
						_sv2v_jump = 2'b00;
						begin : sv2v_autoblock_4
							reg signed [31:0] in_vc;
							begin : sv2v_autoblock_5
								reg signed [31:0] _sv2v_value_on_break;
								reg [0:1] _sv2v_jump_1;
								_sv2v_jump_1 = _sv2v_jump;
								for (in_vc = 0; in_vc < VC_NUM; in_vc = in_vc + 1)
									if (_sv2v_jump < 2'b10) begin
										_sv2v_jump = 2'b00;
										if (vc_grant[(in_port * VC_NUM) + in_vc]) begin
											out_request[(out_port_i[((in_port * VC_NUM) + in_vc) * 3+:3] * 5) + in_port] = 1'b1;
											_sv2v_jump = 2'b10;
										end
										_sv2v_value_on_break = in_vc;
									end
								if (!(_sv2v_jump < 2'b10))
									in_vc = _sv2v_value_on_break;
								if (_sv2v_jump != 2'b11)
									_sv2v_jump = _sv2v_jump_1;
							end
						end
						_sv2v_value_on_break = in_port;
					end
				if (!(_sv2v_jump < 2'b10))
					in_port = _sv2v_value_on_break;
				if (_sv2v_jump != 2'b11)
					_sv2v_jump = 2'b00;
			end
		end
		if (_sv2v_jump == 2'b00) begin : sv2v_autoblock_6
			reg signed [31:0] out_port;
			begin : sv2v_autoblock_7
				reg signed [31:0] _sv2v_value_on_break;
				for (out_port = 0; out_port < noc_params_PORT_NUM; out_port = out_port + 1)
					if (_sv2v_jump < 2'b10) begin
						_sv2v_jump = 2'b00;
						begin : sv2v_autoblock_8
							reg signed [31:0] in_port;
							begin : sv2v_autoblock_9
								reg signed [31:0] _sv2v_value_on_break;
								reg [0:1] _sv2v_jump_1;
								_sv2v_jump_1 = _sv2v_jump;
								for (in_port = 0; in_port < noc_params_PORT_NUM; in_port = in_port + 1)
									if (_sv2v_jump < 2'b10) begin
										_sv2v_jump = 2'b00;
										begin : sv2v_autoblock_10
											reg signed [31:0] in_vc;
											begin : sv2v_autoblock_11
												reg signed [31:0] _sv2v_value_on_break;
												reg [0:1] _sv2v_jump_2;
												_sv2v_jump_2 = _sv2v_jump;
												for (in_vc = 0; in_vc < VC_NUM; in_vc = in_vc + 1)
													if (_sv2v_jump < 2'b10) begin
														_sv2v_jump = 2'b00;
														if (ip_grant[(out_port * 5) + in_port] & vc_grant[(in_port * VC_NUM) + in_vc]) begin
															grant_o[(in_port * VC_NUM) + in_vc] = 1'b1;
															_sv2v_jump = 2'b10;
														end
														_sv2v_value_on_break = in_vc;
													end
												if (!(_sv2v_jump < 2'b10))
													in_vc = _sv2v_value_on_break;
												if (_sv2v_jump != 2'b11)
													_sv2v_jump = _sv2v_jump_2;
											end
										end
										_sv2v_value_on_break = in_port;
									end
								if (!(_sv2v_jump < 2'b10))
									in_port = _sv2v_value_on_break;
								if (_sv2v_jump != 2'b11)
									_sv2v_jump = _sv2v_jump_1;
							end
						end
						_sv2v_value_on_break = out_port;
					end
				if (!(_sv2v_jump < 2'b10))
					out_port = _sv2v_value_on_break;
				if (_sv2v_jump != 2'b11)
					_sv2v_jump = 2'b00;
			end
		end
	end
endmodule
module circular_buffer (
	data_i,
	read_i,
	write_i,
	rst,
	clk,
	data_o,
	is_full_o,
	is_empty_o,
	on_off_o
);
	parameter BUFFER_SIZE = 8;
	localparam noc_params_MESH_SIZE_X = 65;
	localparam noc_params_DEST_ADDR_SIZE_X = 7;
	localparam noc_params_MESH_SIZE_Y = 5;
	localparam noc_params_DEST_ADDR_SIZE_Y = 3;
	localparam noc_params_HEAD_PAYLOAD_SIZE = 74;
	localparam noc_params_FLIT_DATA_SIZE = 84;
	input wire [85:0] data_i;
	input read_i;
	input write_i;
	input rst;
	input clk;
	output reg [85:0] data_o;
	output reg is_full_o;
	output reg is_empty_o;
	output reg on_off_o;
	localparam ON_OFF_LATENCY = 2;
	localparam [31:0] POINTER_SIZE = $clog2(BUFFER_SIZE);
	reg [85:0] memory [BUFFER_SIZE - 1:0];
	reg [POINTER_SIZE - 1:0] read_ptr;
	reg [POINTER_SIZE - 1:0] write_ptr;
	reg [POINTER_SIZE - 1:0] read_ptr_next;
	reg [POINTER_SIZE - 1:0] write_ptr_next;
	reg is_full_next;
	reg is_empty_next;
	reg on_off_next;
	reg [POINTER_SIZE:0] num_flits;
	reg [POINTER_SIZE:0] num_flits_next;
	always @(posedge clk or posedge rst)
		if (rst) begin
			read_ptr <= 0;
			write_ptr <= 0;
			num_flits <= 0;
			is_full_o <= 0;
			is_empty_o <= 1;
			on_off_o <= 1;
		end
		else begin
			read_ptr <= read_ptr_next;
			write_ptr <= write_ptr_next;
			num_flits <= num_flits_next;
			is_full_o <= is_full_next;
			is_empty_o <= is_empty_next;
			on_off_o <= on_off_next;
			if (((~read_i & write_i) & ~is_full_o) | (read_i & write_i))
				memory[write_ptr] <= data_i;
		end
	function [POINTER_SIZE - 1:0] increase_ptr;
		input reg [POINTER_SIZE - 1:0] ptr;
		if (ptr == (BUFFER_SIZE - 1))
			increase_ptr = 0;
		else
			increase_ptr = ptr + 1;
	endfunction
	task update_empty_on_read;
		if (read_ptr_next == write_ptr)
			is_empty_next = 1;
		else
			is_empty_next = 0;
	endtask
	task update_full_on_write;
		if (write_ptr_next == read_ptr)
			is_full_next = 1;
		else
			is_full_next = 0;
	endtask
	always @(circular_buffer.on_off_o or circular_buffer.num_flits_next or circular_buffer.num_flits_next or circular_buffer.num_flits or circular_buffer.num_flits_next or circular_buffer.num_flits_next or circular_buffer.num_flits or circular_buffer.num_flits or circular_buffer.is_empty_o or circular_buffer.is_full_o or circular_buffer.write_ptr or circular_buffer.read_ptr or circular_buffer.num_flits or circular_buffer.is_empty_o or circular_buffer.is_full_o or circular_buffer.write_ptr or circular_buffer.read_ptr or circular_buffer.is_empty_o or circular_buffer.write_i or circular_buffer.read_i or circular_buffer.num_flits or circular_buffer.read_ptr or circular_buffer.write_ptr_next or circular_buffer.write_ptr or circular_buffer.read_ptr or circular_buffer.is_full_o or circular_buffer.write_i or circular_buffer.read_i or circular_buffer.num_flits or circular_buffer.write_ptr or circular_buffer.read_ptr_next or circular_buffer.write_ptr or circular_buffer.read_ptr or circular_buffer.is_empty_o or circular_buffer.write_i or circular_buffer.read_i or circular_buffer.read_ptr or circular_buffer.memory) begin
		data_o = memory[read_ptr];
		if ((read_i & ~write_i) & ~is_empty_o) begin : read_not_empty
			read_ptr_next = increase_ptr(read_ptr);
			write_ptr_next = write_ptr;
			is_full_next = 0;
			update_empty_on_read;
			num_flits_next = num_flits - 1;
		end
		else if ((~read_i & write_i) & ~is_full_o) begin : write_not_full
			read_ptr_next = read_ptr;
			write_ptr_next = increase_ptr(write_ptr);
			update_full_on_write;
			is_empty_next = 0;
			num_flits_next = num_flits + 1;
		end
		else if ((read_i & write_i) & ~is_empty_o) begin : read_write_not_empty
			read_ptr_next = increase_ptr(read_ptr);
			write_ptr_next = increase_ptr(write_ptr);
			is_full_next = is_full_o;
			is_empty_next = is_empty_o;
			num_flits_next = num_flits;
		end
		else begin : do_nothing
			read_ptr_next = read_ptr;
			write_ptr_next = write_ptr;
			is_full_next = is_full_o;
			is_empty_next = is_empty_o;
			num_flits_next = num_flits;
		end
		begin : update_on_off_flag
			if ((num_flits > num_flits_next) & (num_flits_next < ON_OFF_LATENCY))
				on_off_next = 1;
			else if ((num_flits < num_flits_next) & (num_flits_next > (BUFFER_SIZE - ON_OFF_LATENCY)))
				on_off_next = 0;
			else
				on_off_next = on_off_o;
		end
	end
endmodule
module input_buffer (
	data_i,
	read_i,
	write_i,
	vc_new_i,
	vc_valid_i,
	out_port_i,
	rst,
	clk,
	data_o,
	is_full_o,
	is_empty_o,
	on_off_o,
	out_port_o,
	vc_request_o,
	switch_request_o,
	vc_allocatable_o,
	downstream_vc_o,
	error_o
);
	parameter BUFFER_SIZE = 8;
	localparam noc_params_MESH_SIZE_X = 65;
	localparam noc_params_DEST_ADDR_SIZE_X = 7;
	localparam noc_params_MESH_SIZE_Y = 5;
	localparam noc_params_DEST_ADDR_SIZE_Y = 3;
	localparam noc_params_HEAD_PAYLOAD_SIZE = 74;
	localparam noc_params_FLIT_DATA_SIZE = 84;
	input wire [85:0] data_i;
	input read_i;
	input write_i;
	localparam noc_params_VC_NUM = 1;
	localparam noc_params_VC_SIZE = 0;
	input [noc_params_VC_SIZE - 1:0] vc_new_i;
	input vc_valid_i;
	input wire [2:0] out_port_i;
	input rst;
	input clk;
	output reg [85:0] data_o;
	output wire is_full_o;
	output wire is_empty_o;
	output reg on_off_o;
	output reg [2:0] out_port_o;
	output reg vc_request_o;
	output reg switch_request_o;
	output reg vc_allocatable_o;
	output reg [noc_params_VC_SIZE - 1:0] downstream_vc_o;
	output reg error_o;
	reg [1:0] ss;
	reg [1:0] ss_next;
	reg [noc_params_VC_SIZE - 1:0] downstream_vc_next;
	reg read_cmd;
	reg write_cmd;
	reg end_packet;
	reg end_packet_next;
	reg vc_allocatable_next;
	reg error_next;
	wire [85:0] read_flit;
	reg [2:0] out_port_next;
	wire [$clog2(BUFFER_SIZE):0] circular_buffer_count;
	bram_fifo #(
		.WRITE_WIDTH(86),
		.WRITE_DEPTH(BUFFER_SIZE),
		.READ_WIDTH(86),
		.READ_DEPTH(BUFFER_SIZE),
		.BRAM_TYPE(1)
	) circular_buffer(
		.core_clk(clk),
		.resetn(rst),
		.push(write_cmd),
		.in_data(data_i),
		.pop(read_cmd),
		.out_data(read_flit),
		.count(circular_buffer_count),
		.full(is_full_o),
		.empty(is_empty_o)
	);
	localparam ON_OFF_LATENCY = 2;
	always @(posedge clk or posedge rst)
		if (rst)
			on_off_o <= 1'sb1;
		else
			on_off_o <= ((!write_cmd && read_cmd) && (circular_buffer_count < 3) ? 1'b1 : ((write_cmd && !read_cmd) && (circular_buffer_count > (BUFFER_SIZE - 3)) ? 1'b0 : on_off_o));
	always @(posedge clk or posedge rst)
		if (rst) begin
			ss <= 2'd0;
			out_port_o <= 3'd0;
			downstream_vc_o <= 0;
			end_packet <= 0;
			vc_allocatable_o <= 0;
			error_o <= 0;
		end
		else begin
			ss <= ss_next;
			out_port_o <= out_port_next;
			downstream_vc_o <= downstream_vc_next;
			end_packet <= end_packet_next;
			vc_allocatable_o <= vc_allocatable_next;
			error_o <= error_next;
		end
	always @(*) begin
		data_o[85-:2] = read_flit[85-:2];
		data_o[83-:2] = downstream_vc_o;
		data_o[83-:84] = read_flit[83-:84];
		ss_next = ss;
		out_port_next = out_port_o;
		downstream_vc_next = downstream_vc_o;
		read_cmd = 0;
		write_cmd = 0;
		end_packet_next = end_packet;
		error_next = 0;
		vc_request_o = 0;
		switch_request_o = 0;
		vc_allocatable_next = 0;
		case (ss)
			2'd0: begin
				if ((((data_i[85-:2] == 2'd0) | (data_i[85-:2] == 2'd3)) & write_i) & is_empty_o) begin
					ss_next = 2'd1;
					out_port_next = out_port_i;
					write_cmd = 1;
				end
				if (((vc_valid_i | read_i) | (((data_i[85-:2] == 2'd1) | (data_i[85-:2] == 2'd2)) & write_i)) | ~is_empty_o)
					error_next = 1;
				if (write_i & (data_i[85-:2] == 2'd3))
					end_packet_next = 1;
			end
			2'd1: begin
				if (vc_valid_i) begin
					ss_next = 2'd2;
					downstream_vc_next = vc_new_i;
				end
				vc_request_o = 1;
				if ((write_i & ((data_i[85-:2] == 2'd1) | (data_i[85-:2] == 2'd2))) & ~end_packet)
					write_cmd = 1;
				if ((write_i & ((end_packet | (data_i[85-:2] == 2'd0)) | (data_i[85-:2] == 2'd3))) | read_i)
					error_next = 1;
				if (write_i & (data_i[85-:2] == 2'd2))
					end_packet_next = 1;
			end
			2'd2: begin
				if (read_i & ((data_o[85-:2] == 2'd2) | (data_o[85-:2] == 2'd3))) begin
					ss_next = 2'd0;
					vc_allocatable_next = 1;
					end_packet_next = 0;
				end
				if (~is_empty_o)
					switch_request_o = 1;
				read_cmd = read_i;
				if ((write_i & ((data_i[85-:2] == 2'd1) | (data_i[85-:2] == 2'd2))) & ~end_packet)
					write_cmd = 1;
				if ((write_i & ((end_packet | (data_i[85-:2] == 2'd0)) | (data_i[85-:2] == 2'd3))) | vc_valid_i)
					error_next = 1;
				if (write_i & (data_i[85-:2] == 2'd2))
					end_packet_next = 1;
			end
			default: begin
				ss_next = 2'd0;
				vc_allocatable_next = 1;
				error_next = 1;
				end_packet_next = 0;
			end
		endcase
	end
endmodule
module input_port (
	data_i,
	valid_flit_i,
	rst,
	clk,
	sa_sel_vc_i,
	va_new_vc_i,
	va_valid_i,
	sa_valid_i,
	xb_flit_o,
	is_on_off_o,
	is_allocatable_vc_o,
	va_request_o,
	sa_request_o,
	sa_downstream_vc_o,
	out_port_o,
	is_full_o,
	is_empty_o,
	error_o
);
	parameter BUFFER_SIZE = 8;
	localparam noc_params_MESH_SIZE_X = 65;
	parameter X_CURRENT = 32;
	localparam noc_params_MESH_SIZE_Y = 5;
	parameter Y_CURRENT = 2;
	localparam noc_params_DEST_ADDR_SIZE_X = 7;
	localparam noc_params_DEST_ADDR_SIZE_Y = 3;
	localparam noc_params_HEAD_PAYLOAD_SIZE = 74;
	localparam noc_params_FLIT_DATA_SIZE = 84;
	localparam noc_params_VC_NUM = 1;
	localparam noc_params_VC_SIZE = 0;
	input wire [85:0] data_i;
	input valid_flit_i;
	input rst;
	input clk;
	input [noc_params_VC_SIZE - 1:0] sa_sel_vc_i;
	input [noc_params_VC_SIZE - 1:0] va_new_vc_i;
	input [0:0] va_valid_i;
	input sa_valid_i;
	output reg [85:0] xb_flit_o;
	output wire [0:0] is_on_off_o;
	output wire [0:0] is_allocatable_vc_o;
	output wire [0:0] va_request_o;
	output wire [0:0] sa_request_o;
	output wire [noc_params_VC_SIZE - 1:0] sa_downstream_vc_o;
	output wire [2:0] out_port_o;
	output wire [0:0] is_full_o;
	output wire [0:0] is_empty_o;
	output wire [0:0] error_o;
	reg [85:0] data_cmd;
	wire [85:0] data_out;
	wire [2:0] out_port_cmd;
	reg [0:0] read_cmd;
	reg [0:0] write_cmd;
	genvar vc;
	generate
		for (vc = 0; vc < noc_params_VC_NUM; vc = vc + 1) begin : generate_virtual_channels
			input_buffer #(.BUFFER_SIZE(BUFFER_SIZE)) input_buffer(
				.data_i(data_cmd),
				.read_i(read_cmd[vc]),
				.write_i(write_cmd[vc]),
				.vc_new_i(va_new_vc_i[0+:noc_params_VC_SIZE]),
				.vc_valid_i(va_valid_i[vc]),
				.out_port_i(out_port_cmd),
				.rst(rst),
				.clk(clk),
				.data_o(data_out[vc * 86+:86]),
				.is_full_o(is_full_o[vc]),
				.is_empty_o(is_empty_o[vc]),
				.on_off_o(is_on_off_o[vc]),
				.out_port_o(out_port_o[vc * 3+:3]),
				.vc_request_o(va_request_o[vc]),
				.switch_request_o(sa_request_o[vc]),
				.vc_allocatable_o(is_allocatable_vc_o[vc]),
				.downstream_vc_o(sa_downstream_vc_o[0+:noc_params_VC_SIZE]),
				.error_o(error_o[vc])
			);
		end
	endgenerate
	rc_unit #(
		.X_CURRENT(X_CURRENT),
		.Y_CURRENT(Y_CURRENT),
		.DEST_ADDR_SIZE_X(noc_params_DEST_ADDR_SIZE_X),
		.DEST_ADDR_SIZE_Y(noc_params_DEST_ADDR_SIZE_Y)
	) rc_unit(
		.x_dest_i(data_i[83-:7]),
		.y_dest_i(data_i[76-:3]),
		.out_port_o(out_port_cmd)
	);
	always @(*) begin
		data_cmd[85-:2] = data_i[85-:2];
		data_cmd[83-:84] = data_i[83-:84];
		write_cmd = {noc_params_VC_NUM {1'b0}};
		if (valid_flit_i)
			write_cmd[data_i[83-:2]] = 1;
		read_cmd = {noc_params_VC_NUM {1'b0}};
		if (sa_valid_i)
			read_cmd[sa_sel_vc_i] = 1;
		xb_flit_o = data_out[sa_sel_vc_i * 86+:86];
	end
endmodule
module rc_unit (
	x_dest_i,
	y_dest_i,
	out_port_o
);
	parameter X_CURRENT = 0;
	parameter Y_CURRENT = 0;
	parameter DEST_ADDR_SIZE_X = 4;
	parameter DEST_ADDR_SIZE_Y = 4;
	input wire [DEST_ADDR_SIZE_X - 1:0] x_dest_i;
	input wire [DEST_ADDR_SIZE_Y - 1:0] y_dest_i;
	output reg [2:0] out_port_o;
	wire signed [DEST_ADDR_SIZE_X:0] x_offset;
	wire signed [DEST_ADDR_SIZE_Y:0] y_offset;
	assign x_offset = {1'b0, x_dest_i} - X_CURRENT;
	assign y_offset = {1'b0, y_dest_i} - Y_CURRENT;
	always @(*)
		if (x_offset < 0)
			out_port_o = 3'd3;
		else if (x_offset > 0)
			out_port_o = 3'd4;
		else if ((x_offset == 0) & (y_offset < 0))
			out_port_o = 3'd1;
		else if ((x_offset == 0) & (y_offset > 0))
			out_port_o = 3'd2;
		else
			out_port_o = 3'd0;
endmodule
module mesh (
	clk,
	rst,
	error_o,
	data_o,
	is_valid_o,
	is_on_off_i,
	is_allocatable_i,
	data_i,
	is_valid_i,
	is_on_off_o,
	is_allocatable_o
);
	parameter BUFFER_SIZE = 8;
	parameter MESH_SIZE_X = 2;
	parameter MESH_SIZE_Y = 3;
	input clk;
	input rst;
	localparam noc_params_PORT_NUM = 5;
	localparam noc_params_VC_NUM = 1;
	output wire [((MESH_SIZE_X * MESH_SIZE_Y) * 5) - 1:0] error_o;
	localparam noc_params_MESH_SIZE_X = 65;
	localparam noc_params_DEST_ADDR_SIZE_X = 7;
	localparam noc_params_MESH_SIZE_Y = 5;
	localparam noc_params_DEST_ADDR_SIZE_Y = 3;
	localparam noc_params_HEAD_PAYLOAD_SIZE = 74;
	localparam noc_params_FLIT_DATA_SIZE = 84;
	localparam noc_params_VC_SIZE = 0;
	output wire [((MESH_SIZE_X * MESH_SIZE_Y) * 86) - 1:0] data_o;
	output wire [(MESH_SIZE_X * MESH_SIZE_Y) - 1:0] is_valid_o;
	input [(MESH_SIZE_X * MESH_SIZE_Y) - 1:0] is_on_off_i;
	input [(MESH_SIZE_X * MESH_SIZE_Y) - 1:0] is_allocatable_i;
	input wire [((MESH_SIZE_X * MESH_SIZE_Y) * 86) - 1:0] data_i;
	input [(MESH_SIZE_X * MESH_SIZE_Y) - 1:0] is_valid_i;
	output wire [(MESH_SIZE_X * MESH_SIZE_Y) - 1:0] is_on_off_o;
	output wire [(MESH_SIZE_X * MESH_SIZE_Y) - 1:0] is_allocatable_o;
	genvar row;
	genvar col;
	generate
		for (row = 0; row < MESH_SIZE_Y; row = row + 1) begin : mesh_row
			for (col = 0; col < MESH_SIZE_X; col = col + 1) begin : mesh_col
				if (1) begin : local_up
					localparam noc_params_MESH_SIZE_X = 65;
					localparam noc_params_DEST_ADDR_SIZE_X = 7;
					localparam noc_params_MESH_SIZE_Y = 5;
					localparam noc_params_DEST_ADDR_SIZE_Y = 3;
					localparam noc_params_HEAD_PAYLOAD_SIZE = 74;
					localparam noc_params_FLIT_DATA_SIZE = 84;
					localparam noc_params_VC_NUM = 1;
					localparam noc_params_VC_SIZE = 0;
					reg [87:0] data;
					reg is_valid;
					reg [0:0] is_on_off;
					reg [0:0] is_allocatable;
				end
				if (1) begin : north_up
					localparam noc_params_MESH_SIZE_X = 65;
					localparam noc_params_DEST_ADDR_SIZE_X = 7;
					localparam noc_params_MESH_SIZE_Y = 5;
					localparam noc_params_DEST_ADDR_SIZE_Y = 3;
					localparam noc_params_HEAD_PAYLOAD_SIZE = 74;
					localparam noc_params_FLIT_DATA_SIZE = 84;
					localparam noc_params_VC_NUM = 1;
					localparam noc_params_VC_SIZE = 0;
					reg [87:0] data;
					reg is_valid;
					reg [0:0] is_on_off;
					reg [0:0] is_allocatable;
				end
				if (1) begin : south_up
					localparam noc_params_MESH_SIZE_X = 65;
					localparam noc_params_DEST_ADDR_SIZE_X = 7;
					localparam noc_params_MESH_SIZE_Y = 5;
					localparam noc_params_DEST_ADDR_SIZE_Y = 3;
					localparam noc_params_HEAD_PAYLOAD_SIZE = 74;
					localparam noc_params_FLIT_DATA_SIZE = 84;
					localparam noc_params_VC_NUM = 1;
					localparam noc_params_VC_SIZE = 0;
					reg [87:0] data;
					reg is_valid;
					reg [0:0] is_on_off;
					reg [0:0] is_allocatable;
				end
				if (1) begin : west_up
					localparam noc_params_MESH_SIZE_X = 65;
					localparam noc_params_DEST_ADDR_SIZE_X = 7;
					localparam noc_params_MESH_SIZE_Y = 5;
					localparam noc_params_DEST_ADDR_SIZE_Y = 3;
					localparam noc_params_HEAD_PAYLOAD_SIZE = 74;
					localparam noc_params_FLIT_DATA_SIZE = 84;
					localparam noc_params_VC_NUM = 1;
					localparam noc_params_VC_SIZE = 0;
					reg [87:0] data;
					reg is_valid;
					reg [0:0] is_on_off;
					reg [0:0] is_allocatable;
				end
				if (1) begin : east_up
					localparam noc_params_MESH_SIZE_X = 65;
					localparam noc_params_DEST_ADDR_SIZE_X = 7;
					localparam noc_params_MESH_SIZE_Y = 5;
					localparam noc_params_DEST_ADDR_SIZE_Y = 3;
					localparam noc_params_HEAD_PAYLOAD_SIZE = 74;
					localparam noc_params_FLIT_DATA_SIZE = 84;
					localparam noc_params_VC_NUM = 1;
					localparam noc_params_VC_SIZE = 0;
					reg [87:0] data;
					reg is_valid;
					reg [0:0] is_on_off;
					reg [0:0] is_allocatable;
				end
				if (1) begin : local_down
					localparam noc_params_MESH_SIZE_X = 65;
					localparam noc_params_DEST_ADDR_SIZE_X = 7;
					localparam noc_params_MESH_SIZE_Y = 5;
					localparam noc_params_DEST_ADDR_SIZE_Y = 3;
					localparam noc_params_HEAD_PAYLOAD_SIZE = 74;
					localparam noc_params_FLIT_DATA_SIZE = 84;
					localparam noc_params_VC_NUM = 1;
					localparam noc_params_VC_SIZE = 0;
					reg [87:0] data;
					reg is_valid;
					reg [0:0] is_on_off;
					reg [0:0] is_allocatable;
				end
				if (1) begin : north_down
					localparam noc_params_MESH_SIZE_X = 65;
					localparam noc_params_DEST_ADDR_SIZE_X = 7;
					localparam noc_params_MESH_SIZE_Y = 5;
					localparam noc_params_DEST_ADDR_SIZE_Y = 3;
					localparam noc_params_HEAD_PAYLOAD_SIZE = 74;
					localparam noc_params_FLIT_DATA_SIZE = 84;
					localparam noc_params_VC_NUM = 1;
					localparam noc_params_VC_SIZE = 0;
					reg [87:0] data;
					reg is_valid;
					reg [0:0] is_on_off;
					reg [0:0] is_allocatable;
				end
				if (1) begin : south_down
					localparam noc_params_MESH_SIZE_X = 65;
					localparam noc_params_DEST_ADDR_SIZE_X = 7;
					localparam noc_params_MESH_SIZE_Y = 5;
					localparam noc_params_DEST_ADDR_SIZE_Y = 3;
					localparam noc_params_HEAD_PAYLOAD_SIZE = 74;
					localparam noc_params_FLIT_DATA_SIZE = 84;
					localparam noc_params_VC_NUM = 1;
					localparam noc_params_VC_SIZE = 0;
					reg [87:0] data;
					reg is_valid;
					reg [0:0] is_on_off;
					reg [0:0] is_allocatable;
				end
				if (1) begin : west_down
					localparam noc_params_MESH_SIZE_X = 65;
					localparam noc_params_DEST_ADDR_SIZE_X = 7;
					localparam noc_params_MESH_SIZE_Y = 5;
					localparam noc_params_DEST_ADDR_SIZE_Y = 3;
					localparam noc_params_HEAD_PAYLOAD_SIZE = 74;
					localparam noc_params_FLIT_DATA_SIZE = 84;
					localparam noc_params_VC_NUM = 1;
					localparam noc_params_VC_SIZE = 0;
					reg [87:0] data;
					reg is_valid;
					reg [0:0] is_on_off;
					reg [0:0] is_allocatable;
				end
				if (1) begin : east_down
					localparam noc_params_MESH_SIZE_X = 65;
					localparam noc_params_DEST_ADDR_SIZE_X = 7;
					localparam noc_params_MESH_SIZE_Y = 5;
					localparam noc_params_DEST_ADDR_SIZE_Y = 3;
					localparam noc_params_HEAD_PAYLOAD_SIZE = 74;
					localparam noc_params_FLIT_DATA_SIZE = 84;
					localparam noc_params_VC_NUM = 1;
					localparam noc_params_VC_SIZE = 0;
					reg [87:0] data;
					reg is_valid;
					reg [0:0] is_on_off;
					reg [0:0] is_allocatable;
				end
				localparam _param_A4462_BUFFER_SIZE = BUFFER_SIZE;
				localparam _param_A4462_X_CURRENT = col;
				localparam _param_A4462_Y_CURRENT = row;
				if (1) begin : router
					localparam BUFFER_SIZE = _param_A4462_BUFFER_SIZE;
					localparam noc_params_MESH_SIZE_X = 65;
					localparam X_CURRENT = _param_A4462_X_CURRENT;
					localparam noc_params_MESH_SIZE_Y = 5;
					localparam Y_CURRENT = _param_A4462_Y_CURRENT;
					wire clk;
					wire rst;
					localparam noc_params_PORT_NUM = 5;
					localparam noc_params_VC_NUM = 1;
					wire [4:0] error_o;
					localparam noc_params_DEST_ADDR_SIZE_X = 7;
					localparam noc_params_DEST_ADDR_SIZE_Y = 3;
					localparam noc_params_HEAD_PAYLOAD_SIZE = 74;
					localparam noc_params_FLIT_DATA_SIZE = 84;
					localparam noc_params_VC_SIZE = 0;
					wire [439:0] data_out;
					wire [4:0] is_valid_out;
					reg [4:0] is_on_off_in;
					reg [4:0] is_allocatable_in;
					reg [439:0] data_in;
					reg [4:0] is_valid_in;
					wire [4:0] is_on_off_out;
					wire [4:0] is_allocatable_out;
					always @(*) begin
						mesh.mesh_row[row].mesh_col[col].local_up.data = data_out[3'd0 * 88+:88];
						mesh.mesh_row[row].mesh_col[col].north_up.data = data_out[3'd1 * 88+:88];
						mesh.mesh_row[row].mesh_col[col].south_up.data = data_out[3'd2 * 88+:88];
						mesh.mesh_row[row].mesh_col[col].west_up.data = data_out[3'd3 * 88+:88];
						mesh.mesh_row[row].mesh_col[col].east_up.data = data_out[3'd4 * 88+:88];
						mesh.mesh_row[row].mesh_col[col].local_up.is_valid = is_valid_out[3'd0];
						mesh.mesh_row[row].mesh_col[col].north_up.is_valid = is_valid_out[3'd1];
						mesh.mesh_row[row].mesh_col[col].south_up.is_valid = is_valid_out[3'd2];
						mesh.mesh_row[row].mesh_col[col].west_up.is_valid = is_valid_out[3'd3];
						mesh.mesh_row[row].mesh_col[col].east_up.is_valid = is_valid_out[3'd4];
						is_on_off_in[3'd0+:1] = mesh.mesh_row[row].mesh_col[col].local_up.is_on_off;
						is_on_off_in[3'd1+:1] = mesh.mesh_row[row].mesh_col[col].north_up.is_on_off;
						is_on_off_in[3'd2+:1] = mesh.mesh_row[row].mesh_col[col].south_up.is_on_off;
						is_on_off_in[3'd3+:1] = mesh.mesh_row[row].mesh_col[col].west_up.is_on_off;
						is_on_off_in[3'd4+:1] = mesh.mesh_row[row].mesh_col[col].east_up.is_on_off;
						is_allocatable_in[3'd0+:1] = mesh.mesh_row[row].mesh_col[col].local_up.is_allocatable;
						is_allocatable_in[3'd1+:1] = mesh.mesh_row[row].mesh_col[col].north_up.is_allocatable;
						is_allocatable_in[3'd2+:1] = mesh.mesh_row[row].mesh_col[col].south_up.is_allocatable;
						is_allocatable_in[3'd3+:1] = mesh.mesh_row[row].mesh_col[col].west_up.is_allocatable;
						is_allocatable_in[3'd4+:1] = mesh.mesh_row[row].mesh_col[col].east_up.is_allocatable;
						data_in[3'd0 * 88+:88] = mesh.mesh_row[row].mesh_col[col].local_down.data;
						data_in[3'd1 * 88+:88] = mesh.mesh_row[row].mesh_col[col].north_down.data;
						data_in[3'd2 * 88+:88] = mesh.mesh_row[row].mesh_col[col].south_down.data;
						data_in[3'd3 * 88+:88] = mesh.mesh_row[row].mesh_col[col].west_down.data;
						data_in[3'd4 * 88+:88] = mesh.mesh_row[row].mesh_col[col].east_down.data;
						is_valid_in[3'd0] = mesh.mesh_row[row].mesh_col[col].local_down.is_valid;
						is_valid_in[3'd1] = mesh.mesh_row[row].mesh_col[col].north_down.is_valid;
						is_valid_in[3'd2] = mesh.mesh_row[row].mesh_col[col].south_down.is_valid;
						is_valid_in[3'd3] = mesh.mesh_row[row].mesh_col[col].west_down.is_valid;
						is_valid_in[3'd4] = mesh.mesh_row[row].mesh_col[col].east_down.is_valid;
						mesh.mesh_row[row].mesh_col[col].local_down.is_on_off = is_on_off_out[3'd0+:1];
						mesh.mesh_row[row].mesh_col[col].north_down.is_on_off = is_on_off_out[3'd1+:1];
						mesh.mesh_row[row].mesh_col[col].south_down.is_on_off = is_on_off_out[3'd2+:1];
						mesh.mesh_row[row].mesh_col[col].west_down.is_on_off = is_on_off_out[3'd3+:1];
						mesh.mesh_row[row].mesh_col[col].east_down.is_on_off = is_on_off_out[3'd4+:1];
						mesh.mesh_row[row].mesh_col[col].local_down.is_allocatable = is_allocatable_out[3'd0+:1];
						mesh.mesh_row[row].mesh_col[col].north_down.is_allocatable = is_allocatable_out[3'd1+:1];
						mesh.mesh_row[row].mesh_col[col].south_down.is_allocatable = is_allocatable_out[3'd2+:1];
						mesh.mesh_row[row].mesh_col[col].west_down.is_allocatable = is_allocatable_out[3'd3+:1];
						mesh.mesh_row[row].mesh_col[col].east_down.is_allocatable = is_allocatable_out[3'd4+:1];
					end
					if (1) begin : ib2xbar_if
						localparam noc_params_PORT_NUM = 5;
						localparam noc_params_MESH_SIZE_X = 65;
						localparam noc_params_DEST_ADDR_SIZE_X = 7;
						localparam noc_params_MESH_SIZE_Y = 5;
						localparam noc_params_DEST_ADDR_SIZE_Y = 3;
						localparam noc_params_HEAD_PAYLOAD_SIZE = 74;
						localparam noc_params_FLIT_DATA_SIZE = 84;
						localparam noc_params_VC_NUM = 1;
						localparam noc_params_VC_SIZE = 0;
						wire [87:0] flit [4:0];
					end
					if (1) begin : ib2sa_if
						localparam noc_params_PORT_NUM = 5;
						localparam noc_params_VC_NUM = 1;
						wire [14:0] out_port;
						localparam noc_params_VC_SIZE = 0;
						reg [noc_params_VC_SIZE - 1:0] vc_sel [4:0];
						reg valid_sel [4:0];
						wire [noc_params_VC_SIZE - 1:0] downstream_vc [4:0];
						wire [0:0] switch_request [4:0];
					end
					if (1) begin : ib2va_if
						localparam noc_params_PORT_NUM = 5;
						localparam noc_params_VC_NUM = 1;
						localparam noc_params_VC_SIZE = 0;
						reg [noc_params_VC_SIZE - 1:0] vc_new [4:0];
						reg [0:0] vc_valid [4:0];
						wire [0:0] vc_request [4:0];
						wire [14:0] out_port;
					end
					if (1) begin : sa2xbar_if
						localparam noc_params_PORT_NUM = 5;
						localparam noc_params_PORT_SIZE = 3;
						reg [2:0] input_vc_sel [4:0];
					end
					localparam _param_79982_BUFFER_SIZE = BUFFER_SIZE;
					localparam _param_79982_X_CURRENT = X_CURRENT;
					localparam _param_79982_Y_CURRENT = Y_CURRENT;
					if (1) begin : input_block
						localparam PORT_NUM = 5;
						localparam BUFFER_SIZE = _param_79982_BUFFER_SIZE;
						localparam noc_params_MESH_SIZE_X = 65;
						localparam X_CURRENT = _param_79982_X_CURRENT;
						localparam noc_params_MESH_SIZE_Y = 5;
						localparam Y_CURRENT = _param_79982_Y_CURRENT;
						localparam noc_params_DEST_ADDR_SIZE_X = 7;
						localparam noc_params_DEST_ADDR_SIZE_Y = 3;
						localparam noc_params_HEAD_PAYLOAD_SIZE = 74;
						localparam noc_params_FLIT_DATA_SIZE = 84;
						localparam noc_params_VC_NUM = 1;
						localparam noc_params_VC_SIZE = 0;
						wire [439:0] data_i;
						wire [4:0] valid_flit_i;
						wire rst;
						wire clk;
						wire [4:0] on_off_o;
						wire [4:0] vc_allocatable_o;
						wire [4:0] error_o;
						wire [0:0] is_full [4:0];
						wire [0:0] is_empty [4:0];
						wire [14:0] out_port;
						assign mesh.mesh_row[row].mesh_col[col].router.ib2va_if.out_port = out_port;
						assign mesh.mesh_row[row].mesh_col[col].router.ib2sa_if.out_port = out_port;
						genvar ip;
						for (ip = 0; ip < PORT_NUM; ip = ip + 1) begin : generate_input_ports
							input_port #(
								.BUFFER_SIZE(BUFFER_SIZE),
								.X_CURRENT(X_CURRENT),
								.Y_CURRENT(Y_CURRENT)
							) input_port(
								.data_i(data_i[ip * 88+:88]),
								.valid_flit_i(valid_flit_i[ip]),
								.rst(rst),
								.clk(clk),
								.sa_sel_vc_i(mesh.mesh_row[row].mesh_col[col].router.ib2sa_if.vc_sel[ip]),
								.va_new_vc_i(mesh.mesh_row[row].mesh_col[col].router.ib2va_if.vc_new[ip]),
								.va_valid_i(mesh.mesh_row[row].mesh_col[col].router.ib2va_if.vc_valid[ip]),
								.sa_valid_i(mesh.mesh_row[row].mesh_col[col].router.ib2sa_if.valid_sel[ip]),
								.xb_flit_o(mesh.mesh_row[row].mesh_col[col].router.ib2xbar_if.flit[ip]),
								.is_on_off_o(on_off_o[ip+:1]),
								.is_allocatable_vc_o(vc_allocatable_o[ip+:1]),
								.va_request_o(mesh.mesh_row[row].mesh_col[col].router.ib2va_if.vc_request[ip]),
								.sa_request_o(mesh.mesh_row[row].mesh_col[col].router.ib2sa_if.switch_request[ip]),
								.sa_downstream_vc_o(mesh.mesh_row[row].mesh_col[col].router.ib2sa_if.downstream_vc[ip]),
								.out_port_o(out_port[3 * ip+:3]),
								.is_full_o(is_full[ip]),
								.is_empty_o(is_empty[ip]),
								.error_o(error_o[ip+:1])
							);
						end
					end
					assign input_block.rst = rst;
					assign input_block.clk = clk;
					assign input_block.data_i = data_in;
					assign input_block.valid_flit_i = is_valid_in;
					assign is_on_off_out = input_block.on_off_o;
					assign is_allocatable_out = input_block.vc_allocatable_o;
					assign error_o = input_block.error_o;
					if (1) begin : crossbar
						localparam noc_params_PORT_NUM = 5;
						localparam noc_params_MESH_SIZE_X = 65;
						localparam noc_params_DEST_ADDR_SIZE_X = 7;
						localparam noc_params_MESH_SIZE_Y = 5;
						localparam noc_params_DEST_ADDR_SIZE_Y = 3;
						localparam noc_params_HEAD_PAYLOAD_SIZE = 74;
						localparam noc_params_FLIT_DATA_SIZE = 84;
						localparam noc_params_VC_NUM = 1;
						localparam noc_params_VC_SIZE = 0;
						reg [439:0] data_o;
						always @(*) begin : sv2v_autoblock_1
							reg signed [31:0] ip;
							for (ip = 0; ip < noc_params_PORT_NUM; ip = ip + 1)
								data_o[ip * 88+:88] = mesh.mesh_row[row].mesh_col[col].router.ib2xbar_if.flit[mesh.mesh_row[row].mesh_col[col].router.sa2xbar_if.input_vc_sel[ip]];
						end
					end
					assign data_out = crossbar.data_o;
					if (1) begin : switch_allocator
						wire rst;
						wire clk;
						localparam noc_params_PORT_NUM = 5;
						localparam noc_params_VC_NUM = 1;
						wire [4:0] on_off_i;
						reg [4:0] valid_flit_o;
						reg [4:0] request_cmd;
						wire [4:0] grant;
						separable_input_first_allocator #(.VC_NUM(noc_params_VC_NUM)) separable_input_first_allocator(
							.rst(rst),
							.clk(clk),
							.request_i(request_cmd),
							.out_port_i(mesh.mesh_row[row].mesh_col[col].router.ib2sa_if.out_port),
							.grant_o(grant)
						);
						localparam noc_params_PORT_SIZE = 3;
						localparam noc_params_VC_SIZE = 0;
						always @(*) begin
							begin : sv2v_autoblock_2
								reg signed [31:0] port;
								for (port = 0; port < noc_params_PORT_NUM; port = port + 1)
									begin
										mesh.mesh_row[row].mesh_col[col].router.ib2sa_if.valid_sel[port] = 1'b0;
										valid_flit_o[port] = 1'b0;
										mesh.mesh_row[row].mesh_col[col].router.ib2sa_if.vc_sel[port] = {noc_params_VC_SIZE {1'b0}};
										mesh.mesh_row[row].mesh_col[col].router.sa2xbar_if.input_vc_sel[port] = {noc_params_PORT_SIZE {1'b0}};
										request_cmd[port+:1] = {noc_params_VC_NUM {1'b0}};
									end
							end
							begin : sv2v_autoblock_3
								reg signed [31:0] up_port;
								for (up_port = 0; up_port < noc_params_PORT_NUM; up_port = up_port + 1)
									begin : sv2v_autoblock_4
										reg signed [31:0] up_vc;
										for (up_vc = 0; up_vc < noc_params_VC_NUM; up_vc = up_vc + 1)
											if (mesh.mesh_row[row].mesh_col[col].router.ib2sa_if.switch_request[up_port][up_vc] & on_off_i[mesh.mesh_row[row].mesh_col[col].router.ib2sa_if.out_port[(up_port + up_vc) * 3+:3] + mesh.mesh_row[row].mesh_col[col].router.ib2sa_if.downstream_vc[up_port][0+:0]])
												request_cmd[up_port + up_vc] = 1'b1;
									end
							end
							begin : sv2v_autoblock_5
								reg signed [31:0] up_port;
								for (up_port = 0; up_port < noc_params_PORT_NUM; up_port = up_port + 1)
									begin : sv2v_autoblock_6
										reg signed [31:0] up_vc;
										for (up_vc = 0; up_vc < noc_params_VC_NUM; up_vc = up_vc + 1)
											if (grant[up_port + up_vc]) begin
												mesh.mesh_row[row].mesh_col[col].router.ib2sa_if.vc_sel[up_port] = up_vc;
												mesh.mesh_row[row].mesh_col[col].router.ib2sa_if.valid_sel[up_port] = 1'b1;
												valid_flit_o[mesh.mesh_row[row].mesh_col[col].router.ib2sa_if.out_port[(up_port + up_vc) * 3+:3]] = 1'b1;
												mesh.mesh_row[row].mesh_col[col].router.sa2xbar_if.input_vc_sel[mesh.mesh_row[row].mesh_col[col].router.ib2sa_if.out_port[(up_port + up_vc) * 3+:3]] = up_port;
											end
									end
							end
						end
					end
					assign switch_allocator.rst = rst;
					assign switch_allocator.clk = clk;
					assign switch_allocator.on_off_i = is_on_off_in;
					assign is_valid_out = switch_allocator.valid_flit_o;
					if (1) begin : vc_allocator
						wire rst;
						wire clk;
						localparam noc_params_PORT_NUM = 5;
						localparam noc_params_VC_NUM = 1;
						wire [4:0] idle_downstream_vc_i;
						reg [4:0] request_cmd;
						wire [4:0] grant;
						reg [4:0] is_available_vc;
						reg [4:0] is_available_vc_next;
						separable_input_first_allocator #(.VC_NUM(noc_params_VC_NUM)) separable_input_first_allocator(
							.rst(rst),
							.clk(clk),
							.request_i(request_cmd),
							.out_port_i(mesh.mesh_row[row].mesh_col[col].router.ib2va_if.out_port),
							.grant_o(grant)
						);
						always @(posedge clk or posedge rst)
							if (rst)
								is_available_vc <= {5 {1'b1}};
							else
								is_available_vc <= is_available_vc_next;
						localparam noc_params_VC_SIZE = 0;
						function [noc_params_VC_SIZE - 1:0] assign_downstream_vc;
							input reg [2:0] port;
							reg [0:1] _sv2v_jump;
							begin
								_sv2v_jump = 2'b00;
								assign_downstream_vc = {noc_params_VC_SIZE {1'bx}};
								begin : sv2v_autoblock_7
									reg signed [31:0] vc;
									begin : sv2v_autoblock_8
										reg signed [31:0] _sv2v_value_on_break;
										for (vc = 0; vc < noc_params_VC_NUM; vc = vc + 1)
											if (_sv2v_jump < 2'b10) begin
												_sv2v_jump = 2'b00;
												if (is_available_vc[port + vc]) begin
													assign_downstream_vc = vc;
													_sv2v_jump = 2'b10;
												end
												_sv2v_value_on_break = vc;
											end
										if (!(_sv2v_jump < 2'b10))
											vc = _sv2v_value_on_break;
										if (_sv2v_jump != 2'b11)
											_sv2v_jump = 2'b00;
									end
								end
							end
						endfunction
						always @(mesh.mesh_row[row].mesh_col[col].router.vc_allocator.idle_downstream_vc_i or mesh.mesh_row[row].mesh_col[col].router.vc_allocator.is_available_vc or mesh.mesh_row[row].mesh_col[col].router.ib2va_if.out_port or mesh.mesh_row[row].mesh_col[col].router.ib2va_if.vc_new or mesh.mesh_row[row].mesh_col[col].router.ib2va_if.out_port or mesh.mesh_row[row].mesh_col[col].router.vc_allocator.is_available_vc or mesh.mesh_row[row].mesh_col[col].router.vc_allocator.grant or mesh.mesh_row[row].mesh_col[col].router.ib2va_if.out_port or mesh.mesh_row[row].mesh_col[col].router.vc_allocator.is_available_vc or mesh.mesh_row[row].mesh_col[col].router.ib2va_if.vc_request or mesh.mesh_row[row].mesh_col[col].router.vc_allocator.is_available_vc) begin
							is_available_vc_next = is_available_vc;
							begin : sv2v_autoblock_9
								reg signed [31:0] up_port;
								for (up_port = 0; up_port < noc_params_PORT_NUM; up_port = up_port + 1)
									begin : sv2v_autoblock_10
										reg signed [31:0] up_vc;
										for (up_vc = 0; up_vc < noc_params_VC_NUM; up_vc = up_vc + 1)
											begin
												request_cmd[up_port + up_vc] = 1'b0;
												mesh.mesh_row[row].mesh_col[col].router.ib2va_if.vc_valid[up_port][up_vc] = 1'b0;
												mesh.mesh_row[row].mesh_col[col].router.ib2va_if.vc_new[up_port][0+:0] = {noc_params_VC_SIZE {1'bx}};
											end
									end
							end
							begin : sv2v_autoblock_11
								reg signed [31:0] up_port;
								for (up_port = 0; up_port < noc_params_PORT_NUM; up_port = up_port + 1)
									begin : sv2v_autoblock_12
										reg signed [31:0] up_vc;
										for (up_vc = 0; up_vc < noc_params_VC_NUM; up_vc = up_vc + 1)
											if (mesh.mesh_row[row].mesh_col[col].router.ib2va_if.vc_request[up_port][up_vc] & is_available_vc[mesh.mesh_row[row].mesh_col[col].router.ib2va_if.out_port[(up_port + up_vc) * 3+:3]+:1])
												request_cmd[up_port + up_vc] = 1'b1;
									end
							end
							begin : sv2v_autoblock_13
								reg signed [31:0] up_port;
								for (up_port = 0; up_port < noc_params_PORT_NUM; up_port = up_port + 1)
									begin : sv2v_autoblock_14
										reg signed [31:0] up_vc;
										for (up_vc = 0; up_vc < noc_params_VC_NUM; up_vc = up_vc + 1)
											if (grant[up_port + up_vc]) begin
												mesh.mesh_row[row].mesh_col[col].router.ib2va_if.vc_new[up_port][0+:0] = assign_downstream_vc(mesh.mesh_row[row].mesh_col[col].router.ib2va_if.out_port[(up_port + up_vc) * 3+:3]);
												mesh.mesh_row[row].mesh_col[col].router.ib2va_if.vc_valid[up_port][up_vc] = 1'b1;
												is_available_vc_next[mesh.mesh_row[row].mesh_col[col].router.ib2va_if.out_port[(up_port + up_vc) * 3+:3] + mesh.mesh_row[row].mesh_col[col].router.ib2va_if.vc_new[up_port][0+:0]] = 1'b0;
											end
									end
							end
							begin : sv2v_autoblock_15
								reg signed [31:0] down_port;
								for (down_port = 0; down_port < noc_params_PORT_NUM; down_port = down_port + 1)
									begin : sv2v_autoblock_16
										reg signed [31:0] down_vc;
										for (down_vc = 0; down_vc < noc_params_VC_NUM; down_vc = down_vc + 1)
											if (~is_available_vc[down_port + down_vc] & idle_downstream_vc_i[down_port + down_vc])
												is_available_vc_next[down_port + down_vc] = 1'b1;
									end
							end
						end
					end
					assign vc_allocator.rst = rst;
					assign vc_allocator.clk = clk;
					assign vc_allocator.idle_downstream_vc_i = is_allocatable_in;
				end
				assign router.clk = clk;
				assign router.rst = rst;
				assign error_o[((col * MESH_SIZE_Y) + row) * 5+:5] = router.error_o;
			end
		end
		for (row = 0; row < (MESH_SIZE_Y - 1); row = row + 1) begin : vertical_links_row
			for (col = 0; col < MESH_SIZE_X; col = col + 1) begin : vertical_links_col
				if (1) begin : link_one
					always @(*) begin
						mesh.mesh_row[row].mesh_col[_mbase_router_if_up].south_down.data = mesh.mesh_row[row + 1].mesh_col[_mbase_router_if_down].north_up.data;
						mesh.mesh_row[row].mesh_col[_mbase_router_if_up].south_down.is_valid = mesh.mesh_row[row + 1].mesh_col[_mbase_router_if_down].north_up.is_valid;
						mesh.mesh_row[row + 1].mesh_col[_mbase_router_if_down].north_up.is_on_off = mesh.mesh_row[row].mesh_col[_mbase_router_if_up].south_down.is_on_off;
						mesh.mesh_row[row + 1].mesh_col[_mbase_router_if_down].north_up.is_allocatable = mesh.mesh_row[row].mesh_col[_mbase_router_if_up].south_down.is_allocatable;
					end
				end
				if (1) begin : link_two
					always @(*) begin
						mesh.mesh_row[row + 1].mesh_col[_mbase_router_if_up].north_down.data = mesh.mesh_row[row].mesh_col[_mbase_router_if_down].south_up.data;
						mesh.mesh_row[row + 1].mesh_col[_mbase_router_if_up].north_down.is_valid = mesh.mesh_row[row].mesh_col[_mbase_router_if_down].south_up.is_valid;
						mesh.mesh_row[row].mesh_col[_mbase_router_if_down].south_up.is_on_off = mesh.mesh_row[row + 1].mesh_col[_mbase_router_if_up].north_down.is_on_off;
						mesh.mesh_row[row].mesh_col[_mbase_router_if_down].south_up.is_allocatable = mesh.mesh_row[row + 1].mesh_col[_mbase_router_if_up].north_down.is_allocatable;
					end
				end
			end
		end
		for (row = 0; row < MESH_SIZE_Y; row = row + 1) begin : horizontal_links_row
			for (col = 0; col < (MESH_SIZE_X - 1); col = col + 1) begin : horizontal_links_col
				if (1) begin : link_one
					always @(*) begin
						mesh.mesh_row[row].mesh_col[_mbase_router_if_up].east_down.data = mesh.mesh_row[row].mesh_col[_mbase_router_if_down].west_up.data;
						mesh.mesh_row[row].mesh_col[_mbase_router_if_up].east_down.is_valid = mesh.mesh_row[row].mesh_col[_mbase_router_if_down].west_up.is_valid;
						mesh.mesh_row[row].mesh_col[_mbase_router_if_down].west_up.is_on_off = mesh.mesh_row[row].mesh_col[_mbase_router_if_up].east_down.is_on_off;
						mesh.mesh_row[row].mesh_col[_mbase_router_if_down].west_up.is_allocatable = mesh.mesh_row[row].mesh_col[_mbase_router_if_up].east_down.is_allocatable;
					end
				end
				if (1) begin : link_two
					always @(*) begin
						mesh.mesh_row[row].mesh_col[_mbase_router_if_up].west_down.data = mesh.mesh_row[row].mesh_col[_mbase_router_if_down].east_up.data;
						mesh.mesh_row[row].mesh_col[_mbase_router_if_up].west_down.is_valid = mesh.mesh_row[row].mesh_col[_mbase_router_if_down].east_up.is_valid;
						mesh.mesh_row[row].mesh_col[_mbase_router_if_down].east_up.is_on_off = mesh.mesh_row[row].mesh_col[_mbase_router_if_up].west_down.is_on_off;
						mesh.mesh_row[row].mesh_col[_mbase_router_if_down].east_up.is_allocatable = mesh.mesh_row[row].mesh_col[_mbase_router_if_up].west_down.is_allocatable;
					end
				end
			end
		end
		for (row = 0; row < MESH_SIZE_Y; row = row + 1) begin : node_connection_row
			for (col = 0; col < MESH_SIZE_X; col = col + 1) begin : node_connection_col
				if (1) begin : node_link
					localparam noc_params_MESH_SIZE_X = 65;
					localparam noc_params_DEST_ADDR_SIZE_X = 7;
					localparam noc_params_MESH_SIZE_Y = 5;
					localparam noc_params_DEST_ADDR_SIZE_Y = 3;
					localparam noc_params_HEAD_PAYLOAD_SIZE = 74;
					localparam noc_params_FLIT_DATA_SIZE = 84;
					localparam noc_params_VC_NUM = 1;
					localparam noc_params_VC_SIZE = 0;
					wire [87:0] data_i;
					wire is_valid_i;
					reg [0:0] is_on_off_o;
					reg [0:0] is_allocatable_o;
					reg [87:0] data_o;
					reg is_valid_o;
					wire [0:0] is_on_off_i;
					wire [0:0] is_allocatable_i;
					always @(*) begin
						mesh.mesh_row[row].mesh_col[_mbase_router_if_up].local_down.data = data_i;
						mesh.mesh_row[row].mesh_col[_mbase_router_if_up].local_down.is_valid = is_valid_i;
						is_on_off_o = mesh.mesh_row[row].mesh_col[_mbase_router_if_up].local_down.is_on_off;
						is_allocatable_o = mesh.mesh_row[row].mesh_col[_mbase_router_if_up].local_down.is_allocatable;
						data_o = mesh.mesh_row[row].mesh_col[_mbase_router_if_down].local_up.data;
						is_valid_o = mesh.mesh_row[row].mesh_col[_mbase_router_if_down].local_up.is_valid;
						mesh.mesh_row[row].mesh_col[_mbase_router_if_down].local_up.is_on_off = is_on_off_i;
						mesh.mesh_row[row].mesh_col[_mbase_router_if_down].local_up.is_allocatable = is_allocatable_i;
					end
				end
				assign node_link.data_i = data_i[((col * MESH_SIZE_Y) + row) * 86+:86];
				assign node_link.is_valid_i = is_valid_i[(col * MESH_SIZE_Y) + row];
				assign is_on_off_o[(col * MESH_SIZE_Y) + row+:1] = node_link.is_on_off_o;
				assign is_allocatable_o[(col * MESH_SIZE_Y) + row+:1] = node_link.is_allocatable_o;
				assign data_o[((col * MESH_SIZE_Y) + row) * 86+:86] = node_link.data_o;
				assign is_valid_o[(col * MESH_SIZE_Y) + row] = node_link.is_valid_o;
				assign node_link.is_on_off_i = is_on_off_i[(col * MESH_SIZE_Y) + row+:1];
				assign node_link.is_allocatable_i = is_allocatable_i[(col * MESH_SIZE_Y) + row+:1];
			end
		end
	endgenerate
endmodule
`default_nettype none
module aggregation_engine_regbank_regs (
	axi_aclk,
	axi_aresetn,
	s_axi_awaddr,
	s_axi_awprot,
	s_axi_awvalid,
	s_axi_awready,
	s_axi_wdata,
	s_axi_wstrb,
	s_axi_wvalid,
	s_axi_wready,
	s_axi_araddr,
	s_axi_arprot,
	s_axi_arvalid,
	s_axi_arready,
	s_axi_rdata,
	s_axi_rresp,
	s_axi_rvalid,
	s_axi_rready,
	s_axi_bresp,
	s_axi_bvalid,
	s_axi_bready,
	layer_config_in_features_strobe,
	layer_config_in_features_count,
	layer_config_out_features_strobe,
	layer_config_out_features_count,
	layer_config_upsampling_parameter_strobe,
	layer_config_upsampling_parameter_value
);
	parameter AXI_ADDR_WIDTH = 32;
	parameter [31:0] BASEADDR = 32'h00000000;
	input wire axi_aclk;
	input wire axi_aresetn;
	input wire [AXI_ADDR_WIDTH - 1:0] s_axi_awaddr;
	input wire [2:0] s_axi_awprot;
	input wire s_axi_awvalid;
	output wire s_axi_awready;
	input wire [31:0] s_axi_wdata;
	input wire [3:0] s_axi_wstrb;
	input wire s_axi_wvalid;
	output wire s_axi_wready;
	input wire [AXI_ADDR_WIDTH - 1:0] s_axi_araddr;
	input wire [2:0] s_axi_arprot;
	input wire s_axi_arvalid;
	output wire s_axi_arready;
	output wire [31:0] s_axi_rdata;
	output wire [1:0] s_axi_rresp;
	output wire s_axi_rvalid;
	input wire s_axi_rready;
	output wire [1:0] s_axi_bresp;
	output wire s_axi_bvalid;
	input wire s_axi_bready;
	output wire layer_config_in_features_strobe;
	output wire [9:0] layer_config_in_features_count;
	output wire layer_config_out_features_strobe;
	output wire [3:0] layer_config_out_features_count;
	output wire layer_config_upsampling_parameter_strobe;
	output wire [31:0] layer_config_upsampling_parameter_value;
	localparam [1:0] AXI_OKAY = 2'b00;
	localparam [1:0] AXI_SLVERR = 2'b10;
	reg s_axi_awready_r;
	reg s_axi_wready_r;
	reg [AXI_ADDR_WIDTH - 1:0] s_axi_awaddr_reg_r;
	reg s_axi_bvalid_r;
	reg [1:0] s_axi_bresp_r;
	reg s_axi_arready_r;
	reg [AXI_ADDR_WIDTH - 1:0] s_axi_araddr_reg_r;
	reg s_axi_rvalid_r;
	reg [1:0] s_axi_rresp_r;
	reg [31:0] s_axi_wdata_reg_r;
	reg [3:0] s_axi_wstrb_reg_r;
	reg [31:0] s_axi_rdata_r;
	reg s_layer_config_in_features_strobe_r;
	reg [9:0] s_reg_layer_config_in_features_count_r;
	reg s_layer_config_out_features_strobe_r;
	reg [3:0] s_reg_layer_config_out_features_count_r;
	reg s_layer_config_upsampling_parameter_strobe_r;
	reg [31:0] s_reg_layer_config_upsampling_parameter_value_r;
	localparam MAX_MEMORY_LATENCY = 5;
	localparam [31:0] aggregation_engine_regbank_regs_pkg_LAYER_CONFIG_IN_FEATURES_OFFSET = 32'h00000000;
	localparam [31:0] aggregation_engine_regbank_regs_pkg_LAYER_CONFIG_OUT_FEATURES_OFFSET = 32'h00000004;
	localparam [31:0] aggregation_engine_regbank_regs_pkg_LAYER_CONFIG_UPSAMPLING_PARAMETER_OFFSET = 32'h00000008;
	always @(posedge axi_aclk or negedge axi_aresetn) begin : read_fsm
		reg [31:0] v_state_r;
		reg [31:0] v_rdata_r;
		reg [1:0] v_rresp_r;
		reg [2:0] v_mem_wait_count_r;
		reg v_addr_hit;
		reg [AXI_ADDR_WIDTH - 1:0] v_mem_addr;
		if (~axi_aresetn) begin
			v_state_r <= 32'd0;
			v_rdata_r <= 1'sb0;
			v_rresp_r <= 1'sb0;
			v_mem_wait_count_r <= 1'sb0;
			s_axi_arready_r <= 1'sb0;
			s_axi_rvalid_r <= 1'sb0;
			s_axi_rresp_r <= 1'sb0;
			s_axi_araddr_reg_r <= 1'sb0;
			s_axi_rdata_r <= 1'sb0;
		end
		else begin
			s_axi_arready_r <= 1'b0;
			case (v_state_r)
				32'd0:
					if (s_axi_arvalid) begin
						s_axi_araddr_reg_r <= s_axi_araddr;
						s_axi_arready_r <= 1'b1;
						v_state_r <= 32'd1;
					end
				32'd1: begin
					v_addr_hit = 1'b0;
					v_rdata_r <= 1'sb0;
					if (s_axi_araddr_reg_r[AXI_ADDR_WIDTH - 1:2] == (BASEADDR[AXI_ADDR_WIDTH - 1:2] + aggregation_engine_regbank_regs_pkg_LAYER_CONFIG_IN_FEATURES_OFFSET[AXI_ADDR_WIDTH - 1:2])) begin
						v_addr_hit = 1'b1;
						v_rdata_r[9:0] <= s_reg_layer_config_in_features_count_r;
						v_state_r <= 32'd3;
					end
					if (s_axi_araddr_reg_r[AXI_ADDR_WIDTH - 1:2] == (BASEADDR[AXI_ADDR_WIDTH - 1:2] + aggregation_engine_regbank_regs_pkg_LAYER_CONFIG_OUT_FEATURES_OFFSET[AXI_ADDR_WIDTH - 1:2])) begin
						v_addr_hit = 1'b1;
						v_rdata_r[3:0] <= s_reg_layer_config_out_features_count_r;
						v_state_r <= 32'd3;
					end
					if (s_axi_araddr_reg_r[AXI_ADDR_WIDTH - 1:2] == (BASEADDR[AXI_ADDR_WIDTH - 1:2] + aggregation_engine_regbank_regs_pkg_LAYER_CONFIG_UPSAMPLING_PARAMETER_OFFSET[AXI_ADDR_WIDTH - 1:2])) begin
						v_addr_hit = 1'b1;
						v_rdata_r[31:0] <= s_reg_layer_config_upsampling_parameter_value_r;
						v_state_r <= 32'd3;
					end
					if (v_addr_hit)
						v_rresp_r <= AXI_OKAY;
					else begin
						v_rresp_r <= AXI_SLVERR;
						$warning("ARADDR decode error");
						v_state_r <= 32'd3;
					end
				end
				32'd2:
					if (v_mem_wait_count_r == 0)
						v_state_r <= 32'd3;
					else
						v_mem_wait_count_r <= v_mem_wait_count_r - 1;
				32'd3: begin
					s_axi_rvalid_r <= 1'b1;
					s_axi_rresp_r <= v_rresp_r;
					s_axi_rdata_r <= v_rdata_r;
					v_state_r <= 32'd4;
				end
				32'd4:
					if (s_axi_rready) begin
						s_axi_rvalid_r <= 1'b0;
						s_axi_rdata_r <= 1'sb0;
						v_state_r <= 32'd0;
					end
			endcase
		end
	end
	localparam [9:0] aggregation_engine_regbank_regs_pkg_LAYER_CONFIG_IN_FEATURES_COUNT_RESET = 10'b0000000000;
	localparam [3:0] aggregation_engine_regbank_regs_pkg_LAYER_CONFIG_OUT_FEATURES_COUNT_RESET = 4'b0000;
	localparam [31:0] aggregation_engine_regbank_regs_pkg_LAYER_CONFIG_UPSAMPLING_PARAMETER_VALUE_RESET = 32'b00000000000000000000000000000000;
	always @(posedge axi_aclk or negedge axi_aresetn) begin : write_fsm
		reg [31:0] v_state_r;
		reg v_addr_hit;
		reg [AXI_ADDR_WIDTH - 1:0] v_mem_addr;
		if (~axi_aresetn) begin
			v_state_r <= 32'd0;
			s_axi_awready_r <= 1'b0;
			s_axi_wready_r <= 1'b0;
			s_axi_awaddr_reg_r <= 1'sb0;
			s_axi_wdata_reg_r <= 1'sb0;
			s_axi_wstrb_reg_r <= 1'sb0;
			s_axi_bvalid_r <= 1'b0;
			s_axi_bresp_r <= 1'sb0;
			s_layer_config_in_features_strobe_r <= 1'sb0;
			s_reg_layer_config_in_features_count_r <= aggregation_engine_regbank_regs_pkg_LAYER_CONFIG_IN_FEATURES_COUNT_RESET;
			s_layer_config_out_features_strobe_r <= 1'sb0;
			s_reg_layer_config_out_features_count_r <= aggregation_engine_regbank_regs_pkg_LAYER_CONFIG_OUT_FEATURES_COUNT_RESET;
			s_layer_config_upsampling_parameter_strobe_r <= 1'sb0;
			s_reg_layer_config_upsampling_parameter_value_r <= aggregation_engine_regbank_regs_pkg_LAYER_CONFIG_UPSAMPLING_PARAMETER_VALUE_RESET;
		end
		else begin
			s_axi_awready_r <= 1'b0;
			s_axi_wready_r <= 1'b0;
			s_layer_config_in_features_strobe_r <= 1'sb0;
			s_layer_config_out_features_strobe_r <= 1'sb0;
			s_layer_config_upsampling_parameter_strobe_r <= 1'sb0;
			v_addr_hit = 1'b0;
			case (v_state_r)
				32'd0:
					if (s_axi_awvalid && s_axi_wvalid) begin
						s_axi_awaddr_reg_r <= s_axi_awaddr;
						s_axi_awready_r <= 1'b1;
						s_axi_wdata_reg_r <= s_axi_wdata;
						s_axi_wstrb_reg_r <= s_axi_wstrb;
						s_axi_wready_r <= 1'b1;
						v_state_r <= 32'd3;
					end
					else if (s_axi_awvalid) begin
						s_axi_awaddr_reg_r <= s_axi_awaddr;
						s_axi_awready_r <= 1'b1;
						v_state_r <= 32'd1;
					end
					else if (s_axi_wvalid) begin
						s_axi_wdata_reg_r <= s_axi_wdata;
						s_axi_wstrb_reg_r <= s_axi_wstrb;
						s_axi_wready_r <= 1'b1;
						v_state_r <= 32'd2;
					end
				32'd1:
					if (s_axi_wvalid) begin
						s_axi_wdata_reg_r <= s_axi_wdata;
						s_axi_wstrb_reg_r <= s_axi_wstrb;
						s_axi_wready_r <= 1'b1;
						v_state_r <= 32'd3;
					end
				32'd2:
					if (s_axi_awvalid) begin
						s_axi_awaddr_reg_r <= s_axi_awaddr;
						s_axi_awready_r <= 1'b1;
						v_state_r <= 32'd3;
					end
				32'd3: begin
					s_axi_bresp_r <= AXI_OKAY;
					s_axi_bvalid_r <= 1'b1;
					if (s_axi_awaddr_reg_r[AXI_ADDR_WIDTH - 1:2] == (BASEADDR[AXI_ADDR_WIDTH - 1:2] + aggregation_engine_regbank_regs_pkg_LAYER_CONFIG_IN_FEATURES_OFFSET[AXI_ADDR_WIDTH - 1:2])) begin
						v_addr_hit = 1'b1;
						s_layer_config_in_features_strobe_r <= 1'b1;
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_in_features_count_r[0] <= s_axi_wdata_reg_r[0];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_in_features_count_r[1] <= s_axi_wdata_reg_r[1];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_in_features_count_r[2] <= s_axi_wdata_reg_r[2];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_in_features_count_r[3] <= s_axi_wdata_reg_r[3];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_in_features_count_r[4] <= s_axi_wdata_reg_r[4];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_in_features_count_r[5] <= s_axi_wdata_reg_r[5];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_in_features_count_r[6] <= s_axi_wdata_reg_r[6];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_in_features_count_r[7] <= s_axi_wdata_reg_r[7];
						if (s_axi_wstrb_reg_r[1])
							s_reg_layer_config_in_features_count_r[8] <= s_axi_wdata_reg_r[8];
						if (s_axi_wstrb_reg_r[1])
							s_reg_layer_config_in_features_count_r[9] <= s_axi_wdata_reg_r[9];
					end
					if (s_axi_awaddr_reg_r[AXI_ADDR_WIDTH - 1:2] == (BASEADDR[AXI_ADDR_WIDTH - 1:2] + aggregation_engine_regbank_regs_pkg_LAYER_CONFIG_OUT_FEATURES_OFFSET[AXI_ADDR_WIDTH - 1:2])) begin
						v_addr_hit = 1'b1;
						s_layer_config_out_features_strobe_r <= 1'b1;
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_out_features_count_r[0] <= s_axi_wdata_reg_r[0];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_out_features_count_r[1] <= s_axi_wdata_reg_r[1];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_out_features_count_r[2] <= s_axi_wdata_reg_r[2];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_out_features_count_r[3] <= s_axi_wdata_reg_r[3];
					end
					if (s_axi_awaddr_reg_r[AXI_ADDR_WIDTH - 1:2] == (BASEADDR[AXI_ADDR_WIDTH - 1:2] + aggregation_engine_regbank_regs_pkg_LAYER_CONFIG_UPSAMPLING_PARAMETER_OFFSET[AXI_ADDR_WIDTH - 1:2])) begin
						v_addr_hit = 1'b1;
						s_layer_config_upsampling_parameter_strobe_r <= 1'b1;
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_upsampling_parameter_value_r[0] <= s_axi_wdata_reg_r[0];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_upsampling_parameter_value_r[1] <= s_axi_wdata_reg_r[1];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_upsampling_parameter_value_r[2] <= s_axi_wdata_reg_r[2];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_upsampling_parameter_value_r[3] <= s_axi_wdata_reg_r[3];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_upsampling_parameter_value_r[4] <= s_axi_wdata_reg_r[4];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_upsampling_parameter_value_r[5] <= s_axi_wdata_reg_r[5];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_upsampling_parameter_value_r[6] <= s_axi_wdata_reg_r[6];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_upsampling_parameter_value_r[7] <= s_axi_wdata_reg_r[7];
						if (s_axi_wstrb_reg_r[1])
							s_reg_layer_config_upsampling_parameter_value_r[8] <= s_axi_wdata_reg_r[8];
						if (s_axi_wstrb_reg_r[1])
							s_reg_layer_config_upsampling_parameter_value_r[9] <= s_axi_wdata_reg_r[9];
						if (s_axi_wstrb_reg_r[1])
							s_reg_layer_config_upsampling_parameter_value_r[10] <= s_axi_wdata_reg_r[10];
						if (s_axi_wstrb_reg_r[1])
							s_reg_layer_config_upsampling_parameter_value_r[11] <= s_axi_wdata_reg_r[11];
						if (s_axi_wstrb_reg_r[1])
							s_reg_layer_config_upsampling_parameter_value_r[12] <= s_axi_wdata_reg_r[12];
						if (s_axi_wstrb_reg_r[1])
							s_reg_layer_config_upsampling_parameter_value_r[13] <= s_axi_wdata_reg_r[13];
						if (s_axi_wstrb_reg_r[1])
							s_reg_layer_config_upsampling_parameter_value_r[14] <= s_axi_wdata_reg_r[14];
						if (s_axi_wstrb_reg_r[1])
							s_reg_layer_config_upsampling_parameter_value_r[15] <= s_axi_wdata_reg_r[15];
						if (s_axi_wstrb_reg_r[2])
							s_reg_layer_config_upsampling_parameter_value_r[16] <= s_axi_wdata_reg_r[16];
						if (s_axi_wstrb_reg_r[2])
							s_reg_layer_config_upsampling_parameter_value_r[17] <= s_axi_wdata_reg_r[17];
						if (s_axi_wstrb_reg_r[2])
							s_reg_layer_config_upsampling_parameter_value_r[18] <= s_axi_wdata_reg_r[18];
						if (s_axi_wstrb_reg_r[2])
							s_reg_layer_config_upsampling_parameter_value_r[19] <= s_axi_wdata_reg_r[19];
						if (s_axi_wstrb_reg_r[2])
							s_reg_layer_config_upsampling_parameter_value_r[20] <= s_axi_wdata_reg_r[20];
						if (s_axi_wstrb_reg_r[2])
							s_reg_layer_config_upsampling_parameter_value_r[21] <= s_axi_wdata_reg_r[21];
						if (s_axi_wstrb_reg_r[2])
							s_reg_layer_config_upsampling_parameter_value_r[22] <= s_axi_wdata_reg_r[22];
						if (s_axi_wstrb_reg_r[2])
							s_reg_layer_config_upsampling_parameter_value_r[23] <= s_axi_wdata_reg_r[23];
						if (s_axi_wstrb_reg_r[3])
							s_reg_layer_config_upsampling_parameter_value_r[24] <= s_axi_wdata_reg_r[24];
						if (s_axi_wstrb_reg_r[3])
							s_reg_layer_config_upsampling_parameter_value_r[25] <= s_axi_wdata_reg_r[25];
						if (s_axi_wstrb_reg_r[3])
							s_reg_layer_config_upsampling_parameter_value_r[26] <= s_axi_wdata_reg_r[26];
						if (s_axi_wstrb_reg_r[3])
							s_reg_layer_config_upsampling_parameter_value_r[27] <= s_axi_wdata_reg_r[27];
						if (s_axi_wstrb_reg_r[3])
							s_reg_layer_config_upsampling_parameter_value_r[28] <= s_axi_wdata_reg_r[28];
						if (s_axi_wstrb_reg_r[3])
							s_reg_layer_config_upsampling_parameter_value_r[29] <= s_axi_wdata_reg_r[29];
						if (s_axi_wstrb_reg_r[3])
							s_reg_layer_config_upsampling_parameter_value_r[30] <= s_axi_wdata_reg_r[30];
						if (s_axi_wstrb_reg_r[3])
							s_reg_layer_config_upsampling_parameter_value_r[31] <= s_axi_wdata_reg_r[31];
					end
					if (!v_addr_hit) begin
						s_axi_bresp_r <= AXI_SLVERR;
						$warning("AWADDR decode error");
					end
					v_state_r <= 32'd4;
				end
				32'd4:
					if (s_axi_bready) begin
						s_axi_bvalid_r <= 1'b0;
						v_state_r <= 32'd0;
					end
			endcase
		end
	end
	assign s_axi_awready = s_axi_awready_r;
	assign s_axi_wready = s_axi_wready_r;
	assign s_axi_bvalid = s_axi_bvalid_r;
	assign s_axi_bresp = s_axi_bresp_r;
	assign s_axi_arready = s_axi_arready_r;
	assign s_axi_rvalid = s_axi_rvalid_r;
	assign s_axi_rresp = s_axi_rresp_r;
	assign s_axi_rdata = s_axi_rdata_r;
	assign layer_config_in_features_strobe = s_layer_config_in_features_strobe_r;
	assign layer_config_in_features_count = s_reg_layer_config_in_features_count_r;
	assign layer_config_out_features_strobe = s_layer_config_out_features_strobe_r;
	assign layer_config_out_features_count = s_reg_layer_config_out_features_count_r;
	assign layer_config_upsampling_parameter_strobe = s_layer_config_upsampling_parameter_strobe_r;
	assign layer_config_upsampling_parameter_value = s_reg_layer_config_upsampling_parameter_value_r;
endmodule
`resetall
`default_nettype none
module node_scoreboard_regbank_regs (
	axi_aclk,
	axi_aresetn,
	s_axi_awaddr,
	s_axi_awprot,
	s_axi_awvalid,
	s_axi_awready,
	s_axi_wdata,
	s_axi_wstrb,
	s_axi_wvalid,
	s_axi_wready,
	s_axi_araddr,
	s_axi_arprot,
	s_axi_arvalid,
	s_axi_arready,
	s_axi_rdata,
	s_axi_rresp,
	s_axi_rvalid,
	s_axi_rready,
	s_axi_bresp,
	s_axi_bvalid,
	s_axi_bready,
	layer_config_weights_address_lsb_strobe,
	layer_config_weights_address_lsb_lsb,
	layer_config_weights_address_msb_strobe,
	layer_config_weights_address_msb_msb,
	ctrl_fetch_layer_weights_strobe,
	ctrl_fetch_layer_weights_fetch,
	ctrl_fetch_layer_weights_done_strobe,
	ctrl_fetch_layer_weights_done_done,
	ctrl_fetch_layer_weights_done_ack_strobe,
	ctrl_fetch_layer_weights_done_ack_ack,
	layer_config_in_messages_address_lsb_strobe,
	layer_config_in_messages_address_lsb_lsb,
	layer_config_in_messages_address_msb_strobe,
	layer_config_in_messages_address_msb_msb,
	layer_config_out_messages_address_lsb_strobe,
	layer_config_out_messages_address_lsb_lsb,
	layer_config_out_messages_address_msb_strobe,
	layer_config_out_messages_address_msb_msb,
	nsb_nodeslot_neighbour_count_strobe,
	nsb_nodeslot_neighbour_count_count,
	nsb_nodeslot_node_id_strobe,
	nsb_nodeslot_node_id_id,
	nsb_nodeslot_node_state_strobe,
	nsb_nodeslot_node_state_state,
	nsb_nodeslot_precision_strobe,
	nsb_nodeslot_precision_precision,
	nsb_nodeslot_adjacency_list_address_lsb_strobe,
	nsb_nodeslot_adjacency_list_address_lsb_lsb,
	nsb_nodeslot_adjacency_list_address_msb_strobe,
	nsb_nodeslot_adjacency_list_address_msb_msb,
	nsb_nodeslot_out_messages_address_lsb_strobe,
	nsb_nodeslot_out_messages_address_lsb_lsb,
	nsb_nodeslot_out_messages_address_msb_strobe,
	nsb_nodeslot_out_messages_address_msb_msb,
	nsb_nodeslot_config_make_valid_msb_strobe,
	nsb_nodeslot_config_make_valid_msb_make_valid,
	nsb_nodeslot_config_make_valid_lsb_strobe,
	nsb_nodeslot_config_make_valid_lsb_make_valid,
	nsb_config_aggregation_wait_count_strobe,
	nsb_config_aggregation_wait_count_count,
	nsb_config_transformation_wait_count_strobe,
	nsb_config_transformation_wait_count_count,
	nsb_nodeslot_allocated_fetch_tag_strobe,
	nsb_nodeslot_allocated_fetch_tag_fetch_tag,
	layer_config_in_features_strobe,
	layer_config_in_features_count,
	layer_config_out_features_strobe,
	layer_config_out_features_count,
	layer_config_weights_precision_strobe,
	layer_config_weights_precision_precision,
	layer_config_activations_precision_strobe,
	layer_config_activations_precision_precision,
	layer_config_adjacency_list_address_lsb_strobe,
	layer_config_adjacency_list_address_lsb_lsb,
	layer_config_adjacency_list_address_msb_strobe,
	layer_config_adjacency_list_address_msb_msb,
	nsb_nodeslot_aggregation_function_strobe,
	nsb_nodeslot_aggregation_function_value,
	nsb_nodeslot_scale_factors_address_lsb_strobe,
	nsb_nodeslot_scale_factors_address_lsb_value,
	nsb_nodeslot_scale_factors_address_msb_strobe,
	nsb_nodeslot_scale_factors_address_msb_value
);
	parameter AXI_ADDR_WIDTH = 32;
	parameter [31:0] BASEADDR = 32'h80000000;
	input wire axi_aclk;
	input wire axi_aresetn;
	input wire [AXI_ADDR_WIDTH - 1:0] s_axi_awaddr;
	input wire [2:0] s_axi_awprot;
	input wire s_axi_awvalid;
	output wire s_axi_awready;
	input wire [31:0] s_axi_wdata;
	input wire [3:0] s_axi_wstrb;
	input wire s_axi_wvalid;
	output wire s_axi_wready;
	input wire [AXI_ADDR_WIDTH - 1:0] s_axi_araddr;
	input wire [2:0] s_axi_arprot;
	input wire s_axi_arvalid;
	output wire s_axi_arready;
	output wire [31:0] s_axi_rdata;
	output wire [1:0] s_axi_rresp;
	output wire s_axi_rvalid;
	input wire s_axi_rready;
	output wire [1:0] s_axi_bresp;
	output wire s_axi_bvalid;
	input wire s_axi_bready;
	output wire layer_config_weights_address_lsb_strobe;
	output wire [31:0] layer_config_weights_address_lsb_lsb;
	output wire layer_config_weights_address_msb_strobe;
	output wire [1:0] layer_config_weights_address_msb_msb;
	output wire ctrl_fetch_layer_weights_strobe;
	output wire [0:0] ctrl_fetch_layer_weights_fetch;
	output wire ctrl_fetch_layer_weights_done_strobe;
	input wire [0:0] ctrl_fetch_layer_weights_done_done;
	output wire ctrl_fetch_layer_weights_done_ack_strobe;
	output wire [0:0] ctrl_fetch_layer_weights_done_ack_ack;
	output wire layer_config_in_messages_address_lsb_strobe;
	output wire [31:0] layer_config_in_messages_address_lsb_lsb;
	output wire layer_config_in_messages_address_msb_strobe;
	output wire [1:0] layer_config_in_messages_address_msb_msb;
	output wire layer_config_out_messages_address_lsb_strobe;
	output wire [31:0] layer_config_out_messages_address_lsb_lsb;
	output wire layer_config_out_messages_address_msb_strobe;
	output wire [1:0] layer_config_out_messages_address_msb_msb;
	output wire [31:0] nsb_nodeslot_neighbour_count_strobe;
	output wire [639:0] nsb_nodeslot_neighbour_count_count;
	output wire [31:0] nsb_nodeslot_node_id_strobe;
	output wire [639:0] nsb_nodeslot_node_id_id;
	output wire [31:0] nsb_nodeslot_node_state_strobe;
	input wire [127:0] nsb_nodeslot_node_state_state;
	output wire [31:0] nsb_nodeslot_precision_strobe;
	output wire [63:0] nsb_nodeslot_precision_precision;
	output wire [31:0] nsb_nodeslot_adjacency_list_address_lsb_strobe;
	output wire [1023:0] nsb_nodeslot_adjacency_list_address_lsb_lsb;
	output wire [31:0] nsb_nodeslot_adjacency_list_address_msb_strobe;
	output wire [63:0] nsb_nodeslot_adjacency_list_address_msb_msb;
	output wire [31:0] nsb_nodeslot_out_messages_address_lsb_strobe;
	output wire [1023:0] nsb_nodeslot_out_messages_address_lsb_lsb;
	output wire [31:0] nsb_nodeslot_out_messages_address_msb_strobe;
	output wire [63:0] nsb_nodeslot_out_messages_address_msb_msb;
	output wire nsb_nodeslot_config_make_valid_msb_strobe;
	output wire [31:0] nsb_nodeslot_config_make_valid_msb_make_valid;
	output wire nsb_nodeslot_config_make_valid_lsb_strobe;
	output wire [31:0] nsb_nodeslot_config_make_valid_lsb_make_valid;
	output wire nsb_config_aggregation_wait_count_strobe;
	output wire [5:0] nsb_config_aggregation_wait_count_count;
	output wire nsb_config_transformation_wait_count_strobe;
	output wire [5:0] nsb_config_transformation_wait_count_count;
	output wire [31:0] nsb_nodeslot_allocated_fetch_tag_strobe;
	input wire [191:0] nsb_nodeslot_allocated_fetch_tag_fetch_tag;
	output wire layer_config_in_features_strobe;
	output wire [9:0] layer_config_in_features_count;
	output wire layer_config_out_features_strobe;
	output wire [9:0] layer_config_out_features_count;
	output wire layer_config_weights_precision_strobe;
	output wire [2:0] layer_config_weights_precision_precision;
	output wire layer_config_activations_precision_strobe;
	output wire [2:0] layer_config_activations_precision_precision;
	output wire layer_config_adjacency_list_address_lsb_strobe;
	output wire [31:0] layer_config_adjacency_list_address_lsb_lsb;
	output wire layer_config_adjacency_list_address_msb_strobe;
	output wire [1:0] layer_config_adjacency_list_address_msb_msb;
	output wire [31:0] nsb_nodeslot_aggregation_function_strobe;
	output wire [63:0] nsb_nodeslot_aggregation_function_value;
	output wire [31:0] nsb_nodeslot_scale_factors_address_lsb_strobe;
	output wire [1023:0] nsb_nodeslot_scale_factors_address_lsb_value;
	output wire [31:0] nsb_nodeslot_scale_factors_address_msb_strobe;
	output wire [63:0] nsb_nodeslot_scale_factors_address_msb_value;
	localparam [1:0] AXI_OKAY = 2'b00;
	localparam [1:0] AXI_SLVERR = 2'b10;
	reg s_axi_awready_r;
	reg s_axi_wready_r;
	reg [AXI_ADDR_WIDTH - 1:0] s_axi_awaddr_reg_r;
	reg s_axi_bvalid_r;
	reg [1:0] s_axi_bresp_r;
	reg s_axi_arready_r;
	reg [AXI_ADDR_WIDTH - 1:0] s_axi_araddr_reg_r;
	reg s_axi_rvalid_r;
	reg [1:0] s_axi_rresp_r;
	reg [31:0] s_axi_wdata_reg_r;
	reg [3:0] s_axi_wstrb_reg_r;
	reg [31:0] s_axi_rdata_r;
	reg s_layer_config_weights_address_lsb_strobe_r;
	reg [31:0] s_reg_layer_config_weights_address_lsb_lsb_r;
	reg s_layer_config_weights_address_msb_strobe_r;
	reg [1:0] s_reg_layer_config_weights_address_msb_msb_r;
	reg s_ctrl_fetch_layer_weights_strobe_r;
	reg [0:0] s_reg_ctrl_fetch_layer_weights_fetch_r;
	reg s_ctrl_fetch_layer_weights_done_strobe_r;
	wire [0:0] s_reg_ctrl_fetch_layer_weights_done_done;
	reg s_ctrl_fetch_layer_weights_done_ack_strobe_r;
	reg [0:0] s_reg_ctrl_fetch_layer_weights_done_ack_ack_r;
	reg s_layer_config_in_messages_address_lsb_strobe_r;
	reg [31:0] s_reg_layer_config_in_messages_address_lsb_lsb_r;
	reg s_layer_config_in_messages_address_msb_strobe_r;
	reg [1:0] s_reg_layer_config_in_messages_address_msb_msb_r;
	reg s_layer_config_out_messages_address_lsb_strobe_r;
	reg [31:0] s_reg_layer_config_out_messages_address_lsb_lsb_r;
	reg s_layer_config_out_messages_address_msb_strobe_r;
	reg [1:0] s_reg_layer_config_out_messages_address_msb_msb_r;
	reg [31:0] s_nsb_nodeslot_neighbour_count_strobe_r;
	reg [639:0] s_reg_nsb_nodeslot_neighbour_count_count_r;
	reg [31:0] s_nsb_nodeslot_node_id_strobe_r;
	reg [639:0] s_reg_nsb_nodeslot_node_id_id_r;
	reg [31:0] s_nsb_nodeslot_node_state_strobe_r;
	wire [127:0] s_reg_nsb_nodeslot_node_state_state;
	reg [31:0] s_nsb_nodeslot_precision_strobe_r;
	reg [63:0] s_reg_nsb_nodeslot_precision_precision_r;
	reg [31:0] s_nsb_nodeslot_adjacency_list_address_lsb_strobe_r;
	reg [1023:0] s_reg_nsb_nodeslot_adjacency_list_address_lsb_lsb_r;
	reg [31:0] s_nsb_nodeslot_adjacency_list_address_msb_strobe_r;
	reg [63:0] s_reg_nsb_nodeslot_adjacency_list_address_msb_msb_r;
	reg [31:0] s_nsb_nodeslot_out_messages_address_lsb_strobe_r;
	reg [1023:0] s_reg_nsb_nodeslot_out_messages_address_lsb_lsb_r;
	reg [31:0] s_nsb_nodeslot_out_messages_address_msb_strobe_r;
	reg [63:0] s_reg_nsb_nodeslot_out_messages_address_msb_msb_r;
	reg s_nsb_nodeslot_config_make_valid_msb_strobe_r;
	reg [31:0] s_reg_nsb_nodeslot_config_make_valid_msb_make_valid_r;
	reg s_nsb_nodeslot_config_make_valid_lsb_strobe_r;
	reg [31:0] s_reg_nsb_nodeslot_config_make_valid_lsb_make_valid_r;
	reg s_nsb_config_aggregation_wait_count_strobe_r;
	reg [5:0] s_reg_nsb_config_aggregation_wait_count_count_r;
	reg s_nsb_config_transformation_wait_count_strobe_r;
	reg [5:0] s_reg_nsb_config_transformation_wait_count_count_r;
	reg [31:0] s_nsb_nodeslot_allocated_fetch_tag_strobe_r;
	wire [191:0] s_reg_nsb_nodeslot_allocated_fetch_tag_fetch_tag;
	reg s_layer_config_in_features_strobe_r;
	reg [9:0] s_reg_layer_config_in_features_count_r;
	reg s_layer_config_out_features_strobe_r;
	reg [9:0] s_reg_layer_config_out_features_count_r;
	reg s_layer_config_weights_precision_strobe_r;
	reg [2:0] s_reg_layer_config_weights_precision_precision_r;
	reg s_layer_config_activations_precision_strobe_r;
	reg [2:0] s_reg_layer_config_activations_precision_precision_r;
	reg s_layer_config_adjacency_list_address_lsb_strobe_r;
	reg [31:0] s_reg_layer_config_adjacency_list_address_lsb_lsb_r;
	reg s_layer_config_adjacency_list_address_msb_strobe_r;
	reg [1:0] s_reg_layer_config_adjacency_list_address_msb_msb_r;
	reg [31:0] s_nsb_nodeslot_aggregation_function_strobe_r;
	reg [63:0] s_reg_nsb_nodeslot_aggregation_function_value_r;
	reg [31:0] s_nsb_nodeslot_scale_factors_address_lsb_strobe_r;
	reg [1023:0] s_reg_nsb_nodeslot_scale_factors_address_lsb_value_r;
	reg [31:0] s_nsb_nodeslot_scale_factors_address_msb_strobe_r;
	reg [63:0] s_reg_nsb_nodeslot_scale_factors_address_msb_value_r;
	assign s_reg_ctrl_fetch_layer_weights_done_done = ctrl_fetch_layer_weights_done_done;
	assign s_reg_nsb_nodeslot_node_state_state = nsb_nodeslot_node_state_state;
	assign s_reg_nsb_nodeslot_allocated_fetch_tag_fetch_tag = nsb_nodeslot_allocated_fetch_tag_fetch_tag;
	localparam MAX_MEMORY_LATENCY = 5;
	localparam [31:0] node_scoreboard_regbank_regs_pkg_CTRL_FETCH_LAYER_WEIGHTS_DONE_OFFSET = 32'h0000000c;
	localparam [31:0] node_scoreboard_regbank_regs_pkg_LAYER_CONFIG_ACTIVATIONS_PRECISION_OFFSET = 32'h00000940;
	localparam [31:0] node_scoreboard_regbank_regs_pkg_LAYER_CONFIG_ADJACENCY_LIST_ADDRESS_LSB_OFFSET = 32'h00000944;
	localparam [31:0] node_scoreboard_regbank_regs_pkg_LAYER_CONFIG_ADJACENCY_LIST_ADDRESS_MSB_OFFSET = 32'h00000948;
	localparam [31:0] node_scoreboard_regbank_regs_pkg_LAYER_CONFIG_IN_FEATURES_OFFSET = 32'h00000934;
	localparam [31:0] node_scoreboard_regbank_regs_pkg_LAYER_CONFIG_IN_MESSAGES_ADDRESS_LSB_OFFSET = 32'h00000014;
	localparam [31:0] node_scoreboard_regbank_regs_pkg_LAYER_CONFIG_IN_MESSAGES_ADDRESS_MSB_OFFSET = 32'h00000018;
	localparam [31:0] node_scoreboard_regbank_regs_pkg_LAYER_CONFIG_OUT_FEATURES_OFFSET = 32'h00000938;
	localparam [31:0] node_scoreboard_regbank_regs_pkg_LAYER_CONFIG_OUT_MESSAGES_ADDRESS_LSB_OFFSET = 32'h0000001c;
	localparam [31:0] node_scoreboard_regbank_regs_pkg_LAYER_CONFIG_OUT_MESSAGES_ADDRESS_MSB_OFFSET = 32'h00000020;
	localparam [31:0] node_scoreboard_regbank_regs_pkg_LAYER_CONFIG_WEIGHTS_ADDRESS_LSB_OFFSET = 32'h00000000;
	localparam [31:0] node_scoreboard_regbank_regs_pkg_LAYER_CONFIG_WEIGHTS_ADDRESS_MSB_OFFSET = 32'h00000004;
	localparam [31:0] node_scoreboard_regbank_regs_pkg_LAYER_CONFIG_WEIGHTS_PRECISION_OFFSET = 32'h0000093c;
	localparam [31:0] node_scoreboard_regbank_regs_pkg_NSB_NODESLOT_ADJACENCY_LIST_ADDRESS_LSB_OFFSET = 32'h00000424;
	localparam [31:0] node_scoreboard_regbank_regs_pkg_NSB_NODESLOT_ADJACENCY_LIST_ADDRESS_MSB_OFFSET = 32'h00000524;
	localparam [31:0] node_scoreboard_regbank_regs_pkg_NSB_NODESLOT_AGGREGATION_FUNCTION_OFFSET = 32'h0000094c;
	localparam [31:0] node_scoreboard_regbank_regs_pkg_NSB_NODESLOT_ALLOCATED_FETCH_TAG_OFFSET = 32'h00000834;
	localparam [31:0] node_scoreboard_regbank_regs_pkg_NSB_NODESLOT_CONFIG_MAKE_VALID_LSB_OFFSET = 32'h00000828;
	localparam [31:0] node_scoreboard_regbank_regs_pkg_NSB_NODESLOT_NEIGHBOUR_COUNT_OFFSET = 32'h00000024;
	localparam [31:0] node_scoreboard_regbank_regs_pkg_NSB_NODESLOT_NODE_ID_OFFSET = 32'h00000124;
	localparam [31:0] node_scoreboard_regbank_regs_pkg_NSB_NODESLOT_NODE_STATE_OFFSET = 32'h00000224;
	localparam [31:0] node_scoreboard_regbank_regs_pkg_NSB_NODESLOT_OUT_MESSAGES_ADDRESS_LSB_OFFSET = 32'h00000624;
	localparam [31:0] node_scoreboard_regbank_regs_pkg_NSB_NODESLOT_OUT_MESSAGES_ADDRESS_MSB_OFFSET = 32'h00000724;
	localparam [31:0] node_scoreboard_regbank_regs_pkg_NSB_NODESLOT_PRECISION_OFFSET = 32'h00000324;
	localparam [31:0] node_scoreboard_regbank_regs_pkg_NSB_NODESLOT_SCALE_FACTORS_ADDRESS_LSB_OFFSET = 32'h00000a4c;
	localparam [31:0] node_scoreboard_regbank_regs_pkg_NSB_NODESLOT_SCALE_FACTORS_ADDRESS_MSB_OFFSET = 32'h00000b4c;
	function automatic signed [((AXI_ADDR_WIDTH - 3) >= 0 ? AXI_ADDR_WIDTH - 2 : 4 - AXI_ADDR_WIDTH) - 1:0] sv2v_cast_5219A_signed;
		input reg signed [((AXI_ADDR_WIDTH - 3) >= 0 ? AXI_ADDR_WIDTH - 2 : 4 - AXI_ADDR_WIDTH) - 1:0] inp;
		sv2v_cast_5219A_signed = inp;
	endfunction
	always @(posedge axi_aclk or negedge axi_aresetn) begin : read_fsm
		reg [31:0] v_state_r;
		reg [31:0] v_rdata_r;
		reg [1:0] v_rresp_r;
		reg [2:0] v_mem_wait_count_r;
		reg v_addr_hit;
		reg [AXI_ADDR_WIDTH - 1:0] v_mem_addr;
		if (~axi_aresetn) begin
			v_state_r <= 32'd0;
			v_rdata_r <= 1'sb0;
			v_rresp_r <= 1'sb0;
			v_mem_wait_count_r <= 1'sb0;
			s_axi_arready_r <= 1'sb0;
			s_axi_rvalid_r <= 1'sb0;
			s_axi_rresp_r <= 1'sb0;
			s_axi_araddr_reg_r <= 1'sb0;
			s_axi_rdata_r <= 1'sb0;
			s_ctrl_fetch_layer_weights_done_strobe_r <= 1'sb0;
			s_nsb_nodeslot_node_state_strobe_r <= 1'sb0;
			s_nsb_nodeslot_allocated_fetch_tag_strobe_r <= 1'sb0;
		end
		else begin
			s_axi_arready_r <= 1'b0;
			s_ctrl_fetch_layer_weights_done_strobe_r <= 1'sb0;
			s_nsb_nodeslot_node_state_strobe_r <= 1'sb0;
			s_nsb_nodeslot_allocated_fetch_tag_strobe_r <= 1'sb0;
			case (v_state_r)
				32'd0:
					if (s_axi_arvalid) begin
						s_axi_araddr_reg_r <= s_axi_araddr;
						s_axi_arready_r <= 1'b1;
						v_state_r <= 32'd1;
					end
				32'd1: begin
					v_addr_hit = 1'b0;
					v_rdata_r <= 1'sb0;
					if (s_axi_araddr_reg_r[AXI_ADDR_WIDTH - 1:2] == (BASEADDR[AXI_ADDR_WIDTH - 1:2] + node_scoreboard_regbank_regs_pkg_LAYER_CONFIG_WEIGHTS_ADDRESS_LSB_OFFSET[AXI_ADDR_WIDTH - 1:2])) begin
						v_addr_hit = 1'b1;
						v_rdata_r[31:0] <= s_reg_layer_config_weights_address_lsb_lsb_r;
						v_state_r <= 32'd3;
					end
					if (s_axi_araddr_reg_r[AXI_ADDR_WIDTH - 1:2] == (BASEADDR[AXI_ADDR_WIDTH - 1:2] + node_scoreboard_regbank_regs_pkg_LAYER_CONFIG_WEIGHTS_ADDRESS_MSB_OFFSET[AXI_ADDR_WIDTH - 1:2])) begin
						v_addr_hit = 1'b1;
						v_rdata_r[1:0] <= s_reg_layer_config_weights_address_msb_msb_r;
						v_state_r <= 32'd3;
					end
					if (s_axi_araddr_reg_r[AXI_ADDR_WIDTH - 1:2] == (BASEADDR[AXI_ADDR_WIDTH - 1:2] + node_scoreboard_regbank_regs_pkg_CTRL_FETCH_LAYER_WEIGHTS_DONE_OFFSET[AXI_ADDR_WIDTH - 1:2])) begin
						v_addr_hit = 1'b1;
						v_rdata_r[0:0] <= s_reg_ctrl_fetch_layer_weights_done_done;
						s_ctrl_fetch_layer_weights_done_strobe_r <= 1'b1;
						v_state_r <= 32'd3;
					end
					if (s_axi_araddr_reg_r[AXI_ADDR_WIDTH - 1:2] == (BASEADDR[AXI_ADDR_WIDTH - 1:2] + node_scoreboard_regbank_regs_pkg_LAYER_CONFIG_IN_MESSAGES_ADDRESS_LSB_OFFSET[AXI_ADDR_WIDTH - 1:2])) begin
						v_addr_hit = 1'b1;
						v_rdata_r[31:0] <= s_reg_layer_config_in_messages_address_lsb_lsb_r;
						v_state_r <= 32'd3;
					end
					if (s_axi_araddr_reg_r[AXI_ADDR_WIDTH - 1:2] == (BASEADDR[AXI_ADDR_WIDTH - 1:2] + node_scoreboard_regbank_regs_pkg_LAYER_CONFIG_IN_MESSAGES_ADDRESS_MSB_OFFSET[AXI_ADDR_WIDTH - 1:2])) begin
						v_addr_hit = 1'b1;
						v_rdata_r[1:0] <= s_reg_layer_config_in_messages_address_msb_msb_r;
						v_state_r <= 32'd3;
					end
					if (s_axi_araddr_reg_r[AXI_ADDR_WIDTH - 1:2] == (BASEADDR[AXI_ADDR_WIDTH - 1:2] + node_scoreboard_regbank_regs_pkg_LAYER_CONFIG_OUT_MESSAGES_ADDRESS_LSB_OFFSET[AXI_ADDR_WIDTH - 1:2])) begin
						v_addr_hit = 1'b1;
						v_rdata_r[31:0] <= s_reg_layer_config_out_messages_address_lsb_lsb_r;
						v_state_r <= 32'd3;
					end
					if (s_axi_araddr_reg_r[AXI_ADDR_WIDTH - 1:2] == (BASEADDR[AXI_ADDR_WIDTH - 1:2] + node_scoreboard_regbank_regs_pkg_LAYER_CONFIG_OUT_MESSAGES_ADDRESS_MSB_OFFSET[AXI_ADDR_WIDTH - 1:2])) begin
						v_addr_hit = 1'b1;
						v_rdata_r[1:0] <= s_reg_layer_config_out_messages_address_msb_msb_r;
						v_state_r <= 32'd3;
					end
					begin : sv2v_autoblock_1
						reg signed [31:0] i;
						for (i = 0; i < 32; i = i + 1)
							if (s_axi_araddr_reg_r[AXI_ADDR_WIDTH - 1:2] == ((BASEADDR[AXI_ADDR_WIDTH - 1:2] + node_scoreboard_regbank_regs_pkg_NSB_NODESLOT_NEIGHBOUR_COUNT_OFFSET[AXI_ADDR_WIDTH - 1:2]) + sv2v_cast_5219A_signed(i * 1))) begin
								v_addr_hit = 1'b1;
								v_rdata_r[19:0] <= s_reg_nsb_nodeslot_neighbour_count_count_r[i * 20+:20];
								v_state_r <= 32'd3;
							end
					end
					begin : sv2v_autoblock_2
						reg signed [31:0] i;
						for (i = 0; i < 32; i = i + 1)
							if (s_axi_araddr_reg_r[AXI_ADDR_WIDTH - 1:2] == ((BASEADDR[AXI_ADDR_WIDTH - 1:2] + node_scoreboard_regbank_regs_pkg_NSB_NODESLOT_NODE_ID_OFFSET[AXI_ADDR_WIDTH - 1:2]) + sv2v_cast_5219A_signed(i * 1))) begin
								v_addr_hit = 1'b1;
								v_rdata_r[19:0] <= s_reg_nsb_nodeslot_node_id_id_r[i * 20+:20];
								v_state_r <= 32'd3;
							end
					end
					begin : sv2v_autoblock_3
						reg signed [31:0] i;
						for (i = 0; i < 32; i = i + 1)
							if (s_axi_araddr_reg_r[AXI_ADDR_WIDTH - 1:2] == ((BASEADDR[AXI_ADDR_WIDTH - 1:2] + node_scoreboard_regbank_regs_pkg_NSB_NODESLOT_NODE_STATE_OFFSET[AXI_ADDR_WIDTH - 1:2]) + sv2v_cast_5219A_signed(i * 1))) begin
								v_addr_hit = 1'b1;
								v_rdata_r[3:0] <= s_reg_nsb_nodeslot_node_state_state[i * 4+:4];
								s_nsb_nodeslot_node_state_strobe_r[i] <= 1'b1;
								v_state_r <= 32'd3;
							end
					end
					begin : sv2v_autoblock_4
						reg signed [31:0] i;
						for (i = 0; i < 32; i = i + 1)
							if (s_axi_araddr_reg_r[AXI_ADDR_WIDTH - 1:2] == ((BASEADDR[AXI_ADDR_WIDTH - 1:2] + node_scoreboard_regbank_regs_pkg_NSB_NODESLOT_PRECISION_OFFSET[AXI_ADDR_WIDTH - 1:2]) + sv2v_cast_5219A_signed(i * 1))) begin
								v_addr_hit = 1'b1;
								v_rdata_r[1:0] <= s_reg_nsb_nodeslot_precision_precision_r[i * 2+:2];
								v_state_r <= 32'd3;
							end
					end
					begin : sv2v_autoblock_5
						reg signed [31:0] i;
						for (i = 0; i < 32; i = i + 1)
							if (s_axi_araddr_reg_r[AXI_ADDR_WIDTH - 1:2] == ((BASEADDR[AXI_ADDR_WIDTH - 1:2] + node_scoreboard_regbank_regs_pkg_NSB_NODESLOT_ADJACENCY_LIST_ADDRESS_LSB_OFFSET[AXI_ADDR_WIDTH - 1:2]) + sv2v_cast_5219A_signed(i * 1))) begin
								v_addr_hit = 1'b1;
								v_rdata_r[31:0] <= s_reg_nsb_nodeslot_adjacency_list_address_lsb_lsb_r[i * 32+:32];
								v_state_r <= 32'd3;
							end
					end
					begin : sv2v_autoblock_6
						reg signed [31:0] i;
						for (i = 0; i < 32; i = i + 1)
							if (s_axi_araddr_reg_r[AXI_ADDR_WIDTH - 1:2] == ((BASEADDR[AXI_ADDR_WIDTH - 1:2] + node_scoreboard_regbank_regs_pkg_NSB_NODESLOT_ADJACENCY_LIST_ADDRESS_MSB_OFFSET[AXI_ADDR_WIDTH - 1:2]) + sv2v_cast_5219A_signed(i * 1))) begin
								v_addr_hit = 1'b1;
								v_rdata_r[1:0] <= s_reg_nsb_nodeslot_adjacency_list_address_msb_msb_r[i * 2+:2];
								v_state_r <= 32'd3;
							end
					end
					begin : sv2v_autoblock_7
						reg signed [31:0] i;
						for (i = 0; i < 32; i = i + 1)
							if (s_axi_araddr_reg_r[AXI_ADDR_WIDTH - 1:2] == ((BASEADDR[AXI_ADDR_WIDTH - 1:2] + node_scoreboard_regbank_regs_pkg_NSB_NODESLOT_OUT_MESSAGES_ADDRESS_LSB_OFFSET[AXI_ADDR_WIDTH - 1:2]) + sv2v_cast_5219A_signed(i * 1))) begin
								v_addr_hit = 1'b1;
								v_rdata_r[31:0] <= s_reg_nsb_nodeslot_out_messages_address_lsb_lsb_r[i * 32+:32];
								v_state_r <= 32'd3;
							end
					end
					begin : sv2v_autoblock_8
						reg signed [31:0] i;
						for (i = 0; i < 32; i = i + 1)
							if (s_axi_araddr_reg_r[AXI_ADDR_WIDTH - 1:2] == ((BASEADDR[AXI_ADDR_WIDTH - 1:2] + node_scoreboard_regbank_regs_pkg_NSB_NODESLOT_OUT_MESSAGES_ADDRESS_MSB_OFFSET[AXI_ADDR_WIDTH - 1:2]) + sv2v_cast_5219A_signed(i * 1))) begin
								v_addr_hit = 1'b1;
								v_rdata_r[1:0] <= s_reg_nsb_nodeslot_out_messages_address_msb_msb_r[i * 2+:2];
								v_state_r <= 32'd3;
							end
					end
					if (s_axi_araddr_reg_r[AXI_ADDR_WIDTH - 1:2] == (BASEADDR[AXI_ADDR_WIDTH - 1:2] + node_scoreboard_regbank_regs_pkg_NSB_NODESLOT_CONFIG_MAKE_VALID_LSB_OFFSET[AXI_ADDR_WIDTH - 1:2])) begin
						v_addr_hit = 1'b1;
						v_rdata_r[31:0] <= s_reg_nsb_nodeslot_config_make_valid_lsb_make_valid_r;
						v_state_r <= 32'd3;
					end
					begin : sv2v_autoblock_9
						reg signed [31:0] i;
						for (i = 0; i < 32; i = i + 1)
							if (s_axi_araddr_reg_r[AXI_ADDR_WIDTH - 1:2] == ((BASEADDR[AXI_ADDR_WIDTH - 1:2] + node_scoreboard_regbank_regs_pkg_NSB_NODESLOT_ALLOCATED_FETCH_TAG_OFFSET[AXI_ADDR_WIDTH - 1:2]) + sv2v_cast_5219A_signed(i * 1))) begin
								v_addr_hit = 1'b1;
								v_rdata_r[5:0] <= s_reg_nsb_nodeslot_allocated_fetch_tag_fetch_tag[i * 6+:6];
								s_nsb_nodeslot_allocated_fetch_tag_strobe_r[i] <= 1'b1;
								v_state_r <= 32'd3;
							end
					end
					if (s_axi_araddr_reg_r[AXI_ADDR_WIDTH - 1:2] == (BASEADDR[AXI_ADDR_WIDTH - 1:2] + node_scoreboard_regbank_regs_pkg_LAYER_CONFIG_IN_FEATURES_OFFSET[AXI_ADDR_WIDTH - 1:2])) begin
						v_addr_hit = 1'b1;
						v_rdata_r[9:0] <= s_reg_layer_config_in_features_count_r;
						v_state_r <= 32'd3;
					end
					if (s_axi_araddr_reg_r[AXI_ADDR_WIDTH - 1:2] == (BASEADDR[AXI_ADDR_WIDTH - 1:2] + node_scoreboard_regbank_regs_pkg_LAYER_CONFIG_OUT_FEATURES_OFFSET[AXI_ADDR_WIDTH - 1:2])) begin
						v_addr_hit = 1'b1;
						v_rdata_r[9:0] <= s_reg_layer_config_out_features_count_r;
						v_state_r <= 32'd3;
					end
					if (s_axi_araddr_reg_r[AXI_ADDR_WIDTH - 1:2] == (BASEADDR[AXI_ADDR_WIDTH - 1:2] + node_scoreboard_regbank_regs_pkg_LAYER_CONFIG_WEIGHTS_PRECISION_OFFSET[AXI_ADDR_WIDTH - 1:2])) begin
						v_addr_hit = 1'b1;
						v_rdata_r[2:0] <= s_reg_layer_config_weights_precision_precision_r;
						v_state_r <= 32'd3;
					end
					if (s_axi_araddr_reg_r[AXI_ADDR_WIDTH - 1:2] == (BASEADDR[AXI_ADDR_WIDTH - 1:2] + node_scoreboard_regbank_regs_pkg_LAYER_CONFIG_ACTIVATIONS_PRECISION_OFFSET[AXI_ADDR_WIDTH - 1:2])) begin
						v_addr_hit = 1'b1;
						v_rdata_r[2:0] <= s_reg_layer_config_activations_precision_precision_r;
						v_state_r <= 32'd3;
					end
					if (s_axi_araddr_reg_r[AXI_ADDR_WIDTH - 1:2] == (BASEADDR[AXI_ADDR_WIDTH - 1:2] + node_scoreboard_regbank_regs_pkg_LAYER_CONFIG_ADJACENCY_LIST_ADDRESS_LSB_OFFSET[AXI_ADDR_WIDTH - 1:2])) begin
						v_addr_hit = 1'b1;
						v_rdata_r[31:0] <= s_reg_layer_config_adjacency_list_address_lsb_lsb_r;
						v_state_r <= 32'd3;
					end
					if (s_axi_araddr_reg_r[AXI_ADDR_WIDTH - 1:2] == (BASEADDR[AXI_ADDR_WIDTH - 1:2] + node_scoreboard_regbank_regs_pkg_LAYER_CONFIG_ADJACENCY_LIST_ADDRESS_MSB_OFFSET[AXI_ADDR_WIDTH - 1:2])) begin
						v_addr_hit = 1'b1;
						v_rdata_r[1:0] <= s_reg_layer_config_adjacency_list_address_msb_msb_r;
						v_state_r <= 32'd3;
					end
					begin : sv2v_autoblock_10
						reg signed [31:0] i;
						for (i = 0; i < 32; i = i + 1)
							if (s_axi_araddr_reg_r[AXI_ADDR_WIDTH - 1:2] == ((BASEADDR[AXI_ADDR_WIDTH - 1:2] + node_scoreboard_regbank_regs_pkg_NSB_NODESLOT_AGGREGATION_FUNCTION_OFFSET[AXI_ADDR_WIDTH - 1:2]) + sv2v_cast_5219A_signed(i * 1))) begin
								v_addr_hit = 1'b1;
								v_rdata_r[1:0] <= s_reg_nsb_nodeslot_aggregation_function_value_r[i * 2+:2];
								v_state_r <= 32'd3;
							end
					end
					begin : sv2v_autoblock_11
						reg signed [31:0] i;
						for (i = 0; i < 32; i = i + 1)
							if (s_axi_araddr_reg_r[AXI_ADDR_WIDTH - 1:2] == ((BASEADDR[AXI_ADDR_WIDTH - 1:2] + node_scoreboard_regbank_regs_pkg_NSB_NODESLOT_SCALE_FACTORS_ADDRESS_LSB_OFFSET[AXI_ADDR_WIDTH - 1:2]) + sv2v_cast_5219A_signed(i * 1))) begin
								v_addr_hit = 1'b1;
								v_rdata_r[31:0] <= s_reg_nsb_nodeslot_scale_factors_address_lsb_value_r[i * 32+:32];
								v_state_r <= 32'd3;
							end
					end
					begin : sv2v_autoblock_12
						reg signed [31:0] i;
						for (i = 0; i < 32; i = i + 1)
							if (s_axi_araddr_reg_r[AXI_ADDR_WIDTH - 1:2] == ((BASEADDR[AXI_ADDR_WIDTH - 1:2] + node_scoreboard_regbank_regs_pkg_NSB_NODESLOT_SCALE_FACTORS_ADDRESS_MSB_OFFSET[AXI_ADDR_WIDTH - 1:2]) + sv2v_cast_5219A_signed(i * 1))) begin
								v_addr_hit = 1'b1;
								v_rdata_r[1:0] <= s_reg_nsb_nodeslot_scale_factors_address_msb_value_r[i * 2+:2];
								v_state_r <= 32'd3;
							end
					end
					if (v_addr_hit)
						v_rresp_r <= AXI_OKAY;
					else begin
						v_rresp_r <= AXI_SLVERR;
						$warning("ARADDR decode error");
						v_state_r <= 32'd3;
					end
				end
				32'd2:
					if (v_mem_wait_count_r == 0)
						v_state_r <= 32'd3;
					else
						v_mem_wait_count_r <= v_mem_wait_count_r - 1;
				32'd3: begin
					s_axi_rvalid_r <= 1'b1;
					s_axi_rresp_r <= v_rresp_r;
					s_axi_rdata_r <= v_rdata_r;
					v_state_r <= 32'd4;
				end
				32'd4:
					if (s_axi_rready) begin
						s_axi_rvalid_r <= 1'b0;
						s_axi_rdata_r <= 1'sb0;
						v_state_r <= 32'd0;
					end
			endcase
		end
	end
	localparam [0:0] node_scoreboard_regbank_regs_pkg_CTRL_FETCH_LAYER_WEIGHTS_DONE_ACK_ACK_RESET = 1'b0;
	localparam [31:0] node_scoreboard_regbank_regs_pkg_CTRL_FETCH_LAYER_WEIGHTS_DONE_ACK_OFFSET = 32'h00000010;
	localparam [0:0] node_scoreboard_regbank_regs_pkg_CTRL_FETCH_LAYER_WEIGHTS_FETCH_RESET = 1'b0;
	localparam [31:0] node_scoreboard_regbank_regs_pkg_CTRL_FETCH_LAYER_WEIGHTS_OFFSET = 32'h00000008;
	localparam [2:0] node_scoreboard_regbank_regs_pkg_LAYER_CONFIG_ACTIVATIONS_PRECISION_PRECISION_RESET = 3'b000;
	localparam [31:0] node_scoreboard_regbank_regs_pkg_LAYER_CONFIG_ADJACENCY_LIST_ADDRESS_LSB_LSB_RESET = 32'b00000000000000000000000000000000;
	localparam [1:0] node_scoreboard_regbank_regs_pkg_LAYER_CONFIG_ADJACENCY_LIST_ADDRESS_MSB_MSB_RESET = 2'b00;
	localparam [9:0] node_scoreboard_regbank_regs_pkg_LAYER_CONFIG_IN_FEATURES_COUNT_RESET = 10'b0000000000;
	localparam [31:0] node_scoreboard_regbank_regs_pkg_LAYER_CONFIG_IN_MESSAGES_ADDRESS_LSB_LSB_RESET = 32'b00000000000000000000000000000000;
	localparam [1:0] node_scoreboard_regbank_regs_pkg_LAYER_CONFIG_IN_MESSAGES_ADDRESS_MSB_MSB_RESET = 2'b00;
	localparam [9:0] node_scoreboard_regbank_regs_pkg_LAYER_CONFIG_OUT_FEATURES_COUNT_RESET = 10'b0000000000;
	localparam [31:0] node_scoreboard_regbank_regs_pkg_LAYER_CONFIG_OUT_MESSAGES_ADDRESS_LSB_LSB_RESET = 32'b00000000000000000000000000000000;
	localparam [1:0] node_scoreboard_regbank_regs_pkg_LAYER_CONFIG_OUT_MESSAGES_ADDRESS_MSB_MSB_RESET = 2'b00;
	localparam [31:0] node_scoreboard_regbank_regs_pkg_LAYER_CONFIG_WEIGHTS_ADDRESS_LSB_LSB_RESET = 32'b00000000000000000000000000000000;
	localparam [1:0] node_scoreboard_regbank_regs_pkg_LAYER_CONFIG_WEIGHTS_ADDRESS_MSB_MSB_RESET = 2'b00;
	localparam [2:0] node_scoreboard_regbank_regs_pkg_LAYER_CONFIG_WEIGHTS_PRECISION_PRECISION_RESET = 3'b000;
	localparam [5:0] node_scoreboard_regbank_regs_pkg_NSB_CONFIG_AGGREGATION_WAIT_COUNT_COUNT_RESET = 6'b111111;
	localparam [31:0] node_scoreboard_regbank_regs_pkg_NSB_CONFIG_AGGREGATION_WAIT_COUNT_OFFSET = 32'h0000082c;
	localparam [5:0] node_scoreboard_regbank_regs_pkg_NSB_CONFIG_TRANSFORMATION_WAIT_COUNT_COUNT_RESET = 6'b111111;
	localparam [31:0] node_scoreboard_regbank_regs_pkg_NSB_CONFIG_TRANSFORMATION_WAIT_COUNT_OFFSET = 32'h00000830;
	localparam [31:0] node_scoreboard_regbank_regs_pkg_NSB_NODESLOT_ADJACENCY_LIST_ADDRESS_LSB_LSB_RESET = 32'b00000000000000000000000000000000;
	localparam [1:0] node_scoreboard_regbank_regs_pkg_NSB_NODESLOT_ADJACENCY_LIST_ADDRESS_MSB_MSB_RESET = 2'b00;
	localparam [1:0] node_scoreboard_regbank_regs_pkg_NSB_NODESLOT_AGGREGATION_FUNCTION_VALUE_RESET = 2'b00;
	localparam [31:0] node_scoreboard_regbank_regs_pkg_NSB_NODESLOT_CONFIG_MAKE_VALID_LSB_MAKE_VALID_RESET = 32'b00000000000000000000000000000000;
	localparam [31:0] node_scoreboard_regbank_regs_pkg_NSB_NODESLOT_CONFIG_MAKE_VALID_MSB_MAKE_VALID_RESET = 32'b00000000000000000000000000000000;
	localparam [31:0] node_scoreboard_regbank_regs_pkg_NSB_NODESLOT_CONFIG_MAKE_VALID_MSB_OFFSET = 32'h00000824;
	localparam [19:0] node_scoreboard_regbank_regs_pkg_NSB_NODESLOT_NEIGHBOUR_COUNT_COUNT_RESET = 20'b00000000000000000000;
	localparam [19:0] node_scoreboard_regbank_regs_pkg_NSB_NODESLOT_NODE_ID_ID_RESET = 20'b00000000000000000000;
	localparam [31:0] node_scoreboard_regbank_regs_pkg_NSB_NODESLOT_OUT_MESSAGES_ADDRESS_LSB_LSB_RESET = 32'b00000000000000000000000000000000;
	localparam [1:0] node_scoreboard_regbank_regs_pkg_NSB_NODESLOT_OUT_MESSAGES_ADDRESS_MSB_MSB_RESET = 2'b00;
	localparam [1:0] node_scoreboard_regbank_regs_pkg_NSB_NODESLOT_PRECISION_PRECISION_RESET = 2'b00;
	localparam [31:0] node_scoreboard_regbank_regs_pkg_NSB_NODESLOT_SCALE_FACTORS_ADDRESS_LSB_VALUE_RESET = 32'b00000000000000000000000000000000;
	localparam [1:0] node_scoreboard_regbank_regs_pkg_NSB_NODESLOT_SCALE_FACTORS_ADDRESS_MSB_VALUE_RESET = 2'b00;
	always @(posedge axi_aclk or negedge axi_aresetn) begin : write_fsm
		reg [31:0] v_state_r;
		reg v_addr_hit;
		reg [AXI_ADDR_WIDTH - 1:0] v_mem_addr;
		if (~axi_aresetn) begin
			v_state_r <= 32'd0;
			s_axi_awready_r <= 1'b0;
			s_axi_wready_r <= 1'b0;
			s_axi_awaddr_reg_r <= 1'sb0;
			s_axi_wdata_reg_r <= 1'sb0;
			s_axi_wstrb_reg_r <= 1'sb0;
			s_axi_bvalid_r <= 1'b0;
			s_axi_bresp_r <= 1'sb0;
			s_layer_config_weights_address_lsb_strobe_r <= 1'sb0;
			s_reg_layer_config_weights_address_lsb_lsb_r <= node_scoreboard_regbank_regs_pkg_LAYER_CONFIG_WEIGHTS_ADDRESS_LSB_LSB_RESET;
			s_layer_config_weights_address_msb_strobe_r <= 1'sb0;
			s_reg_layer_config_weights_address_msb_msb_r <= node_scoreboard_regbank_regs_pkg_LAYER_CONFIG_WEIGHTS_ADDRESS_MSB_MSB_RESET;
			s_ctrl_fetch_layer_weights_strobe_r <= 1'sb0;
			s_reg_ctrl_fetch_layer_weights_fetch_r <= node_scoreboard_regbank_regs_pkg_CTRL_FETCH_LAYER_WEIGHTS_FETCH_RESET;
			s_ctrl_fetch_layer_weights_done_ack_strobe_r <= 1'sb0;
			s_reg_ctrl_fetch_layer_weights_done_ack_ack_r <= node_scoreboard_regbank_regs_pkg_CTRL_FETCH_LAYER_WEIGHTS_DONE_ACK_ACK_RESET;
			s_layer_config_in_messages_address_lsb_strobe_r <= 1'sb0;
			s_reg_layer_config_in_messages_address_lsb_lsb_r <= node_scoreboard_regbank_regs_pkg_LAYER_CONFIG_IN_MESSAGES_ADDRESS_LSB_LSB_RESET;
			s_layer_config_in_messages_address_msb_strobe_r <= 1'sb0;
			s_reg_layer_config_in_messages_address_msb_msb_r <= node_scoreboard_regbank_regs_pkg_LAYER_CONFIG_IN_MESSAGES_ADDRESS_MSB_MSB_RESET;
			s_layer_config_out_messages_address_lsb_strobe_r <= 1'sb0;
			s_reg_layer_config_out_messages_address_lsb_lsb_r <= node_scoreboard_regbank_regs_pkg_LAYER_CONFIG_OUT_MESSAGES_ADDRESS_LSB_LSB_RESET;
			s_layer_config_out_messages_address_msb_strobe_r <= 1'sb0;
			s_reg_layer_config_out_messages_address_msb_msb_r <= node_scoreboard_regbank_regs_pkg_LAYER_CONFIG_OUT_MESSAGES_ADDRESS_MSB_MSB_RESET;
			s_nsb_nodeslot_neighbour_count_strobe_r <= 1'sb0;
			begin : sv2v_autoblock_13
				reg signed [31:0] i;
				for (i = 0; i < 32; i = i + 1)
					s_reg_nsb_nodeslot_neighbour_count_count_r[i * 20+:20] <= node_scoreboard_regbank_regs_pkg_NSB_NODESLOT_NEIGHBOUR_COUNT_COUNT_RESET;
			end
			s_nsb_nodeslot_node_id_strobe_r <= 1'sb0;
			begin : sv2v_autoblock_14
				reg signed [31:0] i;
				for (i = 0; i < 32; i = i + 1)
					s_reg_nsb_nodeslot_node_id_id_r[i * 20+:20] <= node_scoreboard_regbank_regs_pkg_NSB_NODESLOT_NODE_ID_ID_RESET;
			end
			s_nsb_nodeslot_precision_strobe_r <= 1'sb0;
			begin : sv2v_autoblock_15
				reg signed [31:0] i;
				for (i = 0; i < 32; i = i + 1)
					s_reg_nsb_nodeslot_precision_precision_r[i * 2+:2] <= node_scoreboard_regbank_regs_pkg_NSB_NODESLOT_PRECISION_PRECISION_RESET;
			end
			s_nsb_nodeslot_adjacency_list_address_lsb_strobe_r <= 1'sb0;
			begin : sv2v_autoblock_16
				reg signed [31:0] i;
				for (i = 0; i < 32; i = i + 1)
					s_reg_nsb_nodeslot_adjacency_list_address_lsb_lsb_r[i * 32+:32] <= node_scoreboard_regbank_regs_pkg_NSB_NODESLOT_ADJACENCY_LIST_ADDRESS_LSB_LSB_RESET;
			end
			s_nsb_nodeslot_adjacency_list_address_msb_strobe_r <= 1'sb0;
			begin : sv2v_autoblock_17
				reg signed [31:0] i;
				for (i = 0; i < 32; i = i + 1)
					s_reg_nsb_nodeslot_adjacency_list_address_msb_msb_r[i * 2+:2] <= node_scoreboard_regbank_regs_pkg_NSB_NODESLOT_ADJACENCY_LIST_ADDRESS_MSB_MSB_RESET;
			end
			s_nsb_nodeslot_out_messages_address_lsb_strobe_r <= 1'sb0;
			begin : sv2v_autoblock_18
				reg signed [31:0] i;
				for (i = 0; i < 32; i = i + 1)
					s_reg_nsb_nodeslot_out_messages_address_lsb_lsb_r[i * 32+:32] <= node_scoreboard_regbank_regs_pkg_NSB_NODESLOT_OUT_MESSAGES_ADDRESS_LSB_LSB_RESET;
			end
			s_nsb_nodeslot_out_messages_address_msb_strobe_r <= 1'sb0;
			begin : sv2v_autoblock_19
				reg signed [31:0] i;
				for (i = 0; i < 32; i = i + 1)
					s_reg_nsb_nodeslot_out_messages_address_msb_msb_r[i * 2+:2] <= node_scoreboard_regbank_regs_pkg_NSB_NODESLOT_OUT_MESSAGES_ADDRESS_MSB_MSB_RESET;
			end
			s_nsb_nodeslot_config_make_valid_msb_strobe_r <= 1'sb0;
			s_reg_nsb_nodeslot_config_make_valid_msb_make_valid_r <= node_scoreboard_regbank_regs_pkg_NSB_NODESLOT_CONFIG_MAKE_VALID_MSB_MAKE_VALID_RESET;
			s_nsb_nodeslot_config_make_valid_lsb_strobe_r <= 1'sb0;
			s_reg_nsb_nodeslot_config_make_valid_lsb_make_valid_r <= node_scoreboard_regbank_regs_pkg_NSB_NODESLOT_CONFIG_MAKE_VALID_LSB_MAKE_VALID_RESET;
			s_nsb_config_aggregation_wait_count_strobe_r <= 1'sb0;
			s_reg_nsb_config_aggregation_wait_count_count_r <= node_scoreboard_regbank_regs_pkg_NSB_CONFIG_AGGREGATION_WAIT_COUNT_COUNT_RESET;
			s_nsb_config_transformation_wait_count_strobe_r <= 1'sb0;
			s_reg_nsb_config_transformation_wait_count_count_r <= node_scoreboard_regbank_regs_pkg_NSB_CONFIG_TRANSFORMATION_WAIT_COUNT_COUNT_RESET;
			s_layer_config_in_features_strobe_r <= 1'sb0;
			s_reg_layer_config_in_features_count_r <= node_scoreboard_regbank_regs_pkg_LAYER_CONFIG_IN_FEATURES_COUNT_RESET;
			s_layer_config_out_features_strobe_r <= 1'sb0;
			s_reg_layer_config_out_features_count_r <= node_scoreboard_regbank_regs_pkg_LAYER_CONFIG_OUT_FEATURES_COUNT_RESET;
			s_layer_config_weights_precision_strobe_r <= 1'sb0;
			s_reg_layer_config_weights_precision_precision_r <= node_scoreboard_regbank_regs_pkg_LAYER_CONFIG_WEIGHTS_PRECISION_PRECISION_RESET;
			s_layer_config_activations_precision_strobe_r <= 1'sb0;
			s_reg_layer_config_activations_precision_precision_r <= node_scoreboard_regbank_regs_pkg_LAYER_CONFIG_ACTIVATIONS_PRECISION_PRECISION_RESET;
			s_layer_config_adjacency_list_address_lsb_strobe_r <= 1'sb0;
			s_reg_layer_config_adjacency_list_address_lsb_lsb_r <= node_scoreboard_regbank_regs_pkg_LAYER_CONFIG_ADJACENCY_LIST_ADDRESS_LSB_LSB_RESET;
			s_layer_config_adjacency_list_address_msb_strobe_r <= 1'sb0;
			s_reg_layer_config_adjacency_list_address_msb_msb_r <= node_scoreboard_regbank_regs_pkg_LAYER_CONFIG_ADJACENCY_LIST_ADDRESS_MSB_MSB_RESET;
			s_nsb_nodeslot_aggregation_function_strobe_r <= 1'sb0;
			begin : sv2v_autoblock_20
				reg signed [31:0] i;
				for (i = 0; i < 32; i = i + 1)
					s_reg_nsb_nodeslot_aggregation_function_value_r[i * 2+:2] <= node_scoreboard_regbank_regs_pkg_NSB_NODESLOT_AGGREGATION_FUNCTION_VALUE_RESET;
			end
			s_nsb_nodeslot_scale_factors_address_lsb_strobe_r <= 1'sb0;
			begin : sv2v_autoblock_21
				reg signed [31:0] i;
				for (i = 0; i < 32; i = i + 1)
					s_reg_nsb_nodeslot_scale_factors_address_lsb_value_r[i * 32+:32] <= node_scoreboard_regbank_regs_pkg_NSB_NODESLOT_SCALE_FACTORS_ADDRESS_LSB_VALUE_RESET;
			end
			s_nsb_nodeslot_scale_factors_address_msb_strobe_r <= 1'sb0;
			begin : sv2v_autoblock_22
				reg signed [31:0] i;
				for (i = 0; i < 32; i = i + 1)
					s_reg_nsb_nodeslot_scale_factors_address_msb_value_r[i * 2+:2] <= node_scoreboard_regbank_regs_pkg_NSB_NODESLOT_SCALE_FACTORS_ADDRESS_MSB_VALUE_RESET;
			end
		end
		else begin
			s_axi_awready_r <= 1'b0;
			s_axi_wready_r <= 1'b0;
			s_layer_config_weights_address_lsb_strobe_r <= 1'sb0;
			s_layer_config_weights_address_msb_strobe_r <= 1'sb0;
			s_ctrl_fetch_layer_weights_strobe_r <= 1'sb0;
			s_ctrl_fetch_layer_weights_done_ack_strobe_r <= 1'sb0;
			s_layer_config_in_messages_address_lsb_strobe_r <= 1'sb0;
			s_layer_config_in_messages_address_msb_strobe_r <= 1'sb0;
			s_layer_config_out_messages_address_lsb_strobe_r <= 1'sb0;
			s_layer_config_out_messages_address_msb_strobe_r <= 1'sb0;
			s_nsb_nodeslot_neighbour_count_strobe_r <= 1'sb0;
			s_nsb_nodeslot_node_id_strobe_r <= 1'sb0;
			s_nsb_nodeslot_precision_strobe_r <= 1'sb0;
			s_nsb_nodeslot_adjacency_list_address_lsb_strobe_r <= 1'sb0;
			s_nsb_nodeslot_adjacency_list_address_msb_strobe_r <= 1'sb0;
			s_nsb_nodeslot_out_messages_address_lsb_strobe_r <= 1'sb0;
			s_nsb_nodeslot_out_messages_address_msb_strobe_r <= 1'sb0;
			s_nsb_nodeslot_config_make_valid_msb_strobe_r <= 1'sb0;
			s_nsb_nodeslot_config_make_valid_lsb_strobe_r <= 1'sb0;
			s_nsb_config_aggregation_wait_count_strobe_r <= 1'sb0;
			s_nsb_config_transformation_wait_count_strobe_r <= 1'sb0;
			s_layer_config_in_features_strobe_r <= 1'sb0;
			s_layer_config_out_features_strobe_r <= 1'sb0;
			s_layer_config_weights_precision_strobe_r <= 1'sb0;
			s_layer_config_activations_precision_strobe_r <= 1'sb0;
			s_layer_config_adjacency_list_address_lsb_strobe_r <= 1'sb0;
			s_layer_config_adjacency_list_address_msb_strobe_r <= 1'sb0;
			s_nsb_nodeslot_aggregation_function_strobe_r <= 1'sb0;
			s_nsb_nodeslot_scale_factors_address_lsb_strobe_r <= 1'sb0;
			s_nsb_nodeslot_scale_factors_address_msb_strobe_r <= 1'sb0;
			v_addr_hit = 1'b0;
			s_reg_ctrl_fetch_layer_weights_fetch_r <= 1'sb0;
			s_reg_ctrl_fetch_layer_weights_done_ack_ack_r <= 1'sb0;
			s_reg_nsb_nodeslot_config_make_valid_msb_make_valid_r <= 1'sb0;
			s_reg_nsb_nodeslot_config_make_valid_lsb_make_valid_r <= 1'sb0;
			case (v_state_r)
				32'd0:
					if (s_axi_awvalid && s_axi_wvalid) begin
						s_axi_awaddr_reg_r <= s_axi_awaddr;
						s_axi_awready_r <= 1'b1;
						s_axi_wdata_reg_r <= s_axi_wdata;
						s_axi_wstrb_reg_r <= s_axi_wstrb;
						s_axi_wready_r <= 1'b1;
						v_state_r <= 32'd3;
					end
					else if (s_axi_awvalid) begin
						s_axi_awaddr_reg_r <= s_axi_awaddr;
						s_axi_awready_r <= 1'b1;
						v_state_r <= 32'd1;
					end
					else if (s_axi_wvalid) begin
						s_axi_wdata_reg_r <= s_axi_wdata;
						s_axi_wstrb_reg_r <= s_axi_wstrb;
						s_axi_wready_r <= 1'b1;
						v_state_r <= 32'd2;
					end
				32'd1:
					if (s_axi_wvalid) begin
						s_axi_wdata_reg_r <= s_axi_wdata;
						s_axi_wstrb_reg_r <= s_axi_wstrb;
						s_axi_wready_r <= 1'b1;
						v_state_r <= 32'd3;
					end
				32'd2:
					if (s_axi_awvalid) begin
						s_axi_awaddr_reg_r <= s_axi_awaddr;
						s_axi_awready_r <= 1'b1;
						v_state_r <= 32'd3;
					end
				32'd3: begin
					s_axi_bresp_r <= AXI_OKAY;
					s_axi_bvalid_r <= 1'b1;
					if (s_axi_awaddr_reg_r[AXI_ADDR_WIDTH - 1:2] == (BASEADDR[AXI_ADDR_WIDTH - 1:2] + node_scoreboard_regbank_regs_pkg_LAYER_CONFIG_WEIGHTS_ADDRESS_LSB_OFFSET[AXI_ADDR_WIDTH - 1:2])) begin
						v_addr_hit = 1'b1;
						s_layer_config_weights_address_lsb_strobe_r <= 1'b1;
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_weights_address_lsb_lsb_r[0] <= s_axi_wdata_reg_r[0];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_weights_address_lsb_lsb_r[1] <= s_axi_wdata_reg_r[1];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_weights_address_lsb_lsb_r[2] <= s_axi_wdata_reg_r[2];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_weights_address_lsb_lsb_r[3] <= s_axi_wdata_reg_r[3];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_weights_address_lsb_lsb_r[4] <= s_axi_wdata_reg_r[4];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_weights_address_lsb_lsb_r[5] <= s_axi_wdata_reg_r[5];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_weights_address_lsb_lsb_r[6] <= s_axi_wdata_reg_r[6];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_weights_address_lsb_lsb_r[7] <= s_axi_wdata_reg_r[7];
						if (s_axi_wstrb_reg_r[1])
							s_reg_layer_config_weights_address_lsb_lsb_r[8] <= s_axi_wdata_reg_r[8];
						if (s_axi_wstrb_reg_r[1])
							s_reg_layer_config_weights_address_lsb_lsb_r[9] <= s_axi_wdata_reg_r[9];
						if (s_axi_wstrb_reg_r[1])
							s_reg_layer_config_weights_address_lsb_lsb_r[10] <= s_axi_wdata_reg_r[10];
						if (s_axi_wstrb_reg_r[1])
							s_reg_layer_config_weights_address_lsb_lsb_r[11] <= s_axi_wdata_reg_r[11];
						if (s_axi_wstrb_reg_r[1])
							s_reg_layer_config_weights_address_lsb_lsb_r[12] <= s_axi_wdata_reg_r[12];
						if (s_axi_wstrb_reg_r[1])
							s_reg_layer_config_weights_address_lsb_lsb_r[13] <= s_axi_wdata_reg_r[13];
						if (s_axi_wstrb_reg_r[1])
							s_reg_layer_config_weights_address_lsb_lsb_r[14] <= s_axi_wdata_reg_r[14];
						if (s_axi_wstrb_reg_r[1])
							s_reg_layer_config_weights_address_lsb_lsb_r[15] <= s_axi_wdata_reg_r[15];
						if (s_axi_wstrb_reg_r[2])
							s_reg_layer_config_weights_address_lsb_lsb_r[16] <= s_axi_wdata_reg_r[16];
						if (s_axi_wstrb_reg_r[2])
							s_reg_layer_config_weights_address_lsb_lsb_r[17] <= s_axi_wdata_reg_r[17];
						if (s_axi_wstrb_reg_r[2])
							s_reg_layer_config_weights_address_lsb_lsb_r[18] <= s_axi_wdata_reg_r[18];
						if (s_axi_wstrb_reg_r[2])
							s_reg_layer_config_weights_address_lsb_lsb_r[19] <= s_axi_wdata_reg_r[19];
						if (s_axi_wstrb_reg_r[2])
							s_reg_layer_config_weights_address_lsb_lsb_r[20] <= s_axi_wdata_reg_r[20];
						if (s_axi_wstrb_reg_r[2])
							s_reg_layer_config_weights_address_lsb_lsb_r[21] <= s_axi_wdata_reg_r[21];
						if (s_axi_wstrb_reg_r[2])
							s_reg_layer_config_weights_address_lsb_lsb_r[22] <= s_axi_wdata_reg_r[22];
						if (s_axi_wstrb_reg_r[2])
							s_reg_layer_config_weights_address_lsb_lsb_r[23] <= s_axi_wdata_reg_r[23];
						if (s_axi_wstrb_reg_r[3])
							s_reg_layer_config_weights_address_lsb_lsb_r[24] <= s_axi_wdata_reg_r[24];
						if (s_axi_wstrb_reg_r[3])
							s_reg_layer_config_weights_address_lsb_lsb_r[25] <= s_axi_wdata_reg_r[25];
						if (s_axi_wstrb_reg_r[3])
							s_reg_layer_config_weights_address_lsb_lsb_r[26] <= s_axi_wdata_reg_r[26];
						if (s_axi_wstrb_reg_r[3])
							s_reg_layer_config_weights_address_lsb_lsb_r[27] <= s_axi_wdata_reg_r[27];
						if (s_axi_wstrb_reg_r[3])
							s_reg_layer_config_weights_address_lsb_lsb_r[28] <= s_axi_wdata_reg_r[28];
						if (s_axi_wstrb_reg_r[3])
							s_reg_layer_config_weights_address_lsb_lsb_r[29] <= s_axi_wdata_reg_r[29];
						if (s_axi_wstrb_reg_r[3])
							s_reg_layer_config_weights_address_lsb_lsb_r[30] <= s_axi_wdata_reg_r[30];
						if (s_axi_wstrb_reg_r[3])
							s_reg_layer_config_weights_address_lsb_lsb_r[31] <= s_axi_wdata_reg_r[31];
					end
					if (s_axi_awaddr_reg_r[AXI_ADDR_WIDTH - 1:2] == (BASEADDR[AXI_ADDR_WIDTH - 1:2] + node_scoreboard_regbank_regs_pkg_LAYER_CONFIG_WEIGHTS_ADDRESS_MSB_OFFSET[AXI_ADDR_WIDTH - 1:2])) begin
						v_addr_hit = 1'b1;
						s_layer_config_weights_address_msb_strobe_r <= 1'b1;
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_weights_address_msb_msb_r[0] <= s_axi_wdata_reg_r[0];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_weights_address_msb_msb_r[1] <= s_axi_wdata_reg_r[1];
					end
					if (s_axi_awaddr_reg_r[AXI_ADDR_WIDTH - 1:2] == (BASEADDR[AXI_ADDR_WIDTH - 1:2] + node_scoreboard_regbank_regs_pkg_CTRL_FETCH_LAYER_WEIGHTS_OFFSET[AXI_ADDR_WIDTH - 1:2])) begin
						v_addr_hit = 1'b1;
						s_ctrl_fetch_layer_weights_strobe_r <= 1'b1;
						if (s_axi_wstrb_reg_r[0])
							s_reg_ctrl_fetch_layer_weights_fetch_r[0] <= s_axi_wdata_reg_r[0];
					end
					if (s_axi_awaddr_reg_r[AXI_ADDR_WIDTH - 1:2] == (BASEADDR[AXI_ADDR_WIDTH - 1:2] + node_scoreboard_regbank_regs_pkg_CTRL_FETCH_LAYER_WEIGHTS_DONE_ACK_OFFSET[AXI_ADDR_WIDTH - 1:2])) begin
						v_addr_hit = 1'b1;
						s_ctrl_fetch_layer_weights_done_ack_strobe_r <= 1'b1;
						if (s_axi_wstrb_reg_r[0])
							s_reg_ctrl_fetch_layer_weights_done_ack_ack_r[0] <= s_axi_wdata_reg_r[0];
					end
					if (s_axi_awaddr_reg_r[AXI_ADDR_WIDTH - 1:2] == (BASEADDR[AXI_ADDR_WIDTH - 1:2] + node_scoreboard_regbank_regs_pkg_LAYER_CONFIG_IN_MESSAGES_ADDRESS_LSB_OFFSET[AXI_ADDR_WIDTH - 1:2])) begin
						v_addr_hit = 1'b1;
						s_layer_config_in_messages_address_lsb_strobe_r <= 1'b1;
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_in_messages_address_lsb_lsb_r[0] <= s_axi_wdata_reg_r[0];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_in_messages_address_lsb_lsb_r[1] <= s_axi_wdata_reg_r[1];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_in_messages_address_lsb_lsb_r[2] <= s_axi_wdata_reg_r[2];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_in_messages_address_lsb_lsb_r[3] <= s_axi_wdata_reg_r[3];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_in_messages_address_lsb_lsb_r[4] <= s_axi_wdata_reg_r[4];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_in_messages_address_lsb_lsb_r[5] <= s_axi_wdata_reg_r[5];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_in_messages_address_lsb_lsb_r[6] <= s_axi_wdata_reg_r[6];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_in_messages_address_lsb_lsb_r[7] <= s_axi_wdata_reg_r[7];
						if (s_axi_wstrb_reg_r[1])
							s_reg_layer_config_in_messages_address_lsb_lsb_r[8] <= s_axi_wdata_reg_r[8];
						if (s_axi_wstrb_reg_r[1])
							s_reg_layer_config_in_messages_address_lsb_lsb_r[9] <= s_axi_wdata_reg_r[9];
						if (s_axi_wstrb_reg_r[1])
							s_reg_layer_config_in_messages_address_lsb_lsb_r[10] <= s_axi_wdata_reg_r[10];
						if (s_axi_wstrb_reg_r[1])
							s_reg_layer_config_in_messages_address_lsb_lsb_r[11] <= s_axi_wdata_reg_r[11];
						if (s_axi_wstrb_reg_r[1])
							s_reg_layer_config_in_messages_address_lsb_lsb_r[12] <= s_axi_wdata_reg_r[12];
						if (s_axi_wstrb_reg_r[1])
							s_reg_layer_config_in_messages_address_lsb_lsb_r[13] <= s_axi_wdata_reg_r[13];
						if (s_axi_wstrb_reg_r[1])
							s_reg_layer_config_in_messages_address_lsb_lsb_r[14] <= s_axi_wdata_reg_r[14];
						if (s_axi_wstrb_reg_r[1])
							s_reg_layer_config_in_messages_address_lsb_lsb_r[15] <= s_axi_wdata_reg_r[15];
						if (s_axi_wstrb_reg_r[2])
							s_reg_layer_config_in_messages_address_lsb_lsb_r[16] <= s_axi_wdata_reg_r[16];
						if (s_axi_wstrb_reg_r[2])
							s_reg_layer_config_in_messages_address_lsb_lsb_r[17] <= s_axi_wdata_reg_r[17];
						if (s_axi_wstrb_reg_r[2])
							s_reg_layer_config_in_messages_address_lsb_lsb_r[18] <= s_axi_wdata_reg_r[18];
						if (s_axi_wstrb_reg_r[2])
							s_reg_layer_config_in_messages_address_lsb_lsb_r[19] <= s_axi_wdata_reg_r[19];
						if (s_axi_wstrb_reg_r[2])
							s_reg_layer_config_in_messages_address_lsb_lsb_r[20] <= s_axi_wdata_reg_r[20];
						if (s_axi_wstrb_reg_r[2])
							s_reg_layer_config_in_messages_address_lsb_lsb_r[21] <= s_axi_wdata_reg_r[21];
						if (s_axi_wstrb_reg_r[2])
							s_reg_layer_config_in_messages_address_lsb_lsb_r[22] <= s_axi_wdata_reg_r[22];
						if (s_axi_wstrb_reg_r[2])
							s_reg_layer_config_in_messages_address_lsb_lsb_r[23] <= s_axi_wdata_reg_r[23];
						if (s_axi_wstrb_reg_r[3])
							s_reg_layer_config_in_messages_address_lsb_lsb_r[24] <= s_axi_wdata_reg_r[24];
						if (s_axi_wstrb_reg_r[3])
							s_reg_layer_config_in_messages_address_lsb_lsb_r[25] <= s_axi_wdata_reg_r[25];
						if (s_axi_wstrb_reg_r[3])
							s_reg_layer_config_in_messages_address_lsb_lsb_r[26] <= s_axi_wdata_reg_r[26];
						if (s_axi_wstrb_reg_r[3])
							s_reg_layer_config_in_messages_address_lsb_lsb_r[27] <= s_axi_wdata_reg_r[27];
						if (s_axi_wstrb_reg_r[3])
							s_reg_layer_config_in_messages_address_lsb_lsb_r[28] <= s_axi_wdata_reg_r[28];
						if (s_axi_wstrb_reg_r[3])
							s_reg_layer_config_in_messages_address_lsb_lsb_r[29] <= s_axi_wdata_reg_r[29];
						if (s_axi_wstrb_reg_r[3])
							s_reg_layer_config_in_messages_address_lsb_lsb_r[30] <= s_axi_wdata_reg_r[30];
						if (s_axi_wstrb_reg_r[3])
							s_reg_layer_config_in_messages_address_lsb_lsb_r[31] <= s_axi_wdata_reg_r[31];
					end
					if (s_axi_awaddr_reg_r[AXI_ADDR_WIDTH - 1:2] == (BASEADDR[AXI_ADDR_WIDTH - 1:2] + node_scoreboard_regbank_regs_pkg_LAYER_CONFIG_IN_MESSAGES_ADDRESS_MSB_OFFSET[AXI_ADDR_WIDTH - 1:2])) begin
						v_addr_hit = 1'b1;
						s_layer_config_in_messages_address_msb_strobe_r <= 1'b1;
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_in_messages_address_msb_msb_r[0] <= s_axi_wdata_reg_r[0];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_in_messages_address_msb_msb_r[1] <= s_axi_wdata_reg_r[1];
					end
					if (s_axi_awaddr_reg_r[AXI_ADDR_WIDTH - 1:2] == (BASEADDR[AXI_ADDR_WIDTH - 1:2] + node_scoreboard_regbank_regs_pkg_LAYER_CONFIG_OUT_MESSAGES_ADDRESS_LSB_OFFSET[AXI_ADDR_WIDTH - 1:2])) begin
						v_addr_hit = 1'b1;
						s_layer_config_out_messages_address_lsb_strobe_r <= 1'b1;
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_out_messages_address_lsb_lsb_r[0] <= s_axi_wdata_reg_r[0];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_out_messages_address_lsb_lsb_r[1] <= s_axi_wdata_reg_r[1];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_out_messages_address_lsb_lsb_r[2] <= s_axi_wdata_reg_r[2];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_out_messages_address_lsb_lsb_r[3] <= s_axi_wdata_reg_r[3];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_out_messages_address_lsb_lsb_r[4] <= s_axi_wdata_reg_r[4];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_out_messages_address_lsb_lsb_r[5] <= s_axi_wdata_reg_r[5];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_out_messages_address_lsb_lsb_r[6] <= s_axi_wdata_reg_r[6];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_out_messages_address_lsb_lsb_r[7] <= s_axi_wdata_reg_r[7];
						if (s_axi_wstrb_reg_r[1])
							s_reg_layer_config_out_messages_address_lsb_lsb_r[8] <= s_axi_wdata_reg_r[8];
						if (s_axi_wstrb_reg_r[1])
							s_reg_layer_config_out_messages_address_lsb_lsb_r[9] <= s_axi_wdata_reg_r[9];
						if (s_axi_wstrb_reg_r[1])
							s_reg_layer_config_out_messages_address_lsb_lsb_r[10] <= s_axi_wdata_reg_r[10];
						if (s_axi_wstrb_reg_r[1])
							s_reg_layer_config_out_messages_address_lsb_lsb_r[11] <= s_axi_wdata_reg_r[11];
						if (s_axi_wstrb_reg_r[1])
							s_reg_layer_config_out_messages_address_lsb_lsb_r[12] <= s_axi_wdata_reg_r[12];
						if (s_axi_wstrb_reg_r[1])
							s_reg_layer_config_out_messages_address_lsb_lsb_r[13] <= s_axi_wdata_reg_r[13];
						if (s_axi_wstrb_reg_r[1])
							s_reg_layer_config_out_messages_address_lsb_lsb_r[14] <= s_axi_wdata_reg_r[14];
						if (s_axi_wstrb_reg_r[1])
							s_reg_layer_config_out_messages_address_lsb_lsb_r[15] <= s_axi_wdata_reg_r[15];
						if (s_axi_wstrb_reg_r[2])
							s_reg_layer_config_out_messages_address_lsb_lsb_r[16] <= s_axi_wdata_reg_r[16];
						if (s_axi_wstrb_reg_r[2])
							s_reg_layer_config_out_messages_address_lsb_lsb_r[17] <= s_axi_wdata_reg_r[17];
						if (s_axi_wstrb_reg_r[2])
							s_reg_layer_config_out_messages_address_lsb_lsb_r[18] <= s_axi_wdata_reg_r[18];
						if (s_axi_wstrb_reg_r[2])
							s_reg_layer_config_out_messages_address_lsb_lsb_r[19] <= s_axi_wdata_reg_r[19];
						if (s_axi_wstrb_reg_r[2])
							s_reg_layer_config_out_messages_address_lsb_lsb_r[20] <= s_axi_wdata_reg_r[20];
						if (s_axi_wstrb_reg_r[2])
							s_reg_layer_config_out_messages_address_lsb_lsb_r[21] <= s_axi_wdata_reg_r[21];
						if (s_axi_wstrb_reg_r[2])
							s_reg_layer_config_out_messages_address_lsb_lsb_r[22] <= s_axi_wdata_reg_r[22];
						if (s_axi_wstrb_reg_r[2])
							s_reg_layer_config_out_messages_address_lsb_lsb_r[23] <= s_axi_wdata_reg_r[23];
						if (s_axi_wstrb_reg_r[3])
							s_reg_layer_config_out_messages_address_lsb_lsb_r[24] <= s_axi_wdata_reg_r[24];
						if (s_axi_wstrb_reg_r[3])
							s_reg_layer_config_out_messages_address_lsb_lsb_r[25] <= s_axi_wdata_reg_r[25];
						if (s_axi_wstrb_reg_r[3])
							s_reg_layer_config_out_messages_address_lsb_lsb_r[26] <= s_axi_wdata_reg_r[26];
						if (s_axi_wstrb_reg_r[3])
							s_reg_layer_config_out_messages_address_lsb_lsb_r[27] <= s_axi_wdata_reg_r[27];
						if (s_axi_wstrb_reg_r[3])
							s_reg_layer_config_out_messages_address_lsb_lsb_r[28] <= s_axi_wdata_reg_r[28];
						if (s_axi_wstrb_reg_r[3])
							s_reg_layer_config_out_messages_address_lsb_lsb_r[29] <= s_axi_wdata_reg_r[29];
						if (s_axi_wstrb_reg_r[3])
							s_reg_layer_config_out_messages_address_lsb_lsb_r[30] <= s_axi_wdata_reg_r[30];
						if (s_axi_wstrb_reg_r[3])
							s_reg_layer_config_out_messages_address_lsb_lsb_r[31] <= s_axi_wdata_reg_r[31];
					end
					if (s_axi_awaddr_reg_r[AXI_ADDR_WIDTH - 1:2] == (BASEADDR[AXI_ADDR_WIDTH - 1:2] + node_scoreboard_regbank_regs_pkg_LAYER_CONFIG_OUT_MESSAGES_ADDRESS_MSB_OFFSET[AXI_ADDR_WIDTH - 1:2])) begin
						v_addr_hit = 1'b1;
						s_layer_config_out_messages_address_msb_strobe_r <= 1'b1;
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_out_messages_address_msb_msb_r[0] <= s_axi_wdata_reg_r[0];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_out_messages_address_msb_msb_r[1] <= s_axi_wdata_reg_r[1];
					end
					begin : sv2v_autoblock_23
						reg signed [31:0] i;
						for (i = 0; i < 32; i = i + 1)
							if (s_axi_awaddr_reg_r[AXI_ADDR_WIDTH - 1:2] == ((BASEADDR[AXI_ADDR_WIDTH - 1:2] + node_scoreboard_regbank_regs_pkg_NSB_NODESLOT_NEIGHBOUR_COUNT_OFFSET[AXI_ADDR_WIDTH - 1:2]) + sv2v_cast_5219A_signed(i * 1))) begin
								v_addr_hit = 1'b1;
								s_nsb_nodeslot_neighbour_count_strobe_r[i] <= 1'b1;
								if (s_axi_wstrb_reg_r[0])
									s_reg_nsb_nodeslot_neighbour_count_count_r[i * 20] <= s_axi_wdata_reg_r[0];
								if (s_axi_wstrb_reg_r[0])
									s_reg_nsb_nodeslot_neighbour_count_count_r[(i * 20) + 1] <= s_axi_wdata_reg_r[1];
								if (s_axi_wstrb_reg_r[0])
									s_reg_nsb_nodeslot_neighbour_count_count_r[(i * 20) + 2] <= s_axi_wdata_reg_r[2];
								if (s_axi_wstrb_reg_r[0])
									s_reg_nsb_nodeslot_neighbour_count_count_r[(i * 20) + 3] <= s_axi_wdata_reg_r[3];
								if (s_axi_wstrb_reg_r[0])
									s_reg_nsb_nodeslot_neighbour_count_count_r[(i * 20) + 4] <= s_axi_wdata_reg_r[4];
								if (s_axi_wstrb_reg_r[0])
									s_reg_nsb_nodeslot_neighbour_count_count_r[(i * 20) + 5] <= s_axi_wdata_reg_r[5];
								if (s_axi_wstrb_reg_r[0])
									s_reg_nsb_nodeslot_neighbour_count_count_r[(i * 20) + 6] <= s_axi_wdata_reg_r[6];
								if (s_axi_wstrb_reg_r[0])
									s_reg_nsb_nodeslot_neighbour_count_count_r[(i * 20) + 7] <= s_axi_wdata_reg_r[7];
								if (s_axi_wstrb_reg_r[1])
									s_reg_nsb_nodeslot_neighbour_count_count_r[(i * 20) + 8] <= s_axi_wdata_reg_r[8];
								if (s_axi_wstrb_reg_r[1])
									s_reg_nsb_nodeslot_neighbour_count_count_r[(i * 20) + 9] <= s_axi_wdata_reg_r[9];
								if (s_axi_wstrb_reg_r[1])
									s_reg_nsb_nodeslot_neighbour_count_count_r[(i * 20) + 10] <= s_axi_wdata_reg_r[10];
								if (s_axi_wstrb_reg_r[1])
									s_reg_nsb_nodeslot_neighbour_count_count_r[(i * 20) + 11] <= s_axi_wdata_reg_r[11];
								if (s_axi_wstrb_reg_r[1])
									s_reg_nsb_nodeslot_neighbour_count_count_r[(i * 20) + 12] <= s_axi_wdata_reg_r[12];
								if (s_axi_wstrb_reg_r[1])
									s_reg_nsb_nodeslot_neighbour_count_count_r[(i * 20) + 13] <= s_axi_wdata_reg_r[13];
								if (s_axi_wstrb_reg_r[1])
									s_reg_nsb_nodeslot_neighbour_count_count_r[(i * 20) + 14] <= s_axi_wdata_reg_r[14];
								if (s_axi_wstrb_reg_r[1])
									s_reg_nsb_nodeslot_neighbour_count_count_r[(i * 20) + 15] <= s_axi_wdata_reg_r[15];
								if (s_axi_wstrb_reg_r[2])
									s_reg_nsb_nodeslot_neighbour_count_count_r[(i * 20) + 16] <= s_axi_wdata_reg_r[16];
								if (s_axi_wstrb_reg_r[2])
									s_reg_nsb_nodeslot_neighbour_count_count_r[(i * 20) + 17] <= s_axi_wdata_reg_r[17];
								if (s_axi_wstrb_reg_r[2])
									s_reg_nsb_nodeslot_neighbour_count_count_r[(i * 20) + 18] <= s_axi_wdata_reg_r[18];
								if (s_axi_wstrb_reg_r[2])
									s_reg_nsb_nodeslot_neighbour_count_count_r[(i * 20) + 19] <= s_axi_wdata_reg_r[19];
							end
					end
					begin : sv2v_autoblock_24
						reg signed [31:0] i;
						for (i = 0; i < 32; i = i + 1)
							if (s_axi_awaddr_reg_r[AXI_ADDR_WIDTH - 1:2] == ((BASEADDR[AXI_ADDR_WIDTH - 1:2] + node_scoreboard_regbank_regs_pkg_NSB_NODESLOT_NODE_ID_OFFSET[AXI_ADDR_WIDTH - 1:2]) + sv2v_cast_5219A_signed(i * 1))) begin
								v_addr_hit = 1'b1;
								s_nsb_nodeslot_node_id_strobe_r[i] <= 1'b1;
								if (s_axi_wstrb_reg_r[0])
									s_reg_nsb_nodeslot_node_id_id_r[i * 20] <= s_axi_wdata_reg_r[0];
								if (s_axi_wstrb_reg_r[0])
									s_reg_nsb_nodeslot_node_id_id_r[(i * 20) + 1] <= s_axi_wdata_reg_r[1];
								if (s_axi_wstrb_reg_r[0])
									s_reg_nsb_nodeslot_node_id_id_r[(i * 20) + 2] <= s_axi_wdata_reg_r[2];
								if (s_axi_wstrb_reg_r[0])
									s_reg_nsb_nodeslot_node_id_id_r[(i * 20) + 3] <= s_axi_wdata_reg_r[3];
								if (s_axi_wstrb_reg_r[0])
									s_reg_nsb_nodeslot_node_id_id_r[(i * 20) + 4] <= s_axi_wdata_reg_r[4];
								if (s_axi_wstrb_reg_r[0])
									s_reg_nsb_nodeslot_node_id_id_r[(i * 20) + 5] <= s_axi_wdata_reg_r[5];
								if (s_axi_wstrb_reg_r[0])
									s_reg_nsb_nodeslot_node_id_id_r[(i * 20) + 6] <= s_axi_wdata_reg_r[6];
								if (s_axi_wstrb_reg_r[0])
									s_reg_nsb_nodeslot_node_id_id_r[(i * 20) + 7] <= s_axi_wdata_reg_r[7];
								if (s_axi_wstrb_reg_r[1])
									s_reg_nsb_nodeslot_node_id_id_r[(i * 20) + 8] <= s_axi_wdata_reg_r[8];
								if (s_axi_wstrb_reg_r[1])
									s_reg_nsb_nodeslot_node_id_id_r[(i * 20) + 9] <= s_axi_wdata_reg_r[9];
								if (s_axi_wstrb_reg_r[1])
									s_reg_nsb_nodeslot_node_id_id_r[(i * 20) + 10] <= s_axi_wdata_reg_r[10];
								if (s_axi_wstrb_reg_r[1])
									s_reg_nsb_nodeslot_node_id_id_r[(i * 20) + 11] <= s_axi_wdata_reg_r[11];
								if (s_axi_wstrb_reg_r[1])
									s_reg_nsb_nodeslot_node_id_id_r[(i * 20) + 12] <= s_axi_wdata_reg_r[12];
								if (s_axi_wstrb_reg_r[1])
									s_reg_nsb_nodeslot_node_id_id_r[(i * 20) + 13] <= s_axi_wdata_reg_r[13];
								if (s_axi_wstrb_reg_r[1])
									s_reg_nsb_nodeslot_node_id_id_r[(i * 20) + 14] <= s_axi_wdata_reg_r[14];
								if (s_axi_wstrb_reg_r[1])
									s_reg_nsb_nodeslot_node_id_id_r[(i * 20) + 15] <= s_axi_wdata_reg_r[15];
								if (s_axi_wstrb_reg_r[2])
									s_reg_nsb_nodeslot_node_id_id_r[(i * 20) + 16] <= s_axi_wdata_reg_r[16];
								if (s_axi_wstrb_reg_r[2])
									s_reg_nsb_nodeslot_node_id_id_r[(i * 20) + 17] <= s_axi_wdata_reg_r[17];
								if (s_axi_wstrb_reg_r[2])
									s_reg_nsb_nodeslot_node_id_id_r[(i * 20) + 18] <= s_axi_wdata_reg_r[18];
								if (s_axi_wstrb_reg_r[2])
									s_reg_nsb_nodeslot_node_id_id_r[(i * 20) + 19] <= s_axi_wdata_reg_r[19];
							end
					end
					begin : sv2v_autoblock_25
						reg signed [31:0] i;
						for (i = 0; i < 32; i = i + 1)
							if (s_axi_awaddr_reg_r[AXI_ADDR_WIDTH - 1:2] == ((BASEADDR[AXI_ADDR_WIDTH - 1:2] + node_scoreboard_regbank_regs_pkg_NSB_NODESLOT_PRECISION_OFFSET[AXI_ADDR_WIDTH - 1:2]) + sv2v_cast_5219A_signed(i * 1))) begin
								v_addr_hit = 1'b1;
								s_nsb_nodeslot_precision_strobe_r[i] <= 1'b1;
								if (s_axi_wstrb_reg_r[0])
									s_reg_nsb_nodeslot_precision_precision_r[i * 2] <= s_axi_wdata_reg_r[0];
								if (s_axi_wstrb_reg_r[0])
									s_reg_nsb_nodeslot_precision_precision_r[(i * 2) + 1] <= s_axi_wdata_reg_r[1];
							end
					end
					begin : sv2v_autoblock_26
						reg signed [31:0] i;
						for (i = 0; i < 32; i = i + 1)
							if (s_axi_awaddr_reg_r[AXI_ADDR_WIDTH - 1:2] == ((BASEADDR[AXI_ADDR_WIDTH - 1:2] + node_scoreboard_regbank_regs_pkg_NSB_NODESLOT_ADJACENCY_LIST_ADDRESS_LSB_OFFSET[AXI_ADDR_WIDTH - 1:2]) + sv2v_cast_5219A_signed(i * 1))) begin
								v_addr_hit = 1'b1;
								s_nsb_nodeslot_adjacency_list_address_lsb_strobe_r[i] <= 1'b1;
								if (s_axi_wstrb_reg_r[0])
									s_reg_nsb_nodeslot_adjacency_list_address_lsb_lsb_r[i * 32] <= s_axi_wdata_reg_r[0];
								if (s_axi_wstrb_reg_r[0])
									s_reg_nsb_nodeslot_adjacency_list_address_lsb_lsb_r[(i * 32) + 1] <= s_axi_wdata_reg_r[1];
								if (s_axi_wstrb_reg_r[0])
									s_reg_nsb_nodeslot_adjacency_list_address_lsb_lsb_r[(i * 32) + 2] <= s_axi_wdata_reg_r[2];
								if (s_axi_wstrb_reg_r[0])
									s_reg_nsb_nodeslot_adjacency_list_address_lsb_lsb_r[(i * 32) + 3] <= s_axi_wdata_reg_r[3];
								if (s_axi_wstrb_reg_r[0])
									s_reg_nsb_nodeslot_adjacency_list_address_lsb_lsb_r[(i * 32) + 4] <= s_axi_wdata_reg_r[4];
								if (s_axi_wstrb_reg_r[0])
									s_reg_nsb_nodeslot_adjacency_list_address_lsb_lsb_r[(i * 32) + 5] <= s_axi_wdata_reg_r[5];
								if (s_axi_wstrb_reg_r[0])
									s_reg_nsb_nodeslot_adjacency_list_address_lsb_lsb_r[(i * 32) + 6] <= s_axi_wdata_reg_r[6];
								if (s_axi_wstrb_reg_r[0])
									s_reg_nsb_nodeslot_adjacency_list_address_lsb_lsb_r[(i * 32) + 7] <= s_axi_wdata_reg_r[7];
								if (s_axi_wstrb_reg_r[1])
									s_reg_nsb_nodeslot_adjacency_list_address_lsb_lsb_r[(i * 32) + 8] <= s_axi_wdata_reg_r[8];
								if (s_axi_wstrb_reg_r[1])
									s_reg_nsb_nodeslot_adjacency_list_address_lsb_lsb_r[(i * 32) + 9] <= s_axi_wdata_reg_r[9];
								if (s_axi_wstrb_reg_r[1])
									s_reg_nsb_nodeslot_adjacency_list_address_lsb_lsb_r[(i * 32) + 10] <= s_axi_wdata_reg_r[10];
								if (s_axi_wstrb_reg_r[1])
									s_reg_nsb_nodeslot_adjacency_list_address_lsb_lsb_r[(i * 32) + 11] <= s_axi_wdata_reg_r[11];
								if (s_axi_wstrb_reg_r[1])
									s_reg_nsb_nodeslot_adjacency_list_address_lsb_lsb_r[(i * 32) + 12] <= s_axi_wdata_reg_r[12];
								if (s_axi_wstrb_reg_r[1])
									s_reg_nsb_nodeslot_adjacency_list_address_lsb_lsb_r[(i * 32) + 13] <= s_axi_wdata_reg_r[13];
								if (s_axi_wstrb_reg_r[1])
									s_reg_nsb_nodeslot_adjacency_list_address_lsb_lsb_r[(i * 32) + 14] <= s_axi_wdata_reg_r[14];
								if (s_axi_wstrb_reg_r[1])
									s_reg_nsb_nodeslot_adjacency_list_address_lsb_lsb_r[(i * 32) + 15] <= s_axi_wdata_reg_r[15];
								if (s_axi_wstrb_reg_r[2])
									s_reg_nsb_nodeslot_adjacency_list_address_lsb_lsb_r[(i * 32) + 16] <= s_axi_wdata_reg_r[16];
								if (s_axi_wstrb_reg_r[2])
									s_reg_nsb_nodeslot_adjacency_list_address_lsb_lsb_r[(i * 32) + 17] <= s_axi_wdata_reg_r[17];
								if (s_axi_wstrb_reg_r[2])
									s_reg_nsb_nodeslot_adjacency_list_address_lsb_lsb_r[(i * 32) + 18] <= s_axi_wdata_reg_r[18];
								if (s_axi_wstrb_reg_r[2])
									s_reg_nsb_nodeslot_adjacency_list_address_lsb_lsb_r[(i * 32) + 19] <= s_axi_wdata_reg_r[19];
								if (s_axi_wstrb_reg_r[2])
									s_reg_nsb_nodeslot_adjacency_list_address_lsb_lsb_r[(i * 32) + 20] <= s_axi_wdata_reg_r[20];
								if (s_axi_wstrb_reg_r[2])
									s_reg_nsb_nodeslot_adjacency_list_address_lsb_lsb_r[(i * 32) + 21] <= s_axi_wdata_reg_r[21];
								if (s_axi_wstrb_reg_r[2])
									s_reg_nsb_nodeslot_adjacency_list_address_lsb_lsb_r[(i * 32) + 22] <= s_axi_wdata_reg_r[22];
								if (s_axi_wstrb_reg_r[2])
									s_reg_nsb_nodeslot_adjacency_list_address_lsb_lsb_r[(i * 32) + 23] <= s_axi_wdata_reg_r[23];
								if (s_axi_wstrb_reg_r[3])
									s_reg_nsb_nodeslot_adjacency_list_address_lsb_lsb_r[(i * 32) + 24] <= s_axi_wdata_reg_r[24];
								if (s_axi_wstrb_reg_r[3])
									s_reg_nsb_nodeslot_adjacency_list_address_lsb_lsb_r[(i * 32) + 25] <= s_axi_wdata_reg_r[25];
								if (s_axi_wstrb_reg_r[3])
									s_reg_nsb_nodeslot_adjacency_list_address_lsb_lsb_r[(i * 32) + 26] <= s_axi_wdata_reg_r[26];
								if (s_axi_wstrb_reg_r[3])
									s_reg_nsb_nodeslot_adjacency_list_address_lsb_lsb_r[(i * 32) + 27] <= s_axi_wdata_reg_r[27];
								if (s_axi_wstrb_reg_r[3])
									s_reg_nsb_nodeslot_adjacency_list_address_lsb_lsb_r[(i * 32) + 28] <= s_axi_wdata_reg_r[28];
								if (s_axi_wstrb_reg_r[3])
									s_reg_nsb_nodeslot_adjacency_list_address_lsb_lsb_r[(i * 32) + 29] <= s_axi_wdata_reg_r[29];
								if (s_axi_wstrb_reg_r[3])
									s_reg_nsb_nodeslot_adjacency_list_address_lsb_lsb_r[(i * 32) + 30] <= s_axi_wdata_reg_r[30];
								if (s_axi_wstrb_reg_r[3])
									s_reg_nsb_nodeslot_adjacency_list_address_lsb_lsb_r[(i * 32) + 31] <= s_axi_wdata_reg_r[31];
							end
					end
					begin : sv2v_autoblock_27
						reg signed [31:0] i;
						for (i = 0; i < 32; i = i + 1)
							if (s_axi_awaddr_reg_r[AXI_ADDR_WIDTH - 1:2] == ((BASEADDR[AXI_ADDR_WIDTH - 1:2] + node_scoreboard_regbank_regs_pkg_NSB_NODESLOT_ADJACENCY_LIST_ADDRESS_MSB_OFFSET[AXI_ADDR_WIDTH - 1:2]) + sv2v_cast_5219A_signed(i * 1))) begin
								v_addr_hit = 1'b1;
								s_nsb_nodeslot_adjacency_list_address_msb_strobe_r[i] <= 1'b1;
								if (s_axi_wstrb_reg_r[0])
									s_reg_nsb_nodeslot_adjacency_list_address_msb_msb_r[i * 2] <= s_axi_wdata_reg_r[0];
								if (s_axi_wstrb_reg_r[0])
									s_reg_nsb_nodeslot_adjacency_list_address_msb_msb_r[(i * 2) + 1] <= s_axi_wdata_reg_r[1];
							end
					end
					begin : sv2v_autoblock_28
						reg signed [31:0] i;
						for (i = 0; i < 32; i = i + 1)
							if (s_axi_awaddr_reg_r[AXI_ADDR_WIDTH - 1:2] == ((BASEADDR[AXI_ADDR_WIDTH - 1:2] + node_scoreboard_regbank_regs_pkg_NSB_NODESLOT_OUT_MESSAGES_ADDRESS_LSB_OFFSET[AXI_ADDR_WIDTH - 1:2]) + sv2v_cast_5219A_signed(i * 1))) begin
								v_addr_hit = 1'b1;
								s_nsb_nodeslot_out_messages_address_lsb_strobe_r[i] <= 1'b1;
								if (s_axi_wstrb_reg_r[0])
									s_reg_nsb_nodeslot_out_messages_address_lsb_lsb_r[i * 32] <= s_axi_wdata_reg_r[0];
								if (s_axi_wstrb_reg_r[0])
									s_reg_nsb_nodeslot_out_messages_address_lsb_lsb_r[(i * 32) + 1] <= s_axi_wdata_reg_r[1];
								if (s_axi_wstrb_reg_r[0])
									s_reg_nsb_nodeslot_out_messages_address_lsb_lsb_r[(i * 32) + 2] <= s_axi_wdata_reg_r[2];
								if (s_axi_wstrb_reg_r[0])
									s_reg_nsb_nodeslot_out_messages_address_lsb_lsb_r[(i * 32) + 3] <= s_axi_wdata_reg_r[3];
								if (s_axi_wstrb_reg_r[0])
									s_reg_nsb_nodeslot_out_messages_address_lsb_lsb_r[(i * 32) + 4] <= s_axi_wdata_reg_r[4];
								if (s_axi_wstrb_reg_r[0])
									s_reg_nsb_nodeslot_out_messages_address_lsb_lsb_r[(i * 32) + 5] <= s_axi_wdata_reg_r[5];
								if (s_axi_wstrb_reg_r[0])
									s_reg_nsb_nodeslot_out_messages_address_lsb_lsb_r[(i * 32) + 6] <= s_axi_wdata_reg_r[6];
								if (s_axi_wstrb_reg_r[0])
									s_reg_nsb_nodeslot_out_messages_address_lsb_lsb_r[(i * 32) + 7] <= s_axi_wdata_reg_r[7];
								if (s_axi_wstrb_reg_r[1])
									s_reg_nsb_nodeslot_out_messages_address_lsb_lsb_r[(i * 32) + 8] <= s_axi_wdata_reg_r[8];
								if (s_axi_wstrb_reg_r[1])
									s_reg_nsb_nodeslot_out_messages_address_lsb_lsb_r[(i * 32) + 9] <= s_axi_wdata_reg_r[9];
								if (s_axi_wstrb_reg_r[1])
									s_reg_nsb_nodeslot_out_messages_address_lsb_lsb_r[(i * 32) + 10] <= s_axi_wdata_reg_r[10];
								if (s_axi_wstrb_reg_r[1])
									s_reg_nsb_nodeslot_out_messages_address_lsb_lsb_r[(i * 32) + 11] <= s_axi_wdata_reg_r[11];
								if (s_axi_wstrb_reg_r[1])
									s_reg_nsb_nodeslot_out_messages_address_lsb_lsb_r[(i * 32) + 12] <= s_axi_wdata_reg_r[12];
								if (s_axi_wstrb_reg_r[1])
									s_reg_nsb_nodeslot_out_messages_address_lsb_lsb_r[(i * 32) + 13] <= s_axi_wdata_reg_r[13];
								if (s_axi_wstrb_reg_r[1])
									s_reg_nsb_nodeslot_out_messages_address_lsb_lsb_r[(i * 32) + 14] <= s_axi_wdata_reg_r[14];
								if (s_axi_wstrb_reg_r[1])
									s_reg_nsb_nodeslot_out_messages_address_lsb_lsb_r[(i * 32) + 15] <= s_axi_wdata_reg_r[15];
								if (s_axi_wstrb_reg_r[2])
									s_reg_nsb_nodeslot_out_messages_address_lsb_lsb_r[(i * 32) + 16] <= s_axi_wdata_reg_r[16];
								if (s_axi_wstrb_reg_r[2])
									s_reg_nsb_nodeslot_out_messages_address_lsb_lsb_r[(i * 32) + 17] <= s_axi_wdata_reg_r[17];
								if (s_axi_wstrb_reg_r[2])
									s_reg_nsb_nodeslot_out_messages_address_lsb_lsb_r[(i * 32) + 18] <= s_axi_wdata_reg_r[18];
								if (s_axi_wstrb_reg_r[2])
									s_reg_nsb_nodeslot_out_messages_address_lsb_lsb_r[(i * 32) + 19] <= s_axi_wdata_reg_r[19];
								if (s_axi_wstrb_reg_r[2])
									s_reg_nsb_nodeslot_out_messages_address_lsb_lsb_r[(i * 32) + 20] <= s_axi_wdata_reg_r[20];
								if (s_axi_wstrb_reg_r[2])
									s_reg_nsb_nodeslot_out_messages_address_lsb_lsb_r[(i * 32) + 21] <= s_axi_wdata_reg_r[21];
								if (s_axi_wstrb_reg_r[2])
									s_reg_nsb_nodeslot_out_messages_address_lsb_lsb_r[(i * 32) + 22] <= s_axi_wdata_reg_r[22];
								if (s_axi_wstrb_reg_r[2])
									s_reg_nsb_nodeslot_out_messages_address_lsb_lsb_r[(i * 32) + 23] <= s_axi_wdata_reg_r[23];
								if (s_axi_wstrb_reg_r[3])
									s_reg_nsb_nodeslot_out_messages_address_lsb_lsb_r[(i * 32) + 24] <= s_axi_wdata_reg_r[24];
								if (s_axi_wstrb_reg_r[3])
									s_reg_nsb_nodeslot_out_messages_address_lsb_lsb_r[(i * 32) + 25] <= s_axi_wdata_reg_r[25];
								if (s_axi_wstrb_reg_r[3])
									s_reg_nsb_nodeslot_out_messages_address_lsb_lsb_r[(i * 32) + 26] <= s_axi_wdata_reg_r[26];
								if (s_axi_wstrb_reg_r[3])
									s_reg_nsb_nodeslot_out_messages_address_lsb_lsb_r[(i * 32) + 27] <= s_axi_wdata_reg_r[27];
								if (s_axi_wstrb_reg_r[3])
									s_reg_nsb_nodeslot_out_messages_address_lsb_lsb_r[(i * 32) + 28] <= s_axi_wdata_reg_r[28];
								if (s_axi_wstrb_reg_r[3])
									s_reg_nsb_nodeslot_out_messages_address_lsb_lsb_r[(i * 32) + 29] <= s_axi_wdata_reg_r[29];
								if (s_axi_wstrb_reg_r[3])
									s_reg_nsb_nodeslot_out_messages_address_lsb_lsb_r[(i * 32) + 30] <= s_axi_wdata_reg_r[30];
								if (s_axi_wstrb_reg_r[3])
									s_reg_nsb_nodeslot_out_messages_address_lsb_lsb_r[(i * 32) + 31] <= s_axi_wdata_reg_r[31];
							end
					end
					begin : sv2v_autoblock_29
						reg signed [31:0] i;
						for (i = 0; i < 32; i = i + 1)
							if (s_axi_awaddr_reg_r[AXI_ADDR_WIDTH - 1:2] == ((BASEADDR[AXI_ADDR_WIDTH - 1:2] + node_scoreboard_regbank_regs_pkg_NSB_NODESLOT_OUT_MESSAGES_ADDRESS_MSB_OFFSET[AXI_ADDR_WIDTH - 1:2]) + sv2v_cast_5219A_signed(i * 1))) begin
								v_addr_hit = 1'b1;
								s_nsb_nodeslot_out_messages_address_msb_strobe_r[i] <= 1'b1;
								if (s_axi_wstrb_reg_r[0])
									s_reg_nsb_nodeslot_out_messages_address_msb_msb_r[i * 2] <= s_axi_wdata_reg_r[0];
								if (s_axi_wstrb_reg_r[0])
									s_reg_nsb_nodeslot_out_messages_address_msb_msb_r[(i * 2) + 1] <= s_axi_wdata_reg_r[1];
							end
					end
					if (s_axi_awaddr_reg_r[AXI_ADDR_WIDTH - 1:2] == (BASEADDR[AXI_ADDR_WIDTH - 1:2] + node_scoreboard_regbank_regs_pkg_NSB_NODESLOT_CONFIG_MAKE_VALID_MSB_OFFSET[AXI_ADDR_WIDTH - 1:2])) begin
						v_addr_hit = 1'b1;
						s_nsb_nodeslot_config_make_valid_msb_strobe_r <= 1'b1;
						if (s_axi_wstrb_reg_r[0])
							s_reg_nsb_nodeslot_config_make_valid_msb_make_valid_r[0] <= s_axi_wdata_reg_r[0];
						if (s_axi_wstrb_reg_r[0])
							s_reg_nsb_nodeslot_config_make_valid_msb_make_valid_r[1] <= s_axi_wdata_reg_r[1];
						if (s_axi_wstrb_reg_r[0])
							s_reg_nsb_nodeslot_config_make_valid_msb_make_valid_r[2] <= s_axi_wdata_reg_r[2];
						if (s_axi_wstrb_reg_r[0])
							s_reg_nsb_nodeslot_config_make_valid_msb_make_valid_r[3] <= s_axi_wdata_reg_r[3];
						if (s_axi_wstrb_reg_r[0])
							s_reg_nsb_nodeslot_config_make_valid_msb_make_valid_r[4] <= s_axi_wdata_reg_r[4];
						if (s_axi_wstrb_reg_r[0])
							s_reg_nsb_nodeslot_config_make_valid_msb_make_valid_r[5] <= s_axi_wdata_reg_r[5];
						if (s_axi_wstrb_reg_r[0])
							s_reg_nsb_nodeslot_config_make_valid_msb_make_valid_r[6] <= s_axi_wdata_reg_r[6];
						if (s_axi_wstrb_reg_r[0])
							s_reg_nsb_nodeslot_config_make_valid_msb_make_valid_r[7] <= s_axi_wdata_reg_r[7];
						if (s_axi_wstrb_reg_r[1])
							s_reg_nsb_nodeslot_config_make_valid_msb_make_valid_r[8] <= s_axi_wdata_reg_r[8];
						if (s_axi_wstrb_reg_r[1])
							s_reg_nsb_nodeslot_config_make_valid_msb_make_valid_r[9] <= s_axi_wdata_reg_r[9];
						if (s_axi_wstrb_reg_r[1])
							s_reg_nsb_nodeslot_config_make_valid_msb_make_valid_r[10] <= s_axi_wdata_reg_r[10];
						if (s_axi_wstrb_reg_r[1])
							s_reg_nsb_nodeslot_config_make_valid_msb_make_valid_r[11] <= s_axi_wdata_reg_r[11];
						if (s_axi_wstrb_reg_r[1])
							s_reg_nsb_nodeslot_config_make_valid_msb_make_valid_r[12] <= s_axi_wdata_reg_r[12];
						if (s_axi_wstrb_reg_r[1])
							s_reg_nsb_nodeslot_config_make_valid_msb_make_valid_r[13] <= s_axi_wdata_reg_r[13];
						if (s_axi_wstrb_reg_r[1])
							s_reg_nsb_nodeslot_config_make_valid_msb_make_valid_r[14] <= s_axi_wdata_reg_r[14];
						if (s_axi_wstrb_reg_r[1])
							s_reg_nsb_nodeslot_config_make_valid_msb_make_valid_r[15] <= s_axi_wdata_reg_r[15];
						if (s_axi_wstrb_reg_r[2])
							s_reg_nsb_nodeslot_config_make_valid_msb_make_valid_r[16] <= s_axi_wdata_reg_r[16];
						if (s_axi_wstrb_reg_r[2])
							s_reg_nsb_nodeslot_config_make_valid_msb_make_valid_r[17] <= s_axi_wdata_reg_r[17];
						if (s_axi_wstrb_reg_r[2])
							s_reg_nsb_nodeslot_config_make_valid_msb_make_valid_r[18] <= s_axi_wdata_reg_r[18];
						if (s_axi_wstrb_reg_r[2])
							s_reg_nsb_nodeslot_config_make_valid_msb_make_valid_r[19] <= s_axi_wdata_reg_r[19];
						if (s_axi_wstrb_reg_r[2])
							s_reg_nsb_nodeslot_config_make_valid_msb_make_valid_r[20] <= s_axi_wdata_reg_r[20];
						if (s_axi_wstrb_reg_r[2])
							s_reg_nsb_nodeslot_config_make_valid_msb_make_valid_r[21] <= s_axi_wdata_reg_r[21];
						if (s_axi_wstrb_reg_r[2])
							s_reg_nsb_nodeslot_config_make_valid_msb_make_valid_r[22] <= s_axi_wdata_reg_r[22];
						if (s_axi_wstrb_reg_r[2])
							s_reg_nsb_nodeslot_config_make_valid_msb_make_valid_r[23] <= s_axi_wdata_reg_r[23];
						if (s_axi_wstrb_reg_r[3])
							s_reg_nsb_nodeslot_config_make_valid_msb_make_valid_r[24] <= s_axi_wdata_reg_r[24];
						if (s_axi_wstrb_reg_r[3])
							s_reg_nsb_nodeslot_config_make_valid_msb_make_valid_r[25] <= s_axi_wdata_reg_r[25];
						if (s_axi_wstrb_reg_r[3])
							s_reg_nsb_nodeslot_config_make_valid_msb_make_valid_r[26] <= s_axi_wdata_reg_r[26];
						if (s_axi_wstrb_reg_r[3])
							s_reg_nsb_nodeslot_config_make_valid_msb_make_valid_r[27] <= s_axi_wdata_reg_r[27];
						if (s_axi_wstrb_reg_r[3])
							s_reg_nsb_nodeslot_config_make_valid_msb_make_valid_r[28] <= s_axi_wdata_reg_r[28];
						if (s_axi_wstrb_reg_r[3])
							s_reg_nsb_nodeslot_config_make_valid_msb_make_valid_r[29] <= s_axi_wdata_reg_r[29];
						if (s_axi_wstrb_reg_r[3])
							s_reg_nsb_nodeslot_config_make_valid_msb_make_valid_r[30] <= s_axi_wdata_reg_r[30];
						if (s_axi_wstrb_reg_r[3])
							s_reg_nsb_nodeslot_config_make_valid_msb_make_valid_r[31] <= s_axi_wdata_reg_r[31];
					end
					if (s_axi_awaddr_reg_r[AXI_ADDR_WIDTH - 1:2] == (BASEADDR[AXI_ADDR_WIDTH - 1:2] + node_scoreboard_regbank_regs_pkg_NSB_NODESLOT_CONFIG_MAKE_VALID_LSB_OFFSET[AXI_ADDR_WIDTH - 1:2])) begin
						v_addr_hit = 1'b1;
						s_nsb_nodeslot_config_make_valid_lsb_strobe_r <= 1'b1;
						if (s_axi_wstrb_reg_r[0])
							s_reg_nsb_nodeslot_config_make_valid_lsb_make_valid_r[0] <= s_axi_wdata_reg_r[0];
						if (s_axi_wstrb_reg_r[0])
							s_reg_nsb_nodeslot_config_make_valid_lsb_make_valid_r[1] <= s_axi_wdata_reg_r[1];
						if (s_axi_wstrb_reg_r[0])
							s_reg_nsb_nodeslot_config_make_valid_lsb_make_valid_r[2] <= s_axi_wdata_reg_r[2];
						if (s_axi_wstrb_reg_r[0])
							s_reg_nsb_nodeslot_config_make_valid_lsb_make_valid_r[3] <= s_axi_wdata_reg_r[3];
						if (s_axi_wstrb_reg_r[0])
							s_reg_nsb_nodeslot_config_make_valid_lsb_make_valid_r[4] <= s_axi_wdata_reg_r[4];
						if (s_axi_wstrb_reg_r[0])
							s_reg_nsb_nodeslot_config_make_valid_lsb_make_valid_r[5] <= s_axi_wdata_reg_r[5];
						if (s_axi_wstrb_reg_r[0])
							s_reg_nsb_nodeslot_config_make_valid_lsb_make_valid_r[6] <= s_axi_wdata_reg_r[6];
						if (s_axi_wstrb_reg_r[0])
							s_reg_nsb_nodeslot_config_make_valid_lsb_make_valid_r[7] <= s_axi_wdata_reg_r[7];
						if (s_axi_wstrb_reg_r[1])
							s_reg_nsb_nodeslot_config_make_valid_lsb_make_valid_r[8] <= s_axi_wdata_reg_r[8];
						if (s_axi_wstrb_reg_r[1])
							s_reg_nsb_nodeslot_config_make_valid_lsb_make_valid_r[9] <= s_axi_wdata_reg_r[9];
						if (s_axi_wstrb_reg_r[1])
							s_reg_nsb_nodeslot_config_make_valid_lsb_make_valid_r[10] <= s_axi_wdata_reg_r[10];
						if (s_axi_wstrb_reg_r[1])
							s_reg_nsb_nodeslot_config_make_valid_lsb_make_valid_r[11] <= s_axi_wdata_reg_r[11];
						if (s_axi_wstrb_reg_r[1])
							s_reg_nsb_nodeslot_config_make_valid_lsb_make_valid_r[12] <= s_axi_wdata_reg_r[12];
						if (s_axi_wstrb_reg_r[1])
							s_reg_nsb_nodeslot_config_make_valid_lsb_make_valid_r[13] <= s_axi_wdata_reg_r[13];
						if (s_axi_wstrb_reg_r[1])
							s_reg_nsb_nodeslot_config_make_valid_lsb_make_valid_r[14] <= s_axi_wdata_reg_r[14];
						if (s_axi_wstrb_reg_r[1])
							s_reg_nsb_nodeslot_config_make_valid_lsb_make_valid_r[15] <= s_axi_wdata_reg_r[15];
						if (s_axi_wstrb_reg_r[2])
							s_reg_nsb_nodeslot_config_make_valid_lsb_make_valid_r[16] <= s_axi_wdata_reg_r[16];
						if (s_axi_wstrb_reg_r[2])
							s_reg_nsb_nodeslot_config_make_valid_lsb_make_valid_r[17] <= s_axi_wdata_reg_r[17];
						if (s_axi_wstrb_reg_r[2])
							s_reg_nsb_nodeslot_config_make_valid_lsb_make_valid_r[18] <= s_axi_wdata_reg_r[18];
						if (s_axi_wstrb_reg_r[2])
							s_reg_nsb_nodeslot_config_make_valid_lsb_make_valid_r[19] <= s_axi_wdata_reg_r[19];
						if (s_axi_wstrb_reg_r[2])
							s_reg_nsb_nodeslot_config_make_valid_lsb_make_valid_r[20] <= s_axi_wdata_reg_r[20];
						if (s_axi_wstrb_reg_r[2])
							s_reg_nsb_nodeslot_config_make_valid_lsb_make_valid_r[21] <= s_axi_wdata_reg_r[21];
						if (s_axi_wstrb_reg_r[2])
							s_reg_nsb_nodeslot_config_make_valid_lsb_make_valid_r[22] <= s_axi_wdata_reg_r[22];
						if (s_axi_wstrb_reg_r[2])
							s_reg_nsb_nodeslot_config_make_valid_lsb_make_valid_r[23] <= s_axi_wdata_reg_r[23];
						if (s_axi_wstrb_reg_r[3])
							s_reg_nsb_nodeslot_config_make_valid_lsb_make_valid_r[24] <= s_axi_wdata_reg_r[24];
						if (s_axi_wstrb_reg_r[3])
							s_reg_nsb_nodeslot_config_make_valid_lsb_make_valid_r[25] <= s_axi_wdata_reg_r[25];
						if (s_axi_wstrb_reg_r[3])
							s_reg_nsb_nodeslot_config_make_valid_lsb_make_valid_r[26] <= s_axi_wdata_reg_r[26];
						if (s_axi_wstrb_reg_r[3])
							s_reg_nsb_nodeslot_config_make_valid_lsb_make_valid_r[27] <= s_axi_wdata_reg_r[27];
						if (s_axi_wstrb_reg_r[3])
							s_reg_nsb_nodeslot_config_make_valid_lsb_make_valid_r[28] <= s_axi_wdata_reg_r[28];
						if (s_axi_wstrb_reg_r[3])
							s_reg_nsb_nodeslot_config_make_valid_lsb_make_valid_r[29] <= s_axi_wdata_reg_r[29];
						if (s_axi_wstrb_reg_r[3])
							s_reg_nsb_nodeslot_config_make_valid_lsb_make_valid_r[30] <= s_axi_wdata_reg_r[30];
						if (s_axi_wstrb_reg_r[3])
							s_reg_nsb_nodeslot_config_make_valid_lsb_make_valid_r[31] <= s_axi_wdata_reg_r[31];
					end
					if (s_axi_awaddr_reg_r[AXI_ADDR_WIDTH - 1:2] == (BASEADDR[AXI_ADDR_WIDTH - 1:2] + node_scoreboard_regbank_regs_pkg_NSB_CONFIG_AGGREGATION_WAIT_COUNT_OFFSET[AXI_ADDR_WIDTH - 1:2])) begin
						v_addr_hit = 1'b1;
						s_nsb_config_aggregation_wait_count_strobe_r <= 1'b1;
						if (s_axi_wstrb_reg_r[0])
							s_reg_nsb_config_aggregation_wait_count_count_r[0] <= s_axi_wdata_reg_r[0];
						if (s_axi_wstrb_reg_r[0])
							s_reg_nsb_config_aggregation_wait_count_count_r[1] <= s_axi_wdata_reg_r[1];
						if (s_axi_wstrb_reg_r[0])
							s_reg_nsb_config_aggregation_wait_count_count_r[2] <= s_axi_wdata_reg_r[2];
						if (s_axi_wstrb_reg_r[0])
							s_reg_nsb_config_aggregation_wait_count_count_r[3] <= s_axi_wdata_reg_r[3];
						if (s_axi_wstrb_reg_r[0])
							s_reg_nsb_config_aggregation_wait_count_count_r[4] <= s_axi_wdata_reg_r[4];
						if (s_axi_wstrb_reg_r[0])
							s_reg_nsb_config_aggregation_wait_count_count_r[5] <= s_axi_wdata_reg_r[5];
					end
					if (s_axi_awaddr_reg_r[AXI_ADDR_WIDTH - 1:2] == (BASEADDR[AXI_ADDR_WIDTH - 1:2] + node_scoreboard_regbank_regs_pkg_NSB_CONFIG_TRANSFORMATION_WAIT_COUNT_OFFSET[AXI_ADDR_WIDTH - 1:2])) begin
						v_addr_hit = 1'b1;
						s_nsb_config_transformation_wait_count_strobe_r <= 1'b1;
						if (s_axi_wstrb_reg_r[0])
							s_reg_nsb_config_transformation_wait_count_count_r[0] <= s_axi_wdata_reg_r[0];
						if (s_axi_wstrb_reg_r[0])
							s_reg_nsb_config_transformation_wait_count_count_r[1] <= s_axi_wdata_reg_r[1];
						if (s_axi_wstrb_reg_r[0])
							s_reg_nsb_config_transformation_wait_count_count_r[2] <= s_axi_wdata_reg_r[2];
						if (s_axi_wstrb_reg_r[0])
							s_reg_nsb_config_transformation_wait_count_count_r[3] <= s_axi_wdata_reg_r[3];
						if (s_axi_wstrb_reg_r[0])
							s_reg_nsb_config_transformation_wait_count_count_r[4] <= s_axi_wdata_reg_r[4];
						if (s_axi_wstrb_reg_r[0])
							s_reg_nsb_config_transformation_wait_count_count_r[5] <= s_axi_wdata_reg_r[5];
					end
					if (s_axi_awaddr_reg_r[AXI_ADDR_WIDTH - 1:2] == (BASEADDR[AXI_ADDR_WIDTH - 1:2] + node_scoreboard_regbank_regs_pkg_LAYER_CONFIG_IN_FEATURES_OFFSET[AXI_ADDR_WIDTH - 1:2])) begin
						v_addr_hit = 1'b1;
						s_layer_config_in_features_strobe_r <= 1'b1;
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_in_features_count_r[0] <= s_axi_wdata_reg_r[0];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_in_features_count_r[1] <= s_axi_wdata_reg_r[1];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_in_features_count_r[2] <= s_axi_wdata_reg_r[2];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_in_features_count_r[3] <= s_axi_wdata_reg_r[3];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_in_features_count_r[4] <= s_axi_wdata_reg_r[4];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_in_features_count_r[5] <= s_axi_wdata_reg_r[5];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_in_features_count_r[6] <= s_axi_wdata_reg_r[6];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_in_features_count_r[7] <= s_axi_wdata_reg_r[7];
						if (s_axi_wstrb_reg_r[1])
							s_reg_layer_config_in_features_count_r[8] <= s_axi_wdata_reg_r[8];
						if (s_axi_wstrb_reg_r[1])
							s_reg_layer_config_in_features_count_r[9] <= s_axi_wdata_reg_r[9];
					end
					if (s_axi_awaddr_reg_r[AXI_ADDR_WIDTH - 1:2] == (BASEADDR[AXI_ADDR_WIDTH - 1:2] + node_scoreboard_regbank_regs_pkg_LAYER_CONFIG_OUT_FEATURES_OFFSET[AXI_ADDR_WIDTH - 1:2])) begin
						v_addr_hit = 1'b1;
						s_layer_config_out_features_strobe_r <= 1'b1;
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_out_features_count_r[0] <= s_axi_wdata_reg_r[0];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_out_features_count_r[1] <= s_axi_wdata_reg_r[1];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_out_features_count_r[2] <= s_axi_wdata_reg_r[2];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_out_features_count_r[3] <= s_axi_wdata_reg_r[3];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_out_features_count_r[4] <= s_axi_wdata_reg_r[4];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_out_features_count_r[5] <= s_axi_wdata_reg_r[5];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_out_features_count_r[6] <= s_axi_wdata_reg_r[6];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_out_features_count_r[7] <= s_axi_wdata_reg_r[7];
						if (s_axi_wstrb_reg_r[1])
							s_reg_layer_config_out_features_count_r[8] <= s_axi_wdata_reg_r[8];
						if (s_axi_wstrb_reg_r[1])
							s_reg_layer_config_out_features_count_r[9] <= s_axi_wdata_reg_r[9];
					end
					if (s_axi_awaddr_reg_r[AXI_ADDR_WIDTH - 1:2] == (BASEADDR[AXI_ADDR_WIDTH - 1:2] + node_scoreboard_regbank_regs_pkg_LAYER_CONFIG_WEIGHTS_PRECISION_OFFSET[AXI_ADDR_WIDTH - 1:2])) begin
						v_addr_hit = 1'b1;
						s_layer_config_weights_precision_strobe_r <= 1'b1;
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_weights_precision_precision_r[0] <= s_axi_wdata_reg_r[0];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_weights_precision_precision_r[1] <= s_axi_wdata_reg_r[1];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_weights_precision_precision_r[2] <= s_axi_wdata_reg_r[2];
					end
					if (s_axi_awaddr_reg_r[AXI_ADDR_WIDTH - 1:2] == (BASEADDR[AXI_ADDR_WIDTH - 1:2] + node_scoreboard_regbank_regs_pkg_LAYER_CONFIG_ACTIVATIONS_PRECISION_OFFSET[AXI_ADDR_WIDTH - 1:2])) begin
						v_addr_hit = 1'b1;
						s_layer_config_activations_precision_strobe_r <= 1'b1;
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_activations_precision_precision_r[0] <= s_axi_wdata_reg_r[0];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_activations_precision_precision_r[1] <= s_axi_wdata_reg_r[1];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_activations_precision_precision_r[2] <= s_axi_wdata_reg_r[2];
					end
					if (s_axi_awaddr_reg_r[AXI_ADDR_WIDTH - 1:2] == (BASEADDR[AXI_ADDR_WIDTH - 1:2] + node_scoreboard_regbank_regs_pkg_LAYER_CONFIG_ADJACENCY_LIST_ADDRESS_LSB_OFFSET[AXI_ADDR_WIDTH - 1:2])) begin
						v_addr_hit = 1'b1;
						s_layer_config_adjacency_list_address_lsb_strobe_r <= 1'b1;
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_adjacency_list_address_lsb_lsb_r[0] <= s_axi_wdata_reg_r[0];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_adjacency_list_address_lsb_lsb_r[1] <= s_axi_wdata_reg_r[1];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_adjacency_list_address_lsb_lsb_r[2] <= s_axi_wdata_reg_r[2];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_adjacency_list_address_lsb_lsb_r[3] <= s_axi_wdata_reg_r[3];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_adjacency_list_address_lsb_lsb_r[4] <= s_axi_wdata_reg_r[4];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_adjacency_list_address_lsb_lsb_r[5] <= s_axi_wdata_reg_r[5];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_adjacency_list_address_lsb_lsb_r[6] <= s_axi_wdata_reg_r[6];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_adjacency_list_address_lsb_lsb_r[7] <= s_axi_wdata_reg_r[7];
						if (s_axi_wstrb_reg_r[1])
							s_reg_layer_config_adjacency_list_address_lsb_lsb_r[8] <= s_axi_wdata_reg_r[8];
						if (s_axi_wstrb_reg_r[1])
							s_reg_layer_config_adjacency_list_address_lsb_lsb_r[9] <= s_axi_wdata_reg_r[9];
						if (s_axi_wstrb_reg_r[1])
							s_reg_layer_config_adjacency_list_address_lsb_lsb_r[10] <= s_axi_wdata_reg_r[10];
						if (s_axi_wstrb_reg_r[1])
							s_reg_layer_config_adjacency_list_address_lsb_lsb_r[11] <= s_axi_wdata_reg_r[11];
						if (s_axi_wstrb_reg_r[1])
							s_reg_layer_config_adjacency_list_address_lsb_lsb_r[12] <= s_axi_wdata_reg_r[12];
						if (s_axi_wstrb_reg_r[1])
							s_reg_layer_config_adjacency_list_address_lsb_lsb_r[13] <= s_axi_wdata_reg_r[13];
						if (s_axi_wstrb_reg_r[1])
							s_reg_layer_config_adjacency_list_address_lsb_lsb_r[14] <= s_axi_wdata_reg_r[14];
						if (s_axi_wstrb_reg_r[1])
							s_reg_layer_config_adjacency_list_address_lsb_lsb_r[15] <= s_axi_wdata_reg_r[15];
						if (s_axi_wstrb_reg_r[2])
							s_reg_layer_config_adjacency_list_address_lsb_lsb_r[16] <= s_axi_wdata_reg_r[16];
						if (s_axi_wstrb_reg_r[2])
							s_reg_layer_config_adjacency_list_address_lsb_lsb_r[17] <= s_axi_wdata_reg_r[17];
						if (s_axi_wstrb_reg_r[2])
							s_reg_layer_config_adjacency_list_address_lsb_lsb_r[18] <= s_axi_wdata_reg_r[18];
						if (s_axi_wstrb_reg_r[2])
							s_reg_layer_config_adjacency_list_address_lsb_lsb_r[19] <= s_axi_wdata_reg_r[19];
						if (s_axi_wstrb_reg_r[2])
							s_reg_layer_config_adjacency_list_address_lsb_lsb_r[20] <= s_axi_wdata_reg_r[20];
						if (s_axi_wstrb_reg_r[2])
							s_reg_layer_config_adjacency_list_address_lsb_lsb_r[21] <= s_axi_wdata_reg_r[21];
						if (s_axi_wstrb_reg_r[2])
							s_reg_layer_config_adjacency_list_address_lsb_lsb_r[22] <= s_axi_wdata_reg_r[22];
						if (s_axi_wstrb_reg_r[2])
							s_reg_layer_config_adjacency_list_address_lsb_lsb_r[23] <= s_axi_wdata_reg_r[23];
						if (s_axi_wstrb_reg_r[3])
							s_reg_layer_config_adjacency_list_address_lsb_lsb_r[24] <= s_axi_wdata_reg_r[24];
						if (s_axi_wstrb_reg_r[3])
							s_reg_layer_config_adjacency_list_address_lsb_lsb_r[25] <= s_axi_wdata_reg_r[25];
						if (s_axi_wstrb_reg_r[3])
							s_reg_layer_config_adjacency_list_address_lsb_lsb_r[26] <= s_axi_wdata_reg_r[26];
						if (s_axi_wstrb_reg_r[3])
							s_reg_layer_config_adjacency_list_address_lsb_lsb_r[27] <= s_axi_wdata_reg_r[27];
						if (s_axi_wstrb_reg_r[3])
							s_reg_layer_config_adjacency_list_address_lsb_lsb_r[28] <= s_axi_wdata_reg_r[28];
						if (s_axi_wstrb_reg_r[3])
							s_reg_layer_config_adjacency_list_address_lsb_lsb_r[29] <= s_axi_wdata_reg_r[29];
						if (s_axi_wstrb_reg_r[3])
							s_reg_layer_config_adjacency_list_address_lsb_lsb_r[30] <= s_axi_wdata_reg_r[30];
						if (s_axi_wstrb_reg_r[3])
							s_reg_layer_config_adjacency_list_address_lsb_lsb_r[31] <= s_axi_wdata_reg_r[31];
					end
					if (s_axi_awaddr_reg_r[AXI_ADDR_WIDTH - 1:2] == (BASEADDR[AXI_ADDR_WIDTH - 1:2] + node_scoreboard_regbank_regs_pkg_LAYER_CONFIG_ADJACENCY_LIST_ADDRESS_MSB_OFFSET[AXI_ADDR_WIDTH - 1:2])) begin
						v_addr_hit = 1'b1;
						s_layer_config_adjacency_list_address_msb_strobe_r <= 1'b1;
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_adjacency_list_address_msb_msb_r[0] <= s_axi_wdata_reg_r[0];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_adjacency_list_address_msb_msb_r[1] <= s_axi_wdata_reg_r[1];
					end
					begin : sv2v_autoblock_30
						reg signed [31:0] i;
						for (i = 0; i < 32; i = i + 1)
							if (s_axi_awaddr_reg_r[AXI_ADDR_WIDTH - 1:2] == ((BASEADDR[AXI_ADDR_WIDTH - 1:2] + node_scoreboard_regbank_regs_pkg_NSB_NODESLOT_AGGREGATION_FUNCTION_OFFSET[AXI_ADDR_WIDTH - 1:2]) + sv2v_cast_5219A_signed(i * 1))) begin
								v_addr_hit = 1'b1;
								s_nsb_nodeslot_aggregation_function_strobe_r[i] <= 1'b1;
								if (s_axi_wstrb_reg_r[0])
									s_reg_nsb_nodeslot_aggregation_function_value_r[i * 2] <= s_axi_wdata_reg_r[0];
								if (s_axi_wstrb_reg_r[0])
									s_reg_nsb_nodeslot_aggregation_function_value_r[(i * 2) + 1] <= s_axi_wdata_reg_r[1];
							end
					end
					begin : sv2v_autoblock_31
						reg signed [31:0] i;
						for (i = 0; i < 32; i = i + 1)
							if (s_axi_awaddr_reg_r[AXI_ADDR_WIDTH - 1:2] == ((BASEADDR[AXI_ADDR_WIDTH - 1:2] + node_scoreboard_regbank_regs_pkg_NSB_NODESLOT_SCALE_FACTORS_ADDRESS_LSB_OFFSET[AXI_ADDR_WIDTH - 1:2]) + sv2v_cast_5219A_signed(i * 1))) begin
								v_addr_hit = 1'b1;
								s_nsb_nodeslot_scale_factors_address_lsb_strobe_r[i] <= 1'b1;
								if (s_axi_wstrb_reg_r[0])
									s_reg_nsb_nodeslot_scale_factors_address_lsb_value_r[i * 32] <= s_axi_wdata_reg_r[0];
								if (s_axi_wstrb_reg_r[0])
									s_reg_nsb_nodeslot_scale_factors_address_lsb_value_r[(i * 32) + 1] <= s_axi_wdata_reg_r[1];
								if (s_axi_wstrb_reg_r[0])
									s_reg_nsb_nodeslot_scale_factors_address_lsb_value_r[(i * 32) + 2] <= s_axi_wdata_reg_r[2];
								if (s_axi_wstrb_reg_r[0])
									s_reg_nsb_nodeslot_scale_factors_address_lsb_value_r[(i * 32) + 3] <= s_axi_wdata_reg_r[3];
								if (s_axi_wstrb_reg_r[0])
									s_reg_nsb_nodeslot_scale_factors_address_lsb_value_r[(i * 32) + 4] <= s_axi_wdata_reg_r[4];
								if (s_axi_wstrb_reg_r[0])
									s_reg_nsb_nodeslot_scale_factors_address_lsb_value_r[(i * 32) + 5] <= s_axi_wdata_reg_r[5];
								if (s_axi_wstrb_reg_r[0])
									s_reg_nsb_nodeslot_scale_factors_address_lsb_value_r[(i * 32) + 6] <= s_axi_wdata_reg_r[6];
								if (s_axi_wstrb_reg_r[0])
									s_reg_nsb_nodeslot_scale_factors_address_lsb_value_r[(i * 32) + 7] <= s_axi_wdata_reg_r[7];
								if (s_axi_wstrb_reg_r[1])
									s_reg_nsb_nodeslot_scale_factors_address_lsb_value_r[(i * 32) + 8] <= s_axi_wdata_reg_r[8];
								if (s_axi_wstrb_reg_r[1])
									s_reg_nsb_nodeslot_scale_factors_address_lsb_value_r[(i * 32) + 9] <= s_axi_wdata_reg_r[9];
								if (s_axi_wstrb_reg_r[1])
									s_reg_nsb_nodeslot_scale_factors_address_lsb_value_r[(i * 32) + 10] <= s_axi_wdata_reg_r[10];
								if (s_axi_wstrb_reg_r[1])
									s_reg_nsb_nodeslot_scale_factors_address_lsb_value_r[(i * 32) + 11] <= s_axi_wdata_reg_r[11];
								if (s_axi_wstrb_reg_r[1])
									s_reg_nsb_nodeslot_scale_factors_address_lsb_value_r[(i * 32) + 12] <= s_axi_wdata_reg_r[12];
								if (s_axi_wstrb_reg_r[1])
									s_reg_nsb_nodeslot_scale_factors_address_lsb_value_r[(i * 32) + 13] <= s_axi_wdata_reg_r[13];
								if (s_axi_wstrb_reg_r[1])
									s_reg_nsb_nodeslot_scale_factors_address_lsb_value_r[(i * 32) + 14] <= s_axi_wdata_reg_r[14];
								if (s_axi_wstrb_reg_r[1])
									s_reg_nsb_nodeslot_scale_factors_address_lsb_value_r[(i * 32) + 15] <= s_axi_wdata_reg_r[15];
								if (s_axi_wstrb_reg_r[2])
									s_reg_nsb_nodeslot_scale_factors_address_lsb_value_r[(i * 32) + 16] <= s_axi_wdata_reg_r[16];
								if (s_axi_wstrb_reg_r[2])
									s_reg_nsb_nodeslot_scale_factors_address_lsb_value_r[(i * 32) + 17] <= s_axi_wdata_reg_r[17];
								if (s_axi_wstrb_reg_r[2])
									s_reg_nsb_nodeslot_scale_factors_address_lsb_value_r[(i * 32) + 18] <= s_axi_wdata_reg_r[18];
								if (s_axi_wstrb_reg_r[2])
									s_reg_nsb_nodeslot_scale_factors_address_lsb_value_r[(i * 32) + 19] <= s_axi_wdata_reg_r[19];
								if (s_axi_wstrb_reg_r[2])
									s_reg_nsb_nodeslot_scale_factors_address_lsb_value_r[(i * 32) + 20] <= s_axi_wdata_reg_r[20];
								if (s_axi_wstrb_reg_r[2])
									s_reg_nsb_nodeslot_scale_factors_address_lsb_value_r[(i * 32) + 21] <= s_axi_wdata_reg_r[21];
								if (s_axi_wstrb_reg_r[2])
									s_reg_nsb_nodeslot_scale_factors_address_lsb_value_r[(i * 32) + 22] <= s_axi_wdata_reg_r[22];
								if (s_axi_wstrb_reg_r[2])
									s_reg_nsb_nodeslot_scale_factors_address_lsb_value_r[(i * 32) + 23] <= s_axi_wdata_reg_r[23];
								if (s_axi_wstrb_reg_r[3])
									s_reg_nsb_nodeslot_scale_factors_address_lsb_value_r[(i * 32) + 24] <= s_axi_wdata_reg_r[24];
								if (s_axi_wstrb_reg_r[3])
									s_reg_nsb_nodeslot_scale_factors_address_lsb_value_r[(i * 32) + 25] <= s_axi_wdata_reg_r[25];
								if (s_axi_wstrb_reg_r[3])
									s_reg_nsb_nodeslot_scale_factors_address_lsb_value_r[(i * 32) + 26] <= s_axi_wdata_reg_r[26];
								if (s_axi_wstrb_reg_r[3])
									s_reg_nsb_nodeslot_scale_factors_address_lsb_value_r[(i * 32) + 27] <= s_axi_wdata_reg_r[27];
								if (s_axi_wstrb_reg_r[3])
									s_reg_nsb_nodeslot_scale_factors_address_lsb_value_r[(i * 32) + 28] <= s_axi_wdata_reg_r[28];
								if (s_axi_wstrb_reg_r[3])
									s_reg_nsb_nodeslot_scale_factors_address_lsb_value_r[(i * 32) + 29] <= s_axi_wdata_reg_r[29];
								if (s_axi_wstrb_reg_r[3])
									s_reg_nsb_nodeslot_scale_factors_address_lsb_value_r[(i * 32) + 30] <= s_axi_wdata_reg_r[30];
								if (s_axi_wstrb_reg_r[3])
									s_reg_nsb_nodeslot_scale_factors_address_lsb_value_r[(i * 32) + 31] <= s_axi_wdata_reg_r[31];
							end
					end
					begin : sv2v_autoblock_32
						reg signed [31:0] i;
						for (i = 0; i < 32; i = i + 1)
							if (s_axi_awaddr_reg_r[AXI_ADDR_WIDTH - 1:2] == ((BASEADDR[AXI_ADDR_WIDTH - 1:2] + node_scoreboard_regbank_regs_pkg_NSB_NODESLOT_SCALE_FACTORS_ADDRESS_MSB_OFFSET[AXI_ADDR_WIDTH - 1:2]) + sv2v_cast_5219A_signed(i * 1))) begin
								v_addr_hit = 1'b1;
								s_nsb_nodeslot_scale_factors_address_msb_strobe_r[i] <= 1'b1;
								if (s_axi_wstrb_reg_r[0])
									s_reg_nsb_nodeslot_scale_factors_address_msb_value_r[i * 2] <= s_axi_wdata_reg_r[0];
								if (s_axi_wstrb_reg_r[0])
									s_reg_nsb_nodeslot_scale_factors_address_msb_value_r[(i * 2) + 1] <= s_axi_wdata_reg_r[1];
							end
					end
					if (!v_addr_hit) begin
						s_axi_bresp_r <= AXI_SLVERR;
						$warning("AWADDR decode error");
					end
					v_state_r <= 32'd4;
				end
				32'd4:
					if (s_axi_bready) begin
						s_axi_bvalid_r <= 1'b0;
						v_state_r <= 32'd0;
					end
			endcase
		end
	end
	assign s_axi_awready = s_axi_awready_r;
	assign s_axi_wready = s_axi_wready_r;
	assign s_axi_bvalid = s_axi_bvalid_r;
	assign s_axi_bresp = s_axi_bresp_r;
	assign s_axi_arready = s_axi_arready_r;
	assign s_axi_rvalid = s_axi_rvalid_r;
	assign s_axi_rresp = s_axi_rresp_r;
	assign s_axi_rdata = s_axi_rdata_r;
	assign layer_config_weights_address_lsb_strobe = s_layer_config_weights_address_lsb_strobe_r;
	assign layer_config_weights_address_lsb_lsb = s_reg_layer_config_weights_address_lsb_lsb_r;
	assign layer_config_weights_address_msb_strobe = s_layer_config_weights_address_msb_strobe_r;
	assign layer_config_weights_address_msb_msb = s_reg_layer_config_weights_address_msb_msb_r;
	assign ctrl_fetch_layer_weights_strobe = s_ctrl_fetch_layer_weights_strobe_r;
	assign ctrl_fetch_layer_weights_fetch = s_reg_ctrl_fetch_layer_weights_fetch_r;
	assign ctrl_fetch_layer_weights_done_strobe = s_ctrl_fetch_layer_weights_done_strobe_r;
	assign ctrl_fetch_layer_weights_done_ack_strobe = s_ctrl_fetch_layer_weights_done_ack_strobe_r;
	assign ctrl_fetch_layer_weights_done_ack_ack = s_reg_ctrl_fetch_layer_weights_done_ack_ack_r;
	assign layer_config_in_messages_address_lsb_strobe = s_layer_config_in_messages_address_lsb_strobe_r;
	assign layer_config_in_messages_address_lsb_lsb = s_reg_layer_config_in_messages_address_lsb_lsb_r;
	assign layer_config_in_messages_address_msb_strobe = s_layer_config_in_messages_address_msb_strobe_r;
	assign layer_config_in_messages_address_msb_msb = s_reg_layer_config_in_messages_address_msb_msb_r;
	assign layer_config_out_messages_address_lsb_strobe = s_layer_config_out_messages_address_lsb_strobe_r;
	assign layer_config_out_messages_address_lsb_lsb = s_reg_layer_config_out_messages_address_lsb_lsb_r;
	assign layer_config_out_messages_address_msb_strobe = s_layer_config_out_messages_address_msb_strobe_r;
	assign layer_config_out_messages_address_msb_msb = s_reg_layer_config_out_messages_address_msb_msb_r;
	assign nsb_nodeslot_neighbour_count_strobe = s_nsb_nodeslot_neighbour_count_strobe_r;
	assign nsb_nodeslot_neighbour_count_count = s_reg_nsb_nodeslot_neighbour_count_count_r;
	assign nsb_nodeslot_node_id_strobe = s_nsb_nodeslot_node_id_strobe_r;
	assign nsb_nodeslot_node_id_id = s_reg_nsb_nodeslot_node_id_id_r;
	assign nsb_nodeslot_node_state_strobe = s_nsb_nodeslot_node_state_strobe_r;
	assign nsb_nodeslot_precision_strobe = s_nsb_nodeslot_precision_strobe_r;
	assign nsb_nodeslot_precision_precision = s_reg_nsb_nodeslot_precision_precision_r;
	assign nsb_nodeslot_adjacency_list_address_lsb_strobe = s_nsb_nodeslot_adjacency_list_address_lsb_strobe_r;
	assign nsb_nodeslot_adjacency_list_address_lsb_lsb = s_reg_nsb_nodeslot_adjacency_list_address_lsb_lsb_r;
	assign nsb_nodeslot_adjacency_list_address_msb_strobe = s_nsb_nodeslot_adjacency_list_address_msb_strobe_r;
	assign nsb_nodeslot_adjacency_list_address_msb_msb = s_reg_nsb_nodeslot_adjacency_list_address_msb_msb_r;
	assign nsb_nodeslot_out_messages_address_lsb_strobe = s_nsb_nodeslot_out_messages_address_lsb_strobe_r;
	assign nsb_nodeslot_out_messages_address_lsb_lsb = s_reg_nsb_nodeslot_out_messages_address_lsb_lsb_r;
	assign nsb_nodeslot_out_messages_address_msb_strobe = s_nsb_nodeslot_out_messages_address_msb_strobe_r;
	assign nsb_nodeslot_out_messages_address_msb_msb = s_reg_nsb_nodeslot_out_messages_address_msb_msb_r;
	assign nsb_nodeslot_config_make_valid_msb_strobe = s_nsb_nodeslot_config_make_valid_msb_strobe_r;
	assign nsb_nodeslot_config_make_valid_msb_make_valid = s_reg_nsb_nodeslot_config_make_valid_msb_make_valid_r;
	assign nsb_nodeslot_config_make_valid_lsb_strobe = s_nsb_nodeslot_config_make_valid_lsb_strobe_r;
	assign nsb_nodeslot_config_make_valid_lsb_make_valid = s_reg_nsb_nodeslot_config_make_valid_lsb_make_valid_r;
	assign nsb_config_aggregation_wait_count_strobe = s_nsb_config_aggregation_wait_count_strobe_r;
	assign nsb_config_aggregation_wait_count_count = s_reg_nsb_config_aggregation_wait_count_count_r;
	assign nsb_config_transformation_wait_count_strobe = s_nsb_config_transformation_wait_count_strobe_r;
	assign nsb_config_transformation_wait_count_count = s_reg_nsb_config_transformation_wait_count_count_r;
	assign nsb_nodeslot_allocated_fetch_tag_strobe = s_nsb_nodeslot_allocated_fetch_tag_strobe_r;
	assign layer_config_in_features_strobe = s_layer_config_in_features_strobe_r;
	assign layer_config_in_features_count = s_reg_layer_config_in_features_count_r;
	assign layer_config_out_features_strobe = s_layer_config_out_features_strobe_r;
	assign layer_config_out_features_count = s_reg_layer_config_out_features_count_r;
	assign layer_config_weights_precision_strobe = s_layer_config_weights_precision_strobe_r;
	assign layer_config_weights_precision_precision = s_reg_layer_config_weights_precision_precision_r;
	assign layer_config_activations_precision_strobe = s_layer_config_activations_precision_strobe_r;
	assign layer_config_activations_precision_precision = s_reg_layer_config_activations_precision_precision_r;
	assign layer_config_adjacency_list_address_lsb_strobe = s_layer_config_adjacency_list_address_lsb_strobe_r;
	assign layer_config_adjacency_list_address_lsb_lsb = s_reg_layer_config_adjacency_list_address_lsb_lsb_r;
	assign layer_config_adjacency_list_address_msb_strobe = s_layer_config_adjacency_list_address_msb_strobe_r;
	assign layer_config_adjacency_list_address_msb_msb = s_reg_layer_config_adjacency_list_address_msb_msb_r;
	assign nsb_nodeslot_aggregation_function_strobe = s_nsb_nodeslot_aggregation_function_strobe_r;
	assign nsb_nodeslot_aggregation_function_value = s_reg_nsb_nodeslot_aggregation_function_value_r;
	assign nsb_nodeslot_scale_factors_address_lsb_strobe = s_nsb_nodeslot_scale_factors_address_lsb_strobe_r;
	assign nsb_nodeslot_scale_factors_address_lsb_value = s_reg_nsb_nodeslot_scale_factors_address_lsb_value_r;
	assign nsb_nodeslot_scale_factors_address_msb_strobe = s_nsb_nodeslot_scale_factors_address_msb_strobe_r;
	assign nsb_nodeslot_scale_factors_address_msb_value = s_reg_nsb_nodeslot_scale_factors_address_msb_value_r;
endmodule
`resetall
`default_nettype none
module prefetcher_regbank_regs (
	axi_aclk,
	axi_aresetn,
	s_axi_awaddr,
	s_axi_awprot,
	s_axi_awvalid,
	s_axi_awready,
	s_axi_wdata,
	s_axi_wstrb,
	s_axi_wvalid,
	s_axi_wready,
	s_axi_araddr,
	s_axi_arprot,
	s_axi_arvalid,
	s_axi_arready,
	s_axi_rdata,
	s_axi_rresp,
	s_axi_rvalid,
	s_axi_rready,
	s_axi_bresp,
	s_axi_bvalid,
	s_axi_bready,
	layer_config_in_features_strobe,
	layer_config_in_features_count,
	layer_config_out_features_strobe,
	layer_config_out_features_count,
	layer_config_in_messages_address_lsb_strobe,
	layer_config_in_messages_address_lsb_value,
	layer_config_in_messages_address_msb_strobe,
	layer_config_in_messages_address_msb_value,
	layer_config_adjacency_list_address_lsb_strobe,
	layer_config_adjacency_list_address_lsb_value,
	layer_config_adjacency_list_address_msb_strobe,
	layer_config_adjacency_list_address_msb_value,
	layer_config_weights_address_lsb_strobe,
	layer_config_weights_address_lsb_value,
	layer_config_weights_address_msb_strobe,
	layer_config_weights_address_msb_value,
	layer_config_scale_factors_address_lsb_strobe,
	layer_config_scale_factors_address_lsb_value,
	layer_config_scale_factors_address_msb_strobe,
	layer_config_scale_factors_address_msb_value
);
	parameter AXI_ADDR_WIDTH = 32;
	parameter [31:0] BASEADDR = 32'hc0000000;
	input wire axi_aclk;
	input wire axi_aresetn;
	input wire [AXI_ADDR_WIDTH - 1:0] s_axi_awaddr;
	input wire [2:0] s_axi_awprot;
	input wire s_axi_awvalid;
	output wire s_axi_awready;
	input wire [31:0] s_axi_wdata;
	input wire [3:0] s_axi_wstrb;
	input wire s_axi_wvalid;
	output wire s_axi_wready;
	input wire [AXI_ADDR_WIDTH - 1:0] s_axi_araddr;
	input wire [2:0] s_axi_arprot;
	input wire s_axi_arvalid;
	output wire s_axi_arready;
	output wire [31:0] s_axi_rdata;
	output wire [1:0] s_axi_rresp;
	output wire s_axi_rvalid;
	input wire s_axi_rready;
	output wire [1:0] s_axi_bresp;
	output wire s_axi_bvalid;
	input wire s_axi_bready;
	output wire layer_config_in_features_strobe;
	output wire [9:0] layer_config_in_features_count;
	output wire layer_config_out_features_strobe;
	output wire [9:0] layer_config_out_features_count;
	output wire layer_config_in_messages_address_lsb_strobe;
	output wire [31:0] layer_config_in_messages_address_lsb_value;
	output wire layer_config_in_messages_address_msb_strobe;
	output wire [1:0] layer_config_in_messages_address_msb_value;
	output wire layer_config_adjacency_list_address_lsb_strobe;
	output wire [31:0] layer_config_adjacency_list_address_lsb_value;
	output wire layer_config_adjacency_list_address_msb_strobe;
	output wire [1:0] layer_config_adjacency_list_address_msb_value;
	output wire layer_config_weights_address_lsb_strobe;
	output wire [31:0] layer_config_weights_address_lsb_value;
	output wire layer_config_weights_address_msb_strobe;
	output wire [1:0] layer_config_weights_address_msb_value;
	output wire layer_config_scale_factors_address_lsb_strobe;
	output wire [31:0] layer_config_scale_factors_address_lsb_value;
	output wire layer_config_scale_factors_address_msb_strobe;
	output wire [1:0] layer_config_scale_factors_address_msb_value;
	localparam [1:0] AXI_OKAY = 2'b00;
	localparam [1:0] AXI_SLVERR = 2'b10;
	reg s_axi_awready_r;
	reg s_axi_wready_r;
	reg [AXI_ADDR_WIDTH - 1:0] s_axi_awaddr_reg_r;
	reg s_axi_bvalid_r;
	reg [1:0] s_axi_bresp_r;
	reg s_axi_arready_r;
	reg [AXI_ADDR_WIDTH - 1:0] s_axi_araddr_reg_r;
	reg s_axi_rvalid_r;
	reg [1:0] s_axi_rresp_r;
	reg [31:0] s_axi_wdata_reg_r;
	reg [3:0] s_axi_wstrb_reg_r;
	reg [31:0] s_axi_rdata_r;
	reg s_layer_config_in_features_strobe_r;
	reg [9:0] s_reg_layer_config_in_features_count_r;
	reg s_layer_config_out_features_strobe_r;
	reg [9:0] s_reg_layer_config_out_features_count_r;
	reg s_layer_config_in_messages_address_lsb_strobe_r;
	reg [31:0] s_reg_layer_config_in_messages_address_lsb_value_r;
	reg s_layer_config_in_messages_address_msb_strobe_r;
	reg [1:0] s_reg_layer_config_in_messages_address_msb_value_r;
	reg s_layer_config_adjacency_list_address_lsb_strobe_r;
	reg [31:0] s_reg_layer_config_adjacency_list_address_lsb_value_r;
	reg s_layer_config_adjacency_list_address_msb_strobe_r;
	reg [1:0] s_reg_layer_config_adjacency_list_address_msb_value_r;
	reg s_layer_config_weights_address_lsb_strobe_r;
	reg [31:0] s_reg_layer_config_weights_address_lsb_value_r;
	reg s_layer_config_weights_address_msb_strobe_r;
	reg [1:0] s_reg_layer_config_weights_address_msb_value_r;
	reg s_layer_config_scale_factors_address_lsb_strobe_r;
	reg [31:0] s_reg_layer_config_scale_factors_address_lsb_value_r;
	reg s_layer_config_scale_factors_address_msb_strobe_r;
	reg [1:0] s_reg_layer_config_scale_factors_address_msb_value_r;
	localparam MAX_MEMORY_LATENCY = 5;
	localparam [31:0] prefetcher_regbank_regs_pkg_LAYER_CONFIG_ADJACENCY_LIST_ADDRESS_LSB_OFFSET = 32'h00000010;
	localparam [31:0] prefetcher_regbank_regs_pkg_LAYER_CONFIG_ADJACENCY_LIST_ADDRESS_MSB_OFFSET = 32'h00000014;
	localparam [31:0] prefetcher_regbank_regs_pkg_LAYER_CONFIG_IN_FEATURES_OFFSET = 32'h00000000;
	localparam [31:0] prefetcher_regbank_regs_pkg_LAYER_CONFIG_IN_MESSAGES_ADDRESS_LSB_OFFSET = 32'h00000008;
	localparam [31:0] prefetcher_regbank_regs_pkg_LAYER_CONFIG_IN_MESSAGES_ADDRESS_MSB_OFFSET = 32'h0000000c;
	localparam [31:0] prefetcher_regbank_regs_pkg_LAYER_CONFIG_OUT_FEATURES_OFFSET = 32'h00000004;
	localparam [31:0] prefetcher_regbank_regs_pkg_LAYER_CONFIG_SCALE_FACTORS_ADDRESS_LSB_OFFSET = 32'h00000020;
	localparam [31:0] prefetcher_regbank_regs_pkg_LAYER_CONFIG_SCALE_FACTORS_ADDRESS_MSB_OFFSET = 32'h00000024;
	localparam [31:0] prefetcher_regbank_regs_pkg_LAYER_CONFIG_WEIGHTS_ADDRESS_LSB_OFFSET = 32'h00000018;
	localparam [31:0] prefetcher_regbank_regs_pkg_LAYER_CONFIG_WEIGHTS_ADDRESS_MSB_OFFSET = 32'h0000001c;
	always @(posedge axi_aclk or negedge axi_aresetn) begin : read_fsm
		reg [31:0] v_state_r;
		reg [31:0] v_rdata_r;
		reg [1:0] v_rresp_r;
		reg [2:0] v_mem_wait_count_r;
		reg v_addr_hit;
		reg [AXI_ADDR_WIDTH - 1:0] v_mem_addr;
		if (~axi_aresetn) begin
			v_state_r <= 32'd0;
			v_rdata_r <= 1'sb0;
			v_rresp_r <= 1'sb0;
			v_mem_wait_count_r <= 1'sb0;
			s_axi_arready_r <= 1'sb0;
			s_axi_rvalid_r <= 1'sb0;
			s_axi_rresp_r <= 1'sb0;
			s_axi_araddr_reg_r <= 1'sb0;
			s_axi_rdata_r <= 1'sb0;
		end
		else begin
			s_axi_arready_r <= 1'b0;
			case (v_state_r)
				32'd0:
					if (s_axi_arvalid) begin
						s_axi_araddr_reg_r <= s_axi_araddr;
						s_axi_arready_r <= 1'b1;
						v_state_r <= 32'd1;
					end
				32'd1: begin
					v_addr_hit = 1'b0;
					v_rdata_r <= 1'sb0;
					if (s_axi_araddr_reg_r[AXI_ADDR_WIDTH - 1:2] == (BASEADDR[AXI_ADDR_WIDTH - 1:2] + prefetcher_regbank_regs_pkg_LAYER_CONFIG_IN_FEATURES_OFFSET[AXI_ADDR_WIDTH - 1:2])) begin
						v_addr_hit = 1'b1;
						v_rdata_r[9:0] <= s_reg_layer_config_in_features_count_r;
						v_state_r <= 32'd3;
					end
					if (s_axi_araddr_reg_r[AXI_ADDR_WIDTH - 1:2] == (BASEADDR[AXI_ADDR_WIDTH - 1:2] + prefetcher_regbank_regs_pkg_LAYER_CONFIG_OUT_FEATURES_OFFSET[AXI_ADDR_WIDTH - 1:2])) begin
						v_addr_hit = 1'b1;
						v_rdata_r[9:0] <= s_reg_layer_config_out_features_count_r;
						v_state_r <= 32'd3;
					end
					if (s_axi_araddr_reg_r[AXI_ADDR_WIDTH - 1:2] == (BASEADDR[AXI_ADDR_WIDTH - 1:2] + prefetcher_regbank_regs_pkg_LAYER_CONFIG_IN_MESSAGES_ADDRESS_LSB_OFFSET[AXI_ADDR_WIDTH - 1:2])) begin
						v_addr_hit = 1'b1;
						v_rdata_r[31:0] <= s_reg_layer_config_in_messages_address_lsb_value_r;
						v_state_r <= 32'd3;
					end
					if (s_axi_araddr_reg_r[AXI_ADDR_WIDTH - 1:2] == (BASEADDR[AXI_ADDR_WIDTH - 1:2] + prefetcher_regbank_regs_pkg_LAYER_CONFIG_IN_MESSAGES_ADDRESS_MSB_OFFSET[AXI_ADDR_WIDTH - 1:2])) begin
						v_addr_hit = 1'b1;
						v_rdata_r[1:0] <= s_reg_layer_config_in_messages_address_msb_value_r;
						v_state_r <= 32'd3;
					end
					if (s_axi_araddr_reg_r[AXI_ADDR_WIDTH - 1:2] == (BASEADDR[AXI_ADDR_WIDTH - 1:2] + prefetcher_regbank_regs_pkg_LAYER_CONFIG_ADJACENCY_LIST_ADDRESS_LSB_OFFSET[AXI_ADDR_WIDTH - 1:2])) begin
						v_addr_hit = 1'b1;
						v_rdata_r[31:0] <= s_reg_layer_config_adjacency_list_address_lsb_value_r;
						v_state_r <= 32'd3;
					end
					if (s_axi_araddr_reg_r[AXI_ADDR_WIDTH - 1:2] == (BASEADDR[AXI_ADDR_WIDTH - 1:2] + prefetcher_regbank_regs_pkg_LAYER_CONFIG_ADJACENCY_LIST_ADDRESS_MSB_OFFSET[AXI_ADDR_WIDTH - 1:2])) begin
						v_addr_hit = 1'b1;
						v_rdata_r[1:0] <= s_reg_layer_config_adjacency_list_address_msb_value_r;
						v_state_r <= 32'd3;
					end
					if (s_axi_araddr_reg_r[AXI_ADDR_WIDTH - 1:2] == (BASEADDR[AXI_ADDR_WIDTH - 1:2] + prefetcher_regbank_regs_pkg_LAYER_CONFIG_WEIGHTS_ADDRESS_LSB_OFFSET[AXI_ADDR_WIDTH - 1:2])) begin
						v_addr_hit = 1'b1;
						v_rdata_r[31:0] <= s_reg_layer_config_weights_address_lsb_value_r;
						v_state_r <= 32'd3;
					end
					if (s_axi_araddr_reg_r[AXI_ADDR_WIDTH - 1:2] == (BASEADDR[AXI_ADDR_WIDTH - 1:2] + prefetcher_regbank_regs_pkg_LAYER_CONFIG_WEIGHTS_ADDRESS_MSB_OFFSET[AXI_ADDR_WIDTH - 1:2])) begin
						v_addr_hit = 1'b1;
						v_rdata_r[1:0] <= s_reg_layer_config_weights_address_msb_value_r;
						v_state_r <= 32'd3;
					end
					if (s_axi_araddr_reg_r[AXI_ADDR_WIDTH - 1:2] == (BASEADDR[AXI_ADDR_WIDTH - 1:2] + prefetcher_regbank_regs_pkg_LAYER_CONFIG_SCALE_FACTORS_ADDRESS_LSB_OFFSET[AXI_ADDR_WIDTH - 1:2])) begin
						v_addr_hit = 1'b1;
						v_rdata_r[31:0] <= s_reg_layer_config_scale_factors_address_lsb_value_r;
						v_state_r <= 32'd3;
					end
					if (s_axi_araddr_reg_r[AXI_ADDR_WIDTH - 1:2] == (BASEADDR[AXI_ADDR_WIDTH - 1:2] + prefetcher_regbank_regs_pkg_LAYER_CONFIG_SCALE_FACTORS_ADDRESS_MSB_OFFSET[AXI_ADDR_WIDTH - 1:2])) begin
						v_addr_hit = 1'b1;
						v_rdata_r[1:0] <= s_reg_layer_config_scale_factors_address_msb_value_r;
						v_state_r <= 32'd3;
					end
					if (v_addr_hit)
						v_rresp_r <= AXI_OKAY;
					else begin
						v_rresp_r <= AXI_SLVERR;
						$warning("ARADDR decode error");
						v_state_r <= 32'd3;
					end
				end
				32'd2:
					if (v_mem_wait_count_r == 0)
						v_state_r <= 32'd3;
					else
						v_mem_wait_count_r <= v_mem_wait_count_r - 1;
				32'd3: begin
					s_axi_rvalid_r <= 1'b1;
					s_axi_rresp_r <= v_rresp_r;
					s_axi_rdata_r <= v_rdata_r;
					v_state_r <= 32'd4;
				end
				32'd4:
					if (s_axi_rready) begin
						s_axi_rvalid_r <= 1'b0;
						s_axi_rdata_r <= 1'sb0;
						v_state_r <= 32'd0;
					end
			endcase
		end
	end
	localparam [31:0] prefetcher_regbank_regs_pkg_LAYER_CONFIG_ADJACENCY_LIST_ADDRESS_LSB_VALUE_RESET = 32'b00000000000000000000000000000000;
	localparam [1:0] prefetcher_regbank_regs_pkg_LAYER_CONFIG_ADJACENCY_LIST_ADDRESS_MSB_VALUE_RESET = 2'b00;
	localparam [9:0] prefetcher_regbank_regs_pkg_LAYER_CONFIG_IN_FEATURES_COUNT_RESET = 10'b0000000000;
	localparam [31:0] prefetcher_regbank_regs_pkg_LAYER_CONFIG_IN_MESSAGES_ADDRESS_LSB_VALUE_RESET = 32'b00000000000000000000000000000000;
	localparam [1:0] prefetcher_regbank_regs_pkg_LAYER_CONFIG_IN_MESSAGES_ADDRESS_MSB_VALUE_RESET = 2'b00;
	localparam [9:0] prefetcher_regbank_regs_pkg_LAYER_CONFIG_OUT_FEATURES_COUNT_RESET = 10'b0000000000;
	localparam [31:0] prefetcher_regbank_regs_pkg_LAYER_CONFIG_SCALE_FACTORS_ADDRESS_LSB_VALUE_RESET = 32'b00000000000000000000000000000000;
	localparam [1:0] prefetcher_regbank_regs_pkg_LAYER_CONFIG_SCALE_FACTORS_ADDRESS_MSB_VALUE_RESET = 2'b00;
	localparam [31:0] prefetcher_regbank_regs_pkg_LAYER_CONFIG_WEIGHTS_ADDRESS_LSB_VALUE_RESET = 32'b00000000000000000000000000000000;
	localparam [1:0] prefetcher_regbank_regs_pkg_LAYER_CONFIG_WEIGHTS_ADDRESS_MSB_VALUE_RESET = 2'b00;
	always @(posedge axi_aclk or negedge axi_aresetn) begin : write_fsm
		reg [31:0] v_state_r;
		reg v_addr_hit;
		reg [AXI_ADDR_WIDTH - 1:0] v_mem_addr;
		if (~axi_aresetn) begin
			v_state_r <= 32'd0;
			s_axi_awready_r <= 1'b0;
			s_axi_wready_r <= 1'b0;
			s_axi_awaddr_reg_r <= 1'sb0;
			s_axi_wdata_reg_r <= 1'sb0;
			s_axi_wstrb_reg_r <= 1'sb0;
			s_axi_bvalid_r <= 1'b0;
			s_axi_bresp_r <= 1'sb0;
			s_layer_config_in_features_strobe_r <= 1'sb0;
			s_reg_layer_config_in_features_count_r <= prefetcher_regbank_regs_pkg_LAYER_CONFIG_IN_FEATURES_COUNT_RESET;
			s_layer_config_out_features_strobe_r <= 1'sb0;
			s_reg_layer_config_out_features_count_r <= prefetcher_regbank_regs_pkg_LAYER_CONFIG_OUT_FEATURES_COUNT_RESET;
			s_layer_config_in_messages_address_lsb_strobe_r <= 1'sb0;
			s_reg_layer_config_in_messages_address_lsb_value_r <= prefetcher_regbank_regs_pkg_LAYER_CONFIG_IN_MESSAGES_ADDRESS_LSB_VALUE_RESET;
			s_layer_config_in_messages_address_msb_strobe_r <= 1'sb0;
			s_reg_layer_config_in_messages_address_msb_value_r <= prefetcher_regbank_regs_pkg_LAYER_CONFIG_IN_MESSAGES_ADDRESS_MSB_VALUE_RESET;
			s_layer_config_adjacency_list_address_lsb_strobe_r <= 1'sb0;
			s_reg_layer_config_adjacency_list_address_lsb_value_r <= prefetcher_regbank_regs_pkg_LAYER_CONFIG_ADJACENCY_LIST_ADDRESS_LSB_VALUE_RESET;
			s_layer_config_adjacency_list_address_msb_strobe_r <= 1'sb0;
			s_reg_layer_config_adjacency_list_address_msb_value_r <= prefetcher_regbank_regs_pkg_LAYER_CONFIG_ADJACENCY_LIST_ADDRESS_MSB_VALUE_RESET;
			s_layer_config_weights_address_lsb_strobe_r <= 1'sb0;
			s_reg_layer_config_weights_address_lsb_value_r <= prefetcher_regbank_regs_pkg_LAYER_CONFIG_WEIGHTS_ADDRESS_LSB_VALUE_RESET;
			s_layer_config_weights_address_msb_strobe_r <= 1'sb0;
			s_reg_layer_config_weights_address_msb_value_r <= prefetcher_regbank_regs_pkg_LAYER_CONFIG_WEIGHTS_ADDRESS_MSB_VALUE_RESET;
			s_layer_config_scale_factors_address_lsb_strobe_r <= 1'sb0;
			s_reg_layer_config_scale_factors_address_lsb_value_r <= prefetcher_regbank_regs_pkg_LAYER_CONFIG_SCALE_FACTORS_ADDRESS_LSB_VALUE_RESET;
			s_layer_config_scale_factors_address_msb_strobe_r <= 1'sb0;
			s_reg_layer_config_scale_factors_address_msb_value_r <= prefetcher_regbank_regs_pkg_LAYER_CONFIG_SCALE_FACTORS_ADDRESS_MSB_VALUE_RESET;
		end
		else begin
			s_axi_awready_r <= 1'b0;
			s_axi_wready_r <= 1'b0;
			s_layer_config_in_features_strobe_r <= 1'sb0;
			s_layer_config_out_features_strobe_r <= 1'sb0;
			s_layer_config_in_messages_address_lsb_strobe_r <= 1'sb0;
			s_layer_config_in_messages_address_msb_strobe_r <= 1'sb0;
			s_layer_config_adjacency_list_address_lsb_strobe_r <= 1'sb0;
			s_layer_config_adjacency_list_address_msb_strobe_r <= 1'sb0;
			s_layer_config_weights_address_lsb_strobe_r <= 1'sb0;
			s_layer_config_weights_address_msb_strobe_r <= 1'sb0;
			s_layer_config_scale_factors_address_lsb_strobe_r <= 1'sb0;
			s_layer_config_scale_factors_address_msb_strobe_r <= 1'sb0;
			v_addr_hit = 1'b0;
			case (v_state_r)
				32'd0:
					if (s_axi_awvalid && s_axi_wvalid) begin
						s_axi_awaddr_reg_r <= s_axi_awaddr;
						s_axi_awready_r <= 1'b1;
						s_axi_wdata_reg_r <= s_axi_wdata;
						s_axi_wstrb_reg_r <= s_axi_wstrb;
						s_axi_wready_r <= 1'b1;
						v_state_r <= 32'd3;
					end
					else if (s_axi_awvalid) begin
						s_axi_awaddr_reg_r <= s_axi_awaddr;
						s_axi_awready_r <= 1'b1;
						v_state_r <= 32'd1;
					end
					else if (s_axi_wvalid) begin
						s_axi_wdata_reg_r <= s_axi_wdata;
						s_axi_wstrb_reg_r <= s_axi_wstrb;
						s_axi_wready_r <= 1'b1;
						v_state_r <= 32'd2;
					end
				32'd1:
					if (s_axi_wvalid) begin
						s_axi_wdata_reg_r <= s_axi_wdata;
						s_axi_wstrb_reg_r <= s_axi_wstrb;
						s_axi_wready_r <= 1'b1;
						v_state_r <= 32'd3;
					end
				32'd2:
					if (s_axi_awvalid) begin
						s_axi_awaddr_reg_r <= s_axi_awaddr;
						s_axi_awready_r <= 1'b1;
						v_state_r <= 32'd3;
					end
				32'd3: begin
					s_axi_bresp_r <= AXI_OKAY;
					s_axi_bvalid_r <= 1'b1;
					if (s_axi_awaddr_reg_r[AXI_ADDR_WIDTH - 1:2] == (BASEADDR[AXI_ADDR_WIDTH - 1:2] + prefetcher_regbank_regs_pkg_LAYER_CONFIG_IN_FEATURES_OFFSET[AXI_ADDR_WIDTH - 1:2])) begin
						v_addr_hit = 1'b1;
						s_layer_config_in_features_strobe_r <= 1'b1;
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_in_features_count_r[0] <= s_axi_wdata_reg_r[0];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_in_features_count_r[1] <= s_axi_wdata_reg_r[1];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_in_features_count_r[2] <= s_axi_wdata_reg_r[2];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_in_features_count_r[3] <= s_axi_wdata_reg_r[3];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_in_features_count_r[4] <= s_axi_wdata_reg_r[4];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_in_features_count_r[5] <= s_axi_wdata_reg_r[5];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_in_features_count_r[6] <= s_axi_wdata_reg_r[6];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_in_features_count_r[7] <= s_axi_wdata_reg_r[7];
						if (s_axi_wstrb_reg_r[1])
							s_reg_layer_config_in_features_count_r[8] <= s_axi_wdata_reg_r[8];
						if (s_axi_wstrb_reg_r[1])
							s_reg_layer_config_in_features_count_r[9] <= s_axi_wdata_reg_r[9];
					end
					if (s_axi_awaddr_reg_r[AXI_ADDR_WIDTH - 1:2] == (BASEADDR[AXI_ADDR_WIDTH - 1:2] + prefetcher_regbank_regs_pkg_LAYER_CONFIG_OUT_FEATURES_OFFSET[AXI_ADDR_WIDTH - 1:2])) begin
						v_addr_hit = 1'b1;
						s_layer_config_out_features_strobe_r <= 1'b1;
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_out_features_count_r[0] <= s_axi_wdata_reg_r[0];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_out_features_count_r[1] <= s_axi_wdata_reg_r[1];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_out_features_count_r[2] <= s_axi_wdata_reg_r[2];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_out_features_count_r[3] <= s_axi_wdata_reg_r[3];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_out_features_count_r[4] <= s_axi_wdata_reg_r[4];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_out_features_count_r[5] <= s_axi_wdata_reg_r[5];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_out_features_count_r[6] <= s_axi_wdata_reg_r[6];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_out_features_count_r[7] <= s_axi_wdata_reg_r[7];
						if (s_axi_wstrb_reg_r[1])
							s_reg_layer_config_out_features_count_r[8] <= s_axi_wdata_reg_r[8];
						if (s_axi_wstrb_reg_r[1])
							s_reg_layer_config_out_features_count_r[9] <= s_axi_wdata_reg_r[9];
					end
					if (s_axi_awaddr_reg_r[AXI_ADDR_WIDTH - 1:2] == (BASEADDR[AXI_ADDR_WIDTH - 1:2] + prefetcher_regbank_regs_pkg_LAYER_CONFIG_IN_MESSAGES_ADDRESS_LSB_OFFSET[AXI_ADDR_WIDTH - 1:2])) begin
						v_addr_hit = 1'b1;
						s_layer_config_in_messages_address_lsb_strobe_r <= 1'b1;
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_in_messages_address_lsb_value_r[0] <= s_axi_wdata_reg_r[0];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_in_messages_address_lsb_value_r[1] <= s_axi_wdata_reg_r[1];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_in_messages_address_lsb_value_r[2] <= s_axi_wdata_reg_r[2];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_in_messages_address_lsb_value_r[3] <= s_axi_wdata_reg_r[3];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_in_messages_address_lsb_value_r[4] <= s_axi_wdata_reg_r[4];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_in_messages_address_lsb_value_r[5] <= s_axi_wdata_reg_r[5];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_in_messages_address_lsb_value_r[6] <= s_axi_wdata_reg_r[6];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_in_messages_address_lsb_value_r[7] <= s_axi_wdata_reg_r[7];
						if (s_axi_wstrb_reg_r[1])
							s_reg_layer_config_in_messages_address_lsb_value_r[8] <= s_axi_wdata_reg_r[8];
						if (s_axi_wstrb_reg_r[1])
							s_reg_layer_config_in_messages_address_lsb_value_r[9] <= s_axi_wdata_reg_r[9];
						if (s_axi_wstrb_reg_r[1])
							s_reg_layer_config_in_messages_address_lsb_value_r[10] <= s_axi_wdata_reg_r[10];
						if (s_axi_wstrb_reg_r[1])
							s_reg_layer_config_in_messages_address_lsb_value_r[11] <= s_axi_wdata_reg_r[11];
						if (s_axi_wstrb_reg_r[1])
							s_reg_layer_config_in_messages_address_lsb_value_r[12] <= s_axi_wdata_reg_r[12];
						if (s_axi_wstrb_reg_r[1])
							s_reg_layer_config_in_messages_address_lsb_value_r[13] <= s_axi_wdata_reg_r[13];
						if (s_axi_wstrb_reg_r[1])
							s_reg_layer_config_in_messages_address_lsb_value_r[14] <= s_axi_wdata_reg_r[14];
						if (s_axi_wstrb_reg_r[1])
							s_reg_layer_config_in_messages_address_lsb_value_r[15] <= s_axi_wdata_reg_r[15];
						if (s_axi_wstrb_reg_r[2])
							s_reg_layer_config_in_messages_address_lsb_value_r[16] <= s_axi_wdata_reg_r[16];
						if (s_axi_wstrb_reg_r[2])
							s_reg_layer_config_in_messages_address_lsb_value_r[17] <= s_axi_wdata_reg_r[17];
						if (s_axi_wstrb_reg_r[2])
							s_reg_layer_config_in_messages_address_lsb_value_r[18] <= s_axi_wdata_reg_r[18];
						if (s_axi_wstrb_reg_r[2])
							s_reg_layer_config_in_messages_address_lsb_value_r[19] <= s_axi_wdata_reg_r[19];
						if (s_axi_wstrb_reg_r[2])
							s_reg_layer_config_in_messages_address_lsb_value_r[20] <= s_axi_wdata_reg_r[20];
						if (s_axi_wstrb_reg_r[2])
							s_reg_layer_config_in_messages_address_lsb_value_r[21] <= s_axi_wdata_reg_r[21];
						if (s_axi_wstrb_reg_r[2])
							s_reg_layer_config_in_messages_address_lsb_value_r[22] <= s_axi_wdata_reg_r[22];
						if (s_axi_wstrb_reg_r[2])
							s_reg_layer_config_in_messages_address_lsb_value_r[23] <= s_axi_wdata_reg_r[23];
						if (s_axi_wstrb_reg_r[3])
							s_reg_layer_config_in_messages_address_lsb_value_r[24] <= s_axi_wdata_reg_r[24];
						if (s_axi_wstrb_reg_r[3])
							s_reg_layer_config_in_messages_address_lsb_value_r[25] <= s_axi_wdata_reg_r[25];
						if (s_axi_wstrb_reg_r[3])
							s_reg_layer_config_in_messages_address_lsb_value_r[26] <= s_axi_wdata_reg_r[26];
						if (s_axi_wstrb_reg_r[3])
							s_reg_layer_config_in_messages_address_lsb_value_r[27] <= s_axi_wdata_reg_r[27];
						if (s_axi_wstrb_reg_r[3])
							s_reg_layer_config_in_messages_address_lsb_value_r[28] <= s_axi_wdata_reg_r[28];
						if (s_axi_wstrb_reg_r[3])
							s_reg_layer_config_in_messages_address_lsb_value_r[29] <= s_axi_wdata_reg_r[29];
						if (s_axi_wstrb_reg_r[3])
							s_reg_layer_config_in_messages_address_lsb_value_r[30] <= s_axi_wdata_reg_r[30];
						if (s_axi_wstrb_reg_r[3])
							s_reg_layer_config_in_messages_address_lsb_value_r[31] <= s_axi_wdata_reg_r[31];
					end
					if (s_axi_awaddr_reg_r[AXI_ADDR_WIDTH - 1:2] == (BASEADDR[AXI_ADDR_WIDTH - 1:2] + prefetcher_regbank_regs_pkg_LAYER_CONFIG_IN_MESSAGES_ADDRESS_MSB_OFFSET[AXI_ADDR_WIDTH - 1:2])) begin
						v_addr_hit = 1'b1;
						s_layer_config_in_messages_address_msb_strobe_r <= 1'b1;
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_in_messages_address_msb_value_r[0] <= s_axi_wdata_reg_r[0];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_in_messages_address_msb_value_r[1] <= s_axi_wdata_reg_r[1];
					end
					if (s_axi_awaddr_reg_r[AXI_ADDR_WIDTH - 1:2] == (BASEADDR[AXI_ADDR_WIDTH - 1:2] + prefetcher_regbank_regs_pkg_LAYER_CONFIG_ADJACENCY_LIST_ADDRESS_LSB_OFFSET[AXI_ADDR_WIDTH - 1:2])) begin
						v_addr_hit = 1'b1;
						s_layer_config_adjacency_list_address_lsb_strobe_r <= 1'b1;
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_adjacency_list_address_lsb_value_r[0] <= s_axi_wdata_reg_r[0];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_adjacency_list_address_lsb_value_r[1] <= s_axi_wdata_reg_r[1];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_adjacency_list_address_lsb_value_r[2] <= s_axi_wdata_reg_r[2];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_adjacency_list_address_lsb_value_r[3] <= s_axi_wdata_reg_r[3];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_adjacency_list_address_lsb_value_r[4] <= s_axi_wdata_reg_r[4];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_adjacency_list_address_lsb_value_r[5] <= s_axi_wdata_reg_r[5];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_adjacency_list_address_lsb_value_r[6] <= s_axi_wdata_reg_r[6];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_adjacency_list_address_lsb_value_r[7] <= s_axi_wdata_reg_r[7];
						if (s_axi_wstrb_reg_r[1])
							s_reg_layer_config_adjacency_list_address_lsb_value_r[8] <= s_axi_wdata_reg_r[8];
						if (s_axi_wstrb_reg_r[1])
							s_reg_layer_config_adjacency_list_address_lsb_value_r[9] <= s_axi_wdata_reg_r[9];
						if (s_axi_wstrb_reg_r[1])
							s_reg_layer_config_adjacency_list_address_lsb_value_r[10] <= s_axi_wdata_reg_r[10];
						if (s_axi_wstrb_reg_r[1])
							s_reg_layer_config_adjacency_list_address_lsb_value_r[11] <= s_axi_wdata_reg_r[11];
						if (s_axi_wstrb_reg_r[1])
							s_reg_layer_config_adjacency_list_address_lsb_value_r[12] <= s_axi_wdata_reg_r[12];
						if (s_axi_wstrb_reg_r[1])
							s_reg_layer_config_adjacency_list_address_lsb_value_r[13] <= s_axi_wdata_reg_r[13];
						if (s_axi_wstrb_reg_r[1])
							s_reg_layer_config_adjacency_list_address_lsb_value_r[14] <= s_axi_wdata_reg_r[14];
						if (s_axi_wstrb_reg_r[1])
							s_reg_layer_config_adjacency_list_address_lsb_value_r[15] <= s_axi_wdata_reg_r[15];
						if (s_axi_wstrb_reg_r[2])
							s_reg_layer_config_adjacency_list_address_lsb_value_r[16] <= s_axi_wdata_reg_r[16];
						if (s_axi_wstrb_reg_r[2])
							s_reg_layer_config_adjacency_list_address_lsb_value_r[17] <= s_axi_wdata_reg_r[17];
						if (s_axi_wstrb_reg_r[2])
							s_reg_layer_config_adjacency_list_address_lsb_value_r[18] <= s_axi_wdata_reg_r[18];
						if (s_axi_wstrb_reg_r[2])
							s_reg_layer_config_adjacency_list_address_lsb_value_r[19] <= s_axi_wdata_reg_r[19];
						if (s_axi_wstrb_reg_r[2])
							s_reg_layer_config_adjacency_list_address_lsb_value_r[20] <= s_axi_wdata_reg_r[20];
						if (s_axi_wstrb_reg_r[2])
							s_reg_layer_config_adjacency_list_address_lsb_value_r[21] <= s_axi_wdata_reg_r[21];
						if (s_axi_wstrb_reg_r[2])
							s_reg_layer_config_adjacency_list_address_lsb_value_r[22] <= s_axi_wdata_reg_r[22];
						if (s_axi_wstrb_reg_r[2])
							s_reg_layer_config_adjacency_list_address_lsb_value_r[23] <= s_axi_wdata_reg_r[23];
						if (s_axi_wstrb_reg_r[3])
							s_reg_layer_config_adjacency_list_address_lsb_value_r[24] <= s_axi_wdata_reg_r[24];
						if (s_axi_wstrb_reg_r[3])
							s_reg_layer_config_adjacency_list_address_lsb_value_r[25] <= s_axi_wdata_reg_r[25];
						if (s_axi_wstrb_reg_r[3])
							s_reg_layer_config_adjacency_list_address_lsb_value_r[26] <= s_axi_wdata_reg_r[26];
						if (s_axi_wstrb_reg_r[3])
							s_reg_layer_config_adjacency_list_address_lsb_value_r[27] <= s_axi_wdata_reg_r[27];
						if (s_axi_wstrb_reg_r[3])
							s_reg_layer_config_adjacency_list_address_lsb_value_r[28] <= s_axi_wdata_reg_r[28];
						if (s_axi_wstrb_reg_r[3])
							s_reg_layer_config_adjacency_list_address_lsb_value_r[29] <= s_axi_wdata_reg_r[29];
						if (s_axi_wstrb_reg_r[3])
							s_reg_layer_config_adjacency_list_address_lsb_value_r[30] <= s_axi_wdata_reg_r[30];
						if (s_axi_wstrb_reg_r[3])
							s_reg_layer_config_adjacency_list_address_lsb_value_r[31] <= s_axi_wdata_reg_r[31];
					end
					if (s_axi_awaddr_reg_r[AXI_ADDR_WIDTH - 1:2] == (BASEADDR[AXI_ADDR_WIDTH - 1:2] + prefetcher_regbank_regs_pkg_LAYER_CONFIG_ADJACENCY_LIST_ADDRESS_MSB_OFFSET[AXI_ADDR_WIDTH - 1:2])) begin
						v_addr_hit = 1'b1;
						s_layer_config_adjacency_list_address_msb_strobe_r <= 1'b1;
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_adjacency_list_address_msb_value_r[0] <= s_axi_wdata_reg_r[0];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_adjacency_list_address_msb_value_r[1] <= s_axi_wdata_reg_r[1];
					end
					if (s_axi_awaddr_reg_r[AXI_ADDR_WIDTH - 1:2] == (BASEADDR[AXI_ADDR_WIDTH - 1:2] + prefetcher_regbank_regs_pkg_LAYER_CONFIG_WEIGHTS_ADDRESS_LSB_OFFSET[AXI_ADDR_WIDTH - 1:2])) begin
						v_addr_hit = 1'b1;
						s_layer_config_weights_address_lsb_strobe_r <= 1'b1;
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_weights_address_lsb_value_r[0] <= s_axi_wdata_reg_r[0];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_weights_address_lsb_value_r[1] <= s_axi_wdata_reg_r[1];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_weights_address_lsb_value_r[2] <= s_axi_wdata_reg_r[2];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_weights_address_lsb_value_r[3] <= s_axi_wdata_reg_r[3];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_weights_address_lsb_value_r[4] <= s_axi_wdata_reg_r[4];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_weights_address_lsb_value_r[5] <= s_axi_wdata_reg_r[5];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_weights_address_lsb_value_r[6] <= s_axi_wdata_reg_r[6];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_weights_address_lsb_value_r[7] <= s_axi_wdata_reg_r[7];
						if (s_axi_wstrb_reg_r[1])
							s_reg_layer_config_weights_address_lsb_value_r[8] <= s_axi_wdata_reg_r[8];
						if (s_axi_wstrb_reg_r[1])
							s_reg_layer_config_weights_address_lsb_value_r[9] <= s_axi_wdata_reg_r[9];
						if (s_axi_wstrb_reg_r[1])
							s_reg_layer_config_weights_address_lsb_value_r[10] <= s_axi_wdata_reg_r[10];
						if (s_axi_wstrb_reg_r[1])
							s_reg_layer_config_weights_address_lsb_value_r[11] <= s_axi_wdata_reg_r[11];
						if (s_axi_wstrb_reg_r[1])
							s_reg_layer_config_weights_address_lsb_value_r[12] <= s_axi_wdata_reg_r[12];
						if (s_axi_wstrb_reg_r[1])
							s_reg_layer_config_weights_address_lsb_value_r[13] <= s_axi_wdata_reg_r[13];
						if (s_axi_wstrb_reg_r[1])
							s_reg_layer_config_weights_address_lsb_value_r[14] <= s_axi_wdata_reg_r[14];
						if (s_axi_wstrb_reg_r[1])
							s_reg_layer_config_weights_address_lsb_value_r[15] <= s_axi_wdata_reg_r[15];
						if (s_axi_wstrb_reg_r[2])
							s_reg_layer_config_weights_address_lsb_value_r[16] <= s_axi_wdata_reg_r[16];
						if (s_axi_wstrb_reg_r[2])
							s_reg_layer_config_weights_address_lsb_value_r[17] <= s_axi_wdata_reg_r[17];
						if (s_axi_wstrb_reg_r[2])
							s_reg_layer_config_weights_address_lsb_value_r[18] <= s_axi_wdata_reg_r[18];
						if (s_axi_wstrb_reg_r[2])
							s_reg_layer_config_weights_address_lsb_value_r[19] <= s_axi_wdata_reg_r[19];
						if (s_axi_wstrb_reg_r[2])
							s_reg_layer_config_weights_address_lsb_value_r[20] <= s_axi_wdata_reg_r[20];
						if (s_axi_wstrb_reg_r[2])
							s_reg_layer_config_weights_address_lsb_value_r[21] <= s_axi_wdata_reg_r[21];
						if (s_axi_wstrb_reg_r[2])
							s_reg_layer_config_weights_address_lsb_value_r[22] <= s_axi_wdata_reg_r[22];
						if (s_axi_wstrb_reg_r[2])
							s_reg_layer_config_weights_address_lsb_value_r[23] <= s_axi_wdata_reg_r[23];
						if (s_axi_wstrb_reg_r[3])
							s_reg_layer_config_weights_address_lsb_value_r[24] <= s_axi_wdata_reg_r[24];
						if (s_axi_wstrb_reg_r[3])
							s_reg_layer_config_weights_address_lsb_value_r[25] <= s_axi_wdata_reg_r[25];
						if (s_axi_wstrb_reg_r[3])
							s_reg_layer_config_weights_address_lsb_value_r[26] <= s_axi_wdata_reg_r[26];
						if (s_axi_wstrb_reg_r[3])
							s_reg_layer_config_weights_address_lsb_value_r[27] <= s_axi_wdata_reg_r[27];
						if (s_axi_wstrb_reg_r[3])
							s_reg_layer_config_weights_address_lsb_value_r[28] <= s_axi_wdata_reg_r[28];
						if (s_axi_wstrb_reg_r[3])
							s_reg_layer_config_weights_address_lsb_value_r[29] <= s_axi_wdata_reg_r[29];
						if (s_axi_wstrb_reg_r[3])
							s_reg_layer_config_weights_address_lsb_value_r[30] <= s_axi_wdata_reg_r[30];
						if (s_axi_wstrb_reg_r[3])
							s_reg_layer_config_weights_address_lsb_value_r[31] <= s_axi_wdata_reg_r[31];
					end
					if (s_axi_awaddr_reg_r[AXI_ADDR_WIDTH - 1:2] == (BASEADDR[AXI_ADDR_WIDTH - 1:2] + prefetcher_regbank_regs_pkg_LAYER_CONFIG_WEIGHTS_ADDRESS_MSB_OFFSET[AXI_ADDR_WIDTH - 1:2])) begin
						v_addr_hit = 1'b1;
						s_layer_config_weights_address_msb_strobe_r <= 1'b1;
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_weights_address_msb_value_r[0] <= s_axi_wdata_reg_r[0];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_weights_address_msb_value_r[1] <= s_axi_wdata_reg_r[1];
					end
					if (s_axi_awaddr_reg_r[AXI_ADDR_WIDTH - 1:2] == (BASEADDR[AXI_ADDR_WIDTH - 1:2] + prefetcher_regbank_regs_pkg_LAYER_CONFIG_SCALE_FACTORS_ADDRESS_LSB_OFFSET[AXI_ADDR_WIDTH - 1:2])) begin
						v_addr_hit = 1'b1;
						s_layer_config_scale_factors_address_lsb_strobe_r <= 1'b1;
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_scale_factors_address_lsb_value_r[0] <= s_axi_wdata_reg_r[0];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_scale_factors_address_lsb_value_r[1] <= s_axi_wdata_reg_r[1];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_scale_factors_address_lsb_value_r[2] <= s_axi_wdata_reg_r[2];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_scale_factors_address_lsb_value_r[3] <= s_axi_wdata_reg_r[3];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_scale_factors_address_lsb_value_r[4] <= s_axi_wdata_reg_r[4];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_scale_factors_address_lsb_value_r[5] <= s_axi_wdata_reg_r[5];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_scale_factors_address_lsb_value_r[6] <= s_axi_wdata_reg_r[6];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_scale_factors_address_lsb_value_r[7] <= s_axi_wdata_reg_r[7];
						if (s_axi_wstrb_reg_r[1])
							s_reg_layer_config_scale_factors_address_lsb_value_r[8] <= s_axi_wdata_reg_r[8];
						if (s_axi_wstrb_reg_r[1])
							s_reg_layer_config_scale_factors_address_lsb_value_r[9] <= s_axi_wdata_reg_r[9];
						if (s_axi_wstrb_reg_r[1])
							s_reg_layer_config_scale_factors_address_lsb_value_r[10] <= s_axi_wdata_reg_r[10];
						if (s_axi_wstrb_reg_r[1])
							s_reg_layer_config_scale_factors_address_lsb_value_r[11] <= s_axi_wdata_reg_r[11];
						if (s_axi_wstrb_reg_r[1])
							s_reg_layer_config_scale_factors_address_lsb_value_r[12] <= s_axi_wdata_reg_r[12];
						if (s_axi_wstrb_reg_r[1])
							s_reg_layer_config_scale_factors_address_lsb_value_r[13] <= s_axi_wdata_reg_r[13];
						if (s_axi_wstrb_reg_r[1])
							s_reg_layer_config_scale_factors_address_lsb_value_r[14] <= s_axi_wdata_reg_r[14];
						if (s_axi_wstrb_reg_r[1])
							s_reg_layer_config_scale_factors_address_lsb_value_r[15] <= s_axi_wdata_reg_r[15];
						if (s_axi_wstrb_reg_r[2])
							s_reg_layer_config_scale_factors_address_lsb_value_r[16] <= s_axi_wdata_reg_r[16];
						if (s_axi_wstrb_reg_r[2])
							s_reg_layer_config_scale_factors_address_lsb_value_r[17] <= s_axi_wdata_reg_r[17];
						if (s_axi_wstrb_reg_r[2])
							s_reg_layer_config_scale_factors_address_lsb_value_r[18] <= s_axi_wdata_reg_r[18];
						if (s_axi_wstrb_reg_r[2])
							s_reg_layer_config_scale_factors_address_lsb_value_r[19] <= s_axi_wdata_reg_r[19];
						if (s_axi_wstrb_reg_r[2])
							s_reg_layer_config_scale_factors_address_lsb_value_r[20] <= s_axi_wdata_reg_r[20];
						if (s_axi_wstrb_reg_r[2])
							s_reg_layer_config_scale_factors_address_lsb_value_r[21] <= s_axi_wdata_reg_r[21];
						if (s_axi_wstrb_reg_r[2])
							s_reg_layer_config_scale_factors_address_lsb_value_r[22] <= s_axi_wdata_reg_r[22];
						if (s_axi_wstrb_reg_r[2])
							s_reg_layer_config_scale_factors_address_lsb_value_r[23] <= s_axi_wdata_reg_r[23];
						if (s_axi_wstrb_reg_r[3])
							s_reg_layer_config_scale_factors_address_lsb_value_r[24] <= s_axi_wdata_reg_r[24];
						if (s_axi_wstrb_reg_r[3])
							s_reg_layer_config_scale_factors_address_lsb_value_r[25] <= s_axi_wdata_reg_r[25];
						if (s_axi_wstrb_reg_r[3])
							s_reg_layer_config_scale_factors_address_lsb_value_r[26] <= s_axi_wdata_reg_r[26];
						if (s_axi_wstrb_reg_r[3])
							s_reg_layer_config_scale_factors_address_lsb_value_r[27] <= s_axi_wdata_reg_r[27];
						if (s_axi_wstrb_reg_r[3])
							s_reg_layer_config_scale_factors_address_lsb_value_r[28] <= s_axi_wdata_reg_r[28];
						if (s_axi_wstrb_reg_r[3])
							s_reg_layer_config_scale_factors_address_lsb_value_r[29] <= s_axi_wdata_reg_r[29];
						if (s_axi_wstrb_reg_r[3])
							s_reg_layer_config_scale_factors_address_lsb_value_r[30] <= s_axi_wdata_reg_r[30];
						if (s_axi_wstrb_reg_r[3])
							s_reg_layer_config_scale_factors_address_lsb_value_r[31] <= s_axi_wdata_reg_r[31];
					end
					if (s_axi_awaddr_reg_r[AXI_ADDR_WIDTH - 1:2] == (BASEADDR[AXI_ADDR_WIDTH - 1:2] + prefetcher_regbank_regs_pkg_LAYER_CONFIG_SCALE_FACTORS_ADDRESS_MSB_OFFSET[AXI_ADDR_WIDTH - 1:2])) begin
						v_addr_hit = 1'b1;
						s_layer_config_scale_factors_address_msb_strobe_r <= 1'b1;
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_scale_factors_address_msb_value_r[0] <= s_axi_wdata_reg_r[0];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_scale_factors_address_msb_value_r[1] <= s_axi_wdata_reg_r[1];
					end
					if (!v_addr_hit) begin
						s_axi_bresp_r <= AXI_SLVERR;
						$warning("AWADDR decode error");
					end
					v_state_r <= 32'd4;
				end
				32'd4:
					if (s_axi_bready) begin
						s_axi_bvalid_r <= 1'b0;
						v_state_r <= 32'd0;
					end
			endcase
		end
	end
	assign s_axi_awready = s_axi_awready_r;
	assign s_axi_wready = s_axi_wready_r;
	assign s_axi_bvalid = s_axi_bvalid_r;
	assign s_axi_bresp = s_axi_bresp_r;
	assign s_axi_arready = s_axi_arready_r;
	assign s_axi_rvalid = s_axi_rvalid_r;
	assign s_axi_rresp = s_axi_rresp_r;
	assign s_axi_rdata = s_axi_rdata_r;
	assign layer_config_in_features_strobe = s_layer_config_in_features_strobe_r;
	assign layer_config_in_features_count = s_reg_layer_config_in_features_count_r;
	assign layer_config_out_features_strobe = s_layer_config_out_features_strobe_r;
	assign layer_config_out_features_count = s_reg_layer_config_out_features_count_r;
	assign layer_config_in_messages_address_lsb_strobe = s_layer_config_in_messages_address_lsb_strobe_r;
	assign layer_config_in_messages_address_lsb_value = s_reg_layer_config_in_messages_address_lsb_value_r;
	assign layer_config_in_messages_address_msb_strobe = s_layer_config_in_messages_address_msb_strobe_r;
	assign layer_config_in_messages_address_msb_value = s_reg_layer_config_in_messages_address_msb_value_r;
	assign layer_config_adjacency_list_address_lsb_strobe = s_layer_config_adjacency_list_address_lsb_strobe_r;
	assign layer_config_adjacency_list_address_lsb_value = s_reg_layer_config_adjacency_list_address_lsb_value_r;
	assign layer_config_adjacency_list_address_msb_strobe = s_layer_config_adjacency_list_address_msb_strobe_r;
	assign layer_config_adjacency_list_address_msb_value = s_reg_layer_config_adjacency_list_address_msb_value_r;
	assign layer_config_weights_address_lsb_strobe = s_layer_config_weights_address_lsb_strobe_r;
	assign layer_config_weights_address_lsb_value = s_reg_layer_config_weights_address_lsb_value_r;
	assign layer_config_weights_address_msb_strobe = s_layer_config_weights_address_msb_strobe_r;
	assign layer_config_weights_address_msb_value = s_reg_layer_config_weights_address_msb_value_r;
	assign layer_config_scale_factors_address_lsb_strobe = s_layer_config_scale_factors_address_lsb_strobe_r;
	assign layer_config_scale_factors_address_lsb_value = s_reg_layer_config_scale_factors_address_lsb_value_r;
	assign layer_config_scale_factors_address_msb_strobe = s_layer_config_scale_factors_address_msb_strobe_r;
	assign layer_config_scale_factors_address_msb_value = s_reg_layer_config_scale_factors_address_msb_value_r;
endmodule
`resetall
`default_nettype none
module feature_transformation_engine_regbank_regs (
	axi_aclk,
	axi_aresetn,
	s_axi_awaddr,
	s_axi_awprot,
	s_axi_awvalid,
	s_axi_awready,
	s_axi_wdata,
	s_axi_wstrb,
	s_axi_wvalid,
	s_axi_wready,
	s_axi_araddr,
	s_axi_arprot,
	s_axi_arvalid,
	s_axi_arready,
	s_axi_rdata,
	s_axi_rresp,
	s_axi_rvalid,
	s_axi_rready,
	s_axi_bresp,
	s_axi_bvalid,
	s_axi_bready,
	layer_config_in_features_strobe,
	layer_config_in_features_count,
	layer_config_out_features_strobe,
	layer_config_out_features_count,
	layer_config_activation_function_strobe,
	layer_config_activation_function_value,
	layer_config_bias_strobe,
	layer_config_bias_value,
	layer_config_leaky_relu_alpha_strobe,
	layer_config_leaky_relu_alpha_value,
	layer_config_out_features_address_msb_strobe,
	layer_config_out_features_address_msb_value,
	layer_config_out_features_address_lsb_strobe,
	layer_config_out_features_address_lsb_value,
	ctrl_buffering_enable_strobe,
	ctrl_buffering_enable_value,
	ctrl_writeback_enable_strobe,
	ctrl_writeback_enable_value
);
	parameter AXI_ADDR_WIDTH = 32;
	parameter [31:0] BASEADDR = 32'h40000000;
	input wire axi_aclk;
	input wire axi_aresetn;
	input wire [AXI_ADDR_WIDTH - 1:0] s_axi_awaddr;
	input wire [2:0] s_axi_awprot;
	input wire s_axi_awvalid;
	output wire s_axi_awready;
	input wire [31:0] s_axi_wdata;
	input wire [3:0] s_axi_wstrb;
	input wire s_axi_wvalid;
	output wire s_axi_wready;
	input wire [AXI_ADDR_WIDTH - 1:0] s_axi_araddr;
	input wire [2:0] s_axi_arprot;
	input wire s_axi_arvalid;
	output wire s_axi_arready;
	output wire [31:0] s_axi_rdata;
	output wire [1:0] s_axi_rresp;
	output wire s_axi_rvalid;
	input wire s_axi_rready;
	output wire [1:0] s_axi_bresp;
	output wire s_axi_bvalid;
	input wire s_axi_bready;
	output wire layer_config_in_features_strobe;
	output wire [9:0] layer_config_in_features_count;
	output wire layer_config_out_features_strobe;
	output wire [9:0] layer_config_out_features_count;
	output wire layer_config_activation_function_strobe;
	output wire [1:0] layer_config_activation_function_value;
	output wire layer_config_bias_strobe;
	output wire [31:0] layer_config_bias_value;
	output wire layer_config_leaky_relu_alpha_strobe;
	output wire [31:0] layer_config_leaky_relu_alpha_value;
	output wire layer_config_out_features_address_msb_strobe;
	output wire [1:0] layer_config_out_features_address_msb_value;
	output wire layer_config_out_features_address_lsb_strobe;
	output wire [31:0] layer_config_out_features_address_lsb_value;
	output wire ctrl_buffering_enable_strobe;
	output wire [0:0] ctrl_buffering_enable_value;
	output wire ctrl_writeback_enable_strobe;
	output wire [0:0] ctrl_writeback_enable_value;
	localparam [1:0] AXI_OKAY = 2'b00;
	localparam [1:0] AXI_SLVERR = 2'b10;
	reg s_axi_awready_r;
	reg s_axi_wready_r;
	reg [AXI_ADDR_WIDTH - 1:0] s_axi_awaddr_reg_r;
	reg s_axi_bvalid_r;
	reg [1:0] s_axi_bresp_r;
	reg s_axi_arready_r;
	reg [AXI_ADDR_WIDTH - 1:0] s_axi_araddr_reg_r;
	reg s_axi_rvalid_r;
	reg [1:0] s_axi_rresp_r;
	reg [31:0] s_axi_wdata_reg_r;
	reg [3:0] s_axi_wstrb_reg_r;
	reg [31:0] s_axi_rdata_r;
	reg s_layer_config_in_features_strobe_r;
	reg [9:0] s_reg_layer_config_in_features_count_r;
	reg s_layer_config_out_features_strobe_r;
	reg [9:0] s_reg_layer_config_out_features_count_r;
	reg s_layer_config_activation_function_strobe_r;
	reg [1:0] s_reg_layer_config_activation_function_value_r;
	reg s_layer_config_bias_strobe_r;
	reg [31:0] s_reg_layer_config_bias_value_r;
	reg s_layer_config_leaky_relu_alpha_strobe_r;
	reg [31:0] s_reg_layer_config_leaky_relu_alpha_value_r;
	reg s_layer_config_out_features_address_msb_strobe_r;
	reg [1:0] s_reg_layer_config_out_features_address_msb_value_r;
	reg s_layer_config_out_features_address_lsb_strobe_r;
	reg [31:0] s_reg_layer_config_out_features_address_lsb_value_r;
	reg s_ctrl_buffering_enable_strobe_r;
	reg [0:0] s_reg_ctrl_buffering_enable_value_r;
	reg s_ctrl_writeback_enable_strobe_r;
	reg [0:0] s_reg_ctrl_writeback_enable_value_r;
	localparam MAX_MEMORY_LATENCY = 5;
	localparam [31:0] feature_transformation_engine_regbank_regs_pkg_CTRL_BUFFERING_ENABLE_OFFSET = 32'h0000001c;
	localparam [31:0] feature_transformation_engine_regbank_regs_pkg_CTRL_WRITEBACK_ENABLE_OFFSET = 32'h00000020;
	localparam [31:0] feature_transformation_engine_regbank_regs_pkg_LAYER_CONFIG_ACTIVATION_FUNCTION_OFFSET = 32'h00000008;
	localparam [31:0] feature_transformation_engine_regbank_regs_pkg_LAYER_CONFIG_BIAS_OFFSET = 32'h0000000c;
	localparam [31:0] feature_transformation_engine_regbank_regs_pkg_LAYER_CONFIG_IN_FEATURES_OFFSET = 32'h00000000;
	localparam [31:0] feature_transformation_engine_regbank_regs_pkg_LAYER_CONFIG_LEAKY_RELU_ALPHA_OFFSET = 32'h00000010;
	localparam [31:0] feature_transformation_engine_regbank_regs_pkg_LAYER_CONFIG_OUT_FEATURES_ADDRESS_LSB_OFFSET = 32'h00000018;
	localparam [31:0] feature_transformation_engine_regbank_regs_pkg_LAYER_CONFIG_OUT_FEATURES_ADDRESS_MSB_OFFSET = 32'h00000014;
	localparam [31:0] feature_transformation_engine_regbank_regs_pkg_LAYER_CONFIG_OUT_FEATURES_OFFSET = 32'h00000004;
	always @(posedge axi_aclk or negedge axi_aresetn) begin : read_fsm
		reg [31:0] v_state_r;
		reg [31:0] v_rdata_r;
		reg [1:0] v_rresp_r;
		reg [2:0] v_mem_wait_count_r;
		reg v_addr_hit;
		reg [AXI_ADDR_WIDTH - 1:0] v_mem_addr;
		if (~axi_aresetn) begin
			v_state_r <= 32'd0;
			v_rdata_r <= 1'sb0;
			v_rresp_r <= 1'sb0;
			v_mem_wait_count_r <= 1'sb0;
			s_axi_arready_r <= 1'sb0;
			s_axi_rvalid_r <= 1'sb0;
			s_axi_rresp_r <= 1'sb0;
			s_axi_araddr_reg_r <= 1'sb0;
			s_axi_rdata_r <= 1'sb0;
		end
		else begin
			s_axi_arready_r <= 1'b0;
			case (v_state_r)
				32'd0:
					if (s_axi_arvalid) begin
						s_axi_araddr_reg_r <= s_axi_araddr;
						s_axi_arready_r <= 1'b1;
						v_state_r <= 32'd1;
					end
				32'd1: begin
					v_addr_hit = 1'b0;
					v_rdata_r <= 1'sb0;
					if (s_axi_araddr_reg_r[AXI_ADDR_WIDTH - 1:2] == (BASEADDR[AXI_ADDR_WIDTH - 1:2] + feature_transformation_engine_regbank_regs_pkg_LAYER_CONFIG_IN_FEATURES_OFFSET[AXI_ADDR_WIDTH - 1:2])) begin
						v_addr_hit = 1'b1;
						v_rdata_r[9:0] <= s_reg_layer_config_in_features_count_r;
						v_state_r <= 32'd3;
					end
					if (s_axi_araddr_reg_r[AXI_ADDR_WIDTH - 1:2] == (BASEADDR[AXI_ADDR_WIDTH - 1:2] + feature_transformation_engine_regbank_regs_pkg_LAYER_CONFIG_OUT_FEATURES_OFFSET[AXI_ADDR_WIDTH - 1:2])) begin
						v_addr_hit = 1'b1;
						v_rdata_r[9:0] <= s_reg_layer_config_out_features_count_r;
						v_state_r <= 32'd3;
					end
					if (s_axi_araddr_reg_r[AXI_ADDR_WIDTH - 1:2] == (BASEADDR[AXI_ADDR_WIDTH - 1:2] + feature_transformation_engine_regbank_regs_pkg_LAYER_CONFIG_ACTIVATION_FUNCTION_OFFSET[AXI_ADDR_WIDTH - 1:2])) begin
						v_addr_hit = 1'b1;
						v_rdata_r[1:0] <= s_reg_layer_config_activation_function_value_r;
						v_state_r <= 32'd3;
					end
					if (s_axi_araddr_reg_r[AXI_ADDR_WIDTH - 1:2] == (BASEADDR[AXI_ADDR_WIDTH - 1:2] + feature_transformation_engine_regbank_regs_pkg_LAYER_CONFIG_BIAS_OFFSET[AXI_ADDR_WIDTH - 1:2])) begin
						v_addr_hit = 1'b1;
						v_rdata_r[31:0] <= s_reg_layer_config_bias_value_r;
						v_state_r <= 32'd3;
					end
					if (s_axi_araddr_reg_r[AXI_ADDR_WIDTH - 1:2] == (BASEADDR[AXI_ADDR_WIDTH - 1:2] + feature_transformation_engine_regbank_regs_pkg_LAYER_CONFIG_LEAKY_RELU_ALPHA_OFFSET[AXI_ADDR_WIDTH - 1:2])) begin
						v_addr_hit = 1'b1;
						v_rdata_r[31:0] <= s_reg_layer_config_leaky_relu_alpha_value_r;
						v_state_r <= 32'd3;
					end
					if (s_axi_araddr_reg_r[AXI_ADDR_WIDTH - 1:2] == (BASEADDR[AXI_ADDR_WIDTH - 1:2] + feature_transformation_engine_regbank_regs_pkg_LAYER_CONFIG_OUT_FEATURES_ADDRESS_MSB_OFFSET[AXI_ADDR_WIDTH - 1:2])) begin
						v_addr_hit = 1'b1;
						v_rdata_r[1:0] <= s_reg_layer_config_out_features_address_msb_value_r;
						v_state_r <= 32'd3;
					end
					if (s_axi_araddr_reg_r[AXI_ADDR_WIDTH - 1:2] == (BASEADDR[AXI_ADDR_WIDTH - 1:2] + feature_transformation_engine_regbank_regs_pkg_LAYER_CONFIG_OUT_FEATURES_ADDRESS_LSB_OFFSET[AXI_ADDR_WIDTH - 1:2])) begin
						v_addr_hit = 1'b1;
						v_rdata_r[31:0] <= s_reg_layer_config_out_features_address_lsb_value_r;
						v_state_r <= 32'd3;
					end
					if (s_axi_araddr_reg_r[AXI_ADDR_WIDTH - 1:2] == (BASEADDR[AXI_ADDR_WIDTH - 1:2] + feature_transformation_engine_regbank_regs_pkg_CTRL_BUFFERING_ENABLE_OFFSET[AXI_ADDR_WIDTH - 1:2])) begin
						v_addr_hit = 1'b1;
						v_rdata_r[0:0] <= s_reg_ctrl_buffering_enable_value_r;
						v_state_r <= 32'd3;
					end
					if (s_axi_araddr_reg_r[AXI_ADDR_WIDTH - 1:2] == (BASEADDR[AXI_ADDR_WIDTH - 1:2] + feature_transformation_engine_regbank_regs_pkg_CTRL_WRITEBACK_ENABLE_OFFSET[AXI_ADDR_WIDTH - 1:2])) begin
						v_addr_hit = 1'b1;
						v_rdata_r[0:0] <= s_reg_ctrl_writeback_enable_value_r;
						v_state_r <= 32'd3;
					end
					if (v_addr_hit)
						v_rresp_r <= AXI_OKAY;
					else begin
						v_rresp_r <= AXI_SLVERR;
						$warning("ARADDR decode error");
						v_state_r <= 32'd3;
					end
				end
				32'd2:
					if (v_mem_wait_count_r == 0)
						v_state_r <= 32'd3;
					else
						v_mem_wait_count_r <= v_mem_wait_count_r - 1;
				32'd3: begin
					s_axi_rvalid_r <= 1'b1;
					s_axi_rresp_r <= v_rresp_r;
					s_axi_rdata_r <= v_rdata_r;
					v_state_r <= 32'd4;
				end
				32'd4:
					if (s_axi_rready) begin
						s_axi_rvalid_r <= 1'b0;
						s_axi_rdata_r <= 1'sb0;
						v_state_r <= 32'd0;
					end
			endcase
		end
	end
	localparam [0:0] feature_transformation_engine_regbank_regs_pkg_CTRL_BUFFERING_ENABLE_VALUE_RESET = 1'b0;
	localparam [0:0] feature_transformation_engine_regbank_regs_pkg_CTRL_WRITEBACK_ENABLE_VALUE_RESET = 1'b1;
	localparam [1:0] feature_transformation_engine_regbank_regs_pkg_LAYER_CONFIG_ACTIVATION_FUNCTION_VALUE_RESET = 2'b00;
	localparam [31:0] feature_transformation_engine_regbank_regs_pkg_LAYER_CONFIG_BIAS_VALUE_RESET = 32'b00000000000000000000000000000000;
	localparam [9:0] feature_transformation_engine_regbank_regs_pkg_LAYER_CONFIG_IN_FEATURES_COUNT_RESET = 10'b0000000000;
	localparam [31:0] feature_transformation_engine_regbank_regs_pkg_LAYER_CONFIG_LEAKY_RELU_ALPHA_VALUE_RESET = 32'b00000000000000000000000000000000;
	localparam [31:0] feature_transformation_engine_regbank_regs_pkg_LAYER_CONFIG_OUT_FEATURES_ADDRESS_LSB_VALUE_RESET = 32'b00000000000000000000000000000000;
	localparam [1:0] feature_transformation_engine_regbank_regs_pkg_LAYER_CONFIG_OUT_FEATURES_ADDRESS_MSB_VALUE_RESET = 2'b00;
	localparam [9:0] feature_transformation_engine_regbank_regs_pkg_LAYER_CONFIG_OUT_FEATURES_COUNT_RESET = 10'b0000000000;
	always @(posedge axi_aclk or negedge axi_aresetn) begin : write_fsm
		reg [31:0] v_state_r;
		reg v_addr_hit;
		reg [AXI_ADDR_WIDTH - 1:0] v_mem_addr;
		if (~axi_aresetn) begin
			v_state_r <= 32'd0;
			s_axi_awready_r <= 1'b0;
			s_axi_wready_r <= 1'b0;
			s_axi_awaddr_reg_r <= 1'sb0;
			s_axi_wdata_reg_r <= 1'sb0;
			s_axi_wstrb_reg_r <= 1'sb0;
			s_axi_bvalid_r <= 1'b0;
			s_axi_bresp_r <= 1'sb0;
			s_layer_config_in_features_strobe_r <= 1'sb0;
			s_reg_layer_config_in_features_count_r <= feature_transformation_engine_regbank_regs_pkg_LAYER_CONFIG_IN_FEATURES_COUNT_RESET;
			s_layer_config_out_features_strobe_r <= 1'sb0;
			s_reg_layer_config_out_features_count_r <= feature_transformation_engine_regbank_regs_pkg_LAYER_CONFIG_OUT_FEATURES_COUNT_RESET;
			s_layer_config_activation_function_strobe_r <= 1'sb0;
			s_reg_layer_config_activation_function_value_r <= feature_transformation_engine_regbank_regs_pkg_LAYER_CONFIG_ACTIVATION_FUNCTION_VALUE_RESET;
			s_layer_config_bias_strobe_r <= 1'sb0;
			s_reg_layer_config_bias_value_r <= feature_transformation_engine_regbank_regs_pkg_LAYER_CONFIG_BIAS_VALUE_RESET;
			s_layer_config_leaky_relu_alpha_strobe_r <= 1'sb0;
			s_reg_layer_config_leaky_relu_alpha_value_r <= feature_transformation_engine_regbank_regs_pkg_LAYER_CONFIG_LEAKY_RELU_ALPHA_VALUE_RESET;
			s_layer_config_out_features_address_msb_strobe_r <= 1'sb0;
			s_reg_layer_config_out_features_address_msb_value_r <= feature_transformation_engine_regbank_regs_pkg_LAYER_CONFIG_OUT_FEATURES_ADDRESS_MSB_VALUE_RESET;
			s_layer_config_out_features_address_lsb_strobe_r <= 1'sb0;
			s_reg_layer_config_out_features_address_lsb_value_r <= feature_transformation_engine_regbank_regs_pkg_LAYER_CONFIG_OUT_FEATURES_ADDRESS_LSB_VALUE_RESET;
			s_ctrl_buffering_enable_strobe_r <= 1'sb0;
			s_reg_ctrl_buffering_enable_value_r <= feature_transformation_engine_regbank_regs_pkg_CTRL_BUFFERING_ENABLE_VALUE_RESET;
			s_ctrl_writeback_enable_strobe_r <= 1'sb0;
			s_reg_ctrl_writeback_enable_value_r <= feature_transformation_engine_regbank_regs_pkg_CTRL_WRITEBACK_ENABLE_VALUE_RESET;
		end
		else begin
			s_axi_awready_r <= 1'b0;
			s_axi_wready_r <= 1'b0;
			s_layer_config_in_features_strobe_r <= 1'sb0;
			s_layer_config_out_features_strobe_r <= 1'sb0;
			s_layer_config_activation_function_strobe_r <= 1'sb0;
			s_layer_config_bias_strobe_r <= 1'sb0;
			s_layer_config_leaky_relu_alpha_strobe_r <= 1'sb0;
			s_layer_config_out_features_address_msb_strobe_r <= 1'sb0;
			s_layer_config_out_features_address_lsb_strobe_r <= 1'sb0;
			s_ctrl_buffering_enable_strobe_r <= 1'sb0;
			s_ctrl_writeback_enable_strobe_r <= 1'sb0;
			v_addr_hit = 1'b0;
			case (v_state_r)
				32'd0:
					if (s_axi_awvalid && s_axi_wvalid) begin
						s_axi_awaddr_reg_r <= s_axi_awaddr;
						s_axi_awready_r <= 1'b1;
						s_axi_wdata_reg_r <= s_axi_wdata;
						s_axi_wstrb_reg_r <= s_axi_wstrb;
						s_axi_wready_r <= 1'b1;
						v_state_r <= 32'd3;
					end
					else if (s_axi_awvalid) begin
						s_axi_awaddr_reg_r <= s_axi_awaddr;
						s_axi_awready_r <= 1'b1;
						v_state_r <= 32'd1;
					end
					else if (s_axi_wvalid) begin
						s_axi_wdata_reg_r <= s_axi_wdata;
						s_axi_wstrb_reg_r <= s_axi_wstrb;
						s_axi_wready_r <= 1'b1;
						v_state_r <= 32'd2;
					end
				32'd1:
					if (s_axi_wvalid) begin
						s_axi_wdata_reg_r <= s_axi_wdata;
						s_axi_wstrb_reg_r <= s_axi_wstrb;
						s_axi_wready_r <= 1'b1;
						v_state_r <= 32'd3;
					end
				32'd2:
					if (s_axi_awvalid) begin
						s_axi_awaddr_reg_r <= s_axi_awaddr;
						s_axi_awready_r <= 1'b1;
						v_state_r <= 32'd3;
					end
				32'd3: begin
					s_axi_bresp_r <= AXI_OKAY;
					s_axi_bvalid_r <= 1'b1;
					if (s_axi_awaddr_reg_r[AXI_ADDR_WIDTH - 1:2] == (BASEADDR[AXI_ADDR_WIDTH - 1:2] + feature_transformation_engine_regbank_regs_pkg_LAYER_CONFIG_IN_FEATURES_OFFSET[AXI_ADDR_WIDTH - 1:2])) begin
						v_addr_hit = 1'b1;
						s_layer_config_in_features_strobe_r <= 1'b1;
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_in_features_count_r[0] <= s_axi_wdata_reg_r[0];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_in_features_count_r[1] <= s_axi_wdata_reg_r[1];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_in_features_count_r[2] <= s_axi_wdata_reg_r[2];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_in_features_count_r[3] <= s_axi_wdata_reg_r[3];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_in_features_count_r[4] <= s_axi_wdata_reg_r[4];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_in_features_count_r[5] <= s_axi_wdata_reg_r[5];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_in_features_count_r[6] <= s_axi_wdata_reg_r[6];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_in_features_count_r[7] <= s_axi_wdata_reg_r[7];
						if (s_axi_wstrb_reg_r[1])
							s_reg_layer_config_in_features_count_r[8] <= s_axi_wdata_reg_r[8];
						if (s_axi_wstrb_reg_r[1])
							s_reg_layer_config_in_features_count_r[9] <= s_axi_wdata_reg_r[9];
					end
					if (s_axi_awaddr_reg_r[AXI_ADDR_WIDTH - 1:2] == (BASEADDR[AXI_ADDR_WIDTH - 1:2] + feature_transformation_engine_regbank_regs_pkg_LAYER_CONFIG_OUT_FEATURES_OFFSET[AXI_ADDR_WIDTH - 1:2])) begin
						v_addr_hit = 1'b1;
						s_layer_config_out_features_strobe_r <= 1'b1;
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_out_features_count_r[0] <= s_axi_wdata_reg_r[0];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_out_features_count_r[1] <= s_axi_wdata_reg_r[1];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_out_features_count_r[2] <= s_axi_wdata_reg_r[2];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_out_features_count_r[3] <= s_axi_wdata_reg_r[3];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_out_features_count_r[4] <= s_axi_wdata_reg_r[4];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_out_features_count_r[5] <= s_axi_wdata_reg_r[5];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_out_features_count_r[6] <= s_axi_wdata_reg_r[6];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_out_features_count_r[7] <= s_axi_wdata_reg_r[7];
						if (s_axi_wstrb_reg_r[1])
							s_reg_layer_config_out_features_count_r[8] <= s_axi_wdata_reg_r[8];
						if (s_axi_wstrb_reg_r[1])
							s_reg_layer_config_out_features_count_r[9] <= s_axi_wdata_reg_r[9];
					end
					if (s_axi_awaddr_reg_r[AXI_ADDR_WIDTH - 1:2] == (BASEADDR[AXI_ADDR_WIDTH - 1:2] + feature_transformation_engine_regbank_regs_pkg_LAYER_CONFIG_ACTIVATION_FUNCTION_OFFSET[AXI_ADDR_WIDTH - 1:2])) begin
						v_addr_hit = 1'b1;
						s_layer_config_activation_function_strobe_r <= 1'b1;
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_activation_function_value_r[0] <= s_axi_wdata_reg_r[0];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_activation_function_value_r[1] <= s_axi_wdata_reg_r[1];
					end
					if (s_axi_awaddr_reg_r[AXI_ADDR_WIDTH - 1:2] == (BASEADDR[AXI_ADDR_WIDTH - 1:2] + feature_transformation_engine_regbank_regs_pkg_LAYER_CONFIG_BIAS_OFFSET[AXI_ADDR_WIDTH - 1:2])) begin
						v_addr_hit = 1'b1;
						s_layer_config_bias_strobe_r <= 1'b1;
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_bias_value_r[0] <= s_axi_wdata_reg_r[0];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_bias_value_r[1] <= s_axi_wdata_reg_r[1];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_bias_value_r[2] <= s_axi_wdata_reg_r[2];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_bias_value_r[3] <= s_axi_wdata_reg_r[3];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_bias_value_r[4] <= s_axi_wdata_reg_r[4];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_bias_value_r[5] <= s_axi_wdata_reg_r[5];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_bias_value_r[6] <= s_axi_wdata_reg_r[6];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_bias_value_r[7] <= s_axi_wdata_reg_r[7];
						if (s_axi_wstrb_reg_r[1])
							s_reg_layer_config_bias_value_r[8] <= s_axi_wdata_reg_r[8];
						if (s_axi_wstrb_reg_r[1])
							s_reg_layer_config_bias_value_r[9] <= s_axi_wdata_reg_r[9];
						if (s_axi_wstrb_reg_r[1])
							s_reg_layer_config_bias_value_r[10] <= s_axi_wdata_reg_r[10];
						if (s_axi_wstrb_reg_r[1])
							s_reg_layer_config_bias_value_r[11] <= s_axi_wdata_reg_r[11];
						if (s_axi_wstrb_reg_r[1])
							s_reg_layer_config_bias_value_r[12] <= s_axi_wdata_reg_r[12];
						if (s_axi_wstrb_reg_r[1])
							s_reg_layer_config_bias_value_r[13] <= s_axi_wdata_reg_r[13];
						if (s_axi_wstrb_reg_r[1])
							s_reg_layer_config_bias_value_r[14] <= s_axi_wdata_reg_r[14];
						if (s_axi_wstrb_reg_r[1])
							s_reg_layer_config_bias_value_r[15] <= s_axi_wdata_reg_r[15];
						if (s_axi_wstrb_reg_r[2])
							s_reg_layer_config_bias_value_r[16] <= s_axi_wdata_reg_r[16];
						if (s_axi_wstrb_reg_r[2])
							s_reg_layer_config_bias_value_r[17] <= s_axi_wdata_reg_r[17];
						if (s_axi_wstrb_reg_r[2])
							s_reg_layer_config_bias_value_r[18] <= s_axi_wdata_reg_r[18];
						if (s_axi_wstrb_reg_r[2])
							s_reg_layer_config_bias_value_r[19] <= s_axi_wdata_reg_r[19];
						if (s_axi_wstrb_reg_r[2])
							s_reg_layer_config_bias_value_r[20] <= s_axi_wdata_reg_r[20];
						if (s_axi_wstrb_reg_r[2])
							s_reg_layer_config_bias_value_r[21] <= s_axi_wdata_reg_r[21];
						if (s_axi_wstrb_reg_r[2])
							s_reg_layer_config_bias_value_r[22] <= s_axi_wdata_reg_r[22];
						if (s_axi_wstrb_reg_r[2])
							s_reg_layer_config_bias_value_r[23] <= s_axi_wdata_reg_r[23];
						if (s_axi_wstrb_reg_r[3])
							s_reg_layer_config_bias_value_r[24] <= s_axi_wdata_reg_r[24];
						if (s_axi_wstrb_reg_r[3])
							s_reg_layer_config_bias_value_r[25] <= s_axi_wdata_reg_r[25];
						if (s_axi_wstrb_reg_r[3])
							s_reg_layer_config_bias_value_r[26] <= s_axi_wdata_reg_r[26];
						if (s_axi_wstrb_reg_r[3])
							s_reg_layer_config_bias_value_r[27] <= s_axi_wdata_reg_r[27];
						if (s_axi_wstrb_reg_r[3])
							s_reg_layer_config_bias_value_r[28] <= s_axi_wdata_reg_r[28];
						if (s_axi_wstrb_reg_r[3])
							s_reg_layer_config_bias_value_r[29] <= s_axi_wdata_reg_r[29];
						if (s_axi_wstrb_reg_r[3])
							s_reg_layer_config_bias_value_r[30] <= s_axi_wdata_reg_r[30];
						if (s_axi_wstrb_reg_r[3])
							s_reg_layer_config_bias_value_r[31] <= s_axi_wdata_reg_r[31];
					end
					if (s_axi_awaddr_reg_r[AXI_ADDR_WIDTH - 1:2] == (BASEADDR[AXI_ADDR_WIDTH - 1:2] + feature_transformation_engine_regbank_regs_pkg_LAYER_CONFIG_LEAKY_RELU_ALPHA_OFFSET[AXI_ADDR_WIDTH - 1:2])) begin
						v_addr_hit = 1'b1;
						s_layer_config_leaky_relu_alpha_strobe_r <= 1'b1;
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_leaky_relu_alpha_value_r[0] <= s_axi_wdata_reg_r[0];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_leaky_relu_alpha_value_r[1] <= s_axi_wdata_reg_r[1];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_leaky_relu_alpha_value_r[2] <= s_axi_wdata_reg_r[2];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_leaky_relu_alpha_value_r[3] <= s_axi_wdata_reg_r[3];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_leaky_relu_alpha_value_r[4] <= s_axi_wdata_reg_r[4];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_leaky_relu_alpha_value_r[5] <= s_axi_wdata_reg_r[5];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_leaky_relu_alpha_value_r[6] <= s_axi_wdata_reg_r[6];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_leaky_relu_alpha_value_r[7] <= s_axi_wdata_reg_r[7];
						if (s_axi_wstrb_reg_r[1])
							s_reg_layer_config_leaky_relu_alpha_value_r[8] <= s_axi_wdata_reg_r[8];
						if (s_axi_wstrb_reg_r[1])
							s_reg_layer_config_leaky_relu_alpha_value_r[9] <= s_axi_wdata_reg_r[9];
						if (s_axi_wstrb_reg_r[1])
							s_reg_layer_config_leaky_relu_alpha_value_r[10] <= s_axi_wdata_reg_r[10];
						if (s_axi_wstrb_reg_r[1])
							s_reg_layer_config_leaky_relu_alpha_value_r[11] <= s_axi_wdata_reg_r[11];
						if (s_axi_wstrb_reg_r[1])
							s_reg_layer_config_leaky_relu_alpha_value_r[12] <= s_axi_wdata_reg_r[12];
						if (s_axi_wstrb_reg_r[1])
							s_reg_layer_config_leaky_relu_alpha_value_r[13] <= s_axi_wdata_reg_r[13];
						if (s_axi_wstrb_reg_r[1])
							s_reg_layer_config_leaky_relu_alpha_value_r[14] <= s_axi_wdata_reg_r[14];
						if (s_axi_wstrb_reg_r[1])
							s_reg_layer_config_leaky_relu_alpha_value_r[15] <= s_axi_wdata_reg_r[15];
						if (s_axi_wstrb_reg_r[2])
							s_reg_layer_config_leaky_relu_alpha_value_r[16] <= s_axi_wdata_reg_r[16];
						if (s_axi_wstrb_reg_r[2])
							s_reg_layer_config_leaky_relu_alpha_value_r[17] <= s_axi_wdata_reg_r[17];
						if (s_axi_wstrb_reg_r[2])
							s_reg_layer_config_leaky_relu_alpha_value_r[18] <= s_axi_wdata_reg_r[18];
						if (s_axi_wstrb_reg_r[2])
							s_reg_layer_config_leaky_relu_alpha_value_r[19] <= s_axi_wdata_reg_r[19];
						if (s_axi_wstrb_reg_r[2])
							s_reg_layer_config_leaky_relu_alpha_value_r[20] <= s_axi_wdata_reg_r[20];
						if (s_axi_wstrb_reg_r[2])
							s_reg_layer_config_leaky_relu_alpha_value_r[21] <= s_axi_wdata_reg_r[21];
						if (s_axi_wstrb_reg_r[2])
							s_reg_layer_config_leaky_relu_alpha_value_r[22] <= s_axi_wdata_reg_r[22];
						if (s_axi_wstrb_reg_r[2])
							s_reg_layer_config_leaky_relu_alpha_value_r[23] <= s_axi_wdata_reg_r[23];
						if (s_axi_wstrb_reg_r[3])
							s_reg_layer_config_leaky_relu_alpha_value_r[24] <= s_axi_wdata_reg_r[24];
						if (s_axi_wstrb_reg_r[3])
							s_reg_layer_config_leaky_relu_alpha_value_r[25] <= s_axi_wdata_reg_r[25];
						if (s_axi_wstrb_reg_r[3])
							s_reg_layer_config_leaky_relu_alpha_value_r[26] <= s_axi_wdata_reg_r[26];
						if (s_axi_wstrb_reg_r[3])
							s_reg_layer_config_leaky_relu_alpha_value_r[27] <= s_axi_wdata_reg_r[27];
						if (s_axi_wstrb_reg_r[3])
							s_reg_layer_config_leaky_relu_alpha_value_r[28] <= s_axi_wdata_reg_r[28];
						if (s_axi_wstrb_reg_r[3])
							s_reg_layer_config_leaky_relu_alpha_value_r[29] <= s_axi_wdata_reg_r[29];
						if (s_axi_wstrb_reg_r[3])
							s_reg_layer_config_leaky_relu_alpha_value_r[30] <= s_axi_wdata_reg_r[30];
						if (s_axi_wstrb_reg_r[3])
							s_reg_layer_config_leaky_relu_alpha_value_r[31] <= s_axi_wdata_reg_r[31];
					end
					if (s_axi_awaddr_reg_r[AXI_ADDR_WIDTH - 1:2] == (BASEADDR[AXI_ADDR_WIDTH - 1:2] + feature_transformation_engine_regbank_regs_pkg_LAYER_CONFIG_OUT_FEATURES_ADDRESS_MSB_OFFSET[AXI_ADDR_WIDTH - 1:2])) begin
						v_addr_hit = 1'b1;
						s_layer_config_out_features_address_msb_strobe_r <= 1'b1;
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_out_features_address_msb_value_r[0] <= s_axi_wdata_reg_r[0];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_out_features_address_msb_value_r[1] <= s_axi_wdata_reg_r[1];
					end
					if (s_axi_awaddr_reg_r[AXI_ADDR_WIDTH - 1:2] == (BASEADDR[AXI_ADDR_WIDTH - 1:2] + feature_transformation_engine_regbank_regs_pkg_LAYER_CONFIG_OUT_FEATURES_ADDRESS_LSB_OFFSET[AXI_ADDR_WIDTH - 1:2])) begin
						v_addr_hit = 1'b1;
						s_layer_config_out_features_address_lsb_strobe_r <= 1'b1;
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_out_features_address_lsb_value_r[0] <= s_axi_wdata_reg_r[0];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_out_features_address_lsb_value_r[1] <= s_axi_wdata_reg_r[1];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_out_features_address_lsb_value_r[2] <= s_axi_wdata_reg_r[2];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_out_features_address_lsb_value_r[3] <= s_axi_wdata_reg_r[3];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_out_features_address_lsb_value_r[4] <= s_axi_wdata_reg_r[4];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_out_features_address_lsb_value_r[5] <= s_axi_wdata_reg_r[5];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_out_features_address_lsb_value_r[6] <= s_axi_wdata_reg_r[6];
						if (s_axi_wstrb_reg_r[0])
							s_reg_layer_config_out_features_address_lsb_value_r[7] <= s_axi_wdata_reg_r[7];
						if (s_axi_wstrb_reg_r[1])
							s_reg_layer_config_out_features_address_lsb_value_r[8] <= s_axi_wdata_reg_r[8];
						if (s_axi_wstrb_reg_r[1])
							s_reg_layer_config_out_features_address_lsb_value_r[9] <= s_axi_wdata_reg_r[9];
						if (s_axi_wstrb_reg_r[1])
							s_reg_layer_config_out_features_address_lsb_value_r[10] <= s_axi_wdata_reg_r[10];
						if (s_axi_wstrb_reg_r[1])
							s_reg_layer_config_out_features_address_lsb_value_r[11] <= s_axi_wdata_reg_r[11];
						if (s_axi_wstrb_reg_r[1])
							s_reg_layer_config_out_features_address_lsb_value_r[12] <= s_axi_wdata_reg_r[12];
						if (s_axi_wstrb_reg_r[1])
							s_reg_layer_config_out_features_address_lsb_value_r[13] <= s_axi_wdata_reg_r[13];
						if (s_axi_wstrb_reg_r[1])
							s_reg_layer_config_out_features_address_lsb_value_r[14] <= s_axi_wdata_reg_r[14];
						if (s_axi_wstrb_reg_r[1])
							s_reg_layer_config_out_features_address_lsb_value_r[15] <= s_axi_wdata_reg_r[15];
						if (s_axi_wstrb_reg_r[2])
							s_reg_layer_config_out_features_address_lsb_value_r[16] <= s_axi_wdata_reg_r[16];
						if (s_axi_wstrb_reg_r[2])
							s_reg_layer_config_out_features_address_lsb_value_r[17] <= s_axi_wdata_reg_r[17];
						if (s_axi_wstrb_reg_r[2])
							s_reg_layer_config_out_features_address_lsb_value_r[18] <= s_axi_wdata_reg_r[18];
						if (s_axi_wstrb_reg_r[2])
							s_reg_layer_config_out_features_address_lsb_value_r[19] <= s_axi_wdata_reg_r[19];
						if (s_axi_wstrb_reg_r[2])
							s_reg_layer_config_out_features_address_lsb_value_r[20] <= s_axi_wdata_reg_r[20];
						if (s_axi_wstrb_reg_r[2])
							s_reg_layer_config_out_features_address_lsb_value_r[21] <= s_axi_wdata_reg_r[21];
						if (s_axi_wstrb_reg_r[2])
							s_reg_layer_config_out_features_address_lsb_value_r[22] <= s_axi_wdata_reg_r[22];
						if (s_axi_wstrb_reg_r[2])
							s_reg_layer_config_out_features_address_lsb_value_r[23] <= s_axi_wdata_reg_r[23];
						if (s_axi_wstrb_reg_r[3])
							s_reg_layer_config_out_features_address_lsb_value_r[24] <= s_axi_wdata_reg_r[24];
						if (s_axi_wstrb_reg_r[3])
							s_reg_layer_config_out_features_address_lsb_value_r[25] <= s_axi_wdata_reg_r[25];
						if (s_axi_wstrb_reg_r[3])
							s_reg_layer_config_out_features_address_lsb_value_r[26] <= s_axi_wdata_reg_r[26];
						if (s_axi_wstrb_reg_r[3])
							s_reg_layer_config_out_features_address_lsb_value_r[27] <= s_axi_wdata_reg_r[27];
						if (s_axi_wstrb_reg_r[3])
							s_reg_layer_config_out_features_address_lsb_value_r[28] <= s_axi_wdata_reg_r[28];
						if (s_axi_wstrb_reg_r[3])
							s_reg_layer_config_out_features_address_lsb_value_r[29] <= s_axi_wdata_reg_r[29];
						if (s_axi_wstrb_reg_r[3])
							s_reg_layer_config_out_features_address_lsb_value_r[30] <= s_axi_wdata_reg_r[30];
						if (s_axi_wstrb_reg_r[3])
							s_reg_layer_config_out_features_address_lsb_value_r[31] <= s_axi_wdata_reg_r[31];
					end
					if (s_axi_awaddr_reg_r[AXI_ADDR_WIDTH - 1:2] == (BASEADDR[AXI_ADDR_WIDTH - 1:2] + feature_transformation_engine_regbank_regs_pkg_CTRL_BUFFERING_ENABLE_OFFSET[AXI_ADDR_WIDTH - 1:2])) begin
						v_addr_hit = 1'b1;
						s_ctrl_buffering_enable_strobe_r <= 1'b1;
						if (s_axi_wstrb_reg_r[0])
							s_reg_ctrl_buffering_enable_value_r[0] <= s_axi_wdata_reg_r[0];
					end
					if (s_axi_awaddr_reg_r[AXI_ADDR_WIDTH - 1:2] == (BASEADDR[AXI_ADDR_WIDTH - 1:2] + feature_transformation_engine_regbank_regs_pkg_CTRL_WRITEBACK_ENABLE_OFFSET[AXI_ADDR_WIDTH - 1:2])) begin
						v_addr_hit = 1'b1;
						s_ctrl_writeback_enable_strobe_r <= 1'b1;
						if (s_axi_wstrb_reg_r[0])
							s_reg_ctrl_writeback_enable_value_r[0] <= s_axi_wdata_reg_r[0];
					end
					if (!v_addr_hit) begin
						s_axi_bresp_r <= AXI_SLVERR;
						$warning("AWADDR decode error");
					end
					v_state_r <= 32'd4;
				end
				32'd4:
					if (s_axi_bready) begin
						s_axi_bvalid_r <= 1'b0;
						v_state_r <= 32'd0;
					end
			endcase
		end
	end
	assign s_axi_awready = s_axi_awready_r;
	assign s_axi_wready = s_axi_wready_r;
	assign s_axi_bvalid = s_axi_bvalid_r;
	assign s_axi_bresp = s_axi_bresp_r;
	assign s_axi_arready = s_axi_arready_r;
	assign s_axi_rvalid = s_axi_rvalid_r;
	assign s_axi_rresp = s_axi_rresp_r;
	assign s_axi_rdata = s_axi_rdata_r;
	assign layer_config_in_features_strobe = s_layer_config_in_features_strobe_r;
	assign layer_config_in_features_count = s_reg_layer_config_in_features_count_r;
	assign layer_config_out_features_strobe = s_layer_config_out_features_strobe_r;
	assign layer_config_out_features_count = s_reg_layer_config_out_features_count_r;
	assign layer_config_activation_function_strobe = s_layer_config_activation_function_strobe_r;
	assign layer_config_activation_function_value = s_reg_layer_config_activation_function_value_r;
	assign layer_config_bias_strobe = s_layer_config_bias_strobe_r;
	assign layer_config_bias_value = s_reg_layer_config_bias_value_r;
	assign layer_config_leaky_relu_alpha_strobe = s_layer_config_leaky_relu_alpha_strobe_r;
	assign layer_config_leaky_relu_alpha_value = s_reg_layer_config_leaky_relu_alpha_value_r;
	assign layer_config_out_features_address_msb_strobe = s_layer_config_out_features_address_msb_strobe_r;
	assign layer_config_out_features_address_msb_value = s_reg_layer_config_out_features_address_msb_value_r;
	assign layer_config_out_features_address_lsb_strobe = s_layer_config_out_features_address_lsb_strobe_r;
	assign layer_config_out_features_address_lsb_value = s_reg_layer_config_out_features_address_lsb_value_r;
	assign ctrl_buffering_enable_strobe = s_ctrl_buffering_enable_strobe_r;
	assign ctrl_buffering_enable_value = s_reg_ctrl_buffering_enable_value_r;
	assign ctrl_writeback_enable_strobe = s_ctrl_writeback_enable_strobe_r;
	assign ctrl_writeback_enable_value = s_reg_ctrl_writeback_enable_value_r;
endmodule
`resetall
module passthrough_aggregator (
	core_clk,
	resetn,
	in_feature_valid,
	in_feature,
	out_feature_valid,
	out_feature
);
	parameter DATA_WIDTH = 32;
	parameter PRECISION = "FLOAT_32";
	input wire core_clk;
	input wire resetn;
	input wire in_feature_valid;
	input wire [DATA_WIDTH - 1:0] in_feature;
	output wire out_feature_valid;
	output wire [DATA_WIDTH - 1:0] out_feature;
	assign out_feature = in_feature;
	assign out_feature_valid = in_feature_valid;
endmodule
module sum_aggregator (
	core_clk,
	resetn,
	in_feature_valid,
	in_feature,
	acc_feature,
	out_feature_valid,
	out_feature
);
	parameter DATA_WIDTH = 32;
	parameter PRECISION = "FLOAT_32";
	input wire core_clk;
	input wire resetn;
	input wire in_feature_valid;
	input wire [DATA_WIDTH - 1:0] in_feature;
	input wire [DATA_WIDTH - 1:0] acc_feature;
	output wire out_feature_valid;
	output wire [DATA_WIDTH - 1:0] out_feature;
	generate
		if (PRECISION == "FLOAT_32") begin : genblk1
			fp_add fp_add_i(
				.s_axis_a_tvalid(in_feature_valid),
				.s_axis_a_tdata(acc_feature),
				.s_axis_b_tvalid(in_feature_valid),
				.s_axis_b_tdata(in_feature),
				.m_axis_result_tvalid(out_feature_valid),
				.m_axis_result_tdata(out_feature)
			);
		end
		else begin : genblk1
			assign out_feature_valid = in_feature_valid;
			assign out_feature = acc_feature + in_feature;
		end
	endgenerate
endmodule
module feature_aggregator (
	core_clk,
	resetn,
	aggregation_function_sel,
	in_feature_valid,
	in_feature_ready,
	in_feature,
	scale_factor,
	feature_updated,
	accumulator,
	reset_accumulator,
	upsample,
	upsampled_accumulator_valid,
	upsampled_accumulator,
	layer_config_upsampling_parameter
);
	parameter DATA_WIDTH = 32;
	parameter FLOAT_WIDTH = 32;
	parameter PRECISION = "FLOAT_32";
	input wire core_clk;
	input wire resetn;
	input wire [1:0] aggregation_function_sel;
	input wire in_feature_valid;
	output reg in_feature_ready;
	input wire [DATA_WIDTH - 1:0] in_feature;
	input wire [FLOAT_WIDTH - 1:0] scale_factor;
	output reg feature_updated;
	output reg [DATA_WIDTH - 1:0] accumulator;
	input wire reset_accumulator;
	input wire upsample;
	output reg upsampled_accumulator_valid;
	output reg [FLOAT_WIDTH - 1:0] upsampled_accumulator;
	input wire [31:0] layer_config_upsampling_parameter;
	reg passthrough_aggregator_in_feature_valid;
	reg sum_aggregator_in_feature_valid;
	wire [DATA_WIDTH - 1:0] passthrough_aggregator_out_feature;
	wire passthrough_aggregator_out_valid;
	wire [DATA_WIDTH - 1:0] sum_aggregator_out_feature;
	wire sum_aggregator_out_valid;
	wire scaled_feature_valid_comb;
	reg scaled_feature_valid;
	wire [FLOAT_WIDTH - 1:0] scaled_feature_comb;
	reg [FLOAT_WIDTH - 1:0] scaled_feature;
	localparam top_pkg_MAX_FEATURE_COUNT = 1024;
	reg [9:0] feature_accumulation_count;
	reg busy;
	wire accumulator_float_valid;
	wire [FLOAT_WIDTH - 1:0] accumulator_float;
	wire upsampled_accumulator_valid_comb;
	wire [FLOAT_WIDTH - 1:0] upsampled_accumulator_comb;
	generate
		if (PRECISION == "FLOAT_32") begin : genblk1
			fp_mult scale_factor_mult(
				.s_axis_a_tvalid(in_feature_valid && in_feature_ready),
				.s_axis_a_tdata(scale_factor),
				.s_axis_b_tvalid(in_feature_valid && in_feature_ready),
				.s_axis_b_tdata(in_feature),
				.m_axis_result_tvalid(scaled_feature_valid_comb),
				.m_axis_result_tdata(scaled_feature_comb)
			);
		end
		else begin : genblk1
			assign scaled_feature_valid_comb = in_feature_valid && in_feature_ready;
			assign scaled_feature_comb = scale_factor[DATA_WIDTH - 1:0] * in_feature[DATA_WIDTH - 1:0];
		end
	endgenerate
	always @(posedge core_clk or negedge resetn)
		if (!resetn) begin
			scaled_feature_valid <= 1'sb0;
			scaled_feature <= 1'sb0;
		end
		else begin
			scaled_feature_valid <= scaled_feature_valid_comb;
			scaled_feature <= scaled_feature_comb;
		end
	passthrough_aggregator #(
		.DATA_WIDTH(DATA_WIDTH),
		.PRECISION(PRECISION)
	) passthrough_aggregator_i(
		.core_clk(core_clk),
		.resetn(resetn),
		.in_feature_valid(busy && passthrough_aggregator_in_feature_valid),
		.in_feature(scaled_feature[DATA_WIDTH - 1:0]),
		.out_feature(passthrough_aggregator_out_feature),
		.out_feature_valid(passthrough_aggregator_out_valid)
	);
	sum_aggregator #(
		.DATA_WIDTH(DATA_WIDTH),
		.PRECISION(PRECISION)
	) sum_aggregator_i(
		.core_clk(core_clk),
		.resetn(resetn),
		.in_feature_valid(busy && sum_aggregator_in_feature_valid),
		.in_feature(scaled_feature[DATA_WIDTH - 1:0]),
		.acc_feature(accumulator),
		.out_feature_valid(sum_aggregator_out_valid),
		.out_feature(sum_aggregator_out_feature)
	);
	generate
		if (PRECISION == "FIXED_16") begin : genblk2
			fixed16_upsampler upsampler_i(
				.s_axis_a_tvalid(upsample),
				.s_axis_a_tdata(accumulator),
				.m_axis_result_tvalid(accumulator_float_valid),
				.m_axis_result_tdata(accumulator_float)
			);
		end
		else if (PRECISION == "FIXED_8") begin : genblk2
			fixed8_upsampler upsampler_i(
				.s_axis_a_tvalid(upsample),
				.s_axis_a_tdata(accumulator),
				.m_axis_result_tvalid(accumulator_float_valid),
				.m_axis_result_tdata(accumulator_float)
			);
		end
		else if (PRECISION == "FIXED_4") begin : genblk2
			fixed4_upsampler upsampler_i(
				.s_axis_a_tvalid(upsample),
				.s_axis_a_tdata(accumulator),
				.m_axis_result_tvalid(accumulator_float_valid),
				.m_axis_result_tdata(accumulator_float)
			);
		end
	endgenerate
	fp_mult upsampler_mult(
		.s_axis_a_tvalid(accumulator_float_valid),
		.s_axis_a_tdata(accumulator_float),
		.s_axis_b_tvalid(1'sb1),
		.s_axis_b_tdata(layer_config_upsampling_parameter),
		.m_axis_result_tvalid(upsampled_accumulator_valid_comb),
		.m_axis_result_tdata(upsampled_accumulator_comb)
	);
	always @(posedge core_clk or negedge resetn)
		if (!resetn)
			busy <= 1'sb0;
		else if (in_feature_valid && in_feature_ready)
			busy <= 1'b1;
		else if (feature_updated)
			busy <= 1'b0;
	always @(*) begin
		passthrough_aggregator_in_feature_valid = (feature_accumulation_count == {10 {1'sb0}}) && scaled_feature_valid;
		sum_aggregator_in_feature_valid = (|feature_accumulation_count && scaled_feature_valid) && (aggregation_function_sel == 2'd0);
		feature_updated = busy && (feature_accumulation_count == {10 {1'sb0}} ? passthrough_aggregator_out_valid : (aggregation_function_sel == 2'd0 ? sum_aggregator_out_valid : 1'b0));
		in_feature_ready = !busy;
	end
	always @(posedge core_clk or negedge resetn)
		if (!resetn) begin
			feature_accumulation_count <= 1'sb0;
			accumulator <= 1'sb0;
		end
		else if (reset_accumulator) begin
			feature_accumulation_count <= 1'sb0;
			accumulator <= 1'sb0;
		end
		else if (feature_updated) begin
			feature_accumulation_count <= feature_accumulation_count + 1'b1;
			if (feature_accumulation_count == {10 {1'sb0}})
				accumulator <= passthrough_aggregator_out_feature;
			else
				case (aggregation_function_sel)
					2'd0: accumulator <= sum_aggregator_out_feature;
					default: accumulator <= accumulator;
				endcase
		end
	generate
		if (((PRECISION == "FIXED_16") || (PRECISION == "FIXED_8")) || (PRECISION == "FIXED_4")) begin : genblk3
			always @(posedge core_clk or negedge resetn)
				if (!resetn) begin
					upsampled_accumulator <= 1'sb0;
					upsampled_accumulator_valid <= 1'sb0;
				end
				else if (upsampled_accumulator_valid_comb) begin
					upsampled_accumulator <= upsampled_accumulator_comb;
					upsampled_accumulator_valid <= 1'sb1;
				end
		end
		else begin : genblk3
			always @(posedge core_clk or negedge resetn)
				if (!resetn) begin
					upsampled_accumulator <= 1'sb0;
					upsampled_accumulator_valid <= 1'sb0;
				end
				else if (upsample) begin
					upsampled_accumulator <= accumulator;
					upsampled_accumulator_valid <= 1'sb1;
				end
		end
	endgenerate
endmodule
module aggregation_core_allocator (
	core_clk,
	resetn,
	allocation_req_valid,
	allocation_req_ready,
	allocation_req,
	cores_free,
	layer_config_in_features_count,
	deallocation_valid,
	deallocation_cores,
	age_agm_req_valid,
	age_agm_req_ready,
	age_agm_req
);
	localparam top_pkg_MAX_NODESLOT_COUNT = 32;
	localparam age_pkg_AGC_COLS = top_pkg_MAX_NODESLOT_COUNT;
	localparam age_pkg_AGC_ROWS = 4;
	localparam age_pkg_TOTAL_AGGREGATION_CORES = 128;
	parameter NUM_CORES = age_pkg_TOTAL_AGGREGATION_CORES;
	localparam age_pkg_AGC_FLOAT32_COL_OFFSET = 0;
	parameter PRECISION_COL_OFFSET = age_pkg_AGC_FLOAT32_COL_OFFSET;
	input wire core_clk;
	input wire resetn;
	input wire allocation_req_valid;
	output reg allocation_req_ready;
	localparam top_pkg_FETCH_TAG_COUNT = top_pkg_MAX_NODESLOT_COUNT;
	localparam top_pkg_MAX_NODES = 1048576;
	localparam top_pkg_NODE_ID_WIDTH = 20;
	input wire [33:0] allocation_req;
	input wire [NUM_CORES - 1:0] cores_free;
	input wire [9:0] layer_config_in_features_count;
	input wire deallocation_valid;
	input wire [NUM_CORES - 1:0] deallocation_cores;
	localparam age_pkg_AGM_COLS = top_pkg_MAX_NODESLOT_COUNT;
	localparam age_pkg_AGM_ROWS = 1;
	localparam age_pkg_TOTAL_AGGREGATION_MANAGERS = 32;
	output wire [31:0] age_agm_req_valid;
	input wire [31:0] age_agm_req_ready;
	localparam age_pkg_AGC_FLOAT32_COLS = 8;
	localparam age_pkg_AGC_FLOAT32_ROWS = 4;
	localparam age_pkg_AGC_COUNT_FLOAT32 = 32;
	localparam top_pkg_MAX_FEATURE_COUNT = 1024;
	localparam age_pkg_MAX_AGC_PER_NODE = 64;
	localparam age_pkg_BM_COLS = 1;
	localparam age_pkg_MESH_COLS = 33;
	localparam age_pkg_MESH_ROWS = 5;
	output reg [647:0] age_agm_req;
	reg busy;
	reg done;
	reg [33:0] allocation_req_q;
	reg [NUM_CORES - 1:0] allocatable_cores;
	reg [5:0] agc_counter;
	wire [NUM_CORES - 1:0] allocated_core;
	wire [$clog2(NUM_CORES) - 1:0] allocated_core_bin;
	rr_arbiter #(.NUM_REQUESTERS(NUM_CORES)) arbiter_i(
		.clk(core_clk),
		.resetn(resetn),
		.request(cores_free & allocatable_cores),
		.update_lru(busy && !done),
		.grant_oh(allocated_core)
	);
	onehot_to_binary_comb #(.INPUT_WIDTH(NUM_CORES)) allocated_core_oh2bin(
		.input_data(allocated_core),
		.output_data(allocated_core_bin)
	);
	always @(*) begin
		age_agm_req[647-:34] = allocation_req_q;
		age_agm_req[581-:6] = layer_config_in_features_count[9:4] + (|layer_config_in_features_count[3:0] ? 1'b1 : {6 {1'sb0}});
		allocation_req_ready = !busy;
		done = agc_counter == age_agm_req[581-:6];
	end
	always @(posedge core_clk or negedge resetn)
		if (!resetn) begin
			busy <= 1'sb0;
			allocation_req_q <= 1'sb0;
			agc_counter <= 1'sb0;
			age_agm_req <= 1'sb0;
		end
		else if (!busy & allocation_req_valid) begin
			busy <= 1'sb1;
			allocation_req_q <= allocation_req;
			agc_counter <= 1'sb0;
			age_agm_req <= 1'sb0;
		end
		else if (busy && !done) begin
			agc_counter <= agc_counter + 1'b1;
			age_agm_req[613-:32] <= age_agm_req[613-:32] | allocated_core;
		end
		else if (|(age_agm_req_valid & age_agm_req_ready))
			busy <= 1'sb0;
	genvar allocation_slot;
	localparam age_pkg_AGC_FIXED16_COLS = 8;
	localparam age_pkg_AGC_FIXED16_ROWS = 4;
	localparam age_pkg_AGC_COUNT_FIXED16 = 32;
	generate
		for (allocation_slot = 0; allocation_slot < age_pkg_MAX_AGC_PER_NODE; allocation_slot = allocation_slot + 1) begin : genblk1
			always @(posedge core_clk or negedge resetn)
				if (!resetn) begin
					age_agm_req[192 + (allocation_slot * 6)+:6] <= 1'sb0;
					age_agm_req[0 + (allocation_slot * 3)+:3] <= 1'sb0;
				end
				else if ((busy && !done) && (agc_counter == allocation_slot)) begin
					age_agm_req[192 + (allocation_slot * 6)+:6] <= PRECISION_COL_OFFSET[5:0] + allocated_core_bin[3:0];
					age_agm_req[0 + (allocation_slot * 3)+:3] <= allocated_core_bin[4:4];
				end
		end
	endgenerate
	always @(posedge core_clk or negedge resetn)
		if (!resetn)
			allocatable_cores <= 1'sb1;
		else
			allocatable_cores <= (allocatable_cores & ~(allocated_core & {NUM_CORES {busy && !done}})) | (deallocation_cores & {NUM_CORES {deallocation_valid}});
	genvar agm;
	generate
		for (agm = 0; agm < age_pkg_TOTAL_AGGREGATION_MANAGERS; agm = agm + 1) begin : genblk2
			assign age_agm_req_valid[agm] = (busy && done) && (allocation_req_q[8-:5] == agm);
		end
	endgenerate
endmodule
module aggregation_core (
	core_clk,
	resetn,
	aggregation_core_free,
	aggregation_core_router_on,
	aggregation_core_router_valid,
	aggregation_core_router_ready,
	aggregation_core_router_data,
	router_aggregation_core_on,
	router_aggregation_core_valid,
	router_aggregation_core_ready,
	router_aggregation_core_data,
	layer_config_upsampling_parameter
);
	parameter X_COORD = 0;
	parameter Y_COORD = 0;
	parameter FEATURE_COUNT = 16;
	parameter DATA_WIDTH = 32;
	parameter FLOAT_WIDTH = 32;
	parameter PRECISION = "FLOAT_32";
	input wire core_clk;
	input wire resetn;
	output reg aggregation_core_free;
	input wire aggregation_core_router_on;
	output reg aggregation_core_router_valid;
	input wire aggregation_core_router_ready;
	localparam noc_params_MESH_SIZE_X = 65;
	localparam noc_params_DEST_ADDR_SIZE_X = 7;
	localparam noc_params_MESH_SIZE_Y = 5;
	localparam noc_params_DEST_ADDR_SIZE_Y = 3;
	localparam noc_params_HEAD_PAYLOAD_SIZE = 74;
	localparam noc_params_FLIT_DATA_SIZE = 84;
	localparam noc_params_VC_NUM = 1;
	localparam noc_params_VC_SIZE = 0;
	output reg [85:0] aggregation_core_router_data;
	output reg router_aggregation_core_on;
	input wire router_aggregation_core_valid;
	output reg router_aggregation_core_ready;
	input wire [85:0] router_aggregation_core_data;
	input wire [31:0] layer_config_upsampling_parameter;
	localparam top_pkg_MAX_NODESLOT_COUNT = 32;
	parameter ALLOCATION_PKT_AGGR_FUNC_OFFSET = 5;
	localparam age_pkg_PAYLOAD_DATA_WIDTH = 64;
	function [2:0] decode_head_packet;
		input reg [85:0] input_packet;
		reg [1:0] field;
		reg [1:0] out_type;
		reg last_flag;
		begin
			field = input_packet[63:62];
			out_type = (field == 2'b00 ? 2'b00 : (field == 2'b01 ? 2'b01 : (field == 2'b10 ? 2'b10 : 2'b11)));
			last_flag = input_packet[61];
			decode_head_packet = {out_type, last_flag};
		end
	endfunction
	reg [3:0] agc_state;
	reg [3:0] agc_state_n;
	reg [4:0] nodeslot_allocation_nodeslot;
	reg [1:0] nodeslot_allocation_aggregation_function;
	wire [(FEATURE_COUNT * DATA_WIDTH) - 1:0] features;
	reg [FEATURE_COUNT - 1:0] feature_aggregator_in_feature_valid;
	wire [FEATURE_COUNT - 1:0] feature_aggregator_in_feature_ready;
	reg [(FEATURE_COUNT * DATA_WIDTH) - 1:0] feature_aggregator_in_feature;
	wire [FEATURE_COUNT - 1:0] feature_aggregator_feature_updated;
	wire [FEATURE_COUNT - 1:0] feature_aggregator_reset_accumulator;
	reg [FEATURE_COUNT - 1:0] feature_updated;
	reg [85:0] router_agc_pkt_q;
	reg [3:0] received_flits;
	reg head_packet;
	reg tail_packet;
	localparam age_pkg_AGC_ROWS = 4;
	localparam age_pkg_AGM_ROWS = 1;
	localparam age_pkg_MESH_ROWS = 5;
	reg [2:0] packet_dest_row;
	localparam age_pkg_AGC_COLS = top_pkg_MAX_NODESLOT_COUNT;
	localparam age_pkg_BM_COLS = 1;
	localparam age_pkg_MESH_COLS = 33;
	reg [5:0] packet_dest_col;
	reg correct_pkt_dest;
	reg [2:0] packet_source_row;
	reg [5:0] packet_source_col;
	reg aggregation_manager_pkt;
	reg [1:0] aggregation_manager_packet_type;
	reg aggregation_manager_packet_last;
	reg aggregation_manager_packet_last_q;
	reg received_buffer_req_head;
	reg [2:0] buffer_manager_pkt_dest_row;
	reg [5:0] buffer_manager_pkt_dest_col;
	reg [63:0] bm_chosen_data;
	reg [$clog2(FEATURE_COUNT / 2) - 1:0] sent_flits_counter;
	reg noc_router_waiting;
	wire upsample;
	wire [FEATURE_COUNT - 1:0] upsampled_accumulator_valid;
	wire [(FEATURE_COUNT * FLOAT_WIDTH) - 1:0] upsampled_features;
	localparam top_pkg_SCALE_FACTOR_QUEUE_READ_WIDTH = 32;
	reg [31:0] scale_factor_q;
	genvar feature;
	generate
		for (feature = 0; feature < FEATURE_COUNT; feature = feature + 1) begin : genblk1
			feature_aggregator #(
				.DATA_WIDTH(DATA_WIDTH),
				.PRECISION(PRECISION)
			) feature_aggregator_i(
				.core_clk(core_clk),
				.resetn(resetn),
				.aggregation_function_sel(nodeslot_allocation_aggregation_function),
				.in_feature_valid(feature_aggregator_in_feature_valid[feature]),
				.in_feature_ready(feature_aggregator_in_feature_ready[feature]),
				.in_feature(feature_aggregator_in_feature[feature * DATA_WIDTH+:DATA_WIDTH]),
				.scale_factor(scale_factor_q),
				.feature_updated(feature_aggregator_feature_updated[feature]),
				.accumulator(features[feature * DATA_WIDTH+:DATA_WIDTH]),
				.reset_accumulator(feature_aggregator_reset_accumulator[feature]),
				.upsample(upsample),
				.upsampled_accumulator_valid(upsampled_accumulator_valid[feature]),
				.upsampled_accumulator(upsampled_features[feature * FLOAT_WIDTH+:FLOAT_WIDTH]),
				.layer_config_upsampling_parameter(layer_config_upsampling_parameter)
			);
			always @(posedge core_clk or negedge resetn)
				if (!resetn)
					feature_updated[feature] <= 1'sb0;
				else if (((router_aggregation_core_valid && router_aggregation_core_ready) && aggregation_manager_pkt) && head_packet)
					feature_updated[feature] <= 1'sb0;
				else if (feature_aggregator_feature_updated[feature])
					feature_updated[feature] <= 1'sb1;
		end
	endgenerate
	always @(posedge core_clk or negedge resetn)
		if (!resetn)
			agc_state <= 4'd0;
		else
			agc_state <= agc_state_n;
	always @(*) begin
		agc_state_n = agc_state;
		case (agc_state)
			4'd0: agc_state_n = ((((router_aggregation_core_valid && head_packet) && aggregation_manager_pkt) && correct_pkt_dest) && (aggregation_manager_packet_type == 2'b00) ? 4'd1 : 4'd0);
			4'd1: agc_state_n = (((router_aggregation_core_valid && tail_packet) && aggregation_manager_pkt) && correct_pkt_dest ? 4'd2 : 4'd1);
			4'd2: agc_state_n = ((((router_aggregation_core_valid && head_packet) && aggregation_manager_pkt) && correct_pkt_dest) && (aggregation_manager_packet_type == 2'b01) ? 4'd3 : 4'd2);
			4'd3: agc_state_n = ((router_aggregation_core_valid && aggregation_manager_pkt) && correct_pkt_dest ? 4'd4 : 4'd3);
			4'd4: agc_state_n = ((((received_flits == 4'd8) && feature_updated[FEATURE_COUNT - 1]) && feature_updated[FEATURE_COUNT - 2]) && aggregation_manager_packet_last_q ? 4'd5 : (((received_flits == 4'd8) && feature_updated[FEATURE_COUNT - 1]) && feature_updated[FEATURE_COUNT - 2] ? 4'd2 : (feature_updated[2 * (received_flits - 1)] && feature_updated[(2 * (received_flits - 1)) + 1] ? 4'd3 : 4'd4)));
			4'd5: agc_state_n = (&upsampled_accumulator_valid ? 4'd6 : 4'd5);
			4'd6: agc_state_n = ((((router_aggregation_core_valid && aggregation_manager_pkt) && received_buffer_req_head) && tail_packet) && correct_pkt_dest ? 4'd7 : 4'd6);
			4'd7: agc_state_n = (sent_flits_counter == 'd7 ? 4'd0 : 4'd7);
			4'd8: agc_state_n = (noc_router_waiting ? 4'd0 : 4'd8);
			default: agc_state_n = 4'd0;
		endcase
	end
	localparam age_pkg_MESH_NODE_ID_WIDTH = 9;
	reg [8:0] packet_source;
	always @(*) begin
		head_packet = router_aggregation_core_data[85-:2] == 2'd0;
		tail_packet = router_aggregation_core_data[85-:2] == 2'd2;
		packet_source = router_aggregation_core_data[73:65];
		packet_source_col = packet_source[8:3];
		packet_source_row = packet_source[2:0];
		packet_dest_col = router_aggregation_core_data[83-:7];
		packet_dest_row = router_aggregation_core_data[76-:3];
		correct_pkt_dest = (packet_dest_row == Y_COORD[2:0]) && (packet_dest_col == X_COORD[5:0]);
	end
	always @(*) begin
		aggregation_manager_pkt = packet_source_row == age_pkg_AGC_ROWS;
		{aggregation_manager_packet_type, aggregation_manager_packet_last} = decode_head_packet(router_aggregation_core_data);
	end
	always @(posedge core_clk or negedge resetn)
		if (!resetn) begin
			router_agc_pkt_q <= 1'sb0;
			received_flits <= 1'sb0;
			aggregation_manager_packet_last_q <= 1'sb0;
			received_buffer_req_head <= 1'sb0;
			sent_flits_counter <= 1'sb0;
			scale_factor_q <= 1'sb0;
		end
		else if ((agc_state_n == 4'd0) || (agc_state_n == 4'd2)) begin
			router_agc_pkt_q <= router_aggregation_core_data;
			received_flits <= 1'sb0;
			aggregation_manager_packet_last_q <= 1'sb0;
			received_buffer_req_head <= 1'sb0;
			sent_flits_counter <= 1'sb0;
			scale_factor_q <= 1'sb0;
		end
		else if ((router_aggregation_core_valid && router_aggregation_core_ready) && aggregation_manager_pkt) begin
			if (head_packet) begin
				aggregation_manager_packet_last_q <= aggregation_manager_packet_last;
				received_buffer_req_head <= aggregation_manager_packet_type == 2'b10;
				scale_factor_q <= router_aggregation_core_data[FLOAT_WIDTH - 1:0];
			end
			else
				received_flits <= received_flits + 1;
			router_agc_pkt_q <= router_aggregation_core_data;
		end
		else if (aggregation_core_router_valid && noc_router_waiting)
			sent_flits_counter <= sent_flits_counter + 1;
	always @(posedge core_clk or negedge resetn)
		if (!resetn)
			noc_router_waiting <= 1'sb1;
		else if (aggregation_core_router_ready)
			noc_router_waiting <= 1'sb1;
		else if (aggregation_core_router_valid && (aggregation_core_router_data[85-:2] == 2'd2))
			noc_router_waiting <= 1'sb0;
	assign feature_aggregator_reset_accumulator = ((agc_state == 4'd0) && (agc_state_n == 4'd1) ? {FEATURE_COUNT {1'sb1}} : {FEATURE_COUNT {1'sb0}});
	genvar pkt;
	generate
		for (pkt = 0; pkt < 8; pkt = pkt + 1) begin : genblk2
			always @(*) begin
				feature_aggregator_in_feature_valid[2 * pkt] = ((agc_state == 4'd4) && (received_flits == (pkt + 1))) && !feature_updated[2 * pkt];
				feature_aggregator_in_feature[(2 * pkt) * DATA_WIDTH+:DATA_WIDTH] = router_agc_pkt_q[(32 + DATA_WIDTH) - 1:32];
				feature_aggregator_in_feature_valid[(2 * pkt) + 1] = ((agc_state == 4'd4) && (received_flits == (pkt + 1))) && !feature_updated[(2 * pkt) + 1];
				feature_aggregator_in_feature[((2 * pkt) + 1) * DATA_WIDTH+:DATA_WIDTH] = router_agc_pkt_q[DATA_WIDTH - 1:0];
			end
		end
	endgenerate
	assign upsample = agc_state == 4'd5;
	localparam age_pkg_BUFFER_MANAGER_COLUMN = 32;
	localparam age_pkg_BM_ROWS = 4;
	localparam age_pkg_TOTAL_BUFFER_MANAGERS = 4;
	always @(*) begin
		buffer_manager_pkt_dest_row = router_agc_pkt_q[1:0];
		buffer_manager_pkt_dest_col = age_pkg_BUFFER_MANAGER_COLUMN;
		router_aggregation_core_ready = ((((agc_state == 4'd0) || (agc_state == 4'd1)) || (agc_state == 4'd2)) || (agc_state == 4'd3)) || (agc_state == 4'd6);
		router_aggregation_core_on = router_aggregation_core_ready;
		aggregation_core_router_valid = agc_state == 4'd7;
		bm_chosen_data = (sent_flits_counter == 'd0 ? {upsampled_features[FLOAT_WIDTH+:FLOAT_WIDTH], upsampled_features[0+:FLOAT_WIDTH]} : (sent_flits_counter == 'd1 ? {upsampled_features[3 * FLOAT_WIDTH+:FLOAT_WIDTH], upsampled_features[2 * FLOAT_WIDTH+:FLOAT_WIDTH]} : (sent_flits_counter == 'd2 ? {upsampled_features[5 * FLOAT_WIDTH+:FLOAT_WIDTH], upsampled_features[4 * FLOAT_WIDTH+:FLOAT_WIDTH]} : (sent_flits_counter == 'd3 ? {upsampled_features[7 * FLOAT_WIDTH+:FLOAT_WIDTH], upsampled_features[6 * FLOAT_WIDTH+:FLOAT_WIDTH]} : (sent_flits_counter == 'd4 ? {upsampled_features[9 * FLOAT_WIDTH+:FLOAT_WIDTH], upsampled_features[8 * FLOAT_WIDTH+:FLOAT_WIDTH]} : (sent_flits_counter == 'd5 ? {upsampled_features[11 * FLOAT_WIDTH+:FLOAT_WIDTH], upsampled_features[10 * FLOAT_WIDTH+:FLOAT_WIDTH]} : (sent_flits_counter == 'd6 ? {upsampled_features[13 * FLOAT_WIDTH+:FLOAT_WIDTH], upsampled_features[12 * FLOAT_WIDTH+:FLOAT_WIDTH]} : (sent_flits_counter == 'd7 ? {upsampled_features[15 * FLOAT_WIDTH+:FLOAT_WIDTH], upsampled_features[14 * FLOAT_WIDTH+:FLOAT_WIDTH]} : {64 {1'sb0}}))))))));
		aggregation_core_router_data[83-:2] = 1'sb0;
		aggregation_core_router_data[85-:2] = (sent_flits_counter == {$clog2(FEATURE_COUNT / 2) {1'sb0}} ? 2'd0 : (sent_flits_counter == 'd7 ? 2'd2 : 2'd1));
		aggregation_core_router_data[83-:noc_params_FLIT_DATA_SIZE] = {buffer_manager_pkt_dest_col, buffer_manager_pkt_dest_row, X_COORD[5:0], Y_COORD[2:0], bm_chosen_data};
	end
	always @(posedge core_clk or negedge resetn)
		if (!resetn) begin
			aggregation_core_free <= 1'sb1;
			nodeslot_allocation_nodeslot <= 1'sb0;
			nodeslot_allocation_aggregation_function <= 2'd0;
		end
		else if ((agc_state == 4'd8) && (agc_state_n == 4'd0)) begin
			aggregation_core_free <= 1'sb1;
			nodeslot_allocation_nodeslot <= 1'sb0;
			nodeslot_allocation_aggregation_function <= 2'd0;
		end
		else if ((agc_state == 4'd0) && (agc_state_n == 4'd1))
			aggregation_core_free <= 1'sb0;
		else if ((agc_state == 4'd1) && (agc_state_n == 4'd2)) begin
			nodeslot_allocation_nodeslot <= router_aggregation_core_data[4:0];
			nodeslot_allocation_aggregation_function <= (router_aggregation_core_data[0 + (ALLOCATION_PKT_AGGR_FUNC_OFFSET + 1):0 + ALLOCATION_PKT_AGGR_FUNC_OFFSET] == 2'd0 ? 2'd0 : (router_aggregation_core_data[0 + (ALLOCATION_PKT_AGGR_FUNC_OFFSET + 1):0 + ALLOCATION_PKT_AGGR_FUNC_OFFSET] == 2'd1 ? 2'd1 : (router_aggregation_core_data[0 + (ALLOCATION_PKT_AGGR_FUNC_OFFSET + 1):0 + ALLOCATION_PKT_AGGR_FUNC_OFFSET] == 2'd2 ? 2'd2 : 2'd3)));
		end
endmodule
module aggregation_manager (
	core_clk,
	resetn,
	age_aggregation_manager_req_valid,
	age_aggregation_manager_req_ready,
	age_aggregation_manager_req,
	aggregation_manager_age_done_valid,
	aggregation_manager_age_done_ready,
	age_aggregation_manager_buffer_manager_allocation_valid,
	age_aggregation_manager_buffer_manager_allocation_ready,
	age_aggregation_manager_buffer_manager_allocation,
	message_channel_req_valid,
	message_channel_req_ready,
	message_channel_req,
	message_channel_resp_valid,
	message_channel_resp_ready,
	message_channel_resp,
	aggregation_manager_router_on,
	aggregation_manager_router_valid,
	aggregation_manager_router_ready,
	aggregation_manager_router_data,
	router_aggregation_manager_on,
	router_aggregation_manager_valid,
	router_aggregation_manager_ready,
	router_aggregation_manager_data,
	agm_allocation,
	agm_allocated_agcs,
	agm_allocated_agcs_count,
	coords_buffer_x,
	coords_buffer_y,
	scale_factor_queue_pop,
	scale_factor_queue_out_data,
	scale_factor_queue_count,
	scale_factor_queue_empty,
	scale_factor_queue_full
);
	parameter X_COORD = 0;
	parameter Y_COORD = 0;
	input wire core_clk;
	input wire resetn;
	input wire age_aggregation_manager_req_valid;
	output reg age_aggregation_manager_req_ready;
	localparam top_pkg_MAX_NODESLOT_COUNT = 32;
	localparam age_pkg_AGC_FLOAT32_COLS = 8;
	localparam age_pkg_AGC_FLOAT32_ROWS = 4;
	localparam age_pkg_AGC_COUNT_FLOAT32 = 32;
	localparam top_pkg_MAX_FEATURE_COUNT = 1024;
	localparam age_pkg_MAX_AGC_PER_NODE = 64;
	localparam age_pkg_AGC_COLS = top_pkg_MAX_NODESLOT_COUNT;
	localparam age_pkg_BM_COLS = 1;
	localparam age_pkg_MESH_COLS = 33;
	localparam age_pkg_AGC_ROWS = 4;
	localparam age_pkg_AGM_ROWS = 1;
	localparam age_pkg_MESH_ROWS = 5;
	localparam top_pkg_FETCH_TAG_COUNT = top_pkg_MAX_NODESLOT_COUNT;
	localparam top_pkg_MAX_NODES = 1048576;
	localparam top_pkg_NODE_ID_WIDTH = 20;
	input wire [647:0] age_aggregation_manager_req;
	output reg aggregation_manager_age_done_valid;
	input wire aggregation_manager_age_done_ready;
	input wire age_aggregation_manager_buffer_manager_allocation_valid;
	output wire age_aggregation_manager_buffer_manager_allocation_ready;
	localparam age_pkg_BM_ROWS = 4;
	localparam age_pkg_TOTAL_BUFFER_MANAGERS = 4;
	input wire [1:0] age_aggregation_manager_buffer_manager_allocation;
	output reg message_channel_req_valid;
	input wire message_channel_req_ready;
	output reg [9:0] message_channel_req;
	input wire message_channel_resp_valid;
	output reg message_channel_resp_ready;
	localparam top_pkg_AXI_DATA_WIDTH = 512;
	input wire [513:0] message_channel_resp;
	input wire aggregation_manager_router_on;
	output reg aggregation_manager_router_valid;
	input wire aggregation_manager_router_ready;
	localparam noc_params_MESH_SIZE_X = 65;
	localparam noc_params_DEST_ADDR_SIZE_X = 7;
	localparam noc_params_MESH_SIZE_Y = 5;
	localparam noc_params_DEST_ADDR_SIZE_Y = 3;
	localparam noc_params_HEAD_PAYLOAD_SIZE = 74;
	localparam noc_params_FLIT_DATA_SIZE = 84;
	localparam noc_params_VC_NUM = 1;
	localparam noc_params_VC_SIZE = 0;
	output reg [85:0] aggregation_manager_router_data;
	output reg router_aggregation_manager_on;
	input wire router_aggregation_manager_valid;
	output reg router_aggregation_manager_ready;
	input wire [85:0] router_aggregation_manager_data;
	output reg [33:0] agm_allocation;
	output reg [31:0] agm_allocated_agcs;
	output reg [5:0] agm_allocated_agcs_count;
	output reg [383:0] coords_buffer_x;
	output reg [191:0] coords_buffer_y;
	output wire scale_factor_queue_pop;
	localparam top_pkg_SCALE_FACTOR_QUEUE_READ_WIDTH = 32;
	input wire [31:0] scale_factor_queue_out_data;
	localparam top_pkg_SCALE_FACTOR_QUEUE_READ_DEPTH = 1024;
	input wire [10:0] scale_factor_queue_count;
	input wire scale_factor_queue_empty;
	input wire scale_factor_queue_full;
	wire [5:0] x_coord;
	wire [2:0] y_coord;
	reg [5:0] coord_ptr;
	reg [4:0] agm_state;
	reg [4:0] agm_state_n;
	reg [3:0] packet_state;
	reg [3:0] packet_state_n;
	reg pkt_done;
	reg agc_pkt_head_sent;
	reg [513:0] message_channel_resp_q;
	reg [1:0] buffer_manager_allocation_q;
	wire [2:0] packet_source_row;
	wire [5:0] packet_source_col;
	reg noc_router_waiting;
	assign x_coord = X_COORD;
	assign y_coord = Y_COORD;
	always @(posedge core_clk or negedge resetn)
		if (!resetn)
			agm_state <= 5'd0;
		else
			agm_state <= agm_state_n;
	always @(*) begin
		agm_state_n = agm_state;
		case (agm_state)
			5'd0: agm_state_n = (age_aggregation_manager_req_valid ? 5'd1 : 5'd0);
			5'd1: agm_state_n = ((aggregation_manager_router_data[85-:2] == 2'd2) && (coord_ptr == (agm_allocated_agcs_count - 1'b1)) ? 5'd2 : 5'd1);
			5'd2: agm_state_n = (noc_router_waiting ? 5'd3 : 5'd2);
			5'd3: agm_state_n = (message_channel_req_ready ? 5'd4 : 5'd3);
			5'd4: agm_state_n = (message_channel_resp_valid ? 5'd5 : 5'd4);
			5'd5: agm_state_n = (pkt_done && message_channel_resp_q[0] ? 5'd6 : (pkt_done ? 5'd4 : 5'd5));
			5'd6: agm_state_n = (noc_router_waiting ? 5'd7 : 5'd6);
			5'd7: agm_state_n = (age_aggregation_manager_buffer_manager_allocation_valid ? 5'd8 : 5'd7);
			5'd8: agm_state_n = ((coord_ptr == (agm_allocated_agcs_count - 1'b1)) && agc_pkt_head_sent ? 5'd9 : 5'd8);
			5'd9: agm_state_n = (noc_router_waiting ? 5'd10 : 5'd9);
			5'd10: agm_state_n = ((router_aggregation_manager_valid && (packet_source_col == 32)) && (packet_source_row == buffer_manager_allocation_q) ? 5'd11 : 5'd10);
			5'd11: agm_state_n = (aggregation_manager_age_done_ready ? 5'd0 : 5'd11);
			default: agm_state_n = 5'd0;
		endcase
	end
	always @(posedge core_clk or negedge resetn)
		if (!resetn) begin
			agm_allocation[33-:5] <= 1'sb0;
			agm_allocation[8-:5] <= 1'sb0;
			agm_allocation[3-:2] <= 2'd0;
			agm_allocation[1-:2] <= 2'd0;
			agm_allocated_agcs <= 1'sb0;
			agm_allocated_agcs_count <= 1'sb0;
		end
		else if (age_aggregation_manager_req_valid && age_aggregation_manager_req_ready) begin
			agm_allocation[33-:5] <= age_aggregation_manager_req[647-:5];
			agm_allocation[8-:5] <= age_aggregation_manager_req[622-:5];
			agm_allocation[3-:2] <= age_aggregation_manager_req[617-:2];
			agm_allocation[1-:2] <= age_aggregation_manager_req[615-:2];
			agm_allocated_agcs_count <= age_aggregation_manager_req[581-:6];
			agm_allocated_agcs <= age_aggregation_manager_req[613-:32];
		end
	always @(*) begin
		age_aggregation_manager_req_ready = (agm_state == 5'd0) && (packet_state == 4'd0);
		aggregation_manager_age_done_valid = agm_state == 5'd11;
	end
	always @(*) begin
		message_channel_req_valid = agm_state == 5'd3;
		message_channel_req[9-:5] = agm_allocation[33-:5];
		message_channel_req[4-:5] = agm_allocation[8-:5];
		message_channel_resp_ready = agm_state == 5'd4;
	end
	always @(posedge core_clk or negedge resetn)
		if (!resetn)
			message_channel_resp_q <= 1'sb0;
		else if ((agm_state == 5'd4) && message_channel_resp_valid)
			message_channel_resp_q <= message_channel_resp;
	always @(posedge core_clk or negedge resetn)
		if (!resetn)
			packet_state <= 4'd0;
		else
			packet_state <= packet_state_n;
	always @(*) begin
		pkt_done = packet_state == 4'd9;
		packet_state_n = packet_state;
		case (packet_state)
			4'd0: packet_state_n = ((aggregation_manager_router_on && (agm_state == 5'd5)) && noc_router_waiting ? 4'd1 : 4'd0);
			4'd1: packet_state_n = 4'd2;
			4'd2: packet_state_n = 4'd3;
			4'd3: packet_state_n = 4'd4;
			4'd4: packet_state_n = 4'd5;
			4'd5: packet_state_n = 4'd6;
			4'd6: packet_state_n = 4'd7;
			4'd7: packet_state_n = 4'd8;
			4'd8: packet_state_n = 4'd9;
			4'd9: packet_state_n = 4'd0;
			default: packet_state_n = 4'd0;
		endcase
	end
	always @(posedge core_clk or negedge resetn)
		if (!resetn)
			noc_router_waiting <= 1'sb1;
		else if (aggregation_manager_router_ready)
			noc_router_waiting <= 1'sb1;
		else if (aggregation_manager_router_valid && (aggregation_manager_router_data[85-:2] == 2'd2))
			noc_router_waiting <= 1'sb0;
	localparam age_pkg_PAYLOAD_DATA_WIDTH = 64;
	always @(*) begin
		aggregation_manager_router_valid = ((packet_state != 4'd0) || (agm_state == 5'd1)) || (agm_state == 5'd8);
		aggregation_manager_router_data[83-:2] = 1'sb0;
		if (agm_state == 5'd1) begin
			aggregation_manager_router_data[85-:2] = (agc_pkt_head_sent ? 2'd2 : 2'd0);
			aggregation_manager_router_data[83-:noc_params_FLIT_DATA_SIZE] = (agc_pkt_head_sent ? {coords_buffer_x[coord_ptr * 6+:6], coords_buffer_y[coord_ptr * 3+:3], x_coord, y_coord, {57 {1'b0}}, agm_allocation[1-:2], agm_allocation[33-:5]} : {coords_buffer_x[coord_ptr * 6+:6], coords_buffer_y[coord_ptr * 3+:3], x_coord, y_coord, 2'b00, 1'b1, {61 {1'b0}}});
		end
		else if (agm_state == 5'd5) begin
			aggregation_manager_router_data[85-:2] = (packet_state == 4'd1 ? 2'd0 : (packet_state == 4'd9 ? 2'd2 : 2'd1));
			aggregation_manager_router_data[83-:noc_params_FLIT_DATA_SIZE] = (packet_state == 4'd1 ? {coords_buffer_x[coord_ptr * 6+:6], coords_buffer_y[coord_ptr * 3+:3], x_coord, y_coord, 2'b01, message_channel_resp_q[1], {29 {1'b0}}, scale_factor_queue_out_data} : (packet_state == 4'd2 ? {coords_buffer_x[coord_ptr * 6+:6], coords_buffer_y[coord_ptr * 3+:3], x_coord, y_coord, message_channel_resp_q[513:450]} : (packet_state == 4'd3 ? {coords_buffer_x[coord_ptr * 6+:6], coords_buffer_y[coord_ptr * 3+:3], x_coord, y_coord, message_channel_resp_q[449:386]} : (packet_state == 4'd4 ? {coords_buffer_x[coord_ptr * 6+:6], coords_buffer_y[coord_ptr * 3+:3], x_coord, y_coord, message_channel_resp_q[385:322]} : (packet_state == 4'd5 ? {coords_buffer_x[coord_ptr * 6+:6], coords_buffer_y[coord_ptr * 3+:3], x_coord, y_coord, message_channel_resp_q[321:258]} : (packet_state == 4'd6 ? {coords_buffer_x[coord_ptr * 6+:6], coords_buffer_y[coord_ptr * 3+:3], x_coord, y_coord, message_channel_resp_q[257:194]} : (packet_state == 4'd7 ? {coords_buffer_x[coord_ptr * 6+:6], coords_buffer_y[coord_ptr * 3+:3], x_coord, y_coord, message_channel_resp_q[193:130]} : (packet_state == 4'd8 ? {coords_buffer_x[coord_ptr * 6+:6], coords_buffer_y[coord_ptr * 3+:3], x_coord, y_coord, message_channel_resp_q[129:66]} : (packet_state == 4'd9 ? {coords_buffer_x[coord_ptr * 6+:6], coords_buffer_y[coord_ptr * 3+:3], x_coord, y_coord, message_channel_resp_q[65:2]} : {84 {1'sb0}})))))))));
		end
		else if (agm_state == 5'd8) begin
			aggregation_manager_router_data[85-:2] = (agc_pkt_head_sent ? 2'd2 : 2'd0);
			aggregation_manager_router_data[83-:noc_params_FLIT_DATA_SIZE] = (agc_pkt_head_sent ? {coords_buffer_x[coord_ptr * 6+:6], coords_buffer_y[coord_ptr * 3+:3], x_coord, y_coord, {62 {1'b0}}, buffer_manager_allocation_q} : {coords_buffer_x[coord_ptr * 6+:6], coords_buffer_y[coord_ptr * 3+:3], x_coord, y_coord, 2'b10, 1'b1, {61 {1'b0}}});
		end
		else begin
			aggregation_manager_router_data[85-:2] = 2'd0;
			aggregation_manager_router_data[83-:noc_params_FLIT_DATA_SIZE] = 1'sb0;
		end
		router_aggregation_manager_on = agm_state == 5'd10;
		router_aggregation_manager_ready = agm_state == 5'd10;
	end
	always @(posedge core_clk or negedge resetn)
		if (!resetn) begin
			coords_buffer_x <= 1'sb0;
			coords_buffer_y <= 1'sb0;
			coord_ptr <= 1'sb0;
			agc_pkt_head_sent <= 1'sb0;
		end
		else if (age_aggregation_manager_req_valid && age_aggregation_manager_req_ready) begin
			coords_buffer_x <= age_aggregation_manager_req[575-:384];
			coords_buffer_y <= age_aggregation_manager_req[191-:192];
			coord_ptr <= 1'sb0;
			agc_pkt_head_sent <= 1'sb0;
		end
		else if (aggregation_manager_router_valid) begin
			if ((((agm_state == 5'd5) && (packet_state == 4'd9)) || ((agm_state == 5'd1) && agc_pkt_head_sent)) || ((agm_state == 5'd8) && agc_pkt_head_sent))
				coord_ptr <= (coord_ptr == (agm_allocated_agcs_count - 1'b1) ? {6 {1'sb0}} : coord_ptr + 1);
			if (noc_router_waiting && ((agm_state == 5'd1) || (agm_state == 5'd8)))
				agc_pkt_head_sent <= (aggregation_manager_router_data[85-:2] == 2'd0 ? 1'b1 : (aggregation_manager_router_data[85-:2] == 2'd2 ? 1'b0 : agc_pkt_head_sent));
		end
	assign scale_factor_queue_pop = (((agm_state == 5'd5) && aggregation_manager_router_valid) && (packet_state == 4'd9)) && (coord_ptr == (agm_allocated_agcs_count - 1'b1));
	assign age_aggregation_manager_buffer_manager_allocation_ready = agm_state == 5'd7;
	always @(posedge core_clk or negedge resetn)
		if (!resetn)
			buffer_manager_allocation_q <= 1'sb0;
		else if ((agm_state == 5'd7) && age_aggregation_manager_buffer_manager_allocation_valid)
			buffer_manager_allocation_q <= age_aggregation_manager_buffer_manager_allocation;
	localparam age_pkg_MESH_NODE_ID_WIDTH = 9;
	function [8:0] age_pkg_decode_packet_source;
		input reg [85:0] input_packet;
		reg [8:0] packet_source;
		reg [2:0] packet_source_row;
		reg [5:0] packet_source_col;
		begin
			packet_source = input_packet[73:65];
			packet_source_col = packet_source[8:3];
			packet_source_row = packet_source[2:0];
			age_pkg_decode_packet_source = {packet_source_col, packet_source_row};
		end
	endfunction
	assign {packet_source_col, packet_source_row} = age_pkg_decode_packet_source(router_aggregation_manager_data);
endmodule
module buffer_manager (
	core_clk,
	resetn,
	age_buffer_manager_nodeslot_allocation_valid,
	age_buffer_manager_nodeslot_allocation_ready,
	age_buffer_manager_nodeslot_allocation,
	buffer_manager_router_on,
	buffer_manager_router_valid,
	buffer_manager_router_ready,
	buffer_manager_router_data,
	router_buffer_manager_on,
	router_buffer_manager_valid,
	router_buffer_manager_ready,
	router_buffer_manager_data,
	buffer_slot_set_node_id_valid,
	buffer_slot_set_node_id,
	bm_buffer_slot_write_enable,
	bm_buffer_slot_write_address,
	bm_buffer_slot_write_data,
	buffer_slot_bm_feature_count,
	buffer_slot_bm_slot_free
);
	parameter X_COORD = 0;
	parameter Y_COORD = 0;
	parameter BUFFER_SLOT_WRITE_DEPTH = 512;
	parameter BUFFER_SLOT_WRITE_WIDTH = 64;
	input wire core_clk;
	input wire resetn;
	input wire age_buffer_manager_nodeslot_allocation_valid;
	output wire age_buffer_manager_nodeslot_allocation_ready;
	localparam top_pkg_MAX_FEATURE_COUNT = 1024;
	localparam age_pkg_MAX_AGC_PER_NODE = 64;
	localparam top_pkg_MAX_NODESLOT_COUNT = 32;
	localparam age_pkg_AGC_COLS = top_pkg_MAX_NODESLOT_COUNT;
	localparam age_pkg_BM_COLS = 1;
	localparam age_pkg_MESH_COLS = 33;
	localparam age_pkg_AGC_ROWS = 4;
	localparam age_pkg_AGM_ROWS = 1;
	localparam age_pkg_MESH_ROWS = 5;
	localparam age_pkg_AGM_COLS = top_pkg_MAX_NODESLOT_COUNT;
	localparam age_pkg_TOTAL_AGGREGATION_MANAGERS = 32;
	localparam top_pkg_MAX_NODES = 1048576;
	localparam top_pkg_NODE_ID_WIDTH = 20;
	input wire [611:0] age_buffer_manager_nodeslot_allocation;
	input wire buffer_manager_router_on;
	output reg buffer_manager_router_valid;
	input wire buffer_manager_router_ready;
	localparam noc_params_MESH_SIZE_X = 65;
	localparam noc_params_DEST_ADDR_SIZE_X = 7;
	localparam noc_params_MESH_SIZE_Y = 5;
	localparam noc_params_DEST_ADDR_SIZE_Y = 3;
	localparam noc_params_HEAD_PAYLOAD_SIZE = 74;
	localparam noc_params_FLIT_DATA_SIZE = 84;
	localparam noc_params_VC_NUM = 1;
	localparam noc_params_VC_SIZE = 0;
	output reg [85:0] buffer_manager_router_data;
	output reg router_buffer_manager_on;
	input wire router_buffer_manager_valid;
	output reg router_buffer_manager_ready;
	input wire [85:0] router_buffer_manager_data;
	output wire buffer_slot_set_node_id_valid;
	output wire [19:0] buffer_slot_set_node_id;
	output reg bm_buffer_slot_write_enable;
	output reg [$clog2(BUFFER_SLOT_WRITE_DEPTH) - 1:0] bm_buffer_slot_write_address;
	output reg [BUFFER_SLOT_WRITE_WIDTH - 1:0] bm_buffer_slot_write_data;
	localparam top_pkg_AGGREGATION_BUFFER_READ_DEPTH = 1024;
	input wire [9:0] buffer_slot_bm_feature_count;
	input wire buffer_slot_bm_slot_free;
	reg [2:0] bm_state;
	reg [2:0] bm_state_n;
	reg [31:0] allocated_agm_q;
	reg [383:0] allocated_agcs_x_coords_q;
	reg [191:0] allocated_agcs_y_coords_q;
	reg [5:0] allocated_agcs_count_q;
	wire [63:0] allocated_agcs_oh;
	wire [63:0] allocated_agcs;
	wire [63:0] agc_done;
	reg [85:0] received_flit;
	wire [5:0] agc_offset;
	reg [2:0] received_packet_source_row;
	reg [5:0] received_packet_source_col;
	reg [2:0] incoming_packet_source_row;
	reg [5:0] incoming_packet_source_col;
	wire [63:0] agc_source_oh;
	wire [63:0] agc_source_oh_early;
	reg [255:0] flit_counter;
	reg [5:0] outgoing_packet_dest_col;
	reg [2:0] outgoing_packet_dest_row;
	reg noc_router_waiting;
	reg done_head_sent;
	binary_to_onehot #(.WIDTH(6)) allocated_agcs_bin2oh(
		.binary_input(allocated_agcs_count_q),
		.one_hot_output(allocated_agcs_oh)
	);
	onehot_to_binary_comb #(.INPUT_WIDTH(age_pkg_MAX_AGC_PER_NODE)) agc_offset_oh2bin(
		.input_data(agc_source_oh),
		.output_data(agc_offset)
	);
	assign buffer_slot_set_node_id = age_buffer_manager_nodeslot_allocation[606-:20];
	assign buffer_slot_set_node_id_valid = (bm_state == 3'd0) && age_buffer_manager_nodeslot_allocation_valid;
	always @(posedge core_clk or negedge resetn)
		if (!resetn)
			bm_state <= 3'd0;
		else
			bm_state <= bm_state_n;
	always @(*) begin
		bm_state_n = bm_state;
		case (bm_state)
			3'd0: bm_state_n = (age_buffer_manager_nodeslot_allocation_valid ? 3'd1 : 3'd0);
			3'd1: bm_state_n = (router_buffer_manager_valid ? 3'd2 : 3'd1);
			3'd2: bm_state_n = (&agc_done ? 3'd3 : 3'd1);
			3'd3: bm_state_n = (noc_router_waiting && done_head_sent ? 3'd4 : 3'd3);
			3'd4: bm_state_n = (noc_router_waiting ? 3'd0 : 3'd5);
			3'd5: bm_state_n = (buffer_slot_bm_slot_free ? 3'd0 : 3'd5);
			default: bm_state_n = 3'd0;
		endcase
	end
	assign age_buffer_manager_nodeslot_allocation_ready = bm_state == 3'd0;
	always @(posedge core_clk or negedge resetn)
		if (!resetn) begin
			allocated_agm_q <= 1'sb0;
			allocated_agcs_x_coords_q <= 1'sb0;
			allocated_agcs_y_coords_q <= 1'sb0;
			allocated_agcs_count_q <= 1'sb0;
		end
		else if (age_buffer_manager_nodeslot_allocation_valid && age_buffer_manager_nodeslot_allocation_ready) begin
			allocated_agm_q <= age_buffer_manager_nodeslot_allocation[586-:5];
			allocated_agcs_x_coords_q <= age_buffer_manager_nodeslot_allocation[581-:384];
			allocated_agcs_y_coords_q <= age_buffer_manager_nodeslot_allocation[197-:192];
			allocated_agcs_count_q <= age_buffer_manager_nodeslot_allocation[5-:6];
		end
	assign allocated_agcs = allocated_agcs_oh - 1'b1;
	localparam age_pkg_MESH_NODE_ID_WIDTH = 9;
	function [8:0] age_pkg_decode_packet_source;
		input reg [85:0] input_packet;
		reg [8:0] packet_source;
		reg [2:0] packet_source_row;
		reg [5:0] packet_source_col;
		begin
			packet_source = input_packet[73:65];
			packet_source_col = packet_source[8:3];
			packet_source_row = packet_source[2:0];
			age_pkg_decode_packet_source = {packet_source_col, packet_source_row};
		end
	endfunction
	always @(*) begin
		{received_packet_source_col, received_packet_source_row} = age_pkg_decode_packet_source(received_flit);
		{incoming_packet_source_col, incoming_packet_source_row} = age_pkg_decode_packet_source(router_buffer_manager_data);
	end
	always @(*) begin
		router_buffer_manager_on = bm_state == 3'd1;
		router_buffer_manager_ready = bm_state == 3'd1;
	end
	always @(posedge core_clk or negedge resetn)
		if (!resetn)
			received_flit <= 1'sb0;
		else if ((router_buffer_manager_on && router_buffer_manager_valid) && router_buffer_manager_ready)
			received_flit <= router_buffer_manager_data;
	genvar agc_source;
	generate
		for (agc_source = 0; agc_source < age_pkg_MAX_AGC_PER_NODE; agc_source = agc_source + 1) begin : genblk1
			assign agc_source_oh[agc_source] = (allocated_agcs_x_coords_q[agc_source * 6+:6] == received_packet_source_col) && (allocated_agcs_y_coords_q[agc_source * 3+:3] == received_packet_source_row);
			assign agc_source_oh_early[agc_source] = (allocated_agcs_x_coords_q[agc_source * 6+:6] == incoming_packet_source_col) && (allocated_agcs_y_coords_q[agc_source * 3+:3] == incoming_packet_source_row);
			always @(posedge core_clk or negedge resetn)
				if (!resetn)
					flit_counter[agc_source * 4+:4] <= 1'sb0;
				else if ((bm_state == 3'd0) && age_buffer_manager_nodeslot_allocation_valid)
					flit_counter[agc_source * 4+:4] <= 1'sb0;
				else if ((router_buffer_manager_on && router_buffer_manager_valid) && router_buffer_manager_ready)
					flit_counter[agc_source * 4+:4] <= (agc_source_oh_early[agc_source] ? flit_counter[agc_source * 4+:4] + 1 : flit_counter[agc_source * 4+:4]);
			assign agc_done[agc_source] = (allocated_agcs[agc_source] ? flit_counter[agc_source * 4+:4] == 'd8 : 1'b1);
		end
	endgenerate
	always @(*) begin
		bm_buffer_slot_write_enable = bm_state == 3'd2;
		bm_buffer_slot_write_address = {agc_offset, flit_counter[agc_offset * 4+:4] - 1'b1};
		bm_buffer_slot_write_data = received_flit[63:0];
	end
	localparam age_pkg_PAYLOAD_DATA_WIDTH = 64;
	always @(*) begin
		buffer_manager_router_valid = bm_state == 3'd3;
		outgoing_packet_dest_col = allocated_agm_q;
		outgoing_packet_dest_row = 4;
		buffer_manager_router_data[83-:2] = 1'sb0;
		buffer_manager_router_data[85-:2] = (done_head_sent ? 2'd2 : 2'd0);
		buffer_manager_router_data[83-:noc_params_FLIT_DATA_SIZE] = {outgoing_packet_dest_col, outgoing_packet_dest_row, X_COORD[5:0], Y_COORD[5:0], {age_pkg_PAYLOAD_DATA_WIDTH {1'b0}}};
	end
	always @(posedge core_clk or negedge resetn)
		if (!resetn) begin
			noc_router_waiting <= 1'sb1;
			done_head_sent <= 1'sb0;
		end
		else if (buffer_manager_router_ready)
			noc_router_waiting <= 1'sb1;
		else if (buffer_manager_router_valid && (buffer_manager_router_data[85-:2] == 2'd0))
			done_head_sent <= 1'sb1;
		else if (buffer_manager_router_valid && (buffer_manager_router_data[85-:2] == 2'd2)) begin
			noc_router_waiting <= 1'sb0;
			done_head_sent <= 1'sb0;
		end
endmodule
module aggregation_engine (
	core_clk,
	resetn,
	s_axi_awaddr,
	s_axi_awprot,
	s_axi_awvalid,
	s_axi_awready,
	s_axi_wdata,
	s_axi_wstrb,
	s_axi_wvalid,
	s_axi_wready,
	s_axi_araddr,
	s_axi_arprot,
	s_axi_arvalid,
	s_axi_arready,
	s_axi_rdata,
	s_axi_rresp,
	s_axi_rvalid,
	s_axi_rready,
	s_axi_bresp,
	s_axi_bvalid,
	s_axi_bready,
	nsb_age_req_valid,
	nsb_age_req_ready,
	nsb_age_req,
	nsb_age_resp_valid,
	nsb_age_resp,
	message_channel_req_valid,
	message_channel_req_ready,
	message_channel_req,
	message_channel_resp_valid,
	message_channel_resp_ready,
	message_channel_resp,
	aggregation_buffer_slot_set_node_id_valid,
	aggregation_buffer_slot_set_node_id,
	aggregation_buffer_slot_write_enable,
	aggregation_buffer_slot_write_address,
	aggregation_buffer_slot_write_data,
	aggregation_buffer_slot_feature_count,
	aggregation_buffer_slot_slot_free,
	scale_factor_queue_pop,
	scale_factor_queue_out_data,
	scale_factor_queue_count,
	scale_factor_queue_empty,
	scale_factor_queue_full
);
	parameter AXI_ADDR_WIDTH = 32;
	input wire core_clk;
	input wire resetn;
	input wire [AXI_ADDR_WIDTH - 1:0] s_axi_awaddr;
	input wire [2:0] s_axi_awprot;
	input wire s_axi_awvalid;
	output wire s_axi_awready;
	input wire [31:0] s_axi_wdata;
	input wire [3:0] s_axi_wstrb;
	input wire s_axi_wvalid;
	output wire s_axi_wready;
	input wire [AXI_ADDR_WIDTH - 1:0] s_axi_araddr;
	input wire [2:0] s_axi_arprot;
	input wire s_axi_arvalid;
	output wire s_axi_arready;
	output wire [31:0] s_axi_rdata;
	output wire [1:0] s_axi_rresp;
	output wire s_axi_rvalid;
	input wire s_axi_rready;
	output wire [1:0] s_axi_bresp;
	output wire s_axi_bvalid;
	input wire s_axi_bready;
	input wire nsb_age_req_valid;
	output reg nsb_age_req_ready;
	localparam top_pkg_MAX_NODESLOT_COUNT = 32;
	localparam top_pkg_FETCH_TAG_COUNT = top_pkg_MAX_NODESLOT_COUNT;
	localparam top_pkg_MAX_NODES = 1048576;
	localparam top_pkg_NODE_ID_WIDTH = 20;
	input wire [33:0] nsb_age_req;
	output wire nsb_age_resp_valid;
	output wire [4:0] nsb_age_resp;
	localparam top_pkg_MESSAGE_CHANNEL_COUNT = top_pkg_MAX_NODESLOT_COUNT;
	output wire [31:0] message_channel_req_valid;
	input wire [31:0] message_channel_req_ready;
	output wire [319:0] message_channel_req;
	input wire [31:0] message_channel_resp_valid;
	output wire [31:0] message_channel_resp_ready;
	localparam top_pkg_AXI_DATA_WIDTH = 512;
	input wire [16447:0] message_channel_resp;
	localparam top_pkg_AGGREGATION_BUFFER_SLOTS = 16;
	output wire [15:0] aggregation_buffer_slot_set_node_id_valid;
	output wire [319:0] aggregation_buffer_slot_set_node_id;
	output wire [15:0] aggregation_buffer_slot_write_enable;
	localparam top_pkg_MAX_FEATURE_COUNT = 1024;
	localparam top_pkg_AGGREGATION_BUFFER_WRITE_DEPTH = 512;
	output wire [143:0] aggregation_buffer_slot_write_address;
	localparam age_pkg_PAYLOAD_DATA_WIDTH = 64;
	output wire [1023:0] aggregation_buffer_slot_write_data;
	localparam top_pkg_AGGREGATION_BUFFER_READ_DEPTH = 1024;
	input wire [159:0] aggregation_buffer_slot_feature_count;
	input wire [15:0] aggregation_buffer_slot_slot_free;
	localparam age_pkg_AGM_COLS = top_pkg_MAX_NODESLOT_COUNT;
	localparam age_pkg_AGM_ROWS = 1;
	localparam age_pkg_TOTAL_AGGREGATION_MANAGERS = 32;
	output wire [31:0] scale_factor_queue_pop;
	localparam top_pkg_SCALE_FACTOR_QUEUE_READ_WIDTH = 32;
	input wire [1023:0] scale_factor_queue_out_data;
	localparam top_pkg_SCALE_FACTOR_QUEUE_READ_DEPTH = 1024;
	input wire [351:0] scale_factor_queue_count;
	input wire [31:0] scale_factor_queue_empty;
	input wire [31:0] scale_factor_queue_full;
	wire layer_config_in_features_strobe;
	wire [9:0] layer_config_in_features_count;
	wire layer_config_out_features_strobe;
	wire [3:0] layer_config_out_features_count;
	wire layer_config_upsampling_parameter_strobe;
	wire [31:0] layer_config_upsampling_parameter_value;
	localparam age_pkg_AGC_COLS = top_pkg_MAX_NODESLOT_COUNT;
	localparam age_pkg_BM_COLS = 1;
	localparam age_pkg_MESH_COLS = 33;
	localparam age_pkg_AGC_ROWS = 4;
	localparam age_pkg_MESH_ROWS = 5;
	localparam noc_params_VC_NUM = 1;
	wire [164:0] node_router_on;
	reg [164:0] node_router_valid;
	wire [164:0] node_router_ready;
	localparam noc_params_MESH_SIZE_X = 65;
	localparam noc_params_DEST_ADDR_SIZE_X = 7;
	localparam noc_params_MESH_SIZE_Y = 5;
	localparam noc_params_DEST_ADDR_SIZE_Y = 3;
	localparam noc_params_HEAD_PAYLOAD_SIZE = 74;
	localparam noc_params_FLIT_DATA_SIZE = 84;
	localparam noc_params_VC_SIZE = 0;
	reg [14189:0] node_router_data;
	reg [164:0] router_node_on;
	wire [164:0] router_node_valid;
	reg [164:0] router_node_ready;
	wire [14189:0] router_node_data;
	wire allocation_req_ready_float32;
	wire allocation_req_ready_fixed16;
	reg [31:0] age_agm_req_valid;
	wire [31:0] age_agm_req_valid_float32;
	wire [31:0] age_agm_req_valid_fixed16;
	wire [31:0] age_agm_req_ready;
	localparam age_pkg_AGC_FLOAT32_COLS = 8;
	localparam age_pkg_AGC_FLOAT32_ROWS = 4;
	localparam age_pkg_AGC_COUNT_FLOAT32 = 32;
	localparam age_pkg_MAX_AGC_PER_NODE = 64;
	wire [20735:0] age_agm_req;
	wire [647:0] age_agm_req_float32;
	wire [647:0] age_agm_req_fixed16;
	wire [31:0] aggregation_manager_age_done_valid;
	reg [31:0] aggregation_manager_age_done_ready;
	wire [31:0] age_agm_buffer_manager_allocation_valid;
	wire [31:0] age_agm_buffer_manager_allocation_ready;
	localparam age_pkg_BM_ROWS = 4;
	localparam age_pkg_TOTAL_BUFFER_MANAGERS = 4;
	wire [1:0] age_agm_buffer_manager_allocation;
	reg [31:0] aggregation_manager_router_on;
	wire [31:0] aggregation_manager_router_valid;
	reg [31:0] aggregation_manager_router_ready;
	wire [2751:0] aggregation_manager_router_data;
	wire [31:0] router_aggregation_manager_on;
	reg [31:0] router_aggregation_manager_valid;
	wire [31:0] router_aggregation_manager_ready;
	reg [2751:0] router_aggregation_manager_data;
	wire [1087:0] agm_allocation;
	wire [1023:0] agm_allocated_agcs;
	wire [191:0] agm_allocated_agcs_count;
	wire [12287:0] agm_coords_buffer_x;
	wire [6143:0] agm_coords_buffer_y;
	wire [31:0] aggregation_manager_resp_arbitration_oh;
	wire [4:0] aggregation_manager_resp_arbitration_bin;
	wire [127:0] aggregation_core_free;
	reg [127:0] aggregation_core_router_on;
	wire [127:0] aggregation_core_router_valid;
	reg [127:0] aggregation_core_router_ready;
	wire [11007:0] aggregation_core_router_data;
	wire [127:0] router_aggregation_core_on;
	reg [127:0] router_aggregation_core_valid;
	wire [127:0] router_aggregation_core_ready;
	reg [11007:0] router_aggregation_core_data;
	wire [3:0] age_bm_nodeslot_allocation_valid;
	wire [3:0] age_bm_nodeslot_allocation_ready;
	reg [611:0] age_bm_nodeslot_allocation;
	wire [4:0] agm_receiving_buffer_manager_allocation;
	reg [3:0] buffer_manager_router_on;
	wire [3:0] buffer_manager_router_valid;
	reg [3:0] buffer_manager_router_ready;
	wire [343:0] buffer_manager_router_data;
	wire [3:0] router_buffer_manager_on;
	reg [3:0] router_buffer_manager_valid;
	wire [3:0] router_buffer_manager_ready;
	reg [343:0] router_buffer_manager_data;
	wire [31:0] agc_float32_free_mask;
	localparam age_pkg_AGC_FIXED16_COLS = 8;
	localparam age_pkg_AGC_FIXED16_ROWS = 4;
	localparam age_pkg_AGC_COUNT_FIXED16 = 32;
	wire [31:0] agc_fixed16_free_mask;
	wire [3:0] buffer_master_allocation_oh;
	wire agm_waiting;
	wire bm_waiting;
	localparam noc_params_PORT_NUM = 5;
	wire [824:0] error_o;
	aggregation_engine_regbank_regs #(
		.AXI_ADDR_WIDTH(32),
		.BASEADDR(32'b00000000000000000000000000000000)
	) aggregation_engine_regbank_regs_i(
		.axi_aclk(core_clk),
		.axi_aresetn(resetn),
		.s_axi_awaddr(s_axi_awaddr),
		.s_axi_awprot(s_axi_awprot),
		.s_axi_awvalid(s_axi_awvalid),
		.s_axi_awready(s_axi_awready),
		.s_axi_wdata(s_axi_wdata),
		.s_axi_wstrb(s_axi_wstrb),
		.s_axi_wvalid(s_axi_wvalid),
		.s_axi_wready(s_axi_wready),
		.s_axi_araddr(s_axi_araddr),
		.s_axi_arprot(s_axi_arprot),
		.s_axi_arvalid(s_axi_arvalid),
		.s_axi_arready(s_axi_arready),
		.s_axi_rdata(s_axi_rdata),
		.s_axi_rresp(s_axi_rresp),
		.s_axi_rvalid(s_axi_rvalid),
		.s_axi_rready(s_axi_rready),
		.s_axi_bresp(s_axi_bresp),
		.s_axi_bvalid(s_axi_bvalid),
		.s_axi_bready(s_axi_bready),
		.layer_config_in_features_strobe(layer_config_in_features_strobe),
		.layer_config_in_features_count(layer_config_in_features_count),
		.layer_config_out_features_strobe(layer_config_out_features_strobe),
		.layer_config_out_features_count(layer_config_out_features_count),
		.layer_config_upsampling_parameter_strobe(layer_config_upsampling_parameter_strobe),
		.layer_config_upsampling_parameter_value(layer_config_upsampling_parameter_value)
	);
	mesh #(
		.BUFFER_SIZE(10),
		.MESH_SIZE_X(age_pkg_MESH_COLS),
		.MESH_SIZE_Y(age_pkg_MESH_ROWS)
	) noc_mesh_i(
		.clk(core_clk),
		.rst(!resetn),
		.is_on_off_o(node_router_on),
		.is_valid_i(node_router_valid),
		.is_allocatable_o(node_router_ready),
		.data_i(node_router_data),
		.is_on_off_i(router_node_on),
		.is_valid_o(router_node_valid),
		.is_allocatable_i(router_node_ready),
		.data_o(router_node_data),
		.error_o(error_o)
	);
	genvar agm;
	generate
		for (agm = 0; agm < age_pkg_TOTAL_AGGREGATION_MANAGERS; agm = agm + 1) begin : genblk1
			aggregation_manager #(
				.X_COORD(agm),
				.Y_COORD(4)
			) agm_i(
				.core_clk(core_clk),
				.resetn(resetn),
				.age_aggregation_manager_req_valid(age_agm_req_valid[agm]),
				.age_aggregation_manager_req_ready(age_agm_req_ready[agm]),
				.age_aggregation_manager_req(age_agm_req[agm * 648+:648]),
				.aggregation_manager_age_done_valid(aggregation_manager_age_done_valid[agm]),
				.aggregation_manager_age_done_ready(aggregation_manager_age_done_ready[agm]),
				.age_aggregation_manager_buffer_manager_allocation_valid(age_agm_buffer_manager_allocation_valid[agm]),
				.age_aggregation_manager_buffer_manager_allocation_ready(age_agm_buffer_manager_allocation_ready[agm]),
				.age_aggregation_manager_buffer_manager_allocation(age_agm_buffer_manager_allocation),
				.message_channel_req_valid(message_channel_req_valid[agm]),
				.message_channel_req_ready(message_channel_req_ready[agm]),
				.message_channel_req(message_channel_req[agm * 10+:10]),
				.message_channel_resp_valid(message_channel_resp_valid[agm]),
				.message_channel_resp_ready(message_channel_resp_ready[agm]),
				.message_channel_resp(message_channel_resp[0 + (agm * 514)+:514]),
				.aggregation_manager_router_on(aggregation_manager_router_on[agm]),
				.aggregation_manager_router_valid(aggregation_manager_router_valid[agm]),
				.aggregation_manager_router_ready(aggregation_manager_router_ready[agm]),
				.aggregation_manager_router_data(aggregation_manager_router_data[agm * 86+:86]),
				.router_aggregation_manager_on(router_aggregation_manager_on[agm]),
				.router_aggregation_manager_valid(router_aggregation_manager_valid[agm]),
				.router_aggregation_manager_ready(router_aggregation_manager_ready[agm]),
				.router_aggregation_manager_data(router_aggregation_manager_data[agm * 86+:86]),
				.agm_allocation(agm_allocation[0 + (agm * 34)+:34]),
				.agm_allocated_agcs(agm_allocated_agcs[agm * 32+:32]),
				.agm_allocated_agcs_count(agm_allocated_agcs_count[agm * 6+:6]),
				.coords_buffer_x(agm_coords_buffer_x[6 * (agm * 64)+:384]),
				.coords_buffer_y(agm_coords_buffer_y[3 * (agm * 64)+:192]),
				.scale_factor_queue_pop(scale_factor_queue_pop[agm]),
				.scale_factor_queue_out_data(scale_factor_queue_out_data[agm * 32+:32]),
				.scale_factor_queue_count(scale_factor_queue_count[agm * 11+:11]),
				.scale_factor_queue_empty(scale_factor_queue_empty[agm]),
				.scale_factor_queue_full(scale_factor_queue_full[agm])
			);
			always @(*) begin
				aggregation_manager_age_done_ready[agm] = aggregation_manager_resp_arbitration_oh[agm];
				aggregation_manager_router_on[agm] = node_router_on[(agm * 5) + 4];
				aggregation_manager_router_ready[agm] = node_router_ready[(agm * 5) + 4];
				node_router_valid[(agm * 5) + 4] = aggregation_manager_router_valid[agm];
				node_router_data[((agm * 5) + 4) * 86+:86] = aggregation_manager_router_data[agm * 86+:86];
				router_aggregation_manager_valid[agm] = router_node_valid[(agm * 5) + 4];
				router_aggregation_manager_data[agm * 86+:86] = router_node_data[((agm * 5) + 4) * 86+:86];
				router_node_on[(agm * 5) + 4] = router_aggregation_manager_on[agm];
				router_node_ready[(agm * 5) + 4] = router_aggregation_manager_ready[agm];
			end
			assign age_agm_req[agm * 648+:648] = (age_agm_req_valid_float32[agm] ? age_agm_req_float32 : (age_agm_req_valid_fixed16[agm] ? age_agm_req_fixed16 : {648 {1'sb0}}));
		end
	endgenerate
	genvar agc_float32_row;
	localparam age_pkg_AGC_FLOAT32_COL_OFFSET = 0;
	generate
		for (agc_float32_row = 0; agc_float32_row < age_pkg_AGC_FLOAT32_ROWS; agc_float32_row = agc_float32_row + 1) begin : float32_row_gen
			assign agc_float32_free_mask[((agc_float32_row + 1) * age_pkg_AGC_FLOAT32_COLS) - 1:agc_float32_row * age_pkg_AGC_FLOAT32_COLS] = aggregation_core_free[(agc_float32_row * 32) + 7-:8];
			genvar agc_float32_col;
			for (agc_float32_col = 0; agc_float32_col < age_pkg_AGC_FLOAT32_COLS; agc_float32_col = agc_float32_col + 1) begin : float32_col_gen
				aggregation_core #(
					.X_COORD(agc_float32_col),
					.Y_COORD(agc_float32_row),
					.FEATURE_COUNT(16),
					.DATA_WIDTH(32)
				) agc_float32_i(
					.core_clk(core_clk),
					.resetn(resetn),
					.aggregation_core_free(aggregation_core_free[(agc_float32_row * 32) + agc_float32_col]),
					.aggregation_core_router_on(aggregation_core_router_on[(agc_float32_row * 32) + agc_float32_col]),
					.aggregation_core_router_valid(aggregation_core_router_valid[(agc_float32_row * 32) + agc_float32_col]),
					.aggregation_core_router_ready(aggregation_core_router_ready[(agc_float32_row * 32) + agc_float32_col]),
					.aggregation_core_router_data(aggregation_core_router_data[((agc_float32_row * 32) + agc_float32_col) * 86+:86]),
					.router_aggregation_core_on(router_aggregation_core_on[(agc_float32_row * 32) + agc_float32_col]),
					.router_aggregation_core_valid(router_aggregation_core_valid[(agc_float32_row * 32) + agc_float32_col]),
					.router_aggregation_core_ready(router_aggregation_core_ready[(agc_float32_row * 32) + agc_float32_col]),
					.router_aggregation_core_data(router_aggregation_core_data[((agc_float32_row * 32) + agc_float32_col) * 86+:86]),
					.layer_config_upsampling_parameter(layer_config_upsampling_parameter_value)
				);
				always @(*) begin
					aggregation_core_router_on[(agc_float32_row * 32) + agc_float32_col] = node_router_on[(agc_float32_col * 5) + agc_float32_row];
					aggregation_core_router_ready[(agc_float32_row * 32) + agc_float32_col] = node_router_ready[(agc_float32_col * 5) + agc_float32_row];
					node_router_valid[(agc_float32_col * 5) + agc_float32_row] = aggregation_core_router_valid[(agc_float32_row * 32) + agc_float32_col];
					node_router_data[((agc_float32_col * 5) + agc_float32_row) * 86+:86] = aggregation_core_router_data[((agc_float32_row * 32) + agc_float32_col) * 86+:86];
					router_aggregation_core_valid[(agc_float32_row * 32) + agc_float32_col] = router_node_valid[(agc_float32_col * 5) + agc_float32_row];
					router_aggregation_core_data[((agc_float32_row * 32) + agc_float32_col) * 86+:86] = router_node_data[((agc_float32_col * 5) + agc_float32_row) * 86+:86];
					router_node_on[(agc_float32_col * 5) + agc_float32_row] = router_aggregation_core_on[(agc_float32_row * 32) + agc_float32_col];
					router_node_ready[(agc_float32_col * 5) + agc_float32_row] = router_aggregation_core_ready[(agc_float32_row * 32) + agc_float32_col];
				end
			end
		end
	endgenerate
	genvar agc_fixed16_row;
	localparam age_pkg_AGC_FIXED16_COL_OFFSET = age_pkg_AGC_FLOAT32_COLS;
	generate
		for (agc_fixed16_row = 0; agc_fixed16_row < age_pkg_AGC_FIXED16_ROWS; agc_fixed16_row = agc_fixed16_row + 1) begin : fixed16_row_gen
			assign agc_fixed16_free_mask[((agc_fixed16_row + 1) * age_pkg_AGC_FIXED16_COLS) - 1:agc_fixed16_row * age_pkg_AGC_FIXED16_COLS] = aggregation_core_free[(agc_fixed16_row * 32) + 15-:8];
			genvar agc_fixed16_col;
			for (agc_fixed16_col = age_pkg_AGC_FIXED16_COL_OFFSET; agc_fixed16_col < 16; agc_fixed16_col = agc_fixed16_col + 1) begin : fixed16_col_gen
				aggregation_core #(
					.X_COORD(agc_fixed16_col),
					.Y_COORD(agc_fixed16_row),
					.FEATURE_COUNT(16),
					.DATA_WIDTH(16),
					.PRECISION("FIXED_16")
				) agc_fixed16_i(
					.core_clk(core_clk),
					.resetn(resetn),
					.aggregation_core_free(aggregation_core_free[(agc_fixed16_row * 32) + agc_fixed16_col]),
					.aggregation_core_router_on(aggregation_core_router_on[(agc_fixed16_row * 32) + agc_fixed16_col]),
					.aggregation_core_router_valid(aggregation_core_router_valid[(agc_fixed16_row * 32) + agc_fixed16_col]),
					.aggregation_core_router_ready(aggregation_core_router_ready[(agc_fixed16_row * 32) + agc_fixed16_col]),
					.aggregation_core_router_data(aggregation_core_router_data[((agc_fixed16_row * 32) + agc_fixed16_col) * 86+:86]),
					.router_aggregation_core_on(router_aggregation_core_on[(agc_fixed16_row * 32) + agc_fixed16_col]),
					.router_aggregation_core_valid(router_aggregation_core_valid[(agc_fixed16_row * 32) + agc_fixed16_col]),
					.router_aggregation_core_ready(router_aggregation_core_ready[(agc_fixed16_row * 32) + agc_fixed16_col]),
					.router_aggregation_core_data(router_aggregation_core_data[((agc_fixed16_row * 32) + agc_fixed16_col) * 86+:86]),
					.layer_config_upsampling_parameter(layer_config_upsampling_parameter_value)
				);
				always @(*) begin
					aggregation_core_router_on[(agc_fixed16_row * 32) + agc_fixed16_col] = node_router_on[(agc_fixed16_col * 5) + agc_fixed16_row];
					aggregation_core_router_ready[(agc_fixed16_row * 32) + agc_fixed16_col] = node_router_ready[(agc_fixed16_col * 5) + agc_fixed16_row];
					node_router_valid[(agc_fixed16_col * 5) + agc_fixed16_row] = aggregation_core_router_valid[(agc_fixed16_row * 32) + agc_fixed16_col];
					node_router_data[((agc_fixed16_col * 5) + agc_fixed16_row) * 86+:86] = aggregation_core_router_data[((agc_fixed16_row * 32) + agc_fixed16_col) * 86+:86];
					router_aggregation_core_valid[(agc_fixed16_row * 32) + agc_fixed16_col] = router_node_valid[(agc_fixed16_col * 5) + agc_fixed16_row];
					router_aggregation_core_data[((agc_fixed16_row * 32) + agc_fixed16_col) * 86+:86] = router_node_data[((agc_fixed16_col * 5) + agc_fixed16_row) * 86+:86];
					router_node_on[(agc_fixed16_col * 5) + agc_fixed16_row] = router_aggregation_core_on[(agc_fixed16_row * 32) + agc_fixed16_col];
					router_node_ready[(agc_fixed16_col * 5) + agc_fixed16_row] = router_aggregation_core_ready[(agc_fixed16_row * 32) + agc_fixed16_col];
				end
			end
		end
	endgenerate
	genvar col;
	localparam age_pkg_AGC_UNUSED_COLS_OFFSET = 16;
	generate
		for (col = age_pkg_AGC_UNUSED_COLS_OFFSET; col < age_pkg_AGC_COLS; col = col + 1) begin : genblk4
			genvar row;
			for (row = 0; row < 8; row = row + 1) begin : genblk1
				always @(*) begin
					node_router_valid[(col * 5) + row] = 1'sb0;
					node_router_data[((col * 5) + row) * 86+:86] = 1'sb0;
					router_node_on[(col * 5) + row+:1] = 1'sb0;
					router_node_ready[(col * 5) + row+:1] = 1'sb0;
				end
			end
		end
	endgenerate
	genvar bm;
	generate
		for (bm = 0; bm < age_pkg_TOTAL_BUFFER_MANAGERS; bm = bm + 1) begin : genblk5
			buffer_manager #(
				.X_COORD(age_pkg_AGC_COLS),
				.Y_COORD(bm)
			) buffer_manager_i(
				.core_clk(core_clk),
				.resetn(resetn),
				.age_buffer_manager_nodeslot_allocation_valid(age_bm_nodeslot_allocation_valid[bm]),
				.age_buffer_manager_nodeslot_allocation_ready(age_bm_nodeslot_allocation_ready[bm]),
				.age_buffer_manager_nodeslot_allocation(age_bm_nodeslot_allocation),
				.buffer_manager_router_on(buffer_manager_router_on[bm+:1]),
				.buffer_manager_router_valid(buffer_manager_router_valid[bm+:1]),
				.buffer_manager_router_ready(buffer_manager_router_ready[bm+:1]),
				.buffer_manager_router_data(buffer_manager_router_data[86 * bm+:86]),
				.router_buffer_manager_on(router_buffer_manager_on[bm+:1]),
				.router_buffer_manager_valid(router_buffer_manager_valid[bm+:1]),
				.router_buffer_manager_ready(router_buffer_manager_ready[bm+:1]),
				.router_buffer_manager_data(router_buffer_manager_data[86 * bm+:86]),
				.buffer_slot_set_node_id_valid(aggregation_buffer_slot_set_node_id_valid[bm]),
				.buffer_slot_set_node_id(aggregation_buffer_slot_set_node_id[bm * 20+:20]),
				.bm_buffer_slot_write_enable(aggregation_buffer_slot_write_enable[bm]),
				.bm_buffer_slot_write_address(aggregation_buffer_slot_write_address[bm * 9+:9]),
				.bm_buffer_slot_write_data(aggregation_buffer_slot_write_data[bm * 64+:64]),
				.buffer_slot_bm_feature_count(aggregation_buffer_slot_feature_count[bm * 10+:10]),
				.buffer_slot_bm_slot_free(aggregation_buffer_slot_slot_free[bm])
			);
			always @(*) begin
				buffer_manager_router_on[bm+:1] = node_router_on[160 + bm];
				buffer_manager_router_ready[bm+:1] = node_router_ready[160 + bm];
				node_router_valid[160 + bm] = buffer_manager_router_valid[bm+:1];
				node_router_data[(160 + bm) * 86+:86] = buffer_manager_router_data[86 * bm+:86];
				router_buffer_manager_valid[bm+:1] = router_node_valid[160 + bm];
				router_buffer_manager_data[86 * bm+:86] = router_node_data[(160 + bm) * 86+:86];
				router_node_on[160 + bm] = router_buffer_manager_on[bm+:1];
				router_node_ready[160 + bm] = router_buffer_manager_ready[bm+:1];
			end
		end
	endgenerate
	genvar row;
	generate
		for (row = age_pkg_TOTAL_BUFFER_MANAGERS; row < top_pkg_AGGREGATION_BUFFER_SLOTS; row = row + 1) begin : genblk6
			assign aggregation_buffer_slot_write_enable = 1'sb0;
			assign aggregation_buffer_slot_write_address = 1'sb0;
			assign aggregation_buffer_slot_write_data = 1'sb0;
		end
	endgenerate
	aggregation_core_allocator #(
		.NUM_CORES(age_pkg_AGC_COUNT_FLOAT32),
		.PRECISION_COL_OFFSET(age_pkg_AGC_FLOAT32_COL_OFFSET)
	) agc_float32_allocator(
		.core_clk(core_clk),
		.resetn(resetn),
		.allocation_req_valid(nsb_age_req_valid && (nsb_age_req[3-:2] == 2'd0)),
		.allocation_req_ready(allocation_req_ready_float32),
		.allocation_req(nsb_age_req),
		.cores_free(agc_float32_free_mask),
		.layer_config_in_features_count(layer_config_in_features_count),
		.deallocation_valid(nsb_age_resp_valid && (agm_allocation[(aggregation_manager_resp_arbitration_bin * 34) + 3-:2] == 2'd0)),
		.deallocation_cores(agm_allocated_agcs[aggregation_manager_resp_arbitration_bin * 32+:32]),
		.age_agm_req_valid(age_agm_req_valid_float32),
		.age_agm_req_ready(age_agm_req_ready),
		.age_agm_req(age_agm_req_float32)
	);
	aggregation_core_allocator #(
		.NUM_CORES(age_pkg_AGC_COUNT_FIXED16),
		.PRECISION_COL_OFFSET(age_pkg_AGC_FIXED16_COL_OFFSET)
	) agc_fixed16_allocator(
		.core_clk(core_clk),
		.resetn(resetn),
		.allocation_req_valid(nsb_age_req_valid && (nsb_age_req[3-:2] == 2'd1)),
		.allocation_req_ready(allocation_req_ready_fixed16),
		.allocation_req(nsb_age_req),
		.cores_free(agc_fixed16_free_mask),
		.layer_config_in_features_count(layer_config_in_features_count),
		.deallocation_valid(nsb_age_resp_valid && (agm_allocation[(aggregation_manager_resp_arbitration_bin * 34) + 3-:2] == 2'd1)),
		.deallocation_cores(agm_allocated_agcs[aggregation_manager_resp_arbitration_bin * 32+:32]),
		.age_agm_req_valid(age_agm_req_valid_fixed16),
		.age_agm_req_ready(age_agm_req_ready),
		.age_agm_req(age_agm_req_fixed16)
	);
	always @(*) begin
		nsb_age_req_ready = (nsb_age_req[3-:2] == 2'd0 ? allocation_req_ready_float32 : (nsb_age_req[3-:2] == 2'd1 ? allocation_req_ready_fixed16 : 1'b0));
		age_agm_req_valid = age_agm_req_valid_float32 | age_agm_req_valid_fixed16;
	end
	assign nsb_age_resp_valid = |aggregation_manager_age_done_valid;
	assign nsb_age_resp[4-:5] = agm_allocation[(aggregation_manager_resp_arbitration_bin * 34) + 33-:5];
	rr_arbiter #(.NUM_REQUESTERS(age_pkg_TOTAL_AGGREGATION_MANAGERS)) aggregation_manager_resp_arbiter(
		.clk(core_clk),
		.resetn(resetn),
		.request(aggregation_manager_age_done_valid),
		.update_lru(|aggregation_manager_age_done_valid),
		.grant_oh(aggregation_manager_resp_arbitration_oh)
	);
	onehot_to_binary_comb #(.INPUT_WIDTH(age_pkg_TOTAL_AGGREGATION_MANAGERS)) bm_alloc_oh2bin(
		.input_data(aggregation_manager_resp_arbitration_oh),
		.output_data(aggregation_manager_resp_arbitration_bin)
	);
	assign agm_waiting = age_agm_buffer_manager_allocation_ready != {32 {1'sb0}};
	assign bm_waiting = age_bm_nodeslot_allocation_ready != {4 {1'sb0}};
	wire [31:0] agm_allocation_oh;
	rr_arbiter #(.NUM_REQUESTERS(age_pkg_TOTAL_AGGREGATION_MANAGERS)) free_agm_arbiter(
		.clk(core_clk),
		.resetn(resetn),
		.request(age_agm_buffer_manager_allocation_ready),
		.update_lru(agm_waiting && bm_waiting),
		.grant_oh(agm_allocation_oh)
	);
	onehot_to_binary_comb #(.INPUT_WIDTH(age_pkg_TOTAL_AGGREGATION_MANAGERS)) agm_alloc_req_oh2bin(
		.input_data(agm_allocation_oh),
		.output_data(agm_receiving_buffer_manager_allocation)
	);
	assign age_agm_buffer_manager_allocation_valid = agm_allocation_oh & {age_pkg_TOTAL_AGGREGATION_MANAGERS {bm_waiting}};
	rr_arbiter #(.NUM_REQUESTERS(age_pkg_TOTAL_BUFFER_MANAGERS)) free_buffer_manager_arbiter(
		.clk(core_clk),
		.resetn(resetn),
		.request(age_bm_nodeslot_allocation_ready),
		.update_lru(agm_waiting && bm_waiting),
		.grant_oh(buffer_master_allocation_oh)
	);
	onehot_to_binary_comb #(.INPUT_WIDTH(age_pkg_TOTAL_BUFFER_MANAGERS)) agm_resp_arb_oh2bin(
		.input_data(buffer_master_allocation_oh),
		.output_data(age_agm_buffer_manager_allocation)
	);
	assign age_bm_nodeslot_allocation_valid = buffer_master_allocation_oh & {age_pkg_TOTAL_BUFFER_MANAGERS {agm_waiting}};
	always @(*) begin
		age_bm_nodeslot_allocation[611-:5] = agm_receiving_buffer_manager_allocation;
		age_bm_nodeslot_allocation[606-:20] = agm_allocation[(agm_receiving_buffer_manager_allocation * 34) + 28-:20];
		age_bm_nodeslot_allocation[586-:5] = agm_receiving_buffer_manager_allocation;
		age_bm_nodeslot_allocation[581-:384] = agm_coords_buffer_x[6 * (agm_receiving_buffer_manager_allocation * 64)+:384];
		age_bm_nodeslot_allocation[197-:192] = agm_coords_buffer_y[3 * (agm_receiving_buffer_manager_allocation * 64)+:192];
		age_bm_nodeslot_allocation[5-:6] = agm_allocated_agcs_count[agm_receiving_buffer_manager_allocation * 6+:6];
	end
endmodule
module hybrid_buffer_slot (
	core_clk,
	resetn,
	write_enable,
	write_address,
	write_data,
	pop,
	out_feature,
	feature_count,
	slot_free
);
	parameter WRITE_WIDTH = 64;
	parameter WRITE_DEPTH = 512;
	parameter READ_WIDTH = 32;
	parameter READ_DEPTH = 1024;
	parameter BUFFER_TYPE = "AGGREGATION";
	input wire core_clk;
	input wire resetn;
	input wire write_enable;
	input wire [$clog2(WRITE_DEPTH) - 1:0] write_address;
	input wire [WRITE_WIDTH - 1:0] write_data;
	input wire pop;
	output wire [READ_WIDTH - 1:0] out_feature;
	output reg [$clog2(READ_DEPTH) - 1:0] feature_count;
	output wire slot_free;
	reg [$clog2(READ_DEPTH) - 1:0] rd_ptr;
	wire [$clog2(READ_DEPTH) - 1:0] read_address;
	assign read_address = (pop ? rd_ptr + 1'b1 : rd_ptr);
	generate
		if (BUFFER_TYPE == "AGGREGATION") begin : genblk1
			aggregation_buffer_sdp_bram fifo(
				.clka(core_clk),
				.ena(1'sb1),
				.wea(write_enable),
				.addra(write_address),
				.dina(write_data),
				.clkb(core_clk),
				.enb(1'sb1),
				.addrb(read_address),
				.doutb(out_feature),
				.sleep(1'sb0)
			);
		end
		else if (BUFFER_TYPE == "TRANSFORMATION") begin : genblk1
			transformation_buffer_sdp_bram fifo(
				.clka(core_clk),
				.ena(1'sb1),
				.wea(write_enable),
				.addra(write_address),
				.dina(write_data),
				.clkb(core_clk),
				.enb(1'sb1),
				.addrb(read_address),
				.doutb(out_feature)
			);
		end
	endgenerate
	always @(posedge core_clk or negedge resetn)
		if (!resetn) begin
			rd_ptr <= 1'sb0;
			feature_count <= 0;
		end
		else begin
			if (write_enable)
				feature_count <= feature_count + 'd2;
			if (pop) begin
				rd_ptr <= rd_ptr + 1;
				feature_count <= feature_count - 1'b1;
			end
		end
	assign slot_free = feature_count == {$clog2(READ_DEPTH) {1'sb0}};
endmodule
module hybrid_buffer (
	core_clk,
	resetn,
	set_node_id_valid,
	set_node_id,
	slot_node_id,
	write_enable,
	write_address,
	write_data,
	pop,
	out_feature,
	feature_count,
	slot_free
);
	parameter NUM_SLOTS = 16;
	parameter WRITE_WIDTH = 64;
	parameter WRITE_DEPTH = 512;
	parameter READ_WIDTH = 32;
	parameter READ_DEPTH = 1024;
	parameter BUFFER_TYPE = "AGGREGATION";
	input wire core_clk;
	input wire resetn;
	input wire [NUM_SLOTS - 1:0] set_node_id_valid;
	localparam top_pkg_MAX_NODES = 1048576;
	localparam top_pkg_NODE_ID_WIDTH = 20;
	input wire [(NUM_SLOTS * 20) - 1:0] set_node_id;
	output reg [(NUM_SLOTS * 20) - 1:0] slot_node_id;
	input wire [NUM_SLOTS - 1:0] write_enable;
	input wire [(NUM_SLOTS * $clog2(WRITE_DEPTH)) - 1:0] write_address;
	input wire [(NUM_SLOTS * WRITE_WIDTH) - 1:0] write_data;
	input wire [NUM_SLOTS - 1:0] pop;
	output wire [(NUM_SLOTS * READ_WIDTH) - 1:0] out_feature;
	output wire [(NUM_SLOTS * $clog2(READ_DEPTH)) - 1:0] feature_count;
	output wire [NUM_SLOTS - 1:0] slot_free;
	genvar slot;
	generate
		for (slot = 0; slot < NUM_SLOTS; slot = slot + 1) begin : genblk1
			hybrid_buffer_slot #(
				.WRITE_WIDTH(WRITE_WIDTH),
				.WRITE_DEPTH(WRITE_DEPTH),
				.READ_WIDTH(READ_WIDTH),
				.READ_DEPTH(READ_DEPTH),
				.BUFFER_TYPE(BUFFER_TYPE)
			) slot_i(
				.core_clk(core_clk),
				.resetn(resetn),
				.write_enable(write_enable[slot]),
				.write_address(write_address[slot * $clog2(WRITE_DEPTH)+:$clog2(WRITE_DEPTH)]),
				.write_data(write_data[slot * WRITE_WIDTH+:WRITE_WIDTH]),
				.pop(pop[slot]),
				.out_feature(out_feature[slot * READ_WIDTH+:READ_WIDTH]),
				.feature_count(feature_count[slot * $clog2(READ_DEPTH)+:$clog2(READ_DEPTH)]),
				.slot_free(slot_free[slot])
			);
			always @(posedge core_clk or negedge resetn)
				if (!resetn)
					slot_node_id[slot * 20+:20] <= 0;
				else if (set_node_id && set_node_id_valid[slot])
					slot_node_id[slot * 20+:20] <= set_node_id[slot * 20+:20];
		end
	endgenerate
endmodule
module hybrid_buffer_driver (
	core_clk,
	resetn,
	begin_dump,
	pulse,
	pulse_limit,
	slot_pop_shift
);
	parameter BUFFER_SLOTS = 16;
	localparam top_pkg_MAX_FEATURE_COUNT = 1024;
	parameter MAX_PULSES_PER_SLOT = top_pkg_MAX_FEATURE_COUNT;
	input wire core_clk;
	input wire resetn;
	input wire begin_dump;
	input wire pulse;
	input wire [$clog2(MAX_PULSES_PER_SLOT) - 1:0] pulse_limit;
	output reg [BUFFER_SLOTS - 1:0] slot_pop_shift;
	reg [$clog2(MAX_PULSES_PER_SLOT) - 1:0] slot_pop_counter;
	genvar slot;
	generate
		for (slot = 1; slot < BUFFER_SLOTS; slot = slot + 1) begin : genblk1
			always @(posedge core_clk or negedge resetn)
				if (!resetn)
					slot_pop_shift[slot] <= 1'sb0;
				else if (begin_dump)
					slot_pop_shift[slot] <= 1'sb0;
				else if (pulse)
					slot_pop_shift[slot] <= slot_pop_shift[slot - 1];
		end
	endgenerate
	always @(posedge core_clk or negedge resetn)
		if (!resetn) begin
			slot_pop_shift[0] <= 1'sb0;
			slot_pop_counter <= 1'sb0;
		end
		else if (begin_dump) begin
			slot_pop_shift[0] <= 1'sb1;
			slot_pop_counter <= 1'sb0;
		end
		else if (pulse) begin
			slot_pop_counter <= (slot_pop_counter == (pulse_limit - 1) ? slot_pop_counter : slot_pop_counter + 1'b1);
			slot_pop_shift[0] <= slot_pop_counter != (pulse_limit - 1);
		end
endmodule
module axi_read_master (
	core_clk,
	resetn,
	fetch_req_valid,
	fetch_req_ready,
	fetch_start_address,
	fetch_byte_count,
	fetch_resp_valid,
	fetch_resp_ready,
	fetch_resp_last,
	fetch_resp_data,
	fetch_resp_axi_id,
	axi_araddr,
	axi_arburst,
	axi_arcache,
	axi_arid,
	axi_arlen,
	axi_arlock,
	axi_arprot,
	axi_arqos,
	axi_arsize,
	axi_arvalid,
	axi_arready,
	axi_rdata,
	axi_rid,
	axi_rlast,
	axi_rvalid,
	axi_rready,
	axi_rresp
);
	parameter MAX_BYTE_COUNT = 1000000000;
	parameter AXI_ADDRESS_WIDTH = 34;
	parameter DATA_WIDTH = 512;
	input wire core_clk;
	input wire resetn;
	input wire fetch_req_valid;
	output reg fetch_req_ready;
	input wire [AXI_ADDRESS_WIDTH - 1:0] fetch_start_address;
	input wire [$clog2(MAX_BYTE_COUNT) - 1:0] fetch_byte_count;
	output reg fetch_resp_valid;
	input wire fetch_resp_ready;
	output reg fetch_resp_last;
	output reg [DATA_WIDTH - 1:0] fetch_resp_data;
	output reg [3:0] fetch_resp_axi_id;
	output reg [AXI_ADDRESS_WIDTH - 1:0] axi_araddr;
	output reg [1:0] axi_arburst;
	output reg [3:0] axi_arcache;
	output reg [3:0] axi_arid;
	output reg [7:0] axi_arlen;
	output reg [0:0] axi_arlock;
	output reg [2:0] axi_arprot;
	output reg [3:0] axi_arqos;
	output reg [2:0] axi_arsize;
	output reg axi_arvalid;
	input wire axi_arready;
	input wire [DATA_WIDTH - 1:0] axi_rdata;
	input wire [3:0] axi_rid;
	input wire axi_rlast;
	input wire axi_rvalid;
	output reg axi_rready;
	input wire [1:0] axi_rresp;
	parameter MAX_TOTAL_BEATS = ((MAX_BYTE_COUNT - 1) / 64) + 1;
	parameter MAX_TRANSACTIONS = ((MAX_TOTAL_BEATS - 1) / 256) + 1;
	reg [2:0] fetch_state;
	reg [2:0] fetch_state_n;
	reg [$clog2(MAX_BYTE_COUNT) - 1:0] req_fetch_byte_count;
	reg accepting_fetch_request;
	reg accepting_axi_read_transaction;
	reg accepting_axi_read_response;
	reg [$clog2(MAX_TOTAL_BEATS) - 1:0] required_beat_count;
	reg [7:0] burst_length_final_transaction;
	reg [$clog2(MAX_TRANSACTIONS) - 1:0] required_transaction_count;
	reg [$clog2(MAX_TRANSACTIONS) - 1:0] sent_transactions;
	reg [$clog2(MAX_TOTAL_BEATS) - 1:0] beats_requested;
	reg [$clog2(MAX_TOTAL_BEATS) - 1:0] beats_received;
	reg [7:0] received_read_responses;
	reg [AXI_ADDRESS_WIDTH - 1:0] current_transaction_address;
	reg last_transaction_pending;
	reg last_read_response_pending;
	always @(*) begin
		accepting_fetch_request = fetch_req_valid && fetch_req_ready;
		accepting_axi_read_transaction = axi_arvalid && axi_arready;
		accepting_axi_read_response = axi_rvalid && axi_rready;
		required_beat_count = req_fetch_byte_count[$clog2(MAX_BYTE_COUNT) - 1:6] + (req_fetch_byte_count[5:0] == {6 {1'sb0}} ? 1'b0 : 1'b1);
		burst_length_final_transaction = required_beat_count[5:0];
		required_transaction_count = required_beat_count[$clog2(MAX_TOTAL_BEATS) - 1:6] + (burst_length_final_transaction == {8 {1'sb0}} ? 1'b0 : 1'b1);
		last_transaction_pending = sent_transactions == (required_transaction_count - 1'b1);
		last_read_response_pending = beats_received == (required_beat_count - 1'b1);
	end
	always @(posedge core_clk or negedge resetn)
		if (!resetn) begin
			fetch_state <= 3'd0;
			req_fetch_byte_count <= 1'sb0;
			current_transaction_address <= 1'sb0;
			sent_transactions <= 1'sb0;
			beats_requested <= 1'sb0;
			received_read_responses <= 1'sb0;
			beats_received <= 1'sb0;
		end
		else if (fetch_state_n == 3'd0) begin
			fetch_state <= fetch_state_n;
			req_fetch_byte_count <= 1'sb0;
			current_transaction_address <= 1'sb0;
			sent_transactions <= 1'sb0;
			beats_requested <= 1'sb0;
			received_read_responses <= 1'sb0;
			beats_received <= 1'sb0;
		end
		else begin
			fetch_state <= fetch_state_n;
			if (accepting_fetch_request) begin
				req_fetch_byte_count <= fetch_byte_count;
				current_transaction_address <= fetch_start_address;
			end
			if ((fetch_state == 3'd1) && accepting_axi_read_transaction) begin
				sent_transactions <= sent_transactions + 1'b1;
				beats_requested <= beats_requested + axi_arlen;
				current_transaction_address <= current_transaction_address + 13'd4096;
			end
			if ((fetch_state == 3'd2) && accepting_axi_read_response) begin
				received_read_responses <= received_read_responses + 1'b1;
				beats_received <= beats_received + 1'b1;
			end
		end
	always @(*) begin
		fetch_state_n = fetch_state;
		case (fetch_state)
			3'd0: fetch_state_n = (accepting_fetch_request ? 3'd1 : 3'd0);
			3'd1: fetch_state_n = (accepting_axi_read_transaction && last_transaction_pending ? 3'd2 : 3'd1);
			3'd2: fetch_state_n = (accepting_axi_read_response && last_read_response_pending ? 3'd0 : 3'd2);
		endcase
	end
	always @(*) begin
		axi_arvalid = fetch_state == 3'd1;
		axi_araddr = current_transaction_address;
		axi_arid = 1'sb0;
		axi_arburst = (req_fetch_byte_count > 64 ? 2'b01 : {2 {1'sb0}});
		axi_arsize = 3'b110;
		axi_arlen = (last_transaction_pending && (burst_length_final_transaction == {8 {1'sb0}}) ? 8'd63 : (last_transaction_pending && (burst_length_final_transaction != {8 {1'sb0}}) ? burst_length_final_transaction - 1 : 8'd63));
		axi_arcache = 1'sb0;
		axi_arlock = 1'sb0;
		axi_arprot = 1'sb0;
		axi_arqos = 1'sb0;
		axi_rready = (fetch_state == 3'd2) && fetch_resp_ready;
	end
	always @(*) begin
		fetch_req_ready = fetch_state == 3'd0;
		fetch_resp_valid = (fetch_state == 3'd2) && axi_rvalid;
		fetch_resp_last = ((fetch_state == 3'd2) && axi_rvalid) && axi_rlast;
		fetch_resp_data = axi_rdata;
		fetch_resp_axi_id = axi_rid;
	end
endmodule
module float_mac (
	core_clk,
	resetn,
	in_valid,
	in_ready,
	a,
	b,
	overwrite,
	overwrite_data,
	accumulator
);
	parameter FLOAT_WIDTH = 32;
	input wire core_clk;
	input wire resetn;
	input wire in_valid;
	output wire in_ready;
	input wire [FLOAT_WIDTH - 1:0] a;
	input wire [FLOAT_WIDTH - 1:0] b;
	input wire overwrite;
	input wire [FLOAT_WIDTH - 1:0] overwrite_data;
	output wire [FLOAT_WIDTH - 1:0] accumulator;
	reg [FLOAT_WIDTH - 1:0] acc_reg;
	wire fp_mult_result_valid_comb;
	wire [FLOAT_WIDTH - 1:0] fp_mult_result_comb;
	reg fp_mult_result_valid_q;
	reg [FLOAT_WIDTH - 1:0] fp_mult_result_q;
	wire fp_add_result_valid;
	wire [FLOAT_WIDTH - 1:0] fp_add_result;
	reg busy;
	fp_mult multiplier_i(
		.s_axis_a_tvalid(in_valid && in_ready),
		.s_axis_a_tdata(a),
		.s_axis_b_tvalid(in_valid && in_ready),
		.s_axis_b_tdata(b),
		.m_axis_result_tvalid(fp_mult_result_valid_comb),
		.m_axis_result_tdata(fp_mult_result_comb)
	);
	fp_add adder_i(
		.s_axis_a_tvalid(busy && fp_mult_result_valid_q),
		.s_axis_a_tdata(fp_mult_result_q),
		.s_axis_b_tvalid(busy && fp_mult_result_valid_q),
		.s_axis_b_tdata(acc_reg),
		.m_axis_result_tvalid(fp_add_result_valid),
		.m_axis_result_tdata(fp_add_result)
	);
	always @(posedge core_clk or negedge resetn)
		if (!resetn) begin
			fp_mult_result_valid_q <= 1'sb0;
			fp_mult_result_q <= 1'sb0;
		end
		else begin
			fp_mult_result_valid_q <= fp_mult_result_valid_comb;
			fp_mult_result_q <= fp_mult_result_comb;
		end
	always @(posedge core_clk or negedge resetn)
		if (!resetn)
			acc_reg <= 1'sb0;
		else
			acc_reg <= (overwrite ? overwrite_data : (busy && fp_add_result_valid ? fp_add_result : acc_reg));
	assign accumulator = acc_reg;
	always @(posedge core_clk or negedge resetn)
		if (!resetn)
			busy <= 1'sb0;
		else if (in_valid && in_ready)
			busy <= (in_valid && in_ready ? 1'b1 : (busy && fp_add_result_valid ? 1'b0 : busy));
	assign in_ready = !busy;
endmodule
module mac (
	core_clk,
	resetn,
	in_valid,
	in_ready,
	a,
	b,
	accumulator,
	overwrite,
	overwrite_data
);
	parameter FLOAT_WIDTH = 32;
	parameter DATA_WIDTH = 32;
	parameter PRECISION = "FLOAT_32";
	input wire core_clk;
	input wire resetn;
	input wire in_valid;
	output wire in_ready;
	input wire [DATA_WIDTH - 1:0] a;
	input wire [DATA_WIDTH - 1:0] b;
	output wire [DATA_WIDTH - 1:0] accumulator;
	input wire overwrite;
	input wire [DATA_WIDTH - 1:0] overwrite_data;
	generate
		if (PRECISION == "FLOAT_32") begin : genblk1
			float_mac #(.FLOAT_WIDTH(FLOAT_WIDTH)) float_mac_i(
				.core_clk(core_clk),
				.resetn(resetn),
				.in_valid(in_valid),
				.in_ready(in_ready),
				.a(a),
				.b(b),
				.overwrite(overwrite),
				.overwrite_data(overwrite_data),
				.accumulator(accumulator)
			);
		end
		else if (PRECISION == "FIXED_16") begin : genblk1
			fixed_point_mac #(
				.WIDTH(FLOAT_WIDTH),
				.DATA_WIDTH(DATA_WIDTH)
			) fixed_point_mac_i(
				.core_clk(core_clk),
				.resetn(resetn),
				.in_valid(in_valid),
				.in_ready(in_ready),
				.a(a),
				.b(b),
				.overwrite(overwrite),
				.overwrite_data(overwrite_data),
				.accumulator(accumulator)
			);
		end
	endgenerate
endmodule
module binary_to_onehot (
	binary_input,
	one_hot_output
);
	parameter WIDTH = 4;
	input wire [WIDTH - 1:0] binary_input;
	output wire [(1 << WIDTH) - 1:0] one_hot_output;
	genvar i;
	generate
		for (i = 0; i < (1 << WIDTH); i = i + 1) begin : one_hot_gen
			assign one_hot_output[i] = i == binary_input;
		end
	endgenerate
endmodule
module count_ones (
	data,
	count
);
	parameter INPUT_WIDTH = 32;
	input wire [INPUT_WIDTH - 1:0] data;
	output reg [$clog2(INPUT_WIDTH) - 1:0] count;
	always @(*) begin
		count = 1'sb0;
		begin : sv2v_autoblock_1
			reg signed [31:0] i;
			for (i = 0; i < INPUT_WIDTH; i = i + 1)
				if (data[i] == 1'b1)
					count = count + 1'b1;
		end
	end
endmodule
module onehot_to_binary_comb (
	input_data,
	output_data
);
	parameter INPUT_WIDTH = 32;
	input wire [INPUT_WIDTH - 1:0] input_data;
	output reg [$clog2(INPUT_WIDTH) - 1:0] output_data;
	always @(*) begin : sv2v_autoblock_1
		reg [0:1] _sv2v_jump;
		_sv2v_jump = 2'b00;
		if (input_data == {INPUT_WIDTH {1'sb0}})
			output_data = 1'sb0;
		else begin : sv2v_autoblock_2
			reg signed [31:0] i;
			begin : sv2v_autoblock_3
				reg signed [31:0] _sv2v_value_on_break;
				for (i = 0; i < INPUT_WIDTH; i = i + 1)
					if (_sv2v_jump < 2'b10) begin
						_sv2v_jump = 2'b00;
						if (input_data[i]) begin
							output_data = i;
							_sv2v_jump = 2'b10;
						end
						_sv2v_value_on_break = i;
					end
				if (!(_sv2v_jump < 2'b10))
					i = _sv2v_value_on_break;
				if (_sv2v_jump != 2'b11)
					_sv2v_jump = 2'b00;
			end
		end
	end
endmodule
module rr_arbiter (
	clk,
	resetn,
	request,
	update_lru,
	grant_oh
);
	parameter NUM_REQUESTERS = 4;
	input clk;
	input resetn;
	input [NUM_REQUESTERS - 1:0] request;
	input update_lru;
	output reg [NUM_REQUESTERS - 1:0] grant_oh;
	wire [NUM_REQUESTERS - 1:0] priority_oh_nxt;
	reg [NUM_REQUESTERS - 1:0] priority_oh;
	localparam BIT_IDX_WIDTH = $clog2(NUM_REQUESTERS);
	always @(*) begin : sv2v_autoblock_1
		reg signed [31:0] grant_idx;
		for (grant_idx = 0; grant_idx < NUM_REQUESTERS; grant_idx = grant_idx + 1)
			begin
				grant_oh[grant_idx] = 0;
				begin : sv2v_autoblock_2
					reg signed [31:0] priority_idx;
					for (priority_idx = 0; priority_idx < NUM_REQUESTERS; priority_idx = priority_idx + 1)
						begin : sv2v_autoblock_3
							reg is_granted;
							is_granted = request[grant_idx] & priority_oh[priority_idx];
							begin : sv2v_autoblock_4
								reg [BIT_IDX_WIDTH - 1:0] bit_idx;
								for (bit_idx = priority_idx[BIT_IDX_WIDTH - 1:0]; bit_idx != grant_idx[BIT_IDX_WIDTH - 1:0]; bit_idx = bit_idx + 1)
									is_granted = is_granted & !request[bit_idx];
							end
							grant_oh[grant_idx] = grant_oh[grant_idx] | is_granted;
						end
				end
			end
	end
	assign priority_oh_nxt = {grant_oh[NUM_REQUESTERS - 2:0], grant_oh[NUM_REQUESTERS - 1]};
	always @(posedge clk or negedge resetn)
		if (!resetn)
			priority_oh <= 1;
		else if ((request != 0) && update_lru)
			priority_oh <= priority_oh_nxt;
endmodule
module node_scoreboard (
	core_clk,
	resetn,
	s_axi_awaddr,
	s_axi_awprot,
	s_axi_awvalid,
	s_axi_awready,
	s_axi_wdata,
	s_axi_wstrb,
	s_axi_wvalid,
	s_axi_wready,
	s_axi_araddr,
	s_axi_arprot,
	s_axi_arvalid,
	s_axi_arready,
	s_axi_rdata,
	s_axi_rresp,
	s_axi_rvalid,
	s_axi_rready,
	s_axi_bresp,
	s_axi_bvalid,
	s_axi_bready,
	nsb_age_req_valid,
	nsb_age_req_ready,
	nsb_age_req,
	nsb_age_resp_valid,
	nsb_age_resp,
	nsb_fte_req_valid,
	nsb_fte_req_ready,
	nsb_fte_req,
	nsb_fte_resp_valid,
	nsb_fte_resp,
	nsb_prefetcher_req_valid,
	nsb_prefetcher_req_ready,
	nsb_prefetcher_req,
	nsb_prefetcher_resp_valid,
	nsb_prefetcher_resp,
	nsb_output_buffer_req_valid,
	nsb_output_buffer_req_ready,
	nsb_output_buffer_req,
	nsb_output_buffer_resp_valid,
	nsb_output_buffer_resp
);
	parameter AXIL_ADDR_WIDTH = 32;
	parameter NODESLOT_COUNT = 64;
	input wire core_clk;
	input wire resetn;
	input wire [AXIL_ADDR_WIDTH - 1:0] s_axi_awaddr;
	input wire [2:0] s_axi_awprot;
	input wire s_axi_awvalid;
	output wire s_axi_awready;
	input wire [31:0] s_axi_wdata;
	input wire [3:0] s_axi_wstrb;
	input wire s_axi_wvalid;
	output wire s_axi_wready;
	input wire [AXIL_ADDR_WIDTH - 1:0] s_axi_araddr;
	input wire [2:0] s_axi_arprot;
	input wire s_axi_arvalid;
	output wire s_axi_arready;
	output wire [31:0] s_axi_rdata;
	output wire [1:0] s_axi_rresp;
	output wire s_axi_rvalid;
	input wire s_axi_rready;
	output wire [1:0] s_axi_bresp;
	output wire s_axi_bvalid;
	input wire s_axi_bready;
	output wire nsb_age_req_valid;
	input wire nsb_age_req_ready;
	localparam top_pkg_MAX_NODESLOT_COUNT = 32;
	localparam top_pkg_FETCH_TAG_COUNT = top_pkg_MAX_NODESLOT_COUNT;
	localparam top_pkg_MAX_NODES = 1048576;
	localparam top_pkg_NODE_ID_WIDTH = 20;
	output wire [33:0] nsb_age_req;
	input wire nsb_age_resp_valid;
	input wire [4:0] nsb_age_resp;
	output wire nsb_fte_req_valid;
	input wire nsb_fte_req_ready;
	output wire [31:0] nsb_fte_req;
	input wire nsb_fte_resp_valid;
	input wire [31:0] nsb_fte_resp;
	output reg nsb_prefetcher_req_valid;
	input wire nsb_prefetcher_req_ready;
	localparam top_pkg_AXI_ADDRESS_WIDTH = 34;
	localparam top_pkg_MAX_FEATURE_COUNT = 1024;
	localparam top_pkg_MAX_NEIGHBOURS = 1024;
	output reg [75:0] nsb_prefetcher_req;
	input wire nsb_prefetcher_resp_valid;
	input wire [13:0] nsb_prefetcher_resp;
	output wire nsb_output_buffer_req_valid;
	input wire nsb_output_buffer_req_ready;
	output wire [31:0] nsb_output_buffer_req;
	input wire nsb_output_buffer_resp_valid;
	input wire [4:0] nsb_output_buffer_resp;
	parameter AXI_ADDRESS_MSB_BITS = 2;
	wire ctrl_fetch_layer_weights_strobe;
	wire [0:0] ctrl_fetch_layer_weights_fetch;
	wire ctrl_fetch_layer_weights_done_strobe;
	reg [0:0] ctrl_fetch_layer_weights_done_done;
	wire ctrl_fetch_layer_weights_done_ack_strobe;
	wire [0:0] ctrl_fetch_layer_weights_done_ack_ack;
	wire layer_config_in_features_strobe;
	wire [9:0] layer_config_in_features_count;
	wire layer_config_out_features_strobe;
	wire [9:0] layer_config_out_features_count;
	wire layer_config_weights_precision_strobe;
	wire [2:0] layer_config_weights_precision_precision;
	wire layer_config_activations_precision_strobe;
	wire [2:0] layer_config_activations_precision_precision;
	wire layer_config_adjacency_list_address_lsb_strobe;
	wire [31:0] layer_config_adjacency_list_address_lsb_lsb;
	wire layer_config_adjacency_list_address_msb_strobe;
	wire [1:0] layer_config_adjacency_list_address_msb_msb;
	wire layer_config_in_messages_address_lsb_strobe;
	wire [31:0] layer_config_in_messages_address_lsb_lsb;
	wire layer_config_in_messages_address_msb_strobe;
	wire [1:0] layer_config_in_messages_address_msb_msb;
	wire layer_config_weights_address_lsb_strobe;
	wire [31:0] layer_config_weights_address_lsb_lsb;
	wire layer_config_weights_address_msb_strobe;
	wire [1:0] layer_config_weights_address_msb_msb;
	wire layer_config_out_messages_address_lsb_strobe;
	wire [31:0] layer_config_out_messages_address_lsb_lsb;
	wire layer_config_out_messages_address_msb_strobe;
	wire [1:0] layer_config_out_messages_address_msb_msb;
	wire [63:0] nsb_nodeslot_neighbour_count_strobe;
	wire [1279:0] nsb_nodeslot_neighbour_count_count;
	wire [63:0] nsb_nodeslot_node_id_strobe;
	wire [1279:0] nsb_nodeslot_node_id_id;
	wire [63:0] nsb_nodeslot_node_state_strobe;
	reg [255:0] nsb_nodeslot_node_state_state;
	wire [63:0] nsb_nodeslot_precision_strobe;
	wire [127:0] nsb_nodeslot_precision_precision;
	wire [63:0] nsb_nodeslot_adjacency_list_address_lsb_strobe;
	wire [2047:0] nsb_nodeslot_adjacency_list_address_lsb_lsb;
	wire [63:0] nsb_nodeslot_adjacency_list_address_msb_strobe;
	wire [127:0] nsb_nodeslot_adjacency_list_address_msb_msb;
	wire [63:0] nsb_nodeslot_out_messages_address_lsb_strobe;
	wire [2047:0] nsb_nodeslot_out_messages_address_lsb_lsb;
	wire [63:0] nsb_nodeslot_out_messages_address_msb_strobe;
	wire [127:0] nsb_nodeslot_out_messages_address_msb_msb;
	wire [63:0] nsb_nodeslot_aggregation_function_strobe;
	wire [127:0] nsb_nodeslot_aggregation_function_value;
	wire [63:0] nsb_nodeslot_scale_factors_address_lsb_strobe;
	wire [2047:0] nsb_nodeslot_scale_factors_address_lsb_value;
	wire [63:0] nsb_nodeslot_scale_factors_address_msb_strobe;
	wire [127:0] nsb_nodeslot_scale_factors_address_msb_value;
	wire nsb_nodeslot_config_make_valid_msb_strobe;
	wire [31:0] nsb_nodeslot_config_make_valid_msb_make_valid;
	wire nsb_nodeslot_config_make_valid_lsb_strobe;
	wire [31:0] nsb_nodeslot_config_make_valid_lsb_make_valid;
	wire nsb_config_aggregation_wait_count_strobe;
	wire [5:0] nsb_config_aggregation_wait_count_count;
	wire nsb_config_transformation_wait_count_strobe;
	wire [5:0] nsb_config_transformation_wait_count_count;
	wire [63:0] nsb_nodeslot_allocated_fetch_tag_strobe;
	reg [383:0] nsb_nodeslot_allocated_fetch_tag_fetch_tag;
	wire [(NODESLOT_COUNT * 4) - 1:0] nodeslot_state;
	reg [(NODESLOT_COUNT * 4) - 1:0] nodeslot_state_n;
	wire [NODESLOT_COUNT - 1:0] nodeslot_make_valid;
	reg [NODESLOT_COUNT - 1:0] fetch_nb_list_resp_received;
	reg [NODESLOT_COUNT - 1:0] fetch_scale_factors_resp_received;
	reg [NODESLOT_COUNT - 1:0] fetch_nbs_resp_received;
	reg [NODESLOT_COUNT - 1:0] aggregation_done;
	reg [NODESLOT_COUNT - 1:0] transformation_done;
	wire [NODESLOT_COUNT - 1:0] nodeslots_waiting_nb_list_fetch;
	wire [NODESLOT_COUNT - 1:0] nodeslots_waiting_neighbour_fetch;
	wire [NODESLOT_COUNT - 1:0] nodeslots_waiting_scale_factor_fetch;
	wire [NODESLOT_COUNT - 1:0] nodeslots_waiting_prefetcher;
	wire [NODESLOT_COUNT - 1:0] nodeslots_waiting_aggregation;
	wire [NODESLOT_COUNT - 1:0] nodeslots_waiting_transformation;
	wire [NODESLOT_COUNT - 1:0] nodeslots_waiting_writeback;
	wire accepting_prefetch_request;
	wire accepting_aggr_request;
	wire accepting_transformation_request;
	wire accepting_writeback_request;
	reg [5:0] aggregation_buffer_population_count;
	reg [5:0] transformation_buffer_population_count;
	wire [NODESLOT_COUNT - 1:0] prefetcher_arbiter_grant_oh;
	wire [$clog2(NODESLOT_COUNT) - 1:0] prefetcher_arbiter_grant_bin;
	wire [NODESLOT_COUNT - 1:0] age_arbiter_grant_oh;
	wire [$clog2(NODESLOT_COUNT) - 1:0] age_arbiter_grant_bin;
	node_scoreboard_regbank_regs node_scoreboard_regbank_i(
		.axi_aclk(core_clk),
		.axi_aresetn(resetn),
		.s_axi_awaddr(s_axi_awaddr),
		.s_axi_awprot(s_axi_awprot),
		.s_axi_awvalid(s_axi_awvalid),
		.s_axi_awready(s_axi_awready),
		.s_axi_wdata(s_axi_wdata),
		.s_axi_wstrb(s_axi_wstrb),
		.s_axi_wvalid(s_axi_wvalid),
		.s_axi_wready(s_axi_wready),
		.s_axi_araddr(s_axi_araddr),
		.s_axi_arprot(s_axi_arprot),
		.s_axi_arvalid(s_axi_arvalid),
		.s_axi_arready(s_axi_arready),
		.s_axi_rdata(s_axi_rdata),
		.s_axi_rresp(s_axi_rresp),
		.s_axi_rvalid(s_axi_rvalid),
		.s_axi_rready(s_axi_rready),
		.s_axi_bresp(s_axi_bresp),
		.s_axi_bvalid(s_axi_bvalid),
		.s_axi_bready(s_axi_bready),
		.layer_config_in_features_strobe(layer_config_in_features_strobe),
		.layer_config_in_features_count(layer_config_in_features_count),
		.layer_config_out_features_strobe(layer_config_out_features_strobe),
		.layer_config_out_features_count(layer_config_out_features_count),
		.layer_config_weights_precision_strobe(layer_config_weights_precision_strobe),
		.layer_config_weights_precision_precision(layer_config_weights_precision_precision),
		.layer_config_activations_precision_strobe(layer_config_activations_precision_strobe),
		.layer_config_activations_precision_precision(layer_config_activations_precision_precision),
		.layer_config_adjacency_list_address_lsb_strobe(layer_config_adjacency_list_address_lsb_strobe),
		.layer_config_adjacency_list_address_lsb_lsb(layer_config_adjacency_list_address_lsb_lsb),
		.layer_config_adjacency_list_address_msb_strobe(layer_config_adjacency_list_address_msb_strobe),
		.layer_config_adjacency_list_address_msb_msb(layer_config_adjacency_list_address_msb_msb),
		.layer_config_in_messages_address_lsb_strobe(layer_config_in_messages_address_lsb_strobe),
		.layer_config_in_messages_address_lsb_lsb(layer_config_in_messages_address_lsb_lsb),
		.layer_config_in_messages_address_msb_strobe(layer_config_in_messages_address_msb_strobe),
		.layer_config_in_messages_address_msb_msb(layer_config_in_messages_address_msb_msb),
		.layer_config_weights_address_lsb_strobe(layer_config_weights_address_lsb_strobe),
		.layer_config_weights_address_lsb_lsb(layer_config_weights_address_lsb_lsb),
		.layer_config_weights_address_msb_strobe(layer_config_weights_address_msb_strobe),
		.layer_config_weights_address_msb_msb(layer_config_weights_address_msb_msb),
		.layer_config_out_messages_address_lsb_strobe(layer_config_out_messages_address_lsb_strobe),
		.layer_config_out_messages_address_lsb_lsb(layer_config_out_messages_address_lsb_lsb),
		.layer_config_out_messages_address_msb_strobe(layer_config_out_messages_address_msb_strobe),
		.layer_config_out_messages_address_msb_msb(layer_config_out_messages_address_msb_msb),
		.ctrl_fetch_layer_weights_strobe(ctrl_fetch_layer_weights_strobe),
		.ctrl_fetch_layer_weights_fetch(ctrl_fetch_layer_weights_fetch),
		.ctrl_fetch_layer_weights_done_strobe(ctrl_fetch_layer_weights_done_strobe),
		.ctrl_fetch_layer_weights_done_done(ctrl_fetch_layer_weights_done_done),
		.ctrl_fetch_layer_weights_done_ack_strobe(ctrl_fetch_layer_weights_done_ack_strobe),
		.ctrl_fetch_layer_weights_done_ack_ack(ctrl_fetch_layer_weights_done_ack_ack),
		.nsb_nodeslot_neighbour_count_strobe(nsb_nodeslot_neighbour_count_strobe),
		.nsb_nodeslot_neighbour_count_count(nsb_nodeslot_neighbour_count_count),
		.nsb_nodeslot_node_id_strobe(nsb_nodeslot_node_id_strobe),
		.nsb_nodeslot_node_id_id(nsb_nodeslot_node_id_id),
		.nsb_nodeslot_node_state_strobe(nsb_nodeslot_node_state_strobe),
		.nsb_nodeslot_node_state_state(nsb_nodeslot_node_state_state),
		.nsb_nodeslot_precision_strobe(nsb_nodeslot_precision_strobe),
		.nsb_nodeslot_precision_precision(nsb_nodeslot_precision_precision),
		.nsb_nodeslot_adjacency_list_address_lsb_strobe(nsb_nodeslot_adjacency_list_address_lsb_strobe),
		.nsb_nodeslot_adjacency_list_address_lsb_lsb(nsb_nodeslot_adjacency_list_address_lsb_lsb),
		.nsb_nodeslot_adjacency_list_address_msb_strobe(nsb_nodeslot_adjacency_list_address_msb_strobe),
		.nsb_nodeslot_adjacency_list_address_msb_msb(nsb_nodeslot_adjacency_list_address_msb_msb),
		.nsb_nodeslot_out_messages_address_lsb_strobe(nsb_nodeslot_out_messages_address_lsb_strobe),
		.nsb_nodeslot_out_messages_address_lsb_lsb(nsb_nodeslot_out_messages_address_lsb_lsb),
		.nsb_nodeslot_out_messages_address_msb_strobe(nsb_nodeslot_out_messages_address_msb_strobe),
		.nsb_nodeslot_out_messages_address_msb_msb(nsb_nodeslot_out_messages_address_msb_msb),
		.nsb_nodeslot_config_make_valid_msb_strobe(nsb_nodeslot_config_make_valid_msb_strobe),
		.nsb_nodeslot_config_make_valid_msb_make_valid(nsb_nodeslot_config_make_valid_msb_make_valid),
		.nsb_nodeslot_config_make_valid_lsb_strobe(nsb_nodeslot_config_make_valid_lsb_strobe),
		.nsb_nodeslot_config_make_valid_lsb_make_valid(nsb_nodeslot_config_make_valid_lsb_make_valid),
		.nsb_nodeslot_scale_factors_address_lsb_strobe(nsb_nodeslot_scale_factors_address_lsb_strobe),
		.nsb_nodeslot_scale_factors_address_lsb_value(nsb_nodeslot_scale_factors_address_lsb_value),
		.nsb_nodeslot_scale_factors_address_msb_strobe(nsb_nodeslot_scale_factors_address_msb_strobe),
		.nsb_nodeslot_scale_factors_address_msb_value(nsb_nodeslot_scale_factors_address_msb_value),
		.nsb_config_aggregation_wait_count_strobe(nsb_config_aggregation_wait_count_strobe),
		.nsb_config_aggregation_wait_count_count(nsb_config_aggregation_wait_count_count),
		.nsb_config_transformation_wait_count_strobe(nsb_config_transformation_wait_count_strobe),
		.nsb_config_transformation_wait_count_count(nsb_config_transformation_wait_count_count),
		.nsb_nodeslot_allocated_fetch_tag_strobe(nsb_nodeslot_allocated_fetch_tag_strobe),
		.nsb_nodeslot_allocated_fetch_tag_fetch_tag(nsb_nodeslot_allocated_fetch_tag_fetch_tag),
		.nsb_nodeslot_aggregation_function_strobe(nsb_nodeslot_aggregation_function_strobe),
		.nsb_nodeslot_aggregation_function_value(nsb_nodeslot_aggregation_function_value)
	);
	assign nodeslot_make_valid[31:0] = nsb_nodeslot_config_make_valid_lsb_make_valid;
	assign accepting_prefetch_request = nsb_prefetcher_req_valid && nsb_prefetcher_req_ready;
	assign accepting_aggr_request = nsb_age_req_valid && nsb_age_req_ready;
	assign accepting_transformation_request = nsb_fte_req_valid && nsb_fte_req_ready;
	assign accepting_writeback_request = nsb_output_buffer_req_valid && nsb_output_buffer_req_ready;
	genvar nodeslot;
	generate
		for (nodeslot = 0; nodeslot < NODESLOT_COUNT; nodeslot = nodeslot + 1) begin : per_nodeslot_logic
			assign nodeslot_state[nodeslot * 4+:4] = nsb_nodeslot_node_state_state[nodeslot * 4+:4];
			always @(posedge core_clk or negedge resetn)
				if (!resetn) begin
					nsb_nodeslot_node_state_state[nodeslot * 4+:4] <= 4'd0;
					fetch_nb_list_resp_received[nodeslot] <= 1'sb0;
					fetch_scale_factors_resp_received[nodeslot] <= 1'sb0;
					fetch_nbs_resp_received[nodeslot] <= 1'sb0;
					aggregation_done[nodeslot] <= 1'sb0;
					transformation_done[nodeslot] <= 1'sb0;
				end
				else if (nodeslot_state_n[nodeslot * 4+:4] == 4'd0) begin
					nsb_nodeslot_node_state_state[nodeslot * 4+:4] <= nodeslot_state_n[nodeslot * 4+:4];
					fetch_nb_list_resp_received[nodeslot] <= 1'sb0;
					fetch_scale_factors_resp_received[nodeslot] <= 1'sb0;
					fetch_nbs_resp_received[nodeslot] <= 1'sb0;
					aggregation_done[nodeslot] <= 1'sb0;
					transformation_done[nodeslot] <= 1'sb0;
				end
				else begin
					nsb_nodeslot_node_state_state[nodeslot * 4+:4] <= nodeslot_state_n[nodeslot * 4+:4];
					if ((((nodeslot_state[nodeslot * 4+:4] == 4'd2) && nsb_prefetcher_resp_valid) && (nsb_prefetcher_resp[13-:5] == nodeslot)) && (nsb_prefetcher_resp[8-:3] == 3'd1))
						fetch_nb_list_resp_received[nodeslot] <= 1'b1;
					else if ((((nodeslot_state[nodeslot * 4+:4] == 4'd3) && nsb_prefetcher_resp_valid) && (nsb_prefetcher_resp[13-:5] == nodeslot)) && (nsb_prefetcher_resp[8-:3] == 3'd3))
						fetch_scale_factors_resp_received[nodeslot] <= 1'b1;
					else if ((((nodeslot_state[nodeslot * 4+:4] == 4'd4) && nsb_prefetcher_resp_valid) && (nsb_prefetcher_resp[13-:5] == nodeslot)) && (nsb_prefetcher_resp[8-:3] == 3'd2))
						fetch_nbs_resp_received[nodeslot] <= 1'b1;
					else if (((nodeslot_state[nodeslot * 4+:4] == 4'd5) && nsb_age_resp_valid) && (nsb_age_resp[4-:5] == nodeslot))
						aggregation_done[nodeslot] <= 1'b1;
					else if (((nodeslot_state[nodeslot * 4+:4] == 4'd6) && nsb_fte_resp_valid) && (nsb_fte_resp[31-:top_pkg_MAX_NODESLOT_COUNT] == nodeslot))
						transformation_done[nodeslot] <= 1'b1;
				end
			always @(*) begin
				nodeslot_state_n[nodeslot * 4+:4] = 4'd0;
				case (nodeslot_state[nodeslot * 4+:4])
					4'd0: nodeslot_state_n[nodeslot * 4+:4] = (nodeslot_make_valid[nodeslot] ? 4'd1 : 4'd0);
					4'd1: nodeslot_state_n[nodeslot * 4+:4] = ((accepting_prefetch_request && (nsb_prefetcher_req[16-:5] == nodeslot)) && (nsb_prefetcher_req[75-:3] == 3'd1) ? 4'd2 : 4'd1);
					4'd2: nodeslot_state_n[nodeslot * 4+:4] = (((fetch_nb_list_resp_received[nodeslot] && accepting_prefetch_request) && (nsb_prefetcher_req[16-:5] == nodeslot)) && (nsb_prefetcher_req[75-:3] == 3'd3) ? 4'd3 : 4'd2);
					4'd3: nodeslot_state_n[nodeslot * 4+:4] = (((fetch_scale_factors_resp_received[nodeslot] && accepting_prefetch_request) && (nsb_prefetcher_req[16-:5] == nodeslot)) && (nsb_prefetcher_req[75-:3] == 3'd2) ? 4'd4 : 4'd3);
					4'd4: nodeslot_state_n[nodeslot * 4+:4] = ((fetch_nbs_resp_received[nodeslot] && accepting_aggr_request) && (nsb_age_req[33-:5] == nodeslot) ? 4'd5 : 4'd4);
					4'd5: nodeslot_state_n[nodeslot * 4+:4] = (aggregation_done[nodeslot] && accepting_transformation_request ? 4'd6 : 4'd5);
					4'd6: nodeslot_state_n[nodeslot * 4+:4] = (transformation_done[nodeslot] && accepting_writeback_request ? 4'd8 : 4'd6);
					4'd7: nodeslot_state_n[nodeslot * 4+:4] = 4'd0;
					4'd8: nodeslot_state_n[nodeslot * 4+:4] = (nsb_output_buffer_resp_valid && (nsb_output_buffer_resp[4-:5] == nodeslot) ? 4'd0 : 4'd8);
					4'd9: nodeslot_state_n[nodeslot * 4+:4] = 4'd0;
				endcase
			end
			assign nodeslots_waiting_nb_list_fetch[nodeslot] = nodeslot_state[nodeslot * 4+:4] == 4'd1;
			assign nodeslots_waiting_scale_factor_fetch[nodeslot] = (nodeslot_state[nodeslot * 4+:4] == 4'd2) && fetch_nb_list_resp_received[nodeslot];
			assign nodeslots_waiting_neighbour_fetch[nodeslot] = (nodeslot_state[nodeslot * 4+:4] == 4'd3) && fetch_scale_factors_resp_received[nodeslot];
			assign nodeslots_waiting_prefetcher[nodeslot] = (nodeslots_waiting_nb_list_fetch[nodeslot] || nodeslots_waiting_neighbour_fetch[nodeslot]) || nodeslots_waiting_scale_factor_fetch[nodeslot];
			assign nodeslots_waiting_aggregation[nodeslot] = (nodeslot_state[nodeslot * 4+:4] == 4'd4) && fetch_nbs_resp_received[nodeslot];
			assign nodeslots_waiting_transformation[nodeslot] = (nodeslot_state[nodeslot * 4+:4] == 4'd5) && aggregation_done[nodeslot];
			assign nodeslots_waiting_writeback[nodeslot] = (nodeslot_state[nodeslot * 4+:4] == 4'd6) && transformation_done[nodeslot];
			always @(posedge core_clk or negedge resetn)
				if (!resetn)
					nsb_nodeslot_allocated_fetch_tag_fetch_tag[nodeslot * 6+:6] <= 1'sb0;
				else if (nodeslot_state_n[nodeslot * 4+:4] == 4'd0)
					nsb_nodeslot_allocated_fetch_tag_fetch_tag[nodeslot * 6+:6] <= 1'sb0;
				else if ((nsb_prefetcher_resp_valid && (nsb_prefetcher_resp[8-:3] == 3'd1)) && (nsb_prefetcher_resp[13-:5] == nodeslot))
					nsb_nodeslot_allocated_fetch_tag_fetch_tag[nodeslot * 6+:6] <= nsb_prefetcher_resp[5-:5];
		end
	endgenerate
	reg waiting_weights_fetch_req;
	always @(posedge core_clk or negedge resetn)
		if (!resetn) begin
			waiting_weights_fetch_req <= 1'sb0;
			ctrl_fetch_layer_weights_done_done <= 1'sb0;
		end
		else if (ctrl_fetch_layer_weights_fetch) begin
			waiting_weights_fetch_req <= 1'sb1;
			ctrl_fetch_layer_weights_done_done <= 1'sb0;
		end
		else if (nsb_prefetcher_req_valid && (nsb_prefetcher_req[75-:3] == 3'd0)) begin
			waiting_weights_fetch_req <= 1'sb0;
			ctrl_fetch_layer_weights_done_done <= 1'sb0;
		end
		else if (nsb_prefetcher_resp_valid && (nsb_prefetcher_resp[8-:3] == 3'd0)) begin
			waiting_weights_fetch_req <= 1'sb0;
			ctrl_fetch_layer_weights_done_done <= 1'sb1;
		end
		else if (ctrl_fetch_layer_weights_done_ack_ack) begin
			waiting_weights_fetch_req <= 1'sb0;
			ctrl_fetch_layer_weights_done_done <= 1'sb0;
		end
	always @(posedge core_clk or negedge resetn)
		if (!resetn) begin
			aggregation_buffer_population_count <= 1'sb0;
			transformation_buffer_population_count <= 1'sb0;
		end
		else begin
			if (nsb_age_resp_valid)
				aggregation_buffer_population_count <= aggregation_buffer_population_count + 1'b1;
			else if (accepting_transformation_request)
				aggregation_buffer_population_count <= 1'sb0;
			if (nsb_fte_resp_valid)
				transformation_buffer_population_count <= transformation_buffer_population_count + 1'b1;
			else if (accepting_writeback_request)
				transformation_buffer_population_count <= 1'sb0;
		end
	rr_arbiter #(.NUM_REQUESTERS(NODESLOT_COUNT)) prefetcher_req_arb(
		.clk(core_clk),
		.resetn(resetn),
		.request(nodeslots_waiting_prefetcher),
		.update_lru(nsb_prefetcher_req_valid && nsb_prefetcher_req_ready),
		.grant_oh(prefetcher_arbiter_grant_oh)
	);
	onehot_to_binary_comb #(.INPUT_WIDTH(NODESLOT_COUNT)) prefetcher_req_oh2bin(
		.input_data(prefetcher_arbiter_grant_oh),
		.output_data(prefetcher_arbiter_grant_bin)
	);
	always @(*) begin : nsb_prefetcher_req_logic
		nsb_prefetcher_req_valid = |nodeslots_waiting_prefetcher || waiting_weights_fetch_req;
		nsb_prefetcher_req[75-:3] = (waiting_weights_fetch_req ? 3'd0 : (|(nodeslots_waiting_nb_list_fetch & prefetcher_arbiter_grant_oh) ? 3'd1 : (|(nodeslots_waiting_scale_factor_fetch & prefetcher_arbiter_grant_oh) ? 3'd3 : (|(nodeslots_waiting_neighbour_fetch & prefetcher_arbiter_grant_oh) ? 3'd2 : 3'd4))));
		nsb_prefetcher_req[16-:5] = prefetcher_arbiter_grant_bin;
		nsb_prefetcher_req[72-:34] = (nsb_prefetcher_req[75-:3] == 3'd0 ? {layer_config_weights_address_msb_msb, layer_config_weights_address_lsb_lsb} : (nsb_prefetcher_req[75-:3] == 3'd1 ? {nsb_nodeslot_adjacency_list_address_msb_msb[prefetcher_arbiter_grant_bin * 2+:2], nsb_nodeslot_adjacency_list_address_lsb_lsb[prefetcher_arbiter_grant_bin * 32+:32]} : (nsb_prefetcher_req[75-:3] == 3'd3 ? {nsb_nodeslot_scale_factors_address_msb_value[prefetcher_arbiter_grant_bin * 2+:2], nsb_nodeslot_scale_factors_address_lsb_value[prefetcher_arbiter_grant_bin * 32+:32]} : {34 {1'sb0}})));
		nsb_prefetcher_req[9-:10] = nsb_nodeslot_neighbour_count_count[prefetcher_arbiter_grant_bin * 20+:20];
		nsb_prefetcher_req[11-:2] = 2'd0;
		nsb_prefetcher_req[38-:11] = layer_config_in_features_count;
		nsb_prefetcher_req[27-:11] = layer_config_out_features_count;
	end
	rr_arbiter #(.NUM_REQUESTERS(NODESLOT_COUNT)) age_req_arb(
		.clk(core_clk),
		.resetn(resetn),
		.request(nodeslots_waiting_aggregation),
		.update_lru(nsb_age_req_valid && nsb_age_req_ready),
		.grant_oh(age_arbiter_grant_oh)
	);
	onehot_to_binary_comb #(.INPUT_WIDTH(NODESLOT_COUNT)) age_req_oh2bin(
		.input_data(age_arbiter_grant_oh),
		.output_data(age_arbiter_grant_bin)
	);
	assign nsb_age_req_valid = |nodeslots_waiting_aggregation;
	assign nsb_age_req[33-:5] = age_arbiter_grant_bin;
	assign nsb_age_req[28-:20] = nsb_nodeslot_node_id_id[age_arbiter_grant_bin * 20+:20];
	assign nsb_age_req[3-:2] = nsb_nodeslot_precision_precision[age_arbiter_grant_bin * 2+:2];
	assign nsb_age_req[1-:2] = nsb_nodeslot_aggregation_function_value[age_arbiter_grant_bin * 2+:2];
	assign nsb_age_req[8-:5] = nsb_nodeslot_allocated_fetch_tag_fetch_tag[age_arbiter_grant_bin * 6+:6];
	assign nsb_fte_req_valid = aggregation_buffer_population_count == nsb_config_aggregation_wait_count_count;
	assign nsb_fte_req[31-:top_pkg_MAX_NODESLOT_COUNT] = nodeslots_waiting_transformation;
	assign nsb_output_buffer_req_valid = transformation_buffer_population_count == nsb_config_transformation_wait_count_count;
	assign nsb_output_buffer_req[31-:top_pkg_MAX_NODESLOT_COUNT] = nodeslots_waiting_writeback;
endmodule
module ultraram_fifo (
	core_clk,
	resetn,
	push,
	in_data,
	pop,
	out_valid,
	out_data,
	count,
	empty,
	full
);
	parameter WIDTH = 512;
	parameter DEPTH = 4096;
	input wire core_clk;
	input wire resetn;
	input wire push;
	input wire [WIDTH - 1:0] in_data;
	input wire pop;
	output reg out_valid;
	output wire [WIDTH - 1:0] out_data;
	output reg [$clog2(DEPTH):0] count;
	output wire empty;
	output wire full;
	parameter AWIDTH = $clog2(DEPTH);
	reg [AWIDTH - 1:0] wr_ptr;
	reg [AWIDTH - 1:0] rd_ptr;
	reg pop1;
	reg pop2;
	reg wr_wrap;
	reg rd_wrap;
	ultraram #(
		.AWIDTH(AWIDTH),
		.DWIDTH(WIDTH),
		.NBPIPE(1)
	) fifo(
		.core_clk(core_clk),
		.resetn(resetn),
		.mem_en(1'sb1),
		.write_enable(push),
		.addra(wr_ptr),
		.dina(in_data),
		.regceb(1'sb1),
		.addrb(rd_ptr),
		.doutb(out_data)
	);
	always @(posedge core_clk or negedge resetn)
		if (!resetn) begin
			wr_ptr <= 1'sb0;
			rd_ptr <= 1'sb0;
			pop1 <= 1'sb0;
			pop2 <= 1'sb0;
			out_valid <= 1'sb1;
			wr_wrap <= 1'sb0;
			rd_wrap <= 1'sb0;
			count <= 1'sb0;
		end
		else begin
			if (push) begin
				wr_ptr <= wr_ptr + 1'b1;
				count <= count + 1'b1;
			end
			if (pop) begin
				rd_ptr <= rd_ptr + 1'b1;
				count <= count - 1'b1;
			end
			if (pop)
				out_valid <= 1'sb0;
			else if (pop2)
				out_valid <= 1'sb1;
			pop1 <= pop;
			pop2 <= pop1;
			if ((wr_ptr == {AWIDTH {1'b1}}) && push)
				wr_wrap <= !wr_wrap;
			if ((rd_ptr == {AWIDTH {1'b1}}) && pop)
				rd_wrap <= !rd_wrap;
		end
	assign empty = (wr_ptr == rd_ptr) && !(wr_wrap ^ rd_wrap);
	assign full = (wr_ptr == rd_ptr) && (wr_wrap ^ rd_wrap);
endmodule
module prefetcher_streaming_manager (
	core_clk,
	resetn,
	free,
	fetch_req_valid,
	fetch_req_ready,
	fetch_req_opcode,
	fetch_req_start_address,
	fetch_req_obj_count,
	fetch_resp_valid,
	fetch_resp_partial,
	fetch_memory_range_start_address,
	read_master_req_valid,
	read_master_req_ready,
	read_master_start_address,
	read_master_byte_count,
	read_master_resp_valid,
	read_master_resp_ready,
	read_master_resp_last,
	read_master_resp_data,
	read_master_resp_axi_id,
	push_queue,
	push_data,
	queue_slots_available,
	queue_empty,
	queue_full
);
	parameter [2:0] FETCH_TYPE = 3'd1;
	parameter QUEUE_WIDTH = 512;
	parameter QUEUE_DEPTH = 64;
	localparam top_pkg_MAX_NEIGHBOURS = 1024;
	parameter MAX_OBJECTS = top_pkg_MAX_NEIGHBOURS;
	parameter STREAMING_ENABLED = 1;
	parameter UNPACKING_ENABLED = 1;
	input wire core_clk;
	input wire resetn;
	output wire free;
	input wire fetch_req_valid;
	output wire fetch_req_ready;
	input wire [2:0] fetch_req_opcode;
	localparam top_pkg_AXI_ADDRESS_WIDTH = 34;
	input wire [33:0] fetch_req_start_address;
	input wire [$clog2(MAX_OBJECTS) - 1:0] fetch_req_obj_count;
	output reg fetch_resp_valid;
	output reg fetch_resp_partial;
	input wire [33:0] fetch_memory_range_start_address;
	output reg read_master_req_valid;
	input wire read_master_req_ready;
	output reg [33:0] read_master_start_address;
	localparam top_pkg_MAX_NODES = 1048576;
	localparam top_pkg_NODE_ID_WIDTH = 20;
	localparam top_pkg_MAX_REQUIRED_BYTES_ADJ_FETCH_REQ = 2560;
	localparam top_pkg_LARGE_FEATURE_COUNT = 1024;
	localparam top_pkg_LARGE_MSG_QUEUE_DEPTH = 64;
	localparam top_pkg_LARGE_PRECISION_BYTE_COUNT = 4;
	localparam top_pkg_MAX_REQUIRED_BYTES_MSG_FETCH_REQ = 262144;
	localparam top_pkg_MAX_FETCH_REQ_BYTE_COUNT = top_pkg_MAX_REQUIRED_BYTES_MSG_FETCH_REQ;
	output reg [17:0] read_master_byte_count;
	input wire read_master_resp_valid;
	output reg read_master_resp_ready;
	input wire read_master_resp_last;
	localparam top_pkg_AXI_DATA_WIDTH = 512;
	input wire [511:0] read_master_resp_data;
	input wire [3:0] read_master_resp_axi_id;
	output reg push_queue;
	output reg [QUEUE_WIDTH - 1:0] push_data;
	input wire [$clog2(QUEUE_DEPTH):0] queue_slots_available;
	input wire queue_empty;
	input wire queue_full;
	reg [2:0] fetch_state;
	reg [2:0] fetch_state_n;
	reg accepting_fetch_req;
	reg accepting_rm_req;
	reg accepting_rm_resp;
	reg [33:0] fetch_req_address_offset;
	localparam top_pkg_MAX_REQUIRED_BYTES_WEIGHTS_FETCH_REQ = 4194304;
	localparam top_pkg_MAX_REQUIRED_BYTES_FETCH_REQ = top_pkg_MAX_REQUIRED_BYTES_WEIGHTS_FETCH_REQ;
	reg [21:0] fetch_req_bytes;
	reg [9:0] fetch_obj_remaining;
	localparam prefetcher_pkg_ADJ_QUEUE_DEPTH = 64;
	localparam prefetcher_pkg_ADJ_QUEUE_WIDTH = 32;
	localparam prefetcher_pkg_MAX_ADJ_FETCH_RESPONSES = 4;
	localparam top_pkg_MAX_FEATURE_COUNT = 1024;
	localparam top_pkg_MAX_PRECISION_BYTE_COUNT = 4;
	localparam prefetcher_pkg_MAX_MSG_FETCH_RESPONSES = 64;
	localparam prefetcher_pkg_MAX_FETCH_RESPONSES = prefetcher_pkg_MAX_MSG_FETCH_RESPONSES;
	reg [5:0] fetch_responses_pending;
	reg [8:0] buffered_fetch_resp_offset;
	reg issue_partial_done;
	reg issue_partial_done_q;
	reg trigger_partial_resp;
	reg [9:0] obj_remaining_store;
	reg [511:0] rm_resp_data_q;
	always @(*) begin
		accepting_fetch_req = fetch_req_valid && fetch_req_ready;
		accepting_rm_req = read_master_req_valid && read_master_req_ready;
		accepting_rm_resp = read_master_resp_valid && read_master_resp_ready;
	end
	always @(posedge core_clk or negedge resetn)
		if (!resetn)
			fetch_state <= 3'd0;
		else
			fetch_state <= fetch_state_n;
	always @(*) begin
		fetch_state_n = fetch_state;
		case (fetch_state)
			3'd0: fetch_state_n = ((accepting_fetch_req && (fetch_req_opcode == FETCH_TYPE)) && queue_empty ? 3'd1 : 3'd0);
			3'd1: fetch_state_n = (accepting_rm_req ? 3'd2 : 3'd1);
			3'd2: fetch_state_n = (accepting_rm_resp ? 3'd3 : 3'd2);
			3'd3: fetch_state_n = (obj_remaining_store == {10 {1'sb0}} ? 3'd5 : (queue_full ? 3'd4 : (|fetch_responses_pending && (buffered_fetch_resp_offset == 'd15) ? 3'd2 : ((fetch_responses_pending == {6 {1'sb0}}) && |fetch_obj_remaining ? 3'd1 : 3'd3))));
			3'd4: fetch_state_n = (|obj_remaining_store && !queue_full ? 3'd1 : (obj_remaining_store == {10 {1'sb0}} ? 3'd0 : 3'd4));
			3'd5: fetch_state_n = (fetch_resp_valid ? 3'd0 : 3'd5);
		endcase
	end
	assign fetch_req_ready = (fetch_state == 3'd0) && (fetch_req_opcode == FETCH_TYPE);
	assign free = fetch_state == 3'd0;
	always @(posedge core_clk or negedge resetn)
		if (!resetn) begin
			fetch_req_address_offset <= 1'sb0;
			fetch_obj_remaining <= 1'sb0;
			fetch_responses_pending <= 1'sb0;
			rm_resp_data_q <= 1'sb0;
			issue_partial_done <= 1'sb0;
			issue_partial_done_q <= 1'sb0;
			obj_remaining_store <= 1'sb0;
			buffered_fetch_resp_offset <= 1'sb0;
		end
		else begin
			if (((fetch_state == 3'd0) && accepting_fetch_req) && (fetch_req_opcode == FETCH_TYPE)) begin
				fetch_req_address_offset <= fetch_req_start_address;
				fetch_obj_remaining <= fetch_req_obj_count;
				issue_partial_done <= 1'sb0;
				fetch_responses_pending <= 1'sb0;
				obj_remaining_store <= fetch_req_obj_count;
				buffered_fetch_resp_offset <= 1'sb0;
			end
			else if (accepting_rm_req) begin
				fetch_req_address_offset <= fetch_req_address_offset + fetch_req_bytes;
				fetch_obj_remaining <= fetch_obj_remaining - (fetch_obj_remaining > queue_slots_available ? queue_slots_available : fetch_obj_remaining);
				fetch_responses_pending <= ((fetch_req_bytes - 1) / 64) + 1;
			end
			else if (accepting_rm_resp) begin
				fetch_responses_pending <= fetch_responses_pending - 1'b1;
				rm_resp_data_q <= read_master_resp_data;
				buffered_fetch_resp_offset <= 1'sb0;
			end
			else if (fetch_state == 3'd3) begin
				if (push_queue) begin
					buffered_fetch_resp_offset <= buffered_fetch_resp_offset + 1'b1;
					obj_remaining_store <= obj_remaining_store - 1'b1;
				end
				if (fetch_state_n == 3'd4)
					issue_partial_done <= 1'sb1;
			end
			issue_partial_done_q <= issue_partial_done;
		end
	always @(*) begin
		fetch_req_bytes = (fetch_obj_remaining > queue_slots_available ? queue_slots_available : fetch_obj_remaining) * 4;
		read_master_req_valid = fetch_state == 3'd1;
		read_master_start_address = fetch_memory_range_start_address + fetch_req_address_offset;
		read_master_byte_count = fetch_req_bytes;
		read_master_resp_ready = fetch_state == 3'd2;
	end
	always @(*) begin
		push_queue = ((fetch_state == 3'd3) && !queue_full) && |obj_remaining_store;
		if (UNPACKING_ENABLED)
			push_data = (buffered_fetch_resp_offset == 'd0 ? rm_resp_data_q[511:480] : (buffered_fetch_resp_offset == 'd1 ? rm_resp_data_q[479:448] : (buffered_fetch_resp_offset == 'd2 ? rm_resp_data_q[447:416] : (buffered_fetch_resp_offset == 'd3 ? rm_resp_data_q[415:384] : (buffered_fetch_resp_offset == 'd4 ? rm_resp_data_q[383:352] : (buffered_fetch_resp_offset == 'd5 ? rm_resp_data_q[351:320] : (buffered_fetch_resp_offset == 'd6 ? rm_resp_data_q[319:288] : (buffered_fetch_resp_offset == 'd7 ? rm_resp_data_q[287:256] : (buffered_fetch_resp_offset == 'd8 ? rm_resp_data_q[255:224] : (buffered_fetch_resp_offset == 'd9 ? rm_resp_data_q[223:192] : (buffered_fetch_resp_offset == 'd10 ? rm_resp_data_q[191:160] : (buffered_fetch_resp_offset == 'd11 ? rm_resp_data_q[159:128] : (buffered_fetch_resp_offset == 'd12 ? rm_resp_data_q[127:96] : (buffered_fetch_resp_offset == 'd13 ? rm_resp_data_q[95:64] : (buffered_fetch_resp_offset == 'd14 ? rm_resp_data_q[63:32] : (buffered_fetch_resp_offset == 'd15 ? rm_resp_data_q[31:0] : {QUEUE_WIDTH {1'sb0}}))))))))))))))));
		else
			push_data = rm_resp_data_q;
	end
	always @(*) begin
		trigger_partial_resp = issue_partial_done && !issue_partial_done_q;
		fetch_resp_valid = fetch_state == 3'd5;
		fetch_resp_partial = 1'sb0;
	end
endmodule
module prefetcher_fetch_tag (
	core_clk,
	resetn,
	nsb_prefetcher_req_valid,
	nsb_prefetcher_req_ready,
	nsb_prefetcher_req,
	nsb_prefetcher_resp_valid,
	nsb_prefetcher_resp_ready,
	nsb_prefetcher_resp,
	allocation_valid,
	allocation_nodeslot,
	allocation_feature_count,
	deallocation_valid,
	tag_free,
	fetch_tag_adj_rm_req_valid,
	fetch_tag_adj_rm_req_ready,
	fetch_tag_adj_rm_start_address,
	fetch_tag_adj_rm_byte_count,
	fetch_tag_adj_rm_resp_valid,
	fetch_tag_adj_rm_resp_ready,
	fetch_tag_adj_rm_resp_last,
	fetch_tag_adj_rm_resp_data,
	fetch_tag_adj_rm_resp_axi_id,
	fetch_tag_msg_rm_req_valid,
	fetch_tag_msg_rm_req_ready,
	fetch_tag_msg_rm_start_address,
	fetch_tag_msg_rm_byte_count,
	fetch_tag_msg_rm_resp_valid,
	fetch_tag_msg_rm_resp_ready,
	fetch_tag_msg_rm_resp_last,
	fetch_tag_msg_rm_resp_data,
	fetch_tag_msg_rm_resp_axi_id,
	message_channel_req_valid,
	message_channel_req_ready,
	message_channel_req,
	message_channel_resp_valid,
	message_channel_resp_ready,
	message_channel_resp,
	scale_factor_queue_pop,
	scale_factor_queue_out_data,
	scale_factor_queue_count,
	scale_factor_queue_empty,
	scale_factor_queue_full,
	layer_config_adjacency_list_address_lsb_value,
	layer_config_in_messages_address_lsb_value,
	layer_config_scale_factors_address_lsb_value,
	layer_config_scale_factors_address_msb_value
);
	parameter TAG = 0;
	parameter AXI_ADDRESS_WIDTH = 34;
	parameter AXI_DATA_WIDTH = 512;
	parameter signed [31:0] ADJ_QUEUE_WIDTH = 32;
	parameter signed [31:0] ADJ_QUEUE_DEPTH = 64;
	parameter signed [31:0] MESSAGE_QUEUE_WIDTH = 512;
	parameter signed [31:0] MESSAGE_QUEUE_DEPTH = 4096;
	input wire core_clk;
	input wire resetn;
	input wire nsb_prefetcher_req_valid;
	output reg nsb_prefetcher_req_ready;
	localparam top_pkg_AXI_ADDRESS_WIDTH = 34;
	localparam top_pkg_MAX_FEATURE_COUNT = 1024;
	localparam top_pkg_MAX_NEIGHBOURS = 1024;
	localparam top_pkg_MAX_NODESLOT_COUNT = 32;
	input wire [75:0] nsb_prefetcher_req;
	output reg nsb_prefetcher_resp_valid;
	input wire nsb_prefetcher_resp_ready;
	localparam top_pkg_FETCH_TAG_COUNT = top_pkg_MAX_NODESLOT_COUNT;
	output reg [13:0] nsb_prefetcher_resp;
	input wire allocation_valid;
	input wire [4:0] allocation_nodeslot;
	input wire [9:0] allocation_feature_count;
	input wire deallocation_valid;
	output reg tag_free;
	output wire fetch_tag_adj_rm_req_valid;
	input wire fetch_tag_adj_rm_req_ready;
	output wire [AXI_ADDRESS_WIDTH - 1:0] fetch_tag_adj_rm_start_address;
	localparam top_pkg_MAX_NODES = 1048576;
	localparam top_pkg_NODE_ID_WIDTH = 20;
	localparam top_pkg_MAX_REQUIRED_BYTES_ADJ_FETCH_REQ = 2560;
	localparam top_pkg_LARGE_FEATURE_COUNT = 1024;
	localparam top_pkg_LARGE_MSG_QUEUE_DEPTH = 64;
	localparam top_pkg_LARGE_PRECISION_BYTE_COUNT = 4;
	localparam top_pkg_MAX_REQUIRED_BYTES_MSG_FETCH_REQ = 262144;
	localparam top_pkg_MAX_FETCH_REQ_BYTE_COUNT = top_pkg_MAX_REQUIRED_BYTES_MSG_FETCH_REQ;
	output wire [17:0] fetch_tag_adj_rm_byte_count;
	input wire fetch_tag_adj_rm_resp_valid;
	output wire fetch_tag_adj_rm_resp_ready;
	input wire fetch_tag_adj_rm_resp_last;
	input wire [AXI_DATA_WIDTH - 1:0] fetch_tag_adj_rm_resp_data;
	input wire [3:0] fetch_tag_adj_rm_resp_axi_id;
	output reg fetch_tag_msg_rm_req_valid;
	input wire fetch_tag_msg_rm_req_ready;
	output reg [AXI_ADDRESS_WIDTH - 1:0] fetch_tag_msg_rm_start_address;
	output reg [17:0] fetch_tag_msg_rm_byte_count;
	input wire fetch_tag_msg_rm_resp_valid;
	output reg fetch_tag_msg_rm_resp_ready;
	input wire fetch_tag_msg_rm_resp_last;
	input wire [AXI_DATA_WIDTH - 1:0] fetch_tag_msg_rm_resp_data;
	input wire [3:0] fetch_tag_msg_rm_resp_axi_id;
	input wire message_channel_req_valid;
	output reg message_channel_req_ready;
	input wire [9:0] message_channel_req;
	output reg message_channel_resp_valid;
	input wire message_channel_resp_ready;
	localparam top_pkg_AXI_DATA_WIDTH = 512;
	output reg [513:0] message_channel_resp;
	input wire scale_factor_queue_pop;
	localparam top_pkg_SCALE_FACTOR_QUEUE_READ_WIDTH = 32;
	output wire [31:0] scale_factor_queue_out_data;
	localparam top_pkg_SCALE_FACTOR_QUEUE_READ_DEPTH = 1024;
	output wire [10:0] scale_factor_queue_count;
	output wire scale_factor_queue_empty;
	output wire scale_factor_queue_full;
	input wire [31:0] layer_config_adjacency_list_address_lsb_value;
	input wire [31:0] layer_config_in_messages_address_lsb_value;
	input wire [31:0] layer_config_scale_factors_address_lsb_value;
	input wire [1:0] layer_config_scale_factors_address_msb_value;
	reg [4:0] allocated_nodeslot;
	reg [9:0] allocated_feature_count;
	wire make_tag_free;
	reg [2:0] message_fetch_state;
	reg [2:0] message_fetch_state_n;
	wire push_adj_queue;
	reg pop_adj_queue;
	wire [ADJ_QUEUE_WIDTH - 1:0] adj_queue_write_data;
	wire adj_queue_head_valid;
	wire [ADJ_QUEUE_WIDTH - 1:0] adj_queue_head;
	wire adj_queue_empty;
	wire adj_queue_full;
	wire [$clog2(ADJ_QUEUE_DEPTH):0] adj_queue_count;
	reg [$clog2(ADJ_QUEUE_DEPTH):0] adj_queue_slots_available;
	wire adj_queue_manager_free;
	wire adj_queue_manager_ready;
	wire adj_queue_fetch_resp_valid;
	wire adj_queue_fetch_resp_partial;
	reg push_message_queue;
	reg pop_message_queue;
	wire message_queue_head_valid;
	wire [MESSAGE_QUEUE_WIDTH - 1:0] message_queue_head;
	wire message_queue_empty;
	wire message_queue_full;
	wire [$clog2(MESSAGE_QUEUE_DEPTH):0] message_queue_count;
	reg accepting_nsb_req;
	reg accepting_message_fetch_req;
	reg accepting_msg_fetch_resp;
	wire scale_factor_queue_push;
	localparam top_pkg_SCALE_FACTOR_QUEUE_WRITE_WIDTH = 512;
	wire [511:0] scale_factor_queue_in_data;
	wire scale_factor_fetch_req_ready;
	wire scale_factor_fetch_resp_valid;
	wire scale_factor_fetch_resp_partial;
	wire scale_factor_read_master_req_valid;
	wire [AXI_ADDRESS_WIDTH - 1:0] scale_factor_read_master_start_address;
	wire [17:0] scale_factor_read_master_byte_count;
	wire scale_factor_read_master_resp_ready;
	reg [1:0] msg_fetch_req_precision_q;
	localparam top_pkg_MAX_PRECISION_BYTE_COUNT = 4;
	localparam prefetcher_pkg_MAX_MSG_FETCH_RESPONSES = 64;
	reg [5:0] msg_queue_expected_responses;
	reg issue_nsb_partial_done_msg_fetch;
	reg issue_nsb_partial_done_msg_fetch_q;
	reg [MESSAGE_QUEUE_WIDTH - 1:0] msg_queue_write_data;
	reg accepted_message_channel_req;
	ultraram_fifo #(
		.WIDTH(ADJ_QUEUE_WIDTH),
		.DEPTH(ADJ_QUEUE_DEPTH)
	) adjacency_queue(
		.core_clk(core_clk),
		.resetn(resetn),
		.push(push_adj_queue),
		.in_data(adj_queue_write_data),
		.pop(pop_adj_queue),
		.out_valid(adj_queue_head_valid),
		.out_data(adj_queue_head),
		.count(adj_queue_count),
		.empty(adj_queue_empty),
		.full(adj_queue_full)
	);
	prefetcher_streaming_manager #(
		.FETCH_TYPE(3'd1),
		.QUEUE_WIDTH(ADJ_QUEUE_WIDTH),
		.QUEUE_DEPTH(ADJ_QUEUE_DEPTH),
		.STREAMING_ENABLED(1),
		.UNPACKING_ENABLED(1)
	) adj_queue_manager_i(
		.core_clk(core_clk),
		.resetn(resetn),
		.free(adj_queue_manager_free),
		.fetch_req_valid(!tag_free && nsb_prefetcher_req_valid),
		.fetch_req_ready(adj_queue_manager_ready),
		.fetch_req_opcode(nsb_prefetcher_req[75-:3]),
		.fetch_req_start_address(nsb_prefetcher_req[72-:34]),
		.fetch_req_obj_count(nsb_prefetcher_req[9-:10]),
		.fetch_resp_valid(adj_queue_fetch_resp_valid),
		.fetch_resp_partial(adj_queue_fetch_resp_partial),
		.fetch_memory_range_start_address({2'd0, layer_config_adjacency_list_address_lsb_value}),
		.read_master_req_valid(fetch_tag_adj_rm_req_valid),
		.read_master_req_ready(fetch_tag_adj_rm_req_ready),
		.read_master_start_address(fetch_tag_adj_rm_start_address),
		.read_master_byte_count(fetch_tag_adj_rm_byte_count),
		.read_master_resp_valid(fetch_tag_adj_rm_resp_valid),
		.read_master_resp_ready(fetch_tag_adj_rm_resp_ready),
		.read_master_resp_last(fetch_tag_adj_rm_resp_last),
		.read_master_resp_data(fetch_tag_adj_rm_resp_data),
		.read_master_resp_axi_id(fetch_tag_adj_rm_resp_axi_id),
		.push_queue(push_adj_queue),
		.push_data(adj_queue_write_data),
		.queue_slots_available(adj_queue_slots_available),
		.queue_empty(adj_queue_empty),
		.queue_full(adj_queue_full)
	);
	ultraram_fifo #(
		.WIDTH(MESSAGE_QUEUE_WIDTH),
		.DEPTH(MESSAGE_QUEUE_DEPTH)
	) message_queue(
		.core_clk(core_clk),
		.resetn(resetn),
		.push(push_message_queue),
		.in_data(msg_queue_write_data),
		.pop(pop_message_queue),
		.out_valid(message_queue_head_valid),
		.out_data(message_queue_head),
		.count(message_queue_count),
		.empty(message_queue_empty),
		.full(message_queue_full)
	);
	localparam top_pkg_SCALE_FACTOR_QUEUE_WRITE_DEPTH = 64;
	bram_fifo #(
		.WRITE_WIDTH(top_pkg_SCALE_FACTOR_QUEUE_WRITE_WIDTH),
		.WRITE_DEPTH(top_pkg_SCALE_FACTOR_QUEUE_WRITE_DEPTH),
		.READ_WIDTH(top_pkg_SCALE_FACTOR_QUEUE_READ_WIDTH),
		.READ_DEPTH(top_pkg_SCALE_FACTOR_QUEUE_READ_DEPTH),
		.BRAM_TYPE(0)
	) scale_factor_queue(
		.core_clk(core_clk),
		.resetn(resetn),
		.push(scale_factor_queue_push),
		.in_data(scale_factor_queue_in_data),
		.pop(scale_factor_queue_pop),
		.out_data(scale_factor_queue_out_data),
		.count(scale_factor_queue_count),
		.empty(scale_factor_queue_empty),
		.full(scale_factor_queue_full)
	);
	localparam sv2v_uu_scale_factor_queue_manager_QUEUE_DEPTH = top_pkg_SCALE_FACTOR_QUEUE_WRITE_DEPTH;
	localparam [6:0] sv2v_uu_scale_factor_queue_manager_ext_queue_slots_available_1 = 1'sb1;
	prefetcher_streaming_manager #(
		.FETCH_TYPE(3'd3),
		.QUEUE_WIDTH(top_pkg_SCALE_FACTOR_QUEUE_WRITE_WIDTH),
		.QUEUE_DEPTH(top_pkg_SCALE_FACTOR_QUEUE_WRITE_DEPTH),
		.STREAMING_ENABLED(0),
		.UNPACKING_ENABLED(0)
	) scale_factor_queue_manager(
		.core_clk(core_clk),
		.resetn(resetn),
		.fetch_req_valid(!tag_free && nsb_prefetcher_req_valid),
		.fetch_req_ready(scale_factor_fetch_req_ready),
		.fetch_req_opcode(nsb_prefetcher_req[75-:3]),
		.fetch_req_start_address(nsb_prefetcher_req[72-:34]),
		.fetch_req_obj_count(nsb_prefetcher_req[9-:10]),
		.fetch_resp_valid(scale_factor_fetch_resp_valid),
		.fetch_resp_partial(scale_factor_fetch_resp_partial),
		.fetch_memory_range_start_address({layer_config_scale_factors_address_msb_value, layer_config_scale_factors_address_lsb_value}),
		.read_master_req_valid(scale_factor_read_master_req_valid),
		.read_master_req_ready(fetch_tag_msg_rm_req_ready),
		.read_master_start_address(scale_factor_read_master_start_address),
		.read_master_byte_count(scale_factor_read_master_byte_count),
		.read_master_resp_valid(fetch_tag_msg_rm_resp_valid),
		.read_master_resp_ready(scale_factor_read_master_resp_ready),
		.read_master_resp_last(fetch_tag_msg_rm_resp_last),
		.read_master_resp_data(fetch_tag_msg_rm_resp_data),
		.read_master_resp_axi_id(fetch_tag_msg_rm_resp_axi_id),
		.push_queue(scale_factor_queue_push),
		.push_data(scale_factor_queue_in_data),
		.queue_slots_available(sv2v_uu_scale_factor_queue_manager_ext_queue_slots_available_1),
		.queue_empty(scale_factor_queue_empty),
		.queue_full(scale_factor_queue_full)
	);
	always @(*) begin
		accepting_nsb_req = nsb_prefetcher_req_valid && nsb_prefetcher_req_ready;
		accepting_message_fetch_req = fetch_tag_msg_rm_req_valid && fetch_tag_msg_rm_req_ready;
		accepting_msg_fetch_resp = fetch_tag_msg_rm_resp_valid && fetch_tag_msg_rm_resp_ready;
	end
	always @(*) adj_queue_slots_available = 7'd64 - adj_queue_count;
	always @(posedge core_clk or negedge resetn)
		if (!resetn)
			message_fetch_state <= 3'd0;
		else
			message_fetch_state <= message_fetch_state_n;
	always @(*) begin
		message_fetch_state_n = message_fetch_state;
		case (message_fetch_state)
			3'd0: message_fetch_state_n = ((((!tag_free && accepting_nsb_req) && (nsb_prefetcher_req[75-:3] == 3'd2)) && !adj_queue_empty) && (nsb_prefetcher_req[16-:5] == allocated_nodeslot) ? 3'd1 : 3'd0);
			3'd1: message_fetch_state_n = (accepting_message_fetch_req ? 3'd2 : 3'd1);
			3'd2: message_fetch_state_n = ((accepting_msg_fetch_resp && (msg_queue_expected_responses == 1'b1)) && adj_queue_empty ? 3'd4 : (((accepting_msg_fetch_resp && (msg_queue_expected_responses == 1'b1)) && !adj_queue_empty) && message_queue_full ? 3'd3 : (((accepting_msg_fetch_resp && (msg_queue_expected_responses == 1'b1)) && !adj_queue_empty) && !message_queue_full ? 3'd1 : 3'd2)));
			3'd3: message_fetch_state_n = (adj_queue_empty ? 3'd4 : (!adj_queue_empty && !message_queue_full ? 3'd1 : 3'd3));
			3'd4: message_fetch_state_n = ((nsb_prefetcher_resp_valid && nsb_prefetcher_resp_ready) && (nsb_prefetcher_resp[8-:3] == 3'd2) ? 3'd0 : 3'd4);
		endcase
	end
	function [5:0] top_pkg_bits_per_precision;
		input reg [1:0] precision;
		reg [5:0] bits;
		begin
			case (precision)
				2'd0: bits = 6'd32;
				2'd1: bits = 6'd16;
				2'd2: bits = 6'd8;
				2'd3: bits = 6'd4;
				default: bits = 6'd0;
			endcase
			top_pkg_bits_per_precision = bits;
		end
	endfunction
	always @(*) begin
		fetch_tag_msg_rm_req_valid = scale_factor_read_master_req_valid || ((((message_fetch_state == 3'd1) && !adj_queue_empty) && adj_queue_head_valid) && !message_queue_full);
		fetch_tag_msg_rm_start_address = (scale_factor_read_master_req_valid ? scale_factor_read_master_start_address : {2'd0, layer_config_in_messages_address_lsb_value} + (64 * adj_queue_head));
		fetch_tag_msg_rm_byte_count = (scale_factor_read_master_req_valid ? scale_factor_read_master_byte_count : (allocated_feature_count * top_pkg_bits_per_precision(msg_fetch_req_precision_q)) / 8);
		fetch_tag_msg_rm_resp_ready = (message_fetch_state == 3'd2) || scale_factor_read_master_resp_ready;
		push_message_queue = (message_fetch_state == 3'd2) && accepting_msg_fetch_resp;
		msg_queue_write_data = fetch_tag_msg_rm_resp_data;
		pop_adj_queue = (message_fetch_state == 3'd1) && accepting_message_fetch_req;
	end
	always @(posedge core_clk or negedge resetn)
		if (!resetn) begin
			msg_fetch_req_precision_q <= 2'd0;
			msg_queue_expected_responses <= 1'sb0;
			issue_nsb_partial_done_msg_fetch <= 1'sb0;
		end
		else if ((message_fetch_state == 3'd0) && (message_fetch_state_n == 3'd1)) begin
			msg_fetch_req_precision_q <= nsb_prefetcher_req[11-:2];
			msg_queue_expected_responses <= 1'sb0;
			issue_nsb_partial_done_msg_fetch <= 1'sb0;
		end
		else if (accepting_message_fetch_req)
			msg_queue_expected_responses <= ((fetch_tag_msg_rm_byte_count - 1) / 64) + 1;
		else begin
			if (accepting_msg_fetch_resp)
				msg_queue_expected_responses <= msg_queue_expected_responses - 1;
			if ((message_fetch_state == 3'd2) && (message_fetch_state_n == 3'd3))
				issue_nsb_partial_done_msg_fetch <= 1'sb1;
			issue_nsb_partial_done_msg_fetch_q <= issue_nsb_partial_done_msg_fetch;
		end
	wire trigger_msg_partial_resp;
	assign trigger_msg_partial_resp = issue_nsb_partial_done_msg_fetch && !issue_nsb_partial_done_msg_fetch_q;
	always @(*) begin
		nsb_prefetcher_req_ready = (!tag_free && (nsb_prefetcher_req[16-:5] == allocated_nodeslot)) && (nsb_prefetcher_req[75-:3] == 3'd1 ? adj_queue_manager_ready : (nsb_prefetcher_req[75-:3] == 3'd3 ? scale_factor_fetch_req_ready : (nsb_prefetcher_req[75-:3] == 3'd2 ? ((message_fetch_state == 3'd0) && (nsb_prefetcher_req[75-:3] == 3'd2)) && !adj_queue_empty : 1'b0)));
		nsb_prefetcher_resp_valid = ((adj_queue_fetch_resp_valid || (message_fetch_state == 3'd4)) || trigger_msg_partial_resp) || scale_factor_fetch_resp_valid;
		nsb_prefetcher_resp[13-:5] = allocated_nodeslot;
		nsb_prefetcher_resp[8-:3] = (adj_queue_fetch_resp_valid ? 3'd1 : (scale_factor_fetch_resp_valid ? 3'd3 : (trigger_msg_partial_resp || (message_fetch_state == 3'd4) ? 3'd2 : 3'd4)));
		nsb_prefetcher_resp[5-:5] = TAG[4:0];
		nsb_prefetcher_resp[0] = (adj_queue_fetch_resp_partial || trigger_msg_partial_resp) || scale_factor_fetch_resp_partial;
	end
	always @(posedge core_clk or negedge resetn)
		if (!resetn)
			accepted_message_channel_req <= 1'sb0;
		else if (tag_free && allocation_valid)
			accepted_message_channel_req <= 1'sb0;
		else if (message_channel_req_valid && message_channel_req_ready)
			accepted_message_channel_req <= 1'sb1;
	always @(*) begin
		message_channel_req_ready = (!message_queue_empty && (message_fetch_state == 3'd0)) && (message_channel_req[9-:5] == allocated_nodeslot);
		message_channel_resp_valid = (accepted_message_channel_req && message_queue_head_valid) && !message_queue_empty;
		message_channel_resp[513-:512] = message_queue_head;
		message_channel_resp[1] = message_queue_count <= ({allocated_feature_count[9:4], 4'd0} + (|allocated_feature_count[3:0] ? 1'b1 : 1'b0));
		message_channel_resp[0] = (message_queue_count[$clog2(MESSAGE_QUEUE_DEPTH) - 1:1] == {(($clog2(MESSAGE_QUEUE_DEPTH) - 1) >= 1 ? $clog2(MESSAGE_QUEUE_DEPTH) - 1 : 3 - $clog2(MESSAGE_QUEUE_DEPTH)) * 1 {1'sb0}}) && message_queue_count[0];
		pop_message_queue = message_channel_resp_valid && message_channel_resp_ready;
	end
	assign make_tag_free = (((deallocation_valid && adj_queue_empty) && message_queue_empty) && adj_queue_manager_free) && (message_fetch_state == 3'd0);
	always @(posedge core_clk or negedge resetn)
		if (!resetn) begin
			tag_free <= 1'sb1;
			allocated_nodeslot <= 1'sb0;
			allocated_feature_count <= 1'sb0;
		end
		else if (tag_free && allocation_valid) begin
			allocated_nodeslot <= allocation_nodeslot;
			allocated_feature_count <= allocation_feature_count;
			tag_free <= 1'sb0;
		end
		else if (make_tag_free)
			tag_free <= 1'sb1;
endmodule
module prefetcher_feature_bank (
	core_clk,
	resetn,
	nsb_prefetcher_feature_bank_req_valid,
	nsb_prefetcher_feature_bank_req_ready,
	nsb_prefetcher_feature_bank_req,
	nsb_prefetcher_feature_bank_resp_valid,
	nsb_prefetcher_feature_bank_resp,
	adj_rm_fetch_req_valid,
	adj_rm_fetch_req_ready,
	adj_rm_fetch_start_address,
	adj_rm_fetch_byte_count,
	adj_rm_fetch_resp_valid,
	adj_rm_fetch_resp_ready,
	adj_rm_fetch_resp_last,
	adj_rm_fetch_resp_data,
	adj_rm_fetch_resp_axi_id,
	msg_rm_fetch_req_valid,
	msg_rm_fetch_req_ready,
	msg_rm_fetch_start_address,
	msg_rm_fetch_byte_count,
	msg_rm_fetch_resp_valid,
	msg_rm_fetch_resp_ready,
	msg_rm_fetch_resp_last,
	msg_rm_fetch_resp_data,
	msg_rm_fetch_resp_axi_id,
	message_channel_req_valid,
	message_channel_req_ready,
	message_channel_req,
	message_channel_resp_valid,
	message_channel_resp_ready,
	message_channel_resp,
	scale_factor_queue_pop,
	scale_factor_queue_out_valid,
	scale_factor_queue_out_data,
	scale_factor_queue_count,
	scale_factor_queue_empty,
	scale_factor_queue_full,
	layer_config_in_features_count,
	layer_config_adjacency_list_address_lsb_value,
	layer_config_in_messages_address_lsb_value,
	layer_config_scale_factors_address_lsb_value,
	layer_config_scale_factors_address_msb_value
);
	parameter AXI_ADDRESS_WIDTH = 34;
	parameter AXI_DATA_WIDTH = 512;
	parameter FETCH_TAG_COUNT = 1;
	input wire core_clk;
	input wire resetn;
	input wire nsb_prefetcher_feature_bank_req_valid;
	output reg nsb_prefetcher_feature_bank_req_ready;
	localparam top_pkg_AXI_ADDRESS_WIDTH = 34;
	localparam top_pkg_MAX_FEATURE_COUNT = 1024;
	localparam top_pkg_MAX_NEIGHBOURS = 1024;
	localparam top_pkg_MAX_NODESLOT_COUNT = 32;
	input wire [75:0] nsb_prefetcher_feature_bank_req;
	output reg nsb_prefetcher_feature_bank_resp_valid;
	localparam top_pkg_FETCH_TAG_COUNT = top_pkg_MAX_NODESLOT_COUNT;
	output reg [13:0] nsb_prefetcher_feature_bank_resp;
	output reg adj_rm_fetch_req_valid;
	input wire adj_rm_fetch_req_ready;
	output reg [AXI_ADDRESS_WIDTH - 1:0] adj_rm_fetch_start_address;
	localparam top_pkg_MAX_NODES = 1048576;
	localparam top_pkg_NODE_ID_WIDTH = 20;
	localparam top_pkg_MAX_REQUIRED_BYTES_ADJ_FETCH_REQ = 2560;
	localparam top_pkg_LARGE_FEATURE_COUNT = 1024;
	localparam top_pkg_LARGE_MSG_QUEUE_DEPTH = 64;
	localparam top_pkg_LARGE_PRECISION_BYTE_COUNT = 4;
	localparam top_pkg_MAX_REQUIRED_BYTES_MSG_FETCH_REQ = 262144;
	localparam top_pkg_MAX_FETCH_REQ_BYTE_COUNT = top_pkg_MAX_REQUIRED_BYTES_MSG_FETCH_REQ;
	output reg [17:0] adj_rm_fetch_byte_count;
	input wire adj_rm_fetch_resp_valid;
	output reg adj_rm_fetch_resp_ready;
	input wire adj_rm_fetch_resp_last;
	input wire [AXI_DATA_WIDTH - 1:0] adj_rm_fetch_resp_data;
	input wire [3:0] adj_rm_fetch_resp_axi_id;
	output reg msg_rm_fetch_req_valid;
	input wire msg_rm_fetch_req_ready;
	output reg [AXI_ADDRESS_WIDTH - 1:0] msg_rm_fetch_start_address;
	output reg [17:0] msg_rm_fetch_byte_count;
	input wire msg_rm_fetch_resp_valid;
	output reg msg_rm_fetch_resp_ready;
	input wire msg_rm_fetch_resp_last;
	input wire [AXI_DATA_WIDTH - 1:0] msg_rm_fetch_resp_data;
	input wire [3:0] msg_rm_fetch_resp_axi_id;
	localparam top_pkg_MESSAGE_CHANNEL_COUNT = top_pkg_MAX_NODESLOT_COUNT;
	input wire [31:0] message_channel_req_valid;
	output wire [31:0] message_channel_req_ready;
	input wire [319:0] message_channel_req;
	output wire [31:0] message_channel_resp_valid;
	input wire [31:0] message_channel_resp_ready;
	localparam top_pkg_AXI_DATA_WIDTH = 512;
	output wire [16447:0] message_channel_resp;
	input wire [FETCH_TAG_COUNT - 1:0] scale_factor_queue_pop;
	output wire [FETCH_TAG_COUNT - 1:0] scale_factor_queue_out_valid;
	localparam top_pkg_SCALE_FACTOR_QUEUE_READ_WIDTH = 32;
	output wire [(FETCH_TAG_COUNT * 32) - 1:0] scale_factor_queue_out_data;
	localparam top_pkg_SCALE_FACTOR_QUEUE_READ_DEPTH = 1024;
	output wire [(FETCH_TAG_COUNT * 11) - 1:0] scale_factor_queue_count;
	output wire [FETCH_TAG_COUNT - 1:0] scale_factor_queue_empty;
	output wire [FETCH_TAG_COUNT - 1:0] scale_factor_queue_full;
	input wire [9:0] layer_config_in_features_count;
	input wire [31:0] layer_config_adjacency_list_address_lsb_value;
	input wire [31:0] layer_config_in_messages_address_lsb_value;
	input wire [31:0] layer_config_scale_factors_address_lsb_value;
	input wire [1:0] layer_config_scale_factors_address_msb_value;
	reg [FETCH_TAG_COUNT - 1:0] allocation_valid;
	reg [(FETCH_TAG_COUNT * 5) - 1:0] allocation_nodeslot;
	reg [(FETCH_TAG_COUNT * 10) - 1:0] allocation_feature_count;
	reg [FETCH_TAG_COUNT - 1:0] deallocation_valid;
	wire [FETCH_TAG_COUNT - 1:0] tag_free;
	wire [FETCH_TAG_COUNT - 1:0] fetch_tag_adj_rm_req_valid;
	wire [FETCH_TAG_COUNT - 1:0] fetch_tag_adj_rm_req_ready;
	wire [(FETCH_TAG_COUNT * AXI_ADDRESS_WIDTH) - 1:0] fetch_tag_adj_rm_start_address;
	wire [(FETCH_TAG_COUNT * 18) - 1:0] fetch_tag_adj_rm_byte_count;
	reg [FETCH_TAG_COUNT - 1:0] fetch_tag_adj_rm_resp_valid;
	wire [FETCH_TAG_COUNT - 1:0] fetch_tag_adj_rm_resp_ready;
	reg [FETCH_TAG_COUNT - 1:0] fetch_tag_adj_rm_resp_last;
	reg [(FETCH_TAG_COUNT * AXI_DATA_WIDTH) - 1:0] fetch_tag_adj_rm_resp_data;
	reg [(FETCH_TAG_COUNT * 4) - 1:0] fetch_tag_adj_rm_resp_axi_id;
	wire [FETCH_TAG_COUNT - 1:0] fetch_tag_msg_rm_req_valid;
	wire [FETCH_TAG_COUNT - 1:0] fetch_tag_msg_rm_req_ready;
	wire [(FETCH_TAG_COUNT * AXI_ADDRESS_WIDTH) - 1:0] fetch_tag_msg_rm_start_address;
	wire [(FETCH_TAG_COUNT * 18) - 1:0] fetch_tag_msg_rm_byte_count;
	reg [FETCH_TAG_COUNT - 1:0] fetch_tag_msg_rm_resp_valid;
	wire [FETCH_TAG_COUNT - 1:0] fetch_tag_msg_rm_resp_ready;
	reg [FETCH_TAG_COUNT - 1:0] fetch_tag_msg_rm_resp_last;
	reg [(FETCH_TAG_COUNT * AXI_DATA_WIDTH) - 1:0] fetch_tag_msg_rm_resp_data;
	reg [(FETCH_TAG_COUNT * 4) - 1:0] fetch_tag_msg_rm_resp_axi_id;
	reg [FETCH_TAG_COUNT - 1:0] nsb_prefetcher_fetch_tag_req_valid;
	wire [FETCH_TAG_COUNT - 1:0] nsb_prefetcher_fetch_tag_req_ready;
	reg [(FETCH_TAG_COUNT * 76) - 1:0] nsb_prefetcher_fetch_tag_req;
	wire [FETCH_TAG_COUNT - 1:0] nsb_prefetcher_fetch_tag_resp_valid;
	wire [(FETCH_TAG_COUNT * 14) - 1:0] nsb_prefetcher_fetch_tag_resp;
	wire [FETCH_TAG_COUNT - 1:0] fetch_tag_resp_arb;
	wire [$clog2(FETCH_TAG_COUNT) - 1:0] fetch_tag_resp_arb_bin;
	wire [FETCH_TAG_COUNT - 1:0] chosen_fetch_tag_adj_rm_req;
	wire [$clog2(FETCH_TAG_COUNT) - 1:0] chosen_fetch_tag_adj_rm_req_bin;
	reg [$clog2(FETCH_TAG_COUNT) - 1:0] chosen_fetch_tag_adj_rm_req_bin_q;
	wire [FETCH_TAG_COUNT - 1:0] chosen_fetch_tag_msg_rm_req;
	wire [$clog2(FETCH_TAG_COUNT) - 1:0] chosen_fetch_tag_msg_rm_req_bin;
	reg [$clog2(FETCH_TAG_COUNT) - 1:0] chosen_fetch_tag_msg_rm_req_bin_q;
	genvar fetch_tag;
	generate
		for (fetch_tag = 0; fetch_tag < FETCH_TAG_COUNT; fetch_tag = fetch_tag + 1) begin : genblk1
			prefetcher_fetch_tag #(
				.TAG(fetch_tag),
				.ADJ_QUEUE_WIDTH(32),
				.ADJ_QUEUE_DEPTH(64),
				.MESSAGE_QUEUE_WIDTH(512),
				.MESSAGE_QUEUE_DEPTH(4096)
			) fetch_tag_i(
				.core_clk(core_clk),
				.resetn(resetn),
				.allocation_valid(allocation_valid[fetch_tag]),
				.allocation_nodeslot(allocation_nodeslot[fetch_tag * 5+:5]),
				.allocation_feature_count(allocation_feature_count[fetch_tag * 10+:10]),
				.deallocation_valid(deallocation_valid[fetch_tag]),
				.tag_free(tag_free[fetch_tag]),
				.nsb_prefetcher_req_valid(nsb_prefetcher_fetch_tag_req_valid[fetch_tag]),
				.nsb_prefetcher_req_ready(nsb_prefetcher_fetch_tag_req_ready[fetch_tag]),
				.nsb_prefetcher_req(nsb_prefetcher_fetch_tag_req[fetch_tag * 76+:76]),
				.nsb_prefetcher_resp_valid(nsb_prefetcher_fetch_tag_resp_valid[fetch_tag]),
				.nsb_prefetcher_resp_ready(fetch_tag_resp_arb[fetch_tag]),
				.nsb_prefetcher_resp(nsb_prefetcher_fetch_tag_resp[0 + (fetch_tag * 14)+:14]),
				.fetch_tag_adj_rm_req_valid(fetch_tag_adj_rm_req_valid[fetch_tag]),
				.fetch_tag_adj_rm_req_ready(fetch_tag_adj_rm_req_ready[fetch_tag]),
				.fetch_tag_adj_rm_start_address(fetch_tag_adj_rm_start_address[fetch_tag * AXI_ADDRESS_WIDTH+:AXI_ADDRESS_WIDTH]),
				.fetch_tag_adj_rm_byte_count(fetch_tag_adj_rm_byte_count[fetch_tag * 18+:18]),
				.fetch_tag_adj_rm_resp_valid(fetch_tag_adj_rm_resp_valid[fetch_tag]),
				.fetch_tag_adj_rm_resp_ready(fetch_tag_adj_rm_resp_ready[fetch_tag]),
				.fetch_tag_adj_rm_resp_last(fetch_tag_adj_rm_resp_last[fetch_tag]),
				.fetch_tag_adj_rm_resp_data(fetch_tag_adj_rm_resp_data[fetch_tag * AXI_DATA_WIDTH+:AXI_DATA_WIDTH]),
				.fetch_tag_adj_rm_resp_axi_id(fetch_tag_adj_rm_resp_axi_id[fetch_tag * 4+:4]),
				.fetch_tag_msg_rm_req_valid(fetch_tag_msg_rm_req_valid[fetch_tag]),
				.fetch_tag_msg_rm_req_ready(fetch_tag_msg_rm_req_ready[fetch_tag]),
				.fetch_tag_msg_rm_start_address(fetch_tag_msg_rm_start_address[fetch_tag * AXI_ADDRESS_WIDTH+:AXI_ADDRESS_WIDTH]),
				.fetch_tag_msg_rm_byte_count(fetch_tag_msg_rm_byte_count[fetch_tag * 18+:18]),
				.fetch_tag_msg_rm_resp_valid(fetch_tag_msg_rm_resp_valid[fetch_tag]),
				.fetch_tag_msg_rm_resp_ready(fetch_tag_msg_rm_resp_ready[fetch_tag]),
				.fetch_tag_msg_rm_resp_last(fetch_tag_msg_rm_resp_last[fetch_tag]),
				.fetch_tag_msg_rm_resp_data(fetch_tag_msg_rm_resp_data[fetch_tag * AXI_DATA_WIDTH+:AXI_DATA_WIDTH]),
				.fetch_tag_msg_rm_resp_axi_id(fetch_tag_msg_rm_resp_axi_id[fetch_tag * 4+:4]),
				.message_channel_req_valid(message_channel_req_valid[fetch_tag]),
				.message_channel_req_ready(message_channel_req_ready[fetch_tag]),
				.message_channel_req(message_channel_req[fetch_tag * 10+:10]),
				.message_channel_resp_valid(message_channel_resp_valid[fetch_tag]),
				.message_channel_resp_ready(message_channel_resp_ready[fetch_tag]),
				.message_channel_resp(message_channel_resp[0 + (fetch_tag * 514)+:514]),
				.scale_factor_queue_pop(scale_factor_queue_pop[fetch_tag]),
				.scale_factor_queue_out_data(scale_factor_queue_out_data[fetch_tag * 32+:32]),
				.scale_factor_queue_count(scale_factor_queue_count[fetch_tag * 11+:11]),
				.scale_factor_queue_empty(scale_factor_queue_empty[fetch_tag]),
				.scale_factor_queue_full(scale_factor_queue_full[fetch_tag]),
				.layer_config_adjacency_list_address_lsb_value(layer_config_adjacency_list_address_lsb_value),
				.layer_config_in_messages_address_lsb_value(layer_config_in_messages_address_lsb_value),
				.layer_config_scale_factors_address_lsb_value(layer_config_scale_factors_address_lsb_value),
				.layer_config_scale_factors_address_msb_value(layer_config_scale_factors_address_msb_value)
			);
			always @(*) begin
				allocation_valid[fetch_tag] = (nsb_prefetcher_feature_bank_req_valid && (nsb_prefetcher_feature_bank_req[75-:3] == 3'd1)) && (nsb_prefetcher_feature_bank_req[16-:5] == fetch_tag);
				allocation_nodeslot[fetch_tag * 5+:5] = nsb_prefetcher_feature_bank_req[16-:5];
				allocation_feature_count[fetch_tag * 10+:10] = layer_config_in_features_count;
			end
			always @(posedge core_clk or negedge resetn)
				if (!resetn)
					deallocation_valid[fetch_tag] <= 1'sb0;
				else
					deallocation_valid[fetch_tag] <= ((message_channel_resp_valid[fetch_tag] && message_channel_resp_ready[fetch_tag]) && message_channel_resp[(fetch_tag * 514) + 0] ? 1'b1 : 1'b0);
			always @(*) begin
				nsb_prefetcher_fetch_tag_req_valid[fetch_tag] = nsb_prefetcher_feature_bank_req_valid && (nsb_prefetcher_feature_bank_req[16-:5] == fetch_tag);
				nsb_prefetcher_fetch_tag_req[fetch_tag * 76+:76] = nsb_prefetcher_feature_bank_req;
			end
			assign fetch_tag_adj_rm_req_ready[fetch_tag] = chosen_fetch_tag_adj_rm_req[fetch_tag] && adj_rm_fetch_req_ready;
			assign fetch_tag_msg_rm_req_ready[fetch_tag] = chosen_fetch_tag_msg_rm_req[fetch_tag] && msg_rm_fetch_req_ready;
			always @(*) begin
				fetch_tag_adj_rm_resp_valid[fetch_tag] = adj_rm_fetch_resp_valid && (chosen_fetch_tag_adj_rm_req_bin_q == fetch_tag);
				fetch_tag_adj_rm_resp_last[fetch_tag] = adj_rm_fetch_resp_last;
				fetch_tag_adj_rm_resp_data[fetch_tag * AXI_DATA_WIDTH+:AXI_DATA_WIDTH] = adj_rm_fetch_resp_data;
				fetch_tag_adj_rm_resp_axi_id[fetch_tag * 4+:4] = adj_rm_fetch_resp_axi_id;
				fetch_tag_msg_rm_resp_valid[fetch_tag] = msg_rm_fetch_resp_valid && (chosen_fetch_tag_msg_rm_req_bin_q == fetch_tag);
				fetch_tag_msg_rm_resp_last[fetch_tag] = msg_rm_fetch_resp_last;
				fetch_tag_msg_rm_resp_data[fetch_tag * AXI_DATA_WIDTH+:AXI_DATA_WIDTH] = msg_rm_fetch_resp_data;
				fetch_tag_msg_rm_resp_axi_id[fetch_tag * 4+:4] = msg_rm_fetch_resp_axi_id;
			end
		end
	endgenerate
	localparam [0:0] sv2v_uu_fetch_tag_resp_arb_i_ext_update_lru_1 = 1'sb1;
	rr_arbiter #(.NUM_REQUESTERS(FETCH_TAG_COUNT)) fetch_tag_resp_arb_i(
		.clk(core_clk),
		.resetn(resetn),
		.request(nsb_prefetcher_fetch_tag_resp_valid),
		.update_lru(sv2v_uu_fetch_tag_resp_arb_i_ext_update_lru_1),
		.grant_oh(fetch_tag_resp_arb)
	);
	onehot_to_binary_comb #(.INPUT_WIDTH(FETCH_TAG_COUNT)) fetch_tag_resp_arb_oh2bin(
		.input_data(fetch_tag_resp_arb),
		.output_data(fetch_tag_resp_arb_bin)
	);
	rr_arbiter #(.NUM_REQUESTERS(FETCH_TAG_COUNT)) adj_rm_req_arb(
		.clk(core_clk),
		.resetn(resetn),
		.request(fetch_tag_adj_rm_req_valid),
		.update_lru(adj_rm_fetch_req_ready),
		.grant_oh(chosen_fetch_tag_adj_rm_req)
	);
	onehot_to_binary_comb #(.INPUT_WIDTH(FETCH_TAG_COUNT)) adj_rm_req_arb_oh2bin(
		.input_data(chosen_fetch_tag_adj_rm_req),
		.output_data(chosen_fetch_tag_adj_rm_req_bin)
	);
	rr_arbiter #(.NUM_REQUESTERS(FETCH_TAG_COUNT)) msg_rm_req_arb(
		.clk(core_clk),
		.resetn(resetn),
		.request(fetch_tag_msg_rm_req_valid),
		.update_lru(msg_rm_fetch_req_ready),
		.grant_oh(chosen_fetch_tag_msg_rm_req)
	);
	onehot_to_binary_comb #(.INPUT_WIDTH(FETCH_TAG_COUNT)) msg_rm_req_arb_oh2bin(
		.input_data(chosen_fetch_tag_msg_rm_req),
		.output_data(chosen_fetch_tag_msg_rm_req_bin)
	);
	always @(*) begin
		nsb_prefetcher_feature_bank_req_ready = nsb_prefetcher_fetch_tag_req_ready[nsb_prefetcher_feature_bank_req[16-:5]];
		nsb_prefetcher_feature_bank_resp_valid = |nsb_prefetcher_fetch_tag_resp_valid;
		nsb_prefetcher_feature_bank_resp = nsb_prefetcher_fetch_tag_resp[0 + (fetch_tag_resp_arb_bin * 14)+:14];
	end
	always @(posedge core_clk or negedge resetn)
		if (!resetn) begin
			chosen_fetch_tag_adj_rm_req_bin_q <= 1'sb0;
			chosen_fetch_tag_msg_rm_req_bin_q <= 1'sb0;
		end
		else begin
			if (adj_rm_fetch_req_valid && adj_rm_fetch_req_ready)
				chosen_fetch_tag_adj_rm_req_bin_q <= chosen_fetch_tag_adj_rm_req_bin;
			if (msg_rm_fetch_req_valid && msg_rm_fetch_req_ready)
				chosen_fetch_tag_msg_rm_req_bin_q <= chosen_fetch_tag_msg_rm_req_bin;
		end
	always @(*) begin
		adj_rm_fetch_req_valid = |fetch_tag_adj_rm_req_valid;
		adj_rm_fetch_start_address = fetch_tag_adj_rm_start_address[chosen_fetch_tag_adj_rm_req_bin * AXI_ADDRESS_WIDTH+:AXI_ADDRESS_WIDTH];
		adj_rm_fetch_byte_count = fetch_tag_adj_rm_byte_count[chosen_fetch_tag_adj_rm_req_bin * 18+:18];
		adj_rm_fetch_resp_ready = fetch_tag_adj_rm_resp_ready[chosen_fetch_tag_adj_rm_req_bin_q];
	end
	always @(*) begin
		msg_rm_fetch_req_valid = |fetch_tag_msg_rm_req_valid;
		msg_rm_fetch_start_address = fetch_tag_msg_rm_start_address[chosen_fetch_tag_msg_rm_req_bin * AXI_ADDRESS_WIDTH+:AXI_ADDRESS_WIDTH];
		msg_rm_fetch_byte_count = fetch_tag_msg_rm_byte_count[chosen_fetch_tag_msg_rm_req_bin * 18+:18];
		msg_rm_fetch_resp_ready = fetch_tag_msg_rm_resp_ready[chosen_fetch_tag_msg_rm_req_bin_q];
	end
endmodule
module prefetcher_weight_bank (
	core_clk,
	resetn,
	nsb_prefetcher_weight_bank_req_valid,
	nsb_prefetcher_weight_bank_req_ready,
	nsb_prefetcher_weight_bank_req,
	nsb_prefetcher_weight_bank_resp_valid,
	nsb_prefetcher_weight_bank_resp,
	weight_bank_axi_rm_fetch_req_valid,
	weight_bank_axi_rm_fetch_req_ready,
	weight_bank_axi_rm_fetch_start_address,
	weight_bank_axi_rm_fetch_byte_count,
	weight_bank_axi_rm_fetch_resp_valid,
	weight_bank_axi_rm_fetch_resp_ready,
	weight_bank_axi_rm_fetch_resp_last,
	weight_bank_axi_rm_fetch_resp_data,
	weight_bank_axi_rm_fetch_resp_axi_id,
	weight_channel_req_valid,
	weight_channel_req_ready,
	weight_channel_req,
	weight_channel_resp_valid,
	weight_channel_resp_ready,
	weight_channel_resp,
	layer_config_weights_address_lsb_value
);
	parameter AXI_ADDRESS_WIDTH = 34;
	parameter AXI_DATA_WIDTH = 512;
	localparam top_pkg_MAX_FEATURE_COUNT = 1024;
	parameter MAX_FEATURE_COUNT = top_pkg_MAX_FEATURE_COUNT;
	input wire core_clk;
	input wire resetn;
	input wire nsb_prefetcher_weight_bank_req_valid;
	output reg nsb_prefetcher_weight_bank_req_ready;
	localparam top_pkg_AXI_ADDRESS_WIDTH = 34;
	localparam top_pkg_MAX_NEIGHBOURS = 1024;
	localparam top_pkg_MAX_NODESLOT_COUNT = 32;
	input wire [75:0] nsb_prefetcher_weight_bank_req;
	output reg nsb_prefetcher_weight_bank_resp_valid;
	localparam top_pkg_FETCH_TAG_COUNT = top_pkg_MAX_NODESLOT_COUNT;
	output reg [13:0] nsb_prefetcher_weight_bank_resp;
	output reg weight_bank_axi_rm_fetch_req_valid;
	input wire weight_bank_axi_rm_fetch_req_ready;
	output reg [AXI_ADDRESS_WIDTH - 1:0] weight_bank_axi_rm_fetch_start_address;
	localparam top_pkg_MAX_NODES = 1048576;
	localparam top_pkg_NODE_ID_WIDTH = 20;
	localparam top_pkg_MAX_REQUIRED_BYTES_ADJ_FETCH_REQ = 2560;
	localparam top_pkg_LARGE_FEATURE_COUNT = 1024;
	localparam top_pkg_LARGE_MSG_QUEUE_DEPTH = 64;
	localparam top_pkg_LARGE_PRECISION_BYTE_COUNT = 4;
	localparam top_pkg_MAX_REQUIRED_BYTES_MSG_FETCH_REQ = 262144;
	localparam top_pkg_MAX_FETCH_REQ_BYTE_COUNT = top_pkg_MAX_REQUIRED_BYTES_MSG_FETCH_REQ;
	output reg [17:0] weight_bank_axi_rm_fetch_byte_count;
	input wire weight_bank_axi_rm_fetch_resp_valid;
	output wire weight_bank_axi_rm_fetch_resp_ready;
	input wire weight_bank_axi_rm_fetch_resp_last;
	input wire [AXI_DATA_WIDTH - 1:0] weight_bank_axi_rm_fetch_resp_data;
	input wire [3:0] weight_bank_axi_rm_fetch_resp_axi_id;
	input wire weight_channel_req_valid;
	output wire weight_channel_req_ready;
	input wire [21:0] weight_channel_req;
	output reg weight_channel_resp_valid;
	input wire weight_channel_resp_ready;
	output reg [33792:0] weight_channel_resp;
	input wire [31:0] layer_config_weights_address_lsb_value;
	reg [75:0] nsb_prefetcher_weight_bank_req_q;
	wire [MAX_FEATURE_COUNT - 1:0] row_fifo_push;
	reg [31:0] row_fifo_in_data;
	wire [MAX_FEATURE_COUNT - 1:0] row_fifo_pop;
	wire [MAX_FEATURE_COUNT - 1:0] row_fifo_out_valid;
	wire [(MAX_FEATURE_COUNT * 32) - 1:0] row_fifo_out_data;
	wire [($clog2(MAX_FEATURE_COUNT) >= 0 ? (MAX_FEATURE_COUNT * ($clog2(MAX_FEATURE_COUNT) + 1)) - 1 : (MAX_FEATURE_COUNT * (1 - $clog2(MAX_FEATURE_COUNT))) + ($clog2(MAX_FEATURE_COUNT) - 1)):($clog2(MAX_FEATURE_COUNT) >= 0 ? 0 : $clog2(MAX_FEATURE_COUNT) + 0)] row_fifo_count;
	wire [MAX_FEATURE_COUNT - 1:0] row_fifo_empty;
	wire [MAX_FEATURE_COUNT - 1:0] row_fifo_full;
	reg [3:0] weight_bank_state;
	reg [3:0] weight_bank_state_n;
	reg [$clog2(MAX_FEATURE_COUNT):0] features_written;
	reg [$clog2(MAX_FEATURE_COUNT):0] rows_fetched;
	reg [$clog2(AXI_DATA_WIDTH / 32) - 1:0] feature_offset;
	reg [4:0] expected_responses;
	reg weight_bank_axi_rm_fetch_resp_last_q;
	reg [AXI_DATA_WIDTH - 1:0] weight_bank_axi_rm_fetch_resp_data_q;
	reg [3:0] weight_bank_axi_rm_fetch_resp_axi_id_q;
	reg [MAX_FEATURE_COUNT - 1:0] row_pop_shift;
	reg [$clog2(MAX_FEATURE_COUNT):0] row_counter;
	reg accepting_weight_channel_resp;
	genvar row;
	generate
		for (row = 0; row < MAX_FEATURE_COUNT; row = row + 1) begin : genblk1
			ultraram_fifo #(
				.WIDTH(32),
				.DEPTH(MAX_FEATURE_COUNT)
			) weight_matrix_row(
				.core_clk(core_clk),
				.resetn(resetn),
				.push(row_fifo_push[row]),
				.in_data(row_fifo_in_data),
				.pop(row_fifo_pop[row]),
				.out_valid(row_fifo_out_valid[row]),
				.out_data(row_fifo_out_data[row * 32+:32]),
				.count(row_fifo_count[($clog2(MAX_FEATURE_COUNT) >= 0 ? 0 : $clog2(MAX_FEATURE_COUNT)) + (row * ($clog2(MAX_FEATURE_COUNT) >= 0 ? $clog2(MAX_FEATURE_COUNT) + 1 : 1 - $clog2(MAX_FEATURE_COUNT)))+:($clog2(MAX_FEATURE_COUNT) >= 0 ? $clog2(MAX_FEATURE_COUNT) + 1 : 1 - $clog2(MAX_FEATURE_COUNT))]),
				.empty(row_fifo_empty[row]),
				.full(row_fifo_full[row])
			);
			assign row_fifo_push[row] = (weight_bank_state == 4'd3) & (row == (rows_fetched - 1));
			assign row_fifo_pop[row] = (((weight_bank_state == 4'd5) && row_pop_shift[row]) && !row_fifo_empty[row]) && accepting_weight_channel_resp;
		end
	endgenerate
	always @(posedge core_clk or negedge resetn)
		if (!resetn)
			weight_bank_state <= 4'd0;
		else
			weight_bank_state <= weight_bank_state_n;
	always @(*) begin
		weight_bank_state_n = weight_bank_state;
		case (weight_bank_state)
			4'd0: weight_bank_state_n = (nsb_prefetcher_weight_bank_req_valid && (nsb_prefetcher_weight_bank_req[75-:3] == 3'd0) ? 4'd1 : 4'd0);
			4'd1: weight_bank_state_n = (weight_bank_axi_rm_fetch_req_ready ? 4'd2 : 4'd1);
			4'd2: weight_bank_state_n = (weight_bank_axi_rm_fetch_resp_valid ? 4'd3 : 4'd2);
			4'd3: weight_bank_state_n = (((feature_offset == 4'd15) && (rows_fetched == nsb_prefetcher_weight_bank_req_q[27-:11])) && (expected_responses == {5 {1'sb0}}) ? 4'd4 : ((feature_offset == 4'd15) && (expected_responses == {5 {1'sb0}}) ? 4'd1 : (feature_offset == 4'd15 ? 4'd2 : 4'd3)));
			4'd4: weight_bank_state_n = (weight_channel_req_valid ? 4'd5 : 4'd4);
			4'd5: weight_bank_state_n = ((weight_channel_resp_valid && weight_channel_resp_ready) && weight_channel_resp[0] ? 4'd4 : 4'd5);
		endcase
	end
	always @(posedge core_clk or negedge resetn)
		if (!resetn)
			nsb_prefetcher_weight_bank_req_q <= 1'sb0;
		else if (nsb_prefetcher_weight_bank_req_valid && nsb_prefetcher_weight_bank_req_ready)
			nsb_prefetcher_weight_bank_req_q <= nsb_prefetcher_weight_bank_req;
	always @(*) begin
		nsb_prefetcher_weight_bank_req_ready = weight_bank_state == 4'd0;
		nsb_prefetcher_weight_bank_resp_valid = (weight_bank_state == 4'd3) && (weight_bank_state_n == 4'd4);
		nsb_prefetcher_weight_bank_resp[8-:3] = 3'd0;
		nsb_prefetcher_weight_bank_resp[13-:5] = 1'sb0;
		nsb_prefetcher_weight_bank_resp[0] = ~row_fifo_full;
	end
	reg [$clog2(MAX_FEATURE_COUNT * 4) - 1:0] bytes_per_row;
	reg [$clog2(MAX_FEATURE_COUNT * 4) - 1:0] bytes_per_row_padded;
	always @(*) begin
		weight_bank_axi_rm_fetch_req_valid = weight_bank_state == 4'd1;
		weight_bank_axi_rm_fetch_byte_count = nsb_prefetcher_weight_bank_req_q[38-:11] * 4;
		bytes_per_row = nsb_prefetcher_weight_bank_req_q[38-:11] * 4;
		bytes_per_row_padded = {bytes_per_row[$clog2(MAX_FEATURE_COUNT * 4) - 1:6], 6'b000000} + (|bytes_per_row[5:0] ? 'd64 : {$clog2(MAX_FEATURE_COUNT * 4) {1'sb0}});
		weight_bank_axi_rm_fetch_start_address = nsb_prefetcher_weight_bank_req_q[72-:34] + (rows_fetched * bytes_per_row_padded);
	end
	always @(posedge core_clk or negedge resetn)
		if (!resetn) begin
			rows_fetched <= 1'sb0;
			expected_responses <= 1'sb0;
			weight_bank_axi_rm_fetch_resp_last_q <= 1'sb0;
			weight_bank_axi_rm_fetch_resp_data_q <= 1'sb0;
			weight_bank_axi_rm_fetch_resp_axi_id_q <= 1'sb0;
		end
		else if (weight_bank_axi_rm_fetch_req_valid && weight_bank_axi_rm_fetch_req_ready) begin
			rows_fetched <= rows_fetched + 1'b1;
			expected_responses <= nsb_prefetcher_weight_bank_req_q[28 + $clog2(MAX_FEATURE_COUNT):32] + (|nsb_prefetcher_weight_bank_req_q[31:28] ? 1'b1 : 1'b0);
		end
		else if (weight_bank_axi_rm_fetch_resp_valid && weight_bank_axi_rm_fetch_resp_ready) begin
			expected_responses <= expected_responses - 1'b1;
			weight_bank_axi_rm_fetch_resp_last_q <= weight_bank_axi_rm_fetch_resp_last;
			weight_bank_axi_rm_fetch_resp_data_q <= weight_bank_axi_rm_fetch_resp_data;
			weight_bank_axi_rm_fetch_resp_axi_id_q <= weight_bank_axi_rm_fetch_resp_axi_id;
		end
	assign weight_bank_axi_rm_fetch_resp_ready = weight_bank_state == 4'd2;
	always @(*) row_fifo_in_data = (feature_offset == {$clog2(AXI_DATA_WIDTH / 32) {1'sb0}} ? weight_bank_axi_rm_fetch_resp_data_q[511:480] : (feature_offset == 1'b1 ? weight_bank_axi_rm_fetch_resp_data_q[479:448] : (feature_offset == 2'b10 ? weight_bank_axi_rm_fetch_resp_data_q[447:416] : (feature_offset == 2'b11 ? weight_bank_axi_rm_fetch_resp_data_q[415:384] : (feature_offset == 3'b100 ? weight_bank_axi_rm_fetch_resp_data_q[383:352] : (feature_offset == 3'b101 ? weight_bank_axi_rm_fetch_resp_data_q[351:320] : (feature_offset == 3'b110 ? weight_bank_axi_rm_fetch_resp_data_q[319:288] : (feature_offset == 3'b111 ? weight_bank_axi_rm_fetch_resp_data_q[287:256] : (feature_offset == 4'b1000 ? weight_bank_axi_rm_fetch_resp_data_q[255:224] : (feature_offset == 4'b1001 ? weight_bank_axi_rm_fetch_resp_data_q[223:192] : (feature_offset == 4'b1010 ? weight_bank_axi_rm_fetch_resp_data_q[191:160] : (feature_offset == 4'b1011 ? weight_bank_axi_rm_fetch_resp_data_q[159:128] : (feature_offset == 4'b1100 ? weight_bank_axi_rm_fetch_resp_data_q[127:96] : (feature_offset == 4'b1101 ? weight_bank_axi_rm_fetch_resp_data_q[95:64] : (feature_offset == 4'b1110 ? weight_bank_axi_rm_fetch_resp_data_q[63:32] : (feature_offset == 4'b1111 ? weight_bank_axi_rm_fetch_resp_data_q[31:0] : {32 {1'sb0}}))))))))))))))));
	always @(posedge core_clk or negedge resetn)
		if (!resetn) begin
			feature_offset <= 1'sb0;
			features_written <= 1'sb0;
		end
		else if (weight_bank_state == 4'd3) begin
			feature_offset <= (feature_offset == 4'd15 ? {$clog2(AXI_DATA_WIDTH / 32) {1'sb0}} : feature_offset + 1'b1);
			features_written <= features_written + 1'b1;
		end
	assign weight_channel_req_ready = weight_bank_state == 4'd4;
	generate
		for (row = 1; row < MAX_FEATURE_COUNT; row = row + 1) begin : genblk2
			always @(posedge core_clk or negedge resetn)
				if (!resetn)
					row_pop_shift[row] <= 1'sb0;
				else if ((weight_bank_state == 4'd4) && (weight_bank_state_n == 4'd5))
					row_pop_shift[row] <= 1'sb0;
				else if (weight_channel_resp_valid && weight_channel_resp_ready)
					row_pop_shift[row] <= row_pop_shift[row - 1];
		end
	endgenerate
	wire [$clog2(MAX_FEATURE_COUNT) - 1:0] required_pulses;
	assign required_pulses = {nsb_prefetcher_weight_bank_req_q[27 + $clog2(MAX_FEATURE_COUNT):32], 4'd0} + (|nsb_prefetcher_weight_bank_req_q[31:28] ? 'd16 : {$clog2(MAX_FEATURE_COUNT) {1'sb0}});
	always @(posedge core_clk or negedge resetn)
		if (!resetn) begin
			row_pop_shift[0] <= 1'sb0;
			row_counter <= 1'sb0;
		end
		else if ((weight_bank_state == 4'd4) && (weight_bank_state_n == 4'd5)) begin
			row_pop_shift[0] <= 1'sb1;
			row_counter <= 1'sb0;
		end
		else if (|row_fifo_pop) begin
			row_counter <= (row_counter == required_pulses ? row_counter : row_counter + 1'b1);
			row_pop_shift[0] <= !(row_counter >= (required_pulses - 1'b1));
		end
	always @(*) begin
		weight_channel_resp_valid = ((weight_bank_state == 4'd5) && &row_fifo_out_valid) && |row_pop_shift;
		weight_channel_resp[33792-:32768] = row_fifo_out_data;
		weight_channel_resp[1024-:1024] = row_pop_shift & ~row_fifo_empty;
		weight_channel_resp[0] = weight_channel_resp[1024-:1024] == {1024 {1'sb0}};
		accepting_weight_channel_resp = weight_channel_resp_valid && weight_channel_resp_ready;
	end
endmodule
module prefetcher (
	core_clk,
	resetn,
	nsb_prefetcher_req_valid,
	nsb_prefetcher_req_ready,
	nsb_prefetcher_req,
	nsb_prefetcher_resp_valid,
	nsb_prefetcher_resp,
	s_axi_awaddr,
	s_axi_awprot,
	s_axi_awvalid,
	s_axi_awready,
	s_axi_wdata,
	s_axi_wstrb,
	s_axi_wvalid,
	s_axi_wready,
	s_axi_araddr,
	s_axi_arprot,
	s_axi_arvalid,
	s_axi_arready,
	s_axi_rdata,
	s_axi_rresp,
	s_axi_rvalid,
	s_axi_rready,
	s_axi_bresp,
	s_axi_bvalid,
	s_axi_bready,
	prefetcher_adj_rm_axi_interconnect_axi_araddr,
	prefetcher_adj_rm_axi_interconnect_axi_arburst,
	prefetcher_adj_rm_axi_interconnect_axi_arcache,
	prefetcher_adj_rm_axi_interconnect_axi_arid,
	prefetcher_adj_rm_axi_interconnect_axi_arlen,
	prefetcher_adj_rm_axi_interconnect_axi_arlock,
	prefetcher_adj_rm_axi_interconnect_axi_arprot,
	prefetcher_adj_rm_axi_interconnect_axi_arqos,
	prefetcher_adj_rm_axi_interconnect_axi_arsize,
	prefetcher_adj_rm_axi_interconnect_axi_arvalid,
	prefetcher_adj_rm_axi_interconnect_axi_arready,
	prefetcher_adj_rm_axi_interconnect_axi_awaddr,
	prefetcher_adj_rm_axi_interconnect_axi_awburst,
	prefetcher_adj_rm_axi_interconnect_axi_awcache,
	prefetcher_adj_rm_axi_interconnect_axi_awid,
	prefetcher_adj_rm_axi_interconnect_axi_awlen,
	prefetcher_adj_rm_axi_interconnect_axi_awlock,
	prefetcher_adj_rm_axi_interconnect_axi_awprot,
	prefetcher_adj_rm_axi_interconnect_axi_awqos,
	prefetcher_adj_rm_axi_interconnect_axi_awready,
	prefetcher_adj_rm_axi_interconnect_axi_awsize,
	prefetcher_adj_rm_axi_interconnect_axi_awvalid,
	prefetcher_adj_rm_axi_interconnect_axi_bid,
	prefetcher_adj_rm_axi_interconnect_axi_bready,
	prefetcher_adj_rm_axi_interconnect_axi_bresp,
	prefetcher_adj_rm_axi_interconnect_axi_bvalid,
	prefetcher_adj_rm_axi_interconnect_axi_rdata,
	prefetcher_adj_rm_axi_interconnect_axi_rid,
	prefetcher_adj_rm_axi_interconnect_axi_rlast,
	prefetcher_adj_rm_axi_interconnect_axi_rready,
	prefetcher_adj_rm_axi_interconnect_axi_rresp,
	prefetcher_adj_rm_axi_interconnect_axi_rvalid,
	prefetcher_adj_rm_axi_interconnect_axi_wdata,
	prefetcher_adj_rm_axi_interconnect_axi_wlast,
	prefetcher_adj_rm_axi_interconnect_axi_wready,
	prefetcher_adj_rm_axi_interconnect_axi_wstrb,
	prefetcher_adj_rm_axi_interconnect_axi_wvalid,
	prefetcher_msg_rm_axi_interconnect_axi_araddr,
	prefetcher_msg_rm_axi_interconnect_axi_arburst,
	prefetcher_msg_rm_axi_interconnect_axi_arcache,
	prefetcher_msg_rm_axi_interconnect_axi_arid,
	prefetcher_msg_rm_axi_interconnect_axi_arlen,
	prefetcher_msg_rm_axi_interconnect_axi_arlock,
	prefetcher_msg_rm_axi_interconnect_axi_arprot,
	prefetcher_msg_rm_axi_interconnect_axi_arqos,
	prefetcher_msg_rm_axi_interconnect_axi_arsize,
	prefetcher_msg_rm_axi_interconnect_axi_arvalid,
	prefetcher_msg_rm_axi_interconnect_axi_arready,
	prefetcher_msg_rm_axi_interconnect_axi_awaddr,
	prefetcher_msg_rm_axi_interconnect_axi_awburst,
	prefetcher_msg_rm_axi_interconnect_axi_awcache,
	prefetcher_msg_rm_axi_interconnect_axi_awid,
	prefetcher_msg_rm_axi_interconnect_axi_awlen,
	prefetcher_msg_rm_axi_interconnect_axi_awlock,
	prefetcher_msg_rm_axi_interconnect_axi_awprot,
	prefetcher_msg_rm_axi_interconnect_axi_awqos,
	prefetcher_msg_rm_axi_interconnect_axi_awready,
	prefetcher_msg_rm_axi_interconnect_axi_awsize,
	prefetcher_msg_rm_axi_interconnect_axi_awvalid,
	prefetcher_msg_rm_axi_interconnect_axi_bid,
	prefetcher_msg_rm_axi_interconnect_axi_bready,
	prefetcher_msg_rm_axi_interconnect_axi_bresp,
	prefetcher_msg_rm_axi_interconnect_axi_bvalid,
	prefetcher_msg_rm_axi_interconnect_axi_rdata,
	prefetcher_msg_rm_axi_interconnect_axi_rid,
	prefetcher_msg_rm_axi_interconnect_axi_rlast,
	prefetcher_msg_rm_axi_interconnect_axi_rready,
	prefetcher_msg_rm_axi_interconnect_axi_rresp,
	prefetcher_msg_rm_axi_interconnect_axi_rvalid,
	prefetcher_msg_rm_axi_interconnect_axi_wdata,
	prefetcher_msg_rm_axi_interconnect_axi_wlast,
	prefetcher_msg_rm_axi_interconnect_axi_wready,
	prefetcher_msg_rm_axi_interconnect_axi_wstrb,
	prefetcher_msg_rm_axi_interconnect_axi_wvalid,
	prefetcher_weight_bank_rm_axi_interconnect_axi_araddr,
	prefetcher_weight_bank_rm_axi_interconnect_axi_arburst,
	prefetcher_weight_bank_rm_axi_interconnect_axi_arcache,
	prefetcher_weight_bank_rm_axi_interconnect_axi_arid,
	prefetcher_weight_bank_rm_axi_interconnect_axi_arlen,
	prefetcher_weight_bank_rm_axi_interconnect_axi_arlock,
	prefetcher_weight_bank_rm_axi_interconnect_axi_arprot,
	prefetcher_weight_bank_rm_axi_interconnect_axi_arqos,
	prefetcher_weight_bank_rm_axi_interconnect_axi_arsize,
	prefetcher_weight_bank_rm_axi_interconnect_axi_arvalid,
	prefetcher_weight_bank_rm_axi_interconnect_axi_arready,
	prefetcher_weight_bank_rm_axi_interconnect_axi_awaddr,
	prefetcher_weight_bank_rm_axi_interconnect_axi_awburst,
	prefetcher_weight_bank_rm_axi_interconnect_axi_awcache,
	prefetcher_weight_bank_rm_axi_interconnect_axi_awid,
	prefetcher_weight_bank_rm_axi_interconnect_axi_awlen,
	prefetcher_weight_bank_rm_axi_interconnect_axi_awlock,
	prefetcher_weight_bank_rm_axi_interconnect_axi_awprot,
	prefetcher_weight_bank_rm_axi_interconnect_axi_awqos,
	prefetcher_weight_bank_rm_axi_interconnect_axi_awready,
	prefetcher_weight_bank_rm_axi_interconnect_axi_awsize,
	prefetcher_weight_bank_rm_axi_interconnect_axi_awvalid,
	prefetcher_weight_bank_rm_axi_interconnect_axi_bid,
	prefetcher_weight_bank_rm_axi_interconnect_axi_bready,
	prefetcher_weight_bank_rm_axi_interconnect_axi_bresp,
	prefetcher_weight_bank_rm_axi_interconnect_axi_bvalid,
	prefetcher_weight_bank_rm_axi_interconnect_axi_rdata,
	prefetcher_weight_bank_rm_axi_interconnect_axi_rid,
	prefetcher_weight_bank_rm_axi_interconnect_axi_rlast,
	prefetcher_weight_bank_rm_axi_interconnect_axi_rready,
	prefetcher_weight_bank_rm_axi_interconnect_axi_rresp,
	prefetcher_weight_bank_rm_axi_interconnect_axi_rvalid,
	prefetcher_weight_bank_rm_axi_interconnect_axi_wdata,
	prefetcher_weight_bank_rm_axi_interconnect_axi_wlast,
	prefetcher_weight_bank_rm_axi_interconnect_axi_wready,
	prefetcher_weight_bank_rm_axi_interconnect_axi_wstrb,
	prefetcher_weight_bank_rm_axi_interconnect_axi_wvalid,
	message_channel_req_valid,
	message_channel_req_ready,
	message_channel_req,
	message_channel_resp_valid,
	message_channel_resp_ready,
	message_channel_resp,
	weight_channel_req_valid,
	weight_channel_req_ready,
	weight_channel_req,
	weight_channel_resp_valid,
	weight_channel_resp_ready,
	weight_channel_resp,
	scale_factor_queue_pop,
	scale_factor_queue_out_data,
	scale_factor_queue_count,
	scale_factor_queue_empty,
	scale_factor_queue_full
);
	parameter FETCH_TAG_COUNT = 1;
	input wire core_clk;
	input wire resetn;
	input wire nsb_prefetcher_req_valid;
	output reg nsb_prefetcher_req_ready;
	localparam top_pkg_AXI_ADDRESS_WIDTH = 34;
	localparam top_pkg_MAX_FEATURE_COUNT = 1024;
	localparam top_pkg_MAX_NEIGHBOURS = 1024;
	localparam top_pkg_MAX_NODESLOT_COUNT = 32;
	input wire [75:0] nsb_prefetcher_req;
	output reg nsb_prefetcher_resp_valid;
	localparam top_pkg_FETCH_TAG_COUNT = top_pkg_MAX_NODESLOT_COUNT;
	output reg [13:0] nsb_prefetcher_resp;
	localparam top_pkg_AXIL_ADDR_WIDTH = 32;
	input wire [31:0] s_axi_awaddr;
	input wire [2:0] s_axi_awprot;
	input wire s_axi_awvalid;
	output wire s_axi_awready;
	input wire [31:0] s_axi_wdata;
	input wire [3:0] s_axi_wstrb;
	input wire s_axi_wvalid;
	output wire s_axi_wready;
	input wire [31:0] s_axi_araddr;
	input wire [2:0] s_axi_arprot;
	input wire s_axi_arvalid;
	output wire s_axi_arready;
	output wire [31:0] s_axi_rdata;
	output wire [1:0] s_axi_rresp;
	output wire s_axi_rvalid;
	input wire s_axi_rready;
	output wire [1:0] s_axi_bresp;
	output wire s_axi_bvalid;
	input wire s_axi_bready;
	output wire [33:0] prefetcher_adj_rm_axi_interconnect_axi_araddr;
	output wire [1:0] prefetcher_adj_rm_axi_interconnect_axi_arburst;
	output wire [3:0] prefetcher_adj_rm_axi_interconnect_axi_arcache;
	output wire [3:0] prefetcher_adj_rm_axi_interconnect_axi_arid;
	output wire [7:0] prefetcher_adj_rm_axi_interconnect_axi_arlen;
	output wire [0:0] prefetcher_adj_rm_axi_interconnect_axi_arlock;
	output wire [2:0] prefetcher_adj_rm_axi_interconnect_axi_arprot;
	output wire [3:0] prefetcher_adj_rm_axi_interconnect_axi_arqos;
	output wire [2:0] prefetcher_adj_rm_axi_interconnect_axi_arsize;
	output wire prefetcher_adj_rm_axi_interconnect_axi_arvalid;
	input wire prefetcher_adj_rm_axi_interconnect_axi_arready;
	output reg [33:0] prefetcher_adj_rm_axi_interconnect_axi_awaddr;
	output reg [1:0] prefetcher_adj_rm_axi_interconnect_axi_awburst;
	output reg [3:0] prefetcher_adj_rm_axi_interconnect_axi_awcache;
	output reg [3:0] prefetcher_adj_rm_axi_interconnect_axi_awid;
	output reg [7:0] prefetcher_adj_rm_axi_interconnect_axi_awlen;
	output reg [0:0] prefetcher_adj_rm_axi_interconnect_axi_awlock;
	output reg [2:0] prefetcher_adj_rm_axi_interconnect_axi_awprot;
	output reg [3:0] prefetcher_adj_rm_axi_interconnect_axi_awqos;
	input wire prefetcher_adj_rm_axi_interconnect_axi_awready;
	output reg [2:0] prefetcher_adj_rm_axi_interconnect_axi_awsize;
	output reg prefetcher_adj_rm_axi_interconnect_axi_awvalid;
	input wire [3:0] prefetcher_adj_rm_axi_interconnect_axi_bid;
	output reg prefetcher_adj_rm_axi_interconnect_axi_bready;
	input wire [1:0] prefetcher_adj_rm_axi_interconnect_axi_bresp;
	input wire prefetcher_adj_rm_axi_interconnect_axi_bvalid;
	input wire [511:0] prefetcher_adj_rm_axi_interconnect_axi_rdata;
	input wire [3:0] prefetcher_adj_rm_axi_interconnect_axi_rid;
	input wire prefetcher_adj_rm_axi_interconnect_axi_rlast;
	output wire prefetcher_adj_rm_axi_interconnect_axi_rready;
	input wire [1:0] prefetcher_adj_rm_axi_interconnect_axi_rresp;
	input wire prefetcher_adj_rm_axi_interconnect_axi_rvalid;
	output reg [511:0] prefetcher_adj_rm_axi_interconnect_axi_wdata;
	output reg prefetcher_adj_rm_axi_interconnect_axi_wlast;
	input wire prefetcher_adj_rm_axi_interconnect_axi_wready;
	output reg [63:0] prefetcher_adj_rm_axi_interconnect_axi_wstrb;
	output reg prefetcher_adj_rm_axi_interconnect_axi_wvalid;
	output wire [33:0] prefetcher_msg_rm_axi_interconnect_axi_araddr;
	output wire [1:0] prefetcher_msg_rm_axi_interconnect_axi_arburst;
	output wire [3:0] prefetcher_msg_rm_axi_interconnect_axi_arcache;
	output wire [3:0] prefetcher_msg_rm_axi_interconnect_axi_arid;
	output wire [7:0] prefetcher_msg_rm_axi_interconnect_axi_arlen;
	output wire [0:0] prefetcher_msg_rm_axi_interconnect_axi_arlock;
	output wire [2:0] prefetcher_msg_rm_axi_interconnect_axi_arprot;
	output wire [3:0] prefetcher_msg_rm_axi_interconnect_axi_arqos;
	output wire [2:0] prefetcher_msg_rm_axi_interconnect_axi_arsize;
	output wire prefetcher_msg_rm_axi_interconnect_axi_arvalid;
	input wire prefetcher_msg_rm_axi_interconnect_axi_arready;
	output reg [33:0] prefetcher_msg_rm_axi_interconnect_axi_awaddr;
	output reg [1:0] prefetcher_msg_rm_axi_interconnect_axi_awburst;
	output reg [3:0] prefetcher_msg_rm_axi_interconnect_axi_awcache;
	output reg [3:0] prefetcher_msg_rm_axi_interconnect_axi_awid;
	output reg [7:0] prefetcher_msg_rm_axi_interconnect_axi_awlen;
	output reg [0:0] prefetcher_msg_rm_axi_interconnect_axi_awlock;
	output reg [2:0] prefetcher_msg_rm_axi_interconnect_axi_awprot;
	output reg [3:0] prefetcher_msg_rm_axi_interconnect_axi_awqos;
	input wire prefetcher_msg_rm_axi_interconnect_axi_awready;
	output reg [2:0] prefetcher_msg_rm_axi_interconnect_axi_awsize;
	output reg prefetcher_msg_rm_axi_interconnect_axi_awvalid;
	input wire [3:0] prefetcher_msg_rm_axi_interconnect_axi_bid;
	output reg prefetcher_msg_rm_axi_interconnect_axi_bready;
	input wire [1:0] prefetcher_msg_rm_axi_interconnect_axi_bresp;
	input wire prefetcher_msg_rm_axi_interconnect_axi_bvalid;
	input wire [511:0] prefetcher_msg_rm_axi_interconnect_axi_rdata;
	input wire [3:0] prefetcher_msg_rm_axi_interconnect_axi_rid;
	input wire prefetcher_msg_rm_axi_interconnect_axi_rlast;
	output wire prefetcher_msg_rm_axi_interconnect_axi_rready;
	input wire [1:0] prefetcher_msg_rm_axi_interconnect_axi_rresp;
	input wire prefetcher_msg_rm_axi_interconnect_axi_rvalid;
	output reg [511:0] prefetcher_msg_rm_axi_interconnect_axi_wdata;
	output reg prefetcher_msg_rm_axi_interconnect_axi_wlast;
	input wire prefetcher_msg_rm_axi_interconnect_axi_wready;
	output reg [63:0] prefetcher_msg_rm_axi_interconnect_axi_wstrb;
	output reg prefetcher_msg_rm_axi_interconnect_axi_wvalid;
	output wire [33:0] prefetcher_weight_bank_rm_axi_interconnect_axi_araddr;
	output wire [1:0] prefetcher_weight_bank_rm_axi_interconnect_axi_arburst;
	output wire [3:0] prefetcher_weight_bank_rm_axi_interconnect_axi_arcache;
	output wire [3:0] prefetcher_weight_bank_rm_axi_interconnect_axi_arid;
	output wire [7:0] prefetcher_weight_bank_rm_axi_interconnect_axi_arlen;
	output wire [0:0] prefetcher_weight_bank_rm_axi_interconnect_axi_arlock;
	output wire [2:0] prefetcher_weight_bank_rm_axi_interconnect_axi_arprot;
	output wire [3:0] prefetcher_weight_bank_rm_axi_interconnect_axi_arqos;
	output wire [2:0] prefetcher_weight_bank_rm_axi_interconnect_axi_arsize;
	output wire prefetcher_weight_bank_rm_axi_interconnect_axi_arvalid;
	input wire prefetcher_weight_bank_rm_axi_interconnect_axi_arready;
	output reg [33:0] prefetcher_weight_bank_rm_axi_interconnect_axi_awaddr;
	output reg [1:0] prefetcher_weight_bank_rm_axi_interconnect_axi_awburst;
	output reg [3:0] prefetcher_weight_bank_rm_axi_interconnect_axi_awcache;
	output reg [3:0] prefetcher_weight_bank_rm_axi_interconnect_axi_awid;
	output reg [7:0] prefetcher_weight_bank_rm_axi_interconnect_axi_awlen;
	output reg [0:0] prefetcher_weight_bank_rm_axi_interconnect_axi_awlock;
	output reg [2:0] prefetcher_weight_bank_rm_axi_interconnect_axi_awprot;
	output reg [3:0] prefetcher_weight_bank_rm_axi_interconnect_axi_awqos;
	input wire prefetcher_weight_bank_rm_axi_interconnect_axi_awready;
	output reg [2:0] prefetcher_weight_bank_rm_axi_interconnect_axi_awsize;
	output reg prefetcher_weight_bank_rm_axi_interconnect_axi_awvalid;
	input wire [3:0] prefetcher_weight_bank_rm_axi_interconnect_axi_bid;
	output reg prefetcher_weight_bank_rm_axi_interconnect_axi_bready;
	input wire [1:0] prefetcher_weight_bank_rm_axi_interconnect_axi_bresp;
	input wire prefetcher_weight_bank_rm_axi_interconnect_axi_bvalid;
	input wire [511:0] prefetcher_weight_bank_rm_axi_interconnect_axi_rdata;
	input wire [3:0] prefetcher_weight_bank_rm_axi_interconnect_axi_rid;
	input wire prefetcher_weight_bank_rm_axi_interconnect_axi_rlast;
	output wire prefetcher_weight_bank_rm_axi_interconnect_axi_rready;
	input wire [1:0] prefetcher_weight_bank_rm_axi_interconnect_axi_rresp;
	input wire prefetcher_weight_bank_rm_axi_interconnect_axi_rvalid;
	output reg [511:0] prefetcher_weight_bank_rm_axi_interconnect_axi_wdata;
	output reg prefetcher_weight_bank_rm_axi_interconnect_axi_wlast;
	input wire prefetcher_weight_bank_rm_axi_interconnect_axi_wready;
	output reg [63:0] prefetcher_weight_bank_rm_axi_interconnect_axi_wstrb;
	output reg prefetcher_weight_bank_rm_axi_interconnect_axi_wvalid;
	localparam top_pkg_MESSAGE_CHANNEL_COUNT = top_pkg_MAX_NODESLOT_COUNT;
	input wire [31:0] message_channel_req_valid;
	output wire [31:0] message_channel_req_ready;
	input wire [319:0] message_channel_req;
	output wire [31:0] message_channel_resp_valid;
	input wire [31:0] message_channel_resp_ready;
	localparam top_pkg_AXI_DATA_WIDTH = 512;
	output wire [16447:0] message_channel_resp;
	input wire weight_channel_req_valid;
	output wire weight_channel_req_ready;
	input wire [21:0] weight_channel_req;
	output wire weight_channel_resp_valid;
	input wire weight_channel_resp_ready;
	output wire [33792:0] weight_channel_resp;
	input wire [FETCH_TAG_COUNT - 1:0] scale_factor_queue_pop;
	localparam top_pkg_SCALE_FACTOR_QUEUE_READ_WIDTH = 32;
	output wire [(FETCH_TAG_COUNT * 32) - 1:0] scale_factor_queue_out_data;
	localparam top_pkg_SCALE_FACTOR_QUEUE_READ_DEPTH = 1024;
	output wire [(FETCH_TAG_COUNT * 11) - 1:0] scale_factor_queue_count;
	output wire [FETCH_TAG_COUNT - 1:0] scale_factor_queue_empty;
	output wire [FETCH_TAG_COUNT - 1:0] scale_factor_queue_full;
	wire layer_config_in_features_strobe;
	wire [9:0] layer_config_in_features_count;
	wire layer_config_out_features_strobe;
	wire [9:0] layer_config_out_features_count;
	wire layer_config_in_messages_address_lsb_strobe;
	wire [31:0] layer_config_in_messages_address_lsb_value;
	wire layer_config_in_messages_address_msb_strobe;
	wire [1:0] layer_config_in_messages_address_msb_value;
	wire layer_config_adjacency_list_address_lsb_strobe;
	wire [31:0] layer_config_adjacency_list_address_lsb_value;
	wire layer_config_adjacency_list_address_msb_strobe;
	wire [1:0] layer_config_adjacency_list_address_msb_value;
	wire layer_config_weights_address_lsb_strobe;
	wire [31:0] layer_config_weights_address_lsb_value;
	wire layer_config_weights_address_msb_strobe;
	wire [1:0] layer_config_weights_address_msb_value;
	wire layer_config_scale_factors_address_lsb_strobe;
	wire [31:0] layer_config_scale_factors_address_lsb_value;
	wire layer_config_scale_factors_address_msb_strobe;
	wire [1:0] layer_config_scale_factors_address_msb_value;
	reg nsb_prefetcher_feature_bank_req_valid;
	wire nsb_prefetcher_feature_bank_req_ready;
	wire nsb_prefetcher_feature_bank_resp_valid;
	wire [13:0] nsb_prefetcher_feature_bank_resp;
	wire adj_rm_fetch_req_valid;
	wire adj_rm_fetch_req_ready;
	wire [33:0] adj_rm_fetch_start_address;
	localparam top_pkg_MAX_NODES = 1048576;
	localparam top_pkg_NODE_ID_WIDTH = 20;
	localparam top_pkg_MAX_REQUIRED_BYTES_ADJ_FETCH_REQ = 2560;
	localparam top_pkg_LARGE_FEATURE_COUNT = 1024;
	localparam top_pkg_LARGE_MSG_QUEUE_DEPTH = 64;
	localparam top_pkg_LARGE_PRECISION_BYTE_COUNT = 4;
	localparam top_pkg_MAX_REQUIRED_BYTES_MSG_FETCH_REQ = 262144;
	localparam top_pkg_MAX_FETCH_REQ_BYTE_COUNT = top_pkg_MAX_REQUIRED_BYTES_MSG_FETCH_REQ;
	wire [17:0] adj_rm_fetch_byte_count;
	wire adj_rm_fetch_resp_valid;
	wire adj_rm_fetch_resp_ready;
	wire adj_rm_fetch_resp_last;
	wire [511:0] adj_rm_fetch_resp_data;
	wire [3:0] adj_rm_fetch_resp_axi_id;
	wire msg_rm_fetch_req_valid;
	wire msg_rm_fetch_req_ready;
	wire [33:0] msg_rm_fetch_start_address;
	wire [17:0] msg_rm_fetch_byte_count;
	wire msg_rm_fetch_resp_valid;
	wire msg_rm_fetch_resp_ready;
	wire msg_rm_fetch_resp_last;
	wire [511:0] msg_rm_fetch_resp_data;
	wire [3:0] msg_rm_fetch_resp_axi_id;
	reg nsb_prefetcher_weight_bank_req_valid;
	wire nsb_prefetcher_weight_bank_req_ready;
	wire nsb_prefetcher_weight_bank_resp_valid;
	wire [13:0] nsb_prefetcher_weight_bank_resp;
	wire weight_bank_axi_rm_fetch_req_valid;
	wire weight_bank_axi_rm_fetch_req_ready;
	wire [33:0] weight_bank_axi_rm_fetch_start_address;
	wire [17:0] weight_bank_axi_rm_fetch_byte_count;
	wire weight_bank_axi_rm_fetch_resp_valid;
	wire weight_bank_axi_rm_fetch_resp_ready;
	wire weight_bank_axi_rm_fetch_resp_last;
	wire [511:0] weight_bank_axi_rm_fetch_resp_data;
	wire [3:0] weight_bank_axi_rm_fetch_resp_axi_id;
	prefetcher_regbank_regs prefetcher_regbank_i(
		.axi_aclk(core_clk),
		.axi_aresetn(resetn),
		.s_axi_awaddr(s_axi_awaddr),
		.s_axi_awprot(s_axi_awprot),
		.s_axi_awvalid(s_axi_awvalid),
		.s_axi_awready(s_axi_awready),
		.s_axi_wdata(s_axi_wdata),
		.s_axi_wstrb(s_axi_wstrb),
		.s_axi_wvalid(s_axi_wvalid),
		.s_axi_wready(s_axi_wready),
		.s_axi_araddr(s_axi_araddr),
		.s_axi_arprot(s_axi_arprot),
		.s_axi_arvalid(s_axi_arvalid),
		.s_axi_arready(s_axi_arready),
		.s_axi_rdata(s_axi_rdata),
		.s_axi_rresp(s_axi_rresp),
		.s_axi_rvalid(s_axi_rvalid),
		.s_axi_rready(s_axi_rready),
		.s_axi_bresp(s_axi_bresp),
		.s_axi_bvalid(s_axi_bvalid),
		.s_axi_bready(s_axi_bready),
		.layer_config_in_features_strobe(layer_config_in_features_strobe),
		.layer_config_in_features_count(layer_config_in_features_count),
		.layer_config_out_features_strobe(layer_config_out_features_strobe),
		.layer_config_out_features_count(layer_config_out_features_count),
		.layer_config_adjacency_list_address_lsb_strobe(layer_config_adjacency_list_address_lsb_strobe),
		.layer_config_adjacency_list_address_lsb_value(layer_config_adjacency_list_address_lsb_value),
		.layer_config_adjacency_list_address_msb_strobe(layer_config_adjacency_list_address_msb_strobe),
		.layer_config_adjacency_list_address_msb_value(layer_config_adjacency_list_address_msb_value),
		.layer_config_weights_address_lsb_strobe(layer_config_weights_address_lsb_strobe),
		.layer_config_weights_address_lsb_value(layer_config_weights_address_lsb_value),
		.layer_config_weights_address_msb_strobe(layer_config_weights_address_msb_strobe),
		.layer_config_weights_address_msb_value(layer_config_weights_address_msb_value),
		.layer_config_in_messages_address_lsb_strobe(layer_config_in_messages_address_lsb_strobe),
		.layer_config_in_messages_address_lsb_value(layer_config_in_messages_address_lsb_value),
		.layer_config_in_messages_address_msb_strobe(layer_config_in_messages_address_msb_strobe),
		.layer_config_in_messages_address_msb_value(layer_config_in_messages_address_msb_value),
		.layer_config_scale_factors_address_lsb_strobe(layer_config_scale_factors_address_lsb_strobe),
		.layer_config_scale_factors_address_lsb_value(layer_config_scale_factors_address_lsb_value),
		.layer_config_scale_factors_address_msb_strobe(layer_config_scale_factors_address_msb_strobe),
		.layer_config_scale_factors_address_msb_value(layer_config_scale_factors_address_msb_value)
	);
	prefetcher_feature_bank #(.FETCH_TAG_COUNT(FETCH_TAG_COUNT)) feature_bank_i(
		.core_clk(core_clk),
		.resetn(resetn),
		.nsb_prefetcher_feature_bank_req_valid(nsb_prefetcher_feature_bank_req_valid),
		.nsb_prefetcher_feature_bank_req_ready(nsb_prefetcher_feature_bank_req_ready),
		.nsb_prefetcher_feature_bank_req(nsb_prefetcher_req),
		.nsb_prefetcher_feature_bank_resp_valid(nsb_prefetcher_feature_bank_resp_valid),
		.nsb_prefetcher_feature_bank_resp(nsb_prefetcher_feature_bank_resp),
		.adj_rm_fetch_req_valid(adj_rm_fetch_req_valid),
		.adj_rm_fetch_req_ready(adj_rm_fetch_req_ready),
		.adj_rm_fetch_start_address(adj_rm_fetch_start_address),
		.adj_rm_fetch_byte_count(adj_rm_fetch_byte_count),
		.adj_rm_fetch_resp_valid(adj_rm_fetch_resp_valid),
		.adj_rm_fetch_resp_ready(adj_rm_fetch_resp_ready),
		.adj_rm_fetch_resp_last(adj_rm_fetch_resp_last),
		.adj_rm_fetch_resp_data(adj_rm_fetch_resp_data),
		.adj_rm_fetch_resp_axi_id(adj_rm_fetch_resp_axi_id),
		.msg_rm_fetch_req_valid(msg_rm_fetch_req_valid),
		.msg_rm_fetch_req_ready(msg_rm_fetch_req_ready),
		.msg_rm_fetch_start_address(msg_rm_fetch_start_address),
		.msg_rm_fetch_byte_count(msg_rm_fetch_byte_count),
		.msg_rm_fetch_resp_valid(msg_rm_fetch_resp_valid),
		.msg_rm_fetch_resp_ready(msg_rm_fetch_resp_ready),
		.msg_rm_fetch_resp_last(msg_rm_fetch_resp_last),
		.msg_rm_fetch_resp_data(msg_rm_fetch_resp_data),
		.msg_rm_fetch_resp_axi_id(msg_rm_fetch_resp_axi_id),
		.message_channel_req_valid(message_channel_req_valid),
		.message_channel_req_ready(message_channel_req_ready),
		.message_channel_req(message_channel_req),
		.message_channel_resp_valid(message_channel_resp_valid),
		.message_channel_resp_ready(message_channel_resp_ready),
		.message_channel_resp(message_channel_resp),
		.scale_factor_queue_pop(scale_factor_queue_pop),
		.scale_factor_queue_out_data(scale_factor_queue_out_data),
		.scale_factor_queue_count(scale_factor_queue_count),
		.scale_factor_queue_empty(scale_factor_queue_empty),
		.scale_factor_queue_full(scale_factor_queue_full),
		.layer_config_in_features_count(layer_config_in_features_count),
		.layer_config_adjacency_list_address_lsb_value(layer_config_adjacency_list_address_lsb_value),
		.layer_config_in_messages_address_lsb_value(layer_config_in_messages_address_lsb_value),
		.layer_config_scale_factors_address_lsb_value(layer_config_scale_factors_address_lsb_value),
		.layer_config_scale_factors_address_msb_value(layer_config_scale_factors_address_msb_value)
	);
	prefetcher_weight_bank #(
		.AXI_ADDRESS_WIDTH(34),
		.AXI_DATA_WIDTH(512),
		.MAX_FEATURE_COUNT(top_pkg_MAX_FEATURE_COUNT)
	) weight_bank_i(
		.core_clk(core_clk),
		.resetn(resetn),
		.nsb_prefetcher_weight_bank_req_valid(nsb_prefetcher_weight_bank_req_valid),
		.nsb_prefetcher_weight_bank_req_ready(nsb_prefetcher_weight_bank_req_ready),
		.nsb_prefetcher_weight_bank_req(nsb_prefetcher_req),
		.nsb_prefetcher_weight_bank_resp_valid(nsb_prefetcher_weight_bank_resp_valid),
		.nsb_prefetcher_weight_bank_resp(nsb_prefetcher_weight_bank_resp),
		.weight_bank_axi_rm_fetch_req_valid(weight_bank_axi_rm_fetch_req_valid),
		.weight_bank_axi_rm_fetch_req_ready(weight_bank_axi_rm_fetch_req_ready),
		.weight_bank_axi_rm_fetch_start_address(weight_bank_axi_rm_fetch_start_address),
		.weight_bank_axi_rm_fetch_byte_count(weight_bank_axi_rm_fetch_byte_count),
		.weight_bank_axi_rm_fetch_resp_valid(weight_bank_axi_rm_fetch_resp_valid),
		.weight_bank_axi_rm_fetch_resp_ready(weight_bank_axi_rm_fetch_resp_ready),
		.weight_bank_axi_rm_fetch_resp_last(weight_bank_axi_rm_fetch_resp_last),
		.weight_bank_axi_rm_fetch_resp_data(weight_bank_axi_rm_fetch_resp_data),
		.weight_bank_axi_rm_fetch_resp_axi_id(weight_bank_axi_rm_fetch_resp_axi_id),
		.weight_channel_req_valid(weight_channel_req_valid),
		.weight_channel_req_ready(weight_channel_req_ready),
		.weight_channel_req(weight_channel_req),
		.weight_channel_resp_valid(weight_channel_resp_valid),
		.weight_channel_resp_ready(weight_channel_resp_ready),
		.weight_channel_resp(weight_channel_resp),
		.layer_config_weights_address_lsb_value(layer_config_weights_address_lsb_value)
	);
	axi_read_master #(
		.MAX_BYTE_COUNT(top_pkg_MAX_FETCH_REQ_BYTE_COUNT),
		.DATA_WIDTH(top_pkg_AXI_DATA_WIDTH)
	) adj_read_master(
		.core_clk(core_clk),
		.resetn(resetn),
		.fetch_req_valid(adj_rm_fetch_req_valid),
		.fetch_req_ready(adj_rm_fetch_req_ready),
		.fetch_start_address(adj_rm_fetch_start_address),
		.fetch_byte_count(adj_rm_fetch_byte_count),
		.fetch_resp_valid(adj_rm_fetch_resp_valid),
		.fetch_resp_ready(adj_rm_fetch_resp_ready),
		.fetch_resp_last(adj_rm_fetch_resp_last),
		.fetch_resp_data(adj_rm_fetch_resp_data),
		.fetch_resp_axi_id(adj_rm_fetch_resp_axi_id),
		.axi_araddr(prefetcher_adj_rm_axi_interconnect_axi_araddr),
		.axi_arburst(prefetcher_adj_rm_axi_interconnect_axi_arburst),
		.axi_arcache(prefetcher_adj_rm_axi_interconnect_axi_arcache),
		.axi_arid(prefetcher_adj_rm_axi_interconnect_axi_arid),
		.axi_arlen(prefetcher_adj_rm_axi_interconnect_axi_arlen),
		.axi_arlock(prefetcher_adj_rm_axi_interconnect_axi_arlock),
		.axi_arprot(prefetcher_adj_rm_axi_interconnect_axi_arprot),
		.axi_arqos(prefetcher_adj_rm_axi_interconnect_axi_arqos),
		.axi_arsize(prefetcher_adj_rm_axi_interconnect_axi_arsize),
		.axi_arvalid(prefetcher_adj_rm_axi_interconnect_axi_arvalid),
		.axi_arready(prefetcher_adj_rm_axi_interconnect_axi_arready),
		.axi_rdata(prefetcher_adj_rm_axi_interconnect_axi_rdata),
		.axi_rid(prefetcher_adj_rm_axi_interconnect_axi_rid),
		.axi_rlast(prefetcher_adj_rm_axi_interconnect_axi_rlast),
		.axi_rvalid(prefetcher_adj_rm_axi_interconnect_axi_rvalid),
		.axi_rready(prefetcher_adj_rm_axi_interconnect_axi_rready),
		.axi_rresp(prefetcher_adj_rm_axi_interconnect_axi_rresp)
	);
	axi_read_master #(
		.MAX_BYTE_COUNT(top_pkg_MAX_FETCH_REQ_BYTE_COUNT),
		.DATA_WIDTH(top_pkg_AXI_DATA_WIDTH)
	) msg_read_master(
		.core_clk(core_clk),
		.resetn(resetn),
		.fetch_req_valid(msg_rm_fetch_req_valid),
		.fetch_req_ready(msg_rm_fetch_req_ready),
		.fetch_start_address(msg_rm_fetch_start_address),
		.fetch_byte_count(msg_rm_fetch_byte_count),
		.fetch_resp_valid(msg_rm_fetch_resp_valid),
		.fetch_resp_ready(msg_rm_fetch_resp_ready),
		.fetch_resp_last(msg_rm_fetch_resp_last),
		.fetch_resp_data(msg_rm_fetch_resp_data),
		.fetch_resp_axi_id(msg_rm_fetch_resp_axi_id),
		.axi_araddr(prefetcher_msg_rm_axi_interconnect_axi_araddr),
		.axi_arburst(prefetcher_msg_rm_axi_interconnect_axi_arburst),
		.axi_arcache(prefetcher_msg_rm_axi_interconnect_axi_arcache),
		.axi_arid(prefetcher_msg_rm_axi_interconnect_axi_arid),
		.axi_arlen(prefetcher_msg_rm_axi_interconnect_axi_arlen),
		.axi_arlock(prefetcher_msg_rm_axi_interconnect_axi_arlock),
		.axi_arprot(prefetcher_msg_rm_axi_interconnect_axi_arprot),
		.axi_arqos(prefetcher_msg_rm_axi_interconnect_axi_arqos),
		.axi_arsize(prefetcher_msg_rm_axi_interconnect_axi_arsize),
		.axi_arvalid(prefetcher_msg_rm_axi_interconnect_axi_arvalid),
		.axi_arready(prefetcher_msg_rm_axi_interconnect_axi_arready),
		.axi_rdata(prefetcher_msg_rm_axi_interconnect_axi_rdata),
		.axi_rid(prefetcher_msg_rm_axi_interconnect_axi_rid),
		.axi_rlast(prefetcher_msg_rm_axi_interconnect_axi_rlast),
		.axi_rvalid(prefetcher_msg_rm_axi_interconnect_axi_rvalid),
		.axi_rready(prefetcher_msg_rm_axi_interconnect_axi_rready),
		.axi_rresp(prefetcher_msg_rm_axi_interconnect_axi_rresp)
	);
	axi_read_master #(.MAX_BYTE_COUNT(top_pkg_MAX_FETCH_REQ_BYTE_COUNT)) weight_read_master_i(
		.core_clk(core_clk),
		.resetn(resetn),
		.fetch_req_valid(weight_bank_axi_rm_fetch_req_valid),
		.fetch_req_ready(weight_bank_axi_rm_fetch_req_ready),
		.fetch_start_address(weight_bank_axi_rm_fetch_start_address),
		.fetch_byte_count(weight_bank_axi_rm_fetch_byte_count),
		.fetch_resp_valid(weight_bank_axi_rm_fetch_resp_valid),
		.fetch_resp_ready(weight_bank_axi_rm_fetch_resp_ready),
		.fetch_resp_last(weight_bank_axi_rm_fetch_resp_last),
		.fetch_resp_data(weight_bank_axi_rm_fetch_resp_data),
		.fetch_resp_axi_id(weight_bank_axi_rm_fetch_resp_axi_id),
		.axi_araddr(prefetcher_weight_bank_rm_axi_interconnect_axi_araddr),
		.axi_arburst(prefetcher_weight_bank_rm_axi_interconnect_axi_arburst),
		.axi_arcache(prefetcher_weight_bank_rm_axi_interconnect_axi_arcache),
		.axi_arid(prefetcher_weight_bank_rm_axi_interconnect_axi_arid),
		.axi_arlen(prefetcher_weight_bank_rm_axi_interconnect_axi_arlen),
		.axi_arlock(prefetcher_weight_bank_rm_axi_interconnect_axi_arlock),
		.axi_arprot(prefetcher_weight_bank_rm_axi_interconnect_axi_arprot),
		.axi_arqos(prefetcher_weight_bank_rm_axi_interconnect_axi_arqos),
		.axi_arsize(prefetcher_weight_bank_rm_axi_interconnect_axi_arsize),
		.axi_arvalid(prefetcher_weight_bank_rm_axi_interconnect_axi_arvalid),
		.axi_arready(prefetcher_weight_bank_rm_axi_interconnect_axi_arready),
		.axi_rdata(prefetcher_weight_bank_rm_axi_interconnect_axi_rdata),
		.axi_rid(prefetcher_weight_bank_rm_axi_interconnect_axi_rid),
		.axi_rlast(prefetcher_weight_bank_rm_axi_interconnect_axi_rlast),
		.axi_rvalid(prefetcher_weight_bank_rm_axi_interconnect_axi_rvalid),
		.axi_rready(prefetcher_weight_bank_rm_axi_interconnect_axi_rready),
		.axi_rresp(prefetcher_weight_bank_rm_axi_interconnect_axi_rresp)
	);
	always @(*) begin
		nsb_prefetcher_feature_bank_req_valid = nsb_prefetcher_req_valid && (((nsb_prefetcher_req[75-:3] == 3'd1) || (nsb_prefetcher_req[75-:3] == 3'd2)) || (nsb_prefetcher_req[75-:3] == 3'd3));
		nsb_prefetcher_weight_bank_req_valid = nsb_prefetcher_req_valid && (nsb_prefetcher_req[75-:3] == 3'd0);
		nsb_prefetcher_req_ready = (nsb_prefetcher_req[75-:3] == 3'd0 ? nsb_prefetcher_weight_bank_req_ready : nsb_prefetcher_feature_bank_req_ready);
		nsb_prefetcher_resp_valid = nsb_prefetcher_feature_bank_resp_valid || nsb_prefetcher_weight_bank_resp_valid;
		nsb_prefetcher_resp = (nsb_prefetcher_weight_bank_resp_valid ? nsb_prefetcher_weight_bank_resp : nsb_prefetcher_feature_bank_resp);
	end
	always @(*) begin
		prefetcher_adj_rm_axi_interconnect_axi_awaddr = 1'sb0;
		prefetcher_adj_rm_axi_interconnect_axi_awburst = 1'sb0;
		prefetcher_adj_rm_axi_interconnect_axi_awcache = 1'sb0;
		prefetcher_adj_rm_axi_interconnect_axi_awid = 1'sb0;
		prefetcher_adj_rm_axi_interconnect_axi_awlen = 1'sb0;
		prefetcher_adj_rm_axi_interconnect_axi_awlock = 1'sb0;
		prefetcher_adj_rm_axi_interconnect_axi_awprot = 1'sb0;
		prefetcher_adj_rm_axi_interconnect_axi_awqos = 1'sb0;
		prefetcher_adj_rm_axi_interconnect_axi_awsize = 1'sb0;
		prefetcher_adj_rm_axi_interconnect_axi_awvalid = 1'sb0;
		prefetcher_adj_rm_axi_interconnect_axi_bready = 1'sb0;
		prefetcher_adj_rm_axi_interconnect_axi_wdata = 1'sb0;
		prefetcher_adj_rm_axi_interconnect_axi_wlast = 1'sb0;
		prefetcher_adj_rm_axi_interconnect_axi_wstrb = 1'sb0;
		prefetcher_adj_rm_axi_interconnect_axi_wvalid = 1'sb0;
		prefetcher_msg_rm_axi_interconnect_axi_awaddr = 1'sb0;
		prefetcher_msg_rm_axi_interconnect_axi_awburst = 1'sb0;
		prefetcher_msg_rm_axi_interconnect_axi_awcache = 1'sb0;
		prefetcher_msg_rm_axi_interconnect_axi_awid = 1'sb0;
		prefetcher_msg_rm_axi_interconnect_axi_awlen = 1'sb0;
		prefetcher_msg_rm_axi_interconnect_axi_awlock = 1'sb0;
		prefetcher_msg_rm_axi_interconnect_axi_awprot = 1'sb0;
		prefetcher_msg_rm_axi_interconnect_axi_awqos = 1'sb0;
		prefetcher_msg_rm_axi_interconnect_axi_awsize = 1'sb0;
		prefetcher_msg_rm_axi_interconnect_axi_awvalid = 1'sb0;
		prefetcher_msg_rm_axi_interconnect_axi_bready = 1'sb0;
		prefetcher_msg_rm_axi_interconnect_axi_wdata = 1'sb0;
		prefetcher_msg_rm_axi_interconnect_axi_wlast = 1'sb0;
		prefetcher_msg_rm_axi_interconnect_axi_wstrb = 1'sb0;
		prefetcher_msg_rm_axi_interconnect_axi_wvalid = 1'sb0;
		prefetcher_weight_bank_rm_axi_interconnect_axi_awaddr = 1'sb0;
		prefetcher_weight_bank_rm_axi_interconnect_axi_awburst = 1'sb0;
		prefetcher_weight_bank_rm_axi_interconnect_axi_awcache = 1'sb0;
		prefetcher_weight_bank_rm_axi_interconnect_axi_awid = 1'sb0;
		prefetcher_weight_bank_rm_axi_interconnect_axi_awlen = 1'sb0;
		prefetcher_weight_bank_rm_axi_interconnect_axi_awlock = 1'sb0;
		prefetcher_weight_bank_rm_axi_interconnect_axi_awprot = 1'sb0;
		prefetcher_weight_bank_rm_axi_interconnect_axi_awqos = 1'sb0;
		prefetcher_weight_bank_rm_axi_interconnect_axi_awsize = 1'sb0;
		prefetcher_weight_bank_rm_axi_interconnect_axi_awvalid = 1'sb0;
		prefetcher_weight_bank_rm_axi_interconnect_axi_bready = 1'sb0;
		prefetcher_weight_bank_rm_axi_interconnect_axi_wdata = 1'sb0;
		prefetcher_weight_bank_rm_axi_interconnect_axi_wlast = 1'sb0;
		prefetcher_weight_bank_rm_axi_interconnect_axi_wstrb = 1'sb0;
		prefetcher_weight_bank_rm_axi_interconnect_axi_wvalid = 1'sb0;
	end
endmodule
module activation_core (
	sel_activation,
	in_feature_valid,
	in_feature,
	activated_feature_valid,
	activated_feature,
	layer_config_leaky_relu_alpha_value
);
	parameter FLOAT_WIDTH = 32;
	input wire [1:0] sel_activation;
	input wire in_feature_valid;
	input wire [FLOAT_WIDTH - 1:0] in_feature;
	output wire activated_feature_valid;
	output reg [FLOAT_WIDTH - 1:0] activated_feature;
	input wire [31:0] layer_config_leaky_relu_alpha_value;
	wire leaky_relu_activation_valid;
	wire [FLOAT_WIDTH - 1:0] leaky_relu_activation;
	always @(*)
		case (sel_activation)
			2'd0: activated_feature = in_feature;
			2'd1: activated_feature = (in_feature[FLOAT_WIDTH - 1] ? {FLOAT_WIDTH {1'sb0}} : in_feature);
			2'd2: activated_feature = (in_feature[FLOAT_WIDTH - 1] ? leaky_relu_activation : in_feature);
		endcase
	fp_mult upsampler_mult(
		.s_axis_a_tvalid(in_feature_valid),
		.s_axis_a_tdata(in_feature),
		.s_axis_b_tvalid(1'sb1),
		.s_axis_b_tdata(layer_config_leaky_relu_alpha_value),
		.m_axis_result_tvalid(leaky_relu_activation_valid),
		.m_axis_result_tdata(leaky_relu_activation)
	);
	assign activated_feature_valid = (sel_activation == 2'd0 ? in_feature_valid : (sel_activation == 2'd1 ? in_feature_valid : (sel_activation == 2'd2 ? leaky_relu_activation_valid : 1'b0)));
endmodule
module processing_element (
	core_clk,
	resetn,
	pulse_systolic_module,
	pe_forward_in_valid,
	pe_forward_in,
	pe_down_in_valid,
	pe_down_in,
	pe_forward_out_valid,
	pe_forward_out,
	pe_down_out_valid,
	pe_down_out,
	bias_valid,
	bias,
	activation_valid,
	activation,
	shift_valid,
	shift_data,
	pe_acc,
	layer_config_leaky_relu_alpha_value
);
	parameter FLOAT_WIDTH = 32;
	input wire core_clk;
	input wire resetn;
	input wire pulse_systolic_module;
	input wire pe_forward_in_valid;
	input wire [FLOAT_WIDTH - 1:0] pe_forward_in;
	input wire pe_down_in_valid;
	input wire [FLOAT_WIDTH - 1:0] pe_down_in;
	output reg pe_forward_out_valid;
	output reg [FLOAT_WIDTH - 1:0] pe_forward_out;
	output reg pe_down_out_valid;
	output reg [FLOAT_WIDTH - 1:0] pe_down_out;
	input wire bias_valid;
	input wire [FLOAT_WIDTH - 1:0] bias;
	input wire activation_valid;
	input wire [1:0] activation;
	input wire shift_valid;
	input wire [FLOAT_WIDTH - 1:0] shift_data;
	output wire [FLOAT_WIDTH - 1:0] pe_acc;
	input wire [31:0] layer_config_leaky_relu_alpha_value;
	wire update_accumulator;
	reg overwrite_accumulator;
	reg [FLOAT_WIDTH - 1:0] overwrite_data;
	wire bias_out_valid_comb;
	wire [FLOAT_WIDTH - 1:0] pe_acc_add_bias_comb;
	reg bias_out_valid;
	reg [FLOAT_WIDTH - 1:0] pe_acc_add_bias;
	wire activated_feature_valid;
	wire [FLOAT_WIDTH - 1:0] activated_feature;
	mac #(.FLOAT_WIDTH(FLOAT_WIDTH)) mac_i(
		.core_clk(core_clk),
		.resetn(resetn),
		.in_valid(update_accumulator),
		.a(pe_forward_in),
		.b(pe_down_in),
		.overwrite(overwrite_accumulator),
		.overwrite_data(overwrite_data),
		.accumulator(pe_acc)
	);
	fp_add bias_adder(
		.s_axis_a_tvalid(1'sb1),
		.s_axis_a_tdata(pe_acc),
		.s_axis_b_tvalid(bias_valid),
		.s_axis_b_tdata(bias),
		.m_axis_result_tvalid(bias_out_valid_comb),
		.m_axis_result_tdata(pe_acc_add_bias_comb)
	);
	always @(posedge core_clk or negedge resetn)
		if (!resetn) begin
			bias_out_valid <= 1'sb0;
			pe_acc_add_bias <= 1'sb0;
		end
		else begin
			bias_out_valid <= bias_out_valid_comb;
			pe_acc_add_bias <= pe_acc_add_bias_comb;
		end
	activation_core activation_core_i(
		.sel_activation(activation),
		.in_feature_valid(activation_valid),
		.in_feature(pe_acc),
		.activated_feature_valid(activated_feature_valid),
		.activated_feature(activated_feature),
		.layer_config_leaky_relu_alpha_value(layer_config_leaky_relu_alpha_value)
	);
	assign update_accumulator = (pulse_systolic_module && pe_forward_in_valid) && pe_down_in_valid;
	always @(posedge core_clk or negedge resetn)
		if (!resetn) begin
			pe_forward_out_valid <= 1'sb0;
			pe_forward_out <= 1'sb0;
			pe_down_out_valid <= 1'sb0;
			pe_down_out <= 1'sb0;
		end
		else if (update_accumulator) begin
			pe_forward_out_valid <= pe_forward_in_valid;
			pe_forward_out <= pe_forward_in;
			pe_down_out_valid <= pe_down_in_valid;
			pe_down_out <= pe_down_in;
		end
	always @(*) begin
		overwrite_accumulator = (bias_out_valid || activated_feature_valid) || shift_valid;
		overwrite_data = (bias_out_valid ? pe_acc_add_bias : (activated_feature_valid ? activated_feature : (shift_valid ? shift_data : {FLOAT_WIDTH {1'sb0}})));
	end
endmodule
module systolic_module (
	core_clk,
	resetn,
	pulse_systolic_module,
	sys_module_forward_in_valid,
	sys_module_forward_in,
	sys_module_down_in_valid,
	sys_module_down_in,
	sys_module_forward_out_valid,
	sys_module_forward_out,
	sys_module_down_out_valid,
	sys_module_down_out,
	bias_valid,
	bias,
	activation_valid,
	activation,
	shift_valid,
	sys_module_pe_acc,
	diagonal_flush_done,
	layer_config_leaky_relu_alpha_value
);
	parameter FLOAT_WIDTH = 32;
	parameter MATRIX_N = 4;
	input wire core_clk;
	input wire resetn;
	input wire pulse_systolic_module;
	input wire [MATRIX_N - 1:0] sys_module_forward_in_valid;
	input wire [(MATRIX_N * 32) - 1:0] sys_module_forward_in;
	input wire [MATRIX_N - 1:0] sys_module_down_in_valid;
	input wire [(MATRIX_N * 32) - 1:0] sys_module_down_in;
	output reg [MATRIX_N - 1:0] sys_module_forward_out_valid;
	output reg [(MATRIX_N * 32) - 1:0] sys_module_forward_out;
	output reg [MATRIX_N - 1:0] sys_module_down_out_valid;
	output reg [(MATRIX_N * 32) - 1:0] sys_module_down_out;
	input wire bias_valid;
	input wire [FLOAT_WIDTH - 1:0] bias;
	input wire activation_valid;
	input wire [1:0] activation;
	input wire shift_valid;
	output wire [((MATRIX_N >= 0 ? ((MATRIX_N + 1) * MATRIX_N) - 1 : ((1 - MATRIX_N) * MATRIX_N) + ((MATRIX_N * MATRIX_N) - 1)) >= (MATRIX_N >= 0 ? 0 : MATRIX_N * MATRIX_N) ? ((((MATRIX_N >= 0 ? ((MATRIX_N + 1) * MATRIX_N) - 1 : ((1 - MATRIX_N) * MATRIX_N) + ((MATRIX_N * MATRIX_N) - 1)) - (MATRIX_N >= 0 ? 0 : MATRIX_N * MATRIX_N)) + 1) * FLOAT_WIDTH) + (((MATRIX_N >= 0 ? 0 : MATRIX_N * MATRIX_N) * FLOAT_WIDTH) - 1) : ((((MATRIX_N >= 0 ? 0 : MATRIX_N * MATRIX_N) - (MATRIX_N >= 0 ? ((MATRIX_N + 1) * MATRIX_N) - 1 : ((1 - MATRIX_N) * MATRIX_N) + ((MATRIX_N * MATRIX_N) - 1))) + 1) * FLOAT_WIDTH) + (((MATRIX_N >= 0 ? ((MATRIX_N + 1) * MATRIX_N) - 1 : ((1 - MATRIX_N) * MATRIX_N) + ((MATRIX_N * MATRIX_N) - 1)) * FLOAT_WIDTH) - 1)):((MATRIX_N >= 0 ? ((MATRIX_N + 1) * MATRIX_N) - 1 : ((1 - MATRIX_N) * MATRIX_N) + ((MATRIX_N * MATRIX_N) - 1)) >= (MATRIX_N >= 0 ? 0 : MATRIX_N * MATRIX_N) ? (MATRIX_N >= 0 ? 0 : MATRIX_N * MATRIX_N) * FLOAT_WIDTH : (MATRIX_N >= 0 ? ((MATRIX_N + 1) * MATRIX_N) - 1 : ((1 - MATRIX_N) * MATRIX_N) + ((MATRIX_N * MATRIX_N) - 1)) * FLOAT_WIDTH)] sys_module_pe_acc;
	output wire diagonal_flush_done;
	input wire [31:0] layer_config_leaky_relu_alpha_value;
	reg [(MATRIX_N * MATRIX_N) - 1:0] sys_module_pe_forward_valid;
	reg [((MATRIX_N * MATRIX_N) * FLOAT_WIDTH) - 1:0] sys_module_pe_forward;
	reg [(MATRIX_N * MATRIX_N) - 1:0] sys_module_pe_down_valid;
	reg [((MATRIX_N * MATRIX_N) * FLOAT_WIDTH) - 1:0] sys_module_pe_down;
	wire [MATRIX_N - 1:0] forward_flush_done;
	wire [MATRIX_N - 1:0] down_flush_done;
	genvar row;
	generate
		for (row = 0; row < MATRIX_N; row = row + 1) begin : rows_gen
			genvar col;
			for (col = 0; col < MATRIX_N; col = col + 1) begin : cols_gen
				wire [1:1] sv2v_tmp_pe_i_pe_forward_out_valid;
				always @(*) sys_module_pe_forward_valid[(row * MATRIX_N) + (col + 1)+:1] = sv2v_tmp_pe_i_pe_forward_out_valid;
				wire [FLOAT_WIDTH:1] sv2v_tmp_pe_i_pe_forward_out;
				always @(*) sys_module_pe_forward[((row * MATRIX_N) + (col + 1)) * FLOAT_WIDTH+:FLOAT_WIDTH] = sv2v_tmp_pe_i_pe_forward_out;
				wire [1:1] sv2v_tmp_pe_i_pe_down_out_valid;
				always @(*) sys_module_pe_down_valid[((row + 1) * MATRIX_N) + col+:1] = sv2v_tmp_pe_i_pe_down_out_valid;
				wire [FLOAT_WIDTH:1] sv2v_tmp_pe_i_pe_down_out;
				always @(*) sys_module_pe_down[(((row + 1) * MATRIX_N) + col) * FLOAT_WIDTH+:FLOAT_WIDTH] = sv2v_tmp_pe_i_pe_down_out;
				processing_element #(.FLOAT_WIDTH(FLOAT_WIDTH)) pe_i(
					.core_clk(core_clk),
					.resetn(resetn),
					.pulse_systolic_module(pulse_systolic_module),
					.pe_forward_in_valid(sys_module_pe_forward_valid[(row * MATRIX_N) + col+:1]),
					.pe_forward_in(sys_module_pe_forward[((row * MATRIX_N) + col) * FLOAT_WIDTH+:FLOAT_WIDTH]),
					.pe_down_in_valid(sys_module_pe_down_valid[(row * MATRIX_N) + col+:1]),
					.pe_down_in(sys_module_pe_down[((row * MATRIX_N) + col) * FLOAT_WIDTH+:FLOAT_WIDTH]),
					.pe_forward_out_valid(sv2v_tmp_pe_i_pe_forward_out_valid),
					.pe_forward_out(sv2v_tmp_pe_i_pe_forward_out),
					.pe_down_out_valid(sv2v_tmp_pe_i_pe_down_out_valid),
					.pe_down_out(sv2v_tmp_pe_i_pe_down_out),
					.bias_valid(bias_valid),
					.bias(bias),
					.activation_valid(activation_valid),
					.activation(activation),
					.shift_valid(shift_valid),
					.shift_data(sys_module_pe_acc[((MATRIX_N >= 0 ? ((MATRIX_N + 1) * MATRIX_N) - 1 : ((1 - MATRIX_N) * MATRIX_N) + ((MATRIX_N * MATRIX_N) - 1)) >= (MATRIX_N >= 0 ? 0 : MATRIX_N * MATRIX_N) ? ((MATRIX_N >= 0 ? row + 1 : MATRIX_N - (row + 1)) * MATRIX_N) + col : (MATRIX_N >= 0 ? 0 : MATRIX_N * MATRIX_N) - ((((MATRIX_N >= 0 ? row + 1 : MATRIX_N - (row + 1)) * MATRIX_N) + col) - (MATRIX_N >= 0 ? ((MATRIX_N + 1) * MATRIX_N) - 1 : ((1 - MATRIX_N) * MATRIX_N) + ((MATRIX_N * MATRIX_N) - 1)))) * FLOAT_WIDTH+:FLOAT_WIDTH]),
					.pe_acc(sys_module_pe_acc[((MATRIX_N >= 0 ? ((MATRIX_N + 1) * MATRIX_N) - 1 : ((1 - MATRIX_N) * MATRIX_N) + ((MATRIX_N * MATRIX_N) - 1)) >= (MATRIX_N >= 0 ? 0 : MATRIX_N * MATRIX_N) ? ((MATRIX_N >= 0 ? row : MATRIX_N - row) * MATRIX_N) + col : (MATRIX_N >= 0 ? 0 : MATRIX_N * MATRIX_N) - ((((MATRIX_N >= 0 ? row : MATRIX_N - row) * MATRIX_N) + col) - (MATRIX_N >= 0 ? ((MATRIX_N + 1) * MATRIX_N) - 1 : ((1 - MATRIX_N) * MATRIX_N) + ((MATRIX_N * MATRIX_N) - 1)))) * FLOAT_WIDTH+:FLOAT_WIDTH]),
					.layer_config_leaky_relu_alpha_value(layer_config_leaky_relu_alpha_value)
				);
			end
		end
	endgenerate
	assign sys_module_pe_acc[FLOAT_WIDTH * ((MATRIX_N >= 0 ? ((MATRIX_N + 1) * MATRIX_N) - 1 : ((1 - MATRIX_N) * MATRIX_N) + ((MATRIX_N * MATRIX_N) - 1)) >= (MATRIX_N >= 0 ? 0 : MATRIX_N * MATRIX_N) ? ((MATRIX_N >= 0 ? ((MATRIX_N + 1) * MATRIX_N) - 1 : ((1 - MATRIX_N) * MATRIX_N) + ((MATRIX_N * MATRIX_N) - 1)) >= (MATRIX_N >= 0 ? 0 : MATRIX_N * MATRIX_N) ? (MATRIX_N >= 0 ? MATRIX_N : MATRIX_N - MATRIX_N) * MATRIX_N : ((MATRIX_N >= 0 ? MATRIX_N : MATRIX_N - MATRIX_N) * MATRIX_N) + (MATRIX_N - 1)) : (MATRIX_N >= 0 ? 0 : MATRIX_N * MATRIX_N) - (((MATRIX_N >= 0 ? ((MATRIX_N + 1) * MATRIX_N) - 1 : ((1 - MATRIX_N) * MATRIX_N) + ((MATRIX_N * MATRIX_N) - 1)) >= (MATRIX_N >= 0 ? 0 : MATRIX_N * MATRIX_N) ? (MATRIX_N >= 0 ? MATRIX_N : MATRIX_N - MATRIX_N) * MATRIX_N : ((MATRIX_N >= 0 ? MATRIX_N : MATRIX_N - MATRIX_N) * MATRIX_N) + (MATRIX_N - 1)) - (MATRIX_N >= 0 ? ((MATRIX_N + 1) * MATRIX_N) - 1 : ((1 - MATRIX_N) * MATRIX_N) + ((MATRIX_N * MATRIX_N) - 1))))+:FLOAT_WIDTH * MATRIX_N] = 1'sb0;
	generate
		for (row = 0; row < MATRIX_N; row = row + 1) begin : genblk2
			always @(*) begin
				sys_module_pe_forward[(row * MATRIX_N) * FLOAT_WIDTH+:FLOAT_WIDTH] = sys_module_forward_in[row * 32+:32];
				sys_module_pe_forward_valid[row * MATRIX_N+:1] = sys_module_forward_in_valid[row];
				sys_module_forward_out_valid[row] = sys_module_pe_forward_valid[(row * MATRIX_N) + (MATRIX_N - 1)+:1];
				sys_module_forward_out[row * 32+:32] = sys_module_pe_forward[((row * MATRIX_N) + (MATRIX_N - 1)) * FLOAT_WIDTH+:FLOAT_WIDTH];
			end
		end
	endgenerate
	assign forward_flush_done = ~sys_module_forward_out_valid;
	genvar col;
	generate
		for (col = 0; col < MATRIX_N; col = col + 1) begin : genblk3
			always @(*) begin
				sys_module_pe_down[(0 + col) * FLOAT_WIDTH+:FLOAT_WIDTH] = sys_module_down_in[col * 32+:32];
				sys_module_pe_down_valid[0 + col+:1] = sys_module_down_in_valid[col];
				sys_module_down_out_valid[col] = sys_module_pe_down_valid[((MATRIX_N - 1) * MATRIX_N) + col+:1];
				sys_module_down_out[col * 32+:32] = sys_module_pe_down[(((MATRIX_N - 1) * MATRIX_N) + col) * FLOAT_WIDTH+:FLOAT_WIDTH];
			end
		end
	endgenerate
	assign down_flush_done = ~sys_module_down_out_valid;
	assign diagonal_flush_done = &forward_flush_done && &down_flush_done;
endmodule
module feature_transformation_engine (
	core_clk,
	resetn,
	s_axi_awaddr,
	s_axi_awprot,
	s_axi_awvalid,
	s_axi_awready,
	s_axi_wdata,
	s_axi_wstrb,
	s_axi_wvalid,
	s_axi_wready,
	s_axi_araddr,
	s_axi_arprot,
	s_axi_arvalid,
	s_axi_arready,
	s_axi_rdata,
	s_axi_rresp,
	s_axi_rvalid,
	s_axi_rready,
	s_axi_bresp,
	s_axi_bvalid,
	s_axi_bready,
	nsb_fte_req_valid,
	nsb_fte_req_ready,
	nsb_fte_req,
	nsb_fte_resp_valid,
	nsb_fte_resp,
	aggregation_buffer_node_id,
	aggregation_buffer_pop,
	aggregation_buffer_out_feature,
	aggregation_buffer_slot_free,
	weight_channel_req_valid,
	weight_channel_req_ready,
	weight_channel_req,
	weight_channel_resp_valid,
	weight_channel_resp_ready,
	weight_channel_resp,
	transformation_buffer_write_enable,
	transformation_buffer_write_address,
	transformation_buffer_write_data,
	transformation_buffer_slot_free,
	transformation_engine_axi_interconnect_axi_araddr,
	transformation_engine_axi_interconnect_axi_arburst,
	transformation_engine_axi_interconnect_axi_arcache,
	transformation_engine_axi_interconnect_axi_arid,
	transformation_engine_axi_interconnect_axi_arlen,
	transformation_engine_axi_interconnect_axi_arlock,
	transformation_engine_axi_interconnect_axi_arprot,
	transformation_engine_axi_interconnect_axi_arqos,
	transformation_engine_axi_interconnect_axi_arsize,
	transformation_engine_axi_interconnect_axi_arvalid,
	transformation_engine_axi_interconnect_axi_arready,
	transformation_engine_axi_interconnect_axi_rdata,
	transformation_engine_axi_interconnect_axi_rid,
	transformation_engine_axi_interconnect_axi_rlast,
	transformation_engine_axi_interconnect_axi_rready,
	transformation_engine_axi_interconnect_axi_rresp,
	transformation_engine_axi_interconnect_axi_rvalid,
	transformation_engine_axi_interconnect_axi_awaddr,
	transformation_engine_axi_interconnect_axi_awburst,
	transformation_engine_axi_interconnect_axi_awcache,
	transformation_engine_axi_interconnect_axi_awid,
	transformation_engine_axi_interconnect_axi_awlen,
	transformation_engine_axi_interconnect_axi_awlock,
	transformation_engine_axi_interconnect_axi_awprot,
	transformation_engine_axi_interconnect_axi_awqos,
	transformation_engine_axi_interconnect_axi_awready,
	transformation_engine_axi_interconnect_axi_awsize,
	transformation_engine_axi_interconnect_axi_awvalid,
	transformation_engine_axi_interconnect_axi_wdata,
	transformation_engine_axi_interconnect_axi_wlast,
	transformation_engine_axi_interconnect_axi_wready,
	transformation_engine_axi_interconnect_axi_wstrb,
	transformation_engine_axi_interconnect_axi_wvalid,
	transformation_engine_axi_interconnect_axi_bid,
	transformation_engine_axi_interconnect_axi_bready,
	transformation_engine_axi_interconnect_axi_bresp,
	transformation_engine_axi_interconnect_axi_bvalid
);
	parameter FLOAT_WIDTH = 32;
	parameter AXI_ADDR_WIDTH = 32;
	parameter MATRIX_N = 16;
	input wire core_clk;
	input wire resetn;
	input wire [AXI_ADDR_WIDTH - 1:0] s_axi_awaddr;
	input wire [2:0] s_axi_awprot;
	input wire s_axi_awvalid;
	output wire s_axi_awready;
	input wire [31:0] s_axi_wdata;
	input wire [3:0] s_axi_wstrb;
	input wire s_axi_wvalid;
	output wire s_axi_wready;
	input wire [AXI_ADDR_WIDTH - 1:0] s_axi_araddr;
	input wire [2:0] s_axi_arprot;
	input wire s_axi_arvalid;
	output wire s_axi_arready;
	output wire [31:0] s_axi_rdata;
	output wire [1:0] s_axi_rresp;
	output wire s_axi_rvalid;
	input wire s_axi_rready;
	output wire [1:0] s_axi_bresp;
	output wire s_axi_bvalid;
	input wire s_axi_bready;
	input wire nsb_fte_req_valid;
	output reg nsb_fte_req_ready;
	localparam top_pkg_MAX_NODESLOT_COUNT = 32;
	input wire [31:0] nsb_fte_req;
	output reg nsb_fte_resp_valid;
	output reg [31:0] nsb_fte_resp;
	localparam top_pkg_AGGREGATION_BUFFER_SLOTS = 16;
	localparam top_pkg_MAX_NODES = 1048576;
	localparam top_pkg_NODE_ID_WIDTH = 20;
	input wire [319:0] aggregation_buffer_node_id;
	output reg [15:0] aggregation_buffer_pop;
	localparam top_pkg_AGGREGATION_BUFFER_READ_WIDTH = 32;
	input wire [511:0] aggregation_buffer_out_feature;
	input wire [15:0] aggregation_buffer_slot_free;
	output reg weight_channel_req_valid;
	input wire weight_channel_req_ready;
	localparam top_pkg_MAX_FEATURE_COUNT = 1024;
	output reg [21:0] weight_channel_req;
	input wire weight_channel_resp_valid;
	output reg weight_channel_resp_ready;
	input wire [33792:0] weight_channel_resp;
	localparam top_pkg_TRANSFORMATION_BUFFER_SLOTS = 16;
	output reg [15:0] transformation_buffer_write_enable;
	localparam top_pkg_TRANSFORMATION_BUFFER_WRITE_DEPTH = 64;
	output reg [95:0] transformation_buffer_write_address;
	localparam top_pkg_TRANSFORMATION_BUFFER_WRITE_WIDTH = 512;
	output reg [8191:0] transformation_buffer_write_data;
	input wire [15:0] transformation_buffer_slot_free;
	output reg [33:0] transformation_engine_axi_interconnect_axi_araddr;
	output reg [1:0] transformation_engine_axi_interconnect_axi_arburst;
	output reg [3:0] transformation_engine_axi_interconnect_axi_arcache;
	output reg [3:0] transformation_engine_axi_interconnect_axi_arid;
	output reg [7:0] transformation_engine_axi_interconnect_axi_arlen;
	output reg [0:0] transformation_engine_axi_interconnect_axi_arlock;
	output reg [2:0] transformation_engine_axi_interconnect_axi_arprot;
	output reg [3:0] transformation_engine_axi_interconnect_axi_arqos;
	output reg [2:0] transformation_engine_axi_interconnect_axi_arsize;
	output reg transformation_engine_axi_interconnect_axi_arvalid;
	input wire transformation_engine_axi_interconnect_axi_arready;
	input wire [511:0] transformation_engine_axi_interconnect_axi_rdata;
	input wire [3:0] transformation_engine_axi_interconnect_axi_rid;
	input wire transformation_engine_axi_interconnect_axi_rlast;
	output reg transformation_engine_axi_interconnect_axi_rready;
	input wire [1:0] transformation_engine_axi_interconnect_axi_rresp;
	input wire transformation_engine_axi_interconnect_axi_rvalid;
	output reg [33:0] transformation_engine_axi_interconnect_axi_awaddr;
	output reg [1:0] transformation_engine_axi_interconnect_axi_awburst;
	output reg [3:0] transformation_engine_axi_interconnect_axi_awcache;
	output reg [3:0] transformation_engine_axi_interconnect_axi_awid;
	output reg [7:0] transformation_engine_axi_interconnect_axi_awlen;
	output reg [0:0] transformation_engine_axi_interconnect_axi_awlock;
	output reg [2:0] transformation_engine_axi_interconnect_axi_awprot;
	output reg [3:0] transformation_engine_axi_interconnect_axi_awqos;
	input wire transformation_engine_axi_interconnect_axi_awready;
	output reg [2:0] transformation_engine_axi_interconnect_axi_awsize;
	output reg transformation_engine_axi_interconnect_axi_awvalid;
	output reg [511:0] transformation_engine_axi_interconnect_axi_wdata;
	output reg transformation_engine_axi_interconnect_axi_wlast;
	input wire transformation_engine_axi_interconnect_axi_wready;
	output reg [63:0] transformation_engine_axi_interconnect_axi_wstrb;
	output reg transformation_engine_axi_interconnect_axi_wvalid;
	input wire [3:0] transformation_engine_axi_interconnect_axi_bid;
	output reg transformation_engine_axi_interconnect_axi_bready;
	input wire [1:0] transformation_engine_axi_interconnect_axi_bresp;
	input wire transformation_engine_axi_interconnect_axi_bvalid;
	parameter SYSTOLIC_MODULE_COUNT = 4;
	reg [3:0] fte_state;
	reg [3:0] fte_state_n;
	reg last_weight_resp_received;
	wire layer_config_in_features_strobe;
	wire [9:0] layer_config_in_features_count;
	wire layer_config_out_features_strobe;
	wire [9:0] layer_config_out_features_count;
	wire layer_config_activation_function_strobe;
	wire [1:0] layer_config_activation_function_value;
	wire layer_config_bias_strobe;
	wire [31:0] layer_config_bias_value;
	wire layer_config_leaky_relu_alpha_strobe;
	wire [31:0] layer_config_leaky_relu_alpha_value;
	wire layer_config_out_features_address_msb_strobe;
	wire [1:0] layer_config_out_features_address_msb_value;
	wire layer_config_out_features_address_lsb_strobe;
	wire [31:0] layer_config_out_features_address_lsb_value;
	wire ctrl_buffering_enable_strobe;
	wire [0:0] ctrl_buffering_enable_value;
	wire ctrl_writeback_enable_strobe;
	wire [0:0] ctrl_writeback_enable_value;
	wire [4:0] nodeslot_count;
	reg [4:0] nodeslots_to_buffer;
	reg [4:0] nodeslots_to_writeback;
	reg [(SYSTOLIC_MODULE_COUNT >= 0 ? ((SYSTOLIC_MODULE_COUNT + 1) * MATRIX_N) - 1 : ((1 - SYSTOLIC_MODULE_COUNT) * MATRIX_N) + ((SYSTOLIC_MODULE_COUNT * MATRIX_N) - 1)):(SYSTOLIC_MODULE_COUNT >= 0 ? 0 : SYSTOLIC_MODULE_COUNT * MATRIX_N)] sys_module_forward_valid;
	reg [((SYSTOLIC_MODULE_COUNT >= 0 ? ((SYSTOLIC_MODULE_COUNT + 1) * MATRIX_N) - 1 : ((1 - SYSTOLIC_MODULE_COUNT) * MATRIX_N) + ((SYSTOLIC_MODULE_COUNT * MATRIX_N) - 1)) >= (SYSTOLIC_MODULE_COUNT >= 0 ? 0 : SYSTOLIC_MODULE_COUNT * MATRIX_N) ? ((((SYSTOLIC_MODULE_COUNT >= 0 ? ((SYSTOLIC_MODULE_COUNT + 1) * MATRIX_N) - 1 : ((1 - SYSTOLIC_MODULE_COUNT) * MATRIX_N) + ((SYSTOLIC_MODULE_COUNT * MATRIX_N) - 1)) - (SYSTOLIC_MODULE_COUNT >= 0 ? 0 : SYSTOLIC_MODULE_COUNT * MATRIX_N)) + 1) * 32) + (((SYSTOLIC_MODULE_COUNT >= 0 ? 0 : SYSTOLIC_MODULE_COUNT * MATRIX_N) * 32) - 1) : ((((SYSTOLIC_MODULE_COUNT >= 0 ? 0 : SYSTOLIC_MODULE_COUNT * MATRIX_N) - (SYSTOLIC_MODULE_COUNT >= 0 ? ((SYSTOLIC_MODULE_COUNT + 1) * MATRIX_N) - 1 : ((1 - SYSTOLIC_MODULE_COUNT) * MATRIX_N) + ((SYSTOLIC_MODULE_COUNT * MATRIX_N) - 1))) + 1) * 32) + (((SYSTOLIC_MODULE_COUNT >= 0 ? ((SYSTOLIC_MODULE_COUNT + 1) * MATRIX_N) - 1 : ((1 - SYSTOLIC_MODULE_COUNT) * MATRIX_N) + ((SYSTOLIC_MODULE_COUNT * MATRIX_N) - 1)) * 32) - 1)):((SYSTOLIC_MODULE_COUNT >= 0 ? ((SYSTOLIC_MODULE_COUNT + 1) * MATRIX_N) - 1 : ((1 - SYSTOLIC_MODULE_COUNT) * MATRIX_N) + ((SYSTOLIC_MODULE_COUNT * MATRIX_N) - 1)) >= (SYSTOLIC_MODULE_COUNT >= 0 ? 0 : SYSTOLIC_MODULE_COUNT * MATRIX_N) ? (SYSTOLIC_MODULE_COUNT >= 0 ? 0 : SYSTOLIC_MODULE_COUNT * MATRIX_N) * 32 : (SYSTOLIC_MODULE_COUNT >= 0 ? ((SYSTOLIC_MODULE_COUNT + 1) * MATRIX_N) - 1 : ((1 - SYSTOLIC_MODULE_COUNT) * MATRIX_N) + ((SYSTOLIC_MODULE_COUNT * MATRIX_N) - 1)) * 32)] sys_module_forward;
	reg [1023:0] sys_module_down_in_valid;
	reg [32767:0] sys_module_down_in;
	wire [1023:0] sys_module_down_out_valid;
	wire [32767:0] sys_module_down_out;
	wire [SYSTOLIC_MODULE_COUNT - 1:0] sys_module_flush_done;
	wire [(((MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1)) >= (MATRIX_N >= 0 ? 0 : MATRIX_N + 0) ? ((((MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1)) - (MATRIX_N >= 0 ? 0 : MATRIX_N + 0)) + 1) * MATRIX_N) + (((MATRIX_N >= 0 ? 0 : MATRIX_N + 0) * MATRIX_N) - 1) : ((((MATRIX_N >= 0 ? 0 : MATRIX_N + 0) - (MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1))) + 1) * MATRIX_N) + (((MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1)) * MATRIX_N) - 1)) >= ((MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1)) >= (MATRIX_N >= 0 ? 0 : MATRIX_N + 0) ? (MATRIX_N >= 0 ? 0 : MATRIX_N + 0) * MATRIX_N : (MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1)) * MATRIX_N) ? (((((MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1)) >= (MATRIX_N >= 0 ? 0 : MATRIX_N + 0) ? ((((MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1)) - (MATRIX_N >= 0 ? 0 : MATRIX_N + 0)) + 1) * MATRIX_N) + (((MATRIX_N >= 0 ? 0 : MATRIX_N + 0) * MATRIX_N) - 1) : ((((MATRIX_N >= 0 ? 0 : MATRIX_N + 0) - (MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1))) + 1) * MATRIX_N) + (((MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1)) * MATRIX_N) - 1)) - ((MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1)) >= (MATRIX_N >= 0 ? 0 : MATRIX_N + 0) ? (MATRIX_N >= 0 ? 0 : MATRIX_N + 0) * MATRIX_N : (MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1)) * MATRIX_N)) + 1) * FLOAT_WIDTH) + ((((MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1)) >= (MATRIX_N >= 0 ? 0 : MATRIX_N + 0) ? (MATRIX_N >= 0 ? 0 : MATRIX_N + 0) * MATRIX_N : (MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1)) * MATRIX_N) * FLOAT_WIDTH) - 1) : (((((MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1)) >= (MATRIX_N >= 0 ? 0 : MATRIX_N + 0) ? (MATRIX_N >= 0 ? 0 : MATRIX_N + 0) * MATRIX_N : (MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1)) * MATRIX_N) - ((MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1)) >= (MATRIX_N >= 0 ? 0 : MATRIX_N + 0) ? ((((MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1)) - (MATRIX_N >= 0 ? 0 : MATRIX_N + 0)) + 1) * MATRIX_N) + (((MATRIX_N >= 0 ? 0 : MATRIX_N + 0) * MATRIX_N) - 1) : ((((MATRIX_N >= 0 ? 0 : MATRIX_N + 0) - (MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1))) + 1) * MATRIX_N) + (((MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1)) * MATRIX_N) - 1))) + 1) * FLOAT_WIDTH) + ((((MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1)) >= (MATRIX_N >= 0 ? 0 : MATRIX_N + 0) ? ((((MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1)) - (MATRIX_N >= 0 ? 0 : MATRIX_N + 0)) + 1) * MATRIX_N) + (((MATRIX_N >= 0 ? 0 : MATRIX_N + 0) * MATRIX_N) - 1) : ((((MATRIX_N >= 0 ? 0 : MATRIX_N + 0) - (MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1))) + 1) * MATRIX_N) + (((MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1)) * MATRIX_N) - 1)) * FLOAT_WIDTH) - 1)):(((MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1)) >= (MATRIX_N >= 0 ? 0 : MATRIX_N + 0) ? ((((MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1)) - (MATRIX_N >= 0 ? 0 : MATRIX_N + 0)) + 1) * MATRIX_N) + (((MATRIX_N >= 0 ? 0 : MATRIX_N + 0) * MATRIX_N) - 1) : ((((MATRIX_N >= 0 ? 0 : MATRIX_N + 0) - (MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1))) + 1) * MATRIX_N) + (((MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1)) * MATRIX_N) - 1)) >= ((MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1)) >= (MATRIX_N >= 0 ? 0 : MATRIX_N + 0) ? (MATRIX_N >= 0 ? 0 : MATRIX_N + 0) * MATRIX_N : (MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1)) * MATRIX_N) ? ((MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1)) >= (MATRIX_N >= 0 ? 0 : MATRIX_N + 0) ? (MATRIX_N >= 0 ? 0 : MATRIX_N + 0) * MATRIX_N : (MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1)) * MATRIX_N) * FLOAT_WIDTH : ((MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1)) >= (MATRIX_N >= 0 ? 0 : MATRIX_N + 0) ? ((((MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1)) - (MATRIX_N >= 0 ? 0 : MATRIX_N + 0)) + 1) * MATRIX_N) + (((MATRIX_N >= 0 ? 0 : MATRIX_N + 0) * MATRIX_N) - 1) : ((((MATRIX_N >= 0 ? 0 : MATRIX_N + 0) - (MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1))) + 1) * MATRIX_N) + (((MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1)) * MATRIX_N) - 1)) * FLOAT_WIDTH)] sys_module_pe_acc;
	reg [SYSTOLIC_MODULE_COUNT - 1:0] shift_sys_module;
	reg bias_valid;
	reg activation_valid;
	reg begin_feature_dump;
	reg pulse_systolic_module;
	wire [15:0] slot_pop_shift;
	reg [15:0] busy_aggregation_slots_snapshot;
	reg pe_delay_counter;
	wire [15:0] transformation_buffer_slot_arb_oh;
	wire start_memory_dump;
	reg [1:0] axi_write_state;
	reg [1:0] axi_write_state_n;
	reg [$clog2(SYSTOLIC_MODULE_COUNT) - 1:0] sys_module_counter;
	reg [(MATRIX_N >= 0 ? ((MATRIX_N + 1) * 20) - 1 : ((1 - MATRIX_N) * 20) + ((MATRIX_N * 20) - 1)):(MATRIX_N >= 0 ? 0 : MATRIX_N * 20)] sys_module_node_id_snapshot;
	reg [11:0] out_features_required_bytes;
	feature_transformation_engine_regbank_regs feature_transformation_engine_regbank_i(
		.axi_aclk(core_clk),
		.axi_aresetn(resetn),
		.s_axi_awaddr(s_axi_awaddr),
		.s_axi_awprot(s_axi_awprot),
		.s_axi_awvalid(s_axi_awvalid),
		.s_axi_awready(s_axi_awready),
		.s_axi_wdata(s_axi_wdata),
		.s_axi_wstrb(s_axi_wstrb),
		.s_axi_wvalid(s_axi_wvalid),
		.s_axi_wready(s_axi_wready),
		.s_axi_araddr(s_axi_araddr),
		.s_axi_arprot(s_axi_arprot),
		.s_axi_arvalid(s_axi_arvalid),
		.s_axi_arready(s_axi_arready),
		.s_axi_rdata(s_axi_rdata),
		.s_axi_rresp(s_axi_rresp),
		.s_axi_rvalid(s_axi_rvalid),
		.s_axi_rready(s_axi_rready),
		.s_axi_bresp(s_axi_bresp),
		.s_axi_bvalid(s_axi_bvalid),
		.s_axi_bready(s_axi_bready),
		.layer_config_in_features_strobe(layer_config_in_features_strobe),
		.layer_config_in_features_count(layer_config_in_features_count),
		.layer_config_out_features_strobe(layer_config_out_features_strobe),
		.layer_config_out_features_count(layer_config_out_features_count),
		.layer_config_activation_function_strobe(layer_config_activation_function_strobe),
		.layer_config_activation_function_value(layer_config_activation_function_value),
		.layer_config_bias_strobe(layer_config_bias_strobe),
		.layer_config_bias_value(layer_config_bias_value),
		.layer_config_leaky_relu_alpha_strobe(layer_config_leaky_relu_alpha_strobe),
		.layer_config_leaky_relu_alpha_value(layer_config_leaky_relu_alpha_value),
		.layer_config_out_features_address_msb_strobe(layer_config_out_features_address_msb_strobe),
		.layer_config_out_features_address_msb_value(layer_config_out_features_address_msb_value),
		.layer_config_out_features_address_lsb_strobe(layer_config_out_features_address_lsb_strobe),
		.layer_config_out_features_address_lsb_value(layer_config_out_features_address_lsb_value)
	);
	genvar sys_module;
	generate
		for (sys_module = 0; sys_module < SYSTOLIC_MODULE_COUNT; sys_module = sys_module + 1) begin : genblk1
			always @(*) begin
				sys_module_down_in_valid[(sys_module * MATRIX_N) + (MATRIX_N - 1):sys_module * MATRIX_N] = {MATRIX_N {weight_channel_resp_valid}} & weight_channel_resp[1 + ((sys_module * MATRIX_N) + (MATRIX_N - 1)):1 + (sys_module * MATRIX_N)];
				sys_module_down_in[32 * ((((sys_module * MATRIX_N) + (MATRIX_N - 1)) >= (sys_module * MATRIX_N) ? (sys_module * MATRIX_N) + (MATRIX_N - 1) : (((sys_module * MATRIX_N) + (MATRIX_N - 1)) + (((sys_module * MATRIX_N) + (MATRIX_N - 1)) >= (sys_module * MATRIX_N) ? (((sys_module * MATRIX_N) + (MATRIX_N - 1)) - (sys_module * MATRIX_N)) + 1 : ((sys_module * MATRIX_N) - ((sys_module * MATRIX_N) + (MATRIX_N - 1))) + 1)) - 1) - ((((sys_module * MATRIX_N) + (MATRIX_N - 1)) >= (sys_module * MATRIX_N) ? (((sys_module * MATRIX_N) + (MATRIX_N - 1)) - (sys_module * MATRIX_N)) + 1 : ((sys_module * MATRIX_N) - ((sys_module * MATRIX_N) + (MATRIX_N - 1))) + 1) - 1))+:32 * (((sys_module * MATRIX_N) + (MATRIX_N - 1)) >= (sys_module * MATRIX_N) ? (((sys_module * MATRIX_N) + (MATRIX_N - 1)) - (sys_module * MATRIX_N)) + 1 : ((sys_module * MATRIX_N) - ((sys_module * MATRIX_N) + (MATRIX_N - 1))) + 1)] = weight_channel_resp[1025 + (32 * ((((sys_module * MATRIX_N) + (MATRIX_N - 1)) >= (sys_module * MATRIX_N) ? (sys_module * MATRIX_N) + (MATRIX_N - 1) : (((sys_module * MATRIX_N) + (MATRIX_N - 1)) + (((sys_module * MATRIX_N) + (MATRIX_N - 1)) >= (sys_module * MATRIX_N) ? (((sys_module * MATRIX_N) + (MATRIX_N - 1)) - (sys_module * MATRIX_N)) + 1 : ((sys_module * MATRIX_N) - ((sys_module * MATRIX_N) + (MATRIX_N - 1))) + 1)) - 1) - ((((sys_module * MATRIX_N) + (MATRIX_N - 1)) >= (sys_module * MATRIX_N) ? (((sys_module * MATRIX_N) + (MATRIX_N - 1)) - (sys_module * MATRIX_N)) + 1 : ((sys_module * MATRIX_N) - ((sys_module * MATRIX_N) + (MATRIX_N - 1))) + 1) - 1)))+:32 * (((sys_module * MATRIX_N) + (MATRIX_N - 1)) >= (sys_module * MATRIX_N) ? (((sys_module * MATRIX_N) + (MATRIX_N - 1)) - (sys_module * MATRIX_N)) + 1 : ((sys_module * MATRIX_N) - ((sys_module * MATRIX_N) + (MATRIX_N - 1))) + 1)];
			end
			wire [MATRIX_N * 1:1] sv2v_tmp_sys_module_i_sys_module_forward_out_valid;
			always @(*) sys_module_forward_valid[(SYSTOLIC_MODULE_COUNT >= 0 ? sys_module + 1 : SYSTOLIC_MODULE_COUNT - (sys_module + 1)) * MATRIX_N+:MATRIX_N] = sv2v_tmp_sys_module_i_sys_module_forward_out_valid;
			wire [MATRIX_N * 32:1] sv2v_tmp_sys_module_i_sys_module_forward_out;
			always @(*) sys_module_forward[32 * ((SYSTOLIC_MODULE_COUNT >= 0 ? ((SYSTOLIC_MODULE_COUNT + 1) * MATRIX_N) - 1 : ((1 - SYSTOLIC_MODULE_COUNT) * MATRIX_N) + ((SYSTOLIC_MODULE_COUNT * MATRIX_N) - 1)) >= (SYSTOLIC_MODULE_COUNT >= 0 ? 0 : SYSTOLIC_MODULE_COUNT * MATRIX_N) ? ((SYSTOLIC_MODULE_COUNT >= 0 ? ((SYSTOLIC_MODULE_COUNT + 1) * MATRIX_N) - 1 : ((1 - SYSTOLIC_MODULE_COUNT) * MATRIX_N) + ((SYSTOLIC_MODULE_COUNT * MATRIX_N) - 1)) >= (SYSTOLIC_MODULE_COUNT >= 0 ? 0 : SYSTOLIC_MODULE_COUNT * MATRIX_N) ? (SYSTOLIC_MODULE_COUNT >= 0 ? sys_module + 1 : SYSTOLIC_MODULE_COUNT - (sys_module + 1)) * MATRIX_N : ((SYSTOLIC_MODULE_COUNT >= 0 ? sys_module + 1 : SYSTOLIC_MODULE_COUNT - (sys_module + 1)) * MATRIX_N) + (MATRIX_N - 1)) : (SYSTOLIC_MODULE_COUNT >= 0 ? 0 : SYSTOLIC_MODULE_COUNT * MATRIX_N) - (((SYSTOLIC_MODULE_COUNT >= 0 ? ((SYSTOLIC_MODULE_COUNT + 1) * MATRIX_N) - 1 : ((1 - SYSTOLIC_MODULE_COUNT) * MATRIX_N) + ((SYSTOLIC_MODULE_COUNT * MATRIX_N) - 1)) >= (SYSTOLIC_MODULE_COUNT >= 0 ? 0 : SYSTOLIC_MODULE_COUNT * MATRIX_N) ? (SYSTOLIC_MODULE_COUNT >= 0 ? sys_module + 1 : SYSTOLIC_MODULE_COUNT - (sys_module + 1)) * MATRIX_N : ((SYSTOLIC_MODULE_COUNT >= 0 ? sys_module + 1 : SYSTOLIC_MODULE_COUNT - (sys_module + 1)) * MATRIX_N) + (MATRIX_N - 1)) - (SYSTOLIC_MODULE_COUNT >= 0 ? ((SYSTOLIC_MODULE_COUNT + 1) * MATRIX_N) - 1 : ((1 - SYSTOLIC_MODULE_COUNT) * MATRIX_N) + ((SYSTOLIC_MODULE_COUNT * MATRIX_N) - 1))))+:32 * MATRIX_N] = sv2v_tmp_sys_module_i_sys_module_forward_out;
			systolic_module #(
				.FLOAT_WIDTH(FLOAT_WIDTH),
				.MATRIX_N(MATRIX_N)
			) sys_module_i(
				.core_clk(core_clk),
				.resetn(resetn),
				.pulse_systolic_module(pulse_systolic_module),
				.sys_module_forward_in_valid(sys_module_forward_valid[(SYSTOLIC_MODULE_COUNT >= 0 ? sys_module : SYSTOLIC_MODULE_COUNT - sys_module) * MATRIX_N+:MATRIX_N]),
				.sys_module_forward_in(sys_module_forward[32 * ((SYSTOLIC_MODULE_COUNT >= 0 ? ((SYSTOLIC_MODULE_COUNT + 1) * MATRIX_N) - 1 : ((1 - SYSTOLIC_MODULE_COUNT) * MATRIX_N) + ((SYSTOLIC_MODULE_COUNT * MATRIX_N) - 1)) >= (SYSTOLIC_MODULE_COUNT >= 0 ? 0 : SYSTOLIC_MODULE_COUNT * MATRIX_N) ? ((SYSTOLIC_MODULE_COUNT >= 0 ? ((SYSTOLIC_MODULE_COUNT + 1) * MATRIX_N) - 1 : ((1 - SYSTOLIC_MODULE_COUNT) * MATRIX_N) + ((SYSTOLIC_MODULE_COUNT * MATRIX_N) - 1)) >= (SYSTOLIC_MODULE_COUNT >= 0 ? 0 : SYSTOLIC_MODULE_COUNT * MATRIX_N) ? (SYSTOLIC_MODULE_COUNT >= 0 ? sys_module : SYSTOLIC_MODULE_COUNT - sys_module) * MATRIX_N : ((SYSTOLIC_MODULE_COUNT >= 0 ? sys_module : SYSTOLIC_MODULE_COUNT - sys_module) * MATRIX_N) + (MATRIX_N - 1)) : (SYSTOLIC_MODULE_COUNT >= 0 ? 0 : SYSTOLIC_MODULE_COUNT * MATRIX_N) - (((SYSTOLIC_MODULE_COUNT >= 0 ? ((SYSTOLIC_MODULE_COUNT + 1) * MATRIX_N) - 1 : ((1 - SYSTOLIC_MODULE_COUNT) * MATRIX_N) + ((SYSTOLIC_MODULE_COUNT * MATRIX_N) - 1)) >= (SYSTOLIC_MODULE_COUNT >= 0 ? 0 : SYSTOLIC_MODULE_COUNT * MATRIX_N) ? (SYSTOLIC_MODULE_COUNT >= 0 ? sys_module : SYSTOLIC_MODULE_COUNT - sys_module) * MATRIX_N : ((SYSTOLIC_MODULE_COUNT >= 0 ? sys_module : SYSTOLIC_MODULE_COUNT - sys_module) * MATRIX_N) + (MATRIX_N - 1)) - (SYSTOLIC_MODULE_COUNT >= 0 ? ((SYSTOLIC_MODULE_COUNT + 1) * MATRIX_N) - 1 : ((1 - SYSTOLIC_MODULE_COUNT) * MATRIX_N) + ((SYSTOLIC_MODULE_COUNT * MATRIX_N) - 1))))+:32 * MATRIX_N]),
				.sys_module_down_in_valid(sys_module_down_in_valid[(sys_module * MATRIX_N) + (MATRIX_N - 1):sys_module * MATRIX_N]),
				.sys_module_down_in(sys_module_down_in[32 * ((((sys_module * MATRIX_N) + (MATRIX_N - 1)) >= (sys_module * MATRIX_N) ? (sys_module * MATRIX_N) + (MATRIX_N - 1) : (((sys_module * MATRIX_N) + (MATRIX_N - 1)) + (((sys_module * MATRIX_N) + (MATRIX_N - 1)) >= (sys_module * MATRIX_N) ? (((sys_module * MATRIX_N) + (MATRIX_N - 1)) - (sys_module * MATRIX_N)) + 1 : ((sys_module * MATRIX_N) - ((sys_module * MATRIX_N) + (MATRIX_N - 1))) + 1)) - 1) - ((((sys_module * MATRIX_N) + (MATRIX_N - 1)) >= (sys_module * MATRIX_N) ? (((sys_module * MATRIX_N) + (MATRIX_N - 1)) - (sys_module * MATRIX_N)) + 1 : ((sys_module * MATRIX_N) - ((sys_module * MATRIX_N) + (MATRIX_N - 1))) + 1) - 1))+:32 * (((sys_module * MATRIX_N) + (MATRIX_N - 1)) >= (sys_module * MATRIX_N) ? (((sys_module * MATRIX_N) + (MATRIX_N - 1)) - (sys_module * MATRIX_N)) + 1 : ((sys_module * MATRIX_N) - ((sys_module * MATRIX_N) + (MATRIX_N - 1))) + 1)]),
				.sys_module_forward_out_valid(sv2v_tmp_sys_module_i_sys_module_forward_out_valid),
				.sys_module_forward_out(sv2v_tmp_sys_module_i_sys_module_forward_out),
				.sys_module_down_out_valid(sys_module_down_out_valid[(sys_module * MATRIX_N) + (MATRIX_N - 1):sys_module * MATRIX_N]),
				.sys_module_down_out(sys_module_down_out[32 * ((((sys_module * MATRIX_N) + (MATRIX_N - 1)) >= (sys_module * MATRIX_N) ? (sys_module * MATRIX_N) + (MATRIX_N - 1) : (((sys_module * MATRIX_N) + (MATRIX_N - 1)) + (((sys_module * MATRIX_N) + (MATRIX_N - 1)) >= (sys_module * MATRIX_N) ? (((sys_module * MATRIX_N) + (MATRIX_N - 1)) - (sys_module * MATRIX_N)) + 1 : ((sys_module * MATRIX_N) - ((sys_module * MATRIX_N) + (MATRIX_N - 1))) + 1)) - 1) - ((((sys_module * MATRIX_N) + (MATRIX_N - 1)) >= (sys_module * MATRIX_N) ? (((sys_module * MATRIX_N) + (MATRIX_N - 1)) - (sys_module * MATRIX_N)) + 1 : ((sys_module * MATRIX_N) - ((sys_module * MATRIX_N) + (MATRIX_N - 1))) + 1) - 1))+:32 * (((sys_module * MATRIX_N) + (MATRIX_N - 1)) >= (sys_module * MATRIX_N) ? (((sys_module * MATRIX_N) + (MATRIX_N - 1)) - (sys_module * MATRIX_N)) + 1 : ((sys_module * MATRIX_N) - ((sys_module * MATRIX_N) + (MATRIX_N - 1))) + 1)]),
				.bias_valid(bias_valid),
				.bias(layer_config_bias_value),
				.activation_valid(activation_valid),
				.activation(layer_config_activation_function_value),
				.shift_valid(shift_sys_module[sys_module]),
				.sys_module_pe_acc(sys_module_pe_acc[FLOAT_WIDTH * (((MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1)) >= (MATRIX_N >= 0 ? 0 : MATRIX_N + 0) ? ((((MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1)) - (MATRIX_N >= 0 ? 0 : MATRIX_N + 0)) + 1) * MATRIX_N) + (((MATRIX_N >= 0 ? 0 : MATRIX_N + 0) * MATRIX_N) - 1) : ((((MATRIX_N >= 0 ? 0 : MATRIX_N + 0) - (MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1))) + 1) * MATRIX_N) + (((MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1)) * MATRIX_N) - 1)) >= ((MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1)) >= (MATRIX_N >= 0 ? 0 : MATRIX_N + 0) ? (MATRIX_N >= 0 ? 0 : MATRIX_N + 0) * MATRIX_N : (MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1)) * MATRIX_N) ? (((MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1)) >= (MATRIX_N >= 0 ? 0 : MATRIX_N + 0) ? ((((MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1)) - (MATRIX_N >= 0 ? 0 : MATRIX_N + 0)) + 1) * MATRIX_N) + (((MATRIX_N >= 0 ? 0 : MATRIX_N + 0) * MATRIX_N) - 1) : ((((MATRIX_N >= 0 ? 0 : MATRIX_N + 0) - (MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1))) + 1) * MATRIX_N) + (((MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1)) * MATRIX_N) - 1)) >= ((MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1)) >= (MATRIX_N >= 0 ? 0 : MATRIX_N + 0) ? (MATRIX_N >= 0 ? 0 : MATRIX_N + 0) * MATRIX_N : (MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1)) * MATRIX_N) ? MATRIX_N * ((MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1)) >= (MATRIX_N >= 0 ? 0 : MATRIX_N + 0) ? ((MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1)) >= (MATRIX_N >= 0 ? 0 : MATRIX_N + 0) ? (MATRIX_N >= 0 ? 0 : MATRIX_N) + (sys_module * (MATRIX_N >= 0 ? MATRIX_N + 1 : 1 - MATRIX_N)) : ((MATRIX_N >= 0 ? 0 : MATRIX_N) + (sys_module * (MATRIX_N >= 0 ? MATRIX_N + 1 : 1 - MATRIX_N))) + ((MATRIX_N >= 0 ? MATRIX_N + 1 : 1 - MATRIX_N) - 1)) : (MATRIX_N >= 0 ? 0 : MATRIX_N + 0) - (((MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1)) >= (MATRIX_N >= 0 ? 0 : MATRIX_N + 0) ? (MATRIX_N >= 0 ? 0 : MATRIX_N) + (sys_module * (MATRIX_N >= 0 ? MATRIX_N + 1 : 1 - MATRIX_N)) : ((MATRIX_N >= 0 ? 0 : MATRIX_N) + (sys_module * (MATRIX_N >= 0 ? MATRIX_N + 1 : 1 - MATRIX_N))) + ((MATRIX_N >= 0 ? MATRIX_N + 1 : 1 - MATRIX_N) - 1)) - (MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1)))) : (MATRIX_N * ((MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1)) >= (MATRIX_N >= 0 ? 0 : MATRIX_N + 0) ? ((MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1)) >= (MATRIX_N >= 0 ? 0 : MATRIX_N + 0) ? (MATRIX_N >= 0 ? 0 : MATRIX_N) + (sys_module * (MATRIX_N >= 0 ? MATRIX_N + 1 : 1 - MATRIX_N)) : ((MATRIX_N >= 0 ? 0 : MATRIX_N) + (sys_module * (MATRIX_N >= 0 ? MATRIX_N + 1 : 1 - MATRIX_N))) + ((MATRIX_N >= 0 ? MATRIX_N + 1 : 1 - MATRIX_N) - 1)) : (MATRIX_N >= 0 ? 0 : MATRIX_N + 0) - (((MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1)) >= (MATRIX_N >= 0 ? 0 : MATRIX_N + 0) ? (MATRIX_N >= 0 ? 0 : MATRIX_N) + (sys_module * (MATRIX_N >= 0 ? MATRIX_N + 1 : 1 - MATRIX_N)) : ((MATRIX_N >= 0 ? 0 : MATRIX_N) + (sys_module * (MATRIX_N >= 0 ? MATRIX_N + 1 : 1 - MATRIX_N))) + ((MATRIX_N >= 0 ? MATRIX_N + 1 : 1 - MATRIX_N) - 1)) - (MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1))))) + ((MATRIX_N * (MATRIX_N >= 0 ? MATRIX_N + 1 : 1 - MATRIX_N)) - 1)) : ((MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1)) >= (MATRIX_N >= 0 ? 0 : MATRIX_N + 0) ? (MATRIX_N >= 0 ? 0 : MATRIX_N + 0) * MATRIX_N : (MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1)) * MATRIX_N) - ((((MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1)) >= (MATRIX_N >= 0 ? 0 : MATRIX_N + 0) ? ((((MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1)) - (MATRIX_N >= 0 ? 0 : MATRIX_N + 0)) + 1) * MATRIX_N) + (((MATRIX_N >= 0 ? 0 : MATRIX_N + 0) * MATRIX_N) - 1) : ((((MATRIX_N >= 0 ? 0 : MATRIX_N + 0) - (MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1))) + 1) * MATRIX_N) + (((MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1)) * MATRIX_N) - 1)) >= ((MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1)) >= (MATRIX_N >= 0 ? 0 : MATRIX_N + 0) ? (MATRIX_N >= 0 ? 0 : MATRIX_N + 0) * MATRIX_N : (MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1)) * MATRIX_N) ? MATRIX_N * ((MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1)) >= (MATRIX_N >= 0 ? 0 : MATRIX_N + 0) ? ((MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1)) >= (MATRIX_N >= 0 ? 0 : MATRIX_N + 0) ? (MATRIX_N >= 0 ? 0 : MATRIX_N) + (sys_module * (MATRIX_N >= 0 ? MATRIX_N + 1 : 1 - MATRIX_N)) : ((MATRIX_N >= 0 ? 0 : MATRIX_N) + (sys_module * (MATRIX_N >= 0 ? MATRIX_N + 1 : 1 - MATRIX_N))) + ((MATRIX_N >= 0 ? MATRIX_N + 1 : 1 - MATRIX_N) - 1)) : (MATRIX_N >= 0 ? 0 : MATRIX_N + 0) - (((MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1)) >= (MATRIX_N >= 0 ? 0 : MATRIX_N + 0) ? (MATRIX_N >= 0 ? 0 : MATRIX_N) + (sys_module * (MATRIX_N >= 0 ? MATRIX_N + 1 : 1 - MATRIX_N)) : ((MATRIX_N >= 0 ? 0 : MATRIX_N) + (sys_module * (MATRIX_N >= 0 ? MATRIX_N + 1 : 1 - MATRIX_N))) + ((MATRIX_N >= 0 ? MATRIX_N + 1 : 1 - MATRIX_N) - 1)) - (MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1)))) : (MATRIX_N * ((MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1)) >= (MATRIX_N >= 0 ? 0 : MATRIX_N + 0) ? ((MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1)) >= (MATRIX_N >= 0 ? 0 : MATRIX_N + 0) ? (MATRIX_N >= 0 ? 0 : MATRIX_N) + (sys_module * (MATRIX_N >= 0 ? MATRIX_N + 1 : 1 - MATRIX_N)) : ((MATRIX_N >= 0 ? 0 : MATRIX_N) + (sys_module * (MATRIX_N >= 0 ? MATRIX_N + 1 : 1 - MATRIX_N))) + ((MATRIX_N >= 0 ? MATRIX_N + 1 : 1 - MATRIX_N) - 1)) : (MATRIX_N >= 0 ? 0 : MATRIX_N + 0) - (((MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1)) >= (MATRIX_N >= 0 ? 0 : MATRIX_N + 0) ? (MATRIX_N >= 0 ? 0 : MATRIX_N) + (sys_module * (MATRIX_N >= 0 ? MATRIX_N + 1 : 1 - MATRIX_N)) : ((MATRIX_N >= 0 ? 0 : MATRIX_N) + (sys_module * (MATRIX_N >= 0 ? MATRIX_N + 1 : 1 - MATRIX_N))) + ((MATRIX_N >= 0 ? MATRIX_N + 1 : 1 - MATRIX_N) - 1)) - (MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1))))) + ((MATRIX_N * (MATRIX_N >= 0 ? MATRIX_N + 1 : 1 - MATRIX_N)) - 1)) - ((MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1)) >= (MATRIX_N >= 0 ? 0 : MATRIX_N + 0) ? ((((MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1)) - (MATRIX_N >= 0 ? 0 : MATRIX_N + 0)) + 1) * MATRIX_N) + (((MATRIX_N >= 0 ? 0 : MATRIX_N + 0) * MATRIX_N) - 1) : ((((MATRIX_N >= 0 ? 0 : MATRIX_N + 0) - (MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1))) + 1) * MATRIX_N) + (((MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1)) * MATRIX_N) - 1))))+:FLOAT_WIDTH * (MATRIX_N * (MATRIX_N >= 0 ? MATRIX_N + 1 : 1 - MATRIX_N))]),
				.diagonal_flush_done(sys_module_flush_done[sys_module]),
				.layer_config_leaky_relu_alpha_value(layer_config_leaky_relu_alpha_value)
			);
		end
	endgenerate
	rr_arbiter #(.NUM_REQUESTERS(top_pkg_TRANSFORMATION_BUFFER_SLOTS)) prefetcher_req_arb(
		.clk(core_clk),
		.resetn(resetn),
		.request(transformation_buffer_slot_free),
		.update_lru(fte_state == 4'd7),
		.grant_oh(transformation_buffer_slot_arb_oh)
	);
	hybrid_buffer_driver #(
		.BUFFER_SLOTS(top_pkg_AGGREGATION_BUFFER_SLOTS),
		.MAX_PULSES_PER_SLOT(top_pkg_MAX_FEATURE_COUNT)
	) aggregation_buffer_driver_i(
		.core_clk(core_clk),
		.resetn(resetn),
		.begin_dump(begin_feature_dump),
		.pulse(pulse_systolic_module),
		.pulse_limit(layer_config_in_features_count),
		.slot_pop_shift(slot_pop_shift)
	);
	always @(posedge core_clk or negedge resetn)
		if (!resetn)
			fte_state <= 4'd0;
		else
			fte_state <= fte_state_n;
	always @(*) begin
		fte_state_n = fte_state;
		case (fte_state)
			4'd0: fte_state_n = (nsb_fte_req_valid ? 4'd1 : 4'd0);
			4'd1: fte_state_n = (weight_channel_req_ready ? 4'd2 : 4'd1);
			4'd2: fte_state_n = (last_weight_resp_received && sys_module_flush_done[SYSTOLIC_MODULE_COUNT - 1] ? 4'd3 : 4'd2);
			4'd3: fte_state_n = 4'd4;
			4'd4: fte_state_n = 4'd5;
			4'd5: fte_state_n = (ctrl_buffering_enable_value ? 4'd6 : 4'd7);
			4'd6: fte_state_n = 4'd7;
			4'd7: fte_state_n = (((nodeslots_to_writeback == 'd1) && (sys_module_counter == SYSTOLIC_MODULE_COUNT)) && transformation_engine_axi_interconnect_axi_bvalid ? 4'd9 : ((sys_module_counter == SYSTOLIC_MODULE_COUNT) && transformation_engine_axi_interconnect_axi_bvalid ? 4'd8 : 4'd7));
			4'd8: fte_state_n = (ctrl_buffering_enable_value ? 4'd6 : (ctrl_writeback_enable_value ? 4'd7 : 4'd9));
			4'd9: fte_state_n = 4'd9;
			default: fte_state_n = 4'd0;
		endcase
	end
	always @(posedge core_clk or negedge resetn)
		if (!resetn)
			busy_aggregation_slots_snapshot <= 1'sb0;
		else if ((fte_state == 4'd0) && (fte_state_n == 4'd1))
			busy_aggregation_slots_snapshot <= ~aggregation_buffer_slot_free;
	genvar row;
	generate
		for (row = 0; row < MATRIX_N; row = row + 1) begin : genblk2
			always @(posedge core_clk or negedge resetn)
				if (!resetn)
					sys_module_node_id_snapshot[(MATRIX_N >= 0 ? row : MATRIX_N - row) * 20+:20] <= 1'sb0;
				else if ((fte_state == 4'd0) && (fte_state_n == 4'd1))
					sys_module_node_id_snapshot[(MATRIX_N >= 0 ? row : MATRIX_N - row) * 20+:20] <= aggregation_buffer_node_id[row * 20+:20];
				else if (fte_state == 4'd8)
					sys_module_node_id_snapshot[(MATRIX_N >= 0 ? row : MATRIX_N - row) * 20+:20] <= sys_module_node_id_snapshot[(MATRIX_N >= 0 ? row + 1 : MATRIX_N - (row + 1)) * 20+:20];
		end
	endgenerate
	wire [20:1] sv2v_tmp_9BC4B;
	assign sv2v_tmp_9BC4B = 1'sb0;
	always @(*) sys_module_node_id_snapshot[(MATRIX_N >= 0 ? MATRIX_N : MATRIX_N - MATRIX_N) * 20+:20] = sv2v_tmp_9BC4B;
	always @(*) begin
		begin_feature_dump = (fte_state == 4'd1) && (fte_state_n == 4'd2);
		pulse_systolic_module = ((fte_state_n == 4'd2) && weight_channel_resp_valid) && pe_delay_counter;
		sys_module_forward_valid[(SYSTOLIC_MODULE_COUNT >= 0 ? 0 : SYSTOLIC_MODULE_COUNT) * MATRIX_N+:MATRIX_N] = slot_pop_shift & busy_aggregation_slots_snapshot;
		sys_module_forward[32 * ((SYSTOLIC_MODULE_COUNT >= 0 ? ((SYSTOLIC_MODULE_COUNT + 1) * MATRIX_N) - 1 : ((1 - SYSTOLIC_MODULE_COUNT) * MATRIX_N) + ((SYSTOLIC_MODULE_COUNT * MATRIX_N) - 1)) >= (SYSTOLIC_MODULE_COUNT >= 0 ? 0 : SYSTOLIC_MODULE_COUNT * MATRIX_N) ? ((SYSTOLIC_MODULE_COUNT >= 0 ? ((SYSTOLIC_MODULE_COUNT + 1) * MATRIX_N) - 1 : ((1 - SYSTOLIC_MODULE_COUNT) * MATRIX_N) + ((SYSTOLIC_MODULE_COUNT * MATRIX_N) - 1)) >= (SYSTOLIC_MODULE_COUNT >= 0 ? 0 : SYSTOLIC_MODULE_COUNT * MATRIX_N) ? (SYSTOLIC_MODULE_COUNT >= 0 ? 0 : SYSTOLIC_MODULE_COUNT) * MATRIX_N : ((SYSTOLIC_MODULE_COUNT >= 0 ? 0 : SYSTOLIC_MODULE_COUNT) * MATRIX_N) + (MATRIX_N - 1)) : (SYSTOLIC_MODULE_COUNT >= 0 ? 0 : SYSTOLIC_MODULE_COUNT * MATRIX_N) - (((SYSTOLIC_MODULE_COUNT >= 0 ? ((SYSTOLIC_MODULE_COUNT + 1) * MATRIX_N) - 1 : ((1 - SYSTOLIC_MODULE_COUNT) * MATRIX_N) + ((SYSTOLIC_MODULE_COUNT * MATRIX_N) - 1)) >= (SYSTOLIC_MODULE_COUNT >= 0 ? 0 : SYSTOLIC_MODULE_COUNT * MATRIX_N) ? (SYSTOLIC_MODULE_COUNT >= 0 ? 0 : SYSTOLIC_MODULE_COUNT) * MATRIX_N : ((SYSTOLIC_MODULE_COUNT >= 0 ? 0 : SYSTOLIC_MODULE_COUNT) * MATRIX_N) + (MATRIX_N - 1)) - (SYSTOLIC_MODULE_COUNT >= 0 ? ((SYSTOLIC_MODULE_COUNT + 1) * MATRIX_N) - 1 : ((1 - SYSTOLIC_MODULE_COUNT) * MATRIX_N) + ((SYSTOLIC_MODULE_COUNT * MATRIX_N) - 1))))+:32 * MATRIX_N] = aggregation_buffer_out_feature;
		aggregation_buffer_pop = ((slot_pop_shift & {MATRIX_N {pulse_systolic_module}}) & busy_aggregation_slots_snapshot) & ~aggregation_buffer_slot_free;
	end
	always @(posedge core_clk or negedge resetn)
		if (!resetn)
			pe_delay_counter <= 1'sb1;
		else
			pe_delay_counter <= (begin_feature_dump ? 1'b1 : (fte_state != 4'd2 ? pe_delay_counter : !pe_delay_counter));
	always @(*) begin
		bias_valid = fte_state == 4'd4;
		activation_valid = fte_state == 4'd5;
		shift_sys_module = (fte_state == 4'd8 ? {SYSTOLIC_MODULE_COUNT {1'sb1}} : {SYSTOLIC_MODULE_COUNT {1'sb0}});
	end
	genvar slot;
	generate
		for (slot = 0; slot < top_pkg_TRANSFORMATION_BUFFER_SLOTS; slot = slot + 1) begin : genblk3
			always @(*) begin
				transformation_buffer_write_enable[slot] = transformation_buffer_slot_arb_oh[slot] && (fte_state == 4'd6);
				transformation_buffer_write_address[slot * 6+:6] = 1'sb0;
				transformation_buffer_write_data[slot * 512+:512] = sys_module_pe_acc[FLOAT_WIDTH * (((MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1)) >= (MATRIX_N >= 0 ? 0 : MATRIX_N + 0) ? ((((MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1)) - (MATRIX_N >= 0 ? 0 : MATRIX_N + 0)) + 1) * MATRIX_N) + (((MATRIX_N >= 0 ? 0 : MATRIX_N + 0) * MATRIX_N) - 1) : ((((MATRIX_N >= 0 ? 0 : MATRIX_N + 0) - (MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1))) + 1) * MATRIX_N) + (((MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1)) * MATRIX_N) - 1)) >= ((MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1)) >= (MATRIX_N >= 0 ? 0 : MATRIX_N + 0) ? (MATRIX_N >= 0 ? 0 : MATRIX_N + 0) * MATRIX_N : (MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1)) * MATRIX_N) ? (((MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1)) >= (MATRIX_N >= 0 ? 0 : MATRIX_N + 0) ? ((((MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1)) - (MATRIX_N >= 0 ? 0 : MATRIX_N + 0)) + 1) * MATRIX_N) + (((MATRIX_N >= 0 ? 0 : MATRIX_N + 0) * MATRIX_N) - 1) : ((((MATRIX_N >= 0 ? 0 : MATRIX_N + 0) - (MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1))) + 1) * MATRIX_N) + (((MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1)) * MATRIX_N) - 1)) >= ((MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1)) >= (MATRIX_N >= 0 ? 0 : MATRIX_N + 0) ? (MATRIX_N >= 0 ? 0 : MATRIX_N + 0) * MATRIX_N : (MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1)) * MATRIX_N) ? ((MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1)) >= (MATRIX_N >= 0 ? 0 : MATRIX_N + 0) ? 0 + (MATRIX_N >= 0 ? 0 : MATRIX_N) : (MATRIX_N >= 0 ? 0 : MATRIX_N + 0) - ((0 + (MATRIX_N >= 0 ? 0 : MATRIX_N)) - (MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1)))) * MATRIX_N : (((MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1)) >= (MATRIX_N >= 0 ? 0 : MATRIX_N + 0) ? 0 + (MATRIX_N >= 0 ? 0 : MATRIX_N) : (MATRIX_N >= 0 ? 0 : MATRIX_N + 0) - ((0 + (MATRIX_N >= 0 ? 0 : MATRIX_N)) - (MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1)))) * MATRIX_N) + (MATRIX_N - 1)) : ((MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1)) >= (MATRIX_N >= 0 ? 0 : MATRIX_N + 0) ? (MATRIX_N >= 0 ? 0 : MATRIX_N + 0) * MATRIX_N : (MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1)) * MATRIX_N) - ((((MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1)) >= (MATRIX_N >= 0 ? 0 : MATRIX_N + 0) ? ((((MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1)) - (MATRIX_N >= 0 ? 0 : MATRIX_N + 0)) + 1) * MATRIX_N) + (((MATRIX_N >= 0 ? 0 : MATRIX_N + 0) * MATRIX_N) - 1) : ((((MATRIX_N >= 0 ? 0 : MATRIX_N + 0) - (MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1))) + 1) * MATRIX_N) + (((MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1)) * MATRIX_N) - 1)) >= ((MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1)) >= (MATRIX_N >= 0 ? 0 : MATRIX_N + 0) ? (MATRIX_N >= 0 ? 0 : MATRIX_N + 0) * MATRIX_N : (MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1)) * MATRIX_N) ? ((MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1)) >= (MATRIX_N >= 0 ? 0 : MATRIX_N + 0) ? 0 + (MATRIX_N >= 0 ? 0 : MATRIX_N) : (MATRIX_N >= 0 ? 0 : MATRIX_N + 0) - ((0 + (MATRIX_N >= 0 ? 0 : MATRIX_N)) - (MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1)))) * MATRIX_N : (((MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1)) >= (MATRIX_N >= 0 ? 0 : MATRIX_N + 0) ? 0 + (MATRIX_N >= 0 ? 0 : MATRIX_N) : (MATRIX_N >= 0 ? 0 : MATRIX_N + 0) - ((0 + (MATRIX_N >= 0 ? 0 : MATRIX_N)) - (MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1)))) * MATRIX_N) + (MATRIX_N - 1)) - ((MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1)) >= (MATRIX_N >= 0 ? 0 : MATRIX_N + 0) ? ((((MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1)) - (MATRIX_N >= 0 ? 0 : MATRIX_N + 0)) + 1) * MATRIX_N) + (((MATRIX_N >= 0 ? 0 : MATRIX_N + 0) * MATRIX_N) - 1) : ((((MATRIX_N >= 0 ? 0 : MATRIX_N + 0) - (MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1))) + 1) * MATRIX_N) + (((MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1)) * MATRIX_N) - 1))))+:FLOAT_WIDTH * MATRIX_N];
			end
		end
	endgenerate
	always @(posedge core_clk or negedge resetn)
		if (!resetn) begin
			nodeslots_to_buffer <= 1'sb0;
			nodeslots_to_writeback <= 1'sb0;
		end
		else if (nsb_fte_req_valid && nsb_fte_req_ready) begin
			nodeslots_to_buffer <= nodeslot_count;
			nodeslots_to_writeback <= nodeslot_count;
		end
		else if (fte_state == 4'd6)
			nodeslots_to_buffer <= nodeslots_to_buffer - 1'b1;
		else if ((fte_state == 4'd7) && transformation_engine_axi_interconnect_axi_bvalid)
			nodeslots_to_writeback <= nodeslots_to_writeback - 1'b1;
	count_ones #(.INPUT_WIDTH(top_pkg_MAX_NODESLOT_COUNT)) count_nodeslots(
		.data(nsb_fte_req[31-:top_pkg_MAX_NODESLOT_COUNT]),
		.count(nodeslot_count)
	);
	assign start_memory_dump = (fte_state == 4'd6) && (fte_state_n == 4'd7);
	always @(posedge core_clk or negedge resetn)
		if (!resetn)
			sys_module_counter <= 1'sb0;
		else if ((fte_state == 4'd6) && (fte_state_n == 4'd7))
			sys_module_counter <= 1'sb0;
		else if (transformation_engine_axi_interconnect_axi_wvalid && transformation_engine_axi_interconnect_axi_wready)
			sys_module_counter <= sys_module_counter + 1'b1;
	always @(posedge core_clk or negedge resetn)
		if (!resetn)
			axi_write_state <= 2'd0;
		else
			axi_write_state <= axi_write_state_n;
	always @(*) begin
		axi_write_state_n = axi_write_state;
		case (axi_write_state)
			2'd0: axi_write_state_n = (start_memory_dump ? 2'd1 : 2'd0);
			2'd1: axi_write_state_n = (transformation_engine_axi_interconnect_axi_awready ? 2'd2 : 2'd1);
			2'd2: axi_write_state_n = ((transformation_engine_axi_interconnect_axi_wvalid && transformation_engine_axi_interconnect_axi_wready) && transformation_engine_axi_interconnect_axi_wlast ? 2'd3 : 2'd2);
			2'd3: axi_write_state_n = (transformation_engine_axi_interconnect_axi_bvalid ? 2'd0 : 2'd3);
		endcase
	end
	always @(*) begin
		out_features_required_bytes = layer_config_out_features_count * 4;
		out_features_required_bytes = {out_features_required_bytes[11:6], 6'd0} + (out_features_required_bytes[5:0] ? 'd64 : 1'b0);
		transformation_engine_axi_interconnect_axi_awvalid = axi_write_state == 2'd1;
		transformation_engine_axi_interconnect_axi_awaddr = {layer_config_out_features_address_msb_value, layer_config_out_features_address_lsb_value} + (sys_module_node_id_snapshot[(MATRIX_N >= 0 ? 0 : MATRIX_N) * 20+:20] * out_features_required_bytes);
		transformation_engine_axi_interconnect_axi_awsize = 3'b110;
		transformation_engine_axi_interconnect_axi_awburst = 2'b01;
		transformation_engine_axi_interconnect_axi_awlen = SYSTOLIC_MODULE_COUNT[7:0] - 1'b1;
		transformation_engine_axi_interconnect_axi_awcache = 1'sb0;
		transformation_engine_axi_interconnect_axi_awid = 1'sb0;
		transformation_engine_axi_interconnect_axi_awlock = 1'sb0;
		transformation_engine_axi_interconnect_axi_awprot = 1'sb0;
		transformation_engine_axi_interconnect_axi_awqos = 1'sb0;
		transformation_engine_axi_interconnect_axi_wvalid = axi_write_state == 2'd2;
		transformation_engine_axi_interconnect_axi_wdata = sys_module_pe_acc[FLOAT_WIDTH * (((MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1)) >= (MATRIX_N >= 0 ? 0 : MATRIX_N + 0) ? ((((MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1)) - (MATRIX_N >= 0 ? 0 : MATRIX_N + 0)) + 1) * MATRIX_N) + (((MATRIX_N >= 0 ? 0 : MATRIX_N + 0) * MATRIX_N) - 1) : ((((MATRIX_N >= 0 ? 0 : MATRIX_N + 0) - (MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1))) + 1) * MATRIX_N) + (((MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1)) * MATRIX_N) - 1)) >= ((MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1)) >= (MATRIX_N >= 0 ? 0 : MATRIX_N + 0) ? (MATRIX_N >= 0 ? 0 : MATRIX_N + 0) * MATRIX_N : (MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1)) * MATRIX_N) ? (((MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1)) >= (MATRIX_N >= 0 ? 0 : MATRIX_N + 0) ? ((((MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1)) - (MATRIX_N >= 0 ? 0 : MATRIX_N + 0)) + 1) * MATRIX_N) + (((MATRIX_N >= 0 ? 0 : MATRIX_N + 0) * MATRIX_N) - 1) : ((((MATRIX_N >= 0 ? 0 : MATRIX_N + 0) - (MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1))) + 1) * MATRIX_N) + (((MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1)) * MATRIX_N) - 1)) >= ((MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1)) >= (MATRIX_N >= 0 ? 0 : MATRIX_N + 0) ? (MATRIX_N >= 0 ? 0 : MATRIX_N + 0) * MATRIX_N : (MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1)) * MATRIX_N) ? ((MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1)) >= (MATRIX_N >= 0 ? 0 : MATRIX_N + 0) ? (sys_module_counter * (MATRIX_N >= 0 ? MATRIX_N + 1 : 1 - MATRIX_N)) + (MATRIX_N >= 0 ? 0 : MATRIX_N) : (MATRIX_N >= 0 ? 0 : MATRIX_N + 0) - (((sys_module_counter * (MATRIX_N >= 0 ? MATRIX_N + 1 : 1 - MATRIX_N)) + (MATRIX_N >= 0 ? 0 : MATRIX_N)) - (MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1)))) * MATRIX_N : (((MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1)) >= (MATRIX_N >= 0 ? 0 : MATRIX_N + 0) ? (sys_module_counter * (MATRIX_N >= 0 ? MATRIX_N + 1 : 1 - MATRIX_N)) + (MATRIX_N >= 0 ? 0 : MATRIX_N) : (MATRIX_N >= 0 ? 0 : MATRIX_N + 0) - (((sys_module_counter * (MATRIX_N >= 0 ? MATRIX_N + 1 : 1 - MATRIX_N)) + (MATRIX_N >= 0 ? 0 : MATRIX_N)) - (MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1)))) * MATRIX_N) + (MATRIX_N - 1)) : ((MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1)) >= (MATRIX_N >= 0 ? 0 : MATRIX_N + 0) ? (MATRIX_N >= 0 ? 0 : MATRIX_N + 0) * MATRIX_N : (MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1)) * MATRIX_N) - ((((MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1)) >= (MATRIX_N >= 0 ? 0 : MATRIX_N + 0) ? ((((MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1)) - (MATRIX_N >= 0 ? 0 : MATRIX_N + 0)) + 1) * MATRIX_N) + (((MATRIX_N >= 0 ? 0 : MATRIX_N + 0) * MATRIX_N) - 1) : ((((MATRIX_N >= 0 ? 0 : MATRIX_N + 0) - (MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1))) + 1) * MATRIX_N) + (((MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1)) * MATRIX_N) - 1)) >= ((MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1)) >= (MATRIX_N >= 0 ? 0 : MATRIX_N + 0) ? (MATRIX_N >= 0 ? 0 : MATRIX_N + 0) * MATRIX_N : (MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1)) * MATRIX_N) ? ((MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1)) >= (MATRIX_N >= 0 ? 0 : MATRIX_N + 0) ? (sys_module_counter * (MATRIX_N >= 0 ? MATRIX_N + 1 : 1 - MATRIX_N)) + (MATRIX_N >= 0 ? 0 : MATRIX_N) : (MATRIX_N >= 0 ? 0 : MATRIX_N + 0) - (((sys_module_counter * (MATRIX_N >= 0 ? MATRIX_N + 1 : 1 - MATRIX_N)) + (MATRIX_N >= 0 ? 0 : MATRIX_N)) - (MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1)))) * MATRIX_N : (((MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1)) >= (MATRIX_N >= 0 ? 0 : MATRIX_N + 0) ? (sys_module_counter * (MATRIX_N >= 0 ? MATRIX_N + 1 : 1 - MATRIX_N)) + (MATRIX_N >= 0 ? 0 : MATRIX_N) : (MATRIX_N >= 0 ? 0 : MATRIX_N + 0) - (((sys_module_counter * (MATRIX_N >= 0 ? MATRIX_N + 1 : 1 - MATRIX_N)) + (MATRIX_N >= 0 ? 0 : MATRIX_N)) - (MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1)))) * MATRIX_N) + (MATRIX_N - 1)) - ((MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1)) >= (MATRIX_N >= 0 ? 0 : MATRIX_N + 0) ? ((((MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1)) - (MATRIX_N >= 0 ? 0 : MATRIX_N + 0)) + 1) * MATRIX_N) + (((MATRIX_N >= 0 ? 0 : MATRIX_N + 0) * MATRIX_N) - 1) : ((((MATRIX_N >= 0 ? 0 : MATRIX_N + 0) - (MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1))) + 1) * MATRIX_N) + (((MATRIX_N >= 0 ? (SYSTOLIC_MODULE_COUNT * (MATRIX_N + 1)) - 1 : (SYSTOLIC_MODULE_COUNT * (1 - MATRIX_N)) + (MATRIX_N - 1)) * MATRIX_N) - 1))))+:FLOAT_WIDTH * MATRIX_N];
		transformation_engine_axi_interconnect_axi_wlast = sys_module_counter == (SYSTOLIC_MODULE_COUNT - 1);
		transformation_engine_axi_interconnect_axi_wstrb = 1'sb1;
		transformation_engine_axi_interconnect_axi_bready = axi_write_state == 2'd3;
	end
	always @(*) begin
		nsb_fte_req_ready = fte_state == 4'd0;
		nsb_fte_resp_valid = fte_state == 4'd9;
		nsb_fte_resp = 1'sb0;
	end
	always @(*) begin
		weight_channel_req_valid = fte_state == 4'd1;
		weight_channel_req[21-:11] = top_pkg_MAX_FEATURE_COUNT;
		weight_channel_req[10-:11] = top_pkg_MAX_FEATURE_COUNT;
		weight_channel_resp_ready = (fte_state == 4'd2) && (pulse_systolic_module || weight_channel_resp[0]);
	end
	always @(posedge core_clk or negedge resetn)
		if (!resetn)
			last_weight_resp_received <= 1'sb0;
		else if (weight_channel_resp_valid && weight_channel_resp[0])
			last_weight_resp_received <= 1'sb1;
	always @(*) begin
		transformation_engine_axi_interconnect_axi_araddr = 1'sb0;
		transformation_engine_axi_interconnect_axi_arburst = 1'sb0;
		transformation_engine_axi_interconnect_axi_arcache = 1'sb0;
		transformation_engine_axi_interconnect_axi_arid = 1'sb0;
		transformation_engine_axi_interconnect_axi_arlen = 1'sb0;
		transformation_engine_axi_interconnect_axi_arlock = 1'sb0;
		transformation_engine_axi_interconnect_axi_arprot = 1'sb0;
		transformation_engine_axi_interconnect_axi_arqos = 1'sb0;
		transformation_engine_axi_interconnect_axi_arsize = 1'sb0;
		transformation_engine_axi_interconnect_axi_arvalid = 1'sb0;
		transformation_engine_axi_interconnect_axi_rready = 1'sb0;
	end
endmodule
module top (
	sys_clk,
	sys_rst,
	host_axil_awaddr,
	host_axil_awprot,
	host_axil_awvalid,
	host_axil_awready,
	host_axil_wdata,
	host_axil_wstrb,
	host_axil_wvalid,
	host_axil_bready,
	host_axil_araddr,
	host_axil_arprot,
	host_axil_arvalid,
	host_axil_rready,
	host_axil_wready,
	host_axil_bresp,
	host_axil_bvalid,
	host_axil_arready,
	host_axil_rdata,
	host_axil_rresp,
	host_axil_rvalid,
	c0_ddr4_s_axi_awid,
	c0_ddr4_s_axi_awaddr,
	c0_ddr4_s_axi_awlen,
	c0_ddr4_s_axi_awsize,
	c0_ddr4_s_axi_awburst,
	c0_ddr4_s_axi_awlock,
	c0_ddr4_s_axi_awcache,
	c0_ddr4_s_axi_awprot,
	c0_ddr4_s_axi_awqos,
	c0_ddr4_s_axi_awvalid,
	c0_ddr4_s_axi_awready,
	c0_ddr4_s_axi_wdata,
	c0_ddr4_s_axi_wstrb,
	c0_ddr4_s_axi_wlast,
	c0_ddr4_s_axi_wvalid,
	c0_ddr4_s_axi_wready,
	c0_ddr4_s_axi_bid,
	c0_ddr4_s_axi_bresp,
	c0_ddr4_s_axi_bvalid,
	c0_ddr4_s_axi_bready,
	c0_ddr4_s_axi_arid,
	c0_ddr4_s_axi_araddr,
	c0_ddr4_s_axi_arlen,
	c0_ddr4_s_axi_arsize,
	c0_ddr4_s_axi_arburst,
	c0_ddr4_s_axi_arlock,
	c0_ddr4_s_axi_arcache,
	c0_ddr4_s_axi_arprot,
	c0_ddr4_s_axi_arqos,
	c0_ddr4_s_axi_arvalid,
	c0_ddr4_s_axi_arready,
	c0_ddr4_s_axi_rid,
	c0_ddr4_s_axi_rdata,
	c0_ddr4_s_axi_rresp,
	c0_ddr4_s_axi_rlast,
	c0_ddr4_s_axi_rvalid,
	c0_ddr4_s_axi_rready
);
	input wire sys_clk;
	input sys_rst;
	input wire [31:0] host_axil_awaddr;
	input wire [2:0] host_axil_awprot;
	input wire [0:0] host_axil_awvalid;
	output wire [0:0] host_axil_awready;
	input wire [31:0] host_axil_wdata;
	input wire [3:0] host_axil_wstrb;
	input wire [0:0] host_axil_wvalid;
	input wire [0:0] host_axil_bready;
	input wire [31:0] host_axil_araddr;
	input wire [2:0] host_axil_arprot;
	input wire [0:0] host_axil_arvalid;
	input wire [0:0] host_axil_rready;
	output wire [0:0] host_axil_wready;
	output wire [1:0] host_axil_bresp;
	output wire [0:0] host_axil_bvalid;
	output wire [0:0] host_axil_arready;
	output wire [31:0] host_axil_rdata;
	output wire [1:0] host_axil_rresp;
	output wire [0:0] host_axil_rvalid;
	output wire [7:0] c0_ddr4_s_axi_awid;
	output wire [33:0] c0_ddr4_s_axi_awaddr;
	output wire [7:0] c0_ddr4_s_axi_awlen;
	output wire [2:0] c0_ddr4_s_axi_awsize;
	output wire [1:0] c0_ddr4_s_axi_awburst;
	output wire [0:0] c0_ddr4_s_axi_awlock;
	output wire [3:0] c0_ddr4_s_axi_awcache;
	output wire [2:0] c0_ddr4_s_axi_awprot;
	output wire [3:0] c0_ddr4_s_axi_awqos;
	output wire c0_ddr4_s_axi_awvalid;
	input wire c0_ddr4_s_axi_awready;
	output wire [511:0] c0_ddr4_s_axi_wdata;
	output wire [63:0] c0_ddr4_s_axi_wstrb;
	output wire c0_ddr4_s_axi_wlast;
	output wire c0_ddr4_s_axi_wvalid;
	input wire c0_ddr4_s_axi_wready;
	input wire [7:0] c0_ddr4_s_axi_bid;
	input wire [1:0] c0_ddr4_s_axi_bresp;
	input wire c0_ddr4_s_axi_bvalid;
	output wire c0_ddr4_s_axi_bready;
	output wire [7:0] c0_ddr4_s_axi_arid;
	output wire [33:0] c0_ddr4_s_axi_araddr;
	output wire [7:0] c0_ddr4_s_axi_arlen;
	output wire [2:0] c0_ddr4_s_axi_arsize;
	output wire [1:0] c0_ddr4_s_axi_arburst;
	output wire [0:0] c0_ddr4_s_axi_arlock;
	output wire [3:0] c0_ddr4_s_axi_arcache;
	output wire [2:0] c0_ddr4_s_axi_arprot;
	output wire [3:0] c0_ddr4_s_axi_arqos;
	output wire c0_ddr4_s_axi_arvalid;
	input wire c0_ddr4_s_axi_arready;
	input wire [7:0] c0_ddr4_s_axi_rid;
	input wire [511:0] c0_ddr4_s_axi_rdata;
	input wire [1:0] c0_ddr4_s_axi_rresp;
	input wire c0_ddr4_s_axi_rlast;
	input wire c0_ddr4_s_axi_rvalid;
	output wire c0_ddr4_s_axi_rready;
	wire [127:0] axil_interconnect_m_axi_awaddr;
	wire [11:0] axil_interconnect_m_axi_awprot;
	wire [3:0] axil_interconnect_m_axi_awvalid;
	wire [3:0] axil_interconnect_m_axi_awready;
	wire [127:0] axil_interconnect_m_axi_wdata;
	wire [15:0] axil_interconnect_m_axi_wstrb;
	wire [3:0] axil_interconnect_m_axi_wvalid;
	wire [3:0] axil_interconnect_m_axi_wready;
	wire [7:0] axil_interconnect_m_axi_bresp;
	wire [3:0] axil_interconnect_m_axi_bvalid;
	wire [3:0] axil_interconnect_m_axi_bready;
	wire [127:0] axil_interconnect_m_axi_araddr;
	wire [11:0] axil_interconnect_m_axi_arprot;
	wire [3:0] axil_interconnect_m_axi_arvalid;
	wire [3:0] axil_interconnect_m_axi_arready;
	wire [127:0] axil_interconnect_m_axi_rdata;
	wire [7:0] axil_interconnect_m_axi_rresp;
	wire [3:0] axil_interconnect_m_axi_rvalid;
	wire [3:0] axil_interconnect_m_axi_rready;
	wire [33:0] prefetcher_adj_rm_axi_interconnect_axi_araddr;
	wire [1:0] prefetcher_adj_rm_axi_interconnect_axi_arburst;
	wire [3:0] prefetcher_adj_rm_axi_interconnect_axi_arcache;
	wire [3:0] prefetcher_adj_rm_axi_interconnect_axi_arid;
	wire [7:0] prefetcher_adj_rm_axi_interconnect_axi_arlen;
	wire [0:0] prefetcher_adj_rm_axi_interconnect_axi_arlock;
	wire [2:0] prefetcher_adj_rm_axi_interconnect_axi_arprot;
	wire [3:0] prefetcher_adj_rm_axi_interconnect_axi_arqos;
	wire [2:0] prefetcher_adj_rm_axi_interconnect_axi_arsize;
	wire prefetcher_adj_rm_axi_interconnect_axi_arvalid;
	wire prefetcher_adj_rm_axi_interconnect_axi_arready;
	wire [33:0] prefetcher_adj_rm_axi_interconnect_axi_awaddr;
	wire [1:0] prefetcher_adj_rm_axi_interconnect_axi_awburst;
	wire [3:0] prefetcher_adj_rm_axi_interconnect_axi_awcache;
	wire [3:0] prefetcher_adj_rm_axi_interconnect_axi_awid;
	wire [7:0] prefetcher_adj_rm_axi_interconnect_axi_awlen;
	wire [0:0] prefetcher_adj_rm_axi_interconnect_axi_awlock;
	wire [2:0] prefetcher_adj_rm_axi_interconnect_axi_awprot;
	wire [3:0] prefetcher_adj_rm_axi_interconnect_axi_awqos;
	wire prefetcher_adj_rm_axi_interconnect_axi_awready;
	wire [2:0] prefetcher_adj_rm_axi_interconnect_axi_awsize;
	wire prefetcher_adj_rm_axi_interconnect_axi_awvalid;
	wire [3:0] prefetcher_adj_rm_axi_interconnect_axi_bid;
	wire prefetcher_adj_rm_axi_interconnect_axi_bready;
	wire [1:0] prefetcher_adj_rm_axi_interconnect_axi_bresp;
	wire prefetcher_adj_rm_axi_interconnect_axi_bvalid;
	wire [511:0] prefetcher_adj_rm_axi_interconnect_axi_rdata;
	wire [3:0] prefetcher_adj_rm_axi_interconnect_axi_rid;
	wire prefetcher_adj_rm_axi_interconnect_axi_rlast;
	wire prefetcher_adj_rm_axi_interconnect_axi_rready;
	wire [1:0] prefetcher_adj_rm_axi_interconnect_axi_rresp;
	wire prefetcher_adj_rm_axi_interconnect_axi_rvalid;
	wire [511:0] prefetcher_adj_rm_axi_interconnect_axi_wdata;
	wire prefetcher_adj_rm_axi_interconnect_axi_wlast;
	wire prefetcher_adj_rm_axi_interconnect_axi_wready;
	wire [63:0] prefetcher_adj_rm_axi_interconnect_axi_wstrb;
	wire prefetcher_adj_rm_axi_interconnect_axi_wvalid;
	wire [33:0] prefetcher_msg_rm_axi_interconnect_axi_araddr;
	wire [1:0] prefetcher_msg_rm_axi_interconnect_axi_arburst;
	wire [3:0] prefetcher_msg_rm_axi_interconnect_axi_arcache;
	wire [3:0] prefetcher_msg_rm_axi_interconnect_axi_arid;
	wire [7:0] prefetcher_msg_rm_axi_interconnect_axi_arlen;
	wire [0:0] prefetcher_msg_rm_axi_interconnect_axi_arlock;
	wire [2:0] prefetcher_msg_rm_axi_interconnect_axi_arprot;
	wire [3:0] prefetcher_msg_rm_axi_interconnect_axi_arqos;
	wire [2:0] prefetcher_msg_rm_axi_interconnect_axi_arsize;
	wire prefetcher_msg_rm_axi_interconnect_axi_arvalid;
	wire prefetcher_msg_rm_axi_interconnect_axi_arready;
	wire [33:0] prefetcher_msg_rm_axi_interconnect_axi_awaddr;
	wire [1:0] prefetcher_msg_rm_axi_interconnect_axi_awburst;
	wire [3:0] prefetcher_msg_rm_axi_interconnect_axi_awcache;
	wire [3:0] prefetcher_msg_rm_axi_interconnect_axi_awid;
	wire [7:0] prefetcher_msg_rm_axi_interconnect_axi_awlen;
	wire [0:0] prefetcher_msg_rm_axi_interconnect_axi_awlock;
	wire [2:0] prefetcher_msg_rm_axi_interconnect_axi_awprot;
	wire [3:0] prefetcher_msg_rm_axi_interconnect_axi_awqos;
	wire prefetcher_msg_rm_axi_interconnect_axi_awready;
	wire [2:0] prefetcher_msg_rm_axi_interconnect_axi_awsize;
	wire prefetcher_msg_rm_axi_interconnect_axi_awvalid;
	wire [3:0] prefetcher_msg_rm_axi_interconnect_axi_bid;
	wire prefetcher_msg_rm_axi_interconnect_axi_bready;
	wire [1:0] prefetcher_msg_rm_axi_interconnect_axi_bresp;
	wire prefetcher_msg_rm_axi_interconnect_axi_bvalid;
	wire [511:0] prefetcher_msg_rm_axi_interconnect_axi_rdata;
	wire [3:0] prefetcher_msg_rm_axi_interconnect_axi_rid;
	wire prefetcher_msg_rm_axi_interconnect_axi_rlast;
	wire prefetcher_msg_rm_axi_interconnect_axi_rready;
	wire [1:0] prefetcher_msg_rm_axi_interconnect_axi_rresp;
	wire prefetcher_msg_rm_axi_interconnect_axi_rvalid;
	wire [511:0] prefetcher_msg_rm_axi_interconnect_axi_wdata;
	wire prefetcher_msg_rm_axi_interconnect_axi_wlast;
	wire prefetcher_msg_rm_axi_interconnect_axi_wready;
	wire [63:0] prefetcher_msg_rm_axi_interconnect_axi_wstrb;
	wire prefetcher_msg_rm_axi_interconnect_axi_wvalid;
	wire [33:0] prefetcher_weight_bank_rm_axi_interconnect_axi_araddr;
	wire [1:0] prefetcher_weight_bank_rm_axi_interconnect_axi_arburst;
	wire [3:0] prefetcher_weight_bank_rm_axi_interconnect_axi_arcache;
	wire [3:0] prefetcher_weight_bank_rm_axi_interconnect_axi_arid;
	wire [7:0] prefetcher_weight_bank_rm_axi_interconnect_axi_arlen;
	wire [0:0] prefetcher_weight_bank_rm_axi_interconnect_axi_arlock;
	wire [2:0] prefetcher_weight_bank_rm_axi_interconnect_axi_arprot;
	wire [3:0] prefetcher_weight_bank_rm_axi_interconnect_axi_arqos;
	wire [2:0] prefetcher_weight_bank_rm_axi_interconnect_axi_arsize;
	wire prefetcher_weight_bank_rm_axi_interconnect_axi_arvalid;
	wire prefetcher_weight_bank_rm_axi_interconnect_axi_arready;
	wire [33:0] prefetcher_weight_bank_rm_axi_interconnect_axi_awaddr;
	wire [1:0] prefetcher_weight_bank_rm_axi_interconnect_axi_awburst;
	wire [3:0] prefetcher_weight_bank_rm_axi_interconnect_axi_awcache;
	wire [3:0] prefetcher_weight_bank_rm_axi_interconnect_axi_awid;
	wire [7:0] prefetcher_weight_bank_rm_axi_interconnect_axi_awlen;
	wire [0:0] prefetcher_weight_bank_rm_axi_interconnect_axi_awlock;
	wire [2:0] prefetcher_weight_bank_rm_axi_interconnect_axi_awprot;
	wire [3:0] prefetcher_weight_bank_rm_axi_interconnect_axi_awqos;
	wire prefetcher_weight_bank_rm_axi_interconnect_axi_awready;
	wire [2:0] prefetcher_weight_bank_rm_axi_interconnect_axi_awsize;
	wire prefetcher_weight_bank_rm_axi_interconnect_axi_awvalid;
	wire [3:0] prefetcher_weight_bank_rm_axi_interconnect_axi_bid;
	wire prefetcher_weight_bank_rm_axi_interconnect_axi_bready;
	wire [1:0] prefetcher_weight_bank_rm_axi_interconnect_axi_bresp;
	wire prefetcher_weight_bank_rm_axi_interconnect_axi_bvalid;
	wire [511:0] prefetcher_weight_bank_rm_axi_interconnect_axi_rdata;
	wire [3:0] prefetcher_weight_bank_rm_axi_interconnect_axi_rid;
	wire prefetcher_weight_bank_rm_axi_interconnect_axi_rlast;
	wire prefetcher_weight_bank_rm_axi_interconnect_axi_rready;
	wire [1:0] prefetcher_weight_bank_rm_axi_interconnect_axi_rresp;
	wire prefetcher_weight_bank_rm_axi_interconnect_axi_rvalid;
	wire [511:0] prefetcher_weight_bank_rm_axi_interconnect_axi_wdata;
	wire prefetcher_weight_bank_rm_axi_interconnect_axi_wlast;
	wire prefetcher_weight_bank_rm_axi_interconnect_axi_wready;
	wire [63:0] prefetcher_weight_bank_rm_axi_interconnect_axi_wstrb;
	wire prefetcher_weight_bank_rm_axi_interconnect_axi_wvalid;
	wire [33:0] transformation_engine_axi_interconnect_axi_araddr;
	wire [1:0] transformation_engine_axi_interconnect_axi_arburst;
	wire [3:0] transformation_engine_axi_interconnect_axi_arcache;
	wire [3:0] transformation_engine_axi_interconnect_axi_arid;
	wire [7:0] transformation_engine_axi_interconnect_axi_arlen;
	wire [0:0] transformation_engine_axi_interconnect_axi_arlock;
	wire [2:0] transformation_engine_axi_interconnect_axi_arprot;
	wire [3:0] transformation_engine_axi_interconnect_axi_arqos;
	wire [2:0] transformation_engine_axi_interconnect_axi_arsize;
	wire transformation_engine_axi_interconnect_axi_arvalid;
	wire transformation_engine_axi_interconnect_axi_arready;
	wire [33:0] transformation_engine_axi_interconnect_axi_awaddr;
	wire [1:0] transformation_engine_axi_interconnect_axi_awburst;
	wire [3:0] transformation_engine_axi_interconnect_axi_awcache;
	wire [3:0] transformation_engine_axi_interconnect_axi_awid;
	wire [7:0] transformation_engine_axi_interconnect_axi_awlen;
	wire [0:0] transformation_engine_axi_interconnect_axi_awlock;
	wire [2:0] transformation_engine_axi_interconnect_axi_awprot;
	wire [3:0] transformation_engine_axi_interconnect_axi_awqos;
	wire transformation_engine_axi_interconnect_axi_awready;
	wire [2:0] transformation_engine_axi_interconnect_axi_awsize;
	wire transformation_engine_axi_interconnect_axi_awvalid;
	wire [3:0] transformation_engine_axi_interconnect_axi_bid;
	wire transformation_engine_axi_interconnect_axi_bready;
	wire [1:0] transformation_engine_axi_interconnect_axi_bresp;
	wire transformation_engine_axi_interconnect_axi_bvalid;
	wire [511:0] transformation_engine_axi_interconnect_axi_rdata;
	wire [3:0] transformation_engine_axi_interconnect_axi_rid;
	wire transformation_engine_axi_interconnect_axi_rlast;
	wire transformation_engine_axi_interconnect_axi_rready;
	wire [1:0] transformation_engine_axi_interconnect_axi_rresp;
	wire transformation_engine_axi_interconnect_axi_rvalid;
	wire [511:0] transformation_engine_axi_interconnect_axi_wdata;
	wire transformation_engine_axi_interconnect_axi_wlast;
	wire transformation_engine_axi_interconnect_axi_wready;
	wire [63:0] transformation_engine_axi_interconnect_axi_wstrb;
	wire transformation_engine_axi_interconnect_axi_wvalid;
	wire S00_AXI_ARESET_OUT_N;
	wire S01_AXI_ARESET_OUT_N;
	wire S02_AXI_ARESET_OUT_N;
	wire S03_AXI_ARESET_OUT_N;
	wire S04_AXI_ARESET_OUT_N;
	wire S05_AXI_ARESET_OUT_N;
	wire S06_AXI_ARESET_OUT_N;
	wire S07_AXI_ARESET_OUT_N;
	wire M00_AXI_ARESET_OUT_N;
	wire nsb_age_req_valid;
	wire nsb_age_req_ready;
	localparam top_pkg_MAX_NODESLOT_COUNT = 32;
	localparam top_pkg_FETCH_TAG_COUNT = top_pkg_MAX_NODESLOT_COUNT;
	localparam top_pkg_MAX_NODES = 1048576;
	localparam top_pkg_NODE_ID_WIDTH = 20;
	wire [33:0] nsb_age_req;
	wire nsb_age_resp_valid;
	wire [4:0] nsb_age_resp;
	wire nsb_fte_req_valid;
	wire nsb_fte_req_ready;
	wire [31:0] nsb_fte_req;
	wire nsb_fte_resp_valid;
	wire [31:0] nsb_fte_resp;
	wire nsb_prefetcher_req_valid;
	wire nsb_prefetcher_req_ready;
	localparam top_pkg_AXI_ADDRESS_WIDTH = 34;
	localparam top_pkg_MAX_FEATURE_COUNT = 1024;
	localparam top_pkg_MAX_NEIGHBOURS = 1024;
	wire [75:0] nsb_prefetcher_req;
	wire nsb_prefetcher_resp_valid;
	wire [13:0] nsb_prefetcher_resp;
	wire nsb_output_buffer_req_valid;
	wire nsb_output_buffer_req_ready;
	wire [31:0] nsb_output_buffer_req;
	wire nsb_output_buffer_resp_valid;
	wire [4:0] nsb_output_buffer_resp;
	localparam top_pkg_MESSAGE_CHANNEL_COUNT = top_pkg_MAX_NODESLOT_COUNT;
	wire [31:0] message_channel_req_valid;
	wire [31:0] message_channel_req_ready;
	wire [319:0] message_channel_req;
	wire [31:0] message_channel_resp_valid;
	wire [31:0] message_channel_resp_ready;
	localparam top_pkg_AXI_DATA_WIDTH = 512;
	wire [16447:0] message_channel_resp;
	wire weight_channel_req_valid;
	wire weight_channel_req_ready;
	wire [21:0] weight_channel_req;
	wire weight_channel_resp_valid;
	wire weight_channel_resp_ready;
	wire [33792:0] weight_channel_resp;
	localparam top_pkg_AGGREGATION_BUFFER_SLOTS = 16;
	wire [15:0] aggregation_buffer_set_node_id_valid;
	wire [319:0] aggregation_buffer_set_node_id;
	wire [15:0] aggregation_buffer_write_enable;
	localparam top_pkg_AGGREGATION_BUFFER_WRITE_DEPTH = 512;
	wire [143:0] aggregation_buffer_write_address;
	localparam top_pkg_AGGREGATION_BUFFER_WRITE_WIDTH = 64;
	wire [1023:0] aggregation_buffer_write_data;
	localparam top_pkg_AGGREGATION_BUFFER_READ_DEPTH = 1024;
	wire [159:0] aggregation_buffer_feature_count;
	wire [319:0] aggregation_buffer_node_id;
	wire [15:0] aggregation_buffer_pop;
	localparam top_pkg_AGGREGATION_BUFFER_READ_WIDTH = 32;
	wire [511:0] aggregation_buffer_out_feature;
	wire [15:0] aggregation_buffer_slot_free;
	localparam top_pkg_TRANSFORMATION_BUFFER_SLOTS = 16;
	wire [15:0] transformation_buffer_write_enable;
	localparam top_pkg_TRANSFORMATION_BUFFER_WRITE_DEPTH = 64;
	wire [95:0] transformation_buffer_write_address;
	localparam top_pkg_TRANSFORMATION_BUFFER_WRITE_WIDTH = 512;
	wire [8191:0] transformation_buffer_write_data;
	localparam top_pkg_TRANSFORMATION_BUFFER_READ_DEPTH = 1024;
	wire [159:0] transformation_buffer_feature_count;
	wire [15:0] transformation_buffer_pop;
	localparam top_pkg_TRANSFORMATION_BUFFER_READ_WIDTH = 32;
	wire [511:0] transformation_buffer_out_feature;
	wire [15:0] transformation_buffer_slot_free;
	wire [31:0] scale_factor_queue_pop;
	localparam top_pkg_SCALE_FACTOR_QUEUE_READ_WIDTH = 32;
	wire [1023:0] scale_factor_queue_out_data;
	localparam top_pkg_SCALE_FACTOR_QUEUE_READ_DEPTH = 1024;
	wire [351:0] scale_factor_queue_count;
	wire [31:0] scale_factor_queue_empty;
	wire [31:0] scale_factor_queue_full;
	node_scoreboard #(.NODESLOT_COUNT(top_pkg_MAX_NODESLOT_COUNT)) node_scoreboard_i(
		.core_clk(sys_clk),
		.resetn(!sys_rst),
		.s_axi_awaddr(axil_interconnect_m_axi_awaddr[95:64]),
		.s_axi_awprot(axil_interconnect_m_axi_awprot[8:6]),
		.s_axi_awvalid(axil_interconnect_m_axi_awvalid[2:2]),
		.s_axi_awready(axil_interconnect_m_axi_awready[2:2]),
		.s_axi_wdata(axil_interconnect_m_axi_wdata[95:64]),
		.s_axi_wstrb(axil_interconnect_m_axi_wstrb[11:8]),
		.s_axi_wvalid(axil_interconnect_m_axi_wvalid[2:2]),
		.s_axi_wready(axil_interconnect_m_axi_wready[2:2]),
		.s_axi_bresp(axil_interconnect_m_axi_bresp[5:4]),
		.s_axi_bvalid(axil_interconnect_m_axi_bvalid[2:2]),
		.s_axi_bready(axil_interconnect_m_axi_bready[2:2]),
		.s_axi_araddr(axil_interconnect_m_axi_araddr[95:64]),
		.s_axi_arprot(axil_interconnect_m_axi_arprot[8:6]),
		.s_axi_arvalid(axil_interconnect_m_axi_arvalid[2:2]),
		.s_axi_arready(axil_interconnect_m_axi_arready[2:2]),
		.s_axi_rdata(axil_interconnect_m_axi_rdata[95:64]),
		.s_axi_rresp(axil_interconnect_m_axi_rresp[5:4]),
		.s_axi_rvalid(axil_interconnect_m_axi_rvalid[2:2]),
		.s_axi_rready(axil_interconnect_m_axi_rready[2:2]),
		.nsb_age_req_valid(nsb_age_req_valid),
		.nsb_age_req_ready(nsb_age_req_ready),
		.nsb_age_req(nsb_age_req),
		.nsb_age_resp_valid(nsb_age_resp_valid),
		.nsb_age_resp(nsb_age_resp),
		.nsb_fte_req_valid(nsb_fte_req_valid),
		.nsb_fte_req_ready(nsb_fte_req_ready),
		.nsb_fte_req(nsb_fte_req),
		.nsb_fte_resp_valid(nsb_fte_resp_valid),
		.nsb_fte_resp(nsb_fte_resp),
		.nsb_prefetcher_req_valid(nsb_prefetcher_req_valid),
		.nsb_prefetcher_req_ready(nsb_prefetcher_req_ready),
		.nsb_prefetcher_req(nsb_prefetcher_req),
		.nsb_prefetcher_resp_valid(nsb_prefetcher_resp_valid),
		.nsb_prefetcher_resp(nsb_prefetcher_resp),
		.nsb_output_buffer_req_valid(nsb_output_buffer_req_valid),
		.nsb_output_buffer_req_ready(nsb_output_buffer_req_ready),
		.nsb_output_buffer_req(nsb_output_buffer_req),
		.nsb_output_buffer_resp_valid(nsb_output_buffer_resp_valid),
		.nsb_output_buffer_resp(nsb_output_buffer_resp)
	);
	prefetcher #(.FETCH_TAG_COUNT(top_pkg_MAX_NODESLOT_COUNT)) prefetcher_i(
		.core_clk(sys_clk),
		.resetn(!sys_rst),
		.nsb_prefetcher_req_valid(nsb_prefetcher_req_valid),
		.nsb_prefetcher_req_ready(nsb_prefetcher_req_ready),
		.nsb_prefetcher_req(nsb_prefetcher_req),
		.nsb_prefetcher_resp_valid(nsb_prefetcher_resp_valid),
		.nsb_prefetcher_resp(nsb_prefetcher_resp),
		.s_axi_awaddr(axil_interconnect_m_axi_awaddr[127:96]),
		.s_axi_wdata(axil_interconnect_m_axi_wdata[127:96]),
		.s_axi_araddr(axil_interconnect_m_axi_araddr[127:96]),
		.s_axi_rdata(axil_interconnect_m_axi_rdata[127:96]),
		.s_axi_awprot(axil_interconnect_m_axi_awprot[11:9]),
		.s_axi_arprot(axil_interconnect_m_axi_arprot[11:9]),
		.s_axi_awvalid(axil_interconnect_m_axi_awvalid[3:3]),
		.s_axi_awready(axil_interconnect_m_axi_awready[3:3]),
		.s_axi_wvalid(axil_interconnect_m_axi_wvalid[3:3]),
		.s_axi_wready(axil_interconnect_m_axi_wready[3:3]),
		.s_axi_bvalid(axil_interconnect_m_axi_bvalid[3:3]),
		.s_axi_bready(axil_interconnect_m_axi_bready[3:3]),
		.s_axi_arvalid(axil_interconnect_m_axi_arvalid[3:3]),
		.s_axi_arready(axil_interconnect_m_axi_arready[3:3]),
		.s_axi_rvalid(axil_interconnect_m_axi_rvalid[3:3]),
		.s_axi_rready(axil_interconnect_m_axi_rready[3:3]),
		.s_axi_wstrb(axil_interconnect_m_axi_wstrb[15:12]),
		.s_axi_bresp(axil_interconnect_m_axi_bresp[7:6]),
		.s_axi_rresp(axil_interconnect_m_axi_rresp[7:6]),
		.prefetcher_adj_rm_axi_interconnect_axi_araddr(prefetcher_adj_rm_axi_interconnect_axi_araddr),
		.prefetcher_adj_rm_axi_interconnect_axi_arburst(prefetcher_adj_rm_axi_interconnect_axi_arburst),
		.prefetcher_adj_rm_axi_interconnect_axi_arcache(prefetcher_adj_rm_axi_interconnect_axi_arcache),
		.prefetcher_adj_rm_axi_interconnect_axi_arid(prefetcher_adj_rm_axi_interconnect_axi_arid),
		.prefetcher_adj_rm_axi_interconnect_axi_arlen(prefetcher_adj_rm_axi_interconnect_axi_arlen),
		.prefetcher_adj_rm_axi_interconnect_axi_arlock(prefetcher_adj_rm_axi_interconnect_axi_arlock),
		.prefetcher_adj_rm_axi_interconnect_axi_arprot(prefetcher_adj_rm_axi_interconnect_axi_arprot),
		.prefetcher_adj_rm_axi_interconnect_axi_arqos(prefetcher_adj_rm_axi_interconnect_axi_arqos),
		.prefetcher_adj_rm_axi_interconnect_axi_arsize(prefetcher_adj_rm_axi_interconnect_axi_arsize),
		.prefetcher_adj_rm_axi_interconnect_axi_arvalid(prefetcher_adj_rm_axi_interconnect_axi_arvalid),
		.prefetcher_adj_rm_axi_interconnect_axi_arready(prefetcher_adj_rm_axi_interconnect_axi_arready),
		.prefetcher_adj_rm_axi_interconnect_axi_awaddr(prefetcher_adj_rm_axi_interconnect_axi_awaddr),
		.prefetcher_adj_rm_axi_interconnect_axi_awburst(prefetcher_adj_rm_axi_interconnect_axi_awburst),
		.prefetcher_adj_rm_axi_interconnect_axi_awcache(prefetcher_adj_rm_axi_interconnect_axi_awcache),
		.prefetcher_adj_rm_axi_interconnect_axi_awid(prefetcher_adj_rm_axi_interconnect_axi_awid),
		.prefetcher_adj_rm_axi_interconnect_axi_awlen(prefetcher_adj_rm_axi_interconnect_axi_awlen),
		.prefetcher_adj_rm_axi_interconnect_axi_awlock(prefetcher_adj_rm_axi_interconnect_axi_awlock),
		.prefetcher_adj_rm_axi_interconnect_axi_awprot(prefetcher_adj_rm_axi_interconnect_axi_awprot),
		.prefetcher_adj_rm_axi_interconnect_axi_awqos(prefetcher_adj_rm_axi_interconnect_axi_awqos),
		.prefetcher_adj_rm_axi_interconnect_axi_awready(prefetcher_adj_rm_axi_interconnect_axi_awready),
		.prefetcher_adj_rm_axi_interconnect_axi_awsize(prefetcher_adj_rm_axi_interconnect_axi_awsize),
		.prefetcher_adj_rm_axi_interconnect_axi_awvalid(prefetcher_adj_rm_axi_interconnect_axi_awvalid),
		.prefetcher_adj_rm_axi_interconnect_axi_bid(prefetcher_adj_rm_axi_interconnect_axi_bid),
		.prefetcher_adj_rm_axi_interconnect_axi_bready(prefetcher_adj_rm_axi_interconnect_axi_bready),
		.prefetcher_adj_rm_axi_interconnect_axi_bresp(prefetcher_adj_rm_axi_interconnect_axi_bresp),
		.prefetcher_adj_rm_axi_interconnect_axi_bvalid(prefetcher_adj_rm_axi_interconnect_axi_bvalid),
		.prefetcher_adj_rm_axi_interconnect_axi_rdata(prefetcher_adj_rm_axi_interconnect_axi_rdata),
		.prefetcher_adj_rm_axi_interconnect_axi_rid(prefetcher_adj_rm_axi_interconnect_axi_rid),
		.prefetcher_adj_rm_axi_interconnect_axi_rlast(prefetcher_adj_rm_axi_interconnect_axi_rlast),
		.prefetcher_adj_rm_axi_interconnect_axi_rready(prefetcher_adj_rm_axi_interconnect_axi_rready),
		.prefetcher_adj_rm_axi_interconnect_axi_rresp(prefetcher_adj_rm_axi_interconnect_axi_rresp),
		.prefetcher_adj_rm_axi_interconnect_axi_rvalid(prefetcher_adj_rm_axi_interconnect_axi_rvalid),
		.prefetcher_adj_rm_axi_interconnect_axi_wdata(prefetcher_adj_rm_axi_interconnect_axi_wdata),
		.prefetcher_adj_rm_axi_interconnect_axi_wlast(prefetcher_adj_rm_axi_interconnect_axi_wlast),
		.prefetcher_adj_rm_axi_interconnect_axi_wready(prefetcher_adj_rm_axi_interconnect_axi_wready),
		.prefetcher_adj_rm_axi_interconnect_axi_wstrb(prefetcher_adj_rm_axi_interconnect_axi_wstrb),
		.prefetcher_adj_rm_axi_interconnect_axi_wvalid(prefetcher_adj_rm_axi_interconnect_axi_wvalid),
		.prefetcher_msg_rm_axi_interconnect_axi_araddr(prefetcher_msg_rm_axi_interconnect_axi_araddr),
		.prefetcher_msg_rm_axi_interconnect_axi_arburst(prefetcher_msg_rm_axi_interconnect_axi_arburst),
		.prefetcher_msg_rm_axi_interconnect_axi_arcache(prefetcher_msg_rm_axi_interconnect_axi_arcache),
		.prefetcher_msg_rm_axi_interconnect_axi_arid(prefetcher_msg_rm_axi_interconnect_axi_arid),
		.prefetcher_msg_rm_axi_interconnect_axi_arlen(prefetcher_msg_rm_axi_interconnect_axi_arlen),
		.prefetcher_msg_rm_axi_interconnect_axi_arlock(prefetcher_msg_rm_axi_interconnect_axi_arlock),
		.prefetcher_msg_rm_axi_interconnect_axi_arprot(prefetcher_msg_rm_axi_interconnect_axi_arprot),
		.prefetcher_msg_rm_axi_interconnect_axi_arqos(prefetcher_msg_rm_axi_interconnect_axi_arqos),
		.prefetcher_msg_rm_axi_interconnect_axi_arsize(prefetcher_msg_rm_axi_interconnect_axi_arsize),
		.prefetcher_msg_rm_axi_interconnect_axi_arvalid(prefetcher_msg_rm_axi_interconnect_axi_arvalid),
		.prefetcher_msg_rm_axi_interconnect_axi_arready(prefetcher_msg_rm_axi_interconnect_axi_arready),
		.prefetcher_msg_rm_axi_interconnect_axi_awaddr(prefetcher_msg_rm_axi_interconnect_axi_awaddr),
		.prefetcher_msg_rm_axi_interconnect_axi_awburst(prefetcher_msg_rm_axi_interconnect_axi_awburst),
		.prefetcher_msg_rm_axi_interconnect_axi_awcache(prefetcher_msg_rm_axi_interconnect_axi_awcache),
		.prefetcher_msg_rm_axi_interconnect_axi_awid(prefetcher_msg_rm_axi_interconnect_axi_awid),
		.prefetcher_msg_rm_axi_interconnect_axi_awlen(prefetcher_msg_rm_axi_interconnect_axi_awlen),
		.prefetcher_msg_rm_axi_interconnect_axi_awlock(prefetcher_msg_rm_axi_interconnect_axi_awlock),
		.prefetcher_msg_rm_axi_interconnect_axi_awprot(prefetcher_msg_rm_axi_interconnect_axi_awprot),
		.prefetcher_msg_rm_axi_interconnect_axi_awqos(prefetcher_msg_rm_axi_interconnect_axi_awqos),
		.prefetcher_msg_rm_axi_interconnect_axi_awready(prefetcher_msg_rm_axi_interconnect_axi_awready),
		.prefetcher_msg_rm_axi_interconnect_axi_awsize(prefetcher_msg_rm_axi_interconnect_axi_awsize),
		.prefetcher_msg_rm_axi_interconnect_axi_awvalid(prefetcher_msg_rm_axi_interconnect_axi_awvalid),
		.prefetcher_msg_rm_axi_interconnect_axi_bid(prefetcher_msg_rm_axi_interconnect_axi_bid),
		.prefetcher_msg_rm_axi_interconnect_axi_bready(prefetcher_msg_rm_axi_interconnect_axi_bready),
		.prefetcher_msg_rm_axi_interconnect_axi_bresp(prefetcher_msg_rm_axi_interconnect_axi_bresp),
		.prefetcher_msg_rm_axi_interconnect_axi_bvalid(prefetcher_msg_rm_axi_interconnect_axi_bvalid),
		.prefetcher_msg_rm_axi_interconnect_axi_rdata(prefetcher_msg_rm_axi_interconnect_axi_rdata),
		.prefetcher_msg_rm_axi_interconnect_axi_rid(prefetcher_msg_rm_axi_interconnect_axi_rid),
		.prefetcher_msg_rm_axi_interconnect_axi_rlast(prefetcher_msg_rm_axi_interconnect_axi_rlast),
		.prefetcher_msg_rm_axi_interconnect_axi_rready(prefetcher_msg_rm_axi_interconnect_axi_rready),
		.prefetcher_msg_rm_axi_interconnect_axi_rresp(prefetcher_msg_rm_axi_interconnect_axi_rresp),
		.prefetcher_msg_rm_axi_interconnect_axi_rvalid(prefetcher_msg_rm_axi_interconnect_axi_rvalid),
		.prefetcher_msg_rm_axi_interconnect_axi_wdata(prefetcher_msg_rm_axi_interconnect_axi_wdata),
		.prefetcher_msg_rm_axi_interconnect_axi_wlast(prefetcher_msg_rm_axi_interconnect_axi_wlast),
		.prefetcher_msg_rm_axi_interconnect_axi_wready(prefetcher_msg_rm_axi_interconnect_axi_wready),
		.prefetcher_msg_rm_axi_interconnect_axi_wstrb(prefetcher_msg_rm_axi_interconnect_axi_wstrb),
		.prefetcher_msg_rm_axi_interconnect_axi_wvalid(prefetcher_msg_rm_axi_interconnect_axi_wvalid),
		.prefetcher_weight_bank_rm_axi_interconnect_axi_araddr(prefetcher_weight_bank_rm_axi_interconnect_axi_araddr),
		.prefetcher_weight_bank_rm_axi_interconnect_axi_arburst(prefetcher_weight_bank_rm_axi_interconnect_axi_arburst),
		.prefetcher_weight_bank_rm_axi_interconnect_axi_arcache(prefetcher_weight_bank_rm_axi_interconnect_axi_arcache),
		.prefetcher_weight_bank_rm_axi_interconnect_axi_arid(prefetcher_weight_bank_rm_axi_interconnect_axi_arid),
		.prefetcher_weight_bank_rm_axi_interconnect_axi_arlen(prefetcher_weight_bank_rm_axi_interconnect_axi_arlen),
		.prefetcher_weight_bank_rm_axi_interconnect_axi_arlock(prefetcher_weight_bank_rm_axi_interconnect_axi_arlock),
		.prefetcher_weight_bank_rm_axi_interconnect_axi_arprot(prefetcher_weight_bank_rm_axi_interconnect_axi_arprot),
		.prefetcher_weight_bank_rm_axi_interconnect_axi_arqos(prefetcher_weight_bank_rm_axi_interconnect_axi_arqos),
		.prefetcher_weight_bank_rm_axi_interconnect_axi_arsize(prefetcher_weight_bank_rm_axi_interconnect_axi_arsize),
		.prefetcher_weight_bank_rm_axi_interconnect_axi_arvalid(prefetcher_weight_bank_rm_axi_interconnect_axi_arvalid),
		.prefetcher_weight_bank_rm_axi_interconnect_axi_arready(prefetcher_weight_bank_rm_axi_interconnect_axi_arready),
		.prefetcher_weight_bank_rm_axi_interconnect_axi_awaddr(prefetcher_weight_bank_rm_axi_interconnect_axi_awaddr),
		.prefetcher_weight_bank_rm_axi_interconnect_axi_awburst(prefetcher_weight_bank_rm_axi_interconnect_axi_awburst),
		.prefetcher_weight_bank_rm_axi_interconnect_axi_awcache(prefetcher_weight_bank_rm_axi_interconnect_axi_awcache),
		.prefetcher_weight_bank_rm_axi_interconnect_axi_awid(prefetcher_weight_bank_rm_axi_interconnect_axi_awid),
		.prefetcher_weight_bank_rm_axi_interconnect_axi_awlen(prefetcher_weight_bank_rm_axi_interconnect_axi_awlen),
		.prefetcher_weight_bank_rm_axi_interconnect_axi_awlock(prefetcher_weight_bank_rm_axi_interconnect_axi_awlock),
		.prefetcher_weight_bank_rm_axi_interconnect_axi_awprot(prefetcher_weight_bank_rm_axi_interconnect_axi_awprot),
		.prefetcher_weight_bank_rm_axi_interconnect_axi_awqos(prefetcher_weight_bank_rm_axi_interconnect_axi_awqos),
		.prefetcher_weight_bank_rm_axi_interconnect_axi_awready(prefetcher_weight_bank_rm_axi_interconnect_axi_awready),
		.prefetcher_weight_bank_rm_axi_interconnect_axi_awsize(prefetcher_weight_bank_rm_axi_interconnect_axi_awsize),
		.prefetcher_weight_bank_rm_axi_interconnect_axi_awvalid(prefetcher_weight_bank_rm_axi_interconnect_axi_awvalid),
		.prefetcher_weight_bank_rm_axi_interconnect_axi_bid(prefetcher_weight_bank_rm_axi_interconnect_axi_bid),
		.prefetcher_weight_bank_rm_axi_interconnect_axi_bready(prefetcher_weight_bank_rm_axi_interconnect_axi_bready),
		.prefetcher_weight_bank_rm_axi_interconnect_axi_bresp(prefetcher_weight_bank_rm_axi_interconnect_axi_bresp),
		.prefetcher_weight_bank_rm_axi_interconnect_axi_bvalid(prefetcher_weight_bank_rm_axi_interconnect_axi_bvalid),
		.prefetcher_weight_bank_rm_axi_interconnect_axi_rdata(prefetcher_weight_bank_rm_axi_interconnect_axi_rdata),
		.prefetcher_weight_bank_rm_axi_interconnect_axi_rid(prefetcher_weight_bank_rm_axi_interconnect_axi_rid),
		.prefetcher_weight_bank_rm_axi_interconnect_axi_rlast(prefetcher_weight_bank_rm_axi_interconnect_axi_rlast),
		.prefetcher_weight_bank_rm_axi_interconnect_axi_rready(prefetcher_weight_bank_rm_axi_interconnect_axi_rready),
		.prefetcher_weight_bank_rm_axi_interconnect_axi_rresp(prefetcher_weight_bank_rm_axi_interconnect_axi_rresp),
		.prefetcher_weight_bank_rm_axi_interconnect_axi_rvalid(prefetcher_weight_bank_rm_axi_interconnect_axi_rvalid),
		.prefetcher_weight_bank_rm_axi_interconnect_axi_wdata(prefetcher_weight_bank_rm_axi_interconnect_axi_wdata),
		.prefetcher_weight_bank_rm_axi_interconnect_axi_wlast(prefetcher_weight_bank_rm_axi_interconnect_axi_wlast),
		.prefetcher_weight_bank_rm_axi_interconnect_axi_wready(prefetcher_weight_bank_rm_axi_interconnect_axi_wready),
		.prefetcher_weight_bank_rm_axi_interconnect_axi_wstrb(prefetcher_weight_bank_rm_axi_interconnect_axi_wstrb),
		.prefetcher_weight_bank_rm_axi_interconnect_axi_wvalid(prefetcher_weight_bank_rm_axi_interconnect_axi_wvalid),
		.message_channel_req_valid(message_channel_req_valid),
		.message_channel_req_ready(message_channel_req_ready),
		.message_channel_req(message_channel_req),
		.message_channel_resp_valid(message_channel_resp_valid),
		.message_channel_resp_ready(message_channel_resp_ready),
		.message_channel_resp(message_channel_resp),
		.weight_channel_req_valid(weight_channel_req_valid),
		.weight_channel_req_ready(weight_channel_req_ready),
		.weight_channel_req(weight_channel_req),
		.weight_channel_resp_valid(weight_channel_resp_valid),
		.weight_channel_resp_ready(weight_channel_resp_ready),
		.weight_channel_resp(weight_channel_resp),
		.scale_factor_queue_pop(scale_factor_queue_pop),
		.scale_factor_queue_out_data(scale_factor_queue_out_data),
		.scale_factor_queue_count(scale_factor_queue_count),
		.scale_factor_queue_empty(scale_factor_queue_empty),
		.scale_factor_queue_full(scale_factor_queue_full)
	);
	aggregation_engine aggregation_engine_i(
		.core_clk(sys_clk),
		.resetn(!sys_rst),
		.nsb_age_req_valid(nsb_age_req_valid),
		.nsb_age_req_ready(nsb_age_req_ready),
		.nsb_age_req(nsb_age_req),
		.nsb_age_resp_valid(nsb_age_resp_valid),
		.nsb_age_resp(nsb_age_resp),
		.s_axi_awaddr(axil_interconnect_m_axi_awaddr[31:0]),
		.s_axi_awprot(axil_interconnect_m_axi_awprot[2:0]),
		.s_axi_awvalid(axil_interconnect_m_axi_awvalid[0]),
		.s_axi_awready(axil_interconnect_m_axi_awready[0]),
		.s_axi_wdata(axil_interconnect_m_axi_wdata[31:0]),
		.s_axi_wstrb(axil_interconnect_m_axi_wstrb[3:0]),
		.s_axi_wvalid(axil_interconnect_m_axi_wvalid[0]),
		.s_axi_wready(axil_interconnect_m_axi_wready[0]),
		.s_axi_bresp(axil_interconnect_m_axi_bresp[1:0]),
		.s_axi_bvalid(axil_interconnect_m_axi_bvalid[0]),
		.s_axi_bready(axil_interconnect_m_axi_bready[0]),
		.s_axi_araddr(axil_interconnect_m_axi_araddr[31:0]),
		.s_axi_arprot(axil_interconnect_m_axi_arprot[2:0]),
		.s_axi_arvalid(axil_interconnect_m_axi_arvalid[0]),
		.s_axi_arready(axil_interconnect_m_axi_arready[0]),
		.s_axi_rdata(axil_interconnect_m_axi_rdata[31:0]),
		.s_axi_rresp(axil_interconnect_m_axi_rresp[1:0]),
		.s_axi_rvalid(axil_interconnect_m_axi_rvalid[0]),
		.s_axi_rready(axil_interconnect_m_axi_rready[0]),
		.message_channel_req_valid(message_channel_req_valid),
		.message_channel_req_ready(message_channel_req_ready),
		.message_channel_req(message_channel_req),
		.message_channel_resp_valid(message_channel_resp_valid),
		.message_channel_resp_ready(message_channel_resp_ready),
		.message_channel_resp(message_channel_resp),
		.aggregation_buffer_slot_set_node_id_valid(aggregation_buffer_set_node_id_valid),
		.aggregation_buffer_slot_set_node_id(aggregation_buffer_set_node_id),
		.aggregation_buffer_slot_write_enable(aggregation_buffer_write_enable),
		.aggregation_buffer_slot_write_address(aggregation_buffer_write_address),
		.aggregation_buffer_slot_write_data(aggregation_buffer_write_data),
		.aggregation_buffer_slot_feature_count(aggregation_buffer_feature_count),
		.aggregation_buffer_slot_slot_free(aggregation_buffer_slot_free),
		.scale_factor_queue_pop(scale_factor_queue_pop),
		.scale_factor_queue_out_data(scale_factor_queue_out_data),
		.scale_factor_queue_count(scale_factor_queue_count),
		.scale_factor_queue_empty(scale_factor_queue_empty),
		.scale_factor_queue_full(scale_factor_queue_full)
	);
	hybrid_buffer #(
		.NUM_SLOTS(top_pkg_AGGREGATION_BUFFER_SLOTS),
		.WRITE_WIDTH(top_pkg_AGGREGATION_BUFFER_WRITE_WIDTH),
		.WRITE_DEPTH(top_pkg_AGGREGATION_BUFFER_WRITE_DEPTH),
		.READ_WIDTH(top_pkg_AGGREGATION_BUFFER_READ_WIDTH),
		.READ_DEPTH(top_pkg_AGGREGATION_BUFFER_READ_DEPTH)
	) aggregation_buffer_i(
		.core_clk(sys_clk),
		.resetn(!sys_rst),
		.set_node_id_valid(aggregation_buffer_set_node_id_valid),
		.set_node_id(aggregation_buffer_set_node_id),
		.slot_node_id(aggregation_buffer_node_id),
		.write_enable(aggregation_buffer_write_enable),
		.write_address(aggregation_buffer_write_address),
		.write_data(aggregation_buffer_write_data),
		.feature_count(aggregation_buffer_feature_count),
		.pop(aggregation_buffer_pop),
		.out_feature(aggregation_buffer_out_feature),
		.slot_free(aggregation_buffer_slot_free)
	);
	feature_transformation_engine transformation_engine_i(
		.core_clk(sys_clk),
		.resetn(!sys_rst),
		.s_axi_awaddr(axil_interconnect_m_axi_awaddr[63:32]),
		.s_axi_awprot(axil_interconnect_m_axi_awprot[5:3]),
		.s_axi_awvalid(axil_interconnect_m_axi_awvalid[1:1]),
		.s_axi_awready(axil_interconnect_m_axi_awready[1:1]),
		.s_axi_wdata(axil_interconnect_m_axi_wdata[63:32]),
		.s_axi_wstrb(axil_interconnect_m_axi_wstrb[7:4]),
		.s_axi_wvalid(axil_interconnect_m_axi_wvalid[1:1]),
		.s_axi_wready(axil_interconnect_m_axi_wready[1:1]),
		.s_axi_araddr(axil_interconnect_m_axi_araddr[63:32]),
		.s_axi_arprot(axil_interconnect_m_axi_arprot[5:3]),
		.s_axi_arvalid(axil_interconnect_m_axi_arvalid[1:1]),
		.s_axi_arready(axil_interconnect_m_axi_arready[1:1]),
		.s_axi_rdata(axil_interconnect_m_axi_rdata[63:32]),
		.s_axi_rresp(axil_interconnect_m_axi_rresp[3:2]),
		.s_axi_rvalid(axil_interconnect_m_axi_rvalid[1:1]),
		.s_axi_rready(axil_interconnect_m_axi_rready[1:1]),
		.s_axi_bresp(axil_interconnect_m_axi_bresp[3:2]),
		.s_axi_bvalid(axil_interconnect_m_axi_bvalid[1:1]),
		.s_axi_bready(axil_interconnect_m_axi_bready[1:1]),
		.nsb_fte_req_valid(nsb_fte_req_valid),
		.nsb_fte_req_ready(nsb_fte_req_ready),
		.nsb_fte_req(nsb_fte_req),
		.nsb_fte_resp_valid(nsb_fte_resp_valid),
		.nsb_fte_resp(nsb_fte_resp),
		.aggregation_buffer_node_id(aggregation_buffer_node_id),
		.aggregation_buffer_pop(aggregation_buffer_pop),
		.aggregation_buffer_out_feature(aggregation_buffer_out_feature),
		.aggregation_buffer_slot_free(aggregation_buffer_slot_free),
		.weight_channel_req_valid(weight_channel_req_valid),
		.weight_channel_req_ready(weight_channel_req_ready),
		.weight_channel_req(weight_channel_req),
		.weight_channel_resp_valid(weight_channel_resp_valid),
		.weight_channel_resp_ready(weight_channel_resp_ready),
		.weight_channel_resp(weight_channel_resp),
		.transformation_engine_axi_interconnect_axi_araddr(transformation_engine_axi_interconnect_axi_araddr),
		.transformation_engine_axi_interconnect_axi_arburst(transformation_engine_axi_interconnect_axi_arburst),
		.transformation_engine_axi_interconnect_axi_arcache(transformation_engine_axi_interconnect_axi_arcache),
		.transformation_engine_axi_interconnect_axi_arid(transformation_engine_axi_interconnect_axi_arid),
		.transformation_engine_axi_interconnect_axi_arlen(transformation_engine_axi_interconnect_axi_arlen),
		.transformation_engine_axi_interconnect_axi_arlock(transformation_engine_axi_interconnect_axi_arlock),
		.transformation_engine_axi_interconnect_axi_arprot(transformation_engine_axi_interconnect_axi_arprot),
		.transformation_engine_axi_interconnect_axi_arqos(transformation_engine_axi_interconnect_axi_arqos),
		.transformation_engine_axi_interconnect_axi_arsize(transformation_engine_axi_interconnect_axi_arsize),
		.transformation_engine_axi_interconnect_axi_arvalid(transformation_engine_axi_interconnect_axi_arvalid),
		.transformation_engine_axi_interconnect_axi_arready(transformation_engine_axi_interconnect_axi_arready),
		.transformation_engine_axi_interconnect_axi_awaddr(transformation_engine_axi_interconnect_axi_awaddr),
		.transformation_engine_axi_interconnect_axi_awburst(transformation_engine_axi_interconnect_axi_awburst),
		.transformation_engine_axi_interconnect_axi_awcache(transformation_engine_axi_interconnect_axi_awcache),
		.transformation_engine_axi_interconnect_axi_awid(transformation_engine_axi_interconnect_axi_awid),
		.transformation_engine_axi_interconnect_axi_awlen(transformation_engine_axi_interconnect_axi_awlen),
		.transformation_engine_axi_interconnect_axi_awlock(transformation_engine_axi_interconnect_axi_awlock),
		.transformation_engine_axi_interconnect_axi_awprot(transformation_engine_axi_interconnect_axi_awprot),
		.transformation_engine_axi_interconnect_axi_awqos(transformation_engine_axi_interconnect_axi_awqos),
		.transformation_engine_axi_interconnect_axi_awready(transformation_engine_axi_interconnect_axi_awready),
		.transformation_engine_axi_interconnect_axi_awsize(transformation_engine_axi_interconnect_axi_awsize),
		.transformation_engine_axi_interconnect_axi_awvalid(transformation_engine_axi_interconnect_axi_awvalid),
		.transformation_engine_axi_interconnect_axi_bid(transformation_engine_axi_interconnect_axi_bid),
		.transformation_engine_axi_interconnect_axi_bready(transformation_engine_axi_interconnect_axi_bready),
		.transformation_engine_axi_interconnect_axi_bresp(transformation_engine_axi_interconnect_axi_bresp),
		.transformation_engine_axi_interconnect_axi_bvalid(transformation_engine_axi_interconnect_axi_bvalid),
		.transformation_engine_axi_interconnect_axi_rdata(transformation_engine_axi_interconnect_axi_rdata),
		.transformation_engine_axi_interconnect_axi_rid(transformation_engine_axi_interconnect_axi_rid),
		.transformation_engine_axi_interconnect_axi_rlast(transformation_engine_axi_interconnect_axi_rlast),
		.transformation_engine_axi_interconnect_axi_rready(transformation_engine_axi_interconnect_axi_rready),
		.transformation_engine_axi_interconnect_axi_rresp(transformation_engine_axi_interconnect_axi_rresp),
		.transformation_engine_axi_interconnect_axi_rvalid(transformation_engine_axi_interconnect_axi_rvalid),
		.transformation_engine_axi_interconnect_axi_wdata(transformation_engine_axi_interconnect_axi_wdata),
		.transformation_engine_axi_interconnect_axi_wlast(transformation_engine_axi_interconnect_axi_wlast),
		.transformation_engine_axi_interconnect_axi_wready(transformation_engine_axi_interconnect_axi_wready),
		.transformation_engine_axi_interconnect_axi_wstrb(transformation_engine_axi_interconnect_axi_wstrb),
		.transformation_engine_axi_interconnect_axi_wvalid(transformation_engine_axi_interconnect_axi_wvalid)
	);
	hybrid_buffer #(
		.NUM_SLOTS(top_pkg_TRANSFORMATION_BUFFER_SLOTS),
		.WRITE_WIDTH(top_pkg_TRANSFORMATION_BUFFER_WRITE_WIDTH),
		.WRITE_DEPTH(top_pkg_TRANSFORMATION_BUFFER_WRITE_DEPTH),
		.READ_WIDTH(top_pkg_TRANSFORMATION_BUFFER_READ_WIDTH),
		.READ_DEPTH(top_pkg_TRANSFORMATION_BUFFER_READ_DEPTH),
		.BUFFER_TYPE("TRANSFORMATION")
	) transformation_buffer_i(
		.core_clk(sys_clk),
		.resetn(!sys_rst),
		.write_enable(transformation_buffer_write_enable),
		.write_address(transformation_buffer_write_address),
		.write_data(transformation_buffer_write_data),
		.feature_count(transformation_buffer_feature_count),
		.pop(transformation_buffer_pop),
		.out_feature(transformation_buffer_out_feature),
		.slot_free(transformation_buffer_slot_free)
	);
	axi_L_register_control_crossbar axi_L_register_control_crossbar_i(
		.aclk(sys_clk),
		.aresetn(!sys_rst),
		.s_axi_awaddr(host_axil_awaddr),
		.s_axi_awprot(host_axil_awprot),
		.s_axi_awvalid(host_axil_awvalid),
		.s_axi_awready(host_axil_awready),
		.s_axi_wdata(host_axil_wdata),
		.s_axi_wstrb(host_axil_wstrb),
		.s_axi_wvalid(host_axil_wvalid),
		.s_axi_wready(host_axil_wready),
		.s_axi_bresp(host_axil_bresp),
		.s_axi_bvalid(host_axil_bvalid),
		.s_axi_bready(host_axil_bready),
		.s_axi_araddr(host_axil_araddr),
		.s_axi_arprot(host_axil_arprot),
		.s_axi_arvalid(host_axil_arvalid),
		.s_axi_arready(host_axil_arready),
		.s_axi_rdata(host_axil_rdata),
		.s_axi_rresp(host_axil_rresp),
		.s_axi_rvalid(host_axil_rvalid),
		.s_axi_rready(host_axil_rready),
		.m_axi_awaddr(axil_interconnect_m_axi_awaddr),
		.m_axi_awprot(axil_interconnect_m_axi_awprot),
		.m_axi_awvalid(axil_interconnect_m_axi_awvalid),
		.m_axi_awready(axil_interconnect_m_axi_awready),
		.m_axi_wdata(axil_interconnect_m_axi_wdata),
		.m_axi_wstrb(axil_interconnect_m_axi_wstrb),
		.m_axi_wvalid(axil_interconnect_m_axi_wvalid),
		.m_axi_wready(axil_interconnect_m_axi_wready),
		.m_axi_bresp(axil_interconnect_m_axi_bresp),
		.m_axi_bvalid(axil_interconnect_m_axi_bvalid),
		.m_axi_bready(axil_interconnect_m_axi_bready),
		.m_axi_araddr(axil_interconnect_m_axi_araddr),
		.m_axi_arprot(axil_interconnect_m_axi_arprot),
		.m_axi_arvalid(axil_interconnect_m_axi_arvalid),
		.m_axi_arready(axil_interconnect_m_axi_arready),
		.m_axi_rdata(axil_interconnect_m_axi_rdata),
		.m_axi_rresp(axil_interconnect_m_axi_rresp),
		.m_axi_rvalid(axil_interconnect_m_axi_rvalid),
		.m_axi_rready(axil_interconnect_m_axi_rready)
	);
	axi_memory_interconnect axi_memory_interconnect_i(
		.INTERCONNECT_ACLK(sys_clk),
		.INTERCONNECT_ARESETN(!sys_rst),
		.S00_AXI_ACLK(sys_clk),
		.S00_AXI_ARESET_OUT_N(S00_AXI_ARESET_OUT_N),
		.S00_AXI_ARADDR(prefetcher_adj_rm_axi_interconnect_axi_araddr),
		.S00_AXI_ARBURST(prefetcher_adj_rm_axi_interconnect_axi_arburst),
		.S00_AXI_ARCACHE(prefetcher_adj_rm_axi_interconnect_axi_arcache),
		.S00_AXI_ARID(prefetcher_adj_rm_axi_interconnect_axi_arid),
		.S00_AXI_ARLEN(prefetcher_adj_rm_axi_interconnect_axi_arlen),
		.S00_AXI_ARLOCK(prefetcher_adj_rm_axi_interconnect_axi_arlock),
		.S00_AXI_ARPROT(prefetcher_adj_rm_axi_interconnect_axi_arprot),
		.S00_AXI_ARQOS(prefetcher_adj_rm_axi_interconnect_axi_arqos),
		.S00_AXI_ARSIZE(prefetcher_adj_rm_axi_interconnect_axi_arsize),
		.S00_AXI_ARVALID(prefetcher_adj_rm_axi_interconnect_axi_arvalid),
		.S00_AXI_ARREADY(prefetcher_adj_rm_axi_interconnect_axi_arready),
		.S00_AXI_AWADDR(prefetcher_adj_rm_axi_interconnect_axi_awaddr),
		.S00_AXI_AWBURST(prefetcher_adj_rm_axi_interconnect_axi_awburst),
		.S00_AXI_AWCACHE(prefetcher_adj_rm_axi_interconnect_axi_awcache),
		.S00_AXI_AWID(prefetcher_adj_rm_axi_interconnect_axi_awid),
		.S00_AXI_AWLEN(prefetcher_adj_rm_axi_interconnect_axi_awlen),
		.S00_AXI_AWLOCK(prefetcher_adj_rm_axi_interconnect_axi_awlock),
		.S00_AXI_AWPROT(prefetcher_adj_rm_axi_interconnect_axi_awprot),
		.S00_AXI_AWQOS(prefetcher_adj_rm_axi_interconnect_axi_awqos),
		.S00_AXI_AWREADY(prefetcher_adj_rm_axi_interconnect_axi_awready),
		.S00_AXI_AWSIZE(prefetcher_adj_rm_axi_interconnect_axi_awsize),
		.S00_AXI_AWVALID(prefetcher_adj_rm_axi_interconnect_axi_awvalid),
		.S00_AXI_BID(prefetcher_adj_rm_axi_interconnect_axi_bid),
		.S00_AXI_BREADY(prefetcher_adj_rm_axi_interconnect_axi_bready),
		.S00_AXI_BRESP(prefetcher_adj_rm_axi_interconnect_axi_bresp),
		.S00_AXI_BVALID(prefetcher_adj_rm_axi_interconnect_axi_bvalid),
		.S00_AXI_RDATA(prefetcher_adj_rm_axi_interconnect_axi_rdata),
		.S00_AXI_RID(prefetcher_adj_rm_axi_interconnect_axi_rid),
		.S00_AXI_RLAST(prefetcher_adj_rm_axi_interconnect_axi_rlast),
		.S00_AXI_RREADY(prefetcher_adj_rm_axi_interconnect_axi_rready),
		.S00_AXI_RRESP(prefetcher_adj_rm_axi_interconnect_axi_rresp),
		.S00_AXI_RVALID(prefetcher_adj_rm_axi_interconnect_axi_rvalid),
		.S00_AXI_WDATA(prefetcher_adj_rm_axi_interconnect_axi_wdata),
		.S00_AXI_WLAST(prefetcher_adj_rm_axi_interconnect_axi_wlast),
		.S00_AXI_WREADY(prefetcher_adj_rm_axi_interconnect_axi_wready),
		.S00_AXI_WSTRB(prefetcher_adj_rm_axi_interconnect_axi_wstrb),
		.S00_AXI_WVALID(prefetcher_adj_rm_axi_interconnect_axi_wvalid),
		.S01_AXI_ACLK(sys_clk),
		.S01_AXI_ARESET_OUT_N(S01_AXI_ARESET_OUT_N),
		.S01_AXI_ARADDR(prefetcher_weight_bank_rm_axi_interconnect_axi_araddr),
		.S01_AXI_ARBURST(prefetcher_weight_bank_rm_axi_interconnect_axi_arburst),
		.S01_AXI_ARCACHE(prefetcher_weight_bank_rm_axi_interconnect_axi_arcache),
		.S01_AXI_ARID(prefetcher_weight_bank_rm_axi_interconnect_axi_arid),
		.S01_AXI_ARLEN(prefetcher_weight_bank_rm_axi_interconnect_axi_arlen),
		.S01_AXI_ARLOCK(prefetcher_weight_bank_rm_axi_interconnect_axi_arlock),
		.S01_AXI_ARPROT(prefetcher_weight_bank_rm_axi_interconnect_axi_arprot),
		.S01_AXI_ARQOS(prefetcher_weight_bank_rm_axi_interconnect_axi_arqos),
		.S01_AXI_ARSIZE(prefetcher_weight_bank_rm_axi_interconnect_axi_arsize),
		.S01_AXI_ARVALID(prefetcher_weight_bank_rm_axi_interconnect_axi_arvalid),
		.S01_AXI_ARREADY(prefetcher_weight_bank_rm_axi_interconnect_axi_arready),
		.S01_AXI_AWADDR(prefetcher_weight_bank_rm_axi_interconnect_axi_awaddr),
		.S01_AXI_AWBURST(prefetcher_weight_bank_rm_axi_interconnect_axi_awburst),
		.S01_AXI_AWCACHE(prefetcher_weight_bank_rm_axi_interconnect_axi_awcache),
		.S01_AXI_AWID(prefetcher_weight_bank_rm_axi_interconnect_axi_awid),
		.S01_AXI_AWLEN(prefetcher_weight_bank_rm_axi_interconnect_axi_awlen),
		.S01_AXI_AWLOCK(prefetcher_weight_bank_rm_axi_interconnect_axi_awlock),
		.S01_AXI_AWPROT(prefetcher_weight_bank_rm_axi_interconnect_axi_awprot),
		.S01_AXI_AWQOS(prefetcher_weight_bank_rm_axi_interconnect_axi_awqos),
		.S01_AXI_AWREADY(prefetcher_weight_bank_rm_axi_interconnect_axi_awready),
		.S01_AXI_AWSIZE(prefetcher_weight_bank_rm_axi_interconnect_axi_awsize),
		.S01_AXI_AWVALID(prefetcher_weight_bank_rm_axi_interconnect_axi_awvalid),
		.S01_AXI_BID(prefetcher_weight_bank_rm_axi_interconnect_axi_bid),
		.S01_AXI_BREADY(prefetcher_weight_bank_rm_axi_interconnect_axi_bready),
		.S01_AXI_BRESP(prefetcher_weight_bank_rm_axi_interconnect_axi_bresp),
		.S01_AXI_BVALID(prefetcher_weight_bank_rm_axi_interconnect_axi_bvalid),
		.S01_AXI_RDATA(prefetcher_weight_bank_rm_axi_interconnect_axi_rdata),
		.S01_AXI_RID(prefetcher_weight_bank_rm_axi_interconnect_axi_rid),
		.S01_AXI_RLAST(prefetcher_weight_bank_rm_axi_interconnect_axi_rlast),
		.S01_AXI_RREADY(prefetcher_weight_bank_rm_axi_interconnect_axi_rready),
		.S01_AXI_RRESP(prefetcher_weight_bank_rm_axi_interconnect_axi_rresp),
		.S01_AXI_RVALID(prefetcher_weight_bank_rm_axi_interconnect_axi_rvalid),
		.S01_AXI_WDATA(prefetcher_weight_bank_rm_axi_interconnect_axi_wdata),
		.S01_AXI_WLAST(prefetcher_weight_bank_rm_axi_interconnect_axi_wlast),
		.S01_AXI_WREADY(prefetcher_weight_bank_rm_axi_interconnect_axi_wready),
		.S01_AXI_WSTRB(prefetcher_weight_bank_rm_axi_interconnect_axi_wstrb),
		.S01_AXI_WVALID(prefetcher_weight_bank_rm_axi_interconnect_axi_wvalid),
		.S02_AXI_ACLK(sys_clk),
		.S02_AXI_ARESET_OUT_N(S02_AXI_ARESET_OUT_N),
		.S02_AXI_AWID(1'sb0),
		.S02_AXI_AWADDR(1'sb0),
		.S02_AXI_AWLEN(1'sb0),
		.S02_AXI_AWSIZE(1'sb0),
		.S02_AXI_AWBURST(1'sb0),
		.S02_AXI_AWLOCK(1'sb0),
		.S02_AXI_AWCACHE(1'sb0),
		.S02_AXI_AWPROT(1'sb0),
		.S02_AXI_AWQOS(1'sb0),
		.S02_AXI_AWVALID(1'sb0),
		.S02_AXI_AWREADY(),
		.S02_AXI_WDATA(1'sb0),
		.S02_AXI_WSTRB(1'sb0),
		.S02_AXI_WLAST(1'sb0),
		.S02_AXI_WVALID(1'sb0),
		.S02_AXI_WREADY(),
		.S02_AXI_BID(),
		.S02_AXI_BRESP(),
		.S02_AXI_BVALID(),
		.S02_AXI_BREADY(1'sb0),
		.S02_AXI_ARID(1'sb0),
		.S02_AXI_ARADDR(1'sb0),
		.S02_AXI_ARLEN(1'sb0),
		.S02_AXI_ARSIZE(1'sb0),
		.S02_AXI_ARBURST(1'sb0),
		.S02_AXI_ARLOCK(1'sb0),
		.S02_AXI_ARCACHE(1'sb0),
		.S02_AXI_ARPROT(1'sb0),
		.S02_AXI_ARQOS(1'sb0),
		.S02_AXI_ARVALID(1'sb0),
		.S02_AXI_ARREADY(),
		.S02_AXI_RID(),
		.S02_AXI_RDATA(),
		.S02_AXI_RRESP(),
		.S02_AXI_RLAST(),
		.S02_AXI_RVALID(),
		.S02_AXI_RREADY(1'sb0),
		.S03_AXI_ACLK(sys_clk),
		.S03_AXI_ARESET_OUT_N(S03_AXI_ARESET_OUT_N),
		.S03_AXI_AWID(transformation_engine_axi_interconnect_axi_awid),
		.S03_AXI_AWADDR(transformation_engine_axi_interconnect_axi_awaddr),
		.S03_AXI_AWLEN(transformation_engine_axi_interconnect_axi_awlen),
		.S03_AXI_AWSIZE(transformation_engine_axi_interconnect_axi_awsize),
		.S03_AXI_AWBURST(transformation_engine_axi_interconnect_axi_awburst),
		.S03_AXI_AWLOCK(transformation_engine_axi_interconnect_axi_awlock),
		.S03_AXI_AWCACHE(transformation_engine_axi_interconnect_axi_awcache),
		.S03_AXI_AWPROT(transformation_engine_axi_interconnect_axi_awprot),
		.S03_AXI_AWQOS(transformation_engine_axi_interconnect_axi_awqos),
		.S03_AXI_AWVALID(transformation_engine_axi_interconnect_axi_awvalid),
		.S03_AXI_AWREADY(transformation_engine_axi_interconnect_axi_awready),
		.S03_AXI_WDATA(transformation_engine_axi_interconnect_axi_wdata),
		.S03_AXI_WSTRB(transformation_engine_axi_interconnect_axi_wstrb),
		.S03_AXI_WLAST(transformation_engine_axi_interconnect_axi_wlast),
		.S03_AXI_WVALID(transformation_engine_axi_interconnect_axi_wvalid),
		.S03_AXI_WREADY(transformation_engine_axi_interconnect_axi_wready),
		.S03_AXI_BID(transformation_engine_axi_interconnect_axi_bid),
		.S03_AXI_BRESP(transformation_engine_axi_interconnect_axi_bresp),
		.S03_AXI_BVALID(transformation_engine_axi_interconnect_axi_bvalid),
		.S03_AXI_BREADY(transformation_engine_axi_interconnect_axi_bready),
		.S03_AXI_ARID(transformation_engine_axi_interconnect_axi_arid),
		.S03_AXI_ARADDR(transformation_engine_axi_interconnect_axi_araddr),
		.S03_AXI_ARLEN(transformation_engine_axi_interconnect_axi_arlen),
		.S03_AXI_ARSIZE(transformation_engine_axi_interconnect_axi_arsize),
		.S03_AXI_ARBURST(transformation_engine_axi_interconnect_axi_arburst),
		.S03_AXI_ARLOCK(transformation_engine_axi_interconnect_axi_arlock),
		.S03_AXI_ARCACHE(transformation_engine_axi_interconnect_axi_arcache),
		.S03_AXI_ARPROT(transformation_engine_axi_interconnect_axi_arprot),
		.S03_AXI_ARQOS(transformation_engine_axi_interconnect_axi_arqos),
		.S03_AXI_ARVALID(transformation_engine_axi_interconnect_axi_arvalid),
		.S03_AXI_ARREADY(transformation_engine_axi_interconnect_axi_arready),
		.S03_AXI_RID(transformation_engine_axi_interconnect_axi_rid),
		.S03_AXI_RDATA(transformation_engine_axi_interconnect_axi_rdata),
		.S03_AXI_RRESP(transformation_engine_axi_interconnect_axi_rresp),
		.S03_AXI_RLAST(transformation_engine_axi_interconnect_axi_rlast),
		.S03_AXI_RVALID(transformation_engine_axi_interconnect_axi_rvalid),
		.S03_AXI_RREADY(transformation_engine_axi_interconnect_axi_rready),
		.S04_AXI_ACLK(sys_clk),
		.S04_AXI_ARESET_OUT_N(S04_AXI_ARESET_OUT_N),
		.S04_AXI_ARADDR(prefetcher_msg_rm_axi_interconnect_axi_araddr),
		.S04_AXI_ARBURST(prefetcher_msg_rm_axi_interconnect_axi_arburst),
		.S04_AXI_ARCACHE(prefetcher_msg_rm_axi_interconnect_axi_arcache),
		.S04_AXI_ARID(prefetcher_msg_rm_axi_interconnect_axi_arid),
		.S04_AXI_ARLEN(prefetcher_msg_rm_axi_interconnect_axi_arlen),
		.S04_AXI_ARLOCK(prefetcher_msg_rm_axi_interconnect_axi_arlock),
		.S04_AXI_ARPROT(prefetcher_msg_rm_axi_interconnect_axi_arprot),
		.S04_AXI_ARQOS(prefetcher_msg_rm_axi_interconnect_axi_arqos),
		.S04_AXI_ARSIZE(prefetcher_msg_rm_axi_interconnect_axi_arsize),
		.S04_AXI_ARVALID(prefetcher_msg_rm_axi_interconnect_axi_arvalid),
		.S04_AXI_ARREADY(prefetcher_msg_rm_axi_interconnect_axi_arready),
		.S04_AXI_AWADDR(prefetcher_msg_rm_axi_interconnect_axi_awaddr),
		.S04_AXI_AWBURST(prefetcher_msg_rm_axi_interconnect_axi_awburst),
		.S04_AXI_AWCACHE(prefetcher_msg_rm_axi_interconnect_axi_awcache),
		.S04_AXI_AWID(prefetcher_msg_rm_axi_interconnect_axi_awid),
		.S04_AXI_AWLEN(prefetcher_msg_rm_axi_interconnect_axi_awlen),
		.S04_AXI_AWLOCK(prefetcher_msg_rm_axi_interconnect_axi_awlock),
		.S04_AXI_AWPROT(prefetcher_msg_rm_axi_interconnect_axi_awprot),
		.S04_AXI_AWQOS(prefetcher_msg_rm_axi_interconnect_axi_awqos),
		.S04_AXI_AWREADY(prefetcher_msg_rm_axi_interconnect_axi_awready),
		.S04_AXI_AWSIZE(prefetcher_msg_rm_axi_interconnect_axi_awsize),
		.S04_AXI_AWVALID(prefetcher_msg_rm_axi_interconnect_axi_awvalid),
		.S04_AXI_BID(prefetcher_msg_rm_axi_interconnect_axi_bid),
		.S04_AXI_BREADY(prefetcher_msg_rm_axi_interconnect_axi_bready),
		.S04_AXI_BRESP(prefetcher_msg_rm_axi_interconnect_axi_bresp),
		.S04_AXI_BVALID(prefetcher_msg_rm_axi_interconnect_axi_bvalid),
		.S04_AXI_RDATA(prefetcher_msg_rm_axi_interconnect_axi_rdata),
		.S04_AXI_RID(prefetcher_msg_rm_axi_interconnect_axi_rid),
		.S04_AXI_RLAST(prefetcher_msg_rm_axi_interconnect_axi_rlast),
		.S04_AXI_RREADY(prefetcher_msg_rm_axi_interconnect_axi_rready),
		.S04_AXI_RRESP(prefetcher_msg_rm_axi_interconnect_axi_rresp),
		.S04_AXI_RVALID(prefetcher_msg_rm_axi_interconnect_axi_rvalid),
		.S04_AXI_WDATA(prefetcher_msg_rm_axi_interconnect_axi_wdata),
		.S04_AXI_WLAST(prefetcher_msg_rm_axi_interconnect_axi_wlast),
		.S04_AXI_WREADY(prefetcher_msg_rm_axi_interconnect_axi_wready),
		.S04_AXI_WSTRB(prefetcher_msg_rm_axi_interconnect_axi_wstrb),
		.S04_AXI_WVALID(prefetcher_msg_rm_axi_interconnect_axi_wvalid),
		.S05_AXI_ACLK(sys_clk),
		.S05_AXI_ARESET_OUT_N(S05_AXI_ARESET_OUT_N),
		.S05_AXI_ARADDR(1'sb0),
		.S05_AXI_ARBURST(1'sb0),
		.S05_AXI_ARCACHE(1'sb0),
		.S05_AXI_ARID(1'sb0),
		.S05_AXI_ARLEN(1'sb0),
		.S05_AXI_ARLOCK(1'sb0),
		.S05_AXI_ARPROT(1'sb0),
		.S05_AXI_ARQOS(1'sb0),
		.S05_AXI_ARSIZE(1'sb0),
		.S05_AXI_ARVALID(1'sb0),
		.S05_AXI_ARREADY(),
		.S05_AXI_AWADDR(1'sb0),
		.S05_AXI_AWBURST(1'sb0),
		.S05_AXI_AWCACHE(1'sb0),
		.S05_AXI_AWID(1'sb0),
		.S05_AXI_AWLEN(1'sb0),
		.S05_AXI_AWLOCK(1'sb0),
		.S05_AXI_AWPROT(1'sb0),
		.S05_AXI_AWQOS(1'sb0),
		.S05_AXI_AWREADY(),
		.S05_AXI_AWSIZE(1'sb0),
		.S05_AXI_AWVALID(1'sb0),
		.S05_AXI_BID(),
		.S05_AXI_BREADY(1'sb0),
		.S05_AXI_BRESP(),
		.S05_AXI_BVALID(),
		.S05_AXI_RDATA(),
		.S05_AXI_RID(),
		.S05_AXI_RLAST(),
		.S05_AXI_RREADY(1'sb0),
		.S05_AXI_RRESP(),
		.S05_AXI_RVALID(),
		.S05_AXI_WDATA(1'sb0),
		.S05_AXI_WLAST(1'sb0),
		.S05_AXI_WREADY(),
		.S05_AXI_WSTRB(1'sb0),
		.S05_AXI_WVALID(1'sb0),
		.S06_AXI_ACLK(sys_clk),
		.S06_AXI_ARESET_OUT_N(S06_AXI_ARESET_OUT_N),
		.S06_AXI_ARADDR(1'sb0),
		.S06_AXI_ARBURST(1'sb0),
		.S06_AXI_ARCACHE(1'sb0),
		.S06_AXI_ARID(1'sb0),
		.S06_AXI_ARLEN(1'sb0),
		.S06_AXI_ARLOCK(1'sb0),
		.S06_AXI_ARPROT(1'sb0),
		.S06_AXI_ARQOS(1'sb0),
		.S06_AXI_ARSIZE(1'sb0),
		.S06_AXI_ARVALID(1'sb0),
		.S06_AXI_ARREADY(),
		.S06_AXI_AWADDR(1'sb0),
		.S06_AXI_AWBURST(1'sb0),
		.S06_AXI_AWCACHE(1'sb0),
		.S06_AXI_AWID(1'sb0),
		.S06_AXI_AWLEN(1'sb0),
		.S06_AXI_AWLOCK(1'sb0),
		.S06_AXI_AWPROT(1'sb0),
		.S06_AXI_AWQOS(1'sb0),
		.S06_AXI_AWREADY(),
		.S06_AXI_AWSIZE(1'sb0),
		.S06_AXI_AWVALID(1'sb0),
		.S06_AXI_BID(),
		.S06_AXI_BREADY(1'sb0),
		.S06_AXI_BRESP(),
		.S06_AXI_BVALID(),
		.S06_AXI_RDATA(),
		.S06_AXI_RID(),
		.S06_AXI_RLAST(),
		.S06_AXI_RREADY(1'sb0),
		.S06_AXI_RRESP(),
		.S06_AXI_RVALID(),
		.S06_AXI_WDATA(1'sb0),
		.S06_AXI_WLAST(1'sb0),
		.S06_AXI_WREADY(),
		.S06_AXI_WSTRB(1'sb0),
		.S06_AXI_WVALID(1'sb0),
		.S07_AXI_ACLK(sys_clk),
		.S07_AXI_ARESET_OUT_N(S07_AXI_ARESET_OUT_N),
		.S07_AXI_ARADDR(1'sb0),
		.S07_AXI_ARBURST(1'sb0),
		.S07_AXI_ARCACHE(1'sb0),
		.S07_AXI_ARID(1'sb0),
		.S07_AXI_ARLEN(1'sb0),
		.S07_AXI_ARLOCK(1'sb0),
		.S07_AXI_ARPROT(1'sb0),
		.S07_AXI_ARQOS(1'sb0),
		.S07_AXI_ARSIZE(1'sb0),
		.S07_AXI_ARVALID(1'sb0),
		.S07_AXI_ARREADY(),
		.S07_AXI_AWADDR(1'sb0),
		.S07_AXI_AWBURST(1'sb0),
		.S07_AXI_AWCACHE(1'sb0),
		.S07_AXI_AWID(1'sb0),
		.S07_AXI_AWLEN(1'sb0),
		.S07_AXI_AWLOCK(1'sb0),
		.S07_AXI_AWPROT(1'sb0),
		.S07_AXI_AWQOS(1'sb0),
		.S07_AXI_AWREADY(),
		.S07_AXI_AWSIZE(1'sb0),
		.S07_AXI_AWVALID(1'sb0),
		.S07_AXI_BID(),
		.S07_AXI_BREADY(1'sb0),
		.S07_AXI_BRESP(),
		.S07_AXI_BVALID(),
		.S07_AXI_RDATA(),
		.S07_AXI_RID(),
		.S07_AXI_RLAST(),
		.S07_AXI_RREADY(1'sb0),
		.S07_AXI_RRESP(),
		.S07_AXI_RVALID(),
		.S07_AXI_WDATA(1'sb0),
		.S07_AXI_WLAST(1'sb0),
		.S07_AXI_WREADY(),
		.S07_AXI_WSTRB(1'sb0),
		.S07_AXI_WVALID(1'sb0),
		.M00_AXI_ACLK(sys_clk),
		.M00_AXI_ARESET_OUT_N(M00_AXI_ARESET_OUT_N),
		.M00_AXI_AWID(c0_ddr4_s_axi_awid),
		.M00_AXI_AWADDR(c0_ddr4_s_axi_awaddr),
		.M00_AXI_AWLEN(c0_ddr4_s_axi_awlen),
		.M00_AXI_AWSIZE(c0_ddr4_s_axi_awsize),
		.M00_AXI_AWBURST(c0_ddr4_s_axi_awburst),
		.M00_AXI_AWLOCK(c0_ddr4_s_axi_awlock),
		.M00_AXI_AWCACHE(c0_ddr4_s_axi_awcache),
		.M00_AXI_AWPROT(c0_ddr4_s_axi_awprot),
		.M00_AXI_AWQOS(c0_ddr4_s_axi_awqos),
		.M00_AXI_AWVALID(c0_ddr4_s_axi_awvalid),
		.M00_AXI_AWREADY(c0_ddr4_s_axi_awready),
		.M00_AXI_WDATA(c0_ddr4_s_axi_wdata),
		.M00_AXI_WSTRB(c0_ddr4_s_axi_wstrb),
		.M00_AXI_WLAST(c0_ddr4_s_axi_wlast),
		.M00_AXI_WVALID(c0_ddr4_s_axi_wvalid),
		.M00_AXI_WREADY(c0_ddr4_s_axi_wready),
		.M00_AXI_BREADY(c0_ddr4_s_axi_bready),
		.M00_AXI_BID(c0_ddr4_s_axi_bid),
		.M00_AXI_BRESP(c0_ddr4_s_axi_bresp),
		.M00_AXI_BVALID(c0_ddr4_s_axi_bvalid),
		.M00_AXI_ARID(c0_ddr4_s_axi_arid),
		.M00_AXI_ARADDR(c0_ddr4_s_axi_araddr),
		.M00_AXI_ARLEN(c0_ddr4_s_axi_arlen),
		.M00_AXI_ARSIZE(c0_ddr4_s_axi_arsize),
		.M00_AXI_ARBURST(c0_ddr4_s_axi_arburst),
		.M00_AXI_ARLOCK(c0_ddr4_s_axi_arlock),
		.M00_AXI_ARCACHE(c0_ddr4_s_axi_arcache),
		.M00_AXI_ARPROT(c0_ddr4_s_axi_arprot),
		.M00_AXI_ARQOS(c0_ddr4_s_axi_arqos),
		.M00_AXI_ARVALID(c0_ddr4_s_axi_arvalid),
		.M00_AXI_ARREADY(c0_ddr4_s_axi_arready),
		.M00_AXI_RREADY(c0_ddr4_s_axi_rready),
		.M00_AXI_RID(c0_ddr4_s_axi_rid),
		.M00_AXI_RDATA(c0_ddr4_s_axi_rdata),
		.M00_AXI_RRESP(c0_ddr4_s_axi_rresp),
		.M00_AXI_RLAST(c0_ddr4_s_axi_rlast),
		.M00_AXI_RVALID(c0_ddr4_s_axi_rvalid)
	);
endmodule