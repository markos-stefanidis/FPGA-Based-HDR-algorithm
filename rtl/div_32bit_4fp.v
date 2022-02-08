`define N 32
`define FP 4
module div_32bit_4fp(
	input clk,
	input rst_n,
	input [`N-1: 0] A,
	input [`N-1: 0] B,
	input valid,

	output [`N-1: 0] OUT,

	output ovrflow,
	output ready,
	output inv
);

	wire [`N+`FP-1: 0] Q, R;
	wire [`N+`FP-1: 0] FP_A, FP_B;

	assign FP_A = (A << 4);
	assign FP_B = {4'b0, B};

	div_36bit div(
		.clk (clk),
		.rst_n (rst_n),

		.A (FP_A),
		.B (FP_B),
		.valid (valid),

		.Q (Q),
		.R (R),
		.ready (ready),
		.inv (inv)
	);

	assign ovrflow = |(Q[`N+`FP-1:`N]);
	assign OUT = Q[`N-1: 0];



endmodule
