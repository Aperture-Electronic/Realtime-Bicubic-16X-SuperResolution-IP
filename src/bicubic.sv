// System verilog source file
// Bicubic algorithm IP /w AXI-Stream video input & output
// Designer:    Deng LiWei
// Date:        2022/03
// Description: This Bicubic IP is capable of scaling up
//    the input video stream by 4x. 
//    AXI-Stream video streams are used for both input and output.
//    The input stream has only 1 channel (often use one of YUV),
//    if you need to scaling up both 3 channels for a full-colored video,
//    you can use 3 of this core parallelly

module bicubic
#(
    parameter INPUT_VIDEO_WIDTH  = 960,
    parameter INPUT_VIDEO_HEIGHT = 540
)
(
    // Clock & reset
    input logic clk,
    input logic aresetn,
    input logic dsp_reset,
    input logic bram_reset,
    input logic clken,
    input logic sclr,

    // Input AXI-Stream video
    input  logic [7:0]  s_axis_video_in_tdata,
    input  logic        s_axis_video_in_tvalid,
    input  logic        s_axis_video_in_tuser,   // Start of frame
    input  logic        s_axis_video_in_tlast,   // End of line
    output logic        s_axis_video_in_tready,

    // Output AXI-Stream video
    output logic [31:0] m_axis_video_out_tdata,
    output logic        m_axis_video_out_tvalid,
    output logic        m_axis_video_out_tuser,   // Start of frame
    output logic        m_axis_video_out_tlast    // End of line
);

// Local parameters
localparam OUTPUT_VIDEO_WIDTH  = INPUT_VIDEO_WIDTH * 4;
localparam OUTPUT_VIDEO_HEIGHT = INPUT_VIDEO_HEIGHT * 4;

// Signals between line buffer and pipeline
logic [7:0] line_buf_to_pipe [0:3];
logic       line_buf_valid_to_pipe;
logic       line_buf_sof_to_pipe;
logic       pipe_ready_to_line_buf;

// Pipeline control signals
logic [3:0] mux_ctrl_to_refpx_buf;
logic       super_y_symmetric_to_symm_mux;
logic       line_to_coeff_rom;

// Signals between pipeline and re-aligner
logic [31:0] pixel_without_realign;
logic        pixel_line_valid;
logic        pixel_end_of_line;
logic        pixel_start_of_frame;

// Line buffer
bicubic_line_buffer #(
    .INPUT_IMAGE_WIDTH(INPUT_VIDEO_WIDTH),
    .INPUT_IMAGE_HEIGHT(INPUT_VIDEO_HEIGHT),
    .PIXEL_WIDTH(8)
) bicubic_lbf
(
    .*,

    // Input video pixel
    .pixel_in(s_axis_video_in_tdata),
    .pixel_in_valid(s_axis_video_in_tvalid),
    .pixel_in_start_of_frame(s_axis_video_in_tuser),
    .pixel_in_end_of_line(s_axis_video_in_tlast),
    .buffer_ready(s_axis_video_in_tready),

    // Output control
    .pipeline_ready(pipe_ready_to_line_buf),
    .pixel_out_valid(line_buf_valid_to_pipe),
    .pixel_out_start_of_frame(line_buf_sof_to_pipe),

    // Output pixel
    .pixel_line0(line_buf_to_pipe[0]),
    .pixel_line1(line_buf_to_pipe[1]),
    .pixel_line2(line_buf_to_pipe[2]),
    .pixel_line3(line_buf_to_pipe[3])
);

// Pipeline controller
bicubic_pipeline_controller #(
    .INPUT_WIDTH(INPUT_VIDEO_WIDTH),
    .INPUT_HEIGHT(INPUT_VIDEO_HEIGHT),

    .INPUT_PIXEL_LATENCY(1),
    .REFPX_BUF_LATENCY  (1),
    .SYMMERTIAL_LATNECY (1),
    .COEFF_ROM_LATENCY  (1),
    .SIMD_MUL_LATENCY   (5),
    .DSP_ADD8_LATENCY   (4),
    .SIMD_ROUND_LATENCY (2),
    .PX_LIMIT_LATENCY   (1)
) bicubic_pipe_ctrl
(
    .*,

    .pixel_in_valid(line_buf_valid_to_pipe),
    .pixel_in_start_of_frame(line_buf_sof_to_pipe),
    .pipeline_ready(pipe_ready_to_line_buf),
    .pixel_out_valid(),
    .pixel_out_valid_to_end_pipe(),
    .start_of_frame_to_end_pipe(pixel_start_of_frame),
    .end_of_line_to_end_pipe(pixel_end_of_line),
    .pixel_out_valid_line_to_end_pipe(pixel_line_valid)
);

// Algorithm pipeline
bicubic_pipeline #(
    // Output image size
    .OUTPUT_WIDTH(OUTPUT_VIDEO_WIDTH),
    .OUTPUT_HEIGHT(OUTPUT_VIDEO_HEIGHT),

    // Parallel processing units
    .PARALLEL_MUL_CORE(16),
    .PARALLEL_ADD_CORE(4)
) bicubic_pipe
(
    .*,

    // Video pixel input from line buffer
    .input_pixel_line0(line_buf_to_pipe[0]),
    .input_pixel_line1(line_buf_to_pipe[1]),
    .input_pixel_line2(line_buf_to_pipe[2]),
    .input_pixel_line3(line_buf_to_pipe[3]),

    // Bicubic pixels output
    .pixel_out(pixel_without_realign)
);

// Pixel re-align
bicubic_pixel_out_realign pixel_realign
(
    .*,
    // Input data
    .pixel_in(pixel_without_realign),
    .pixel_valid_in(pixel_line_valid),
    .pixel_end_of_line_in(pixel_end_of_line),
    .pixel_start_of_frame_in(pixel_start_of_frame),

    // Output data
    .pixel_realign_out(m_axis_video_out_tdata),
    .pixel_valid_out(m_axis_video_out_tvalid),
    .pixel_start_of_frame_out(m_axis_video_out_tuser),
    .pixel_end_of_line_out(m_axis_video_out_tlast)
);

endmodule
