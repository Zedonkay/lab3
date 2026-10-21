module dFlipFlop (
    output logic q,
    input logic d, clock, reset
);
    always_ff @(posedge clock)
        if (reset)
            q <= 1'b0;
        else
            q <= d;
endmodule : dFlipFlop

module myExplicitFSM (
    output logic [3:0] fMove,
    output logic win, q0, q1, q2,
    input logic [3:0] hMove,
    input logic clock, reset
);
    logic d0, d1, d2;
    logic START5, PLAY1, PLAY3, WIN9, WIN7, WIN2;
    logic h2, h3, h4, h6, h7, h8, h9;
    logic p1Win9, p1Invalid, p3Win2, p3Invalid;
    logic nextPLAY1, nextPLAY3, nextWIN9, nextWIN7, nextWIN2;

    dFlipFlop ff0 (.d(d0), .q(q0), .*);
    dFlipFlop ff1 (.d(d1), .q(q1), .*);
    dFlipFlop ff2 (.d(d2), .q(q2), .*);

    assign START5 = ~q2 & ~q1 & ~q0;
    assign PLAY1  = ~q2 & ~q1 &  q0;
    assign PLAY3  = ~q2 &  q1 & ~q0;
    assign WIN9   =  q2 & ~q1 & ~q0;
    assign WIN7   =  q2 & ~q1 &  q0;
    assign WIN2   =  q2 &  q1 & ~q0;

    assign h2 = (hMove == 4'h2);
    assign h3 = (hMove == 4'h3);
    assign h4 = (hMove == 4'h4);
    assign h6 = (hMove == 4'h6);
    assign h7 = (hMove == 4'h7);
    assign h8 = (hMove == 4'h8);
    assign h9 = (hMove == 4'h9);

    assign p1Win9 = h2 | h3 | h4 | h7 | h8;
    assign p1Invalid = ~(p1Win9 | h9);
    assign p3Win2 = h4 | h7 | h8;
    assign p3Invalid = ~(p3Win2 | h2);

    assign nextPLAY1 = (START5 & h6) | (PLAY1 & p1Invalid);
    assign nextPLAY3 = (PLAY1 & h9) | (PLAY3 & p3Invalid);
    assign nextWIN9 = (PLAY1 & p1Win9) | WIN9;
    assign nextWIN7 = (PLAY3 & h2) | WIN7;
    assign nextWIN2 = (PLAY3 & p3Win2) | WIN2;

    assign d0 = nextPLAY1 | nextWIN7;
    assign d1 = nextPLAY3 | nextWIN2;
    assign d2 = nextWIN9 | nextWIN7 | nextWIN2;

    assign fMove[3] = WIN9;
    assign fMove[2] = START5 | WIN7;
    assign fMove[1] = PLAY3 | WIN7 | WIN2;
    assign fMove[0] = START5 | PLAY1 | PLAY3 | WIN9 | WIN7;
    assign win = WIN9 | WIN7 | WIN2;
endmodule : myExplicitFSM
