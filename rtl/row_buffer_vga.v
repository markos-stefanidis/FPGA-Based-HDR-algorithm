module row_buffer_vga(
	input clk_25M,
	input rst_n_25M,
	input clk_133M,
	input rst_n_133M,
	
	input [9:0] vga_h_counter,
	input rd_valid,
	input [127:0] rd_data,	
	
	input start_frame,
	input start_row,
	
	input [2:0] last_frame,
	input ram_busy,
	
	input hdr_en,
	input hdr_last_frame,
	
	output [15:0] pixel_data,
	output reg [24:0] rd_address,
	output reg rd_req
);
	
	// This is module buffers each row of the stored image and then feeds it to the vga_controller to be displayed.
	// The vga_controller informs the row buffer when to start reading a frame, or when to start reading a row.
	// The camera_capture module informs the row buffer what frame to start reading.
	
	
	wire rst_buffer;
	reg rd_en;
	wire wr_en;
	
	reg q_start_row;
	reg start_row_133M;
	reg q_start_row_133M;
	reg qq_start_row_133M;
	
	reg q_start_frame;
	reg start_frame_133M;
	reg q_start_frame_133M;
	
	
	reg row_done;
	reg [6:0] data_counter; // data_counter counts how many times rd_data have arrived from the memory.
	
	reg reg_rd_req;
	reg [9:0] pixel_address;
	
	
	assign rst_buffer = ~rst_n_25M;
	
	assign wr_en = (data_counter < 80);

	always@(posedge clk_133M) begin
		if(~rst_n_133M) begin
			q_start_row <= 1'b0;
			start_row_133M <= 1'b0;
			q_start_row_133M <= 1'b0;
			qq_start_row_133M <= 1'b0;
			
			q_start_frame <= 1'b0;
			start_frame_133M <= 1'b0;
			q_start_frame_133M <= 1'b0;
			
			
			rd_address <= 25'b0;
			rd_req <= 1'b0;
			
			data_counter <= 7'h50;

			reg_rd_req <= 1'b0;
			
			row_done <= 1'b0;
		end else begin
			q_start_row <= start_row;
			start_row_133M <= q_start_row;
			q_start_row_133M <= start_row_133M;
			qq_start_row_133M <= q_start_row_133M;			
			
			q_start_frame <= start_frame;
			start_frame_133M <= q_start_frame;
			q_start_frame_133M <= start_frame_133M;
			
			
			
			if(start_frame_133M && ~q_start_frame_133M) begin
				if(hdr_en) begin
					rd_address <= (hdr_last_frame) ? 25'hE1000 : 25'h106800; 
				end else begin
					case(last_frame)
						3'b101: rd_address <= 25'h0; //LOw
						3'b000: rd_address <= 25'h25800; //MID
						3'b001: rd_address <= 25'h4B000; //HIGH
						3'b010: rd_address <= 25'h70800; //LOW
						3'b011: rd_address <= 25'h96000; //MID
						3'b100: rd_address <= 25'hBB800; //HIGH
						
						default: rd_address <= 25'h0;
					endcase
				end	
			end else if(rd_req) begin
				rd_address <= rd_address + 4;
			end
			
			if(start_row_133M && ~q_start_row_133M) begin
				data_counter <= 7'b0;
			end else if (rd_valid) begin
				data_counter <= data_counter + 1;
			end
			
			
			if((q_start_row_133M && ~qq_start_row_133M) || rd_valid || reg_rd_req) begin //If the ram is not ready to accept requests, reg_rd_req is asserted to indicate that the read request has not been made.
				if(~ram_busy && ~row_done) begin
					rd_req <= 1'b1;
					reg_rd_req <= 1'b0;
				end else if (~row_done) begin
					rd_req <= 1'b0;
					reg_rd_req <= 1'b1;
				end else begin
					rd_req <= 1'b0;
					reg_rd_req <= 1'b0;
				end
			end else begin
				rd_req <= 1'b0;
				reg_rd_req <= 1'b0;
			end
						
			
			if(start_row_133M && ~q_start_row_133M) begin
				row_done <= 1'b0;
			end else if (data_counter == 78 && rd_valid) begin
				row_done <= 1'b1;
			end
			
			
		end	
	end

	always@(posedge clk_25M) begin
		if(~rst_n_25M) begin
			pixel_address <= 10'b0;
			rd_en <= 10'b0;
		end else begin
			if(vga_h_counter == 798) begin
				pixel_address <= 10'b0;
				rd_en <= 1'b1;
			end else begin
				pixel_address <= (pixel_address < 640) ? pixel_address + 1 : pixel_address;
				rd_en <= (pixel_address < 640);
			end
		end
	end
	
	
	row_buffer row_0( 				//This is a memory that writes 128bit data but reads 16bit data. Read address 0x0 will return the 16 LSB of the 128bit data written to write address 0x0, so the bytes need to be inverted before displayed
		.WrAddress (data_counter),
		.RdAddress (pixel_address),
		.Data (rd_data),
		.WE (rd_valid),
		.RdClock (clk_25M),
		.RdClockEn (rd_en), 
		.Reset (rst_buffer),
		.WrClock (clk_133M),
		.WrClockEn (wr_en),
		.Q (pixel_data)
	);

endmodule
