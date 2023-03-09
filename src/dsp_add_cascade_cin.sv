// System verilog source file
// DSP Cascade adder with compensate carry input
// Designer:    Deng LiWei
// Date:        2022/03
// Description: A cascade adder with compensate carry input, 
//    one input of the adder is from previous DSP slice (use PCIN port).
//    And the other input is from A:B input, with a compensate carry input,
//    which allows input the high segment output of SIMD 2x multiplier
//    Here is the simple diagram for use this module
//
//                             DSP_ADD3_CIN
//                             +----------+
//  From     OUTL[17:0]--------+OP0       |
//  Other                      |          |
//  SIMDMULs OUTL[17:0]--------+OP1       |
//                             |          |
// +-------------------+       |     PCOUT+--------+
// |         OUTH[17:0]+-------+OP2       |        |
// |SIMDMUL            |       |          |        |
// |         OUTL[17]  +-------+CIN       |        |
// +-------------------+       +----------+        v
//              Compensate Path             +-------------+
//                                          |     PCIN    |
// +-------------------+                    |             |
// |         OUTH[17:0]+------------------->|OP0          |
// |SIMDMUL            |                    |         POUT+-->
// |         OUTL[17]  +------------------->|CIN          |
// +-------------------+ Compensate Path    |             |
//                                          +-------------+
//                                        DSP_ADD_CASCADE_CIN

`include "bicubic_global_settings.sv"

`ifndef USE_DSP48E2_PRIMITIVE
(* use_dsp = "yes" *)
`endif
module dsp_add_cascade_cin
(
    // Clock & reset
    input logic clk,
    input logic aresetn,
    input logic clken,

    // DSP reset
    input logic dsp_reset,

    // Data input
    input logic signed [17:0]op0,

    // Compensate input
    input logic cin,

    // Cascade input
    input logic signed [47:0]cascade_in,
    input logic signed [47:0]pc_in,

    // Output
    output logic signed [47:0]result
);

logic signed [47:0]dsp_inab;
logic signed [29:0]dsp_ina;
logic signed [17:0]dsp_inb;
logic signed [47:0]dsp_inc;
logic dsp_cin;
logic signed [47:0]dsp_pcin;

assign dsp_inab = op0;
assign dsp_ina = dsp_inab[47:18];
assign dsp_inb = dsp_inab[17:0];
assign dsp_inc = cascade_in;
assign dsp_cin = cin;
assign dsp_pcin = pc_in;

`ifdef USE_DSP48E2_PRIMITIVE
logic signed [47:0]p_out;

assign result = p_out;

