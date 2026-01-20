`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/27/2025 11:00:06 AM
// Design Name: 
// Module Name: hex_num_gen
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


module hex_num_gen(
    input [3:0] digit_sel,
    input [15:0] sw,
    output reg [3:0] hex_num
    );
    
    //break up the 16 switches into four sets each one determiens the value of an individual display segment
    wire [3:0] digit4 = sw[15:12];
    wire [3:0] digit3 = sw[11:8];
    wire [3:0] digit2 = sw[7:4];
    wire [3:0] digit1 = sw[3:0];
    
    //check the state of digit_sel
    //depending on its state set hex_num to the correct set of switches for that display
    //so we can output the correct value
    always @ (*)
        case (digit_sel)
            4'b1110: hex_num = digit1;
            4'b1101: hex_num = digit2;
            4'b1011: hex_num = digit3;
            4'b0111: hex_num = digit4;
            default: hex_num = 4'b0000;
        endcase
    
endmodule
