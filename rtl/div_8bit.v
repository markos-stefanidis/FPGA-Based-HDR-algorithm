module div_8bit
	(input  [11:0] A,
	 input  [11:0] B,
	 
	 output [11:0] Q,
	 output [11:0] R,
	 output inv
);
	
	localparam N = 11;
	wire [N -1:0] a1 [N-1:0];

	assign a1[0] = A >> (N - 1);
	assign Q[N - 1] = (B <= a1[0]);
	
	generate
		genvar i;
		for (i = 1; i < N; i = i + 1) begin
			assign a1[i] = (Q[N - i]) ? {a1[i - 1] - B, A[N-i-1]} : {a1[i - 1], A[N-i-1]};
			assign Q[N - 1 - i] = (B <= a1[i]);
		end
		
	endgenerate
	
	assign R = (Q[0]) ? (a1[N - 1] - B) : a1[N - 1];
	
	
	assign inv = (B == 0);
endmodule
