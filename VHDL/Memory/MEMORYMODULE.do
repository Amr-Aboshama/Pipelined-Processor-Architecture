vsim work.memorymodule

add wave -position insertpoint sim:/memorymodule/*

# write- miss dirty =0
force -freeze sim:/memorymodule/M_CLK 1 0, 0 {50 ps} -r 100
force -freeze sim:/memorymodule/M_DATAIN 1111000011110000 0
force -freeze sim:/memorymodule/M_ADDRESS 10100010001 0
force -freeze sim:/memorymodule/M_WRITE 1 0
run
force -freeze sim:/memorymodule/M_WRITE 0 0
run
run
run
run
run

# read-hit 
force -freeze sim:/memorymodule/M_READ 1 0
force -freeze sim:/memorymodule/M_ADDRESS 10100010001 0
run
force -freeze sim:/memorymodule/M_READ 0 0
run 

# write - hit 
force -freeze sim:/memorymodule/M_WRITE 1 0
force -freeze sim:/memorymodule/M_ADDRESS 10100010001 0
force -freeze sim:/memorymodule/M_DATAIN 1111110011001100 0
run 
force -freeze sim:/memorymodule/M_WRITE 0 0
run


force -freeze sim:/memorymodule/M_READ 1 0
force -freeze sim:/memorymodule/M_ADDRESS 10100010001 0
run
force -freeze sim:/memorymodule/M_READ 0 0
run