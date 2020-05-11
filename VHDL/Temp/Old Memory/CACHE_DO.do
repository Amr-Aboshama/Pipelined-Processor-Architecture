vsim work.cache
add wave -position insertpoint sim:/cache/*

force -freeze sim:/cache/CLK 1 0, 0 {50 ps} -r 100

# write into cache from controller
force -freeze sim:/cache/INDEX 01000 0
force -freeze sim:/cache/DISPLACEMENT 000 0
force -freeze sim:/cache/CONTROLLERDATAIN 0100000000000000 0
force -freeze sim:/cache/CACHEWRITE 1 0
run

# write into cache from controller
force -freeze sim:/cache/INDEX 00010 0
force -freeze sim:/cache/DISPLACEMENT 111 0
force -freeze sim:/cache/CONTROLLERDATAIN 1111000011110000 0
force -freeze sim:/cache/CACHEWRITE 1 0
run

#read the first written data
force -freeze sim:/cache/CACHEWRITE 0 0
force -freeze sim:/cache/CACHEREAD 1 0
force -freeze sim:/cache/INDEX 01000 0
force -freeze sim:/cache/DISPLACEMENT 000 0
run

#read the second written data
force -freeze sim:/cache/CACHEWRITE 0 0
force -freeze sim:/cache/CACHEREAD 1 0
force -freeze sim:/cache/INDEX 00010 0
force -freeze sim:/cache/DISPLACEMENT 111 0
run

