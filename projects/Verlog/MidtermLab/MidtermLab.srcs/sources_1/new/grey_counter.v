`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/07/2025 06:04:41 PM
// Design Name: 
// Module Name: grey_counter
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


module grey_counter(
    input clk,
    input rst,
    output [2:0] state
    );
    
    reg [2:0] next_state;
    reg [2:0] current_state = 3'b111;
    
    always @ (posedge clk)
    begin
        if (rst)
            current_state <= 3'b000;
        else
            current_state <= next_state;
    end
    
    always @(*)
    begin
        case (current_state)
            3'b000: next_state = 3'b001;
            3'b001: next_state = 3'b101;
            3'b010: next_state = 3'b110;
            3'b011: next_state = 3'b010;
            3'b100: next_state = 3'b000;
            3'b101: next_state = 3'b111;
            3'b110: next_state = 3'b100;
            3'b111: next_state = 3'b011;
            
        endcase
    end
    
    assign state = current_state;
endmodule
