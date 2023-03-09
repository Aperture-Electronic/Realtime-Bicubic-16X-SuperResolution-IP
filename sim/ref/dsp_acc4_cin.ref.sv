// System verilog test reference model file
// DSP 4-input accumulator with compensate carry input
// Designer:    Deng LiWei
// Date:        2022/03

module dsp_acc4_cin_ref
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

    // Compensate input
    input logic op2_cin,
    input logic op3_cin,

    // Mode input
    input logic mode,

    // Result output
    output logic signed [47:0]result,

    // Reference output
    output logic signed [17:0]op0_l_ref,
    output logic signed [17:0]op1_l_ref,
    output logic signed [17:0]op2_h_ref,
    output logic signed [17:0]op3_h_ref,
    output logic op2_cin_ref,
    output logic op3_cin_ref,
    output logic mode_ref,
    output logic signed [47:0]acc_prev_ref, // Previous value in accumulator
    output logic signed [47:0]acc_value_ref // New value add to accumulator
);

logic signed [47:0]acc_val;
logic signed [47:0]acc_reg;

// Computation
always_comb begin
    if (dsp_reset) begin
        acc_val = 0;
    end
    else begin
        acc_val = op0_l + op1_l + op2_h + op3_h + 
            $signed({1'b0, op2_cin}) + $signed({1'b0, op3_cin});
    end
end

// Accumulator
always_ff @(posedge clk) begin
    if (dsp_reset) begin
        acc_reg <= 0;
    end
    else begin
        if (mode) begin
            acc_reg <= acc_reg + acc_val;
        end
        else begin
            acc_reg <= acc_val;
        end
    end
end

// Shift registers
sfr #(.LATENCY(LATENCY - 1), .WIDTH(48)) srl_result_ref (.*, .data_in(acc_reg), .data_out(result));

sfr #(.LATENCY(LATENCY), .WIDTH(48)) srl_acc_prev_ref (.*, .data_in(acc_reg), .data_out(acc_prev_ref));
sfr #(.LATENCY(LATENCY), .WIDTH(48)) srl_acc_val_ref (.*, .data_in(acc_val), .data_out(acc_value_ref));

sfr #(.LATENCY(LATENCY), .WIDTH(18)) srl_op0_ref (.*, .data_in(op0_l), .data_out(op0_l_ref));
sfr #(.LATENCY(LATENCY), .WIDTH(18)) srl_op1_ref (.*, .data_in(op1_l), .data_out(op1_l_ref));
sfr #(.LATENCY(LATENCY), .WIDTH(18)) srl_op2_ref (.*, .data_in(op2_h), .data_out(op2_h_ref));
sfr #(.LATENCY(LATENCY), .WIDTH(18)) srl_op3_ref (.*, .data_in(op3_h), .data_out(op3_h_ref));

sfr #(.LATENCY(LATENCY), .WIDTH(1)) srl_op2_cin_ref (.*, .data_in(op2_cin), .data_out(op2_cin_ref));
sfr #(.LATENCY(LATENCY), .WIDTH(1)) srl_op3_cin_ref (.*, .data_in(op3_cin), .data_out(op3_cin_ref));
sfr #(.LATENCY(LATENCY), .WIDTH(1)) srl_mode_ref (.*, .data_in(mode), .data_out(mode_ref));

endmodule
