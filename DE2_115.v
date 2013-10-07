module DE2_115(
    /* clocks */
    input CLOCK_50,
    input CLOCK2_50,
    input CLOCK3_50,
    input ENETCLK_25,

    /* SMA clock distribution connectors */
    input SMA_CLKIN,
    output SMA_CLKOUT,

    /* small LEDs above the keys and switches */
    output [8:0]  LEDG, /* green */
    output [17:0] LEDR, /* red */

    input [3:0]  KEY, /* push buttons */
    input [17:0] SW,  /* toggle switches */

    /* seven-segment displays */
    output [6:0] HEX0,
    output [6:0] HEX1,
    output [6:0] HEX2,
    output [6:0] HEX3,
    output [6:0] HEX4,
    output [6:0] HEX5,
    output [6:0] HEX6,
    output [6:0] HEX7,

    /* LCD */
    inout [7:0] LCD_DATA,
    output LCD_EN,   /* enable */
    output LCD_ON,   /* LCD power ON/OFF */
    output LCD_RS,   /* 0 = command, 1 = data */
    output LCD_RW,   /* 0 = write, 1 = read */
    output LCD_BLON, /* backlight ON/OFF (does nothing, there is no backlight) */

    /* RS-232 serial port */
    output UART_CTS, /* clear to send */
    input UART_RTS,  /* request to send */
    input UART_RXD,  /* receiver */
    output UART_TXD, /* transmitter */

    /* PS/2 serial port */
    inout PS2_CLK,
    inout PS2_DAT,
    inout PS2_CLK2,
    inout PS2_DAT2,

    /* SD Card */
    output SD_CLK,
    inout SD_CMD,
    inout [3:0] SD_DAT,
    inout SD_WP_N,

    /* VGA interface */
    output VGA_CLK,
    output [7:0] VGA_R,
    output [7:0] VGA_G,
    output [7:0] VGA_B,
    output VGA_HS,
    output VGA_VS,
    output VGA_BLANK_N,
    output VGA_SYNC_N,

    /* 24-bit audio CODEC */
    input AUD_ADCDAT,
    inout AUD_ADCLRCK,
    inout AUD_BCLK,
    output AUD_DACDAT,
    inout AUD_DACLRCK,
    output AUD_XCK,

    /* EEPROM */
    output EEP_I2C_SCLK,
    inout EEP_I2C_SDAT,

    /* I2C for audio and TV decoder */
    output I2C_SCLK,
    inout I2C_SDAT,

    /* Ethernet 0 */
    output       ENET0_GTX_CLK,
    input        ENET0_INT_N,
    output       ENET0_MDC,
    input        ENET0_MDIO,
    output       ENET0_RST_N,
    input        ENET0_RX_CLK,
    input        ENET0_RX_COL,
    input        ENET0_RX_CRS,
    input  [3:0] ENET0_RX_DATA,
    input        ENET0_RX_DV,
    input        ENET0_RX_ER,
    input        ENET0_TX_CLK,
    output [3:0] ENET0_TX_DATA,
    output       ENET0_TX_EN,
    output       ENET0_TX_ER,
    input        ENET0_LINK100,

    /* Ethernet 1 */
    output       ENET1_GTX_CLK,
    input        ENET1_INT_N,
    output       ENET1_MDC,
    input        ENET1_MDIO,
    output       ENET1_RST_N,
    input        ENET1_RX_CLK,
    input        ENET1_RX_COL,
    input        ENET1_RX_CRS,
    input  [3:0] ENET1_RX_DATA,
    input        ENET1_RX_DV,
    input        ENET1_RX_ER,
    input        ENET1_TX_CLK,
    output [3:0] ENET1_TX_DATA,
    output       ENET1_TX_EN,
    output       ENET1_TX_ER,
    input        ENET1_LINK100,

    /* TV decoder */
    input       TD_CLK27,
    input [7:0] TD_DATA,
    input       TD_HS,
    output      TD_RESET_N,
    input       TD_VS,

    /* USB interface */
    inout  [15:0] OTG_DATA,
    output [1:0]  OTG_ADDR,
    output        OTG_CS_N,
    output        OTG_WR_N,
    output        OTG_RD_N,
    input  [1:0]  OTG_INT,
    output        OTG_RST_N,
    input  [1:0]  OTG_DREQ,
    output [1:0]  OTG_DACK_N,
    inout         OTG_FSPEED,
    inout         OTG_LSPEED,

    /* IR receiver */
    input IRDA_RXD,

    /* external SDRAM */
    output [12:0] DRAM_ADDR,
    output [1:0]  DRAM_BA,
    output        DRAM_CAS_N,
    output        DRAM_CKE,
    output        DRAM_CLK,
    output        DRAM_CS_N,
    inout  [31:0] DRAM_DQ,
    output [3:0]  DRAM_DQM,
    output        DRAM_RAS_N,
    output        DRAM_WE_N,

    /* external SRAM */
    output [19:0] SRAM_ADDR,
    output        SRAM_CE_N,
    inout  [15:0] SRAM_DQ,
    output        SRAM_LB_N,
    output        SRAM_OE_N,
    output        SRAM_UB_N,
    output        SRAM_WE_N,

    /* Flash memory */
    output [22:0] FL_ADDR,
    output        FL_CE_N,
    inout  [7:0]  FL_DQ,
    output        FL_OE_N,
    output        FL_RST_N,
    input         FL_RY,
    output        FL_WE_N,
    output        FL_WP_N,

    inout [35:0] GPIO
);

    /* set all unused inouts to high-impedance (just in case) */
    assign LCD_DATA     = 8'hzz;
    assign PS2_CLK      = 1'bz;
    assign PS2_DAT      = 1'bz;
    assign PS2_CLK2     = 1'bz;
    assign PS2_DAT2     = 1'bz;
    assign SD_CLK       = 1'bz; // FIXME: output?
    assign SD_CMD       = 1'bz;
    assign SD_DAT       = 4'hz;
    assign SD_WP_N      = 1'bz;
    assign AUD_ADCLRCK  = 1'bz;
    assign AUD_BCLK     = 1'bz;
    assign AUD_DACLRCK  = 1'bz;
    assign AUD_DACDAT   = 1'bz; // FIXME: output?
    assign AUD_XCK      = 1'bz; // FIXME: output?
    assign EEP_I2C_SDAT = 1'bz;
    assign EEP_I2C_SCLK = 1'bz; // FIXME: output?
    assign I2C_SDAT     = 1'bz;
    assign I2C_SCLK     = 1'bz; // FIXME: output?
    assign OTG_FSPEED   = 1'bz;
    assign OTG_LSPEED   = 1'bz;
    assign OTG_DATA     = 16'hzzzz;
    assign DRAM_DQ      = 32'hzzzzzzzz;
    assign SRAM_DQ      = 16'hzzzz;
    assign FL_DQ        = 8'hzz;
    assign GPIO         = 36'hzzzzzzzz;

    /* reset delay timer */
    /* TODO: deal with this inverted logic madness... */
    wire not_rst, rst = ~not_rst | SW[16];
    Reset_Delay reset_delay(.iCLK(CLOCK_50), .oRESET(not_rst));

    /* TODO: do we need all these clocks? */
    wire clk_vga;
    VGA_Audio_PLL vga_audio_pll(
        .areset(rst),
        .inclk0(CLOCK2_50),
        .c0(clk_vga)
    );

    /* power down seven-segment displays */
    assign HEX0 = 7'b1111111;
    assign HEX1 = 7'b1111111;
    assign HEX2 = 7'b1111111;
    assign HEX3 = 7'b1111111;
    assign HEX4 = 7'b1111111;
    assign HEX5 = 7'b1111111;
    assign HEX6 = 7'b1111111;
    assign HEX7 = 7'b1111111;

    /* red LEDs show states of toggle switches */
    assign LEDR = SW;

    /* randomness source */
    wire [7:0] random;
    wire entropy = ~(KEY[0] | KEY[1] | KEY[2] | KEY[3]);
    PseudorandomGenerator prg(CLOCK2_50, rst, entropy, random);

    /* show off randomly generated bits using the green LEDs */
    reg [32:0] rnd_vis_cnt;
    reg [7:0] rnd_vis;
    assign LEDG = { 1'b0, rnd_vis };
    always @(posedge CLOCK2_50)
    begin
        if (rst)
        begin
            rnd_vis <= 8'b01010101;
            rnd_vis_cnt <= 32'd0;
        end
        else
        begin
            if (rnd_vis_cnt == 32'd50000000)
            begin
                rnd_vis_cnt <= 32'd0;
                rnd_vis <= ~random;
            end
            else
                rnd_vis_cnt <= rnd_vis_cnt + 32'd1;
        end
    end

    /* game state: goes from GameLogic to GameGraphics */
    wire [11:0] pad_left;
    wire [11:0] pad_right;
    wire [11:0] ball_x;
    wire [11:0] ball_y;

    GameLogic game_logic(
        .clk(CLOCK2_50),
        .rst(rst),
        .random(random),

        .pad_left(pad_left),
        .pad_right(pad_right),
        .ball_x(ball_x),
        .ball_y(ball_y),

        .keys_left(KEY[3:2]),
        .keys_right(KEY[1:0])
    );

    assign VGA_CLK = clk_vga;
    GameGraphics game_graphics(
        .clk_vga(clk_vga),
        .rst(rst),
        .switch(SW[5:0]),

        .pad_left(pad_left),
        .pad_right(pad_right),
        .ball_x(ball_x),
        .ball_y(ball_y),

        .VGA_BLANK_N(VGA_BLANK_N),
        .VGA_HS(VGA_HS),
        .VGA_VS(VGA_VS),
        .VGA_R(VGA_R),
        .VGA_G(VGA_G),
        .VGA_B(VGA_B)
    );
endmodule
