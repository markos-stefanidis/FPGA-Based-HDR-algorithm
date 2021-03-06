/* Verilog netlist generated by SCUBA Diamond (64-bit) 3.12.0.240.2 */
/* Module Version: 5.1 */
/* C:\lscc\diamond\3.12\ispfpga\bin\nt64\scuba.exe -w -n fifo_out_addr -lang verilog -synth synplify -bus_exp 7 -bb -arch ep5a00 -type ebfifo -depth 512 -width 2 -depth 512 -no_enable -pe -1 -pf -1  */
/* Mon Oct 11 18:15:13 2021 */


`timescale 1 ns / 1 ps
module fifo_out_addr (Data, Clock, WrEn, RdEn, Reset, Q, Empty, Full)/* synthesis NGD_DRC_MASK=1 */;
    input wire [1:0] Data;
    input wire Clock;
    input wire WrEn;
    input wire RdEn;
    input wire Reset;
    output wire [1:0] Q;
    output wire Empty;
    output wire Full;

    wire invout_1;
    wire invout_0;
    wire rden_i_inv;
    wire fcnt_en;
    wire empty_i;
    wire empty_d;
    wire full_i;
    wire full_d;
    wire ifcount_0;
    wire ifcount_1;
    wire bdcnt_bctr_ci;
    wire ifcount_2;
    wire ifcount_3;
    wire co0;
    wire ifcount_4;
    wire ifcount_5;
    wire co1;
    wire ifcount_6;
    wire ifcount_7;
    wire co2;
    wire ifcount_8;
    wire ifcount_9;
    wire co4;
    wire cnt_con;
    wire co3;
    wire cmp_ci;
    wire rden_i;
    wire co0_1;
    wire co1_1;
    wire co2_1;
    wire co3_1;
    wire cmp_le_1;
    wire cmp_le_1_c;
    wire cmp_ci_1;
    wire fcount_0;
    wire fcount_1;
    wire co0_2;
    wire fcount_2;
    wire fcount_3;
    wire co1_2;
    wire fcount_4;
    wire fcount_5;
    wire co2_2;
    wire fcount_6;
    wire fcount_7;
    wire co3_2;
    wire wren_i;
    wire wren_i_inv;
    wire fcount_8;
    wire fcount_9;
    wire cmp_ge_d1;
    wire cmp_ge_d1_c;
    wire iwcount_0;
    wire iwcount_1;
    wire w_ctr_ci;
    wire wcount_0;
    wire wcount_1;
    wire iwcount_2;
    wire iwcount_3;
    wire co0_3;
    wire wcount_2;
    wire wcount_3;
    wire iwcount_4;
    wire iwcount_5;
    wire co1_3;
    wire wcount_4;
    wire wcount_5;
    wire iwcount_6;
    wire iwcount_7;
    wire co2_3;
    wire wcount_6;
    wire wcount_7;
    wire iwcount_8;
    wire iwcount_9;
    wire co4_1;
    wire co3_3;
    wire wcount_8;
    wire wcount_9;
    wire scuba_vlo;
    wire scuba_vhi;
    wire ircount_0;
    wire ircount_1;
    wire r_ctr_ci;
    wire rcount_0;
    wire rcount_1;
    wire ircount_2;
    wire ircount_3;
    wire co0_4;
    wire rcount_2;
    wire rcount_3;
    wire ircount_4;
    wire ircount_5;
    wire co1_4;
    wire rcount_4;
    wire rcount_5;
    wire ircount_6;
    wire ircount_7;
    wire co2_4;
    wire rcount_6;
    wire rcount_7;
    wire ircount_8;
    wire ircount_9;
    wire co4_2;
    wire co3_4;
    wire rcount_8;
    wire rcount_9;

    AND2 AND2_t3 (.A(WrEn), .B(invout_1), .Z(wren_i));

    INV INV_3 (.A(full_i), .Z(invout_1));

    AND2 AND2_t2 (.A(RdEn), .B(invout_0), .Z(rden_i));

    INV INV_2 (.A(empty_i), .Z(invout_0));

    AND2 AND2_t1 (.A(wren_i), .B(rden_i_inv), .Z(cnt_con));

    XOR2 XOR2_t0 (.A(wren_i), .B(rden_i), .Z(fcnt_en));

    INV INV_1 (.A(rden_i), .Z(rden_i_inv));

    INV INV_0 (.A(wren_i), .Z(wren_i_inv));

    // synopsys translate_off
    defparam LUT4_1.initval =  16'h3232 ;
    // synopsys translate_on
    ROM16X1 LUT4_1 (.AD3(scuba_vlo), .AD2(cmp_le_1), .AD1(wren_i), .AD0(empty_i), 
        .DO0(empty_d))
             /* synthesis initval="0x3232" */;

    // synopsys translate_off
    defparam LUT4_0.initval =  16'h3232 ;
    // synopsys translate_on
    ROM16X1 LUT4_0 (.AD3(scuba_vlo), .AD2(cmp_ge_d1), .AD1(rden_i), .AD0(full_i), 
        .DO0(full_d))
             /* synthesis initval="0x3232" */;

    // synopsys translate_off
    defparam pdp_ram_0_0_0.CSDECODE_R =  3'b000 ;
    defparam pdp_ram_0_0_0.CSDECODE_W =  3'b001 ;
    defparam pdp_ram_0_0_0.GSR = "DISABLED" ;
    defparam pdp_ram_0_0_0.RESETMODE = "ASYNC" ;
    defparam pdp_ram_0_0_0.REGMODE = "NOREG" ;
    defparam pdp_ram_0_0_0.DATA_WIDTH_R = 36 ;
    defparam pdp_ram_0_0_0.DATA_WIDTH_W = 36 ;
    // synopsys translate_on
    PDPW16KB pdp_ram_0_0_0 (.DI0(Data[0]), .DI1(Data[1]), .DI2(scuba_vlo), 
        .DI3(scuba_vlo), .DI4(scuba_vlo), .DI5(scuba_vlo), .DI6(scuba_vlo), 
        .DI7(scuba_vlo), .DI8(scuba_vlo), .DI9(scuba_vlo), .DI10(scuba_vlo), 
        .DI11(scuba_vlo), .DI12(scuba_vlo), .DI13(scuba_vlo), .DI14(scuba_vlo), 
        .DI15(scuba_vlo), .DI16(scuba_vlo), .DI17(scuba_vlo), .DI18(scuba_vlo), 
        .DI19(scuba_vlo), .DI20(scuba_vlo), .DI21(scuba_vlo), .DI22(scuba_vlo), 
        .DI23(scuba_vlo), .DI24(scuba_vlo), .DI25(scuba_vlo), .DI26(scuba_vlo), 
        .DI27(scuba_vlo), .DI28(scuba_vlo), .DI29(scuba_vlo), .DI30(scuba_vlo), 
        .DI31(scuba_vlo), .DI32(scuba_vlo), .DI33(scuba_vlo), .DI34(scuba_vlo), 
        .DI35(scuba_vlo), .ADW0(wcount_0), .ADW1(wcount_1), .ADW2(wcount_2), 
        .ADW3(wcount_3), .ADW4(wcount_4), .ADW5(wcount_5), .ADW6(wcount_6), 
        .ADW7(wcount_7), .ADW8(wcount_8), .BE0(scuba_vhi), .BE1(scuba_vhi), 
        .BE2(scuba_vhi), .BE3(scuba_vhi), .CEW(wren_i), .CLKW(Clock), .CSW0(scuba_vhi), 
        .CSW1(scuba_vlo), .CSW2(scuba_vlo), .ADR0(scuba_vlo), .ADR1(scuba_vlo), 
        .ADR2(scuba_vlo), .ADR3(scuba_vlo), .ADR4(scuba_vlo), .ADR5(rcount_0), 
        .ADR6(rcount_1), .ADR7(rcount_2), .ADR8(rcount_3), .ADR9(rcount_4), 
        .ADR10(rcount_5), .ADR11(rcount_6), .ADR12(rcount_7), .ADR13(rcount_8), 
        .CER(rden_i), .CLKR(Clock), .CSR0(scuba_vlo), .CSR1(scuba_vlo), 
        .CSR2(scuba_vlo), .RST(Reset), .DO0(), .DO1(), .DO2(), .DO3(), .DO4(), 
        .DO5(), .DO6(), .DO7(), .DO8(), .DO9(), .DO10(), .DO11(), .DO12(), 
        .DO13(), .DO14(), .DO15(), .DO16(), .DO17(), .DO18(Q[0]), .DO19(Q[1]), 
        .DO20(), .DO21(), .DO22(), .DO23(), .DO24(), .DO25(), .DO26(), .DO27(), 
        .DO28(), .DO29(), .DO30(), .DO31(), .DO32(), .DO33(), .DO34(), .DO35())
             /* synthesis MEM_LPC_FILE="fifo_out_addr.lpc" */
             /* synthesis MEM_INIT_FILE="" */
             /* synthesis CSDECODE_R="0b000" */
             /* synthesis CSDECODE_W="0b001" */
             /* synthesis GSR="DISABLED" */
             /* synthesis RESETMODE="ASYNC" */
             /* synthesis REGMODE="NOREG" */
             /* synthesis DATA_WIDTH_R="36" */
             /* synthesis DATA_WIDTH_W="36" */;

    // synopsys translate_off
    defparam FF_31.GSR = "ENABLED" ;
    // synopsys translate_on
    FD1P3DX FF_31 (.D(ifcount_0), .SP(fcnt_en), .CK(Clock), .CD(Reset), 
        .Q(fcount_0))
             /* synthesis GSR="ENABLED" */;

    // synopsys translate_off
    defparam FF_30.GSR = "ENABLED" ;
    // synopsys translate_on
    FD1P3DX FF_30 (.D(ifcount_1), .SP(fcnt_en), .CK(Clock), .CD(Reset), 
        .Q(fcount_1))
             /* synthesis GSR="ENABLED" */;

    // synopsys translate_off
    defparam FF_29.GSR = "ENABLED" ;
    // synopsys translate_on
    FD1P3DX FF_29 (.D(ifcount_2), .SP(fcnt_en), .CK(Clock), .CD(Reset), 
        .Q(fcount_2))
             /* synthesis GSR="ENABLED" */;

    // synopsys translate_off
    defparam FF_28.GSR = "ENABLED" ;
    // synopsys translate_on
    FD1P3DX FF_28 (.D(ifcount_3), .SP(fcnt_en), .CK(Clock), .CD(Reset), 
        .Q(fcount_3))
             /* synthesis GSR="ENABLED" */;

    // synopsys translate_off
    defparam FF_27.GSR = "ENABLED" ;
    // synopsys translate_on
    FD1P3DX FF_27 (.D(ifcount_4), .SP(fcnt_en), .CK(Clock), .CD(Reset), 
        .Q(fcount_4))
             /* synthesis GSR="ENABLED" */;

    // synopsys translate_off
    defparam FF_26.GSR = "ENABLED" ;
    // synopsys translate_on
    FD1P3DX FF_26 (.D(ifcount_5), .SP(fcnt_en), .CK(Clock), .CD(Reset), 
        .Q(fcount_5))
             /* synthesis GSR="ENABLED" */;

    // synopsys translate_off
    defparam FF_25.GSR = "ENABLED" ;
    // synopsys translate_on
    FD1P3DX FF_25 (.D(ifcount_6), .SP(fcnt_en), .CK(Clock), .CD(Reset), 
        .Q(fcount_6))
             /* synthesis GSR="ENABLED" */;

    // synopsys translate_off
    defparam FF_24.GSR = "ENABLED" ;
    // synopsys translate_on
    FD1P3DX FF_24 (.D(ifcount_7), .SP(fcnt_en), .CK(Clock), .CD(Reset), 
        .Q(fcount_7))
             /* synthesis GSR="ENABLED" */;

    // synopsys translate_off
    defparam FF_23.GSR = "ENABLED" ;
    // synopsys translate_on
    FD1P3DX FF_23 (.D(ifcount_8), .SP(fcnt_en), .CK(Clock), .CD(Reset), 
        .Q(fcount_8))
             /* synthesis GSR="ENABLED" */;

    // synopsys translate_off
    defparam FF_22.GSR = "ENABLED" ;
    // synopsys translate_on
    FD1P3DX FF_22 (.D(ifcount_9), .SP(fcnt_en), .CK(Clock), .CD(Reset), 
        .Q(fcount_9))
             /* synthesis GSR="ENABLED" */;

    // synopsys translate_off
    defparam FF_21.GSR = "ENABLED" ;
    // synopsys translate_on
    FD1S3BX FF_21 (.D(empty_d), .CK(Clock), .PD(Reset), .Q(empty_i))
             /* synthesis GSR="ENABLED" */;

    // synopsys translate_off
    defparam FF_20.GSR = "ENABLED" ;
    // synopsys translate_on
    FD1S3DX FF_20 (.D(full_d), .CK(Clock), .CD(Reset), .Q(full_i))
             /* synthesis GSR="ENABLED" */;

    // synopsys translate_off
    defparam FF_19.GSR = "ENABLED" ;
    // synopsys translate_on
    FD1P3DX FF_19 (.D(iwcount_0), .SP(wren_i), .CK(Clock), .CD(Reset), .Q(wcount_0))
             /* synthesis GSR="ENABLED" */;

    // synopsys translate_off
    defparam FF_18.GSR = "ENABLED" ;
    // synopsys translate_on
    FD1P3DX FF_18 (.D(iwcount_1), .SP(wren_i), .CK(Clock), .CD(Reset), .Q(wcount_1))
             /* synthesis GSR="ENABLED" */;

    // synopsys translate_off
    defparam FF_17.GSR = "ENABLED" ;
    // synopsys translate_on
    FD1P3DX FF_17 (.D(iwcount_2), .SP(wren_i), .CK(Clock), .CD(Reset), .Q(wcount_2))
             /* synthesis GSR="ENABLED" */;

    // synopsys translate_off
    defparam FF_16.GSR = "ENABLED" ;
    // synopsys translate_on
    FD1P3DX FF_16 (.D(iwcount_3), .SP(wren_i), .CK(Clock), .CD(Reset), .Q(wcount_3))
             /* synthesis GSR="ENABLED" */;

    // synopsys translate_off
    defparam FF_15.GSR = "ENABLED" ;
    // synopsys translate_on
    FD1P3DX FF_15 (.D(iwcount_4), .SP(wren_i), .CK(Clock), .CD(Reset), .Q(wcount_4))
             /* synthesis GSR="ENABLED" */;

    // synopsys translate_off
    defparam FF_14.GSR = "ENABLED" ;
    // synopsys translate_on
    FD1P3DX FF_14 (.D(iwcount_5), .SP(wren_i), .CK(Clock), .CD(Reset), .Q(wcount_5))
             /* synthesis GSR="ENABLED" */;

    // synopsys translate_off
    defparam FF_13.GSR = "ENABLED" ;
    // synopsys translate_on
    FD1P3DX FF_13 (.D(iwcount_6), .SP(wren_i), .CK(Clock), .CD(Reset), .Q(wcount_6))
             /* synthesis GSR="ENABLED" */;

    // synopsys translate_off
    defparam FF_12.GSR = "ENABLED" ;
    // synopsys translate_on
    FD1P3DX FF_12 (.D(iwcount_7), .SP(wren_i), .CK(Clock), .CD(Reset), .Q(wcount_7))
             /* synthesis GSR="ENABLED" */;

    // synopsys translate_off
    defparam FF_11.GSR = "ENABLED" ;
    // synopsys translate_on
    FD1P3DX FF_11 (.D(iwcount_8), .SP(wren_i), .CK(Clock), .CD(Reset), .Q(wcount_8))
             /* synthesis GSR="ENABLED" */;

    // synopsys translate_off
    defparam FF_10.GSR = "ENABLED" ;
    // synopsys translate_on
    FD1P3DX FF_10 (.D(iwcount_9), .SP(wren_i), .CK(Clock), .CD(Reset), .Q(wcount_9))
             /* synthesis GSR="ENABLED" */;

    // synopsys translate_off
    defparam FF_9.GSR = "ENABLED" ;
    // synopsys translate_on
    FD1P3DX FF_9 (.D(ircount_0), .SP(rden_i), .CK(Clock), .CD(Reset), .Q(rcount_0))
             /* synthesis GSR="ENABLED" */;

    // synopsys translate_off
    defparam FF_8.GSR = "ENABLED" ;
    // synopsys translate_on
    FD1P3DX FF_8 (.D(ircount_1), .SP(rden_i), .CK(Clock), .CD(Reset), .Q(rcount_1))
             /* synthesis GSR="ENABLED" */;

    // synopsys translate_off
    defparam FF_7.GSR = "ENABLED" ;
    // synopsys translate_on
    FD1P3DX FF_7 (.D(ircount_2), .SP(rden_i), .CK(Clock), .CD(Reset), .Q(rcount_2))
             /* synthesis GSR="ENABLED" */;

    // synopsys translate_off
    defparam FF_6.GSR = "ENABLED" ;
    // synopsys translate_on
    FD1P3DX FF_6 (.D(ircount_3), .SP(rden_i), .CK(Clock), .CD(Reset), .Q(rcount_3))
             /* synthesis GSR="ENABLED" */;

    // synopsys translate_off
    defparam FF_5.GSR = "ENABLED" ;
    // synopsys translate_on
    FD1P3DX FF_5 (.D(ircount_4), .SP(rden_i), .CK(Clock), .CD(Reset), .Q(rcount_4))
             /* synthesis GSR="ENABLED" */;

    // synopsys translate_off
    defparam FF_4.GSR = "ENABLED" ;
    // synopsys translate_on
    FD1P3DX FF_4 (.D(ircount_5), .SP(rden_i), .CK(Clock), .CD(Reset), .Q(rcount_5))
             /* synthesis GSR="ENABLED" */;

    // synopsys translate_off
    defparam FF_3.GSR = "ENABLED" ;
    // synopsys translate_on
    FD1P3DX FF_3 (.D(ircount_6), .SP(rden_i), .CK(Clock), .CD(Reset), .Q(rcount_6))
             /* synthesis GSR="ENABLED" */;

    // synopsys translate_off
    defparam FF_2.GSR = "ENABLED" ;
    // synopsys translate_on
    FD1P3DX FF_2 (.D(ircount_7), .SP(rden_i), .CK(Clock), .CD(Reset), .Q(rcount_7))
             /* synthesis GSR="ENABLED" */;

    // synopsys translate_off
    defparam FF_1.GSR = "ENABLED" ;
    // synopsys translate_on
    FD1P3DX FF_1 (.D(ircount_8), .SP(rden_i), .CK(Clock), .CD(Reset), .Q(rcount_8))
             /* synthesis GSR="ENABLED" */;

    // synopsys translate_off
    defparam FF_0.GSR = "ENABLED" ;
    // synopsys translate_on
    FD1P3DX FF_0 (.D(ircount_9), .SP(rden_i), .CK(Clock), .CD(Reset), .Q(rcount_9))
             /* synthesis GSR="ENABLED" */;

    FADD2B bdcnt_bctr_cia (.A0(scuba_vlo), .A1(cnt_con), .B0(scuba_vlo), 
        .B1(cnt_con), .CI(scuba_vlo), .COUT(bdcnt_bctr_ci), .S0(), .S1());

    CB2 bdcnt_bctr_0 (.CI(bdcnt_bctr_ci), .PC0(fcount_0), .PC1(fcount_1), 
        .CON(cnt_con), .CO(co0), .NC0(ifcount_0), .NC1(ifcount_1));

    CB2 bdcnt_bctr_1 (.CI(co0), .PC0(fcount_2), .PC1(fcount_3), .CON(cnt_con), 
        .CO(co1), .NC0(ifcount_2), .NC1(ifcount_3));

    CB2 bdcnt_bctr_2 (.CI(co1), .PC0(fcount_4), .PC1(fcount_5), .CON(cnt_con), 
        .CO(co2), .NC0(ifcount_4), .NC1(ifcount_5));

    CB2 bdcnt_bctr_3 (.CI(co2), .PC0(fcount_6), .PC1(fcount_7), .CON(cnt_con), 
        .CO(co3), .NC0(ifcount_6), .NC1(ifcount_7));

    CB2 bdcnt_bctr_4 (.CI(co3), .PC0(fcount_8), .PC1(fcount_9), .CON(cnt_con), 
        .CO(co4), .NC0(ifcount_8), .NC1(ifcount_9));

    FADD2B e_cmp_ci_a (.A0(scuba_vhi), .A1(scuba_vhi), .B0(scuba_vhi), .B1(scuba_vhi), 
        .CI(scuba_vlo), .COUT(cmp_ci), .S0(), .S1());

    ALEB2 e_cmp_0 (.A0(fcount_0), .A1(fcount_1), .B0(rden_i), .B1(scuba_vlo), 
        .CI(cmp_ci), .LE(co0_1));

    ALEB2 e_cmp_1 (.A0(fcount_2), .A1(fcount_3), .B0(scuba_vlo), .B1(scuba_vlo), 
        .CI(co0_1), .LE(co1_1));

    ALEB2 e_cmp_2 (.A0(fcount_4), .A1(fcount_5), .B0(scuba_vlo), .B1(scuba_vlo), 
        .CI(co1_1), .LE(co2_1));

    ALEB2 e_cmp_3 (.A0(fcount_6), .A1(fcount_7), .B0(scuba_vlo), .B1(scuba_vlo), 
        .CI(co2_1), .LE(co3_1));

    ALEB2 e_cmp_4 (.A0(fcount_8), .A1(fcount_9), .B0(scuba_vlo), .B1(scuba_vlo), 
        .CI(co3_1), .LE(cmp_le_1_c));

    FADD2B a0 (.A0(scuba_vlo), .A1(scuba_vlo), .B0(scuba_vlo), .B1(scuba_vlo), 
        .CI(cmp_le_1_c), .COUT(), .S0(cmp_le_1), .S1());

    FADD2B g_cmp_ci_a (.A0(scuba_vhi), .A1(scuba_vhi), .B0(scuba_vhi), .B1(scuba_vhi), 
        .CI(scuba_vlo), .COUT(cmp_ci_1), .S0(), .S1());

    AGEB2 g_cmp_0 (.A0(fcount_0), .A1(fcount_1), .B0(wren_i), .B1(wren_i), 
        .CI(cmp_ci_1), .GE(co0_2));

    AGEB2 g_cmp_1 (.A0(fcount_2), .A1(fcount_3), .B0(wren_i), .B1(wren_i), 
        .CI(co0_2), .GE(co1_2));

    AGEB2 g_cmp_2 (.A0(fcount_4), .A1(fcount_5), .B0(wren_i), .B1(wren_i), 
        .CI(co1_2), .GE(co2_2));

    AGEB2 g_cmp_3 (.A0(fcount_6), .A1(fcount_7), .B0(wren_i), .B1(wren_i), 
        .CI(co2_2), .GE(co3_2));

    AGEB2 g_cmp_4 (.A0(fcount_8), .A1(fcount_9), .B0(wren_i), .B1(wren_i_inv), 
        .CI(co3_2), .GE(cmp_ge_d1_c));

    FADD2B a1 (.A0(scuba_vlo), .A1(scuba_vlo), .B0(scuba_vlo), .B1(scuba_vlo), 
        .CI(cmp_ge_d1_c), .COUT(), .S0(cmp_ge_d1), .S1());

    FADD2B w_ctr_cia (.A0(scuba_vlo), .A1(scuba_vhi), .B0(scuba_vlo), .B1(scuba_vhi), 
        .CI(scuba_vlo), .COUT(w_ctr_ci), .S0(), .S1());

    CU2 w_ctr_0 (.CI(w_ctr_ci), .PC0(wcount_0), .PC1(wcount_1), .CO(co0_3), 
        .NC0(iwcount_0), .NC1(iwcount_1));

    CU2 w_ctr_1 (.CI(co0_3), .PC0(wcount_2), .PC1(wcount_3), .CO(co1_3), 
        .NC0(iwcount_2), .NC1(iwcount_3));

    CU2 w_ctr_2 (.CI(co1_3), .PC0(wcount_4), .PC1(wcount_5), .CO(co2_3), 
        .NC0(iwcount_4), .NC1(iwcount_5));

    CU2 w_ctr_3 (.CI(co2_3), .PC0(wcount_6), .PC1(wcount_7), .CO(co3_3), 
        .NC0(iwcount_6), .NC1(iwcount_7));

    CU2 w_ctr_4 (.CI(co3_3), .PC0(wcount_8), .PC1(wcount_9), .CO(co4_1), 
        .NC0(iwcount_8), .NC1(iwcount_9));

    VLO scuba_vlo_inst (.Z(scuba_vlo));

    VHI scuba_vhi_inst (.Z(scuba_vhi));

    FADD2B r_ctr_cia (.A0(scuba_vlo), .A1(scuba_vhi), .B0(scuba_vlo), .B1(scuba_vhi), 
        .CI(scuba_vlo), .COUT(r_ctr_ci), .S0(), .S1());

    CU2 r_ctr_0 (.CI(r_ctr_ci), .PC0(rcount_0), .PC1(rcount_1), .CO(co0_4), 
        .NC0(ircount_0), .NC1(ircount_1));

    CU2 r_ctr_1 (.CI(co0_4), .PC0(rcount_2), .PC1(rcount_3), .CO(co1_4), 
        .NC0(ircount_2), .NC1(ircount_3));

    CU2 r_ctr_2 (.CI(co1_4), .PC0(rcount_4), .PC1(rcount_5), .CO(co2_4), 
        .NC0(ircount_4), .NC1(ircount_5));

    CU2 r_ctr_3 (.CI(co2_4), .PC0(rcount_6), .PC1(rcount_7), .CO(co3_4), 
        .NC0(ircount_6), .NC1(ircount_7));

    CU2 r_ctr_4 (.CI(co3_4), .PC0(rcount_8), .PC1(rcount_9), .CO(co4_2), 
        .NC0(ircount_8), .NC1(ircount_9));

    assign Empty = empty_i;
    assign Full = full_i;


    // exemplar begin
    // exemplar attribute LUT4_1 initval 0x3232
    // exemplar attribute LUT4_0 initval 0x3232
    // exemplar attribute pdp_ram_0_0_0 MEM_LPC_FILE fifo_out_addr.lpc
    // exemplar attribute pdp_ram_0_0_0 MEM_INIT_FILE 
    // exemplar attribute pdp_ram_0_0_0 CSDECODE_R 0b000
    // exemplar attribute pdp_ram_0_0_0 CSDECODE_W 0b001
    // exemplar attribute pdp_ram_0_0_0 GSR DISABLED
    // exemplar attribute pdp_ram_0_0_0 RESETMODE ASYNC
    // exemplar attribute pdp_ram_0_0_0 REGMODE NOREG
    // exemplar attribute pdp_ram_0_0_0 DATA_WIDTH_R 36
    // exemplar attribute pdp_ram_0_0_0 DATA_WIDTH_W 36
    // exemplar attribute FF_31 GSR ENABLED
    // exemplar attribute FF_30 GSR ENABLED
    // exemplar attribute FF_29 GSR ENABLED
    // exemplar attribute FF_28 GSR ENABLED
    // exemplar attribute FF_27 GSR ENABLED
    // exemplar attribute FF_26 GSR ENABLED
    // exemplar attribute FF_25 GSR ENABLED
    // exemplar attribute FF_24 GSR ENABLED
    // exemplar attribute FF_23 GSR ENABLED
    // exemplar attribute FF_22 GSR ENABLED
    // exemplar attribute FF_21 GSR ENABLED
    // exemplar attribute FF_20 GSR ENABLED
    // exemplar attribute FF_19 GSR ENABLED
    // exemplar attribute FF_18 GSR ENABLED
    // exemplar attribute FF_17 GSR ENABLED
    // exemplar attribute FF_16 GSR ENABLED
    // exemplar attribute FF_15 GSR ENABLED
    // exemplar attribute FF_14 GSR ENABLED
    // exemplar attribute FF_13 GSR ENABLED
    // exemplar attribute FF_12 GSR ENABLED
    // exemplar attribute FF_11 GSR ENABLED
    // exemplar attribute FF_10 GSR ENABLED
    // exemplar attribute FF_9 GSR ENABLED
    // exemplar attribute FF_8 GSR ENABLED
    // exemplar attribute FF_7 GSR ENABLED
    // exemplar attribute FF_6 GSR ENABLED
    // exemplar attribute FF_5 GSR ENABLED
    // exemplar attribute FF_4 GSR ENABLED
    // exemplar attribute FF_3 GSR ENABLED
    // exemplar attribute FF_2 GSR ENABLED
    // exemplar attribute FF_1 GSR ENABLED
    // exemplar attribute FF_0 GSR ENABLED
    // exemplar end

endmodule
