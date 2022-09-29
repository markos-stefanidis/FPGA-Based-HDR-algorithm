module row_buffer(
	input clk,
	input clk_25M,
	input wr_en,
	input [127:0] wr_data,
	input rd_en,
	input [6:0] wr_address,
	input [9:0] rd_address,

	output reg [15:0] rd_data
);
	reg [127:0] buffer [0:79];
	reg [127:0] data_out;
	reg [2:0] q_rd;

	always@(posedge clk) begin
		if(wr_en) begin
			buffer[wr_address] <= wr_data;
		end

	end

	always@(posedge clk_25M) begin
		q_rd <= rd_address[2:0];
		if(rd_en) begin
			data_out <= buffer[rd_address[9:3]];
		end
	end

	always@(*) begin
		case(q_rd)
			3'b000: rd_data = data_out[15:0];
			3'b001: rd_data = data_out[31:16];
			3'b010: rd_data = data_out[47:32];
			3'b011: rd_data = data_out[63:48];
			3'b100: rd_data = data_out[79:64];
			3'b101: rd_data = data_out[95:80];
			3'b110: rd_data = data_out[111:96];
			3'b111: rd_data = data_out[127:112];
		endcase
	end
endmodule
