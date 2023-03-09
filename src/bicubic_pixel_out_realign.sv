// System verilog source file
// Bicubic algorithm pixel output re-align module
// Designer:    Deng LiWei
// Date:        2022/03
// Description: This module has a register which help to re-align the output from
//    the Bicubic pipeline, because of the output has padding pixels and lines.

module bicubic_pixel_out_realign
(
    // Clock & reset
    input logic clk,
    input logic aresetn,
    input logic clken,
    input logic sclr,

    // Input data
    input logic [31:0] pixel_in,
    input logic        pixel_valid_in,
    input logic        pixel_end_of_line_in,
    input logic        pixel_start_of_frame_in,

    // Output data
    output logic [31:0] pixel_realign_out,
    output logic        pixel_valid_out,
    output logic        pixel_start_of_frame_out,
    output logic        pixel_end_of_line_out
);

logic [15:0] realign_reg;

always_ff @(posedge clk, negedge aresetn) begin
    if (!aresetn) begin
        realign_reg <= 'b0; 

        pixel_valid_out <= 'b0;
        pixel_start_of_frame_out <= 'b0;
    end
    else if (clken) begin
        if (sclr) begin
            realign_reg <= 'b0; 

            pixel_valid_out <= 'b0;
            pixel_start_of_frame_out <= 'b0;            
        end
        else begin
            if (pixel_valid_in) begin
                realign_reg <= pixel_in[31:16];
                pixel_start_of_frame_out <= pixel_start_of_frame_in;

                pixel_valid_out <= ~pixel_end_of_line_in;
            end
            else begin
                pixel_valid_out <= pixel_valid_in;
            end
        end
    end
end

assign pixel_realign_out = {pixel_in[15:0], realign_reg};
assign pixel_end_of_line_out = pixel_end_of_line_in;

endmodule
