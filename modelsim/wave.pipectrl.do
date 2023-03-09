onerror {resume}
quietly virtual function -install /bicubic_pipeline_controller_tb/refpx_buf -env /bicubic_pipeline_controller_tb/refpx_buf { (concat_noflatten)&{/bicubic_pipeline_controller_tb/refpx_buf/px_0_0_out, /bicubic_pipeline_controller_tb/refpx_buf/px_1_0_out, /bicubic_pipeline_controller_tb/refpx_buf/px_2_0_out, /bicubic_pipeline_controller_tb/refpx_buf/px_3_0_out }} ROW0
quietly virtual function -install /bicubic_pipeline_controller_tb/refpx_buf -env /bicubic_pipeline_controller_tb/refpx_buf { (concat_noflatten)&{/bicubic_pipeline_controller_tb/refpx_buf/px_0_1_out, /bicubic_pipeline_controller_tb/refpx_buf/px_1_1_out, /bicubic_pipeline_controller_tb/refpx_buf/px_2_1_out, /bicubic_pipeline_controller_tb/refpx_buf/px_3_1_out }} ROW1
quietly virtual function -install /bicubic_pipeline_controller_tb/refpx_buf -env /bicubic_pipeline_controller_tb/refpx_buf { &{/bicubic_pipeline_controller_tb/refpx_buf/px_0_2_out, /bicubic_pipeline_controller_tb/refpx_buf/px_1_2_out, /bicubic_pipeline_controller_tb/refpx_buf/px_2_2_out, /bicubic_pipeline_controller_tb/refpx_buf/px_3_2_out }} ROW2
quietly virtual function -install /bicubic_pipeline_controller_tb/refpx_buf -env /bicubic_pipeline_controller_tb/refpx_buf { (concat_noflatten)&{/bicubic_pipeline_controller_tb/refpx_buf/px_0_2_out, /bicubic_pipeline_controller_tb/refpx_buf/px_1_2_out, /bicubic_pipeline_controller_tb/refpx_buf/px_2_2_out, /bicubic_pipeline_controller_tb/refpx_buf/px_3_2_out }} ROW2001
quietly virtual function -install /bicubic_pipeline_controller_tb/refpx_buf -env /bicubic_pipeline_controller_tb/refpx_buf { (concat_noflatten)&{/bicubic_pipeline_controller_tb/refpx_buf/px_0_3_out, /bicubic_pipeline_controller_tb/refpx_buf/px_1_3_out, /bicubic_pipeline_controller_tb/refpx_buf/px_2_3_out, /bicubic_pipeline_controller_tb/refpx_buf/px_3_3_out }} ROW3
quietly WaveActivateNextPane {} 0
add wave -noupdate /bicubic_pipeline_controller_tb/DUV/clk
add wave -noupdate /bicubic_pipeline_controller_tb/DUV/aresetn
add wave -noupdate /bicubic_pipeline_controller_tb/DUV/clken
add wave -noupdate /bicubic_pipeline_controller_tb/DUV/pixel_valid
add wave -noupdate /bicubic_pipeline_controller_tb/DUV/pipeline_ready
add wave -noupdate -radix unsigned /bicubic_pipeline_controller_tb/DUV/sublk_x_reg
add wave -noupdate -radix unsigned /bicubic_pipeline_controller_tb/DUV/nxt_sublk_x_reg
add wave -noupdate /bicubic_pipeline_controller_tb/DUV/sublk_last_column
add wave -noupdate -radix hexadecimal /bicubic_pipeline_controller_tb/DUV/mux_ctrl_to_refpx_buf
add wave -noupdate /bicubic_pipeline_controller_tb/DUV/sublk_enter_interval
add wave -noupdate /bicubic_pipeline_controller_tb/DUV/sublk_y_symm_reg
add wave -noupdate /bicubic_pipeline_controller_tb/DUV/mux_ctrl_to_pipeline
add wave -noupdate /bicubic_pipeline_controller_tb/DUV/super_y_symmetric_to_pipeline
add wave -noupdate /bicubic_pipeline_controller_tb/DUV/column_interval
add wave -noupdate /bicubic_pipeline_controller_tb/DUV/super_y_symmetric_to_symm_mux
add wave -noupdate -radix unsigned -childformat {{{/bicubic_pipeline_controller_tb/refpx_buf/px_buf[0]} -radix unsigned} {{/bicubic_pipeline_controller_tb/refpx_buf/px_buf[1]} -radix unsigned} {{/bicubic_pipeline_controller_tb/refpx_buf/px_buf[2]} -radix unsigned} {{/bicubic_pipeline_controller_tb/refpx_buf/px_buf[3]} -radix unsigned} {{/bicubic_pipeline_controller_tb/refpx_buf/px_buf[4]} -radix unsigned} {{/bicubic_pipeline_controller_tb/refpx_buf/px_buf[5]} -radix unsigned} {{/bicubic_pipeline_controller_tb/refpx_buf/px_buf[6]} -radix unsigned} {{/bicubic_pipeline_controller_tb/refpx_buf/px_buf[7]} -radix unsigned} {{/bicubic_pipeline_controller_tb/refpx_buf/px_buf[8]} -radix unsigned} {{/bicubic_pipeline_controller_tb/refpx_buf/px_buf[9]} -radix unsigned} {{/bicubic_pipeline_controller_tb/refpx_buf/px_buf[10]} -radix unsigned} {{/bicubic_pipeline_controller_tb/refpx_buf/px_buf[11]} -radix unsigned} {{/bicubic_pipeline_controller_tb/refpx_buf/px_buf[12]} -radix unsigned} {{/bicubic_pipeline_controller_tb/refpx_buf/px_buf[13]} -radix unsigned} {{/bicubic_pipeline_controller_tb/refpx_buf/px_buf[14]} -radix unsigned} {{/bicubic_pipeline_controller_tb/refpx_buf/px_buf[15]} -radix unsigned}} -subitemconfig {{/bicubic_pipeline_controller_tb/refpx_buf/px_buf[0]} {-height 17 -radix unsigned} {/bicubic_pipeline_controller_tb/refpx_buf/px_buf[1]} {-height 17 -radix unsigned} {/bicubic_pipeline_controller_tb/refpx_buf/px_buf[2]} {-height 17 -radix unsigned} {/bicubic_pipeline_controller_tb/refpx_buf/px_buf[3]} {-height 17 -radix unsigned} {/bicubic_pipeline_controller_tb/refpx_buf/px_buf[4]} {-height 17 -radix unsigned} {/bicubic_pipeline_controller_tb/refpx_buf/px_buf[5]} {-height 17 -radix unsigned} {/bicubic_pipeline_controller_tb/refpx_buf/px_buf[6]} {-height 17 -radix unsigned} {/bicubic_pipeline_controller_tb/refpx_buf/px_buf[7]} {-height 17 -radix unsigned} {/bicubic_pipeline_controller_tb/refpx_buf/px_buf[8]} {-height 17 -radix unsigned} {/bicubic_pipeline_controller_tb/refpx_buf/px_buf[9]} {-height 17 -radix unsigned} {/bicubic_pipeline_controller_tb/refpx_buf/px_buf[10]} {-height 17 -radix unsigned} {/bicubic_pipeline_controller_tb/refpx_buf/px_buf[11]} {-height 17 -radix unsigned} {/bicubic_pipeline_controller_tb/refpx_buf/px_buf[12]} {-height 17 -radix unsigned} {/bicubic_pipeline_controller_tb/refpx_buf/px_buf[13]} {-height 17 -radix unsigned} {/bicubic_pipeline_controller_tb/refpx_buf/px_buf[14]} {-height 17 -radix unsigned} {/bicubic_pipeline_controller_tb/refpx_buf/px_buf[15]} {-height 17 -radix unsigned}} /bicubic_pipeline_controller_tb/refpx_buf/px_buf
add wave -noupdate -radix unsigned /bicubic_pipeline_controller_tb/refpx_buf/line_0_in
add wave -noupdate -radix unsigned /bicubic_pipeline_controller_tb/refpx_buf/line_1_in
add wave -noupdate -radix unsigned /bicubic_pipeline_controller_tb/refpx_buf/line_2_in
add wave -noupdate -radix unsigned /bicubic_pipeline_controller_tb/refpx_buf/line_3_in
add wave -noupdate -radix binary /bicubic_pipeline_controller_tb/refpx_buf/mux_ctrl
add wave -noupdate -radix unsigned /bicubic_pipeline_controller_tb/l
add wave -noupdate -radix unsigned /bicubic_pipeline_controller_tb/c
add wave -noupdate -radix unsigned /bicubic_pipeline_controller_tb/q
add wave -noupdate -group SYMM_MUX /bicubic_pipeline_controller_tb/symm_mux/clk
add wave -noupdate -group SYMM_MUX /bicubic_pipeline_controller_tb/symm_mux/aresetn
add wave -noupdate -group SYMM_MUX /bicubic_pipeline_controller_tb/symm_mux/clken
add wave -noupdate -group SYMM_MUX /bicubic_pipeline_controller_tb/symm_mux/super_y_symmetric
add wave -noupdate -group SYMM_MUX -radix unsigned /bicubic_pipeline_controller_tb/symm_mux/px_0_0_in
add wave -noupdate -group SYMM_MUX -radix unsigned /bicubic_pipeline_controller_tb/symm_mux/px_1_0_in
add wave -noupdate -group SYMM_MUX -radix unsigned /bicubic_pipeline_controller_tb/symm_mux/px_2_0_in
add wave -noupdate -group SYMM_MUX -radix unsigned /bicubic_pipeline_controller_tb/symm_mux/px_3_0_in
add wave -noupdate -group SYMM_MUX -radix unsigned /bicubic_pipeline_controller_tb/symm_mux/px_0_1_in
add wave -noupdate -group SYMM_MUX -radix unsigned /bicubic_pipeline_controller_tb/symm_mux/px_1_1_in
add wave -noupdate -group SYMM_MUX -radix unsigned /bicubic_pipeline_controller_tb/symm_mux/px_2_1_in
add wave -noupdate -group SYMM_MUX -radix unsigned /bicubic_pipeline_controller_tb/symm_mux/px_3_1_in
add wave -noupdate -group SYMM_MUX -radix unsigned /bicubic_pipeline_controller_tb/symm_mux/px_0_2_in
add wave -noupdate -group SYMM_MUX -radix unsigned /bicubic_pipeline_controller_tb/symm_mux/px_1_2_in
add wave -noupdate -group SYMM_MUX -radix unsigned /bicubic_pipeline_controller_tb/symm_mux/px_2_2_in
add wave -noupdate -group SYMM_MUX -radix unsigned /bicubic_pipeline_controller_tb/symm_mux/px_3_2_in
add wave -noupdate -group SYMM_MUX -radix unsigned /bicubic_pipeline_controller_tb/symm_mux/px_0_3_in
add wave -noupdate -group SYMM_MUX -radix unsigned /bicubic_pipeline_controller_tb/symm_mux/px_1_3_in
add wave -noupdate -group SYMM_MUX -radix unsigned /bicubic_pipeline_controller_tb/symm_mux/px_2_3_in
add wave -noupdate -group SYMM_MUX -radix unsigned /bicubic_pipeline_controller_tb/symm_mux/px_3_3_in
add wave -noupdate -group SYMM_MUX -radix unsigned /bicubic_pipeline_controller_tb/symm_mux/dsp_grp_l_out
add wave -noupdate -group SYMM_MUX -radix unsigned /bicubic_pipeline_controller_tb/symm_mux/dsp_grp_h_out
add wave -noupdate -radix unsigned /bicubic_pipeline_controller_tb/refpx_buf/ROW0
add wave -noupdate -radix unsigned /bicubic_pipeline_controller_tb/refpx_buf/ROW1
add wave -noupdate -radix unsigned /bicubic_pipeline_controller_tb/refpx_buf/ROW2001
add wave -noupdate -radix unsigned /bicubic_pipeline_controller_tb/refpx_buf/ROW3
add wave -noupdate -group COL0 -radix unsigned /bicubic_pipeline_controller_tb/refpx_buf/px_0_0_out
add wave -noupdate -group COL0 -radix unsigned /bicubic_pipeline_controller_tb/refpx_buf/px_0_1_out
add wave -noupdate -group COL0 -radix unsigned /bicubic_pipeline_controller_tb/refpx_buf/px_0_2_out
add wave -noupdate -group COL0 -radix unsigned /bicubic_pipeline_controller_tb/refpx_buf/px_0_3_out
add wave -noupdate -group COL1 -radix unsigned /bicubic_pipeline_controller_tb/refpx_buf/px_1_0_out
add wave -noupdate -group COL1 -radix unsigned /bicubic_pipeline_controller_tb/refpx_buf/px_1_1_out
add wave -noupdate -group COL1 -radix unsigned /bicubic_pipeline_controller_tb/refpx_buf/px_1_2_out
add wave -noupdate -group COL1 -radix unsigned /bicubic_pipeline_controller_tb/refpx_buf/px_1_3_out
add wave -noupdate -group COL2 -radix unsigned /bicubic_pipeline_controller_tb/refpx_buf/px_2_0_out
add wave -noupdate -group COL2 -radix unsigned /bicubic_pipeline_controller_tb/refpx_buf/px_2_1_out
add wave -noupdate -group COL2 -radix unsigned /bicubic_pipeline_controller_tb/refpx_buf/px_2_2_out
add wave -noupdate -group COL2 -radix unsigned /bicubic_pipeline_controller_tb/refpx_buf/px_2_3_out
add wave -noupdate -group COL3 -radix unsigned /bicubic_pipeline_controller_tb/refpx_buf/px_3_0_out
add wave -noupdate -group COL3 -radix unsigned /bicubic_pipeline_controller_tb/refpx_buf/px_3_1_out
add wave -noupdate -group COL3 -radix unsigned /bicubic_pipeline_controller_tb/refpx_buf/px_3_2_out
add wave -noupdate -group COL3 -radix unsigned /bicubic_pipeline_controller_tb/refpx_buf/px_3_3_out
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {215 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 179
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
WaveRestoreZoom {186 ns} {301 ns}
