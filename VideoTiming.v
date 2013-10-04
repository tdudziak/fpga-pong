module VideoTiming(
    input rst,
    input clk_vga,
    output reg VGA_BLANK_N,
    output reg VGA_HS,
    output reg VGA_VS,
    output reg [9:0] x,
    output reg [8:0] y
);

    /**
     * Horizontal timing (units are pixels; 1 pixel = 39.72ns):
     *              ____________                 ____________
     *             |            |               |            |
     * ____________|   VIDEO    |_______________|   VIDEO    |________
     *
     * _____   ______________________   __________________________   _
     *      |_|                      |_|        (next line)       |_|
     *       B<-C-><-----D-----><-E->
     *      <------------A---------->
     */

    parameter h_sync_pulse  = 96;   /* B above; about 3.813µs */
    parameter h_back_porch  = 48;   /* C above; about 1.907µs */
    parameter h_visible     = 640;  /* D above; about 25.42µs */
    parameter h_front_porch = 16;   /* E above; about 0.6355µs*/
    parameter h_total       = 800;  /* A above; 1 line = 31.778µs */

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

    parameter v_sync_pulse  = 2;    /* P above; about 63.55µs */
    parameter v_back_porch  = 33;   /* Q above; about 1049µs  */
    parameter v_visible     = 480;  /* R above; about 15.25ms */
    parameter v_front_porch = 10;   /* S above; about 317.8µs */
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
                    v_cnt <= v_cnt + 10'd1;
            end
            else
                h_cnt <= h_cnt + 11'd1;
        end
    end

    /* true if we're transmitting pixels in the visible area (D) */
    wire h_valid = (h_cnt >= h_sync_pulse + h_back_porch)
                && (h_cnt < h_total - h_front_porch);

    /* true if we're in the visible part of vertical signal (R) */
    wire v_valid = (v_cnt >= v_sync_pulse + v_back_porch)
                && (v_cnt < v_total - v_front_porch);

    wire [10:0] wide_x = h_valid? (h_cnt - h_sync_pulse - h_back_porch) : 11'd0;
    wire [9:0]  wide_y = v_valid? (v_cnt - v_sync_pulse - v_back_porch) : 10'd0;

    // TODO: document what exactly happnes on positive and negative edges
    always @(posedge clk_vga)
    begin
        x <= wide_x[9:0];
        y <= wide_y[8:0];
    end

    always @(negedge clk_vga)
    begin
        VGA_HS <= (h_cnt >= h_sync_pulse);
        VGA_VS <= (v_cnt >= v_sync_pulse);

        /* if zero, the DAC ignores VGA_{R,G,B} inputs and outputs nothing */
        VGA_BLANK_N <= h_valid && v_valid;
    end
endmodule
