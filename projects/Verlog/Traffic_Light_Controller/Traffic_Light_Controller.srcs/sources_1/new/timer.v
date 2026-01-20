`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/10/2025 10:31:54 AM
// Design Name: 
// Module Name: timer
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


module timer #(
    parameter MAX_COUNT = 3
    ) (
    input clk_1Hz,
    input rst,
    input start_pulse,
    output reg tm_done
    );
    
    reg [$clog2(MAX_COUNT):0] count;
    
    always @(posedge clk_1Hz, posedge start_pulse, posedge rst) begin
        if(start_pulse || rst) begin
            count <= 0;
            tm_done <= 0;
        end
        else if(count < MAX_COUNT - 1) begin
            count <= count + 1;    
            tm_done <= 0;
        end
        else begin
            tm_done <= 1;
        end
    end
endmodule
