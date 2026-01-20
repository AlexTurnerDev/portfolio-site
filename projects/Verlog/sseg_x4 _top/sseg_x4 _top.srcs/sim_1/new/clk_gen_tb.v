`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/20/2025 11:10:06 AM
// Design Name: 
// Module Name: clk_gen_tb
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


module clk_gen_tb(
    );
    
    wire clk;
    wire reset;
    wire clkd;
    
    clk_gen uut (
        .clk(clk),
        .reset(reset),
        .clkd(clkd)
    );
    
    initial
    
    begin
        
    
endmodule
