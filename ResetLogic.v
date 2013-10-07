module ResetLogic(
    input clk,
    input rst_button,
    output reg rst
);

    parameter reset_val = 20'hfffff;
    reg [19:0] counter;

    always @(posedge clk, posedge rst_button)
    begin
        if (rst_button)
            rst <= 1'b1;
        else
        begin
            if (counter != reset_val)
            begin
                counter <= counter + 20'd1;
                rst <= 1'b1;
            end
            else
                rst <= 1'b0;
        end
    end
endmodule
