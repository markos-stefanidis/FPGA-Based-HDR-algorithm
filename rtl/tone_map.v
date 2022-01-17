module tone_map(
	input clk,
	input rst_n,
	
	input hdr_done,
	input [11:0] lE_red,
	input [11:0] lE_green,
	input [11:0] lE_blue,
	
	input frame_done,
	
	input ram_busy,
	
	output [2:0] last_frame,
	output reg [127:0] wr_data,
	output reg wr_req
);

	//N (number of pixels) = 307200, a = 0.18, aN = a*N = 55296
	localparam FP = 8;
	localparam N = 307200 << FP;
	localparam a = 46;
	localparam max_red = 31 << FP;
	localparam max_green = 63 << FP;
	localparam max_blue = 31 << FP;
	
	reg [31:0] slE_red;
	reg [31:0] slE_green;
	reg [31:0] slE_blue;
	
	reg [15:0] glE_red;
	reg [15:0] glE_green;
	reg [15:0] glE_blue;
	
	wire [31:0] gE_red;
	wire [31:0] gE_green;
	wire [31:0] gE_blue;
	
	reg [31:0] E_red;
	reg [31:0] E_green;
	reg [31:0] E_blue;
	
	reg [31:0] D_red;
	reg [31:0] D_green;
	reg [31:0] D_blue;
	
	reg [2:0] pixel_counter;
	
	wire [11:0] exp_in_red;
	wire [11:0] exp_in_green;
	wire [11:0] exp_in_blue;
	
	wire [31:0] exp_out_red;
	wire [31:0] exp_out_green;
	wire [31:0] exp_out_blue;
	
	wire lut_rst;
	assign lut_rst = ~rst_n;
	
	reg gE_sum_ready;
	reg gE_ready;
	reg E_ready;
	reg allE_ready;
	reg div_ready;
	reg D_ready;
	
	reg [31:0] aE_red;
	reg [31:0] aE_green;
	reg [31:0] aE_blue;
	
	reg [31:0] divE_red;
	reg [31:0] divE_green;
	reg [31:0] divE_blue;
	
	wire exp_lut_en;
	assign exp_lut_en = hdr_done || gE_sum_ready;
	
	always@(posedge clk) begin
		if(~rst_n) begin
			slE_red <= 32'b0;
			slE_green <= 32'b0;
			slE_blue <= 32'b0;
			gE_sum_ready <= 1'b0;
			gE_ready <= 1'b0;
			E_ready <= 1'b0;
			aE_red <= 32'b0;
			aE_green <= 32'b0;
			aE_blue <= 32'b0;
		end else begin
		
			gE_sum_ready <= frame_done;
			gE_ready <= gE_sum_ready;
		
			E_ready <= hdr_done;
			//allE_ready <= E_ready;
			div_ready <= E_ready;
			D_ready <= div_ready;
		
			if (hdr_done) begin
				slE_red <= glE_red + lE_red;
				slE_green <= glE_green + lE_green;
				slE_blue <= glE_blue + lE_blue;
			end else if (frame_done) begin
				slE_red <= 32'b0;
				slE_green <= 32'b0;
				slE_blue <= 32'b0;
			end
		
			if(frame_done) begin
				glE_red <= (slE_red << FP) / N;
				glE_green <= (slE_red << FP) / N;
				glE_blue <= (slE_red << FP) / N;
			end
		
			if (gE_ready) begin
				aE_red <= (exp_out_red << FP) / a;
				aE_green <= (exp_out_green << FP) / a;
				aE_blue <= (exp_out_blue << FP) / a;
			end else if (E_ready) begin
				E_red <= exp_out_red;
				E_green <= exp_out_green;
				E_blue <= exp_out_blue;
			end
		
			if (E_ready) begin
				divE_red <= (aE_red << FP) / exp_out_red + 256;
				divE_green <= (aE_green << FP) / exp_out_green + 256;
				divE_blue <= (aE_blue << FP) / exp_out_blue + 256;
			end
		
			if(div_ready) begin
				D_red <= (max_red << FP)/divE_red;
				D_green <= (max_green << FP)/divE_green;
				D_blue <= (max_blue << FP)/divE_blue;
			end
		
	/*	
			if(gE_sum_ready) begin
			        exp_in_red <= glE_red[12:0];
	div		        exp_in_green <= glE_green[12:0];
			        exp_in_blue <= glE_blue[12:0];
			end else if (hdr_done) begin
			        exp_in_red <= lE_red;
			        exp_in_green <= lE_green;
			        exp_in_blue <= lE_blue;
			end
	*/
		end
	end

	assign exp_in_red = (hdr_done) ? (lE_red) : ((gE_sum_ready) ? (glE_red[11:0]) : 12'b0);
	assign exp_in_green = (hdr_done) ? (lE_green) : ((gE_sum_ready) ? (glE_green[11:0]) : 12'b0);
	assign exp_in_blue = (hdr_done) ? (lE_blue) : ((gE_sum_ready) ? (glE_blue[11:0]) : 12'b0);
	
	exp_lut exp_lut_red(
		.Address (exp_in_red),
		.OutClock (clk),
		.OutClockEn (exp_lut_en),
		.Reset (lut_rst),
	
		.Q (exp_out_red)
	);
	
	exp_lut exp_lut_green(
		.Address (exp_in_green),
		.OutClock (clk),
		.OutClockEn (exp_lut_en),
		.Reset (lut_rst),
	
		.Q (exp_out_green)
	);
	
	exp_lut exp_lut_blue(
		.Address (exp_in_blue),
		.OutClock (clk),
		.OutClockEn (exp_lut_en),
		.Reset (lut_rst),
	
		.Q (exp_out_blue)
	);
	
	wire [4:0] hdr_red;
	wire [5:0] hdr_green;
	wire [4:0] hdr_blue;
	
	reg wr_ready;
	reg reg_wr_req;
	
	assign hdr_red = (|(D_red[FP-1:0])) ? (D_red[FP+4:FP] + 1) : (D_red[FP+5:FP]);
	assign hdr_green = (|(D_green[FP-1:0])) ? (D_green[FP+5:FP] + 1) : (D_green[FP+6:FP]);
	assign hdr_blue = (|(D_blue[FP-1:0])) ? (D_blue[FP+4:FP] + 1) : (D_blue[FP+5:FP]);
	
	always@(posedge clk) begin
		if(~rst_n) begin
			pixel_counter <= 3'b0;
			wr_req <= 1'b0;
			wr_ready <= 1'b0;
			reg_wr_req <= 1'b0;
		end else begin
			if (D_ready) begin
				case(pixel_counter)
					3'b000: begin
						wr_data[7:0] <= {hdr_red, hdr_green[5:4]};
						wr_data[15:0] <= {hdr_green[4:0], hdr_blue};
					end
					
					3'b001: begin
						wr_data[23:16] <= {hdr_red, hdr_green[5:4]};
						wr_data[31:24] <= {hdr_green[4:0], hdr_blue};
					end
					
					3'b010: begin
						wr_data[39:32] <= {hdr_red, hdr_green[5:4]};
						wr_data[47:40] <= {hdr_green[4:0], hdr_blue};
					end
					
					3'b011: begin
						wr_data[55:48] <= {hdr_red, hdr_green[5:4]};
						wr_data[63:56] <= {hdr_green[4:0], hdr_blue};
					end
					
					3'b100: begin
						wr_data[71:64] <= {hdr_red, hdr_green[5:4]};
						wr_data[79:72] <= {hdr_green[4:0], hdr_blue};
					end
					
					3'b101: begin
						wr_data[87:80] <= {hdr_red, hdr_green[5:4]};
						wr_data[95:88] <= {hdr_green[4:0], hdr_blue};
					end
					
					3'b110: begin
						wr_data[103:96] <= {hdr_red, hdr_green[5:4]};
						wr_data[111:104] <= {hdr_green[4:0], hdr_blue};
					end
					
					3'b111: begin
						wr_data[119:112] <= {hdr_red, hdr_green[5:4]};
						wr_data[127:120] <= {hdr_green[4:0], hdr_blue};
					end
				endcase
		
				pixel_counter <= pixel_counter + 1;
				wr_ready <= (pixel_counter == 3'b111);
			end else begin
				wr_ready <= 1'b0;
			end
		
			if (wr_ready || reg_wr_req) begin
				if(~ram_busy) begin
					wr_req <= 1'b1;	
					reg_wr_req <= 1'b0;
				end else begin
					wr_req <= 1'b0;
					reg_wr_req <= 1'b1;
				end
			end else begin
				wr_req <= 1'b0;
				reg_wr_req <= 1'b0;
			end
		end
	end
	
endmodule
