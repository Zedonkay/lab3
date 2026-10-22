`default_nettype none
//AI (codex 4ish messages) used to clean up the code (style things) 
//AI (codex 5ish messages) used to rsync to ece before starting git

// Uncomment exactly one complete ChipInterface module, including its header.
// Part 3 is selected.

// Part 1
// module ChipInterface (
//     output logic [6:0] DS1_SEG, DS2_SEG,
//     output logic DS1_DP, DS1_AN, DS2_DP, DS2_AN,
//     output logic [17:0] LD,
//     output logic [2:0] RGB0, RGB1,
//     input logic [17:0] SW,
//     input logic [3:0] BTN
// );
//     logic clock, reset, win;
//     logic [3:0] hMove, fMove;
//
//     assign clock = BTN[3];
//     assign reset = SW[17];
//     assign hMove = SW[15:12];
//
//     myExplicitFSM fsm (.fMove, .win, .q0(), .q1(), .q2(), 
//                        .hMove, .clock, .reset);
//
//     HextoSevenSegment fsm_move_display (.hex(fMove), .segment(DS2_SEG));
//
//     assign DS1_SEG = 7'b1111111;
//     assign DS1_DP = 1'b1;
//     assign DS1_AN = 1'b1;
//     assign DS2_DP = 1'b1;
//     assign DS2_AN = 1'b0;
//     assign LD = '0;
//     assign RGB0 = {1'b0, win, 1'b0};
//     assign RGB1 = '0;
// endmodule : ChipInterface

// Part 2
// module ChipInterface (
//     output logic [6:0] DS1_SEG, DS2_SEG,
//     output logic DS1_DP, DS1_AN, DS2_DP, DS2_AN,
//     output logic [17:0] LD,
//     output logic [2:0] RGB0, RGB1,
//     input logic [17:0] SW,
//     input logic [3:0] BTN
// );
//     logic clock, reset, win;
//     logic [3:0] hMove, fMove;
//
//     assign clock = BTN[3];
//     assign reset = SW[17];
//     assign hMove = SW[15:12];
//
//     myAbstractFSM fsm (.fMove, .win, .hMove, .clock, .reset);
//
//     HextoSevenSegment fsm_move_display (.hex(fMove), .segment(DS2_SEG));
//
//     assign DS1_SEG = 7'b1111111;
//     assign DS1_DP = 1'b1;
//     assign DS1_AN = 1'b1;
//     assign DS2_DP = 1'b1;
//     assign DS2_AN = 1'b0;
//     assign LD = '0;
//     assign RGB0 = {1'b0, win, 1'b0};
//     assign RGB1 = '0;
// endmodule : ChipInterface

// Part 3
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
