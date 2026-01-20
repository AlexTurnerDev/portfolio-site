`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/20/2025 10:17:09 AM
// Design Name: 
// Module Name: sseg_x4 _top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module sseg_x4_top(
    input [15:0] sw,
    input btnC,
    output [6:0] seg,
    output [3:0] an,
    output dp,
    output [4:0] JA,
    input clk
    );
    
    wire clkd;
    wire [3:0] not_used;
    wire [3:0] hex_num;
    
    //instantiate clk_gen
    clk_gen U1 (
        .clk(clk),
        .rst(btnC),
        .clkd(clkd)
    );
    
    //instantiate digit_selector
    digit_selector U2 (
        .clk(clkd),
        .rst(btnC),
        .digit_sel(an)
    );
    
    //instantiate hex_num_gen
    hex_num_gen U3(
        .digit_sel(an),
        .sw(sw),
        .hex_num(hex_num)
    );
    
    //instantiate sseg
    sseg U4 (
        .seg(seg),
        .an(not_used),
        .dp(dp),
        .sw(hex_num)
    );
    
    assign JA[0] = clkd;    // slowed clk signal
    assign JA[1] = an[0];   // Anode for digit 1
    assign JA[2] = an[1];   // Anode for digit 2
    assign JA[3] = an[2];   // Anode for digit 3
    assign JA[4] = an[3];   // Anode for digit 4
endmodule
