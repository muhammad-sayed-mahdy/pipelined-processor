set file_name {TwoOperand.bin}

project compileoutofdate

vsim -gui work.processor

add wave processor/clk
add wave processor/rst
add wave processor/in_port
add wave processor/out_port
add wave processor/reg_file_Q
add wave processor/FR_Q
add wave processor/IF_stage/curr_address

mem load -infile Assembler/tests/Delivery\ Cases/${file_name} -filldata 1110000000000000 -fillradix binary -format bin processor/IF_stage/instruction_mem/memory
mem load -infile Assembler/tests/Delivery\ Cases/${file_name} -filldata 1110000000000000 -fillradix binary -endaddress 3 -format bin processor/MEM_stage/ram/memory

force -freeze sim:/processor/clk 0 0, 1 {50 ps} -r 100
force processor/rst 0
force processor/int 0
run

force processor/rst 1
run

force processor/rst 0
run 400

force -freeze sim:/processor/in_port 32'h5 0
run

force -freeze sim:/processor/in_port 32'h19 0
run

force -freeze sim:/processor/in_port 32'hFFFD 0
run

force -freeze sim:/processor/in_port 32'hF320 0
run
noforce in_port

run 2000 ps
