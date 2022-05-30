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
	output reg [127:0] p_data,
	output reg data_valid,
//	output reg [24:0] wr_address,
	output reg change_exp

);

	//Capturing data from camera module.
	//Frame starts when vsync goes low. Row starts when href goes high.
	//The DDR memory reads/writes 128bit of data, so 8 pixels need to be captured before writing them to memory


	reg STATE;
	reg [3:0] byte_counter;
	reg q_vsync;
	reg q_href;
	reg [9:0] row;
	reg exp_done;
	localparam IDLE = 0;
	localparam CAPTURE = 1;



	always @ (posedge p_clk) begin
		if(~rst_n || take_pic) begin
			byte_counter <= 4'b1111;
			STATE <= IDLE;
			p_data <= 128'b0;
			data_valid <= 1'b0;
			frame_done <= 1'b0;
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
					STATE <= (!vsync && q_vsync) ? CAPTURE : IDLE;
					if(hdr_en) begin
						exp_done <= (!vsync) ? 1'b0 : exp_done;
					end else begin
						exp_done <= 1'b1;
					end
					byte_counter <= 4'b1111;
					row <= 10'b0;
				end

				CAPTURE: begin
					STATE <= (vsync) ? IDLE : CAPTURE;

//					wr_address <= (data_valid) ? wr_address + 4 : wr_address;

					if(q_href && ~href) begin
						row <= row + 1;
					end

					if(href) begin

						data_valid <= (byte_counter == 4'b0) ? 1'b1 : 1'b0;
						byte_counter <= byte_counter - 1;

							p_data[127:120] <= (byte_counter == 4'b0000) ? data : p_data[127:120];
							p_data[119:112] <= (byte_counter == 4'b0001) ? data : p_data[119:112];
							p_data[111:104] <= (byte_counter == 4'b0010) ? data : p_data[111:104];
							p_data[103:96]  <= (byte_counter == 4'b0011) ? data : p_data[103:96];
							p_data[95:88]   <= (byte_counter == 4'b0100) ? data : p_data[95:88];
							p_data[87:80]   <= (byte_counter == 4'b0101) ? data : p_data[87:80];
							p_data[79:72]   <= (byte_counter == 4'b0110) ? data : p_data[79:72];
							p_data[71:64]   <= (byte_counter == 4'b0111) ? data : p_data[71:64];
							p_data[63:56]   <= (byte_counter == 4'b1000) ? data : p_data[63:56];
							p_data[55:48]   <= (byte_counter == 4'b1001) ? data : p_data[55:48];
							p_data[47:40]   <= (byte_counter == 4'b1010) ? data : p_data[47:40];
							p_data[39:32]   <= (byte_counter == 4'b1011) ? data : p_data[39:32];
							p_data[31:24]   <= (byte_counter == 4'b1100) ? data : p_data[31:24];
							p_data[23:16]   <= (byte_counter == 4'b1101) ? data : p_data[23:16];
							p_data[15:8]    <= (byte_counter == 4'b1110) ? data : p_data[15:8];
							p_data[7:0]     <= (byte_counter == 4'b1111) ? data : p_data[7:0];

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
