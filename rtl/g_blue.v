module g_blue_lut(
	input clk,
	input clk_en,
	input [4:0] pixel,
	
	output reg [7:0] data
);

	always@(posedge clk) begin
		if(clk_en) begin
			case(pixel)
				5'h00: data <= 7'b00000001;
				5'h01: data <= 7'b00000000;
				5'h02: data <= 7'b00000001;
				5'h03: data <= 7'b00000011;
				5'h04: data <= 7'b00000110;
				5'h05: data <= 7'b00001001;
				5'h06: data <= 7'b00001011;
				5'h07: data <= 7'b00001101;
				5'h08: data <= 7'b00001101;
				5'h09: data <= 7'b00001100;
				5'h0A: data <= 7'b00001011;
				5'h0B: data <= 7'b00001011;
				5'h0C: data <= 7'b00001011;
				5'h0D: data <= 7'b00001100;
				5'h0E: data <= 7'b00001100;
				5'h0F: data <= 7'b00001101;
				5'h10: data <= 7'b00001101;
				5'h11: data <= 7'b00001101;
				5'h12: data <= 7'b00001101;
				5'h13: data <= 7'b00001101;
				5'h14: data <= 7'b00001101;
				5'h15: data <= 7'b00001101;
				5'h16: data <= 7'b00001111;
				5'h17: data <= 7'b00010001;
				5'h18: data <= 7'b00010011;
				5'h19: data <= 7'b00010101;
				5'h1A: data <= 7'b00010110;
				5'h1B: data <= 7'b00011000;
				5'h1C: data <= 7'b00011000;
				5'h1D: data <= 7'b00011001;
				5'h1E: data <= 7'b00011010;
				5'h1F: data <= 7'b00011011;
			endcase
		end
	end

endmodule
