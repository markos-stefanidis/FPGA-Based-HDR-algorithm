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

	wire rst;
	wire rprst;

	assign rst = ~rst_n_133M;
	assign rprst = ~rst_n_25M;

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



	pixel_fifo fifo_high(
		.Data (data_high),
		.WrClock (clk_133M),
		.RdClock (clk_25M),
		.WrEn (rd_valid),
		.RdEn (rd_en),
		.Reset (rst),
		.RPReset (rprst),
		.Q (pixel_data_high),
		.Empty (high_empty),
		.Full (high_full)
	);

	pixel_fifo fifo_mid(
		.Data (data_mid),
		.WrClock (clk_133M),
		.RdClock (clk_25M),
		.WrEn (rd_valid),
		.RdEn (rd_en),
		.Reset (rst),
		.RPReset (rprst),
		.Q (pixel_data_mid),
		.Empty (mid_empty),
		.Full (mid_full)
	);

	pixel_fifo fifo_low(
		.Data (data_low),
		.WrClock (clk_133M),
		.RdClock (clk_25M),
		.WrEn (rd_valid),
		.RdEn (rd_en),
		.Reset (rst),
		.RPReset (rprst),
		.Q (pixel_data_low),
		.Empty (low_empty),
		.Full (low_full)
	);

endmodule
