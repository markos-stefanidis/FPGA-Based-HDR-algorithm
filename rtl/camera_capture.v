module camera_capture(
	input p_clk,
	input rst_n,
	input [7:0] data,
	input href,
	input vsync,
	input take_pic,
	input hdr_en,
	
	output reg [2:0] last_frame,
	output reg frame_done,
	output reg [255:0] p_data,
	output reg data_valid,
	output reg [24:0] wr_address,
	output reg change_exp
	
);

	//Capturing data from camera module.
	//Frame starts when vsync goes low. Row starts when href goes high.
	//The DDR memory reads/writes 128bit of data, so 8 pixels need to be captured before writing them to memory

	
	reg STATE;
	reg [4:0] byte_counter;
	reg q_vsync;
	reg q_href;
	reg [9:0] row;
	reg exp_done;

	localparam IDLE = 0;
	localparam CAPTURE = 1;
	
	

	always @ (posedge p_clk) begin
		if(~rst_n || take_pic) begin
			byte_counter <= 5'b11111;
			STATE <= IDLE;
			p_data <= 128'b0;
			data_valid <= 1'b0;
			frame_done <= 1'b0;
			wr_address <= 25'b0;
			row <= 10'b0;
			change_exp <= 1'b0;
			exp_done <= 1'b0;
			q_vsync <= 1'b1;
		end else begin
			
			q_href <= href;
			q_vsync <= vsync;
			
			frame_done <= ~(q_vsync) && vsync;
		
			case(STATE)
			
				IDLE: begin
					STATE <= (!vsync) ? CAPTURE : IDLE;
					if(hdr_en) begin
						exp_done <= (!vsync) ? 1'b0 : exp_done;
					end else begin
						exp_done <= 1'b1;
					end
					byte_counter <= 5'b11111;
					//wr_address <= (last_frame) ? 25'h0 : 25'h25800;
					case(last_frame)
						3'b000: wr_address <= 25'h0;
						3'b001: wr_address <= 25'h25800;
						3'b010: wr_address <= 25'h4B000;
						3'b011: wr_address <= 25'h70800;
						3'b100: wr_address <= 25'h96000;
						3'b101: wr_address <= 25'hBB800;
						
						default: wr_address <= 25'h0;
					endcase
					row <= 10'b0;
				end
				
				CAPTURE: begin
					STATE <= (vsync) ? IDLE : CAPTURE;
					
					wr_address <= (data_valid) ? wr_address + 8 : wr_address;
					
					if(q_href && ~href) begin
						row <= row + 1;
					end
					
					if(href) begin
						
						data_valid <= (byte_counter == 5'b0) ? 1'b1 : 1'b0;
						byte_counter <= byte_counter - 1;
							
							p_data[255:248] <= (byte_counter == 5'b00000) ? data : p_data[255:248];
							p_data[247:240] <= (byte_counter == 5'b00001) ? data : p_data[247:240];
							p_data[239:232] <= (byte_counter == 5'b00010) ? data : p_data[239:232];
							p_data[231:224] <= (byte_counter == 5'b00011) ? data : p_data[231:224];				
							p_data[223:216] <= (byte_counter == 5'b00100) ? data : p_data[223:216];
							p_data[215:208] <= (byte_counter == 5'b00101) ? data : p_data[215:208];
							p_data[207:200] <= (byte_counter == 5'b00110) ? data : p_data[207:200];
							p_data[199:192] <= (byte_counter == 5'b00111) ? data : p_data[199:192];
							p_data[191:184] <= (byte_counter == 5'b01000) ? data : p_data[191:184];
							p_data[183:176] <= (byte_counter == 5'b01001) ? data : p_data[183:176];
							p_data[175:168] <= (byte_counter == 5'b01010) ? data : p_data[175:168];
							p_data[167:160] <= (byte_counter == 5'b01011) ? data : p_data[167:160];
							p_data[159:152] <= (byte_counter == 5'b01100) ? data : p_data[159:152];
							p_data[151:144] <= (byte_counter == 5'b01101) ? data : p_data[151:144];
							p_data[143:136] <= (byte_counter == 5'b01110) ? data : p_data[143:136];
							p_data[135:128] <= (byte_counter == 5'b01111) ? data : p_data[135:128];				
							p_data[127:120] <= (byte_counter == 5'b10000) ? data : p_data[127:120];
							p_data[119:112] <= (byte_counter == 5'b10001) ? data : p_data[119:112];
							p_data[111:104] <= (byte_counter == 5'b10010) ? data : p_data[111:104];
							p_data[103:96]  <= (byte_counter == 5'b10011) ? data : p_data[103:96];				
							p_data[95:88]   <= (byte_counter == 5'b10100) ? data : p_data[95:88];
							p_data[87:80]   <= (byte_counter == 5'b10101) ? data : p_data[87:80];
							p_data[79:72]   <= (byte_counter == 5'b10110) ? data : p_data[79:72];
							p_data[71:64]   <= (byte_counter == 5'b10111) ? data : p_data[71:64];				
							p_data[63:56]   <= (byte_counter == 5'b11000) ? data : p_data[63:56];
							p_data[55:48]   <= (byte_counter == 5'b11001) ? data : p_data[55:48];
							p_data[47:40]   <= (byte_counter == 5'b11010) ? data : p_data[47:40];
							p_data[39:32]   <= (byte_counter == 5'b11011) ? data : p_data[39:32];				
							p_data[31:24]   <= (byte_counter == 5'b11100) ? data : p_data[31:24];
							p_data[23:16]   <= (byte_counter == 5'b11101) ? data : p_data[23:16];
							p_data[15:8]    <= (byte_counter == 5'b11110) ? data : p_data[15:8];
							p_data[7:0]     <= (byte_counter == 5'b11111) ? data : p_data[7:0];				
							
					end else begin
						data_valid <= 1'b0;
					end					
					
					if(row == 480 && ~exp_done) begin
						change_exp <= 1'b1;
						exp_done <= 1'b1;
					end else begin
						change_exp <= 1'b0;
					end
				end
			endcase
		end
	end
	
	always@(posedge p_clk) begin
		if(~rst_n) begin
			last_frame <= 3'b0;                                  //last_frame = 0 means that camera is writing the second frame (0x25800). last_frame = 1 means camera is writing the first frame (0x0).
		end else begin
			if((~q_vsync) && vsync) begin
				if(last_frame < 5) begin	
					last_frame <=  last_frame + 1;
				end else begin
					last_frame <= 3'b0;
				end
			end
		end
	end

endmodule
