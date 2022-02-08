module top_level(
	input clk,
	input rst_n,
	input camera_vsync,
	input camera_href,
	input[7:0] camera_data,
	input p_clk,
	input conf_en,
	input [3:0] keypad_row,


	output[1:0] red,
	output[1:0] green,
	output[1:0] blue,
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


// Generating the clock frequencies needed. Input clock (clk) is at 25MHz.

	wire clk_25M;
	wire clk_100M;
	wire clk_133M;


	pll_100M pll_100M(      // A 100MHz clock frequency is needed as the PLLs cannot generate 24MHz and 133MHz clock frequencies from 25Mhz.
		.CLK (clk),
		.CLKOP (clk_100M),
		.CLKOS (clk_25M),
		.LOCK ()
	);

	pll_24M pll_24M(      // Generating 24MHz clock for the camera module.
		.CLK (clk_100M),
		.CLKOP (xclk),
		.LOCK ()
	);

	pll_133M ddr_clk_pll(  //Generating 133MHz clock for the DDR Memory
		.CLK (clk_100M),
		.CLKOP (clk_133M),
		.CLKOS (),
		.LOCK ()
	);



// Double floping rst_n to create synchronous reset for each clock domain.
	reg q_rst_n_25M;
	reg q_rst_n_100M;
	reg q_rst_n_133M;

	reg qq_rst_n_25M;
	reg qq_rst_n_100M;
	reg qq_rst_n_133M;


	wire rst_n_25M;
	wire rst_n_100M;
	wire rst_n_133M;




	always@(posedge clk_25M or negedge rst_n) begin
		if(~rst_n) begin
			q_rst_n_25M <= 1'b0;
			qq_rst_n_25M <= 1'b0;
		end else begin
			q_rst_n_25M <= 1'b1;
			qq_rst_n_25M <= q_rst_n_25M;
		end
	end


	always@(posedge clk_133M or negedge rst_n) begin
		if(~rst_n) begin
			q_rst_n_133M <= 1'b0;
			qq_rst_n_133M <= 1'b0;
		end else begin
			q_rst_n_133M <= 1'b1;
			qq_rst_n_133M <= q_rst_n_133M;
		end
	end

	assign rst_n_25M = qq_rst_n_25M;
	assign rst_n_133M = qq_rst_n_133M;

	reg q_rst_n_24M;
	reg qq_rst_n_24M;

	always@(posedge xclk or negedge rst_n) begin
		if(~rst_n) begin
			q_rst_n_24M <= 1'b0;
			qq_rst_n_24M <= 1'b0;
		end else begin
			q_rst_n_24M <= 1'b1;
			qq_rst_n_24M <= q_rst_n_24M;
		end
	end

	wire rst_n_24M;

	assign rst_n_24M = qq_rst_n_24M;
	assign camera_rst_n = rst_n_24M;




	reg sys_200us; // Used to indicate to the DDR memory controller when 200us have passed
	reg [12:0] counter_200us;

	always@(posedge clk_25M) begin
		if(~rst_n_25M) begin
			counter_200us <= 13'b0;
		end else begin
			counter_200us <= (counter_200us < 13'h1388) ? (counter_200us + 1) : counter_200us;
			sys_200us <= (counter_200us == 13'h1388);
		end
	end


// Instantiating the rest of the modules


	wire [127:0] camera_p_data;
	wire [24:0] camera_p_address;
	wire camera_data_valid;
	wire [2:0] camera_last_frame;
	wire camera_frame_done;
	wire take_pic;
	wire hdr_en;
	wire change_exp_24M;
	reg [2:0] q_last_frame_133M;
	reg [2:0] last_frame_133M;

	reg hdr_en_24M;

	reg q_hdr_en_25M;
	reg hdr_en_25M;
	reg q_hdr_en_133M;
	reg hdr_en_133M;

	camera_capture camera_capture(
		.p_clk (p_clk),
		.rst_n (rst_n_24M),
		.data (camera_data),
		.href (camera_href),
		.vsync (camera_vsync),
		.take_pic (take_pic),
		.hdr_en (hdr_en_25M),

		.last_frame (camera_last_frame),
		.frame_done (camera_frame_done),
		.p_data (camera_p_data),
		.data_valid (camera_data_valid),
		.change_exp (change_exp_24M)
	);


	reg q_frame_done_133M;
	reg qq_frame_done_133M;
	reg qqq_frame_done_133M;
	wire frame_done_133M;
	reg q_frame_done_25M;
	reg qq_frame_done_25M;
	reg qqq_frame_done_25M;
	wire frame_done_25M;
	wire ram_busy;
	wire [127:0] camera_wr_data;
	wire [24:0] camera_wr_address;

	camera_store camera_store(
		.clk_133M (clk_133M),
		.p_clk (p_clk),
		.rst_n_133M (rst_n_133M),
		.rst_n_24M (rst_n_24M),
		.frame_done (frame_done_133M),
		.last_frame (last_frame_133M),

		.p_data (camera_p_data),
		.data_valid (camera_data_valid),
		.ram_busy (ram_busy),

		.data (camera_wr_data),
		.wr_address (camera_wr_address),
		.wr_req (camera_wr_req)
	);


	always@(posedge clk_133M) begin
	     q_last_frame_133M <= camera_last_frame;
	     last_frame_133M <= q_last_frame_133M;

	     q_frame_done_133M <= camera_frame_done;
	     qq_frame_done_133M <= q_frame_done_133M;
	     qqq_frame_done_133M <= qq_frame_done_133M;

	     q_hdr_en_133M <= hdr_en_24M;
	     hdr_en_133M <= q_hdr_en_133M;
	end

	always@(posedge clk_25M) begin
		q_frame_done_25M <= camera_frame_done;
		qq_frame_done_25M <= q_frame_done_25M;
		qqq_frame_done_25M <= qq_frame_done_25M;

		q_hdr_en_25M <= hdr_en_24M;
		hdr_en_25M <= q_hdr_en_25M;
	end

	always@(posedge xclk) begin
		if(~rst_n_24M) begin
			hdr_en_24M <= 1'b0;
		end else begin
			if(hdr_en && camera_frame_done) begin
				hdr_en_24M <= 1'b1;
			end else if (~hdr_en && camera_frame_done) begin
				hdr_en_24M <= 1'b0;
			end
		end
	end

	assign frame_done_133M = (~qq_frame_done_133M && qqq_frame_done_133M);
	assign frame_done_25M = (~qq_frame_done_25M && qqq_frame_done_25M);


	wire camera_config_done;
	wire [7:0] conf_addr;
	wire [7:0] conf_data;
	reg q_change_exp;
	reg change_exp_25M;

	always@(posedge clk_25M) begin
		q_change_exp <= change_exp_24M;
		change_exp_25M <= q_change_exp;
	end

	camera_config camera_config(
		.clk_25M (clk_25M),
		.rst_n (rst_n_25M),
		.start (sccb_start),
		.i_conf_addr (conf_addr),
		.i_conf_data (conf_data),
		.change_exp (change_exp_25M),
		.hdr_en (hdr_en),
		.last_frame (camera_last_frame),

		.sda (sda),
		.scl (scl),
		.done (camera_config_done)
	);


	wire cmd_busy;
	wire cmd_valid;
	wire vga_read_req;
	wire ddr_data_valid;
	wire [24:0] vga_read_address;
	wire [127:0] ddr_rd_data;
	wire ddr_init_done;
	wire [3:0] cmd;
	wire [24:0] sys_addr;
	wire [127:0] vga_read_data;
	wire [127:0] ddr_wr_data;
	wire vga_data_valid;



	wire [9:0] vga_h_counter;
	wire vga_start_row;
	wire vga_start_frame;
	wire [15:0] pixel_data;
	wire hdr_last_frame;

	vga_controller vga_controller(
		.clk_25M (clk_25M),
		.rst_n (rst_n_25M),
		.pixel_data (pixel_data),

		.h_counter (vga_h_counter),
		.vsync (vga_vsync),
		.hsync (vga_hsync),
		.red (red),
		.green (green),
		.blue (blue),

		.start_row (vga_start_row),
		.start_frame (vga_start_frame)
	);


	row_buffer_vga row_buffer_vga(
		.clk_25M (clk_25M),
		.rst_n_25M (rst_n_25M),
		.clk_133M (clk_133M),
		.rst_n_133M (rst_n_133M),

		.vga_h_counter (vga_h_counter),
		.rd_valid (vga_data_valid),
		.rd_data (vga_read_data),

		.start_frame (vga_start_frame),
		.start_row (vga_start_row),

		.last_frame (last_frame_133M),
		.ram_busy (ram_busy),

		.hdr_en (hdr_en_133M),
		.hdr_last_frame (hdr_last_frame),

		.pixel_data (pixel_data),
		.rd_address (vga_read_address),
		.rd_req (vga_read_req)
	);

	reg q_take_pic;
	reg take_pic_133M;

	wire [127:0] uart_rd_data;
	wire uart_data_valid;
	wire uart_rd_req;
	wire [24:0] uart_rd_address;
	wire [127:0] hdr_rd_data;
	wire hdr_rd_valid;
	wire hdr_rd_req;
	wire [24:0] hdr_rd_address;
	wire hdr_wr_req;
	wire [24:0] hdr_wr_address;
	wire [127:0] hdr_wr_data;

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

	uart_controller uart_controller(
		.clk (clk_133M),
		.rst_n (rst_n_133M),
		.rd_data (uart_rd_data),
		.rd_data_valid (uart_data_valid),
		.start (take_pic_133M),
		.last_frame (last_frame_133M),
		.ram_busy (ram_busy),

		.hdr_en (hdr_en_133M),
		.hdr_last_frame (hdr_last_frame),

		.rd_req (uart_rd_req),
		.rd_address (uart_rd_address),
		.TX (TX),
		.busy_led (TX_led)
	);


	ram_fifo ram_fifo(
		.clk_133M (clk_133M),
		.rst_n_133M (rst_n_133M),
		.cmd_busy (cmd_busy),

		.camera_wr_req (camera_wr_req),
		.vga_read_req (vga_read_req),
		.ddr_data_valid (ddr_data_valid),
		.hdr_rd_req (hdr_rd_req),
		.hdr_wr_req (hdr_wr_req),

		.camera_wr_address (camera_wr_address),
		.vga_read_address (vga_read_address),
		.camera_wr_data (camera_wr_data),
		.ddr_rd_data (ddr_rd_data),

		.hdr_rd_address (hdr_rd_address),
		.hdr_wr_address (hdr_wr_address),
		.hdr_wr_data (hdr_wr_data),

		.uart_rd_address (uart_rd_address),
		.uart_rd_req (uart_rd_req),

		.init_done (ddr_init_done),

		.busy (ram_busy),
		.cmd (cmd),
		.cmd_valid (cmd_valid),

		.ddr_address (sys_addr),
		.ddr_wr_data (ddr_wr_data),

		.hdr_rd_data (hdr_rd_data),
		.hdr_rd_valid (hdr_rd_valid),

		.uart_rd_data (uart_rd_data),
		.uart_data_valid (uart_data_valid),

		.uart_led (),

		.vga_read_data (vga_read_data),
		.vga_data_valid (vga_data_valid)
	);





	ddr_memory_controller ddr_memory_controller(
		.clk (clk_133M),
		.rst_n (rst_n_133M),
		.sys_addr (sys_addr),
		.wr_data (ddr_wr_data),
		.cmd (cmd),
		.cmd_valid (cmd_valid),
		.sys_200us (sys_200us),

		.rd_data (ddr_rd_data),
		.cmd_busy (cmd_busy),
		.init_done (ddr_init_done),

		.read_data_valid (ddr_data_valid),

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

	always@(posedge clk_133M) begin
		if(~rst_n) begin
			q_take_pic <= 1'b0;
			take_pic_133M <= 1'b0;
		end else begin
			q_take_pic <= take_pic;
			take_pic_133M <= q_take_pic;
		end
	end

	key_read key_read(
		.clk (clk_25M),
		.rst_n (rst_n_25M),
		.conf_en (conf_en),
		.row (keypad_row),

		.col (keypad_col),
		.conf_addr (conf_addr),
		.conf_data (conf_data),
		.sccb_start (sccb_start),

		.take_pic (take_pic),
		.hdr_en (hdr_en),

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
	assign hdr_led = ~hdr_en;

endmodule
