`include "Parameters.v"

module GameLogic(
    input clk,
    input rst,
    input random,

    /* game state */
    output reg [9:0] pad_left,
    output reg [9:0] pad_right,
    output reg [9:0] ball_x,
    output reg [8:0] ball_y,

    /* controls */
    input [1:0] keys_left,
    input [1:0] keys_right
);

    /* internal game clock; purposely slowed down */
    wire clk_game = counter[`GAME_SLOWNESS];
    reg [`GAME_SLOWNESS:0] counter;
    always @(posedge clk) counter <= counter + 18'd1;

    /* ball velocity */
    reg signed [2:0] vx;
    reg signed [2:0] vy;

    /* restart the game at next cycle */
    reg sched_restart;
    wire restart = sched_restart || rst;

    always @(posedge clk_game, posedge restart)
        if (restart)
        begin
            pad_left <= `SCREEN_HEIGHT/2;
            pad_right <= `SCREEN_HEIGHT/2;
            ball_x <= `SCREEN_WIDTH/2;
            ball_y <= `SCREEN_HEIGHT/2;
            vx <= -3'sd1;
            vy <= 3'sd1;
            sched_restart <= 1'b0;
        end
        else
        begin
            /* right pad movement */
            if (keys_right == 2'b10 && pad_right != 0)
                pad_right <= pad_right - 10'd1;
            else if (keys_right == 2'b01 && pad_right < `SCREEN_HEIGHT)
                pad_right <= pad_right + 10'd1;

            /* left pad movement */
            if (keys_left == 2'b10 && pad_left != 0)
                pad_left <= pad_left - 10'd1;
            else if (keys_left == 2'b01 && pad_left < `SCREEN_HEIGHT)
                pad_left <= pad_left + 10'd1;

            if (vx > 3'sd0 && ball_x >= `SCREEN_WIDTH-`PAD_WIDTH-`PAD_DISTANCE)
            begin
                /* collision with right border */
                if ((ball_y >= pad_right-`PAD_HEIGHT/2) && (ball_y <= pad_right+`PAD_HEIGHT/2))
                    vx <= random? -3'sd1 : -3'sd2;
                else
                    sched_restart <= 1'b1;
            end
            else if (vx < 3'sd0 && ball_x <= `PAD_DISTANCE+`PAD_WIDTH)
            begin
                /* collision with left border */
                if ((ball_y >= pad_left-`PAD_HEIGHT/2) && (ball_y <= pad_left+`PAD_HEIGHT/2))
                    vx <= random? 3'sd1 : 3'sd2;
                else
                    sched_restart <= 1'b1;
            end
            else
                ball_x <= $signed(ball_x) + vx;

            if ((vy > 3'sd0 && ball_y >= `SCREEN_HEIGHT)
                || (vy < 3'sd0 && ball_y == 0))
            begin
                /* collision with top or down */
                vy <= -vy;
            end
            else
                ball_y <= $signed(ball_y) + vy;
        end
endmodule
