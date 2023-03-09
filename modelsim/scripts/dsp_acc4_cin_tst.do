# Modelsim TCL Script file
# DSP 4-input Accumulator with Compensate Carry Input Test
# Designer:    Deng LiWei
# Date:        2020/03

# Compile the global files
vlog glbl.v
vlog ../src/sfr.sv
vlog ../src/bicubic_global_settings.sv

# Compile IP files
vlog ../src/dsp_add3_cin.sv
vlog ../src/dsp_acc_cascade_cin.sv
vlog ../src/dsp_acc4_cin.sv
vlog ../sim/scb/dsp_acc4_cin.scb.sv
vlog ../sim/ref/dsp_acc4_cin.ref.sv
vlog ../sim/tb/dsp_acc4_cin.tb.sv

# Simulation
vsim glbl work.dsp_acc4_cin_tb -L secureip -L unisims_ver
run -all

