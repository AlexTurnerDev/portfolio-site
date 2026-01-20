`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/24/2025 10:27:54 AM
// Design Name: 
// Module Name: pipelined_multiplier
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


module pipelined_multiplier(
    input clk,
    input [7:0] left,
    input [7:0] right,
    output wire [15:0] result
    );
    
    wire [15:0] parts [7:0]; //setupt variables for each step of the multiplication process
    
    reg [15:0] sum01, sum23, sum45, sum67, sum0123, sum4567;
    
    //perform bit shifting
    assign parts[0] = left[0] ? {8'b0, right} : 16'b0;
    assign parts[1] = left[1] ? {7'b0, right, 1'b0} : 16'b0;
    assign parts[2] = left[2] ? {6'b0, right, 2'b0} : 16'b0;
    assign parts[3] = left[3] ? {5'b0, right, 3'b0} : 16'b0; 
    assign parts[4] = left[4] ? {4'b0, right, 4'b0} : 16'b0; 
    assign parts[5] = left[5] ? {3'b0, right, 5'b0} : 16'b0; 
    assign parts[6] = left[6] ? {2'b0, right, 6'b0} : 16'b0; 
    assign parts[7] = left[7] ? {1'b0, right, 7'b0} : 16'b0;    
    
    //perform stage 1 suming two of the parts at a time
    always @(posedge clk) begin
        sum01 <= parts[0] + parts[1];
        sum23 <= parts[2] + parts[3];
        sum45 <= parts[4] + parts[5];
        sum67 <= parts[6] + parts[7];
    end
    
    //stage 2 summing 2 of the summed two parts
    always @(posedge clk) begin
        sum0123 <= sum01 + sum23;
        sum4567 <= sum45 + sum67;
    end
    
    //add the final sums together to get the result
    assign result = sum0123 + sum4567;
    
endmodule
