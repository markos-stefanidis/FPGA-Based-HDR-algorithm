module hdr_store(
	input clk_25M,
	input clk_133M,
	input rst_n_25M,
	input rst_n_133M,

	input [127:0] hdr_data,
	input hdr_data_valid,
	input frame_done,

	input hdr_wr_ack,
	input ram_busy,

	output reg hdr_last_frame,
	output reg [24:0] wr_address,
	output [127:0] wr_data,
	output reg wr_req
);

	reg rd_en;

	wire full;
	wire empty;
	wire rst;
	wire rprst;

	reg reg_wr_req;
	reg q_hdr_data_valid;
	reg qq_hdr_data_valid;
	reg qqq_hdr_data_valid;
	reg q_rd_en;

	assign rst = ~rst_n_25M;
	assign rprst = ~rst_n_133M;

	always@(posedge clk_133M) begin
		if(~rst_n_133M) begin
			wr_req <= 1'b0;
			reg_wr_req <= 1'b0;
			q_hdr_data_valid <= 1'b0;
			qq_hdr_data_valid <= 1'b0;
			qqq_hdr_data_valid <= 1'b0;
			rd_en <= 1'b0;
			q_rd_en <= 1'b0;
			wr_address <= 25'b0;
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
				wr_address <= (hdr_last_frame) ? 25'h106800 : 25'hE1000;
			end else if (hdr_wr_ack) begin
				wr_address <= wr_address + 4;
			end

		end
	end

	hdr_fifo hdr_fifo(
		.Data (hdr_data),
		.WrClock (clk_25M),
		.RdClock (clk_133M),
		.WrEn (hdr_data_valid),
		.RdEn (rd_en),
		.Reset (rst),
		.RPReset (rprst),
		.Q (wr_data),
		.Empty (empty),
		.Full (full)
	);

endmodule
