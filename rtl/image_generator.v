module image_generator(
	input clk_133M,
	input clk_25M,
	input rst_n_133M,
	input rst_n_25M,
	input hdr_en,

	input [2:0] last_frame,
	input frame_done_133M,
	input frame_done_25M,
	input [127:0] rd_data,
	input rd_valid,

	input hdr_rd_ack,
	input hdr_wr_ack,

	input [127:0] camera_data,
	input camera_wr_req,

	output reg rd_req,
	output wr_req,
	output reg [26:0] rd_address,
	output [26:0] wr_address,
	output hdr_last_frame,
	output [127:0] wr_data
);

	reg [26:0] rd_address_next;
	reg all_read;
	reg  last_req;
	reg reg_rd_req;

	reg [127:0] rd_data_high;
	reg [127:0] rd_data_mid;
	reg [127:0] rd_data_low;
	reg last_read;

	reg q_camera_wr_req;

	localparam N = 8;
	localparam FP = 4;

	always@(posedge clk_133M) begin
		q_camera_wr_req <= camera_wr_req;

		if(~rst_n_133M) begin
			rd_address <= 27'b0;
			rd_data_high <= 127'b0;
			rd_data_mid <= 127'b0;
			rd_data_low <= 127'b0;
			rd_req <= 1'b0;
			last_req <= 1'b1;
			all_read <= 1'b0;
			reg_rd_req <= 1'b0;
			last_read <= 1'b0;
		end else if (hdr_en) begin
			if(frame_done_133M) begin
				case(last_frame)

					3'b000: begin
						rd_address <= 27'h12C000; //Camera writing low exp, reading mid and then high
						rd_address_next <= 27'h177000;
					end

					3'b001: begin
						rd_address <= 27'h0; //Camera writing mid exp, reading low and then high
						rd_address_next <= 27'h177000;
					end

					3'b101: begin
						rd_address <= 27'h0; //Camera writing high exp, reading low and then mid
						rd_address_next <= 27'h4B000;
					end

					3'b100: begin
						rd_address <= 27'h4B000; //Camera writing low exp, reading mid and then high
						rd_address_next <= 27'h96000;
					end

					3'b110: begin
						rd_address <= 27'hE1000;  //Camera writing mid exp, reading low and then high
						rd_address_next <= 27'h96000;
					end

					3'b010: begin
						rd_address <= 27'hE1000; //Camera Writing high exp, reading low and then mid
						rd_address_next <= 27'h12C000;
					end

				endcase
				last_req <= 1'b0;
			end else if(hdr_rd_ack) begin
				rd_address <= rd_address_next;
				rd_address_next <= rd_address + 8;
				last_req <= ~last_req;
			end

			if(frame_done_133M) begin
				last_read <= 1'b0;
			end else if (rd_valid) begin
				last_read <= ~last_read;
			end

			if(rd_valid) begin
				case(last_frame)

					3'b000: begin
						rd_data_mid <= (last_read) ? rd_data_mid : rd_data;
						rd_data_high <= (last_read) ? rd_data : rd_data_high;
					end

					3'b001: begin
						rd_data_low <= (last_read) ? rd_data_low : rd_data;
						rd_data_high <= (last_read) ? rd_data : rd_data_high;
					end

					3'b101: begin
						rd_data_low <= (last_read) ? rd_data_low : rd_data;
						rd_data_mid <= (last_read) ? rd_data : rd_data_mid;
					end

					3'b100: begin
						rd_data_mid <= (last_read) ? rd_data_mid : rd_data;
						rd_data_high <= (last_read) ? rd_data : rd_data_high;
					end

					3'b110: begin
						rd_data_low <= (last_read) ? rd_data_low : rd_data;
						rd_data_high <= (last_read) ? rd_data : rd_data_high;
					end

					3'b010: begin
						rd_data_low <= (last_read) ? rd_data_low : rd_data;
						rd_data_mid <= (last_read) ? rd_data : rd_data_mid;
					end
				endcase

			end

			if(camera_wr_req && ~q_camera_wr_req) begin
				case(last_frame)

					3'b000: begin
						rd_data_low <= camera_data;
					end

					3'b001: begin
						rd_data_mid <= camera_data;
					end

					3'b101: begin
						rd_data_high <= camera_data;
					end

					3'b100: begin
						rd_data_low <= camera_data;
					end

					3'b110: begin
						rd_data_mid <= camera_data;
					end

					3'b010: begin
						rd_data_high <= camera_data;
					end
				endcase

			end

			if(frame_done_133M || ((hdr_rd_ack) && ~last_req) || (camera_wr_req && ~q_camera_wr_req))  begin
				rd_req <= 1'b1;
			end else if (hdr_rd_ack) begin
				rd_req <= 1'b0;
			end

			all_read <= camera_wr_req && ~q_camera_wr_req;
		end
	end

	wire [127:0] pixel_data_high;
	wire [127:0] pixel_data_mid;
	wire [127:0] pixel_data_low;

	wire pixel_data_valid;

	pixel_buffer pixel_buffer(
		.clk_133M (clk_133M),
		.clk_25M (clk_25M),
		.rst_n_133M (rst_n_133M),
		.rst_n_25M (rst_n_25M),

		.data_high (rd_data_high),
		.data_mid (rd_data_mid),
		.data_low (rd_data_low),
		.rd_valid (all_read),

		.pixel_data_high (pixel_data_high),
		.pixel_data_mid (pixel_data_mid),
		.pixel_data_low (pixel_data_low),
		.pixel_data_valid (pixel_data_valid)
	);


	reg [15:0] pixel_high;
	reg [15:0] pixel_mid;
	reg [15:0] pixel_low;
	reg hdr_start;
	reg STATE;
	reg [2:0] pixel_counter;

	localparam WAITING_DATA = 0;
	localparam PROCESSING = 1;

	always@(posedge clk_25M) begin
		if(~rst_n_25M) begin
			pixel_high <= 16'b0;
			pixel_mid <= 16'b0;
			pixel_low <= 16'b0;
			pixel_counter <= 3'b0;
			hdr_start <= 1'b0;
			STATE <= WAITING_DATA;
		end else begin
			case(STATE)

				WAITING_DATA: begin
					STATE <= (pixel_data_valid) ? PROCESSING : WAITING_DATA;
					pixel_counter <= 3'b0;
					hdr_start <= 1'b0;
				end

				PROCESSING: begin
					case(pixel_counter)

						3'b000: begin
							pixel_high <= pixel_data_high[15:0];
							pixel_mid <= pixel_data_mid[15:0];
							pixel_low <= pixel_data_low[15:0];
						end

						3'b001: begin
							pixel_high <= pixel_data_high[31:16];
							pixel_mid <= pixel_data_mid[31:16];
							pixel_low <= pixel_data_low[31:16];
						end

						3'b010: begin
							pixel_high <= pixel_data_high[47:32];
							pixel_mid <= pixel_data_mid[47:32];
							pixel_low <= pixel_data_low[47:32];
						end

						3'b011: begin
							pixel_high <= pixel_data_high[63:48];
							pixel_mid <= pixel_data_mid[63:48];
							pixel_low <= pixel_data_low[63:48];
						end

						3'b100: begin
							pixel_high <= pixel_data_high[79:64];
							pixel_mid <= pixel_data_mid[79:64];
							pixel_low <= pixel_data_low[79:64];
						end

						3'b101: begin
							pixel_high <= pixel_data_high[95:80];
							pixel_mid <= pixel_data_mid[95:80];
							pixel_low <= pixel_data_low[95:80];
						end

						3'b110: begin
							pixel_high <= pixel_data_high[111:96];
							pixel_mid <= pixel_data_mid[111:96];
							pixel_low <= pixel_data_low[111:96];
						end

						3'b111: begin
							pixel_high <= pixel_data_high[127:112];
							pixel_mid <= pixel_data_mid[127:112];
							pixel_low <= pixel_data_low[127:112];
						end
