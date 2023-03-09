// System verilog test scroeboard file
// SIMD 2x rounding module
// Designer:    Deng LiWei
// Date:        2022/03

module simd2x_round_scb
#(
    parameter INPUT_WIDTH = 48,
    parameter RSHIFT_RANGE = 8,
    parameter OUTPUT_WIDTH = 9
)
(
    // Clock
    input logic clk,
    input logic aresetn,

    // Enable & reset
    input logic scoreboard_en,
    input logic scoreboard_reset,

    // Data from reference model
    input logic signed [OUTPUT_WIDTH - 1:0]rout_ch0_ref,
    input logic signed [OUTPUT_WIDTH - 1:0]rout_ch1_ref,
    input logic signed [INPUT_WIDTH - 1:0]rin_ch0_ref,
    input logic signed [INPUT_WIDTH - 1:0]rin_ch1_ref,

    // Data from DUV
    input logic signed [OUTPUT_WIDTH - 1:0]rout_ch0,
    input logic signed [OUTPUT_WIDTH - 1:0]rout_ch1,

    // Scoreboard output
    output int test_count,
    output int error_count,
    output int ch0_error_count,
    output int ch1_error_count
);

logic duv_ref_match;
logic duv_ref_ch0_dismatch;
logic duv_ref_ch1_dismatch;

always_comb begin
    duv_ref_ch0_dismatch = rout_ch0_ref !== rout_ch0;
    duv_ref_ch1_dismatch = rout_ch1_ref !== rout_ch1;
    duv_ref_match = !(duv_ref_ch0_dismatch || duv_ref_ch1_dismatch);
end

always_ff @(posedge clk, negedge aresetn) begin
    if (!aresetn) begin
        test_count <= 'b0;
        error_count <= 'b0;
        ch0_error_count <= 'b0;
        ch1_error_count <= 'b0;
    end
    else if (scoreboard_reset) begin
        $display("Scoreboard reseted @%t, all statistics goes to 0.", $time);
        error_count <= 'b0;
        test_count <= 'b0;
        ch0_error_count <= 'b0;
        ch1_error_count <= 'b0;
    end
    else if (scoreboard_en) begin
        if (!duv_ref_match) begin
            if (duv_ref_ch0_dismatch) begin
                $display("Mismatched result of channel 0.");
                $display("When X(%d) must rounding to Y(%d), now is %d.",
                    rin_ch0_ref, rout_ch0_ref, rout_ch0);
                $display("X(%d) / (2 ^ %d) = %f", 
                    rin_ch0_ref, RSHIFT_RANGE, $itor(rin_ch0_ref) / $pow(2, RSHIFT_RANGE));

                ch0_error_count <= ch0_error_count + 1;
            end 
            if (duv_ref_ch1_dismatch) begin
                $display("Mismatched result of channel 1.");
                $display("When X(%d) must rounding to Y(%d), now is %d.",
                    rin_ch1_ref, rout_ch1_ref, rout_ch1);
                $display("X(%d) / (2 ^ %d) = %f", 
                    rin_ch1_ref, RSHIFT_RANGE, $itor(rin_ch1_ref) / $pow(2, RSHIFT_RANGE));

                ch1_error_count <= ch1_error_count + 1;
            end 

            error_count <= error_count + 1;
        end

        test_count <= test_count + 1;
    end   
end


endmodule
