`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/29/2025 09:49:06 AM
// Design Name: 
// Module Name: adder8
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


module adder8(
    input [15:0] sw, //switch inputs
    output [8:0] led //led outputs
    );
    
    wire [7:0]a = sw[7:0]; //split up the switches into two sets
    wire [7:0]b = sw[15:8];
    wire [7:1]c; //carry over
        
    generate //make a block of code that could create structures
        genvar i;
        for (i = 0; i < 8; i = i + 1) begin : ripple_carry_stage //we have two sets of 8 switchs so loop 8 times. Give it a name so we can access the created structures
            fulladd stage ( //call the fulladd module and while specifying the variable to change give them a value
                .Cin(c[i]),
                .x(a[i]),
                .y(b[i]),
                .s(led[i]),
                .Cout(c[i+1])
            );
        end
    endgenerate
    
    assign led[8] = c[8]; // we can't do this in the loop so we must assign the final carryout to a carry out bit LED
    
endmodule

module fulladd(
    input Cin, x, y, //inputs carry, one bit and another bit to add
    output s, Cout //should we turn on the led, is there a carry out
    );
    
    xor (s, x, y, Cin); //make the logic
    and (z1, x, y),
        (z2, x, Cin),
        (z3, y, Cin);
    or (Cout, z1, z2, z3);
endmodule
    
