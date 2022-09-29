module sync#(parameter DATA_WIDTH = 1)(
	input clk,
	input rst_n,
	input [DATA_WIDTH - 1:0] in,

	output [DATA_WIDTH - 1:0] out
);

	reg [DATA_WIDTH - 1:0] q_in;
	reg [DATA_WIDTH - 1:0] qq_in;

	always@(posedge clk, negedge rst_n) begin
		if(~rst_n) begin
			q_in <= 0;
			qq_in <= 0;
		end else begin
			q_in <= in;
			qq_in <= q_in;
		end
	end

	assign out = qq_in;
endmodule
