`timescale 1ns / 1ps

module memory(
     input wire clk,
     input wire we,
     input wire [3:0] addr,
     input wire [15:0] data_in,
     output reg [15:0] data_out
); 
    reg [15:0] mem [15:0];

    initial begin
        mem[0] = 0;
        mem[1] = 0;
        mem[2] = 0;
        mem[3] = 0;
    end

    always@(posedge clk) begin 
        if (we)
            mem[addr] <= data_in; 
        data_out <= mem[addr];
    end 
endmodule 
