module ov7670_config(
	input clk_25M,
	input rst_n,
	input sccb_ready,
	input start,
	input [7:0] conf_addr,
	input [7:0] conf_data,
	input[15:0] rom_data,
	output reg done,
	output reg sccb_start,
	output reg [7:0] rom_address,
	output reg [7:0] sccb_data,
	output reg[7:0] sccb_address
);
	// On reset the address/data is read from the ov7670_rom. When the reset configuration is done, rst_done is asserted and the address/data are read from the keypad. 
	
	
	reg[1:0] STATE;
	reg[1:0] RETURN_STATE;
	reg[17:0] delay_count;
	reg rst_done;
	
	localparam IDLE = 0;
	localparam START_CONFIG = 1;
	localparam READY = 2;
	localparam TIMER = 3;
	
	
	always@(posedge clk_25M) begin
		if(~rst_n) begin
			done <= 1'b0;
			sccb_start <= 1'b0;
			rom_address <= 8'b0;
			sccb_data <= 8'b0;
			sccb_address <= 8'b0;
			STATE <= IDLE;
			delay_count <= 18'b0;
			rst_done <= 1'b0;
		end else begin
			case(STATE)
				
				IDLE: begin
					STATE <= start ? START_CONFIG : IDLE;
					rom_address <= 8'b0;
					done <= start ? 0 : done;
				end
			
				START_CONFIG: begin
					if(rst_done) begin
						if(sccb_ready) begin
							STATE <= TIMER;
							RETURN_STATE <= READY;
							delay_count <= 0;
							sccb_address <= conf_addr;
							sccb_data <= conf_data;
							sccb_start <= 1'b1;
						end						
						
					end else begin
						case(rom_data)
						
							16'hFFFF: begin //End of ROM
								//STATE <= READY;
								//sccb_start <= 1'b0;if(sccb_ready) begin
								if (sccb_ready) begin
									//STATE <= TIMER;
									STATE <= READY;
									//delay_count <= 0;
									//sccb_address <= rom_data[15:8];
									//sccb_data <= rom_data[7:0];
									//sccb_start <= 1;
									rst_done <= 1'b1;
									
								end
							end
							
							16'hFFF0: begin
								STATE <= TIMER;
								RETURN_STATE <= START_CONFIG;
								rom_address <= rom_address + 1;
								delay_count <= 18'd250000; //Delay 10ms
								sccb_start <= 1'b0;
							end
							
							default: begin
								if(sccb_ready) begin
									STATE <= TIMER;
									RETURN_STATE <= START_CONFIG;
									delay_count <= 0;
									rom_address <= rom_address + 1;
									sccb_address <= rom_data[15:8];
									sccb_data <= rom_data[7:0];
									sccb_start <= 1;
									
								end
								
							end
						endcase
					end
				end
				
				READY: begin
					STATE <= (sccb_ready) ? IDLE : READY;
					done <= (sccb_ready);
					sccb_start <= 1'b0;
				end
				
				TIMER: begin
					STATE <= (delay_count == 0) ? RETURN_STATE : TIMER;
					delay_count <= delay_count - 1;
				end
				
			endcase
		end
		
	
	end

endmodule
