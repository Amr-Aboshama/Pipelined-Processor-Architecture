vsim work.cachecontroller

add wave -position insertpoint sim:/cachecontroller/*

force -freeze sim:/cachecontroller/CLK 1 0, 0 {50 ps} -r 100
force -freeze sim:/cachecontroller/ADDRESSIN 00000010000 0
force -freeze sim:/cachecontroller/READSIGNAL 1 0
force -freeze sim:/cachecontroller/VALID(2) 1 0
force -freeze sim:/cachecontroller/TAGS(2) 000 0
run
run

force -freeze sim:/cachecontroller/ADDRESSIN 10100010001 0
force -freeze sim:/cachecontroller/READSIGNAL 1 0
force -freeze sim:/cachecontroller/VALID(2) 0 0
force -freeze sim:/cachecontroller/TAGS(2) 010 0
force -freeze sim:/cachecontroller/DIRTY(2) 1 0
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


force -freeze sim:/cachecontroller/ADDRESSIN 10100010001 0
force -freeze sim:/cachecontroller/READSIGNAL 0 0
force -freeze sim:/cachecontroller/WRITESIGNAL 1 0
force -freeze sim:/cachecontroller/VALID(2) 1 0
force -freeze sim:/cachecontroller/TAGS(2) 101 0
force -freeze sim:/cachecontroller/DATAIN 1111000011110000 0
run


force -freeze sim:/cachecontroller/WRITESIGNAL 1 0
force -freeze sim:/cachecontroller/ADDRESSIN 10100010001 0
force -freeze sim:/cachecontroller/VALID(2) 1 0
force -freeze sim:/cachecontroller/TAGS(2) 010 0
force -freeze sim:/cachecontroller/DIRTY(2) 1 0
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

