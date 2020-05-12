
force -freeze sim:/memorymodule/M_CLK 1 0, 0 {50 ps} -r 100

# write-miss dirty=0
force -freeze sim:/memorymodule/M_WRITE 1 0
force -freeze sim:/memorymodule/M_READ 0 0
force -freeze sim:/memorymodule/M_DATAIN 0000111100001111 0
force -freeze sim:/memorymodule/M_ADDRESS 11100010000 0
run 700


# write-miss dirty=0
force -freeze sim:/memorymodule/M_WRITE 1 0
force -freeze sim:/memorymodule/M_READ 0 0
force -freeze sim:/memorymodule/M_DATAIN 1111000011110000 0
force -freeze sim:/memorymodule/M_ADDRESS 10100001000 0
run 700


# read-hit 
force -freeze sim:/memorymodule/M_WRITE 0 0
force -freeze sim:/memorymodule/M_READ 1 0
force -freeze sim:/memorymodule/M_ADDRESS 11100010000 0
force -freeze sim:/memorymodule/M_DATAIN 0000000000000000 0
run 300


# read-hit 
force -freeze sim:/memorymodule/M_WRITE 0 0
force -freeze sim:/memorymodule/M_READ 1 0
force -freeze sim:/memorymodule/M_ADDRESS 10100001000 0
force -freeze sim:/memorymodule/M_DATAIN 0000000000000000 0
run 300


#write-miss dirty = 1
force -freeze sim:/memorymodule/M_WRITE 1 0
force -freeze sim:/memorymodule/M_READ 0 0
force -freeze sim:/memorymodule/M_DATAIN 1100110011001100 0
force -freeze sim:/memorymodule/M_ADDRESS 01000010001 0
run 1000

#read-hit
force -freeze sim:/memorymodule/M_WRITE 0 0
force -freeze sim:/memorymodule/M_READ 1 0
force -freeze sim:/memorymodule/M_DATAIN 0000000000000000 0
force -freeze sim:/memorymodule/M_ADDRESS 01000010001 0
run 300

# read-miss dirty = 1
force -freeze sim:/memorymodule/M_WRITE 0 0
force -freeze sim:/memorymodule/M_READ 1 0
force -freeze sim:/memorymodule/M_ADDRESS 11100010000 0
force -freeze sim:/memorymodule/M_DATAIN 0000000000000000 0
run 1100


# write-hit 
force -freeze sim:/memorymodule/M_WRITE 1 0
force -freeze sim:/memorymodule/M_READ 0 0
force -freeze sim:/memorymodule/M_ADDRESS 11100010000 0
force -freeze sim:/memorymodule/M_DATAIN 1111111111111111 0
run 300


# read-hit 
force -freeze sim:/memorymodule/M_WRITE 0 0
force -freeze sim:/memorymodule/M_READ 1 0
force -freeze sim:/memorymodule/M_ADDRESS 11100010000 0
force -freeze sim:/memorymodule/M_DATAIN 0000000000000000 0
run 300

# read-miss dirty = 0
force -freeze sim:/memorymodule/M_WRITE 0 0
force -freeze sim:/memorymodule/M_READ 1 0
force -freeze sim:/memorymodule/M_ADDRESS 11111111111 0
force -freeze sim:/memorymodule/M_DATAIN 0000000000000000 0
run 1100