module top_level(
	input clk,
	input rst_n,
	input camera_vsync,
	input camera_href,
	input[7:0] camera_data,
	input p_clk,
	input conf_en,
	input [3:0] keypad_row,


	output [5:0] vga_red,
	output [5:0] vga_green,
	output [5:0] vga_blue,
	output vga_vsync,
	output vga_hsync,
	output scl,
	output sda,
	output xclk,

	output[1:0] ddr_clk,
	output[1:0] ddr_cke,
	output[1:0] ddr_cs_n,
	output ddr_we_n,
	output ddr_cas_n,
	output ddr_ras_n,
	inout [31:0] ddr_dq,
	output[1:0] ddr_ba,
	output[12:0] ddr_addr,
	inout [3:0] ddr_dqs,
	output[3:0] ddr_dm,

	output [2:0] keypad_col,

	output seven_seg_right,
	output seven_seg_left,
	output seven_seg_A,
	output seven_seg_B,
	output seven_seg_C,
	output seven_seg_D,
	output seven_seg_E,
	output seven_seg_F,
	output seven_seg_G,
	output seven_seg_DP,

	output TX,

	output camera_rst_n,

	output addr_led,
	output [2:0] state_led,
	output reset_led,
	output config_led,
	output TX_led,
	output hdr_led
);

//Generating Clock Frequencies needed. Input clock (clk) is 25MHz

	wire clk_25M;
	wire clk_100M;
	wire clk_133M;

	//A 100MHz clock is required to generate 133MHz and 24MHz

	pll_100M pll_100M(
		.CLK (clk),
		.CLKOP (clk_100M),
		.CLKOS (clk_25M),
		.LOCK ()
	);

	pll_24M pll_24M(
		.CLK (clk_100M),
		.CLKOP (clk_24M),
		.LOCK ()
	);

	pll_133M pll_133M(
		.CLK (clk_100M),
		.CLKOP (clk_133M),
		.LOCK ()
	);


	assign xclk = clk_24M; //24MHz clock needed for camera module

//Double flopping rst_n to create synchronous reset signals

	reg q_rst_n_24M;
	reg q_rst_n_25M;
	reg q_rst_n_133M;

	reg rst_n_24M;
	reg rst_n_25M;
	reg rst_n_133M;

	always@(posedge clk_25M) begin
		q_rst_n_25M <= rst_n;
		rst_n_25M <= q_rst_n_25M;
	end

	always@(posedge clk_24M) begin
		q_rst_n_24M <= rst_n;
		rst_n_24M <= q_rst_n_24M;
	end

	always@(posedge clk_133M) begin
		q_rst_n_133M <= rst_n;
		rst_n_133M <= q_rst_n_133M;
	end

	assign camera_rst_n = rst_n_24M;

