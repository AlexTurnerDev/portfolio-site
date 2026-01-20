`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/20/2025 11:52:57 AM
// Design Name: 
// Module Name: sseg_x4_tb
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


module sseg_x4_tb(
    );
    
    reg clk;
    reg btnC;
    reg [15:0] sw;
    
    wire [6:0] seg;
    wire [3:0] an;
    wire dp;
    wire [4:0] JA;
    
    
    sseg_x4_top uut(
        .clk(clk),
        .btnC(btnC),
        .sw(sw),
        .seg(seg),
        .an(an),
        .dp(dp),
        .JA(JA)
    );
    
    initial
        clk = 0;
    always #5 
        clk = ~clk;
    
    initial
    begin        
        btnC = 1'b1;
        sw = 16'h4321;
        
        #20;
        
        btnC = 1'b0;
        
        #5000000;
        
        $finish;
        
    end
endmodule
