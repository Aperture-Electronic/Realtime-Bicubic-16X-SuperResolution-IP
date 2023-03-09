// System verilog source file
// Bicubic algorithm pipeline
// Designer:    Deng LiWei
// Date:        2022/03
// Description: The pipeline module includes all computation and control unit
//    for the Bicubic algorithm

module bicubic_pipeline
  #(
     // Output image size
     parameter OUTPUT_WIDTH = 3840,
     parameter OUTPUT_HEIGHT = 2160,

     // Parallel processing unit
     parameter PARALLEL_MUL_CORE = 16,

     // Parallel adder unit
     parameter PARALLEL_ADD_CORE = 4,

     // Output pixel per clock
     parameter OUT_PIXEL_PER_CLK = PARALLEL_ADD_CORE
   )
   (
     // Clock & reset
     input logic clk,
     input logic aresetn,
     input logic dsp_reset,
     input logic clken,

     // Video pixel input
     input logic [7:0] input_pixel_line0,
     input logic [7:0] input_pixel_line1,
     input logic [7:0] input_pixel_line2,
     input logic [7:0] input_pixel_line3,

     // EU control signals
     input logic [3:0] mux_ctrl_to_refpx_buf,
     input logic       super_y_symmetric_to_symm_mux,
     input logic       line_to_coeff_rom,

     // Video stream output
     output logic [OUT_PIXEL_PER_CLK * 8 - 1:0] pixel_out
   );

  // Output data for reference pixels block buffer
  logic [7:0] ref_pixels [0:15];

  // Input/output data for SIMD multipliers
  logic [PARALLEL_MUL_CORE * 8 - 1:0]  simd_mul_a0;
  logic [PARALLEL_MUL_CORE * 8 - 1:0]  simd_mul_b0;
  logic [PARALLEL_MUL_CORE * 9 - 1:0]  simd_mul_coeff0; // Signed, do NOT use for calculation
  logic [PARALLEL_MUL_CORE * 8 - 1:0]  simd_mul_a1;
  logic [PARALLEL_MUL_CORE * 8 - 1:0]  simd_mul_b1;
  logic [PARALLEL_MUL_CORE * 9 - 1:0]  simd_mul_coeff1; // Signed, do NOT use for calculation
  logic [PARALLEL_MUL_CORE * 48 - 1:0] simd_mul_dout;

  // Input/output data for DSP adders
  logic [PARALLEL_ADD_CORE * 18 - 1:0] dsp_add_op0_l;
  logic [PARALLEL_ADD_CORE * 18 - 1:0] dsp_add_op1_l;
  logic [PARALLEL_ADD_CORE * 18 - 1:0] dsp_add_op2_h;
  logic [PARALLEL_ADD_CORE * 18 - 1:0] dsp_add_op3_h;
  logic [PARALLEL_ADD_CORE * 18 - 1:0] dsp_add_op4_l;
  logic [PARALLEL_ADD_CORE * 18 - 1:0] dsp_add_op5_l;
  logic [PARALLEL_ADD_CORE * 18 - 1:0] dsp_add_op6_h;
  logic [PARALLEL_ADD_CORE * 18 - 1:0] dsp_add_op7_h;
  logic [PARALLEL_ADD_CORE - 1:0]      dsp_add_op2_cin;
  logic [PARALLEL_ADD_CORE - 1:0]      dsp_add_op3_cin;
  logic [PARALLEL_ADD_CORE - 1:0]      dsp_add_op6_cin;
  logic [PARALLEL_ADD_CORE - 1:0]      dsp_add_op7_cin;
  logic [PARALLEL_ADD_CORE * 48 - 1:0] dsp_add_result;

  // Input/output data for DSP SIMD rounding units
  logic        [47:0] simd_rnd_in  [0:3];
  logic signed [9:0]  simd_rnd_out [0:3];

  // Output data from pixel limiter
  logic [4 * 10 - 1:0] limit_pixel_in;
  logic [4 * 8 - 1:0] limited_pixel_out;

  // Pixels to DSP SIMD multiplier
  logic [8 * 8 - 1:0]dsp_grp_l_out;
  logic [8 * 8 - 1:0]dsp_grp_h_out;
  logic [7:0] dsp_grp_l[0:PARALLEL_MUL_CORE - 1];
  logic [7:0] dsp_grp_h[0:PARALLEL_MUL_CORE - 1];

  // Coefficients
  logic [18 * 16 - 1:0] coeff_rom_out;
  logic [17:0]          coeff_dsp [0:15];

  // Reference pixels block buffer
  bicubic_refpx_block_buffer #(.PIXEL_WIDTH(8)) refpx_buf
                             (
                               .*,

                               // Input multi-line data
                               .line_0_in(input_pixel_line0),
                               .line_1_in(input_pixel_line1),
                               .line_2_in(input_pixel_line2),
                               .line_3_in(input_pixel_line3),
                               .wren(1'b1),

                               // Buffer padding multiplexer control
                               .mux_ctrl(mux_ctrl_to_refpx_buf),

                               // Output pixels
                               .px_0_0_out(ref_pixels[ 0]),
                               .px_1_0_out(ref_pixels[ 1]),
                               .px_2_0_out(ref_pixels[ 2]),
                               .px_3_0_out(ref_pixels[ 3]),

                               .px_0_1_out(ref_pixels[ 4]),
                               .px_1_1_out(ref_pixels[ 5]),
                               .px_2_1_out(ref_pixels[ 6]),
                               .px_3_1_out(ref_pixels[ 7]),

                               .px_0_2_out(ref_pixels[ 8]),
                               .px_1_2_out(ref_pixels[ 9]),
                               .px_2_2_out(ref_pixels[10]),
                               .px_3_2_out(ref_pixels[11]),

                               .px_0_3_out(ref_pixels[12]),
                               .px_1_3_out(ref_pixels[13]),
                               .px_2_3_out(ref_pixels[14]),
                               .px_3_3_out(ref_pixels[15])
                             );

  // Symmertial multiplexer
  bicubic_symmertial_mux symm_mux
                         (
                           .*,

                           // Pixels input
                           .px_0_0_in(ref_pixels[ 0]),
                           .px_1_0_in(ref_pixels[ 1]),
                           .px_2_0_in(ref_pixels[ 2]),
                           .px_3_0_in(ref_pixels[ 3]),

                           .px_0_1_in(ref_pixels[ 4]),
                           .px_1_1_in(ref_pixels[ 5]),
                           .px_2_1_in(ref_pixels[ 6]),
                           .px_3_1_in(ref_pixels[ 7]),

                           .px_0_2_in(ref_pixels[ 8]),
                           .px_1_2_in(ref_pixels[ 9]),
                           .px_2_2_in(ref_pixels[10]),
                           .px_3_2_in(ref_pixels[11]),

                           .px_0_3_in(ref_pixels[12]),
                           .px_1_3_in(ref_pixels[13]),
                           .px_2_3_in(ref_pixels[14]),
                           .px_3_3_in(ref_pixels[15]),

                           // Symmetric control
                           .super_y_symmetric(super_y_symmetric_to_symm_mux)
                         );

  // Assignment of output of symmertial multiplexer
  generate for (genvar i = 0; i < 8; i++)
    begin
      assign dsp_grp_l[i] = dsp_grp_l_out[(((i * 8) + 8) - 1) : (i * 8)];
      assign dsp_grp_h[i] = dsp_grp_h_out[(((i * 8) + 8) - 1) : (i * 8)];
    end
  endgenerate

  // Coefficient ROM
  bicubic_coeff_rom coeff_rom
                    (
                      .*,
                      .line(line_to_coeff_rom),
                      .coeff_dsp_o(coeff_rom_out)
                    );

  // Assignment of output of coefficient ROM
  generate
    for (genvar i = 0; i < 16; i++)
    begin
      assign coeff_dsp[i] = coeff_rom_out[(i * 18) + 18 - 1:(i * 18)];
    end
  endgenerate

  // Assignment of input/output of DSP SIMD multiplier & adder EUs
  assign simd_mul_a0 = {
           {4{dsp_grp_l[6]}},
           {4{dsp_grp_l[4]}},
           {4{dsp_grp_l[2]}},
           {4{dsp_grp_l[0]}}
         };

  assign simd_mul_b0 = {
           {4{dsp_grp_h[6]}},
           {4{dsp_grp_h[4]}},
           {4{dsp_grp_h[2]}},
           {4{dsp_grp_h[0]}}
         };

  assign simd_mul_a1 = {
           {4{dsp_grp_l[7]}},
           {4{dsp_grp_l[5]}},
           {4{dsp_grp_l[3]}},
           {4{dsp_grp_l[1]}}
         };

  assign simd_mul_b1 = {
           {4{dsp_grp_h[7]}},
           {4{dsp_grp_h[5]}},
           {4{dsp_grp_h[3]}},
           {4{dsp_grp_h[1]}}
         };

  assign simd_mul_coeff0 = {
           coeff_dsp[15][17:9], coeff_dsp[14][17:9],
           coeff_dsp[13][17:9], coeff_dsp[12][17:9],
           coeff_dsp[11][17:9], coeff_dsp[10][17:9],
           coeff_dsp[ 9][17:9], coeff_dsp[ 8][17:9],
           coeff_dsp[ 7][17:9], coeff_dsp[ 6][17:9],
           coeff_dsp[ 5][17:9], coeff_dsp[ 4][17:9],
           coeff_dsp[ 3][17:9], coeff_dsp[ 2][17:9],
           coeff_dsp[ 1][17:9], coeff_dsp[ 0][17:9]
         };

  assign simd_mul_coeff1 = {
           coeff_dsp[15][8:0], coeff_dsp[14][8:0],
           coeff_dsp[13][8:0], coeff_dsp[12][8:0],
           coeff_dsp[11][8:0], coeff_dsp[10][8:0],
           coeff_dsp[ 9][8:0], coeff_dsp[ 8][8:0],
           coeff_dsp[ 7][8:0], coeff_dsp[ 6][8:0],
           coeff_dsp[ 5][8:0], coeff_dsp[ 4][8:0],
           coeff_dsp[ 3][8:0], coeff_dsp[ 2][8:0],
           coeff_dsp[ 1][8:0], coeff_dsp[ 0][8:0]
         };

  // DSP SIMD multiplier & adder EUs
  bicubic_nx_simd_mul #(
                        .PARALLEL_CORE(PARALLEL_MUL_CORE)
                      ) mul_eus
                      (
                        .*,

                        // Data input
                        .a0(simd_mul_a0),
                        .b0(simd_mul_b0),
                        .coeff0(simd_mul_coeff0),
                        .a1(simd_mul_a1),
                        .b1(simd_mul_b1),
                        .coeff1(simd_mul_coeff1),

                        // Data output
                        .dout(simd_mul_dout)
                      );

  // Assignment of input/output of DSP accumulator EUs
  assign dsp_add_op0_l = {
           simd_mul_dout[(0 * 48 + 17):(0 * 48)],  // From MUL_EU0, low segment
           simd_mul_dout[(1 * 48 + 17):(1 * 48)],  // From MUL_EU1, low segment
           simd_mul_dout[(2 * 48 + 17):(2 * 48)],  // From MUL_EU2, low segment
           simd_mul_dout[(3 * 48 + 17):(3 * 48)]   // From MUL_EU3, low segment
         };

  assign dsp_add_op1_l = {
           simd_mul_dout[(4 * 48 + 17):(4 * 48)],  // From MUL_EU4, low segment
           simd_mul_dout[(5 * 48 + 17):(5 * 48)],  // From MUL_EU5, low segment
           simd_mul_dout[(6 * 48 + 17):(6 * 48)],  // From MUL_EU6, low segment
           simd_mul_dout[(7 * 48 + 17):(7 * 48)]   // From MUL_EU7, low segment
         };

  assign dsp_add_op2_h = {
           simd_mul_dout[(3 * 48 + 18 + 17):(3 * 48 + 18)],  // From MUL_EU3, high segment
           simd_mul_dout[(2 * 48 + 18 + 17):(2 * 48 + 18)],  // From MUL_EU2, high segment
           simd_mul_dout[(1 * 48 + 18 + 17):(1 * 48 + 18)],  // From MUL_EU1, high segment
           simd_mul_dout[(0 * 48 + 18 + 17):(0 * 48 + 18)]   // From MUL_EU0, high segment
         };

  assign dsp_add_op3_h = {
           simd_mul_dout[(7 * 48 + 18 + 17):(7 * 48 + 18)],  // From MUL_EU7, high segment
           simd_mul_dout[(6 * 48 + 18 + 17):(6 * 48 + 18)],  // From MUL_EU6, high segment
           simd_mul_dout[(5 * 48 + 18 + 17):(5 * 48 + 18)],  // From MUL_EU5, high segment
           simd_mul_dout[(4 * 48 + 18 + 17):(4 * 48 + 18)]   // From MUL_EU4, high segment
         };

  assign dsp_add_op4_l = {
           simd_mul_dout[(8  * 48 + 17):(8  * 48)],  // From MUL_EU8, low segment
           simd_mul_dout[(9  * 48 + 17):(9  * 48)],  // From MUL_EU9, low segment
           simd_mul_dout[(10 * 48 + 17):(10 * 48)],  // From MUL_EU10, low segment
           simd_mul_dout[(11 * 48 + 17):(11 * 48)]   // From MUL_EU11, low segment
         };

  assign dsp_add_op5_l = {
           simd_mul_dout[(12 * 48 + 17):(12 * 48)],  // From MUL_EU12, low segment
           simd_mul_dout[(13 * 48 + 17):(13 * 48)],  // From MUL_EU13, low segment
           simd_mul_dout[(14 * 48 + 17):(14 * 48)],  // From MUL_EU14, low segment
           simd_mul_dout[(15 * 48 + 17):(15 * 48)]   // From MUL_EU15, low segment
         };

  assign dsp_add_op6_h = {
           simd_mul_dout[(11 * 48 + 18 + 17):(11 * 48 + 18)],  // From MUL_EU11, high segment
           simd_mul_dout[(10 * 48 + 18 + 17):(10 * 48 + 18)],  // From MUL_EU10, high segment
           simd_mul_dout[(9  * 48 + 18 + 17):(9  * 48 + 18)],  // From MUL_EU9, high segment
           simd_mul_dout[(8  * 48 + 18 + 17):(8  * 48 + 18)]   // From MUL_EU8, high segment
         };

  assign dsp_add_op7_h = {
           simd_mul_dout[(15 * 48 + 18 + 17):(15 * 48 + 18)],  // From MUL_EU15, high segment
           simd_mul_dout[(14 * 48 + 18 + 17):(14 * 48 + 18)],  // From MUL_EU14, high segment
           simd_mul_dout[(13 * 48 + 18 + 17):(13 * 48 + 18)],  // From MUL_EU13, high segment
           simd_mul_dout[(12 * 48 + 18 + 17):(12 * 48 + 18)]   // From MUL_EU12, high segment
         };

  assign dsp_add_op2_cin = {
           simd_mul_dout[3 * 48 + 17],  // From MUL_EU3, MSB of low segment
           simd_mul_dout[2 * 48 + 17],  // From MUL_EU2, MSB of low segment
           simd_mul_dout[1 * 48 + 17],  // From MUL_EU1, MSB of low segment
           simd_mul_dout[0 * 48 + 17]   // From MUL_EU0, MSB of low segment
         };

  assign dsp_add_op3_cin = {
           simd_mul_dout[7 * 48 + 17],  // From MUL_EU7, MSB of low segment
           simd_mul_dout[6 * 48 + 17],  // From MUL_EU6, MSB of low segment
           simd_mul_dout[5 * 48 + 17],  // From MUL_EU5, MSB of low segment
           simd_mul_dout[4 * 48 + 17]   // From MUL_EU4, MSB of low segment
         };

  assign dsp_add_op6_cin = {
           simd_mul_dout[11 * 48 + 17],  // From MUL_EU11, MSB of low segment
           simd_mul_dout[10 * 48 + 17],  // From MUL_EU10, MSB of low segment
           simd_mul_dout[9  * 48 + 17],  // From MUL_EU9, MSB of low segment
           simd_mul_dout[8  * 48 + 17]   // From MUL_EU8, MSB of low segment
         };

  assign dsp_add_op7_cin = {
           simd_mul_dout[15 * 48 + 17],  // From MUL_EU15, MSB of low segment
           simd_mul_dout[14 * 48 + 17],  // From MUL_EU14, MSB of low segment
           simd_mul_dout[13 * 48 + 17],  // From MUL_EU13, MSB of low segment
           simd_mul_dout[12 * 48 + 17]   // From MUL_EU12, MSB of low segment
         };

  // DSP accumulator EUs
  bicubic_nx_dsp_add #(
                       .PARALLEL_CORE(PARALLEL_ADD_CORE)
                     ) add_eus
                     (
                       .*,

                       // Data input
                       .op0_l(dsp_add_op0_l),
                       .op1_l(dsp_add_op1_l),
                       .op2_h(dsp_add_op2_h),
                       .op3_h(dsp_add_op3_h),
                       .op4_l(dsp_add_op4_l),
                       .op5_l(dsp_add_op5_l),
                       .op6_h(dsp_add_op6_h),
                       .op7_h(dsp_add_op7_h),

                       // Compensate input
                       .op2_cin(dsp_add_op2_cin),
                       .op3_cin(dsp_add_op3_cin),
                       .op6_cin(dsp_add_op6_cin),
                       .op7_cin(dsp_add_op7_cin),

                       // Result output
                       .result(dsp_add_result)
                     );

  // Assignment of input of DSP SIMD rounding EU
  generate for(genvar i = 0; i < 4; i++)
    begin
      assign simd_rnd_in[i] = dsp_add_result[(((i + 1) * 48) - 1):(i * 48)];
    end
  endgenerate

  // DSP SIMD rounding
  simd4x_round #(
                 .INPUT_WIDTH(48),
                 .RSHIFT_RANGE(8),
                 .OUTPUT_WIDTH(10)
               ) round_eu
               (
                 .*,

                 // Data input
                 .rin_ch0(simd_rnd_in[0]),
                 .rin_ch1(simd_rnd_in[1]),
                 .rin_ch2(simd_rnd_in[2]),
                 .rin_ch3(simd_rnd_in[3]),

                 // Data output
                 .rout_ch0(simd_rnd_out[0]),
                 .rout_ch1(simd_rnd_out[1]),
                 .rout_ch2(simd_rnd_out[2]),
                 .rout_ch3(simd_rnd_out[3])
               );

  // Assignment of input of pixel limiter
  assign limit_pixel_in = {
           simd_rnd_out[3],
           simd_rnd_out[2],
           simd_rnd_out[1],
           simd_rnd_out[0]
         };

  // Pixel limit output
  bicubic_nx_pixel_limit #(
                           .PARALLEL_CORE(4),
                           .INPUT_WIDTH(10)
                         )
                         px_limit_eus
                         (
                           .*,
                           .data_in(limit_pixel_in),
                           .pixel_out(limited_pixel_out)
                         );

  // Pixel output
  assign pixel_out = limited_pixel_out;

endmodule
