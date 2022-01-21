module fifo_in (Data, Clock, WrEn, RdEn, Reset, Q, Empty, Full, 
    AlmostEmpty, AlmostFull);
    input wire [284:0] Data;
    input wire Clock;
    input wire WrEn;
    input wire RdEn;
    input wire Reset;
    output wire [284:0] Q;
    output wire Empty;
    output wire Full;
    output wire AlmostEmpty;
    output wire AlmostFull;

    wire Empty1;
    wire Empty2;
    wire AlmostEmpty1;
    wire AlmostEmpty2;

    wire Full1;
    wire Full2;
    wire AlmostFull1;
    wire AlmostFull2;

    ram_fifo_1 ram_fifo_1(
    	.Data (Data[255:0]),
	.Clock (Clock),
	.WrEn (WrEn),
	.RdEn (RdEn),
	.Reset (Reset),
	.Q (Q[255:0]),
	.Empty (Empty1),
	.Full (Full1),
	.AlmostEmpty (AlmostEmpty1),
	.AlmostFull (AlmostFull1)
    );

    ram_fifo_2 ram_fifo_2(
    	.Data (Data[284:256]),
	.Clock (Clock),
	.WrEn (WrEn),
	.RdEn (RdEn),
	.Reset (Reset),
	.Q (Q[284:256]),
	.Empty (Empty2),
	.Full (Full2),
	.AlmostEmpty (AlmostEmpty2),
	.AlmostFull (AlmostFull2)
    );

    assign Empty = Empty1 || Empty2;
    assign Full = Full1 || Full2;
    assign AlmostEmpty = AlmostEmpty1 || AlmostEmpty2;
    assign AlmostFull = AlmostFull1 || AlmostFull2;

endmodule
