`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/09/2025 07:13:14 PM
// Design Name: 
// Module Name: moore_101_detector
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


module moore_101_detector(
    input clk,
    input rst,
    input A,
    output B
    );
    
    reg [1:0] y, Y;
    
    parameter [2:1] S0 = 2'b00, S1 = 2'b01, S2 = 2'b10, S3 = 2'b11;
    
    always @ (A, y)
    begin
            case (y)
                S0: if(A) Y = S1;
                    else  Y = S0;
                S1: if(A) Y = S1;
                    else  Y = S2;
                S2: if(A) Y = S3;
                    else  Y = S0;
                S3: if(A) Y = S1;
                    else  Y = S2;
                default Y = 2'bxx;
            endcase
     end
     
     assign B = (y == S3);
     
     always @(negedge rst, posedge clk)
        if(!rst) y <= S0;
        else y <= Y;
endmodule
