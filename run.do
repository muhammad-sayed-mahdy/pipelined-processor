vsim -gui work.processor

add wave *
add wave sim:/processor/IF_stage/instruction_mem/*

force -freeze sim:/processor/clk 0 0, 1 {50 ps} -r 100
force processor/rst 0
force processor/int 0

run

force processor/rst 1

run

force processor/rst 0

run

