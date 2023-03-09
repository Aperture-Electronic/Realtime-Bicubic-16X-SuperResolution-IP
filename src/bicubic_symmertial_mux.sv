// System verilog source file
// Symmertial multiplexer for Bicubic input reference pixels
// Designer:    Deng LiWei
// Date:        2022/03
// Description: A Y-axis symmertial multiplexer for Bicubic input reference pixels.
//    Line 0, 1 in superblock can read the reference pixel line-sequentially,
//    and line 2, 3 in superblock can read the reference pixel in reverse-line order.
//    This version of symmertial multiplexer did not support multi-phase DSP operation.

module bicubic_symmertial_mux
(
    // Clock & reset
    input logic clk,
    input logic aresetn,
    input logic clken,

    // Symmertial control
    input logic super_y_symmetric,

    // Input reference pixels
    input logic [7:0]px_0_0_in,
    input logic [7:0]px_1_0_in,
    input logic [7:0]px_2_0_in,
    input logic [7:0]px_3_0_in,

    input logic [7:0]px_0_1_in,
    input logic [7:0]px_1_1_in,
    input logic [7:0]px_2_1_in,
    input logic [7:0]px_3_1_in,

    input logic [7:0]px_0_2_in,
    input logic [7:0]px_1_2_in,
    input logic [7:0]px_2_2_in,
    input logic [7:0]px_3_2_in,

    input logic [7:0]px_0_3_in,
    input logic [7:0]px_1_3_in,
    input logic [7:0]px_2_3_in,
    input logic [7:0]px_3_3_in,

    // Output pixels
    output logic [8 * 8 - 1:0]dsp_grp_l_out,
    output logic [8 * 8 - 1:0]dsp_grp_h_out
);

always_ff @(posedge clk, negedge aresetn) begin : SYMMERTIAL_CTRL
    if (!aresetn) begin
        dsp_grp_l_out <= 'b0;
        dsp_grp_h_out <= 'b0;
    end
    else if (clken) begin
        if (super_y_symmetric) begin
            dsp_grp_l_out <= {
                px_2_0_in,
                px_2_1_in,
                px_3_0_in,
                px_3_1_in,
                px_2_2_in,
                px_2_3_in,
                px_3_2_in,
                px_3_3_in
            };

            dsp_grp_h_out <= {
                px_1_0_in,
                px_1_1_in,
                px_0_0_in,
                px_0_1_in,
                px_1_2_in,
                px_1_3_in,
                px_0_2_in,
                px_0_3_in
            };
        end
        else begin
            dsp_grp_l_out <= {
                px_2_3_in,
                px_2_2_in,
                px_3_3_in,
                px_3_2_in,
                px_2_1_in,
                px_2_0_in,
                px_3_1_in,
                px_3_0_in
            };

            dsp_grp_h_out <= {
                px_1_3_in,
                px_1_2_in,
                px_0_3_in,
                px_0_2_in,
                px_1_1_in,
                px_1_0_in,
                px_0_1_in,
                px_0_0_in
            };
        end
    end
end

endmodule

