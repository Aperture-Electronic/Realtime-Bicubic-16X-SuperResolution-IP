// System verilog source file
// DSP SIMD 2x INT9xUINT8 Multiplier Unit
// Designer:    Deng LiWei
// Date:        2022/03
// Description: A multiplier unit which using DSP48E2 slice for 2x INT9xUINT8 multiply computation.

`include "bicubic_global_settings.sv"

module dsp_simd2x_int9xuint8
#
(
    parameter CASCADE_IN  = "false", // Set if this module connect after a DSP slice
    parameter CASCADE_OUT = "false"  // Set if this module connect before a DSP slice
)
(
    // Clock & reset
    input logic clk,
    input logic aresetn,
    input logic clken,

    // DSP synchronous reset
    input logic dsp_reset,

    // Data input
    input logic        [7:0]  a,
    input logic        [7:0]  b,
    input logic signed [8:0]  coeff,

    // Cascade input
    input logic signed [47:0] pcin,

    // Data output
    output logic signed [47:0] dout
);

// 1 DSP48E2 slice for 2x INT9 x UINT8 calculation
// Configured the DSP48E2 in mode P = (A + D) * B + C
// Which A = b << 18, D = a, B = coeff, C = cin
// The output result is
// Coeff * A on [17:0]
// Coeff * B on [33:18]
logic signed [26:0]dsp_ina;
logic signed [17:0]dsp_inb;
logic signed [26:0]dsp_ind;

assign dsp_ina = {1'b0, b, 18'b0};
assign dsp_inb = coeff;
assign dsp_ind = a;

`ifdef USE_DSP48E2_PRIMITIVE
logic signed [47:0]dsp_outp;
logic signed [47:0]dsp_pcout;

generate
    if (CASCADE_OUT == "true") begin
        assign dout = dsp_pcout;
    end
    else begin
        assign dout = dsp_outp;
    end
endgenerate

logic signed [47:0]dsp_pcin;
logic [8:0]dsp_opmode;
generate
    if (CASCADE_IN == "true") begin
        assign dsp_pcin = pcin;  
        assign dsp_opmode = 9'h15; // DSP48E operation mode: W = 0, Z = PCIN, X, Y = M (Multiplier result)  
    end
    else begin
        assign dsp_pcin = 48'b0;    
        assign dsp_opmode = 9'h05; // DSP48E operation mode: W = 0, Z = 0, X, Y = M (Multiplier result)  
    end
endgenerate