// Instance of DSP48E slice
DSP48E2 #(
    // Feature control attributes: Data path selection
    .A_INPUT("DIRECT"),                 // Direct input A
    .AMULTSEL("AD"),                    // Multiplier 27-bit input: A + D
    .B_INPUT("DIRECT"),                 // Direct input B
    .BMULTSEL("B"),                     // Multiplier 18-bit input: B
    .PREADDINSEL("A"),                  // Pre-adder A + D
    .RND(48'h0),                        // Rounding constant into the WMUX
    .USE_MULT("NONE"),                  // Do not use multiplier
    .USE_SIMD("ONE48"),                 // Using single 48-bit DSP operation
    .USE_WIDEXOR("FALSE"),              // Wide XOR, unused
    .XORSIMD("XOR24_48_96"),            // Wide XOR mode, unused
    // Pattern detector attributes: Pattern detection configuration
    .AUTORESET_PATDET("NO_RESET"),      // No reset P register
    .AUTORESET_PRIORITY("RESET"),       // Priority of automatic reset function, unused
    .MASK(48'h3fffffffffff),            // Mask for pattern detection, unused
    .PATTERN(48'h0),                    // 48-bit value for pattern detector, unused
    .SEL_MASK("MASK"),                  // Mask to be used for the pattern detector, unused
    .SEL_PATTERN("PATTERN"),            // Pattern to be used for the pattern detector, unused
    .USE_PATTERN_DETECT("NO_PATDET"),   // Pattern detection function, unused
    // Programmable inversion attributes: Specifies built-in programmable inversion on specific pins
    .IS_ALUMODE_INVERTED(4'b0000),      // Optional inversion for ALUMODE   
    .IS_CARRYIN_INVERTED(1'b0),         // Optional inversion for CARRYIN   
    .IS_CLK_INVERTED(1'b0),             // Optional inversion for CLK   
    .IS_INMODE_INVERTED(5'b00000),      // Optional inversion for INMODE   
    .IS_OPMODE_INVERTED(9'b000000000),  // Optional inversion for OPMODE   
    .IS_RSTALLCARRYIN_INVERTED(1'b0),   // Optional inversion for RSTALLCARRYIN   
    .IS_RSTALUMODE_INVERTED(1'b0),      // Optional inversion for RSTALUMODE   
    .IS_RSTA_INVERTED(1'b0),            // Optional inversion for RSTA   
    .IS_RSTB_INVERTED(1'b0),            // Optional inversion for RSTB   
    .IS_RSTCTRL_INVERTED(1'b0),         // Optional inversion for RSTCTRL   
    .IS_RSTC_INVERTED(1'b0),            // Optional inversion for RSTC   
    .IS_RSTD_INVERTED(1'b0),            // Optional inversion for RSTD   
    .IS_RSTINMODE_INVERTED(1'b0),       // Optional inversion for RSTINMODE   
    .IS_RSTM_INVERTED(1'b0),            // Optional inversion for RSTM   
    .IS_RSTP_INVERTED(1'b0),            // Optional inversion for RSTP
    // Register control attributes: Pipeline register configuration
    .ACASCREG(1),                       // Number of A input registers on the A cascade path, unused
    .ADREG(1),                          // Number of pre-adder (A + D) pipeline registers: 1
    .AREG(2),                           // Number of A input registers: 2
    .BCASCREG(1),                       // Number of B input registers on the B cascade path, unused
    .BREG(2),                           // Number of B input registers: 2
    .CARRYINREG(1),                     // Number of carry input registers: 1
    .CARRYINSELREG(1),                  // Number of carry input selection registers: 1
    .CREG(0),                           // Number of C input registers: 0
    .DREG(1),                           // Number of D input registers, unused
    .INMODEREG(1),                      // Number of input mode registers: 1
    .MREG(0),                           // Number of multiplier output register stages: 0
    .OPMODEREG(1),                      // Number of operation mode registers: 1
    .PREG(1)                            // Number of P output register
    // As the configuration in front, the latency of this DSP48E slice is
    //                          Op      Lat Op  Lat Total
    // 1. Input latency:        A:B     2       2
    // 2. Output latency:       P       1       3
    // Please note that C input has not input register
)
dsp_add_cascade
(
    .XOROUT(),                  // Wide XOR output, unused
    // Cascade ports
    .ACIN(30'b0),               // Cascaded data input A, unused
    .ACOUT(),                   // Cascaded data output A, unused
    .BCIN(18'b0),               // Cascaded data input B, unused
    .BCOUT(),                   // Cascaded data output B, unused
    .CARRYCASCIN(1'b0),         // Cascaded carry input, unused
    .CARRYCASCOUT(),            // Cascaded carry output, unused
    .MULTSIGNIN(1'b0),          // Cascaded multiplier sign input, unused
    .MULTSIGNOUT(),             // Cascaded multiplier sign output, unused
    .PCIN(dsp_pcin),            // Cascaded P carry input, use for cascade of previous DSP slice
    .PCOUT(),                   // Cascaded P carry output, unused
    // Control inputs / status bits
    .ALUMODE(4'b0),             // ALU mode: Z + W + X + Y + CIN
    .CARRYINSEL(3'b000),        // Carry input selection: CARRYIN pin
    .CLK(clk),                  // DSP48E slice clock
    .INMODE(5'b00010),          // DSP48E input mode: 0 * B
    .OPMODE(9'h193),     		// DSP48E operation mode: W = C, X = A:B, Y = 0, Z = PCIN
    .OVERFLOW(),                // Overflow output, unused
    .PATTERNBDETECT(),          // Pattern matched between P, unused
    .PATTERNDETECT(),           // Pattern matched between P (masked), unused
    .UNDERFLOW(),               // Underflow output, unused
    // Data ports
    .A(dsp_ina),                // DSP48E input A[29:0]
    .B(dsp_inb),                // DSP48E input B[17:0]
    .C(dsp_inc),                // DSP48E input C[47:0]
    .CARRYIN(dsp_cin),          // DSP48E carry input
    .CARRYOUT(),                // DSP48E carry output, unused
    .D(27'b0),                  // DSP48E input D[26:0]
    .P(p_out),                  // DSP48E output P[47:0]
    // Reset & clock enable
    .CEAD(clken),                // Clock enable for pre-adder output AD pipeline register
    .CEALUMODE(clken),           // Clock enable for ALUMODE register
    .CEA1(clken),                // Clock enable for A input register stage 1
    .CEA2(clken),                // Clock enable for A input register stage 2
    .CEB1(clken),                // Clock enable for B input register stage 1
    .CEB2(clken),                // Clock enable for B input register stage 2
    .CEC(clken),                 // Clock enable for C input register
    .CECARRYIN(clken),           // Clock enable for carry input register, unused
    .CECTRL(clken),              // Clock enable for OPMODE and CARRYINSEL control input registers
    .CED(clken),                 // Clock enable for D input register
    .CEINMODE(clken),            // Clock enable for inut mode register
    .CEM(clken),                 // Clock enable for post-multiplty pipeline register
    .CEP(clken),                 // Clock enable for output register
    .RSTA(dsp_reset),           // Synchronous reset for A input register
    .RSTALLCARRYIN(dsp_reset),  // Synchronous reset for all carry input / internal carry regsiters, unused
    .RSTALUMODE(dsp_reset),     // Synchronous reset for ALUMODE register
    .RSTB(dsp_reset),           // Synchronous reset for B input register
    .RSTC(1'b1),                // Synchronous reset for C input register
    .RSTCTRL(dsp_reset),        // Synchronous reset for OPMODE and CARRYINSEL control input registers
    .RSTD(1'b1),     	     	// Synchronous reset for D input register
    .RSTINMODE(dsp_reset),   	// Synchronous reset for INMODE register
    .RSTM(1'b1),                // Synchronous reset for post-multiplty pipeline register
    .RSTP(dsp_reset)            // Synchronous reset for output register
);
`else
logic signed [47:0]ab1_reg;
logic signed [47:0]ab2_reg;
logic cin_reg;
logic signed [47:0]p_reg;

always_ff @(posedge clk) begin
    if (dsp_reset) begin
        ab1_reg <= 'b0;
        ab2_reg <= 'b0;
        cin_reg <= 'b0;
        p_reg <= 'b0;
    end
    else if (clken) begin
        // A:B input register
        ab1_reg <= dsp_inab;
        ab2_reg <= ab1_reg;

        // Carry input register
        cin_reg <= dsp_cin;

        // Adder
        p_reg <= ab2_reg + dsp_inc + pc_in + $signed({1'b0, cin_reg});
    end
end

assign result = p_reg;
`endif


endmodule
