`timescale 1ns / 1ps

module debounce_buttons (
     input clk,
     input btnL, btnC, btnR, btnU, btnD,
     output left, center, right, up, down
     );   
     wire clk_deb;
     
    debounce_div div1  (.clk(clk), .clk_deb(clk_deb));
    btn_debounce u_btn (.clk(clk_deb), .btn_in(btnU), .btn_status(up));
    btn_debounce d_btn (.clk(clk_deb), .btn_in(btnD), .btn_status(down));
    btn_debounce l_btn (.clk(clk_deb), .btn_in(btnL), .btn_status(left));
    btn_debounce r_btn (.clk(clk_deb), .btn_in(btnR), .btn_status(right));
    btn_debounce c_btn (.clk(clk_deb), .btn_in(btnC), .btn_status(center));  
endmodule
