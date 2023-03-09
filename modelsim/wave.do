onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /bicubic_line_buffer_tb/DUV/aresetn
add wave -noupdate /bicubic_line_buffer_tb/DUV/aclk
add wave -noupdate -radix unsigned /bicubic_line_buffer_tb/DUV/s_axis_video_in_tdata
add wave -noupdate /bicubic_line_buffer_tb/DUV/s_axis_video_in_tvalid
add wave -noupdate /bicubic_line_buffer_tb/DUV/s_axis_video_in_tready
add wave -noupdate /bicubic_line_buffer_tb/DUV/s_axis_video_in_tlast
add wave -noupdate /bicubic_line_buffer_tb/DUV/s_axis_video_in_tuser
add wave -noupdate /bicubic_line_buffer_tb/DUV/oclk
add wave -noupdate /bicubic_line_buffer_tb/DUV/sreset
add wave -noupdate /bicubic_line_buffer_tb/DUV/output_req
add wave -noupdate /bicubic_line_buffer_tb/DUV/output_valid
add wave -noupdate -expand -group OUTPUT_PIXELS -radix unsigned /bicubic_line_buffer_tb/DUV/pixel_line0
add wave -noupdate -expand -group OUTPUT_PIXELS -radix unsigned /bicubic_line_buffer_tb/DUV/pixel_line1
add wave -noupdate -expand -group OUTPUT_PIXELS -radix unsigned /bicubic_line_buffer_tb/DUV/pixel_line2
add wave -noupdate -expand -group OUTPUT_PIXELS -radix unsigned /bicubic_line_buffer_tb/DUV/pixel_line3
add wave -noupdate /bicubic_line_buffer_tb/DUV/input_end_of_line
add wave -noupdate /bicubic_line_buffer_tb/DUV/buf_wren
add wave -noupdate /bicubic_line_buffer_tb/DUV/nxt_output_valid
add wave -noupdate /bicubic_line_buffer_tb/DUV/buffered_lines
add wave -noupdate /bicubic_line_buffer_tb/DUV/read_lines
add wave -noupdate -radix binary /bicubic_line_buffer_tb/DUV/input_line_reg
add wave -noupdate -radix octal /bicubic_line_buffer_tb/DUV/startup_out_mux_sel
add wave -noupdate -radix octal /bicubic_line_buffer_tb/DUV/output_mux_sel
add wave -noupdate /bicubic_line_buffer_tb/DUV/output_line_reg
add wave -noupdate /bicubic_line_buffer_tb/DUV/out_padding_state
add wave -noupdate /bicubic_line_buffer_tb/DUV/nxt_out_padding_state
add wave -noupdate /bicubic_line_buffer_tb/DUV/in_exit_padding_state
add wave -noupdate /bicubic_line_buffer_tb/DUV/out_last_of_line
add wave -noupdate /bicubic_line_buffer_tb/DUV/out_last_same_line
add wave -noupdate -radix unsigned /bicubic_line_buffer_tb/DUV/input_x_reg
add wave -noupdate -radix unsigned /bicubic_line_buffer_tb/DUV/input_y_reg
add wave -noupdate -radix unsigned /bicubic_line_buffer_tb/DUV/output_x_reg
add wave -noupdate -radix unsigned /bicubic_line_buffer_tb/DUV/output_y_reg
add wave -noupdate /bicubic_line_buffer_tb/DUV/rd_same_line_reg
add wave -noupdate /bicubic_line_buffer_tb/DUV/buf_out_data
add wave -noupdate -radix unsigned /bicubic_line_buffer_tb/f
add wave -noupdate -radix unsigned /bicubic_line_buffer_tb/y
add wave -noupdate -radix unsigned /bicubic_line_buffer_tb/x
add wave -noupdate -group LBUF0 {/bicubic_line_buffer_tb/DUV/LINE_BUFFER_GEN[0]/line_buffer_ram/a_clk}
add wave -noupdate -group LBUF0 {/bicubic_line_buffer_tb/DUV/LINE_BUFFER_GEN[0]/line_buffer_ram/b_clk}
add wave -noupdate -group LBUF0 {/bicubic_line_buffer_tb/DUV/LINE_BUFFER_GEN[0]/line_buffer_ram/sreset}
add wave -noupdate -group LBUF0 {/bicubic_line_buffer_tb/DUV/LINE_BUFFER_GEN[0]/line_buffer_ram/a_addr}
add wave -noupdate -group LBUF0 {/bicubic_line_buffer_tb/DUV/LINE_BUFFER_GEN[0]/line_buffer_ram/a_data}
add wave -noupdate -group LBUF0 {/bicubic_line_buffer_tb/DUV/LINE_BUFFER_GEN[0]/line_buffer_ram/a_wren}
add wave -noupdate -group LBUF0 {/bicubic_line_buffer_tb/DUV/LINE_BUFFER_GEN[0]/line_buffer_ram/b_addr}
add wave -noupdate -group LBUF0 {/bicubic_line_buffer_tb/DUV/LINE_BUFFER_GEN[0]/line_buffer_ram/b_data}
add wave -noupdate -group LBUF0 -radix unsigned {/bicubic_line_buffer_tb/DUV/LINE_BUFFER_GEN[0]/line_buffer_ram/ram}
add wave -noupdate -group LBUF0 {/bicubic_line_buffer_tb/DUV/LINE_BUFFER_GEN[0]/line_buffer_ram/read_b}
add wave -noupdate -group LBUF1 {/bicubic_line_buffer_tb/DUV/LINE_BUFFER_GEN[1]/line_buffer_ram/a_clk}
add wave -noupdate -group LBUF1 {/bicubic_line_buffer_tb/DUV/LINE_BUFFER_GEN[1]/line_buffer_ram/b_clk}
add wave -noupdate -group LBUF1 {/bicubic_line_buffer_tb/DUV/LINE_BUFFER_GEN[1]/line_buffer_ram/sreset}
add wave -noupdate -group LBUF1 {/bicubic_line_buffer_tb/DUV/LINE_BUFFER_GEN[1]/line_buffer_ram/a_addr}
add wave -noupdate -group LBUF1 {/bicubic_line_buffer_tb/DUV/LINE_BUFFER_GEN[1]/line_buffer_ram/a_data}
add wave -noupdate -group LBUF1 {/bicubic_line_buffer_tb/DUV/LINE_BUFFER_GEN[1]/line_buffer_ram/a_wren}
add wave -noupdate -group LBUF1 -radix unsigned {/bicubic_line_buffer_tb/DUV/LINE_BUFFER_GEN[1]/line_buffer_ram/b_addr}
add wave -noupdate -group LBUF1 -radix unsigned {/bicubic_line_buffer_tb/DUV/LINE_BUFFER_GEN[1]/line_buffer_ram/b_data}
add wave -noupdate -group LBUF1 -radix unsigned {/bicubic_line_buffer_tb/DUV/LINE_BUFFER_GEN[1]/line_buffer_ram/ram}
add wave -noupdate -group LBUF1 {/bicubic_line_buffer_tb/DUV/LINE_BUFFER_GEN[1]/line_buffer_ram/read_b}
add wave -noupdate -group LBUF2 {/bicubic_line_buffer_tb/DUV/LINE_BUFFER_GEN[2]/line_buffer_ram/a_clk}
add wave -noupdate -group LBUF2 {/bicubic_line_buffer_tb/DUV/LINE_BUFFER_GEN[2]/line_buffer_ram/b_clk}
add wave -noupdate -group LBUF2 {/bicubic_line_buffer_tb/DUV/LINE_BUFFER_GEN[2]/line_buffer_ram/sreset}
add wave -noupdate -group LBUF2 {/bicubic_line_buffer_tb/DUV/LINE_BUFFER_GEN[2]/line_buffer_ram/a_addr}
add wave -noupdate -group LBUF2 {/bicubic_line_buffer_tb/DUV/LINE_BUFFER_GEN[2]/line_buffer_ram/a_data}
add wave -noupdate -group LBUF2 {/bicubic_line_buffer_tb/DUV/LINE_BUFFER_GEN[2]/line_buffer_ram/a_wren}
add wave -noupdate -group LBUF2 {/bicubic_line_buffer_tb/DUV/LINE_BUFFER_GEN[2]/line_buffer_ram/b_addr}
add wave -noupdate -group LBUF2 {/bicubic_line_buffer_tb/DUV/LINE_BUFFER_GEN[2]/line_buffer_ram/b_data}
add wave -noupdate -group LBUF2 {/bicubic_line_buffer_tb/DUV/LINE_BUFFER_GEN[2]/line_buffer_ram/ram}
add wave -noupdate -group LBUF2 {/bicubic_line_buffer_tb/DUV/LINE_BUFFER_GEN[2]/line_buffer_ram/read_b}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {25259 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 10
configure wave -gridperiod 20
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ns} {13126 ns}
