// all dimensions in pixels
`define SCREEN_WIDTH 640
`define SCREEN_HEIGHT 480

// space between each pad and screen edge
`define PAD_DISTANCE 5

`define PAD_WIDTH 10
`define PAD_HEIGHT 70

// ball radius is equal to sqrt(2**BALL_SIZE_LOG2) = 2**(BALL_SIZE_LOG2/2)
`define BALL_SIZE_LOG2 6

// vaguely related to how fast the pads are moving (smaller is faster)
`define GAME_SLOWNESS 17
