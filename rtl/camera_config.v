module camera_config(
	input clk_25M,
	input rst_n_25M,
	input start,
	input [7:0] i_conf_addr,
	input [7:0] i_conf_data,
	input change_exp,
	input hdr_en,
	input [2:0] last_frame,
	input frame_done,

	output sda,
	output scl,
	output done
);

	// This module is responsible for configuring the camera module.
	// ov7670_config module feeds the sccb interface with the address of the configuration register and the data to be written.
	// On reset, the ov7670_config module reads the address and the data from the ov7670_rom. The camera can be configured manually through a keypad.
	// t_exp = AEC[15:0] * t_row_interval
	// AEC[15:0] = {AECHH[5:0] (0x07), AECH[7:0] (0x10), COM1[1:0] (0x04)}
	// t_row_interval = 2*(787 + Dummy Pixels) * t_int_clk = 65.48 us
	// t_int_clk = t_clk * (CLKRC[5:0] + 1) = 41.6 ns

	localparam IDLE = 0;
	localparam CHANGE_EXP1 = 1;
	localparam WAIT_STATE = 2;
	localparam CHANGE_EXP2 = 3;
	localparam HIGH_EXP_VALUE = 8'h7F;


	wire [7:0] rom_address;
	wire [15:0] rom_data;
	wire sccb_ready;
	wire sccb_start;
	wire [7:0] sccb_data;
	wire [7:0] sccb_address;

	reg [1:0] STATE;

	reg [7:0] conf_data;
	reg [7:0] conf_addr;
	reg config_start;
	//reg [1:0] exposure;
	reg q_hdr_en;
	reg q_start;

	always@(posedge clk_25M) begin
		if(~rst_n_25M) begin
			STATE <= IDLE;
			config_start <= 1'b1;
			//exposure <= 2'b0;
			q_hdr_en <= 1'b0;
			q_start <= 1'b0;
		end else begin

			if(frame_done) begin
				q_hdr_en <= hdr_en;
			end

			case(STATE)
				IDLE: begin
					q_start <= start;
					if(start && ~q_start) begin
						conf_data <= i_conf_data;
						conf_addr <= i_conf_addr;
						config_start <= 1'b1;
					end else if (hdr_en && ~q_hdr_en) begin
						conf_data <= 8'hC4;
						conf_addr <= 8'h13;
						config_start <= 1'b1;
					end else if (~hdr_en && q_hdr_en) begin
						conf_data <= 8'hC5;
						conf_addr <= 8'h13;
						config_start <= 1'b1;
					end else if (change_exp) begin
						STATE <= CHANGE_EXP1;
					end else begin
						config_start <= 1'b0;
					end
				end

				CHANGE_EXP1: begin
					if(done) begin
						if(last_frame == 3'b0 || last_frame == 3'b100) begin
							conf_data <= HIGH_EXP_VALUE;
						end else if (last_frame == 3'b1 || last_frame == 3'b110) begin
							conf_data <= HIGH_EXP_VALUE >> 2;
						end else begin
							conf_data <= HIGH_EXP_VALUE >> 1;
						end


						//case(exposure)
						//	2'b00: begin
						//		conf_data <= 8'h54;  //MID
						//		exposure <= 2'b01;
						//	end
						//
						//	2'b01: begin
						//		conf_data <= 8'h7F;  //HIGH
						//		exposure <= 2'b10;
						//	end
						//
						//	2'b10: begin
						//		conf_data <= 8'h2A;  //LOW
						//		exposure <= 2'b0;
						//	end
						//endcase
						conf_addr <= 8'h10;
						STATE <= IDLE;
						config_start <= 1'b1;
					end else begin
						config_start <= 1'b0;
					end
				end

				//WAIT_STATE: begin
				//	STATE <= CHANGE_EXP2;
				//
				//	//if(done) begin
				//	//	if(exposure == 2'b0) begin
				//	//		conf_data <= 8'h55;
				//	//	end else if (exposure == 2'b01) begin
				//	//		conf_data <= 8'hAC;
				//	//	end else begin
				//	//		conf_data <= 8'hFF;
				//	//	end
				//	//	conf_addr <= 8'h10;
				//	//	STATE <= CHANGE_EXP3;
				//	//	config_start <= 1'b0;
				//	//end else begin
				//	//	config_start <= 1'b0;
				//	//end
				//end

				//CHANGE_EXP2: begin
				//	if(done) begin
				//		case(exposure)
				//			2'b00: begin
				//				conf_data <= 8'h3;  //MID
				//				exposure <= 2'b01;
				//			end
				//
				//			2'b01: begin
				//				conf_data <= 8'h0;  //HIGH
				//				exposure <= 2'b10;
				//			end
				//
				//			2'b10: begin
				//				conf_data <= 8'h3;  //LOW
				//				exposure <= 2'b0;
				//			end
				//
				//
				//		endcase
				//		conf_addr <= 8'h04;
				//		STATE <= IDLE;
				//		config_start <= 1'b1;
				//	end else begin
				//		config_start <= 1'b0;
				//	end
				//end
			endcase
		end
	end


	ov7670_rom ov7670_rom (
		.clk (clk_25M),
		.address (rom_address),
		.dout (rom_data)
	);

	ov7670_config ov7670_config(
		.clk_25M (clk_25M),
		.rst_n_25M (rst_n_25M),
		.sccb_ready (sccb_ready),
		.start (config_start),
		.conf_addr (conf_addr),
		.conf_data (conf_data),
		.rom_data (rom_data),
		.done (done),
		.sccb_start (sccb_start),
		.rom_address (rom_address),
		.sccb_data (sccb_data),
		.sccb_address (sccb_address)
	);

	sccb sccb(
		.clk_25M (clk_25M),
		.sccb_start (sccb_start),
		.rst_n_25M (rst_n_25M),
		.address (sccb_address),
		.data (sccb_data),
		.sda (sda),
		.scl (scl),
		.ready (sccb_ready)
	);

endmodule

