// System verilog source file
// DSP SIMD 4x INT12 Adder
// Designer:    Deng LiWei
// Date:        2022/03
// Description: 4x INT12 adder implement by DSP48 SIMD mode
`include "bicubic_global_settings.sv"

module dsp_simd4x_int12_add
(
    // Clock & reset
    input logic clk,
    input logic aresetn,
    input logic clken,

    // DSP synchronous reset
    input logic dsp_reset,

    // Data input
    input logic signed [11:0] a0,
    input logic signed [11:0] b0,
    input logic signed [11:0] a1,
    input logic signed [11:0] b1,
    input logic signed [11:0] a2,
    input logic signed [11:0] b2,
    input logic signed [11:0] a3,
    input logic signed [11:0] b3,

    // Data output
    output logic signed [11:0] add0,
    output logic signed [11:0] add1,
    output logic signed [11:0] add2,
    output logic signed [11:0] add3
);

// Using DSP48E2 slice for 4x12b SIMD adder
// 3 inputs need be used: A, B and C
// The DSP48E2 adder using the function P = A:B + C (SIMD)
// [47:0]A:B, A[29:0] is [47:18], B[17:0] is [17:0]

// In each 48-bit input of adder
// [47:24], [23:0] are 4 of the independent adding path

`ifdef USE_DSP48E2_PRIMITIVE
logic signed [47:0]simd_op0;
logic signed [47:0]simd_op1;

logic signed [29:0]dsp_ina;
logic signed [17:0]dsp_inb;
logic signed [47:0]dsp_inc;
logic signed [47:0]dsp_outp;

assign simd_op0 = {a3, a2, a1, a0};
assign simd_op1 = {b3, b2, b1, b0};

assign dsp_inb = simd_op0[17:0];
assign dsp_ina = simd_op0[47:18];
assign dsp_inc = simd_op1;

assign add0 = dsp_outp[11:0];
assign add1 = dsp_outp[23:12];
assign add2 = dsp_outp[35:24];
assign add3 = dsp_outp[47:36];

