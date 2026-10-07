
module ChipInterface
    (output logic [ 6:0] DS1_SEG , DS2_SEG,
     output logic DS1_DP , DS1_AN , DS2_DP , DS2_AN ,
     output logic [17:0] LD ,
     output logic [ 2:0] RGB0 , RGB1 ,
     input logic [17:0] SW ,
     input logic [ 3:0] BTN );

    logic       clock;
    logic       reset_N;
    logic [3:0] hMove;
    logic [3:0] fMove;
    logic       win;

    assign clock = BTN[3];
    assign reset_N = SW[17];
    assign hMove = SW[15:12];

    myExplicitFSM fsm (.fMove, .win, .hMove, .clock, .reset(reset_N));

    // For Part 2, comment out the line above and uncomment this line.
    // myAbstractFSM fsm (.fMove, .win, .hMove, .clock, .reset(reset_N));

    HextoSevenSegment human_move_display (.hex(hMove), .segment(DS1_SEG));
    HextoSevenSegment fsm_move_display   (.hex(fMove), .segment(DS2_SEG));

    assign DS1_AN = 1'b0;
    assign DS2_AN = 1'b0;
    assign DS1_DP = 1'b1;
    assign DS2_DP = 1'b1;

endmodule : ChipInterface
