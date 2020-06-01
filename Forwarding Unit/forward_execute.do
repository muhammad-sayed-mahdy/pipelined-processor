vsim -gui work.forward_execute
add wave sim:/forward_execute/*

force -freeze sim:/forward_execute/Rsrc1 'h4 0
force -freeze sim:/forward_execute/Rsrc2 'h5 0
force -freeze sim:/forward_execute/Rsrc1_enable 1 0
force -freeze sim:/forward_execute/Rsrc2_enable 1 0
force -freeze sim:/forward_execute/Rdst_WB 'h5 0
force -freeze sim:/forward_execute/Rdst_Mem 'h4 0
force -freeze sim:/forward_execute/WB_WB 0 0
force -freeze sim:/forward_execute/Mem_WB 1 0
force -freeze sim:/forward_execute/FR1_WB 'h1 0
force -freeze sim:/forward_execute/FR2_WB 'h2 0
force -freeze sim:/forward_execute/FR1_Mem 'h3 0
force -freeze sim:/forward_execute/FR2_Mem 'h4 0
force -freeze sim:/forward_execute/decode_Operand1 'h5 0
force -freeze sim:/forward_execute/decode_Operand2 'h6 0
force -freeze sim:/forward_execute/op_Mem 'h0 0
force -freeze sim:/forward_execute/op_WB 'h0 0
force -freeze sim:/forward_execute/op_E 'h0 0
run

force -freeze sim:/forward_execute/Rdst_WB 'h4 0
force -freeze sim:/forward_execute/Rsrc1_Mem 'h5 0
force -freeze sim:/forward_execute/Rsrc1_WB 'h4 0
run

force -freeze sim:/forward_execute/WB_WB 1 0
force -freeze sim:/forward_execute/Mem_WB 0 0
run

force -freeze sim:/forward_execute/op_Mem 10 0
force -freeze sim:/forward_execute/op_WB 10 0
run

force -freeze sim:/forward_execute/op_E 10 0
run
