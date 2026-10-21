`default_nettype none

module ChipInterface (
    output logic [3:0] D1_AN, D2_AN,
    output logic [7:0] D1_SEG, D2_SEG,
    output logic [17:0] LD,
    output logic [2:0] RGB0, RGB1,
    input logic [17:0] SW,
    input logic [3:0] BTN,
    input logic CLOCK_100
);
    logic [3:0] hMove, fMove;
    logic clock, enter, new_game, reset, win;
    logic [3:0] HEX7, HEX6, HEX5, HEX4, HEX3, HEX2, HEX1, HEX0;
    logic [7:0] blank;

    (* ASYNC_REG = "TRUE" *) logic [6:0] inputs_meta, inputs_sync;
    always_ff @(posedge CLOCK_100) begin
        inputs_meta <= {SW[15], BTN[0], BTN[3], SW[3:0]};
        inputs_sync <= inputs_meta;
    end

    // Uncomment exactly one complete Part block. Part 3 is selected below.

    // Part 1: BTN[3] clocks; SW[17] resets; SW[15:12] selects hMove.
    // assign clock = BTN[3];
    // assign reset = SW[17];
    // assign hMove = SW[15:12];
    // assign enter = 1'b0;
    // assign new_game = 1'b0;
    // myExplicitFSM fsm (
    //     .fMove, .win, .q0(), .q1(), .q2(), .hMove, .clock, .reset
    // );
    // assign {HEX7, HEX6, HEX5, HEX4} = {hMove, 12'b0};
    // assign {HEX3, HEX2, HEX1, HEX0} = {fMove, 12'b0};
    // assign blank = 8'b0111_0111;

    // Part 2: BTN[3] clocks; SW[17] resets; SW[15:12] selects hMove.
    // assign clock = BTN[3];
    // assign reset = SW[17];
    // assign hMove = SW[15:12];
    // assign enter = 1'b0;
    // assign new_game = 1'b0;
    // myAbstractFSM fsm (.fMove, .win, .hMove, .clock, .reset);
    // assign {HEX7, HEX6, HEX5, HEX4} = {hMove, 12'b0};
    // assign {HEX3, HEX2, HEX1, HEX0} = {fMove, 12'b0};
    // assign blank = 8'b0111_0111;

    // Part 3: 100 MHz clock; SW[15] resets; SW[3:0] selects hMove.
    // BTN[3] enters a move; BTN[0] requests a new game.
    assign clock = CLOCK_100;
    assign {reset, new_game, enter, hMove} = inputs_sync;
    myExpandedFSM fsm (
        .fMove, .win, .HEX7, .HEX6, .HEX5, .HEX4,
        .HEX3, .HEX2, .HEX1, .HEX0, .blank,
        .hMove, .enter, .new_game, .clock, .reset
    );

    EightSevenSegmentDisplays displays (
        .HEX7, .HEX6, .HEX5, .HEX4, .HEX3, .HEX2, .HEX1, .HEX0,
        .CLOCK_100, .reset, .blank, .dec_points(8'b0),
        .D1_AN, .D2_AN, .D1_SEG, .D2_SEG
    );

    assign LD = {14'b0, fMove};
    assign RGB0 = 3'b000;
    assign RGB1 = win ? 3'b101 : 3'b000;
endmodule : ChipInterface
