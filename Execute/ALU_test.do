vcom Execute/ALU.vhd -2008
vsim alu
add wave *

# Arithmetic
force -freeze sim:/alu/Opcode(3 downto 2) 10 0

force -freeze sim:/alu/A 32'h0F1F 0
force -freeze sim:/alu/B 32'h00F0 0

force -freeze sim:/alu/Opcode(1 downto 0) 00 0
run
force -freeze sim:/alu/Opcode(1 downto 0) 01 0
run
force -freeze sim:/alu/Opcode(1 downto 0) 10 0
run
force -freeze sim:/alu/Opcode(1 downto 0) 11 0
run

#subtraction to check flags
force -freeze sim:/alu/Opcode 1001 0
force -freeze sim:/alu/A 32'h0000 0
force -freeze sim:/alu/B 32'h0000 0
run
force -freeze sim:/alu/A 32'h0000 0
force -freeze sim:/alu/B 32'h0001 0
run
force -freeze sim:/alu/A 32'h0001 0
force -freeze sim:/alu/B 32'h0000 0
run
force -freeze sim:/alu/A 32'h0001 0
force -freeze sim:/alu/B 32'h0001 0
run

#Logic_shift
force -freeze sim:/ALU/A 32'd6 0
force -freeze sim:/ALU/B 32'd2 0
force -freeze sim:/ALU/Opcode 0100 0
run
force -freeze sim:/ALU/Opcode 0101 0
run
force -freeze sim:/ALU/Opcode 0110 0
run
force -freeze sim:/ALU/Opcode 0111 0
run
