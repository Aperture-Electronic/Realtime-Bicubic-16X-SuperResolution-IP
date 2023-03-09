// System verilog source file
// SIMD 4x rounding module
// Designer:    Deng LiWei
// Date:        2022/03
// Description: This module can shifting & rounding 4 of pixels in parallel.
//     Can implement by DSP or LUT.
`include "bicubic_global_settings.sv"

module simd4x_round
#(
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
    input logic signed [INPUT_WIDTH - 1:0]rin_ch0,
    input logic signed [INPUT_WIDTH - 1:0]rin_ch1,
    input logic signed [INPUT_WIDTH - 1:0]rin_ch2,
    input logic signed [INPUT_WIDTH - 1:0]rin_ch3,

    // Data output
    output logic signed [OUTPUT_WIDTH - 1:0]rout_ch0,
    output logic signed [OUTPUT_WIDTH - 1:0]rout_ch1,
    output logic signed [OUTPUT_WIDTH - 1:0]rout_ch2,
    output logic signed [OUTPUT_WIDTH - 1:0]rout_ch3
);

// Rounding
logic signed [OUTPUT_WIDTH - 1:0]rounding_ch0;
logic signed [OUTPUT_WIDTH - 1:0]rounding_ch1;
logic signed [OUTPUT_WIDTH - 1:0]rounding_ch2;
logic signed [OUTPUT_WIDTH - 1:0]rounding_ch3;
logic round_carry_ch0;
logic round_carry_ch1;
logic round_carry_ch2;
logic round_carry_ch3;

assign rounding_ch0 = rin_ch0[RSHIFT_RANGE + OUTPUT_WIDTH - 1:RSHIFT_RANGE];
assign rounding_ch1 = rin_ch1[RSHIFT_RANGE + OUTPUT_WIDTH - 1:RSHIFT_RANGE];
assign rounding_ch2 = rin_ch2[RSHIFT_RANGE + OUTPUT_WIDTH - 1:RSHIFT_RANGE];
assign rounding_ch3 = rin_ch3[RSHIFT_RANGE + OUTPUT_WIDTH - 1:RSHIFT_RANGE];
assign round_carry_ch0 = rin_ch0[RSHIFT_RANGE - 1];
assign round_carry_ch1 = rin_ch1[RSHIFT_RANGE - 1];
assign round_carry_ch2 = rin_ch2[RSHIFT_RANGE - 1];
assign round_carry_ch3 = rin_ch3[RSHIFT_RANGE - 1];

`ifdef USE_LUT_FOR_ROUNDING
// Input registers
logic signed [OUTPUT_WIDTH - 1:0]rsft_ch0_in_reg;
logic signed [OUTPUT_WIDTH - 1:0]rsft_ch1_in_reg;
logic signed [OUTPUT_WIDTH - 1:0]rsft_ch2_in_reg;
logic signed [OUTPUT_WIDTH - 1:0]rsft_ch3_in_reg;
logic rc_ch0_in_reg;
logic rc_ch1_in_reg;
logic rc_ch2_in_reg;
logic rc_ch3_in_reg;

always_ff @(posedge clk, negedge aresetn) begin
    if (!aresetn) begin
        rsft_ch0_in_reg <= 'b0;
        rsft_ch1_in_reg <= 'b0;
        rsft_ch2_in_reg <= 'b0;
        rsft_ch3_in_reg <= 'b0;
        rc_ch0_in_reg <= 'b0;
        rc_ch1_in_reg <= 'b0;
        rc_ch2_in_reg <= 'b0;
        rc_ch3_in_reg <= 'b0;
    end
    else begin
        rsft_ch0_in_reg <= rounding_ch0;
        rsft_ch1_in_reg <= rounding_ch1;
        rsft_ch2_in_reg <= rounding_ch2;
        rsft_ch3_in_reg <= rounding_ch3;
        rc_ch0_in_reg <= round_carry_ch0;
        rc_ch1_in_reg <= round_carry_ch1;
        rc_ch2_in_reg <= round_carry_ch2;
        rc_ch3_in_reg <= round_carry_ch3;
    end
end
 
// Output
logic signed [OUTPUT_WIDTH - 1:0]rout_ch0_reg;
logic signed [OUTPUT_WIDTH - 1:0]rout_ch1_reg;
logic signed [OUTPUT_WIDTH - 1:0]rout_ch2_reg;
logic signed [OUTPUT_WIDTH - 1:0]rout_ch3_reg;

always_ff @(posedge clk, negedge aresetn) begin
    if (!aresetn) begin
        rout_ch0_reg <= 'b0;
        rout_ch1_reg <= 'b0;
        rout_ch2_reg <= 'b0;
        rout_ch3_reg <= 'b0;
    end
    else begin
        rout_ch0_reg <= rsft_ch0_in_reg + $signed({1'b0, rc_ch0_in_reg});
        rout_ch1_reg <= rsft_ch1_in_reg + $signed({1'b0, rc_ch1_in_reg});
        rout_ch2_reg <= rsft_ch2_in_reg + $signed({1'b0, rc_ch2_in_reg});
        rout_ch3_reg <= rsft_ch3_in_reg + $signed({1'b0, rc_ch3_in_reg});
    end
end  

assign rout_ch0 = rout_ch0_reg;
assign rout_ch1 = rout_ch1_reg;
assign rout_ch2 = rout_ch2_reg;
assign rout_ch3 = rout_ch3_reg;

`else // Using DSP

logic signed [11:0]dsp_a0;
logic signed [11:0]dsp_b0;
logic signed [11:0]dsp_a1;
logic signed [11:0]dsp_b1;
logic signed [11:0]dsp_a2;
logic signed [11:0]dsp_b2;
logic signed [11:0]dsp_a3;
logic signed [11:0]dsp_b3;
logic signed [11:0]dsp_out0;
logic signed [11:0]dsp_out1;
logic signed [11:0]dsp_out2;
logic signed [11:0]dsp_out3;

assign dsp_a0 = rounding_ch0;
assign dsp_b0 = round_carry_ch0;
assign dsp_a1 = rounding_ch1;
assign dsp_b1 = round_carry_ch1;
assign dsp_a2 = rounding_ch2;
assign dsp_b2 = round_carry_ch2;
assign dsp_a3 = rounding_ch3;
assign dsp_b3 = round_carry_ch3;

dsp_simd4x_int12_add dsp_round_adder
(
    .*,
    .a0(dsp_a0),
    .b0(dsp_b0),
    .a1(dsp_a1),
    .b1(dsp_b1),
    .a2(dsp_a2),
    .b2(dsp_b2),
    .a3(dsp_a3),
    .b3(dsp_b3),
    .add0(dsp_out0),
    .add1(dsp_out1),
    .add2(dsp_out2),
    .add3(dsp_out3)
);

assign rout_ch0 = dsp_out0[OUTPUT_WIDTH - 1:0];
assign rout_ch1 = dsp_out1[OUTPUT_WIDTH - 1:0];
assign rout_ch2 = dsp_out2[OUTPUT_WIDTH - 1:0];
assign rout_ch3 = dsp_out3[OUTPUT_WIDTH - 1:0];

`endif

endmodule

