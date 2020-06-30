set file_name {Branch.bin}

project compileoutofdate

vsim -gui work.processor

add wave *
add wave sim:/processor/IF_stage/*
add wave sim:/processor/IF_stage/instruction_mem/*
add wave sim:/processor/IF_stage/instruction_mem/memory
add wave -position insertpoint sim:/processor/IF_stage/PC/*
add wave -position insertpoint sim:/processor/MEM_stage/ram/memory

add wave -position insertpoint sim:/processor/MEM_stage/*

add wave processor/EX_FWD/*
add wave processor/EX_stage/*

add wave -position insertpoint sim:/processor/HZRD_UNIT/*

mem load -infile Assembler/tests/Delivery\ Cases/${file_name} -filldata 1110000000000000 -fillradix binary -format bin processor/IF_stage/instruction_mem/memory
mem load -infile Assembler/tests/Delivery\ Cases/${file_name} -filldata 1110000000000000 -fillradix binary -endaddress 3 -format bin processor/MEM_stage/ram/memory

force -freeze sim:/processor/clk 0 0, 1 {50 ps} -r 100
force processor/rst 0
force processor/int 0
run

force processor/rst 1
run

force processor/rst 0
run
run

force -freeze sim:/processor/in_port 32'h30 0
run

force -freeze sim:/processor/in_port 32'h50 0
run

force -freeze sim:/processor/in_port 32'h100 0
run

force -freeze sim:/processor/in_port 32'h300 0
run

force -freeze sim:/processor/in_port 32'hFFFFFFFF 0
run

force -freeze sim:/processor/in_port 32'hFFFFFFFF 0
run

run
run
run
force processor/int 1
run
force processor/int 0
run
force -freeze sim:/processor/in_port 32'h200 0
run

run 2000 ps
