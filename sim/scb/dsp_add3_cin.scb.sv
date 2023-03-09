// System verilog test scoreboard file
// DSP 3-input Adder with compensate carry input
// Designer:    Deng LiWei
// Date:        2022/03

module dsp_add3_cin_scb
(
    // Clock
    input logic clk,
    input logic aresetn,

    // Enable & reset
    input logic scoreboard_en,
    input logic scoreboard_reset,

    // Data from reference model
    input logic signed [17:0]op0_ref,
    input logic signed [17:0]op1_ref,
    input logic signed [17:0]op2_ref,
    input logic cin_ref,
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
            $display("Mismatched result when A(%d)+B(%d)+C(%d)+CIN(%d), must be %d, but now is %d",
                op0_ref, op1_ref, op2_ref, cin_ref, result_ref, result);
            error_count <= error_count + 1;
        end

        test_count <= test_count + 1;
    end   
end
    
endmodule

