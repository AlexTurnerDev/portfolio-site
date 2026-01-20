`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/24/2025 10:02:24 AM
// Design Name: 
// Module Name: decoder
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


module decoder_structural(
    input [2:0] sw,
    output [7:0] led
    );
    

    wire nsw_0, nsw_1, nsw_2;//creates wires for the not gates

    not not_gate0 (nsw_0, sw[0]);//creates a not gate for s0
    not not_gate1 (nsw_1, sw[1]);//creates a not gate for s1
    not not_gate2 (nsw_2, sw[2]);//creates a not gate for s2

    and and_gate0 (led[0], nsw_2, nsw_1, nsw_0);//if sw= 000 then led0 turns on
    and and_gate1 (led[1], nsw_2, nsw_1, sw[0]);//if sw= 001 then led1 turns on
    and and_gate2 (led[2], nsw_2, sw[1],  nsw_0);//if sw= 010 then led2 turns on
    and and_gate3 (led[3], nsw_2, sw[1],  sw[0]);//if sw= 011 then led3 turns on
    and and_gate4 (led[4], sw[2],  nsw_1, nsw_0);//if sw= 100 then led4 turns on
    and and_gate5 (led[5], sw[2],  nsw_1, sw[0]);//if sw= 101 then led5 turns on
    and and_gate6 (led[6], sw[2],  sw[1],  nsw_0);//if sw= 110 then led6 turns on
    and and_gate7 (led[7], sw[2],  sw[1],  sw[0]);//if sw= 111 then led7 turns on
    
endmodule
