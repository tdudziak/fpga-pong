`include "Parameters.v"

module GameLogic(
    input clk,
    input rst,

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

    /* TODO: document */
    reg [1:0] vx;
    reg [1:0] vy;

    always @(posedge clk_game, posedge rst)
        if (rst)
        begin
            pad_left <= 0;
            pad_right <= 0;
            ball_x <= 300;
            ball_y <= 200;
            vx <= 2'b01;
            vy <= 2'b10;
        end
        else
        begin
            if (keys_left == 2'b10 && pad_left != 0)
                pad_left <= pad_left - 10'd1;
            else if (keys_left == 2'b01 && pad_left < `SCREEN_HEIGHT)
                pad_left <= pad_left + 10'd1;

            if (keys_right == 2'b10 && pad_right != 0)
                pad_right <= pad_right - 10'd1;
            else if (keys_right == 2'b01 && pad_right < `SCREEN_HEIGHT)
                pad_right <= pad_right + 10'd1;

            /* TODO: ball movement and collision detection */
            if (vx == 2'b01)
            begin
                if (ball_x < `SCREEN_WIDTH-`PAD_WIDTH-`PAD_DISTANCE)
                    ball_x <= ball_x + 10'd1;
                else
                    vx <= ~vx;
            end
            else if (vx == 2'b10)
            begin
                if (ball_x > `PAD_DISTANCE+`PAD_WIDTH)
                    ball_x <= ball_x - 10'd1;
                else
                    vx <= ~vx;
            end

            if (vy == 2'b01)
            begin
                if (ball_y < `SCREEN_HEIGHT)
                    ball_y <= ball_y + 10'd1;
                else
                    vy <= ~vy;
            end
            else if (vy == 2'b10)
            begin
                if (ball_y > 0)
                    ball_y <= ball_y - 10'd1;
                else
                    vy <= ~vy;
            end
        end
endmodule
