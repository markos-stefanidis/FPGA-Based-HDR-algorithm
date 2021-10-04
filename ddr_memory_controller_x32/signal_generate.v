module signal_generate(
	input clk,
	input rst_n,
	input [3:0] i_state,
	input init_done,
	input [3:0] c_state,
	input [24:0] sys_addr,
	input cke,
	output reg [1:0] ddr_cs_n,
	output reg [1:0] ddr_cke,
	output reg ddr_ras_n,
	output reg ddr_cas_n,
	output reg ddr_we_n,
	output reg [12:0] ddr_addr,
	output reg [1:0] ddr_ba
);

	// This module generates the command (cke, cs_n, ras_n, cas_n, we_n) and address (addr, ba) signals for the DDR memory by
	// reading the state of either cmd_fsm or ram_initialize



	reg [24:0] reg_addr;


	always @ (posedge clk) begin
		if(~rst_n) begin
			ddr_addr <= 14'b0;
			ddr_ba <= 2'b0;
			ddr_cas_n <= 1'b1;
			ddr_cke <= 2'b0;
			ddr_cs_n <= 2'b11;
			ddr_ras_n <= 1'b1;
			ddr_we_n <= 1'b1;
			reg_addr <= 25'b0;
		end else begin
			
			if(init_done) begin
				case(c_state)
					
					
					
					4'b0000: begin //IDLE
						ddr_cke <= 2'b11;
						ddr_cs_n <= 2'b11;
						ddr_ras_n <= 1'b1;
						ddr_cas_n <= 1'b1;
						ddr_we_n <= 1'b1;
						reg_addr <= sys_addr;
					end
					
					4'b0001: begin //ACT
						ddr_cke <= 2'b11;
						ddr_cs_n <= (reg_addr[11]) ? 2'b01 : 2'b10;
						ddr_ras_n <= 1'b0;
						ddr_cas_n <= 1'b1;
						ddr_we_n <= 1'b1;
						ddr_addr <= reg_addr[24:12];
						ddr_ba <= reg_addr[10:9];
					end
					
					4'b0010: begin //READ
						ddr_cke <= 2'b11;
						ddr_cs_n <= (reg_addr[11]) ? 2'b01 : 2'b10;
						ddr_ras_n <= 1'b1;
						ddr_cas_n <= 1'b0;
						ddr_we_n <= 1'b1;
						ddr_addr[9:0] <= reg_addr[8:0];
						ddr_addr[10] <= 1'b0;
						ddr_addr[12:11] <= 2'b0;
						ddr_ba <= reg_addr[10:9];
					end
					
					4'b0011: begin //WRITE
						ddr_cke <= 2'b11;
						ddr_cs_n <= (reg_addr[11]) ? 2'b01 : 2'b10;
						ddr_ras_n <= 1'b1;
						ddr_cas_n <= 1'b0;
						ddr_we_n <= 1'b0;
						ddr_addr[9:0] <= reg_addr[8:0];
						ddr_addr[10] <= 1'b0;
						ddr_addr[12:11] <= 2'b0;
						ddr_ba <= reg_addr[10:9];
					end
					
					4'b0100: begin //READ_PRE
						ddr_cke <= 2'b11;
						ddr_cs_n <= (reg_addr[11]) ? 2'b01 : 2'b10;
						ddr_ras_n <= 1'b1;
						ddr_cas_n <= 1'b0;
						ddr_we_n <= 1'b1;
						ddr_addr[9:0] <= reg_addr[8:0];
						ddr_addr[10] <= 1'b1;
						ddr_addr[12:11] <= 2'b0;
						ddr_ba <= reg_addr[10:9];
					end
					
					4'b0101: begin //WRITE_PRE
						ddr_cke <= 2'b11;
						ddr_cs_n <= (reg_addr[11]) ? 2'b01 : 2'b10;
						ddr_ras_n <= 1'b1;
						ddr_cas_n <= 1'b0;
						ddr_we_n <= 1'b0;
						ddr_addr[9:0] <= reg_addr[8:0];
						ddr_addr[10] <= 1'b1;
						ddr_addr[12:11] <= 2'b0;
						ddr_ba <= reg_addr[10:9];
					end
					
					4'b0110: begin //RD_DATA
						ddr_cke <= 2'b11;
						ddr_cs_n <= 2'b11;
						ddr_ras_n <= 1'b1;
						ddr_cas_n <= 1'b1;
						ddr_we_n <= 1'b1;
					end
					
					4'b0111: begin //WR_DATA
						ddr_cke <= 2'b11;
						ddr_cs_n <= 2'b11;
						ddr_ras_n <= 1'b1;
						ddr_cas_n <= 1'b1;
						ddr_we_n <= 1'b1;	
					end
					
					4'b1000: begin //PWRDN_ENTER
						ddr_cke <= 2'b0;
						ddr_cs_n <= 2'b11;
					
					end
					
					4'b1001: begin //PWRDN_EXIT
						ddr_cke <= 2'b11;
						ddr_cs_n <= 2'b11;
					
					end
					
					4'b1010: begin //Load Mode Regsiter
						ddr_cs_n <= 2'b0;
						ddr_ras_n <= 1'b0;
						ddr_cas_n <= 1'b0;
						ddr_we_n <= 1'b0;
						ddr_addr <= {4'b0, 1'b0, 1'b0, 3'b010, 1'b0, 3'b010}; //Normal Mode, CAS Latency = 2, BT = Seq, BL = 4
						ddr_ba <= 2'b00; //MRS
					end
					
					4'b1011: begin //SREF_ENTER
						ddr_cke <= 2'b0;
						ddr_cs_n <= 2'b0;
						ddr_ras_n <= 1'b0;
						ddr_cas_n <= 1'b0;
						ddr_we_n <= 1'b1;
					end
					
					4'b1100: begin //SREF_EXIT
						ddr_cke <= 2'b11;
						ddr_cs_n <= 2'b11;
					end
					
					4'b1101: begin //AUTO_REF
						ddr_cke <= 2'b11;
						ddr_cs_n <= 2'b0;
						ddr_cas_n <= 1'b0;
						ddr_ras_n <= 1'b0;
						ddr_cs_n <= 1'b0;
						ddr_we_n <= 1'b1;
					end
					
					4'b1110: begin //AUTO_REF_COUNTER
						ddr_cke <= 2'b11;
						ddr_cs_n <= 2'b11;
						ddr_ras_n <= 1'b1;
						ddr_cas_n <= 1'b1;
						ddr_we_n <= 1'b1;	
					end		
					
					4'b1111: begin //TIMER
						ddr_cke <= 2'b11;
						ddr_cs_n <= 2'b11;
						ddr_ras_n <= 1'b1;
						ddr_cas_n <= 1'b1;
						ddr_we_n <= 1'b1;	
					
					end
				endcase
			
			end else begin
				case(i_state)
					
					4'b0000: begin //IDLE
						ddr_cke <= {cke, cke};
						ddr_cs_n <= 2'b11;
						ddr_ras_n <= 1'b1;
						ddr_cas_n <= 1'b1;
						ddr_we_n <= 1'b1;						
					end
					
					
					4'b0001: begin //NOP
						ddr_cke <= 2'b11;
						ddr_cs_n <= 2'b0;
						ddr_ras_n <= 1'b1;
						ddr_cas_n <= 1'b1;
						ddr_we_n <= 1'b1;						
					end
					
					4'b0010: begin //PRECHARGE
						ddr_cs_n <= 2'b0;
						ddr_ras_n <= 1'b0;
						ddr_cas_n <= 1'b1;
						ddr_we_n <= 1'b0;
						ddr_addr[10] <= 1'b1;
					end

					
					4'b0011: begin //EMRS
						ddr_cs_n <= 2'b0;
						ddr_ras_n <= 1'b0;
						ddr_cas_n <= 1'b0;
						ddr_we_n <= 1'b0;
						ddr_addr <= {10'b0, 1'b0, 1'b1, 1'b0}; //Normal Mode, Full Strength Driver, DLL Enable
						ddr_ba <= 2'b01; //EMRS
					end
					
					4'b0100: begin //MRS1
						ddr_cs_n <= 2'b0;
						ddr_ras_n <= 1'b0;
						ddr_cas_n <= 1'b0;
						ddr_we_n <= 1'b0;
						ddr_addr <= {4'b0, 1'b1, 1'b0, 3'b010, 1'b0, 3'b010}; //Normal Mode, DLL Reset, CAS Latency = 2, BT = Seq, BL = 4
						ddr_ba <= 2'b00; //MRS
					
					end
					
					4'b0101: begin //AUTO_REF
						ddr_cke <= 2'b11;
						ddr_cs_n <= 2'b0;
						ddr_cas_n <= 1'b0;
						ddr_ras_n <= 1'b0;
						ddr_we_n <= 1'b1;
					end
								
					
					4'b0110: begin //MRS2
						ddr_cs_n <= 2'b0;
						ddr_ras_n <= 1'b0;
						ddr_cas_n <= 1'b0;
						ddr_we_n <= 1'b0;
						ddr_addr <= {4'b0, 1'b0, 1'b0, 3'b010, 1'b0, 3'b010}; //Normal Mode, CAS Latency = 2, BT = Seq, BL = 4
						ddr_ba <= 2'b00; //MRS
					
					end
					
					4'b0111: begin //TIMER
						ddr_cke <= 2'b11;
						ddr_cs_n <= 2'b11;
						ddr_ras_n <= 1'b1;
						ddr_cas_n <= 1'b1;
						ddr_we_n <= 1'b1;	
					end
				
				endcase
			
			end
			
			
		end
	
	end




endmodule
