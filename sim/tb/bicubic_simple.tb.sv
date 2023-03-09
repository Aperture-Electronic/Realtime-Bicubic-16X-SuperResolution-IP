// System verilog testbench file
// Bicubic core (Simple test)
// Designer:    Deng LiWei
// Date:        2022/03
`timescale 1ns/1ns

import bitmap_processing::*;
import axi_stream_video_image::*;

module bicubic_simple_tb();

// IP parameters
localparam INPUT_VIDEO_WIDTH  = 16;
localparam INPUT_VIDEO_HEIGHT = 8;

// Interfaces
// DUV
// Clock & reset
logic clk;
logic aresetn;
logic dsp_reset;
logic bram_reset;
logic clken;
logic sclr;

// Input AXI-Stream video
logic [7:0]  s_axis_video_r_in_tdata;
logic [7:0]  s_axis_video_g_in_tdata;
logic [7:0]  s_axis_video_b_in_tdata;

logic        s_axis_video_in_tvalid;
logic        s_axis_video_in_tuser;   // Start of frame
logic        s_axis_video_in_tlast;   // End of line
logic        s_axis_video_in_tready;

// Output AXI-Stream video
logic [31:0] m_axis_video_r_out_tdata;
logic        m_axis_video_r_out_tvalid;
logic        m_axis_video_r_out_tuser;   // Start of frame
logic        m_axis_video_r_out_tlast;   // End of line

logic [31:0] m_axis_video_g_out_tdata;
logic        m_axis_video_g_out_tvalid;
logic        m_axis_video_g_out_tuser;   // Start of frame
logic        m_axis_video_g_out_tlast;   // End of line

logic [31:0] m_axis_video_b_out_tdata;
logic        m_axis_video_b_out_tvalid;
logic        m_axis_video_b_out_tuser;   // Start of frame
logic        m_axis_video_b_out_tlast;   // End of line

// Bitmaps
Bitmap inputBitmap;
Bitmap outputBitmap;
 
// Input / output video data slice 
logic [31:0]         s_axis_video_in_tdata_original;
logic [32 * 4 - 1:0] m_axis_video_out_tdata_original;

assign s_axis_video_r_in_tdata = s_axis_video_in_tdata_original[15:8];
assign s_axis_video_g_in_tdata = s_axis_video_in_tdata_original[23:16];
assign s_axis_video_b_in_tdata = s_axis_video_in_tdata_original[31:24];

assign m_axis_video_out_tdata_original = {
    m_axis_video_b_out_tdata[31:24], m_axis_video_g_out_tdata[31:24], m_axis_video_r_out_tdata[31:24], 8'b0,
    m_axis_video_b_out_tdata[23:16], m_axis_video_g_out_tdata[23:16], m_axis_video_r_out_tdata[23:16], 8'b0,
    m_axis_video_b_out_tdata[15: 8], m_axis_video_g_out_tdata[15: 8], m_axis_video_r_out_tdata[15: 8], 8'b0,
    m_axis_video_b_out_tdata[ 7: 0], m_axis_video_g_out_tdata[ 7: 0], m_axis_video_r_out_tdata[ 7: 0], 8'b0
};
//assign m_axis_video_out_tdata_original = {32'hFF000000, 32'h00000000, 32'h0000FF00, 32'h00FF0000};
assign m_axis_video_g_out_tdata = 0;
assign m_axis_video_r_out_tdata = 0;
// Callback class
bit[1:0] sent;
class VideoVIPCallback extends AxisVideoImageCallback;
    virtual task SentCallback(); 
        $display("Sent");
	 if (sent == 0) begin
	     $display("Send next");
	     //in_vip.SendBitmap();
             sent = 1;
	 end
	 else begin
             sent = 2;
	 end
    endtask

    virtual task ReceivedCallback(); 
        $display("Received");
        // $finish();
        if (sent == 2) $stop();
        else out_vip.ReceiveAndSaveBitmap("out.bmp");
    endtask
endclass

VideoVIPCallback vcallback = new();
AxisVideoImageCallback callbacks = vcallback;


// DUV
bicubic #(
    .INPUT_VIDEO_WIDTH(INPUT_VIDEO_WIDTH),
    .INPUT_VIDEO_HEIGHT(INPUT_VIDEO_HEIGHT)
) DUV_B 
(
    .*,
    .s_axis_video_in_tdata(s_axis_video_b_in_tdata),
    .m_axis_video_out_tdata(m_axis_video_b_out_tdata)
);
/*
bicubic #(
    .INPUT_VIDEO_WIDTH(INPUT_VIDEO_WIDTH),
    .INPUT_VIDEO_HEIGHT(INPUT_VIDEO_HEIGHT)
) DUV_G 
(
    .*,
    .s_axis_video_in_tdata(s_axis_video_g_in_tdata),    
    .s_axis_video_in_tready(),
    .m_axis_video_out_tdata(m_axis_video_g_out_tdata),
    .m_axis_video_out_tvalid(),
    .m_axis_video_out_tuser(), 
    .m_axis_video_out_tlast()
);

bicubic #(
    .INPUT_VIDEO_WIDTH(INPUT_VIDEO_WIDTH),
    .INPUT_VIDEO_HEIGHT(INPUT_VIDEO_HEIGHT)
) DUV_R 
(
    .*,
    .s_axis_video_in_tdata(s_axis_video_r_in_tdata),    
    .s_axis_video_in_tready(),
    .m_axis_video_out_tdata(m_axis_video_r_out_tdata),
    .m_axis_video_out_tvalid(),
    .m_axis_video_out_tuser(), 
    .m_axis_video_out_tlast()
);
*/
// VIPs
axis_video_img_in_vip #(
    .IMAGE_WIDTH (INPUT_VIDEO_WIDTH ),
    .IMAGE_HEIGHT(INPUT_VIDEO_HEIGHT),
    .PIXEL_PER_CLK(1)
)
in_vip
(
    .*,
    .frameBitmap(inputBitmap),
    .callbacks(callbacks),
    .m_axis_video_out_tdata (s_axis_video_in_tdata_original),
    .m_axis_video_out_tvalid(s_axis_video_in_tvalid),
    .m_axis_video_out_tlast (s_axis_video_in_tlast ),
    .m_axis_video_out_tuser (s_axis_video_in_tuser ),
    .m_axis_video_out_tready(s_axis_video_in_tready)    
);

axis_video_img_out_vip #(
    .IMAGE_WIDTH (INPUT_VIDEO_WIDTH  * 4),
    .IMAGE_HEIGHT(INPUT_VIDEO_HEIGHT * 4),
    .PIXEL_PER_CLK(4)
)
out_vip
(
    .*,
    .frameBitmap (outputBitmap),
    .callbacks(callbacks),
    .s_axis_video_in_tdata (m_axis_video_out_tdata_original ),
    .s_axis_video_in_tvalid(m_axis_video_out_tvalid),
    .s_axis_video_in_tlast (m_axis_video_out_tlast ),
    .s_axis_video_in_tuser (m_axis_video_out_tuser ),
    .s_axis_video_in_tready(1'b1)
);

// Clock generate
always begin
    clk = 0;
    forever #5 clk = ~clk;
end

// Testflow
initial begin
    $display("bicubic_line_buffer Testbench");
    $display("Reseting...");

    clken = 0;
    aresetn = 0;
    dsp_reset = 1;
    bram_reset = 1;
    sent = 0;
    sclr = 0;

    #15
    @(negedge clk) aresetn = 1;
    $display("Running...");
    for (int i = 0; i < 16; i++) begin
        @(posedge clk);
    end
    $display("DSP48E & BRAM slice reset released @%t.", $time);
    clken = 1;
    bram_reset = 0;
    dsp_reset = 0;

    @(posedge clk);

    out_vip.ReceiveAndSaveBitmap("");
    in_vip.ReadAndSendBitmap("in.bmp");
    #1000
    in_vip.Cancel();
    wait(sent == 1);
    out_vip.Cancel();
    #100
    sclr = 1;
    #200
    sclr = 0;
    @(posedge clk);

    in_vip.SendBitmap();
end
endmodule
