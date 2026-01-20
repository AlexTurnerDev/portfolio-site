`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/08/2025 09:16:38 AM
// Design Name: 
// Module Name: seg7_tb
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


module seg7_tb(
    );
    
    reg [3:0] sw;
    wire [6:0] seg;
    wire [3:0] an;
    wire dp;
    
    seg7 uut (
        .sw(sw),
        .seg(seg),
        .an(an),
        .dp(dp)
    );
    
    initial
    begin
        sw = 4'h0;
        
        #100
        
        for (integer i = 0; i < 10; i = i + 1) 
        begin
            sw = i;
            #10;
        end
        
        $finish;
    end
    
endmodule
