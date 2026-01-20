`timescale 1ns / 1ps

module game_logic(
    input clk,
    input rst,
    input btnL, btnR, btnU, btnD,
    output reg [1:0] dir_out, 
    output reg [6:0] count_down,
    output reg [15:0] score,
    input [15:0] score_read,
    output reg [15:0] score_write,
    output reg mem_we,
    output [3:0] debug_state,
    output reg new_record
);

    // STATE DEFINITIONS
    localparam IDLE           = 4'd0;
    localparam NEW_ROUND      = 4'd1;
    localparam WAIT_INPUT     = 4'd2;
    localparam CHECK_FAIL     = 4'd3;
    localparam SAVE_SCORE     = 4'd4;
    localparam GAME_OVER      = 4'd5;
    localparam WAIT_REL       = 4'd6; 
    localparam WAIT_REL_RETRY = 4'd7; 
    localparam WAIT_TO_HS     = 4'd8; 
    localparam VIEW_HS        = 4'd9; 
    localparam WAIT_TO_IDLE   = 4'd10;
    localparam WAIT_FROM_GO   = 4'd11;
    
    reg [3:0] state = IDLE;
    reg [31:0] timer_count;
    reg [1:0] dir;
    
    // LFSR Random Generator linear feedback shift register
    reg [3:0] lfsr = 4'b1011; 
    always @(posedge clk) begin
        lfsr <= {lfsr[2:0], lfsr[3] ^ lfsr[2]};
    end
    
    // Timer Pulse
    wire pulse_1sec; 
    clk_gen #(.COUNTER_MAX(100_000_000)) timer_pulse_inst (
        .clk(clk), .rst(rst), .en_10hz(pulse_1sec)
    );

    assign debug_state = state;
    
    initial begin
        score = 0;
        state = IDLE;
        count_down = 30;
        new_record = 0;
    end
    
    always @(posedge clk) begin
        if (rst) begin
            state <= IDLE;
            score <= 0;
            mem_we <= 0;
            count_down <= 0;
            dir_out <= 2'd2; 
            new_record <= 0;
        end else begin
            mem_we <= 0; 
            count_down <= timer_count[6:0];

            case (state)
                // --- MAIN MENU ---
                IDLE: begin
                    count_down <= 30; 
                    dir_out <= 2'd2; 
                    new_record <= 0; 
                    
                    if (btnU) begin
                        score <= 0; 
                        timer_count <= 30; 
                        state <= WAIT_REL; 
                    end
                    else if (btnR) begin
                        state <= WAIT_TO_HS;
                    end
                end

                // --- MENU NAVIGATION ---
                WAIT_TO_HS: begin
                    if (!btnR) state <= VIEW_HS;
                end
                VIEW_HS: begin
                    if (btnR) state <= WAIT_TO_IDLE;
                end
                WAIT_TO_IDLE: begin
                    if (!btnR) state <= IDLE;
                end
                WAIT_FROM_GO: begin
                    if (!btnU) state <= IDLE; // Return to menu only when button released
                end

                // --- GAMEPLAY ---
                WAIT_REL: begin
                    if (!btnU && !btnD && !btnL && !btnR) state <= NEW_ROUND;
                end
                WAIT_REL_RETRY: begin
                    if (!btnU && !btnD && !btnL && !btnR) state <= WAIT_INPUT; 
                end

                NEW_ROUND: begin
                    dir <= lfsr[1:0]; 
                    dir_out <= lfsr[1:0];
                    state <= WAIT_INPUT;
                end

                WAIT_INPUT: begin
                    if (pulse_1sec) begin
                        if (timer_count > 0) timer_count <= timer_count - 1;
                        else state <= CHECK_FAIL; 
                    end
                    
                    if ((dir != 0 && btnL) || (dir != 1 && btnR) || (dir != 2 && btnU) || (dir != 3 && btnD)) begin
                        if (timer_count > 2) begin
                            timer_count <= timer_count - 2; 
                            state <= WAIT_REL_RETRY;        
                        end else begin
                            timer_count <= 0;               
                            state <= CHECK_FAIL;
                        end
                    end
                    else if ((dir == 0 && btnL) || (dir == 1 && btnR) || (dir == 2 && btnU) || (dir == 3 && btnD)) begin
                        score <= score + 1;
                        state <= WAIT_REL; 
                    end
                end
                
                CHECK_FAIL: begin
                    if (score > score_read) begin
                        score_write <= score;
                        mem_we <= 1; 
                        new_record <= 1; 
                        state <= SAVE_SCORE;
                    end else begin
                        state <= GAME_OVER;
                    end
                end
                
                SAVE_SCORE: begin
                    mem_we <= 0;
                    state <= GAME_OVER;
                end

                GAME_OVER: begin
                    count_down <= 0; 
                    if (btnU) state <= WAIT_FROM_GO; // NEW: Press U to restart
                end
            endcase
        end
    end
endmodule