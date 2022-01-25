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
	output reg [255:0] wr_data,
	output reg wr_req,
	output reg hdr_last_frame,
	output reg [24:0] wr_address
);
	//  slE ----> Sum of all lE from HDR module. Reset at each frame.
	//  Used to find global E.
	//
	//  glE ----> Mean of all lE from HDR. Reset at each frame.
	//  glE = slE/N_pixels
	//
	//  gE  ----> Global E needed for tonemapping.
	//  gE = exp(glE)
	//  Not actually a signal as it comes out of exp_lut
	//
	//  E   ----> Radiance of each pixel from HDR module.
	//  E = exp(lE)
	//
	//  aE  ----> Global E divided by constant a = .18. Needed for final pixel value.
	//  aE = gE/a 
	//
	//  divE ---> aE divided by E. Needed for final pixel value.
	//  divE = aE/E
	//
	//  D   ----> Actual tonemapped HDR pixel.
	//  D  = max_value/(1 + gE/(a*E))
	//
	//
	//N_pixels (number of pixels) = 307200, a = 0.18, aN = a*N_pixels = 55296

	localparam FP = 8;
	localparam N_pixels = 307200 << FP;
	localparam a = 46;
	localparam max_red = 31 << FP;
	localparam max_green = 63 << FP;
	localparam max_blue = 31 << FP;
	
	reg [31:0] slE_red;
	reg [31:0] slE_green;
	reg [31:0] slE_blue;
	
	wire [31:0] glE_red;
	wire [31:0] glE_green;
	wire [31:0] glE_blue;
	
	wire [31:0] D_red;
	wire [31:0] D_green;
	wire [31:0] D_blue;
	
	reg [3:0] pixel_counter;
	
	wire [11:0] exp_in_red;
	wire [11:0] exp_in_green;
	wire [11:0] exp_in_blue;
	
	wire [31:0] exp_out_red;
	wire [31:0] exp_out_green;
	wire [31:0] exp_out_blue;

	wire [31:0] divE_red_min;
	wire [31:0] divE_green_min;
	wire [31:0] divE_blue_min;
	
	wire lut_rst;
	assign lut_rst = ~rst_n;
	
	reg gE_ready;
	reg E_ready;
	wire divE_ready;
	wire D_ready;
	
	wire [31:0] waE_red;
	wire [31:0] waE_green;
	wire [31:0] waE_blue;

	reg [31:0] aE_red;
	reg [31:0] aE_green;
	reg [31:0] aE_blue;
	
	wire [31:0] divE_red;
	wire [31:0] divE_green;
	wire [31:0] divE_blue;

	wire glE_red_ready;
	wire glE_green_ready;
	wire glE_blue_ready;

	wire aE_red_ready;
	wire aE_green_ready;
	wire aE_blue_ready;
	
	wire divE_red_ready;
	wire divE_green_ready;
	wire divE_blue_ready;

	wire div_red_ready;
	wire div_green_ready;
	wire div_blue_ready;

	wire D_red_ready;
	wire D_green_ready;
	wire D_blue_ready;

	wire div_ready;

	wire aE_ready;

	wire glE_ready;

	wire exp_lut_en;
	assign exp_lut_en = hdr_done || glE_ready;
	
	always@(posedge clk) begin
		if(~rst_n) begin
			slE_red <= 32'b0;
			slE_green <= 32'b0;
			slE_blue <= 32'b0;
			gE_ready <= 1'b0;
			E_ready <= 1'b0;
		end else begin
		
			gE_ready <= glE_ready;
			E_ready <= hdr_done;
		
			if (aE_ready) begin
				aE_red <= waE_red;
				aE_green <= waE_green;
				aE_blue <= waE_blue;
			end

			if (hdr_done) begin
				slE_red <= slE_red + lE_red;
				slE_green <= slE_green + lE_green;
				slE_blue <= slE_blue + lE_blue;
			end else if (frame_done) begin
				slE_red <= 32'b0;
				slE_green <= 32'b0;
				slE_blue <= 32'b0;
			end
		end
	end

	assign exp_in_red = (hdr_done) ? (lE_red) : ((glE_red_ready) ? (glE_red[11:0]) : 12'b0);
	assign exp_in_green = (hdr_done) ? (lE_green) : ((glE_green_ready) ? (glE_green[11:0]) : 12'b0);
	assign exp_in_blue = (hdr_done) ? (lE_blue) : ((glE_blue_ready) ? (glE_blue[11:0]) : 12'b0);
	
	exp_lut exp_lut_red(
		.clk (clk),
		.clk_en (exp_lut_en),
		.address (exp_in_red),
	
		.data (exp_out_red)
	);
	
	exp_lut exp_lut_green(
		.clk (clk),
		.clk_en (exp_lut_en),
		.address (exp_in_green),
	
		.data (exp_out_green)
	);

	exp_lut exp_lut_blue(
		.clk (clk),
		.clk_en (exp_lut_en),
		.address (exp_in_blue),
	
		.data (exp_out_blue)
	);

	div_fp32bit div_slE_red(
		.clk (clk),
		.rst_n (rst_n),

		.A(slE_red),
		.B(N_pixels),
		.valid (frame_done),

		.OUT (glE_red),

		.ovrflow(),
		.ready (glE_red_ready),
		.inv ()
	);

	div_fp32bit div_slE_green(
		.clk (clk),
		.rst_n (rst_n),

		.A(slE_green),
		.B(N_pixels),
		.valid (frame_done),

		.OUT (glE_green),

		.ovrflow(),
		.ready (glE_green_ready),
		.inv ()
	);

	div_fp32bit div_slE_blue(
		.clk (clk),
		.rst_n (rst_n),

		.A(slE_blue),
		.B(N_pixels),
		.valid (frame_done),

		.OUT (glE_blue),

		.ovrflow(),
		.ready (glE_blue_ready),
		.inv ()
	);
	
	div_fp32bit div_aE_red(
		.clk (clk),
		.rst_n (rst_n),

		.A(exp_out_red),
		.B(a),
		.valid (gE_ready),

		.OUT (waE_red),

		.ovrflow(),
		.ready (aE_red_ready),
		.inv ()
	);

	div_fp32bit div_aE_green(
		.clk (clk),
		.rst_n (rst_n),

		.A(exp_out_green),
		.B(a),
		.valid (gE_ready),

		.OUT (waE_green),

		.ovrflow(),
		.ready (aE_green_ready),
		.inv ()
	);

	div_fp32bit div_aE_blue(
		.clk (clk),
		.rst_n (rst_n),

		.A(exp_out_blue),
		.B(a),
		.valid (gE_ready),

		.OUT (waE_blue),

		.ovrflow(),
		.ready (aE_blue_ready),
		.inv ()
	);

	div_fp32bit div_E_red(
		.clk (clk),
		.rst_n (rst_n),

		.A(aE_red),
		.B(exp_out_red),
		.valid (E_ready),

		.OUT (divE_red_min),

		.ovrflow(),
		.ready (div_red_ready),
		.inv ()
	);

	div_fp32bit div_E_green(
		.clk (clk),
		.rst_n (rst_n),

		.A(aE_green),
		.B(exp_out_green),
		.valid (E_ready),

		.OUT (divE_green_min),

		.ovrflow(),
		.ready (div_green_ready),
		.inv ()
	);

	div_fp32bit div_E_blue(
		.clk (clk),
		.rst_n (rst_n),

		.A(aE_blue),
		.B(exp_out_blue),
		.valid (E_ready),

		.OUT (divE_blue_min),

		.ovrflow(),
		.ready (div_blue_ready),
		.inv ()
	);

	div_fp32bit div_D_red(
		.clk (clk),
		.rst_n (rst_n),

		.A(max_red),
		.B(divE_red),
		.valid (div_ready),

		.OUT (D_red),

		.ovrflow(),
		.ready (D_red_ready),
		.inv ()
	);

	div_fp32bit div_D_green(
		.clk (clk),
		.rst_n (rst_n),

		.A(max_green),
		.B(divE_green),
		.valid (div_ready),

		.OUT (D_green),

		.ovrflow(),
		.ready (D_green_ready),
		.inv ()
	);

	div_fp32bit div_D_blue(
		.clk (clk),
		.rst_n (rst_n),

		.A(max_blue),
		.B(divE_blue),
		.valid (div_ready),

		.OUT (D_blue),

		.ovrflow(),
		.ready (D_blue_ready),
		.inv ()
	);

	assign glE_ready = glE_red_ready && glE_green_ready && glE_blue_ready;
	assign aE_ready = aE_red_ready && aE_green_ready && aE_blue_ready;
	assign D_ready = D_red_ready && D_green_ready && D_blue_ready;
	assign div_ready = div_red_ready && div_green_ready && div_blue_ready;

	assign divE_red = divE_red_min + 256;
	assign divE_green = divE_green_min + 256;
	assign divE_blue = divE_blue_min + 256;

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
			pixel_counter <= 4'b0;
			wr_req <= 1'b0;
			wr_ready <= 1'b0;
			reg_wr_req <= 1'b0;
			wr_address <= 25'hE1000;
		end else begin
			if (D_ready) begin
				case(pixel_counter)
					4'b0000: begin
						wr_data[7:0] <= {hdr_red, hdr_green[5:3]};
						wr_data[15:8] <= {hdr_green[2:0], hdr_blue};
					end
					
					4'b0001: begin
						wr_data[23:16] <= {hdr_red, hdr_green[5:3]};
						wr_data[31:24] <= {hdr_green[2:0], hdr_blue};
					end
					
					4'b0010: begin
						wr_data[39:32] <= {hdr_red, hdr_green[5:3]};
						wr_data[47:40] <= {hdr_green[2:0], hdr_blue};
					end
					
					4'b0011: begin
						wr_data[55:48] <= {hdr_red, hdr_green[5:3]};
						wr_data[63:56] <= {hdr_green[2:0], hdr_blue};
					end
					
					4'b0100: begin
						wr_data[71:64] <= {hdr_red, hdr_green[5:3]};
						wr_data[79:72] <= {hdr_green[2:0], hdr_blue};
					end
					
					4'b0101: begin
						wr_data[87:80] <= {hdr_red, hdr_green[5:3]};
						wr_data[95:88] <= {hdr_green[2:0], hdr_blue};
					end
					
					4'b0110: begin
						wr_data[103:96] <= {hdr_red, hdr_green[5:3]};
						wr_data[111:104] <= {hdr_green[2:0], hdr_blue};
					end
					
					4'b0111: begin
						wr_data[119:112] <= {hdr_red, hdr_green[5:3]};
						wr_data[127:120] <= {hdr_green[2:0], hdr_blue};
					end

					4'b1000: begin
						wr_data[135:128] <= {hdr_red, hdr_green[5:3]};
						wr_data[143:136] <= {hdr_green[2:0], hdr_blue};
					end
					
					4'b1001: begin
						wr_data[151:144] <= {hdr_red, hdr_green[5:3]};
						wr_data[159:152] <= {hdr_green[2:0], hdr_blue};
					end
					
					4'b1010: begin
						wr_data[167:160] <= {hdr_red, hdr_green[5:3]};
						wr_data[175:168] <= {hdr_green[2:0], hdr_blue};
					end
					
					4'b1011: begin
						wr_data[183:176] <= {hdr_red, hdr_green[5:3]};
						wr_data[191:184] <= {hdr_green[2:0], hdr_blue};
					end
					
					4'b1100: begin
						wr_data[199:192] <= {hdr_red, hdr_green[5:3]};
						wr_data[207:200] <= {hdr_green[2:0], hdr_blue};
					end
					
					4'b1101: begin
						wr_data[215:208] <= {hdr_red, hdr_green[5:3]};
						wr_data[223:216] <= {hdr_green[2:0], hdr_blue};
					end
					
					4'b1110: begin
						wr_data[231:224] <= {hdr_red, hdr_green[5:3]};
						wr_data[239:232] <= {hdr_green[2:0], hdr_blue};
					end
					
					4'b1111: begin
						wr_data[247:240] <= {hdr_red, hdr_green[5:3]};
						wr_data[255:248] <= {hdr_green[2:0], hdr_blue};
					end
				endcase
		
				pixel_counter <= pixel_counter + 1;
				wr_ready <= (pixel_counter == 4'b1111);
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

			if(wr_req) begin
				wr_address <= (wr_address < 25'h12BFFF) ? wr_address + 4 : 25'hE1000;
			end

			hdr_last_frame <= (wr_address > 25'h106800);

		end
	end
	
endmodule
