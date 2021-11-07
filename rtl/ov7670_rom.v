module ov7670_rom(
	input  clk,
	input [7:0] address,
	output reg[15:0] dout
);

	always@(posedge clk) begin
		
		case(address) 
			0:  dout <= 16'h12_80; //reset
			1:  dout <= 16'hFF_F0; //delay
			2:  dout <= 16'h12_04; // COM7,     set RGB color output
			3:  dout <= 16'h11_80; // CLKRC     internal PLL matches input clock
			4:  dout <= 16'h0C_00; // COM3,     default settings
			5:  dout <= 16'h3E_00; // COM14,    no scaling, normal pclock
			6:  dout <= 16'h04_00; // COM1,     disable CCIR656
			7:  dout <= 16'h40_d0; //COM15,     RGB565, full output range
			8:  dout <= 16'h3a_04; //TSLB       set correct output data sequence (magic)
			9:  dout <= 16'h14_18; //COM9       MAX AGC value x4
			10: dout <= 16'h4F_B3; //MTX1       all of these are magical matrix coefficients
			11: dout <= 16'h50_B3; //MTX2
			12: dout <= 16'h51_00; //MTX3
			13: dout <= 16'h52_3d; //MTX4
			14: dout <= 16'h53_A7; //MTX5
			15: dout <= 16'h54_E4; //MTX6
			16: dout <= 16'h58_9E; //MTXS
			17: dout <= 16'h3D_C0; //COM13      sets gamma enable, does not preserve reserved bits, may be wrong?
			18: dout <= 16'h17_14; //HSTART     start high 8 bits
			19: dout <= 16'h18_02; //HSTOP      stop high 8 bits //these kill the odd colored line
			20: dout <= 16'h32_80; //HREF       edge offset
			21: dout <= 16'h19_03; //VSTART     start high 8 bits
			22: dout <= 16'h1A_7B; //VSTOP      stop high 8 bits
			23: dout <= 16'h03_0A; //VREF       vsync edge offset
			24: dout <= 16'h0F_41; //COM6       reset timings
			25: dout <= 16'h1E_30; //MVFP       disable mirror / flip //might have magic value of 03
			26: dout <= 16'h33_0B; //CHLF       //magic value from the internet
			27: dout <= 16'h3C_78; //COM12      no HREF when VSYNC low
			28: dout <= 16'h69_00; //GFIX       fix gain control
			29: dout <= 16'h74_00; //REG74      Digital gain control
			30: dout <= 16'hB0_84; //RSVD       magic value from the internet *required* for good color
			31: dout <= 16'hB1_0c; //ABLC1
			32: dout <= 16'hB2_0e; //RSVD       more magic internet values
			33: dout <= 16'hB3_80; //THL_ST
			//begin mystery scaling numbers
			34: dout <= 16'h70_3a;
			35: dout <= 16'h71_35;
			36: dout <= 16'h72_11;
			37: dout <= 16'h73_f0;
			38: dout <= 16'ha2_02;
			//gamma curve values
			39: dout <= 16'h7a_20;
			40: dout <= 16'h7b_10;
			41: dout <= 16'h7c_1e;
			42: dout <= 16'h7d_35;
			43: dout <= 16'h7e_5a;
			44: dout <= 16'h7f_69;
			45: dout <= 16'h80_76;
			46: dout <= 16'h81_80;
			47: dout <= 16'h82_88;
			48: dout <= 16'h83_8f;
			49: dout <= 16'h84_96;
			50: dout <= 16'h85_a3;
			51: dout <= 16'h86_af;
			52: dout <= 16'h87_c4;
			53: dout <= 16'h88_d7;
			54: dout <= 16'h89_e8;
			//AGC and AEC
			54: dout <= 16'h13_e0; //COM8, disable AGC / AEC
			55: dout <= 16'h00_00; //set gain reg to 0 for AGC
			56: dout <= 16'h10_00; //set ARCJ reg to 0
			57: dout <= 16'h0d_40; //magic reserved bit for COM4
			58: dout <= 16'h14_18; //COM9, 4x gain + magic bit
			59: dout <= 16'ha5_05; // BD50MAX
			60: dout <= 16'hab_07; //DB60MAX
			61: dout <= 16'h24_95; //AGC upper limit
			62: dout <= 16'h25_33; //AGC lower limit
			63: dout <= 16'h26_e3; //AGC/AEC fast mode op region
			64: dout <= 16'h9f_78; //HAECC1
			65: dout <= 16'ha0_68; //HAECC2
			66: dout <= 16'ha1_03; //magic
			67: dout <= 16'ha6_d8; //HAECC3
			68: dout <= 16'ha7_d8; //HAECC4
			69: dout <= 16'ha8_f0; //HAECC5
			70: dout <= 16'ha9_90; //HAECC6
			71: dout <= 16'haa_94; //HAECC7
			72: dout <= 16'h13_c5; //COM8, enable AGC / AEC
			73: dout <= 16'h07_00;
			default: dout <= 16'hFF_FF;         //mark end of ROM
			
		endcase
	end
	
endmodule
