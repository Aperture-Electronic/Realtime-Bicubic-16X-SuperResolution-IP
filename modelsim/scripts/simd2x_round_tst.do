# Modelsim TCL Script file
# SIMD 2x Rounding Module
# Designer:    Deng LiWei
# Date:        2020/03

# Compile the global files
vlog glbl.v
vlog ../src/sfr.sv
vlog ../src/bicubic_global_settings.sv

# Compile IP files
vlog ../src/dsp_simd2x_int24_add.sv
vlog ../src/simd2x_round.sv
vlog ../sim/scb/simd2x_round.scb.sv
vlog ../sim/ref/simd2x_round.ref.sv
vlog ../sim/tb/simd2x_round.tb.sv

# Simulation
vsim glbl work.simd2x_round_tb -L secureip -L unisims_ver
run -all

