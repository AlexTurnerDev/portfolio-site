`timescale 1ns / 1ps

module joystick_driver(
    input clk,
    input rst,
    input vauxp6, input vauxn6,     // X-axis (VAUX6)
    input vauxp14, input vauxn14,   // Y-axis (VAUX14)
    output reg [11:0] x_data,
    output reg [11:0] y_data
);

    // XADC Interface Signals
    wire ready;
    wire [15:0] data_out;
    reg [6:0] addr;
    reg enable_r;

    // --- FIX: Correct XADC Addresses for Basys 3 ---
    // Address = 0x10 + Channel Number
    // Channel 6 (Pins J3/K3) -> 0x16
    // Channel 14 (Pins L3/M3) -> 0x1E
    localparam ADDR_X = 7'h16;   
    localparam ADDR_Y = 7'h1E;   
    // -----------------------------------------------

    // Read States
    localparam READ_X = 0;
    localparam READ_Y = 1;
    reg state;

    // Simple enable strobe
    reg [15:0] delay_cnt = 0;
    always @(posedge clk) begin
        if (rst) begin
            delay_cnt <= 0;
            enable_r <= 0;
        end else begin
            if (delay_cnt == 16'hFFFF) begin
                delay_cnt <= 0;
                enable_r <= 1;
            end else begin
                delay_cnt <= delay_cnt + 1;
                enable_r <= 0;
            end
        end
    end

    // XADC Wizard Instance
    xadc_wiz_0 XADC_INST (
        .daddr_in(addr),
        .dclk_in(clk),
        .den_in(enable_r),
        .di_in(16'h0000),
        .dwe_in(1'b0),
        .reset_in(rst),

        .busy_out(),
        .channel_out(),
        .do_out(data_out),
        .drdy_out(ready),

        .vp_in(1'b0), .vn_in(1'b0),
        .vauxp6(vauxp6), .vauxn6(vauxn6),
        .vauxp14(vauxp14), .vauxn14(vauxn14),

        .eoc_out(),
        .eos_out(),
        .alarm_out()
    );

    // Read Data from XADC
    always @(posedge clk) begin
        if (rst) begin
            state <= READ_X;
            addr <= ADDR_X;
            x_data <= 0;
            y_data <= 0;
        end else if (ready) begin
            case (state)
                READ_X: begin
                    x_data <= data_out[15:4]; 
                    addr <= ADDR_Y;
                    state <= READ_Y;
                end
                READ_Y: begin
                    y_data <= data_out[15:4];
                    addr <= ADDR_X;
                    state <= READ_X;
                end
            endcase
        end
    end

endmodule