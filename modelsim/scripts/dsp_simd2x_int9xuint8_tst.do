# Modelsim TCL Script file
# DSP SIMD 2x INT9xUINT8 Test
# Designer:    Deng LiWei
# Date:        2020/03

# Compile the global files
vlog glbl.v
vlog ../src/sfr.sv
vlog ../src/bicubic_global_settings.sv

# Compile IP files
vlog ../src/dsp_simd2x_int9xuint8.sv
vlog ../sim/scb/dsp_simd2x_int9xuint8.scb.sv
vlog ../sim/ref/dsp_simd2x_int9xuint8.ref.sv
vlog ../sim/tb/dsp_simd2x_int9xuint8.tb.sv

# Simulation
vsim glbl work.dsp_simd2x_int9xuint8_tb -L secureip -L unisims_ver
run -all

