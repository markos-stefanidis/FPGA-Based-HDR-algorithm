module g_green_lut(
	input clk,
	input clk_en,
	input [5:0] pixel,

	output reg [7:0] data
);

	always@(posedge clk) begin
		if(clk_en) begin
			case(pixel)
				6'h00: data <= 8'b00000000;
				6'h01: data <= 8'b00000011;
				6'h02: data <= 8'b00000110;
				6'h03: data <= 8'b00001000;
				6'h04: data <= 8'b00001010;
				6'h05: data <= 8'b00001100;
				6'h06: data <= 8'b00001110;
				6'h07: data <= 8'b00001111;
				6'h08: data <= 8'b00010001;
				6'h09: data <= 8'b00010010;
				6'h0A: data <= 8'b00010011;
				6'h0B: data <= 8'b00010100;
				6'h0C: data <= 8'b00010101;
				6'h0D: data <= 8'b00010110;
				6'h0E: data <= 8'b00010111;
				6'h0F: data <= 8'b00011000;
				6'h10: data <= 8'b00011001;
				6'h11: data <= 8'b00011010;
				6'h12: data <= 8'b00011011;
				6'h13: data <= 8'b00011100;
				6'h14: data <= 8'b00011101;
				6'h15: data <= 8'b00011101;
				6'h16: data <= 8'b00011110;
				6'h17: data <= 8'b00011111;
				6'h18: data <= 8'b00100000;
				6'h19: data <= 8'b00100000;
				6'h1A: data <= 8'b00100001;
				6'h1B: data <= 8'b00100010;
				6'h1C: data <= 8'b00100011;
				6'h1D: data <= 8'b00100100;
				6'h1E: data <= 8'b00100100;
				6'h1F: data <= 8'b00100101;
				6'h20: data <= 8'b00100110;
				6'h21: data <= 8'b00100111;
				6'h22: data <= 8'b00100111;
				6'h23: data <= 8'b00101000;
				6'h24: data <= 8'b00101001;
				6'h25: data <= 8'b00101001;
				6'h26: data <= 8'b00101010;
				6'h27: data <= 8'b00101011;
				6'h28: data <= 8'b00101100;
				6'h29: data <= 8'b00101101;
				6'h2A: data <= 8'b00101110;
				6'h2B: data <= 8'b00101111;
				6'h2C: data <= 8'b00110000;
				6'h2D: data <= 8'b00110001;
				6'h2E: data <= 8'b00110010;
				6'h2F: data <= 8'b00110010;
				6'h30: data <= 8'b00110011;
				6'h31: data <= 8'b00110011;
				6'h32: data <= 8'b00110100;
				6'h33: data <= 8'b00110100;
				6'h34: data <= 8'b00110101;
				6'h35: data <= 8'b00110110;
				6'h36: data <= 8'b00110110;
				6'h37: data <= 8'b00110111;
				6'h38: data <= 8'b00111000;
				6'h39: data <= 8'b00111000;
				6'h3A: data <= 8'b00111001;
				6'h3B: data <= 8'b00111010;
				6'h3C: data <= 8'b00111011;
				6'h3D: data <= 8'b00111100;
				6'h3E: data <= 8'b00111101;
				6'h3F: data <= 8'b00111110;
			endcase
		end
	end

endmodule
