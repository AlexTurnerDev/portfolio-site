`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/22/2025 10:14:08 AM
// Design Name: 
// Module Name: digit_selector
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


module digit_selector(
    input clk,
    input rst,
    output reg [3:0] digit_sel
    );
    
    //count is a register we will count through
    reg [1:0] count;
    
    
    //counter to count through count
    always @ (posedge clk or posedge rst)
        begin
            if (rst)
                count <= 2'b0; //if rst is true then restart count
            else
                count <= count + 1; //if rst is false keep counting
        end     
        
    //check the state on count and depending on its state set digit_sel to one of the 4 displays
    always @(*)
        begin
            case (count)
                2'b00: digit_sel = 4'b1110;
                2'b01: digit_sel = 4'b1101;
                2'b10: digit_sel = 4'b1011;
                2'b11: digit_sel = 4'b0111;
                default: digit_sel = 4'b1111;
            endcase
        end
        
endmodule
