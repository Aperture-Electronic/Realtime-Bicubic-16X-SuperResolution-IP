# Modelsim TCL Script file
# DSP 2x INT9xUINT8 Cascade Adding Test
# Designer:    Deng LiWei
# Date:        2020/03

# Compile the global files
vlog glbl.v
vlog ../src/sfr.sv
vlog ../src/bicubic_global_settings.sv

# Compile IP files
vlog ../src/dsp_simd2x_int9xuint8.sv
vlog ../src/dsp_simd2x_int9xuint8_cascade_add.sv
vlog ../sim/scb/dsp_simd2x_int9xuint8_cascade_add.scb.sv
vlog ../sim/ref/dsp_simd2x_int9xuint8_cascade_add.ref.sv
vlog ../sim/tb/dsp_simd2x_int9xuint8_cascade_add.tb.sv

# Simulation
vsim glbl work.dsp_simd2x_int9xuint8_cascade_add_tb -L secureip -L unisims_ver
run -all

