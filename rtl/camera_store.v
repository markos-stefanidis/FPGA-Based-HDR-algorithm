module camera_store(
	input clk_133M,
	input p_clk,
	input rst_n_133M,
	input rst_n_24M,
	
	input [255:0] p_data,
	input data_valid,
	input ram_busy,
	
	output reg [255:0] data,
	output reg [24:0] wr_address,
	output reg wr_req
);


	// This module is practically just a fifo used to cross from 24MHz clock domain to 133MHz clock domain
	
	wire rst;
	assign rst = ~rst_n_133M;
	wire [156:0] wr_data;
	wire [255:0] rd_data;
	reg rd_en;
	wire full;
	wire empty;
	reg reg_wr_req;
	
	reg [127:0] q_p_data;
	reg [127:0] qq_p_data;
	reg [24:0] q_wr_address;
	reg [24:0] qq_wr_address;
	reg q_last_frame;
	reg qq_last_frame;
	reg q_frame_done;
	reg qq_frame_done;
	reg q_data_valid;
	reg qq_data_valid;
	reg qqq_data_valid;
	reg q_rd_en;
	
	//assign rd_en = qqq_data_valid;
	//assign wr_data = {p_data, wr_address, last_frame, frame_done};
/*	

	// This section implements clock domain crossing by double-floping the data. With this method data corruption is more likely.


	always@(posedge clk_25M) begin
		if(~rst_n) begin
			o_p_data <= 128'b0;
			o_wr_address <= 25'b0;
			o_last_frame <= 1'b0;
			o_frame_done <= 1'b0;
			wr_req <= 1'b0;
			
			q_p_data <= 128'b0;
			qq_p_data <= 128'b0;
			q_wr_address <= 25'b0;
			qq_wr_address <= 25'b0;
			q_last_frame <= 1'b0;
			q_frame_done <= 1'b0;
			q_data_valid <= 1'b0;
			qq_data_valid <= 1'b0;
			
			reg_wr_req <= 1'b0;
		end else begin
		
			q_p_data <= p_data;
			qq_p_data <= q_p_data;
			
			q_wr_address <= wr_address;
			qq_wr_address <= q_wr_address;
			
			q_last_frame <= last_frame;
			qq_last_frame <= q_last_frame;
			
			q_frame_done <= frame_done;
			qq_frame_done <= q_frame_done;
			
			q_data_valid <= data_valid;
			qq_data_valid <= q_data_valid;
			
			if(qq_data_valid) begin
				o_p_data <= qq_p_data;
				o_wr_address <= qq_wr_address;
				o_last_frame <= qq_last_frame;
				o_frame_done <= qq_frame_done;
			end
			
			if(qq_data_valid) begin
				if(~in_full) begin
					wr_req <= 1'b1;
					reg_wr_req <= 1'b0;
				end else begin
					wr_req <= 1'b0;
					reg_wr_req <= 1'b1;
				end
			end else begin
				if(reg_wr_req && ~in_full) begin
					wr_req <= 1'b1;
					reg_wr_req <= 1'b0;
				end else begin
					wr_req <= 1'b0;
				end
			end
			
		end
	end
	
	*/

	always@(posedge clk_133M) begin
		if(~rst_n_133M) begin
			data <= 255'b0;
			wr_address <= 25'b0;
			wr_req <= 1'b0;
			q_data_valid <= 1'b0;
			qq_data_valid <= 1'b0;
			qqq_data_valid <= 1'b0;
			rd_en <= 1'b0;
			q_rd_en <= 1'b0;
		end else begin
			
			q_data_valid <= data_valid;
			qq_data_valid <= q_data_valid;
			qqq_data_valid <= qq_data_valid;
			rd_en <= qqq_data_valid && ~(qq_data_valid);
			q_rd_en <= rd_en;
			
			if(wr_req) begin
				if(wr_address < 25'hE0FFF) begin
					wr_address <= wr_address + 8;
				end else begin
					wr_address <= 25'h0;
				end
			end

			if(~ram_busy) begin
				data <= rd_data;
			end
			
			if(q_rd_en) begin // If the ram is not ready to accept requests, then reg_wr_req is asserted indicating that the write request has not been made.
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
		end
	end
	
	
	camera_fifo camera_fifo(
		.slow_clk (p_clk),
		.fast_clk (clk_133M),
		.rst_n_slow (rst_n_24M),
		.rst_n_fast (rst_n_133M),

		.rd_clk_en (rd_en),
		.wr_clk_en (data_valid),

		.data_in (p_data),

		.data_out (rd_data),
		.empty (empty),
		.full (full)

	);

endmodule
