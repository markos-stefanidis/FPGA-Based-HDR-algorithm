module g_red_lut(
	input clk,
	input clk_en,
	input [4:0] pixel,

	output reg [7:0] data
);

	always@(posedge clk) begin
		if(clk_en) begin
			case(pixel)
				5'h00: data <= 8'b00000000;
				5'h01: data <= 8'b00000110;
				5'h02: data <= 8'b00001011;
				5'h03: data <= 8'b00001110;
				5'h04: data <= 8'b00010001;
				5'h05: data <= 8'b00010100;
				5'h06: data <= 8'b00010111;
				5'h07: data <= 8'b00011010;
				5'h08: data <= 8'b00011100;
				5'h09: data <= 8'b00011110;
				5'h0A: data <= 8'b00100000;
				5'h0B: data <= 8'b00100001;
				5'h0C: data <= 8'b00100011;
				5'h0D: data <= 8'b00100101;
				5'h0E: data <= 8'b00100111;
				5'h0F: data <= 8'b00101001;
				5'h10: data <= 8'b00101011;
				5'h11: data <= 8'b00101100;
				5'h12: data <= 8'b00101110;
				5'h13: data <= 8'b00110000;
				5'h14: data <= 8'b00110010;
				5'h15: data <= 8'b00110100;
				5'h16: data <= 8'b00110101;
				5'h17: data <= 8'b00110111;
				5'h18: data <= 8'b00111000;
				5'h19: data <= 8'b00111010;
				5'h1A: data <= 8'b00111011;
				5'h1B: data <= 8'b00111101;
				5'h1C: data <= 8'b00111110;
				5'h1D: data <= 8'b01000000;
				5'h1E: data <= 8'b01000010;
				5'h1F: data <= 8'b01000100;
			endcase
		end
	end

endmodule
