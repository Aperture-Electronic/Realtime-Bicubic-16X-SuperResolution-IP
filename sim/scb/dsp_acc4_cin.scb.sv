// System verilog test scoreboard file
// DSP 4-input accumulator with compensate carry input
// Designer:    Deng LiWei
// Date:        2022/03

module dsp_acc4_cin_scb
(
    // Clock
    input logic clk,
    input logic aresetn,

    // Enable & reset
    input logic scoreboard_en,
    input logic scoreboard_reset,

    // Data from reference model
    input logic signed [17:0]op0_l_ref,
    input logic signed [17:0]op1_l_ref,
    input logic signed [17:0]op2_h_ref,
    input logic signed [17:0]op3_h_ref,
    input logic op2_cin_ref,
    input logic op3_cin_ref,
    input logic mode_ref,
    input logic signed [47:0]result_ref,
    input logic signed [47:0]acc_prev_ref, // Previous value in accumulator
    input logic signed [47:0]acc_value_ref,// New value add to accumulator

    // Data from DUV
    input logic signed [47:0]result,

    // Scoreboard output
    output int test_count,
    output int error_count
);

logic duv_ref_match;

always_comb begin
    duv_ref_match = result_ref === result; 
end

always_ff @(posedge clk, negedge aresetn) begin
    if (!aresetn) begin
        test_count <= 'b0;
        error_count <= 'b0;
    end
    else if (scoreboard_reset) begin
        $display("Scoreboard reseted @%t, all statistics goes to 0.", $time);
        error_count <= 'b0;
        test_count <= 'b0;
    end
    else if (scoreboard_en) begin
        if (!duv_ref_match) begin
            $display("Mismatched result when A(%d)+B(%d)+C(%d)+D(%d)+cC(%d)+cD(%d), ",
                op0_l_ref, op1_l_ref, op2_h_ref, op3_h_ref, op2_cin_ref, op3_cin_ref);
            $display("accumulator mode is %d, result must be %d, but now is %d, ",
                mode_ref, result_ref, result);
            $display("previous accumulator register value must be %d, ", acc_prev_ref);
            $display("new value add into accumulator must be %d.", acc_value_ref);
            error_count <= error_count + 1;
        end

        test_count <= test_count + 1;
    end   
end


endmodule

