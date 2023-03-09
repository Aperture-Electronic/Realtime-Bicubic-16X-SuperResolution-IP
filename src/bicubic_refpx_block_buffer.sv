// System verilog source file
// Reference (original) pixel block buffer for Bicubic
// Designer:    Deng LiWei
// Date:        2022/03
// Description: A buffer can storage 4x4 pixels which use for reference pixel of Bicubic algorithm

module bicubic_refpx_block_buffer
#(
    parameter PIXEL_WIDTH = 8
)
(
    // Clock & reset
    input logic clk,
    input logic aresetn,
    input logic clken,

    // Input data
    input logic [PIXEL_WIDTH - 1:0]line_0_in,
    input logic [PIXEL_WIDTH - 1:0]line_1_in,
    input logic [PIXEL_WIDTH - 1:0]line_2_in,
    input logic [PIXEL_WIDTH - 1:0]line_3_in,

    // Write enable
    input logic wren,

    // MUX control
    input logic [3:0]mux_ctrl,

    // Output pixels
    output logic [PIXEL_WIDTH - 1:0]px_0_0_out,
    output logic [PIXEL_WIDTH - 1:0]px_1_0_out,
    output logic [PIXEL_WIDTH - 1:0]px_2_0_out,
    output logic [PIXEL_WIDTH - 1:0]px_3_0_out,

    output logic [PIXEL_WIDTH - 1:0]px_0_1_out,
    output logic [PIXEL_WIDTH - 1:0]px_1_1_out,
    output logic [PIXEL_WIDTH - 1:0]px_2_1_out,
    output logic [PIXEL_WIDTH - 1:0]px_3_1_out,

    output logic [PIXEL_WIDTH - 1:0]px_0_2_out,
    output logic [PIXEL_WIDTH - 1:0]px_1_2_out,
    output logic [PIXEL_WIDTH - 1:0]px_2_2_out,
    output logic [PIXEL_WIDTH - 1:0]px_3_2_out,

    output logic [PIXEL_WIDTH - 1:0]px_0_3_out,
    output logic [PIXEL_WIDTH - 1:0]px_1_3_out,
    output logic [PIXEL_WIDTH - 1:0]px_2_3_out,
    output logic [PIXEL_WIDTH - 1:0]px_3_3_out
);

// MUX control
// The multiplixer is for padding left/right of the image
// MUX_CTRL         Output columns
// [3] [2] [1] [0]  0  1  2  3   
// 0   0   0   0    0  1  2  3  -- Normal
// 0   0   0   1    1  1  2  3  -- Padding left
// 0   0   1   0    2  2  2  3
// 0   1   0   0    0  1  2  2  -- Padding right
// 1   0   0   0    0  1  1  1
// Others           X  X  X  X  -- Invalid

// Line input
logic [PIXEL_WIDTH - 1:0]line_in[0:3];

// always_ff @(posedge clk, negedge aresetn) begin
//     if (!aresetn) begin
//         line_in[0] <= 'd0;
//         line_in[1] <= 'd0;
//         line_in[2] <= 'd0;
//         line_in[3] <= 'd0;
//     end
//     else begin
//         line_in[0] <= line_0_in;
//         line_in[1] <= line_1_in;
//         line_in[2] <= line_2_in;
//         line_in[3] <= line_3_in;
//     end
// end

assign line_in[0] = line_0_in;
assign line_in[1] = line_1_in;
assign line_in[2] = line_2_in;
assign line_in[3] = line_3_in;

// Pixel buffer
logic [PIXEL_WIDTH - 1:0]px_buf[0:15];

// index    0 1 2 3 4 5 6 7 8 9 ...
// line     0 1 2 3 0 1 2 3 0 1 ...
// column   3       2       1       0

generate 
    for (genvar i = 0; i < 16; i++) begin
        always_ff @(posedge clk, negedge aresetn) begin
            if (!aresetn) begin
                px_buf[i] <= 'b0;
            end
            else if (clken && wren) begin
                if (i < 4) begin
                    px_buf[i] <= line_in[i];
                end
                else begin
                    px_buf[i] <= px_buf[i - 4];
                end
            end
        end
    end
endgenerate

