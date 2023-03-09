// System verilog source file
// A compensator for DSP SIMD 2x INT9xUINT8 multiplier 
// Designer:    Deng LiWei
// Date:        2022/03
// Description: The high segment of the output of DSP SIMD 2x INT9xUINT8 multiplier need
//              be compensated by the most significant bit of low segment

module dsp_simd2x_hseg_comp
#(
    // Set if we need a register slice for higher performance
    parameter OUT_REG_SLICE = "true"
)
(
    // Clock & reset
    input logic clk,
    input logic aresetn,
    input logic clken,

    // Data input
    input logic signed [47:0] dsp_data_in,

    // Separated compensated output
    output logic signed [17:0] low_segment,
    output logic signed [17:0] high_segment
);

generate
    if (OUT_REG_SLICE == "true") begin
        // Need a register slice for higher performance
        logic signed [17:0] low_segment_reg;
        logic signed [17:0] high_segment_reg;

        always_ff @(posedge clk, negedge aresetn) begin
            if (!aresetn) begin
                low_segment <= 'b0;
                high_segment <= 'b0;
            end
            else if (clken) begin
                low_segment_reg <= dsp_data_in[17:0];
                high_segment_reg <= dsp_data_in[35:18] + dsp_data_in[17];
            end
        end

        assign low_segment = low_segment_reg;
        assign high_segment = high_segment_reg;
    end
    else begin
        // Do not need a register slice for smaller area
        assign low_segment = dsp_data_in[17:0];
        assign high_segment = dsp_data_in[35:18] + dsp_data_in[17];
    end
endgenerate


endmodule

