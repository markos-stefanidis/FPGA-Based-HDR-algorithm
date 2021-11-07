module uart(
	input clk,
	input rst_n,
	input start,
	input [7:0] data_in,
	
	output reg ready,
	output reg TX
);

	localparam CLK_FREQ = 133000000;
	localparam UART_FREQ = 115200;
	localparam IDLE = 0;
	localparam TRANSMIT = 1;
	localparam TIMER = 2;
	localparam STOP = 3;


	reg [1:0] STATE;
	reg [1:0] RETURN_STATE;
	reg [7:0] reg_data_in;
	reg [10:0] delay_count;
	reg [2:0] byte_index;

	always@(posedge clk) begin
		if(~rst_n) begin
			STATE <= TIMER;
			delay_count <= CLK_FREQ/UART_FREQ;
			RETURN_STATE <= IDLE;
			reg_data_in <= 8'b0;
			byte_index <= 3'b0;
			
			ready <= 1'b0;
			TX <= 1'b1;
		end else begin
			
			case(STATE)
				
				IDLE: begin
					if(start) begin
						reg_data_in <= data_in;
						STATE <= TIMER;
						RETURN_STATE <= TRANSMIT;
						delay_count <= CLK_FREQ/UART_FREQ;
						byte_index <= 3'b0;						
						
						ready <= 1'b0;
						TX <= 1'b0;
					end else begin
						ready <= 1'b1;
						TX <= 1'b1;
					end
				end
				
				TRANSMIT: begin
					TX <= reg_data_in[0];
					byte_index <= byte_index + 1;
					reg_data_in <= reg_data_in >> 1;
					STATE <= TIMER;
					RETURN_STATE <= (byte_index == 3'b111) ? STOP : TRANSMIT;
					delay_count <= CLK_FREQ/UART_FREQ;
				end
				
				STOP: begin
					TX <= 1'b1;
					STATE <= TIMER;
					RETURN_STATE <= IDLE;
					delay_count <= CLK_FREQ/UART_FREQ;
				end
				
				TIMER: begin
					delay_count <= (delay_count - 1);
					STATE <= (delay_count == 11'b0) ? RETURN_STATE : TIMER;
				end			
			endcase			
		
		end
	
	end

endmodule