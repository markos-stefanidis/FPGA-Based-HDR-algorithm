module key_read(
	input clk,
	input rst_n,
	input conf_en,
	input [3:0] row,
	
	output [2:0] col,
	output reg [7:0] conf_addr,
	output reg [7:0] conf_data,
	output reg sccb_start,
	
	output reg seven_seg_right,
	output reg seven_seg_left,
	output  seven_seg_A,
	output  seven_seg_B,
	output  seven_seg_C,
	output  seven_seg_D,
	output  seven_seg_E,
	output  seven_seg_F,
	output  seven_seg_G,
	output  seven_seg_DP	
);
	
	//This module reads the address and data from keypad to manually configure the camera module.
	//As the keypad has digits from 0-9, the user needs to input the decimal value of the address/data. This module then displays the hex values on the 2 digit seven segment dsiplay.
	//It won't allow for values larger than 255.
	//Pressing the E key will register the value, while pressing the C key will clear the value.
	
	
	localparam IDLE = 0;
	localparam WAIT_1_DIGIT = 1;
	localparam WAIT_2_DIGIT = 2;
	localparam WAIT_3_DIGIT = 3;
	localparam CONFIRM = 4;
	localparam CLK_FREQ = 25000000;
	localparam SEVEN_SEG_FREQ = 50;
	
	reg STATE;
	reg scan;
	reg [7:0] data;
	reg wr_addr;
	wire key_ready;
	wire [3:0] key_code;

	always@(posedge clk) begin
		if(~rst_n) begin
			STATE <= IDLE;
			scan <= 1'b0;
			data <= 8'b0;
			wr_addr <= 1'b0;
			conf_addr <= 8'b0;
			conf_data <= 8'b0;
			sccb_start <= 1'b0;
			
		end else begin
			case(STATE)
			
				IDLE: begin
					if(conf_en) begin
						STATE <= WAIT_1_DIGIT;
						scan <= 1'b1;
					end else begin
						scan <= 1'b0;
					end
					sccb_start <= 1'b0;
				end
				
				WAIT_1_DIGIT: begin
					sccb_start <= 1'b0;
					if(key_ready) begin
						case(key_code)
							
							4'b0010: begin
								data <= 8'hC8; //Key 2*100
								STATE <= WAIT_2_DIGIT;
							end
							
							4'b0001: begin
								data <= 8'h64; //Key 1*100
								STATE <= WAIT_2_DIGIT;
							end
							
							4'b0000: begin
								data <= 8'h0;  //Key 0*100
								STATE <= WAIT_2_DIGIT;
							end
							
							default: begin
								data <= 8'h0;
								STATE <= WAIT_1_DIGIT;
							end
							
						endcase
						scan <= 1'b1;						
					end else if (~conf_en) begin
						STATE <= IDLE;
						scan <= 1'b0;
					end else begin
						scan <= 1'b0;
					end
				end
				
				WAIT_2_DIGIT: begin
					if(key_ready) begin
						if(data == 8'hFA) begin
							case(key_code) 
								4'b0110: begin
									data <= data + 8'h6; //Key 6
								end
							
								4'b0101: begin
									data <= data + 8'h5; //Key 5
									STATE <= WAIT_3_DIGIT;
								end
								
								4'b0100: begin
									data <= data + 8'h4; //Key 4
									STATE <= WAIT_3_DIGIT;
								end
								
								4'b0011: begin
									data <= data + 8'h3; //Key 3
									STATE <= WAIT_3_DIGIT;
								end
								
								4'b0010: begin
									data <= data + 8'h2; //Key 2
									STATE <= WAIT_3_DIGIT;
								end
								
								4'b0001: begin
									data <= data + 8'h1; //Key 1
									STATE <= WAIT_3_DIGIT;
								end
								
								4'b0000: begin
									data <= data; 		  //Key 0
									STATE <= WAIT_3_DIGIT;
								end
								
								default: begin
									STATE <= WAIT_2_DIGIT;
								end
							endcase
						end else begin
							case(key_code) 							
								4'b1001: begin
									data <= data + 8'h9; //Key 9
									STATE <= WAIT_3_DIGIT;
								end
								
								4'b1000: begin
									data <= data + 8'h8; //Key 8
									STATE <= WAIT_3_DIGIT;
								end
								
								4'b0111: begin
									data <= data + 8'h7; //Key 7
									STATE <= WAIT_3_DIGIT;
								end
								
								4'b0110: begin
									data <= data + 8'h6; //Key 6
									STATE <= WAIT_3_DIGIT;
								end
								
								4'b0101: begin
									data <= data + 8'h5; //Key 5
									STATE <= WAIT_3_DIGIT;
								end
								
								4'b0100: begin
									data <= data + 8'h4; //Key 4
									STATE <= WAIT_3_DIGIT;
								end
								
								4'b0011: begin
									data <= data + 8'h3; //Key 3
									STATE <= WAIT_3_DIGIT;
								end
								
								4'b0010: begin
									data <= data + 8'h2; //Key 2
									STATE <= WAIT_3_DIGIT;
								end
								
								4'b0001: begin
									data <= data + 8'h1; //Key 1
									STATE <= WAIT_3_DIGIT;
								end
								
								4'b0000: begin
									data <= data; 		  //Key 0
									STATE <= WAIT_3_DIGIT;
								end
								
								default: begin
									STATE <= WAIT_2_DIGIT;
								end
							endcase
						end
						scan <= 1'b1;
					end else if (~conf_en) begin
						STATE <= IDLE;
						scan <= 1'b0;
					end else begin
						scan <= 1'b0;
					end
				end
				
				WAIT_3_DIGIT: begin
					if(key_ready) begin
							if(data == 8'hC8) begin
								case(key_code) 
									4'b0101: begin
										data <= data + 8'h32; //Key 5*10
										STATE <= CONFIRM;
									end
									
									4'b0100: begin
										data <= data + 8'h28; //Key 4*10
										STATE <= CONFIRM;
									end
									
									4'b0011: begin
										data <= data + 8'h1E; //Key 3*10
										STATE <= CONFIRM;
									end
									
									4'b0010: begin
										data <= data + 8'h14; //Key 2*10
										STATE <= CONFIRM;
									end
									
									4'b0001: begin
										data <= data + 8'hA; //Key 1*10
										STATE <= CONFIRM;
									end
									
									4'b0000: begin
										data <= data; 		  //Key 0*10
										STATE <= CONFIRM;
									end
									
									default: begin
										STATE <= WAIT_3_DIGIT;
									end
								endcase
							end else begin
								case(key_code)								
									4'b1001: begin
										data <= data + 8'h5A; //Key 9*10
										STATE <= CONFIRM;
									end
									
									4'b1000: begin
										data <= data + 8'h50; //Key 8*10
										STATE <= CONFIRM;
									end
									
									4'b0111: begin
										data <= data + 8'h46; //Key 7*10
										STATE <= CONFIRM;
									end
									
									4'b0110: begin
										data <= data + 8'h3C; //Key 6*10
										STATE <= CONFIRM;
									end
									
									4'b0101: begin
										data <= data + 8'h32; //Key 5*10
										STATE <= CONFIRM;
									end
									
									4'b0100: begin
										data <= data + 8'h28; //Key 4*10
										STATE <= CONFIRM;
									end
									
									4'b0011: begin
										data <= data + 8'h1E; //Key 3*10
										STATE <= CONFIRM;
									end
									
									4'b0010: begin
										data <= data + 8'h14; //Key 2*10
										STATE <= CONFIRM;
									end
									
									4'b0001: begin
										data <= data + 8'hA; //Key 1*10
										STATE <= CONFIRM;
									end
									
									4'b0000: begin
										data <= data; 		  //Key 0*10
										STATE <= CONFIRM;
									end
									
									default: begin
										STATE <= WAIT_3_DIGIT;
									end
								endcase
								scan <= 1'b1;
							end
					end else if (~conf_en) begin
						STATE <= IDLE;
						scan <= 1'b0;
					end else begin
						scan <= 1'b0;
					end
				end
				
				CONFIRM: begin
					if(key_ready) begin
						case(key_code)
							4'b1010: begin
								if(~wr_addr) begin
									conf_addr <= data;
									wr_addr <= ~wr_addr;
								end else begin
									conf_data <= data;
									wr_addr <= ~wr_addr;
									sccb_start <= 1'b1;
								end
								STATE <= WAIT_1_DIGIT;
							end
							
							4'b1011: begin
								STATE <= WAIT_1_DIGIT;
								scan <= 1'b1;
							end							
						endcase
					end else if (~conf_en) begin
						STATE <= IDLE;
						scan <= 1'b0;
					end else begin
						scan <= 1'b0;
					end
				end				
			
			endcase
		
		end
	
	end
	
	
	key_pad key_pad(
		.clk (clk),
		.rst_n (rst_n),
		.scan (scan),
		.row (row),	
		
		.key_code (key_code),
		.col (col),
		.key_ready (key_ready)
	);
	
	reg [17:0] seven_seg_counter;
	wire [3:0] num;
	
	
	//The two seven segment displays for two digits share the same signals for displaying a value. To display different digits, the displays are flashing at 50Hz.
	
	always@(posedge clk) begin
		if(~rst_n) begin
			seven_seg_counter <= 18'b0;
			seven_seg_right <= 1'b1;
			seven_seg_left <= 1'b0;
		end else begin
			seven_seg_counter <= (seven_seg_counter < (CLK_FREQ/SEVEN_SEG_FREQ - 1)) ? seven_seg_counter + 1 : 18'b0;
			seven_seg_right <= (seven_seg_counter == (CLK_FREQ/SEVEN_SEG_FREQ - 1)) ? ~seven_seg_right : seven_seg_right;
			seven_seg_left <= (seven_seg_counter == (CLK_FREQ/SEVEN_SEG_FREQ - 1)) ? ~seven_seg_left : seven_seg_left;
		end
	end
	
	assign num = (seven_seg_right) ? data[3:0] : data[7:4];
	
	seven_seg seven_seg(
		.num (num),
		
		.A  (seven_seg_A),
		.B  (seven_seg_B),
		.C  (seven_seg_C),
		.D  (seven_seg_D),
		.E  (seven_seg_E),
		.F  (seven_seg_F),
		.G  (seven_seg_G),
		.DP (seven_seg_DP)
	);


endmodule
