set file_name {hzrd.bin}

project compileoutofdate

vsim -gui work.processor

add wave *
add wave sim:/processor/IF_stage/*
add wave sim:/processor/IF_stage/instruction_mem/*
add wave sim:/processor/IF_stage/instruction_mem/memory
add wave sim:/processor/IF_stage/bpram/ram
add wave -position insertpoint sim:/processor/IF_stage/PC/*
add wave -position insertpoint sim:/processor/EX_stage/*
add wave -position insertpoint sim:/processor/MEM_stage/*
add wave -position insertpoint sim:/processor/MEM_stage/ram/memory
add wave -position insertpoint sim:/processor/HZRD_UNIT/*
add wave sim:/processor/IF_FWD/*

mem load -infile Assembler/tests/${file_name} -filldata 1110000000000000 -fillradix binary -format bin processor/IF_stage/instruction_mem/memory

force -freeze sim:/processor/MEM_stage/ram/memory(1) 0000000000000000
force -freeze sim:/processor/MEM_stage/ram/memory(3) 0000000001100100

force -freeze sim:/processor/clk 0 0, 1 {50 ps} -r 100
force processor/rst 0
force processor/int 0
run

force processor/rst 1
run

force processor/rst 0
run

#force -freeze sim:/processor/in_port 32'd55 0

run
run
noforce in_port

run 4000 ps
