set file_name {Delivery Cases/Memory.bin}

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
mem load -infile Assembler/tests/${file_name} -filldata 1110000000000000 -fillradix binary -endaddress 3 -format bin processor/MEM_stage/ram/memory

force -freeze sim:/processor/clk 0 0, 1 {50 ps} -r 100
force processor/int 0
force processor/rst 1
run

force processor/rst 0
run
run

force -freeze sim:/processor/in_port 32'h0CDAFE19 0
run

force -freeze sim:/processor/in_port 32'hFFFF 0
run

force -freeze sim:/processor/in_port 32'hF320 0
run

force -freeze sim:/processor/in_port 32'hF320 0
run
noforce in_port

run

#run 4000 ps
