// System verilog source file
// Line buffer for Bicubic
// Designer:    Deng LiWei
// Date:        2022/04
// Description: This line buffer can storage 4 lines of image 
//    which uses by Bicubic algorithm
//    This buffer has the function of cross clock-domain, 
//    which allow different input and output clock frequency.
//    In general conditions, the output clock is times of input clock.
//    Input port of the line buffer can storage a single pixel per clock
//    On the output port, the module using 4-line parallel output,
//    can output 1xN pixels at same time.
//    This line buffer include access FIFO counters, 5 SDPRAMs

module bicubic_line_buffer
#(
    parameter INPUT_IMAGE_WIDTH  = 960,
    parameter INPUT_IMAGE_HEIGHT = 540,
    parameter PIXEL_WIDTH  = 8  
)
(
    // Clock & reset
    input logic clk,
    input logic aresetn,
    input logic sclr,
    input logic bram_reset,
    input logic clken,

    // Input video pixel
    input  logic [PIXEL_WIDTH - 1:0] pixel_in,
    input  logic                     pixel_in_valid,
    input  logic                     pixel_in_start_of_frame,
    input  logic                     pixel_in_end_of_line,
    output logic                     buffer_ready,

    // Output control
    input  logic pipeline_ready,
    output logic pixel_out_valid,
    output logic pixel_out_start_of_frame,

    // Output pixel
    output logic [PIXEL_WIDTH - 1:0] pixel_line0,
    output logic [PIXEL_WIDTH - 1:0] pixel_line1,
    output logic [PIXEL_WIDTH - 1:0] pixel_line2,
    output logic [PIXEL_WIDTH - 1:0] pixel_line3
);

localparam REPEAT_LINE = 4;
localparam BUFFER_LINE_CNT_WIDTH = $clog2(5);
localparam REPEAT_LINE_CNT_WIDTH = $clog2(REPEAT_LINE);
localparam BRAM_LATENCY = 1;

localparam IMAGE_X_CNT_WIDTH  = $clog2(INPUT_IMAGE_WIDTH);
localparam IMAGE_Y_CNT_WIDTH  = $clog2(INPUT_IMAGE_HEIGHT);

localparam LINE_MEMORY_SIZE   = INPUT_IMAGE_WIDTH * PIXEL_WIDTH;

localparam SUPER_BLOCK_HEIGHT = INPUT_IMAGE_HEIGHT + 1;
localparam SUBLK_Y_REG_WIDTH  = $clog2(SUPER_BLOCK_HEIGHT);

localparam SUBLK_Y_ENTER_INTERVAL = SUPER_BLOCK_HEIGHT - 2;

// Input super-block counter
logic [SUBLK_Y_REG_WIDTH - 1:0] sublk_y_reg;
// -- Signals from counter
logic sublk_y_last_row;
assign sublk_y_last_row = (sublk_y_reg == SUPER_BLOCK_HEIGHT - 1);
logic sublk_y_enter_padding;
assign sublk_y_enter_padding = (sublk_y_reg == SUPER_BLOCK_HEIGHT - 2);

// Input pixel counter
logic [IMAGE_X_CNT_WIDTH - 1:0] in_x_reg;

