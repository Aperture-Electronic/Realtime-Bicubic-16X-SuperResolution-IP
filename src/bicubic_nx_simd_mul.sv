// System verilog source file
// Nx SIMD 2x INT9xUINT8 Multiplier for Bicubic
// Designer:    Deng LiWei
// Date:        2022/03
// Description: This module includes N of SIMD 2x INT9xUINT8 cascade adder unit, 
//    which allow parallel computation in Bicubic processing pipeline.

module bicubic_nx_simd_mul
#(
    parameter PARALLEL_CORE = 8
)
(
    // Clock & reset
    input logic clk,
    input logic aresetn,
    input logic clken,

    input logic dsp_reset,

    // Data input
    input logic [PARALLEL_CORE * 8 - 1:0] a0,
    input logic [PARALLEL_CORE * 8 - 1:0] b0,
    input logic [PARALLEL_CORE * 9 - 1:0] coeff0, // Signed, do NOT use for calculation
    input logic [PARALLEL_CORE * 8 - 1:0] a1,
    input logic [PARALLEL_CORE * 8 - 1:0] b1,
    input logic [PARALLEL_CORE * 9 - 1:0] coeff1, // Signed, do NOT use for calculation

    // Data output
    output logic [PARALLEL_CORE * 48 - 1:0] dout
);

generate
    for (genvar i = 0; i < PARALLEL_CORE; i++) begin : PARALLEL_CORE_GEN
        dsp_simd2x_int9xuint8_cascade_add simd_core
        (
            .*,
            .a0(a0[(((i + 1) * 8) - 1):(i * 8)]),
            .b0(b0[(((i + 1) * 8) - 1):(i * 8)]),
            .coeff0(coeff0[(((i + 1) * 9) - 1):(i * 9)]),
            .a1(a1[(((i + 1) * 8) - 1):(i * 8)]),
            .b1(b1[(((i + 1) * 8) - 1):(i * 8)]),
            .coeff1(coeff1[(((i + 1) * 9) - 1):(i * 9)]),

            .dout(dout[(((i + 1) * 48) - 1):(i * 48)])
        );
    end
endgenerate

endmodule
