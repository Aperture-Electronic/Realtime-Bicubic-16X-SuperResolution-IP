// System verilog testbench file
// Line buffer for Bicubic
// Designer:    Deng LiWei
// Date:        2022/03

`timescale 1ns/1ns

module bicubic_line_buffer_tb();

// Testbench settings

// Control signals latnecy settings
localparam REFPX_BUF_LATENCY  = 1;
localparam SYMMERTIAL_LATNECY = 1;
localparam COEFF_ROM_LATENCY  = 1;
localparam SIMD_MUL_LATENCY   = 5;
localparam DSP_ADD8_LATENCY   = 4;
localparam SIMD_ROUND_LATENCY = 2;
localparam PX_LIMIT_LATENCY   = 1;

// IP settings
localparam INPUT_IMAGE_WIDTH  = 16;
localparam INPUT_IMAGE_HEIGHT = 8;
localparam PIXEL_WIDTH  = 16;  

// Interfaces
// Clock & reset
logic clk;
logic aresetn;
logic bram_reset;
logic clken;

// Input video pixel
logic [PIXEL_WIDTH - 1:0] pixel_in;
logic                     pixel_in_valid;
logic                     pixel_in_start_of_frame;
logic                     pixel_in_end_of_line;
logic                     buffer_ready;

// Output control
logic pipeline_ready;
logic pixel_out_valid;
logic pixel_read_valid;

// Output pixel
logic [PIXEL_WIDTH - 1:0] pixel_line0;
logic [PIXEL_WIDTH - 1:0] pixel_line1;
logic [PIXEL_WIDTH - 1:0] pixel_line2;
logic [PIXEL_WIDTH - 1:0] pixel_line3;

// Pixel valid signal input
logic pixel_valid;

// Control signals to pipeline stages
logic [3:0] mux_ctrl_to_refpx_buf;
logic       wren_to_refpx_buf;
logic       super_y_symmetric_to_symm_mux;
logic       line_to_coeff_rom;

logic pipeline_ctrl_pixel_out_valid;

// Output data for reference pixels block buffer
logic [PIXEL_WIDTH - 1:0] ref_pixels [0:15];

// DUV
bicubic_line_buffer #(
    .INPUT_IMAGE_HEIGHT(INPUT_IMAGE_HEIGHT),
    .INPUT_IMAGE_WIDTH(INPUT_IMAGE_WIDTH),
    .PIXEL_WIDTH(PIXEL_WIDTH)   
)DUV(.*);

assign pixel_valid = pixel_out_valid;

// VIPs
bicubic_pipeline_controller #(
    .INPUT_WIDTH        (INPUT_IMAGE_WIDTH  ),
    .REFPX_BUF_LATENCY  (REFPX_BUF_LATENCY  ),
    .SYMMERTIAL_LATNECY (SYMMERTIAL_LATNECY ),
    .COEFF_ROM_LATENCY  (COEFF_ROM_LATENCY  ),
    .SIMD_MUL_LATENCY   (SIMD_MUL_LATENCY   ),
    .DSP_ADD8_LATENCY   (DSP_ADD8_LATENCY   ),
    .SIMD_ROUND_LATENCY (SIMD_ROUND_LATENCY ),
    .PX_LIMIT_LATENCY   (PX_LIMIT_LATENCY   )
) PIPECTRL(.*, .pixel_in_valid(pixel_out_valid), .pixel_out_valid(pipeline_ctrl_pixel_out_valid));

bicubic_refpx_block_buffer #(.PIXEL_WIDTH(PIXEL_WIDTH))
refpx_buf
(
    .*,
    
    // Input multi-line data
    .line_0_in(pixel_line0),
    .line_1_in(pixel_line1),
    .line_2_in(pixel_line2),
    .line_3_in(pixel_line3),

    // Write enable
    .wren(1'b1),

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

// Clock generate
always begin
    clk = 0;
    forever #5 clk = ~clk;
end

// Global variables
bit sink_en = 0;
int f, x, y;
int frame_dly;
localparam FRAME_DELAY = 1000;

always_comb begin
    pixel_in = f * 10000 + y * 100 + x;
    pixel_in_start_of_frame = (x == 0) && (y == 0);
    pixel_in_end_of_line = (x == INPUT_IMAGE_WIDTH - 1);
end

always_ff @(posedge clk, negedge aresetn) begin
    if (!aresetn) begin
        f <= 'b0;
        x <= 'b0;
        y <= 'b0;
        pixel_in_valid <= 1'b0;
        frame_dly = 0;
    end
    else if (sink_en) begin
        if (frame_dly == 0) begin
            pixel_in_valid <= 1'b1;

            if (buffer_ready && pixel_in_valid) begin
                if (x == INPUT_IMAGE_WIDTH - 1) begin
                    x <= 0;
                    if (y == INPUT_IMAGE_HEIGHT - 1) begin
                        y <= 0;
                        f <= f + 1;

                        pixel_in_valid <= 'b0;
                        frame_dly <= FRAME_DELAY;
                    end
                    else begin
                        if (y == 5) begin
                            
                        end

                        y <= y + 1;
                    end
                end
                else begin
                    x <= x + 1;
                end
            end
        end
        else begin
            pixel_in_valid <= 1'b0;
            frame_dly <= frame_dly - 1'b1;
        end
    end
end

// Testflow
initial begin
    $display("bicubic_pipeline_controller Testbench");
    $display("Reseting...");

    clken = 0;
    aresetn = 0;
    bram_reset = 1;
    sink_en = 0;

    #15
    @(negedge clk) aresetn = 1;
    $display("Running...");
    for (int i = 0; i < 16; i++) begin
        @(posedge clk);
    end
    $display("DSP48E & BRAM slice reset released @%t.", $time);
    clken = 1;
    sink_en = 1;
    bram_reset = 0;
end

endmodule
