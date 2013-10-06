module ResetLogic(
    input clk,
    input rst_button,
    output reg rst
);

    parameter reset_val = 20'hfffff;
    reg [19:0] counter;

    always @(posedge clk, negedge rst_button)
    begin
        if (rst_button == 1'b0 || counter == reset_val)
            rst <= 1'b1;
        else if (rst == 1'b1)
            rst <= 1'b0;
        else if (counter != reset_val)
        begin
            rst <= 1'b0;
            counter <= counter + 20'd1;
        end
    end
endmodule
