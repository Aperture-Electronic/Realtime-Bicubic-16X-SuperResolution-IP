// System verilog testbench file
// Pixel, memory, computation controller for Bicubic
// Designer:    Deng LiWei
// Date:        2022/03

module bicubic_pixel_controller_tb();

// IP settings
// Output image size
localparam OUTPUT_WIDTH = 3840;
localparam OUTPUT_HEIGHT = 2160;

// Pixel phase (How many clocks we will stop on a pixel)
localparam PIXEL_PHASE = 2;
localparam PPHS_REG_WIDTH = $clog2(PIXEL_PHASE);

// Clock & reset
logic clk;
logic aresetn;
logic clken;

// Phase output
logic [PPHS_REG_WIDTH - 1:0]phase;

// Super line
logic superline;

// Super-block Y symmetric output
logic super_y_symmetric;

// Reference pixel buffer multiplexer control
logic [3:0]ref_pb_mux_ctrl;

// DUV
bicubic_pixel_controller #(
    .OUTPUT_WIDTH(OUTPUT_WIDTH),
    .OUTPUT_HEIGHT(OUTPUT_HEIGHT),
    .PIXEL_PHASE(PIXEL_PHASE),
    .PPHS_REG_WIDTH(PPHS_REG_WIDTH)
) DUV(.*);

// Clock generate
always begin
    clk = 0;
    forever #5 clk = ~clk;
end

// Testflow
initial begin
    $display("bicubic_pixel_controller Testbench");
    $display("Reseting...");

    clken = 0;
    aresetn = 0;

    #15
    @(negedge clk) aresetn = 1;
    $display("Running...");
    for (int i = 0; i < 16; i++) begin
        @(posedge clk);
    end
    $display("DSP48E slice reset released @%t.", $time);
    clken = 1;
end

endmodule

