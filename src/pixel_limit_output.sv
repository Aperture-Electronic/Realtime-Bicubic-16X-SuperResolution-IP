// System verilog source file
// Pixel limitation output
// Designer:    Deng LiWei
// Date:        2022/03
// Description: A module can limit the output of pixel data in standard range (0-255)

module pixel_limit_output
#(
    parameter INPUT_WIDTH = 9
)
(
    // Clock & reset
    input logic clk,
    input logic aresetn,

    // Data input
    input logic signed [INPUT_WIDTH - 1:0]data_in,

    // Data output
    output logic [7:0]pixel_out
);

logic sign;
logic over_max;

assign sign = data_in[INPUT_WIDTH - 1];
assign over_max = data_in > 255;

always_ff @(posedge clk, negedge aresetn) begin
    if (!aresetn) begin
        pixel_out <= 'b0;
    end
    else begin
        if (sign) begin
            pixel_out <= 'h0;
        end
        else if (over_max) begin
            pixel_out <= 'hFF;
        end
        else begin
            pixel_out <= data_in[7:0];
        end
    end
end

endmodule

