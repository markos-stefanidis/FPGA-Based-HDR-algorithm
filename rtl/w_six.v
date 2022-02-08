module w_six
(	input clk,
	input rst_n,	
	input start,
 	input [5:0] pixel_high,
	input [5:0] pixel_mid,
	input [5:0] pixel_low,

	output reg [7:0] w_high,
	output reg [7:0] w_mid,
	output reg [7:0] w_low
);

	localparam N = 6;
	localparam MAX = (2**N);

	always@(posedge clk) begin
		if(~rst_n) begin
			w_high <= 8'b0;	
			w_mid <= 8'b0; 
			w_low <= 8'b0; 
		end else if(start) begin
			w_high <= (pixel_high[N-1]) ? (MAX - pixel_high) : (pixel_high + 1);
			w_mid <= (pixel_mid[N-1]) ? (MAX - pixel_mid) : (pixel_mid + 1);
			w_low <= (pixel_low[N-1]) ? (MAX - pixel_low) : (pixel_low + 1);
		end
	end

//	assign w_high = (pixel_high[N-1]) ? (MAX - pixel_high) : (pixel_high + 1);
//	assign w_mid = (pixel_mid[N-1]) ? (MAX - pixel_mid) : (pixel_mid + 1);
//	assign w_low = (pixel_low[N-1]) ? (MAX - pixel_low) : (pixel_low + 1);
	
endmodule
