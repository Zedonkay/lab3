`timescale 1ns/1ps
`default_nettype none

module part3_tb;
    logic clock = 0;
    always #5 clock = ~clock;
    logic reset, enter, new_game;
    logic [3:0] hMove, fMove;
    logic win;
    logic [3:0] HEX7, HEX6, HEX5, HEX4, HEX3, HEX2, HEX1, HEX0;
    logic [7:0] blank;
    myAbstractFSM dut (.*);

    logic [17:0] SW;
    logic [3:0] BTN;
    wire [17:0] LD;
    wire [2:0] RGB0, RGB1;
    wire [3:0] D1_AN, D2_AN;
    wire [7:0] D1_SEG, D2_SEG;
    ChipInterface board (.CLOCK_100(clock), .*);
    integer checks = 0;

    task automatic tick;
        @(posedge clock); #1;
    endtask

    task automatic check_outputs(
        input logic [3:0] expected_move,
        input logic expected_win,
        input logic [15:0] human_digits, fpga_digits,
        input logic [7:0] expected_blank
    );
        checks = checks + 1;
        if ({fMove, win, HEX7, HEX6, HEX5, HEX4,
             HEX3, HEX2, HEX1, HEX0, blank} !==
            {expected_move, expected_win, human_digits, fpga_digits, expected_blank})
            $fatal(1, "state=%0d: got f=%h win=%b H=%h F=%h blank=%h; expected %h %b %h %h %h",
                dut.currState, fMove, win, {HEX7, HEX6, HEX5, HEX4},
                {HEX3, HEX2, HEX1, HEX0}, blank,
                expected_move, expected_win, human_digits, fpga_digits, expected_blank);
    endtask

    task automatic check_start;
        check_outputs(5, 0, 16'h0000, 16'h5000, 8'hf7);
    endtask

    task automatic check_win9;
        check_outputs(9, 1, 16'h2600, 16'h1590, 8'h31);
    endtask

    task automatic reset_game;
        reset = 1; enter = 0; new_game = 0; hMove = 0;
        tick(); check_start();
        reset = 0;
        tick(); check_start();
    endtask

    task automatic submit(
        input logic [3:0] move_value, old_fpga_move, next_fpga_move,
        input logic next_win,
        input logic [15:0] human_digits, old_fpga_digits, next_fpga_digits,
        input logic [7:0] held_blank, released_blank
    );
        hMove = move_value; enter = 1;
        tick();
        check_outputs(old_fpga_move, 0, human_digits, old_fpga_digits, held_blank);
        for (int v = 0; v < 16; v++) begin
            hMove = v; tick();
            check_outputs(old_fpga_move, 0, human_digits, old_fpga_digits, held_blank);
        end
        enter = 0; tick();
        check_outputs(next_fpga_move, next_win, human_digits, next_fpga_digits, released_blank);
    endtask

    task automatic first_move;
        submit(6, 5, 1, 0, 16'h6000, 16'h5000, 16'h1500, 8'h77, 8'h73);
    endtask

    task automatic second_nine;
        submit(9, 1, 3, 0, 16'h6900, 16'h1500, 16'h1350, 8'h33, 8'h31);
    endtask

    task automatic restart_terminal(
        input logic [3:0] expected_move,
        input logic [15:0] human_digits, fpga_digits,
        input logic [7:0] expected_blank
    );
        tick();
        check_outputs(expected_move, 1, human_digits, fpga_digits, expected_blank);
        enter = 1; tick();
        check_outputs(expected_move, 1, human_digits, fpga_digits, expected_blank);
        new_game = 1; tick();
        check_outputs(expected_move, 1, human_digits, fpga_digits, expected_blank);
        new_game = 0; tick();
        check_outputs(expected_move, 1, human_digits, fpga_digits, expected_blank);
        enter = 0; tick(); check_start();
    endtask

    task automatic reach_win;
        reset_game(); first_move();
        submit(2, 1, 9, 1, 16'h2600, 16'h1500, 16'h1590, 8'h33, 8'h31);
        tick(); check_win9();
    endtask

    initial begin
        logic [15:0] human_digits;
        SW = 0; SW[15] = 1; BTN = 0;
        reset_game();

        for (int v = 0; v < 16; v++) begin
            if (v != 6) begin
                reset_game(); hMove = v; enter = 1; tick(); check_start();
                hMove = 6; repeat (4) tick(); check_start();
                enter = 0; tick(); check_start();
            end
        end
        for (int v = 0; v < 16; v++) begin
            reset_game(); first_move();
            if (v == 2 || v == 3 || v == 4 || v == 7 || v == 8) begin
                case (v)
                    2: human_digits = 16'h2600;
                    3: human_digits = 16'h3600;
                    4: human_digits = 16'h4600;
                    7: human_digits = 16'h6700;
                    8: human_digits = 16'h6800;
                endcase
                submit(v, 1, 9, 1, human_digits, 16'h1500, 16'h1590, 8'h33, 8'h31);
                repeat (3) tick();
                check_outputs(9, 1, human_digits, 16'h1590, 8'h31);
                restart_terminal(9, human_digits, 16'h1590, 8'h31);
                reset_game();
            end
            else if (v == 9) second_nine();
            else begin
                hMove = v; enter = 1; tick();
                check_outputs(1, 0, 16'h6000, 16'h1500, 8'h73);
                hMove = 9; repeat (4) tick();
                check_outputs(1, 0, 16'h6000, 16'h1500, 8'h73);
                enter = 0; tick();
                check_outputs(1, 0, 16'h6000, 16'h1500, 8'h73);
            end
        end
        for (int v = 0; v < 16; v++) begin
            reset_game(); first_move(); second_nine();
            if (v == 2 || v == 4 || v == 7 || v == 8) begin
                case (v)
                    2: human_digits = 16'h2690;
                    4: human_digits = 16'h4690;
                    7: human_digits = 16'h6790;
                    8: human_digits = 16'h6890;
                endcase
                submit(v, 3, (v == 2 ? 7 : 2), 1, human_digits,
                    16'h1350, (v == 2 ? 16'h1357 : 16'h1235), 8'h11, 8'h10);
                restart_terminal((v == 2 ? 7 : 2), human_digits,
                    (v == 2 ? 16'h1357 : 16'h1235), 8'h10);
                reset_game();
            end
            else begin
                hMove = v; enter = 1; tick();
                check_outputs(3, 0, 16'h6900, 16'h1350, 8'h31);
                hMove = 2; repeat (4) tick();
                check_outputs(3, 0, 16'h6900, 16'h1350, 8'h31);
                enter = 0; tick();
                check_outputs(3, 0, 16'h6900, 16'h1350, 8'h31);
            end
        end

        reach_win(); repeat (5) tick(); check_win9();
        enter = 1; repeat (5) tick(); check_win9();
        enter = 0; tick(); check_win9();

        new_game = 1; repeat (5) tick(); check_win9();
        new_game = 0; tick(); check_start();

        reach_win(); new_game = 1; tick();
        enter = 1; tick(); check_win9();
        enter = 0; tick(); check_win9();
        new_game = 0; tick(); check_start();

        reach_win(); enter = 1; tick(); new_game = 1; tick();
        enter = 0; tick(); check_win9();
        new_game = 0; tick(); check_start();

        reach_win(); enter = 1; tick(); new_game = 1; tick();
        new_game = 0; repeat (4) tick(); check_win9();
        new_game = 1; tick(); new_game = 0; tick(); check_win9();
        enter = 0; tick(); check_start();

        reach_win(); new_game = 1; tick(); enter = 1; tick();
        new_game = 0; repeat (4) tick(); check_win9();
        enter = 0; tick(); check_start();

        reach_win(); enter = 1; tick(); new_game = 1; tick();
        enter = 0; tick(); check_win9();
        enter = 1; tick(); new_game = 0; tick(); check_win9();
        enter = 0; tick(); check_start();

        reset_game(); new_game = 1; tick(); new_game = 0; tick();
        check_start(); first_move();
        submit(2, 1, 9, 1, 16'h2600, 16'h1500, 16'h1590, 8'h33, 8'h31);
        repeat (4) tick(); check_win9();

        reset_game(); first_move(); new_game = 1;
        submit(2, 1, 9, 1, 16'h2600, 16'h1500, 16'h1590, 8'h33, 8'h31);
        repeat (4) tick(); check_win9();
        new_game = 0; tick(); check_win9();
        new_game = 1; tick(); check_win9();
        new_game = 0; tick(); check_start();

        reset_game(); hMove = 6; enter = 1; tick();
        reset = 1; tick(); check_start();
        reset_game(); first_move(); hMove = 2; enter = 1; tick();
        reset = 1; tick(); check_start();
        reset_game(); first_move(); second_nine(); hMove = 4; enter = 1; tick();
        reset = 1; tick(); check_start();
        reset_game(); hMove = 0; enter = 1; tick();
        reset = 1; tick(); check_start();

        repeat (5) tick();
        if (LD !== 18'd5 || RGB1 !== 0 || RGB0 !== 0)
            $fatal(1, "Board reset outputs incorrect");
        SW[15] = 0; repeat (5) tick();
        SW[3:0] = 6; repeat (5) tick();
        BTN[3] = 1; repeat (5) tick();
        if (LD !== 18'd5 || board.HEX7 !== 6 || board.blank !== 8'h77)
            $fatal(1, "Board enter press incorrect");
        SW[3:0] = 9; repeat (5) tick();
        BTN[3] = 0; repeat (5) tick();
        if (LD !== 18'd1 || board.HEX7 !== 6)
            $fatal(1, "Board hold/release incorrect");
        SW[3:0] = 2; repeat (5) tick();
        BTN[3] = 1; repeat (5) tick();
        BTN[3] = 0; repeat (5) tick();
        if (LD !== 18'd9 || RGB1 !== 3'b101 || board.blank !== 8'h31)
            $fatal(1, "Board winning outputs incorrect");
        BTN[0] = 1; repeat (5) tick();
        BTN[0] = 0; repeat (5) tick();
        if (LD !== 18'd5 || RGB1 !== 0 || board.blank !== 8'hf7)
            $fatal(1, "Board restart incorrect");

        SW[15] = 1; repeat (5) tick();
        SW[15] = 0; repeat (5) tick();
        if (D1_AN !== 4'b1110 || D2_AN !== 4'b1110 ||
            D1_SEG !== 8'hff || D2_SEG !== 8'hff)
            $fatal(1, "Display index zero incorrect");
        repeat (100001) tick();
        if (D1_AN !== 4'b1101 || D2_AN !== 4'b1101 || D2_SEG !== 8'hff)
            $fatal(1, "Display index one incorrect");
        repeat (100001) tick();
        if (D1_AN !== 4'b1011 || D2_AN !== 4'b1011 || D2_SEG !== 8'hff)
            $fatal(1, "Display index two incorrect");
        repeat (100001) tick();
        if (D1_AN !== 4'b0111 || D2_AN !== 4'b0111 ||
            D1_SEG !== 8'hff || D2_SEG !== 8'h92)
            $fatal(1, "Display index three must show FPGA's initial 5");
        $display("PASS: %0d FSM output checks, board integration and display scan", checks);
        $finish;
    end

    initial begin
        #10000000;
        $fatal(1, "Testbench timed out");
    end
endmodule : part3_tb
