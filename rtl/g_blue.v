module g_blue_lut(
	input clk,
	input clk_en,
	input [4:0] pixel,
	
	output reg [11:0] data
);

	always@(posedge clk) begin
		if(clk_en) begin
			case(pixel)
				5'h00: data <= 12'b000000000110;
				5'h01: data <= 12'b000000000000;
				5'h02: data <= 12'b000000000110;
				5'h03: data <= 12'b000000101010;
				5'h04: data <= 12'b000001011110;
				5'h05: data <= 12'b000010000111;
				5'h06: data <= 12'b000010101011;
				5'h07: data <= 12'b000011000100;
				5'h08: data <= 12'b000011001010;
				5'h09: data <= 12'b000010111100;
				5'h0A: data <= 12'b000010101011;
				5'h0B: data <= 12'b000010101001;
				5'h0C: data <= 12'b000010110000;
				5'h0D: data <= 12'b000010111000;
				5'h0E: data <= 12'b000011000000;
				5'h0F: data <= 12'b000011000100;
				5'h10: data <= 12'b000011000101;
				5'h11: data <= 12'b000011000100;
				5'h12: data <= 12'b000011000011;
				5'h13: data <= 12'b000011000010;
				5'h14: data <= 12'b000011000011;
				5'h15: data <= 12'b000011001111;
				5'h16: data <= 12'b000011100110;
				5'h17: data <= 12'b000100000110;
				5'h18: data <= 12'b000100100110;
				5'h19: data <= 12'b000101000100;
				5'h1A: data <= 12'b000101011101;
				5'h1B: data <= 12'b000101110001;
				5'h1C: data <= 12'b000110000000;
				5'h1D: data <= 12'b000110001101;
				5'h1E: data <= 12'b000110011001;
				5'h1F: data <= 12'b000110100110;
			endcase
		end
	end

endmodule
