vsim work.ram

add wave -position insertpoint sim:/ram/*

force -freeze sim:/ram/CLK 1 0, 0 {50 ps} -r 100
force -freeze sim:/ram/MEMWRITE 1 0
force -freeze sim:/ram/ADDRESS 00000000001 0
force -freeze sim:/ram/DATAIN 0000000000000001 0

run
force -freeze sim:/ram/ADDRESS 00000000010 0
force -freeze sim:/ram/DATAIN 0000000000000010 0

run
force -freeze sim:/ram/ADDRESS 00000000011 0
force -freeze sim:/ram/DATAIN 0000000000000011 0

run
force -freeze sim:/ram/ADDRESS 00000000100 0
force -freeze sim:/ram/DATAIN 0000000000000100 0

run
force -freeze sim:/ram/ADDRESS 00000000101 0
force -freeze sim:/ram/DATAIN 0000000000000101 0

run
force -freeze sim:/ram/ADDRESS 00000000110 0
force -freeze sim:/ram/DATAIN 0000000000000110 0

run
force -freeze sim:/ram/ADDRESS 00000000111 0
force -freeze sim:/ram/DATAIN 0000000000000111 0

run
force -freeze sim:/ram/ADDRESS 00000001000 0
force -freeze sim:/ram/DATAIN 0000000000001000 0

run
force -freeze sim:/ram/ADDRESS 00000000001 0
force -freeze sim:/ram/MEMREAD 1 0
force -freeze sim:/ram/MEMWRITE 0 0

run
run
run
run