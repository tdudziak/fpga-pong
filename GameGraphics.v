`include "Parameters.v"

module GameGraphics(
    input clk_vga,
    input rst,

    /* graphics configuration from toggle switches */
    input [5:0] switch,

    /* game state: pad and ball positions */
    input [8:0] pad_left,
    input [8:0] pad_right,
    input [9:0] ball_x,
    input [8:0] ball_y,

    /* VGA interface */
    output VGA_BLANK_N,
    output VGA_HS,
    output VGA_VS,
    output [7:0] VGA_B,
    output [7:0] VGA_G,
    output [7:0] VGA_R
);

    wire [9:0] x;
    wire [8:0] y;

    VideoTiming video_timing(
        .clk_vga(clk_vga),
        .rst(rst),
        .VGA_BLANK_N(VGA_BLANK_N),
        .VGA_HS(VGA_HS),
        .VGA_VS(VGA_VS),
        .x(x),
        .y(y)
    );

    wire img_frame = (x == 10'd0) || (x == `SCREEN_WIDTH-10'd1)
                  || (y == 9'd0)  || (y == `SCREEN_HEIGHT-9'd1);

    wire img_pad1 = (x > `PAD_DISTANCE) & (x < `PAD_DISTANCE + `PAD_WIDTH)
                  & (y + `PAD_HEIGHT/2 > pad_left) & (y < pad_left + `PAD_HEIGHT/2);

    wire img_pad2 = (x < `SCREEN_WIDTH - `PAD_DISTANCE)
                  & (x > `SCREEN_WIDTH - `PAD_DISTANCE - `PAD_WIDTH)
                  & (y + `PAD_HEIGHT/2 > pad_right) & (y < pad_right + `PAD_HEIGHT/2);

    wire img_ball = (x + `BALL_SIZE/2 > ball_x) & (x < ball_x + `BALL_SIZE/2)
                  & (y + `BALL_SIZE/2 > ball_y) & (y < ball_y + `BALL_SIZE/2);

    wire image = img_frame | img_pad1 | img_pad2 | img_ball;

    wire background = (switch[0] & (x[1] ^ y[1]))
                    | (switch[1] & (x[4] ^ y[4]));

    wire [7:0] f_lum = image? 8'hff : 8'h00;
    wire [7:0] b_lum = background? 8'h60 : 8'h00;

    assign VGA_R = switch[2]? (b_lum | f_lum) : f_lum;
    assign VGA_G = switch[3]? (b_lum | f_lum) : f_lum;
    assign VGA_B = switch[4]? (b_lum | f_lum) : f_lum;
endmodule
