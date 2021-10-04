module vga_controller(
	input clk_25M,
	input rst_n,
	input [15:0] pixel_data,
	
	output reg [9:0] h_counter, // h_counter as output, as it is needed for the pixel_address of the row buffer
	output reg vsync,
	output reg hsync,
	output reg [1:0] red,
	output reg [1:0] green,
	output reg [1:0] blue,
	
	output reg start_frame,
	output reg start_row
);

	
	reg[9:0] v_counter;
	
	
	always@(posedge clk_25M) begin
		if(~rst_n) begin
			vsync <= 1'b1;
			hsync <= 1'b1;
			
			h_counter <= 10'h0;
			v_counter <= 10'd524;
			
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
			
			if(v_counter == 524) begin
				if(h_counter == 640) begin
					start_row <= 1'b1;  //Asserted to let the row buffer know when to start reading a new row
					start_frame <= 1'b1; //Asserted to let the row buffer know when to start reading a new frame
				end else begin
					start_row <= 1'b0;
					start_frame <= 1'b0;
				end
			end else if (v_counter < 479) begin
				if(h_counter == 640) begin
					start_row <= 1'b1;
				end else begin
					start_row <= 1'b0;
				end
			end
			
			
			hsync <= (h_counter < 656 || h_counter > 751);
			vsync <= (v_counter < 490 || v_counter > 491);
			
			
			// Bytes are inverted as Row buffer address 0x0 actually returns the 16nth byte of the 128bit rd_data
			// red   ---> pixel_data[7:3]
			// green ---> pixel_data[3:0], pixel_data[15:13]
			// blue  ---> pixel_data[12:8]
			
			
		
			if (h_counter < 640 && v_counter < 480) begin
				red <= (pixel_data[7:6] == 2'b11) ? (2'b11) : (pixel_data[7:6] + (pixel_data[5] && (pixel_data[4] || pixel_data[3])));  // Rounding up for 2bit output
				green <= (pixel_data[2:1] == 2'b11) ? (2'b11) : (pixel_data[2:1] + (pixel_data[0] && (pixel_data[15] || pixel_data[14] || pixel_data[13]))); // Rounding up for 2bit output
				blue <= (pixel_data[12:11] == 2'b11) ? (2'b11) : (pixel_data[12:11] + (pixel_data[10] && (pixel_data[9] || pixel_data[8]))); // Rounding up for 2bit output
			end else begin
				red <= 2'b0;
				green <= 2'b0;
				blue <= 2'b0;
			end
			
		end
	
	end
	
	
endmodule
