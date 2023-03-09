onerror {resume}
quietly virtual function -install /bicubic_line_buffer_tb/refpx_buf -env /bicubic_line_buffer_tb/refpx_buf { (concat_noflatten)&{/bicubic_line_buffer_tb/refpx_buf/px_0_0_out, /bicubic_line_buffer_tb/refpx_buf/px_1_0_out, /bicubic_line_buffer_tb/refpx_buf/px_2_0_out, /bicubic_line_buffer_tb/refpx_buf/px_3_0_out }} ROW0
quietly virtual function -install /bicubic_line_buffer_tb/refpx_buf -env /bicubic_line_buffer_tb/refpx_buf { (concat_noflatten)&{/bicubic_line_buffer_tb/refpx_buf/px_0_1_out, /bicubic_line_buffer_tb/refpx_buf/px_1_1_out, /bicubic_line_buffer_tb/refpx_buf/px_2_1_out, /bicubic_line_buffer_tb/refpx_buf/px_3_1_out }} ROW1
quietly virtual function -install /bicubic_line_buffer_tb/refpx_buf -env /bicubic_line_buffer_tb/refpx_buf { (concat_noflatten)&{/bicubic_line_buffer_tb/refpx_buf/px_0_2_out, /bicubic_line_buffer_tb/refpx_buf/px_1_2_out, /bicubic_line_buffer_tb/refpx_buf/px_2_2_out, /bicubic_line_buffer_tb/refpx_buf/px_3_2_out }} ROW2
quietly virtual function -install /bicubic_line_buffer_tb/refpx_buf -env /bicubic_line_buffer_tb/refpx_buf { (concat_noflatten)&{/bicubic_line_buffer_tb/refpx_buf/px_0_3_out, /bicubic_line_buffer_tb/refpx_buf/px_1_3_out, /bicubic_line_buffer_tb/refpx_buf/px_2_3_out, /bicubic_line_buffer_tb/refpx_buf/px_3_3_out }} ROW3
quietly WaveActivateNextPane {} 0
add wave -noupdate /bicubic_line_buffer_tb/DUV/clk
add wave -noupdate /bicubic_line_buffer_tb/DUV/aresetn
add wave -noupdate /bicubic_line_buffer_tb/DUV/bram_reset
add wave -noupdate /bicubic_line_buffer_tb/DUV/clken
add wave -noupdate -radix unsigned /bicubic_line_buffer_tb/DUV/pixel_in
add wave -noupdate /bicubic_line_buffer_tb/DUV/pixel_in_valid
add wave -noupdate /bicubic_line_buffer_tb/DUV/pixel_in_start_of_frame
add wave -noupdate /bicubic_line_buffer_tb/DUV/pixel_in_end_of_line
add wave -noupdate /bicubic_line_buffer_tb/DUV/buffer_ready
add wave -noupdate /bicubic_line_buffer_tb/DUV/pixel_read_valid
add wave -noupdate /bicubic_line_buffer_tb/DUV/pipeline_ready
add wave -noupdate /bicubic_line_buffer_tb/DUV/pixel_out_valid
add wave -noupdate /bicubic_line_buffer_tb/DUV/pipeline_ready
add wave -noupdate -radix unsigned /bicubic_line_buffer_tb/DUV/out_repeat_reg
add wave -noupdate -expand -group SUPERBLK -expand -group IN -radix unsigned /bicubic_line_buffer_tb/DUV/sublk_y_reg
add wave -noupdate -radix binary /bicubic_line_buffer_tb/DUV/buffer_active_reg
add wave -noupdate -radix binary /bicubic_line_buffer_tb/DUV/buffer_wract_reg
add wave -noupdate /bicubic_line_buffer_tb/DUV/buffered_line
add wave -noupdate -radix unsigned /bicubic_line_buffer_tb/DUV/in_x_reg
add wave -noupdate -radix unsigned /bicubic_line_buffer_tb/DUV/out_x_reg
add wave -noupdate -radix binary /bicubic_line_buffer_tb/DUV/buffer_active_reg_pipe
add wave -noupdate -radix binary /bicubic_line_buffer_tb/DUV/out_padding_reg_pipe
add wave -noupdate -expand -group PXLINE_OUT -radix unsigned /bicubic_line_buffer_tb/DUV/pixel_line0
add wave -noupdate -expand -group PXLINE_OUT -radix unsigned /bicubic_line_buffer_tb/DUV/pixel_line1
add wave -noupdate -expand -group PXLINE_OUT -radix unsigned /bicubic_line_buffer_tb/DUV/pixel_line2
add wave -noupdate -expand -group PXLINE_OUT -radix unsigned /bicubic_line_buffer_tb/DUV/pixel_line3
add wave -noupdate -radix binary /bicubic_line_buffer_tb/DUV/out_padding_reg
add wave -noupdate /bicubic_line_buffer_tb/DUV/allow_write_to_buffer
add wave -noupdate -radix unsigned /bicubic_line_buffer_tb/DUV/buf_out_data
add wave -noupdate -radix unsigned /bicubic_line_buffer_tb/DUV/line_out_data
add wave -noupdate -group REFPX_BUF /bicubic_line_buffer_tb/refpx_buf/clk
add wave -noupdate -group REFPX_BUF /bicubic_line_buffer_tb/refpx_buf/aresetn
add wave -noupdate -group REFPX_BUF /bicubic_line_buffer_tb/refpx_buf/clken
add wave -noupdate -group REFPX_BUF -radix binary /bicubic_line_buffer_tb/refpx_buf/mux_ctrl
add wave -noupdate -group REFPX_BUF -radix unsigned /bicubic_line_buffer_tb/refpx_buf/line_0_in
add wave -noupdate -group REFPX_BUF -radix unsigned /bicubic_line_buffer_tb/refpx_buf/line_1_in
add wave -noupdate -group REFPX_BUF -radix unsigned /bicubic_line_buffer_tb/refpx_buf/line_2_in
add wave -noupdate -group REFPX_BUF -radix unsigned /bicubic_line_buffer_tb/refpx_buf/line_3_in
add wave -noupdate -group REFPX_BUF /bicubic_line_buffer_tb/refpx_buf/wren
add wave -noupdate -group REFPX_BUF -radix unsigned /bicubic_line_buffer_tb/refpx_buf/ROW0
add wave -noupdate -group REFPX_BUF -radix unsigned /bicubic_line_buffer_tb/refpx_buf/ROW1
add wave -noupdate -group REFPX_BUF -radix unsigned /bicubic_line_buffer_tb/refpx_buf/ROW2
add wave -noupdate -group REFPX_BUF -radix unsigned /bicubic_line_buffer_tb/refpx_buf/ROW3
add wave -noupdate -group PIPE_CTRL /bicubic_line_buffer_tb/PIPECTRL/clk
add wave -noupdate -group PIPE_CTRL /bicubic_line_buffer_tb/PIPECTRL/aresetn
add wave -noupdate -group PIPE_CTRL /bicubic_line_buffer_tb/PIPECTRL/clken
add wave -noupdate -group PIPE_CTRL /bicubic_line_buffer_tb/PIPECTRL/pixel_valid
add wave -noupdate -group PIPE_CTRL /bicubic_line_buffer_tb/PIPECTRL/pipeline_ready
add wave -noupdate -group PIPE_CTRL /bicubic_line_buffer_tb/PIPECTRL/mux_ctrl_to_refpx_buf
add wave -noupdate -group PIPE_CTRL /bicubic_line_buffer_tb/PIPECTRL/super_y_symmetric_to_symm_mux
add wave -noupdate -group PIPE_CTRL /bicubic_line_buffer_tb/PIPECTRL/sublk_x_reg
add wave -noupdate -group PIPE_CTRL /bicubic_line_buffer_tb/PIPECTRL/nxt_sublk_x_reg
add wave -noupdate -group PIPE_CTRL /bicubic_line_buffer_tb/PIPECTRL/sublk_last_column
add wave -noupdate -group PIPE_CTRL /bicubic_line_buffer_tb/PIPECTRL/sublk_enter_interval
add wave -noupdate -group PIPE_CTRL /bicubic_line_buffer_tb/PIPECTRL/sublk_y_symm_reg
add wave -noupdate -group PIPE_CTRL /bicubic_line_buffer_tb/PIPECTRL/mux_ctrl_to_pipeline
add wave -noupdate -group PIPE_CTRL /bicubic_line_buffer_tb/PIPECTRL/super_y_symmetric_to_pipeline
add wave -noupdate -group PIPE_CTRL /bicubic_line_buffer_tb/PIPECTRL/column_interval
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {147191 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 208
configure wave -valuecolwidth 235
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 5000
configure wave -gridperiod 10000
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {1419211 ps} {5188463 ps}
