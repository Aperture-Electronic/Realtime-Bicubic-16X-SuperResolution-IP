// System verilog testbench file
// Cascade 2 DSP SIMD 2x INT9xUINT8 Multiplier Unit for Pipeline Adder (2 stage)
// Designer:    Deng LiWei
// Date:        2022/03
`timescale 1ns/1ns

module dsp_simd2x_int9xuint8_cascade_add_tb();
// Simulation settings
localparam RAND_TEST_ROUND = 50000;
localparam DUV_LATENCY = 5;
localparam EXTREME_A_B_SATURS = 4;
localparam EXTREME_COE_SATURS = 4;
localparam EXTREME_TEST_RNDS1 = EXTREME_A_B_SATURS * EXTREME_A_B_SATURS * EXTREME_COE_SATURS;
localparam EXTREME_TEST_ROUND = EXTREME_TEST_RNDS1 * EXTREME_TEST_RNDS1;

// Extreme saturation LUT
bit [7:0]extreme_a_b[0:EXTREME_A_B_SATURS - 1] = {'hFF, 'h7F, 'h80, 'h00};
bit [8:0]extreme_coeff[0:EXTREME_COE_SATURS - 1] = {'h1FF, 'h0FF, 'h100, 'h000};

// Interfaces

// DUV
// Clock & reset
logic clk;
logic aresetn;
logic clken;
assign clken = 1'b1;

// DSP synchronous reset
logic dsp_reset;

// Data input
logic        [7:0]  a     [0:1];
logic        [7:0]  b     [0:1];
logic signed [8:0]  coeff [0:1];

// Data output
logic signed [47:0] dout;

logic signed [17:0]ca_mul;
logic signed [17:0]cb_mul;

assign ca_mul = dout[17:0];
assign cb_mul = dout[35:18] + ca_mul[17];

// Reference model
logic signed [17:0]ca_mul_ref;
logic signed [17:0]cb_mul_ref;
var        [7:0]a_ref     [0:1];
var        [7:0]b_ref     [0:1];
var signed [8:0]coeff_ref [0:1];

// Scoreboard
// Scoreboard reset
logic scoreboard_reset;

// Scoreboard enable
logic scoreboard_en;

// Scoreboard output
int test_count;
int error_count;
int ca_error_count;
int cb_error_count;

// DUV
dsp_simd2x_int9xuint8_cascade_add DUV(
    .*,
    .a0(a[0]),
    .b0(b[0]),
    .coeff0(coeff[0]),
    .a1(a[1]),
    .b1(b[1]),
    .coeff1(coeff[1])
);

// Reference model
dsp_simd2x_int9xuint8_cascade_add_ref #(.LATENCY(DUV_LATENCY))  REF
(
    .*,
    .ca_mul(ca_mul_ref),
    .cb_mul(cb_mul_ref)
);

// Scoreboard
dsp_simd2x_int9xuint8_cascade_add_scb SCB(.*);

// Clock generate
always begin
    clk = 0;
    forever #5 clk = ~clk;
end

// Testflow
initial begin
    automatic bit[11:0] ex_index = 0;

    $display("dsp_simd2x_int9xuint8_cascade_add Testbench");
    $display("Reseting...");
    dsp_reset = 1;
    aresetn = 0;
    for (int i = 0; i < 2; i++) begin
        a[i] = 0;
        b[i] = 0;
        coeff[i] = 0;
    end

    scoreboard_en = 0;
    scoreboard_reset = 0;

    #15
    @(negedge clk) aresetn = 1;
    $display("Running...");
    for (int i = 0; i < 16; i++) begin
        @(posedge clk);
    end
    $display("DSP48E slice reset released @%t.", $time);
    dsp_reset = 0;
    scoreboard_reset = 1;

    // Random test
    @(posedge clk);
    scoreboard_reset = 0;
    $display("Step 1: Random data test, will test %d rounds, @%t.", RAND_TEST_ROUND, $time);
    for (int i = 0; i < RAND_TEST_ROUND; i++) begin
        // Gererate the random input
        for (int j = 0; j < 2; j++) begin
            a[j] = {$random}%256;
            b[j] = {$random}%256;
            coeff[j] = {$random}%512;
        end

        if (i == DUV_LATENCY) begin // Start scoreboard after the first result output
            scoreboard_en = 1; 
        end
        @(posedge clk);
    end

    // Wait the latency
    for (int i = 0; i < DUV_LATENCY; i++) begin
        @(posedge clk);
    end

    scoreboard_en = 0;
    
    @(posedge clk);
    $display("Test step 1 over @ %t.", $time);
    $display("We ran %d tests, and there is/are %d error(s).", test_count, error_count);
    $display("There is/are %d error(s) on C * A and %d error(s) on C * B.", ca_error_count, cb_error_count);
    scoreboard_reset = 1;

    for (int i = 0; i < 2; i++) begin
        a[i] = 0;
        b[i] = 0;
        coeff[i] = 0;
    end


    @(posedge clk);
    scoreboard_reset = 0;

    $display("Step 2: Extreme data test, will test %d rounds, @%t.", EXTREME_TEST_ROUND, $time);
    for (int i = 0; i < EXTREME_TEST_ROUND; i++) begin
        // Get the saturation in extreme LUT
        for (int j = 0; j < 2; j++) begin
            a[j] = EXTREME_A_B_SATURS[ex_index[1:0]];
            b[j] = EXTREME_A_B_SATURS[ex_index[3:2]];
            coeff[j] = EXTREME_COE_SATURS[ex_index[5:4]]; 
        end

        // Next saturation 
        ex_index++;

        if (i == DUV_LATENCY) begin // Start scoreboard after the first result output
            scoreboard_en = 1; 
        end
        @(posedge clk);
    end

    // Wait the latency
    for (int i = 0; i < DUV_LATENCY; i++) begin
        @(posedge clk);
    end

    scoreboard_en = 0;

    @(posedge clk);

    $display("Test step 2 over @ %t.", $time);
    $display("We ran %d tests, and there is/are %d error(s).", test_count, error_count);
    $display("There is/are %d error(s) on C * A and %d error(s) on C * B.", ca_error_count, cb_error_count);

    $stop();
end


endmodule
