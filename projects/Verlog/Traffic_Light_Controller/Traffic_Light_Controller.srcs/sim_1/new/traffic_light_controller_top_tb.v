`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/15/2025 01:47:04 PM
// Design Name: 
// Module Name: traffic_light_controller_top_tb
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


module traffic_light_controller_top_tb(
    );
    
    reg clk, btnC;
    wire [6:0] led;
    
    traffic_light_controller_top UUT (
        .clk(clk),
        .btnC(btnC),
        .led(led)
    );
    
    initial
        clk = 0;
    always #5
        clk = ~clk;
    
    initial
    begin
        btnC = 1'b1;
        
        #20;
        
        btnC = 1'b0;
        
        #100000;
        
        $finish;
    end
endmodule
