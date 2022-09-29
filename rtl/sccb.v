module sccb(
	input clk_25M,
	input sccb_start,
	input rst_n_25M,
	input[7:0] address,
	input[7:0] data,
	output reg sda,
	output reg scl,
	output reg ready
);

	// This module implements the Seraial Camera Controll Bus (SCCB), a variation of I2C.
	// In order to write to the camera register, the camera write address (0x42) must first be transmited through the serail bus. Then the register address is transmited and finally the data to be written.
	// After each of theese 3 bytes are transmited, a don't care bit must be transmited before the next byte. A 0 is appended to all 3 bytes for that reason.
	// The maximum frequency of the serial bus is 100KHz.
	//https://www.waveshare.com/w/upload/1/14/OmniVision_Technologies_Seril_Camera_Control_Bus%28SCCB%29_Specification.pdf

	reg	[3:0] STATE;
	reg	[3:0] RETURN_STATE;
	reg	[8:0] r_address;
	reg	[8:0] r_data;
	reg	[10:0] delay_count;
	reg	[3:0] byte_index;
	reg [1:0] byte_counter;

	localparam cam_address = 9'h084;

	localparam IDLE = 0;
	localparam INIT = 1;
	localparam START = 2;
	localparam BYTE_1 = 3;
	localparam BYTE_2 = 4;
	localparam BYTE_3 = 5;
	localparam STOP_SCL = 6;
	localparam STOP_SDA = 7;
	localparam STOP_SCCB = 8;
	localparam TIMER = 9;



	always@(posedge clk_25M) begin
		if (~rst_n_25M) begin
			scl <= 1'b1;
			sda <= 1'b1;
			ready <= 1'b1;
			STATE <= TIMER;
			RETURN_STATE <= IDLE;
			delay_count <= 11'b0;
			byte_index <= 4'b1000;
			byte_counter <= 2'b0;
		end else begin

			case (STATE)
				IDLE: begin
					if (sccb_start) begin
						STATE <= TIMER;
						RETURN_STATE <= INIT;
						delay_count <= 11'd32;  //Delay 1.28us
						sda <= 1'b1;
						ready <= 1'b0;
						r_address <= {address, 1'b0};
						r_data <= {data, 1'b0};
					end else begin
						ready <= 1'b1;
					end
				end

				INIT: begin
					STATE <= TIMER;
					RETURN_STATE <= START;
					sda <= 1'b0;
					delay_count <= 11'd124; //Delay 5 us
				end

				START: begin
					scl <= 1'b0;
					STATE <= TIMER;
					RETURN_STATE <= BYTE_1;
					delay_count <= 11'd62; //Delay 2.5us
					byte_index <= 4'b1000;
					byte_counter <= 2'b0;
				end

				BYTE_1: begin
					case(byte_counter)
						2'b00: begin
							case(byte_index)
								4'b0000: sda <= cam_address[0];
								4'b0001: sda <= cam_address[1];
								4'b0010: sda <= cam_address[2];
								4'b0011: sda <= cam_address[3];
								4'b0100: sda <= cam_address[4];
								4'b0101: sda <= cam_address[5];
								4'b0110: sda <= cam_address[6];
								4'b0111: sda <= cam_address[7];
								4'b1000: sda <= cam_address[8];
							endcase
						end

						2'b01: begin
							case(byte_index)
								4'b0000: sda <= r_address[0];
								4'b0001: sda <= r_address[1];
								4'b0010: sda <= r_address[2];
								4'b0011: sda <= r_address[3];
								4'b0100: sda <= r_address[4];
								4'b0101: sda <= r_address[5];
								4'b0110: sda <= r_address[6];
								4'b0111: sda <= r_address[7];
								4'b1000: sda <= r_address[8];
							endcase
						end

						2'b10: begin
							case(byte_index)
								4'b0000: sda <= r_data[0];
								4'b0001: sda <= r_data[1];
								4'b0010: sda <= r_data[2];
								4'b0011: sda <= r_data[3];
								4'b0100: sda <= r_data[4];
								4'b0101: sda <= r_data[5];
								4'b0110: sda <= r_data[6];
								4'b0111: sda <= r_data[7];
								4'b1000: sda <= r_data[8];
							endcase
						end

					endcase
					STATE <= TIMER;
					RETURN_STATE <= BYTE_2;
					delay_count <= 11'd62; //Delay 2.5us
				end

				BYTE_2: begin
					scl <= 1'b1;
					STATE <= TIMER;
					RETURN_STATE <= BYTE_3;
					delay_count <= 11'd124;
				end

				BYTE_3: begin
					scl <= 1'b0;
					STATE <= TIMER;
					RETURN_STATE <= (byte_counter == 2'b10 && byte_index == 4'b0) ? STOP_SCL : BYTE_1;
					delay_count <= (byte_counter == 2'b10) ? 11'd124 : 11'd62;
					byte_counter <= (byte_index == 0) ? byte_counter + 1 : byte_counter;
					byte_index <= (byte_index == 0) ? 4'b1000 : byte_index - 1;
				end


				STOP_SCL: begin
					scl <= 1'b1;
					STATE <= TIMER;
					RETURN_STATE <= STOP_SDA;
					delay_count <= 11'd124; //Delay 5us
				end

				STOP_SDA: begin
					sda <= 1'b1;
					STATE <= TIMER;
					RETURN_STATE <= STOP_SCCB;
					delay_count <= 11'd248; // Delay 1.28us
				end

				STOP_SCCB: begin
					sda <= 1'b1;
					STATE <= IDLE;
					ready <= 1'b1;

				end

				TIMER: begin
					STATE <= (delay_count == 0) ? RETURN_STATE : TIMER;
					delay_count <= delay_count - 1;
				end

			endcase

		end
	end
endmodule
