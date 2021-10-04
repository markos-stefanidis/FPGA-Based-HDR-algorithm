module data_path(
	input clk,
	input clk_90,
	input clk_180,
	input clk_270,
	input clkx2,
	input rst_n,
	input cmd_valid,
	input [3:0] cmd,
	input [3:0] c_state,
	
	input [127:0] data_in,
	input [1:0] dm_in,
	
	output reg [15:0] dq_out,
	//output [1:0] dqs_out,
	output reg [1:0] dm_out,
	
	input [1:0] dqs_in,
	inout [15:0] dq,
	inout [1:0] dqs,
	
	
	output reg rd_en,
	output [127:0] data_out,
	output data_valid,
	output reg [2:0] STATE
);
	
	reg [127:0] reg_data;
	reg [15:0] data_in_reg_l;
	reg [2:0] select_byte;
	reg [15:0] dq_out_reg;
	reg dqs_en;
	reg q_dqs_en;
	reg [7:0] rd_byte_1_reg;
	reg [7:0] rd_byte_2_reg;
	reg [7:0] rd_byte_3_reg;
	reg [7:0] rd_byte_4_reg;
	reg [3:0] rd_timer;
	reg [15:0] data_out_1h;
	reg [15:0] data_out_1l;
	reg [15:0] data_out_2h;
	reg [15:0] data_out_2l;
	reg [15:0] data_out_3h;
	reg [15:0] data_out_3l;
	reg [15:0] data_out_4h;
	reg [15:0] data_out_4l;
	
	
	localparam IDLE = 0;
	localparam READ_1 = 1;
	localparam READ_2 = 2;
	localparam WRITE_1 = 3;
	localparam WRITE_2 = 4;

	//cmd states
	localparam ACT = 1;
	localparam READ = 2;
	localparam READ_PRE = 4;
	localparam WR_DATA = 7;
	localparam WRITE = 3;
	localparam WRITE_PRE = 5;
	localparam RD_DATA = 6;
	
	
	
	always@(posedge clk) begin
		if(~rst_n) begin
			//dq_out <= 16'hZZZZ;
			//dqs_out <= 2'b0;
			dm_out <= 2'b0;
			
			//data_out <= 32'b0;
			//data_valid <= 1'b0;
			STATE <= IDLE;
			
			//dq_out_reg <= 16'b0;
			reg_data <= 32'b0;
			data_in_reg_l <= 16'b0;
			//select_byte <= 1'b0;
			
			rd_en <= 1'b0;
			rd_timer <= 4'b0;
			
			dqs_en <= 1'b0;
			q_dqs_en <= 1'b0;
			
			
			
		end else begin
		
			q_dqs_en <= dqs_en;
			
			case(STATE)
				
				IDLE: begin
					rd_timer <= 4'b0;
					//data_valid <= 1'b0;
					reg_data <= ((cmd == 4'b0010 || cmd == 4'b0100) && cmd_valid) ? data_in : reg_data;
					STATE <= ((cmd == 4'b0010 || cmd == 4'b0100) && cmd_valid) ? WRITE_1 :
							 (c_state == READ || c_state == READ_PRE) ? READ_1 : IDLE;
					dqs_en <= (c_state == WRITE || c_state == WRITE_PRE || c_state == WR_DATA) ? 1'b1 : 1'b0;
				end
				
				WRITE_1: begin
					//data_in_reg_l <= reg_data[31:16];
					STATE <= (c_state != 4'b0111) ? WRITE_2 : WRITE_1;
					//select_byte <= 1'b0;
				end
				
				WRITE_2: begin
					STATE <= IDLE;
				end
				
				READ_1: begin
					rd_en <= (rd_timer == 4'b1000) ? 1'b0 : 1'b1;
					rd_timer <= rd_timer + 1;
					STATE <= (rd_timer == 4'b1000) ? READ_2 : READ_1;
				end
				
				READ_2: begin
					STATE <= IDLE;
					//data_valid <= 1'b1;
				end
				
				
			endcase
		
		end
	
	end
	
	always@(posedge dqs_in[0]) begin
		if(rd_en) begin
			rd_byte_1_reg <= dq[15:8];
		end
	end
	
	always@(posedge dqs_in[1]) begin
		if(rd_en) begin
			rd_byte_2_reg <= dq[7:0];
		end
	end
	
	
	always@(negedge dqs_in[0]) begin
		if(rd_en) begin
			rd_byte_3_reg <= dq[15:8];
		end
	end
	
	always@(negedge dqs_in[1]) begin
		if(rd_en) begin
			rd_byte_4_reg <= dq[7:0];
		end
	end
	
	always@(posedge clk) begin
		data_out_1h <= (rd_timer == 4'b0010) ? {rd_byte_1_reg, rd_byte_2_reg} : data_out_1h;
		data_out_2h <= (rd_timer == 4'b0011) ? {rd_byte_1_reg, rd_byte_2_reg} : data_out_2h;
		data_out_3h <= (rd_timer == 4'b0100) ? {rd_byte_1_reg, rd_byte_2_reg} : data_out_3h;
		data_out_4h <= (rd_timer == 4'b0101) ? {rd_byte_1_reg, rd_byte_2_reg} : data_out_4h;
	end
	
	always@(negedge clk) begin
		data_out_1l <= (rd_timer == 4'b0011) ? {rd_byte_3_reg, rd_byte_4_reg} : data_out_1l;
		data_out_2l <= (rd_timer == 4'b0100) ? {rd_byte_3_reg, rd_byte_4_reg} : data_out_2l;
		data_out_3l <= (rd_timer == 4'b0101) ? {rd_byte_3_reg, rd_byte_4_reg} : data_out_3l;
		data_out_4l <= (rd_timer == 4'b0110) ? {rd_byte_3_reg, rd_byte_4_reg} : data_out_4l;
	end
	
	assign data_out = {data_out_1h, data_out_1l, data_out_2h, data_out_2l, data_out_3h, data_out_3l, data_out_4h, data_out_4l};
	assign data_valid = (rd_timer == 4'b0110);
	
	always@(posedge clkx2) begin
		if(~rst_n) begin
			dq_out <= 16'hZZZZ;
			select_byte <= 3'b0;
			dq_out_reg <= 16'b0;
		end else begin
		
			case(c_state)
				
				WR_DATA: begin
					dq_out_reg <= (select_byte == 3'b000) ? reg_data[127:112] :
								  (select_byte == 3'b001) ? reg_data[111:96]  :
								  (select_byte == 3'b010) ? reg_data[95:80]   :
								  (select_byte == 3'b011) ? reg_data[79:64]   :
								  (select_byte == 3'b100) ? reg_data[63:48]   :
								  (select_byte == 3'b101) ? reg_data[47:32]   :
								  (select_byte == 3'b110) ? reg_data[31:16]   :
								  (select_byte == 3'b111) ? reg_data[15:0] : dq_out_reg;
					select_byte <= select_byte + 1;
				end
				
				default: begin 
					dq_out_reg <= 16'hZZZZ;
					select_byte <= 1'b0;
				end
				
			endcase
	
			
			dq_out <= dq_out_reg;
		end
	end
	
	assign dqs = (dqs_en && ~q_dqs_en) ? 2'b0 : 
					 (dqs_en && q_dqs_en) ? {clk_90, clk_90} : 2'bZZ;
	
	assign dq = dq_out;
endmodule
