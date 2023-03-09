// System verilog source file
// Computation pipeline controller for Bicubic
// Designer:    Deng LiWei
// Date:        2022/04
// Description: A controller to control the computation pipeline of 
//    Bicubic algorithm

module bicubic_pipeline_controller
#(
    // Input image size
    parameter INPUT_WIDTH = 960,
    parameter INPUT_HEIGHT = 540,

    // Input data latency settings
    parameter INPUT_PIXEL_LATENCY = 1,

    // Control signals latnecy settings
    parameter REFPX_BUF_LATENCY  = 1,
    parameter SYMMERTIAL_LATNECY = 1,
    parameter COEFF_ROM_LATENCY  = 1,
    parameter SIMD_MUL_LATENCY   = 5,
    parameter DSP_ADD8_LATENCY   = 4,
    parameter SIMD_ROUND_LATENCY = 2,
    parameter PX_LIMIT_LATENCY   = 1
)
(
    // Clock & reset
    input logic clk,
    input logic aresetn,
    input logic clken,
    input logic sclr,

    // Pixel valid signal input
    input logic pixel_in_valid,
    input logic pixel_in_start_of_frame,

    // Ready signal to previous stage
    output logic pipeline_ready,

    // Frame control output
    output logic pixel_out_valid,
    output logic pixel_out_valid_to_end_pipe,
    output logic end_of_line_to_end_pipe,
    output logic start_of_frame_to_end_pipe,
    output logic pixel_out_valid_line_to_end_pipe,

    // Control signals to pipeline stages
    output logic [3:0] mux_ctrl_to_refpx_buf,
    output logic       super_y_symmetric_to_symm_mux,
    output logic       line_to_coeff_rom
);

// A super-block has 4 super-pixels
// The first and the last super-block has only 2 pixels valid
// So we have total (W + 1) * (H + 1) super-blocks
localparam SUPER_BLOCK_WIDTH  = INPUT_WIDTH + 1;
localparam SUBLK_X_REG_WIDTH = $clog2(SUPER_BLOCK_WIDTH);

localparam OUTPUT_HEIGHT = (INPUT_HEIGHT + 1) * 4;
localparam OUT_Y_REG_WIDTH = $clog2(OUTPUT_HEIGHT);

localparam OUT_PADDING_LINE = 2;
localparam OUT_START_VALID_LINE = OUT_PADDING_LINE;
localparam OUT_END_VALID_LINE   = OUTPUT_HEIGHT - OUT_PADDING_LINE; 

localparam BUFFER_PIXEL_CNT_WIDTH = $clog2(5);

// Input super-block counter
logic [SUBLK_X_REG_WIDTH - 1:0] sublk_x_reg;
// -- Signals from counter
logic sublk_last_column;     // Last column of super-blocks
assign sublk_last_column = (sublk_x_reg == SUPER_BLOCK_WIDTH - 1);
logic sublk_x_enter_padding;  // Enter the padding mode
assign sublk_x_enter_padding = (sublk_x_reg == SUPER_BLOCK_WIDTH - 2);

// Output super-block counter
logic [SUBLK_X_REG_WIDTH - 1:0] out_sublk_x_reg;
// -- Signals from counter
logic out_sublk_x_last_column;
assign out_sublk_x_last_column = (out_sublk_x_reg == SUPER_BLOCK_WIDTH - 1);

// Output Y counter
logic [OUT_Y_REG_WIDTH - 1:0] out_y_reg;
// -- Signals from counter
logic out_y_last_row;
assign out_y_last_row = (out_y_reg == OUTPUT_HEIGHT - 1);

// Pixel output valid
logic pixel_out_valid_reg;

// Pixel output valid line
logic pixel_out_valid_line_reg;

// Pixel output start of frame
logic pixel_out_sof_reg;

// Buffered pixel counter
logic [BUFFER_PIXEL_CNT_WIDTH - 1:0] buffered_pixel;

// Padding mode
logic padding_mode;

// Super-block Y symmetric register
logic sublk_y_symm_reg;

// Line register
logic line_reg;

// Signals to the pipeline
logic [3:0] mux_ctrl_to_pipeline;
logic       super_y_symmetric_to_pipeline;
logic       line_to_pipeline;

