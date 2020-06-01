vcom Execute/logic_shift.vhd
vcom Execute/fullAddSub.vhd
vcom Execute/nFullAddSub.vhd
vcom Execute/arithmetic.vhd
vcom Execute/ALU.vhd -2008
vcom Execute/execute_stage.vhd -2008

vsim execute_stage
add wave *

# Arithmetic
force -freeze sim:/execute_stage/code 1000 0

force -freeze sim:/execute_stage/src1 32'h0F1F 0
force -freeze sim:/execute_stage/src2 32'h00F0 0
force -freeze sim:/execute_stage/src2Type 10 0
force -freeze sim:/execute_stage/opType 00 0
force -freeze sim:/execute_stage/secWord 32'd0 0
force -freeze sim:/execute_stage/EA1 32'd0 0
force -freeze sim:/execute_stage/rst 1 0
run
force -freeze sim:/execute_stage/rst 0 0

force -freeze sim:/execute_stage/code(1 downto 0) 00 0
run
force -freeze sim:/execute_stage/code(1 downto 0) 01 0
run
force -freeze sim:/execute_stage/code(1 downto 0) 10 0
run
force -freeze sim:/execute_stage/code(1 downto 0) 11 0
run

#subtraction to check flags
force -freeze sim:/execute_stage/code 1001 0
force -freeze sim:/execute_stage/src1 32'h0000 0
force -freeze sim:/execute_stage/src2 32'h0000 0
run
force -freeze sim:/execute_stage/src1 32'h0000 0
force -freeze sim:/execute_stage/src2 32'h0001 0
run
force -freeze sim:/execute_stage/src1 32'h0001 0
force -freeze sim:/execute_stage/src2 32'h0000 0
run
force -freeze sim:/execute_stage/src1 32'h0001 0
force -freeze sim:/execute_stage/src2 32'h0001 0
run

#not
force -freeze sim:/execute_stage/code 0010 0
run

#NOP
force -freeze sim:/execute_stage/code 0000 0
run

#logic_shift
force -freeze sim:/execute_stage/src1 32'd6 0
force -freeze sim:/execute_stage/src2 32'd2 0
force -freeze sim:/execute_stage/code 0110 0
run
force -freeze sim:/execute_stage/code 0111 0
run
#imm
force -freeze sim:/execute_stage/src2Type 00 0
force -freeze sim:/execute_stage/secWord 32'd3 0
force -freeze sim:/execute_stage/code 0100 0
run
force -freeze sim:/execute_stage/code 0101 0
run

#IAdd
force -freeze sim:/execute_stage/code 1000 0
run

#swap
force -freeze sim:/execute_stage/src2Type 10 0
force -freeze sim:/execute_stage/code 0000 0
force -freeze sim:/execute_stage/opType 01 0
run