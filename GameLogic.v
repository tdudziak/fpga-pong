`include "Parameters.v"

module GameLogic(
    input clk,
    input rst,
    input [7:0] random,

    /* game state */
    output reg [11:0] pad_left,
    output reg [11:0] pad_right,
    output reg [11:0] ball_x,
    output reg [11:0] ball_y,

    /* controls */
    input [1:0] keys_left,
    input [1:0] keys_right,
    input pause
);

    /* internal game clock; purposely slowed down */
    wire clk_game = counter[`GAME_SLOWNESS];
    reg [`GAME_SLOWNESS:0] counter;
    always @(posedge clk) counter <= counter + 1;

    /* ball velocity */
    reg signed [2:0] vx;
    reg signed [2:0] vy;

    /* restart the game at next cycle */
    reg sched_restart;
    wire restart = sched_restart || rst;

    /* ball colides with the top screen edge */
    wire collides_top = (vy > 3'sd0 && ball_y >= `SCREEN_HEIGHT-`BALL_SIZE_INNER);

    /* ball colides with the bottom screen edge */
    wire collides_bottom = (vy < 3'sd0 && ball_y <= `BALL_SIZE_INNER);

    /* ball will cross the line `PAD_WIDTH+`PAD_DISTANCE pixels from the right
       edge; it either has to bounce or it's game over */
    wire collides_right = (vx > 3'sd0)
                       && (ball_x >= `SCREEN_WIDTH-`PAD_WIDTH-`PAD_DISTANCE-2-`BALL_SIZE_INNER);

    /* same for left edge */
    wire collides_left = (vx < 3'sd0)
                      && (ball_x <= `PAD_DISTANCE+`PAD_WIDTH+2+`BALL_SIZE_INNER);


    /* is ball's y-coordinate within boundaries of the right pad? */
    wire matches_right = (ball_y >= pad_right - `PAD_HEIGHT/2)
                      && (ball_y <= pad_right + `PAD_HEIGHT/2);

    /* is ball's y-coordinate within boundaries of the left pad? */
    wire matches_left = (ball_y >= pad_left - `PAD_HEIGHT/2)
                     && (ball_y <= pad_left + `PAD_HEIGHT/2);

    always @(posedge clk_game)
        if (restart)
        begin
            pad_left <= `SCREEN_HEIGHT/2;
            pad_right <= `SCREEN_HEIGHT/2;
            ball_x <= `SCREEN_WIDTH/2;
            ball_y <= `SCREEN_HEIGHT/2;
            vx <= random[7]? -3'sd1 : +3'sd1;
            vy <= random[3]? -3'sd1 : +3'sd1;
            sched_restart <= 1'b0;
        end
        else if(!pause)
        begin
            /* right pad movement */
            if (keys_right == 2'b10 && pad_right >= 2+`PAD_HEIGHT/2)
                pad_right <= pad_right - 12'd2;
            else if (keys_right == 2'b01 && pad_right <= `SCREEN_HEIGHT-2-`PAD_HEIGHT/2)
                pad_right <= pad_right + 12'd2;

            /* left pad movement */
            if (keys_left == 2'b10 && pad_left >= 2+`PAD_HEIGHT/2)
                pad_left <= pad_left - 12'd2;
            else if (keys_left == 2'b01 && pad_left <= `SCREEN_HEIGHT-2-`PAD_HEIGHT/2)
                pad_left <= pad_left + 12'd2;

            /* ball movement */
            if (collides_right)
            begin
                if (matches_right)
                    vx <= (random[2:0] == 2'd0)? -3'sd1 : -3'sd2;
                else
                    sched_restart <= 1'b1;
            end
            else if (collides_left)
            begin
                if (matches_left)
                    vx <= (random[2:0] == 2'd0)? 3'sd1 : 3'sd2;
                else
                    sched_restart <= 1'b1;
            end
            else
                ball_x <= $signed(ball_x) + vx;

            if (collides_top || collides_bottom)
                vy <= -vy;
            else
                ball_y <= $signed(ball_y) + vy;
        end
endmodule
