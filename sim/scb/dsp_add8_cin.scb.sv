// System verilog test scoreboard file
// DSP 8-input adder with compensate carry input
// Designer:    Deng LiWei
// Date:        2022/03

module dsp_add8_cin_scb
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
    input logic signed [17:0]op4_l_ref,
    input logic signed [17:0]op5_l_ref,
    input logic signed [17:0]op6_h_ref,
    input logic signed [17:0]op7_h_ref,
    input logic op2_cin_ref,
    input logic op3_cin_ref,
    input logic op6_cin_ref,
    input logic op7_cin_ref,
    input logic signed [47:0]result_ref,

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
            $display("Mismatched result when A(%d)+B(%d)+C(%d)+D(%d)+cC(%d)+cD(%d)+",
                op0_l_ref, op1_l_ref, op2_h_ref, op3_h_ref, op2_cin_ref, op3_cin_ref);
            $display("E(%d)+F(%d)+G(%d)+H(%d)+cG(%d)+cH(%d), must be %d, but now is %d.",
                op4_l_ref, op5_l_ref, op6_h_ref, op7_h_ref, op6_cin_ref, op7_cin_ref, result_ref, result);
            error_count <= error_count + 1;
        end

        test_count <= test_count + 1;
    end   
end


endmodule

