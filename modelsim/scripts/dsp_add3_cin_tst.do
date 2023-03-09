# Modelsim TCL Script file
# DSP 3-input Adder with Compensate Carry Input Test
# Designer:    Deng LiWei
# Date:        2020/03

# Compile the global files
vlog glbl.v
vlog ../src/sfr.sv
vlog ../src/bicubic_global_settings.sv

# Compile IP files
vlog ../src/dsp_add3_cin.sv
vlog ../sim/scb/dsp_add3_cin.scb.sv
vlog ../sim/ref/dsp_add3_cin.ref.sv
vlog ../sim/tb/dsp_add3_cin.tb.sv

# Simulation
vsim glbl work.dsp_add3_cin_tb -L secureip -L unisims_ver
run -all

