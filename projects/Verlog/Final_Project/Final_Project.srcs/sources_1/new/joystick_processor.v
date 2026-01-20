`timescale 1ns / 1ps

module joystick_processor(
    input clk,
    input rst,
    input [11:0] x_in,
    input [11:0] y_in,
    output reg led0,   // Left
    output reg led1,   // Right
    output reg led2,   // Up
    output reg led3    // Down
);

    // Joystick center approx 0.29V
    localparam THRESH_LOW = 12'd600;
    localparam THRESH_HIGH = 12'd2500;

    always @(posedge clk) begin
        if (rst) begin
            led0 <= 0;
            led1 <= 0;
            led2 <= 0;
            led3 <= 0;

        end else begin

            // Default: all off
            led0 <= 0;
            led1 <= 0;
            led2 <= 0;
            led3 <= 0;

            // X-axis left/right
            if (x_in < THRESH_LOW)
                led0 <= 1;  // LEFT
            else if (x_in > THRESH_HIGH)
                led1 <= 1;  // RIGHT

            // Y-axis up/down
            if (y_in > THRESH_HIGH)
                led2 <= 1;  // UP
            else if (y_in < THRESH_LOW)
                led3 <= 1;  // DOWN

        end
    end

endmodule
