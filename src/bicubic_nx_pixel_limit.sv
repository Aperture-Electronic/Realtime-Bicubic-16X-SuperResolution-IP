// System verilog source file
// Nx pixel limitation output module for Bicubic
// Designer:    Deng LiWei
// Date:        2022/03
// Description: This module includes N of pixel limitation output module, 
//    which allow parallel computation in Bicubic processing pipeline.

module bicubic_nx_pixel_limit
#(
    // Parallel core
    parameter PARALLEL_CORE = 2,
    // Input width
    parameter INPUT_WIDTH = 9
)
(
    // Clock & reset
    input logic clk,
    input logic aresetn,
    input logic clken,

    // Data input
    input logic signed [PARALLEL_CORE * INPUT_WIDTH - 1:0]data_in,

    // Data output
    output logic [PARALLEL_CORE * 8 - 1:0]pixel_out
);

generate
    for (genvar i = 0; i < PARALLEL_CORE; i++) begin : PARALLEL_CORE_GEN
        pixel_limit_output #(
            .INPUT_WIDTH(INPUT_WIDTH)
        )
        pxlm_core
        (
            .*,
            .data_in(data_in[(((i + 1) * INPUT_WIDTH) - 1):(i * INPUT_WIDTH)]),
            .pixel_out(pixel_out[(((i + 1) * 8) - 1):(i * 8)])
        );
    end
endgenerate

endmodule
