`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/10/2025 10:11:42 AM
// Design Name: 
// Module Name: clk_gen
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


module clk_gen(
    input clk,
    input rst,
    output reg clk_1Hz
    );  
    
    reg [25:0] count;
    always @ (posedge clk, posedge rst)
        if (rst)
        begin
            count <= 0;
            clk_1Hz <= 0;
        end
        else if (count < 50000000)
            count <= count +1;
        else
        begin
            count <= 0;
            clk_1Hz <= !clk_1Hz;
        end
endmodule
