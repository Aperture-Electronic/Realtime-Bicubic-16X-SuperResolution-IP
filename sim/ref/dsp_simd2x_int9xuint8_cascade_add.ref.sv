// System verilog test reference model file
// DSP SIMD 2x INT9xUINT8 Multiplier Unit
// Designer:    Deng LiWei
// Date:        2022/03

module dsp_simd2x_int9xuint8_cascade_add_ref
#(
    parameter LATENCY = 5
)
(
    // Clock & reset
    input logic clk,
    input logic aresetn,

    // Input data
    input  var        [7:0]a     [0:1],
    input  var        [7:0]b     [0:1],
    input  var signed [8:0]coeff [0:1],

    // Output data
    output logic signed [17:0]ca_mul,
    output logic signed [17:0]cb_mul,
    output var        [7:0]a_ref     [0:1],
    output var        [7:0]b_ref     [0:1],
    output var signed [8:0]coeff_ref [0:1]
);

logic signed [8:0]a_signed;
logic signed [8:0]b_signed;

logic signed [17:0]result_a;
logic signed [17:0]result_b;

// Computation
always_comb begin
    result_a = 0;
    result_b = 0;
    for (int i = 0; i < 2; i++) begin
        a_signed = a[i];
        b_signed = b[i];
        result_a += a_signed * coeff[i];
        result_b += b_signed * coeff[i];
    end  
end

// Shift registers
generate
    for (genvar i = 0; i < 2; i++) begin
        sfr #(.LATENCY(LATENCY), .WIDTH(8)) srl_a_ref (.*, .data_in(a[i]), .data_out(a_ref[i]));
        sfr #(.LATENCY(LATENCY), .WIDTH(8)) srl_b_ref (.*, .data_in(b[i]), .data_out(b_ref[i]));
        sfr #(.LATENCY(LATENCY), .WIDTH(9)) srl_coeff_ref (.*, .data_in(coeff[i]), .data_out(coeff_ref[i]));
    end
endgenerate

sfr #(.LATENCY(LATENCY), .WIDTH(18)) srl_ca (.*, .data_in(result_a), .data_out(ca_mul));
sfr #(.LATENCY(LATENCY), .WIDTH(18)) srl_cb (.*, .data_in(result_b), .data_out(cb_mul));

endmodule
