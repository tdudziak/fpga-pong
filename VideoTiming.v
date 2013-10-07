/**
* This implements an XGA 1024x768@60Hz mode.
* See http://tinyvga.com/vga-timing/1024x768@60Hz for details.
*/
module VideoTiming(
    input rst,
    input clk_vga, /* 65 MHz */
    output reg VGA_BLANK_N,
    output reg VGA_HS,
    output reg VGA_VS,
    output reg [11:0] x,
    output reg [11:0] y
);

    parameter polarity_hs = 1'b0; // negative
    parameter polarity_vs = 1'b0; // negative

    /**
     * Horizontal timing (units are pixels; 1 pixel = 15.38ns):
     *              ____________                 ____________
     *             |            |               |            |
     * ____________|   VIDEO    |_______________|   VIDEO    |________
     *
     * _____   ______________________   __________________________   _
     *      |_|                      |_|        (next line)       |_|
     *       B<-C-><-----D-----><-E->
     *      <------------A---------->
     */

    parameter h_sync_pulse  = 136;
    parameter h_back_porch  = 160;
    parameter h_visible     = 1024;
    parameter h_front_porch = 24;
    parameter h_total       = 1344;

    /**
     * Vertical timing (uints are lines; 1 line = h_total pixels):
     *              ____________                 ____________
     *             |            |               |            |
     * ____________|   VIDEO    |_______________|   VIDEO    |________
     *
     * _____   ______________________   __________________________   _
     *      |_|                      |_|       (next frame)       |_|
     *       P<-Q-><-----R-----><-S->
     *      <------------O---------->
     */

    parameter v_sync_pulse  = 6;
    parameter v_back_porch  = 29;
    parameter v_visible     = 768;
    parameter v_front_porch = 3;
    parameter v_total       = 806;

    reg [11:0] h_cnt; /* ranges from 0 to h_total-1 */
    reg [11:0] v_cnt; /* ranges from 0 to v_total-1 */

    always @(negedge clk_vga, posedge rst)
    begin
        if (rst)
        begin
            h_cnt <= 12'd0;
            v_cnt <= 12'd0;
        end
        else
        begin
            if (h_cnt == h_total-1)
            begin
                h_cnt <= 12'd0;
                if (v_cnt == v_total-1)
                    v_cnt <= 12'd0;
                else
                    v_cnt <= v_cnt + 12'd1;
            end
            else
                h_cnt <= h_cnt + 12'd1;
        end
    end

    /* true if we're transmitting pixels in the visible area (D) */
    wire h_valid = (h_cnt >= h_sync_pulse + h_back_porch)
                && (h_cnt < h_total - h_front_porch);

    /* true if we're in the visible part of vertical signal (R) */
    wire v_valid = (v_cnt >= v_sync_pulse + v_back_porch)
                && (v_cnt < v_total - v_front_porch);

    // TODO: document what exactly happnes on positive and negative edges
    always @(posedge clk_vga)
    begin
        x <= h_valid? (h_cnt - h_sync_pulse - h_back_porch) : 12'd0;
        y <= v_valid? (v_cnt - v_sync_pulse - v_back_porch) : 12'd0;
    end

    always @(negedge clk_vga)
    begin
        VGA_HS <= (h_cnt >= h_sync_pulse) ^ polarity_hs;
        VGA_VS <= (v_cnt >= v_sync_pulse) ^ polarity_vs;

        /* if zero, the DAC ignores VGA_{R,G,B} inputs and outputs nothing */
        VGA_BLANK_N <= h_valid && v_valid;
    end
endmodule
