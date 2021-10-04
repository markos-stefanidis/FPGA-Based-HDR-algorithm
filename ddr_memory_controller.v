module ddr_memory_controller(
	input clk,
	input rst_n,
	input [24:0] sys_addr,
	input [127:0] wr_data,
	input [3:0] cmd,
	input cmd_valid,
	input sys_200us,
	
	output [127:0] rd_data,
	output cmd_busy,
	output init_done,
	
	output read_data_valid,
	output [1:0] ddr_clk,
	output [1:0] ddr_cke,
	output [1:0] ddr_cs_n,
	output ddr_ras_n,
	output ddr_cas_n,
	output ddr_we_n,
	output [1:0] ddr_ba,
	output [12:0] ddr_addr,
	inout [31:0] ddr_dq,
	output [3:0] ddr_dm,
	inout [3:0] ddr_dqs
);
	
	// This DDR Controller is designed to work for a 32bit memory with burst_term = 4 and CAS latency = 2. 
	// You could change the burst term and CAS latence through a LMR command but it would not work, as the wr_data and the rd_data are fixed to 128bit and CAS latency to 2.
	
	
	
	wire [3:0] c_state;
	wire [3:0] i_state;
	reg [127:0] data_out;
	wire read;
	reg init_start;
	reg data_valid;
	reg [127:0] reg_data_in;
	
	wire burst_counter;

	
	
	wire write;
	
	
	
	
	always @ (posedge clk) begin
		if(~rst_n) begin
			reg_data_in <= 128'b0;
			init_start <= 1'b1;
		end else begin
			reg_data_in <= ((cmd == 4'b0010 || cmd == 4'b0100) && cmd_valid) ? wr_data : reg_data_in;
			init_start <= ~sys_200us;
		end
	end
	
	ram_initialize init(   // Module responsible for the initialization of DDR memory. The memory is initialized at reset.
		.clk (clk),
		.rst_n (rst_n),
		.init_start (init_start),
		.sys_200us (sys_200us),
		.init_done (init_done),
		.STATE (i_state),
		.cke (cke)
	);
	
	cmd_fsm cmd_fsm(      // Module responsible for decoding DDR commands.
		.clk (clk),
		.rst_n (rst_n),
		.cmd (cmd),
		.cmd_valid (cmd_valid),
		.init_done (init_done),
		.STATE (c_state),
		.busy (cmd_busy),
		.read (read),
		.write (write),
		.burst_counter (burst_counter)
	);
	
	signal_generate signal(  // This module generates the command and address signals for the DDR memory.
		.clk (clk),
		.rst_n (rst_n),
		.i_state (i_state),
		.init_done (init_done),
		.cke (cke),
		.c_state (c_state),
		.sys_addr (sys_addr),
		.ddr_cs_n (ddr_cs_n),
		.ddr_cke (ddr_cke),
		.ddr_ras_n (ddr_ras_n),
		.ddr_cas_n (ddr_cas_n),
		.ddr_we_n (ddr_we_n),
		.ddr_addr (ddr_addr),
		.ddr_ba (ddr_ba)
	);


	reg uddcntl; // When low for 2 cycles, the delay of the DQSDLL is updated. As the Lattice High-Speed I/O Interface guide states, it should be asserted at the begining of READ commands.
				 // https://www.latticesemi.com/view_document?document_id=21646
	reg [1:0] uddcntl_counter;
	
	
	reg [31:0] dataout_n; // dataout_n is the data to be written on the negative of the clock
	reg [31:0] dataout_p; // dataout_p is the data to be written on the possitive of the clock
	wire [31:0] data_tri_n; //data_tri_n and data_tri_p need to be asserted high for the datapath to know that dq pins is acting as an output
	wire [31:0] data_tri_p;
	
	reg dqs_en_n;
	
	
	
	always@(posedge clk) begin
		if(~rst_n) begin
			uddcntl <= 1'b1;
			uddcntl_counter <= 2'b0;
		end else begin
			if(read) begin
				uddcntl <= (uddcntl_counter != 2'b01) ? 1'b0 : 1'b1;
				uddcntl_counter <= (uddcntl_counter != 2'b01) ? uddcntl_counter + 1 : 2'b01;
			end
		end		
	end


	reg write_counter;

	always@(posedge clk) begin
		if(~rst_n) begin
			dataout_n <= 32'b0;
			dataout_p <= 32'b0;
			
			dqs_en_n <= 1'b1;
			
			write_counter <= 1'b1;
			
		end else begin
			if(write) begin  //WR_DATA
				
				dqs_en_n <= 1'b0;
				
				
				case(write_counter)
					
					1'b1: begin
						{dataout_p, dataout_n}  <= reg_data_in[127:64];
						write_counter <= write_counter - 1;
					end
					
					1'b0: begin
						{dataout_p, dataout_n}  <= reg_data_in[63:0];
						write_counter <= write_counter - 1;
					end
					
				endcase
			end else begin
				dqs_en_n <= 1'b1;			
			end
			
		end		
	end
	
	assign data_tri_n = (dqs_en_n) ? 32'hFFFFFFFF : 32'h0;
	assign data_tri_p = (dqs_en_n) ? 32'hFFFFFFFF : 32'h0;
	
	wire start_read;
	wire [3:0] datapath_valid;
	reg [3:0] q_datapath_valid;
	wire [3:0] dqs_tri_n;
	wire [3:0] dqs_tri_p;
	
	assign dqs_tri_p = {dqs_en_n, dqs_en_n, dqs_en_n, dqs_en_n}; //same with data_tri signals, dqs_tri signals need to be asserted to high when the dqs pins act as an output
	assign dqs_tri_n = {dqs_en_n, dqs_en_n, dqs_en_n, dqs_en_n};
	
	wire [31:0] datain_n; //datain_n is the data read at the negative edge of the clock
	wire [31:0] datain_p; //datain_p is the data read at the possitive edge of the clock
	
	reg read_counter;

	
	always@(posedge clk) begin
		if(~rst_n) begin
			q_datapath_valid <= 1'b0;
			data_out <= 128'b0;
			data_valid <= 1'b0;
			read_counter <= 1'b1;
		end else begin
			
			q_datapath_valid <= datapath_valid;
			
					
			if(start_read) begin
				read_counter <= 1'b0;
				data_valid <= 1'b0;
				data_out[127:96] <= datain_p;
				data_out[95:64] <= datain_n;
			end else begin
							
				if (read_counter != 1'b1) begin
					read_counter <= read_counter - 1;
				end
				
				
				case(read_counter)
				
					1'b0: begin
						data_out[63:32] <= datain_p;
						data_out[31:0] <= datain_n;
						data_valid <= 1'b1;
					end
					
					default: data_valid <= 1'b0;
					
				endcase
			end

		end
	end
	
	assign start_read = ((&datapath_valid)^(&q_datapath_valid)) && (&datapath_valid); //datapath_valid will go high when data read are valid, but will not go low until another read command is executed
	assign rd_data = data_out;
	assign read_data_valid = data_valid;
	
	wire reset;
	assign reset = ~rst_n;
	
	wire [3:0] datapath_read;
	
	assign datapath_read = {read, read, read, read};
	

	
	ddr_mem datapath(     //This module is generated by ipExpress in Lattice Diamond and contains the ddr buffers and DLLs needed to read/write from memory
		.clk (clk),
		.reset (reset),
		.uddcntl (uddcntl),
		.read (datapath_read),
		
		.dataout_p (dataout_p),
		.dataout_n (dataout_n),
		.datatri_p (data_tri_p),
		.datatri_n (data_tri_n),
		.dqstri_p (dqs_tri_p),
		.dqstri_n (dqs_tri_n),
		
		.datain_p (datain_p),
		.datain_n (datain_n),
		.dqsc (),
		.prmbdet (),
		.lock (),
		
		.datavalid (datapath_valid),
		.dq (ddr_dq),
		.dqs (ddr_dqs),
		.ddrclk (ddr_clk)
	);
	
	assign ddr_dm = 4'b0;


endmodule