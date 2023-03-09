// System verilog source file
// DSP 8-input adder with compensate carry input
// Designer:    Deng LiWei
// Date:        2022/03
// Description: A 8-input adder with compensate carry input.
//    It has 4 compensate carry input, which support 4 ways of data
//    comes from high segment of output of 2x SIMD INT9xUINT8 multiplier.

// Here is a latency control & execute unit struct diagram
// 
//                            |<-------- Latency = 2 ------->|
// 
//                            +------------------------------+
// +---------------------+    |                 DSP_ADD3_CIN |
// |SIMDMUL    OUTL[17:0]+--->|OPA---+                       |
// +---------------------+    |      v                       |
//                            |     (+)-->||----+            |
// +---------------------+    |      ^          |            |
// |SIMDMUL    OUTL[17:0]+--->|OPD---+          v            |
// +---------------------+    |              +>(+)->||--PCOUT+--------------------+   |<--------- Latency = 2 -------->|
//                            |              |  ^            |                    |
// +---------------------+    |              |  |            |                    |
// |           OUTH[17:0]+--->|OPC------->||-+  |            | +------------------+-------------+
// |SIMDMUL              |    |                 |            | |                  |PCIN         |
// |           OUTL  [17]+--->|CIN------->||----+            | |                  v             |
// +---------------------+    |                              | |         +>||--->(+)-->||---POUT+--------+
//                            +------------------------------+ |         |        ^             |        |
//                                                             |         |        |             |        |
// +---------------------+                                     |         |        |             |        |
// |           OUTH[17:0]+------------------------------------>|OPB-->||-+        |             |        |
// |SIMDMUL              |                                     |                  |             |        |
// |           OUTL  [17]+--------------->||------------------>|CIN------->||-----+             |        |
// +---------------------+                                     |                                |        |
//                                                             |            DSP_ADD_CASCADE_CIN |        |
//                                                             +--------------------------------+        |
//                                                                                                       |
//                                             +------------------------------+                          |
// +---------------------+                     |                 DSP_ADD3_CIN |                          |
// |SIMDMUL    OUTL[17:0]+--------------->||-->|OPA---+                       |                          |
// +---------------------+                     |      v                       |                          |
//                                             |     (+)-->||----+            |       +------------------+-------------+
// +---------------------+                     |      ^          |            |       |                  |OPC          |
// |SIMDMUL    OUTL[17:0]+--------------->||-->|OPD---+          v            |       |                  v             |
// +---------------------+                     |              +>(+)->||--PCOUT+----  -+PCIN----------->((+))-->||--POUT+---> RESULT
//                                             |              |  ^            |       |                 ^ ^            |
// +---------------------+                     |              |  |            |       |                 | |            |
// |           OUTH[17:0]+--------------->||-->|OPC------->||-+  |            |       |                 | |            |
// |SIMDMUL              |                     |                 |            | +---->|OPB--->||---->||-+ |            |
// |           OUTL  [17]+--------------->||-->|CIN------->||----+            | |     |                   |            |
// +---------------------+                     |                              | | +-->|CIN---------->||---+            |
//                                             +------------------------------+ | |   |                                |
//                                                                              | |   |            DSP_ADD_CASCADE_CIN |
// +---------------------+                                                      | |   +--------------------------------+
// |           OUTH[17:0]+--------------->||------------------------------------+ |
// |SIMDMUL              |                                                        |
// |           OUTL  [17]+--------------->||-------------->||---------------------+
// +---------------------+
//                            |<------------------------------------ Latency = 4 ------------------------------------->|

module dsp_add8_cin
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
    input logic signed [17:0]op4_l,
    input logic signed [17:0]op5_l,
    input logic signed [17:0]op6_h,
    input logic signed [17:0]op7_h,

    // Compensate input
    input logic op2_cin,
    input logic op3_cin,
    input logic op6_cin,
    input logic op7_cin,

    // Result output 
    output logic signed [47:0]result
);

logic signed [47:0]p_cascade_bt_stage[0:1];
logic signed [47:0]c_cascade_bt_stage;

// Pipeline registers
logic signed [17:0]op6_h_pipe;
logic signed [17:0]op7_h_pipe;
logic op3_cin_pipe;
logic op6_cin_pipe;
logic op7_cin_pipe; 

sfr_ce #(.WIDTH(18), .LATENCY(1)) sfr_op6_h (.*, .data_in(op6_h), .data_out(op6_h_pipe));
sfr_ce #(.WIDTH(18), .LATENCY(1)) sfr_op7_h (.*, .data_in(op7_h), .data_out(op7_h_pipe));
sfr_ce #(.WIDTH(1), .LATENCY(1))  sfr_op3_cin (.*, .data_in(op3_cin), .data_out(op3_cin_pipe));
sfr_ce #(.WIDTH(1), .LATENCY(1))  sfr_op6_cin (.*, .data_in(op6_cin), .data_out(op6_cin_pipe));
sfr_ce #(.WIDTH(1), .LATENCY(2))  sfr_op7_cin (.*, .data_in(op7_cin), .data_out(op7_cin_pipe));

// Stage A0
dsp_add3_cin #(.USE_DSP_PCOUT("true"), .DSP_A_D_INPUT_REG(0)) stage_a_0
(
    .*,
    .op0(op0_l),
    .op1(op1_l),
    .op2(op2_h),
    .cin(op2_cin),
    .result(p_cascade_bt_stage[0])
);

// Stage A1
dsp_add_cascade_cin stage_a_1
(
    .*,
    .op0(op3_h),
    .cin(op3_cin_pipe),
    .cascade_in(48'b0),
    .pc_in(p_cascade_bt_stage[0]),
    .result(c_cascade_bt_stage)
);

// Stage B0
dsp_add3_cin #(.USE_DSP_PCOUT("true"), .DSP_A_D_INPUT_REG(1)) stage_b_0
(
    .*,
    .op0(op4_l),
    .op1(op5_l),
    .op2(op6_h_pipe),
    .cin(op6_cin_pipe),
    .result(p_cascade_bt_stage[1])
);

// Stage B1
dsp_add_cascade_cin stage_b_1
(
    .*,
    .op0(op7_h_pipe),
    .cin(op7_cin_pipe),
    .cascade_in(c_cascade_bt_stage),
    .pc_in(p_cascade_bt_stage[1]),
    .result(result)
);

endmodule
