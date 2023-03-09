// System verilog source file
// DSP 4-input accumulator with compensate carry input
// Designer:    Deng LiWei
// Date:        2022/03
// Description: A 4-input accumulator with compensate carry input.
//    It has 2 compensate carry input, which support two way of data
//    comes from high segment of output of 2x SIMD INT9xUINT8 multiplier.
//    It also has a mode control, which can switch between 
//    accumulate mode and pre-load mode, in different phase.

// Here is a latency control & execute unit struct diagram
// 
//                            |<-------- Latency = 2 ------->|
// 
//                            +------------------------------+
// +---------------------+    |                 DSP_ADD3_CIN |
// |SIMDMUL    OUTL[17:0]+--->|OP0---+                       |
// +---------------------+    |      v                       |
//                            |     (+)-->||----+            |
// +---------------------+    |      ^          |            |
// |SIMDMUL    OUTL[17:0]+--->|OP1---+          v            |
// +---------------------+    |              +>(+)->||--PCOUT+--+
//                            |              |  ^            |  |
// +---------------------+    |              |  |            |  |
// |           OUTH[17:0]+--->|OP2------->||-+  |            |  |
// |SIMDMUL              |    |                 |            |  |
// |           OUTL  [17]+--->|CIN------->||----+            |  |
// +---------------------+    |                              |  |
//                            +------------------------------+  |
//                                                              |
//                                                      +-------+
//                                                      |
//                                   +------------------+-------------+
//                                   |                  |PCIN         |
// +---------------------+           |                  v             |
// |           OUTH[17:0]+---------->|OP0-->||-->||---((+))->||-+-POUT+---> RESULT
// |SIMDMUL              |           |                ^ ^ ^     |     |
// |           OUTL  [17]+--+        |                | | |     |     |
// +---------------------+  +->||--->|CIN------->||---+ | +-----+     |
//                                   |                  |             |
//                   MODE ---->||--->|MODE------>||-----+             |
//                                   |                                |
//                                   |            DSP_ACC_CASCADE_CIN |
//                                   +--------------------------------+
// 
//                             |<------------ Latency = 3 ----------->|

module dsp_acc4_cin
(
    // Clock & reset
    input logic clk,
    input logic aresetn,
    input logic clken,

    // DSP reset
    input logic dsp_reset,

    // Data input
    input logic signed [17:0]op0_l,
    input logic signed [17:0]op1_l,
    input logic signed [17:0]op2_h,
    input logic signed [17:0]op3_h,

    // Compensate input
    input logic op2_cin,
    input logic op3_cin,

    // Mode input
    input logic mode,

    // Result output
    output logic signed [47:0]result
);

logic signed [47:0]p_cascade_bt_stage;

// Pipeline registers
logic op3_cin_pp;
logic mode_pp;

// Pipeline delay registers
always_ff @(posedge clk, negedge aresetn) begin
    if (!aresetn) begin
        op3_cin_pp <= 'b0;
        mode_pp <= 'b0;
    end
    else begin
        op3_cin_pp <= op3_cin;
        mode_pp <= mode;
    end
end

// Stage 0
dsp_add3_cin #(.USE_DSP_PCOUT("true")) stage0
(
    .*,
    .op0(op0_l),
    .op1(op1_l),
    .op2(op2_h),
    .cin(op2_cin),
    .result(p_cascade_bt_stage)
);

// Stage 1
dsp_acc_cascade_cin stage1
(
    .*,
    .op0(op3_h),
    .cin(op3_cin_pp),
    .pc_in(p_cascade_bt_stage),
    .mode(mode_pp)
);

endmodule
