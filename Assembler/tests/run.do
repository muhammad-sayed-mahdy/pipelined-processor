set file_name {memory.bin}

project compileoutofdate

vsim -gui work.processor

add wave *
add wave sim:/processor/IF_stage/*
add wave sim:/processor/IF_stage/instruction_mem/*
add wave sim:/processor/IF_stage/instruction_mem/memory
add wave -position insertpoint sim:/processor/IF_stage/PC/*
add wave -position insertpoint sim:/processor/MEM_stage/ram/memory

add wave -position insertpoint sim:/processor/MEM_stage/*

add wave -position insertpoint sim:/processor/GEN_IF_ID/*

add wave processor/EX_FWD/*
add wave processor/EX_stage/*

mem load -infile Assembler/tests/${file_name} -filldata 1110000000000000 -fillradix binary -format bin processor/IF_stage/instruction_mem/memory

force -freeze sim:/processor/MEM_stage/ram/memory(1) 0000000000010000
force -freeze sim:/processor/MEM_stage/ram/memory(3) 0000000100000000
run

noforce processor/MEM_stage/ram/memory(1)
noforce processor/MEM_stage/ram/memory(3)

force -freeze sim:/processor/clk 0 0, 1 {50 ps} -r 100
force processor/int 0
force processor/rst 1
run

force processor/rst 0
run
run

force -freeze sim:/processor/in_port 32'h5 0
run

force -freeze sim:/processor/in_port 32'h19 0
run

force -freeze sim:/processor/in_port 32'hFFFD 0
run

force -freeze sim:/processor/in_port 32'hF320 0
run
noforce in_port

run
run

run 3000 ps
