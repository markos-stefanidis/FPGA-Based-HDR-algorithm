module div_fp_8bit
(
	input [7:0] A,
	input [7:0] B,
	
	output [7:0] OUT,
	
	output ovrflow,
	output inv
);
	
	localparam N = 8;
	localparam FP = 4;

	wire [N+FP-1: 0] Q, R;
	wire [N+FP-1: 0] FP_A, FP_B;
	
	assign FP_A = (A << FP);
	assign FP_B = B;
	
	div_8bit div(
		.A (FP_A),
		.B (FP_B),
		
		.Q (Q),
		.R (R),
		.inv (inv)
	);
	
	
	assign ovrflow = |(Q[N+FP-1:N]);
	assign OUT = Q[N-1: 0];
	


endmodule
