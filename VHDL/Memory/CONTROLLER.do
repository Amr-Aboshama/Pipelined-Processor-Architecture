vsim work.cachecontroller

add wave -position insertpoint sim:/cachecontroller/*

force -freeze sim:/cachecontroller/CLK 1 0, 0 {50 ps} -r 100

#write- miss dirty bit not equal 1 
force -freeze sim:/cachecontroller/READSIGNAL 0 0
force -freeze sim:/cachecontroller/WRITESIGNAL 1 0
force -freeze sim:/cachecontroller/DATAIN 1111000011110000 0
force -freeze sim:/cachecontroller/ADDRESSIN 10100010001 0
run
run
run
run
run
run

#write- miss dirty bit not equal 1 
force -freeze sim:/cachecontroller/READSIGNAL 0 0
force -freeze sim:/cachecontroller/WRITESIGNAL 1 0
force -freeze sim:/cachecontroller/DATAIN 0000111100001111 0
force -freeze sim:/cachecontroller/ADDRESSIN 11100100000 0
run
run
run
run
run
run
run

#write- miss on index 00010 with different tag (dirtybit = 1)
force -freeze sim:/cachecontroller/READSIGNAL 0 0
force -freeze sim:/cachecontroller/WRITESIGNAL 1 0
force -freeze sim:/cachecontroller/DATAIN 1100110011001100 0
force -freeze sim:/cachecontroller/ADDRESSIN 11100010001 0
run
run
run
run
run
run
run
run
run
run
run

#read-hit from cache 
force -freeze sim:/cachecontroller/WRITESIGNAL 0 0
force -freeze sim:/cachecontroller/READSIGNAL 1 0
force -freeze sim:/cachecontroller/ADDRESSIN 11100010001 0
run

#read- miss from index 00010
force -freeze sim:/cachecontroller/WRITESIGNAL 0 0
force -freeze sim:/cachecontroller/READSIGNAL 1 0
force -freeze sim:/cachecontroller/ADDRESSIN 10100010001 0
run
run
run
run
run
run
run
run
run
run




