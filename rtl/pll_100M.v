/* Verilog netlist generated by SCUBA Diamond (64-bit) 3.12.0.240.2 */
/* Module Version: 5.7 */
/* C:\lscc\diamond\3.12\ispfpga\bin\nt64\scuba.exe -w -n pll_100M -lang verilog -synth synplify -arch ep5a00 -type pll -fin 25 -phase_cntl STATIC -bypasss -fclkop 100 -fclkop_tol 0.0 -delay_cntl AUTO_NO_DELAY -fb_mode CLOCKTREE -extcap AUTO -phaseadj 0.0 -duty 8 -noclkok -norst  */
/* Thu Feb 17 18:12:30 2022 */


`timescale 1 ns / 1 ps
module pll_100M (CLK, CLKOP, CLKOS, LOCK)/* synthesis NGD_DRC_MASK=1 */;
    input wire CLK;
    output wire CLKOP;
    output wire CLKOS;
    output wire LOCK;

    wire CLKOS_t;
    wire CLKOP_t;
    wire scuba_vlo;
    wire CLK_t;

    VLO scuba_vlo_inst (.Z(scuba_vlo));

    // synopsys translate_off
    defparam PLLDInst_0.PLLCAP = "DISABLED" ;
    defparam PLLDInst_0.CLKOK_BYPASS = "DISABLED" ;
    defparam PLLDInst_0.CLKOK_DIV = 2 ;
    defparam PLLDInst_0.CLKOS_BYPASS = "ENABLED" ;
    defparam PLLDInst_0.CLKOP_BYPASS = "DISABLED" ;
    defparam PLLDInst_0.PHASE_CNTL = "STATIC" ;
    defparam PLLDInst_0.DUTY = 8 ;
    defparam PLLDInst_0.PHASEADJ = "0.0" ;
    defparam PLLDInst_0.CLKOP_DIV = 8 ;
    defparam PLLDInst_0.CLKFB_DIV = 4 ;
    defparam PLLDInst_0.CLKI_DIV = 1 ;
    // synopsys translate_on
    EPLLD PLLDInst_0 (.CLKI(CLK_t), .CLKFB(CLKOP_t), .RST(scuba_vlo), .RSTK(scuba_vlo), 
        .DPAMODE(scuba_vlo), .DRPAI3(scuba_vlo), .DRPAI2(scuba_vlo), .DRPAI1(scuba_vlo), 
        .DRPAI0(scuba_vlo), .DFPAI3(scuba_vlo), .DFPAI2(scuba_vlo), .DFPAI1(scuba_vlo), 
        .DFPAI0(scuba_vlo), .CLKOP(CLKOP_t), .CLKOS(CLKOS_t), .CLKOK(), 
        .LOCK(LOCK), .CLKINTFB())
             /* synthesis PLLCAP="DISABLED" */
             /* synthesis PLLTYPE="GPLL" */
             /* synthesis CLKOK_BYPASS="DISABLED" */
             /* synthesis CLKOK_DIV="2" */
             /* synthesis CLKOS_BYPASS="ENABLED" */
             /* synthesis FREQUENCY_PIN_CLKOS="25.000000" */
             /* synthesis FREQUENCY_PIN_CLKOP="100.000000" */
             /* synthesis CLKOP_BYPASS="DISABLED" */
             /* synthesis PHASE_CNTL="STATIC" */
             /* synthesis FDEL="0" */
             /* synthesis DUTY="8" */
             /* synthesis PHASEADJ="0.0" */
             /* synthesis FREQUENCY_PIN_CLKI="25.000000" */
             /* synthesis CLKOP_DIV="8" */
             /* synthesis CLKFB_DIV="4" */
             /* synthesis CLKI_DIV="1" */
             /* synthesis FIN="25.000000" */;

    assign CLKOS = CLKOS_t;
    assign CLKOP = CLKOP_t;
    assign CLK_t = CLK;


    // exemplar begin
    // exemplar attribute PLLDInst_0 PLLCAP DISABLED
    // exemplar attribute PLLDInst_0 PLLTYPE GPLL
    // exemplar attribute PLLDInst_0 CLKOK_BYPASS DISABLED
    // exemplar attribute PLLDInst_0 CLKOK_DIV 2
    // exemplar attribute PLLDInst_0 CLKOS_BYPASS ENABLED
    // exemplar attribute PLLDInst_0 FREQUENCY_PIN_CLKOS 25.000000
    // exemplar attribute PLLDInst_0 FREQUENCY_PIN_CLKOP 100.000000
    // exemplar attribute PLLDInst_0 CLKOP_BYPASS DISABLED
    // exemplar attribute PLLDInst_0 PHASE_CNTL STATIC
    // exemplar attribute PLLDInst_0 FDEL 0
    // exemplar attribute PLLDInst_0 DUTY 8
    // exemplar attribute PLLDInst_0 PHASEADJ 0.0
    // exemplar attribute PLLDInst_0 FREQUENCY_PIN_CLKI 25.000000
    // exemplar attribute PLLDInst_0 CLKOP_DIV 8
    // exemplar attribute PLLDInst_0 CLKFB_DIV 4
    // exemplar attribute PLLDInst_0 CLKI_DIV 1
    // exemplar attribute PLLDInst_0 FIN 25.000000
    // exemplar end

endmodule
