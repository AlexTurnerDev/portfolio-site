`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/24/2025 02:09:27 PM
// Design Name: 
// Module Name: pipelined_multiplier_tb
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


module pipelined_multiplier_tb();

    reg clk;
    reg [7:0] left;
    reg [7:0] right;
    wire [15:0] result;
    
    pipelined_multiplier uut(
        .clk(clk),
        .left(left),
        .right(right),
        .result(result)
    );
    
    always #5
        clk = ~clk;
        
    initial begin
        clk = 0;
        left = 0;
        right = 0;
        
        #10
        left = 3;
        right = 5;
        
        #20
        left = 20;
        right = 10;
        
        #20
        left = 1;
        right = 0;
        
        #20
        
        $finish;
    end
endmodule
