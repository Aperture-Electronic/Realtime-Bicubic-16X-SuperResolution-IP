// System verilog source file
// Width reconfigurable shift register (Z^(-n) transform)
// Designer:    Deng LiWei
// Date:        2022/03
// Description: A shift register which can configure its width and latency

module sfr
#(
    parameter WIDTH = 8,
    parameter LATENCY = 1
)
(
    // Clock & reset
    input logic clk,
    input logic aresetn,

    // Data input
    input logic [WIDTH - 1:0]data_in,

    // Data output
    output logic [WIDTH - 1:0]data_out
);

logic [WIDTH - 1:0]sfr_reg[0:LATENCY - 1];

genvar i;
generate
    for (i = 0; i < LATENCY; i++) begin : SFR_SHIFT
        always_ff @(posedge clk, negedge aresetn) begin : SFR_REG
            if (!aresetn) begin
                sfr_reg[i] <= 'b0;
            end
            else begin
                sfr_reg[i] <= (i == 0) ? data_in : sfr_reg[i - 1];
            end
        end
    end
endgenerate

assign data_out = sfr_reg[LATENCY - 1];

endmodule
