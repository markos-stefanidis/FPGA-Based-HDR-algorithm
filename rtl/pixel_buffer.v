module pixel_buffer(
	input clk_133M,
	input clk_25M,
	input rst_n_25M,
	input rst_n_133M,

	input [127:0] data_high,
	input [127:0] data_mid,
	input [127:0] data_low,
	input rd_valid,
	
	output reg [127:0] pixel_data_high,
	output reg [127:0] pixel_data_mid,
	output reg [127:0] pixel_data_low,
	output reg pixel_data_valid
);

	reg [127:0] high [0:1];
	reg [127:0] mid [0:1];
	reg [127:0] low [0:1];

	reg [1:0] start_pnt;
	wire [1:0] start_pnt_grey;
	reg [1:0] q_start_pnt;
	reg [1:0] qq_start_pnt;
	reg [1:0] end_pnt;
	wire [1:0] end_pnt_grey;
	reg [1:0] q_end_pnt;
	reg [1:0] qq_end_pnt;

	wire empty;
	wire full;

	always@(posedge clk_133M) begin
		if(~rst_n_133M) begin
			q_start_pnt <= 2'b0;	
			qq_start_pnt <= 2'b0;	

			end_pnt <= 2'b0;
		end else begin
			q_start_pnt <= start_pnt_grey;
			qq_start_pnt <= q_start_pnt;

			if(rd_valid) begin
				if(~full) begin
					high[end_pnt[0]] <= data_high;
					mid[end_pnt[0]] <= data_mid;
					low[end_pnt[0]] <= data_low;

					end_pnt <= end_pnt + 1;
				end
			end
		end

	end

	always@(posedge clk_25M) begin
		if(~rst_n_25M) begin
			q_end_pnt <= 2'b0;	
			qq_end_pnt <= 2'b0;	
			
			start_pnt <= 2'b0;
			pixel_data_valid <= 1'b0;
		end else begin
			q_end_pnt <= end_pnt_grey;
			qq_end_pnt <= q_end_pnt;

			if(~empty) begin
				pixel_data_high <= high[start_pnt[0]];
				pixel_data_mid <= mid[start_pnt[0]];
				pixel_data_low <= low[start_pnt[0]];

				start_pnt <= start_pnt + 1;

				pixel_data_valid <= 1'b1;
			end else begin
				pixel_data_valid <= 1'b0;
			end
		end
	end

	assign start_pnt_grey = (start_pnt >> 1) ^ start_pnt;
	assign end_pnt_grey = (end_pnt >> 1) ^ end_pnt;

	assign empty = (qq_start_pnt == end_pnt_grey);
	assign full = ((start_pnt_grey[1] != qq_end_pnt[1]) && (start_pnt_grey[0] == qq_end_pnt[0]));

endmodule
