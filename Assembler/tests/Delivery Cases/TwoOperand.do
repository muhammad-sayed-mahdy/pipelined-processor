set file_name {Delivery Cases/TwoOperand.bin}

project compileoutofdate

vsim -gui work.processor

add wave processor/reg_file_Q
add wave processor/IF_stage/curr_address
add wave processor/FR_Q
add wave processor/clk
add wave processor/rst
add wave processor/int
add wave processor/in_port
add wave processor/out_port

mem load -infile Assembler/tests/${file_name} -filldata 1110000000000000 -fillradix binary -format bin processor/IF_stage/instruction_mem/memory

force -freeze sim:/processor/MEM_stage/ram/memory(1) 0000000000010000
force -freeze sim:/processor/MEM_stage/ram/memory(3) 0000000100000000

force -freeze sim:/processor/clk 0 0, 1 {50 ps} -r 100
force processor/int 0
force processor/rst 1
run

force processor/rst 0
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

#run 4000 ps
