`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/17/2025 10:05:58 AM
// Design Name: 
// Module Name: memory_tb
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


module memory_tb( ); 
reg we, oe, clk; 
wire [15:0] data; 
reg [3:0] addr; 
reg [15:0] data_temp; 
parameter period = 10; 
memory u0 (.we(we), .oe(oe), .clk(clk), .data(data), .addr(addr)); 
 
assign data = we?data_temp:16'hZZZZ;  //If we are not writing set data to a high impedance
always #(period/2) clk = ~clk;  
initial 
begin    clk = 0;    oe = 0;    we = 0; addr = 4'h0; data_temp = 16'h0000; //set things up so we can save values
     #5 we = 1'b1;    
     @(posedge clk) 
     #1              addr = 4'h0; data_temp = 16'h0001;   // wait 1 ns before writing
     #period     addr = 4'h1; data_temp = 16'h1111;        // writing to memory same with the lines below
     #period     addr = 4'h2; data_temp = 16'h2222;    
     #period     addr = 4'h3; data_temp = 16'h3333;
     #period     addr = 4'h4; data_temp = 16'h4444;
     #period     addr = 4'h5; data_temp = 16'h5555;
     #period     addr = 4'h6; data_temp = 16'h6666;
     #period     addr = 4'h7; data_temp = 16'h7777;
     #period     addr = 4'h8; data_temp = 16'h8888;
     #period     addr = 4'h9; data_temp = 16'h9999;
     #period     addr = 4'hA; data_temp = 16'hAAAA;
     #period     addr = 4'hB; data_temp = 16'hBBBB;
     #period     addr = 4'hC; data_temp = 16'hCCCC;
     #period     addr = 4'hD; data_temp = 16'hDDDD;
     #period     addr = 4'hE; data_temp = 16'hEEEE;
     #period     addr = 4'hF; data_temp = 16'hFFFF;

     #period     addr = 4'h0; we= 1'b0; oe = 1'b1;      // reading from memory same as the lines below though we only have to set things up once
     #period     addr = 4'h1;    
     #period     addr = 4'h2;
     #period     addr = 4'h3;
     #period     addr = 4'h4;
     #period     addr = 4'h5;
     #period     addr = 4'h6;
     #period     addr = 4'h7;
     #period     addr = 4'h8;
     #period     addr = 4'h9;
     #period     addr = 4'hA;
     #period     addr = 4'hB;
     #period     addr = 4'hC;
     #period     addr = 4'hD;
     #period     addr = 4'hE;
     #period     addr = 4'hF;
     

     #1000 $finish;
end
endmodule

