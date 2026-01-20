`timescale 1ns / 1ps
    
module Final_Project(
    input clk,
    input btnC, input btnR, input btnL, input btnU, input btnD,
    output [15:0] led,
    output [6:0] seg,
    output [3:0] an
);

    wire left, right, up, down, center;
    wire mem_we;
    wire [15:0] score_read, score_write, score;
    wire [1:0] dir;
    wire [6:0] count_down;
    
    // UPDATED: 4 bits for debug_state
    wire [3:0] debug_state;
    wire new_record;
    
    debounce_buttons U_Debounce(
        .clk(clk),
        .btnL(btnL), .btnR(btnR), .btnU(btnU), .btnD(btnD), .btnC(btnC),
        .left(left), .right(right), .up(up), .down(down), .center(center)
    );
    
    game_logic U_Game(
        .clk(clk),
        .rst(center),
        .btnL(left), .btnR(right), .btnU(up), .btnD(down),
        .dir_out(dir),
        .count_down(count_down),
        .score(score),
        .score_read(score_read),
        .score_write(score_write),
        .mem_we(mem_we),
        .debug_state(debug_state),
        .new_record(new_record)
    );
    
    memory U_Memory(
        .we(mem_we), .clk(clk), .addr(4'b0),
        .data_in(score_write), .data_out(score_read)
    );
    
    segdisplay_driver U_SegDisplay(
        .clk(clk),
        .rst(center),
        .count_down(count_down),
        .dir(dir),
        .score(score), 
        .high_score_val(score_read), // CONNECTED: Pass read score to display
        .game_state(debug_state), 
        .is_new_record(new_record), 
        .seg(seg),
        .an(an)
    );
    
    // LEDs
    assign led[3:0] = debug_state; // Shows 4-bit state
    assign led[4] = up;    
    assign led[5] = down;
    assign led[6] = left;
    assign led[7] = right;
    assign led[15:8] = score[7:0]; 

endmodule