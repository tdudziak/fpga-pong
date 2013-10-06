module PseudorandomGenerator(
    input clk,
    input rst,
    input entropy,
    output [7:0] random
);

    reg [15:0] state;
    assign random = state[11:4];

    always @(posedge clk)
    begin
        if (rst)
            state <= 16'b1;
        else if (state == 16'd0)
            state <= 16'hbeef;
        else
            state <= { state[14] ^ entropy,
                       state[13:0],
                       state[10] ^ state[12] ^ state[13] ^ state[15] };
    end
endmodule
