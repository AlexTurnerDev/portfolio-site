`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/17/2025 10:04:09 AM
// Design Name: 
// Module Name: memory
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


module memory(
     input wire oe, we, clk,
     input wire [3:0] addr,
     inout wire [15:0] data
     ); 
    reg [15:0] mem [15:0];

    assign data = (oe && !we) ? mem[addr]:16'hZZZZ;
    always@(posedge clk)  
    begin 
        if (we) mem[addr] <= data; 
    end 
endmodule 

