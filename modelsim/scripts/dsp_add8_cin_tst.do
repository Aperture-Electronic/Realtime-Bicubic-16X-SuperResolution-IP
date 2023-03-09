# Modelsim TCL Script file
# DSP 8-input Adder with Compensate Carry Input
# Designer:    Deng LiWei
# Date:        2020/03

# Compile the global files
vlog glbl.v
vlog ../src/sfr.sv
vlog ../src/sfr_ce.sv
vlog ../src/bicubic_global_settings.sv

# Compile IP files
vlog ../src/dsp_add3_cin.sv
vlog ../src/dsp_add_cascade_cin.sv
vlog ../src/dsp_add8_cin.sv
vlog ../sim/scb/dsp_add8_cin.scb.sv
vlog ../sim/ref/dsp_add8_cin.ref.sv
vlog ../sim/tb/dsp_add8_cin.tb.sv

# Simulation
vsim glbl work.dsp_add8_cin_tb -L secureip -L unisims_ver
run -all

