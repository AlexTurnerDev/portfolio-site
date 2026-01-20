`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/07/2025 10:34:11 PM
// Design Name: 
// Module Name: grey_counter_top
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


module grey_counter_top(
    input btnC,
    input clk,
    output [2:0] led
    );
    
    wire clkd;
    
    clock_gen U1 (
        .clk(clk),
        .rst(btnC),
        .clkd(clkd)
    );
    
    grey_counter U2 (
        .clk(clkd),
        .rst(btnC),
        .state(led)
    );
    
    
endmodule
