vcom Memory/memory.vhd
vsim memory
add wave *
force -freeze sim:/memory/clk 1 0, 0 {50 ps} -r 100
force -freeze sim:/memory/we 0 0
force -freeze sim:/memory/address 11'd0 0
force -freeze sim:/memory/datain 128'd5 0
run
force -freeze sim:/memory/we 1 0
run
force -freeze sim:/memory/address 00000000010 0
force -freeze sim:/memory/we 0 0
run