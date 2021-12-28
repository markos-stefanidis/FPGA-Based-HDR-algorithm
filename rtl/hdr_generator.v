module image_generator(
	input clk,
	input rst_n,
	input hdr_en,
	
	input [2:0] last_frame,
	input frame_done,
	input [127:0] rd_data,
	input rd_valid,
	
	input ram_busy,
	
	input [127:0] camera_data,
	input camera_wr_req,

	output reg rd_req,
	output reg wr_req,
	output reg [24:0] rd_address,
	output reg [24:0] wr_address,
	output reg [127:0] wr_data
);

	reg [6:0] data_counter;
	reg [24:0] rd_address_next;
	reg req_all;
	reg all_read;
	reg [1:0] last_req;
	reg row_done;
	reg reg_rd_req;
	
	reg [127:0] rd_data_high;
	reg [127:0] rd_data_mid;
	reg [127:0] rd_data_low; 			
	reg last_read;

	wire hdr_ready;

	localparam N = 8;
	localparam FP = 4;
	
	always@(posedge clk) begin
		if(~rst_n) begin
			wr_data <= 128'b0;
			rd_address <= 25'b0;
			wr_address <= 25'b0;
			rd_data_high <= 128'b0;
			rd_data_mid <= 128'b0;
			rd_data_low <= 128'b0; 			
			rd_req <= 1'b0;
			wr_req <= 1'b0;
			data_counter <= 7'b0;
			last_req <= 2'b11;			
			req_all <= 1'b0;
			row_done <= 1'b0;
			all_read <= 1'b0;
			reg_rd_req <= 1'b0;
			last_read <= 1'b0;
		end else if (hdr_en) begin
			if(frame_done) begin
				case(last_frame)
										
					3'b000: begin
						rd_address <= 25'h96000; //Camera writing low exp, reading mid and then high
						rd_address_next <= 25'hBB800;
					end
					
					3'b001: begin
						rd_address <= 25'h0; //Camera writing mid exp, reading low and then high
						rd_address_next <= 25'hBB800;
					end
					
					3'b010: begin
						rd_address <= 25'h0; //Camera writing high exp, reading low and then mid
						rd_address_next <= 25'h25800;
					end
					
					3'b011: begin
						rd_address <= 25'h25800; //Camera writing low exp, reading mid and then high
						rd_address_next <= 25'h4B000;
					end
					
					3'b100: begin
						rd_address <= 25'h70800;  //Camera writing mid exp, reading low and then high
						rd_address_next <= 25'h4B000;
					end	
				
					3'b101: begin
						rd_address <= 25'h70800; //Camera Writing high exp, reading low and then mid
						rd_address <= 25'h9600; //Camera writing mid exp, reading low and then high
					end
				
				endcase
				last_read <= 1'b0;
			end else if(rd_valid) begin
				rd_address <= rd_address_next;
				rd_address_next <= rd_address + 4;
				case(last_frame)
						
					3'b000: begin
						rd_data_mid <= (last_read) ? rd_data_mid : rd_data;
						rd_data_high <= (last_read) ? rd_data : rd_data_high;
					end
					
					3'b001: begin
						rd_data_low <= (last_read) ? rd_data_low : rd_data;
						rd_data_high <= (last_read) ? rd_data : rd_data_high;
					end
					
					3'b010: begin
						rd_data_low <= (last_read) ? rd_data_low : rd_data;
						rd_data_mid <= (last_read) ? rd_data : rd_data_mid;
					end
					
					3'b011: begin
						rd_data_mid <= (last_read) ? rd_data_mid : rd_data;
						rd_data_high <= (last_read) ? rd_data : rd_data_high;
					end
					
					3'b100: begin
						rd_data_low <= (last_read) ? rd_data_low : rd_data;
						rd_data_high <= (last_read) ? rd_data : rd_data_high;
					end	
				
					3'b101: begin
						rd_data_low <= (last_read) ? rd_data_low : rd_data;
						rd_data_mid <= (last_read) ? rd_data : rd_data_mid;
					end
				endcase
				last_read <= ~last_read;
			end

			if(camera_wr_req) begin
				case(last_frame)
						
					3'b000: begin
						rd_data_low <= camera_data;
					end
					
					3'b001: begin
						rd_data_mid <= camera_data;
					end
					
					3'b010: begin
						rd_data_high <= camera_data;
					end
					
					3'b011: begin
						rd_data_low <= camera_data;
					end
					
					3'b100: begin
						rd_data_mid <= camera_data;
					end	
				
					3'b101: begin
						rd_data_high <= camera_data;
					end	
				endcase
				
			end
			
			if(frame_done || ((rd_valid || reg_rd_req)&& ~last_read) || camera_wr_req)  begin 
				if(~ram_busy && ~row_done) begin
					rd_req <= 1'b1;
					reg_rd_req <= 1'b0;
				end else if (~row_done) begin
					rd_req <= 1'b0;
					reg_rd_req <= 1'b1;
				end else begin
					rd_req <= 1'b0;
					reg_rd_req <= 1'b0;
				end
			end else begin
				rd_req <= 1'b0;
			end

			all_read <= camera_wr_req; 
		end	
	end

	reg [15:0] pixel_data_high;
	reg [15:0] pixel_data_mid;
	reg [15:0] pixel_data_low;
	reg [4:0] pixel_counter;
	reg hdr_start;
	
	always@(posedge clk) begin
		if(~rst_n) begin
			pixel_data_high <= 16'b0;
			pixel_data_mid <= 16'b0;
			pixel_data_low <= 16'b0;
			pixel_counter <= 3'b0;
			hdr_start <= 1'b0;
		end else begin
			if(all_read) begin
				if(hdr_ready) begin
					case(pixel_counter)

						3'b000: begin
							pixel_data_high <= rd_data_high[15:0];
							pixel_data_mid <= rd_data_mid[15:0];
							pixel_data_low <= rd_data_low[15:0];
						end	

						3'b001: begin
							pixel_data_high <= rd_data_high[31:16];
							pixel_data_mid <= rd_data_mid[31:16];
							pixel_data_low <= rd_data_low[31:16];
						end	

						3'b010: begin
							pixel_data_high <= rd_data_high[47:32];
							pixel_data_mid <= rd_data_mid[47:32];
							pixel_data_low <= rd_data_low[47:32];
						end	
						
						3'b011: begin
							pixel_data_high <= rd_data_high[63:48];
							pixel_data_mid <= rd_data_mid[63:48];
							pixel_data_low <= rd_data_low[63:48];
						end	

						3'b100: begin
							pixel_data_high <= rd_data_high[79:64];
							pixel_data_mid <= rd_data_mid[79:64];
							pixel_data_low <= rd_data_low[79:64];
						end	

						3'b101: begin
							pixel_data_high <= rd_data_high[95:80];
							pixel_data_mid <= rd_data_mid[95:80];
							pixel_data_low <= rd_data_low[95:80];
						end	

						3'b110: begin
							pixel_data_high <= rd_data_high[111:96];
							pixel_data_mid <= rd_data_mid[111:96];
							pixel_data_low <= rd_data_low[111:96];
						end	

						3'b111: begin
							pixel_data_high <= rd_data_high[127:112];
							pixel_data_mid <= rd_data_mid[127:112];
							pixel_data_low <= rd_data_low[127:112];
						end	

					endcase
					hdr_start <= 1'b1;
					pixel_counter <= pixel_counter + 1;
				end else begin
					hdr_start <= 1'b0;
				end
			end
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

	wire [7:0] lE_red;
	wire [7:0] lE_blue;
	wire [7:0] lE_green;

	assign red_high = pixel_data_high[7:3];
	assign red_mid = pixel_data_mid[7:3];
	assign red_low = pixel_data_low[7:3];

	assign green_high = {pixel_data_high[2:0], pixel_data_high[15:13]};
	assign green_mid = {pixel_data_high[2:0], pixel_data_high[15:13]};
	assign green_low = {pixel_data_high[2:0], pixel_data_high[15:13]};

	assign blue_high = pixel_data_high[12:8];
	assign blue_mid = pixel_data_mid[12:8];
	assign blue_low = pixel_data_low[12:8];

	hdr #(.N(N), .FP(FP)) hdr
	(
		.clk (clk),
		.rst_n (rst_n),
		
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
		.hdr_ready (hdr_ready),
		.hdr_done (hdr_done)
	);	
endmodule