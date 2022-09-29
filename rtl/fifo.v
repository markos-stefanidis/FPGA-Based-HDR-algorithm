module fifo #(parameter N = 0, ADDR = 0)(
	input clk,
	input rst_n,
	input [N-1:0] wr_data,
	input wr_en,
	input rd_en,

	output reg [N-1:0] rd_data,
	output empty,
	output full
);

	reg [N-1:0] fifo [0:2**(ADDR)-1];
	reg [ADDR:0] wr_pntr;
	reg [ADDR:0] rd_pntr;

	always@(posedge clk) begin
		if(~rst_n) begin
			wr_pntr <= 0;
			rd_pntr <= 0;
		end else begin
			if(wr_en) begin
				fifo[wr_pntr[ADDR-1:0]] <= wr_data;
				wr_pntr <= wr_pntr + 1;
			end

			if(rd_en) begin
				rd_data <= fifo[rd_pntr[ADDR-1:0]];
				rd_pntr <= rd_pntr + 1;
			end
		end
	end

	assign empty = (wr_pntr == rd_pntr);
	assign full = (wr_pntr[ADDR] != rd_pntr[ADDR]) && (wr_pntr[ADDR-1:0] == rd_pntr[ADDR-1:0]);

endmodule
