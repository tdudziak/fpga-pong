`include "Parameters.v"

module GameGraphics(
    input clk_vga,
    input rst,

    /* graphics configuration from toggle switches */
    input [5:0] switch,

    /* game state: pad and ball positions */
    input [11:0] pad_left,
    input [11:0] pad_right,
    input [11:0] ball_x,
    input [11:0] ball_y,

    /* VGA interface */
    output VGA_BLANK_N,
    output VGA_HS,
    output VGA_VS,
    output [7:0] VGA_B,
    output [7:0] VGA_G,
    output [7:0] VGA_R
);

    wire [11:0] x;
    wire [11:0] y;

    VideoTiming video_timing(
        .clk_vga(clk_vga),
        .rst(rst),
        .VGA_BLANK_N(VGA_BLANK_N),
        .VGA_HS(VGA_HS),
        .VGA_VS(VGA_VS),
        .x(x),
        .y(y)
    );

    wire img_frame = (x == 12'd0) || (x == `SCREEN_WIDTH-12'd1)
                  || (y == 9'd0)  || (y == `SCREEN_HEIGHT-9'd1);

    wire img_pad1 = (x > `PAD_DISTANCE) & (x < `PAD_DISTANCE + `PAD_WIDTH)
                  & (y + `PAD_HEIGHT/2 > pad_left) & (y < pad_left + `PAD_HEIGHT/2);

    wire img_pad2 = (x < `SCREEN_WIDTH - `PAD_DISTANCE)
                  & (x > `SCREEN_WIDTH - `PAD_DISTANCE - `PAD_WIDTH)
                  & (y + `PAD_HEIGHT/2 > pad_right) & (y < pad_right + `PAD_HEIGHT/2);

    wire [23:0] ball_dist = (x-ball_x)*(x-ball_x) + (y-ball_y)*(y-ball_y);
    wire [23:0] ball_edist = (ball_dist >= `BALL_SIZE_INNER)?
        ball_dist - `BALL_SIZE_INNER
        : 24'd0;
    
    wire [7:0] ball_lum =
        (ball_edist[23:`BALL_EDGE_LOG2] != 0)? 8'h00
        : ~ball_edist[(`BALL_EDGE_LOG2-1):0] << (8-`BALL_EDGE_LOG2);

    wire image = img_frame | img_pad1 | img_pad2;

    wire background = (switch[0] & (x[1] ^ y[1]))
                    | (switch[1] & (x[4] ^ y[4]));

    wire [7:0] f_lum = image? 8'hff : ball_lum;
    wire [7:0] b_lum = background? 8'h60 : 8'h00;

    assign VGA_R = switch[2]? (b_lum | f_lum) : f_lum;
    assign VGA_G = switch[3]? (b_lum | f_lum) : f_lum;
    assign VGA_B = switch[4]? (b_lum | f_lum) : f_lum;
endmodule
