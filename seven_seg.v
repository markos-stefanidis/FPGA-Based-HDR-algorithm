module seven_seg(
	input [3:0] num,
	
	output reg A,
	output reg B,
	output reg C,
	output reg D,
	output reg E,
	output reg F,
	output reg G,
	output reg DP
);

	always@(*) begin
		
		case(num)
			
			4'h0: begin
				A = 1'b0;
				B = 1'b0;
				C = 1'b0;
				D = 1'b0;
				E = 1'b0;
				F = 1'b0;
				G = 1'b1;			
			
			end
			
			4'h1: begin
				A = 1'b1;
				B = 1'b0;
				C = 1'b0;
				D = 1'b1;
				E = 1'b1;
				F = 1'b1;
				G = 1'b1;			
			
			end
			
			4'h2: begin
				A = 1'b0;
				B = 1'b0;
				C = 1'b1;
				D = 1'b0;
				E = 1'b0;
				F = 1'b1;
				G = 1'b0;			
			
			end
			
			4'h3: begin
				A = 1'b0;
				B = 1'b0;
				C = 1'b0;
				D = 1'b0;
				E = 1'b1;
				F = 1'b1;
				G = 1'b0;			
			
			end
			
			4'h4: begin
				A = 1'b1;
				B = 1'b0;
				C = 1'b0;
				D = 1'b1;
				E = 1'b1;
				F = 1'b0;
				G = 1'b1;			
			
			end
			
			4'h5: begin
				A = 1'b0;
				B = 1'b0;
				C = 1'b0;
				D = 1'b0;
				E = 1'b0;
				F = 1'b0;
				G = 1'b1;			
			
			end
			
			4'h6: begin
				A = 1'b0;
				B = 1'b1;
				C = 1'b0;
				D = 1'b0;
				E = 1'b0;
				F = 1'b0;
				G = 1'b0;			
			
			end
			
			4'h7: begin
				A = 1'b0;
				B = 1'b0;
				C = 1'b0;
				D = 1'b1;
				E = 1'b1;
				F = 1'b1;
				G = 1'b1;			
			
			end
			
			4'h8: begin
				A = 1'b0;
				B = 1'b0;
				C = 1'b0;
				D = 1'b0;
				E = 1'b0;
				F = 1'b0;
				G = 1'b0;			
			
			end
			
			4'h9: begin
				A = 1'b0;
				B = 1'b0;
				C = 1'b0;
				D = 1'b0;
				E = 1'b1;
				F = 1'b0;
				G = 1'b0;			
			
			end
			
			4'hA: begin
				A = 1'b0;
				B = 1'b0;
				C = 1'b0;
				D = 1'b1;
				E = 1'b0;
				F = 1'b0;
				G = 1'b0;			
			
			end
			
			4'hB: begin
				A = 1'b1;
				B = 1'b1;
				C = 1'b0;
				D = 1'b0;
				E = 1'b0;
				F = 1'b0;
				G = 1'b0;			
			
			end
			
			4'hC: begin
				A = 1'b0;
				B = 1'b1;
				C = 1'b1;
				D = 1'b0;
				E = 1'b0;
				F = 1'b0;
				G = 1'b1;			
			
			end
			
			4'hD: begin
				A = 1'b1;
				B = 1'b0;
				C = 1'b0;
				D = 1'b0;
				E = 1'b0;
				F = 1'b1;
				G = 1'b0;			
			
			end
			
			4'hE: begin
				A = 1'b0;
				B = 1'b1;
				C = 1'b1;
				D = 1'b0;
				E = 1'b0;
				F = 1'b0;
				G = 1'b0;			
			
			end
			
			4'hF: begin
				A = 1'b0;
				B = 1'b1;
				C = 1'b1;
				D = 1'b1;
				E = 1'b0;
				F = 1'b0;
				G = 1'b0;			
			
			end
			
		
		
		endcase
		
		DP = 1'b1;	
	end


endmodule