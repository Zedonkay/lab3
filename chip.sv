
module ChipInterface
    (output logic [ 3:0] D2_AN , D1_AN,
     output logic [ 7:0] D2_SEG, D1_SEG,
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

    EightSevenSegmentDisplays displays (
        .HEX7(4'h0), .HEX6(4'h0), .HEX5(4'h0), .HEX4(4'h0),
        .HEX3(4'h0), .HEX2(4'h0), .HEX1(fMove), .HEX0(hMove),
        .CLOCK_100(clock),
        .reset(reset_N),
        .dec_points(8'b0),
        .blank(8'b1111_1100),
        .D2_AN,
        .D1_AN,
        .D2_SEG,
        .D1_SEG
    );

endmodule : ChipInterface
