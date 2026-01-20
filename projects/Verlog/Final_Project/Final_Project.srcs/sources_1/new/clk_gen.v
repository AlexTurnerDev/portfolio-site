`timescale 1ns / 1ps

module clk_gen #(
    // Default: 100MHz clock / 10Hz target = 10,000,000 cycles
    // If you want it SLOWER (e.g., 1 count per second), change this to 100,000,000
    parameter COUNTER_MAX = 10_000_000 
)(
    input clk,
    input rst,
    output reg en_10hz
);
    
    reg [26:0] count; 

    always @ (posedge clk) begin
        if (rst) begin
            count <= 0;
            en_10hz <= 0;
        end else begin
            if (count >= COUNTER_MAX - 1) begin 
                count <= 0;
                en_10hz <= 1; // 1-cycle enable pulse
            end else begin
                count <= count + 1;
                en_10hz <= 0;
            end
        end
    end
endmodule