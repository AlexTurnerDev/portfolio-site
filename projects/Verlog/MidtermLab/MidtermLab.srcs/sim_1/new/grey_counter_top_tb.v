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


module grey_counter_top_tb(
    );
    
    reg btnC;
    reg clk;
    wire [2:0] led;
    
    grey_counter_top UUT(
        .btnC(btnC),
        .clk(clk),
        .led(led)
    );
    
    initial
        clk = 0;
    always #5
        clk = ~clk;
        
    initial
    begin
        btnC = 1'b1;
        
        #20;
        
        btnC = 1'b0;
        
        #1000000;
        
        $finish;
        
     end
endmodule