//200us delay needed for DDR Memory Controller

	reg sys_200us;
	reg [12:0] counter_200us;

	always@(posedge clk_25M) begin
		if(~rst_n_25M) begin
			counter_200us <= 13'b0;
			sys_200us <= 1'b0;
		end else begin
			counter_200us <= (counter_200us < 13'h1388) ? (counter_200us + 1) : counter_200us;
			sys_200us <= (counter_200us == 13'h1388);
		end
	end
//Declearing Ram Acks
	wire camera_ack;
	wire vga_ack;
	wire hdr_rd_ack;
	wire hdr_wr_ack;
	wire uart_ack;


//Instantiating Camera Modules

	wire hdr_en_25M;
	wire [2:0] last_frame_24M;
	wire frame_done_24M;
	wire [127:0] camera_p_data;
	wire camera_data_valid;
	wire change_exp_24M;
	wire take_pic_25M;

	camera_capture camera_capture(
		.p_clk (p_clk),
		.rst_n (rst_n_24M),
		.data (camera_data),
		.href (camera_href),
		.vsync (camera_vsync),
		.take_pic (take_pic_25M),
		.hdr_en (hdr_en_25M),

		.last_frame (last_frame_24M),
		.frame_done (frame_done_24M),
		.p_data (camera_p_data),
		.data_valid (camera_data_valid),
		.change_exp (change_exp_24M)
	);

	//Double Flopping frame_done and last_frame to cross them to 133MHz
	reg q_frame_done_133M;
	reg qq_frame_done_133M;
	reg qqq_frame_done_133M;
	wire frame_done_133M;

	reg [2:0] last_frame_133M;
	reg [2:0] q_last_frame_133M;

	always@(posedge clk_133M) begin
		q_frame_done_133M <= frame_done_24M;
		qq_frame_done_133M <= q_frame_done_133M;
		qqq_frame_done_133M <= qq_frame_done_133M;

		q_last_frame_133M <= last_frame_24M;
		last_frame_133M <= q_last_frame_133M;
	end

	assign frame_done_133M = qq_frame_done_133M && ~qqq_frame_done_133M;

	wire ram_busy;
	wire [127:0] camera_wr_data;
	wire [24:0] camera_wr_address;
	wire camera_wr_req;

	camera_store camera_store(
		.clk_133M (clk_133M),
		.p_clk (p_clk),
		.rst_n_133M (rst_n_133M),
		.rst_n_24M (rst_n_24M),
		.frame_done (frame_done_133M),
		.last_frame (last_frame_133M),

		.p_data (camera_p_data),
		.data_valid (camera_data_valid),
		.camera_ack (camera_ack),
		.ram_busy (ram_busy),

		.data (camera_wr_data),
		.wr_address (camera_wr_address),
		.wr_req (camera_wr_req)
	);

	//Double Flopping frame_done, change_exp and last_frame to cross them to 25MHz
	reg q_frame_done_25M;
	reg qq_frame_done_25M;
	reg qqq_frame_done_25M;

	wire frame_done_25M;

	reg [2:0] last_frame_25M;
	reg [2:0] q_last_frame_25M;

	reg q_change_exp_25M;
	reg change_exp_25M;

	always@(posedge clk_25M) begin
		q_frame_done_25M <= frame_done_24M;
		qq_frame_done_25M <= q_frame_done_25M;
		qqq_frame_done_25M <= qq_frame_done_25M;

		q_last_frame_25M <= last_frame_24M;
		last_frame_25M <= q_last_frame_25M;

		q_change_exp_25M <= change_exp_24M;
		change_exp_25M <= q_change_exp_25M;
	end

	assign frame_done_25M = qq_frame_done_25M && ~qqq_frame_done_25M;

	wire sccb_start;
	wire [7:0] conf_addr;
	wire [7:0] conf_data;
	wire camera_config_done;

	camera_config camera_config(
		.clk_25M (clk_25M),
		.rst_n (rst_n_25M),
		.start (sccb_start),
		.i_conf_addr (conf_addr),
		.i_conf_data (conf_data),
		.change_exp (change_exp_25M),
		.hdr_en (hdr_en_25M),
		.last_frame (last_frame_25M),

		.sda (sda),
		.scl (scl),
		.done (camera_config_done)
	);

//Instantiating Image Generator Module

	//Double Flopping hdr_en to cross it to 133MHz
	reg hdr_en_133M;
	reg q_hdr_en_133M;

	always@(posedge clk_133M) begin
		q_hdr_en_133M <= hdr_en_25M;
		hdr_en_133M <= q_hdr_en_133M;
	end

	wire [127:0] hdr_rd_data;
	wire [127:0] hdr_wr_data;

	wire [24:0] hdr_rd_address;
	wire [24:0] hdr_wr_address;

	wire hdr_rd_req;
	wire hdr_wr_req;

	wire hdr_rd_valid;

	wire hdr_last_frame;

	image_generator image_generator(
		.clk_133M (clk_133M),
		.clk_25M (clk_25M),
		.rst_n_133M (rst_n_133M),
		.rst_n_25M (rst_n_25M),
		.hdr_en (hdr_en_133M),

		.last_frame (last_frame_133M),
		.frame_done_133M (frame_done_133M),
		.frame_done_25M (frame_done_25M),
		.rd_data (hdr_rd_data),
		.rd_valid (hdr_rd_valid),

		.hdr_rd_ack (hdr_rd_ack),
		.hdr_wr_ack (hdr_wr_ack),
		.ram_busy (ram_busy),

		.camera_data (camera_wr_data),
		.camera_wr_req (camera_wr_req),

		.rd_req (hdr_rd_req),
		.wr_req (hdr_wr_req),
		.rd_address (hdr_rd_address),
		.wr_address (hdr_wr_address),
		.hdr_last_frame (hdr_last_frame),
		.wr_data (hdr_wr_data)
	);

//Instantiating VGA Modules

	wire [9:0] vga_h_counter;
	wire vga_start_frame;
	wire vga_start_row;

	wire [15:0] vga_pixel_data;

	wire [127:0] vga_rd_data;
	wire [24:0] vga_rd_address;
	wire vga_rd_req;
	wire vga_rd_valid;

	row_buffer_vga row_buffer_vga(
		.clk_25M (clk_25M),
		.rst_n_25M (rst_n_25M),
		.clk_133M (clk_133M),
		.rst_n_133M (rst_n_133M),

		.vga_h_counter (vga_h_counter),
		.rd_valid (vga_rd_valid),
		.rd_data (vga_rd_data),

		.start_frame (vga_start_frame),
		.start_row (vga_start_row),

		.last_frame (last_frame_133M),
		.vga_ack (vga_ack),
		.ram_busy (ram_busy),

		.hdr_en (hdr_en_133M),
		.hdr_last_frame (hdr_last_frame),

		.pixel_data (vga_pixel_data),
		.rd_address (vga_rd_address),
		.rd_req (vga_rd_req)
	);

	vga_controller vga_controller(
		.clk_25M (clk_25M),
		.rst_n (rst_n_25M),
		.pixel_data (vga_pixel_data),

		.h_counter (vga_h_counter),
		.vsync (vga_vsync),
		.hsync (vga_hsync),
		.red (vga_red),
		.blue (vga_blue),
		.green (vga_green),

		.start_row (vga_start_row),
		.start_frame (vga_start_frame)
	);

//Instntiating UART Modules

	reg q_take_pic_133M;
	reg take_pic_133M;

	//Double Flopping take_pic to cross it to 133MHz

	always@(posedge clk_133M) begin
		q_take_pic_133M <= take_pic_25M;
		take_pic_133M <= q_take_pic_133M;
	end

	wire [127:0] uart_rd_data;
	wire [24:0] uart_rd_address;
	wire uart_rd_req;
	wire uart_rd_valid;

	uart_controller uart_controller(
		.clk (clk_133M),
		.rst_n (rst_n_133M),
		.rd_data (uart_rd_data),
		.rd_data_valid (uart_rd_valid),
		.start (take_pic_133M),
		.last_frame (last_frame_133M),
		.uart_ack (uart_ack),
		.ram_busy (ram_busy),

		.hdr_en (hdr_en_133M),
		.hdr_last_frame (hdr_last_frame),

		.rd_req (uart_rd_req),
		.rd_address (uart_rd_address),
		.TX (TX),
		.busy_led (TX_led)
	);

//Instantiating Ram Fifo Module
	wire ddr_cmd_busy;
	wire ddr_init_done;
	wire [3:0] ddr_cmd;
	wire ddr_cmd_valid;
	wire [24:0] ddr_sys_address;
	wire [127:0] ddr_wr_data;
	wire [127:0] ddr_rd_data;
	wire ddr_rd_valid;

	request_handler request_handler(
		.clk_133M (clk_133M),
		.rst_n_133M (rst_n_133M),
		.cmd_busy (ddr_cmd_busy),

		.camera_wr_req (camera_wr_req),
		.vga_rd_req (vga_rd_req),
		.hdr_rd_req (hdr_rd_req),
		.hdr_wr_req (hdr_wr_req),
		.uart_rd_req (uart_rd_req),

		.camera_wr_address (camera_wr_address),
		.vga_rd_address (vga_rd_address),
		.hdr_rd_address (hdr_rd_address),
		.hdr_wr_address (hdr_wr_address),
		.uart_rd_address (uart_rd_address),

		.vga_rd_data (vga_rd_data),
		.hdr_rd_data (hdr_rd_data),
		.uart_rd_data (uart_rd_data),

		.vga_rd_valid (vga_rd_valid),
		.hdr_rd_valid (hdr_rd_valid),
		.uart_rd_valid (uart_rd_valid),

		.camera_wr_data (camera_wr_data),
		.hdr_wr_data (hdr_wr_data),

		.camera_ack (camera_ack),
		.vga_ack (vga_ack),
		.hdr_rd_ack (hdr_rd_ack),
		.hdr_wr_ack (hdr_wr_ack),
		.uart_ack (uart_ack),

		.busy (ram_busy),

		.init_done (ddr_init_done),
		.cmd (ddr_cmd),
		.cmd_valid (ddr_cmd_valid),
		.ddr_address (ddr_sys_address),
		.ddr_wr_data (ddr_wr_data),
		.ddr_rd_data (ddr_rd_data),
		.ddr_rd_valid (ddr_rd_valid)
	);

	ddr_memory_controller ddr_memory_controller(
		.clk (clk_133M),
		.rst_n (rst_n_133M),
		.sys_addr (ddr_sys_address),
		.wr_data (ddr_wr_data),
		.cmd (ddr_cmd),
		.cmd_valid (ddr_cmd_valid),
		.sys_200us (sys_200us),

		.rd_data (ddr_rd_data),
		.cmd_busy (ddr_cmd_busy),
		.init_done (ddr_init_done),

		.read_data_valid (ddr_rd_valid),

		.ddr_clk (ddr_clk),
		.ddr_cke (ddr_cke),
		.ddr_cs_n (ddr_cs_n),
		.ddr_ras_n (ddr_ras_n),
		.ddr_cas_n (ddr_cas_n),
		.ddr_we_n (ddr_we_n),
		.ddr_ba (ddr_ba),
		.ddr_addr (ddr_addr),
		.ddr_dq (ddr_dq),
		.ddr_dm (ddr_dm),
		.ddr_dqs (ddr_dqs)
	);

//Instantiating Key Read Module

	key_read key_read(
		.clk (clk_25M),
		.rst_n (rst_n_25M),
		.conf_en (conf_en),
		.row (keypad_row),

		.col (keypad_col),
		.conf_addr (conf_addr),
		.conf_data (conf_data),
		.sccb_start (sccb_start),

		.take_pic (take_pic_25M),
		.hdr_en (hdr_en_25M),

		.seven_seg_right (seven_seg_right),
		.seven_seg_left (seven_seg_left),
		.seven_seg_A (seven_seg_A),
		.seven_seg_B (seven_seg_B),
		.seven_seg_C (seven_seg_C),
		.seven_seg_D (seven_seg_D),
		.seven_seg_E (seven_seg_E),
		.seven_seg_F (seven_seg_F),
		.seven_seg_G (seven_seg_G),
		.seven_seg_DP (seven_seg_DP),
		.state_led (state_led),
		.addr_led (addr_led)
	);

	assign reset_led = ~rst_n;
	assign config_led = ~conf_en;
	assign hdr_led = ~hdr_en_25M;
endmodule
