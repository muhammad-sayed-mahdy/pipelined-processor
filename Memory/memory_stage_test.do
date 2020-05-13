vcom Memory/memory_stage.vhd
vcom Memory/memory.vhd
vsim memory_stage
add wave *
force -freeze sim:/memory_stage/clk 1 0, 0 {50 ps} -r 100
force -freeze sim:/memory_stage/memWrite 0 0
force -freeze sim:/memory_stage/memRead 1 0
force -freeze sim:/memory_stage/address 32'd0 0
force -freeze sim:/memory_stage/datain 32'd5 0
run
force -freeze sim:/memory_stage/memWrite 1 0
run
force -freeze sim:/memory_stage/address 32'd2 0
force -freeze sim:/memory_stage/memWrite 0 0
run