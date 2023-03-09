// System verilog testbench file
// SIMD 2x rounding module
// Designer:    Deng LiWei
// Date:        2022/03
`timescale 1ns/1ns

module simd2x_round_tb();
// Simulation settings
localparam RAND_TEST_ROUND = 10000;
localparam DUV_LATENCY = 2;

// IP parameters
localparam INPUT_WIDTH = 48;
localparam RSHIFT_RANGE = 8;
localparam OUTPUT_WIDTH = 9;

// Interfaces

// DUV
// Clock & reset
logic clk;
logic aresetn;
logic clken;
assign clken = 1'b1;

// DSP synchronous reset (Only use in DSP implement)
logic dsp_reset;

// Data input
logic signed [INPUT_WIDTH - 1:0]rin_ch0;
logic signed [INPUT_WIDTH - 1:0]rin_ch1;

// Data output
logic signed [OUTPUT_WIDTH - 1:0]rout_ch0;
logic signed [OUTPUT_WIDTH - 1:0]rout_ch1;

// Reference model
// Data output
logic signed [OUTPUT_WIDTH - 1:0]rout_ch0_ref;
logic signed [OUTPUT_WIDTH - 1:0]rout_ch1_ref;

// Reference output
logic signed [INPUT_WIDTH - 1:0]rin_ch0_ref;
logic signed [INPUT_WIDTH - 1:0]rin_ch1_ref;

// Scoreboard
// Scoreboard reset
logic scoreboard_reset;

// Scoreboard enable
logic scoreboard_en;

// Scoreboard output
int test_count;
int error_count;
int ch0_error_count;
int ch1_error_count;

// DUV
simd2x_round #(.INPUT_WIDTH(INPUT_WIDTH), .RSHIFT_RANGE(RSHIFT_RANGE), .OUTPUT_WIDTH(OUTPUT_WIDTH)) DUV(.*);

// Reference model
simd2x_round_ref #(.INPUT_WIDTH(INPUT_WIDTH), .RSHIFT_RANGE(RSHIFT_RANGE), .OUTPUT_WIDTH(OUTPUT_WIDTH), .LATENCY(DUV_LATENCY)) REF(.*,
    .rout_ch0(rout_ch0_ref),
    .rout_ch1(rout_ch1_ref)
);

// Scoreboard
simd2x_round_scb #(.INPUT_WIDTH(INPUT_WIDTH), .RSHIFT_RANGE(RSHIFT_RANGE), .OUTPUT_WIDTH(OUTPUT_WIDTH)) SCB(.*);

// Clock generate
always begin
    clk = 0;
    forever #5 clk = ~clk;
end

// Testflow
initial begin
    $display("dsp_acc4_cin Testbench");
    $display("Reseting...");

    dsp_reset = 1;
    aresetn = 0;
    rin_ch0 = 0;
    rin_ch1 = 0;
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
        rin_ch0 = {$random}%65536;
        rin_ch1 = {$random}%65536;

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
    $display("There is/are %d error(s) on Channel 0, and %d error(s) on Channel 1",
        ch0_error_count, ch1_error_count);
     
    $stop();
end

endmodule

