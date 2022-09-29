`define SYS_DATA_WIDTH 128
`define SYS_ADDR_WIDTH 27
module request_handler(
	input clk,
	input ui_rst_n,
	input addr_fix,
	input addr_fix_hdr,

	input camera_wr_req,
	input hdr_wr_req,
	input vga_rd_req,
	input hdr_rd_req,
	input uart_rd_req,

	input [`SYS_ADDR_WIDTH - 1 : 0] camera_wr_address,
	input [`SYS_ADDR_WIDTH - 1 : 0] vga_rd_address,
	input [`SYS_ADDR_WIDTH - 1 : 0] hdr_rd_address,
	input [`SYS_ADDR_WIDTH - 1 : 0] hdr_wr_address,
	input [`SYS_ADDR_WIDTH - 1 : 0] uart_rd_address,

	output reg [127:0] vga_rd_data,
	output reg [127:0] hdr_rd_data,
	output reg [127:0] uart_rd_data,

	output reg vga_rd_valid,
	output reg hdr_rd_valid,
	output reg uart_rd_valid,

	input [127:0] camera_wr_data,
	input [127:0] hdr_wr_data,

	output reg camera_ack,
	output reg vga_ack,
	output reg hdr_rd_ack,
	output reg hdr_wr_ack,
	output reg uart_ack,

	// MIG-7 Interface
	output reg [`SYS_ADDR_WIDTH - 1 : 0] app_addr, //DDR Address
	output reg [2:0] app_cmd, //DDR Command 3'b000 = WRITE, 3'b001 = READ
	output reg app_en, //app_cmd, app_addr valid
	input app_rdy, //Request ack
	output app_hi_pri, //Assert for high priority requests
	input [`SYS_DATA_WIDTH - 1 : 0] app_rd_data, //DDR read data
	input app_rd_data_end, //Indication that read ends
	input app_rd_data_valid, //Indication that app_rd_data is valid
	output reg [`SYS_DATA_WIDTH - 1 : 0] app_wdf_data, //DDR write data
	output [15:0] app_wdf_mask,
	output reg app_wdf_end, //Indication that write ends
	input app_wdf_rdy, //Indication that MIG fifo is not full
	output reg app_wdf_wren, //DDR write enable
	input init_calib_complete //Initialization is done
);


	reg [1:0] wr_mod;

	wire [1:0] rd_mod;
	wire fifo_rd_en;
	reg fifo_wr_en;
	wire fifo_empty;
	wire fifo_full;


	assign app_hi_pri = 1'b0;
	assign app_wdf_mask  = 16'b0;

	reg [2:0] STATE;
	localparam CALIB = 0;
	localparam IDLE = 1;
	localparam READ = 2;
	localparam WRITE = 3;
	localparam WR_DATA = 4;

	localparam CMD_WRITE = 3'b000;
	localparam CMD_READ = 3'b001;

	reg [127:0] ddr_rd_data;
	reg ddr_rd_valid;
	reg [127:0] q_ddr_rd_data;
	reg q_ddr_rd_valid;

	wire [7:0] f_address;
	wire [7:0] f_address_hdr;

	assign f_address = (addr_fix) ? 128 : 0;
	assign f_address_hdr = (addr_fix_hdr) ? 128 : 0;

	always@(posedge clk) begin
		if(~ui_rst_n) begin
			camera_ack <= 1'b0;
			vga_ack <= 1'b0;
			hdr_rd_ack <= 1'b0;
			hdr_wr_ack <= 1'b0;
			uart_ack <= 1'b0;

	//		ddr_rd_valid <= 1'b0;
			q_ddr_rd_valid <= 1'b0;

			app_cmd <= 3'b0;
			app_addr <= 27'b0;
			app_en <= 1'b0;
			app_wdf_wren <= 1'b0;
			app_wdf_end <= 1'b1;

			wr_mod <= 2'b0;

			fifo_wr_en <= 1'b0;

			STATE <= CALIB;

		end else begin

			case(STATE)
				CALIB: begin
					if (init_calib_complete)
					STATE <= IDLE;
				end

				IDLE: begin
					fifo_wr_en <= 1'b0;
					//if(init_calib_complete) begin
					if(camera_wr_req) begin
						app_addr <= camera_wr_address;
						app_wdf_data <= camera_wr_data;
						if(app_wdf_rdy) begin
							camera_ack <= 1'b1;
							app_wdf_wren <= 1'b1;
							app_wdf_end <= 1'b1;
							STATE <= WRITE;
						end
					end else if (hdr_rd_req && ~fifo_full) begin
						app_addr <= hdr_rd_address + f_address_hdr;
						app_cmd <= CMD_READ;
						app_en <= 1'b1;
						wr_mod <= 2'b11;
						STATE <= READ;
						hdr_rd_ack <= 1'b1;
					end else if (hdr_wr_req) begin
						app_addr <= hdr_wr_address;
						app_wdf_data <= hdr_wr_data;
						if(app_wdf_rdy) begin
							hdr_wr_ack <= 1'b1;
							app_wdf_wren <= 1'b1;
							app_wdf_end <= 1'b1;
							STATE <= WRITE;
						end
					end else if (vga_rd_req && ~fifo_full) begin
						app_addr <= vga_rd_address + f_address;
						app_cmd <= CMD_READ;
						app_en <= 1'b1;
						wr_mod <= 2'b01;
						STATE <= READ;
						vga_ack <= 1'b1;
					end else if (uart_rd_req && ~fifo_full) begin
						app_addr <= uart_rd_address + f_address;
						app_cmd <= CMD_READ;
						app_en <= 1'b1;
						wr_mod <= 2'b10;
						STATE <= READ;
						uart_ack <= 1'b1;
					end else begin
						camera_ack <= 1'b0;
						vga_ack <= 1'b0;
						hdr_rd_ack <= 1'b0;
						hdr_wr_ack <= 1'b0;
						uart_ack <= 1'b0;
						app_en <= 1'b0;
					end
				end

				READ: begin
					camera_ack <= 1'b0;
					vga_ack <= 1'b0;
					hdr_rd_ack <= 1'b0;
					hdr_wr_ack <= 1'b0;
					uart_ack <= 1'b0;

					if(app_rdy) begin
						app_en <= 1'b0;
						fifo_wr_en <= 1'b1;
						STATE <= IDLE;
					end
				end

				WRITE: begin
					camera_ack <= 1'b0;
					vga_ack <= 1'b0;
					hdr_rd_ack <= 1'b0;
					hdr_wr_ack <= 1'b0;
					uart_ack <= 1'b0;

					if(app_wdf_rdy) begin
						app_wdf_wren <= 1'b0;
						app_wdf_end <= 1'b0;
						app_en <= 1'b1;
						app_cmd <= CMD_WRITE;
						STATE <= WR_DATA;
					end
				end

				WR_DATA: begin
					if(app_rdy) begin
						app_en <= 1'b0;
						STATE <= IDLE;
					end
				end
			endcase
		end
    end

	assign fifo_rd_en = app_rd_data_valid;

	fifo #(.N(2), .ADDR(10)) rd_mod_fifo(
		.clk (clk),
		.rst_n (ui_rst_n),
		.wr_data (wr_mod),
		.wr_en (fifo_wr_en),
		.rd_en (fifo_rd_en),

		.rd_data (rd_mod),
		.empty (fifo_empty),
		.full (fifo_full)
	);

	always@(posedge clk) begin
		if(~ui_rst_n) begin
			vga_rd_valid <= 1'b0;
			hdr_rd_valid <= 1'b0;
			uart_rd_valid <= 1'b0;
			ddr_rd_valid <= 1'b0;
		end else begin
			ddr_rd_data <= app_rd_data;
			ddr_rd_valid <= app_rd_data_valid;
			if(ddr_rd_valid) begin
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

					default begin
						vga_rd_valid <= 1'b0;
						hdr_rd_valid <= 1'b0;
						uart_rd_valid <= 1'b0;
					end
				endcase
			end else begin
				hdr_rd_valid <= 1'b0;
				vga_rd_valid <= 1'b0;
				uart_rd_valid <= 1'b0;
			end
		end
	end

endmodule
