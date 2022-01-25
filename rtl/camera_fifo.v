`define N 256
`define depth 2
`define lg_depth 2 //lg(depth)+1
module camera_fifo(
	input slow_clk,
	input fast_clk,
	input rst_n_slow,
	input rst_n_fast,
	
	input rd_clk_en,
	input wr_clk_en,

	input [`N-1:0] data_in,

	output reg [`N-1:0] data_out,
	output empty,
	output full	
);

	reg [`lg_depth:0] start_pnt;
	reg [`lg_depth:0] end_pnt;

	wire [`lg_depth:0] start_pnt_grey;
	wire [`lg_depth:0] end_pnt_grey;

	reg [`lg_depth:0] q_start_pnt;
	reg [`lg_depth:0] qq_start_pnt;
	reg [`lg_depth:0] q_end_pnt;
	reg [`lg_depth:0] qq_end_pnt;
	
	reg [`N-1:0] mem [`depth-1:0];

	always@(posedge slow_clk) begin
		if(~rst_n_slow) begin
			q_start_pnt <= 0;
			qq_start_pnt <= 0;
			
			end_pnt <= 0;
		end else begin
			q_start_pnt <= start_pnt_grey;
			qq_start_pnt <= q_start_pnt;

			if(wr_clk_en) begin
				if(~full) begin
					mem[end_pnt[`lg_depth-1:0]] <= data_in;
					end_pnt <= end_pnt + 1;
				end
			end
		end
	end

	always@(posedge fast_clk) begin
		if(~rst_n_fast) begin
			q_end_pnt <= 0;
			qq_end_pnt <= 0;

			start_pnt <= 0;
		end else begin
			q_end_pnt <= end_pnt_grey;
			qq_end_pnt <= q_end_pnt;

			if(rd_clk_en) begin
				if(~empty) begin
					data_out <= mem[start_pnt[`lg_depth-1:0]];
					start_pnt <= start_pnt + 1;
				end
			end
		end
	end

	assign start_pnt_grey = (start_pnt >> 1) ^ start_pnt;
	assign end_pnt_grey = (end_pnt >> 1) ^ end_pnt;

	assign empty = (qq_start_pnt == end_pnt_grey);
	assign full = ((start_pnt_grey[`lg_depth:1] == ~qq_end_pnt[`lg_depth:1]) && (start_pnt_grey[0] == qq_end_pnt[0]));

endmodule
