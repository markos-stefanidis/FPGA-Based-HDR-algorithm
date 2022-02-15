module vga_controller(
	input clk_25M,
	input rst_n,
	input [15:0] pixel_data,

	output reg [9:0] h_counter, // h_counter as output, as it is needed for the pixel_address of the row buffer
	output reg vsync,
	output reg hsync,
	output reg [5:0] red,
	output reg [5:0] green,
	output reg [5:0] blue,

	output reg start_frame,
	output reg start_row
);


	reg[9:0] v_counter;
	wire [4:0] red_old;
	wire [5:0] green_old;
	wire [4:0] blue_old;


	wire [5:0] red_new;
	wire [5:0] blue_new;
	reg [5:0] green_new;

	reg fts_clk_en;


	always@(posedge clk_25M) begin
		if(~rst_n) begin
			vsync <= 1'b1;
			hsync <= 1'b1;

			h_counter <= 10'h0;
			v_counter <= 10'd524;

			start_frame <= 1'b0;
			start_row <= 1'b0;

			green_new <= 6'b0;
			fts_clk_en <= 1'b0;
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

			if (h_counter == 798) begin
				fts_clk_en <= 1'b1;
			end else if (h_counter == 639) begin
				fts_clk_en <= 1'b0;
			end

			green_new <= green_old;


			hsync <= (h_counter < 656 || h_counter > 751);
			vsync <= (v_counter < 490 || v_counter > 491);


			// Bytes are inverted as Row buffer address 0x0 actually returns the 16nth byte of the 128bit rd_data
			// red   ---> pixel_data[7:3]
			// green ---> pixel_data[3:0], pixel_data[15:13]
			// blue  ---> pixel_data[12:8]



			if (h_counter < 640 && v_counter < 480) begin
				red <= red_new;
				green <= green_new;
				blue <= blue_new;
			end else begin
				red <= 2'b0;
				green <= 2'b0;
				blue <= 2'b0;
			end

		end

	end

	assign red_old = pixel_data[7:3];
	assign green_old = {pixel_data[2:0], pixel_data[15:13]};
	assign blue_old = pixel_data[13:8];

	wire [9:0] fts_address;
	wire fts_rst;
	wire [11:0] fts_out;

	assign fts_rst = ~rst_n;
	assign fts_address = {red_old, blue_old};

	assign red_new = fts_out[11:6];
	assign blue_new = fts_out[5:0];

	five_to_six five_to_six(
		.Address (fts_address),
		.OutClock (clk_25M),
		.OutClockEn (fts_clk_en),
		.Reset (fts_rst),
		.Q(fts_out)
	);


endmodule
