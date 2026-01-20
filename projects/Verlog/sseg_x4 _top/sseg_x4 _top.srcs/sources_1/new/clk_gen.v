`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/20/2025 10:23:06 AM
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
    output clkd
    );
    
    //declare a 26 bit register to that we can count through
    reg [25:0] reg_count;
    
    //counter
    always @ (posedge clk)
        begin
            if (rst)
                reg_count <= 26'b0; //if rst is true then reset the counter to 0s
            else
                reg_count <= reg_count + 1; //if rst is false keep counting up
        end
            
    assign clkd = reg_count[16]; //set the new clk signal clkd to bit 16 of reg_count
                
endmodule
