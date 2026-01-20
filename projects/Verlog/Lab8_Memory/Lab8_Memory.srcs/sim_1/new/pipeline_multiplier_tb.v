`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/24/2025 06:04:19 PM
// Design Name: 
// Module Name: pipeline_multiplier_tb
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

    pipelined_multiplier uut (
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
        right = 2;
        
        #20; 
        left = 0; 
        right = 120;
        
        #20;
        left = 200; 
        right = 4;
        
        #20;
        left = 5; 
        right = 15;
        
        #20;

        $finish;
    end
endmodule
