module hdr_store(
	input clk_25M,
	input clk_133M,
	input rst_n_25M,
	input rst_n_133M,

	input [127:0] hdr_data,
	input hdr_data_valid,
	input frame_done,

	input ram_busy,

	output reg hdr_last_frame,
	output reg [24:0] wr_address,
	output reg [127:0] wr_data,
	output reg wr_req
);

	reg [127:0] fifo[0:1];

	reg [1:0] start_pnt;
	reg [1:0] end_pnt;

	wire [1:0] start_pnt_grey;
	wire [1:0] end_pnt_grey;

	reg [1:0] q_start_pnt;
	reg [1:0] qq_start_pnt;
	reg [1:0] q_end_pnt;
	reg [1:0] qq_end_pnt;
	reg rd_en;

	wire full;
	wire empty;

	always@(posedge clk_25M) begin
		if(~rst_n_25M) begin
			q_start_pnt <= 2'b0;
			qq_start_pnt <= 2'b0;

			end_pnt <= 2'b0;
		end else begin
			q_start_pnt <= start_pnt_grey;
			qq_start_pnt <= q_start_pnt;

			if(hdr_data_valid) begin
				if(~full) begin
					fifo[end_pnt[0]] <= hdr_data;
					end_pnt <= end_pnt + 1;
				end
			end
		end
	end


	always@(posedge clk_133M) begin
		if(~rst_n_133M) begin
			q_end_pnt <= 2'b0;
			qq_end_pnt <= 2'b0;

			start_pnt <= 2'b0;
		end else begin
			q_end_pnt <= end_pnt;
			qq_end_pnt <= q_end_pnt;

			if(rd_en) begin
				if(~empty) begin
					wr_data <= fifo[start_pnt[0]];
					start_pnt <= start_pnt + 1;
				end
			end
		end
	end

	assign start_pnt_grey = (start_pnt >> 1) ^ start_pnt;
	assign end_pnt_grey = (end_pnt >> 1) ^ end_pnt;

	assign empty = (qq_start_pnt == end_pnt_grey);
	assign full = ((start_pnt_grey[1] != qq_end_pnt[1]) && (start_pnt_grey[0] == qq_end_pnt[0]));

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
			wr_address <= 25'b0;
			hdr_last_frame <= 1'b0;
		end else begin
			
			q_hdr_data_valid <= hdr_data_valid;
			qq_hdr_data_valid <= q_hdr_data_valid;
			qqq_hdr_data_valid <= qq_hdr_data_valid;
			rd_en <= qqq_hdr_data_valid && ~(qq_hdr_data_valid);
			q_rd_en <= rd_en;

			hdr_last_frame <= (frame_done) ? (~hdr_last_frame) : hdr_last_frame;

			if(q_rd_en) begin
				if(~ram_busy) begin
					wr_req <= 1'b1;
					reg_wr_req <= 1'b0;
				end else begin
					wr_req <= 1'b0;
					reg_wr_req <= 1'b1;
				end
			end else begin
				if(reg_wr_req && ~ram_busy) begin
					wr_req <= 1'b1;
					reg_wr_req <= 1'b0;
				end else begin
					wr_req <= 1'b0;
					reg_wr_req <= 1'b0;
				end
			end

			if (frame_done) begin
				wr_address <= (hdr_last_frame) ? 25'h106800 : 25'hE1000;
			end else if (wr_req) begin
				wr_address <= wr_address + 4;
			end

		end
	end

endmodule