/*
						4'b1000: begin
							pixel_high <= pixel_data_high[143:128];
							pixel_mid <= pixel_data_mid[143:128];
							pixel_low <= pixel_data_low[143:128];
						end

						4'b1001: begin
							pixel_high <= pixel_data_high[159:144];
							pixel_mid <= pixel_data_mid[159:144];
							pixel_low <= pixel_data_low[159:144];
						end

						4'b1010: begin
							pixel_high <= pixel_data_high[175:160];
							pixel_mid <= pixel_data_mid[175:160];
							pixel_low <= pixel_data_low[175:160];
						end

						4'b1011: begin
							pixel_high <= pixel_data_high[191:176];
							pixel_mid <= pixel_data_mid[191:176];
							pixel_low <= pixel_data_low[191:176];
						end

						4'b1100: begin
							pixel_high <= pixel_data_high[207:192];
							pixel_mid <= pixel_data_mid[207:192];
							pixel_low <= pixel_data_low[207:192];
						end

						4'b1101: begin
							pixel_high <= pixel_data_high[223:208];
							pixel_mid <= pixel_data_mid[223:208];
							pixel_low <= pixel_data_low[223:208];
						end

						4'b1110: begin
							pixel_high <= pixel_data_high[239:224];
							pixel_mid <= pixel_data_mid[239:224];
							pixel_low <= pixel_data_low[239:224];
						end

						4'b1111: begin
							pixel_high <= pixel_data_high[255:240];
							pixel_mid <= pixel_data_mid[255:240];
							pixel_low <= pixel_data_low[255:240];
						end
*/
					endcase
					pixel_counter <= pixel_counter + 1;
					STATE <= (pixel_counter == 3'b111) ? WAITING_DATA : PROCESSING;
					hdr_start <= 1'b1;
				end
			endcase
		end
	end

	wire [4:0]  red_high;
	wire [4:0]  red_mid;
	wire [4:0]  red_low;

	wire [5:0]  green_high;
	wire [5:0]  green_mid;
	wire [5:0]  green_low;

	wire [4:0]  blue_high;
	wire [4:0]  blue_mid;
	wire [4:0]  blue_low;

	wire [N-1:0] lE_red;
	wire [N-1:0] lE_blue;
	wire [N-1:0] lE_green;

	assign red_high = pixel_high[7:3];
	assign red_mid = pixel_mid[7:3];
	assign red_low = pixel_low[7:3];

	assign green_high = {pixel_high[2:0], pixel_high[15:13]};
	assign green_mid = {pixel_mid[2:0], pixel_mid[15:13]};
	assign green_low = {pixel_low[2:0], pixel_low[15:13]};

	assign blue_high = pixel_high[12:8];
	assign blue_mid = pixel_mid[12:8];
	assign blue_low = pixel_low[12:8];

	hdr hdr
	(
		.clk (clk_25M),
		.rst_n (rst_n_25M),

		.red_high (red_high),
		.red_mid (red_mid),
		.red_low (red_low),

		.green_high (green_high),
		.green_mid (green_mid),
		.green_low (green_low),

		.blue_high (blue_high),
		.blue_mid (blue_mid),
		.blue_low (blue_low),

		.hdr_start (hdr_start),

		.lE_red (lE_red),
		.lE_green (lE_green),
		.lE_blue (lE_blue),
		.hdr_done (hdr_done)
	);

	wire [127:0] hdr_data;
	wire hdr_data_valid;

	tone_map tone_map(
		.clk (clk_25M),
		.rst_n (rst_n_25M),

		.hdr_done (hdr_done),
		.lE_red (lE_red),
		.lE_green (lE_green),
		.lE_blue (lE_blue),

		.frame_done (frame_done_25M),

		.hdr_data (hdr_data),
		.hdr_data_valid (hdr_data_valid)
	);

	hdr_store hdr_store(
		.clk_25M (clk_25M),
		.clk_133M (clk_133M),
		.rst_n_25M (rst_n_25M),
		.rst_n_133M (rst_n_133M),

		.hdr_data (hdr_data),
		.hdr_data_valid (hdr_data_valid),
		.frame_done (frame_done_133M),

		.hdr_wr_ack (hdr_wr_ack),

		.hdr_last_frame (hdr_last_frame),
		.wr_address (wr_address),
		.wr_data (wr_data),
		.wr_req (wr_req)
	);




endmodule
