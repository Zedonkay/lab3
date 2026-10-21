`default_nettype none

module myAbstractFSM (
    output logic [3:0] fMove,
    output logic win,
    output logic [3:0] HEX7, HEX6, HEX5, HEX4,
    output logic [3:0] HEX3, HEX2, HEX1, HEX0,
    output logic [7:0] blank,
    input logic [3:0] hMove,
    input logic enter, new_game,
    input logic clock, reset
);
    // The state records the move history. No move registers or sorter are used.
    // HOLD states remember a submitted move until enter is released.
    typedef enum logic [4:0] {
        START5, HOLD6, PLAY1, HOLD9, PLAY3,
        HOLD_H2_WIN9, HOLD_H3_WIN9, HOLD_H4_WIN9,
        HOLD_H7_WIN9, HOLD_H8_WIN9,
        HOLD_H2_WIN7, HOLD_H4_WIN2, HOLD_H7_WIN2, HOLD_H8_WIN2,
        INVALID5, INVALID1, INVALID3,
        WIN9_H2, WIN9_H3, WIN9_H4, WIN9_H7, WIN9_H8,
        WIN7_H2, WIN2_H4, WIN2_H7, WIN2_H8
    } state_t;
    state_t currState, nextState;

    // A small second FSM handles restarting while the game FSM keeps its
    // winning state and display. A press begun before win cannot restart.
    typedef enum logic [1:0] {WAIT_NEW_RELEASE, READY_NEW, WAIT_BOTH_RELEASE}
        restart_state_t;
    restart_state_t restartState, nextRestartState;
    logic restart_game;

    always_comb begin
        nextRestartState = restartState;
        restart_game = 1'b0;
        if (!win)
            nextRestartState = WAIT_NEW_RELEASE;
        else begin
            case (restartState)
                WAIT_NEW_RELEASE:
                    if (!new_game) nextRestartState = READY_NEW;
                READY_NEW:
                    if (new_game) nextRestartState = WAIT_BOTH_RELEASE;
                WAIT_BOTH_RELEASE:
                    if (!new_game && !enter) begin
                        restart_game = 1'b1;
                        nextRestartState = WAIT_NEW_RELEASE;
                    end
                default: nextRestartState = WAIT_NEW_RELEASE;
            endcase
        end
    end

    always_comb begin
        nextState = currState;
        case (currState)
            START5:
                if (enter) begin
                    if (hMove == 4'd6) nextState = HOLD6;
                    else nextState = INVALID5;
                end
            HOLD6: if (!enter) nextState = PLAY1;
            PLAY1:
                if (enter) begin
                    case (hMove)
                        4'd2: nextState = HOLD_H2_WIN9;
                        4'd3: nextState = HOLD_H3_WIN9;
                        4'd4: nextState = HOLD_H4_WIN9;
                        4'd7: nextState = HOLD_H7_WIN9;
                        4'd8: nextState = HOLD_H8_WIN9;
                        4'd9: nextState = HOLD9;
                        default: nextState = INVALID1;
                    endcase
                end
            HOLD9: if (!enter) nextState = PLAY3;
            PLAY3:
                if (enter) begin
                    case (hMove)
                        4'd2: nextState = HOLD_H2_WIN7;
                        4'd4: nextState = HOLD_H4_WIN2;
                        4'd7: nextState = HOLD_H7_WIN2;
                        4'd8: nextState = HOLD_H8_WIN2;
                        default: nextState = INVALID3;
                    endcase
                end
            HOLD_H2_WIN9: if (!enter) nextState = WIN9_H2;
            HOLD_H3_WIN9: if (!enter) nextState = WIN9_H3;
            HOLD_H4_WIN9: if (!enter) nextState = WIN9_H4;
            HOLD_H7_WIN9: if (!enter) nextState = WIN9_H7;
            HOLD_H8_WIN9: if (!enter) nextState = WIN9_H8;
            HOLD_H2_WIN7: if (!enter) nextState = WIN7_H2;
            HOLD_H4_WIN2: if (!enter) nextState = WIN2_H4;
            HOLD_H7_WIN2: if (!enter) nextState = WIN2_H7;
            HOLD_H8_WIN2: if (!enter) nextState = WIN2_H8;
            INVALID5: if (!enter) nextState = START5;
            INVALID1: if (!enter) nextState = PLAY1;
            INVALID3: if (!enter) nextState = PLAY3;
            WIN9_H2, WIN9_H3, WIN9_H4, WIN9_H7, WIN9_H8,
            WIN7_H2, WIN2_H4, WIN2_H7, WIN2_H8:
                if (restart_game) nextState = START5;
            default: nextState = START5;
        endcase
    end

    // Moore outputs: every digit, blank bit, move and win depends only on
    // currState. Human digits update on press; FPGA digits update on release.
    // Within each packed group, the leftmost digit is the smallest move.
    always_comb begin
        fMove = 4'd5;
        win = 1'b0;
        {HEX7, HEX6, HEX5, HEX4} = 16'h0000;
        {HEX3, HEX2, HEX1, HEX0} = 16'h5000;
        blank = 8'b1111_0111;
        case (currState)
            START5, INVALID5: begin end
            HOLD6: begin
                {HEX7, HEX6, HEX5, HEX4} = 16'h6000;
                blank = 8'b0111_0111;
            end
            PLAY1, INVALID1: begin
                fMove = 4'd1;
                {HEX7, HEX6, HEX5, HEX4} = 16'h6000;
                {HEX3, HEX2, HEX1, HEX0} = 16'h1500;
                blank = 8'b0111_0011;
            end
            HOLD9, HOLD_H2_WIN9, HOLD_H3_WIN9, HOLD_H4_WIN9,
            HOLD_H7_WIN9, HOLD_H8_WIN9: begin
                fMove = 4'd1;
                {HEX3, HEX2, HEX1, HEX0} = 16'h1500;
                blank = 8'b0011_0011;
                case (currState)
                    HOLD_H2_WIN9: {HEX7, HEX6, HEX5, HEX4} = 16'h2600;
                    HOLD_H3_WIN9: {HEX7, HEX6, HEX5, HEX4} = 16'h3600;
                    HOLD_H4_WIN9: {HEX7, HEX6, HEX5, HEX4} = 16'h4600;
                    HOLD_H7_WIN9: {HEX7, HEX6, HEX5, HEX4} = 16'h6700;
                    HOLD_H8_WIN9: {HEX7, HEX6, HEX5, HEX4} = 16'h6800;
                    default:     {HEX7, HEX6, HEX5, HEX4} = 16'h6900;
                endcase
            end
            PLAY3, INVALID3: begin
                fMove = 4'd3;
                {HEX7, HEX6, HEX5, HEX4} = 16'h6900;
                {HEX3, HEX2, HEX1, HEX0} = 16'h1350;
                blank = 8'b0011_0001;
            end
            HOLD_H2_WIN7, HOLD_H4_WIN2, HOLD_H7_WIN2, HOLD_H8_WIN2: begin
                fMove = 4'd3;
                {HEX3, HEX2, HEX1, HEX0} = 16'h1350;
                blank = 8'b0001_0001;
                case (currState)
                    HOLD_H2_WIN7: {HEX7, HEX6, HEX5, HEX4} = 16'h2690;
                    HOLD_H4_WIN2: {HEX7, HEX6, HEX5, HEX4} = 16'h4690;
                    HOLD_H7_WIN2: {HEX7, HEX6, HEX5, HEX4} = 16'h6790;
                    default:     {HEX7, HEX6, HEX5, HEX4} = 16'h6890;
                endcase
            end
            WIN9_H2, WIN9_H3, WIN9_H4, WIN9_H7, WIN9_H8: begin
                fMove = 4'd9;
                win = 1'b1;
                {HEX3, HEX2, HEX1, HEX0} = 16'h1590;
                blank = 8'b0011_0001;
                case (currState)
                    WIN9_H2: {HEX7, HEX6, HEX5, HEX4} = 16'h2600;
                    WIN9_H3: {HEX7, HEX6, HEX5, HEX4} = 16'h3600;
                    WIN9_H4: {HEX7, HEX6, HEX5, HEX4} = 16'h4600;
                    WIN9_H7: {HEX7, HEX6, HEX5, HEX4} = 16'h6700;
                    default: {HEX7, HEX6, HEX5, HEX4} = 16'h6800;
                endcase
            end
            WIN7_H2: begin
                fMove = 4'd7;
                win = 1'b1;
                {HEX7, HEX6, HEX5, HEX4} = 16'h2690;
                {HEX3, HEX2, HEX1, HEX0} = 16'h1357;
                blank = 8'b0001_0000;
            end
            WIN2_H4, WIN2_H7, WIN2_H8: begin
                fMove = 4'd2;
                win = 1'b1;
                {HEX3, HEX2, HEX1, HEX0} = 16'h1235;
                blank = 8'b0001_0000;
                case (currState)
                    WIN2_H4: {HEX7, HEX6, HEX5, HEX4} = 16'h4690;
                    WIN2_H7: {HEX7, HEX6, HEX5, HEX4} = 16'h6790;
                    default: {HEX7, HEX6, HEX5, HEX4} = 16'h6890;
                endcase
            end
            default: begin end
        endcase
    end

    always_ff @(posedge clock)
        if (reset) begin
            currState <= START5;
            restartState <= WAIT_NEW_RELEASE;
        end
        else begin
            currState <= nextState;
            restartState <= nextRestartState;
        end
endmodule : myAbstractFSM
