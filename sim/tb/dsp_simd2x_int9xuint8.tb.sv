// System verilog testbench file
// DSP SIMD 2x INT9xUINT8 Multiplier Unit
// Designer:    Deng LiWei
// Date:        2022/03
`timescale 1ns/1ns

module dsp_simd2x_int9xuint8_tb();

// Simulation settings
localparam RAND_TEST_ROUND = 10000;
localparam DUV_LATENCY = 4;
localparam EXTREME_A_B_SATURS = 4;
localparam EXTREME_COE_SATURS = 4;
localparam EXTREME_TEST_ROUND = EXTREME_A_B_SATURS * EXTREME_A_B_SATURS * EXTREME_COE_SATURS;

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
logic        [7:0]  a;
logic        [7:0]  b;
logic signed [8:0]  coeff;
logic signed [47:0] pcin;

// Data output
logic signed [47:0] dout;

logic signed [17:0]ca_mul;
logic signed [17:0]cb_mul;

assign ca_mul = dout[17:0];
assign cb_mul = dout[35:18] + ca_mul[17];

// Reference model
logic signed [17:0]ca_mul_ref;
logic signed [17:0]cb_mul_ref;
logic        [7:0]a_ref;
logic        [7:0]b_ref;
logic signed [8:0]coeff_ref;

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
dsp_simd2x_int9xuint8 #(.CASCADE("false")) DUV(.*);

// Reference model
dsp_simd2x_int9xuint8_ref #(.LATENCY(DUV_LATENCY)) REF(.*,
    .ca_mul(ca_mul_ref),
    .cb_mul(cb_mul_ref)
);

// Scoreboard
dsp_simd2x_int9xuint8_scb SCB(.*);

// Clock generate
always begin
    clk = 0;
    forever #5 clk = ~clk;
end

// Testflow
initial begin
    automatic int a_ex_index = 0, b_ex_index = 0, coeff_ex_index = 0;

    $display("dsp_simd2x_int9xuint8 Testbench");
    $display("WARNING: We do not test cascade mode in this testbench.");
    $display("Reseting...");
    dsp_reset = 1;
    aresetn = 0;
    a = 0;
    b = 0;
    pcin = 0;
    coeff = 0;
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
        a = {$random}%256;
        b = {$random}%256;
        coeff = {$random}%512;

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

    a = 0;
    b = 0;
    coeff = 0;

    @(posedge clk);
    scoreboard_reset = 0;

    $display("Step 2: Extreme data test, will test %d rounds, @%t.", EXTREME_TEST_ROUND, $time);
    for (int i = 0; i < EXTREME_TEST_ROUND; i++) begin
        // Get the saturation in extreme LUT
        a = EXTREME_A_B_SATURS[a_ex_index];
        b = EXTREME_A_B_SATURS[b_ex_index];
        coeff = EXTREME_COE_SATURS[coeff_ex_index];

        // Next saturation 
        a_ex_index++;
        if (a_ex_index == EXTREME_A_B_SATURS) begin
            a_ex_index = 0;
            b_ex_index++;
            if (b_ex_index == EXTREME_A_B_SATURS) begin
                b_ex_index = 0;
                coeff_ex_index++;
            end
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

    $display("Test step 2 over @ %t.", $time);
    $display("We ran %d tests, and there is/are %d error(s).", test_count, error_count);
    $display("There is/are %d error(s) on C * A and %d error(s) on C * B.", ca_error_count, cb_error_count);

    $stop();
end

endmodule
