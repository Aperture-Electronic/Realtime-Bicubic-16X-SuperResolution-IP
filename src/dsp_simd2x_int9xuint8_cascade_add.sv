// System verilog source file
// Cascade 2 DSP SIMD 2x INT9xUINT8 Multiplier Unit for Pipeline Adder (2 stage)
// Designer:    Deng LiWei
// Date:        2022/03
// Description: Cascade 2 DSP SIMD 2x INT9xUINT8 multiplier unit in pipeline for multiply-add

module dsp_simd2x_int9xuint8_cascade_add
(
    // Clock & reset
    input logic clk,
    input logic aresetn,
    input logic clken,

    // DSP synchronous reset
    input logic dsp_reset,

    // Data input
    input logic        [7:0]  a0,
    input logic        [7:0]  b0,
    input logic signed [8:0]  coeff0,
    input logic        [7:0]  a1,
    input logic        [7:0]  b1,
    input logic signed [8:0]  coeff1,

    // Data output
    output logic signed [47:0] dout
);

// A[0]      DSP1
// B[0]-->(X)-->(+)----+
// C[0]                |
// A[1]   +-+     DSP2 v
// B[1]-->| |-->(X)-->(+)-->P
// C[1]   +^+
//   |           |        |
//   +---- 4 ----+-- 1 ---+  Latency

logic signed [47:0] dsp1_dout;

logic [7:0]a1_buf;
logic [7:0]b1_buf;
logic [8:0]coeff1_buf;

// DSP1
dsp_simd2x_int9xuint8 #(
    .CASCADE_IN("false"),
    .CASCADE_OUT("true")
) dsp_blk1
(
    .*,
    .a(a0),
    .b(b0),
    .coeff(coeff0),
    .pcin(48'b0),
    .dout(dsp1_dout)
);

// Register for input data of DSP2
sfr_ce #(.LATENCY(1), .WIDTH(8)) sfr_a1 (.*, .data_in(a1), .data_out(a1_buf));
sfr_ce #(.LATENCY(1), .WIDTH(8)) sfr_b1 (.*, .data_in(b1), .data_out(b1_buf));
sfr_ce #(.LATENCY(1), .WIDTH(9)) sfr_coeff1 (.*, .data_in(coeff1), .data_out(coeff1_buf));

// DSP2
dsp_simd2x_int9xuint8 #(
    .CASCADE_IN("true"),
    .CASCADE_OUT("false")
) dsp_blk2
(
    .*,
    .a(a1_buf),
    .b(b1_buf),
    .coeff(coeff1_buf),
    .pcin(dsp1_dout)
);

endmodule

