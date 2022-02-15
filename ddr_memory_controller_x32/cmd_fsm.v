// Row Address to Column Address Delay (tRCD) = 20ns
//CAS Latency = 2 cycles
//Mode Register Set Delay (tMRD) = 2 cycles
//Row Precharge Time (tRP) = 20ns
//Exit Self Refresh to non-Read command (tXSNR) = 75ns
//Auto Refresh Row Cycle Time (tRFC) = 75ns


module cmd_fsm(
	input clk,
	input rst_n,
	input [3:0] cmd,
	input cmd_valid,
	input init_done,
	output reg [3:0] STATE,
	output reg busy,
	output read,
	output reg write,
	output reg burst_counter
);

// This module Decodes DDR commands after the initilization sequence is complete.

// Busy is asserted a few cycles before the auto refresh command needs to be executed.
// Otherwise, read/write requests that happened on the same cycle would be lost.

// read is asserted so that the datapath module knows when it needs to read data from dq pins.
// write is asserted to start feeding the datapath module with the correct data.

	localparam IDLE = 0;
	localparam ACT = 1;
	localparam READ = 2;
	localparam WRITE = 3;
	localparam READ_PRE = 4;
	localparam WRITE_PRE = 5;
	localparam RD_DATA = 6;
	localparam WR_DATA = 7;
	localparam PWRDWN_ENTER = 8;
	localparam PWRDWN_EXIT = 9;
	localparam LMR = 10;
	localparam SREF_ENTER = 11;
	localparam SREF_EXIT = 12;
	localparam AUTO_REF = 13;
	localparam AUTO_REF_COUNTER = 14;
	localparam TIMER = 15;

	reg [3:0] RETURN_STATE;
	reg [2:0] reg_cmd;
	reg [15:0] counter; //1 cycle delay
	reg [10:0] ref_counter;
	reg ref_reset;
	reg read_assert;

	always @ (posedge clk) begin
		if(~rst_n) begin
			STATE <= 4'b0;
			reg_cmd <= 3'b0;
			ref_counter <= 11'b0;
			ref_reset <= 1'b0;
			burst_counter <= 1'b1;
			read_assert <= 1'b0;
			write <= 1'b0;
		end else if (init_done) begin

			case(STATE)

				IDLE: begin
					if (ref_counter > 11'd1030) begin
						STATE <= AUTO_REF; //AUTO_REF
						ref_reset <= 1'b1;
						busy <= 1'b1;
						counter <= 16'h9;//Auto Ref as counter. 75ns (75*10^-9 * 133.33*10^6Hz = 9.99) + 1 for state change
					end else begin
						if (cmd_valid) begin
							burst_counter <= 1'b1;
							reg_cmd <= cmd[2:0];
							STATE <= (cmd == 4'b0001 || //Read
									cmd == 4'b0010 || //Write
									cmd == 4'b0011 || //Read with Auto Precharge
									cmd == 4'b0100) //Write with Auto Precharge
														? ACT :
									(cmd == 4'b0101) ? PWRDWN_ENTER :
									(cmd == 4'b0110) ? LMR :
									(cmd == 4'b0111) ? SREF_ENTER :
									IDLE;

							counter <= 15'h2; //LMR State as counter tMRD 2 cycles + 1 for state change
						end else begin
							busy <= 1'b0;
						end

						busy <= ((cmd == 4'b0001 || cmd == 4'b0010 || cmd == 4'b0011 || cmd == 4'b0100 || cmd == 4'b0101 || cmd == 4'b0110 || cmd == 4'b0111) && cmd_valid)
					         		|| (ref_counter > 11'd1020 && ref_counter < 11'd1030);
					end
				end

				ACT: begin //ACT
					STATE <= TIMER; //TIMER
					if (reg_cmd[2:0] == 3'b001) begin
						RETURN_STATE <= READ;
					end else if (reg_cmd[2:0] == 3'b010) begin
						RETURN_STATE <= WRITE;
					end else if (reg_cmd[2:0] == 3'b011) begin
						RETURN_STATE <= READ_PRE;
					end else begin
						RETURN_STATE <= WRITE_PRE;
					end
					counter <= 16'h2; //20ns (20*10^-9 * 133.33*10^6Hz = 2.666)
				end

				READ: begin
					read_assert <= 1'b1;
					STATE <= TIMER;
					RETURN_STATE <= RD_DATA;
					counter <= 16'h0; //CAS Latency = 2
				end

				WRITE: begin
					STATE <=  WR_DATA;
				end

				READ_PRE: begin
					read_assert <= 1'b1;
					STATE <= TIMER;
					RETURN_STATE <= RD_DATA;
					counter <= 16'h1; //CAS Latency = 2
				end

				WRITE_PRE: begin
					STATE <=  WR_DATA;
				end


				RD_DATA: begin //RD_DATA
					read_assert <= 1'b0;
					STATE <= (burst_counter == 1'b0) ? (reg_cmd[1] ? TIMER : IDLE) : RD_DATA; //reg_cmd[1] --> PRECHARGE
					burst_counter <= burst_counter - 1;
					RETURN_STATE <= IDLE;
					counter <=  16'h2; // 20ns (20*10^-9 * 133.33*10^6Hz = 2.666)
				end

				WR_DATA: begin
					STATE <= (burst_counter == 1'b0) ? (reg_cmd[2] ? TIMER : IDLE) : WR_DATA; //reg_cmd[2] --> PRECHARGE
					RETURN_STATE <= IDLE;
					write <= (burst_counter != 2'b01 && burst_counter != 2'b00);
					burst_counter <= burst_counter - 1;
					counter <= 16'h2; // 20ns (20*10^-9 * 133.33*10^6Hz = 2.666)
				end

				PWRDWN_ENTER: begin
					if (cmd_valid) begin
						reg_cmd <= cmd;
						if (cmd <= 4'b0101) begin
							busy <= 1'b1;
							STATE <= PWRDWN_EXIT;
						end
					end else begin
						STATE <= PWRDWN_ENTER;
						busy <= 1'b0;
					end
				end

				PWRDWN_EXIT: begin
					STATE <= IDLE;
				end

				LMR: begin
					counter <= counter - 1;
					STATE <= (counter == 16'b0) ? IDLE : LMR;
					busy <= (counter != 16'b0);
				end

				SREF_ENTER: begin

					if (cmd_valid) begin
						reg_cmd <= cmd;
						if(cmd == 4'b0001 || cmd == 4'b0011) begin
							busy <= 1'b1;
							STATE <= SREF_EXIT;
							RETURN_STATE <= ACT;
							counter <= 16'd200; //200 cycles to exit to READ command
						end else if (cmd[3] || cmd == 4'b000) begin
							busy <= 1'b0;
							STATE <= SREF_ENTER;

						end else begin
							busy <= 1'b1;
							STATE <= SREF_EXIT;
							RETURN_STATE <=  (cmd == 4'b0010 || //Write
											 cmd == 4'b0100) //Write with Auto Precharge
													? ACT :
											(cmd == 4'b0101) ? PWRDWN_ENTER :
											(cmd == 4'b0110) ? LMR :
											(cmd == 4'b0111) ? IDLE : SREF_ENTER;
							counter <= 16'h10; //75ns (75*10^-9 * 133.33*10^6Hz = 9.99) to exit to NON-READ command
						end
					end else begin
						busy <= 1'b0;
						STATE <= SREF_ENTER;
					end

				end

				SREF_EXIT: begin
					STATE <= TIMER;
				end

				AUTO_REF: begin
					STATE <= AUTO_REF_COUNTER;
				end


				AUTO_REF_COUNTER: begin
					counter <= counter - 1;
					STATE <= (counter == 16'b0) ? IDLE : AUTO_REF_COUNTER;
					busy <= (counter != 16'b0);
					ref_reset <= (counter != 16'b0);
				end



				TIMER: begin
					write <= (counter == 16'b0) ? (RETURN_STATE == WRITE || RETURN_STATE == WRITE_PRE) : 1'b0;
					counter <= counter - 1;
					STATE <= (counter == 16'b0) ? RETURN_STATE : TIMER;
				end
			endcase

			ref_counter <= (ref_reset) ? 11'b0 : ref_counter + 1;

		end else begin
			busy <= 1'b1;
		end

	end

	assign read = (read_assert) && ~(STATE == RD_DATA);


endmodule
