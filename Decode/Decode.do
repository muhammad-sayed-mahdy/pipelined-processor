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
run

force -freeze sim:/decode/instruction 'h0FFF 0
run

force -freeze sim:/decode/instruction 'h2FFF 0
run

force -freeze sim:/decode/instruction 0010011001000000 0
run

force -freeze sim:/decode/instruction 0010011001000000 0
run
