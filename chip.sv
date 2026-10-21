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
    logic enter, new_game, reset, win;
    logic [3:0] HEX7, HEX6, HEX5, HEX4, HEX3, HEX2, HEX1, HEX0;
    logic [7:0] blank;

    // Synchronize the asynchronous board inputs before using them in the FSM.
    // Set the move switches before pressing enter. These are synchronizers,
    // not mechanical-button debouncers.
    (* ASYNC_REG = "TRUE" *) logic [6:0] inputs_meta, inputs_sync;
    always_ff @(posedge CLOCK_100) begin
        inputs_meta <= {SW[15], BTN[0], BTN[3], SW[3:0]};
        inputs_sync <= inputs_meta;
    end
    assign {reset, new_game, enter, hMove} = inputs_sync;

    myAbstractFSM fsm (
        .fMove, .win, .HEX7, .HEX6, .HEX5, .HEX4,
        .HEX3, .HEX2, .HEX1, .HEX0, .blank,
        .hMove, .enter, .new_game, .clock(CLOCK_100), .reset
    );

    EightSevenSegmentDisplays displays (
        .HEX7, .HEX6, .HEX5, .HEX4, .HEX3, .HEX2, .HEX1, .HEX0,
        .CLOCK_100, .reset, .blank, .dec_points(8'b0),
        .D1_AN, .D2_AN, .D1_SEG, .D2_SEG
    );

    assign LD = {14'b0, fMove};
    assign RGB0 = 3'b000;
    // Both red and blue are on for purple (active-high RGB channels).
    assign RGB1 = win ? 3'b101 : 3'b000;
endmodule : ChipInterface