// Instance of DSP48E slice
DSP48E2 #(
    // Feature control attributes: Data path selection
    .A_INPUT("DIRECT"),                 // Direct input A
    .AMULTSEL("AD"),                    // Multiplier 27-bit input: A + D
    .B_INPUT("DIRECT"),                 // Direct input B
    .BMULTSEL("B"),                     // Multiplier 18-bit input: B
    .PREADDINSEL("A"),                  // Pre-adder A + D
    .RND(48'h0),                        // Rounding constant into the WMUX
    .USE_MULT("MULTIPLY"),              // Using multiplier
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
    .AREG(1),                           // Number of A input registers: 1
    .BCASCREG(1),                       // Number of B input registers on the B cascade path, unused
    .BREG(2),                           // Number of B input registers: 2
    .CARRYINREG(1),                     // Number of carry input registers, unused
    .CARRYINSELREG(1),                  // Number of carry input selection registers, unused
    .CREG(0),                           // Number of C input registers: 0
    .DREG(1),                           // Number of D input registers: 1
    .INMODEREG(1),                      // Number of input mode registers: 1
    .MREG(1),                           // Number of multiplier output register stages: 1
    .OPMODEREG(1),                      // Number of operation mode registers: 1
    .PREG(1)                            // Number of P output register
    // As the configuration in front, the latency of this DSP48E slice is
    //                          Op          Lat Op  Lat Total
    // 1. Input latency:        A, D        1   B   2   
    // 2. Pre-adder latency:    A + D       1       2
    // 3. Multiplier latency:   (A + D) * B 1       3
    // 4. Output latency:       P           1       4
)
dsp_mul
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
    .PCIN(dsp_pcin),            // Cascaded P cascade input
    .PCOUT(dsp_pcout),          // Cascaded P cascade output
    // Control inputs / status bits
    .ALUMODE(4'b0),             // ALU mode: Z + W + X + Y + CIN
    .CARRYINSEL(3'b000),        // Carry input selection: CARRYIN pin
    .CLK(clk),                  // DSP48E slice clock
    .INMODE(5'b00101),          // DSP48E input mode: (D * A1) * B2
    .OPMODE(dsp_opmode),        // DSP48E operation mode: W = 0, Z = PCIN/0, X, Y = M (Multiplier result)
    .OVERFLOW(),                // Overflow output, unused
    .PATTERNBDETECT(),          // Pattern matched between P, unused
    .PATTERNDETECT(),           // Pattern matched between P (masked), unused
    .UNDERFLOW(),               // Underflow output, unused
    // Data ports
    .A({3'b111, dsp_ina}),      // DSP48E input A[29:0]
    .B(dsp_inb),                // DSP48E input B[17:0]
    .C(48'b0),                  // DSP48E input C[47:0]
    .CARRYIN(1'b0),             // DSP48E carry input, unused
    .CARRYOUT(),                // DSP48E carry output, unused
    .D(dsp_ind),                // DSP48E input D[26:0]
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
    .RSTD(dsp_reset),		// Synchronous reset for D input register
    .RSTINMODE(dsp_reset),	// Synchronous reset for INMODE register
    .RSTM(dsp_reset),           // Synchronous reset for post-multiplty pipeline register
    .RSTP(dsp_reset)            // Synchronous reset for output register
);
`else
// These are registers in DSP slice
logic signed [26:0]dsp_a1;
logic signed [17:0]dsp_b1;
logic signed [17:0]dsp_b2;
logic signed [26:0]dsp_d;
logic signed [26:0]dsp_ad;
logic signed [47:0]dsp_m;
logic signed [47:0]dsp_p;

assign dout = dsp_p;
generate
    if (CASCADE == "true") begin
        (* use_dsp = "yes" *)
        always_ff @(posedge clk) begin // We do not use asynchronous reset in DSP slice
            if (dsp_reset) begin
                dsp_a1 <= 'b0;
                dsp_b1 <= 'b0;
                dsp_b2 <= 'b0;
                dsp_d <= 'b0;
                dsp_ad <= 'b0;
                dsp_m <= 'b0;
                dsp_p <= 'b0;
            end
            else if (clken) begin
                // Input registers
                dsp_a1 <= dsp_ina;
                dsp_b1 <= dsp_inb;
                dsp_d <= dsp_ind;

                // Pipeline for B
                dsp_b2 <= dsp_b1;

                // Pre-adder
                dsp_ad <= dsp_a1 + dsp_d;

                // Multiplier
                dsp_m <= dsp_ad * dsp_b2;

                // Adder
                dsp_p <= dsp_m + pcin;
            end
        end
    end
    else begin
        (* use_dsp = "yes" *)
        always_ff @(posedge clk) begin // We do not use asynchronous reset in DSP slice
            if (dsp_reset) begin
                dsp_a1 <= 'b0;
                dsp_b1 <= 'b0;
                dsp_b2 <= 'b0;
                dsp_d <= 'b0;
                dsp_ad <= 'b0;
                dsp_m <= 'b0;
                dsp_p <= 'b0;
            end
            else if (clken) begin
                // Input registers
                dsp_a1 <= dsp_ina;
                dsp_b1 <= dsp_inb;
                dsp_d <= dsp_ind;
        
                // Pipeline for B
                dsp_b2 <= dsp_b1;
        
                // Pre-adder
                dsp_ad <= dsp_a1 + dsp_d;
        
                // Multiplier
                dsp_m <= dsp_ad * dsp_b2;
        
                // Adder
                dsp_p <= dsp_m;
            end
        end 
    end 
endgenerate
`endif

endmodule

