module hdr
//	#(parameter N,
//	  parameter FP)
(
 	input clk,
	input rst_n,

	input [4:0] red_high,
	input [4:0] red_mid,
	input [4:0] red_low,

	input [5:0] green_high,
	input [5:0] green_mid,
	input [5:0] green_low,

	input [4:0] blue_high,
	input [4:0] blue_mid,
	input [4:0] blue_low,
		
	input hdr_start,
	
//	input [15:0] exp_high,
//	input [15:0] exp_mid,
//	input [15:0] exp_low,
	
	output reg [7:0] lE_red,	
	output reg [7:0] lE_green,	
	output reg [7:0] lE_blue,

	output reg hdr_done
);

	localparam N = 8;
	localparam FP = 4;

	wire [N-1:0] g_red_high;
	wire [N-1:0] g_red_mid;
	wire [N-1:0] g_red_low;
	
	wire [N-1:0] g_green_high;
	wire [N-1:0] g_green_mid;
	wire [N-1:0] g_green_low;

	wire [N-1:0] g_blue_high;
	wire [N-1:0] g_blue_mid;
	wire [N-1:0] g_blue_low;

	wire [N-1:0] w_red_high;
	wire [N-1:0] w_red_mid;
	wire [N-1:0] w_red_low;

	wire [N-1:0] w_green_high;
	wire [N-1:0] w_green_mid;
	wire [N-1:0] w_green_low;

	wire [N-1:0] w_blue_high;
	wire [N-1:0] w_blue_mid;
	wire [N-1:0] w_blue_low;

	wire lut_rst;
	wire [N-1:0] w_lE_red;
	wire [N-1:0] w_lE_green;
	wire [N-1:0] w_lE_blue;

	assign lut_rst = ~rst_n;

	localparam ln_exp_high = 6'b111101;
	localparam ln_exp_mid = 6'b110010;
	localparam ln_exp_low = 6'b101011;
	
	g_red G_red_high(
		.Address (red_high),
		.OutClock (clk),
		.OutClockEn (hdr_start),
		.Reset (lut_rst),
		.Q (g_red_high)
	);

	g_red G_red_mid(
		.Address (red_mid),
		.OutClock (clk),
		.OutClockEn (hdr_start),
		.Reset (lut_rst),
		.Q (g_red_mid)
	);
	
	g_red G_red_low(
		.Address (red_low),
		.OutClock (clk),
		.OutClockEn (hdr_start),
		.Reset (lut_rst),
		.Q (g_red_low)
	);

	w_five W_red
	(
		.clk (clk),
		.rst_n (rst_n),
		.start (hdr_start),
		.pixel_high (red_high),
		.pixel_mid (red_mid),
		.pixel_low (red_low),
		
		.w_high (w_red_high),
		.w_mid (w_red_mid),
		.w_low (w_red_low)
	);

	g_green G_green_high(
		.Address (green_high),
		.OutClock (clk),
		.OutClockEn (hdr_start),
		.Reset (lut_rst),
		.Q (g_green_high)
	);

	g_green G_green_mid(
		.Address (green_mid),
		.OutClock (clk),
		.OutClockEn (hdr_start),
		.Reset (lut_rst),
		.Q (g_green_mid)
	);
	
	g_green G_green_low(
		.Address (green_low),
		.OutClock (clk),
		.OutClockEn (hdr_start),
		.Reset (lut_rst),
		.Q (g_green_low)
	);

	
	
	
	w_six W_green
	(
	 	.clk (clk),
		.rst_n (rst_n),
		.start (hdr_start),
		.pixel_high (green_high),
		.pixel_mid (green_mid),
		.pixel_low (green_low),
		
		.w_high (w_green_high),
		.w_mid (w_green_mid),
		.w_low (w_green_low)
	);

	g_blue G_blue_high(
		.Address (blue_high),
		.OutClock (clk),
		.OutClockEn (hdr_start),
		.Reset (lut_rst),
		.Q (g_blue_high)
	);
	
	g_blue G_blue_mid(
		.Address (blue_mid),
		.OutClock (clk),
		.OutClockEn (hdr_start),
		.Reset (lut_rst),
		.Q (g_blue_mid)
	);
	
	g_blue G_blue_low(
		.Address (blue_low),
		.OutClock (clk),
		.OutClockEn (hdr_start),
		.Reset (lut_rst),
		.Q (g_blue_low)
	);


	w_five W_blue
	(
	 	.clk (clk),
		.rst_n (rst_n),
		.start (hdr_start),
		.pixel_high (blue_high),
		.pixel_mid (blue_mid),
		.pixel_low (blue_low),
		
		.w_high (w_blue_high),
		.w_mid (w_blue_mid),
		.w_low (w_blue_low)
	);
	
	
	
	wire [N-1 :0] red_diff_high;
	wire [N-1 :0] red_diff_mid;
	wire [N-1 :0] red_diff_low;
	
	wire [N-1 :0] green_diff_high;
	wire [N-1 :0] green_diff_mid;
	wire [N-1 :0] green_diff_low;
	
	wire [N-1 :0] blue_diff_high;
	wire [N-1 :0] blue_diff_mid;
	wire [N-1 :0] blue_diff_low;

	
	wire [N-1 :0] w_red_diff_high;
	wire [N-1 :0] w_red_diff_mid;
	wire [N-1 :0] w_red_diff_low;
	
	wire [N-1 :0] w_green_diff_high;
	wire [N-1 :0] w_green_diff_mid;
	wire [N-1 :0] w_green_diff_low;

	wire [N-1 :0] w_blue_diff_high;
	wire [N-1 :0] w_blue_diff_mid;
	wire [N-1 :0] w_blue_diff_low;

	reg [N-1 :0] sum_red;
	reg [N-1 :0] w_sum_red;
	reg [N-1 :0] sum_green;
	reg [N-1 :0] w_sum_green;
	reg [N-1 :0] sum_blue;
	reg [N-1 :0] w_sum_blue;
	
	reg stage1;
	reg stage2;
	always@(posedge clk) begin
		if(~rst_n) begin
			stage1 <= 1'b0;
			stage2 <= 1'b0;
			hdr_done <= 1'b0;
			lE_red <= 0;
			lE_green <= 0;
			lE_blue <= 0;
		end else begin
			stage1 <= hdr_start;
			stage2 <= stage1;
			hdr_done <= stage2;

			sum_red <= w_red_diff_high + w_red_diff_low + w_red_diff_mid;
			w_sum_red <= w_red_high + w_red_low + w_red_mid;
			
			sum_green <= w_green_diff_high + w_green_diff_low + w_green_diff_mid;
			w_sum_green <= w_green_high + w_green_low + w_green_mid;
			
			sum_blue <= w_blue_diff_high + w_blue_diff_low + w_blue_diff_mid;
			w_sum_blue <= w_blue_high + w_blue_low + w_blue_mid;

			lE_red <= w_lE_red;
			lE_green <= w_lE_red;
			lE_blue <= w_lE_red;
		end

	end

	assign red_diff_high = g_red_high + ln_exp_high;
	assign red_diff_mid = g_red_mid + ln_exp_mid;
	assign red_diff_low = g_red_low + ln_exp_low;

	assign green_diff_high = g_green_high + ln_exp_high;
	assign green_diff_mid = g_green_mid + ln_exp_mid;
	assign green_diff_low = g_green_low + ln_exp_low;

	assign blue_diff_high = g_blue_high + ln_exp_high;
	assign blue_diff_mid = g_blue_mid + ln_exp_mid;
	assign blue_diff_low = g_blue_low + ln_exp_low;

	assign w_red_diff_high = (red_diff_high * w_red_high) >> FP;
	assign w_red_diff_mid = (red_diff_mid * w_red_mid) >> FP;
	assign w_red_diff_low = (red_diff_low * w_red_low) >> FP;
	
	assign w_green_diff_high = (green_diff_high * w_green_high) >> FP;
	assign w_green_diff_mid = (green_diff_mid * w_green_mid) >> FP;
	assign w_green_diff_low = (green_diff_low * w_green_low) >> FP;

	assign w_blue_diff_high = (blue_diff_high * w_blue_high) >> FP;
	assign w_blue_diff_mid = (blue_diff_mid * w_blue_mid) >> FP;
	assign w_blue_diff_low = (blue_diff_low * w_blue_low) >> FP;

//	assign sum_red = w_red_diff_high + w_red_diff_low + w_red_diff_mid;
//	assign w_sum_red = w_red_high + w_red_low + w_red_mid;
//	
//	assign sum_green = w_green_diff_high + w_green_diff_low + w_green_diff_mid;
//	assign w_sum_green = w_green_high + w_green_low + w_green_mid;
//
//	assign sum_blue = w_blue_diff_high + w_blue_diff_low + w_blue_diff_mid;
//	assign w_sum_blue = w_blue_high + w_blue_low + w_blue_mid;

	div_fp_8bit div_red 
	(
		.A (sum_red),
		.B (w_sum_red),
		.OUT (w_lE_red),
		.ovrflow (),
		.inv ()
	);

	div_fp_8bit div_green 
	(
		.A (sum_green),
		.B (w_sum_green),
		.OUT (w_lE_green),
		.ovrflow (),
		.inv ()
	);

	div_fp_8bit div_blue
	(
		.A (sum_blue),
		.B (w_sum_blue),
		.OUT (w_lE_blue),
		.ovrflow (),
		.inv ()
	);


endmodule
