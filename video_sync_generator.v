module video_sync_generator(
    input rst,
    input clk_vga,
    output reg VGA_BLANK_N,
    output reg VGA_HS,
    output reg VGA_VS
);

    // FIXME: this doesn't add up; seems like H_sync cycle is not included in
    // hori_line (but why does this work, then?)

    /**
     * Horizontal timing (units are pixels):
     *              ____________                 ____________
     *             |            |               |            |
     * ____________|   VIDEO    |_______________|   VIDEO    |________
     *
     * _____   ______________________   __________________________   _
     *      |_|                      |_|        (next line)       |_|
     *       B<-C-><-----D-----><-E->
     *      <------------A---------->
     */

    parameter H_sync_cycle = 96;   /* B above */
    parameter hori_back    = 144;  /* C above; "back porch" */
                                   /* D is the visible area (640 pixels) */
    parameter hori_front   = 16;   /* E above; "front porch" */
    parameter hori_line    = 800;  /* A above; total horizontal line length */

    /**
     * Vertical timing (uints are lines):
     *              ____________                 ____________
     *             |            |               |            |
     * ____________|   VIDEO    |_______________|   VIDEO    |________
     *
     * _____   ______________________   __________________________   _
     *      |_|                      |_|       (next frame)       |_|
     *       P<-Q-><-----R-----><-S->
     *      <------------O---------->
     */

    parameter V_sync_cycle = 2;    /* P above */
    parameter vert_back    = 34;   /* Q above; "back porch" */
                                   /* R is the visible area (480 lines) */
    parameter vert_front   = 11;   /* S above; "front porch" */
    parameter vert_line    = 525;  /* O above; total number of line cycles */

    reg [10:0] h_cnt; /* ranges from 0 to hori_line-1 */
    reg [9:0]  v_cnt; /* ranges from 0 to vert_line-1 */

    always @(negedge clk_vga, posedge rst)
    begin
        if (rst)
        begin
            h_cnt <= 11'd0;
            v_cnt <= 10'd0;
        end
        else
        begin
            if (h_cnt == hori_line-1)
            begin
                h_cnt <= 11'd0;
                if (v_cnt == vert_line-1)
                    v_cnt <= 10'd0;
                else
                    v_cnt <= v_cnt+1;
            end
            else
                h_cnt <= h_cnt+1;
        end
    end

    /* true if we're transmitting pixels in the visible area (D) */
    wire hori_valid =
        (h_cnt < (hori_line-hori_front) && h_cnt >= hori_back)? 1'b1 : 1'b0;

    /* true if we're in the visible part of vertical signal (R) */
    wire vert_valid =
        (v_cnt < (vert_line-vert_front) && v_cnt >= vert_back)? 1'b1 : 1'b0;

    always @(negedge clk_vga)
    begin
        VGA_HS <= (h_cnt < H_sync_cycle)? 1'b0 : 1'b1;
        VGA_VS <= (v_cnt < V_sync_cycle)? 1'b0 : 1'b1;

        /* if zero, the DAC ignores VGA_{R,G,B} inputs and outputs nothing */
        VGA_BLANK_N <= hori_valid && vert_valid;
    end
endmodule