// Column 0, controlled by MUX_CTRL[1:0]
//                             Row   3-Column
always_comb begin          //   |       |
    case (mux_ctrl[1:0])   //   |       |
        'b00: begin        //   |       |
            px_0_0_out = px_buf[0 + 4 * 3];
            px_0_1_out = px_buf[1 + 4 * 3];
            px_0_2_out = px_buf[2 + 4 * 3];
            px_0_3_out = px_buf[3 + 4 * 3];
        end                //   |       |
        'b01: begin        //   |       |
            px_0_0_out = px_buf[0 + 4 * 1];
            px_0_1_out = px_buf[1 + 4 * 1];
            px_0_2_out = px_buf[2 + 4 * 1];
            px_0_3_out = px_buf[3 + 4 * 1];
        end                //   |       |
        'b10: begin        //   |       |
            px_0_0_out = px_buf[0 + 4 * 2];
            px_0_1_out = px_buf[1 + 4 * 2];
            px_0_2_out = px_buf[2 + 4 * 2];
            px_0_3_out = px_buf[3 + 4 * 2];
        end
        default: begin
            px_0_0_out = 'b0;
            px_0_1_out = 'b0;
            px_0_2_out = 'b0;
            px_0_3_out = 'b0;
        end
    endcase
end

// Column 1, controlled by MUX_CTRL[1]
//                             Row   3-Column
always_comb begin          //   |       |
    case (mux_ctrl[0])     //   |       |
        'b0: begin         //   |       |
            px_1_0_out = px_buf[0 + 4 * 2];
            px_1_1_out = px_buf[1 + 4 * 2];
            px_1_2_out = px_buf[2 + 4 * 2];
            px_1_3_out = px_buf[3 + 4 * 2];
        end                //   |       |
        'b1: begin         //   |       |
            px_1_0_out = px_buf[0 + 4 * 1];
            px_1_1_out = px_buf[1 + 4 * 1];
            px_1_2_out = px_buf[2 + 4 * 1];
            px_1_3_out = px_buf[3 + 4 * 1];
        end
        default: begin
            px_1_0_out = 'b0;
            px_1_1_out = 'b0;
            px_1_2_out = 'b0;
            px_1_3_out = 'b0;
        end
    endcase
end

// Column 2, controlled by MUX_CTRL[3]
//                             Row   3-Column
always_comb begin          //   |       |
    case (mux_ctrl[3])     //   |       |
        'b0: begin         //   |       |
            px_2_0_out = px_buf[0 + 4 * 1];
            px_2_1_out = px_buf[1 + 4 * 1];
            px_2_2_out = px_buf[2 + 4 * 1];
            px_2_3_out = px_buf[3 + 4 * 1];
        end                //   |       |
        'b1: begin         //   |       |
            px_2_0_out = px_buf[0 + 4 * 2];
            px_2_1_out = px_buf[1 + 4 * 2];
            px_2_2_out = px_buf[2 + 4 * 2];
            px_2_3_out = px_buf[3 + 4 * 2];
        end
        default: begin
            px_2_0_out = 'b0;
            px_2_1_out = 'b0;
            px_2_2_out = 'b0;
            px_2_3_out = 'b0;
        end
    endcase
end

// Column 3, controlled by MUX_CTRL[3:2]
//                             Row   3-Column
always_comb begin          //   |       |
    case (mux_ctrl[3:2])   //   |       |
        'b00: begin        //   |       |
            px_3_0_out = px_buf[0 + 4 * 0];
            px_3_1_out = px_buf[1 + 4 * 0];
            px_3_2_out = px_buf[2 + 4 * 0];
            px_3_3_out = px_buf[3 + 4 * 0];
        end                //   |       |
        'b01: begin        //   |       |
            px_3_0_out = px_buf[0 + 4 * 1];
            px_3_1_out = px_buf[1 + 4 * 1];
            px_3_2_out = px_buf[2 + 4 * 1];
            px_3_3_out = px_buf[3 + 4 * 1];
        end                //   |       |
        'b10: begin        //   |       |
            px_3_0_out = px_buf[0 + 4 * 2];
            px_3_1_out = px_buf[1 + 4 * 2];
            px_3_2_out = px_buf[2 + 4 * 2];
            px_3_3_out = px_buf[3 + 4 * 2];
        end
        default: begin
            px_3_0_out = 'b0;
            px_3_1_out = 'b0;
            px_3_2_out = 'b0;
            px_3_3_out = 'b0;
        end
    endcase
end

endmodule

