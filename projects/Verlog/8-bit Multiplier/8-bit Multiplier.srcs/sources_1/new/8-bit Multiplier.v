`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/13/2025 10:16:13 AM
// Design Name: 
// Module Name: 8-bit Multiplier
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


module Multiplier(
    input [15:0] sw, //initialize switches as inputs
    output reg [15:0] led //initialize leds as outputs
    );
    
    wire signed [7:0] left_sw = sw[15:8]; //seperate the main switches into a left set and a right set
    wire signed [7:0] right_sw = sw[7:0];
    
    wire signed [15:0] p0, p1, p2, p3, p4, p5, p6, p7; //setupt variables for each step of the multiplication process
    wire signed [15:0] product; //store the final product of the mutliplication
    
    //perform the multiplication
    assign p0 = {{8{left_sw[7] & right_sw[0]}}, {8{right_sw[0]}} & left_sw[7:0]};
    assign p1 = {{7{left_sw[7] & right_sw[1]}}, ({8{right_sw[1]}} & left_sw[7:0]),1'b0};
    assign p2 = {{6{left_sw[7] & right_sw[2]}}, ({8{right_sw[2]}} & left_sw[7:0]),2'b0};
    assign p3 = {{5{left_sw[7] & right_sw[3]}}, ({8{right_sw[3]}} & left_sw[7:0]),3'b0}; 
    assign p4 = {{4{left_sw[7] & right_sw[4]}}, ({8{right_sw[4]}} & left_sw[7:0]),4'b0}; 
    assign p5 = {{3{left_sw[7] & right_sw[5]}}, ({8{right_sw[5]}} & left_sw[7:0]),5'b0}; 
    assign p6 = {{2{left_sw[7] & right_sw[6]}}, ({8{right_sw[6]}} & left_sw[7:0]),6'b0}; 
    assign p7 = -({1'b0, {8{right_sw[7]}} & left_sw[7:0], 7'b0});
    
    //add everything together to get the final product
    assign product = p0 + p1 + p2 + p3 + p4 + p5 + p6 + p7;
    
    //set the LEDs to the product
    always @(product)
    begin
        led = product;
    end
   
endmodule