// Input state machine
always_ff @(posedge clk, negedge aresetn) begin
    if (!aresetn) begin
        // Reset pixel counters
        sublk_x_reg <= 'b0;

        // Reset buffer counter
        buffered_pixel <= 'b0;

        // Pipeline ready signal
        pipeline_ready <= 'b1;

        // Reset padding mode
        padding_mode <= 'b0;
    end
    else if (clken) begin
        if (sclr) begin
            // Reset pixel counters
            sublk_x_reg <= 'b0;

            // Reset buffer counter
            buffered_pixel <= 'b0;

            // Pipeline ready signal
            pipeline_ready <= 'b1;

            // Reset padding mode
            padding_mode <= 'b0;
        end
        else begin
            if (!padding_mode) begin // Normal mode
                if (pipeline_ready) begin
                    // Buffer ready to receive new input pixels 
                    if (pixel_in_valid) begin
                        sublk_x_reg <= 'b0; // Reset the X register

                        // If we write done all pixels of a line,
                        // we need entering padding mode,
                        // because we have to padding 2 lines back of the line
                        if (sublk_x_enter_padding) begin
                            padding_mode <= 1'b1;
                            pipeline_ready <= 'b0;
                        end

                        if (!pixel_out_valid_reg) begin
                            if (buffered_pixel == 'd2) begin
                                // The buffer is full, can not storage more pixels
                                pipeline_ready <= 'b0;
                            end
                            else begin
                                // Increase the buffered line
                                buffered_pixel <= buffered_pixel + 'b1;
                            end
                        end

                        if (sublk_last_column) begin
                            sublk_x_reg <= 'b0;
                        end
                        else begin
                            sublk_x_reg <= sublk_x_reg + 1'b1;
                        end
                    end
                    else begin // If the no input pixel valid
                    // And at this time, a reading has been done.
                    // Because of there is no new pixel,
                    // we need to decrease the pixels in the buffer
                        if (pixel_out_valid_reg) begin
                            buffered_pixel <= buffered_pixel - 'b1;
                        end
                    end
                end
                else begin
                    // The pixels in the buffer was outputed, 
                    // so we can accept a new line
                    pipeline_ready <= 'b1;
                end
            end
            else begin // Padding mode
                // When we in the padding mode, the output is normally.
                // But we do not allow any new pixel write in
                // After 1 reading, we can exit the padding mode
                // When exit the padding mode, increase the super-block counter
                if (sublk_last_column) begin
                    // Reset the super-block counter
                    sublk_x_reg <= 'b0;
                end
                else begin
                    // Increase the super-block counter
                    sublk_x_reg <= sublk_x_reg + 1'b1;
                end

                // We can let pipeline ready
                pipeline_ready <= 'b1;

                // Exit the padding mode
                padding_mode <= 'b0;
            end
        end
    end
end

// Output state machine
always_ff @(posedge clk, negedge aresetn) begin
    if (!aresetn) begin
        // Reset super-block counter
        out_sublk_x_reg <= 'b0;
        out_y_reg <= 'b0;

        // Reset output padding register
        mux_ctrl_to_pipeline <= 'b0001;

        // Reset output valid signals
        pixel_out_valid_reg <= 'b0;

        // Reset output line valid & padding signal
        pixel_out_valid_line_reg <= 'b0;

        // Reset start of frame signal
        pixel_out_sof_reg <= 'b0;
    end
    else if (clken) begin
        if (sclr) begin
            // Reset super-block counter
            out_sublk_x_reg <= 'b0;
            out_y_reg <= 'b0;

            // Reset output padding register
            mux_ctrl_to_pipeline <= 'b0001;

            // Reset output valid signals
            pixel_out_valid_reg <= 'b0;

            // Reset output line valid & padding signal
            pixel_out_valid_line_reg <= 'b0;

            // Reset start of frame signal
            pixel_out_sof_reg <= 'b0;
        end
        else begin
            if (!pixel_out_valid_reg) begin
                // If the read valid is not activate
                if (pixel_in_valid) begin
                    // When the input side has write a pixel.
                    // And there is 2 lines in the buffer,
                    // (BUFFERED_LINE will increase at next clock)
                    // then let pixel read valid

                    if (buffered_pixel == 'd1) begin
                        pixel_out_valid_reg <= 'b1;
                    end

                    // If this is the start of frame, clear the Y super-block counter
                    if (pixel_in_start_of_frame) begin
                        out_y_reg <= 'b0;
                    end
                end
            end
            else begin
                // If the pixel read valid
                // If this is the last column of super-blocks
                if (out_sublk_x_last_column) begin
                    // Reset the super-block counter
                    out_sublk_x_reg <= 'b0;

                    // Summary of Y super-blocks
                    if (out_y_last_row) begin
                        out_y_reg <= 'b0;
                    end
                    else begin
                        out_y_reg <= out_y_reg + 'b1;
                    end

                    case (out_y_reg)
                        (OUT_START_VALID_LINE - 1): begin
                            pixel_out_valid_line_reg <= 'b1;
                            pixel_out_sof_reg <= 'b1;
                        end 
                        (OUT_END_VALID_LINE - 1): begin
                            pixel_out_valid_line_reg <= 'b0;
                        end   
                    endcase
                end
                else begin
                    // Increase the super-block counter
                    out_sublk_x_reg <= out_sublk_x_reg + 'b1;

                    // No start of frame signal at not the first pixel of a line
                    pixel_out_sof_reg <= 'b0;
                end


                // Use super-block counter to control the padding
                case (out_sublk_x_reg)
                    (SUPER_BLOCK_WIDTH - 1): mux_ctrl_to_pipeline <= 'b0001;
                    'h0:                     mux_ctrl_to_pipeline <= 'b0010;
                    (SUPER_BLOCK_WIDTH - 3): mux_ctrl_to_pipeline <= 'b0100;
                    (SUPER_BLOCK_WIDTH - 2): mux_ctrl_to_pipeline <= 'b1000;
                    default:                 mux_ctrl_to_pipeline <= 'b0000;
                endcase

                // When all of the buffered line are readed, exit the read mode
                if ((buffered_pixel == 'd1) && (!padding_mode) && (pipeline_ready) && (!pixel_in_valid)) begin
                    pixel_out_valid_reg <= 'b0;
                end
            end
        end
    end
end

// Control the reference pixel block padding multiplexer
// with the super-block counter
// assign mux_ctrl_to_refpx_buf = mux_ctrl_to_pipeline;
sfr_ce_sclr #(.WIDTH(4), .LATENCY(INPUT_PIXEL_LATENCY)) 
mux_ctrl_to_refpx_buf_sfr
(.*, .data_in(mux_ctrl_to_pipeline), .data_out(mux_ctrl_to_refpx_buf));


// Shift register for pixel out valid
sfr_ce_sclr #(.WIDTH(1), .LATENCY(REFPX_BUF_LATENCY)) 
pixel_out_valid_sfr
(.*, .data_in(pixel_out_valid_reg), .data_out(pixel_out_valid));


// Shift registers for frame control signals
sfr_ce_sclr #(.WIDTH(1), .LATENCY(REFPX_BUF_LATENCY +
                            SYMMERTIAL_LATNECY +
                            SIMD_MUL_LATENCY + 
                            DSP_ADD8_LATENCY +
                            SIMD_ROUND_LATENCY + 
                            PX_LIMIT_LATENCY))
pixel_out_valid_to_end_pipe_sfr
(.*, .data_in(pixel_out_valid_reg), .data_out(pixel_out_valid_to_end_pipe));

sfr_ce_sclr #(.WIDTH(1), .LATENCY(REFPX_BUF_LATENCY +
                            SYMMERTIAL_LATNECY +
                            SIMD_MUL_LATENCY + 
                            DSP_ADD8_LATENCY +
                            SIMD_ROUND_LATENCY + 
                            PX_LIMIT_LATENCY))
