//clk freq = 133.33 MHz
//Row Precharge Time (tRP) = 20ns
//Mode Register Set Delay (tMRD) = 2tCK
//Auto Refresh Row Cycle Time (tRFC) = 75ns
//Counter adds 1 cycle delay

module ram_initialize(
	input clk,
	input rst_n,
	input init_start,
	input sys_200us,
	output reg [3:0] STATE,
	output reg init_done,
	output reg cke //cke is used to let the signal generate module know when to assert ddr_cke
);

	localparam IDLE = 0;
	localparam NOP = 1;
	localparam PRECHARGE = 2;
	localparam EMRS = 3;
	localparam MRS1 = 4;
	localparam AUTO_REF = 5;
	localparam MRS2 = 6;
	localparam TIMER = 7;

	
	reg [3:0] RETURN_STATE;
	reg [15:0] counter; //+1 cycle delay
	reg auto_ref_counter;
	reg precharge_counter;
	reg dll_en;
	reg [7:0] dll_counter;

	
	
	always @ (posedge clk) begin
		if(~rst_n) begin
			STATE <= IDLE;
			init_done <= 1'b0;
			counter <= 15'b0;
			auto_ref_counter <= 1'b0;
			precharge_counter <= 1'b0;
			cke <= 1'b0;
			dll_counter <= 8'b0;
			dll_en <= 1'b0;
		end else begin
			
			case(STATE)
				IDLE: begin
					if (init_start) begin
						STATE <= (sys_200us) ? NOP : IDLE;
						cke <= sys_200us;
					end
				end
			
				TIMER: begin
					counter <= counter - 1;
					STATE <= (counter == 15'b0) ? RETURN_STATE : TIMER;
				end
			
				NOP: begin
					STATE <= PRECHARGE;
				end
			
				PRECHARGE: begin 
					precharge_counter <= precharge_counter + 1;
					STATE <= TIMER;
					RETURN_STATE <= (precharge_counter) ? AUTO_REF : EMRS;
					counter <= 16'h2; // 20ns (20*10^-9 * 133.33*10^6Hz = 2.666)
				end
				
				EMRS: begin
					STATE <= TIMER;
					RETURN_STATE <= MRS1;
					counter <= 16'h1; // 2tCK (+1 cycle delay)
				end
				
				MRS1: begin
					dll_en <= 1'b1;
					STATE <= TIMER;
					RETURN_STATE <=  NOP;
					counter <= 16'h1; // 2tCK (+1 cycle delay)
				end
				
					
				
				
				AUTO_REF: begin
					auto_ref_counter <= auto_ref_counter + 1;
					RETURN_STATE <= (auto_ref_counter) ? MRS2 : AUTO_REF;
					STATE <= TIMER;
					counter <= 16'h9; //75ns (75*10^-9 * 133.33*10^6Hz = 9.99)
				end
				
				MRS2: begin
					STATE <= TIMER;
					RETURN_STATE <= IDLE;
					counter <= 16'h1; // 2tCK (+1 cycle delay)
				end		
			
			
			endcase
			init_done <= (dll_counter == 8'd199) ? 1'b1 : init_done; // init_done indicates when the initialization sequence is complete
			dll_counter <= (dll_en) ? dll_counter  + 1 : 1'b0; // DDR dll is reset when MRS command is executed. 200 cycles need to pass before the first command.
		end
	end


endmodule