`default_nettype none
module myAbstractFSM (
    output logic [3:0] fMove,
    output logic win,
    input logic [3:0] hMove,
    input logic clock, reset
);
    enum logic [2:0] {START5, PLAY1, PLAY3, WIN9, WIN7, WIN2} currState, nextState;

    always_comb begin
        case (currState)
            START5:
                if (hMove == 4'h6)
                    nextState = PLAY1;
                else
                    nextState = START5;
            PLAY1:
                if (hMove == 4'h9)
                    nextState = PLAY3;
                else if (hMove == 4'h2 || hMove == 4'h3 || hMove == 4'h4 ||
                         hMove == 4'h7 || hMove == 4'h8)
                    nextState = WIN9;
                else
                    nextState = PLAY1;
            PLAY3:
                if (hMove == 4'h2)
                    nextState = WIN7;
                else if (hMove == 4'h4 || hMove == 4'h7 || hMove == 4'h8)
                    nextState = WIN2;
                else
                    nextState = PLAY3;
            WIN9: nextState = WIN9;
            WIN7: nextState = WIN7;
            WIN2: nextState = WIN2;
            default: nextState = START5;
        endcase
    end

    always_comb begin
        fMove = 4'b0000;
        win = 1'b0;
        unique case (currState)
            START5: fMove = 4'b0101;
            PLAY1: fMove = 4'b0001;
            PLAY3: fMove = 4'b0011;
            WIN9: begin
                fMove = 4'b1001;
                win = 1'b1;
            end
            WIN7: begin
                fMove = 4'b0111;
                win = 1'b1;
            end
            WIN2: begin
                fMove = 4'b0010;
                win = 1'b1;
            end
        endcase
    end

    always_ff @(posedge clock)
        if (reset)
            currState <= START5;
        else
            currState <= nextState;
endmodule : myAbstractFSM

module myFSM_test;
    logic [3:0] fMove;
    logic win;
    logic [3:0] hMove; 
    logic clock, reset;

    myAbstractFSM dut (
        .fMove(fMove),
        .win(win),
        .hMove(hMove),
        .clock(clock),
        .reset(reset)
    );

    string name= dut.currState.name;
    logic q0=dut.currState[0];
    logic q1=dut.currState[1];
    logic q2=dut.currState[2];

    initial begin 
        clock = 0; 
        forever #5 clock = ~clock;
    end

    initial begin 
        $monitor($time,, "state=%s, fMove = %d, hMove = %d, win = %b",
                  dut.currState.name, fMove, hMove, win);
        hMove = 4'hF;
        reset = 1'b1;
        @(posedge clock); #1;
        if (name != "START5") $display("Expected START5 after reset");
        reset = 1'b0;

        // START5 loops on an invalid move
        hMove = 4'hF;
        @(posedge clock); #1;
        if (name != "START5") $display("Expected START5 after invalid move");

        hMove <= 4'h3;
        @(posedge clock); #1 
        if (name != "START5") $display("Expected START5 after incorrect move");

        hMove = 4'h6;
        @(posedge clock); #1;
        if (name != "PLAY1") $display("Expected PLAY1 after hMove = 6");

        // PLAY1 loops on invalid moves and changes to PLAY3 on 9.
        hMove = 4'h5;
        @(posedge clock); #1;
        if (name != "PLAY1") $display("Expected PLAY1 after invalid move");

        hMove = 4'h9;
        @(posedge clock); #1;
        if (name != "PLAY3") $display("Expected PLAY3 after hMove = 9");

        // PLAY3 loops on invalid moves and can end in WIN7.
        hMove = 4'h5;
        @(posedge clock); #1;
        if (name != "PLAY3") $display("Expected PLAY3 after invalid move");

        hMove = 4'h2;
        @(posedge clock); #1;
        if (name != "WIN7" || !win) $display("Expected WIN7 after hMove = 2");

        hMove = 4'hF;
        @(posedge clock); #1;
        if (name != "WIN7" || !win) $display("Expected WIN7 to hold");

        // Reset and test PLAY1 -> WIN9, then its self-loop.
        reset = 1'b1;
        @(posedge clock); #1;
        reset = 1'b0;
        hMove = 4'h6;
        @(posedge clock); #1;
        hMove = 4'h3;
        @(posedge clock); #1;
        if (name != "WIN9" || !win) $display("Expected WIN9 after hMove = 3");

        hMove = 4'hF;
        @(posedge clock); #1;
        if (name != "WIN9" || !win) $display("Expected WIN9 to hold");

        // Reset and test PLAY3 -> WIN2, then its self-loop.
        reset = 1'b1;
        @(posedge clock); #1;
        reset = 1'b0;
        hMove = 4'h6;
        @(posedge clock); #1;
        hMove = 4'h9;
        @(posedge clock); #1;
        hMove = 4'h4;
        @(posedge clock); #1;
        if (name != "WIN2" || !win) $display("Expected WIN2 after hMove = 4");

        hMove = 4'hF;
        @(posedge clock); #1;
        if (name != "WIN2" || !win) $display("Expected WIN2 to hold");

        // Reset from WIN2.
        reset = 1'b1;
        @(posedge clock); #1;
        if (name != "START5") $display("Expected START5 after reset from WIN2");
        reset = 1'b0;

        // Reset from PLAY1.
        hMove = 4'h6;
        @(posedge clock); #1;
        reset = 1'b1;
        @(posedge clock); #1;
        if (name != "START5") $display("Expected START5 after reset from PLAY1");
        reset = 1'b0;

        // Reset from PLAY3.
        hMove = 4'h6;
        @(posedge clock); #1;
        hMove = 4'h9;
        @(posedge clock); #1;
        reset = 1'b1;
        @(posedge clock); #1;
        if (name != "START5") $display("Expected START5 after reset from PLAY3");
        reset = 1'b0;

        // Reset from WIN9.
        hMove = 4'h6;
        @(posedge clock); #1;
        hMove = 4'h3;
        @(posedge clock); #1;
        reset = 1'b1;
        @(posedge clock); #1;
        if (name != "START5") $display("Expected START5 after reset from WIN9");
        reset = 1'b0;

        // Reset from WIN7.
        hMove = 4'h6;
        @(posedge clock); #1;
        hMove = 4'h9;
        @(posedge clock); #1;
        hMove = 4'h2;
        @(posedge clock); #1;
        reset = 1'b1;
        @(posedge clock); #1;
        if (name != "START5") $display("Expected START5 after reset from WIN7");
        reset = 1'b0;

        $finish;
    end
endmodule : myFSM_test
        