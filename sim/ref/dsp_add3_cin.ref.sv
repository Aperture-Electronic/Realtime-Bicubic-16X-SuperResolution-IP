// System verilog test reference model file
// DSP 3-input Adder with compensate carry input
// Designer:    Deng LiWei
// Date:        2022/03

module dsp_add3_cin_ref
#(
    parameter LATENCY = 2
)
(
    // Clock & reset
    input logic clk,
    input logic aresetn,

    // DSP reset
    input logic dsp_reset,

    // Data input
    input logic signed [17:0]op0,
    input logic signed [17:0]op1,
    input logic signed [17:0]op2,

    // Compensate input
    input logic cin,

    // Output
    output logic signed [47:0]result,

    // Reference output
    output logic signed [17:0]op0_ref,
    output logic signed [17:0]op1_ref,
    output logic signed [17:0]op2_ref,
    output logic cin_ref
);

logic signed [47:0] result_p;
logic signed [1:0]cin_signed;

// Computation
always_comb begin
    if (dsp_reset) begin
        cin_signed = 0;
        result_p = 0;
    end
    else begin
        cin_signed = cin;
        result_p = op0 + op1 + op2 + cin_signed; 
    end
end

// Shift registers
sfr #(.LATENCY(LATENCY), .WIDTH(48)) srl_result_ref (.*, .data_in(result_p), .data_out(result));

sfr #(.LATENCY(LATENCY), .WIDTH(18)) srl_op0_ref (.*, .data_in(op0), .data_out(op0_ref));
sfr #(.LATENCY(LATENCY), .WIDTH(18)) srl_op1_ref (.*, .data_in(op1), .data_out(op1_ref));
sfr #(.LATENCY(LATENCY), .WIDTH(18)) srl_op2_ref (.*, .data_in(op2), .data_out(op2_ref));
sfr #(.LATENCY(LATENCY), .WIDTH(1)) srl_cin_ref (.*, .data_in(cin), .data_out(cin_ref));

endmodule
