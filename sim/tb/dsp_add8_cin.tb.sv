// System verilog testbench file
// DSP 8-input adder with compensate carry input
// Designer:    Deng LiWei
// Date:        2022/03
`timescale 1ns/1ns

module dsp_add8_cin_tb();
// Simulation settings
localparam RAND_TEST_ROUND = 50000;
localparam DUV_LATENCY = 4;

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
logic signed [17:0]op0_l;
logic signed [17:0]op1_l;
logic signed [17:0]op2_h;
logic signed [17:0]op3_h;
logic signed [17:0]op4_l;
logic signed [17:0]op5_l;
logic signed [17:0]op6_h;
logic signed [17:0]op7_h;

// Compensate input
logic op2_cin;
logic op3_cin;
logic op6_cin;
logic op7_cin;

// Result output
logic signed [47:0]result;

// Reference model
// Result output
logic signed [47:0]result_ref;

// Reference output
logic signed [17:0]op0_l_ref;
logic signed [17:0]op1_l_ref;
logic signed [17:0]op2_h_ref;
logic signed [17:0]op3_h_ref;
logic signed [17:0]op4_l_ref;
logic signed [17:0]op5_l_ref;
logic signed [17:0]op6_h_ref;
logic signed [17:0]op7_h_ref;
logic op2_cin_ref;
logic op3_cin_ref;
logic op6_cin_ref;
logic op7_cin_ref;

// Scoreboard
// Scoreboard reset
logic scoreboard_reset;

// Scoreboard enable
logic scoreboard_en;

// Scoreboard output
int test_count;
int error_count;

// DUV
dsp_add8_cin DUV(.*);

// Reference model
dsp_add8_cin_ref #(.LATENCY(DUV_LATENCY)) REF(.*,
    .result(result_ref)
);

// Scoreboard
dsp_add8_cin_scb SCB(.*);

// Clock generate
always begin
    clk = 0;
    forever #5 clk = ~clk;
end

// Testflow
initial begin
    $display("dsp_add8_cin Testbench");
    $display("Reseting...");

    dsp_reset = 1;
    aresetn = 0;
    op0_l = 0;
    op1_l = 0;
    op2_h = 0;
    op3_h = 0;
    op4_l = 0;
    op5_l = 0;
    op6_h = 0;
    op7_h = 0;
    op2_cin = 0;
    op3_cin = 0;
    op6_cin = 0;
    op7_cin = 0;
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
        op0_l = {$random}%262144;
        op1_l = {$random}%262144;
        op2_h = {$random}%262144;
        op3_h = {$random}%262144;
        op4_l = {$random}%262144;
        op5_l = {$random}%262144;
        op6_h = {$random}%262144;
        op7_h = {$random}%262144;
        op2_cin = {$random};
        op3_cin = {$random};
        op6_cin = {$random};
        op7_cin = {$random};

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

