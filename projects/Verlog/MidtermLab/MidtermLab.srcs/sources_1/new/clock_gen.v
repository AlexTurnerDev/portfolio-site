`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/06/2025 08:01:12 PM
// Design Name: 
// Module Name: clock_gen
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


module clock_gen(
    input clk,
    input rst,
    output clkd
    );
    
    reg [25:0] reg_count;
    
    always @ (posedge clk)
        begin
            if(rst)
                reg_count <= 26'b0;
            else
                reg_count <= reg_count + 1;
        end
        
    assign clkd = reg_count[25];
        
endmodule
