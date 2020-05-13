vsim work.ram
add wave -position insertpoint sim:/ram/*
force -freeze sim:/ram/CLK 1 0, 0 {50 ps} -r 100


#write into address 00000000000
force -freeze sim:/ram/MEMWRITE 1 0
force -freeze sim:/ram/MEMREAD 0 0
force -freeze sim:/ram/ADDRESS 00000000000 0
force -freeze sim:/ram/DATAIN 00000000000001110000000000000110000000000000010100000000000001000000000000000011000000000000001000000000000000010000000000000000 0
run
force -freeze sim:/ram/MEMWRITE 0 0
run 400

#write into address 000 00001 000
force -freeze sim:/ram/MEMWRITE 1 0
force -freeze sim:/ram/MEMREAD 0 0
force -freeze sim:/ram/ADDRESS 00000001000 0
force -freeze sim:/ram/DATAIN 00000000000011110000000000001110000000000000110100000000000011000000000000001011000000000000101000000000000010010000000000001000 0
run
force -freeze sim:/ram/MEMWRITE 0 0
run 400

#read address  000 00000 000
force -freeze sim:/ram/MEMREAD 1 0
force -freeze sim:/ram/MEMWRITE 0 0
force -freeze sim:/ram/ADDRESS 00000000000 0
run
force -freeze sim:/ram/MEMREAD 0 0
run 400

#read address 00000001000 
force -freeze sim:/ram/MEMREAD 1 0
force -freeze sim:/ram/MEMWRITE 0 0
force -freeze sim:/ram/ADDRESS 00000001000 0
run
force -freeze sim:/ram/MEMREAD 0 0
run 400

#re-write into address 000 00000 000
force -freeze sim:/ram/MEMWRITE 1 0
force -freeze sim:/ram/MEMREAD 0 0
force -freeze sim:/ram/ADDRESS 00000000000 0
force -freeze sim:/ram/DATAIN 00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 0
run
force -freeze sim:/ram/MEMWRITE 0 0
run 400

#re-read address  000 00000 000
force -freeze sim:/ram/MEMREAD 1 0
force -freeze sim:/ram/MEMWRITE 0 0
force -freeze sim:/ram/ADDRESS 00000000000 0
run
force -freeze sim:/ram/MEMREAD 0 0
run 400
