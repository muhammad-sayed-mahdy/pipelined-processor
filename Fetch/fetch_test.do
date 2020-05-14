vsim -gui work.fetch
add wave -position insertpoint sim:/fetch/*
add wave -position end  sim:/fetch/bpram/ram
force -freeze sim:/fetch/clk 1 0, 0 {50 ps} -r 100
force -freeze sim:/fetch/rst 1 0
run
force -freeze sim:/fetch/rst 0 0
force -freeze sim:/fetch/mem_signal 0 0
force -freeze sim:/fetch/zero_flag 0 0
force -freeze sim:/fetch/skip_instruc 0 0
run
run
force -freeze sim:/fetch/reg_arr(0) 00000000000000000000000000000001 0
run
run
force -freeze sim:/fetch/zero_flag 1 0
force -freeze sim:/fetch/jz_address 00001111 0
force -freeze sim:/fetch/jz_singal 1 0
run
force -freeze sim:/fetch/zero_flag 1 0
run
force -freeze sim:/fetch/jz_singal 0 0
run
force -freeze sim:/fetch/mem_signal 1 0
force -freeze sim:/fetch/mem_val 00000000000000000000000000001110 0
run
force -freeze sim:/fetch/mem_signal 0 0
run
run