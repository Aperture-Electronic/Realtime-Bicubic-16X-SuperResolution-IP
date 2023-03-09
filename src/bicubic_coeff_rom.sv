// System verilog source file
// Bicubic coefficient ROM
// Designer:    Deng LiWei
// Date:        2022/03
// Description: Coefficient ROM (look-up table) of Bicubic

module bicubic_coeff_rom
(
    // Clock & reset
    input logic clk,

    // Line input
    input logic line,

    // Coefficient output
    output logic [18 * 16 - 1:0]coeff_dsp_o
);

(* rom_style = "distributed" *) logic [17:0]coeff_dsp_rom [0:15];

generate for (genvar i = 0; i < 16; i++) begin
    assign coeff_dsp_o[(((i * 18) + 18) - 1):(i * 18)] = coeff_dsp_rom[i];
end
endgenerate 

always_ff @(posedge clk) begin : COEFF_DSP_0
	if (!line) begin
		coeff_dsp_rom[0] <= 'b000000010_111101000;
	end
	else begin
		coeff_dsp_rom[0] <= 'b000000100_111101101;
	end
end

always_ff @(posedge clk) begin : COEFF_DSP_1
	if (!line) begin
		coeff_dsp_rom[1] <= 'b000000100_111011100;
	end
	else begin
		coeff_dsp_rom[1] <= 'b000000101_111100011;
	end
end

always_ff @(posedge clk) begin : COEFF_DSP_2
	if (!line) begin
		coeff_dsp_rom[2] <= 'b000000010_111101010;
	end
	else begin
		coeff_dsp_rom[2] <= 'b000000011_111101111;
	end
end

always_ff @(posedge clk) begin : COEFF_DSP_3
	if (!line) begin
		coeff_dsp_rom[3] <= 'b000000000_111111101;
	end
	else begin
		coeff_dsp_rom[3] <= 'b000000001_111111101;
	end
end

always_ff @(posedge clk) begin : COEFF_DSP_4
	if (!line) begin
		coeff_dsp_rom[4] <= 'b111101000_011110001;
	end
	else begin
		coeff_dsp_rom[4] <= 'b111011100_011000000;
	end
end

always_ff @(posedge clk) begin : COEFF_DSP_5
	if (!line) begin
		coeff_dsp_rom[5] <= 'b111101101_011000000;
	end
	else begin
		coeff_dsp_rom[5] <= 'b111100011_010011000;
	end
end

always_ff @(posedge clk) begin : COEFF_DSP_6
	if (!line) begin
		coeff_dsp_rom[6] <= 'b111110101_001110011;
	end
	else begin
		coeff_dsp_rom[6] <= 'b111101111_001011011;
	end
end

always_ff @(posedge clk) begin : COEFF_DSP_7
	if (!line) begin
		coeff_dsp_rom[7] <= 'b111111101_000100010;
	end
	else begin
		coeff_dsp_rom[7] <= 'b111111011_000011011;
	end
end

always_ff @(posedge clk) begin : COEFF_DSP_8
	if (!line) begin
		coeff_dsp_rom[8] <= 'b111111101_000000000;
	end
	else begin
		coeff_dsp_rom[8] <= 'b111110101_000000010;
	end
end

always_ff @(posedge clk) begin : COEFF_DSP_9
	if (!line) begin
		coeff_dsp_rom[9] <= 'b111111011_000000001;
	end
	else begin
		coeff_dsp_rom[9] <= 'b111101111_000000011;
	end
end

always_ff @(posedge clk) begin : COEFF_DSP_10
	if (!line) begin
		coeff_dsp_rom[10] <= 'b111111101_000000000;
	end
	else begin
		coeff_dsp_rom[10] <= 'b111110110_000000010;
	end
end

always_ff @(posedge clk) begin : COEFF_DSP_11
	if (!line) begin
		coeff_dsp_rom[11] <= 'b000000000_000000000;
	end
	else begin
		coeff_dsp_rom[11] <= 'b111111110_000000000;
	end
end

always_ff @(posedge clk) begin : COEFF_DSP_12
	if (!line) begin
		coeff_dsp_rom[12] <= 'b000100010_111111101;
	end
	else begin
		coeff_dsp_rom[12] <= 'b001110011_111101010;
	end
end

always_ff @(posedge clk) begin : COEFF_DSP_13
	if (!line) begin
		coeff_dsp_rom[13] <= 'b000011011_111111101;
	end
	else begin
		coeff_dsp_rom[13] <= 'b001011011_111101111;
	end
end

always_ff @(posedge clk) begin : COEFF_DSP_14
	if (!line) begin
		coeff_dsp_rom[14] <= 'b000010000_111111110;
	end
	else begin
		coeff_dsp_rom[14] <= 'b000110111_111110110;
	end
end

always_ff @(posedge clk) begin : COEFF_DSP_15
	if (!line) begin
		coeff_dsp_rom[15] <= 'b000000101_000000000;
	end
	else begin
		coeff_dsp_rom[15] <= 'b000010000_111111101;
	end
end

endmodule
