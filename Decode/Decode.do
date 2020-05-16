vsim -gui work.decode(archdecode)
add wave sim:/decode/*

force -freeze sim:/decode/reg_arr(0) 'd1 0
force -freeze sim:/decode/reg_arr(1) 'd2 0
force -freeze sim:/decode/reg_arr(2) 'd3 0
force -freeze sim:/decode/reg_arr(3) 'd4 0
force -freeze sim:/decode/reg_arr(4) 'd5 0
force -freeze sim:/decode/reg_arr(5) 'd6 0
force -freeze sim:/decode/reg_arr(6) 'd7 0
force -freeze sim:/decode/reg_arr(7) 'd8 0
force -freeze sim:/decode/spReg 'd1500 0
force -freeze sim:/decode/instruction 'd0 0
force -freeze sim:/decode/inPort 'hFFFF 0
force -freeze sim:/decode/incrementedPc 'd1300 0
force -freeze sim:/decode/zflag 1 0
force -freeze sim:/decode/decision 1 0
run

force -freeze sim:/decode/instruction 'h0FFF 0
run

force -freeze sim:/decode/instruction 'h2FFF 0
run

force -freeze sim:/decode/instruction 0010011001000000 0
run

force -freeze sim:/decode/instruction 0011011001000000 0
run

force -freeze sim:/decode/instruction 0100011001000000 0
run

force -freeze sim:/decode/instruction 0101011001000000 0
run

force -freeze sim:/decode/instruction 0110011001000000 0
run

force -freeze sim:/decode/instruction 0111011001000000 0
run

force -freeze sim:/decode/instruction 1111011001000000 0
run

force -freeze sim:/decode/instruction 1001000001000000 0
run

force -freeze sim:/decode/instruction 1001000101000000 0
run

force -freeze sim:/decode/instruction 1001001001000000 0
run

force -freeze sim:/decode/instruction 1001011001000000 0
run

force -freeze sim:/decode/instruction 1001101001000000 0
run

force -freeze sim:/decode/instruction 1010001001000000 0
run

force -freeze sim:/decode/instruction 1010011001000000 0
run

force -freeze sim:/decode/instruction 1010100101000000 0
run

force -freeze sim:/decode/instruction 1011001001000000 0
run

force -freeze sim:/decode/instruction 1011010101000000 0
run

force -freeze sim:/decode/instruction 1100001101000000 0
run

force -freeze sim:/decode/instruction 1100010001000000 0
run

force -freeze sim:/decode/instruction 1100100101000000 0
run

force -freeze sim:/decode/zflag 0 0
run

force -freeze sim:/decode/decision 0 0
run

force -freeze sim:/decode/decision 1 0
run

force -freeze sim:/decode/instruction 1101010101000000 0
run

force -freeze sim:/decode/instruction 1101100101000000 0
run