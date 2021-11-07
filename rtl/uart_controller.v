module uart_controller(
	input clk,
	input rst_n,
	input [127:0] rd_data,
	input rd_data_valid,
	input start,
	input [2:0] last_frame,
	input ram_busy,	
	
	output reg rd_req,
	output reg [24:0] rd_address,
	output TX,
	output busy_led
);
	
	localparam IDLE = 0;
	localparam REQUEST_DATA = 1;
	localparam WAIT_DATA = 2;
	localparam TX_DATA = 3;
	localparam DONE = 4;
	
	
	reg [17:0] data_counter;
	reg [2:0] STATE;
	reg [4:0] byte_index;
	reg [127:0] reg_data;
	reg [7:0] uart_data;
	reg uart_start;
	reg q_start;
	reg busy;
	reg reg_rd_req;
	
	wire uart_ready;

	always@(posedge clk) begin
		if(~rst_n) begin
			rd_address <= 24'b0;
			data_counter <= 18'b0;
			STATE <= IDLE;
			byte_index <= 5'b0;
			rd_req <= 1'b0;
			uart_data <= 8'b0;
			uart_start <= 1'b0;
			q_start <= 1'b0;
			busy <= 1'b0;
			reg_rd_req <= 1'b0;
		end else begin
			
			q_start <= start;
		
			case(STATE)
				
				IDLE: begin
					if(start && ~q_start) begin
						//rd_address <= 25'b0; //(last_frame) ? 25'h0 : 25'h25800;
						rd_address <= (last_frame < 3'b011) ? 25'h70800 : 25'h0;
						
						data_counter <= 18'b0;
						STATE <= REQUEST_DATA;
						busy <= 1'b1;
					end
					rd_req <= 1'b0;
				end
				
				REQUEST_DATA: begin
					if(~ram_busy) begin
						rd_req <= 1'b1;
						reg_rd_req <= 1'b0;
						STATE <= WAIT_DATA;
					end else begin
						rd_req <= 1'b0;
						reg_rd_req <= 1'b1;
						STATE <= REQUEST_DATA;
					end				
				end
				
				WAIT_DATA: begin
					rd_req <= 1'b0;
					
					if(rd_data_valid) begin
						data_counter <= data_counter + 1;
						reg_data <= rd_data;
						STATE <= TX_DATA;
						byte_index <= 5'b0;
					end
				end
				
				TX_DATA: begin
					if(uart_ready && ~uart_start) begin
						case(byte_index)
							5'b01111: uart_data <= reg_data[127:120];
							5'b01110: uart_data <= reg_data[119:112];
							5'b01101: uart_data <= reg_data[111:104];
							5'b01100: uart_data <= reg_data[103:96];
							5'b01011: uart_data <= reg_data[95:88];
							5'b01010: uart_data <= reg_data[87:80];
							5'b01001: uart_data <= reg_data[79:72];
							5'b01000: uart_data <= reg_data[71:64];
							5'b00111: uart_data <= reg_data[63:56];
							5'b00110: uart_data <= reg_data[55:48];
							5'b00101: uart_data <= reg_data[47:40];
							5'b00100: uart_data <= reg_data[39:32];
							5'b00011: uart_data <= reg_data[31:24];
							5'b00010: uart_data <= reg_data[23:16];
							5'b00001: uart_data <= reg_data[15:8];
							5'b00000: uart_data <= reg_data[8:0];
						endcase
						uart_start <= (byte_index < 5'b10000);
						byte_index <= byte_index + 1;					
					end else begin
						uart_start <= 1'b0;
					end
					
					if(byte_index == 5'b10000) begin						
						rd_address <= rd_address + 4;
						if(data_counter == 18'h1C200) begin
							STATE <= DONE;
						end else begin
							STATE <= REQUEST_DATA;
						end
					end					
				end
				
				DONE: begin
					if(uart_ready) begin
						STATE <= IDLE;
					end
					busy <= ~uart_ready;
				end			
				
			endcase
		end	
	end
	
	
	uart uart(
		.clk (clk),
		.rst_n (rst_n),
		.start (uart_start),
		.data_in (uart_data),
		
		.ready (uart_ready),
		.TX (TX)
	);
	
	assign busy_led = ~busy;

endmodule