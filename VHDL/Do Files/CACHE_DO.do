vsim work.cache
add wave -position insertpoint sim:/cache/*

force -freeze sim:/cache/CLK 1 0, 0 {50 ps} -r 100

# write into cache from controller
force -freeze sim:/cache/CACHEWRITE 1 0
force -freeze sim:/cache/INDEX 01000 0
force -freeze sim:/cache/DISPLACEMENT 000 0
force -freeze sim:/cache/CONTROLLERDATAIN 0100000000000000 0
run
force -freeze sim:/cache/CACHEWRITE 0 0
run

# write into cache from controller
force -freeze sim:/cache/CACHEWRITE 1 0
force -freeze sim:/cache/INDEX 00100 0
force -freeze sim:/cache/DISPLACEMENT 000 0
force -freeze sim:/cache/CONTROLLERDATAIN 0010000000000000 0
run
force -freeze sim:/cache/CACHEWRITE 0 0
run

#read the first written data
force -freeze sim:/cache/CACHEREAD 1 0
force -freeze sim:/cache/INDEX 01000 0
force -freeze sim:/cache/DISPLACEMENT 000 0
run
force -freeze sim:/cache/CACHEREAD 0 0
run

#read the first written data
force -freeze sim:/cache/CACHEREAD 1 0
force -freeze sim:/cache/INDEX 00100 0
force -freeze sim:/cache/DISPLACEMENT 000 0
run
force -freeze sim:/cache/CACHEREAD 0 0
run

# write into cache from RAM
force -freeze sim:/cache/MEMORYREAD 1 0
force -freeze sim:/cache/INDEX 01000 0
force -freeze sim:/cache/RAMDATAIN 11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111 0
run
force -freeze sim:/cache/MEMORYREAD 0 0
run


#read the data written from memory
force -freeze sim:/cache/CACHEREAD 1 0
force -freeze sim:/cache/INDEX 01000 0
force -freeze sim:/cache/DISPLACEMENT 000 0
run
force -freeze sim:/cache/CACHEREAD 0 0
run


# write into ram 
force -freeze sim:/cache/MEMORYWRITE 1 0
force -freeze sim:/cache/INDEX 01000 0
force -freeze sim:/cache/CONTROLLERDATAIN 0100000000000000 0
run
force -freeze sim:/cache/MEMORYWRITE 0 0
run

