// System verilog test scoreboard file
// DSP SIMD 2x INT9xUINT8 Multiplier Unit
// Designer:    Deng LiWei
// Date:        2022/03

module dsp_simd2x_int9xuint8_cascade_add_scb
(
    // Clock
    input logic clk,
    input logic aresetn,

    // Enable & reset
    input logic scoreboard_en,
    input logic scoreboard_reset,

    // Data from reference model
    input logic signed [17:0]ca_mul_ref,
    input logic signed [17:0]cb_mul_ref,
    input var          [7:0]a_ref     [0:1],
    input var          [7:0]b_ref     [0:1],
    input var   signed [8:0]coeff_ref [0:1],

    // Data from DUV
    input logic signed [17:0]ca_mul,
    input logic signed [17:0]cb_mul,

    // Scoreboard output
    output int test_count,
    output int error_count,
    output int ca_error_count,
    output int cb_error_count
);

logic duv_ref_match;
logic duv_ref_dismatch_ca;
logic duv_ref_dismatch_cb;

always_comb begin
    duv_ref_dismatch_ca = ca_mul !== ca_mul_ref;
    duv_ref_dismatch_cb = cb_mul !== cb_mul_ref;
    duv_ref_match = ~(duv_ref_dismatch_ca || duv_ref_dismatch_cb);
end

always_ff @(posedge clk, negedge aresetn) begin : SCB_NOTICE
    if (!aresetn) begin
        test_count <= 'b0;
        error_count <= 'b0;
        ca_error_count <= 'b0;
        cb_error_count <= 'b0;
    end
    else if (scoreboard_reset) begin
        $display("Scoreboard reseted @%t, all statistics goes to 0.", $time);
        ca_error_count <= 'b0;
        cb_error_count <= 'b0;
        error_count <= 'b0;
        test_count <= 'b0;
    end
    else if (scoreboard_en) begin
        if (duv_ref_dismatch_ca) begin
            $display("Mismatched result when A1(%d) x C1(%d) + A2(%d) x C2(%d), need be %d, but now is %d", 
                a_ref[0], coeff_ref[0], a_ref[1], coeff_ref[1], ca_mul_ref, ca_mul);
            ca_error_count <= ca_error_count + 1;
        end
        if (duv_ref_dismatch_cb) begin
            $display("Mismatched result when B(%d) x C(%d) + B2(%d) x C2(%d), need be %d, but now is %d", 
                b_ref[0], coeff_ref[0], b_ref[1], coeff_ref[1], cb_mul_ref, cb_mul);
            cb_error_count <= cb_error_count + 1;
        end

        if (!duv_ref_match) begin
            error_count <= error_count + 1;
        end

        test_count <= test_count + 1;
    end    
end

endmodule
