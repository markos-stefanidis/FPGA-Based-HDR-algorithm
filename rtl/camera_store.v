module camera_store(
	input ui_clk,
	input p_clk,
	input ui_rst_n,
	input rst_n_24M,
	input frame_done,
	input [2:0] last_frame,
	input init_calib_complete,

	input [127:0] p_data,
	input data_valid,
	input camera_ack,

	output [127:0] data,
	output reg [26:0] wr_address,
	output reg wr_req
);


	// This module is practically just a fifo used to cross from 24MHz clock domain to 133MHz clock domain

	wire rst;
	wire rprst;
	wire [127:0] rd_data;
	reg rd_en;
	wire full;
	wire empty;
	reg reg_wr_req;

	reg q_data_valid;
	reg qq_data_valid;
	reg qqq_data_valid;
	reg qqqq_data_valid;
	reg q_rd_en;
	reg q_init_calib_complete;
	reg qq_init_calib_complete;

	wire wr_en;

	assign wr_en = data_valid && qq_init_calib_complete && ~full;

	always@(posedge p_clk) begin
		if(~rst_n_24M) begin
			q_data_valid <= 1'b0;
			q_init_calib_complete <= 1'b0;
			qq_init_calib_complete <= 1'b0;
		end else begin
			q_data_valid <= data_valid;

			q_init_calib_complete <= init_calib_complete;
			qq_init_calib_complete <= q_init_calib_complete;
		end
	end

	always@(posedge ui_clk) begin
		if(~ui_rst_n) begin
			wr_address <= 27'b0;
			wr_req <= 1'b0;
			qq_data_valid <= 1'b0;
			qqq_data_valid <= 1'b0;
			qqqq_data_valid <= 1'b0;
			rd_en <= 1'b0;
			q_rd_en <= 1'b0;
		end else begin

			qq_data_valid <= q_data_valid;
			qqq_data_valid <= qq_data_valid;
			qqqq_data_valid <= qqq_data_valid;
			rd_en <= qqqq_data_valid && ~(qqq_data_valid) && (~empty);
			q_rd_en <= rd_en;

			if (frame_done) begin
				case(last_frame)
					3'b000: wr_address <= 27'h0;
					3'b001: wr_address <= 27'h4B000;
					3'b101: wr_address <= 27'h96000;
					3'b100: wr_address <= 27'hE1000;
					3'b110: wr_address <= 27'h12C000;
					3'b010: wr_address <= 27'h177000;
				endcase
			end else if(camera_ack) begin
				wr_address <= wr_address + 8;
			end

			if(rd_en) begin
				wr_req <= 1'b1;
			end else if (camera_ack) begin
				wr_req <= 1'b0;
			end
		end
	end

	async_fifo #(.N(128), .ADDR(10)) camera_fifo(
		.wr_clk (p_clk),
		.rd_clk (ui_clk),
		.wr_rst_n (rst_n_24M),
		.rd_rst_n (ui_rst_n),
		.wr_en (wr_en),
		.rd_en (rd_en),
		.wr_data (p_data),

		.rd_data (data),
		.full (full),
		.empty (empty)
	);

endmodule