end_of_line_to_end_pipe_sfr
(.*, .data_in(out_sublk_x_last_column), .data_out(end_of_line_to_end_pipe));

sfr_ce_sclr #(.WIDTH(1), .LATENCY(REFPX_BUF_LATENCY +
                            SYMMERTIAL_LATNECY +
                            SIMD_MUL_LATENCY + 
                            DSP_ADD8_LATENCY +
                            SIMD_ROUND_LATENCY + 
                            PX_LIMIT_LATENCY))
pixel_out_valid_line_to_end_pipe_sfr
(.*, .data_in(pixel_out_valid_line_reg), .data_out(pixel_out_valid_line_to_end_pipe));

sfr_ce_sclr #(.WIDTH(1), .LATENCY(REFPX_BUF_LATENCY +
                            SYMMERTIAL_LATNECY +
                            SIMD_MUL_LATENCY + 
                            DSP_ADD8_LATENCY +
                            SIMD_ROUND_LATENCY + 
                            PX_LIMIT_LATENCY))
start_of_frame_to_end_pipe_sfr
(.*, .data_in(pixel_out_sof_reg), .data_out(start_of_frame_to_end_pipe));



// Super-block Y symmetric control
sfr_ce_sclr #(.WIDTH(1), .LATENCY(REFPX_BUF_LATENCY))
super_y_symmetric_to_symm_mux_sfr
(.*, .data_in(super_y_symmetric_to_pipeline), .data_out(super_y_symmetric_to_symm_mux));

always_ff @(posedge clk, negedge aresetn) begin
    if (!aresetn) begin
        sublk_y_symm_reg <= 'b0;
        super_y_symmetric_to_pipeline <= 'b0;
    end
    else if (clken) begin
        if (sclr) begin
            sublk_y_symm_reg <= 'b0;
            super_y_symmetric_to_pipeline <= 'b0;
        end
        else if (out_sublk_x_last_column) begin
            sublk_y_symm_reg <= ~sublk_y_symm_reg;
            if (sublk_y_symm_reg == 'b1) begin
                super_y_symmetric_to_pipeline <= ~super_y_symmetric_to_pipeline;
            end
        end
    end
end

// Line control to coefficient ROM
sfr_ce_sclr #(.WIDTH(1), .LATENCY(REFPX_BUF_LATENCY))
line_to_coeff_rom_sfr
(.*, .data_in(line_to_pipeline), .data_out(line_to_coeff_rom));

always_ff @(posedge clk, negedge aresetn) begin
    if (!aresetn) begin
        line_reg <= 'b1;
        line_to_pipeline <= 'b0;
    end
    else if (clken) begin
        if (sclr) begin
            line_reg <= 'b1;
            line_to_pipeline <= 'b0;
        end
        else if (out_sublk_x_last_column) begin
            line_reg <= ~line_reg;
            if (line_reg == 'b1) begin
                line_to_pipeline <= ~line_to_pipeline;
            end
        end
    end
end

endmodule