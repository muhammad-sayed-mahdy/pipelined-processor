set file_name {OneOperand.bin}

project compileoutofdate

vsim -gui work.processor

add wave sim:/processor/clk
add wave sim:/processor/rst
add wave sim:/processor/in_port
add wave sim:/processor/out_port
add wave sim:/processor/reg_file_Q
add wave sim:/processor/FR_Q
add wave sim:/processor/IF_stage/curr_address

mem load -infile Assembler/tests/Delivery\ Cases/${file_name} -filldata 1110000000000000 -fillradix binary -format bin processor/IF_stage/instruction_mem/memory
mem load -infile Assembler/tests/Delivery\ Cases/${file_name} -filldata 1110000000000000 -fillradix binary -endaddress 3 -format bin processor/MEM_stage/ram/memory

force -freeze sim:/processor/clk 0 0, 1 {50 ps} -r 100
force processor/rst 0
force processor/int 0
run

force processor/rst 1
run

force processor/rst 0

#(run 700) in case that `in instruction` is seen in decode stage (version-1),
# make it (run 500) if `in` is in fetch stage
run 700

force -freeze sim:/processor/in_port 32'h5 0
run

force -freeze sim:/processor/in_port 32'h10 0
run
noforce in_port

run 900

