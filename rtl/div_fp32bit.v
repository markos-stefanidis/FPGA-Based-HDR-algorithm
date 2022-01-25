`define N 32
`define FP 8
module div_fp32bit(
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
	
	assign FP_A = (A << `FP);
	assign FP_B = B;
	
	div_40bit div(
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
