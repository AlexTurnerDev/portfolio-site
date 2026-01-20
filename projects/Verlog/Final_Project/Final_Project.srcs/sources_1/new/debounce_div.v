`timescale 1ns / 1ps

module debounce_div(
    input clk,
    output clk_deb
    );
    reg [15:0] cnt;

    
    assign clk_deb = cnt[15];
    
    initial cnt = 0;
    always @(posedge clk)
        cnt <= cnt + 1;
        
endmodule
