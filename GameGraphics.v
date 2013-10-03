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
    output reg oBLANK_n,
    output reg oHS,
    output reg oVS,
    output [7:0] b_data,
    output [7:0] g_data,
    output [7:0] r_data
);

    wire cBLANK_n, cHS, cVS;
    reg [9:0] x;
    reg [8:0] y;

    video_sync_generator(
        .vga_clk(clk_vga),
        .reset(rst),
        .blank_n(cBLANK_n),
        .HS(cHS),
        .VS(cVS)
    );

    always@(posedge clk_vga, posedge rst)
    begin
      if (rst)
      begin
         x <= 10'd0;
          y <= 9'd0;
      end
      else if (cHS==1'b0 && cVS==1'b0)
      begin
          x <= 10'd0;
          y <= 9'd0;
      end
      else if (cBLANK_n==1'b1) begin
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

    assign r_data = image? 8'hff : 8'h0;
    assign g_data = image? 8'hff : 8'h0;
    assign b_data = image? 8'hff : 8'h0;

    /* delay the iHD, iVD,iDEN for one clock cycle; */
    // TODO: why?
    always@(negedge clk_vga)
    begin
      oHS<=cHS;
      oVS<=cVS;
      oBLANK_n<=cBLANK_n;
    end
endmodule
