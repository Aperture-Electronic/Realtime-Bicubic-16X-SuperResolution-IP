// System verilog test reference model file
// DSP 8-input adder with compensate carry input
// Designer:    Deng LiWei
// Date:        2022/03

module dsp_add8_cin_ref
#(
    parameter LATENCY = 4
)
(
    // Clock & reset
    input logic clk,
    input logic aresetn,

    // DSP reset
    input logic dsp_reset,

    // Data input
    input logic signed [17:0]op0_l,
    input logic signed [17:0]op1_l,
    input logic signed [17:0]op2_h,
    input logic signed [17:0]op3_h,
    input logic signed [17:0]op4_l,
    input logic signed [17:0]op5_l,
    input logic signed [17:0]op6_h,
    input logic signed [17:0]op7_h,

    // Compensate input
    input logic op2_cin,
    input logic op3_cin,
    input logic op6_cin,
    input logic op7_cin,

    // Result output
    output logic signed [47:0]result,

    // Reference output
    output logic signed [17:0]op0_l_ref,
    output logic signed [17:0]op1_l_ref,
    output logic signed [17:0]op2_h_ref,
    output logic signed [17:0]op3_h_ref,
    output logic signed [17:0]op4_l_ref,
    output logic signed [17:0]op5_l_ref,
    output logic signed [17:0]op6_h_ref,
    output logic signed [17:0]op7_h_ref,
    output logic op2_cin_ref,
    output logic op3_cin_ref,
    output logic op6_cin_ref,
    output logic op7_cin_ref
);

logic signed [47:0]result_val;
// Computation
always_comb begin
    if (dsp_reset) begin
        result_val = 0;
    end
    else begin
        result_val = op0_l + op1_l + op2_h + op3_h + op4_l + op5_l + op6_h + op7_h + 
            $signed({1'b0, op2_cin}) + $signed({1'b0, op3_cin}) +
            $signed({1'b0, op6_cin}) + $signed({1'b0, op7_cin});
    end
end

// Shift registers
sfr #(.LATENCY(LATENCY), .WIDTH(48)) srl_result_ref (.*, .data_in(result_val), .data_out(result));

sfr #(.LATENCY(LATENCY), .WIDTH(18)) srl_op0_ref (.*, .data_in(op0_l), .data_out(op0_l_ref));
sfr #(.LATENCY(LATENCY), .WIDTH(18)) srl_op1_ref (.*, .data_in(op1_l), .data_out(op1_l_ref));
sfr #(.LATENCY(LATENCY), .WIDTH(18)) srl_op2_ref (.*, .data_in(op2_h), .data_out(op2_h_ref));
sfr #(.LATENCY(LATENCY), .WIDTH(18)) srl_op3_ref (.*, .data_in(op3_h), .data_out(op3_h_ref));
sfr #(.LATENCY(LATENCY), .WIDTH(18)) srl_op4_ref (.*, .data_in(op4_l), .data_out(op4_l_ref));
sfr #(.LATENCY(LATENCY), .WIDTH(18)) srl_op5_ref (.*, .data_in(op5_l), .data_out(op5_l_ref));
sfr #(.LATENCY(LATENCY), .WIDTH(18)) srl_op6_ref (.*, .data_in(op6_h), .data_out(op6_h_ref));
sfr #(.LATENCY(LATENCY), .WIDTH(18)) srl_op7_ref (.*, .data_in(op7_h), .data_out(op7_h_ref));

sfr #(.LATENCY(LATENCY), .WIDTH(1)) srl_op2_cin_ref (.*, .data_in(op2_cin), .data_out(op2_cin_ref));
sfr #(.LATENCY(LATENCY), .WIDTH(1)) srl_op3_cin_ref (.*, .data_in(op3_cin), .data_out(op3_cin_ref));
sfr #(.LATENCY(LATENCY), .WIDTH(1)) srl_op6_cin_ref (.*, .data_in(op6_cin), .data_out(op6_cin_ref));
sfr #(.LATENCY(LATENCY), .WIDTH(1)) srl_op7_cin_ref (.*, .data_in(op7_cin), .data_out(op7_cin_ref));

endmodule
