// System verilog testbench file
// DSP 3-input Adder with compensate carry input
// Designer:    Deng LiWei
// Date:        2022/03
`timescale 1ns/1ns

module dsp_add3_cin_tb ();
// Simulation settings
localparam RAND_TEST_ROUND = 10000;
localparam DUV_LATENCY = 2;
    
// Interfaces

// DUV
// Clock & reset
logic clk;
logic aresetn;
logic clken;
assign clken = 1'b1;

// DSP reset
logic dsp_reset;

// Data input
logic signed [17:0]op0;
logic signed [17:0]op1;
logic signed [17:0]op2;

// Compensate input
logic cin;

// Output
logic signed [47:0]result;

// Reference model
logic signed [17:0]op0_ref;
logic signed [17:0]op1_ref;
logic signed [17:0]op2_ref;
logic cin_ref;
logic signed [47:0]result_ref;

// Scoreboard
// Scoreboard reset
logic scoreboard_reset;

// Scoreboard enable
logic scoreboard_en;

// Scoreboard output
int test_count;
int error_count;

// DUV
dsp_add3_cin DUV(.*);

// Reference model
dsp_add3_cin_ref #(.LATENCY(DUV_LATENCY)) REF(.*,
    .result(result_ref)
);

// Scoreboard
dsp_add3_cin_scb SCB(.*);

// Clock generate
always begin
    clk = 0;
    forever #5 clk = ~clk;
end

// Testflow
initial begin
    $display("dsp_add3_cin Testbench");
    $display("Reseting...");

    dsp_reset = 1;
    aresetn = 0;
    op0 = 0;
    op1 = 0;
    op2 = 0;
    cin = 0;
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
        op0 = {$random}%262144;
        op1 = {$random}%262144;
        op2 = {$random}%262144;
        cin = {$random};

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
     
    $stop();
end

endmodule