// Output super-block counter
logic [SUBLK_Y_REG_WIDTH - 1:0] out_sublk_y_reg;
// -- Signals from counter
logic out_sublk_y_first_row;
assign out_sublk_y_first_row = (out_sublk_y_reg == 'd0);
logic out_sublk_y_last_row;
assign out_sublk_y_last_row = (out_sublk_y_reg == SUPER_BLOCK_HEIGHT - 1);

// Output pixel counter
logic [IMAGE_X_CNT_WIDTH - 1:0] out_x_reg;
// -- Signals from counter
logic out_x_first_column;
assign out_x_first_column = (out_x_reg == 'd0);
logic out_x_last_column;
assign out_x_last_column = (out_x_reg == INPUT_IMAGE_WIDTH - 1);

// Output repeat counter
// This counter count the output line repeat
// all lines need to repeat 4 times
logic [REPEAT_LINE_CNT_WIDTH - 1:0] out_repeat_reg; 
// -- Signals from counter
logic out_first_repeat;
assign out_first_repeat = (out_repeat_reg == 'd0);
logic out_last_repeat;
assign out_last_repeat = (out_repeat_reg == REPEAT_LINE - 1);

// Buffered line counter
logic [BUFFER_LINE_CNT_WIDTH - 1:0] buffered_line;

// Padding mode
logic padding_mode;

// Buffer writing signal
logic allow_write_to_buffer;
assign allow_write_to_buffer = buffer_ready & pixel_in_valid;

// Outputs from buffer
logic [PIXEL_WIDTH - 1:0] buf_out_data     [0:4];   // Original output from buffers
logic [PIXEL_WIDTH - 1:0] line_out_data    [0:3];   // Output form valid buffers

// Buffer control signals
logic [4:0] buffer_active_reg;      // Indicate which buffer is the first activate buffer
logic [4:0] buffer_active_reg_pipe; // Pipeline register of activate register, for BRAM
logic [4:0] buffer_wract_reg;       // Indicate which buffer is activate to write

// Output padding control signals
logic [3:0] out_padding_reg;
logic [3:0] out_padding_reg_pipe;

// Input state machine
always_ff @(posedge clk, negedge aresetn) begin
    if (!aresetn) begin
        // Reset pixel counters
        sublk_y_reg <= 'd0;
        in_x_reg <= 'b0;

        // Reset buffer counter
        buffered_line <= 'b0;

        // Buffer ready signal
        buffer_ready <= 'b1;

        // Activate last buffer (ID = 4) to write
        buffer_active_reg <= 'b00001;

        // Reset padding mode
        padding_mode <= 'b0;
    end
    else if (clken) begin
        if (sclr) begin
            // Reset pixel counters
            sublk_y_reg <= 'd0;
            in_x_reg <= 'b0;

            // Reset buffer counter
            buffered_line <= 'b0;

            // Buffer ready signal
            buffer_ready <= 'b1;

            // Activate last buffer (ID = 4) to write
            buffer_active_reg <= 'b00001;

            // Reset padding mode
            padding_mode <= 'b0;
        end
        else begin
            if (!padding_mode) begin // Normal mode
                if (buffer_ready) begin
                    // Buffer ready to receive new input pixels 
                    if (pixel_in_valid) begin
                        if (pixel_in_end_of_line) begin
                            in_x_reg <= 'b0; // Reset the X register

                            // If this is the last row of super-blocks
                            if (sublk_y_last_row) begin
                                // Reset the super-block counter
                                sublk_y_reg <= 'b0;
                            end
                            else begin
                                // Increase the super-block counter
                                sublk_y_reg <= sublk_y_reg + 1'b1;
                            end

                            // If we write done all pixels of a frame,
                            // we need entering padding mode,
                            // because we have to padding 2 lines back of the frame
                            if (sublk_y_enter_padding) begin
                                padding_mode <= 1'b1;
                            end

                            if (buffered_line == 'd2) begin
                                // The buffer is full, can not storage more pixels
                                buffer_ready <= 'b0;
                            end
                            else begin
                                // Increase the buffered line
                                buffered_line <= buffered_line + 'b1;

                                // Set the actived line to next line
                                buffer_active_reg <= {buffer_active_reg[3:0], buffer_active_reg[4]};
                            end
                        end
                        else begin
                            in_x_reg <= in_x_reg + 'b1; // Increase the X register
                        end
                    end
                    else begin // If the no input pixel valid
                        // And at this time, a reading has been done.
                        // Because of there is no new pixel,
                        // we need to decrease the lines in the buffer,
                        // and active next line for read
                        if (out_x_last_column && out_last_repeat) begin
                            buffered_line <= buffered_line - 'b1;

                            // We need to active the next buffer line to read
                            buffer_active_reg <= {buffer_active_reg[3:0], buffer_active_reg[4]};
                        end
                    end
                end
                else begin
                    if (out_x_last_column && out_last_repeat) begin
                        // The lines in the buffer was outputed, 
                        // so we can accept a new line
                        buffer_ready <= 'b1;
                        
                        // We need to active the next buffer line to read & write
                        buffer_active_reg <= {buffer_active_reg[3:0], buffer_active_reg[4]};
                    end
                end
            end 
            else begin // Padding mode
            // When we in the padding mode, the output is normally.
            // But we do not allow any new pixel write in
            // After 1 full reading, we can exit the padding mode
            if (out_x_last_column && out_last_repeat) begin
                // We need to active the next buffer line to read
                buffer_active_reg <= {buffer_active_reg[3:0], buffer_active_reg[4]};

                // When exit the padding mode, increase the super-block counter
                if (sublk_y_last_row) begin
                    // Reset the super-block counter
                    sublk_y_reg <= 'b0;
                end
                else begin
                    // Increase the super-block counter
                    sublk_y_reg <= sublk_y_reg + 1'b1;
                end

                // Exit the padding mode
                padding_mode <= 'b0;
            end
        end
        end
    end
end

// Output state machine
always_ff @(posedge clk, negedge aresetn) begin
    if (!aresetn) begin
        // Reset pixel counters
        out_x_reg <= 'b0;
        out_repeat_reg <= 'b0;

        // Reset super-block counter
        out_sublk_y_reg <= 'b0;

        // Reset output valid signals
        pixel_out_valid <= 'b0;

        // Reset output padding register
        out_padding_reg <= 'b0;
    end
    else if (clken) begin
        if (sclr) begin
            // Reset pixel counters
            out_x_reg <= 'b0;
            out_repeat_reg <= 'b0;

            // Reset super-block counter
            out_sublk_y_reg <= 'b0;

            // Reset output valid signals
            pixel_out_valid <= 'b0;

            // Reset output padding register
            out_padding_reg <= 'b0;
        end
        else begin
            // Use super-block counter to control the padding
            case (out_sublk_y_reg)
                'h0:                      out_padding_reg <= 'b0001;
                'h1:                      out_padding_reg <= 'b0010;
                (SUPER_BLOCK_HEIGHT - 2): out_padding_reg <= 'b0100;
                (SUPER_BLOCK_HEIGHT - 1): out_padding_reg <= 'b1000;
                default:                  out_padding_reg <= 'b0000;
            endcase

            if (!pixel_out_valid) begin
                // If the read valid is not activate
                if (pixel_in_valid && pixel_in_end_of_line) begin
                    // When the input side has write to a end of line
                    // And there is 2 lines in the buffer,
                    // (BUFFERED_LINE will increase at next clock)
                    // then let pixel read valid

                    if (buffered_line == 'd1) begin
                        pixel_out_valid <= 'b1;
                    end
                end
            end
            else begin
            // If the pixel read valid
            if (pipeline_ready) begin // If the pipeline accepted the pixel
                if (out_x_last_column) begin
                    // If this is the end of a line
                    out_x_reg <= 'b0; // Reset the X register
                    if (out_last_repeat) begin
                        // If this is the last repeat of the super-block
                        out_repeat_reg <= 'b0; // Reset the repeat register

                        // If this is the last row of super-blocks
                        if (out_sublk_y_last_row) begin
                            // Reset the super-block counter
                            out_sublk_y_reg <= 'b0;
                        end
                        else begin
                            // Increase the super-block counter
                            out_sublk_y_reg <= out_sublk_y_reg + 'b1;
                        end

                        // When all of the buffered line are readed, exit the read mode
                        if ((buffered_line == 'd1) && (!padding_mode) && (buffer_ready) && (!pixel_in_valid)) begin
                            pixel_out_valid <= 'b0;
                        end
                    end
                    else begin
                        // Else, increase the repeat times
                        out_repeat_reg <= out_repeat_reg + 'b1;
                    end
                end
                else begin
                    // Else, increase the X register to give next pixel
                    out_x_reg <= out_x_reg + 'b1;
                end
            end
        end
        end
    end
end

// Pipeline of output padding control
// sfr_ce #(.WIDTH(4), .LATENCY(BRAM_LATENCY)) 
// out_padding_reg_sfr
// (.*, .data_in(out_padding_reg), .data_out(out_padding_reg_pipe));
assign out_padding_reg_pipe = out_padding_reg;

// Pipeline of buffer activate
sfr_ce_sclr #(.WIDTH(5), .LATENCY(BRAM_LATENCY)) 
buffer_active_reg_sfr
(.*, .data_in(buffer_active_reg), .data_out(buffer_active_reg_pipe));

// Start of frame control
assign pixel_out_start_of_frame = out_sublk_y_first_row & out_x_first_column & out_first_repeat;

// The activate table
// Activate | BACT_REG | Writing | BWRACT_REG
// ==========================================
// 0        | 00001    | 4       | 10000
// 1        | 00010    | 0       | 00001
// 2        | 00100    | 1       | 00010
// 3        | 01000    | 2       | 00100
// 4        | 10000    | 3       | 01000
assign buffer_wract_reg = {buffer_active_reg[0], buffer_active_reg[4:1]};

// Buffer output multiplexer
generate 
    for (genvar i = 0; i < 4; i++) begin : BUF_OUT_MUX_GEN
        always_comb begin : BUF_OUT_MUX
            case (buffer_active_reg_pipe)
                'b00001: line_out_data[i] = buf_out_data[i];
                'b00010: line_out_data[i] = buf_out_data[i + 1];
                'b00100: line_out_data[i] = buf_out_data[(i + 2) > 4 ? i - 3 : i + 2];
                'b01000: line_out_data[i] = buf_out_data[(i + 3) > 4 ? i - 2 : i + 3];
                'b10000: line_out_data[i] = buf_out_data[(i + 4) > 4 ? i - 1 : i + 4];
                default: line_out_data[i] = 'h0;
            endcase
        end
    end
endgenerate

// Output padding multiplexers
always_comb begin : OUT_PADDING_LINE0
    case (out_padding_reg_pipe[1:0])
        'b00:    pixel_line0 = line_out_data[0];
        'b01:    pixel_line0 = line_out_data[2];
        'b10:    pixel_line0 = line_out_data[1];  
        default: pixel_line0 = 'b0;
    endcase
end

always_comb begin : OUT_PADDING_LINE1
    case (out_padding_reg_pipe[0])
        'b0:     pixel_line1 = line_out_data[1];
        'b1:     pixel_line1 = line_out_data[2];
        default: pixel_line1 = 'b0;
    endcase
end

always_comb begin : OUT_PADDING_LINE2
    case (out_padding_reg_pipe[3])
        'b0:     pixel_line2 = line_out_data[2];
        'b1:     pixel_line2 = line_out_data[1];
        default: pixel_line2 = 'b0;
    endcase
end

always_comb begin : OUT_PADDING_LINE3
    case (out_padding_reg_pipe[3:2])
        'b00:    pixel_line3 = line_out_data[3];
        'b01:    pixel_line3 = line_out_data[2];
        'b10:    pixel_line3 = line_out_data[1];
        default: pixel_line3 = 'b0;
    endcase
end

// Buffers (SDPRAM)
generate
    for (genvar i = 0; i < 5; i++) begin : LINE_BUFFER_GEN
        sdpram #(
            .MEMORY_SIZE(LINE_MEMORY_SIZE),
            .ADDR_WIDTH_A(IMAGE_X_CNT_WIDTH),
            .ADDR_WIDTH_B(IMAGE_X_CNT_WIDTH),
            .DATA_WIDTH_A(PIXEL_WIDTH),
            .DATA_WIDTH_B(PIXEL_WIDTH),
            .CLOCKING_MODE("common_clock")
        ) line_buffer_ram (
            .a_clk(clk),
            .b_clk(clk),
            .sreset(bram_reset),
            .a_addr(in_x_reg),
            .a_data(pixel_in),
            .a_wren(buffer_wract_reg[i] & allow_write_to_buffer),
            .b_addr(out_x_reg),
            .b_data(buf_out_data[i])
        );
    end
endgenerate


endmodule
