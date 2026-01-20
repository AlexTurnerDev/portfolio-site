    `timescale 1ns / 1ps
    
    module segdisplay_driver(
        input clk,
        input rst,
        input [6:0] count_down, 
        input [1:0] dir,       
        input [15:0] score,     
        input [15:0] high_score_val,
        input [3:0] game_state,
        input is_new_record,     
        output reg [6:0] seg,
        output reg [3:0] an
    );
    
        reg [19:0] refresh_counter;
        always @(posedge clk or posedge rst) begin
            if (rst) refresh_counter <= 0;
            else refresh_counter <= refresh_counter + 1;
        end
        wire [1:0] digit_select = refresh_counter[19:18];
    
        reg [24:0] scroll_timer; 
        always @(posedge clk or posedge rst) begin
            if (rst) scroll_timer <= 0;
            else scroll_timer <= scroll_timer + 1;
        end
        wire scroll_tick = (scroll_timer == 0);
    
        reg [6:0] scroll_ptr; 
        always @(posedge clk or posedge rst) begin
            if (rst) scroll_ptr <= 0;
            else if (scroll_tick) scroll_ptr <= scroll_ptr + 1;
        end
    
        reg [5:0] char_index;
        
        // Character Constants
        localparam C_0=0, C_1=1, C_2=2, C_3=3, C_4=4, C_5=5, C_6=6, C_7=7, C_8=8, C_9=9;
        localparam C_L=10, C_r=11, C_U=12, C_d=13, C_SPC=14, C_DASH=15;
        localparam C_A=16, C_b=17, C_C=18, C_E=19, C_F=20, C_G=21, C_H=22, C_J=23;
        localparam C_n=24, C_o=25, C_P=26, C_S=27, C_t=28, C_y=29, C_I=30, C_M=31; 
    
        always @(*) begin
            // DEFAULT ANODES
            case(digit_select)
                2'b00: an = 4'b1110; 
                2'b01: an = 4'b1101; 
                2'b10: an = 4'b1011; 
                2'b11: an = 4'b0111; 
            endcase
    
            // --- STATE DISPLAY LOGIC ---
            
            // 1. GAME OVER (State 5) or WAIT FROM GO (State 11)
            if (game_state == 4'd5 || game_state == 4'd11) begin
                if (is_new_record) begin
                     case(digit_select)
                        2'b00: char_index = get_newrecord_char(scroll_ptr + 3); 
                        2'b01: char_index = get_newrecord_char(scroll_ptr + 2); 
                        2'b10: char_index = get_newrecord_char(scroll_ptr + 1); 
                        2'b11: char_index = get_newrecord_char(scroll_ptr);     
                    endcase
                end else begin
                     case(digit_select)
                        2'b00: char_index = get_gameover_char(scroll_ptr + 3); 
                        2'b01: char_index = get_gameover_char(scroll_ptr + 2); 
                        2'b10: char_index = get_gameover_char(scroll_ptr + 1); 
                        2'b11: char_index = get_gameover_char(scroll_ptr);     
                    endcase
                end
            end 
            
            // 2. IDLE / MENU (State 0)
            else if (game_state == 4'd0 || game_state == 4'd10) begin
                case(digit_select)
                    2'b00: char_index = get_welcome_char(scroll_ptr + 3); 
                    2'b01: char_index = get_welcome_char(scroll_ptr + 2); 
                    2'b10: char_index = get_welcome_char(scroll_ptr + 1); 
                    2'b11: char_index = get_welcome_char(scroll_ptr);    
                endcase
            end
            
            // 3. VIEW HIGH SCORE (State 9) or WAIT TO HS (State 8)
            else if (game_state == 4'd9 || game_state == 4'd8) begin
                case(digit_select)
                    2'b00: char_index = get_highscore_char(scroll_ptr + 3); 
                    2'b01: char_index = get_highscore_char(scroll_ptr + 2); 
                    2'b10: char_index = get_highscore_char(scroll_ptr + 1); 
                    2'b11: char_index = get_highscore_char(scroll_ptr);    
                endcase
            end
            
            // 4. PLAYING
            else begin
                 case(digit_select)
                    2'b00: begin // Direction
                        case(dir)
                            2'd0: char_index = C_L;
                            2'd1: char_index = C_r;
                            2'd2: char_index = C_U;
                            2'd3: char_index = C_d;
                        endcase
                    end
                    2'b01: char_index = C_SPC; // Blank
                    2'b10: char_index = (count_down % 10); // Timer
                    2'b11: char_index = (count_down / 10); // Timer
                endcase
            end
        end
    
        // --- TEXT FUNCTIONS ---
    
        // IDLE: "EnTER THE GAUntLEt   PrESS U TO PLAY   PrESS r FOR SCorE      " (Length 58)
        function [5:0] get_welcome_char;
            input [6:0] pos; 
            begin
                case(pos % 58)
                    0: get_welcome_char = C_E; 1: get_welcome_char = C_n; 2: get_welcome_char = C_t;
                    3: get_welcome_char = C_E; 4: get_welcome_char = C_r; 5: get_welcome_char = C_SPC;
                    6: get_welcome_char = C_t; 7: get_welcome_char = C_H; 8: get_welcome_char = C_E;
                    9: get_welcome_char = C_SPC; 10: get_welcome_char = C_G; 11: get_welcome_char = C_A;
                    12: get_welcome_char = C_U; 13: get_welcome_char = C_n; 14: get_welcome_char = C_t;
                    15: get_welcome_char = C_L; 16: get_welcome_char = C_E; 17: get_welcome_char = C_t;
                    18: get_welcome_char = C_SPC; 19: get_welcome_char = C_SPC; 20: get_welcome_char = C_SPC;
                    21: get_welcome_char = C_P; 22: get_welcome_char = C_r; 23: get_welcome_char = C_E;
                    24: get_welcome_char = C_S; 25: get_welcome_char = C_S; 26: get_welcome_char = C_SPC;
                    27: get_welcome_char = C_U; 28: get_welcome_char = C_SPC; 29: get_welcome_char = C_t;
                    30: get_welcome_char = C_o; 31: get_welcome_char = C_SPC; 32: get_welcome_char = C_P;
                    33: get_welcome_char = C_L; 34: get_welcome_char = C_A; 35: get_welcome_char = C_y;
                    36: get_welcome_char = C_SPC; 37: get_welcome_char = C_SPC; 38: get_welcome_char = C_SPC;
                    39: get_welcome_char = C_P; 40: get_welcome_char = C_r; 41: get_welcome_char = C_E;
                    42: get_welcome_char = C_S; 43: get_welcome_char = C_S; 44: get_welcome_char = C_SPC;
                    45: get_welcome_char = C_r; 46: get_welcome_char = C_SPC; 47: get_welcome_char = C_F;
                    48: get_welcome_char = C_o; 49: get_welcome_char = C_r; 50: get_welcome_char = C_SPC;
                    51: get_welcome_char = C_S; 52: get_welcome_char = C_C; 53: get_welcome_char = C_o;
                    54: get_welcome_char = C_r; 55: get_welcome_char = C_E; 
                    default: get_welcome_char = C_SPC;
                endcase
            end
        endfunction
    
        // HIGH SCORE: "HALL OF FAME   SCorE XX   PrESS r TO bACK      " (Length 46)
        function [5:0] get_highscore_char;
            input [6:0] pos;
            begin
                case(pos % 46)
                    0: get_highscore_char = C_H; 1: get_highscore_char = C_A; 2: get_highscore_char = C_L;
                    3: get_highscore_char = C_L; 4: get_highscore_char = C_SPC; 5: get_highscore_char = C_o;
                    6: get_highscore_char = C_F; 7: get_highscore_char = C_SPC; 8: get_highscore_char = C_F;
                    9: get_highscore_char = C_A; 10: get_highscore_char = C_M; 11: get_highscore_char = C_E;
                    12: get_highscore_char = C_SPC; 13: get_highscore_char = C_SPC; 14: get_highscore_char = C_SPC;
                    
                    15: get_highscore_char = C_S; 16: get_highscore_char = C_C; 17: get_highscore_char = C_o;
                    18: get_highscore_char = C_r; 19: get_highscore_char = C_E; 20: get_highscore_char = C_SPC; 
                    21: get_highscore_char = (high_score_val / 10) % 10;
                    22: get_highscore_char = (high_score_val % 10);
                    
                    23: get_highscore_char = C_SPC; 24: get_highscore_char = C_SPC; 25: get_highscore_char = C_SPC;
                    26: get_highscore_char = C_P; 27: get_highscore_char = C_r; 28: get_highscore_char = C_E;
                    29: get_highscore_char = C_S; 30: get_highscore_char = C_S; 31: get_highscore_char = C_SPC;
                    32: get_highscore_char = C_r; 33: get_highscore_char = C_SPC; 34: get_highscore_char = C_t;
                    35: get_highscore_char = C_o; 36: get_highscore_char = C_SPC; 37: get_highscore_char = C_b;
                    38: get_highscore_char = C_A; 39: get_highscore_char = C_C; 40: get_highscore_char = C_F; 
                    default: get_highscore_char = C_SPC;
                endcase
            end
        endfunction
        
        // GAME OVER: "LEGEnD FALLEn   SCorE XX   PrESS U TO MEnU      " (Length 47)
        function [5:0] get_gameover_char;
            input [6:0] pos;
            begin
                 case(pos % 47)
                    0: get_gameover_char = C_L; 1: get_gameover_char = C_E; 2: get_gameover_char = C_G;
                    3: get_gameover_char = C_E; 4: get_gameover_char = C_n; 5: get_gameover_char = C_d;
                    6: get_gameover_char = C_SPC; 7: get_gameover_char = C_F; 8: get_gameover_char = C_A;
                    9: get_gameover_char = C_L; 10: get_gameover_char = C_L; 11: get_gameover_char = C_E;
                    12: get_gameover_char = C_n; 13: get_gameover_char = C_SPC; 14: get_gameover_char = C_SPC; 
                    
                    15: get_gameover_char = C_S; 16: get_gameover_char = C_C; 17: get_gameover_char = C_o; 
                    18: get_gameover_char = C_r; 19: get_gameover_char = C_E; 20: get_gameover_char = C_SPC; 
                    21: get_gameover_char = (score / 10) % 10;
                    22: get_gameover_char = (score % 10);
                    
                    23: get_gameover_char = C_SPC; 24: get_gameover_char = C_SPC; 25: get_gameover_char = C_SPC;
                    26: get_gameover_char = C_P; 27: get_gameover_char = C_r; 28: get_gameover_char = C_E; 
                    29: get_gameover_char = C_S; 30: get_gameover_char = C_S; 31: get_gameover_char = C_SPC;
                    32: get_gameover_char = C_U; 33: get_gameover_char = C_SPC; 34: get_gameover_char = C_t; 
                    35: get_gameover_char = C_o; 36: get_gameover_char = C_SPC; 37: get_gameover_char = C_M; 
                    38: get_gameover_char = C_E; 39: get_gameover_char = C_n; 40: get_gameover_char = C_U;
                    default: get_gameover_char = C_SPC;
                endcase
            end
        endfunction
        
        // NEW RECORD: "A nEU LEgEnd RIsES   SCorE XX   PrESS U TO MEnU      " (Length 52)
        function [5:0] get_newrecord_char;
            input [6:0] pos;
            begin
                 case(pos % 52)
                    0: get_newrecord_char = C_A; 1: get_newrecord_char = C_SPC; 
                    2: get_newrecord_char = C_n; 3: get_newrecord_char = C_E; 4: get_newrecord_char = C_U; 
                    5: get_newrecord_char = C_SPC; 6: get_newrecord_char = C_L; 7: get_newrecord_char = C_E; 
                    8: get_newrecord_char = C_G; 9: get_newrecord_char = C_E; 10: get_newrecord_char = C_n; 
                    11: get_newrecord_char = C_d; 12: get_newrecord_char = C_SPC; 13: get_newrecord_char = C_r; 
                    14: get_newrecord_char = C_I; 15: get_newrecord_char = C_S; 16: get_newrecord_char = C_E; 
                    17: get_newrecord_char = C_S; 18: get_newrecord_char = C_SPC; 19: get_newrecord_char = C_SPC;
                    
                    20: get_newrecord_char = C_S; 21: get_newrecord_char = C_C; 22: get_newrecord_char = C_o; 
                    23: get_newrecord_char = C_r; 24: get_newrecord_char = C_E; 25: get_newrecord_char = C_SPC; 
                    26: get_newrecord_char = (score / 10) % 10;
                    27: get_newrecord_char = (score % 10);
                    
                    28: get_newrecord_char = C_SPC; 29: get_newrecord_char = C_SPC; 30: get_newrecord_char = C_SPC;
                    31: get_newrecord_char = C_P; 32: get_newrecord_char = C_r; 33: get_newrecord_char = C_E; 
                    34: get_newrecord_char = C_S; 35: get_newrecord_char = C_S; 36: get_newrecord_char = C_SPC;
                    37: get_newrecord_char = C_U; 38: get_newrecord_char = C_SPC; 39: get_newrecord_char = C_t; 
                    40: get_newrecord_char = C_o; 41: get_newrecord_char = C_SPC; 42: get_newrecord_char = C_M; 
                    43: get_newrecord_char = C_E; 44: get_newrecord_char = C_n; 45: get_newrecord_char = C_U;
                    default: get_newrecord_char = C_SPC;
                endcase
            end
        endfunction
    
        // DECODER
        always @(*) begin
            case(char_index)
                C_0: seg = 7'b1000000; C_1: seg = 7'b1111001; C_2: seg = 7'b0100100; C_3: seg = 7'b0110000; 
                C_4: seg = 7'b0011001; C_5: seg = 7'b0010010; C_6: seg = 7'b0000010; C_7: seg = 7'b1111000; 
                C_8: seg = 7'b0000000; C_9: seg = 7'b0010000;
                C_L: seg = 7'b1000111; C_r: seg = 7'b0101111; C_U: seg = 7'b1000001; C_d: seg = 7'b0100001; 
                C_SPC: seg = 7'b1111111; C_DASH: seg = 7'b0111111; 
                C_A: seg = 7'b0001000; C_b: seg = 7'b0000011; C_C: seg = 7'b1000110; C_E: seg = 7'b0000110; 
                C_F: seg = 7'b0001110; C_G: seg = 7'b0000010; C_H: seg = 7'b0001001; C_J: seg = 7'b1110001; 
                C_n: seg = 7'b0101011; C_o: seg = 7'b0100011; C_P: seg = 7'b0001100; C_S: seg = 7'b0010010; 
                C_t: seg = 7'b0000111; C_y: seg = 7'b0010001; C_I: seg = 7'b1111001; 
                C_M: seg = 7'b0101010; // M looks kinda like n with extra line? or two n's? Using pseudo-M
                default: seg = 7'b1111111; 
            endcase
        end
    
    endmodule
