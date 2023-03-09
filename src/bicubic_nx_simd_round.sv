// System verilog source file
// Nx DSP SIMD 2x rounding for Bicubic
// Designer:    Deng LiWei
// Date:        2022/03
// Description: This module includes N of SIMD 2x rounding unit, 
//    which allow parallel computation in Bicubic processing pipeline.

module bicubic_nx_round
#(
    // Parallel core
    parameter PARALLEL_CORE = 2,
    // Input width
    parameter INPUT_WIDTH = 48,
    // Right shifting bits
    parameter RSHIFT_RANGE = 8,
    // Output width
    parameter OUTPUT_WIDTH = 9
)
(
    // Clock & reset
    input logic clk,
    input logic aresetn,
    input logic clken,

    // DSP synchronous reset (Only use in DSP implement)
    input logic dsp_reset,

    // Data input
    input logic signed [INPUT_WIDTH * PARALLEL_CORE - 1:0]rin_ch0,
    input logic signed [INPUT_WIDTH * PARALLEL_CORE - 1:0]rin_ch1,

    // Data output
    output logic signed [OUTPUT_WIDTH * PARALLEL_CORE - 1:0]rout_ch0,
    output logic signed [OUTPUT_WIDTH * PARALLEL_CORE - 1:0]rout_ch1
);

generate
    for (genvar i = 0; i < PARALLEL_CORE; i++) begin : PARALLEL_CORE_GEN
        simd2x_round #(
            .INPUT_WIDTH(INPUT_WIDTH),
            .RSHIFT_RANGE(RSHIFT_RANGE),
            .OUTPUT_WIDTH(OUTPUT_WIDTH)
        ) round_core
        (
            .*,
            .rin_ch0(rin_ch0[(((i + 1) * INPUT_WIDTH) - 1):(i * INPUT_WIDTH)]),
            .rin_ch1(rin_ch1[(((i + 1) * INPUT_WIDTH) - 1):(i * INPUT_WIDTH)]),
            .rout_ch0(rout_ch0[(((i + 1) * OUTPUT_WIDTH) - 1):(i * OUTPUT_WIDTH)]),
            .rout_ch1(rout_ch1[(((i + 1) * OUTPUT_WIDTH) - 1):(i * OUTPUT_WIDTH)])
        );
    end
endgenerate


endmodule
