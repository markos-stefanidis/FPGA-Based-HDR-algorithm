`define N 36
module div_36bit(
	input clk,
	input rst_n,
	input valid,
	input [`N-1:0] A,
	input [`N-1:0] B,

	output [`N-1:0] Q,
	output [`N-1:0] R,
	output reg ready,
	output inv
);

	reg [8:0] quo0;
	reg [17:0] quo1;
	reg [27:0] quo2;
	reg [35:0] quo3;

	reg [`N-1:0] a0 [0:8];
	reg [`N-1:0] a1 [0:8];
	reg [`N-1:0] a2 [0:8];
	reg [`N-1:0] a3 [0:8];

	reg [`N-1:0]divident0;
	reg [`N-1:0]divident1;
	reg [`N-1:0]divident2;
	reg [`N-1:0]divident3;

	reg [`N-1:0] divisor0;
	reg [`N-1:0] divisor1;
	reg [`N-1:0] divisor2;
	reg [`N-1:0] divisor3;

	reg stage1;
	reg stage2;


	always@(*) begin
		a0[0] = A >> (`N-1);
		quo0[8] = (B <= a0[0]);
		divident0 = A;
		divisor0 = B;
	end

	generate
		genvar i;
		for (i = 1; i < 9; i = i + 1) begin

			always@(*) begin
				a0[i] = (quo0[9-i]) ? {a0[i-1] - divisor0, divident0[`N-i-1]} : {a0[i-1], divident0[`N-i-1]};
				a1[i] = (quo1[9-i]) ? {a1[i-1] - divisor1, divident1[`N-i-1-9]} : {a1[i-1], divident1[`N-i-1-9]};
				a2[i] = (quo2[9-i]) ? {a2[i-1] - divisor2, divident2[`N-i-1-18]} : {a2[i-1], divident2[`N-i-1-18]};
				a3[i] = (quo3[9-i]) ? {a3[i-1] - divisor3, divident3[`N-i-1-27]} : {a3[i-1], divident3[`N-i-1-27]};

				quo0[8-i] = (divisor0 <= a0[i]);
				quo1[8-i] = (divisor1 <= a1[i]);
				quo2[8-i] = (divisor2 <= a2[i]);
				quo3[8-i] = (divisor3 <= a3[i]);
			end
		end
	endgenerate

	always@(*) begin
		quo1[8] = (divisor1 <= a1[0]);
		quo2[8] = (divisor2 <= a2[0]);
		quo3[8] = (divisor3 <= a3[0]);
	end

	always@(posedge clk) begin
		if(~rst_n) begin
			stage1 <= 1'b0;
			stage2 <= 1'b0;
			ready <= 1'b0;
		end else begin
			stage1 <= valid;
			stage2 <= stage1;
			ready <= stage2;

			divident1 <= divident0;
			divident2 <= divident1;
			divident3 <= divident2;

			divisor1 <= divisor0;
			divisor2 <= divisor1;
			divisor3 <= divisor2;

			quo1[17:9] <= quo0;
			quo2[27:9] <= quo1;
			quo3[35:9] <= quo2;


			a1[0] <= (quo0[0]) ? {a0[8] - divisor0, divident0[`N-9-1]} : {a0[8], divident0[`N-9-1]};
			a2[0] <= (quo1[0]) ? {a1[8] - divisor1, divident1[`N-18-1]} : {a1[8], divident1[`N-18-1]};
			a3[0] <= (quo2[0]) ? {a2[8] - divisor2, divident2[`N-27-1]} : {a2[8], divident2[`N-27-1]};

		end

	end

	assign R = (quo3[0]) ? (a3[8] - divisor3) : a3[8];
	assign Q = quo3[`N-1:0];//+ (R > (divisor3 >> 1));
	assign inv = (divisor3 == 0);
endmodule
