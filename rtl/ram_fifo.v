module ram_bus(
	input clk_133M,
	input rst_n_133M,
	input cmd_busy,

	input camera_wr_req,
	input vga_rd_req,
	input hdr_rd_req,
	input hdr_wr_req,
	input uart_rd_req,

	input [24:0] camera_wr_address,
	input [24:0] vga_rd_address,
	input [24:0] hdr_rd_address,
	input [24:0] hdr_wr_address,
	input [24:0] uart_rd_address,

	output reg [127:0] vga_rd_data,
	output reg [127:0] hdr_rd_data,
	output reg [127:0] uart_rd_data,

	output reg vga_rd_valid,
	output reg hdr_rd_valid,
	output reg uart_rd_valid,

	input [127:0] camera_wr_data,
	input [127:0] hdr_wr_data,

	output busy,

	input init_done,
	output reg [3:0] cmd,
	output reg cmd_valid,
	output reg [24:0] ddr_address,
	output reg [127:0] ddr_wr_data,
	input [127:0] ddr_rd_data,
	input ddr_rd_valid
);

	// This module handles the requests from either the camera module or the row buffer to the DDR Memory.
	// It prioritizes camera_wr_data.
	// ram_busy is asserted when the in_fifo is almost full, or when 2 requests arrive at once. After sorting them, in_fifo is ready to accept new requests.


	wire [4:0] requests;
	wire rst;
	wire one_hot = (requests == 5'b00000 || requests == 5'b00001 || requests == 5'b00010 || requests == 5'b00100 || requests == 5'b01000 || requests == 5'b10000);

	wire in_full;
	wire in_almost_full;
	wire in_empty;

	wire mod_empty;
	wire mod_full;

	reg [156:0] fifo_data_in;
	reg fifo_wr_en;

	reg [156:0] in_wr_data_0;
	reg in_wr_req_0;
	reg [156:0] in_wr_data_1;
	reg in_wr_req_1;
	reg [156:0] in_wr_data_2;
	reg in_wr_req_2;
	reg [156:0] in_wr_data_3;
	reg in_wr_req_3;

	//wr_mod
	//01     |  VGA
	//10     |  UART
	//11     |  HDR

	reg [1:0] wr_mod_0;
	reg [1:0] wr_mod_1;
	reg wr_mod_req_0;
	reg wr_mod_req_1;
	wire rd_mod_en;
	wire [1:0] rd_mod;

	reg q_ddr_rd_valid;


	wire [156:0] in_rd_data;
	wire in_rd_en;
	reg q_in_rd_en;

	assign rd_mod_en = ddr_rd_valid;
	assign rst = ~rst_n_133M;
	assign busy = in_almost_full || ~one_hot || mod_full;
	assign in_rd_en = (init_done && ~(in_empty || cmd_busy || cmd_valid || q_in_rd_en));
	assign requests = {hdr_rd_req, camera_wr_req, hdr_wr_req, vga_rd_req, uart_rd_req};

	always@(posedge clk_133M) begin
		if(~rst_n_133M) begin
			ddr_address <= 25'b0;
			ddr_wr_data <= 128'b0;

			fifo_data_in <= 156'b0;
			fifo_wr_en <= 1'b0;

			in_wr_data_0 <= 156'b0;
			in_wr_data_1 <= 156'b0;
			in_wr_data_2 <= 156'b0;
			in_wr_data_3 <= 156'b0;
			in_wr_req_0 <= 1'b0;
			in_wr_req_1 <= 1'b0;
			in_wr_req_2 <= 1'b0;
			in_wr_req_3 <= 1'b0;

			q_in_rd_en <= 1'b0;

			wr_mod_0 <= 2'b0;
			wr_mod_1 <= 2'b0;
			wr_mod_req_0 <= 1'b0;
			wr_mod_req_1 <= 1'b0;

		end else begin

			q_in_rd_en <= in_rd_en;
			q_ddr_rd_valid <= ddr_rd_valid;

			fifo_data_in <= in_wr_data_0;
			fifo_wr_en <= in_wr_req_0;


			if(init_done) begin
				if(~in_full) begin
					case (requests)

						5'b11110: begin
							in_wr_data_0 <= {4'b0011, 128'b0, vga_rd_address};
							in_wr_data_1 <= {4'b0011, 128'b0, hdr_rd_address};
							in_wr_data_2 <= {4'b0100, camera_wr_data, camera_wr_address};
							in_wr_data_3 <= {4'b0100, hdr_wr_data, hdr_wr_address};

							in_wr_req_0 <= 1'b1;
							in_wr_req_1 <= 1'b1;
							in_wr_req_2 <= 1'b1;
							in_wr_req_3 <= 1'b1;

							wr_mod_0 <= 2'b11;
							wr_mod_1 <= 2'b01;

							wr_mod_req_0 <= 1'b1;
							wr_mod_req_1 <= 1'b1;
						end

						5'b11100: begin
							in_wr_data_0 <= {4'b0011, 128'b0, hdr_rd_address};
							in_wr_data_1 <= {4'b0100, camera_wr_data, camera_wr_address};
							in_wr_data_2 <= {4'b0100, hdr_wr_data, hdr_wr_address};

							in_wr_req_0 <= 1'b1;
							in_wr_req_1 <= 1'b1;
							in_wr_req_2 <= 1'b1;
							in_wr_req_3 <= 1'b0;

							wr_mod_0 <= 2'b11;

							wr_mod_req_0 <= 1'b1;
							wr_mod_req_1 <= 1'b0;
						end

						5'b11010: begin
							in_wr_data_0 <= {4'b0011, 128'b0, vga_rd_address};
							in_wr_data_1 <= {4'b0011, 128'b0, hdr_rd_address};
							in_wr_data_2 <= {4'b0100, camera_wr_data, camera_wr_address};

							in_wr_req_0 <= 1'b1;
							in_wr_req_1 <= 1'b1;
							in_wr_req_2 <= 1'b1;
							in_wr_req_3 <= 1'b0;

							wr_mod_0 <= 2'b01;
							wr_mod_1 <= 2'b11;

							wr_mod_req_0 <= 1'b1;
							wr_mod_req_1 <= 1'b1;
						end

						5'b11000: begin
							in_wr_data_0 <= {4'b0011, 128'b0, hdr_rd_address};
							in_wr_data_1 <= {4'b0100, camera_wr_data, camera_wr_address};

							in_wr_req_0 <= 1'b1;
							in_wr_req_1 <= 1'b1;
							in_wr_req_2 <= 1'b0;
							in_wr_req_3 <= 1'b0;

							wr_mod_0 <= 2'b11;

							wr_mod_req_0 <= 1'b1;
							wr_mod_req_1 <= 1'b0;
						end

						5'b10110: begin
							in_wr_data_0 <= {4'b0011, 128'b0, vga_rd_address};
							in_wr_data_1 <= {4'b0011, 128'b0, hdr_rd_address};
							in_wr_data_2 <= {4'b0100, hdr_wr_data, hdr_wr_data};

							in_wr_req_0 <= 1'b1;
							in_wr_req_1 <= 1'b1;
							in_wr_req_2 <= 1'b1;
							in_wr_req_3 <= 1'b0;

							wr_mod_0 <= 2'b01;
							wr_mod_1 <= 2'b11;

							wr_mod_req_0 <= 1'b1;
							wr_mod_req_1 <= 1'b1;
						end

						5'b10100: begin
							in_wr_data_0 <= {4'b0011, 128'b0, hdr_rd_address};
							in_wr_data_1 <= {4'b0100, hdr_wr_data, hdr_wr_data};

							in_wr_req_0 <= 1'b1;
							in_wr_req_1 <= 1'b1;
							in_wr_req_2 <= 1'b0;
							in_wr_req_3 <= 1'b0;

							wr_mod_0 <= 2'b11;

							wr_mod_req_0 <= 1'b1;
							wr_mod_req_1 <= 1'b0;
						end

						5'b10010: begin
							in_wr_data_0 <= {4'b0011, 128'b0, vga_rd_address};
							in_wr_data_1 <= {4'b0011, 128'b0, hdr_rd_address};

							in_wr_req_0 <= 1'b1;
							in_wr_req_1 <= 1'b1;
							in_wr_req_2 <= 1'b0;
							in_wr_req_3 <= 1'b0;

							wr_mod_0 <= 2'b01;
							wr_mod_1 <= 2'b11;

							wr_mod_req_0 <= 1'b1;
							wr_mod_req_1 <= 1'b1;
						end

						5'b10000: begin
							in_wr_data_0 <= {4'b0011, 128'b0, hdr_rd_address};

							in_wr_req_0 <= 1'b1;
							in_wr_req_1 <= 1'b0;
							in_wr_req_2 <= 1'b0;
							in_wr_req_3 <= 1'b0;

							wr_mod_0 <= 2'b11;

							wr_mod_req_0 <= 1'b1;
							wr_mod_req_1 <= 1'b0;
						end

						5'b01110: begin
							in_wr_data_0 <= {4'b0011, 128'b0, vga_rd_address};
							in_wr_data_1 <= {4'b0100, camera_wr_data, camera_wr_address};
							in_wr_data_2 <= {4'b0100, hdr_wr_data, hdr_wr_data};

							in_wr_req_0 <= 1'b1;
							in_wr_req_1 <= 1'b1;
							in_wr_req_2 <= 1'b1;
							in_wr_req_3 <= 1'b0;

							wr_mod_0 <= 2'b01;

							wr_mod_req_0 <= 1'b1;
							wr_mod_req_1 <= 1'b0;
						end

						5'b01100: begin
							in_wr_data_0 <= {4'b0100, camera_wr_data, camera_wr_address};
							in_wr_data_1 <= {4'b0100, hdr_wr_data, hdr_wr_data};

							in_wr_req_0 <= 1'b1;
							in_wr_req_1 <= 1'b1;
							in_wr_req_2 <= 1'b0;
							in_wr_req_3 <= 1'b0;

							wr_mod_req_0 <= 1'b0;
							wr_mod_req_1 <= 1'b0;

						end

						5'b01010: begin
							in_wr_data_0 <= {4'b0011, 128'b0, vga_rd_address};
							in_wr_data_1 <= {4'b0100, camera_wr_data, camera_wr_address};

							in_wr_req_0 <= 1'b1;
							in_wr_req_1 <= 1'b1;
							in_wr_req_2 <= 1'b0;
							in_wr_req_3 <= 1'b0;

							wr_mod_0 <= 2'b01;

							wr_mod_req_0 <= 1'b1;
							wr_mod_req_1 <= 1'b0;
						end

						5'b01000: begin
							in_wr_data_0 <= {4'b0100, camera_wr_data, camera_wr_address};

							in_wr_req_0 <= 1'b1;
							in_wr_req_1 <= 1'b0;
							in_wr_req_2 <= 1'b0;
							in_wr_req_3 <= 1'b0;

							wr_mod_req_0 <= 1'b0;
							wr_mod_req_1 <= 1'b0;
						end

						5'b00110: begin
							in_wr_data_0 <= {4'b0011, 128'b0, vga_rd_address};
							in_wr_data_1 <= {4'b0100, hdr_wr_data, hdr_wr_address};

							in_wr_req_0 <= 1'b1;
							in_wr_req_1 <= 1'b1;
							in_wr_req_2 <= 1'b0;
							in_wr_req_3 <= 1'b0;

							wr_mod_0 <= 2'b01;

							wr_mod_req_0 <= 1'b1;
							wr_mod_req_1 <= 1'b0;
						end

						5'b00100: begin
							in_wr_data_0 <= {4'b0100, hdr_wr_data, hdr_wr_address};

							in_wr_req_0 <= 1'b1;
							in_wr_req_1 <= 1'b0;
							in_wr_req_2 <= 1'b0;
							in_wr_req_3 <= 1'b0;

							wr_mod_req_0 <= 1'b0;
							wr_mod_req_1 <= 1'b0;
						end

						5'b00010: begin
							in_wr_data_0 <= {4'b0011, 128'b0, vga_rd_address};

							in_wr_req_0 <= 1'b1;
							in_wr_req_1 <= 1'b0;
							in_wr_req_2 <= 1'b0;
							in_wr_req_3 <= 1'b0;

							wr_mod_0 <= 2'b01;

							wr_mod_req_0 <= 1'b1;
							wr_mod_req_1 <= 1'b0;
						end

						5'b00011: begin
							in_wr_data_0 <= {4'b0011, 128'b0, vga_rd_address};
							in_wr_data_1 <= {4'b0011, 128'b0, uart_rd_address};

							in_wr_req_0 <= 1'b1;
							in_wr_req_1 <= 1'b1;
							in_wr_req_2 <= 1'b0;
							in_wr_req_3 <= 1'b0;

							wr_mod_0 <= 2'b01;
							wr_mod_1 <= 2'b10;

							wr_mod_req_0 <= 1'b1;
							wr_mod_req_1 <= 1'b1;
						end

						5'b00001: begin
							in_wr_data_0 <= {4'b0011, 128'b0, uart_rd_address};

							in_wr_req_0 <= 1'b1;
							in_wr_req_1 <= 1'b0;
							in_wr_req_2 <= 1'b0;
							in_wr_req_3 <= 1'b0;

							wr_mod_0 <= 2'b10;

							wr_mod_req_0 <= 1'b1;
							wr_mod_req_1 <= 1'b0;
						end

						default: begin
							in_wr_data_0 <= in_wr_data_1;
							in_wr_data_1 <= in_wr_data_2;
							in_wr_data_2 <= in_wr_data_3;
							in_wr_data_3 <= 285'b0;

							in_wr_req_0 <= in_wr_req_1;
							in_wr_req_1 <= in_wr_req_2;
							in_wr_req_2 <= in_wr_req_3;
							in_wr_req_3 <= 1'b0;

							wr_mod_0 <= wr_mod_1;
							wr_mod_1 <= 2'b0;

							wr_mod_req_0 <= wr_mod_req_1;
							wr_mod_req_1 <= 1'b0;
						end
					endcase
				end
			end

			if(q_in_rd_en) begin
				{cmd, ddr_wr_data, ddr_address} <= in_rd_data;
				cmd_valid <= 1'b1;
			end else begin
				cmd_valid <= 1'b0;
			end

			if(q_ddr_rd_valid) begin
				case(rd_mod)
					2'b01: begin
						vga_rd_data <= ddr_rd_data;
						vga_rd_valid <= 1'b1;
					end

					2'b10: begin
						uart_rd_data <= ddr_rd_data;
						uart_rd_valid <= 1'b1;
					end

					2'b11: begin
						hdr_rd_data <= ddr_rd_data;
						hdr_rd_valid <= 1'b1;
					end
				endcase
			end	else begin
				vga_rd_valid <= 1'b0;
				uart_rd_valid <= 1'b0;
				hdr_rd_valid <= 1'b0;
			end
		end

	end


	fifo_in fifo_in(
		.Data (fifo_data_in),
		.Clock (clk_133M),
		.WrEn (fifo_wr_en),
		.RdEn (in_rd_en),
		.Reset (rst),
		.Q (in_rd_data),
		.Empty (in_empty),
		.Full (in_full),
		.AlmostEmpty (),
		.AlmostFull (in_almost_full)
	);

	fifo_out_addr fifo_out_addr(
		.Data (wr_mod_0),
		.Clock (clk_133M),
		.WrEn (wr_mod_req_0),
		.RdEn (rd_mod_en),
		.Reset (rst),
		.Q (rd_mod),
		.Empty (mod_empty),
		.Full (mod_full)
	);



endmodule
