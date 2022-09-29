module pixel_buffer(
	input clk_133M,
	input clk_25M,
	input rst_n_25M,
	input rst_n_133M,

	input [127:0] data_high,
	input [127:0] data_mid,
	input [127:0] data_low,
	input rd_valid,

	output [127:0] pixel_data_high,
	output [127:0] pixel_data_mid,
	output [127:0] pixel_data_low,
	output reg pixel_data_valid
);

	wire high_empty;
	wire high_full;

	wire mid_empty;
	wire mid_full;

	wire low_empty;
	wire low_full;

	reg data_ready;
	reg q_data_ready;

	wire rd_en;

	assign rd_en = data_ready && ~(q_data_ready);

	always@(posedge clk_25M) begin
		if(~rst_n_25M) begin
			pixel_data_valid <= 1'b0;
			data_ready <= 1'b0;
			q_data_ready <= 1'b0;
		end else begin
			data_ready <= ~(high_empty || mid_empty || low_empty);
			q_data_ready <= data_ready;
			pixel_data_valid <= rd_en;
		end
	end



	async_fifo #(.N(128), .ADDR(10)) fifo_high(
		.wr_data (data_high),
		.wr_clk (clk_133M),
		.rd_clk (clk_25M),
		.wr_en (rd_valid),
		.rd_en (rd_en),
		.wr_rst_n (rst_n_133M),
		.rd_rst_n (rst_n_25M),
		.rd_data (pixel_data_high),
		.empty (high_empty),
		.full (high_full)
	);

	async_fifo #(.N(128), .ADDR(10)) fifo_mid(
		.wr_data (data_mid),
		.wr_clk (clk_133M),
		.rd_clk (clk_25M),
		.wr_en (rd_valid),
		.rd_en (rd_en),
		.wr_rst_n (rst_n_133M),
		.rd_rst_n (rst_n_25M),
		.rd_data (pixel_data_mid),
		.empty (mid_empty),
		.full (mid_full)
	);

	async_fifo #(.N(128), .ADDR(10)) fifo_low(
		.wr_data (data_low),
		.wr_clk (clk_133M),
		.rd_clk (clk_25M),
		.wr_en (rd_valid),
		.rd_en (rd_en),
		.wr_rst_n (rst_n_133M),
		.rd_rst_n (rst_n_25M),
		.rd_data (pixel_data_low),
		.empty (low_empty),
		.full (low_full)
	);

endmodule
