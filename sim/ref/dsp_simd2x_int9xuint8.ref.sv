// System verilog test reference model file
// DSP SIMD 2x INT9xUINT8 Multiplier Unit
// Designer:    Deng LiWei
// Date:        2022/03

module dsp_simd2x_int9xuint8_ref
#(
    parameter LATENCY = 4
)
(
    // Clock & reset
    input logic clk,
    input logic aresetn,

    // Input data
    input  logic        [7:0]a,
    input  logic        [7:0]b,
    input  logic signed [8:0]coeff,

    // Output data
    output logic signed [17:0]ca_mul,
    output logic signed [17:0]cb_mul,
    output logic        [7:0]a_ref,
    output logic        [7:0]b_ref,
    output logic signed [8:0]coeff_ref
);

logic signed [8:0]a_signed;
logic signed [8:0]b_signed;

logic signed [17:0]result_a;
logic signed [17:0]result_b;

// Computation
always_comb begin
    a_signed = a;
    b_signed = b;
    result_a = a_signed * coeff;
    result_b = b_signed * coeff;
end

// Shift registers
sfr #(.LATENCY(LATENCY), .WIDTH(8)) srl_a_ref (.*, .data_in(a), .data_out(a_ref));
sfr #(.LATENCY(LATENCY), .WIDTH(8)) srl_b_ref (.*, .data_in(b), .data_out(b_ref));
sfr #(.LATENCY(LATENCY), .WIDTH(9)) srl_coeff_ref (.*, .data_in(coeff), .data_out(coeff_ref));
sfr #(.LATENCY(LATENCY), .WIDTH(18)) srl_ca (.*, .data_in(result_a), .data_out(ca_mul));
sfr #(.LATENCY(LATENCY), .WIDTH(18)) srl_cb (.*, .data_in(result_b), .data_out(cb_mul));

endmodule