// Instance of DSP48E slice
DSP48E2 #(
    // Feature control attributes: Data path selection
    .A_INPUT("DIRECT"),                 // Direct input A
    .AMULTSEL("AD"),                    // Multiplier 27-bit input: A + D
    .B_INPUT("DIRECT"),                 // Direct input B
    .BMULTSEL("B"),                     // Multiplier 18-bit input: B
    .PREADDINSEL("A"),                  // Pre-adder A + D
    .RND(48'h0),                        // Rounding constant into the WMUX
    .USE_MULT("NONE"),                  // Unuse multiplier
    .USE_SIMD("FOUR12"),                // Using 4x12-bit DSP operation
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
    .AREG(1),                           // Number of A input registers: 1
    .BCASCREG(1),                       // Number of B input registers on the B cascade path, unused
    .BREG(1),                           // Number of B input registers: 1
    .CARRYINREG(1),                     // Number of carry input registers, unused
    .CARRYINSELREG(1),                  // Number of carry input selection registers, unused
    .CREG(1),                           // Number of C input registers: 1
    .DREG(1),                           // Number of D input registers: 1
    .INMODEREG(1),                      // Number of input mode registers: 1
    .MREG(0),                           // Number of multiplier output register stages, unused
    .OPMODEREG(1),                      // Number of operation mode registers: 1
    .PREG(1)                            // Number of P output register
    // As the configuration in front, the latency of this DSP48E slice is
    //                          Op          Lat  Total
    // 1. Input latency:        A, B, C     1    1
    // 2. Adder latency:        A:B + C     1    2
)
dsp_add_simd
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
    .PCIN(48'b0),               // Cascaded P carry input, unused
    .PCOUT(),                   // Cascaded P carry output, unused
    // Control inputs / status bits
    .ALUMODE(4'b0),             // ALU mode: Z + W + X + Y + CIN
    .CARRYINSEL(3'b000),        // Carry input selection: CARRYIN pin
    .CLK(clk),                  // DSP48E slice clock
    .INMODE(5'b00101),          // DSP48E input mode: Unused
    .OPMODE(9'h33),		        // DSP48E operation mode: W = 0, X = A:B, Y = 0, Z = C
    .OVERFLOW(),                // Overflow output, unused
    .PATTERNBDETECT(),          // Pattern matched between P, unused
    .PATTERNDETECT(),           // Pattern matched between P (masked), unused
    .UNDERFLOW(),               // Underflow output, unused
    // Data ports
    .A(dsp_ina),                // DSP48E input A[29:0]
    .B(dsp_inb),                // DSP48E input B[17:0]
    .C(dsp_inc),                // DSP48E input C[47:0]
    .CARRYIN(1'b0),             // DSP48E carry input, unused
    .CARRYOUT(),                // DSP48E carry output, unused
    .D(27'b0),                  // DSP48E input D[26:0]
    .P(dsp_outp),               // DSP48E output P[47:0]
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
    .RSTALLCARRYIN(1'b0),       // Synchronous reset for all carry input / internal carry regsiters, unused
    .RSTALUMODE(dsp_reset),     // Synchronous reset for ALUMODE register
    .RSTB(dsp_reset),           // Synchronous reset for B input register
    .RSTC(dsp_reset),           // Synchronous reset for C input register
    .RSTCTRL(dsp_reset),        // Synchronous reset for OPMODE and CARRYINSEL control input registers
    .RSTD(1'b0),        		// Synchronous reset for D input register
    .RSTINMODE(dsp_reset),  	// Synchronous reset for INMODE register
    .RSTM(1'b0),                // Synchronous reset for post-multiplty pipeline register
    .RSTP(dsp_reset)            // Synchronous reset for output register
);
`else

logic signed [11:0]dsp_simd_a0;
logic signed [11:0]dsp_simd_b0;
logic signed [11:0]dsp_simd_a1;
logic signed [11:0]dsp_simd_b1;
logic signed [11:0]dsp_simd_a2;
logic signed [11:0]dsp_simd_b2;
logic signed [11:0]dsp_simd_a3;
logic signed [11:0]dsp_simd_b3;

logic signed [11:0]dsp_simd_s0;
logic signed [11:0]dsp_simd_s1;
logic signed [11:0]dsp_simd_s2;
logic signed [11:0]dsp_simd_s3;

(* use_dsp = "simd" *)
always_ff @(posedge clk, negedge aresetn) begin
    if (!aresetn) begin
        dsp_simd_a0 <= 'b0;
        dsp_simd_b0 <= 'b0;
        dsp_simd_a1 <= 'b0;
        dsp_simd_b1 <= 'b0;
        dsp_simd_a2 <= 'b0;
        dsp_simd_b2 <= 'b0;
        dsp_simd_a3 <= 'b0;
        dsp_simd_b3 <= 'b0;

        dsp_simd_s0 <= 'b0;
        dsp_simd_s1 <= 'b0;
        dsp_simd_s2 <= 'b0;
        dsp_simd_s3 <= 'b0;
    end
    else if (clken) begin
        dsp_simd_a0 <= a0;
        dsp_simd_b0 <= b0;
        dsp_simd_a1 <= a1;
        dsp_simd_b1 <= b1;
        dsp_simd_a2 <= a2;
        dsp_simd_b2 <= b2;
        dsp_simd_a3 <= a3;
        dsp_simd_b3 <= b3;

        dsp_simd_s0 <= dsp_simd_a0 + dsp_simd_b0;
        dsp_simd_s1 <= dsp_simd_a1 + dsp_simd_b1;
        dsp_simd_s2 <= dsp_simd_a2 + dsp_simd_b2;
        dsp_simd_s3 <= dsp_simd_a3 + dsp_simd_b3;
    end
end

assign add0 = dsp_simd_s0;
assign add1 = dsp_simd_s1;
assign add0 = dsp_simd_s2;
assign add1 = dsp_simd_s3;

`endif

endmodule
