module video_sync_generator(
    input rst,
    input clk_vga,
    output reg VGA_BLANK_N,
    output reg VGA_HS,
    output reg VGA_VS
);

    // FIXME: this doesn't add up; seems like H_sync cycle is not included in
    // h_total (but why does this work, then?)

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

    parameter h_sync_cycle  = 96;   /* B above */
    parameter h_back_porch  = 144;  /* C above */
                                    /* D is the visible area (640 pixels) */
    parameter h_front_porch = 16;   /* E above; "front porch" */
    parameter h_total       = 800;  /* A above; total horizontal line length */

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

    parameter v_sync_cycle  = 2;    /* P above */
    parameter v_back_porch  = 34;   /* Q above  */
                                    /* R is the visible area (480 lines) */
    parameter v_front_porch = 11;   /* S above */
    parameter v_total       = 525;  /* O above; total number of line cycles */

    reg [10:0] h_cnt; /* ranges from 0 to h_total-1 */
    reg [9:0]  v_cnt; /* ranges from 0 to v_total-1 */

    always @(negedge clk_vga, posedge rst)
    begin
        if (rst)
        begin
            h_cnt <= 11'd0;
            v_cnt <= 10'd0;
        end
        else
        begin
            if (h_cnt == h_total-1)
            begin
                h_cnt <= 11'd0;
                if (v_cnt == v_total-1)
                    v_cnt <= 10'd0;
                else
                    v_cnt <= v_cnt+1;
            end
            else
                h_cnt <= h_cnt+1;
        end
    end

    /* true if we're transmitting pixels in the visible area (D) */
    wire h_valid =
        (h_cnt < (h_total-h_front_porch) && h_cnt >= h_back_porch)? 1'b1 : 1'b0;

    /* true if we're in the visible part of vertical signal (R) */
    wire vert_valid =
        (v_cnt < (v_total-v_front_porch) && v_cnt >= v_back_porch)? 1'b1 : 1'b0;

    always @(negedge clk_vga)
    begin
        VGA_HS <= (h_cnt < h_sync_cycle)? 1'b0 : 1'b1;
        VGA_VS <= (v_cnt < v_sync_cycle)? 1'b0 : 1'b1;

        /* if zero, the DAC ignores VGA_{R,G,B} inputs and outputs nothing */
        VGA_BLANK_N <= h_valid && vert_valid;
    end
endmodule


