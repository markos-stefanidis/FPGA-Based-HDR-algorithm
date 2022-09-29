`define SYS_DATA_WIDTH 128
`define SYS_ADDR_WIDTH 27
module top_level(
	input clk,
	input rst_n,

	input camera_vsync,
	input camera_href,
	input [7:0] camera_data,
	/*(* clock_buffer_type = "none" *)*/ input pclk,

	input take_pic,
	input hdr_en,
	input [2:0] last_frame_in,
	input pic_in,

	output sda,
	output scl,
	output xclk,
	output camera_rst,
	output camera_pwdn,

	output [3:0] vga_red,
	output [3:0] vga_green,
	output [3:0] vga_blue,
	output vga_vsync,
	output vga_hsync,

	inout [15:0] ddr2_dq,
	inout [1:0]  ddr2_dqs_n,
	inout [1:0]  ddr2_dqs_p,

	output [12:0] ddr2_addr,
	output [2:0]  ddr2_ba,
	output ddr2_ras_n,
	output ddr2_cas_n,
	output ddr2_we_n,
	output [0:0] ddr2_ck_p,
	output [0:0] ddr2_ck_n,
	output [0:0] ddr2_cke,
	output [0:0] ddr2_cs_n,
	output [1:0] ddr2_dm,
	output [0:0] ddr2_odt,

	output [2:0] last_frame_in_led,
	output hdr_led,
	output pic_led,
	output rst_led,
	output TX
);
	wire clk_25M;

	assign camera_rst = rst_n;
	assign camera_pwdn = 1'b0;

	clk_wiz_0 clk_wiz_ref (
		.clk_in1(clk),
		.clk_200M (sys_clk_i),
		.clk_25M (clk_25M),
		.clk_24M (xclk)
	);

	wire ui_clk;
	wire ui_rst;
	wire ui_rst_n;
	assign ui_rst_n = ~ui_rst;

	wire rst_n_25M;

	sync rst_sync_25M(
		.clk (clk_25M),
		.rst_n (rst_n),
		.in (rst_n),

		.out(rst_n_25M)
	);

	wire p_rst_n;

	sync rst_sync_pclk(
		.clk (pclk),
		.rst_n (rst_n),
		.in (rst_n),

		.out(p_rst_n)
	);

	wire p_take_pic;

	sync take_pic_sync_pclk(
		.clk (pclk),
		.rst_n (rst_n),
		.in (take_pic),

		.out (p_take_pic)
	);

	wire take_pic_25M;

	sync take_pic_sync_25M(
		.clk (clk_25M),
		.rst_n (rst_n),
		.in (take_pic),

		.out (take_pic_25M)
	);

	wire ui_take_pic;

	sync take_pic_sync_uiclk(
		.clk (ui_clk),
		.rst_n (rst_n),
		.in (take_pic),

		.out (ui_take_pic)
	);

	wire p_hdr_en;

	sync hdr_en_sync_pclk(
		.clk (pclk),
		.rst_n (rst_n),
		.in (hdr_en),

		.out (p_hdr_en)
	);

	wire hdr_en_25M;

	sync hdr_en_sync_25M(
		.clk (clk_25M),
		.rst_n (rst_n),
		.in (hdr_en),

		.out (hdr_en_25M)
	);

	wire ui_hdr_en;

	sync hdr_en_sync_ui(
		.clk (ui_clk),
		.rst_n (rst_n),
		.in (hdr_en),

		.out (ui_hdr_en)
	);

	wire[2:0] last_frame_24M;
	wire frame_done_24M;
	wire [127:0] camera_p_data;
	wire camera_data_valid;
	wire change_exp;

	camera_capture camera_capture(
		.p_clk (pclk),
		.rst_n (p_rst_n),
		.data (camera_data),
		.href (camera_href),
		.vsync (camera_vsync),
		.take_pic (p_take_pic),
		.hdr_en (p_hdr_en),

		.last_frame (last_frame_24M),
		.frame_done (frame_done_24M),
		.p_data (camera_p_data),
		.data_valid (camera_data_valid),
		.change_exp (change_exp)
	);



	reg q_ui_frame_done;
	reg qq_ui_frame_done;
	reg qqq_ui_frame_done;

	always@(posedge ui_clk, negedge rst_n) begin
		if(~rst_n) begin
			q_ui_frame_done <= 1'b0;
			qq_ui_frame_done <= 1'b0;
			qqq_ui_frame_done <= 1'b0;
		end else begin
			q_ui_frame_done <= frame_done_24M;
			qq_ui_frame_done <= q_ui_frame_done;
			qqq_ui_frame_done <= qq_ui_frame_done;
		end
	end

	wire ui_frame_done;
	assign ui_frame_done = (qq_ui_frame_done && ~qqq_ui_frame_done);

	reg q_frame_done_25M;
	reg qq_frame_done_25M;
	reg qqq_frame_done_25M;

	always@(posedge clk_25M, negedge rst_n) begin
		if(~rst_n) begin
			q_frame_done_25M <= 1'b0;
			qq_frame_done_25M <= 1'b0;
			qqq_frame_done_25M <= 1'b0;
		end else begin
			q_frame_done_25M <= frame_done_24M;
			qq_frame_done_25M <= q_frame_done_25M;
			qqq_frame_done_25M <= qq_frame_done_25M;
		end
	end

	wire frame_done_25M;
	assign frame_done_25M = (qq_frame_done_25M && ~qqq_frame_done_25M);

	wire [2:0] ui_last_frame;

	sync #(.DATA_WIDTH(3)) last_frame_sync_ui(
		.clk (ui_clk),
		.rst_n (rst_n),
		.in (last_frame_24M),

		.out (ui_last_frame)
	);

	wire [2:0] last_frame_25M;

	sync #(.DATA_WIDTH(3)) last_frame_sync_25M(
		.clk (clk_25M),
		.rst_n (rst_n),
		.in (last_frame_24M),

		.out (last_frame_25M)
	);

	wire change_exp_25M;

	sync change_exp_sync_25M(
		.clk (clk_25M),
		.rst_n (rst_n),
		.in (p_change_exp),

		.out (change_exp_25M)
	);



	wire [127:0] camera_wr_data;
	wire [`SYS_ADDR_WIDTH - 1 : 0] camera_wr_address;
	wire camera_wr_req;
	wire init_calib_complete;
	wire camera_ack;



	camera_store camera_store(
		.ui_clk (ui_clk),
		.p_clk (pclk),
		.rst_n_24M (p_rst_n),
		.ui_rst_n (ui_rst_n),
		.frame_done (ui_frame_done),
		.last_frame (ui_last_frame),
		.init_calib_complete (init_calib_complete),

		.p_data (camera_p_data),
		.data_valid (camera_data_valid),
		.camera_ack (camera_ack),

		.data (camera_wr_data),
		.wr_address (camera_wr_address),
		.wr_req (camera_wr_req)
	);

//	reg [1:0] p_counter;
//
//	always@(posedge ui_clk) begin
//		if(~ui_rst_n) begin
//			p_counter <= 2'b0;
//		end else begin
//			if(camera_wr_req) begin
//				p_counter <= p_counter + 1;
//			end
//			if(p_counter < 2) begin
//				camera_wr_data <= 128'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
//			end else begin
//				camera_wr_data <= 128'h00000000000000000000000000000000;
//			end
//		end
//	end



	camera_config camera_config(
		.clk_25M(clk_25M),
		.rst_n_25M (rst_n_25M),
		.start (1'b0),
		.i_conf_data (8'b0),
		.i_conf_addr (8'b0),
		.change_exp (change_exp),
		.hdr_en (hdr_en_25M),
		.last_frame(last_frame_25M),
		.frame_done (frame_done_25M),

		.sda (sda),
		.scl (scl),
		.done ()
	);

	wire [9:0] vga_h_counter;
	wire vga_start_frame;
	wire vga_start_row;
	wire vga_rd_valid;
	wire [127:0] vga_rd_data;
	wire vga_ack;
	wire [15:0] vga_pixel_data;
	wire [`SYS_ADDR_WIDTH - 1 : 0]vga_rd_address;
	wire vga_rd_req;

	//assign vga_rd_data = 128'h001F001F001F001F001F001F001F001F;
	//

	wire hdr_last_frame;

	wire [2:0] ui_last_frame_in;

	sync#(.DATA_WIDTH(3)) last_frame_in_sync_ui(
		.clk (ui_clk),
		.rst_n (rst_n),
		.in (last_frame_in),

		.out (ui_last_frame_in)
	);

	wire ui_pic_in;

	sync#(.DATA_WIDTH(2)) pic_in_sync_ui(
		.clk (ui_clk),
		.rst_n (rst_n),
		.in (pic_in),

		.out (ui_pic_in)
	);

	row_buffer_vga row_buffer_vga(
		.clk (ui_clk),
		.clk_25M (clk_25M),
		.rst_n_25M (rst_n_25M),
		.ui_rst_n (ui_rst_n),

		.vga_h_counter (vga_h_counter),
		.rd_valid (vga_rd_valid),
		.rd_data (vga_rd_data),

		.start_frame (vga_start_frame),
		.start_row (vga_start_row),

		.last_frame_in (ui_last_frame_in),
		.pic_in (ui_pic_in),

		.last_frame (ui_last_frame),
		.vga_ack (vga_ack),

		.hdr_en (ui_hdr_en),
		.hdr_last_frame (hdr_last_frame),

		.pixel_data (vga_pixel_data),
		.rd_address (vga_rd_address),
		.rd_req (vga_rd_req)
	);

	vga_controller vga_controller(
		.clk_25M (clk_25M),
		.rst_n_25M (rst_n_25M),
		.pixel_data (vga_pixel_data),

		.h_counter (vga_h_counter),
		.vsync (vga_vsync),
		.hsync (vga_hsync),
		.red (vga_red),
		.green (vga_green),
		.blue (vga_blue),

		.start_frame (vga_start_frame),
		.start_row (vga_start_row)
	);

	wire [26:0] app_addr;
	wire [2:0] app_cmd ;
	wire app_en;
	wire app_rdy;
	wire [127:0] app_rd_data;
	wire [127:0] app_wdf_data;
	wire app_wdf_end;
	wire app_wdf_wren;
	wire app_wdf_rdy;
	wire [15:0] app_wdf_mask;
	wire app_rd_data_end;
	wire app_rd_data_valid;

	wire [127:0] hdr_rd_data;
	wire [26:0] hdr_rd_address;
	wire [127:0] hdr_wr_data;
	wire [26:0] hdr_wr_address;
	wire hdr_rd_valid;
	wire hdr_rd_req;
	wire hdr_wr_req;
	wire hdr_rd_ack;
	wire hdr_wr_ack;


	image_generator image_generator(
		.clk_133M(ui_clk),
		.clk_25M (clk_25M),
		.rst_n_133M (ui_rst_n),
		.rst_n_25M (rst_n_25M),
		.hdr_en (ui_hdr_en),

		.last_frame (ui_last_frame),
		.frame_done_133M (ui_frame_done),
		.frame_done_25M (frame_done_25M),
		.rd_data (hdr_rd_data),
		.rd_valid (hdr_rd_valid),

		.hdr_rd_ack (hdr_rd_ack),
		.hdr_wr_ack (hdr_wr_ack),

		.camera_data (camera_wr_data),
		.camera_wr_req (camera_wr_req),

		.rd_req (hdr_rd_req),
		.wr_req (hdr_wr_req),
		.rd_address (hdr_rd_address),
		.wr_address (hdr_wr_address),
		.hdr_last_frame (hdr_last_frame),
		.wr_data (hdr_wr_data)
	);

	wire uart_rd_req;
	wire uart_ack;
	wire uart_rd_valid;
	wire [127:0] uart_rd_data;
	wire [26:0] uart_rd_address;


	request_handler request_handler(
		.clk (ui_clk),
		.ui_rst_n (ui_rst_n),
		.addr_fix (ui_addr_fix),
		.addr_fix_hdr (ui_addr_fix_hdr),

		.camera_wr_req (camera_wr_req),
		.hdr_wr_req (hdr_wr_req),
		.vga_rd_req (vga_rd_req),
		.hdr_rd_req (hdr_rd_req),
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

		.app_addr (app_addr),
		.app_cmd (app_cmd),
		.app_en (app_en),
		.app_rdy (app_rdy),
		.app_hi_pri (app_hi_pri),
		.app_rd_data (app_rd_data),
		.app_rd_data_end (app_rd_data_end),
		.app_rd_data_valid (app_rd_data_valid),
		.app_wdf_data (app_wdf_data),
		.app_wdf_end (app_wdf_end),
		.app_wdf_mask (app_wdf_mask),
		.app_wdf_rdy (app_wdf_rdy),
		.app_wdf_wren (app_wdf_wren),
		.init_calib_complete (init_calib_complete)
	);

	uart_controller uart_controller(
		.clk (ui_clk),
		.rst_n (ui_rst_n),
		.rd_data (uart_rd_data),
		.rd_data_valid (uart_rd_valid),
		.start (ui_take_pic),
		.last_frame (ui_last_frame),
		.uart_ack (uart_ack),
		.hdr_en (ui_hdr_en),
		.hdr_last_frame (hdr_last_frame),

		.rd_req (uart_rd_req),
		.rd_address (uart_rd_address),
		.TX (TX),
		.busy_led ()
	);


	mig_7series_0 mem (
		.ddr2_addr   (ddr2_addr),
		.ddr2_ba     (ddr2_ba),
		.ddr2_cas_n  (ddr2_cas_n),
		.ddr2_ck_n   (ddr2_ck_n),
		.ddr2_ck_p   (ddr2_ck_p),
		.ddr2_cke    (ddr2_cke),
		.ddr2_ras_n  (ddr2_ras_n),
		.ddr2_we_n   (ddr2_we_n),
		.ddr2_dq     (ddr2_dq),
		.ddr2_dqs_n  (ddr2_dqs_n),
		.ddr2_dqs_p  (ddr2_dqs_p),
		.ddr2_cs_n   (ddr2_cs_n),
		.ddr2_dm     (ddr2_dm),
		.ddr2_odt    (ddr2_odt),

		.init_calib_complete (init_calib_complete),

		.app_addr    (app_addr),
		.app_cmd     (app_cmd),
		.app_en      (app_en),
		.app_wdf_data(app_wdf_data),
		.app_wdf_mask(app_wdf_mask),
		.app_wdf_end (app_wdf_end),
		.app_wdf_wren(app_wdf_wren),
		.app_rd_data (app_rd_data),
		.app_rd_data_end (app_rd_data_end),
		.app_rd_data_valid (app_rd_data_valid),
		.app_rdy     (app_rdy),
		.app_wdf_rdy (app_wdf_rdy),
		.app_sr_req  (1'b0),
		.app_ref_req (1'b0),
		.app_zq_req  (1'b0),
		.app_sr_active(),
		.app_ref_ack (),
		.app_zq_ack  (),
		.ui_clk(ui_clk),
		.ui_clk_sync_rst (ui_rst),

		.sys_clk_i (sys_clk_i),
		.sys_rst (rst_n)
	);

	assign last_frame_in_led = last_frame_in;
	assign hdr_led = hdr_en;
	assign pic_led = take_pic;
	assign rst_led = rst_n;
endmodule
