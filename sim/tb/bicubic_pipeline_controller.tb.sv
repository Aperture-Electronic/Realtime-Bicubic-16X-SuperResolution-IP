// System verilog testbench file
// Computation pipeline controller for Bicubic
// Designer:    Deng LiWei
// Date:        2022/04

module bicubic_pipeline_controller_tb();

// Testbench settings
localparam INPUT_HEIGHT = 8;
localparam PIXEL_WIDTH = 16;
localparam PARALLEL_MUL_CORE = 16;

// IP parameters
// Input image size
localparam INPUT_WIDTH = 16;

// Control signals latnecy settings
localparam REFPX_BUF_LATENCY  = 1;
localparam SYMMERTIAL_LATNECY = 1;
localparam COEFF_ROM_LATENCY  = 1;
localparam SIMD_MUL_LATENCY   = 5;
localparam DSP_ADD8_LATENCY   = 4;
localparam SIMD_ROUND_LATENCY = 2;
localparam PX_LIMIT_LATENCY   = 1;

// Interfaces
// Clock & reset
logic clk;
logic aresetn;
logic clken;

// Pixel valid signal input
logic pixel_valid;

// Ready signal to previous stage
logic pipeline_ready;

// Control signals to pipeline stages
logic [3:0] mux_ctrl_to_refpx_buf;
logic       super_y_symmetric_to_symm_mux;
logic       line_to_coeff_rom;

// Output data for reference pixels block buffer
logic [PIXEL_WIDTH - 1:0] ref_pixels [0:15];

// Video pixel input
logic [PIXEL_WIDTH - 1:0] input_pixel_line0;
logic [PIXEL_WIDTH - 1:0] input_pixel_line1;
logic [PIXEL_WIDTH - 1:0] input_pixel_line2;
logic [PIXEL_WIDTH - 1:0] input_pixel_line3;

// Pixels to DSP SIMD multiplier
logic [PARALLEL_MUL_CORE * 8 - 1:0]dsp_grp_l_out;
logic [PARALLEL_MUL_CORE * 8 - 1:0]dsp_grp_h_out;
logic [7:0] dsp_grp_l[0:PARALLEL_MUL_CORE - 1];
logic [7:0] dsp_grp_h[0:PARALLEL_MUL_CORE - 1];

logic video_valid;

// DUV
bicubic_pipeline_controller #(
    .INPUT_WIDTH        (INPUT_WIDTH        ),
    .REFPX_BUF_LATENCY  (REFPX_BUF_LATENCY  ),
    .SYMMERTIAL_LATNECY (SYMMERTIAL_LATNECY ),
    .COEFF_ROM_LATENCY  (COEFF_ROM_LATENCY  ),
    .SIMD_MUL_LATENCY   (SIMD_MUL_LATENCY   ),
    .DSP_ADD8_LATENCY   (DSP_ADD8_LATENCY   ),
    .SIMD_ROUND_LATENCY (SIMD_ROUND_LATENCY ),
    .PX_LIMIT_LATENCY   (PX_LIMIT_LATENCY   )
) DUV(.*);

// VIPs
bicubic_refpx_block_buffer #(.PIXEL_WIDTH(PIXEL_WIDTH))
refpx_buf
(
    .*,
    
    // Input multi-line data
    .line_0_in(input_pixel_line0),
    .line_1_in(input_pixel_line1),
    .line_2_in(input_pixel_line2),
    .line_3_in(input_pixel_line3),

    // Buffer padding multiplexer control
    .mux_ctrl(mux_ctrl_to_refpx_buf),
    //.mux_ctrl(0),

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
generate for (genvar i = 0; i < PARALLEL_MUL_CORE; i++) begin
    assign dsp_grp_l[i] = dsp_grp_l_out[(((i * 8) + 8) - 1) : (i * 8)];
    assign dsp_grp_h[i] = dsp_grp_h_out[(((i * 8) + 8) - 1) : (i * 8)];
end
endgenerate

// Clock generate
always begin
    clk = 0;
    forever #5 clk = ~clk;
end

// Global variables
int state;
int l = 0;
int c = 0;
int q = 0;
bit sink_en = 0;

always_comb begin
    if (l == 0) begin
        input_pixel_line0 = -1;
        input_pixel_line1 = -1;
        input_pixel_line2 = (l + 0) * 1000 + c;
        input_pixel_line3 = (l + 1) * 1000 + c;
    end
    else if (l == 1) begin
        input_pixel_line0 = -1;
        input_pixel_line1 = (l - 1) * 1000 + c;
        input_pixel_line2 = (l + 0) * 1000 + c;
        input_pixel_line3 = (l + 1) * 1000 + c;      
    end
    else begin
        input_pixel_line0 = (l - 1) * 1000 + c;
        input_pixel_line1 = (l + 0) * 1000 + c;
        input_pixel_line2 = (l + 1) * 1000 + c;
        input_pixel_line3 = (l + 2) * 1000 + c;                
    end
end

always_ff @(posedge clk, negedge aresetn) begin
    if (!aresetn) begin
        l <= 0;
        c <= 0;
        q <= 0;
        pixel_valid <= 0;
    end
    else if (sink_en) begin
        pixel_valid <= 'b1;

        if (pipeline_ready) begin
            if (c == INPUT_WIDTH - 1) begin
                if (q == 3) begin
                    l <= l + 1;
                    q <= 0;
                end
                else if ((q == 1) && (l == 0)) begin
                    q <= 0;
                    l <= l + 1;
                end
                else begin
                    q <= q + 1;
                end

                c <= 0;
            end
            else begin
                c <= c + 1;
            end          
        end
    end
end

assign video_valid = pipeline_ready && pixel_valid;

// Testflow
initial begin
    $display("bicubic_pipeline_controller Testbench");
    $display("Reseting...");

    clken = 0;
    aresetn = 0;
    sink_en = 0;

    #15
    @(negedge clk) aresetn = 1;
    $display("Running...");
    for (int i = 0; i < 16; i++) begin
        @(posedge clk);
    end
    $display("DSP48E slice reset released @%t.", $time);
    clken = 1;
    sink_en = 1;
end

endmodule

