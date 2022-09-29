module hdr_store(
	input clk_25M,
	input clk_133M,
	input rst_n_25M,
	input rst_n_133M,

	input [127:0] hdr_data,
	input hdr_data_valid,
	input frame_done,

	input hdr_wr_ack,

	output reg hdr_last_frame,
	output reg [26:0] wr_address,
	output [127:0] wr_data,
	output reg wr_req
);

	reg rd_en;

	wire full;
	wire empty;

	reg reg_wr_req;
	reg q_hdr_data_valid;
	reg qq_hdr_data_valid;
	reg qqq_hdr_data_valid;
	reg q_rd_en;

	always@(posedge clk_133M) begin
		if(~rst_n_133M) begin
			wr_req <= 1'b0;
			reg_wr_req <= 1'b0;
			q_hdr_data_valid <= 1'b0;
			qq_hdr_data_valid <= 1'b0;
			qqq_hdr_data_valid <= 1'b0;
			rd_en <= 1'b0;
			q_rd_en <= 1'b0;
			wr_address <= 27'b0;
			hdr_last_frame <= 1'b0;
		end else begin

			q_hdr_data_valid <= hdr_data_valid;
			qq_hdr_data_valid <= q_hdr_data_valid;
			qqq_hdr_data_valid <= qq_hdr_data_valid;
			rd_en <= qqq_hdr_data_valid && ~(qq_hdr_data_valid);
			q_rd_en <= rd_en;

			hdr_last_frame <= (frame_done) ? (~hdr_last_frame) : hdr_last_frame;

			if(rd_en) begin
				wr_req <= 1'b1;
			end else if (hdr_wr_ack) begin
				wr_req <= 1'b0;
			end

			if (frame_done) begin
				wr_address <= (hdr_last_frame) ? 27'h1C2000 : 27'h20D000;
			end else if (hdr_wr_ack) begin
				wr_address <= wr_address + 8;
			end

		end
	end

	async_fifo #(.N(128), .ADDR(10)) hdr_fifo(
		.wr_data (hdr_data),
		.wr_clk (clk_25M),
		.rd_clk (clk_133M),
		.wr_en (hdr_data_valid),
		.rd_en (rd_en),
		.wr_rst_n (rst_n_25M),
		.rd_rst_n (rst_n_133M),
		.rd_data (wr_data),
		.empty (empty),
		.full (full)
	);

endmodule
