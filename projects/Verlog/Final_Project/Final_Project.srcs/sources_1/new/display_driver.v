`timescale 1ns / 1ps

module display_driver(
    input clk,              
    input rst, 
    // INPUTS FOR MOVEMENT
    input btn_right,
    input btn_left,
    input btn_up,
    input btn_down,
    
    output reg cs,          
    output reg dc,          
    output reg res,         
    output mosi,            
    output sclk,            
    output busy             
    );

    // --- PARAMETERS ---
    parameter SCREEN_W = 128;
    parameter SCREEN_H = 160;
    
    // --- GLOBAL SIZE VARIABLES ---
    parameter RECT_W = 30; 
    parameter RECT_H = 30; 

    // --- COLORS (16-bit RGB565) ---
    localparam COLOR_BG   = 16'h7FE0; // Lime Green
    localparam COLOR_RECT = 16'hF800; // Red

    // --- STATE MACHINE ---
    localparam S_HARD_RESET = 0;
    localparam S_DELAY      = 1;
    localparam S_INIT_CMD   = 2;
    localparam S_SEND_CMD   = 3; 
    localparam S_WAIT_SPI   = 4;
    localparam S_DRAW_START = 5;
    localparam S_DRAW_PIXEL = 6; 
    localparam S_IDLE       = 7;
    
    reg [3:0] state = S_HARD_RESET;
    reg [3:0] return_state; 

    // --- DELAY TIMER ---
    reg [27:0] delay_cnt;
    reg [27:0] delay_target; 

    // --- SPI INTERFACE ---
    reg [15:0] spi_data;    // 16-bit data
    reg [3:0]  spi_bits;    // 7 for 8-bit, 15 for 16-bit
    reg spi_trigger;
    wire spi_busy;

    spi_sender SPI_INST (
        .clk(clk),
        .rst(rst),
        .data_in(spi_data),
        .bit_limit(spi_bits),
        .send_trigger(spi_trigger),
        .mosi(mosi),
        .sclk(sclk),
        .busy(spi_busy)
    );

    // --- GREEN TAB INIT ROM ---
    // Includes specific offsets (X+2, Y+1) common for Green Tab ST7735S
    reg [6:0] init_index; 
    reg [8:0] current_cmd; 
    
    always @(*) begin
        case (init_index)
            // 1. Soft Reset
            0: current_cmd = {1'b0, 8'h01}; // SWRESET
            // 2. Sleep Out
            1: current_cmd = {1'b0, 8'h11}; // SLPOUT
            
            // 3. Frame Rate Control (Normal Mode)
            2: current_cmd = {1'b0, 8'hB1}; 
            3: current_cmd = {1'b1, 8'h01}; 
            4: current_cmd = {1'b1, 8'h2C}; 
            5: current_cmd = {1'b1, 8'h2D}; 

            // 4. Frame Rate Control (Idle Mode)
            6: current_cmd = {1'b0, 8'hB2}; 
            7: current_cmd = {1'b1, 8'h01}; 
            8: current_cmd = {1'b1, 8'h2C}; 
            9: current_cmd = {1'b1, 8'h2D}; 

            // 5. Frame Rate Control (Partial Mode)
            10: current_cmd = {1'b0, 8'hB3}; 
            11: current_cmd = {1'b1, 8'h01}; 
            12: current_cmd = {1'b1, 8'h2C}; 
            13: current_cmd = {1'b1, 8'h2D}; 
            14: current_cmd = {1'b1, 8'h01}; 
            15: current_cmd = {1'b1, 8'h2C}; 
            16: current_cmd = {1'b1, 8'h2D}; 

            // 6. Display Inversion (Green Tab usually needs Inversion OFF)
            17: current_cmd = {1'b0, 8'hB4}; 
            18: current_cmd = {1'b1, 8'h07}; 

            // 7. Power Control 1
            19: current_cmd = {1'b0, 8'hC0}; 
            20: current_cmd = {1'b1, 8'hA2}; 
            21: current_cmd = {1'b1, 8'h02}; 
            22: current_cmd = {1'b1, 8'h84}; 

            // 8. Power Control 2
            23: current_cmd = {1'b0, 8'hC1}; 
            24: current_cmd = {1'b1, 8'hC5}; 

            // 9. Power Control 3
            25: current_cmd = {1'b0, 8'hC2}; 
            26: current_cmd = {1'b1, 8'h0A}; 
            27: current_cmd = {1'b1, 8'h00}; 

            // 10. Power Control 4
            28: current_cmd = {1'b0, 8'hC3}; 
            29: current_cmd = {1'b1, 8'h8A}; 
            30: current_cmd = {1'b1, 8'h2A}; 

            // 11. Power Control 5
            31: current_cmd = {1'b0, 8'hC4}; 
            32: current_cmd = {1'b1, 8'h8A}; 
            33: current_cmd = {1'b1, 8'hEE}; 
            
            // 12. VCOM Control 1
            34: current_cmd = {1'b0, 8'hC5}; 
            35: current_cmd = {1'b1, 8'h0E}; 

            // 13. Inversion Off
            36: current_cmd = {1'b0, 8'h20}; 

            // 14. Memory Access Control (Rotation)
            37: current_cmd = {1'b0, 8'h36}; // MADCTL
            38: current_cmd = {1'b1, 8'hC8}; // BGR Order

            // 15. Color Mode (16-bit)
            39: current_cmd = {1'b0, 8'h3A}; // COLMOD
            40: current_cmd = {1'b1, 8'h05}; 

            // 16. Display On
            41: current_cmd = {1'b0, 8'h29}; // DISPON

            // --- DRAWING LOOP STARTS HERE (Index 42) ---
            // 17. Column Address Set (GREEN TAB OFFSET: X+2)
            42: current_cmd = {1'b0, 8'h2A}; // CASET
            43: current_cmd = {1'b1, 8'h00}; 
            44: current_cmd = {1'b1, 8'h02}; // Start at 2
            45: current_cmd = {1'b1, 8'h00}; 
            46: current_cmd = {1'b1, 8'h81}; // End at 129 (128 pixels wide)

            // 18. Row Address Set (GREEN TAB OFFSET: Y+1)
            47: current_cmd = {1'b0, 8'h2B}; // RASET
            48: current_cmd = {1'b1, 8'h00}; 
            49: current_cmd = {1'b1, 8'h01}; // Start at 1
            50: current_cmd = {1'b1, 8'h00}; 
            51: current_cmd = {1'b1, 8'hA0}; // End at 160 (160 pixels high)

            // 19. Memory Write
            52: current_cmd = {1'b0, 8'h2C}; // RAMWR

            // Terminator
            53: current_cmd = 9'h1FF; 
            default: current_cmd = 9'h1FF;
        endcase
    end

    reg [14:0] pixel_cnt; 
    
    // Coordinates
    reg [7:0] x_cnt;
    reg [7:0] y_cnt;

    // Game State
    reg [7:0] box_x;
    reg [7:0] box_y;
    reg btn_right_prev, btn_left_prev, btn_up_prev, btn_down_prev;

    always @(posedge clk) begin
        if (rst) begin
            state <= S_HARD_RESET;
            delay_cnt <= 0;
            init_index <= 0;
            spi_trigger <= 0;
            cs <= 1; dc <= 0; res <= 0; 
            pixel_cnt <= 0;
            x_cnt <= 0; y_cnt <= 0;
            box_x <= 0; box_y <= 0;
            btn_right_prev <= 0; btn_left_prev <= 0;
            btn_up_prev <= 0; btn_down_prev <= 0;
        end else begin
            case (state)
                // 1. Hardware Reset
                S_HARD_RESET: begin
                    res <= 0; 
                    delay_cnt <= delay_cnt + 1;
                    if (delay_cnt == 1_000_000) begin 
                        res <= 1; 
                        delay_cnt <= 0;
                        state <= S_DELAY;
                        delay_target <= 120_000_000; 
                        return_state <= S_INIT_CMD;
                    end
                end

                // 2. Generic Delay
                S_DELAY: begin
                    delay_cnt <= delay_cnt + 1;
                    if (delay_cnt >= delay_target) begin
                        delay_cnt <= 0;
                        state <= return_state;
                    end
                end

                // 3. Process ROM Commands
                S_INIT_CMD: begin
                    if (current_cmd == 9'h1FF) begin
                        state <= S_DRAW_START;
                    end else begin
                        dc <= current_cmd[8];        
                        // Put 8-bit command in lower byte, clear upper
                        spi_data <= {8'h00, current_cmd[7:0]}; 
                        spi_bits <= 7; // Send 8 bits (0-7)
                        state <= S_SEND_CMD;
                        return_state <= S_INIT_CMD; 
                    end
                end

                // 4. Send 8-bit Command/Data
                S_SEND_CMD: begin
                    cs <= 0; 
                    spi_trigger <= 1;
                    state <= S_WAIT_SPI;
                end

                // 5. Wait for SPI
                S_WAIT_SPI: begin
                    spi_trigger <= 0;
                    if (!spi_busy && spi_trigger == 0) begin
                        
                        // Delays for Init
                        if (init_index == 0 || init_index == 1) begin 
                            state <= S_DELAY;
                            delay_target <= (init_index == 0) ? 15000000 : 25500000;
                            init_index <= init_index + 1;
                            cs <= 1;
                        end 
                        else if (init_index == 52) begin
                            // RAMWR Sent (Index 52). Proceed to Draw.
                            init_index <= 53; 
                            state <= S_DRAW_START;
                        end
                        else if (return_state == S_DRAW_PIXEL) begin
                            state <= return_state;
                        end
                        else begin
                            init_index <= init_index + 1;
                            state <= return_state;
                            cs <= 1;
                        end
                    end
                end

                // 6. Setup Pixel Loop
                S_DRAW_START: begin
                    cs <= 0; 
                    dc <= 1; 
                    pixel_cnt <= 0;
                    x_cnt <= 0;
                    y_cnt <= 0;
                    state <= S_DRAW_PIXEL;
                end

                // 7. Send 16-bit Pixel (THE FAST PART)
                S_DRAW_PIXEL: begin
                    // Color Logic:
                    if (x_cnt >= box_x && x_cnt < (box_x + RECT_W) && 
                        y_cnt >= box_y && y_cnt < (box_y + RECT_H)) begin
                        spi_data <= COLOR_RECT; // Red
                    end else begin
                        spi_data <= COLOR_BG;   // Lime Green
                    end

                    spi_bits <= 15; // Send 16 bits (0-15)
                    spi_trigger <= 1;
                    state <= S_WAIT_SPI;
                    
                    // Increment and Check Done
                    if (pixel_cnt == 20479) begin 
                         return_state <= S_IDLE;
                    end else begin
                         pixel_cnt <= pixel_cnt + 1;
                         
                         // Update X/Y coordinates
                         if (x_cnt == SCREEN_W - 1) begin
                             x_cnt <= 0;
                             y_cnt <= y_cnt + 1;
                         end else begin
                             x_cnt <= x_cnt + 1;
                         end
                         
                         return_state <= S_DRAW_PIXEL;
                    end
                end

                // 8. Idle & Movement Logic
                S_IDLE: begin
                    cs <= 1;
                    
                    // Move Right
                    if (btn_right && !btn_right_prev) begin
                        if (box_x + RECT_W < SCREEN_W) box_x <= box_x + RECT_W;
                    end
                    // Move Left
                    if (btn_left && !btn_left_prev) begin
                        if (box_x >= RECT_W) box_x <= box_x - RECT_W;
                    end
                    // Move Down
                    if (btn_down && !btn_down_prev) begin
                        if (box_y + RECT_H < SCREEN_H) box_y <= box_y + RECT_H;
                    end
                    // Move Up
                    if (btn_up && !btn_up_prev) begin
                        if (box_y >= RECT_H) box_y <= box_y - RECT_H;
                    end

                    btn_right_prev <= btn_right;
                    btn_left_prev  <= btn_left;
                    btn_up_prev    <= btn_up;
                    btn_down_prev  <= btn_down;

                    // FIX: LOOP BACK TO CASET (Index 42)
                    // This resets the drawing cursor to (0,0) for next frame
                    init_index <= 42; 
                    state <= S_INIT_CMD;
                end
            endcase
        end
    end

    assign busy = (state != S_IDLE);

endmodule