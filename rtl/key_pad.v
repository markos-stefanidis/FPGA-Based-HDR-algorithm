module key_pad(
	input clk,
	input rst_n,
	input scan,
	input [3:0] row,	
	
	output reg [3:0] key_code,
	output [2:0] col,
	output reg key_ready
);

	localparam SCAN = 0;
	localparam DECODE = 1;
	localparam IDLE = 2;
	localparam WAIT_RELEASE = 3;
	localparam CLK_FREQ = 25000000;
	localparam POLL_FREQ = 10000;


	wire [3:0] sum;
	reg [1:0] STATE;
	reg [11:0] data;
	reg [12:0] wait_counter;
	reg wait_100us;
	reg wait_rst;
	reg [2:0] reg_col;
	
	assign col = reg_col;
	
	
	assign sum = data[0] + data[1] + data[2]  + data[3]  + 
				 data[4] + data[5] + data[6]  + data[7]  + 
				 data[8] + data[9] + data[10] + data[11];

	always@(posedge clk) begin
		if(~rst_n) begin
			STATE <= IDLE;
			key_code <= 4'b0;
			reg_col <= 3'b0;
			key_ready <= 1'b0;
			data <= 12'b0;
			wait_rst <= 1'b0;
		end else begin
			
			case(STATE)
				
				SCAN: begin
					
					if(wait_100us) begin
					
						case(reg_col)
							
							3'b100: begin
								data[11:8] <= row;
								reg_col <= 3'b010;
								wait_rst <= 1'b1;
							end
							
							3'b010: begin
								data[7:4] <= row;
								reg_col <= 3'b001;
								wait_rst <= 1'b1;
							end
							
							3'b001: begin
								data[3:0] <= row;
								reg_col <= 3'b111;
								wait_rst <= 1'b1;
								STATE <= WAIT_RELEASE;
							end
						
						endcase
					end else begin
						wait_rst <= 1'b0;
					end
				end
				
				WAIT_RELEASE: begin
					STATE <= (row == 3'b0) ? DECODE : WAIT_RELEASE;
				end
				
				DECODE: begin
					if(sum == 4'b1) begin
						case(data)
							//Collumn 1
							12'h800: key_code <= 4'b0001; //Row 1 Key 1
							12'h400: key_code <= 4'b0100; //Row 2 Key 4
							12'h200: key_code <= 4'b0111; //Row 3 Key 7
							12'h100: key_code <= 4'b1010; //Row 4 Key C
							
							//Collumn 2
							12'h080: key_code <= 4'b0010; //Row 1 Key 2
							12'h040: key_code <= 4'b0101; //Row 2 Key 5
							12'h020: key_code <= 4'b1000; //Row 3 Key 8
							12'h010: key_code <= 4'b0000; //Row 4 Key 0
							
							//Collumn 3
							12'h008: key_code <= 4'b0011; //Row 1 Key 3
							12'h004: key_code <= 4'b0110; //Row 2 Key 6
							12'h002: key_code <= 4'b1001; //Row 3 Key 9
							12'h001: key_code <= 4'b1011; //Row 4 Key E
						endcase
							
						key_ready <= 1'b1;
						STATE <= IDLE;						
					end else begin
						key_ready <= 1'b0;
						reg_col <= 3'b100;
						STATE <= SCAN;
						wait_rst <= 1'b1;
					end
					data <= 12'b0;
				end
				
				IDLE: begin
					if(scan) begin
						STATE <= SCAN;
						wait_rst <= 1'b1;
						key_ready <= 1'b0;
						reg_col <= 3'b100;
					end else begin
						reg_col <= 3'b000;
						wait_rst <= 1'b1;
					end
					data <= 12'b0;
				end
			
			endcase
			
		end
	end

	always@(posedge clk) begin
		if(~rst_n || wait_rst) begin
			wait_counter <= 13'b0;
			wait_100us <= 1'b0;
		end else begin
			wait_counter <= (wait_counter < (CLK_FREQ/POLL_FREQ)) ? wait_counter + 1 : wait_counter; 
			wait_100us <= (wait_counter == (CLK_FREQ/POLL_FREQ - 1));
		end
	end



endmodule