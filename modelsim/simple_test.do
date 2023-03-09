vlib work
vmap work work

vlog ../src/*.sv
vlog ../sim/tb/*.sv
vlog ../sim/scb/*.sv
vlog ../sim/ref/*.sv
vlog ../sim/pkg/*.sv

vsim glbl work.bicubic_simple_tb -L secureip -L unisims_ver -L xpm -voptargs=+acc

vcd file wavedump.vcd

vcd add -r /*

run -all
