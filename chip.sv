
module ChipInterface
    (output logic [ 6:0] DS1_SEG, DS2_SEG,
     output logic       DS1_DP, DS1_AN, DS2_DP, DS2_AN,
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

    // myAbstractFSM fsm (.fMove, .win, .hMove, .clock, .reset(reset_N));

    HextoSevenSegment fsm_move_display (.hex(fMove), .segment(DS2_SEG));

    // DS1 is unused; all active-low display signals are held blank.
    assign DS1_SEG = 7'b1111111;
    assign DS1_DP = 1'b1;
    assign DS1_AN = 1'b1;

    // DS2 is continuously enabled and its decimal point remains blank.
    assign DS2_DP = 1'b1;
    assign DS2_AN = 1'b0;

    assign LD = '0;
    assign RGB0 = {1'b0, win, 1'b0};
    assign RGB1 = '0;

endmodule : ChipInterface
