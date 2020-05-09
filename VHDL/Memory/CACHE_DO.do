vsim work.cache
add wave -position insertpoint sim:/cache/*
force -freeze sim:/cache/INDEX 01000 0
force -freeze sim:/cache/DISPLACEMENT 000 0
force -freeze sim:/cache/CONTROLLERDATAIN 0100000000000000 0
force -freeze sim:/cache/CACHEWRITE 1 0
run
force -freeze sim:/cache/CACHEWRITE 0 0
force -freeze sim:/cache/CACHEREAD 1 0
run
force -freeze sim:/cache/CONTROLLERDATAIN 0010000000000000 0
force -freeze sim:/cache/DISPLACEMENT 001 0
force -freeze sim:/cache/CACHEWRITE 1 0
force -freeze sim:/cache/CACHEREAD 0 0
run
force -freeze sim:/cache/CACHEREAD 1 0
force -freeze sim:/cache/CACHEWRITE 0 0
run
force -freeze sim:/cache/READYSIGNAL 1 0
force -freeze sim:/cache/CACHEREAD 0 0
force -freeze sim:/cache/RAMDATAIN 1111000011110000 0
force -freeze sim:/cache/DISPLACEMENT 010 0
run
force -freeze sim:/cache/READYSIGNAL 0 0
force -freeze sim:/cache/CACHEREAD 1 0
run