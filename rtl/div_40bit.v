`define N 40 
module div_40bit(
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

	reg [7:0] quo0;
	reg [15:0] quo1;
	reg [23:0] quo2;
	reg [31:0] quo3;
	reg [`N-1:0] quo4;

	reg [`N-1:0] a0 [0:7];
	reg [`N-1:0] a1 [0:7];
	reg [`N-1:0] a2 [0:7];
	reg [`N-1:0] a3 [0:7];
	reg [`N-1:0] a4 [0:7];

	reg [`N-1:0]divident0;
	reg [`N-1:0]divident1;
	reg [`N-1:0]divident2;
	reg [`N-1:0]divident3;
	reg [`N-1:0]divident4;

	reg [`N-1:0] divisor0;
	reg [`N-1:0] divisor1;
	reg [`N-1:0] divisor2;
	reg [`N-1:0] divisor3;
	reg [`N-1:0] divisor4;

	reg stage1;
	reg stage2;
	reg stage3;


	always@(*) begin
		a0[0] = A >> (`N-1);
		quo0[7] = (B <= a0[0]);
		divident0 = A;
		divisor0 = B;
	end

	generate
		genvar i;
		for (i = 1; i < 8; i = i + 1) begin

			always@(*) begin
				a0[i] = (quo0[8-i]) ? {a0[i-1] - divisor0, divident0[`N-i-1]} : {a0[i-1], divident0[`N-i-1]};
				a1[i] = (quo1[8-i]) ? {a1[i-1] - divisor1, divident1[`N-i-1-8]} : {a1[i-1], divident1[`N-i-1-8]};
				a2[i] = (quo2[8-i]) ? {a2[i-1] - divisor2, divident2[`N-i-1-16]} : {a2[i-1], divident2[`N-i-1-16]};
				a3[i] = (quo3[8-i]) ? {a3[i-1] - divisor3, divident3[`N-i-1-24]} : {a3[i-1], divident3[`N-i-1-24]};
				a4[i] = (quo4[8-i]) ? {a4[i-1] - divisor4, divident4[`N-i-1-32]} : {a4[i-1], divident4[`N-i-1-32]};

				quo0[7-i] = (divisor0 <= a0[i]);
				quo1[7-i] = (divisor1 <= a1[i]);
				quo2[7-i] = (divisor2 <= a2[i]);
				quo3[7-i] = (divisor3 <= a3[i]);
				quo4[7-i] = (divisor4 <= a4[i]);
			end
		end
	endgenerate

	always@(*) begin
		quo1[7] = (divisor1 <= a1[0]);
		quo2[7] = (divisor2 <= a2[0]);
		quo3[7] = (divisor3 <= a3[0]);
		quo4[7] = (divisor4 <= a4[0]);
	end

	always@(posedge clk) begin
		if(~rst_n) begin
			stage1 <= 1'b0;
			stage2 <= 1'b0;
			stage3 <= 1'b0;
			ready <= 1'b0;
		end else begin
			stage1 <= valid;
			stage2 <= stage1;
			stage3 <= stage2;
			ready <= stage3;

			divident1 <= divident0;
			divident2 <= divident1;
			divident3 <= divident2;
			divident4 <= divident3;

			divisor1 <= divisor0;
			divisor2 <= divisor1;
			divisor3 <= divisor2;
			divisor4 <= divisor3;

			quo1[15:8] <= quo0;
			quo2[23:8] <= quo1;
			quo3[31:8] <= quo2;
			quo4[39:8] <= quo3;

			
			a1[0] <= (quo0[0]) ? {a0[7] - divisor0, divident0[`N-8-1]} : {a0[7], divident0[`N-8-1]};
			a2[0] <= (quo1[0]) ? {a1[7] - divisor1, divident1[`N-16-1]} : {a1[7], divident1[`N-16-1]};
			a3[0] <= (quo2[0]) ? {a2[7] - divisor2, divident2[`N-24-1]} : {a2[7], divident2[`N-24-1]};
			a4[0] <= (quo3[0]) ? {a3[7] - divisor3, divident3[`N-32-1]} : {a3[7], divident3[`N-32-1]};

		end

	end

	assign Q = quo4[`N-1:0];
	assign R = (Q[0]) ? (a4[7] - divisor4) : a4[7];
	assign inv = (divisor4 == 0);
endmodule
