module vga_controller(
	input clk_25M,
	input rst_n_25M,
	input [15:0] pixel_data,

	output reg [9:0] h_counter, // h_counter as output, as it is needed for the pixel_address of the row buffer
	output reg vsync,
	output reg hsync,
	output reg [3:0] red,
	output reg [3:0] green,
	output reg [3:0] blue,

	output reg start_frame,
	output reg start_row
);


	reg[9:0] v_counter;

	always@(posedge clk_25M) begin
		if(~rst_n_25M) begin
			vsync <= 1'b1;
			hsync <= 1'b1;

			h_counter <= 10'h600;
			v_counter <= 10'd521;

			start_frame <= 1'b0;
			start_row <= 1'b0;

		end else begin
			if (h_counter < 799) begin
				h_counter <= h_counter + 1;
			end else begin
				h_counter <= 10'b0;
				if (v_counter < 524) begin
					v_counter <= v_counter + 1;
				end else begin
					v_counter <= 10'b0;
				end
			end

			if(v_counter == 522) begin
				if(h_counter == 0) begin
					start_frame <= 1'b1; //Asserted to let the row buffer know when to start reading a new frame
				end else begin
					start_frame <= 1'b0;
				end
			end else begin
				start_frame <= 1'b0;
			end

			if (v_counter < 479) begin
				if(h_counter == 639) begin
					start_row <= 1'b1;  //Asserted to let the row buffer know when to start reading a new row
				end else begin
					start_row <= 1'b0;
				end
			end else begin
				start_row <= 1'b0;
			end


			hsync <= (h_counter < 656 || h_counter > 751);
			vsync <= (v_counter < 490 || v_counter > 491);


			// Bytes are inverted as Row buffer address 0x0 actually returns the 16nth byte of the 128bit rd_data
			// red   ---> pixel_data[7:3]
			// green ---> pixel_data[3:0], pixel_data[15:13]
			// blue  ---> pixel_data[12:8]



			if (h_counter < 640 && v_counter < 480) begin
				red <= pixel_data[7:4];
				green <= {pixel_data[2:0], pixel_data[15]};
				blue <= pixel_data[12:9];
			end else begin
				red <= 2'b0;
				green <= 2'b0;
				blue <= 2'b0;
			end


		end

	end

endmodule
