`timescale 1ns / 1ps

module spi_sender(
    input clk,              // 100 MHz System Clock
    input rst,              // Reset
    input [15:0] data_in,   // 16-bit data input
    input [3:0] bit_limit,  // How many bits to send (7 or 15)
    input send_trigger,     // Start sending
    output reg mosi,        // Serial Data Out
    output reg sclk,        // Serial Clock Out
    output reg busy         // 1 = Sending
    );

    // 12.5 MHz Clock Divider (Safe Fast)
    // Counts 0-7 (8 ticks)
    reg [2:0] clk_div; 
    
    reg [15:0] shift_reg;
    reg [3:0] bit_count;
    
    localparam IDLE = 0;
    localparam SENDING = 1;
    reg state;

    always @(posedge clk) begin
        if (rst) begin
            state <= IDLE;
            mosi <= 0;
            sclk <= 0; 
            busy <= 0;
            clk_div <= 0;
            bit_count <= 0;
        end else begin
            case (state)
                IDLE: begin
                    busy <= 0;
                    sclk <= 0; 
                    mosi <= 0; 
                    
                    if (send_trigger) begin
                        state <= SENDING;
                        busy <= 1;
                        shift_reg <= data_in;
                        bit_count <= 0;
                        clk_div <= 0;
                    end
                end

                SENDING: begin
                    clk_div <= clk_div + 1;
                    
                    // Tick 0: Set Data
                    if (clk_div == 0) begin
                        sclk <= 0;             
                        // MSB Alignment Logic
                        // If sending 16 bits (bit_limit 15), take bit 15.
                        // If sending 8 bits (bit_limit 7), take bit 7.
                        if (bit_limit == 15) mosi <= shift_reg[15]; 
                        else mosi <= shift_reg[7];                  
                    end
                    
                    // Tick 4: SCLK High
                    else if (clk_div == 4) begin
                        sclk <= 1;             
                    end
                    
                    // Tick 7: SCLK Low & Shift
                    else if (clk_div == 7) begin
                        sclk <= 0;             
                        shift_reg <= {shift_reg[14:0], 1'b0}; 
                        
                        if (bit_count == bit_limit) begin
                            state <= IDLE;
                            busy <= 0;
                        end else begin
                            bit_count <= bit_count + 1;
                        end
                    end
                end
            endcase
        end
    end
endmodule