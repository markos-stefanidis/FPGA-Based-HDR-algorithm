module request_handler(
	input clk_133M,
	input rst_n_133M,
	input cmd_busy,

	input camera_wr_req,
	input hdr_wr_req,
	input vga_rd_req,
	input hdr_rd_req,
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

	output reg camera_ack,
	output reg vga_ack,
	output reg hdr_rd_ack,
	output reg hdr_wr_ack,
	output reg uart_ack,

	input init_done,
	output reg [3:0] cmd,
	output reg cmd_valid,
	output reg [24:0] ddr_address,
	output reg [127:0] ddr_wr_data,
	input [127:0] ddr_rd_data,
	input ddr_rd_valid
);
	assign busy = (camera_ack || hdr_rd_ack || vga_ack || uart_ack || hdr_wr_ack) || cmd_busy;
	reg [1:0] wr_mod;

	wire rd_mod_en;
	wire q_ddr_rd_valid;
	assign rd_mod_en = ddr_rd_valid;

	always@(posedge clk_133M) begin
		if(~rst_n_133M) begin
			camera_ack <= 1'b0;
			vga_ack <= 1'b0;
			hdr_rd_ack <= 1'b0;
			hdr_wr_ack <= 1'b0;
			uart_ack <= 1'b0;

			ddr_address <= 25'b0;
			cmd_valid <= 1'b0;
		end else begin


			if(~busy) begin
				if(camera_wr_req) begin
					camera_ack <= 1'b1;
					ddr_address <= camera_wr_address;
					ddr_wr_data <= camera_wr_data;
					cmd <= 4'b0100;
					cmd_valid <= 1'b1;
				end else if (hdr_rd_req) begin
					hdr_rd_ack <= 1'b1;
					ddr_address <= hdr_rd_address;
					cmd <= 4'b0011;
					cmd_valid <= 1'b1;
					wr_mod <= 2'b11;
				end else if (hdr_wr_req) begin
					hdr_wr_ack <= 1'b1;
					ddr_address <= hdr_wr_address;
					ddr_wr_data <= hdr_wr_data;
					cmd <= 4'b0100;
					cmd_valid <= 1'b1;
				end else if (vga_rd_req) begin
					vga_ack <= 1'b1;
					ddr_address <= vga_rd_address;
					cmd <= 4'b0011;
					cmd_valid <= 1'b1;
					wr_mod <= 2'b01;
				end else if (uart_rd_req) begin
					uart_ack <= 1'b1;
					ddr_address <= uart_rd_address;
					cmd <= 4'b0011;
					cmd_valid <= 1'b1;
					wr_mod <= 2'b10;
				end else begin
					cmd_valid <= 1'b0;

					camera_ack <= 1'b0;
					vga_ack <= 1'b0;
					hdr_rd_ack <= 1'b0;
					hdr_wr_ack <= 1'b0;
					uart_ack <= 1'b0;
				end

			end else begin
				cmd_valid <= 1'b0;
				camera_ack <= 1'b0;
				vga_ack <= 1'b0;
				hdr_rd_ack <= 1'b0;
				hdr_wr_ack <= 1'b0;
				uart_ack <= 1'b0;
			end
		end
	end

	always@(*) begin
		if(ddr_rd_valid) begin
			case(wr_mod)
				2'b01: begin
					vga_rd_data = ddr_rd_data;
					vga_rd_valid = 1'b1;
				end

				2'b10: begin
					uart_rd_data = ddr_rd_data;
					uart_rd_valid = 1'b1;
				end

				2'b11: begin
					hdr_rd_data = ddr_rd_data;
					hdr_rd_valid = 1'b1;
				end

				default begin
					vga_rd_valid = 1'b0;
					hdr_rd_valid = 1'b0;
					uart_rd_valid = 1'b0;
				end
			endcase
		end else begin
			hdr_rd_valid = 1'b0;
			vga_rd_valid = 1'b0;
			uart_rd_valid = 1'b0;
		end
	end

endmodule
