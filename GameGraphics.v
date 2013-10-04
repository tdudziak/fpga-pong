`include "Parameters.v"

module GameGraphics(
    input clk_vga,
    input rst,

    /* game state: pad and ball positions */
    input [8:0] pad_left,
    input [8:0] pad_right,
    input [9:0] ball_x,
    input [8:0] ball_y,

    /* VGA interface */
    output reg VGA_BLANK_N,
    output reg VGA_HS,
    output reg VGA_VS,
    output [7:0] VGA_B,
    output [7:0] VGA_G,
    output [7:0] VGA_R
);

    wire next_BLANK_N, next_HS, next_VS;
    reg [9:0] x;
    reg [8:0] y;

    video_sync_generator(
        .vga_clk(clk_vga),
        .reset(rst),
        .VGA_BLANK_N(next_BLANK_N),
        .VGA_HS(next_HS),
        .VGA_VS(next_VS)
    );

    always @(posedge clk_vga, posedge rst)
    begin
        if (rst)
        begin
            x <= 10'd0;
            y <= 9'd0;
        end
        else if (next_HS == 1'b0 && next_VS == 1'b0)
        begin
            x <= 10'd0;
            y <= 9'd0;
        end
        else if (next_BLANK_N == 1'b1) begin
            // FIXME: ugly magic constant, use signals from the sync generator instead
            // FIXME: x=0 column is displayed on the right side of the monitor
            if (x >= `SCREEN_WIDTH-1)
            begin
                x <= 10'd0;
                y <= y + 9'd1;
            end
            else
                x <= x + 9'd1;
        end
    end

    wire img_pad1 = (x > `PAD_DISTANCE) & (x < `PAD_DISTANCE + `PAD_WIDTH)
                  & (y + `PAD_HEIGHT/2 > pad_left) & (y < pad_left + `PAD_HEIGHT/2);

    wire img_pad2 = (x < `SCREEN_WIDTH - `PAD_DISTANCE)
                  & (x > `SCREEN_WIDTH - `PAD_DISTANCE - `PAD_WIDTH)
                  & (y + `PAD_HEIGHT/2 > pad_right) & (y < pad_right + `PAD_HEIGHT/2);

    wire img_ball = (x + `BALL_SIZE/2 > ball_x) & (x < ball_x + `BALL_SIZE/2)
                  & (y + `BALL_SIZE/2 > ball_y) & (y < ball_y + `BALL_SIZE/2);

    wire image = img_pad1 | img_pad2 | img_ball;

    assign VGA_R = image? 8'hff : 8'h0;
    assign VGA_G = image? 8'hff : 8'h0;
    assign VGA_B = image? 8'hff : 8'h0;

    always @(negedge clk_vga)
    begin
        VGA_HS <= next_HS;
        VGA_VS <= next_VS;
        VGA_BLANK_N <= next_BLANK_N;
    end
endmodule
