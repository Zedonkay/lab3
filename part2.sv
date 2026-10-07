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
