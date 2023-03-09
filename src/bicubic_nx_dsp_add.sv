// System verilog source file
// Nx DSP 8-input adder for Bicubic
// Designer:    Deng LiWei
// Date:        2022/03
// Description: This module includes N of DSP 8-input adder unit, 
//    which allow parallel computation in Bicubic processing pipeline.

module bicubic_nx_dsp_add
#(
    parameter PARALLEL_CORE = 4
)
(
    // Clock & reset
    input logic clk,
    input logic aresetn,
    input logic clken,

    // DSP reset
    input logic dsp_reset,

    // Data input
    input logic [PARALLEL_CORE * 18 - 1:0]op0_l,
    input logic [PARALLEL_CORE * 18 - 1:0]op1_l,
    input logic [PARALLEL_CORE * 18 - 1:0]op2_h,
    input logic [PARALLEL_CORE * 18 - 1:0]op3_h,
    input logic [PARALLEL_CORE * 18 - 1:0]op4_l,
    input logic [PARALLEL_CORE * 18 - 1:0]op5_l,
    input logic [PARALLEL_CORE * 18 - 1:0]op6_h,
    input logic [PARALLEL_CORE * 18 - 1:0]op7_h,

    // Compensate input
    input logic [PARALLEL_CORE - 1:0]op2_cin,
    input logic [PARALLEL_CORE - 1:0]op3_cin,
    input logic [PARALLEL_CORE - 1:0]op6_cin,
    input logic [PARALLEL_CORE - 1:0]op7_cin,

    // Result output
    output logic [PARALLEL_CORE * 48 - 1:0]result
);

generate
    for (genvar i = 0; i < PARALLEL_CORE; i++) begin : PARALLEL_CORE_GEN
        dsp_add8_cin add_core
        (
            .*,
            .op0_l(op0_l[(((i + 1) * 18) - 1):(i * 18)]),
            .op1_l(op1_l[(((i + 1) * 18) - 1):(i * 18)]),
            .op2_h(op2_h[(((i + 1) * 18) - 1):(i * 18)]),
            .op3_h(op3_h[(((i + 1) * 18) - 1):(i * 18)]),
            .op4_l(op4_l[(((i + 1) * 18) - 1):(i * 18)]),
            .op5_l(op5_l[(((i + 1) * 18) - 1):(i * 18)]),
            .op6_h(op6_h[(((i + 1) * 18) - 1):(i * 18)]),
            .op7_h(op7_h[(((i + 1) * 18) - 1):(i * 18)]),

            .op2_cin(op2_cin[i]),
            .op3_cin(op3_cin[i]),
            .op6_cin(op6_cin[i]),
            .op7_cin(op7_cin[i]),

            .result(result[(((i + 1) * 48) - 1):(i * 48)])
        );
    end
endgenerate

endmodule
