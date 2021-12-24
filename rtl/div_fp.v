module div_fp
	#(  parameter N,
		parameter FP)
(
	input [N-1: 0] A,
	input [N-1: 0] B,
	
	output [N-1: 0] OUT,
	
	output ovrflow,
	output inv
);
	
	wire [N+FP-1: 0] Q, R;
	wire [N+FP-1: 0] FP_A, FP_B;
	
	assign FP_A = (A << FP);
	assign FP_B = B;
	
	div div(
		.A (FP_A),
		.B (FP_B),
		
		.Q (Q),
		.R (R),
		.inv (inv)
	);
	
	defparam div.N = N + FP;
	
	
	assign ovrflow = |(Q[N+FP-1:N]);
	assign OUT = Q[N-1: 0];
	


endmodule
