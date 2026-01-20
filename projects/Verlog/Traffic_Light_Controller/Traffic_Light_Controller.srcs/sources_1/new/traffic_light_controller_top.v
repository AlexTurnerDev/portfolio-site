`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/10/2025 10:08:52 AM
// Design Name: 
// Module Name: traffic_light_controller_top
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


module traffic_light_controller_top(
    input clk,
    input btnC,
    output [6:0] led
    );
    
    reg [1:0] current_state, next_state;
    reg start_tm3, start_tm10, start_tm15;
    reg MG, MR, MY, CG, CR, CY;
    reg start_tm3_dly, start_tm10_dly, start_tm15_dly;
    
    wire clk_1Hz, start_tm3_pulse, start_tm10_pulse, start_tm15_pulse;
    wire tm3_done, tm10_done, tm15_done;
    
    parameter [1:0] MainG_CenterR = 2'b00, MainY_CenterR = 2'b01, MainR_CenterG =2'b10, MainR_CenterY = 2'b11;
    
    
    clk_gen U1(
        .clk(clk),
        .rst(btnC),
        .clk_1Hz(clk_1Hz)
    );
    
    
    always @(posedge clk) begin
        start_tm3_dly <= start_tm3;
        start_tm10_dly <= start_tm10;
        start_tm15_dly <= start_tm15;
    end
    
    assign start_tm3_pulse = start_tm3 && !start_tm3_dly;
    assign start_tm10_pulse = start_tm10 && !start_tm10_dly;
    assign start_tm15_pulse = start_tm15 && !start_tm15_dly;
    
    timer #(
        .MAX_COUNT(3)
    ) tm3_instance (
        .clk_1Hz(clk_1Hz),
        .rst(btnC),
        .start_pulse(start_tm3_pulse),
        .tm_done(tm3_done)
    );
    
    timer #(
        .MAX_COUNT(10)
    ) tm10_instance (
        .clk_1Hz(clk_1Hz),
        .rst(btnC),
        .start_pulse(start_tm10_pulse),
        .tm_done(tm10_done)
    );
    
    timer #(
        .MAX_COUNT(15)
    ) tm15_instance (
        .clk_1Hz(clk_1Hz),
        .rst(btnC),
        .start_pulse(start_tm15_pulse),
        .tm_done(tm15_done)
    );
    
    always @(current_state) begin
        MG = 0;
        MY = 0;
        MR = 0;
        CG = 0;
        CY = 0;
        CR = 0;
        start_tm3 = 0;
        start_tm10 = 0;
        start_tm15 = 0;
        case(current_state)
            MainG_CenterR: begin 
                MG = 1;
                CR = 1;
                start_tm15 = 1;
            end
            MainY_CenterR: begin
                MY = 1;
                CR = 1;
                start_tm3 = 1;
            end
            MainR_CenterG: begin
                MR = 1;
                CG = 1;
                start_tm10 = 1;
            end
            MainR_CenterY: begin
                MR = 1;
                CY = 1;
                start_tm3 = 1;
            end
        
        endcase
    end
    
    always @(*) begin
        next_state = current_state;
        
        case(current_state)
            MainG_CenterR: begin    
                if(tm15_done) next_state = MainY_CenterR;
            end
            MainY_CenterR: begin    
                if(tm3_done) next_state = MainR_CenterG;
            end
            MainR_CenterG: begin    
                if(tm10_done) next_state = MainR_CenterY;
            end
            MainR_CenterY: begin    
                if(tm3_done) next_state = MainG_CenterR;
            end
        endcase
    end
    
    always @(posedge clk_1Hz, posedge btnC) begin
        if(btnC) current_state <= MainG_CenterR;
        else current_state <= next_state;
    end
    
    assign led[0] = MR;
    assign led[1] = MY;
    assign led[2] = MG;
    assign led[4] = CR;
    assign led[5] = CY;
    assign led[6] = CG;
    
endmodule
