// all dimensions in pixels
`define SCREEN_WIDTH 1024
`define SCREEN_HEIGHT 768

// space between each pad and screen edge
`define PAD_DISTANCE 10

`define PAD_WIDTH 12
`define PAD_HEIGHT 140

// ball radius is equal to sqrt(2**BALL_SIZE_LOG2) = 2**(BALL_SIZE_LOG2/2)
`define BALL_SIZE_LOG2 6

// vaguely related to how fast the pads are moving (smaller is faster)
`define GAME_SLOWNESS 16
