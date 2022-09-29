module async_fifo #(parameter N = 0, parameter ADDR = 0)(
	input wr_clk,
	input rd_clk,
	input wr_rst_n,
	input rd_rst_n,
	input wr_en,
	input rd_en,
	input [N-1:0] wr_data,

	output reg [N-1:0] rd_data,
	output full,
	output empty
);

	reg [N-1:0] fifo [0:2**(ADDR)-1];
	reg [ADDR:0] wr_pntr;
	reg [ADDR:0] rd_pntr;

	always@(posedge wr_clk) begin
		if(~wr_rst_n) begin
			wr_pntr <= 0;
		end else begin
			if(wr_en) begin
				fifo[wr_pntr[ADDR-1:0]] <= wr_data;
				wr_pntr <= wr_pntr + 1;
			end
		end
	end

	always@(posedge rd_clk) begin
		if(~rd_rst_n) begin
			rd_pntr <= 0;
		end else begin
			if(rd_en) begin
				rd_data <= fifo[rd_pntr[ADDR-1:0]];
				rd_pntr <= rd_pntr + 1;
			end
		end
	end

	wire [ADDR:0] wr_pntr_gray;
	assign wr_pntr_gray = wr_pntr ^ (wr_pntr >> 1);

	reg [ADDR:0] q_wr_pntr_gray;
	reg [ADDR:0] qq_wr_pntr_gray;

	wire [ADDR:0] rd_pntr_gray;
	assign rd_pntr_gray = rd_pntr ^ (rd_pntr >> 1);

	reg [ADDR:0] q_rd_pntr_gray;
	reg [ADDR:0] qq_rd_pntr_gray;

	always@(posedge rd_clk) begin
		if(~rd_rst_n) begin
			q_wr_pntr_gray <= 0;
			qq_wr_pntr_gray <= 0;
		end else begin
			q_wr_pntr_gray <= wr_pntr_gray;
			qq_wr_pntr_gray <= q_wr_pntr_gray;
		end
	end

	always@(posedge wr_clk) begin
		if(~wr_rst_n) begin
			q_rd_pntr_gray <= 0;
			qq_rd_pntr_gray <= 0;
		end else begin
			q_rd_pntr_gray <= rd_pntr_gray;
			qq_rd_pntr_gray <= q_rd_pntr_gray;
		end
	end

	assign empty = (qq_wr_pntr_gray == rd_pntr_gray);
	assign full = (wr_pntr_gray[ADDR] != qq_rd_pntr_gray[ADDR]) && (wr_pntr_gray[ADDR-1:0] == qq_rd_pntr_gray[ADDR-1:0]);
endmodule
