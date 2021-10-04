module camera_config(
	input clk_25M,
	input rst_n,
	input start,
	input [7:0] conf_addr,
	input [7:0] conf_data,

	output sda,
	output scl,
	output done
);

	// This module is responsible for configuring the camera module.
	// ov7670_config module feeds the sccb interface with the address of the configuration register and the data to be written.
	// On reset, the ov7670_config module reads the address and the data from the ov7670_rom. The camera can be configured manually through a keypad. 


	wire[7:0] rom_address;
	wire[15:0] rom_data;
	wire sccb_ready;
	reg config_start;
	wire sccb_start;
	wire[7:0] sccb_data;
	wire[7:0] sccb_address;


	always@(posedge clk_25M) begin
		if(~rst_n) begin
			config_start <= 1'b1;
		end else begin
			config_start <= start;
		end
	end
	
	
	ov7670_rom ov7670_rom (
		.clk (clk_25M),
		.address (rom_address),
		.dout (rom_data)
	);
	
	ov7670_config ov7670_config(
		.clk_25M (clk_25M),
		.rst_n (rst_n),
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
		.rst_n (rst_n),
		.address (sccb_address),
		.data (sccb_data),
		.sda (sda),
		.scl (scl),
		.ready (sccb_ready)
	);
	
endmodule
