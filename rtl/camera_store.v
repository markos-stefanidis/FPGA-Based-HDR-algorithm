module camera_store(
	input clk_133M,
	input p_clk,
	input rst_n_133M,
	input rst_n_24M,
	input frame_done,
	input [2:0] last_frame,

	input [127:0] p_data,
	input data_valid,
	input ram_busy,

	output reg [127:0] data,
	output reg [24:0] wr_address,
	output reg wr_req
);


	// This module is practically just a fifo used to cross from 24MHz clock domain to 133MHz clock domain

	wire rst;
	assign rst = ~rst_n_133M;
	wire [127:0] rd_data;
	reg rd_en;
	wire full;
	wire empty;
	reg reg_wr_req;

	reg q_data_valid;
	reg qq_data_valid;
	reg qqq_data_valid;
	reg q_rd_en;

	always@(posedge clk_133M) begin
		if(~rst_n_133M) begin
			data <= 127'b0;
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

			if (frame_done) begin
				case(last_frame)
					3'b000: wr_address <= 25'h0;
					3'b001: wr_address <= 25'h25800;
					3'b010: wr_address <= 25'h4B000;
					3'b011: wr_address <= 25'h70800;
					3'b100: wr_address <= 25'h96000;
					3'b101: wr_address <= 25'hBB800;
				endcase
			end else if(wr_req) begin
				wr_address <= wr_address + 4;
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
		.Data (p_data),
		.WrClock (p_clk),
		.RdClock (clk_133M),
		.WrEn (data_valid),
		.RdEn (rd_en),
		.Reset (rst),
		.RPReset (rst),
		.Q (rd_data),
		.Empty (empty),
		.Full (full)
	);

endmodule
