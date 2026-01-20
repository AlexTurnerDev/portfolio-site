`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/09/2025 07:38:26 PM
// Design Name: 
// Module Name: mealy_101_detector
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


module mealy_101_detector(
    input clk,
    input rst,
    input A,
    output reg B
    );
    
    reg [1:0] y, Y;
    
    parameter S0 = 2'b00, S1 = 2'b01, S2 = 2'b10;
    
    always @(A, y) begin
        case (y)
            S0: begin
                if(A) begin
                    Y = S1;
                    B = 0;
                end
                else begin
                    Y = S0;
                    B = 0;
                end
            end
            
            S1: begin 
                if(A) begin
                    Y = S1;
                    B = 0;
                end
                else begin
                    Y = S2;
                    B = 0;
                end 
            end
            
            S2: begin
                if (A) begin
                    Y = S1;
                    B = 1;
                end
                else begin
                    Y = S0;
                    B = 0;
                end
            end
            
            default: begin
                Y = S0;
                B = 0;
            end
        endcase
   end
   
   always @(negedge rst, posedge clk) begin
       if (!rst) y <= S0;
       else y <= Y;
   end
endmodule
