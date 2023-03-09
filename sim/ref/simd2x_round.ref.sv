// System verilog test reference model file
// SIMD 2x rounding module
// Designer:    Deng LiWei
// Date:        2022/03

module simd2x_round_ref
#(
    parameter LATENCY = 4,
    parameter INPUT_WIDTH = 48,
    parameter RSHIFT_RANGE = 8,
    parameter OUTPUT_WIDTH = 9
)
(
    // Clock & reset
    input logic clk,
    input logic aresetn,

    // Data input
    input logic signed [INPUT_WIDTH - 1:0]rin_ch0,
    input logic signed [INPUT_WIDTH - 1:0]rin_ch1,

    // Data output
    output logic signed [OUTPUT_WIDTH - 1:0]rout_ch0,
    output logic signed [OUTPUT_WIDTH - 1:0]rout_ch1,

    // Reference output
    output logic signed [INPUT_WIDTH - 1:0]rin_ch0_ref,
    output logic signed [INPUT_WIDTH - 1:0]rin_ch1_ref
);

// Rounding
real in_ch0, in_ch1;
real rounding_ch0, rounding_ch1;
real rint_ch0, rint_ch1;

real rounding_div;
assign rounding_div = $pow(2, RSHIFT_RANGE);

logic signed [OUTPUT_WIDTH - 1:0]result_ch0;
logic signed [OUTPUT_WIDTH - 1:0]result_ch1;

// Computation
always_comb begin
    in_ch0 = $itor(rin_ch0);
    in_ch1 = $itor(rin_ch1);
    
    // Div
    rounding_ch0 = in_ch0 / rounding_div;
    rounding_ch1 = in_ch1 / rounding_div;

    // Floor
    rint_ch0 = $floor(rounding_ch0);
    rint_ch1 = $floor(rounding_ch1);

    if (rounding_ch0 - rint_ch0 >= 0.5) begin
        rint_ch0++;
    end
    
    if (rounding_ch1 - rint_ch1 >= 0.5) begin
        rint_ch1++;
    end

    result_ch0 = $rtoi(rint_ch0);
    result_ch1 = $rtoi(rint_ch1);
end

// Shift registers
sfr #(.LATENCY(LATENCY), .WIDTH(OUTPUT_WIDTH)) srl_result0_ref (.*, .data_in(result_ch0), .data_out(rout_ch0));
sfr #(.LATENCY(LATENCY), .WIDTH(OUTPUT_WIDTH)) srl_result1_ref (.*, .data_in(result_ch1), .data_out(rout_ch1));

sfr #(.LATENCY(LATENCY), .WIDTH(INPUT_WIDTH)) srl_ch0_ref (.*, .data_in(rin_ch0), .data_out(rin_ch0_ref));
sfr #(.LATENCY(LATENCY), .WIDTH(INPUT_WIDTH)) srl_ch1_ref (.*, .data_in(rin_ch1), .data_out(rin_ch1_ref));

endmodule

